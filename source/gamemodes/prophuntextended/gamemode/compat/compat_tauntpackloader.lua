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

-- This file adds compatability to the older Taunt Pack loader format, which
--  directly modifies the gamemode tables (something that shouldn't be done).

function CompatTauntPackLoader()
	-- Prepare an empty table for the taunts.
	GAMEMODE.Prop_Taunts = {}
	GAMEMODE.Hunter_Taunts = {}
	
	-- Run the old hook name.
	hook.Run("ph_AddTaunts", nil)
	
	-- Insert the taunts into the new structure (cvar).
	Taunts = {}
	for i,t in ipairs(GAMEMODE.Prop_Taunts) do
		ty = type(t)
		if (ty == "string") then
			Taunts[#Taunts+1] = t
		elseif (ty == "table") then
			Taunts[#Taunts+1] = t[1]
		end
	end
	GAMEMODE.Config.Taunt.HidersCacheStatic = Taunts
	Taunts = {}
	for i,t in ipairs(GAMEMODE.Hunter_Taunts) do
		ty = type(t)
		if (ty == "string") then
			Taunts[#Taunts+1] = t
		elseif (ty == "table") then
			Taunts[#Taunts+1] = t[1]
		end
	end
	GAMEMODE.Config.Taunt.SeekersCacheStatic = Taunts
	
	-- Clean up after ourselves
	GAMEMODE.Prop_Taunts = nil
	GAMEMODE.Hunter_Taunts = nil
end
hook.Add("Initialize", "CompatTauntPackLoader", CompatTauntPackLoader)