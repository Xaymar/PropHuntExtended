--[[
	The MIT License (MIT)
	
	Copyright (c) 2015 Xaymar

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]

DEFINE_BASECLASS("player_default")
local CLASS = {}
CLASS.DisplayName		= "Default"
CLASS.WalkSpeed			= 250		-- How fast to move when not running
CLASS.RunSpeed			= 500		-- How fast to move when running
CLASS.CrouchedWalkSpeed	= 0.5		-- Multiply move speed by this when crouching
CLASS.DuckSpeed			= 0.2		-- How fast to go from not ducking, to ducking
CLASS.UnDuckSpeed		= 0.2		-- How fast to go from ducking, to not ducking
CLASS.JumpPower			= 200		-- How powerful our jump should be
CLASS.CanUseFlashlight	= false		-- Can we use the flashlight
CLASS.MaxHealth			= 100		-- Max health we can have
CLASS.StartHealth		= 100		-- How much health we start with
CLASS.StartArmor		= 0			-- How much armour we start with
CLASS.DropWeaponOnDie	= false		-- Do we drop our weapon when we die
CLASS.TeammateNoCollide	= true		-- Do we collide with teammates or run straight through them
CLASS.AvoidPlayers		= true		-- Automatically swerves around other players
CLASS.UseVMHands		= true		-- Uses viewmodel hands

-- ------------------------------------------------------------------------- --
--! Server-Side
-- ------------------------------------------------------------------------- --
-- Spawn
function CLASS:InitialSpawn()
	self.Player.Data = {}
	self.Player.Data.SelectionHaloTime = CurTime()	
end
function CLASS:Spawn() end
function CLASS:Loadout() end

-- Damage
function CLASS:ShouldTakeDamage(attacker) return true end -- Should take damage from attacker?
function CLASS:Hurt(victim, attacker, healthRemaining, damageTaken) end -- Damage Taken
function CLASS:Damage(victim, attacker, healthRemaining, damageDealt) end -- Damage Dealt
function CLASS:DamageEntity(ent, attacker, dmginfo) end -- Damage Dealt To Entity

-- Death
function CLASS:Death(inflictor, attacker)
	self.Player.Data.Alive = false
	self.Player.Data.AliveTime = CurTime()
	-- Score support
	self.Player:AddDeaths(1)
	if IsValid(attacker) && attacker:IsPlayer() then
		if ((attacker == self.Player)
			|| (attacker:Team() == self.Player:Team())) then
			self.Player:AddFrags(-1)
		end
	end
end
function CLASS:SilentDeath()
	self.Player.Data.Alive = false
	self.Player.Data.AliveTime = CurTime()
end
function CLASS:PostDeath() end
function CLASS:DoDeath() end
function CLASS:DeathThink()
	if (CurTime() - self.Player.Data.AliveTime) > 5 then
		self.Player:Spawn()
		return true
	end
	return false
end
function CLASS:CanSuicide() return true end

-- Visible Stuff
function CLASS:SetModel() BaseClass.SetModel( self ) end

-- Interaction
function CLASS:Use(ent)
	-- Entity must be valid and not a player.
	if (!ent || !ent:IsValid()) then
		return false
	end
	
	-- Cool Down
	if (self.Player.Data.UseTime) then
		local timeSinceUse = (CurTime() - self.Player.Data.UseTime)
		if (0.5 > timeSinceUse) then
			return false
		end
		
		-- Abuse Blacklist (Buttons, Doors, etc)
		if (5 > timeSinceUse) then
			local abuseBlacklist = GAMEMODE.Config.Lists:AbuseBlacklist()
			if (table.HasValue(abuseBlacklist, ent:GetClass())) then
				return false
			end
		end
	end
	self.Player.Data.UseTime = CurTime()
	
	return true
end
function CLASS:AllowPickup(ent) return false end
function CLASS:CanPickupWeapon(ent) return false end
function CLASS:CanPickupItem(ent) return false end

-- Menu (Always Server)
function CLASS:ShowSpare1()
	local lastTaunt = (self.Player.Data.LastTaunt or 0)
	if ((CurTime() - lastTaunt) <= GAMEMODE.Config.Taunt:Cooldown()) then
		return true
	end
	self.Player.Data.LastTaunt = CurTime()
end
function CLASS:ShowSpare2() end

-- ------------------------------------------------------------------------- --
--! Shared
-- ------------------------------------------------------------------------- --
function CLASS:PostThink() end
function CLASS:Tick(mv) end 
function CLASS:FindUseEntity(defEnt) return defEnt end
function CLASS:Alive() return false end

-- ------------------------------------------------------------------------- --
--! Client-Side
-- ------------------------------------------------------------------------- --
-- Spawn
function CLASS:InitialClientSpawn()
	self.Player.Data = {}
	self.Player.Data.ThirdPerson = false -- Default to FirstPerson View
end
function CLASS:ClientSpawn() end

-- View & HUD
function CLASS:GetHandsModel() return BaseClass.GetHandsModel(self) end
function CLASS:ShouldDrawLocal() return false end
function CLASS:HUDPaint()
	-- Death Notices
	GAMEMODE:DrawDeathNotice((ScrW() - 192) / ScrW() , 24 / ScrH())
end
function CLASS:CalcView(camdata)
	-- Config
	local cameraCollision		= GAMEMODE.Config.Camera:Collisions()
	local cameraDistance		= GAMEMODE.Config.Camera:Distance()
	local cameraDistanceRight	= GAMEMODE.Config.Camera:DistanceRight()
	local cameraDistanceUp		= GAMEMODE.Config.Camera:DistanceUp()
	local cameraLag				= GAMEMODE.Config.Camera:Lag()
	local cameraLagInv			= 1 - cameraLag	
	
	-- First/Third Person Target Distance
	local targetDistance = 0
	if (self.Player.Data.ThirdPerson) then -- Incremental Distance instead of instant.
		targetDistance = cameraDistance
		
		if (cameraCollision == true) then
			-- Trace from Player to would-be camera position
			local trace = {
				start = camdata.origin,
				endpos = camdata.origin - (camdata.angles:Forward() * cameraDistance),
				--filter = { "worldspawn", "ph_prop", "player" },
				--[-[
				filter = function(ent)
					local filter = { "worldspawn", "ph_prop", "player" }
					
					if (ent:IsPlayer())
						|| (table.HasValue(filter, ent:GetClass()))
						|| (ent == LocalPlayer()) || (ent == LocalPlayer():GetHands()) then
						return false
					end
					return true
				end,
				--]]
			}
			local result = util.TraceLine(trace)
			
			-- The Camera has a Sphere radius of 10.
			if (result.Hit) then -- Configurable?
				targetDistance = math.Clamp(result.HitPos:Distance(camdata.origin), 0, cameraDistance)
			end
		end
	else
		targetDistance = 0
	end
	
	-- Fade between Target and Current Distance
	self.Player.Data.ViewDistance = math.Clamp(((self.Player.Data.ViewDistance or targetDistance) * cameraLag) + (targetDistance * cameraLagInv), 0, GAMEMODE.Config.Camera:DistanceMax())
	
	-- Adjust CamData and return
	camdata.origin = camdata.origin - (camdata.angles:Forward() * math.Clamp(self.Player.Data.ViewDistance - 10, 0, self.Player.Data.ViewDistance)) + (camdata.angles:Right() * cameraDistanceRight) + (camdata.angles:Up() * cameraDistanceUp)
	return camdata
end

-- ------------------------------------------------------------------------- --
--! Register
-- ------------------------------------------------------------------------- --
player_manager.RegisterClass( "Default", CLASS, "player_default")