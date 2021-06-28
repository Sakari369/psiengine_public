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
require("scripts.psi.color")
require("scripts.psi.obj")
require("scripts.psi.keyb")

-- Script version, keeps relative track of what kind of features we have in our engine.
local script_version = "0.9"

-- Get interfaces to C++ side code.
psi.input = psi_input
psi.video = psi_video
psi.options = psi_options
psi.asset_dir = psi_asset_dir

-- And create some dynamically.
psi.renderer = PSIGLRenderer()
psi.resources = PSIResourceManager()

-- Local variables used within the script.
local _frametime = (1.0/60.0) * 1000.0

local _phase_deg = 0
local _velocity_deg = 0.016

local _camera_params = {
	vec3(-1.491892, 1.526843, 2.860107),
	vec3(-782.451, -24.9001, 0),
	vec3(0.419514, -0.421037, -0.804199),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

function create_icosa_strip(divisions, strip_count, center_hue)
	local icosas = {}
	local side_count = (strip_count / 2)
	local colors = psi.color.hsv_analogue(center_hue, side_count)

	for i = 0, strip_count do
		local color = colors[strip_count - i]

		local mult = vec4(1.0 - (1.0/(i+1)), 1.0, 0.0 + (9.0/(i+1)), 1.0)
		local icosa_color = vec4(color.r * mult.r, color.g * mult.g, color.b * mult.b, color.a * mult.a)

		local icosa = psi.obj.icosahedron.create(divisions, icosa_color)
		icosa:get_material():set_wireframe(true)

		icosas[i] = icosa
	end

	return icosas
end

function create_tetra_strip(strip_count, center_hue)
	local icosas2 = {}
	local side_count = (strip_count / 2)
	local colors = psi.color.hsv_analogue(center_hue, side_count)

	for i = 0, strip_count do
		local color = colors[strip_count - i]

		local mult = vec4(1.0, 1.0, 1.0, 1.0)
		local tetra_color = vec4(color.r * mult.r, color.g * mult.g, color.b * mult.b, color.a * mult.a)

		local tetra = psi.obj.tetrahedron.create(tetra_color)
		tetra:get_material():set_wireframe(true)

		icosas2[i] = tetra
	end

	return icosas2
end

-- our main loop.
function main()
	local quit = false

	if load_shaders() == false then
		os.exit(2)
	end

	psi.video:set_cursor_visible(false)

	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:set_cull_mode(psi.render.culling.BACK)
	psi.renderer:init()

	psi.input:set_movement_speed(0.060)
	psi.internal_status("IcosaRainbowBall", script_version)

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					60.0, psi.video:get_viewport_aspect_ratio())

	-- Our scene.
	local scene = PSIRenderScene()

	-- Lightning.
	psi.lights.directional, psi.lights.ambient = create_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Setup rendering context.
	local ctx = psi.renderer:get_context()
	ctx.bg_color = vec4(0.10, 0.10, 0.10, 1.0)

	local strip_count = 16
	local icosas = create_icosa_strip(1, strip_count, 0.3)
	for i = 0, #icosas do
		local icosa = icosas[i]
		scene:add(icosa)
	end

	local frametimer = PSIFrameTimer()

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		for i = 0, #icosas do
			_phase_deg = ((((_phase_deg + _velocity_deg) % 360.0) + 360.0)) % 360.0
			local angle = _phase_deg + ((i+1) * 0.05)
			local rot = vec3(angle, angle, angle)

			local icosa = icosas[i]
			icosa:get_transform():set_rotation_deg(rot)
		end

		if psi.video:should_close_window() > 0 then
			quit = true
		end

		psi.camera.translate_from_input(camera, _frametime)
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		-- Run with fixed frametime.
		ctx.frametime = frametimer:end_frame_fixed(_frametime)
		ctx.elapsed_time = frametimer:get_elapsed_time()
	until (quit == true)
end

-- Load all of our shaders and place them in the psi scope
function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	-- Assign to psi.shaders namespace for easy access.
	psi.shaders.phong = psi.shader.create('phong', {
		{ psi.shader.type.VERTEX,   "phong.vert", },
		{ psi.shader.type.FRAGMENT, "phong.frag"  }
	})

	return true
end

-- Create scene lights.
function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(0.0, 1.0, 1.0, 1.0))
	ambient:set_intensity(0.43)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.9)
	directional:set_dir(vec3(-0.3, 0.8, 1.0))

	return directional, ambient
end

-- Keyevent handler.
function key_events(camera, scene)
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_ENTER) == 1) then
		camera:print_position_vectors()
	elseif (psi.input:key_pressed(psi.KEYS.KEY_T) == 1) then
		_frametime = _frametime + (1.0/600.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _frametime, 1000.0/_frametime)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_G) == 1) then
		_frametime = _frametime - (1.0/600.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _frametime, 1000.0/_frametime)
	end
end
