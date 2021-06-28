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
require("scripts.psi.fonts")

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
local _paused = false
local _frametime = (1.0/60.0) * 1000.0
local _axis_visible = false

local _camera_params = {
	vec3(0.0, 0.0, 1.800),
	vec3(270.00, 0.0, 0),
	vec3(0.042663, -0.062790, -0.997115),
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

local _axis = nil
local _axis_visible = false

-- our main loop.
function main()
	local quit = false

	if load_shaders() == false then
		os.exit(2)
	end

	psi.video:set_cursor_visible(false)
	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:init()

	psi.input:set_movement_speed(0.060)
	psi.internal_status("Transparent texture test", script_version)

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
	ctx.bg_color = vec4(0.2, 0.2, 0.6, 1.0)

	local texture0 = PSIGLTexture()
	texture0:load_from_file(path.join(psi.asset_dir,"textures/layer0_512x_4_6.png"))

	local texture1 = PSIGLTexture()
	texture1:load_from_file(path.join(psi.asset_dir,"textures/layer0_512x_5_6.png"))

	local texture2 = PSIGLTexture()
	texture2:load_from_file(path.join(psi.asset_dir,"textures/layer0_512x_6_6.png"))

	local layer0 = psi.obj.plane.create(psi.shaders.phong_textured_alpha, vec4(0.1843, 0.8470,0.9450, 1.0), 1, false)
	layer0:get_transform():set_translation(vec3(0.0, 0.0, 0.0))
	layer0:get_material():set_texture(texture0)
	scene:add(layer0)

	local layer1 = psi.obj.plane.create(psi.shaders.phong_textured_alpha, vec4(0.1843, 0.8470,0.9450, 1.0), 1, false)
	layer1:get_transform():set_translation(vec3(0.0, 0.0, -1.0))
	layer1:get_material():set_texture(texture1)
	scene:add(layer1)

	local layer2 = psi.obj.plane.create(psi.shaders.phong_textured_alpha, vec4(0.1843, 0.8470,0.9450, 1.0), 1, false)
	layer2:get_transform():set_translation(vec3(0.0, 0.0, -2.0))
	layer2:get_material():set_texture(texture1)
	scene:add(layer2)

	if _axis_visible then
		_axis = psi.obj.axis.create(1000)
		scene:add(_axis)
	end

	-- Frame timing.
	local timer = PSIFrameTimer()

	repeat
		timer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		if psi.video:should_close_window() > 0 then
			quit = true
		end

		psi.camera.translate_from_input(camera, _frametime)
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		timer:end_frame(_frametime)
		ctx.elapsed_time = timer:get_elapsed_time()
		ctx.frametime_mult = (1.0 / 60.0) * _frametime
		ctx.frametime = _frametime
	until (quit == true)
end

-- Load all of our shaders and place them in the psi scope
function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	-- Assign to psi.shaders namespace for easy access.
	psi.shaders.phong_textured_alpha = psi.shader.create('phong_textured_alpha', {
		{ psi.shader.type.VERTEX,   "phong_textured.vert", },
		{ psi.shader.type.FRAGMENT, "phong_textured_alpha.frag"  }
	})

	return true
end

-- Create scene lights.
function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	ambient:set_intensity(0.75)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.8)
	directional:set_dir(vec3(0.0, 0.3, 1.0))

	return directional, ambient
end

-- Keyevent handler.
function key_events(camera, scene)
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_X) == 1) then
		_axis_visible = not _axis_visible
		if (_axis_visible == true) then
			psi.printf("visible = true\n")
			scene:add(_axis)
		else
			psi.printf("visible = false\n")
			scene:remove(_axis)
		end
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
