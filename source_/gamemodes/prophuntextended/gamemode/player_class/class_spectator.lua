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

DEFINE_BASECLASS("Default")
local CLASS = {}
CLASS.DisplayName		= "Spectator"
CLASS.DuckSpeed			= 0.0		-- How fast to go from not ducking, to ducking
CLASS.UnDuckSpeed		= 0.0		-- How fast to go from ducking, to not ducking
CLASS.CanUseFlashlight	= false		-- Can we use the flashlight
CLASS.UseVMHands		= false		-- Uses viewmodel hands

-- ------------------------------------------------------------------------- --
--! Server-Side
-- ------------------------------------------------------------------------- --
-- Spawn
function CLASS:Spawn()
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Spectator '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.") end
	BaseClass.Spawn(self)
	
	self.Player:Spectate(OBS_MODE_ROAMING)
	self.Player:SetRenderMode(RENDERMODE_NONE)
	
	-- View Offset & Hull
	GAMEMODE:PlayerSetViewOffset(self.Player, Vector(0,0,0), Vector(0,0,0))
	GAMEMODE:PlayerHullFromEntity(self.Player, nil)
end

-- Death
function CLASS:PostDeath(inflictor, attacker)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Spectator '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") died.") end
	BaseClass.PostDeath(self, inflictor, attacker)
	
	self.Player:Spectate(OBS_MODE_NONE)
	self.Player:UnSpectate()
	
	-- Hull
	GAMEMODE:PlayerHullFromEntity(self.Player, nil)
	
	self.Player:SetRenderMode(RENDERMODE_NORMAL)
end

-- Visible Stuff
function CLASS:SetModel()
	self.Player:SetModel("")
	
	-- Hands
	self.Player:SetupHands()
end

-- Interaction
function CLASS:Use(ent) return false end
function CLASS:AllowPickup(ent) return false end
function CLASS:CanPickupWeapon(ent) return false end
function CLASS:CanPickupItem(ent) return false end
-- ------------------------------------------------------------------------- --
--! Client-Side
-- ------------------------------------------------------------------------- --
function CLASS:ClientSpawn()
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt CL: Spectator '"..self.Player:GetName().."' (SteamID: "..self.Player:SteamID()..") spawned.") end
end

function CLASS:ShouldDrawLocal() return false end
function CLASS:CalcView(camdata) return camdata end

player_manager.RegisterClass( "Spectator", CLASS, "Default")