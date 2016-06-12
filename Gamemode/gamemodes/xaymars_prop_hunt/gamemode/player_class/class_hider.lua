-- Create new class
DEFINE_BASECLASS( "player_default" )
local CLASS = {}

-- Some settings for the class
CLASS.DisplayName			= "Hider"
CLASS.WalkSpeed 			= 250
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 250
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false

-- Called by spawn and sets loadout
function CLASS:Loadout(pl)
	-- Props don't get anything
end

-- Called when player spawns with this class
function CLASS:OnSpawn(pl)
	pl:SetColor( Color(255, 255, 255, 0))

	pl.ph_prop = ents.Create("ph_prop")
	pl.ph_prop:SetPos(pl:GetPos())
	pl.ph_prop:SetAngles(pl:GetAngles())
	pl.ph_prop:Spawn()
	pl.ph_prop:SetOwner(pl)
	
	pl:SetJumpPower(200);
	
	-- Update Hull and Health
	pl:SetHealth(100)
	pl:SetMaxHealth(100)
	pl.ph_prop:SetHealth(100)
	pl.ph_prop:SetMaxHealth(100) 
	
	local hullMin = Vector(-20, -20,  -10)
	local hullMax = Vector( 20,  20,  60)
	pl:NewHull(hullMin, hullMax)
	umsg.Start("SetHull", pl)
		umsg.Vector(hullMin)
		umsg.Vector(hullMax)
		umsg.Short(100)
	umsg.End()
end

-- Called when a player dies with this class
function CLASS:OnDeath(pl, attacker, dmginfo)
	pl:RemoveProp()
end

-- Register
player_manager.RegisterClass("Hider", CLASS)
