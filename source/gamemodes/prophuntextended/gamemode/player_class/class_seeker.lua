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
	if (GAMEMODE.Config:DebugLog()) then print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.") end
	BaseClass.Spawn(self)
		
	-- Settings
	self.Player:SetMaxHealth(GAMEMODE.Config.Seeker:HealthMax())
	self.Player:SetHealth(GAMEMODE.Config.Seeker:Health())
	self.Player:SetRenderMode(RENDERMODE_NORMAL)
	self.Player:SetColor(Color(255,255,255,255))
	
	-- Speed and Jump Power
	self.Player:SetWalkSpeed(GAMEMODE.Config.Seeker:WalkSpeed())
	if (GAMEMODE.Config.Seeker:Sprint()) then
		self.Player:SetRunSpeed(GAMEMODE.Config.Seeker:SprintSpeed())
	else
		self.Player:SetRunSpeed(GAMEMODE.Config.Seeker:WalkSpeed())
	end
	self.Player:SetJumpPower(GAMEMODE.Config.Seeker:JumpPower())
	
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
function CLASS:ShouldTakeDamage(attacker)
	if (IsValid(attacker)) then
		if (attacker:IsPlayer()) then
			if (attacker:Team() == self.Player:Team()) then
				local ffmode = GetConVarNumber("mp_friendlyfire")
				if (ffmode == 0) then -- Not Allowed
					return false
				end
			end
		end
	end
	return true
end

function CLASS:Damage(victim, attacker, healthRemaining, damageDealt)
	if ((victim != attacker) && victim:IsPlayer() && attacker:IsPlayer() && (attacker:Team() == victim:Team())) then
		if (GAMEMODE.Config:DebugLog()) then
			print("Prop Hunt: Seeker '"..attacker:GetName().."' (SteamID: "..attacker:SteamID()..") damaged seeker '"..victim:GetName().."' (SteamID: "..victim:SteamID()..") with "..damageDealt.." damage.")
		end
	end
end

function CLASS:Hurt(victim, attacker, healthRemaining, damageTaken)
	if ((victim != attacker) && victim:IsPlayer() && attacker:IsPlayer() && (attacker:Team() == victim:Team())) then
		if (GAMEMODE.Config:DebugLog()) then 
			print("Prop Hunt: Seeker '"..victim:GetName().."' (SteamID: "..victim:SteamID()..") was hurt by seeker '"..attacker:GetName().."' (SteamID: "..attacker:SteamID()..") with "..damageTaken.." damage.")
		end
		
		if (GetConVarNumber("mp_friendlyfire") == 2) then
			victim:SetHealth(healthRemaining + damageTaken)
			attacker:TakeDamage(damageTaken, attacker, attacker)
			print("Prop Hunt: Seeker '"..victim:GetName().."' (SteamID: "..victim:SteamID()..") reflected "..damageTaken.." to seeker '"..attacker:GetName().."' (SteamID: "..attacker:SteamID()..").")
		end
	end
end

function CLASS:DamageEntity(ent, att, dmg)
	if (GAMEMODE.Config:DebugLog()) then print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") damaged entity "..ent:GetClass()..".") end

	if (GAMEMODE:GetRoundState() != GAMEMODE.States.Seek) then return end	
	if (!IsValid(ent) || !IsValid(att)) then return end
	if (att == ent) then return end
	
	-- Only take damage during this phase.
	if IsValid(ent) && (!(ent:IsPlayer())) then
		if (ent:GetClass() == "ph_prop") then
			ent:GetOwner():TakeDamageInfo(dmg)
			self.Player.Data.RandomWeight = self.Player.Data.RandomWeight - 1
		elseif (ent:GetClass() == "func_breakable") then
		elseif (ent:GetClass() == "prop_ragdoll") then
		else
			att:TakeDamage(GAMEMODE.Config.Seeker:HealthPenalty(), ent, ent)
		end
	end
end

-- Death
function CLASS:DoDeath(attacker, dmginfo)
	BaseClass.DoDeath(self, attacker, dmginfo)
	if GAMEMODE.Config:DebugLog() then 
		if (IsValid(attacker) && attacker:IsPlayer() && attacker != self.Player) then
			print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") killed by '"..attacker:GetName().."' (SteamID: "..attacker:SteamID()..").")
		end
	end
	
	if SERVER then
		self.Player:SetShouldServerRagdoll(true)
		--self.Player:CreateRagdoll()
	end
end

function CLASS:PostDeath()
	if (GAMEMODE.Config:DebugLog()) then print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") died.") end
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

-- Menu Buttons
function CLASS:ShowSpare1()
	if BaseClass.ShowSpare1(self) then return end
	
	-- Play a taunt
	local tauntList = GAMEMODE.Config.Taunt:Seekers()
	local index = math.random(#tauntList)
	self.Player:EmitSound(tauntList[index], SNDLVL_NORM, 100, 1, CHAN_VOICE)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") taunted with sound '"..tauntList[index].."'.") end
end

-- ------------------------------------------------------------------------- --
--! Shared
-- ------------------------------------------------------------------------- --
function CLASS:Alive() return true end

-- ------------------------------------------------------------------------- --
--! Client-Side
-- ------------------------------------------------------------------------- --
function CLASS:ClientSpawn()
	if (GAMEMODE.Config:DebugLog()) then print("Prop Hunt CL: Seeker '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.") end
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
	return (self.Player.Data.ViewDistance or 0) >= 10
end

-- Register
player_manager.RegisterClass("Seeker", CLASS, "Default")
