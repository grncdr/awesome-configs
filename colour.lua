-- Import Section:
-- declare everything this package needs from outside
local math = require("math")
local tonumber = tonumber
local string = string
local setmetatable = setmetatable
-- Take that, Americans! ;)
module("colour")

Colour = {
	rgb = {},
	hsv = {}
}

function Colour:new (o)
  o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- function Colour:fromRgb (colourString)
-- 	local colours = colourString.slice(4,-1).split(',')
	-- for(local i = 0; i < colours.length; i++) do
		-- this.rgb[i] = parseInt(colours[i],10)
-- 	end

function Colour.rgbToHsv(c)
	local r = c.rgb[1] / 255
	local g = c.rgb[2] / 255
	local b = c.rgb[3] / 255
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local h, s, v = max, max, max

	local d = max - min;
	if max == 0 then
		s = 0
	else
		s = d / max
	end

	if(max == min) then
		h = 0; -- achromatic
	else
		if   max == r then
			if g < b then
				h = (g - b) / d + 6
			else
				h = (g - b) / d + 0
			end
		elseif max == g then
			h = (b - r) / d + 2
		elseif max == b then
			h = (r - g) / d + 4
		end
		h = h / 6;
	end
	c.hsv = {h, s, v}
end

function Colour.hsvToRgb (c)
	local h = c.hsv[1] 
	local s = c.hsv[2]
	local v = c.hsv[3]

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	local r, g, b;
	local switch = i % 6
	if     switch == 0 then r, g, b = v, t, p
	elseif switch == 1 then r, g, b = q, v, p
	elseif switch == 2 then r, g, b = p, v, t
	elseif switch == 3 then r, g, b = p, q, v
	elseif switch == 4 then r, g, b = t, p, v
	elseif switch == 5 then r, g, b = v, p, q end
	c.rgb = {
		math.floor(r * 255 + 0.5), 
		math.floor(g * 255 + 0.5), 
		math.floor(b * 255 + 0.5)
	}
end

function Colour:rotate ()
	local c = self:new()
	local tmp = self.rgb[1]
	for i=1,2 do
		c.rgb[i] = self.rgb[i+1]
	end
	c.rgb[3] = tmp
	c:rgbToHsv()
	return c
end

function Colour:invert ()
	local c = self:new()
	for i=1,3 do
		c.rgb[i] = 255 - self.rgb[i]
	end
	c:rgbToHsv()
	return c
end

function Colour:contrast ()
	local c = self:new()
	if self.hsv[1] > 0 then
		c.hsv[1] = (self.hsv[1] + (1/3)) % 1
	end
	c.hsv[2] = 1 - self.hsv[2]
	c.hsv[3] = 1 - self.hsv[3]
	c:hsvToRgb()
	return c
end

function Colour.rgbBlend (c1, c2, mix)
	local c = c1:new()
	for i=1,3 do
		c.rgb[i] = (c1.rgb[i] + (c2.rgb[i] - c1.rgb[i]) * mix)
	end
	c:rgbToHsv()
	return c
end

function Colour.hsvBlend (c1, c2, mix)
	local c = c1:new()
	for i=1,3 do
		c.hsv[i] = c1.hsv[i] + ((c1.hsv[i] - c2.hsv[i]) * mix)
	end
	c:hsvToRgb()
	return c
end


function Colour:toHex ()
	local hexstring = '#'
	for i=1,3 do
		hexstring = hexstring .. string.format("%02x", self.rgb[i])
	end
	return hexstring
end
	

function fromHex (hs)
	local c = Colour:new()
	for i = 1, 3 do
		c.rgb[i] = tonumber( '0x' .. string.sub(hs, i*2, i*2+1))
	end
	c:rgbToHsv()
	return c
end
	
