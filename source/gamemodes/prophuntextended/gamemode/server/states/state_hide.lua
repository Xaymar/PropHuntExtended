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

local CLASS = state("Hide", GM.States.Hide)

function CLASS:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StateHide: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.Hide)
end

function CLASS:Tick()
	-- Update Game Time
	local deltaTime = (CurTime() - GAMEMODE.Data.RoundStartTime)
	GAMEMODE.Data.RoundTime = GAMEMODE.Config.Round:Time() - deltaTime
	GAMEMODE.Data.StateTime = math.abs(GAMEMODE.Config.Round:BlindTime()) - deltaTime
	GAMEMODE:SetRoundTime(GAMEMODE.Data.RoundTime)
	GAMEMODE:SetRoundStateTime(GAMEMODE.Data.StateTime)
	
	-- Advance to Seeking State
	if (GAMEMODE.Data.StateTime <= 0) then
		if GAMEMODE.Config:Debug() then print("StateHide: Advancing to Seek stage.") end
		
		RoundManager:SetState(StateSeek)
	end
	
	-- Freeze Seekers
	for i, ply in ipairs(team.GetPlayers(GAMEMODE.Teams.Seekers)) do
		ply:Freeze(true)
		ply:Lock()
		ply:ScreenFade(SCREENFADE.IN, color_black, 1, 9999)
	end
	
	-- ToDo: Logic for more game modes here?
end

function CLASS:OnLeave(NewState)
	if GAMEMODE.Config:Debug() then print("StateHide: OnLeave") end
	
	-- Fretta Hooks
	hook.Run("PropHuntUnblind")
end

_G["StateHide"] = CLASS
