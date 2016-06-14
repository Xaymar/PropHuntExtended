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

StatePostRound = {}

function StatePostRound:OnEnter(OldState)
	if GAMEMODE.Config:Debug() then print("StatePostRound: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PostRound)
end

function StatePostRound:Tick()
	-- Advance State
	GAMEMODE.RoundManager:SetState(StatePreRound) -- Test: Reset to Hide
end

function StatePostRound:OnLeave(NewState)
	if GAMEMODE.Config:Debug() then print("StatePostRound: OnLeave") end
	
	-- Game Mode: Basic
	if (GAMEMODE.Config:GameMode() == GAMEMODE.Modes.Original) then
		-- Swap Teams
		local hiders, seekers = team.GetPlayers(GAMEMODE.Teams.Hiders), team.GetPlayers(GAMEMODE.Teams.Seekers)
		for i, ply in ipairs(hiders) do
			ply:SetTeam(GAMEMODE.Teams.Seekers)
			player_manager.SetPlayerClass(ply, "Seeker")
		end
		for i, ply in ipairs(seekers) do
			ply:SetTeam(GAMEMODE.Teams.Hiders)
			player_manager.SetPlayerClass(ply, "Hider")
		end
		
	-- TODO: Other Gamemodes
	end	
end