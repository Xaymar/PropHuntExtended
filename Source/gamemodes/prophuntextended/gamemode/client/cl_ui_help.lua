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
PANEL:SetTitle("Help")
PANEL:SetDraggable(true)
PANEL:SetVisible(false)
PANEL:SetDraggable(true)
PANEL:SetSizable(true)
PANEL:ShowCloseButton(true)
PANEL:SetDeleteOnClose(false)

function PANEL:Init()
	DFrame.Init(self)
	
	-- Sheets
	self.Sheets = vgui.Create("DPropertySheet", self)
	self.Sheets:Dock(FILL)
	
	-- Basic Info
	self.BasicInfoSheet = vgui.Create("DPanel", self.Sheets)
	function self.BasicInfoSheet:Paint(w, h)
		draw.RoundedBox(4, 0, 0, 100, 100, Color(0,128,255))
	end
	self.Sheets:AddSheet("The Gamemode", self.BasicInfoSheet)
	
	
end

function PANEL:Show()
	self:SetSize(ScrW(), ScrH())
	self:Center()
	self:SetVisible(true)
	self:SetFocusTopLevel(true)
	self:SlideDown(.5)
	self:MakePopup()
end

GAMEMODE.UI.Help = PANEL