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

local FontManagerMeta = {}
FontManagerMeta.__index = FontManagerMeta

-- Global Constructor
function FontManager()
	local obj = {}
	obj.__index = obj
	setmetatable(obj, FontManagerMeta)
	obj:__construct()
	return obj
end

-- Constructor
function FontManagerMeta:__construct()
	self.fonts = {}
end

function FontManagerMeta:Exists(name)
	return (self.fonts[name] != nil)
end

function FontManagerMeta:Request(name, settings)
	if (self.fonts[name] != nil) then
		print("[Prop Hunt Font Manager] Request for font '"..name.."' received and cached.")
		return name
	end
	print("[Prop Hunt Font Manager] Request for font '"..name.."' received and fulfilled.")
	self.fonts[name] = surface.CreateFont(name, settings)
	return name
end

