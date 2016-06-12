-- Gamemode Information
GM.Name		= "Prop Hunt"
GM.Author	= "Michael 'Xaymar' Dirks (Based on Kow@lskis Version, Original by AMT)"
GM.Email	= "michael.fabian.dirks@gmail.com"
GM.Website	= "http://xaymar.com/"
GM.Debug	= (cvars.Number("developer") != 0)

-- ToDo: Remove fretta as a base gamemode (it's outdated and doesn't help us much).
DeriveGamemode("fretta13")

-- Shared Lua Files
if SERVER then
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_player.lua")
end

-- Player Classes
if SERVER then
	AddCSLuaFile("player_class/class_seeker.lua")
	AddCSLuaFile("player_class/class_hider.lua")
end
include "player_class/class_seeker.lua"
include "player_class/class_hider.lua"

-- Set up Teams
TEAM_SPECTATOR	= 0
TEAM_SEEKERS	= 1
TEAM_HIDERS		= 2
TEAM_HUNTERS	= TEAM_SEEKERS		-- Deprecated
TEAM_PROPS		= TEAM_HIDERS		-- Deprecated

function GM:CreateTeams()
	-- Seekers: "Hunters"
	team.SetUp(TEAM_SEEKERS, "Seekers", Color(153, 204, 255, 255))
	team.SetSpawnPoint(TEAM_SEEKERS, {
		"info_player_deathmatch",
		"info_player_axis",
		"info_player_combine",
		"info_player_counterterrorist"
	})
	team.SetClass(TEAM_SEEKERS, { "Seeker" })
	
	-- Hiders: "Props"
	team.SetUp(TEAM_HIDERS, "Hiders", Color(255, 204, 153, 255))
	team.SetSpawnPoint(TEAM_HIDERS, {
		"info_player_deathmatch",
		"info_player_allies",
		"info_player_terrorist"
	})
	team.SetClass(TEAM_HIDERS, { "Hider" })
end





-- Gamemode Player Code & Data
include("sh_player.lua")

-- Gamemode Configuration Code & Data
include("sh_config.lua")

-- Include the configuration for this map
if file.Exists("maps/"..game.GetMap()..".lua", "LUA") || file.Exists("maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

-- Help info
GM.Help = [[Prop Hunt is a twist on the classic backyard game Hide and Seek.

As a Prop you have ]]..GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt()..[[ seconds to replicate an existing prop on the map and then find a good hiding spot. Press [E] to replicate the prop you are looking at. Your health is scaled based on the size of the prop you replicate.

As a Hunter you will be blindfolded for the first ]]..GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt()..[[ seconds of the round while the Props hide. When your blindfold is taken off, you will need to find props controlled by players and kill them. Damaging non-player props will lower your health significantly. However, killing a Prop will increase your health by ]]..GetConVar("HUNTER_KILL_BONUS"):GetInt()..[[ points.

Both teams can press [F3] to play a taunt sound. Props can press F4 to enable rotation.]]


-- Fretta configuration
GM.AddFragsToTeamScore		= true
GM.CanOnlySpectateOwnTeam 	= true
GM.Data 					= {}
GM.EnableFreezeCam			= true
GM.GameLength				= GAME_TIME
GM.NoAutomaticSpawning		= true
GM.NoNonPlayerPlayerDamage	= true
GM.NoPlayerPlayerDamage 	= true
GM.RoundBased				= true
GM.RoundLimit				= ROUNDS_PER_MAP
GM.RoundLength 				= ROUND_TIME
GM.RoundPreStartTime		= 0
GM.SelectModel				= false
GM.SuicideString			= "couldn't take the pressure and committed suicide."
GM.TeamBased 				= true
