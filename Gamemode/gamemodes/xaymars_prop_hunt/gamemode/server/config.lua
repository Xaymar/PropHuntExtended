--[[
	The MIT License (MIT)
	
	Copyright (c) 2015 Project Kube

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

--! Basic Settings
-- Timelimit in minutes
GM.Config.TimeLimit				= math.max(GetConVarNumber("mp_timelimit"),0)
-- You have to wait x seconds to taunt again.
GM.Config.TauntWaitTime			= 5
-- Is sprinting enabled?
GM.Config.Sprinting				= 0 --false

--! Round Settings
GM.Config.Rounds = {}
-- How many rounds should we attempt to have?
GM.Config.Rounds.Amount			= 10
-- Rounds last x seconds.
GM.Config.Rounds.Time			= 300
-- Time for HIders to hide.
GM.Config.Rounds.BlindTime		= 30

--! Game Modes
GM.Config.Modes = {}
-- Sub-mode: Simple Team Swap
GM.Config.Modes.SwapTeams		= 1--true
-- Sub-mode: Randomize Teams
GM.Config.Modes.RandomizeTeams	= 0--false
-- Sub-mode: The Dead Hunt (Dead Prop becomes Hunter)
GM.Config.Modes.TheDeadHunt		= 0--false

--! Seeker Settings
GM.Config.Seeker = {}
GM.Config.Seeker.HealthStart		= 100
GM.Config.Seeker.HealthMax			= 100
GM.Config.Seeker.HealthBonus		= 10
GM.Config.Seeker.HealthPenalty		= 1
GM.Config.Seeker.Weapons			= "weapon_crowbar,weapon_pistol,weapon_ph_smg,weapon_shotgun"
GM.Config.Seeker.Ammo				= "Pistol:100,SMG1:300,SMG1_Grenade:1,Buckshot:64"

--! Hider Settings
GM.Config.Hider = {}
GM.Config.Hider.HealthStart		= 100
GM.Config.Hider.HealthMax			= 100
GM.Config.Hider.HealthScaling		= 1--true
GM.Config.Hider.HealthScalingMax	= 200

--! Taunts
GM.Config.Taunts = {
	Seeker = { },
	Hider = { },
}

-- Taunts.Clear()
--@desc: Clears the current taunt list.
GM.Config.Taunts.Clear = function()
	this.Seeker = {}
	this.Hider = {}
end

-- Taunts.Load(sTauntListFile)
--@desc: Loads the taunt list from disk.
--@param:
--  sTauntListFile - A string containing the path to the taunt list to load.
--@return: true or false depending on success.
GM.Config.Taunts.Load = function(sTauntListFile)
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: Loading taunt list from file '"..sTauntListFile.."'...") end
	
	-- Safeguard against idiots.
	if type(sTauntListFile) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: <sTauntListFile> is not a string.") end
		return false
	end
	
	-- Given file must exist for us to continue.
	if ! file.Exists(sTauntListFile, "GAME") then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: File not found.") end
		return false
	end
	
	-- Read the file and check if it's empty.
	sTauntListData = file.Read(sTauntListFile, "GAME")
	if sTauntListData == "" then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: File is empty.") end
		return false
	end
	
	-- Convert JSON to a table for us to use.
	sTauntList = util.JSONToTable(sTauntListData)
	
	-- Is it nil? Then it's not valid JSON
	if sTauntList == nil then 
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: File contains invalid JSON.") end
		return false
	end
	
	-- Finally, append the taunt lists.
	if sTauntList.Seeker != nil then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: Adding Seeker taunts...") end
		for k,v in pairs(sTauntList.Seeker) do
			GAMEMODE.Taunts.Seeker[k] = v
		end
	end
	if sTauntList.Hider != nil then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: Adding Hider taunts...") end
		for k,v in pairs(sTauntList.Hider) do
			GAMEMODE.Taunts.Hider[k] = v
		end
	end
	
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Load: Complete.") end
	return true
end

-- Taunts.Save(sTauntListFile)
--@desc: Saves the current taunt list to disk.
--@param:
--  sTauntListFile - A string containing the path to the file to save to.
--@return: true or false depending on success.
GM.Config.Taunts.Save = function(sTauntListFile)
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Save: Saving taunt list to file '"..sTauntListFile.."'...") end
	
	-- Safeguard against idiots.
	if type(sTauntListFile) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Save: <sTauntListFile> is not a string.") end
		return false
	end
	
	-- File must not be nil, otherwise we can't write to it.
	if sTauntListFile == nil then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Save: No file given.") end
		return false
	end
	
	-- Convert our taunt table to JSON.
	sTauntListData = util.TableToJSON(GAMEMODE.Taunts);
	if sTauntListData == nil then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Save: Corrupted GAMEMODE table.") end
		return false
	end
	
	-- Write out JSON out to file
	if ! file.Write(sTauntListFile, sTauntListData) then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Save: Failed to write to file.") end
		return false
	end
	
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Save: Complete.") end
	return true
end

-- Taunts.Add(sTauntName, sSoundFile, iTeamID, mPropFilter)
--@desc: Registers a new taunt with the given name, file, team and filter.
--@param:
--  sTauntName - The unique name of the taunt.
--  sSoundFile - A sound file to play when this taunt is selected.
--  iTeamID - The team that should receive the taunt or nil for all teams.
--  mPropFilter - A string or a table containing strings for props that should be able to use this taunt.
--@return: true or false depending on success.
GM.Config.Taunts.Add = function(sTauntName, sSoundFile, iTeamID, mPropFilter)
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: Adding new taunt '"..sTauntName.."'...") end
	
	-- Safeguard against idiots.
	if type(sTauntName) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: <sTauntName> is not a string.") end
		return false
	end
	if type(sSoundFile) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: <sSoundFile> is not a string.") end
		return false
	end
	if (type(iTeamID) != "number" && iTeamID != nil) then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: <iTeamID> is not a number or nil.") end
		return false
	end
	if (type(mPropFilter) != "string" && type(mPropFilter) != "table" && mPropFilter != nil) then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: <mPropFilter> is not a string, table or nil.") end
		return false
	end
	
	-- Check if the sound file actually exists
	if !file.Exists("sound/"..sSoundFile, "GAME") then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: File '"..sSoundFile.."' does not exist.") end
		return false
	end
	
	-- Make sure that our prop filter is a table listing the props it's supposed to work for.
	if (mPropFilter == nil) then
		mPropFilter = { }
	elseif type(mPropFilter) == "string" then
		mPropFilter = { mPropFilter }
	end
	
	-- Prepare Taunt table
	Taunt = {
		File = sSoundFile,
		Filter = mPropFilter
	}
	
	-- If iTeamID is nil, both teams will receive the taunt.
	if iTeamID == nil then
		GAMEMODE.Taunts.Seeker[sTauntName] = Taunt
		GAMEMODE.Taunts.Hider[sTauntName] = Taunt
	else
		-- Make sure that the team is valid.
		if ! team.Valid(iTeamID) then
			if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: Team "..iTeamID.."' does not exist.") end
			return false
		end
		
		if (iTeamID == TEAM_SEEKERS) then
			GAMEMODE.Taunts.Seeker[sTauntName] = Taunt
		elseif (iTeamID == TEAM_HIDERS) then
			GAMEMODE.Taunts.Hider[sTauntName] = Taunt
		else
			if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: Team "..iTeamID.."' can't have taunts.") end
			return false
		end
	end
	
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Add: Complete.") end
	return true
end

-- Taunts.Remove(sTauntName, iTeamID)
--@desc: Removes a registered taunt with the given name and team.
--@param:
--  sTauntName - The unique name of the taunt.
--  iTeamID - The team that the taunt should be removed from or nil for all teams.
--@return: true or false depending on success.
GM.Config.Taunts.Remove = function(sTauntName, iTeamID)
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Remove: Removing taunt '"..sTauntName.."'...") end
	
	-- Safeguard against idiots.
	if type(sTauntName) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Remove: <sTauntName> is not a string.") end
		return false
	end
	if (type(iTeamID) != "number" && iTeamID != nil) then
		if GAMEMODE.Debug then print("Prop Hunt.Taunts.Remove: <iTeamID> is not a number or nil.") end
		return false
	end
	
	-- if iTeamID is nil, both teams will have the taunt removed.
	if (iTeamID == nil) then
		GAMEMODE.Taunts.Seeker[sTauntName] = nil
		GAMEMODE.Taunts.Hider[sTauntName] = nil
	else
		-- Make sure we have a valid Team.
		if ! team.Valid(iTeamID) then
			if GAMEMODE.Debug then print("Prop Hunt.Taunts.Remove: Team "..iTeamID.."' does not exist.") end
			return false
		end
		
		if iTeamID == TEAM_SEEKERS then
			GAMEMODE.Taunts.Seeker[sTauntName] = nil
		elseif iTeamID == TEAM_HIDERS then
			GAMEMODE.Taunts.Hider[sTauntName] = nil
		else
			if GAMEMODE.Debug then print("Prop Hunt.Taunts.Remove: Team "..iTeamID.."' can't have taunts.") end
			return false
		end
	end
	
	if GAMEMODE.Debug then print("Prop Hunt.Taunts.Remove: Complete.") end
	return true
end

-- ToDo: Taunts.Get(iTeamID, sPropName)

--! Announcers (Round Start, Unblind, Win, Loss)
GM.Config.Announcers = {
	Start = { },
	Unblind = { },
	Win = { },
	Loss = { }
}

-- Announcers.Clear()
--@desc: Clears the current announcer list.
GM.Config.Announcers.Clear = function()
	Announcers.Start = { }
	Announcers.Unblind = { }
	Announcers.Win = { }
	Announcers.Loss = { }
end

-- Announcers.Load(sAnnouncerListFile)
--@desc: Tries to load the given announcer list.
--@param:
--  sAnnouncerListFile - A string containing the path to the announcer list to load.
--@return: true or false depending on success.
GM.Config.Announcers.Load = function(sAnnouncerListFile)
	if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: Loading announcer list from file '"..sAnnouncerListFile.."'...") end
	
	-- Safeguard against idiots.
	if type(sAnnouncerListFile) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: <sAnnouncerListFile> is not a string.") end
		return false
	end
	
	-- Given file must exist for us to continue.
	if ! file.Exists(sAnnouncerListFile, "GAME") then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: File not found.") end
		return false
	end
	
	-- Read the file and check if it's empty.
	sAnnouncerListData = file.Read(sAnnouncerListFile, "GAME")
	if sAnnouncerListData == "" then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: File is empty.") end
		return false
	end
			
	-- Convert JSON to a table for us to use.
	sAnnouncerList = util.JSONToTable(sAnnouncerListData)
	
	-- Is it nil? Then it's not valid JSON
	if sAnnouncerList == nil then 
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: File contains invalid JSON.") end
		return false
	end
	
	-- Finally, insert the announcer lists.
	if sAnnouncerList.Start != nil then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: Adding Start announcers...") end
		for k,v in pairs(sAnnouncerList.Start) do
			GAMEMODE.Announcers.Start[k] = v
		end
	end
	if sAnnouncerList.Unblind != nil then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: Adding Unblind announcers...") end
		for k,v in pairs(sAnnouncerList.Unblind) do
			GAMEMODE.Announcers.Unblind[k] = v
		end
	end
	if sAnnouncerList.Win != nil then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: Adding Win announcers...") end
		for k,v in pairs(sAnnouncerList.Win) do
			GAMEMODE.Announcers.Win[k] = v
		end
	end
	if sAnnouncerList.Loss != nil then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: Adding Loss announcers...") end
		for k,v in pairs(sAnnouncerList.Loss) do
			GAMEMODE.Announcers.Loss[k] = v
		end
	end
	
	if GAMEMODE.Debug then print("Prop Hunt.Announcers.Load: Complete.") end
	return true
end

-- Announcers.Save(sAnnouncerListFile)
--@desc: Saves the current taunt list to disk.
--@param:
--  sAnnouncerListFile - A string containing the path to the file to save to.
--@return: true or false depending on success.
GM.Config.Announcers.Save = function(sAnnouncerListFile)
	if GAMEMODE.Debug then print("Prop Hunt.Announcers.Save: Saving announcer list to file '"..sAnnouncerListFile.."'...") end
	
	-- Safeguard against idiots.
	if type(sAnnouncerListFile) != "string" then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Save: <sAnnouncerListFile> is not a string.") end
		return false
	end
	
	-- File must not be nil, otherwise we can't write to it.
	if sAnnouncerListFile == nil then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Save: No file given.") end
		return false
	end
	
	-- Convert our taunt table to JSON.
	sAnnouncerListData = util.TableToJSON(GAMEMODE.Announcers);
	if sAnnouncerListData == nil then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Save: Corrupted GAMEMODE table.") end
		return false
	end
	
	-- Write out JSON out to file
	if ! file.Write(sAnnouncerListFile, sAnnouncerListData) then
		if GAMEMODE.Debug then print("Prop Hunt.Announcers.Save: Failed to write to file.") end
		return false
	end
	
	
	if GAMEMODE.Debug then print("Prop Hunt.Announcers.Save: Complete.") end
	return true
end

-- ToDo: Announcers.Add
-- ToDo: Announcers.Remove
-- ToDo: Announcers.Get(iType)

--! Whitelists and Blacklists
-- Hiders: Entity Whitelist (exact match)
GM.Config.EntityWhitelist = {
	"prop_physics",
	"prop_physics_multiplayer"
}

-- Hiders: Prop Blacklist (exact match)
GM.Config.PropBlacklist = {}

-- Both: Entity Use-abuse Blacklist (exact match)
GM.Config.EntityAbuseBlacklist = {
	"func_door",
	"func_door_rotating",
	"prop_door_rotating"
}
