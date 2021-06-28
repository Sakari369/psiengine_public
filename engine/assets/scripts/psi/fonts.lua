psi.fonts = {}

-- Creates a font atlas
-- With the specified charset of characters
-- Used with font rendering
function psi.fonts.create_atlas(path, size, res, color)
	local atlas_charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^_&*/\\()+-=[]{};'\""
	local atlas = PSIFontAtlas()

	atlas:set_size(ivec2(res, res))
	atlas:set_font_size(size)
	atlas:set_font_color(color)
	atlas:set_font_path(path)
	atlas:set_charset(atlas_charset)
	atlas:init()

	return atlas
end

