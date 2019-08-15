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
--! Gamemode Information
-- ------------------------------------------------------------------------- --
GM.Name		= "Prop Hunt Extended"
GM.Author	= "Michael Fabian 'Xaymar' Dirks"
GM.Email	= "info@xaymar.com"
GM.Website	= "http://xaymar.com/"

GM.TeamBased = true
GM.AllowAutoTeam = true
GM.SecondsBetweenTeamSwitches = 10

-- ------------------------------------------------------------------------- --
--! Code
-- ------------------------------------------------------------------------- --
-- Game States
GM.States = {}
GM.States.PreMatch = 0
GM.States.PreRound = 1
GM.States.Hide = 2
GM.States.Seek = 3
GM.States.PostRound = 4
GM.States.PostMatch = 5

-- Game Modes
GM.Types = {}
GM.Types.Original		= 0
GM.Types.TheDeadHunt	= 1 -- Deprecated: One Hunter, Dead Prop become Hunter, Props can't see each other.

-- Teams
GM.Teams = {}
GM.Teams.Spectators = 0
GM.Teams.Seekers = 1
GM.Teams.Hiders = 2

function GM:CreateTeams()
	-- Specators
	team.SetUp(self.Teams.Spectators, "Spectators", Color(127, 127, 127, 255))
	team.SetSpawnPoint(self.Teams.Spectators, {
		"info_player_start",
		"info_player_spawn",
		"info_player_deathmatch",
		"info_player_combine",
		"info_player_counterterrorist",
		"info_player_allies",
		"info_player_terrorist"
	})
	team.SetClass(self.Teams.Spectators, { "Spectator", "Spectator" })

	-- Seekers: "Hunters"
	team.SetUp(self.Teams.Seekers, "Seekers", Color(0, 128, 255, 255))
	team.SetSpawnPoint(self.Teams.Seekers, {
		"info_player_start",
		"info_player_spawn",
		"info_player_deathmatch",
		"info_player_combine",
		"info_player_counterterrorist"
	})
	team.SetClass(self.Teams.Seekers, { "Seeker", "Spectator" })
	
	-- Hiders: "Props"
	team.SetUp(self.Teams.Hiders, "Hiders", Color(255, 128, 0, 255))
	team.SetSpawnPoint(self.Teams.Hiders, {
		"info_player_start",
		"info_player_spawn",
		"info_player_deathmatch",
		"info_player_allies",
		"info_player_terrorist"
	})
	team.SetClass(self.Teams.Hiders, { "Hider", "Spectator" })
end

-- ------------------------------------------------------------------------- --
--! Player Manager Binding
-- ------------------------------------------------------------------------- --
function GM:PlayerPostThink(ply)
	return player_manager.RunClass(ply, "PostThink")
end

function GM:PlayerTick(ply, mv)
	return player_manager.RunClass(ply, "Tick", mv)
end

function GM:FindUseEntity(ply, defaultEnt)
	return player_manager.RunClass(ply, "FindUseEntity", defaultEnt)
end

-- ------------------------------------------------------------------------- --
--! Gamemode Functionality
-- ------------------------------------------------------------------------- --
function GM:GetRound()
	return GetGlobalInt("Round", 0)
end

function GM:GetRoundTime()
	return GetGlobalInt("RoundTime", 0)
end

function GM:GetRoundState()
	return GetGlobalInt("RoundState", self.States.PreMatch)
end

function GM:GetRoundStateTime()
	return GetGlobalInt("RoundStateTime", 0)
end

function GM:GetRoundWinner()
	return GetGlobalInt("RoundWinner", GAMEMODE.Teams.Spectator)
end

-- ------------------------------------------------------------------------- --
--! Includes
-- ------------------------------------------------------------------------- --
-- Meta
include "meta/player.lua"

-- Configuration
include "sh_config.lua"

-- Player Classes
include "player_class/class_default.lua"
include "player_class/class_spectator.lua"
include "player_class/class_seeker.lua"
include "player_class/class_hider.lua"