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
	print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.")
	BaseClass.Spawn(self, self.Player)
	
	-- Sprinting
	if (!GAMEMODE.Config:Sprinting()) then
		self.Player:SetRunSpeed(self.WalkSpeed)
	end
	
	-- Settings
	self.Player:SetMaxHealth(GAMEMODE.Config.Hider:HealthMax())
	self.Player:SetHealth(GAMEMODE.Config.Hider:Health())
	self.Player:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Player:SetColor(Color(0,0,0,0))
	
	-- Hull & View Offset
	GAMEMODE:PlayerHullFromEntity(self.Player, nil)
	GAMEMODE:PlayerSetViewOffset(self.Player, Vector(0,0,72), Vector(0,0,72))
	
	-- Collision Group
	self.Player:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	-- Prop Stuff
	self.Player.Data.Prop = ents.Create("ph_prop")
	self.Player.Data.Prop:SetOwner(self.Player)
	self.Player.Data.Prop:Spawn()
	self.Player:DeleteOnRemove(self.Player.Data.Prop)
	
	-- Assign Hands (Auto Networked Sync!)
	local oldhands = self.Player:GetHands()
	if (IsValid(oldhands)) then oldhands:Remove() end
	self.Player:SetHands(self.Player.Data.Prop)
end

-- Death
function CLASS:PostDeath(attacker, dmginfo)
	print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") died.")
	BaseClass.PostDeath(self, inflictor, attacker)
	
	-- Delete Hands Model
	self.Player:GetHands():Remove()
	
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
function CLASS:SetModel() self.Player:SetModel("models/Gibs/Antlion_gib_small_3.mdl") end -- does "" even work?

-- Interaction
function CLASS:Use(ent)
	if (!(BaseClass.Use(self, ent))) then
		return false
	end
	
	-- Allow interacting while crouched instead of turning into the prop.
	if (self.Player:Crouching()) then 
		return true
	end
	
	-- Check Lists and other Parameters
	if (!table.HasValue(GAMEMODE.Config.Lists:ClassWhitelist(), ent:GetClass()))-- Class is not Whitelisted
		|| (GAMEMODE.Config.Lists.ModelBlacklist[ent:GetModel()])				-- Model is Blacklisted
		|| !((ent:GetPhysicsObject()) && (ent:GetPhysicsObject():IsValid()))	-- Entity doesn't have Physics
	then
		print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") attempted to turn into "..ent:GetClass().." ("..ent:GetModel()..").")
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
	
	print("Prop Hunt: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") turned into "..ent:GetClass().." ("..ent:GetModel()..").")
end

function CLASS:AllowPickup(ent) return true end

-- ------------------------------------------------------------------------- --
--! Shared
-- ------------------------------------------------------------------------- --

-- ------------------------------------------------------------------------- --
--! Client-Side
-- ------------------------------------------------------------------------- --
function CLASS:ClientSpawn()
	print("Prop Hunt CL: Hider '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.")
	BaseClass.ClientSpawn(self, self.Player)
	
	self.Player:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function CLASS:ShouldDrawLocal()
	return false
end

function CLASS:CalcView(camdata)
	-- ThirdPerson Settings (ToDo: client config maybe?)
	local maxViewDist = 100
	local viewDist = self.Player.Data.ViewDistance or 0
	
	-- First/Third
	if (self.Player.Data.ThirdPerson) then
		if (IsValid(self.Player:GetHands())) then
			self.Player:GetHands():SetRenderMode(RENDERMODE_TRANSALPHA)
			self.Player:GetHands():SetColor(Color(255, 255, 255, 127))
		end
		
		-- Incremental Distance instead of instant.
		viewDist = math.Clamp(viewDist * 0.9 + maxViewDist * 0.1, 0, maxViewDist) -- Zoom Out
	else
		if (IsValid(self.Player:GetHands())) then
			self.Player:GetHands():SetRenderMode(RENDERMODE_TRANSALPHA)
			self.Player:GetHands():SetColor(Color(255, 255, 255, 0))
		end
		
		viewDist = math.Clamp(viewDist * 0.9, 0, maxViewDist) -- Zoom In
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
	camdata.drawviewer = false
	
	-- Return
	return camdata
end

-- Register
player_manager.RegisterClass("Hider", CLASS, "Default")
