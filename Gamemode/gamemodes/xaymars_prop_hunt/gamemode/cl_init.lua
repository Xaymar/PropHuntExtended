-- Include the needed files
include("sh_init.lua")
--include("cl_hints.lua")

-- Draw round timeleft and hunter release timeleft
function HUDPaint()
	if GetGlobalBool("InRound", false) then
		local blindlock_time_left = (GetConVar("HUNTER_BLINDLOCK_TIME"):GetInt() - (CurTime() - GetGlobalFloat("RoundStartTime", 0))) + 1
		
		if blindlock_time_left < 1 && blindlock_time_left > -6 then
			blindlock_time_left_msg = "Hunters have been released!"
		elseif blindlock_time_left > 0 then
			blindlock_time_left_msg = "Hunters will be unblinded and released in "..string.ToMinutesSeconds(blindlock_time_left)
		else
			blindlock_time_left_msg = nil
		end
		
		if LocalPlayer():Team() == TEAM_HUNTERS && blindlock_time_left > 1 then
			draw.RoundedBox(0, 0, 0, surface.ScreenWidth(), surface.ScreenHeight(), Color(20, 20, 20, 255))
		end
		
		if blindlock_time_left_msg then
			surface.SetFont("MyFont")
			local tw, th = surface.GetTextSize(blindlock_time_left_msg)
			
			draw.RoundedBox(8, 20, 20, tw + 20, 26, Color(0, 0, 0, 75))
			draw.DrawText(blindlock_time_left_msg, "MyFont", 31, 26, Color(255, 255, 0, 255), TEXT_ALIGN_LEFT)
		end
	end
end
hook.Add("HUDPaint", "PH_HUDPaint", HUDPaint)

-- Called immediately after starting the gamemode 
function Initialize()
	hullz = 80
	--surface.CreateFont("Arial", 14, 1200, true, false, "ph_arial")
	surface.CreateFont( "MyFont",
	{
		font	= "Arial",
		size	= 14,
		weight	= 1200,
		antialias = true,
		underline = false
	})
end
hook.Add("Initialize", "PH_Initialize", Initialize)


-- Resets the player hull
function ResetHull(um)
	if LocalPlayer() && LocalPlayer():IsValid() then
		LocalPlayer():ResetHull()
		LocalPlayer():SetViewOffset(Vector(0, 0, 64))
		LocalPlayer():SetViewOffsetDucked(Vector(0, 0, 28))
		hullz = 80
	end
end
usermessage.Hook("ResetHull", ResetHull)


-- Sets the local blind variable to be used in CalcView
function SetBlind(um)
	blind = um:ReadBool()
end
usermessage.Hook("SetBlind", SetBlind)


function GM:ShouldDrawLocalPlayer()
	return false
end

function GM:CalcView( ply, pos, ang, fov )
	local view = {
		origin = pos,
		angles = ang,
		fov = fov
	}
	
	if ply:Team() == TEAM_PROPS && ply:Alive() then
		-- Fix lua errors by doing this instead.
		if LocalPlayer().ThirdPersonDistance == nil then
			LocalPlayer().ThirdPersonDistance = 100
		end
		
		-- Slowly return ThirdPersonDistance to 100
		local traceDist = math.Clamp(LocalPlayer().ThirdPersonDistance * 0.98 + 100 * 0.02, 0, 100)
		
		-- Trace a line to find the correct position for the camera.
		local tracePos = pos
		local trace = {
			-- Start somewhat outside the prop.
			start = tracePos - (ang:Forward() * 5),
			endpos = tracePos - (ang:Forward() * (traceDist + 10)),
			filter = function(ent)
				if (ent == LocalPlayer() || ent == LocalPlayer().ph_prop || ent == LocalPlayer().ThirdPersonFilter || ent == ThirdPersonFilter) then
					return false
				elseif (ent:GetClass() == "ph_prop" || ent:GetClass() == "worldspawn") then
					return false
				end
				return true
			end
		}
		local traceResult = util.TraceLine(trace);
		
		-- Readjust trace hit distance to force camera outside of the hit position.
		if traceResult.Hit then
			traceDist = math.max(traceResult.HitPos:Distance(tracePos) - 10, 0)
		end
		LocalPlayer().ThirdPersonDistance = traceDist
		
		-- Correct view position
		view.origin = tracePos - (ang:Forward() * traceDist)
--[[	else
	 	local wep = ply:GetActiveWeapon() 
	 	if wep && wep != NULL then 
	 		local func = wep.GetViewModelPosition 
	 		if func then 
	 			view.vm_origin, view.vm_angles = func(wep, origin*1, angles*1) -- Note: *1 to copy the object so the child function can't edit it. 
	 		end
	 		 
	 		local func = wep.CalcView 
	 		if func then 
	 			view.origin, view.angles, view.fov = func(wep, pl, origin*1, angles*1, fov) -- Note: *1 to copy the object so the child function can't edit it. 
	 		end 
	 	end--]]
	end
	
	return view;
end

-- Render halos and player names.
function DrawPlayerNames(bDrawingDepth, bDrawingSkybox)
	for i,v in ipairs(player.GetAll()) do
		if v:Alive() && v != LocalPlayer() then
			local pos = v:GetPos() + v:GetViewOffset() + Vector(0, 0, 5)
			local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90 - LocalPlayer():EyeAngles().x)
			local healthPrc = v:Health() / v:GetMaxHealth()
			local healthCol = HSVToColor(120 * healthPrc, 1.0, 1.0)
			
			if v:Team() == TEAM_HUNTERS || LocalPlayer():Team() == TEAM_PROPS then
				cam.Start3D2D(pos, ang, 0.15)
					draw.DrawText(v:GetName(), "Trebuchet24", 0, -draw.GetFontHeight("Trebuchet24"), healthCol, TEXT_ALIGN_CENTER)
				cam.End3D2D()
			end
		end
	end
end
hook.Add("PostDrawTranslucentRenderables", "PH_DrawPlayerNames", DrawPlayerNames)

function DrawPlayerHalos(bDrawingDepth, bDrawingSkybox)
	for i,v in ipairs(player.GetAll()) do
		if v:Alive() then
			local pos = v:GetPos() + Vector(0, 0, 1) * (v:OBBMaxs().z - v:OBBMins().z + 5)
			local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90 - LocalPlayer():EyeAngles().x)
			local healthPrc = v:Health() / v:GetMaxHealth()
			local healthCol = HSVToColor(120 * healthPrc, 1.0, 1.0)
			
			if v:Team() == TEAM_HUNTERS || LocalPlayer():Team() == TEAM_PROPS then
				local ent = v
				if v.ph_prop && v.ph_prop:IsValid() then ent = v.ph_prop end
				
				halo.Add({ent}, healthCol, 2, 2, 1)
			end
		end
	end
end
--hook.Add("PostDrawEffects", "PH_DrawPlayerHalos", DrawPlayerHalos)

-- UMSG: Update player Hull and health.
function UMSGSetHull(um)
	local hullOBBMin = um:ReadVector()
	local hullOBBMax = um:ReadVector()
	local new_health = um:ReadShort()
	
	LocalPlayer():NewHull(hullOBBMin, hullOBBMax)
	LocalPlayer():SetHealth(new_health)
end
usermessage.Hook("SetHull", UMSGSetHull)
