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

local PANEL = vgui.Create("DFrame")
PANEL:SetSize(400, 300)
PANEL:SetTitle("Select a Team")
PANEL:SetDraggable(true)
PANEL:SetVisible(false)
PANEL:SetDraggable(true)
PANEL:SetSizable(true)
PANEL:ShowCloseButton(true)
PANEL:SetDeleteOnClose(false)




TeamSelectionUI = {}
TeamSelectionUI.Frame = vgui.Create("DFrame")
TeamSelectionUI.Frame:SetPos(0, 0)
TeamSelectionUI.Frame:SetSize(400, 320)
TeamSelectionUI.Frame:Center()
TeamSelectionUI.Frame:SetTitle("Select a Team")
TeamSelectionUI.Frame:SetVisible(false)
TeamSelectionUI.Frame:SetDraggable(true)
TeamSelectionUI.Frame:SetSizable(false)
TeamSelectionUI.Frame:ShowCloseButton(true)
TeamSelectionUI.Frame:SetDeleteOnClose(false)
function TeamSelectionUI.Frame:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 225))
end

function TeamSelectionUI:Show()
	self.Frame:MakePopup()
	TeamSelectionUI.Frame:SetVisible(true)
end

function TeamSelectionUI:Hide()
	TeamSelectionUI.Frame:Close()
	TeamSelectionUI.Frame:SetVisible(false)
end

TeamSelectionUI.SelectSeeker = vgui.Create("DButton", TeamSelectionUI.Frame)
TeamSelectionUI.SelectSeeker:SetPos(0, 20)
TeamSelectionUI.SelectSeeker:SetSize(200, 200)
TeamSelectionUI.SelectSeeker:SetText("Seeker")
TeamSelectionUI.SelectSeeker.DoClick = function()
	TeamSelectionUI:Hide()
	LocalPlayer():ConCommand("changeteam " .. tostring(GAMEMODE.Teams.Seekers))
end

TeamSelectionUI.SelectHider = vgui.Create("DButton", TeamSelectionUI.Frame)
TeamSelectionUI.SelectHider:SetPos(200, 20)
TeamSelectionUI.SelectHider:SetSize(200, 200)
TeamSelectionUI.SelectHider:SetText("Hiders")
TeamSelectionUI.SelectHider.DoClick = function()
	TeamSelectionUI:Hide()
	LocalPlayer():ConCommand("changeteam " .. tostring(GAMEMODE.Teams.Hiders))
end

TeamSelectionUI.Spectate = vgui.Create("DButton", TeamSelectionUI.Frame)
TeamSelectionUI.Spectate:SetPos(0, 220)
TeamSelectionUI.Spectate:SetSize(400, 100)
TeamSelectionUI.Spectate:SetText("Spectate")
TeamSelectionUI.Spectate.DoClick = function()
	TeamSelectionUI:Hide()
	LocalPlayer():ConCommand("changeteam " .. tostring(GAMEMODE.Teams.Spectators))
end