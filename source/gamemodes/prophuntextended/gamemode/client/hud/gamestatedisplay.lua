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

local UI = {}

function UI:Init()
	self.time = CurTime() - 0.5

	self.padding = 3
	self.size = Vector(320, 30 + self.padding * 2)
	self.size2 = Vector(60, self.size.y)
	self.colors = {}
	self.colors.background = Color(0, 0, 0, 204)
	self.colors.title = Color(204, 204, 204, 255)
	self.colors.text = Color(255, 255, 255, 255)
	self.state = {}
	self.state.name = ""
	
	self.ui = {}
	self:DockPadding(self.padding, self.padding, self.padding, self.padding)

	self.ui.bar = vgui.Create("DShape", self)
	self.ui.bar:SetType("Rect")
	self.ui.bar:SetSize(0, 5)
	self.ui.bar:Dock(BOTTOM)

	self.ui.round = vgui.Create("Panel", self)
	self.ui.round:Dock(LEFT)
	self.ui.round:SetSize(100, self.size.y)

	self.ui.round_title = vgui.Create("DLabelDPI", self.ui.round)
	self.ui.round_title:SetFontEx({ size = 10 })
	self.ui.round_title:SetText("Round")
	self.ui.round_title:SetColor(self.colors.title)
	self.ui.round_title:SetContentAlignment(2)
	self.ui.round_title:SizeToContents()
	self.ui.round_title:Dock(TOP)

	self.ui.round_text = vgui.Create("DLabelDPI", self.ui.round)
	self.ui.round_text:SetFontEx({ size = 14 })
	self.ui.round_text:SetText("0 / 10")
	self.ui.round_text:SetColor(self.colors.text)
	self.ui.round_text:SetContentAlignment(8)
	self.ui.round_text:Dock(FILL)

	self.ui.time = vgui.Create("Panel", self)
	self.ui.time:Dock(RIGHT)
	self.ui.time:SetSize(100, self.size.y)

	self.ui.time_title = vgui.Create("DLabelDPI", self.ui.time)
	self.ui.time_title:SetFontEx({ size = 10 })
	self.ui.time_title:SetText("Time")
	self.ui.time_title:SetColor(self.colors.title)
	self.ui.time_title:SetContentAlignment(2)
	self.ui.time_title:SizeToContents()
	self.ui.time_title:Dock(TOP)

	self.ui.time_text = vgui.Create("DLabelDPI", self.ui.time)
	self.ui.time_text:SetFontEx({ size = 14 })
	self.ui.time_text:SetText("00:00")
	self.ui.time_text:SetColor(self.colors.text)
	self.ui.time_text:SetContentAlignment(8)
	self.ui.time_text:Dock(FILL)

	self.ui.state = vgui.Create("Panel", self)
	self.ui.state:Dock(FILL)

	self.ui.state_title = vgui.Create("DLabelDPI", self.ui.state)
	self.ui.state_title:SetFontEx({ size = 14 })
	self.ui.state_title:SetText("Waiting for Server...")
	self.ui.state_title:SetColor(self.colors.title)
	self.ui.state_title:SetContentAlignment(2)
	self.ui.state_title:SizeToContents()
	self.ui.state_title:Dock(TOP)

	self.ui.state_text = vgui.Create("DLabelDPI", self.ui.state)
	self.ui.state_text:SetFontEx({ size = 10 })
	self.ui.state_text:SetText("Waiting for Server...")
	self.ui.state_text:SetColor(self.colors.text)
	self.ui.state_text:SetContentAlignment(8)
	self.ui.state_text:Dock(FILL)

	hook.Add("RoundManagerEnterState", self, self.HandleEnterState);

	UIManager:Listen("UpdateDPI", self, function(dpi) self:UpdateDPI(dpi) end)
	self:UpdateDPI(UIManager:GetDPIScale())
end

function UI:OnRemove()
	UIManager:Silence("UpdateDPI", self)
end

function UI:Think()
	-- Only update once every 1/20th of a second.
	if ((CurTime() - self.time) < 0.05) then
		return
	end
	self.time = CurTime()

	-- Update Time
	self.ui.time_text:SetText(string.format("%02d:%02d", 
		math.floor(GAMEMODE:GetRoundTime() / 60), 
		math.floor(GAMEMODE:GetRoundTime() % 60)))

	-- Update State Text
	local round_time = GAMEMODE:GetRoundStateTime()
	local team_id = GAMEMODE.Teams.Spectator
	if (LocalPlayer() && LocalPlayer():IsPlayer()) then
		team_id = LocalPlayer():Team()
	end

	if (self.state.name == "Hide") then
		if (team_id == GAMEMODE.Teams.Seekers) then
			self.ui.state_text:SetText(string.format("You will be unblinded in %02d:%02d", 
				math.floor(round_time / 60), math.floor(round_time % 60)))
		else
			self.ui.state_text:SetText(string.format("Seekers unblinded in %02d:%02d...",
				math.floor(round_time / 60), math.floor(round_time % 60)))
		end
	elseif (self.state.name == "Seek") then
		if (team_id == GAMEMODE.Teams.Seekers) then
			self.ui.state_text:SetText(string.format("You have %02d:%02d left to kill all Hiders.", 
				math.floor(round_time / 60), math.floor(round_time % 60)))
		else
			self.ui.state_text:SetText(string.format("You have %02d:%02d left to annoy all Seekers.",
				math.floor(round_time / 60), math.floor(round_time % 60)))
		end
	end
end

function UI:Paint()
	local w,h = self:GetSize()
	draw.RoundedBox(0, 0, 0, w, h, self.colors.background)
end

function UI:PerformLayout(w, h)	
end

function UI:UpdateDPI(dpi)
	local w, h = self.size.x * dpi, self.size.y * dpi
	local w2, h2 = self.size2.x * dpi, self.size2.y * dpi

	self.ui.round:SetSize(w2, h2)
	self.ui.time:SetSize(w2, h2)
	
	self:DockPadding(self.padding * dpi, self.padding * dpi, self.padding * dpi, self.padding * dpi)
	self:SetSize(w, h)
	self:CenterHorizontal()
	self:AlignTop(20 * dpi)

	self.ui.round:InvalidateLayout()
	self.ui.time:InvalidateLayout()
	self:InvalidateLayout()	
end

function UI:UpdateStateDisplay()
	local team_id = GAMEMODE.Teams.Spectator
	if (LocalPlayer() && LocalPlayer():IsPlayer()) then
		team_id = LocalPlayer():Team()
	end
	
	-- Update Team Color
	self.ui.bar:SetColor(team.GetColor(team_id))

	-- Update State itself
	if (self.state.name == "PreMatch") then
		self.ui.state_title:SetText(team.GetName(team_id))
		self.ui.state_text:SetText(string.format("Waiting for players..."))
	elseif (self.state.name == "PreRound") then
		self.ui.state_title:SetText(team.GetName(team_id))
		self.ui.state_text:SetText(string.format("Round starts soon..."))
	elseif (self.state.name == "Hide") then
		local round_time = GAMEMODE:GetRoundStateTime()
		if (team_id == GAMEMODE.Teams.Seekers) then
			self.ui.state_title:SetText("Blinded! Get ready to seek.")
		else
			self.ui.state_title:SetText("Hiding Time!")
		end
	elseif (self.state.name == "Seek") then
		local round_time = GAMEMODE:GetRoundStateTime()
		if (team_id == GAMEMODE.Teams.Seekers) then
			self.ui.state_title:SetText("Seek & Destroy!")
		else
			self.ui.state_title:SetText("Hide & Avoid!")
		end
	elseif (self.state.name == "PostRound") then
		self.ui.state_text:SetText("Next Round starting soon...")
		local winner = GAMEMODE:GetRoundWinner()
		if (winner == GAMEMODE.Teams.Spectators) then
			self.ui.state_title:SetText("Draw! Everybody lost.")
		elseif (winner == GAMEMODE.Teams.Seekers) then
			self.ui.state_title:SetText("Seekers Win!")
		elseif (winner == GAMEMODE.Teams.Hiders) then
			self.ui.state_title:SetText("Hiders Win!")
		end
	elseif (self.state.name == "PostMatch") then
		self.ui.state_title:SetText(team.GetName(team_id))
	end
end

function UI:HandleEnterState(id, name)
	self.state.name = name

	-- Update Round
	if (GAMEMODE.Config.Round:Limit() > 0) then
		self.ui.round_text:SetText(string.format("%d / %d", GAMEMODE:GetRound(), GAMEMODE.Config.Round:Limit()))
	else
		self.ui.round_text:SetText(string.format("%d / ∞", GAMEMODE:GetRound()))
	end
	
	self:UpdateStateDisplay()
end

vgui.Register("PHE_GameState", UI, "Panel")
