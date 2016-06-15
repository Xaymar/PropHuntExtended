-- Entity information
ENT.Type = "anim"
ENT.Base = "base_anim"

-- Initialize
function ENT:Initialize()
	self:SetModel("models/Kleiner.mdl")
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetSolid(SOLID_OBB)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(255,255,255,255))
end

-- Update position
function ENT:Think()
	local hullOBBMin = self:OBBMins()
	local hullOBBMax = self:OBBMaxs()
	local hullOBB = hullOBBMax - hullOBBMin
	local pos = -Vector(0, 0, hullOBBMin.z)
	
	self:SetPos(self.Owner:GetPos() + pos)
	self:SetVelocity(self:GetOwner():GetVelocity())
	
	-- Angles
	if (self.Owner:GetNWBool("PropRotation")) then
		self:SetAngles(self.Owner:EyeAngles())
	end
end

