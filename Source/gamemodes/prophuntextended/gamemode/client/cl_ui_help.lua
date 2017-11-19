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
PANEL:SetSize(640, 480)
PANEL:SetTitle("Help")
PANEL:SetDraggable(true)
PANEL:SetVisible(false)
PANEL:SetDraggable(true)
PANEL:SetSizable(true)
PANEL:ShowCloseButton(true)
PANEL:SetDeleteOnClose(false)

function PANEL:Show()
	--self:SetSize(ScrW(), ScrH())
	self:Center()
	self:SetVisible(true)
	self:SetFocusTopLevel(true)
	self:SlideDown(.5)
	self:MakePopup()
end
function PANEL:Hide()
	self:Close()
	self:SetVisible(false)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,240))
end

-- Sheets
local Element = vgui.Create("DPropertySheet", PANEL)
function Element:PAINT(w,h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,240))
end
Element:Dock(FILL)
PANEL.Sheets = Element
PANEL.Sheet = {}

-- Basic Info
local Element = vgui.Create("DPanel", PANEL.Sheets)
function Element:Paint(w,h) end
PANEL.Sheets:AddSheet("The Gamemode", Element)
PANEL.Sheet.TheGamemode = Element

local Element = vgui.Create("DLabel", PANEL.Sheet.TheGamemode)
Element:Dock(TOP)
Element:SetMultiline(true)
Element:SetText([[
	Prop Hunt Extended is a Gamemode based on the original Prop Hunt Gamemode. It changes many gameplay elements and features, adding the ability to easily integrate Taunt Packs, Configure Game parameters, rotate your prop and much more.
]])



-- Settings
PANEL.SettingsSheet = vgui.Create("DPanel", PANEL.Sheets)
PANEL.Sheets:AddSheet("Settings", PANEL.SettingsSheet)



GM.UI.Help = PANEL