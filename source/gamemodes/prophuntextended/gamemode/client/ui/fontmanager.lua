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
	if (self.fonts[name] != nil) then
		return true
	end
	return false
end

function FontManagerMeta:CreateFontData(settings)
	local base = {}
	base.font = "Roboto"
	base.extended = true
	base.size = 13
	base.weight = 500
	base.blursize = 0
	base.scanlines = 0
	base.antialias = true
	base.underline = false
	base.italic = false
	base.strikeout = false
	base.symbol = false
	base.rotary = false
	base.shadow = false
	base.additive = false
	base.outline = false
	local final = table.Merge(base, settings)
	return final
end

function FontManagerMeta:CreateFont(settings)
	local final = self:CreateFontData(settings)
	local name = self:ToName(final)
	return self:Request(name, final)
end 

function FontManagerMeta:ToName(settings)
	local name = settings.font
	name = name .. "[S" .. settings.size
	name = name .. "W" .. settings.weight
	if (settings.blursize > 0) then name = name .. "B" .. settings.blursize end
	if (settings.scanlines > 0) then name = name .. "L" .. settings.scanlines end
	if (settings.antialias) then name = name .. "A" end
	if (settings.extended) then name = name .. "E" end
	if (settings.underline) then name = name .. "U" end
	if (settings.italic) then name = name .. "I" end
	if (settings.strikeout) then name = name .. "-" end
	if (settings.shadow) then name = name .. "S" end
	if (settings.outline) then name = name .. "O" end
	if (settings.additive) then name = name .. "+" end
	if (settings.rotary) then name = name .. "R" end
	if (settings.symbol) then name = name .. "#" end
	name = name .. "]"
	return name
end

function FontManagerMeta:Request(name, settings)
	if (self.fonts[name] != nil) then
		--print("[Prop Hunt Font Manager] Request for font '"..name.."' received and cached.")
		return name
	end
	
	print("[Font Manager] Creating new Font '"..name.."'...")
	self.fonts[name] = surface.CreateFont(name, settings)
	return name
end

_G["FontManager"] = FontManager()
