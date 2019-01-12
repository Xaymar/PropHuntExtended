--[[
	The MIT License (MIT)
	
	Copyright (c) 2015-2018 Xaymar

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

local DHUDGameStateDisplay = {}

function DHUDGameStateDisplay:Init()
	self.time = CurTime() - 0.5

	self.colors = {}
	self.colors.background = Color(0, 0, 0, 204)
	self.colors.title = Color(204, 204, 204, 255)
	self.colors.content = Color(255, 255, 255, 255)
	self.colors.team = team.GetColor(self.team)

	self.text = {}
	self.text.title = "Initializing..."
	self.text.content = "Initializing..."

	self.round = {}
	self.round.num = GAMEMODE:GetRound()
	self.round.state = GAMEMODE:GetRoundState()
	self.round.time = GAMEMODE:GetRoundTime()

	self.team = GAMEMODE.Teams.Spectators

	-- Set up VGUI
	self.sizes = {}
	self.sizes.area = Vector(420, 48)
	self.sizes.smallFont = 18
	self.sizes.largeFont = 24
	self.sizes.scaledFont = 4

	self.ui = {}
	self.ui.container = vgui.Create("Panel", self)

	self.ui.teamBar = vgui.Create("DShape", self.ui.container)
	self.ui.teamBar:SetType("Rect")
	self.ui.teamBar:SetSize(0, 5)
	self.ui.teamBar:Dock(TOP)
	
	self.ui.timeContainer = vgui.Create("Panel", self.ui.container)
	self.ui.timeContainer:Dock(LEFT)
	self.ui.timeTitle = vgui.Create("DLabel", self.ui.timeContainer)
	self.ui.timeTitle:SetText("N/A")
	self.ui.timeTitle:SetFont("Default")
	self.ui.timeTitle:SetContentAlignment(2)
	self.ui.timeTitle:Dock(TOP)
	self.ui.timeContent = vgui.Create("DLabel", self.ui.timeContainer)
	self.ui.timeContent:SetText("N/A")
	self.ui.timeContent:SetFont("Default")
	self.ui.timeContent:SetContentAlignment(8)
	self.ui.timeContent:Dock(FILL)

	self.ui.mainContainer = vgui.Create("Panel", self.ui.container)
	self.ui.mainContainer:Dock(FILL)
	self.ui.mainTitle = vgui.Create("DLabel", self.ui.mainContainer)
	self.ui.mainTitle:SetText("N/A")
	self.ui.mainTitle:SetFont("Default")
	self.ui.mainTitle:SetContentAlignment(2)
	self.ui.mainTitle:Dock(TOP)
	self.ui.mainContent = vgui.Create("DLabel", self.ui.mainContainer)
	self.ui.mainContent:SetText("N/A")
	self.ui.mainContent:SetFont("Default")
	self.ui.mainContent:SetContentAlignment(8)
	self.ui.mainContent:Dock(FILL)

	self.ui.roundContainer = vgui.Create("Panel", self.ui.container)
	self.ui.roundContainer:Dock(RIGHT)
	self.ui.roundTitle = vgui.Create("DLabel", self.ui.roundContainer)
	self.ui.roundTitle:SetText("N/A")
	self.ui.roundTitle:SetFont("Default")
	self.ui.roundTitle:SetContentAlignment(2)
	self.ui.roundTitle:Dock(TOP)
	self.ui.roundContent = vgui.Create("DLabel", self.ui.roundContainer)
	self.ui.roundContent:SetText("N/A")
	self.ui.roundContent:SetFont("Default")
	self.ui.roundContent:SetContentAlignment(8)
	self.ui.roundContent:Dock(FILL)
	
	self.ui.timeContent:InvalidateParent()
	self.ui.timeTitle:InvalidateParent()	
	self.ui.mainContent:InvalidateParent()
	self.ui.mainTitle:InvalidateParent()
	self.ui.roundContent:InvalidateParent()
	self.ui.roundTitle:InvalidateParent()
	
	self.ui.mainContainer:InvalidateParent()
	self.ui.timeContainer:InvalidateParent()
	self.ui.roundContainer:InvalidateParent()

	self.ui.container:Dock(FILL)
	self.ui.container:InvalidateParent()
	
	GAMEMODE.UIManager:Listen("UpdateDPI", self, function(dpi) self:UpdateDPI(dpi) end)
	self:UpdateDPI(GAMEMODE.UIManager:GetDPIScale())
end

function DHUDGameStateDisplay:OnRemove()
	GAMEMODE.UIManager:Silence("UpdateDPI", self)
end

function DHUDGameStateDisplay:Think()
	-- Only update once every 0.1 seconds.
	if ((CurTime() - self.time) < 0.1) then
		return
	end
	self.time = CurTime()

	-- Update Information
	if (LocalPlayer() && LocalPlayer():IsPlayer()) then
		self.team = LocalPlayer():Team()
	end
	self.round.num = GAMEMODE:GetRound()
	self.round.state = GAMEMODE:GetRoundState()
	self.round.time = GAMEMODE:GetRoundTime()
	self.round.winner = GAMEMODE:GetRoundWinner()
	self.round.statetime = GAMEMODE:GetRoundStateTime()
	
	-- Update Colors
	self.colors.team = team.GetColor(self.team)

	-- Generate text
	if (self.round.state == GAMEMODE.States.PreMatch) then
		self.text.title = "Waiting for Players"
		self.text.content = tostring(team.NumPlayers(GAMEMODE.Teams.Seekers)) .. " " .. team.GetName(GAMEMODE.Teams.Seekers) .. ", " .. tostring(team.NumPlayers(GAMEMODE.Teams.Hiders)) .. " " .. team.GetName(GAMEMODE.Teams.Hiders)
	elseif (self.round.state == GAMEMODE.States.PreRound) then
		self.text.title = "Preparing Round"
		self.text.content = ""
	elseif (self.round.state == GAMEMODE.States.Hide) then
		self.text.title = "Hide! Seekers are unblinded in..."
		self.text.content = string.format("%d:%02d", math.floor(self.round.statetime / 60), math.ceil(self.round.statetime % 60))
	elseif (self.round.state == GAMEMODE.States.Seek) then
		self.text.title = "Seek! Hiders survive for..."
		self.text.content = string.format("%d:%02d", math.floor(self.round.statetime / 60), math.ceil(self.round.statetime % 60))
	elseif (self.round.state == GAMEMODE.States.PostRound) then
		self.text.title = "Round Result:"
		if (self.round.winner == GAMEMODE.Teams.Spectator) then
			self.text.content = "Draw"
		elseif (self.round.winner == GAMEMODE.Teams.Hiders) then
			self.text.content = "Hiders Win!"
		elseif (self.round.winner == GAMEMODE.Teams.Seekers) then
			self.text.content = "Seekers Win!"
		end
		--self.colors.content = team.GetColor(self.round.winner)
	elseif (self.round.state == GAMEMODE.States.PostMatch) then
		self.text.title = "Match Complete"
	end

	-- Update UI
	self.ui.teamBar:SetColor(self.colors.team)
	self.ui.mainTitle:SetText(self.text.title)
	self.ui.mainTitle:SetColor(self.colors.title)
	self.ui.mainTitle:SizeToContents()
	self.ui.mainContent:SetText(self.text.content)
	self.ui.mainContent:SetColor(self.colors.content)
	self.ui.timeTitle:SetText("Time")
	self.ui.timeTitle:SetColor(self.colors.title)
	self.ui.timeTitle:SizeToContents()
	self.ui.timeContent:SetText(string.format("%02d:%02d", math.floor(self.round.time / 60), math.ceil(self.round.time % 60)))
	self.ui.timeContent:SetColor(self.colors.content)
	self.ui.roundTitle:SetText("Round")
	self.ui.roundTitle:SetColor(self.colors.title)
	self.ui.roundTitle:SizeToContents()
	if (GAMEMODE.Config.Round:Limit() > 0) then
		self.ui.roundContent:SetText(string.format("%d of %d", self.round.num, GAMEMODE.Config.Round:Limit()))
	else
		self.ui.roundContent:SetText(string.format("%d of ∞", self.round.num))
	end
	self.ui.roundContent:SetColor(self.colors.content)
end

function DHUDGameStateDisplay:Paint()
	local w,h = self:GetSize()
	draw.RoundedBox(0, 0, 0, w, h, self.colors.background)
end

function DHUDGameStateDisplay:UpdateDPI(dpi)
	local titleFontSize = math.floor(self.sizes.smallFont*dpi)
	local contentFontSize = math.floor(titleFontSize+4)
	local titleFont = "Roboto"..titleFontSize
	local contentFont = "Roboto"..contentFontSize
	
	GAMEMODE.FontManager:Request(titleFont, {font="Roboto", extended=true, size=titleFontSize, weight=500, antialias=true})
	GAMEMODE.FontManager:Request(contentFont, {font="Roboto", extended=true, size=contentFontSize, weight=500, antialias=true})

	self.ui.timeTitle:SetFont(titleFont)
	self.ui.mainTitle:SetFont(titleFont)
	self.ui.roundTitle:SetFont(titleFont)
	self.ui.timeContent:SetFont(contentFont)
	self.ui.mainContent:SetFont(contentFont)
	self.ui.roundContent:SetFont(contentFont)	

	local paddingH = math.floor(10*dpi)
	local paddingV = math.floor(2*dpi)
	self.ui.timeContainer:DockPadding(paddingH, paddingV, paddingH, paddingV)
	self.ui.roundContainer:DockPadding(paddingH, paddingV, paddingH, paddingV)
	self.ui.mainContainer:DockPadding(paddingH, paddingV, paddingH, paddingV)	

	local newSize = self.sizes.area * dpi
	self.ui.teamBar:SetSize(newSize.x, paddingV)
	self.ui.timeContainer:SetSize(newSize.x / 5, newSize.y)
	self.ui.roundContainer:SetSize(newSize.x / 5, newSize.y)
	self:SetSize(newSize.x, newSize.y)

	self.ui.teamBar:InvalidateParent()
	self.ui.mainTitle:InvalidateParent()
	self.ui.timeTitle:InvalidateParent()
	self.ui.roundTitle:InvalidateParent()
	self.ui.timeContainer:InvalidateParent()
	self.ui.mainContainer:InvalidateParent()
	self.ui.roundContainer:InvalidateParent()

	self:AlignBottom()
	self:CenterHorizontal()
end

vgui.Register("PHEHUDGameStateDisplay", DHUDGameStateDisplay, "Panel")
