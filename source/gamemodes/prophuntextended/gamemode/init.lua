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

-- ------------------------------------------------------------------------- --
--! Downloadable Lua
-- ------------------------------------------------------------------------- --
-- Shared
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("meta/player.lua")
AddCSLuaFile("player_class/class_default.lua")
AddCSLuaFile("player_class/class_spectator.lua")
AddCSLuaFile("player_class/class_seeker.lua")
AddCSLuaFile("player_class/class_hider.lua")

-- Client-Only
AddCSLuaFile("vgui/fontmanager.lua")
AddCSLuaFile("vgui/uimanager.lua")
AddCSLuaFile("vgui/dlabeldpi.lua")
AddCSLuaFile("vgui/dframedpi.lua")
AddCSLuaFile("client/ui/help.lua")
AddCSLuaFile("client/ui/settings.lua")
AddCSLuaFile("client/ui/scoreboard.lua")
AddCSLuaFile("client/hud/gamestatedisplay.lua")
AddCSLuaFile("client/roundmanager.lua")
AddCSLuaFile("client/cl_ui_help.lua")
AddCSLuaFile("client/cl_ui_teamselection.lua")

-- Client Init
AddCSLuaFile("cl_init.lua") -- Immediately executed when downloaded, weird behavior.

-- ------------------------------------------------------------------------- --
--! Code
-- ------------------------------------------------------------------------- --
-- Shared
include "sh_init.lua"

-- Server Only
include "compat/compat_tauntpackloader.lua"
include "server/roundmanager.lua"
include "server/states/state_prematch.lua"
include "server/states/state_preround.lua"
include "server/states/state_hide.lua"
include "server/states/state_seek.lua"
include "server/states/state_postround.lua"
include "server/states/state_postmatch.lua"

function GM:Initialize()
	print("-------------------------------------------------------------------------")
	print("Prop Hunt: Initializing...")
	
	print("Prop Hunt: Registering Networked Messages...")
	util.AddNetworkString("PlayerManagerInitialClientSpawn")
	util.AddNetworkString("PlayerManagerClientSpawn")
	util.AddNetworkString("PlayerSetHull")
	util.AddNetworkString("PlayerResetHull")
	util.AddNetworkString("PlayerViewOffset")
	util.AddNetworkString("PlayerRegisterPropEntity")
	util.AddNetworkString("PlayerEnablePropRotation")
	util.AddNetworkString("PlayerDisablePropRotation")
	
	print("Prop Hunt: Initializing Gamemode Data...")
	self.Data = {}
	self.Data.RoundTime = 0
	self.Data.RoundStartTime = 0
	self.Data.StateTime = 0
	
	print("Prop Hunt: Initializing Round Manager")
	RoundManager:SetState(StatePreRound)
	
	print("Prop Hunt: Precaching...")
	GAMEMODE.Config.Taunt:Seekers()
	GAMEMODE.Config.Taunt:Hiders()
	
	print("Prop Hunt: Complete.")
	print("-------------------------------------------------------------------------")
end

-- Player Connected
function GM:PlayerConnect(name, ip)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..name.."' connecting from IP '"..ip.."'.") end
end

-- Player Authenticated
function GM:PlayerAuthed(ply, steamid, uniqueid)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") authenticated.") end
end

-- Player Disconnected
function GM:PlayerDisconnected(ply)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") disconnected.") end
end

-- Player Spawn (Initial)
function GM:PlayerInitialSpawn(ply)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") spawned for the first time, applying defaults...") end
	
	if (!ply.Data) then
		-- Initialize Data Structure
		ply.Data = {}
		ply.Data.Alive = false
		ply.Data.AliveTime = 0
		ply.Data.RandomWeight = 0 -- Higher means higher chance of becoming Seeker instead of Hider.
	end
	
	-- Kill Silently
	ply:KillSilent()
	
	-- Show Team Selection Menu
	ply:SetTeam(GAMEMODE.Teams.Spectators)
	self:ShowTeam(ply)
	
	-- Bot: Auto Assign to Team
	if (ply:IsBot()) then
		if team.NumPlayers(self.Teams.Hiders) > team.NumPlayers(self.Teams.Seekers) then
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Bot '"..ply:GetName().."' assigned to Seekers.") end
			ply:SetTeam(self.Teams.Seekers)
		else
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Bot '"..ply:GetName().."' assigned to Hiders.") end
			ply:SetTeam(self.Teams.Hiders)
		end
	end

	-- Notify Player Manager
	player_manager.RunClass(ply, "InitialSpawn")
	
	-- Signal Client
	net.Start("PlayerManagerInitialClientSpawn");net.Send(ply)
end

-- Player Spawn
function GM:PlayerSpawn(ply)
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") spawned in.") end
	
	-- Player Manager: Assign Player Class
	local class = team.GetClass(ply:Team())
	if (class) then
		if (ply.Data.Alive) then -- Alive Class
			player_manager.SetPlayerClass(ply, class[1])
		else -- Dead Class (Spectator)
			player_manager.SetPlayerClass(ply, class[2])
		end
	else
		player_manager.SetPlayerClass(ply, "Spectator")
	end
	
	-- Notify Player Manager
	player_manager.OnPlayerSpawn(ply)
	player_manager.RunClass(ply, "Spawn")
		
	-- Some hooks are not called
	hook.Call("PlayerSetModel", self, ply)
	hook.Call("PlayerLoadout", self, ply)
	
	-- Signal Client
	net.Start("PlayerManagerClientSpawn");net.Send(ply)
end

-- Player requests Team Change
function GM:PlayerRequestTeam(ply, teamId)
	if self:PlayerCanJoinTeam(ply, teamId) then
		if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") requested to join Team "..team.GetName(teamId)..".") end
		
		if (ply:Team() != teamId) then
			ply:KillSilent()
			ply:SetTeam(teamId)
			
			if (GetGlobalInt("RoundState", GAMEMODE.States.PreMatch) <= GAMEMODE.States.PreRound) then
				ply.Alive = true
				ply.AliveTime = CurTime()
			end
		else
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") attempted to rejoin the Team it is already in.") end
		end
	end
end

-- ------------------------------------------------------------------------- --
--! Player Manager Binding
-- ------------------------------------------------------------------------- --
function GM:PlayerLoadout(ply) player_manager.RunClass(ply, "Loadout") end
function GM:PlayerDeath(ply, inflictor, attacker)
	player_manager.RunClass(ply, "Death", inflictor, attacker)
	
	-- Signal Client Stuff
	if IsValid(attacker) then
		if attacker:IsPlayer() then
			if (attacker == ply) then
				net.Start("PlayerKilledSelf")
				net.WriteEntity(ply)
				net.Broadcast()
			else
				net.Start("PlayerKilledByPlayer")
				net.WriteEntity(ply)
				net.WriteString(inflictor:GetName())
				net.WriteEntity(attacker)
				net.Broadcast()
			end
		else
			net.Start("PlayerKilled")
			net.WriteEntity(ply)
			net.WriteString(inflictor:GetName())
			net.WriteString(attacker:GetClass())
			net.Broadcast()
		end
	else
		net.Start("PlayerKilled")
		net.WriteEntity(ply)
		net.WriteString(inflictor:GetName())
		net.WriteString("World")
		net.Broadcast()
	end
end
function GM:PlayerSilentDeath(ply) player_manager.RunClass(ply, "SilentDeath") end
function GM:PostPlayerDeath(ply)
	player_manager.RunClass(ply, "PostDeath")
	
	-- Debug Mode: Respawn after Death
	if (GAMEMODE.Config:Debug()) then
		ply.Data.Alive = true
		if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Debug Mode active, Player "..ply:GetName().." was respawned.") end
	end
end
function GM:DoPlayerDeath(ply, attacker, dmg) player_manager.RunClass(ply, "DoDeath", attacker, dmg) end
function GM:PlayerDeathThink(ply) return player_manager.RunClass(ply, "DeathThink") end
function GM:CanPlayerSuicide(ply) return player_manager.RunClass(ply, "CanSuicide") end
function GM:PlayerCanPickupWeapon(ply, weapon) return player_manager.RunClass(ply, "CanPickupWeapon", weapon) end
function GM:PlayerCanPickupItem(ply, item) return player_manager.RunClass(ply, "CanPickupItem", item) end
function GM:PlayerUse(ply, ent) return player_manager.RunClass(ply, "Use", ent) end
function GM:AllowPlayerPickup(ply, ent)	return player_manager.RunClass(ply, "AllowPickup", ent) end
function GM:PlayerSetModel(ply)	return player_manager.RunClass(ply, "SetModel") end

-- Damage
function GM:PlayerShouldTakeDamage(victim, attacker)
	return player_manager.RunClass(victim, "ShouldTakeDamage", attacker)
end

function GM:PlayerHurt(victim, attacker, healthRemaining, damageTaken)
	player_manager.RunClass(victim, "Hurt", victim, attacker, healthRemaining, damageTaken)
	
	if (IsValid(attacker) && attacker:IsPlayer()) then
		player_manager.RunClass(attacker, "Damage", victim, attacker, healthRemaining, damageTaken)
	end
end

function GM:EntityTakeDamage(ent, dmg)
	local att = dmg:GetAttacker()
	
	if (att) && (att:IsValid()) && (att:IsPlayer()) then
		player_manager.RunClass(att, "DamageEntity", ent, att, dmg)
	end
end

-- ------------------------------------------------------------------------- --
--! Gamemode Functionality
-- ------------------------------------------------------------------------- --
function GM:SetRound(Round)
	SetGlobalInt("Round", Round)
end

function GM:SetRoundTime(Time)
	SetGlobalInt("RoundTime", Time)
end

function GM:SetRoundState(State)
	SetGlobalInt("RoundState", State)
end

function GM:SetRoundStateTime(Time)
	SetGlobalInt("RoundStateTime", Time)
end

function GM:SetRoundWinner(Winner)
	SetGlobalInt("RoundWinner", Winner)
end

function GM:PlayerHullFromEntity(ply, ent)
	if (ent) && (ent:IsValid()) then
		local hmin, hmax = ent:OBBMins(), ent:OBBMaxs()
		local hull = Vector(hmax.x - hmin.x, hmax.y - hmin.y, hmax.z - hmin.z)
		if hull.x <= hull.y then
			hull.y = hull.x
		else
			hull.x = hull.y
		end
		hull:Mul(0.5)
		hull:Mul(0.95) -- Reduce size slightly
		
		local hullmin = Vector(-hull.x, -hull.y, 0)
		local hullmax = Vector(hull.x, hull.y, hull.z * 2)
		
		ply:SetHull(hullmin, hullmax)
		ply:SetHullDuck(hullmin, hullmax)
		net.Start("PlayerSetHull")
			net.WriteVector(hullmin)
			net.WriteVector(hullmax)
		net.Send(ply)
		return {hullmin, hullmax}
	else
		ply:ResetHull()
		net.Start("PlayerResetHull")
		net.Send(ply)
		return nil
	end
end

function GM:PlayerSetViewOffset(ply, vo, voduck)
	ply:SetViewOffset(vo)
	ply:SetViewOffsetDucked(voduck)
	if ply:Crouching() then
		ply:SetCurrentViewOffset(voduck)
	else
		ply:SetCurrentViewOffset(vo)
	end
	
	-- Signal Client
	net.Start("PlayerViewOffset")
	net.WriteVector(vo)
	net.WriteVector(voduck)
	net.Send(ply)
end

-- ------------------------------------------------------------------------- --
--! Commands
-- ------------------------------------------------------------------------- --
-- F1/ShowHelp
function GM:ShowHelp(ply)
	ply:ConCommand("ph_show_help")
end

-- F2/ShowTeam - Select Team
function GM:ShowTeam(ply)
	ply:ConCommand("ph_select_team")
end

function GM:ShowSpare1(ply)	player_manager.RunClass(ply, "ShowSpare1") end -- F3/ShowSpare1
function GM:ShowSpare2(ply)	player_manager.RunClass(ply, "ShowSpare2") end -- F4/ShowSpare2

-- Debug Command: Print All Players
concommand.Add("ph_debug_printplayers", function(ply, cmd, args, argStr)
	if GAMEMODE.Config:DebugLog() then 
		print ("All Players:")
		for i,ply in ipairs(player.GetAll()) do
			print("  "..ply:GetName().." (SteamID: "..ply:SteamID()..") - Team "..team.GetName(ply:Team()).. " - Alive "..tostring(ply.Data.Alive))
		end
		
		print ("Spectators:")
		for i,ply in ipairs(team.GetPlayers(GAMEMODE.Teams.Spectators)) do
			print("  "..ply:GetName().." (SteamID: "..ply:SteamID()..")")
		end
		
		print ("Seekers:")
		for i,ply in ipairs(team.GetPlayers(GAMEMODE.Teams.Seekers)) do
			print("  "..ply:GetName().." (SteamID: "..ply:SteamID()..")")
		end
		
		print ("Hiders:")
		for i,ply in ipairs(team.GetPlayers(GAMEMODE.Teams.Hiders)) do
			print("  "..ply:GetName().." (SteamID: "..ply:SteamID()..")")
		end
	end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE + FCVAR_CHEAT)

-- Debug Command: Print All Players
concommand.Add("ph_debug_stats", function(ply, cmd, args, argStr)
	if GAMEMODE.Config:DebugLog() then 
		for i,ply in ipairs(player.GetAll()) do
			print(ply:GetName().." (SteamID: "..ply:SteamID()..")")
			print("  Team:      "..team.GetName(ply:Team()))
			print("  Alive:     "..tostring(ply.Data.Alive))
			print("  AliveTime: "..tostring(ply.Data.AliveTime))
			print("  Score:     "..tostring(ply.Data.RandomWeight))
		end
	end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE + FCVAR_CHEAT)



-- ------------------------------------------------------------------------- --
--! Network Messages
-- ------------------------------------------------------------------------- --
net.Receive("PlayerEnablePropRotation", function(len, ply)
	if (ply:Team() != GAMEMODE.Teams.Hiders) then
		return
	end
	
	angle = net.ReadAngle()
	
	ply:SetNWBool("PropRotation", true)
	ply.Data.Prop:ApplyRotation(angle)
	
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") enabled prop rotation with angle ["..tostring(angle).."].") end	
end)
net.Receive("PlayerDisablePropRotation", function(len, ply)
	if (ply:Team() != GAMEMODE.Teams.Hiders) then
		return
	end
	
	angle = net.ReadAngle()
	
	ply:SetNWBool("PropRotation", false)
	ply.Data.Prop:ApplyRotation(angle)
	
	if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") enabled prop rotation with angle ["..tostring(angle).."].") end	
end)