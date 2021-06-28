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

local _time_in_camera_view = 0.0
-- Fixed frametime.
local _frametime = (1.0/60.0) * 1000.0

local _camera_params1 = {
	vec3(-0.128663, 0.155191, -22.924259),
	vec3(-1348.26, -1.80001, 0),
	vec3(-0.030341, -0.031411, 0.999046),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_params2 = {
	vec3(-1.410821, 2.805360, -18.536402),
	vec3(-1361.26, -9.20001, 0),
	vec3(0.192760, -0.159881, 0.968133),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_params3 = {
	vec3(18.026447, 3.254293, -10.537734),
	vec3(-1311.36, -7.75001, 0),
	vec3(-0.618779, -0.134851, 0.773905),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params1[1]
local _camera_yaw_pitch_roll = _camera_params1[2]
local _camera_front = _camera_params1[3]

local _load_skybox = true

local _current_scene = 1

function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(0.9, 0.9, 0.9, 1.0))
	ambient:set_intensity(0.7)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.9)
	directional:set_dir(vec3(1.0, 1.0, 0.0))

	return directional, ambient
end

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
		local tx = offset.x + 0.80 * i * math.cos(t/512.0)
		local ty = offset.y + 1.618 * 2 * math.sin(t)
		local tz = offset.z + 0.0
		local translation = vec3(ty, tz, tx)

		ico:get_transform():set_translation(translation)
		ico:get_transform():set_scaling(vec3(1.0, 1.0, 1.0))

		local hue = 0.10 + 0.03 * math.sin(i/3.0)
		local sat = color_hsv.y
		local val = color_hsv.z

		local hsv = vec3(hue, sat, val)
		local color = psi.color.hsv_to_rgba(hsv)
		ico:get_material():set_color(color)
		ico:get_material():set_wireframe(true)

		icos[#icos + 1] = ico
	end

	return icos
end

local ray_initial_z = {}
local ray_x_area = 22
local ray_y_area = 13
local ray_z_exit = -22
local ray_z_spawn = 32

-- How to make these spawn in a way which the stars would always spawn from a certain distance,
-- but their initial offset is different ?
--
-- Just set their initial z-position in a random position.
-- But when reaching a certain spot, move the translation to a fixed place in the z-ordering.

function create_star_rays(offset, ray_count)
	local rays = {}
	local width = 0.02
	local height = 0.02
	local hsv = vec3(0.0, 0.0, 1.0)
	local color = psi.color.hsv_to_rgba(hsv)

	for i=1, ray_count do
		local depth = 1.6 + math.random()
		local ray = psi.obj.cuboid.create(color, width, height, depth)

		local tx = offset.x + math.random(-ray_x_area, ray_x_area)
		local ty = offset.y + math.random(-ray_y_area, ray_y_area)
		local tz = offset.z + math.random(ray_z_exit, ray_z_spawn)
		local translation = vec3(tx, ty, tz)

		ray:get_transform():set_translation(translation)
		ray:get_transform():set_scaling(vec3(1.0, 1.0, 1.0))

		ray_initial_z[#ray_initial_z + 1] = translation.z

		rays[#rays + 1] = ray
	end

	return rays
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

	psi.input:set_movement_speed(0.15)
	psi.internal_status("DNA Snake", script_version)

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					60.0, psi.video:get_viewport_aspect_ratio())

	-- Our scene.
	local scene = PSIRenderScene()

	-- Lightning.
	psi.lights.directional, psi.lights.ambient = create_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Skybox loading.
	if (_load_skybox == true) then
		local texture_paths = {
			path.join(psi.asset_dir, "textures/skybox/stars/cyanpurple"),
			"right.png", -- left
			"left.png", -- right
			"top.png", -- top
			"bottom.png", -- bottom
			"front.png", -- front
			"back.png", -- back
		}
		local skybox = psi.obj.skybox.create(psi.shaders.cubemap, texture_paths)
		scene:add(skybox)
	end

	local ctx = psi.renderer:get_context()

	local bg_color = psi.color.hsv_to_rgba(vec3(0.61, 1.0, 0.30))
	ctx.bg_color = bg_color

	local snake1 = {}
	local snake_offset = vec3(0.0, 0.0, 0.0)
	local snake_color = vec3(0.2, 0.8, 1.0)
	local snake_length = 224
	for i, ico in ipairs(create_snake(snake_offset, snake_color, snake_length)) do
		scene:add(ico)
		snake1[#snake1 + 1] = ico
	end

	local rays = {}
	for i, ray in ipairs(create_star_rays(snake_offset, 192)) do
		scene:add(ray)
		rays[#rays + 1] = ray
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

		-- Increase time spent in current view.
		_time_in_camera_view = _time_in_camera_view + ctx.frametime;
		if (_time_in_camera_view > 6000) then
			-- Get new camera view parameters.
			if (_current_scene == 0) then
				_camera_pos = _camera_params1[1]
				_camera_yaw_pitch_roll = _camera_params1[2]
				_camera_front = _camera_params1[3]
			elseif (_current_scene == 1) then
				_camera_pos = _camera_params2[1]
				_camera_yaw_pitch_roll = _camera_params2[2]
				_camera_front = _camera_params2[3]
			elseif (_current_scene == 2) then
				_camera_pos = _camera_params3[1]
				_camera_yaw_pitch_roll = _camera_params3[2]
				_camera_front = _camera_params3[3]
			end

			-- Change camera view to new position.
			psi.camera.set(camera, _camera_pos, _camera_yaw_pitch_roll, _camera_front)

			-- Loop through scenes.
			_current_scene = _current_scene + 1
			if (_current_scene > 2) then
				_current_scene = 0
			end

			-- Reset time so can calculate again from 0.
			_time_in_camera_view = 0
		end

		-- translate camera point and render.
		psi.camera.translate_from_input(camera, ctx.frametime)
		psi.renderer:render(scene, ctx, camera)

		local t = ctx.elapsed_time
		local div = 512

		-- Animate the snake.
		for i=1, #snake1 do
			local ico = snake1[i]
			local transform = ico:get_transform():get_translation()

			transform.y = transform.y + ctx.frametime_mult * math.cos(t/div + (i * 0.16)) * 0.30
			transform.x = transform.x + ctx.frametime_mult * math.sin(t/div + (i * 0.16)) * 0.30
			transform.z = transform.z + ctx.frametime_mult * math.cos(t/div + (i * 0.10)) * 0.28

			--local hue = math.sin(t/1024.0) * 1.6 * math.cos(((i+1)/48))
			local hue = 0.12 + 0.03 * math.sin(t/1024.0 + i/32) + 1.0 * math.sin(t/512.0 + i/8)
			local sat = 1.0
			local val = 1.0

			local hsv = vec3(hue, sat, val)
			local color = psi.color.hsv_to_rgba(hsv)
			ico:get_material():set_color(color)
		end

		-- Animate the star rays
		for i=1, #rays do
			local ray = rays[i]
			local transform = ray:get_transform():get_translation()
			transform.z = transform.z - ctx.frametime_mult * 1.00

			if (transform.z < ray_z_exit)
			then
				transform.z = ray_z_spawn
				transform.x = math.random(-ray_x_area, ray_x_area)
				transform.y = math.random(-ray_y_area, ray_y_area)
			end
		end

		if psi.video:should_close_window() > 0 then
			quit = true
		end

		scaler:inc_phase(ctx.frametime)
		psi.video:flip()

		ctx.frametime = frametimer:end_frame_fixed(_frametime)
		ctx.elapsed_time = frametimer:get_elapsed_time()
		ctx.frametime_mult = (1.0 / 60.0) * ctx.frametime
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
	elseif (psi.input:key_pressed(psi.KEYS.KEY_P) == 1) then
		_paused = not _paused;
	elseif (psi.input:key_pressed(psi.KEYS.KEY_T) == 1) then
		_fixed_frametime = _fixed_frametime + (1.0/600.0) * 1000.0
		-- We need: fps = (1.0/60.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _fixed_frametime, 1000.0/_fixed_frametime)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_G) == 1) then
		_fixed_frametime = _fixed_frametime - (1.0/600.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _fixed_frametime, 1000.0/_fixed_frametime)
	end
end

-- Load all of our shaders and place them in the psi scope
function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	local phong_paths = {
		{ psi.shader.type.VERTEX, 	"phong.vert", },
		{ psi.shader.type.FRAGMENT, 	"phong.frag"  }
	}
	psi.shaders.phong = psi.shader.create('phong', phong_paths)

	local phong_textured_paths = {
		{ psi.shader.type.VERTEX, 	"phong_textured.vert", },
		{ psi.shader.type.FRAGMENT, 	"phong_textured.frag"  }
	}
	psi.shaders.phong_textured = psi.shader.create('phong_textured', phong_textured_paths)

	local cubemap_paths = {
		{ psi.shader.type.VERTEX, 	"cubemap.vert", },
		{ psi.shader.type.FRAGMENT, 	"cubemap.frag"  }
	}
	psi.shaders.cubemap = psi.shader.create('cubemap', cubemap_paths)

	return true
end
