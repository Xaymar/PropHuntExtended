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

local CLASS = state("PostMatch", GM.States.PostMatch)

function CLASS:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StatePostMatch: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PostMatch)
	
	self.NextState = StatePreMatch
	
	-- Check Change map conditions.
	if ((GAMEMODE.Config:TimeLimit() > 0) && ((CurTime() - GAMEMODE.Data.StartTime) >= (GAMEMODE.Config:TimeLimit() * 60))) -- Over Time
		|| ((GAMEMODE.Config.Round:Limit() > 0) && (GAMEMODE:GetRound() >= GAMEMODE.Config.Round:Limit())) -- Over Round Limit
		then
		
		-- Advance to nothing
		GAMEMODE:SetRoundState(-1)
		self.NextState = nil
		
		-- MapVote
		if (MapVote != nil) then MapVote.Start(30, true, 30, "ph_") return end
	end
end

function CLASS:Tick()
	-- Advance State
	RoundManager:SetState(self.NextState)
end

function CLASS:OnLeave(NewState)
	if GAMEMODE.Config:DebugLog() then print("StatePostMatch: OnLeave") end
end

_G["StatePostMatch"] = CLASS
