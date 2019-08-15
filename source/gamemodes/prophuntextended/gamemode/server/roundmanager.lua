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

local CLASS = {}
CLASS.__index = CLASS

local netmsg = {
	refresh = "RoundManagerUpdate",
	winner = "RoundManagerWinner"
}

function CLASS:__construct()
	self.state = nil
	self.next_state = nil

	-- Custom Timer Stuff
	self.timers = {}
	self.timers.funcs = {}
	self.timers.times = {}
	self.timers.delay = {}
	
	-- Register all network string
	for k, v in pairs(netmsg) do
		util.AddNetworkString(v)
	end

	-- And some more Timers based functionality.
	self:_RegisterTimer("refresh", 2.0, function() self:RefreshAll() end)

	-- We need a Think hook.
	hook.Add("Think", "RoundManagerThink", function(...) self:Tick(...) end)
end

function CLASS:_RegisterTimer(name, delay, func)
	self.timers.funcs[name] = func
	self.timers.delay[name] = delay
	self.timers.times[name] = CurTime()
end

function CLASS:GetState()
	return self.state
end

function CLASS:GetNextState()
	return self.next_state
end

function CLASS:SetState(state)
	self.next_state = state
end

function CLASS:Tick(...)
	-- Tick State
	if (self.state != nil) then
		if (self.state.Tick != nil) then
			self.state:Tick(...)
		end
	end

	-- Advance States
	if (self.next_state != self.state) then
		local to_id = -1
		local to_name = ""

		-- Call OnLeave
		if (self.state != nil) then
			if (self.state.OnLeave != nil) then
				self.state:OnLeave(self.next_state)
			end
			
			-- Run Hook
			hook.Run("RoundManagerLeaveState", self.state:GetId(), self.state:GetName())
		end
		
		-- Call OnEnter
		if (self.next_state != nil) then		
			if (self.next_state.OnEnter != nil) then
				self.next_state:OnEnter(self.state)
			end

			to_id = self.next_state:GetId()
			to_name = self.next_state:GetName()
			
			-- Run Hook
			hook.Run("RoundManagerEnterState", self.next_state:GetId(), self.next_state:GetName())
		end

		-- Send Network Message
		self:RefreshAll()

		-- Set State
		self.state = self.next_state
	end

	-- Run all timers.
	for k, v in pairs(self.timers.times) do
		if ((CurTime() - self.timers.times[k]) >= self.timers.delay[k]) then
			self.timers.funcs[k]()
			self.timers.times[k] = CurTime()
		end
	end
end

function CLASS:RefreshAll()
	local data = {}
	if (self.state != nil) then 
		data.state = self.state:GetId()
		data.state_name = self.state:GetName()
	else
		data.state = -1
		data.state_name = "Unknown"
	end

	net.Start(netmsg.refresh)
	net.WriteTable(data)
	net.Broadcast()
end

function CLASS:AnnounceWinner(team)

end

function CreateRoundManager()
	local obj = {}
	obj.__index = obj
	setmetatable(obj, CLASS)
	obj:__construct()
	return obj
end

_G["RoundManager"] = CreateRoundManager()
