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

--! This file defines the Seeker player class.
-- A seeker is someone who is looking for the hiders, using weapons or other
--  means of detecting idiots. Also someone who looks like a diaper baby.
-- Weapons and Ammo are granted upon spawn and have to be used sparingly or
--  they'll be stuck with the crowbar. Bad seeker, bad.
-- Gain health upon killing a hider, lose health when attacking non-hiders.
-- Death upon health reaching 0.

DEFINE_BASECLASS( "Default" )
local CLASS = {}
CLASS.DisplayName		= "Seeker"
CLASS.CanUseFlashlight	= true		-- Can we use the flashlight
CLASS.MaxHealth			= 100
CLASS.StartHealth		= 100
CLASS.StartArmor		= 0
CLASS.DropWeaponOnDie	= true

-- ------------------------------------------------------------------------- --
--! Server-Side
-- ------------------------------------------------------------------------- --
-- Spawn
function CLASS:Spawn()
	print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.")
	BaseClass.Spawn(self)
	
	-- Sprinting
	if (GAMEMODE.Config:Sprinting()) then
		self.Player:SetRunSpeed(self.WalkSpeed)
	end
	
	-- Settings
	self.Player:SetMaxHealth(GAMEMODE.Config.Seeker:HealthMax())
	self.Player:SetHealth(GAMEMODE.Config.Seeker:Health())
	self.Player:SetRenderMode(RENDERMODE_NORMAL)
	self.Player:SetColor(Color(255,255,255,255))
	
	-- Hull & View Offset
	GAMEMODE:PlayerHullFromEntity(self.Player, nil)
	GAMEMODE:PlayerSetViewOffset(self.Player, Vector(0,0,64), Vector(0,0,32))
end

function CLASS:Loadout()
	-- Give the weapons the admin told us to.
	local weapons = GAMEMODE.Config.Seeker:Weapons()
	for i,weapon in ipairs(weapons) do
		self.Player:Give(weapon)
	end
	
	-- Give the ammo the admin told us to.
	local ammos = GAMEMODE.Config.Seeker:Ammo()
	for i,ammo in ipairs(ammos) do
		local typeCount = string.Split(ammo, ":")
		self.Player:GiveAmmo(tonumber(typeCount[2]), typeCount[1], true)
	end
	
	-- Default weapon stuff
	local cl_defaultweapon = self.Player:GetInfo("cl_defaultweapon") 
 	if self.Player:HasWeapon(cl_defaultweapon) then 
 		self.Player:SelectWeapon(cl_defaultweapon)
 	end 
end

-- Damage
function CLASS:Damage(victim, attacker, healthRemaining, damageDealt) end
function CLASS:DamageEntity(ent, att, dmg)
	print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") damaged entity "..ent:GetClass()..".")
	
	-- Only take damage during this phase.
	if (GAMEMODE:GetRoundState() == GAMEMODE.States.Seek) then
		if IsValid(ent) && (!(ent:IsPlayer())) then
			if (ent:GetClass() == "ph_prop") then
				ent:GetOwner():TakeDamageInfo(dmg)
			elseif (ent:GetClass() == "func_breakable") then -- ToDo: Make Configurable which entities don't hurt?
			else
				att:TakeDamage(GAMEMODE.Config.Seeker:HealthPenalty(), ent, ent)
			end
		end
	end
end

-- Death
function CLASS:Death(inflictor, attacker)
	BaseClass.Death(self, inflictor, attacker)
	
	self.Player:CreateRagdoll()
end

function CLASS:PostDeath()
	print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") died.")
	BaseClass.PostDeath(self, inflictor, attacker)
	
	self.Player:UnLock()
end

function CLASS:CanSuicide()
	return true
end

function CLASS:DeathThink()
	if (CurTime() - self.Player.Data.AliveTime) > 1 then
		self.Player:Spawn()
		return true
	end
	
	return false
end

-- Visible Stuff
function CLASS:SetModel()
	local cl_playermodel = self.Player:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	if !(util.IsValidModel(modelname)) then
		modelname = "models/player/combine_super_soldier.mdl"
	end
	util.PrecacheModel(modelname)
	self.Player:SetModel(modelname)
	
	-- Hands
	self.Player:SetupHands()	
end

-- Interaction
function CLASS:AllowPickup(ent) return true end
function CLASS:CanPickupItem(ent) return true end
function CLASS:CanPickupWeapon(ent) return true end

-- ------------------------------------------------------------------------- --
--! Client-Side
-- ------------------------------------------------------------------------- --
function CLASS:ClientSpawn()
	print("Prop Hunt CL: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.")
	BaseClass.ClientSpawn(self)
end

function CLASS:HUDPaint()
	BaseClass.HUDPaint(self)
	
	local State = GetGlobalInt("RoundState", GAMEMODE.States.PreMatch)
	if (State == GAMEMODE.States.Hide) then
		local intTime = math.ceil(GetGlobalInt("RoundTime"))
		local strTime = tostring(intTime)
		
		-- Show Status at the center
		surface.SetTextColor( 255, 255, 255, 255 )
		if (intTime >= 1) then
			surface.SetFont("CloseCaption_Bold")
			local w,h = surface.GetTextSize("Unblinded in "..strTime.." seconds...")
			surface.SetTextPos( ScrW()/2 - w / 2, ScrH()/2 - h / 2)
			surface.DrawText("Unblinded in "..strTime.." seconds...")
		else
			surface.SetFont("PHHugeAssFont")
			local w,h = surface.GetTextSize("NOW")
			surface.SetTextPos( ScrW()/2 - w / 2, ScrH()/2 - h / 2)
			surface.DrawText("NOW")
		end
	end
end

function CLASS:ShouldDrawLocal()
	return self.Player.Data.ThirdPerson
end

function CLASS:CalcView(camdata)
	-- ThirdPerson Settings (ToDo: client config maybe?)
	local maxViewDist = 100
	local viewDist = self.Player.Data.ViewDistance or 0
	
	-- First/Third
	if (self.Player.Data.ThirdPerson) then
		viewDist = math.Clamp(viewDist * 0.95 + maxViewDist * 0.05, 0, maxViewDist) -- Zoom Out
	else
		viewDist = math.Clamp(viewDist * 0.95, 0, maxViewDist) -- Zoom In
	end
	
	-- Trace from Player to would-be camera position
	local trace = {
		start = camdata.origin,
		endpos = camdata.origin - (camdata.angles:Forward() * viewDist),
		--filter = { "worldspawn", "ph_prop" },
		filter = function(ent)
			local filter = { "worldspawn", "ph_prop" }
			
			if (ent:IsPlayer())
				|| (table.HasValue(filter, ent:GetClass()))
				|| (ent == LocalPlayer()) || (ent == LocalPlayer():GetHands()) then
				return false
			end
			return true
		end
	}
	local result = util.TraceLine(trace)
	
	-- The Camera has a Sphere radius of 10.
	if (result.Hit) then -- Configurable?
		viewDist = math.Clamp(result.HitPos:Distance(camdata.origin), 0, maxViewDist)
	end
	
	-- Store ViewDistance
	self.Player.Data.ViewDistance = viewDist
	
	-- Adjust CamData
	camdata.origin = camdata.origin - (camdata.angles:Forward() * math.Clamp(viewDist - 10, 0, maxViewDist))
	--camdata.drawviewer = false
	
	-- Return
	return camdata
end

-- Register
player_manager.RegisterClass("Seeker", CLASS, "Default")
