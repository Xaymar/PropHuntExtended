-- Finds the player meta table or terminates
local meta = FindMetaTable("Player")
if !meta then return end

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
