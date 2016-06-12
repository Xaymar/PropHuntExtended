--Thanks to Blasteh for gmod update the fix and nifnat for spectate fix!

-- Send required files to client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
 
-- Include needed files
include("shared.lua")
 
-- Called when we take damge
function ENT:OnTakeDamage(dmg)
	local pl = self.Owner
	local attacker = dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()

	-- Health
	if pl && pl:IsValid() && pl:Alive() && pl:IsPlayer() && attacker:IsPlayer() && dmg:GetDamage() > 0 then
		pl:SetHealth(pl:Health() - dmg:GetDamage())
	   
		if pl:Health() <= 0 then
			-- Figure out real attacker.
			if inflictor && inflictor == attacker && inflictor:IsPlayer() then
				inflictor = inflictor:GetActiveWeapon()
				if !inflictor || inflictor == NULL then inflictor = attacker end
			end
			
			-- Kill player and remove the prop
			pl:KillSilent()
			pl:RemoveProp() -- Needs to be executed before net.Broadcast
			
			-- Send kill message.
			net.Start( "PlayerKilledByPlayer" )
			net.WriteEntity( pl )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )
			net.Broadcast()
			
			-- Broadcast same message to all players in console.
			MsgAll(attacker:Name() .. " found and killed " .. pl:Name() .. "\n")
			
			-- Increment frags and deaths.
			attacker:AddFrags(1)
			pl:AddDeaths(1)
			
			-- Update attacker health
			attacker:SetHealth(math.Clamp(attacker:Health() + GetConVar("HUNTER_KILL_BONUS"):GetInt(), 1, 100))
	   end
	end
end
