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

CreateConVar("ph_tauntwaittime", GM.Config.TauntWaitTime)
CreateConVar("ph_sprinting", GM.Config.Sprinting)
CreateConVar("ph_rounds", GM.Config.Rounds.Amount)
CreateConVar("ph_rounds_time", GM.Config.Rounds.Time)
CreateConVar("ph_rounds_blindtime", GM.Config.Rounds.BlindTime)

CreateConVar("ph_modes_swap", GM.Config.Modes.SwapTeams)
CreateConVar("ph_modes_randomize", GM.Config.Modes.RandomizeTeams)
CreateConVar("ph_modes_thedeadhunt", GM.Config.Modes.TheDeadHunt)

CreateConVar("ph_seeker_health", GM.Config.Seeker.HealthStart)
CreateConVar("ph_seeker_health_max", GM.Config.Seeker.HealthMax)
CreateConVar("ph_seeker_health_killbonus", GM.Config.Seeker.HealthBonus)
CreateConVar("ph_seeker_health_penalty", GM.Config.Seeker.HealthPenalty)
CreateConVar("ph_seeker_weapons", GM.Config.Seeker.Weapons)
CreateConVar("ph_seeker_ammo", GM.Config.Seeker.Ammo)

CreateConVar("ph_hider_health", GM.Config.Hider.HealthStart)
CreateConVar("ph_hider_health_max", GM.Config.Hider.HealthMax)
CreateConVar("ph_hider_health_scale", GM.Config.Hider.HealthScaling)
CreateConVar("ph_hider_health_scaled_max", GM.Config.Hider.HealthScalingMax)