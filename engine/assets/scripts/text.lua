require("math")
require("os")
require("table")

-- Import our core engine scripts.
require("scripts.psi.core")
require("scripts.psi.util")
require("scripts.psi.input")
require("scripts.psi.camera")
require("scripts.psi.renderer")
require("scripts.psi.shader")
require("scripts.psi.obj")
require("scripts.psi.color")
require("scripts.psi.keyb")

-- Script version, keeps relative track of what kind of features we have in our engine.
local script_version = "0.9"

-- Assign global psi namespace references to C++ side core classes.
-- These are created on the C++ side when our engine is initialized, before the Lua script
-- is loaded, and assigned to global variables psi_input and so on.
psi.input = psi_input
psi.video = psi_video
psi.options = psi_options
psi.asset_dir = psi_asset_dir

-- Create instances of the renderer and resources classes.
psi.renderer = PSIGLRenderer()
psi.resources = PSIResourceManager()

-- Camera parameters.
local _camera_params = {
	vec3(19.337484, -0.612830, 22.375536),
	vec3(-76.1999, 7.35002, 0),
	vec3(0.236575, 0.127930, -0.963154),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

local _toggle_text = false
local _active_text_index = 1

-- our main loop.
function main()
	local quit = false

	if load_shaders() == false then
		os.exit(2)
	end

	-- Set video options.
	psi.video:set_cursor_visible(false)

	-- Set renderer options.
	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:set_cull_mode(psi.render.culling.BACK)
	psi.renderer:init()

	-- Set input options.
	psi.input:set_movement_speed(0.100)

	-- Show internal status message.
	psi.internal_status("Text rendering", script_version)

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					90.0, psi.video:get_viewport_aspect_ratio())

	-- Create scene for render objects.
	local scene = PSIRenderScene()

	-- Add directional and ambient light.
	-- Required for phong shader.
	psi.lights.directional, psi.lights.ambient = create_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Frame timing.
	local frametimer = PSIFrameTimer()

	-- Setup rendering context.
	local ctx = psi.renderer:get_context()
	ctx.bg_color = vec4(0.25, 0.25, 0.25, 1.0)

	-- Create font atlas for font rendering.
	local atlas_charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^_&*/\\()+-=[]{};'\""
	local atlas = PSIFontAtlas()
	atlas:set_size(ivec2(4096, 4096))
	atlas:set_font_size(410)
	atlas:set_font_color(vec4(1.0, 1.0, 1.0, 1.0))
	atlas:set_font_path(path.join(psi.asset_dir, "fonts/AppleGothic.ttf"))
	atlas:set_charset(atlas_charset)
	atlas:init()

	-- Overlay text for font rendering effect.
	local overlay_text_color_hsv = vec3(1.0, 1.0, 1.0)
	local overlay_text_material = PSIGLMaterial()
	overlay_text_material:set_shader(psi.shaders.text)
	overlay_text_material:set_color(psi.color.hsv_to_rgba(overlay_text_color_hsv))

	local overlay_text = PSITextRenderer()
	overlay_text:set_material(overlay_text_material)
	overlay_text:set_font_atlas(atlas)
	overlay_text:init()

	local text_material = PSIGLMaterial()
	text_material:set_shader(psi.shaders.text)
	text_material:set_color(vec4(1.0, 1.0, 1.0, 1.0))

	-- Text for font rendering effect.
	-- Overlay effect is drawn on top of this text for an added typewrite like effect.
	local text = PSITextRenderer()
	text:set_material(text_material)
	text:set_font_atlas(atlas)
	text:init()

	local text1 = "PSiTRiANGLE ENGiNE /o\\ ROCKiNG iT!"
	local text2 = "Sakari369 ^_^ Weav1ng B1nary Webs!"
	local text3 = "Writing your own 3D engine == FUN!"
	local active_text = text1

	overlay_text:set_text(active_text)
	text:set_text(active_text)

	local head_offset = 0
	local tail_offset = 0
	local text_draw_length = 22 
	overlay_text:set_draw_count(1)
	overlay_text:set_draw_offset(head_offset)

	text:set_draw_count(1)
	text:set_draw_offset(head_offset)

	scene:add(overlay_text)
	scene:add(text)

	local text_cycles_completed = 0

	-- Main program loop.
	repeat
		-- Begin frame timing.
		frametimer:begin_frame()

		-- Poll events. This polls the input events also, as the input
		-- is handled by the underlying glfw -window subsystem.
		psi.video:poll_events()
		-- Handle camera movement.
		psi.keyb.key_events()
		-- Handle script key events.
		key_events(camera, scene)

		-- Translate camera from input.
		psi.camera.translate_from_input(camera, ctx.frametime)

		if _toggle_text == true then
			if _active_text_index == 0 then
				active_text = text1
				_active_text_index = 1
			elseif _active_text_index == 1 then
				active_text = text2
				_active_text_index = 2
			elseif _active_text_index == 2 then
				active_text = text3
				_active_text_index = 0
			end

			overlay_text:set_text(active_text)
			text:set_text(active_text)
			_toggle_text = false
		end

		if frametimer:get_elapsed_frames() % 4 == 0 then
			local len = string.len(active_text)

			if head_offset < len then
				head_offset = head_offset + 1
			end

			-- Rainbow hue effect for overlay color.
			local color = psi.color.hsv_to_rgba(overlay_text_color_hsv)
			overlay_text_color_hsv.x = overlay_text_color_hsv.x + (1.0 / 18.0)
			overlay_text_material:set_color(color)
			
			-- If we are drawing both the head and the tail
			-- We will have to wait -- < ...... >.
			-- Until the tail has gone to > active_text
			-- Then we can start the cycle again.
			if head_offset > text_draw_length then
				tail_offset = tail_offset + 1

				if tail_offset > len then
					head_offset = 0
					tail_offset = 0

					text_cycles_completed = text_cycles_completed + 1
					if text_cycles_completed >= 1 then
						_toggle_text = true
						text_cycles_completed = 0
					end
				end
			end

			overlay_text:set_draw_offset(head_offset)

			text:set_draw_count(head_offset - tail_offset)
			text:set_draw_offset(tail_offset)
		end

		-- Render scene with current context and camera.
		psi.renderer:render(scene, ctx, camera)
		-- Flip OpenGL buffer to screen.
		psi.video:flip()

		-- Check if application should quit.
		if psi.video:should_close_window() > 0 then
			quit = true
		end

		ctx.frametime = frametimer:end_frame()
		ctx.elapsed_time = frametimer:get_elapsed_time()
	until (quit == true)
end

-- Script key event handler.
function key_events(camera, scene)
	-- On escape key, set that window should close and application quit.
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)
	-- Toggle OpenGL shading mode between solid / wireframe.
	elseif (psi.input:key_pressed(psi.KEYS.KEY_TAB) == 1) then
		psi.renderer:cycle_draw_mode();
	-- Print current camera position vectors.
	elseif (psi.input:key_pressed(psi.KEYS.KEY_ENTER) == 1) then
		camera:print_position_vectors()
	end
end

-- Load all shaders for this script.
function load_shaders()
	-- Load a simple phong shader.
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	local text_paths = {
		{ psi.shader.type.VERTEX,   "text.vert", },
		{ psi.shader.type.FRAGMENT, "text.frag"  }
	}
	psi.shaders.text = psi.shader.create('text', text_paths)

	return true
end

-- Create scene lights.
function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(0.9, 0.9, 0.9, 1.0))
	ambient:set_intensity(0.7)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.8)
	directional:set_dir(vec3(1.0, 1.0, 0.0))

	return directional, ambient
end
