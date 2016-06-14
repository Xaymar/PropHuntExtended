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

StatePreRound = {}

function StatePreRound:OnEnter(OldState)
	if GAMEMODE.Config:Debug() then print("StatePreRound: OnEnter") end
	GAMEMODE:SetRoundState(GAMEMODE.States.PreRound)
	
	-- Clean Up the Map
	game.CleanUpMap()
	
end
function StatePreRound:Tick()
	-- Advance State
	GAMEMODE.RoundManager:SetState(StateHide)
end
function StatePreRound:OnLeave(NewState)
	if GAMEMODE.Config:Debug() then print("StatePreRound: OnLeave") end
	
	-- Game Mode: Basic
	if (GAMEMODE.Config:GameMode() == GAMEMODE.Modes.Original) then
		-- Respawn Everyone
		for i, ply in ipairs(player.GetAll()) do
			ply:KillSilent()
			ply.Data.Alive = true
			ply:Spawn()
		end
	-- TODO: Other Gamemodes
	end
end