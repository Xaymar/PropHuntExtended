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

local DPlayerEntry = {}
function DPlayerEntry:Init()
	self.Data = {}
	self.Data.Margin = {
		left = 0,
		top = 0,
		right = 0,
		bottom = 0
	}
	self.Data.LastUpdate = CurTime() - 10
	self.Data.Player = nil
	
	self:SetMinimumSize(100, 40)
	
	self.Container = vgui.Create("DPanel", self)
	self.Container:SetBackgroundColor(Color(127,127,127,255))
	self.Container:SetPaintBackground(true)
	self.Container:Dock(FILL)
	self.Container:DockMargin(0, 0, 0, 0)
	
	self.Avatar = vgui.Create("AvatarImage", self.Container)
	self.Avatar:Dock(LEFT)
	
	self.Name = vgui.Create("DLabel", self.Container)
	self.Name:SetText("Unknown")
	self.Name:SetFont("Roboto24")
	self.Name:SetContentAlignment(4)
	self.Name:Dock(FILL)
	self.Name:DockMargin(10, 5, 10, 5)
	
	self.Deaths = vgui.Create("DLabel", self.Container)
	self.Deaths:SetSize(80, 30)
	self.Deaths:SetText("N/A")
	self.Deaths:SetFont("Roboto24")
	self.Deaths:SetContentAlignment(6)
	self.Deaths:Dock(RIGHT)
	self.Deaths:DockMargin(10, 5, 10, 5)
	
	self.Kills = vgui.Create("DLabel", self.Container)
	self.Kills:SetSize(80, 30)
	self.Kills:SetText("N/A")
	self.Kills:SetFont("Roboto24")
	self.Kills:SetContentAlignment(6)
	self.Kills:Dock(RIGHT)
	self.Kills:DockMargin(10, 5, 10, 5)
end

function DPlayerEntry:PerformLayout(w, h)
	self:SetMinimumSize(
		100 + self.Data.Margin.left + self.Data.Margin.right,
		40 + self.Data.Margin.top + self.Data.Margin.bottom
	)
	
	-- Docked Content
	local containerX, containerY, containerW, containerH = self.Container:GetBounds()
	self.Avatar:SetSize(containerH, containerH)
	self.Kills:SetSize(80, containerH - 10)
	self.Deaths:SetSize(80, containerH - 10)
end

function DPlayerEntry:Think()
	if (CurTime() - self.Data.LastUpdate) < 0.25 then return end
	if IsValid(self.Data.Player) then
		self.Avatar:SetPlayer(self.Data.Player, 184)
		self.Name:SetText(self.Data.Player:GetName())
		self.Kills:SetText(self.Data.Player:Frags())
		self.Deaths:SetText(self.Data.Player:Deaths())
	end
end

function DPlayerEntry:SetMargin(left, top, right, bottom)
	local uleft = left or 0
	local utop = top or uleft
	local uright = right or uleft
	local ubottom = bottom or utop
	self.Container:DockMargin(uleft, utop, uright, ubottom)
	self:InvalidateLayout()
end

function DPlayerEntry:SetBackgroundColor(clr)
	self.Container:SetBackgroundColor(clr)
end

function DPlayerEntry:SetForegroundColor(clr)
	self.Name:SetColor(clr)
	self.Kills:SetColor(clr)
	self.Deaths:SetColor(clr)
end

function DPlayerEntry:SetPlayer(ply)
	self.Data.Player = ply
end

function DPlayerEntry:ShowFlags(kills, deaths)
	self.Kills:SetVisible(kills)
	self.Deaths:SetVisible(deaths)
	self.Container:InvalidateLayout()
end

vgui.Register("DPlayerEntry", DPlayerEntry, "Panel")

local DPlayerList = {}
function DPlayerList:Init()	
	self.Data = {}
	self.Data.Time = CurTime() - 1
	self.Data.Team = nil
	self.Data.Players = {}
	self.Data.ShowKills = true
	self.Data.ShowDeaths = true

	self.Container = vgui.Create("DPanel", self)
	self.Container:SetPaintBackground(true)
	self.Container:SetBackgroundColor(Color(51, 51, 51, 102))
	self.Container:Dock(FILL)
	
	self.Title = vgui.Create("DPanel", self.Container)
	self.Title:SetSize(1, 40)
	self.Title:Dock(TOP)
	self.Title:DockMargin(0, 0, 0, 5)
	
	self.Title.Name = vgui.Create("DLabel", self.Title)
	self.Title.Name:SetText("Unknown")
	self.Title.Name:SetFont("Roboto32Bold")
	self.Title.Name:SetContentAlignment(5)
	self.Title.Name:Dock(FILL)
	self.Title.Name:DockMargin(10, 5, 10, 5)
	
	self.Title.Deaths = vgui.Create("DLabel", self.Title)
	self.Title.Deaths:SetText("Deaths")
	self.Title.Deaths:SetFont("Roboto24")
	self.Title.Deaths:SetContentAlignment(6)
	self.Title.Deaths:SetSize(80, 40)
	self.Title.Deaths:Dock(RIGHT)
	self.Title.Deaths:DockMargin(10, 5, 10, 5)
	
	self.Title.Kills = vgui.Create("DLabel", self.Title)
	self.Title.Kills:SetText("Kills")
	self.Title.Kills:SetFont("Roboto24")
	self.Title.Kills:SetContentAlignment(6)
	self.Title.Kills:SetSize(80, 40)
	self.Title.Kills:Dock(RIGHT)
	self.Title.Kills:DockMargin(10, 5, 10, 5)

	self.Scroll = vgui.Create("DScrollPanel", self.Container)
	self.Scroll:Dock(FILL)
	self.Layout = vgui.Create("DListLayout", self.Scroll)
	self.Layout:Dock(FILL)
end

function DPlayerList:PerformLayout(w, h)
	--self.Container:SetSize(w, h)
end

function DPlayerList:Think()
	if (self.Data.Team == -1) then return end
	if ((CurTime() - self.Data.Time) < 0.1) then return end
	
	self.Data.Time = CurTime()
	
	-- Update Team Information
	if (self.Data.Team != nil) then
		self.Title:SetBackgroundColor(team.GetColor(self.Data.Team))
		
		-- Name
		self.Title.Name:SetText(team.GetName(self.Data.Team))
		
		-- Text Color
		local hue,sat,val = ColorToHSV(team.GetColor(self.Data.Team))
		sat = sat * 0.1
		val = val * 0.1
		local col = HSVToColor(hue,sat,val)
		self.Title.Name:SetColor(col)
		self.Title.Kills:SetColor(col)
		self.Title.Deaths:SetColor(col)
	end
	
	-- Update living players
	local pls = team.GetPlayers(self.Data.Team)
	for i,v in ipairs(pls) do
		local alive = player_manager.RunClass(v, "Alive")
		local gui = self.Data.Players[v]
		if (gui == nil) then
			gui = vgui.Create("DPlayerEntry")
			gui:SetPlayer(v)
			gui:SetMargin(0, 0, 0, 5)
			gui:Stop()
			gui:SetAlpha(0)
			gui:AlphaTo(255, 1)
			self.Data.Players[v] = gui
			self.Layout:Add(gui)
		end
		if (alive) then
			local hue,sat,val = ColorToHSV(team.GetColor(self.Data.Team))
			local sat2,val2 = sat * 0.8, val * 0.8
			gui:SetBackgroundColor(HSVToColor(hue, sat2, val2))
			local sat3,val3 = sat * 0.1, val
			gui:SetForegroundColor(HSVToColor(hue, sat3, val3))
		else
			local hue,sat,val = ColorToHSV(team.GetColor(self.Data.Team))
			local sat2,val2 = sat * 0.8, val * 0.1
			gui:SetBackgroundColor(HSVToColor(hue, sat2, val2))
			local sat3,val3 = sat * 0.1, val
			gui:SetForegroundColor(HSVToColor(hue, sat3, val3))
		end
		gui:ShowFlags(self.Data.ShowKills, self.Data.ShowDeaths)
	end
	
	-- Find dead players
	for ply,gui in pairs(self.Data.Players) do
		if (!table.HasValue(pls, ply)) then
			self.Data.Players[ply] = nil
			gui:Stop()
			gui:AlphaTo(0, 1)
			gui:SetTerm(1)
		end
	end
	
	self.Layout:InvalidateLayout()
	self.Scroll:InvalidateLayout()
end

function DPlayerList:SetTeam(team)
	self.Data.Team = team
end

function DPlayerList:ShowFlags(kills, deaths)
	self.Data.ShowKills = kills
	self.Data.ShowDeaths = deaths
	self.Title.Kills:SetVisible(self.Data.ShowKills)
	self.Title.Deaths:SetVisible(self.Data.ShowDeaths)	
	self.Title:InvalidateLayout()
end

vgui.Register("DPlayerList", DPlayerList, "Panel")

local DScoreBoard = {}
function DScoreBoard:Init()	
	self.Container = vgui.Create("DPanel", self)
	self.Container:SetPaintBackground(true)
	self.Container:SetBackgroundColor(Color(0, 0, 0, 240))
	self.Container:Dock(FILL)
	self.Container:DockMargin(0, 35, 0, 0)
	
	self.Logo = vgui.Create("DImage", self)
	self.Logo:SetImage("prophuntextended/scoreboard_logo.png")
	self.Logo:SetKeepAspect(true)
	self.Logo:SetSize(580, 70)
	self.Logo:SetPos(10, 0)
	
	self.Frame = vgui.Create("DPanel", self.Container)
	self.Frame:SetPaintBackground(false)
	self.Frame:Dock(FILL)
	self.Frame:DockMargin(5, 40, 5, 5)
	
	self.Teams = {}
	self.Teams.Seekers = vgui.Create("DPlayerList", self.Frame)
	self.Teams.Seekers:SetTeam(GAMEMODE.Teams.Seekers)
	self.Teams.Seekers:Dock(LEFT)
	self.Teams.Seekers:DockMargin(5, 5, 5, 5)
	
	self.Teams.Hiders = vgui.Create("DPlayerList", self.Frame)
	self.Teams.Hiders:SetTeam(GAMEMODE.Teams.Hiders)
	self.Teams.Hiders:Dock(RIGHT)
	self.Teams.Hiders:DockMargin(5, 5, 5, 5)
	
	self.Teams.Spectators = vgui.Create("DPlayerList", self.Container)
	self.Teams.Spectators:SetSize(100, 100)
	self.Teams.Spectators:SetTeam(GAMEMODE.Teams.Spectators)
	self.Teams.Spectators:ShowFlags(false, false)
	self.Teams.Spectators:Dock(BOTTOM)
	self.Teams.Spectators:DockMargin(10, 0, 10, 10)
	
	self:SetVisible(false)
	self:SetAlpha(0)
end

function DScoreBoard:PerformLayout(w, h)
	local frameW, frameH = self.Frame:GetSize()
	local contW, contH = self.Container:GetSize()
	
	-- Update Team Lists
	self.Teams.Seekers:SetSize(frameW / 2 - 10, 0)
	self.Teams.Hiders:SetSize(frameW / 2 - 10, 0)
	self.Teams.Spectators:SetSize(100, contH / 5)
	
	self.Frame:InvalidateLayout()
	self.Container:InvalidateLayout()
end

function DScoreBoard:Show()
	-- Size and Position
	local w, h = ScrW() / 2, ScrH() / 4 * 3
	if (w < 600) then w = 600 end
	if (h < 400) then h = 400 end
	self:SetSize(w, h)
	self:Center()
	
	-- Visibility
	self:Stop()
	self:AlphaTo(255, 0.1)
	self:SetVisible(true)
	
	-- Focus
	self:SetPopupStayAtBack(true)
	self:SetFocusTopLevel(true)
	self:RequestFocus()
end

function DScoreBoard:Hide()
	-- Visibility
	self:Stop()
	self:AlphaTo(0, 0.1, 0, function(animData, pnl)
		pnl:SetVisible(false)
	end)
end
vgui.Register("DScoreBoard", DScoreBoard, "EditablePanel")
