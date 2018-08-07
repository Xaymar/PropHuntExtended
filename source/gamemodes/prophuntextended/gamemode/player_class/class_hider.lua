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

DEFINE_BASECLASS( "Default" )
local CLASS = {}
CLASS.DisplayName		= "Hider"
CLASS.DuckSpeed			= 0.0		-- How fast to go from not ducking, to ducking
CLASS.UnDuckSpeed		= 0.0		-- How fast to go from ducking, to not ducking
CLASS.CanUseFlashlight	= false		-- Can we use the flashlight
CLASS.UseVMHands		= false		-- Uses viewmodel hands

-- ------------------------------------------------------------------------- --
--! Server-Side
-- ------------------------------------------------------------------------- --
-- Spawn
function CLASS:Spawn()
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.") end
	BaseClass.Spawn(self, self.Player)
		
	-- Settings
	self.Player:SetMaxHealth(GAMEMODE.Config.Hider:HealthMax())
	self.Player:SetHealth(GAMEMODE.Config.Hider:Health())
	self.Player:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Player:SetColor(Color(0,0,0,0))
	
	-- Speed and Jump Power
	self.Player:SetWalkSpeed(GAMEMODE.Config.Hider:WalkSpeed())
	if (GAMEMODE.Config.Hider:Sprint()) then
		self.Player:SetRunSpeed(GAMEMODE.Config.Hider:SprintSpeed())
	else
		self.Player:SetRunSpeed(GAMEMODE.Config.Hider:WalkSpeed())
	end
	self.Player:SetJumpPower(GAMEMODE.Config.Hider:JumpPower())
	
	-- Hull & View Offset
	GAMEMODE:PlayerHullFromEntity(self.Player, nil)
	GAMEMODE:PlayerSetViewOffset(self.Player, Vector(0,0,72), Vector(0,0,72))
	
	-- Collision Group
	self.Player:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self.Player:SetSolid(SOLID_VPHYSICS)
	
	-- Prop Stuff
	self.Player.Data.Prop = ents.Create("ph_prop")
	self.Player.Data.Prop:SetOwner(self.Player)
	self.Player.Data.Prop:Spawn()
	self.Player:DeleteOnRemove(self.Player.Data.Prop)
	self.Player.Data.PropContraint = constraint.NoCollide(self.Player, self.Player.Data.Prop, 0, 0)
	
	-- Assign Hands (Auto Networked Sync!)
	local oldhands = self.Player:GetHands()
	if (IsValid(oldhands)) then oldhands:Remove() end
	self.Player:SetHands(self.Player.Data.Prop)
end

-- Death
function CLASS:DoDeath(attacker, dmginfo)
	BaseClass.DoDeath(self, attacker, dmginfo)
	if GAMEMODE.Config:DebugLog() then 
		if (IsValid(attacker) && attacker:IsPlayer() && attacker != self.Player) then
			print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") killed by '"..attacker:GetName().."' (SteamID: "..attacker:SteamID()..").")
		end
	end
	
	if (!IsValid(attacker)) then return end
	if (!attacker:IsPlayer()) then return end
	if (attacker:Team() == self.Player:Team()) then return end
	if (attacker:Team() == GAMEMODE.Teams.Seekers) then
		if GAMEMODE.Config:DebugLog() then
			print("Prop Hunt: Seeker '"..attacker:GetName().."' (SteamID: "..attacker:SteamID()..") gained "..GAMEMODE.Config.Seeker:HealthBonus().." health for killing Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..").")
		end
		local newhealth = attacker:Health() + GAMEMODE.Config.Seeker:HealthBonus()
		if (newhealth > attacker:GetMaxHealth()) then newhealth = attacker:GetMaxHealth() end
		attacker:SetHealth(newhealth)
	end
end

function CLASS:PostDeath()
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") died.") end
	BaseClass.PostDeath(self, inflictor, attacker)
	
	-- Delete Hands Model
	if IsValid(self.Player.Data.PropConstraint) then
		self.Player.Data.PropConstraint:Remove()
	end
	if IsValid(self.Player:GetHands()) then
		self.Player:GetHands():Remove()
	end
	if IsValid(self.Player.Data.Prop) then
		self.Player.Data.Prop:Remove()
	end
	
	-- Collision Group
	self.Player:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	-- Hull
	GAMEMODE:PlayerHullFromEntity(self.Player, nil)
	
	-- Rendering
	self.Player:SetRenderMode(RENDERMODE_NORMAL)
	self.Player:SetColor(Color(255,255,255,255))
end

function CLASS:CanSuicide()
	return true
end

function CLASS:DeathThink()
	if 1 > (CurTime() - self.Player.Data.AliveTime) then
		return false
	end
	
	self.Player:Spawn()
	return true
end

-- Visible Stuff
function CLASS:SetModel()
	self.Player:SetModel("models/Gibs/Antlion_gib_small_3.mdl")
end

-- Interaction
function CLASS:Use(ent)
	if (!(BaseClass.Use(self, ent))) then
		return false
	end
	
	-- Allow interacting while crouched instead of turning into the prop.
	if (self.Player:Crouching()) then
		if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") interacted with "..ent:GetClass().." ("..ent:GetModel()..").") end
		return true
	end
	
	-- Check Lists and other Parameters
	if (!table.HasValue(GAMEMODE.Config.Lists:ClassWhitelist(), ent:GetClass()))	-- Class is not Whitelisted
		|| (table.HasValue(GAMEMODE.Config.Lists:ModelBlacklist(), ent:GetModel()))	-- Model is Blacklisted
		|| !((ent:GetPhysicsObject()) && (ent:GetPhysicsObject():IsValid()))		-- Entity doesn't have Physics
	then
		if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") attempted to turn into "..ent:GetClass().." ("..ent:GetModel()..").") end
		return true -- Use instead of erroring.
	end
	
	-- Turn into the prop
	local eProp = self.Player:GetHands()
	util.PrecacheModel(ent:GetModel())
	eProp:SetModel(ent:GetModel())
	eProp:SetSkin(ent:GetSkin())
	eProp:SetHealth(100)
	eProp:SetMaxHealth(100)
	eProp:SetRenderMode(RENDERMODE_TRANSALPHA)
	
	-- Hull (Optimize into single function? Code is repeated often)
	local hull = GAMEMODE:PlayerHullFromEntity(self.Player, ent)
	
	-- View Offset
	local vo = Vector(0, 0, hull[2].z)
	GAMEMODE:PlayerSetViewOffset(self.Player, vo, vo)
			
	-- Health Scaling
	if (GAMEMODE.Config.Hider:HealthScaling()) then
		local prc = math.Clamp(self.Player:Health() / self.Player:GetMaxHealth(), 0, 1)
		local maxhealth = math.Clamp(ent:GetPhysicsObject():GetVolume() / 250, 1, GAMEMODE.Config.Hider:HealthScalingMax())
		local health = math.Clamp(maxhealth * prc, 1, maxhealth)
		
		-- Set Health
		self.Player:SetHealth(health)
		self.Player:SetMaxHealth(maxhealth)
	end
	
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") turned into "..ent:GetClass().." ("..ent:GetModel()..").") end
end

function CLASS:AllowPickup(ent) return true end

-- Menu Buttons
function CLASS:ShowSpare1()
	if BaseClass.ShowSpare1(self) then return end
	
	-- Play a taunt
	local tauntList = GAMEMODE.Config.Taunt:Hiders()
	local index = math.random(#tauntList)
	self.Player:EmitSound(tauntList[index], SNDLVL_NORM, 100, 1, CHAN_VOICE)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") taunted with sound '"..tauntList[index].."'.") end
end

-- ------------------------------------------------------------------------- --
--! Shared
-- ------------------------------------------------------------------------- --
if SERVER then
	function CLASS:FindUseEntity(defEnt)
		return self.Player:FindUseEntity()
	end
	
	function CLASS:Tick(mv)
		if (self.Player.Data == nil) then return end
		
		-- Selection Halo
		if (GAMEMODE.Config.SelectionHalo:Allow()) && (!GAMEMODE.Config.SelectionHalo:Approximate()) then
			if (self.Player.Data.SelectionHaloTime == nil) then
				self.Player.Data.SelectionHaloTime = CurTime()
			elseif ((CurTime() - self.Player.Data.SelectionHaloTime) > GAMEMODE.Config.SelectionHalo:Interval()) then
				self.Player.Data.SelectionHaloTime = CurTime()
				local ent = self.Player:FindUseEntity()
				if (IsValid(ent)
					&& table.HasValue(GAMEMODE.Config.Lists:ClassWhitelist(), ent:GetClass()) 
					&& !table.HasValue(GAMEMODE.Config.Lists:ModelBlacklist(), ent:GetModel())) then
					self.Player:SetNWEntity("SelectionHalo", ent)
				else
					self.Player:SetNWBool("SelectionHalo", false)
				end				
			end
		end
	end
end
function CLASS:Alive() return true end

-- ------------------------------------------------------------------------- --
--! Client-Side
-- ------------------------------------------------------------------------- --
function CLASS:ClientSpawn()
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt CL: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.") end
	BaseClass.ClientSpawn(self, self.Player)
	
	self.Player:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function CLASS:ShouldDrawLocal()
	if (self.Player.Data.ViewDistance or 0) >= 10 then
		if (IsValid(self.Player:GetHands())) then
			self.Player:GetHands():SetRenderMode(RENDERMODE_TRANSALPHA)
			self.Player:GetHands():SetColor(Color(255, 255, 255, 127))
		end
	else
		if (IsValid(self.Player:GetHands())) then
			self.Player:GetHands():SetRenderMode(RENDERMODE_TRANSALPHA)
			self.Player:GetHands():SetColor(Color(255, 255, 255, 0))
		end
	end
	
	return (self.Player.Data.ViewDistance or 0) >= 10
end

-- Register
player_manager.RegisterClass("Hider", CLASS, "Default")
