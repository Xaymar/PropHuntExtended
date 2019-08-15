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

--[[

# Class UIManager
UIManager is used to simplify the logic required to keep the GameMode's UI looking
 good by simply moving all the logic into a single class and then handing off 
 the UI control to the windows themselves.

# Events
Events must be explicitly listened to by the client object. A client must first call
	UIManager:Listen(string event, any uniqueId, function callback)
to listen to an event and call
	UIManager:Silence(string event, any uniqueId)
to stop listening to an event.

## UpdateDPI(float DPIPercent)
Called whenever a change is made to the DPI, such as a change in the screen resolution,
 or an update from the user of this class. Only parameter is DPI, which is a float.
1.0 designates 100%, 2.0 designates 200% and so on.

--]]

local UIManagerMeta = {}
UIManagerMeta.__index = UIManagerMeta

-- Global Constructor
function UIManager()
	local obj = {}
	obj.__index = obj
	setmetatable(obj, UIManagerMeta)
	obj:__construct()
	return obj
end

-- Constructor
function UIManagerMeta:__construct()
	self:InitializeEvents()
	self:UpdateScreen()
	self:InitializeDPI()
end

-- Events
function UIManagerMeta:InitializeEvents()
	self.events = {}
end

function UIManagerMeta:Listen(event, uniqueName, callback)
	assert(type(event) == "string", "UIManager:Listen(event<string>, callback<function>): event must be a string")
	assert(type(callback) == "function", "UIManager:Listen(event<string>, callback<function>): callback must be a function")
	
	if (self.events[event] == nil) then
		self.events[event] = {}
	end

	self.events[event][uniqueName] = callback
	return true
end

function UIManagerMeta:Silence(event, uniqueName)
	if (self.events[event] == nil) then
		return false
	end
	
	if (self.events[event][uniqueName] == nil) then
		return false
	end
	
	self.events[event][uniqueName] = nil
	return true
end

function UIManagerMeta:Call(event, ...)
	if (self.events[event] == nil) then
		return
	end
	
	for k,v in pairs(self.events[event]) do
		v(...)
	end
end

-- Screen
function UIManagerMeta:UpdateScreen()
	if (self.screen == nil) then
		self.screen = {}
	end
	if ((self.screen.width != ScrW()) || (self.screen.height != ScrH())) then
		self.screen.width = ScrW()
		self.screen.height = ScrH()
		return true
	end
	return false
end

-- Tick
function UIManagerMeta:Tick()
	if (self:UpdateScreen() == true) then
		self.dpi.calculated = self:CalculateDPI()
		self:SetDPIScale(self.dpi.override)
	end
end

-- DPI Scaling
function UIManagerMeta:InitializeDPI()
	self.dpi = {}
	-- Calculate DPI using these base sizes.
	self.dpi.base = {}
	self.dpi.base.width = 1920
	self.dpi.base.height = 1080
	-- Limits
	self.dpi.limits = {}
	self.dpi.limits.min = 0.25
	self.dpi.limits.max = 4.00
	-- Final Value
	self.dpi.override = nil
	self.dpi.calculated = self:CalculateDPI()
end

function UIManagerMeta:CalculateDPI()
	--[[
	DPI Scaling is linear in respect to the base resolution.
	That means that at 50% of the Base resolution, the output is 0.5,
	 and at 200% of the Base resolution, the output is 2.0.
	--]]
	
	-- Shortest Edge scaling
	local wScale, hScale = self.screen.width / self.dpi.base.width, self.screen.height / self.dpi.base.height
	
	if (wScale < hScale) then
		return wScale
	end
	return hScale
end

function UIManagerMeta:GetDPIScale()
	if (self.dpi.override != nil) then
		return self.dpi.override
	end
	return self.dpi.calculated
end

function UIManagerMeta:SetDPIScale(newDPIScale)
	self.dpi.override = newDPIScale
	if (self.dpi.override == nil) then
		self:Call("UpdateDPI", self.dpi.calculated)
	else
		if (self.dpi.override < self.dpi.limits.min) then
			self.dpi.override = self.dpi.limits.min
		end
		if (self.dpi.override > self.dpi.limits.max) then
			self.dpi.override = self.dpi.limits.max
		end
		self:Call("UpdateDPI", self.dpi.override)
	end
end

_G["UIManager"] = UIManager()
