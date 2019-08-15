--[[
	The MIT License (MIT)
	
	Copyright (c) 2019 Xaymar

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

local CLASS = {}
CLASS.__index = CLASS

local netmsg = { -- Keep in sync with server table.
	refresh = "RoundManagerUpdate",
	winner = "RoundManagerWinner"
}

function CLASS:__construct()
    self.state = nil
    self.state_name = ""

	net.Receive(netmsg.refresh, function(len, pl) self:__netRefresh(len, pl) end)
	net.Receive(netmsg.winner, function(len, pl) self:__netWinner(len, pl) end)
end

function CLASS:GetStateId()
    return self.state
end

function CLASS:GetStateName()
    return self.state_name
end

function CLASS:CanJoinTeam(team)
	if (LocalPlayer():Team() == team) then
		return false
	end

	
end

function CLASS:__netRefresh(len, pl)
	local data = net.ReadTable()
	if (self.state != data.state) then
		hook.Run("RoundManagerLeaveState", self.state, self.state_name)
		self.state = data.state
		self.state_name = data.state_name
		hook.Run("RoundManagerEnterState", self.state, self.state_name)
	end
end

function CreateRoundManager()
	local obj = {}
	obj.__index = obj
	setmetatable(obj, CLASS)
	obj:__construct()
	return obj
end

_G["RoundManager"] = CreateRoundManager()
