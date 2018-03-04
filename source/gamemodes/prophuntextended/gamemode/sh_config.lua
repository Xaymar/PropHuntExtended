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

--! Initialize configuration table.
GM.Config = { }
GM.Config.ConVars = {}

function CreateConVarIfNotExists(name, value, flags, helptext)
	cv = GetConVar(name)
	if (cv == nil) then
		cv = CreateConVar(name, value, flags, helptext)
--	else
--		ncv = CreateConVar(name, value, flags, helptext)
	end
	return cv
end

-- ------------------------------------------------------------------------- --
--! Debug Settings
-- ------------------------------------------------------------------------- --
-- Debug Mode
GM.Config.ConVars.Debug = CreateConVarIfNotExists("ph_debug", "0", FCVAR_CHEAT + FCVAR_REPLICATED, "Prop Hunt: Enable Debug Mode")
function GM.Config:Debug()
	return self.ConVars.Debug:GetBool()
end

-- Debug Log
GM.Config.ConVars.DebugLog = CreateConVarIfNotExists("ph_debug_log", "0", FCVAR_REPLICATED, "Prop Hunt: Enable Debug Logging")
function GM.Config:DebugLog()
	return self.ConVars.DebugLog:GetBool()
end

-- ------------------------------------------------------------------------- --
--! Basic Settings
-- ------------------------------------------------------------------------- --
-- Game Mode (See sh_init.lua)
GM.Config.ConVars.GameType = CreateConVarIfNotExists("ph_gametype", GM.Types.Original, FCVAR_REPLICATED, "Prop Hunt: Which Game Type should be played? ("..GM.Types.Original.." = Original Prop Hunt, "..GM.Types.TheDeadHunt.." = The Dead Hunt Mode)")
function GM.Config:GameType()
	return self.ConVars.GameType:GetInt()
end

-- Timelimit in minutes
GM.Config.ConVars.TimeLimit = CreateConVarIfNotExists("mp_timelimit", "20", FCVAR_REPLICATED, "Map Time Limit (in Minutes)")
function GM.Config:TimeLimit()
	return self.ConVars.TimeLimit:GetFloat()
end

-- ------------------------------------------------------------------------- --
--! Round Settings
-- ------------------------------------------------------------------------- --
GM.Config.Round = {}
GM.Config.Round.ConVars = {}

-- How many rounds should the GM attempt to fit into the map timelimit, if there is any?
GM.Config.Round.ConVars.Limit = CreateConVarIfNotExists("ph_round_limit", "10", FCVAR_REPLICATED, "Round Manager: Maximum Rounds to Play on a single Map")
function GM.Config.Round:Limit()
	return self.ConVars.Limit:GetInt()
end

-- Round Time Limit (Seconds, Default 3 minutes)
GM.Config.Round.ConVars.Time = CreateConVarIfNotExists("ph_round_timelimit", "180", FCVAR_REPLICATED, "Round Manager: Time Limit per Round (in Seconds)")
function GM.Config.Round:Time()
	return math.max(self.ConVars.Time:GetFloat() - math.min(self:BlindTime(),0),0)
end

-- For how many seconds are the Seekers blinded? (Seconds)
GM.Config.Round.ConVars.BlindTime = CreateConVarIfNotExists("ph_round_blindtime", "-30", FCVAR_REPLICATED, "Round Manager: Blind Time for Seekers (in Seconds, positive takes away from ph_round_timelimit, negative adds extra time to ph_round_timelimit)")
function GM.Config.Round:BlindTime()
	return self.ConVars.BlindTime:GetFloat()
end

-- ------------------------------------------------------------------------- --
--! Team Settings
-- ------------------------------------------------------------------------- --
GM.Config.Teams = {}
GM.Config.Teams.ConVars = {}

-- Should teams be ranomized each round?
GM.Config.Teams.ConVars.Randomize = CreateConVarIfNotExists("ph_teams_randomize", "0", FCVAR_REPLICATED, "Teams: Randomize Teams instead of swapping each round")
function GM.Config.Teams:Randomize()
	return self.ConVars.Randomize:GetBool()
end

-- Should teams be using weighted randomization?
-- Weighted randomization works by using a score calculated over the entire session.
-- * Round Start: Adjust Score towards the other Team by 1 (Positive = Seeker, Negative = Hider)
-- * Round Win: Adjust score by how many players are still alive on the winning team towards the other team.
-- * Alive players get double the score.
GM.Config.Teams.ConVars.Weighted = CreateConVarIfNotExists("ph_teams_weighted", "1", FCVAR_REPLICATED, "Teams: Use Weighted Randomization")
function GM.Config.Teams:Weighted()
	return self.ConVars.Weighted:GetBool()
end

-- The Dead Hunt: Percent of players to assign to seeker.
GM.Config.Teams.ConVars.SeekerPercentage = CreateConVarIfNotExists("ph_teams_seekerpct", "25", FCVAR_REPLICATED, "Teams: Initial percentage of Seekers in Dead Hunt Game Type")
function GM.Config.Teams:SeekerPercentage()
	return self.ConVars.SeekerPercentage:GetFloat() / 100
end

-- ------------------------------------------------------------------------- --
--! Seeker Settings
-- ------------------------------------------------------------------------- --
GM.Config.Seeker = {}
GM.Config.Seeker.ConVars = {}

GM.Config.Seeker.ConVars.Health = CreateConVarIfNotExists("ph_seeker_health", "100", FCVAR_REPLICATED, "Seekers: Initial Health")
function GM.Config.Seeker:Health()
	return self.ConVars.Health:GetInt()
end

GM.Config.Seeker.ConVars.HealthMax = CreateConVarIfNotExists("ph_seeker_health_max", "100", FCVAR_REPLICATED, "Seekers: Maximum Health")
function GM.Config.Seeker:HealthMax()
	return self.ConVars.HealthMax:GetInt()
end

GM.Config.Seeker.ConVars.HealthBonus = CreateConVarIfNotExists("ph_seeker_health_bonus", "20", FCVAR_REPLICATED, "Seekers: Health Bonus per Kill")
function GM.Config.Seeker:HealthBonus()
	return self.ConVars.HealthBonus:GetInt()
end

GM.Config.Seeker.ConVars.HealthPenalty = CreateConVarIfNotExists("ph_seeker_health_penalty", "5", FCVAR_REPLICATED, "Seekers: Health Penalty per wrong Shot")
function GM.Config.Seeker:HealthPenalty()
	return self.ConVars.HealthPenalty:GetInt()
end

GM.Config.Seeker.ConVars.Weapons = CreateConVarIfNotExists("ph_seeker_weapons", "weapon_crowbar,weapon_pistol,weapon_ph_smg,weapon_shotgun", FCVAR_REPLICATED, "Seekers: Initial Weapons (Weapon,Weapon,...)")
function GM.Config.Seeker:Weapons()
	return string.Split(self.ConVars.Weapons:GetString(), ",")
end

GM.Config.Seeker.ConVars.Ammo = CreateConVarIfNotExists("ph_seeker_ammo", "Pistol:100,SMG1:300,SMG1_Grenade:1,Buckshot:64", FCVAR_REPLICATED, "Seekers: Initial Ammo (Ammo:Amount,Ammo:Amount,...)")
function GM.Config.Seeker:Ammo()
	return string.Split(self.ConVars.Ammo:GetString(), ",")
end

GM.Config.Seeker.ConVars.WalkSpeed = CreateConVarIfNotExists("ph_seeker_walk_speed", "250", 0, "Seekers: Walk Speed")
function GM.Config.Seeker:WalkSpeed()
	return self.ConVars.WalkSpeed:GetFloat()
end

GM.Config.Seeker.ConVars.Sprint = CreateConVarIfNotExists("ph_seeker_sprint", "1", FCVAR_REPLICATED, "Seekers: Allow Sprinting")
function GM.Config.Seeker:Sprint()
	return self.ConVars.Sprint:GetBool()
end

GM.Config.Seeker.ConVars.SprintSpeed = CreateConVarIfNotExists("ph_seeker_sprint_speed", "500", 0, "Seekers: Sprint Speed")
function GM.Config.Seeker:SprintSpeed()
	return self.ConVars.SprintSpeed:GetFloat()
end

GM.Config.Seeker.ConVars.JumpPower = CreateConVarIfNotExists("ph_seeker_jump_power", "200", 0, "Seekers: Jump Power")
function GM.Config.Seeker:JumpPower()
	return self.ConVars.JumpPower:GetFloat()
end

-- ------------------------------------------------------------------------- --
--! Hider Settings
-- ------------------------------------------------------------------------- --
GM.Config.Hider = {}
GM.Config.Hider.ConVars = {}

GM.Config.Hider.ConVars.Health = CreateConVarIfNotExists("ph_hider_health", "100", FCVAR_REPLICATED, "Hiders: Initial Health")
function GM.Config.Hider:Health()
	return self.ConVars.Health:GetInt()
end

GM.Config.Hider.ConVars.HealthMax = CreateConVarIfNotExists("ph_hider_health_max", "100", FCVAR_REPLICATED, "Hiders: Maximum Health")
function GM.Config.Hider:HealthMax()
	return self.ConVars.HealthMax:GetInt()
end

GM.Config.Hider.ConVars.HealthScaling = CreateConVarIfNotExists("ph_hider_health_scaling", "1", FCVAR_REPLICATED, "Hiders: Enable Health Scaling")
function GM.Config.Hider:HealthScaling()
	return self.ConVars.HealthScaling:GetBool()
end

GM.Config.Hider.ConVars.HealthScalingMax = CreateConVarIfNotExists("ph_hider_health_scaling_max", "200", FCVAR_REPLICATED, "Hiders: Maximum scaled Health")
function GM.Config.Hider:HealthScalingMax()
	return self.ConVars.HealthScalingMax:GetInt()
end

GM.Config.Hider.ConVars.AllowFullRotation = CreateConVarIfNotExists("ph_hider_allow_full_rotation", "0", FCVAR_REPLICATED, "Hiders: Enable full 3D Rotation")
function GM.Config.Hider:AllowFullRotation()
	return self.ConVars.AllowFullRotation:GetBool()
end

GM.Config.Hider.ConVars.WalkSpeed = CreateConVarIfNotExists("ph_hider_walk_speed", "250", 0, "Hiders: Walk Speed")
function GM.Config.Hider:WalkSpeed()
	return self.ConVars.WalkSpeed:GetFloat()
end

GM.Config.Hider.ConVars.Sprint = CreateConVarIfNotExists("ph_hider_sprint", "0", FCVAR_REPLICATED, "Hiders: Allow Sprinting")
function GM.Config.Hider:Sprint()
	return self.ConVars.Sprint:GetBool()
end

GM.Config.Hider.ConVars.SprintSpeed = CreateConVarIfNotExists("ph_hider_sprint_speed", "500", 0, "Hiders: Sprint Speed")
function GM.Config.Hider:SprintSpeed()
	return self.ConVars.SprintSpeed:GetFloat()
end

GM.Config.Hider.ConVars.JumpPower = CreateConVarIfNotExists("ph_hider_jump_power", "200", 0, "Hiders: Jump Power")
function GM.Config.Hider:JumpPower()
	return self.ConVars.JumpPower:GetFloat()
end

-- ------------------------------------------------------------------------- --
--! Whitelist & Blacklist
-- ------------------------------------------------------------------------- --
GM.Config.Lists = {}
GM.Config.Lists.ConVars = {}

-- Class Whitelist
GM.Config.Lists.ConVars.ClassWhitelist = CreateConVarIfNotExists("ph_list_class_whitelist", "prop_physics,prop_physics_multiplayer,prop_physics_respawnable", FCVAR_REPLICATED, "Anti-Cheat: Whitelisted Hider Classes")
function GM.Config.Lists:ClassWhitelist()
	local str = self.ConVars.ClassWhitelist:GetString()
	if (self.ClassWhitelistCache != str) then
		self.ClassWhitelistCache = str
		self.ClassWhitelistCacheTbl = string.Split(self.ClassWhitelistCache, ",")
	end
	return self.ClassWhitelistCacheTbl
end

-- Abuse Blacklist
GM.Config.Lists.ConVars.AbuseBlacklist = CreateConVarIfNotExists("ph_list_abuse_blacklist", "func_button,func_door,func_door_rotation,prop_door_rotation,func_tracktrain,func_tanktrain,func_breakable", FCVAR_REPLICATED, "Anti-Cheat: Entity Abuse Blacklist")
function GM.Config.Lists:AbuseBlacklist()
	local str = self.ConVars.AbuseBlacklist:GetString()
	if (self.AbuseBlacklistCache != str) then
		self.AbuseBlacklistCache = str
		self.AbuseBlacklistCacheTbl = string.Split(self.AbuseBlacklistCache, ",")
	end
	return self.AbuseBlacklistCacheTbl
end

-- Model Blacklist
GM.Config.Lists.ConVars.ModelBlacklist = CreateConVarIfNotExists("ph_list_model_blacklist", "models/props/cs_assault/dollar.mdl,models/props/cs_assault/money.mdl,models/props/cs_office/snowman_arm.mdl,models/props/cs_office/projector_remote.mdl", FCVAR_REPLICATED, "Anti-Cheat: Model Abuse Blacklist")
function GM.Config.Lists:ModelBlacklist()
	local str = self.ConVars.ModelBlacklist:GetString()
	if (self.ModelBlacklistCache != str) then
		self.ModelBlacklistCache = str
		self.ModelBlacklistCacheTbl = string.Split(self.ModelBlacklistCache, ",")
	end
	return self.ModelBlacklistCacheTbl
end

-- ------------------------------------------------------------------------- --
--! Taunts
-- ------------------------------------------------------------------------- --
GM.Config.Taunt = {}
GM.Config.Taunt.ConVars = {}

-- Cooldown (Seconds)
GM.Config.Taunt.ConVars.Cooldown = CreateConVarIfNotExists("ph_taunt_cooldown", 5, FCVAR_REPLICATED, "Prop Hunt: Cooldown between Taunts")
function GM.Config.Taunt:Cooldown()
	return self.ConVars.Cooldown:GetFloat()
end

-- Seeker
GM.Config.Taunt.SeekersCache = ""
GM.Config.Taunt.SeekersCacheDynamic = nil
GM.Config.Taunt.SeekersCacheStatic = nil
GM.Config.Taunt.SeekersCacheFull = nil
GM.Config.Taunt.ConVars.Seekers = CreateConVarIfNotExists("ph_taunt_seekers", "bot/a_bunch_of_them.wav,bot/come_out_and_fight_like_a_man.wav,bot/come_out_wherever_you_are.wav,bot/come_to_papa.wav,bot/dont_worry_hell_get_it.wav,bot/hang_on_i_heard_something.wav,bot/hang_on_im_coming.wav,bot/i_dont_think_so.wav,bot/i_have_the_hostages.wav,bot/i_see_our_target.wav,bot/im_waiting_here.wav,bot/keeping_an_eye_on_the_hostages.wav,bot/nnno_sir.wav,bot/spotted_the_delivery_boy.wav,bot/target_acquired.wav,bot/target_spotted.wav,bot/you_heard_the_man_lets_go.wav", 0, "Prop Hunt: Seeker Taunts")
function GM.Config.Taunt:Seekers()
	local str = self.ConVars.Seekers:GetString()
	if (self.SeekersCache != str) then
		self.SeekersCache = str
		self.SeekersCacheDynamic = string.Split(self.SeekersCache, ",")
		self.SeekersCacheFull = table.Add(self.SeekersCacheDynamic, self.SeekersCacheStatic)
		for i,snd in ipairs(self.SeekersCacheFull) do
			util.PrecacheSound(snd)
		end
	end
	return self.SeekersCacheFull
end

-- Hider
GM.Config.Taunt.HidersCache = ""
GM.Config.Taunt.HidersCacheDynamic = nil
GM.Config.Taunt.HidersCacheStatic = nil
GM.Config.Taunt.HidersCacheFull = nil
GM.Config.Taunt.ConVars.Hiders = CreateConVarIfNotExists("ph_taunt_hiders", "ambient/alarms/apc_alarm_pass1.wav,ambient/alarms/manhack_alert_pass1.wav,ambient/alarms/razortrain_horn1.wav,ambient/alarms/scanner_alert_pass1.wav,ambient/alarms/train_horn2.wav,ambient/alarms/train_horn_distant1.wav,ambient/alarms/warningbell1.wav,ambient/energy/whiteflash.wav,ambient/intro/alyxremove.wav,ambient/intro/logosfx.wav,ambient/levels/launch/1stfiringwarning.wav,ambient/levels/launch/rockettakeoffblast.wav,ambient/misc/ambulance1.wav,ambient/misc/carhonk1.wav,ambient/misc/carhonk2.wav,ambient/misc/carhonk3.wav,ambient/outro/gunshipcrash.wav,ambient/3dmeagle.wav,beams/beamstart5.wav,buttons/bell1.wav,buttons/weapon_cant_buy.wav,common/bass.wav,common/bugreporter_failed.wav,common/warning.wav,doors/door_squeek1.wav,friends/friend_join.wav,friends/friend_online.wav,friends/message.wav,hostage/hunuse/comeback.wav,hostage/hunuse/dontleaveme.wav,hostage/hunuse/yeahillstay.wav,items/gift_drop.wav,music/radio1.mp3,phx/eggcrack.wav,plats/elevbell1.wav,player/headshot1.wav,player/headshot2.wav,player/sprayer.wav,radio/enemydown.wav,radio/go.wav,radio/locknload.wav,radio/negative.wav,radio/rounddraw.wav,radio/takepoint.wav,resource/warning.wav,ui/achievement_earned.wav,ui/freeze_cam.wav,vehicles/junker/radar_ping_friendly1.wav,weapons/c4/c4_beep1.wav,weapons/c4/c4_click.wav,weapons/awp/awp1.wav,vo/canals/female01/gunboat_giveemhell.wav,vo/canals/female01/gunboat_justintime.wav,vo/canals/female01/stn6_incoming.wav,vo/canals/male01/gunboat_giveemhell.wav,vo/canals/male01/gunboat_justintime.wav,vo/canals/male01/stn6_incoming.wav,vo/canals/al_radio_stn6.wav,vo/canals/arrest_getgoing.wav,vo/canals/arrest_helpme.wav,vo/canals/arrest_lookingforyou.wav,vo/canals/boxcar_lethimhelp.wav,vo/canals/matt_closecall.wav,vo/canals/premassacre.wav,vo/ravenholm/aimforhead.wav,vo/ravenholm/bucket_patience.wav,vo/ravenholm/madlaugh01.wav,vo/ravenholm/madlaugh02.wav,vo/ravenholm/madlaugh03.wav,vo/ravenholm/madlaugh04.wav,weapons/strider_buster/ol12_stickybombcreator.wav,weapons/c4/c4_explode1.wav,weapons/357/357_fire2.wav,weapons/357/357_fire3.wav,weapons/scout/scout_fire-1.wav,weapons/smokegrenade/sg_explode.wav,weapons/grenade_launcher1.wav,weapons/explode3.wav,weapons/underwater_explode3.wav,items/nvg_on.wav,hostage/huse/letsdoit.wav,hostage/huse/illfollow.wav,hostage/huse/getouttahere.wav,doors/door_screen_move1.wav,doors/heavy_metal_stop1.wav,doors/default_move.wav,common/stuck2.wav,ambient/water_splash1.wav,ambient/water_splash2.wav,ambient/water_splash3.wav,ambient/weather/thunder1.wav,ambient/weather/thunder2.wav,ambient/weather/thunder3.wav,ambient/weather/thunder4.wav,ambient/weather/thunder5.wav,ambient/weather/thunder6.wav,ambient/outro/thunder7.wav,ambient/voices/crying_loop1.wav,ambient/voices/playground_memory.wav,ambient/voices/f_scream1.wav,ambient/voices/m_scream1.wav,ambient/voices/cough1.wav,ambient/voices/cough2.wav,ambient/voices/cough3.wav,ambient/voices/cough4.wav,ambient/overhead/plane1.wav,ambient/overhead/plane2.wav,ambient/overhead/plane3.wav,ambient/overhead/hel1.wav,ambient/overhead/hel2.wav,ambient/misc/truck_backup1.wav,ambient/misc/truck_drive1.wav,ambient/misc/truck_drive2.wav,ambient/machines/pneumatic_drill_1.wav,ambient/machines/pneumatic_drill_2.wav,ambient/machines/pneumatic_drill_3.wav,ambient/machines/pneumatic_drill_4.wav,ambient/machines/station_train_squeel.wav,ambient/machines/ticktock.wav,ambient/creatures/teddy.wav,ambient/creatures/town_child_scream1.wav,ambient/creatures/town_moan1.wav,ambient/creatures/town_muffled_cry1.wav,ambient/creatures/town_scared_breathing1.wav,ambient/creatures/town_scared_breathing2.wav,ambient/creatures/town_scared_sob1.wav,ambient/creatures/town_scared_sob2.wav,ambient/creatures/town_zombie_call1.wav", 0, "Prop Hunt: Hider Taunts")
function GM.Config.Taunt:Hiders()
	local str = self.ConVars.Hiders:GetString()
	if (self.HidersCacheDynamic == nil)
		|| (self.HidersCache != str) then
		self.HidersCache = str
		self.HidersCacheDynamic = string.Split(self.HidersCache, ",")
		self.HidersCacheFull = table.Add(self.HidersCacheDynamic, self.HidersCacheStatic)
		for i,snd in ipairs(self.HidersCacheFull) do
			util.PrecacheSound(snd)
		end
	end
	return self.HidersCacheFull
end

-- ------------------------------------------------------------------------- --
--! Announcers
-- ------------------------------------------------------------------------- --

-- --! Announcers (Round Start, Unblind, Win, Loss)
-- GM.Config.Announcers = {
	-- Start = { },
	-- Unblind = { },
	-- Win = { },
	-- Loss = { }
-- }

-- ------------------------------------------------------------------------- --
--! Camera
-- ------------------------------------------------------------------------- --
GM.Config.Camera = {}
GM.Config.Camera.ConVars = {}

-- Allow Camera No Clip
GM.Config.Camera.ConVars.AllowNoClip = CreateConVarIfNotExists("ph_camera_allow_noclip", "0", FCVAR_REPLICATED, "Camera: Allow clients to disable camera collision.")
function GM.Config.Camera:AllowNoClip()
	return self.ConVars.AllowNoClip:GetBool()
end

-- Camera Distance Maximum
GM.Config.Camera.ConVars.DistanceMax = CreateConVarIfNotExists("ph_camera_distance_max", "150", FCVAR_REPLICATED, "Camera: Maximum allowed distance to player.")
function GM.Config.Camera:DistanceMax()
	return self.ConVars.DistanceMax:GetFloat()
end

-- Camera Distance Minimum
GM.Config.Camera.ConVars.DistanceMin = CreateConVarIfNotExists("ph_camera_distance_min", "30", FCVAR_REPLICATED, "Camera: Minimum allowed distance to player.")
function GM.Config.Camera:DistanceMin()
	return self.ConVars.DistanceMin:GetFloat()
end

-- Camera Distance Right Maximum
GM.Config.Camera.ConVars.DistanceRightRange = CreateConVarIfNotExists("ph_camera_distance_right_range", "20", FCVAR_REPLICATED, "Camera: Horizontal allowed camera distance range.")
function GM.Config.Camera:DistanceRightRange()
	return self.ConVars.DistanceRightRange:GetFloat()
end

-- Camera Distance Up Maximum
GM.Config.Camera.ConVars.DistanceUpRange = CreateConVarIfNotExists("ph_camera_distance_up_range", "20", FCVAR_REPLICATED, "Camera: Vertical allowed camera distance range.")
function GM.Config.Camera:DistanceUpRange()
	return self.ConVars.DistanceUpRange:GetFloat()
end

-- Lag Minimum
GM.Config.Camera.ConVars.LagMinimum = CreateConVarIfNotExists("ph_camera_lag_min", "0.01", FCVAR_REPLICATED, "Camera: Minimum Camera Lag.")
function GM.Config.Camera:LagMinimum()
	return self.ConVars.LagMinimum:GetFloat()
end

-- Lag Maximum
GM.Config.Camera.ConVars.LagMaximum = CreateConVarIfNotExists("ph_camera_lag_max", "0.95", FCVAR_REPLICATED, "Camera: Maximum Camera Lag.")
function GM.Config.Camera:LagMaximum()
	return self.ConVars.LagMaximum:GetFloat()
end

if CLIENT then
	-- Collisions
	GM.Config.Camera.ConVars.Collisions = CreateConVarIfNotExists("ph_camera_collisions", "1", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Camera: Enable collisions with the world and objects in it.")
	function GM.Config.Camera:Collisions()
		if self:AllowNoClip() then
			return self.ConVars.Collisions:GetBool()
		else
			return true
		end
	end

	-- Distance
	GM.Config.Camera.ConVars.Distance = CreateConVarIfNotExists("ph_camera_distance", "100", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Camera: Ideal Distance to player.")
	function GM.Config.Camera:Distance()
		return math.Clamp(self.ConVars.Distance:GetFloat(), self:DistanceMin(), self:DistanceMax())
	end

	-- Distance Right
	GM.Config.Camera.ConVars.DistanceRight = CreateConVarIfNotExists("ph_camera_distance_right", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Camera: Ideal Distance to player horizontally.")
	function GM.Config.Camera:DistanceRight()
		return math.Clamp(self.ConVars.DistanceRight:GetFloat(), -self:DistanceRightRange(), self:DistanceRightRange())
	end

	-- Distance Up
	GM.Config.Camera.ConVars.DistanceUp = CreateConVarIfNotExists("ph_camera_distance_up", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Camera: Ideal Distance to player vertically.")
	function GM.Config.Camera:DistanceUp()
		return math.Clamp(self.ConVars.DistanceUp:GetFloat(), -self:DistanceUpRange(), self:DistanceUpRange())
	end

	-- Lag
	GM.Config.Camera.ConVars.Lag = CreateConVarIfNotExists("ph_camera_lag", "0.95", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Camera: Percentage of camera lag (higher = slower, lower = faster).")
	function GM.Config.Camera:Lag()
		return math.Clamp(self.ConVars.Lag:GetFloat(), self:LagMinimum(), self:LagMaximum())
	end
end

-- ------------------------------------------------------------------------- --
--! Name Plates
-- ------------------------------------------------------------------------- --
GM.Config.NamePlates = {}
GM.Config.NamePlates.ConVars = {}

if CLIENT then
	-- Show
	GM.Config.NamePlates.ConVars.Show = CreateConVarIfNotExists("ph_nameplates_show", "1", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Show a name plate above each player in your team (or all players if spectating).")
	function GM.Config.NamePlates:Show()
		return self.ConVars.Show:GetBool()
	end
	
	-- Scale
	GM.Config.NamePlates.ConVars.Scale = CreateConVarIfNotExists("ph_nameplates_scale", "0.05", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: World scale of name plate, a setting of 1 means 1px = 1unit.")
	function GM.Config.NamePlates:Scale()
		return self.ConVars.Scale:GetFloat()
	end
	
	-- Height
	GM.Config.NamePlates.ConVars.Height = CreateConVarIfNotExists("ph_nameplates_height", "10", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Height above player.")
	function GM.Config.NamePlates:Height()
		return self.ConVars.Height:GetFloat()
	end
	
	-- Tint Color
	GM.Config.NamePlates.ConVars.TintHue = CreateConVarIfNotExists("ph_nameplates_tint_hue", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Tint hue.")
	function GM.Config.NamePlates:TintHue()
		return self.ConVars.TintHue:GetFloat()
	end
	GM.Config.NamePlates.ConVars.TintSaturation = CreateConVarIfNotExists("ph_nameplates_tint_saturation", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Tint saturation.")
	function GM.Config.NamePlates:TintSaturation()
		return self.ConVars.TintSaturation:GetFloat()
	end
	GM.Config.NamePlates.ConVars.TintValue = CreateConVarIfNotExists("ph_nameplates_tint_value", "1", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Tint value.")
	function GM.Config.NamePlates:TintValue()
		return self.ConVars.TintValue:GetFloat()
	end
	
	-- Tint By Health
	GM.Config.NamePlates.ConVars.TintHealth = CreateConVarIfNotExists("ph_nameplates_tint_health", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Tint the nameplate using their health percent.")
	function GM.Config.NamePlates:TintHealth()
		return self.ConVars.TintHealth:GetBool()
	end
	
	-- Tint By Team
	GM.Config.NamePlates.ConVars.TintTeam = CreateConVarIfNotExists("ph_nameplates_tint_team", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Nameplates: Tint the nameplate with the team colors.")
	function GM.Config.NamePlates:TintTeam()
		return self.ConVars.TintTeam:GetBool()
	end	
end

-- ------------------------------------------------------------------------- --
--! Selection Halo
-- ------------------------------------------------------------------------- --
GM.Config.SelectionHalo = {}
GM.Config.SelectionHalo.ConVars = {}

-- Allow
GM.Config.SelectionHalo.ConVars.Allow = CreateConVarIfNotExists("ph_selectionhalo_allow", "1", FCVAR_REPLICATED, "Selection Halo: Allow clients to enable halo around the currently looked at prop?")
function GM.Config.SelectionHalo:Allow()
	return self.ConVars.Allow:GetBool()
end

-- Approximate
GM.Config.SelectionHalo.ConVars.Approximate = CreateConVarIfNotExists("ph_selectionhalo_approximate", "1", FCVAR_REPLICATED, "Selection Halo: Enable approximate selection halo, which only checks the forward vector on the client.")
function GM.Config.SelectionHalo:Approximate()
	return self.ConVars.Approximate:GetBool()
end

if SERVER then
	-- Update Interval
	GM.Config.SelectionHalo.ConVars.Interval = CreateConVarIfNotExists("ph_selectionhalo_interval", "0.05", FCVAR_ARCHIVE, "Selection Halo: Interval for updates of the accuracte selection halo in seconds.")
	function GM.Config.SelectionHalo:Interval()
		return self.ConVars.Interval:GetFloat()
	end
end

if CLIENT then
	-- Enabled
	GM.Config.SelectionHalo.ConVars.Enabled = CreateConVarIfNotExists("ph_selectionhalo_enabled", "1", FCVAR_ARCHIVE, "Selection Halo: Enable halo around prop you might become.")
	function GM.Config.SelectionHalo:Enabled()
		if (self:Allow()) then
			return self.ConVars.Enabled:GetBool()
		else
			return false
		end
	end
	
	-- Settings
	GM.Config.SelectionHalo.ConVars.Passes = CreateConVarIfNotExists("ph_selectionhalo_passes", "1", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Passes")
	function GM.Config.SelectionHalo:Passes()
		return self.ConVars.Passes:GetInt()
	end
	GM.Config.SelectionHalo.ConVars.Additive = CreateConVarIfNotExists("ph_selectionhalo_additive", "1", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Additive")
	function GM.Config.SelectionHalo:Additive()
		return self.ConVars.Additive:GetBool()
	end
	GM.Config.SelectionHalo.ConVars.IgnoreZ = CreateConVarIfNotExists("ph_selectionhalo_ignorez", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Ignore Z")
	function GM.Config.SelectionHalo:IgnoreZ()
		return self.ConVars.IgnoreZ:GetBool()
	end
	
	-- Blur
	GM.Config.SelectionHalo.ConVars.BlurX = CreateConVarIfNotExists("ph_selectionhalo_blur_x", "2", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Blur X")
	function GM.Config.SelectionHalo:BlurX()
		return self.ConVars.BlurX:GetFloat()
	end
	GM.Config.SelectionHalo.ConVars.BlurY = CreateConVarIfNotExists("ph_selectionhalo_blur_y", "2", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Blur Y")
	function GM.Config.SelectionHalo:BlurY()
		return self.ConVars.BlurY:GetFloat()
	end
	
	-- Tint Color
	GM.Config.SelectionHalo.ConVars.TintHue = CreateConVarIfNotExists("ph_selectionhalo_tint_hue", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Tint Hue")
	function GM.Config.SelectionHalo:TintHue()
		return self.ConVars.TintHue:GetFloat()
	end
	GM.Config.SelectionHalo.ConVars.TintSaturation = CreateConVarIfNotExists("ph_selectionhalo_tint_saturation", "0", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Tint Saturation")
	function GM.Config.SelectionHalo:TintSaturation()
		return self.ConVars.TintSaturation:GetFloat()
	end
	GM.Config.SelectionHalo.ConVars.TintValue = CreateConVarIfNotExists("ph_selectionhalo_tint_value", "1", FCVAR_ARCHIVE + FCVAR_CLIENTDLL, "Selection Halo: Tint Value")
	function GM.Config.SelectionHalo:TintValue()
		return self.ConVars.TintValue:GetFloat()
	end
end
