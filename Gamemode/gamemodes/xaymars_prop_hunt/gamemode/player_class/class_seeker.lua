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

--! This file defines the Seeker player class.
-- A seeker is someone who is looking for the hiders, using weapons or other
--  means of detecting idiots. Also someone who looks like a diaper baby.
-- Weapons and Ammo are granted upon spawn and have to be used sparingly or
--  they'll be stuck with the crowbar. Bad seeker, bad.
-- Gain health upon killing a hider, lose health when attacking non-hiders.
-- Death upon health reaching 0.

DEFINE_BASECLASS( "player_default" )
local SEEKER = {}
SEEKER.DisplayName			= "Seeker"
SEEKER.WalkSpeed			= 230		-- How fast to move when not running
SEEKER.RunSpeed				= 460		-- How fast to move when running
SEEKER.CrouchedWalkSpeed	= 0.2		-- Multiply move speed by this when crouching
SEEKER.DuckSpeed			= 0.2		-- How fast to go from not ducking, to ducking
SEEKER.UnDuckSpeed			= 0.2		-- How fast to go from ducking, to not ducking
SEEKER.JumpPower			= 200		-- How powerful our jump should be
SEEKER.CanUseFlashlight		= true		-- Can we use the flashlight
SEEKER.MaxHealth			= 100		-- Max health we can have
SEEKER.StartHealth			= 100		-- How much health we start with
SEEKER.StartArmor			= 0			-- How much armour we start with
SEEKER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
SEEKER.TeammateNoCollide	= true		-- Do we collide with teammates or run straight through them
SEEKER.AvoidPlayers			= true		-- Automatically swerves around other players
SEEKER.UseVMHands			= true		-- Uses viewmodel hands

-- Called by spawn and sets loadout
function SEEKER:Loadout(pl)
	-- Give the weapons the admin told us to.
	local weapons = string.Split(GM.Config.Seeker.Weapons, ",")
	for i,weapon in ipairs(weapons) do
		pl:Give(weapon)
	end
	
	-- Give the ammo the admin told us to.
	local ammos = string.Split(GM.Config.Seeker.Ammo, ",")
	for i,ammo in ipairs(ammos) do
		local typeCount = string.Split(ammo, ":")
		pl:GiveAmmo(typeCount[1], typeCount[0], true)
	end
	
	-- Default weapon stuff
	local cl_defaultweapon = pl:GetInfo("cl_defaultweapon") 
 	if pl:HasWeapon(cl_defaultweapon) then 
 		pl:SelectWeapon(cl_defaultweapon)
 	end 
end

-- Called when player spawns with this class
function SEEKER:OnSpawn(pl)
	local unlock_time = math.Clamp(GetConVar("ph_rounds_blindtime"):GetInt() - (CurTime() - GetGlobalFloat("RoundStartTime", 0)), 0, GetConVar("ph_rounds_blindtime"):GetInt()) - 1
	-- !TODO! ph_rounds_blindtime
	
	--function MyLockFunc()
	--function MyUnlockFunc()
	
	local unblindfunc = function()
		if pl:IsValid() == false then return end
		--MyUnblindFunc(pl.Blind(false))
		pl:Blind(false)
	end
	local lockfunc = function()
		if pl:IsValid() == false then return end
		--MyLockFunc(pl.Lock())
		pl.Lock(pl)
	end
	local unlockfunc = function()
		if pl:IsValid() == false then return end
		--MyUnlockFunc(pl.UnLock())
		pl.UnLock(pl)
	end
	
	if unlock_time > 2 then
		pl:Blind(true)
		
		timer.Simple(unlock_time, unblindfunc)
		
		timer.Simple(1, lockfunc)
		timer.Simple(unlock_time, unlockfunc)
	end
	
	pl:SetupHands()
end

function SEEKER:GetHandsModel()
	return { model = "models/weapons/c_arms_combine.mdl", skin = 1, body = "0100000" }
end

-- Called when a player dies with this SEEKER
function SEEKER:OnDeath(pl, attacker, dmginfo)
	pl:CreateRagdoll()
	pl:UnLock()
end

-- Register
player_manager.RegisterClass("Seeker", SEEKER)
