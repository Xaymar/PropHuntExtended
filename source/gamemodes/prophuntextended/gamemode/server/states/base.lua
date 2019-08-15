--[[
	The MIT License (MIT)
	
	Copyright (c) 2018 Xaymar

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

function CLASS:__construct()
	self.name = "Unnamed"
	self.id = 0
end

function CLASS:GetName()
	return self.name
end

function CLASS:GetId()
	return self.id
end

function CLASS:OnEnter() end

function CLASS:Tick() end

function CLASS:OnLeave() end

function state(name, id)
	local obj = {}
	obj.__index = obj
	setmetatable(obj, CLASS)
	obj:__construct()
	if (name != nil) then
		obj.name = name
	end
	if (id != nil) then
		obj.id = id
	end
	return obj;
end
