--[[
	The MIT License (MIT)
	
	Copyright (c) 2015 Project Kube

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

-- This file adds compatability to the older Taunt Pack loader format, which
--  directly modifies the gamemode tables (something that shouldn't be done).

function CompatTauntPackLoader()
	-- Prepare an empty table for the taunts.
	GAMEMODE.Prop_Taunts = {}
	GAMEMODE.Hunter_Taunts = {}
	
	-- Run the old hook name.
	hook.Run("ph_AddTaunts", nil)
	
	-- Insert the taunts into the new structure.
	for k,v in ipairs(GAMEMODE.Hunter_Taunts) do
		-- ToDo: string.GetFileFromFilename is broken!
		--pcall(GAMEMODE.Config.Taunts.Add("TauntPackLoader."..string.GetFileFromFilename(v), v, TEAM_SEEKERES, nil))
	end
	for k,v in ipairs(GAMEMODE.Prop_Taunts) do
		--pcall(GAMEMODE.Config.Taunts.Add("TauntPackLoader."..string.GetFileFromFilename(v), v, TEAM_HIDERS, nil))
	end
	
	-- Clean up after ourselves
	GAMEMODE.Prop_Taunts = nil
	GAMEMODE.Hunter_Taunts = nil
end
hook.Add("OnPropHuntInitialized", "CompatTauntPackLoader", CompatTauntPackLoader)