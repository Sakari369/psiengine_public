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
local _axis_visible = false

local _camera_params = {
	vec3(-3.192322, 1.173093, 1.834028),
	vec3(-29.5, -15.75, 0),
	vec3(0.837678, -0.271440, -0.473936),
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
	psi.renderer:set_cull_mode(psi.render.culling.BACK)
	psi.renderer:init()

	psi.input:set_movement_speed(0.060)
	psi.internal_status("Merkaba", script_version)

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
	ctx.bg_color = vec4(0.0, 0.0, 0.0, 1.0)

	local tetra = psi.obj.tetrahedron.create(vec4(0.1843, 0.8470,0.9450, 1.0))
	tetra:get_transform():set_rotation_deg(vec3(90.0, 0.0, -90.0))
	scene:add(tetra)

	local tetra2 = psi.obj.tetrahedron.create(vec4(0.8039, 0.1254, 0.4431, 1.0))
	tetra2:get_transform():set_rotation_deg(vec3(-90, 0.0, -90.0))
	scene:add(tetra2)

	if _axis_visible then
		_axis = psi.obj.axis.create(1000)
		scene:add(_axis)
	end

	-- Frame timing.
	local frametimer = PSIFrameTimer()

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		if psi.video:should_close_window() > 0 then
			quit = true
		end

		-- Translate camera point and render.
		psi.camera.translate_from_input(camera, ctx.frametime)
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		ctx.frametime = frametimer:end_frame()
		ctx.elapsed_time = frametimer:get_elapsed_time()
		ctx.frametime_mult = (1.0 / 60.0) * ctx.frametime
	until (quit == true)
end

function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

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
	end
end
