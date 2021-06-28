psi.color = {}

-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--[[
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 1] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
]]
function psi.color.rgba_to_hsv(rgba)
	local r = rgba.x;
	local g = rgba.y;
	local b = rgba.z;

	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return vec3(h, s, v)
end

--[[
* Converts an HSV color value to RGB. Conversion formula
* adapted from http://en.wikipedia.org/wiki/HSV_color_space.
* Assumes h, s, and v are contained in the set [0, 1] and
* returns r, g, and b in the set [0, 1.0]
*
* @param   Number  h       The hue
* @param   Number  s       The saturation
* @param   Number  v       The value
* @return  Array           The RGB representation
]]
function psi.color.hsv_to_rgba(hsv)
	local h = hsv.x
	local s = hsv.y
	local v = hsv.z
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return vec4(r, g, b, 1.0)
end

-- Analogues colors are any colors that are side by side on 
-- a 12 part color wheel ..
--
-- So basically, we take a offset, substract 1/12 hue from that
-- Add that to our colors
-- Then add the offset color
-- Then we add a color that is 1/12 hue forwards in hue 
function psi.color.hsv_analogue(center_hue, side_count)
	colors = {}

	-- 12 steps in our analogue circle
	local hue_step = 1.0/12.0

	-- Starting hue, it's side count from center point
	local start_hue = center_hue - (hue_step * side_count)
	if (start_hue < 0.0) then
		start_hue = 1.0 + start_hue
	end

	local hsv = vec3(start_hue, 1.0, 1.0)

	-- Total colors, sides + center
	local color_count = 2 * side_count + 1

	for i=0, color_count do
		colors[i] = psi.color.hsv_to_rgba(hsv)

		hsv.x = hsv.x + hue_step
		if (hsv.x > 1.0) then
			hsv.x = hsv.x - 1.0
		end
	end

	return colors
end

psi.color.HSV = {
	RED = 0,
	YELLOW = 1 * (1.0/6.0),
	GREEN = 2 * (1.0/6.0),
	CYAN = 3 * (1.0/6.0),
	BLUE = 4 * (1.0/6.0),
	MAGENTA = 5 * (1.0/6.0)
}
