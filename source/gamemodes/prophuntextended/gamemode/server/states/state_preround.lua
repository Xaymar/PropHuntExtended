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

local CLASS = state("PreRound", GM.States.PreRound)

function CLASS:OnEnter(OldState)
	if GAMEMODE.Config:DebugLog() then print("StatePreRound: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PreRound)
	GAMEMODE:SetRound(GAMEMODE:GetRound() + 1)
	
	-- Clean Up the Map
	game.CleanUpMap()
	
	-- Set Round Start Time
	GAMEMODE.Data.RoundStartTime = CurTime()

end

function CLASS:Tick()
	-- Advance State
	RoundManager:SetState(StateHide)
end

function CLASS:OnLeave(NewState)
	if GAMEMODE.Config:DebugLog() then print("StatePreRound: OnLeave") end
	
	-- Respawn Everyone
	for i, ply in ipairs(player.GetAll()) do
		ply:KillSilent()
		ply.Data.Alive = true
		ply:Spawn()
		ply:ScreenFade(SCREENFADE.PURGE, color_black, 0, 0)
		ply:ScreenFade(SCREENFADE.IN, color_black, 1, 0)
		
		-- Weighted Score: Adjust towards other Team.
		if (ply:Team() == GAMEMODE.Teams.Hiders) then
			ply.Data.RandomWeight = ply.Data.RandomWeight + 1
		elseif (ply:Team() == GAMEMODE.Teams.Seekers) then
			ply.Data.RandomWeight = ply.Data.RandomWeight - 1
		end
	end
	
	-- Fretta Hooks
	hook.Run("RoundStart")
end

_G["StatePreRound"] = CLASS
