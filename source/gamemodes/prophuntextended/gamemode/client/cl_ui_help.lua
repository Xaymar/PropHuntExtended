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

local UI = {}

function UI:Init()
	-- Initialize
	self:SetVisible(false)
	self:SetSize(1280, 720)
	self:SetScreenLock(true)
	self:SetTitle("Help & Settings")
	self:SetDraggable(true)
	self:SetSizable(true)
	self:ShowCloseButton(true)
	self:SetDeleteOnClose(false)

	self.scale = 1.0

	self.psh = vgui.Create("DPropertySheet", self)
	self.psh:Dock(FILL)
	self.psh:AddSheet("Help", vgui.Create("PHE_HelpUI_Help", self.psh))
	self.psh:AddSheet("Settings", vgui.Create("PHE_HelpUI_Settings", self.psh))
	
	-- Listen to DPI Updates
	UIManager:Listen("UpdateDPI", self, function(dpi) self:UpdateDPI(dpi) end)
	self:UpdateDPI(UIManager:GetDPIScale())
end

function UI:OnRemove()
	UIManager:Silence("UpdateDPI", self)

	self.psh:Remove()
end

function UI:Show()
	self:Center()
	self:SetVisible(true)
	self:SetFocusTopLevel(true)
	self:MakePopup()
end

function UI:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,240))
end

function UI:UpdateDPI(dpi)
	local mult = dpi / self.scale
	self.scale = dpi

	local x, y = self:GetPos()
	local w, h = self:GetSize()
	local nw, nh = w * mult, h * mult
	local ox, oy = (nw - w) / 2, (nh - h) / 2
	self:SetSize(w * mult, h * mult)
	self:SetPos(x - ox, y - oy)
end

derma.DefineControl("PHE_HelpUI", "Show Help UI Element", UI, "DFrameDPI");
