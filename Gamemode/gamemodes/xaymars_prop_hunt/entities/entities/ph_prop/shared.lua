-- Entity information
ENT.Type = "anim"
ENT.Base = "base_anim"

-- Initialize
function ENT:Initialize()
	self:SetModel("models/player/Kleiner.mdl")
	self:DrawShadow(true);
	
	-- Physical properties
	self:SetSolid(SOLID_OBB)
	
	-- Initialize Networked Variables
	self:SetApplyNewAngles(false)
	self:SetHealth(100)
	if SERVER then self:SetMaxHealth(100) end
	if CLIENT then self.Owner.ph_prop = self.Entity end
end

-- Set up shared Data.
function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "ApplyNewAngles" )
end

-- Update position
function ENT:Think()
	-- Calculate hull size.
	local hullOBBMin = self:OBBMins()
	local hullOBBMax = self:OBBMaxs()
	local hullOBB = hullOBBMax - hullOBBMin
	
	-- Shared update
	local pos = -Vector(0, 0, hullOBBMin.z)
	self:SetPos(self.Owner:GetPos() + pos)
	self:SetVelocity(self:GetOwner():GetVelocity())
	
	-- Server only updates
	if SERVER then
		-- Prevent confusion by updating angles only on the server.
		if self:GetApplyNewAngles() then
			self:SetAngles(Angle(0, self:GetOwner():GetAngles().yaw, 0))
		end
		
		self:NextThink( CurTime() )
	end
end
