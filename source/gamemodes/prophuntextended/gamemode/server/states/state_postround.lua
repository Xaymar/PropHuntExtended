--[[
	The MIT License (MIT)
	
	Copyright (c) 2015-2018 Xaymar

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

include "base.lua"

local CLASS = state("PostRound", GM.States.PostRound)

function CLASS:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StatePostRound: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PostRound)
	
	GAMEMODE.Data.RoundStartTime = CurTime()
	
	-- Fretta Hooks
	hook.Run("RoundEnd")
end

function CLASS:Tick()
	-- Advance State
	if (CurTime() - GAMEMODE.Data.RoundStartTime) >= 5 then -- ToDo: configureable time?
		RoundManager:SetState(StatePostMatch)
		local players = team.GetPlayers(GAMEMODE.Teams.Seekers)
		table.Add(players, team.GetPlayers(GAMEMODE.Teams.Hiders))
		
		-- Assign end of round weighted points.
		local aliveSeekers = 0
		local aliveHiders = 0
		for i,ply in ipairs(players) do
			if ply:Alive() then
				if (ply:Team() == GAMEMODE.Teams.Hiders) then
					aliveHiders = aliveHiders + 1
				elseif (ply:Team() == GAMEMODE.Teams.Seekers) then
					aliveSeekers = aliveSeekers + 1
				end
			end
		end
		for i,ply in ipairs(players) do
			local score = 0
			if (ply:Team() == GAMEMODE:GetRoundWinner()) then
				if (ply:Alive()) then
					score = 2
				else
					score = 1
				end
				if (ply:Team() == GAMEMODE.Teams.Hiders) then
					score = score * aliveHiders
				elseif (ply:Team() == GAMEMODE.Teams.Seekers) then
					score = -1 * score * aliveSeekers
				end
			end
			ply.Data.RandomWeight = ply.Data.RandomWeight + score
		end
		
		-- Team Distribution
		if (GAMEMODE.Config.Teams:Weighted() == true) then
			-- Weighted Teams
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Randomizing Teams using weighted Score.") end
			
			-- table.sort function returns true if it should a should be before b.
			table.sort(players, function(a, b)
				if (a.Data.RandomWeight == b.Data.RandomWeight) then
					return math.random(100) > 50
				else
					return a.Data.RandomWeight > b.Data.RandomWeight
				end
			end)
		elseif (GAMEMODE.Config.Teams:Randomize() == true) then
			-- Randomize Teams
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Randomizing Teams.") end
			
			table.sort(players, function(a,b)
				return math.random(100) > 50
			end)
		else
			-- Swap Teams
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Swapping Teams.") end
			
			table.sort(players, function(a,b)
				return (math.random(100) > 50)
			end)
			table.sort(players, function(a,b)
				if (b:Team() == GAMEMODE.Teams.Seekers) then
					return (a:Team() == GAMEMODE.Teams.Hiders)
				end
				return false
			end)
		end
		
		-- Team Distribution Logic
		local hiders, seekers = {}, {}
		if (GAMEMODE.Config:GameType() == GAMEMODE.Types.Original) then
			-- Game Mode: Basic
			local plyCount, finalPlyCount = #players, math.max(math.ceil(#players / 2), 1)
			for c = 1,finalPlyCount do
				seekers[c] = table.remove(players, 1)
			end
			hiders = players
		elseif (GAMEMODE.Config:GameType() == GAMEMODE.Types.TheDeadHunt) then
			-- Game Mode: The Dead Hunt
			local plyCount, finalPlyCount = #players, math.max(math.ceil(#players * GAMEMODE.Config.Teams:SeekerPercentage()), 1)
			for c = 1,finalPlyCount do
				seekers[c] = table.remove(players, 1)
			end
			hiders = players
		end
		
		-- Kill & Assign Teams
		for i, ply in ipairs(hiders) do
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Assigned '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") to Team Hiders.") end
			ply:KillSilent()
			ply:SetTeam(GAMEMODE.Teams.Hiders)
		end
		for i, ply in ipairs(seekers) do
			if GAMEMODE.Config:DebugLog() then print("Prop Hunt: Assigned '"..ply:GetName().."' (SteamID: "..ply:SteamID()..") to Team Seekers.") end
			ply:KillSilent()
			ply:SetTeam(GAMEMODE.Teams.Seekers)
		end
	end
end

function CLASS:OnLeave(NewState)
	if GAMEMODE.Config:DebugLog() then print("StatePostRound: OnLeave") end
end

_G["StatePostRound"] = CLASS
