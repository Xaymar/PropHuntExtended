--[[
	The MIT License (MIT)
	
	Copyright (c) 2017 Xaymar

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

-- Finds the player meta table or terminates
local meta = FindMetaTable("Player")
if !meta then print("FAILED TO FIND PLAYER META") return end

-- Blinds the player by setting view out into the void
function meta:Blind(bool)
	if !self:IsValid() then return end
	
	if SERVER then
		umsg.Start("SetBlind", self)
		if bool then
			umsg.Bool(true)
		else
			umsg.Bool(false)
		end
		umsg.End()
	elseif CLIENT then
		blind = bool
	end
end

-- Blinds the player by setting view out into the void
function meta:RemoveProp()
	if CLIENT || !self:IsValid() then return end
	
	if self.ph_prop && self.ph_prop:IsValid() then
		self.ph_prop:Remove()
		self.ph_prop = nil
	end
end

-- Sets a new Hull for a player.
function meta:NewHull(hullOBBMin, hullOBBMax)
	if !self:IsValid() then return end
	if hullOBBMax == nil then return end
	if hullOBBMin == nil then return end

	local hullOBB = hullOBBMax - hullOBBMin
	local hullOBBXY = math.max(hullOBB.x, hullOBB.y)
	
	local xyMul = 0.5
	local hullMin = Vector(-hullOBBXY * xyMul, -hullOBBXY * xyMul, 0)
	local hullMax = Vector( hullOBBXY * xyMul,  hullOBBXY * xyMul, hullOBB.z)
	
	self:SetHull(hullMin, hullMax)
	self:SetHullDuck(hullMin, hullMax)
	self:SetViewOffset(Vector(0, 0, hullOBB.z))
	self:SetViewOffsetDucked(Vector(0, 0, hullOBB.z / 2.0))
end

-- Can the passed entity be used by the player?
function testflag(set, flag)
	if (flag == 0) then return true end -- Mod(%) by 0 is nan.
	return (set % (2 * flag)) >= flag
end

function meta:IsUseableEntity(ent, requiredCaps)
	if ((ent != nil) && (ent:IsValid())) then
		local caps = ent:ObjectCaps()
		local capsmask = 16 + 32 + 64 + 128
		if (testflag(caps, 16) 
			|| testflag(caps, 32) 
			|| testflag(caps, 64) 
			|| testflag(caps, 128)
			) && testflag(caps, requiredCaps) then
			return true
		end
	end	
	return false
end

function IntervalDistance(x, x0, x1)
	-- swap so x0 < x1
	if ( x0 > x1 ) then
		local tmp = x0
		x0 = x1
		x1 = tmp
	end

	if ( x < x0 ) then
		return x0-x
	elseif ( x > x1 ) then
		return x - x1
	end
	return 0
end

-- Find useable entity (Lua version of CBasePlayer:FindUseEntity)
function meta:FindUseEntity()
	-- https://raw.githubusercontent.com/ValveSoftware/source-sdk-2013/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/shared/baseplayer_shared.cpp
	local PLAYER_USE_RADIUS = 80
	
	-- Vectors
	local forward = self:EyeAngles():Forward()
	local up = self:EyeAngles():Up()
	local center = self:EyePos()
	
	local trace = {
		start = center,
		endpos = center,
		mins = Vector(-16, -16, -16),
		maxs = Vector( 16,  16,  16),
		mask = MASK_SOLID + CONTENTS_DEBRIS + CONTENTS_PLAYERCLIP,
		filter = function(ent)
			if (ent == self) then return false end
			if (!ent:IsValid()) then return false end
			if (ent:IsPlayer()) then return false end
			if (ent == self:GetHands()) then return false end
			return true
		end,
		output = {}
	}
	
	local foundEnt = nil	
	local nearestDist = 16777216
	local nearestEnt = nil
	
	local tangents_num = 8
	local tangents = {}
	tangents[1] = 0
	tangents[2] = 1
	tangents[3] = 0.57735026919
	tangents[4] = 0.3639702342
	tangents[5] = 0.267949192431
	tangents[6] = 0.1763269807
	tangents[7] = -0.1763269807
	tangents[8] = -0.267949192431
	for idx=1,tangents_num,1 do
		if (idx == 1) then
			trace.endpos = center + forward * 1024
			util.TraceLine(trace)
		else
			local down = forward - (Vector(tangents[idx], tangents[idx], tangents[idx]) * up)
			down:Normalize()
			trace.endpos = center + down * 72
			util.TraceHull(trace)
		end
		foundEnt = trace.output.Entity
		
		local useable = self:IsUseableEntity(foundEnt, 0)
		while ((foundEnt:IsValid()) && !useable && (foundEnt:GetMoveParent():IsValid())) do
			foundEnt = foundEnt:GetMoveParent()
			useable = self:IsUseableEntity(foundEnt, 0)
		end
		
		if (useable) then
			local delta = trace.output.HitPos - trace.output.StartPos
			local centerZ = foundEnt:WorldSpaceCenter().z
			delta.z = IntervalDistance(trace.output.HitPos.z, centerZ + foundEnt:OBBMins().z, centerZ + foundEnt:OBBMaxs().z)
			local dist = delta:Length()
			if (dist < PLAYER_USE_RADIUS) then
				if (foundEnt:IsNPC() && (foundEnt:Team() == self:Team())) then
					foundEnt = self:DoubleCheckUseNPC(foundEnt, center, forward)
				end
				--if (dist < nearestDist) then -- Not identical to CBasePlayer
					--nearestDist = dist
					nearestEnt = foundEnt
				--end
				if (idx == 1) then return foundEnt end				
			end
		end		
	end
	
	-- check ground entity first
	-- if you've got a useable ground entity, then shrink the cone of this search to 45 degrees
	-- otherwise, search out in a 90 degree cone (hemisphere)
	if (self:GetGroundEntity():IsValid() && self:IsUseableEntity(self:GetGroundEntity(), 256)) then
		nearestEnt = self:GetGroundEntity()
	end
	if (nearestEnt) then
		local point = self:NearestPoint(center)
		nearestDist = util.DistanceToLine(point, center, forward)
	end
	
	local search = ents.FindInSphere(center, PLAYER_USE_RADIUS)
	for k,v in ipairs(search) do
		if (v) && (v:IsValid()) && (self:IsUseableEntity(v, 512)) then
			local point = v:NearestPoint(center)
			local dir = (point - center):GetNormalized()
			local dot = dir:Dot(forward)
			if (dot >= 0.8) then
				local dist = util.DistanceToLine(point, center, forward)
				if (dist < nearestDist) then
					trace.endpos = point
					util.TraceLine(trace)
					if ((trace.output.Fraction == 1.0) || (trace.output.Entity == v)) then
						nearestEnt = v
						nearestDist = dist
					end
				end
			end
		end
	end
	
	if (!nearestEnt) then
		trace.endpos = center + forward * PLAYER_USE_RADIUS
		trace.mask = MASK_OPAQUE_AND_NPCS
		util.TraceLine(trace)
		if (trace.output.Entity
			&& trace.output.Entity:IsValid()
			&& self:IsUseableEntity(trace.output.Entity, 0)
			&& trace.output.Entity:IsNPC()
			&& (trace.output.Entity:Team() == self:Team())) then
			nearestEnt = trace.output.Entity
		end
	end
	if (foundEnt:IsNPC() && (foundEnt:Team() == self:Team())) then
		foundEnt = self:DoubleCheckUseNPC(foundEnt, center, forward)
	end
	
	return nearestEnt
end

-- Double Check NPC
-- Perhaps a poorly-named function. This function traces against the supplied
-- NPC's hitboxes (instead of hull). If the trace hits a different NPC, the 
-- new NPC is selected. Otherwise, the supplied NPC is determined to be the 
-- one the citizen wants. This function allows the selection of a citizen over
-- another citizen's shoulder, which is impossible without tracing against
-- hitboxes instead of the hull (sjb)
function meta:DoubleCheckUseNPC(npc, src, dir)
	local trace = {
		start = src,
		endpos = src + dir * 1024,
		mask = MASK_SHOT,
		result = {}
	}
	util.TraceLine(trace)
	if ((trace.result.Entity != nil) && (trace.result.Entity:IsValid()) && (trace.result.Entity:IsNPC()) && (trace.result.Entity != npc)) then
		-- Player is selecting a different NPC through some negative space
		-- in the first NPC's hitboxes (between legs, over shoulder, etc).
		return trace.result.Entity
	end
	return npc
end
