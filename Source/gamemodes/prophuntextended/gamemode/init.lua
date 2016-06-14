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
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("player_class/class_default.lua")
AddCSLuaFile("player_class/class_spectator.lua")
AddCSLuaFile("player_class/class_seeker.lua")
AddCSLuaFile("player_class/class_hider.lua")

-- Client-Only
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("client/cl_ui_teamselection.lua")

-- ------------------------------------------------------------------------- --
--! Code
-- ------------------------------------------------------------------------- --
-- Shared
include "sh_init.lua"

-- Server Only
include "server/config.lua"
include "compat/compat_tauntpackloader.lua"
include "server/roundmanager.lua"
include "server/states/state_prematch.lua"
include "server/states/state_preround.lua"
include "server/states/state_hide.lua"
include "server/states/state_seek.lua"
include "server/states/state_postround.lua"

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
	
	print("Prop Hunt: Initializing Gamemode Data...")
	self.Data = {}
	
	print("Prop Hunt: Setting initial RoundManager State...")
	self.RoundManager:SetState(StatePreMatch)
	
	print("Prop Hunt: Complete.")
	print("-------------------------------------------------------------------------")
end

function GM:Think()
	self.RoundManager:Tick()
end

-- Player Connected
function GM:PlayerConnect(name, ip)
	print("Prop Hunt: Player '"..name.."' connecting from IP '"..ip.."'.")
end

-- Player Authenticated
function GM:PlayerAuthed(ply, steamid, uniqueid)
	print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") authenticated.")
end

-- Player Disconnected
function GM:PlayerDisconnected(ply)
	print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") disconnected.")
end

-- Player Spawn (Initial)
function GM:PlayerInitialSpawn(ply)
	print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") spawned for the first time, applying defaults...")
	
	if (!ply.Data) then
		-- Initialize Data Structure
		ply.Data = {}
		ply.Data.Alive = false
		ply.Data.AliveTime = 0
	end
	
	-- Kill Silently
	ply:KillSilent()
	
	-- Show Team Selection Menu
	ply:SetTeam(GAMEMODE.Teams.Spectators)
	self:ShowTeam(ply)
	
	-- Bot: Auto Assign to Team
	if (ply:IsBot()) then
		if team.NumPlayers(self.Teams.Hiders) > team.NumPlayers(self.Teams.Seekers) then
			print("Prop Hunt: Bot '"..ply:GetName().."' assigned to Seekers.")
			ply:SetTeam(self.Teams.Seekers)
		else
			print("Prop Hunt: Bot '"..ply:GetName().."' assigned to Hiders.")
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
	print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") spawned in.")
	
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
		print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") requested to join Team "..team.GetName(teamId)..".")
		
		if (ply:Team() != teamId) then
			ply:KillSilent()
			ply:SetTeam(teamId)
			
			if (GetGlobalInt("RoundState", GAMEMODE.States.PreMatch) <= GAMEMODE.States.PreRound) then
				ply.Alive = true
				ply.AliveTime = CurTime()
			end
		else
			print("Prop Hunt: Player '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") attempted to rejoin the Team it is already in.")
		end
	end
end

-- ------------------------------------------------------------------------- --
--! Player Manager Binding
-- ------------------------------------------------------------------------- --
function GM:PlayerLoadout(ply) player_manager.RunClass(ply, "Loadout") end
function GM:PlayerDeath(ply, inflictor, attacker) player_manager.RunClass(ply, "Death", inflictor, attacker) end
function GM:PlayerSilentDeath(ply) player_manager.RunClass(ply, "SilentDeath") end
function GM:PostPlayerDeath(ply)
	player_manager.RunClass(ply, "PostDeath")
	
	-- Debug Mode: Respawn after Death
	if (GAMEMODE.Config:Debug()) then
		ply.Data.Alive = true
		print("Prop Hunt: Debug Mode active, Player "..ply:GetName().." was respawned.")
	end
end
--function GM:DoPlayerDeath(ply, attacker, dmg) player_manager.RunClass(ply, "DoDeath", attacker, dmg) end
function GM:PlayerDeathThink(ply) return player_manager.RunClass(ply, "DeathThink") end
function GM:CanPlayerSuicide(ply) return player_manager.RunClass(ply, "CanSuicide") end
function GM:PlayerCanPickupWeapon(ply, weapon) return player_manager.RunClass(ply, "CanPickupWeapon", weapon) end
function GM:PlayerCanPickupItem(ply, item) return player_manager.RunClass(ply, "CanPickupItem", item) end
function GM:PlayerUse(ply, ent) return player_manager.RunClass(ply, "Use", ent) end
function GM:AllowPlayerPickup(ply, ent)	return player_manager.RunClass(ply, "AllowPickup", ent) end
function GM:PlayerSetModel(ply)	return player_manager.RunClass(ply, "SetModel") end

-- Called when an entity takes damage
function GM:EntityTakeDamage(ent, dmg)
	local att = dmg:GetAttacker()
	
	if (att) && (att:IsValid()) && (att:IsPlayer()) then
		player_manager.RunClass(att, "DamageEntity", ent, att, dmg)
	end
end

-- ------------------------------------------------------------------------- --
--! Gamemode Functionality
-- ------------------------------------------------------------------------- --
function GM:SetRoundState(State)
	SetGlobalInt("RoundState", State)
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
function GM:ShowHelp(ply) end

-- F2/ShowTeam - Select Team
function GM:ShowTeam(ply)
	ply:ConCommand("ph_select_team")
end

-- F3/ShowSpare1
function GM:ShowSpare1(ply) end

-- F4/ShowSpare2
function GM:ShowSpare2(ply) end

-- Debug Command: Print All Players
concommand.Add("ph_debug_printplayers", function(ply, cmd, args, argStr)
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
	
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE + FCVAR_CHEAT)

-- ------------------------------------------------------------------------- --
--! LEGACY CODE - TO BE REPLACED SOON
-- ------------------------------------------------------------------------- --
--[[
function AnnounceVictory(players, force)
	for i,pl in ipairs(players) do
		if pl:Alive() || force || pl:Team() == TEAM_SPECTATOR then
			announcer = table.Random(VICTORY_SOUNDS);
			print("Prop Hunt: '"..pl:GetName().."' announcing victory with '"..announcer.."'.")
			pl:EmitSound(announcer, 200, 100, 0.5, CHAN_VOICE2) 
		end
	end
end

function AnnounceLoss(players, force)
	for i,pl in ipairs(players) do
		if pl:Alive() || force || pl:Team() == TEAM_SPECTATOR then
			announcer = table.Random(LOSS_SOUNDS);
			print("Prop Hunt: '"..pl:GetName().."' announcing loss with '"..announcer.."'.")
			pl:EmitSound(announcer, 100, 100, 0.5, CHAN_VOICE2)
		end
	end
end

-- If there is a mapfile send it to the client (sometimes servers want to change settings for certain maps)
if file.Exists("maps/"..game.GetMap()..".lua", "LUA") then
	AddCSLuaFile("maps/"..game.GetMap()..".lua")
end

-- Send the required resources to the client
for _, announcer in pairs(LOSS_SOUNDS) do resource.AddFile("sound/"..announcer) end
for _, announcer in pairs(VICTORY_SOUNDS) do resource.AddFile("source/"..announcer) end
for _, taunt in pairs(HUNTER_TAUNTS) do resource.AddFile("sound/"..taunt) end
for _, taunt in pairs(PROP_TAUNTS) do resource.AddFile("sound/"..taunt) end

-- Called alot
function GM:CheckPlayerDeathRoundEnd()
	if !GAMEMODE.RoundBased || !GAMEMODE:InRound() then 
		return
	end

	local Teams = GAMEMODE:GetTeamAliveCounts()

	if table.Count(Teams) == 0 then
		GAMEMODE:RoundEndWithResult(1001, "Draw, everyone loses!")
		AnnounceLoss(player.GetAll(), true)
		return
	end

	if table.Count(Teams) == 1 then
		-- Play victory and loss sounds.
		if Teams[0] == TEAM_HUNTERS then
			AnnounceVictory(team.GetPlayers(TEAM_HUNTERS))
			AnnounceLoss(team.GetPlayers(TEAM_PROPS))
		elseif Teams[0] == TEAM_PROPS then
			AnnounceLoss(team.GetPlayers(TEAM_HUNTERS))
			AnnounceVictory(team.GetPlayers(TEAM_PROPS))
		end
		
		local TeamID = table.GetFirstKey(Teams)
		GAMEMODE:RoundEndWithResult(TeamID, team.GetName(TeamID).." win!")
		return
	end
end

-- Called when player presses [F3]. Plays a taunt for their team
function GM:ShowSpare1(pl)
	if GAMEMODE:InRound() && pl:Alive() && (pl:Team() == TEAM_HUNTERS || pl:Team() == TEAM_PROPS) && pl.last_taunt_time + TAUNT_DELAY <= CurTime() && #PROP_TAUNTS > 1 && #HUNTER_TAUNTS > 1 then
--		repeat
			if pl:Team() == TEAM_HUNTERS then
				rand_taunt = table.Random(HUNTER_TAUNTS)
			else
				rand_taunt = table.Random(PROP_TAUNTS)
			end
--		until rand_taunt != pl.last_taunt
		
		pl.last_taunt_time = CurTime()
		pl.last_taunt = rand_taunt
		
		print("Prop Hunt: '"..pl:GetName().."' taunting with '"..rand_taunt.."'.")
		local vol = 1.0
		if pl:Team() == TEAM_HUNTERS then vol = vol * 0.5 end
		pl:EmitSound(rand_taunt, 100, 100, vol, CHAN_VOICE2)
	end	
end

-- Allow player to rotate the prop. (Either F4 or ducking)
function GM:ShowSpare2(pl)
	if pl:Alive() && (pl:Team() == TEAM_PROPS) then
		pl.ph_prop:SetApplyNewAngles(!pl.ph_prop:GetApplyNewAngles())
--		pl.ph_prop:SetNewAngles(pl:GetAngles())
	end
end

-- Removes all weapons on a map
function RemoveWeaponsAndItems()
	for _, wep in pairs(ents.FindByClass("weapon_*")) do
		wep:Remove()
	end
	
	for _, item in pairs(ents.FindByClass("item_*")) do
		item:Remove()
	end
end
hook.Add("InitPostEntity", "PH_RemoveWeaponsAndItems", RemoveWeaponsAndItems)

]]