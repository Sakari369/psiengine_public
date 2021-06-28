require("math")
require("os")
require("table")

-- Import our core engine scripts.
require("scripts.psi.core")
require("scripts.psi.shader")
require("scripts.psi.color")
require("scripts.psi.renderer")
require("scripts.psi.camera")
require("scripts.psi.util")
require("scripts.psi.fonts")
require("scripts.psi.input")
require("scripts.psi.keyb")

-- Script version, keeps relative track of what kind of features we have in our engine.
local script_version = "0.9"

-- Assign global psi namespace references to C++ side core classes.
-- These are created on the C++ side when our engine is initialized, before the Lua script
-- is loaded, and assigned to global variables psi_input and so on.
psi.input = psi_input
psi.video = psi_video
psi.audio = psi_audio
psi.options = psi_options
psi.asset_dir = psi_asset_dir

-- Create instances of the renderer and resources classes.
psi.renderer = PSIGLRenderer()
psi.resources = PSIResourceManager()

-- Camera parameters.
local _camera_params = {
	vec3(11.5, 0.0, 8.0),
	vec3(-90.0, 0, 0),
	vec3(0.0, 0.0, -1.0),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

-- our main loop.
function main()
	local quit = false
	psi.internal_status("Audio playback", script_version)

	if load_shaders() == false then
		os.exit(2)
	end

	psi.video:set_cursor_visible(false)
	psi.input:set_movement_speed(0.100)
	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:init()

	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					90.0, psi.video:get_viewport_aspect_ratio())
	local scene = PSIRenderScene()
	local ctx = psi.renderer:get_context()
	ctx.bg_color = vec4(0.0, 0.0, 0.0, 1.0)

	local audio_filename = "Enlightenment_Druid_II_T003.sid_MOS6581R2.ogg"
	psi.audio:load_file(path.join(psi.asset_dir, "audio", audio_filename))
	psi.audio:init()
	psi.audio:set_loop(true)
	psi.audio:play()

	local text = "Playing back: " .. audio_filename
	local text_material = add_text(text, scene)
	local text_color_hsv = vec3(1.0, 1.0, 1.0)

	local frametimer = PSIFrameTimer()

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()

		if frametimer:get_elapsed_frames() % 4 == 0 then
			local color = psi.color.hsv_to_rgba(text_color_hsv)
			text_color_hsv.x = text_color_hsv.x + (1.0 / 24.0)
			text_material:set_color(color)
		end

		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		if (psi.video:should_close_window() > 0) then
			quit = true
		end

		ctx.frametime = frametimer:end_frame()
		ctx.elapsed_time = frametimer:get_elapsed_time()
	until quit == true

	psi.audio:stop()
end

function add_text(str, scene)
	local atlas = psi.fonts.create_atlas(path.join(psi.asset_dir, "fonts/VeraMono.ttf"),
					     64, 2048, vec4(1.0, 1.0, 1.0, 1.0))

	local text_material = PSIGLMaterial()
	text_material:set_shader(psi.shaders.text)
	text_material:set_color(vec4(1.0, 1.0, 1.0, 1.0))

	local text = PSITextRenderer()
	text:set_material(text_material)
	text:set_font_atlas(atlas)
	text:set_text(str)
	text:init()

	scene:add(text)

	return text_material
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