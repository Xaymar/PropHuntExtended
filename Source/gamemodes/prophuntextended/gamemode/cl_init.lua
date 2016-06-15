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

-- ------------------------------------------------------------------------- --
--! Includes
-- ------------------------------------------------------------------------- --
include("sh_init.lua")

GM.UI = {}
include("client/cl_ui_help.lua")
include("client/cl_ui_teamselection.lua")

-- ------------------------------------------------------------------------- --
--! Code
-- ------------------------------------------------------------------------- --
function GM:Initialize()
	print("-------------------------------------------------------------------------")
	print("Prop Hunt CL: Initializing...")
	
	print("Prop Hunt CL: Initializing Gamemode Data...")
	self.Data = {}
	
	print("Prop Hunt CL: Creating Huge Ass Font...")
	surface.CreateFont("PHHugeAssFont", {font="Roboto Bold Condensed", extended=true, size=160, weight=800, antialias=true})
	
	print("Prop Hunt CL: Complete.")
	print("-------------------------------------------------------------------------")
end

function GM:Think() end

function GM:InitialPlayerSpawn()
	print("Prop Hunt CL: InitialPlayerSpawn")
	
	-- Delay execution until LocalPlayer() is valid.
	if (!LocalPlayer()) || (!IsValid(LocalPlayer())) then
		timer.Simple(.1, function() GAMEMODE:InitialPlayerSpawn() end)
		return
	end
	
	print("Prop Hunt CL: InitialPlayerSpawn Valid")
	
	player_manager.RunClass(LocalPlayer(), "InitialClientSpawn")
end

function GM:PlayerSpawn()
	print("Prop Hunt CL: PlayerSpawn")
	
	-- Delay execution until LocalPlayer() is valid.
	if (!LocalPlayer()) || (!IsValid(LocalPlayer())) then
		timer.Simple(.1, function() GAMEMODE:PlayerSpawn() end)
		return
	end
	
	print("Prop Hunt CL: PlayerSpawn Valid")
	
	if !(LocalPlayer().Data) then
		LocalPlayer().Data = {}
		LocalPlayer().Data.ThirdPerson = true
	end
	
	player_manager.RunClass(LocalPlayer(), "ClientSpawn")
end

function GM:PostDrawViewModel( vm, ply, weapon )
	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
	end
end

-- ------------------------------------------------------------------------- --
--! Player Manager Binding
-- ------------------------------------------------------------------------- --
function GM:HUDPaint() player_manager.RunClass(LocalPlayer(), "HUDPaint") end
function GM:CalcView(ply, pos, ang, fov, nearZ, farZ) return player_manager.RunClass(LocalPlayer(), "CalcView", {origin = pos, angles = ang, fov = fov, znear = nearZ, zfar = farZ}) end
function GM:GetHandsModel() return player_manager.RunClass(LocalPlayer(), "GetHandsModel") end

-- ------------------------------------------------------------------------- --
--! Gamemode Functionality
-- ------------------------------------------------------------------------- --
function GM:PlayerSetViewOffset(vo, voduck)
	-- Delay execution until LocalPlayer() is valid.
	if (!LocalPlayer()) || (!IsValid(LocalPlayer())) then
		if !(GAMEMODE.TempData) then GAMEMODE.TempData = {} end
		GAMEMODE.TempData.ViewOffset = vo
		GAMEMODE.TempData.ViewOffsetDuck = voduck
		
		timer.Simple(.1, function() GAMEMODE:PlayerSetViewOffset(GAMEMODE.TempData.ViewOffset, GAMEMODE.TempData.ViewOffsetDuck) end)
		return
	end
	
	LocalPlayer():SetViewOffset(vo)
	LocalPlayer():SetViewOffsetDucked(voduck)
	if LocalPlayer():Crouching() then
		LocalPlayer():SetCurrentViewOffset(voduck)
	else
		LocalPlayer():SetCurrentViewOffset(vo)
	end
end

function GM:PlayerSetHull(hullMin, hullMax)
	-- Delay execution until LocalPlayer() is valid.
	if (!LocalPlayer()) || (!IsValid(LocalPlayer())) then
		if !(GAMEMODE.TempData) then GAMEMODE.TempData = {} end
		GAMEMODE.TempData.HullMin = hullMin
		GAMEMODE.TempData.HullMax = hullMax

		timer.Simple(.1, function() GAMEMODE:PlayerSetHull(GAMEMODE.TempData.HullMin, GAMEMODE.TempData.HullMax) end)
		return
	end
	
	if (hullMin == hullMax) && (hullMin == nil) then
		LocalPlayer():ResetHull()
	else
		LocalPlayer():SetHull(hullMin, hullMax)
		LocalPlayer():SetHullDuck(hullMin, hullMax)
	end
end

-- ------------------------------------------------------------------------- --
--! Commands
-- ------------------------------------------------------------------------- --
function GM:OnContextMenuOpen()
end

function GM:OnContextMenuClose()
	print("Prop Hunt CL: Toggled View Mode")
	LocalPlayer().Data.ThirdPerson = !LocalPlayer().Data.ThirdPerson
end

function GM:OnSpawnMenuOpen()
	print("Prop Hunt CL: Enabling Prop Rotation")
	LocalPlayer():SetNWBool("PropRotation", true)
	net.Start("PlayerEnablePropRotation");net.SendToServer()
end

function GM:OnSpawnMenuClose()
	print("Prop Hunt CL: Disabling Prop Rotation")
	LocalPlayer():SetNWBool("PropRotation", false)
	net.Start("PlayerDisablePropRotation");net.SendToServer()
end

function GM:ShowHelpUI()
	self.UI.Help:Show()
end
concommand.Add("ph_show_help", function() GAMEMODE:ShowHelpUI() end)

function GM:ShowTeamSelection()
	TeamSelectionUI:Show()
end
concommand.Add("ph_select_team", function() GAMEMODE:ShowTeamSelection() end)

-- ------------------------------------------------------------------------- --
--! Network Messages
-- ------------------------------------------------------------------------- --
net.Receive("PlayerManagerInitialClientSpawn", function(len, pl) GAMEMODE:InitialPlayerSpawn() end)
net.Receive("PlayerManagerClientSpawn", function(len, pl) GAMEMODE:PlayerSpawn() end)
net.Receive( "PlayerSetHull", function(len, pl)
	local hullMin, hullMax = net.ReadVector(), net.ReadVector();
	GAMEMODE:PlayerSetHull(hullMin, hullMax)
end)
net.Receive( "PlayerResetHull", function(len, pl) GAMEMODE:PlayerSetHull(nil, nil) end)
net.Receive( "PlayerViewOffset", function(len, pl)
	local vo, voduck = net.ReadVector(), net.ReadVector()
	GAMEMODE:PlayerSetViewOffset(vo, voduck)
end)

-- ------------------------------------------------------------------------- --
--! Old Code
-- ------------------------------------------------------------------------- --
--[[
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
]]