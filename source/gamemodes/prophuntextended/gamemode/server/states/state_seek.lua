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

StateSeek = {}

function StateSeek:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StateSeek: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.Seek)
	
	-- Round Data
	GAMEMODE.Data.RoundTime = GAMEMODE.Config.Round:Time()
	
	-- Unfreeze Seekers
	for i, ply in ipairs(team.GetPlayers(GAMEMODE.Teams.Seekers)) do
		ply:Freeze(false)
		ply:UnLock()
		ply:ScreenFade(SCREENFADE.PURGE, color_black, 0, 0)
		ply:ScreenFade(SCREENFADE.IN, color_black, 1, 0)
	end	
end

function StateSeek:Tick()
	-- Update Game Time
	GAMEMODE.Data.RoundTime = GAMEMODE.Config.Round:Time() - (CurTime() - GAMEMODE.Data.RoundStartTime)
	GAMEMODE:SetRoundTime(GAMEMODE.Data.RoundTime)
	
	-- Victory Conditions
	local hiders, seekers = team.GetPlayers(GAMEMODE.Teams.Hiders), team.GetPlayers(GAMEMODE.Teams.Seekers)
	local hiderAlive, seekerAlive = false, false
	if GAMEMODE.Config:Debug() then
		hiderAlive = true;seekerAlive = true
	end
	for i,ply in ipairs(hiders) do
		if (ply.Data.Alive) then
			hiderAlive = true
		end
	end
	for i,ply in ipairs(seekers) do
		if (ply.Data.Alive) then
			seekerAlive = true
		end
	end
	if (hiderAlive == false) then
		if (seekerAlive == false) then -- Draw, both teams dead.
			GAMEMODE:SetRoundWinner(GAMEMODE.Teams.Spectators)
			GAMEMODE.RoundManager:SetState(StatePostRound)
		else -- Seeker victory, Hiders dead
			GAMEMODE:SetRoundWinner(GAMEMODE.Teams.Seekers)
			GAMEMODE.RoundManager:SetState(StatePostRound)
		end
	else
		if (seekerAlive == false) then -- Hider Victory, Seeker dead.
			GAMEMODE:SetRoundWinner(GAMEMODE.Teams.Hiders)
			GAMEMODE.RoundManager:SetState(StatePostRound)
		else
			if (GAMEMODE.Data.RoundTime <= 0) then -- No Time remaining
				GAMEMODE:SetRoundWinner(GAMEMODE.Teams.Hiders)
				GAMEMODE.RoundManager:SetState(StatePostRound)
			end
		end
	end
end

function StateSeek:OnLeave(NewState)
	if GAMEMODE.Config:DebugLog() then print("StateSeek: OnLeave") end
	
	if GAMEMODE:GetRoundWinner() == GAMEMODE.Teams.Seekers then
		-- Run external Hooks
		hook.Run("RoundVictorySeeker")
		
		-- Assign Team Points
		team.SetScore(GAMEMODE.Teams.Seekers, team.GetScore(GAMEMODE.Teams.Seekers) + 1)
	elseif GAMEMODE:GetRoundWinner() == GAMEMODE.Teams.Hiders then
		-- Run external Hooks
		hook.Run("RoundVictoryHider")
		
		-- Assign Team Points
		team.SetScore(GAMEMODE.Teams.Hiders, team.GetScore(GAMEMODE.Teams.Hiders) + 1)
	else
		-- Run external Hooks
		hook.Run("RoundVictoryDraw")		
	end
end