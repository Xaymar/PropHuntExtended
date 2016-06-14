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

-- Precache Network Message
StatePreMatch = {}

function StatePreMatch:OnEnter(OldState)
	if GAMEMODE.Config:Debug() then print("StatePreMatch: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PreMatch)
	
	SetGlobalInt("Round", GetGlobalInt("Round", 0) + 1)
end

function StatePreMatch:Tick()
	-- Debug: Auto Advance to PreRound State
	if (GAMEMODE.Config:Debug()) then
		print("StatePreMatch: Advancing to StatePreRound")
		GAMEMODE.RoundManager:SetState(StatePreRound)
	end
	
	-- Game Mode: Basic
	if (GAMEMODE.Config:GameMode() == GAMEMODE.Modes.Original) then
		-- Both Teams must have at least 1 player.
		if ((team.NumPlayers(GAMEMODE.Teams.Seekers) >= 1) && (team.NumPlayers(GAMEMODE.Teams.Hiders) >= 1)) then
			GAMEMODE.RoundManager:SetState(StatePreRound)
		end
	-- TODO: Other Gamemodes
	end
end

function StatePreMatch:OnLeave(NewState)
	if GAMEMODE.Config:Debug() then print("StatePreMatch: OnLeave") end
end