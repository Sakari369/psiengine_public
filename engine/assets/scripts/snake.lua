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

-- global class references.
local _paused = false
local _frametime = (1.0/60.0) * 1000.0

local _camera_params = {
	vec3(58.127365, 3.894021, -24.988310),
	vec3(-1353.85, -1.70002, 0),
	vec3(0.067114, -0.029667, 0.997304),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

local _balls = {}

function create_icosahedron()
	local mesh = psi.obj.icosahedron.create(1, vec4(1.0, 0.0, 1.0, 1.0))
	mesh:get_transform():set_scaling(vec3(3.0, 3.2, 3.3))

	return mesh
end

function create_snake(offset, color_hsv, ball_count)
	local icos = {}
	for i=1, ball_count do
		local ico = create_icosahedron()

		local t = 0.18 * i+1
		local translation = vec3(offset.x + 1.133 * i * math.cos(t/512.0), 
					 offset.y + 1.618 * 6 * math.sin(t), 
					 offset.z + 0.0);

		ico:get_transform():set_translation(translation)
		ico:get_transform():set_scaling(vec3(1.0, 1.0, 1.0))

		local hue = color_hsv.x
		--- math.sin(i/32.0) * 0.1
		local sat = color_hsv.y
		local val = color_hsv.z

		local hsv = vec3(hue, sat, val)
		local color = psi.color.hsv_to_rgba(hsv)
		ico:get_material():set_color(color)

		icos[#icos + 1] = ico
	end

	return icos
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

	psi.input:set_movement_speed(0.25)
	psi.internal_status("Snake", script_version)

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					90.0, psi.video:get_viewport_aspect_ratio())

	-- Our scene.
	local scene = PSIRenderScene()

	-- Lightning.
	psi.lights.directional, psi.lights.ambient = get_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	local ctx = psi.renderer:get_context()
	ctx.bg_color = vec4(0.20, 0.20, 0.20, 1.0)

	for i, ico in ipairs(create_snake(vec3(0.0, 0.0, 25.0), vec3(0.6, 1.0, 1.0), 128)) do
		scene:add(ico)
		_balls[#_balls + 1] = ico
	end

	local scaler = PSIScaler()
	scaler:set_min_scale(-1.0)
	scaler:set_max_scale(1.0)
	scaler:set_freq(0.5)

	local frametimer = PSIFrameTimer()

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		local t = frametimer:get_elapsed_time()
		for i=1, #_balls do
			local ico = _balls[i]
			local transform = ico:get_transform():get_translation()

			transform.y = transform.y + math.cos(t/4096.0) * 0.025
			transform.x = transform.x + math.sin(t/4096.0 + (i * 0.15)) * 0.025
			transform.z = transform.z + math.cos(t/4096.0 + (i * 0.15)) * 0.05
		end

		scaler:inc_phase(_frametime)

		if psi.video:should_close_window() > 0 
		or (psi.options.exit_after_one_frame == 1 and frames > 1) then
			quit = true
		end

		psi.camera.translate_from_input(camera, _frametime)
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		frametimer:end_frame(_frametime)
		ctx.elapsed_time = frametimer:get_elapsed_time()
		ctx.frametime_mult = (1.0 / 60.0) * _frametime
		ctx.frametime = _frametime
	until (quit == true)
end

function draw_balls(ctx, ball_idx_offset, offset, scaler, ball_count)
	local start_idx = ball_idx_offset * ball_count
	local end_idx = start_idx + ball_count
	for i=start_idx+1, end_idx do
		local ico = _balls[i]
		local ico_trans = ico:get_transform():get_translation()
		local translation = vec3(
		offset.x + 36.0 * math.cos(scaler:get_phase()+260.0),
		offset.y, offset.z)
		ico:get_transform():set_translation(translation)
	end
end

function key_events(camera, scene)
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_TAB) == 1) then
		psi.renderer:cycle_draw_mode();
	elseif (psi.input:key_pressed(psi.KEYS.KEY_ENTER) == 1) then
		camera:print_position_vectors()
	elseif (psi.input:key_pressed(psi.KEYS.KEY_T) == 1) then
		_frametime = _frametime + (1.0/600.0) * 1000.0
		-- We need: fps = (1.0/60.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _frametime, 1000.0/_frametime)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_G) == 1) then
		_frametime = _frametime - (1.0/600.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _frametime, 1000.0/_frametime)
	end
end

-- Load all of our shaders and place them in the psi scope
function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	local phong_paths = {
		{ psi.shader.type.VERTEX, 	"phong.vert", },
		{ psi.shader.type.FRAGMENT, "phong.frag"  }
	}
	psi.shaders.phong = psi.shader.create('phong', phong_paths)

	return true
end

function get_lights()
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

