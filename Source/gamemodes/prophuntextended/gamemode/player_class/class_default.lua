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
function CLASS:InitialSpawn() end
function CLASS:Spawn() end
function CLASS:Loadout() end

-- Damage
function CLASS:Hurt(victim, attacker, healthRemaining, damageTaken) end -- Damage Taken
function CLASS:Damage(victim, attacker, healthRemaining, damageDealt) end -- Damage Dealt
function CLASS:DamageEntity(ent, attacker, dmginfo) end -- Damage Dealt To Entity

-- Death
function CLASS:Death(inflictor, attacker)
	self.Player.Data.Alive = false
	self.Player.Data.AliveTime = CurTime()
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
	if (!ent) || (!ent:IsValid()) || (ent:IsPlayer()) then
		return false
	end
	
	-- Cool Down
	if (self.Player.Data.UseTime) then
		local timeSinceUse = (CurTime() - self.Player.Data.UseTime)
		if (0.2 > timeSinceUse) then
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

-- ------------------------------------------------------------------------- --
--! Shared
-- ------------------------------------------------------------------------- --
function CLASS:PostThink() end
function CLASS:Tick(mv) end 

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
	local State = GetGlobalInt("RoundState", GAMEMODE.States.PreMatch)
	
	-- Show Status at the top center
	local statusX, statusY, statusW, statusH
	statusW = 192
	statusH = 64
	statusX = ScrW() / 2 - statusW / 2
	statusY = 16
	
	-- Status
	if (State == GAMEMODE.States.PreMatch) then -- Pre Match
		draw.RoundedBox(16, statusX, statusY, statusW, statusH, Color(0, 0, 0, 204))
		surface.SetFont( "Trebuchet24" )
		surface.SetTextColor( 255, 255, 255, 255 )	
		local w,h = surface.GetTextSize("Waiting for Players")
		surface.SetTextPos( statusX + statusW/2 - w / 2, statusY + statusH/2 - h / 2)
		surface.DrawText("Waiting for Players")
	elseif (State == GAMEMODE.States.PreRound) then -- Pre Round
		draw.RoundedBox(16, statusX, statusY, statusW, statusH, Color(0, 0, 0, 204))
		surface.SetFont( "Trebuchet24" )
		surface.SetTextColor( 255, 255, 255, 255 )
		local w,h = surface.GetTextSize("Preparing...")
		surface.SetTextPos( statusX + statusW/2 - w / 2, statusY + statusH/2 - h / 2)
		surface.DrawText( "Preparing..." )
	elseif (State == GAMEMODE.States.Hide) then -- Hide
		local strTime = tostring(math.ceil(GetGlobalInt("RoundTime")))
		
		-- Show Status at the top center
		draw.RoundedBox(16, statusX, statusY, statusW, statusH, Color(0, 0, 0, 204))
		surface.SetTextColor(255,255,255,255)
		surface.SetFont("Trebuchet18")
		local w,h = surface.GetTextSize("Seekers unblinded in:")
		surface.SetTextPos(statusX + statusW/2 - w / 2, statusY + statusH/4 - h / 2)
		surface.DrawText("Seekers unblinded in:")
		
		surface.SetFont( "Trebuchet24" )
		local w,h = surface.GetTextSize(strTime.." Seconds!")
		surface.SetTextPos( statusX + statusW/2 - w / 2, statusY + statusH/1.5 - h / 2)
		surface.DrawText(strTime.." Seconds!")
	elseif (State == GAMEMODE.States.Seek) then -- Seek
		local intTime = math.ceil(GetGlobalInt("RoundTime"))
		local strTime = string.format("%d:%02d", math.floor(intTime / 60), math.ceil(intTime % 60))
		
		-- Show Status at the top center
		draw.RoundedBox(16, statusX, statusY, statusW, statusH, Color(0, 0, 0, 204))
		surface.SetTextColor(255,255,255,255)
		surface.SetFont("Trebuchet18")
		local w,h = surface.GetTextSize("Hunting Time!")
		surface.SetTextPos(statusX + statusW/2 - w / 2, statusY + statusH/4 - h / 2)
		surface.DrawText("Hunting Time!")
		
		surface.SetFont( "Trebuchet24" )
		local w,h = surface.GetTextSize(strTime)
		surface.SetTextPos( statusX + statusW/2 - w / 2, statusY + statusH/1.5 - h / 2)
		surface.DrawText(strTime)
		
	elseif (State == GAMEMODE.States.PostRound) then -- Post Round
		-- Show Status at the top center
		draw.RoundedBox(16, statusX, statusY, statusW, statusH, Color(0, 0, 0, 204))
		surface.SetTextColor(255,255,255,255)
		surface.SetFont("Trebuchet18")
		local w,h = surface.GetTextSize("Match Result")
		surface.SetTextPos(statusX + statusW/2 - w / 2, statusY + statusH/4 - h / 2)
		surface.DrawText("Match Result")
		
		local victor = GAMEMODE:GetRoundWinner()
		local victorName = "Unknown"
		if (victor == GAMEMODE.Teams.Spectator) then
			victorName = "Draw"
		elseif (victor == GAMEMODE.Teams.Hiders) then
			victorName = "Hiders Win"
		elseif (victor == GAMEMODE.Teams.Seekers) then
			victorName = "Seekers Win"
		end
		surface.SetTextColor(team.GetColor(victor))
		
		surface.SetFont( "Trebuchet24" )
		local w,h = surface.GetTextSize(victorName)
		surface.SetTextPos( statusX + statusW/2 - w / 2, statusY + statusH/1.5 - h / 2)
		surface.DrawText(victorName)
	elseif (State == GAMEMODE.States.PostMatch) then -- Post Match
		
	end
end
function CLASS:CalcView(camdata) return camdata end

-- ------------------------------------------------------------------------- --
--! Register
-- ------------------------------------------------------------------------- --
player_manager.RegisterClass( "Default", CLASS, "player_default")