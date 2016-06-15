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

-- ------------------------------------------------------------------------- --
--! Basic Settings
-- ------------------------------------------------------------------------- --
-- Debug Mode
GM.Config.ConVars.Debug = CreateConVar("ph_debug", 0, FCVAR_CHEAT + FCVAR_REPLICATED)
function GM.Config:Debug()
	return self.ConVars.Debug:GetBool()
end

-- Game Mode (See sh_init.lua)
GM.Config.ConVars.GameMode = CreateConVar("ph_gamemode", GM.Modes.Original, FCVAR_REPLICATED)
function GM.Config:GameMode()
	return self.ConVars.GameMode:GetInt()
end

-- Timelimit in minutes
GM.Config.ConVars.TimeLimit = GetConVar("mp_timelimit")
function GM.Config:TimeLimit()
	return self.ConVars.TimeLimit:GetFloat()
end

-- Enable Sprinting?
GM.Config.ConVars.Sprinting = CreateConVar("ph_sprinting", 0, FCVAR_REPLICATED)
function GM.Config:Sprinting()
	return self.ConVars.Sprinting:GetBool()
end

-- Taunt Cooldown (Seconds)
GM.Config.ConVars.TauntCoolDown = CreateConVar("ph_tauntcooldown", 5, FCVAR_REPLICATED)
function GM.Config:TauntCoolDown()
	return self.ConVars.TauntCoolDown:GetFloat()
end

-- ------------------------------------------------------------------------- --
--! Round Settings
-- ------------------------------------------------------------------------- --
GM.Config.Round = {}
GM.Config.Round.ConVars = {}

-- How many rounds should the gamemode attempt to fit into the map timelimit, if there is any?
GM.Config.Round.ConVars.Amount = CreateConVar("ph_round_limit", 10, FCVAR_REPLICATED)
function GM.Config.Round:Amount()
	return self.ConVars.Amount:GetInt()
end

-- Round Time Limit (Seconds, Default 3 minutes)
GM.Config.Round.ConVars.Time = CreateConVar("ph_round_timelimit", 180, FCVAR_REPLICATED)
function GM.Config.Round:Time()
	return self.ConVars.Time:GetInt() - GAMEMODE.Config.Round:BlindTime()
end

-- For how many seconds are the Seekers blinded? (Seconds)
GM.Config.Round.ConVars.BlindTime = CreateConVar("ph_round_blindtime", 30, FCVAR_REPLICATED, "How long are hunters blinded? (positive values will be inside the round time limit, negative will add to the round time limit)")
function GM.Config.Round:BlindTime()
	return self.ConVars.BlindTime:GetInt()
end

-- ------------------------------------------------------------------------- --
--! Seeker Settings
-- ------------------------------------------------------------------------- --
GM.Config.Seeker = {}
GM.Config.Seeker.ConVars = {}

GM.Config.Seeker.ConVars.Health = CreateConVar("ph_seeker_health", 100, FCVAR_REPLICATED)
function GM.Config.Seeker:Health()
	return self.ConVars.Health:GetInt()
end

GM.Config.Seeker.ConVars.HealthMax = CreateConVar("ph_seeker_health_max", 100, FCVAR_REPLICATED)
function GM.Config.Seeker:HealthMax()
	return self.ConVars.HealthMax:GetInt()
end

GM.Config.Seeker.ConVars.HealthBonus = CreateConVar("ph_seeker_health_bonus", 20, FCVAR_REPLICATED)
function GM.Config.Seeker:HealthBonus()
	return self.ConVars.HealthBonus:GetInt()
end

GM.Config.Seeker.ConVars.HealthPenalty = CreateConVar("ph_seeker_health_penalty", 5, FCVAR_REPLICATED)
function GM.Config.Seeker:HealthPenalty()
	return self.ConVars.HealthPenalty:GetInt()
end

GM.Config.Seeker.ConVars.Weapons = CreateConVar("ph_seeker_weapons", "weapon_crowbar,weapon_pistol,weapon_ph_smg,weapon_shotgun", FCVAR_REPLICATED)
function GM.Config.Seeker:Weapons()
	return string.Split(self.ConVars.Weapons:GetString(), ",")
end

GM.Config.Seeker.ConVars.Ammo = CreateConVar("ph_seeker_ammo", "Pistol:100,SMG1:300,SMG1_Grenade:1,Buckshot:64", FCVAR_REPLICATED)
function GM.Config.Seeker:Ammo()
	return string.Split(self.ConVars.Ammo:GetString(), ",")
end

-- ------------------------------------------------------------------------- --
--! Hider Settings
-- ------------------------------------------------------------------------- --
GM.Config.Hider = {}
GM.Config.Hider.ConVars = {}

GM.Config.Hider.ConVars.Health = CreateConVar("ph_hider_health", 100, FCVAR_REPLICATED)
function GM.Config.Hider:Health()
	return self.ConVars.Health:GetInt()
end

GM.Config.Hider.ConVars.HealthMax = CreateConVar("ph_hider_health_max", 100, FCVAR_REPLICATED)
function GM.Config.Hider:HealthMax()
	return self.ConVars.HealthMax:GetInt()
end

GM.Config.Hider.ConVars.HealthScaling = CreateConVar("ph_hider_health_scaling", 100, FCVAR_REPLICATED)
function GM.Config.Hider:HealthScaling()
	return self.ConVars.HealthScaling:GetBool()
end

GM.Config.Hider.ConVars.HealthScalingMax = CreateConVar("ph_hider_health_scaling_max", 200, FCVAR_REPLICATED)
function GM.Config.Hider:HealthScalingMax()
	return self.ConVars.HealthScalingMax:GetInt()
end

-- ------------------------------------------------------------------------- --
--! Whitelist & Blacklist
-- ------------------------------------------------------------------------- --
GM.Config.Lists = {}
GM.Config.Lists.ConVars = {}
GM.Config.Lists.ConCmds = {}

GM.Config.Lists.ConVars.ClassWhitelist = CreateConVar("ph_list_class_whitelist", "prop_physics,prop_physics_multiplayer,prop_physics_respawnable", FCVAR_REPLICATED)
function GM.Config.Lists:ClassWhitelist()
	return string.Split(self.ConVars.ClassWhitelist:GetString(), ",")
end

-- Use Abuse Blacklist
GM.Config.Lists.ConVars.AbuseBlacklist = CreateConVar("ph_list_abuse_blacklist", "func_button,func_door,func_door_rotation,prop_door_rotation,func_tracktrain,func_tanktrain,func_breakable", FCVAR_REPLICATED)
function GM.Config.Lists:AbuseBlacklist()
	return string.Split(self.ConVars.AbuseBlacklist:GetString(), ",")
end

-- Model Blacklist
GM.Config.Lists.ModelBlacklist = {}
GM.Config.Lists.ModelBlacklist["models/props/cs_assault/dollar.mdl"] = true
GM.Config.Lists.ModelBlacklist["models/props/cs_assault/money.mdl"] = true
GM.Config.Lists.ModelBlacklist["models/props/cs_office/snowman_arm.mdl"] = true
GM.Config.Lists.ModelBlacklist["models/props/cs_office/projector_remote.mdl"] = true
--GM.Config.Lists.ModelBlacklist["models/props_junk/garbage_plasticbottle001a.mdl"] = true

GM.Config.Lists.ConCmds.ModelBlacklistList = concommand.Add("ph_list_model_blacklist_list", function(ply, cmd, args, argStr)
	print("Model Blacklist:")
	for k,v in pairs(GAMEMODE.Config.Lists.ModelBlacklist) do
		print("  "..k)
	end
end, "List all blacklisted models.")

GM.Config.Lists.ConCmds.ModelBlacklistClear = concommand.Add("ph_list_model_blacklist_list", function(ply, cmd, args, argStr)
	GM.Config.Lists.ModelBlacklist = {}
end, "Clear blacklisted models.")

GM.Config.Lists.ConCmds.ModelBlacklistAdd = concommand.Add("ph_list_model_blacklist_add", function(ply, cmd, args, argStr)
	if (table.count(args) > 0) then
		GAMEMODE.Config.Lists.ModelBlacklist[args[1]] = true
	else
		print("Missing model name")
	end
end, "Add a new blacklisted model.")

GM.Config.Lists.ConCmds.ModelBlacklistRemove = concommand.Add("ph_list_model_blacklist_remove", function(ply, cmd, args, argStr)
	if (table.count(args) > 0) then
		GAMEMODE.Config.Lists.ModelBlacklist[args[1]] = nil
	else
		print("Missing model name")
	end
end, "Removes a blacklisted model.")

-- ------------------------------------------------------------------------- --
--! Taunts
-- ------------------------------------------------------------------------- --
-- GM.Config.Taunts = {
	-- Seeker = { },
	-- Hider = { },
-- }

-- -- Taunts.Clear()
-- --@desc: Clears the current taunt list.
-- GM.Config.Taunts.Clear = function()
	-- this.Seeker = {}
	-- this.Hider = {}
-- end

-- -- Taunts.Load(sTauntListFile)
-- --@desc: Loads the taunt list from disk.
-- --@param:
-- --  sTauntListFile - A string containing the path to the taunt list to load.
-- --@return: true or false depending on success.
-- GM.Config.Taunts.Load = function(sTauntListFile)
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: Loading taunt list from file '"..sTauntListFile.."'...") end
	
	-- -- Safeguard against idiots.
	-- if type(sTauntListFile) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: <sTauntListFile> is not a string.") end
		-- return false
	-- end
	
	-- -- Given file must exist for us to continue.
	-- if ! file.Exists(sTauntListFile, "GAME") then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: File not found.") end
		-- return false
	-- end
	
	-- -- Read the file and check if it's empty.
	-- sTauntListData = file.Read(sTauntListFile, "GAME")
	-- if sTauntListData == "" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: File is empty.") end
		-- return false
	-- end
	
	-- -- Convert JSON to a table for us to use.
	-- sTauntList = util.JSONToTable(sTauntListData)
	
	-- -- Is it nil? Then it's not valid JSON
	-- if sTauntList == nil then 
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: File contains invalid JSON.") end
		-- return false
	-- end
	
	-- -- Finally, append the taunt lists.
	-- if sTauntList.Seeker != nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: Adding Seeker taunts...") end
		-- for k,v in pairs(sTauntList.Seeker) do
			-- GAMEMODE.Taunts.Seeker[k] = v
		-- end
	-- end
	-- if sTauntList.Hider != nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: Adding Hider taunts...") end
		-- for k,v in pairs(sTauntList.Hider) do
			-- GAMEMODE.Taunts.Hider[k] = v
		-- end
	-- end
	
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Load: Complete.") end
	-- return true
-- end

-- -- Taunts.Save(sTauntListFile)
-- --@desc: Saves the current taunt list to disk.
-- --@param:
-- --  sTauntListFile - A string containing the path to the file to save to.
-- --@return: true or false depending on success.
-- GM.Config.Taunts.Save = function(sTauntListFile)
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Save: Saving taunt list to file '"..sTauntListFile.."'...") end
	
	-- -- Safeguard against idiots.
	-- if type(sTauntListFile) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Save: <sTauntListFile> is not a string.") end
		-- return false
	-- end
	
	-- -- File must not be nil, otherwise we can't write to it.
	-- if sTauntListFile == nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Save: No file given.") end
		-- return false
	-- end
	
	-- -- Convert our taunt table to JSON.
	-- sTauntListData = util.TableToJSON(GAMEMODE.Taunts);
	-- if sTauntListData == nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Save: Corrupted GAMEMODE table.") end
		-- return false
	-- end
	
	-- -- Write out JSON out to file
	-- if ! file.Write(sTauntListFile, sTauntListData) then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Save: Failed to write to file.") end
		-- return false
	-- end
	
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Save: Complete.") end
	-- return true
-- end

-- -- Taunts.Add(sTauntName, sSoundFile, iTeamID, mPropFilter)
-- --@desc: Registers a new taunt with the given name, file, team and filter.
-- --@param:
-- --  sTauntName - The unique name of the taunt.
-- --  sSoundFile - A sound file to play when this taunt is selected.
-- --  iTeamID - The team that should receive the taunt or nil for all teams.
-- --  mPropFilter - A string or a table containing strings for props that should be able to use this taunt.
-- --@return: true or false depending on success.
-- GM.Config.Taunts.Add = function(sTauntName, sSoundFile, iTeamID, mPropFilter)
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: Adding new taunt '"..sTauntName.."'...") end
	
	-- -- Safeguard against idiots.
	-- if type(sTauntName) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: <sTauntName> is not a string.") end
		-- return false
	-- end
	-- if type(sSoundFile) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: <sSoundFile> is not a string.") end
		-- return false
	-- end
	-- if (type(iTeamID) != "number" && iTeamID != nil) then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: <iTeamID> is not a number or nil.") end
		-- return false
	-- end
	-- if (type(mPropFilter) != "string" && type(mPropFilter) != "table" && mPropFilter != nil) then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: <mPropFilter> is not a string, table or nil.") end
		-- return false
	-- end
	
	-- -- Check if the sound file actually exists
	-- if !file.Exists("sound/"..sSoundFile, "GAME") then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: File '"..sSoundFile.."' does not exist.") end
		-- return false
	-- end
	
	-- -- Make sure that our prop filter is a table listing the props it's supposed to work for.
	-- if (mPropFilter == nil) then
		-- mPropFilter = { }
	-- elseif type(mPropFilter) == "string" then
		-- mPropFilter = { mPropFilter }
	-- end
	
	-- -- Prepare Taunt table
	-- Taunt = {
		-- File = sSoundFile,
		-- Filter = mPropFilter
	-- }
	
	-- -- If iTeamID is nil, both teams will receive the taunt.
	-- if iTeamID == nil then
		-- GAMEMODE.Taunts.Seeker[sTauntName] = Taunt
		-- GAMEMODE.Taunts.Hider[sTauntName] = Taunt
	-- else
		-- -- Make sure that the team is valid.
		-- if ! team.Valid(iTeamID) then
			-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: Team "..iTeamID.."' does not exist.") end
			-- return false
		-- end
		
		-- if (iTeamID == TEAM_SEEKERS) then
			-- GAMEMODE.Taunts.Seeker[sTauntName] = Taunt
		-- elseif (iTeamID == TEAM_HIDERS) then
			-- GAMEMODE.Taunts.Hider[sTauntName] = Taunt
		-- else
			-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: Team "..iTeamID.."' can't have taunts.") end
			-- return false
		-- end
	-- end
	
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Add: Complete.") end
	-- return true
-- end

-- -- Taunts.Remove(sTauntName, iTeamID)
-- --@desc: Removes a registered taunt with the given name and team.
-- --@param:
-- --  sTauntName - The unique name of the taunt.
-- --  iTeamID - The team that the taunt should be removed from or nil for all teams.
-- --@return: true or false depending on success.
-- GM.Config.Taunts.Remove = function(sTauntName, iTeamID)
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Remove: Removing taunt '"..sTauntName.."'...") end
	
	-- -- Safeguard against idiots.
	-- if type(sTauntName) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Remove: <sTauntName> is not a string.") end
		-- return false
	-- end
	-- if (type(iTeamID) != "number" && iTeamID != nil) then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Remove: <iTeamID> is not a number or nil.") end
		-- return false
	-- end
	
	-- -- if iTeamID is nil, both teams will have the taunt removed.
	-- if (iTeamID == nil) then
		-- GAMEMODE.Taunts.Seeker[sTauntName] = nil
		-- GAMEMODE.Taunts.Hider[sTauntName] = nil
	-- else
		-- -- Make sure we have a valid Team.
		-- if ! team.Valid(iTeamID) then
			-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Remove: Team "..iTeamID.."' does not exist.") end
			-- return false
		-- end
		
		-- if iTeamID == TEAM_SEEKERS then
			-- GAMEMODE.Taunts.Seeker[sTauntName] = nil
		-- elseif iTeamID == TEAM_HIDERS then
			-- GAMEMODE.Taunts.Hider[sTauntName] = nil
		-- else
			-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Remove: Team "..iTeamID.."' can't have taunts.") end
			-- return false
		-- end
	-- end
	
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Taunts.Remove: Complete.") end
	-- return true
-- end

-- -- ToDo: Taunts.Get(iTeamID, sPropName)

-- --! Announcers (Round Start, Unblind, Win, Loss)
-- GM.Config.Announcers = {
	-- Start = { },
	-- Unblind = { },
	-- Win = { },
	-- Loss = { }
-- }

-- -- Announcers.Clear()
-- --@desc: Clears the current announcer list.
-- GM.Config.Announcers.Clear = function()
	-- Announcers.Start = { }
	-- Announcers.Unblind = { }
	-- Announcers.Win = { }
	-- Announcers.Loss = { }
-- end

-- -- Announcers.Load(sAnnouncerListFile)
-- --@desc: Tries to load the given announcer list.
-- --@param:
-- --  sAnnouncerListFile - A string containing the path to the announcer list to load.
-- --@return: true or false depending on success.
-- GM.Config.Announcers.Load = function(sAnnouncerListFile)
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: Loading announcer list from file '"..sAnnouncerListFile.."'...") end
	
	-- -- Safeguard against idiots.
	-- if type(sAnnouncerListFile) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: <sAnnouncerListFile> is not a string.") end
		-- return false
	-- end
	
	-- -- Given file must exist for us to continue.
	-- if ! file.Exists(sAnnouncerListFile, "GAME") then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: File not found.") end
		-- return false
	-- end
	
	-- -- Read the file and check if it's empty.
	-- sAnnouncerListData = file.Read(sAnnouncerListFile, "GAME")
	-- if sAnnouncerListData == "" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: File is empty.") end
		-- return false
	-- end
			
	-- -- Convert JSON to a table for us to use.
	-- sAnnouncerList = util.JSONToTable(sAnnouncerListData)
	
	-- -- Is it nil? Then it's not valid JSON
	-- if sAnnouncerList == nil then 
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: File contains invalid JSON.") end
		-- return false
	-- end
	
	-- -- Finally, insert the announcer lists.
	-- if sAnnouncerList.Start != nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: Adding Start announcers...") end
		-- for k,v in pairs(sAnnouncerList.Start) do
			-- GAMEMODE.Announcers.Start[k] = v
		-- end
	-- end
	-- if sAnnouncerList.Unblind != nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: Adding Unblind announcers...") end
		-- for k,v in pairs(sAnnouncerList.Unblind) do
			-- GAMEMODE.Announcers.Unblind[k] = v
		-- end
	-- end
	-- if sAnnouncerList.Win != nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: Adding Win announcers...") end
		-- for k,v in pairs(sAnnouncerList.Win) do
			-- GAMEMODE.Announcers.Win[k] = v
		-- end
	-- end
	-- if sAnnouncerList.Loss != nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: Adding Loss announcers...") end
		-- for k,v in pairs(sAnnouncerList.Loss) do
			-- GAMEMODE.Announcers.Loss[k] = v
		-- end
	-- end
	
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Load: Complete.") end
	-- return true
-- end

-- -- Announcers.Save(sAnnouncerListFile)
-- --@desc: Saves the current taunt list to disk.
-- --@param:
-- --  sAnnouncerListFile - A string containing the path to the file to save to.
-- --@return: true or false depending on success.
-- GM.Config.Announcers.Save = function(sAnnouncerListFile)
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Save: Saving announcer list to file '"..sAnnouncerListFile.."'...") end
	
	-- -- Safeguard against idiots.
	-- if type(sAnnouncerListFile) != "string" then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Save: <sAnnouncerListFile> is not a string.") end
		-- return false
	-- end
	
	-- -- File must not be nil, otherwise we can't write to it.
	-- if sAnnouncerListFile == nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Save: No file given.") end
		-- return false
	-- end
	
	-- -- Convert our taunt table to JSON.
	-- sAnnouncerListData = util.TableToJSON(GAMEMODE.Announcers);
	-- if sAnnouncerListData == nil then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Save: Corrupted GAMEMODE table.") end
		-- return false
	-- end
	
	-- -- Write out JSON out to file
	-- if ! file.Write(sAnnouncerListFile, sAnnouncerListData) then
		-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Save: Failed to write to file.") end
		-- return false
	-- end
	
	
	-- if GAMEMODE.Config:Debug() then print("Prop Hunt.Announcers.Save: Complete.") end
	-- return true
-- end

-- -- ToDo: Announcers.Add
-- -- ToDo: Announcers.Remove
-- -- ToDo: Announcers.Get(iType)
