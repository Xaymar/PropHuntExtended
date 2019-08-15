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

local CLASS = state("PreMatch", GM.States.PreMatch)

function CLASS:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StatePreMatch: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PreMatch)
	
	math.randomseed(CurTime())
end

function CLASS:Tick()
	-- Debug: Auto Advance to PreRound State
	if (GAMEMODE.Config:Debug()) then
		if GAMEMODE.Config:DebugLog() then print("StatePreMatch: Advancing to StatePreRound") end
		RoundManager:SetState(StatePreRound)
	end
	
	-- Game Mode: Basic
	if (GAMEMODE.Config:GameType() == GAMEMODE.Types.Original) then
		-- Both Teams must have at least 1 player.
		if ((team.NumPlayers(GAMEMODE.Teams.Seekers) >= 1) && (team.NumPlayers(GAMEMODE.Teams.Hiders) >= 1)) then
			RoundManager:SetState(StatePreRound)
			if GAMEMODE.Config:DebugLog() then print("StatePreMatch: <Original> Have enough players to start match.") end
		end
	-- TODO: Other Gamemodes
	end
end

function CLASS:OnLeave(NewState)
	if GAMEMODE.Config:DebugLog() then print("StatePreMatch: OnLeave") end
end

_G["StatePreMatch"] = CLASS
