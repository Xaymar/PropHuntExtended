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

StateHide = {}

function StateHide:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StateHide: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.Hide)
	
	-- Round Data
	GAMEMODE.Data.RoundTime = math.abs(GAMEMODE.Config.Round:BlindTime())
	GAMEMODE.Data.RoundStartTime = CurTime()
	
	GAMEMODE:SetRoundTime(GAMEMODE.Data.RoundTime)
end

function StateHide:Tick()
	-- Update Game Time
	GAMEMODE.Data.RoundTime = math.abs(GAMEMODE.Config.Round:BlindTime()) - (CurTime() - GAMEMODE.Data.RoundStartTime)
	GAMEMODE:SetRoundTime(GAMEMODE.Data.RoundTime)
	
	-- Advance to Seeking State
	if (GAMEMODE.Data.RoundTime <= 0) then
		if GAMEMODE.Config:Debug() then print("StateHide: Advancing to Seek stage.") end
		
		GAMEMODE.RoundManager:SetState(StateSeek)
	end
	
	-- Freeze Seekers
	for i, ply in ipairs(team.GetPlayers(GAMEMODE.Teams.Seekers)) do
		ply:Freeze(true)
		ply:Lock()
		ply:ScreenFade(SCREENFADE.IN, color_black, 1, 9999)
	end
	
	-- ToDo: Logic for more game modes here?
end

function StateHide:OnLeave(NewState)
	if GAMEMODE.Config:Debug() then print("StateHide: OnLeave") end
	
	-- Fretta Hooks
	hook.Run("PropHuntUnblind")
end