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

local _camera_params = {
	vec3(-0.128663, 0.155191, -22.924259),
	vec3(-1348.26, -1.80001, 0),
	vec3(-0.030341, -0.031411, 0.999046),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camer_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

local _frametime = (1.0 / 60.0) * 1000.0

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

local _ray_initial_z = {}
local _ray_x_area = 22
local _ray_y_area = 13
local _ray_z_exit = -22
local _ray_z_spawn = 32

function create_star_rays(offset, ray_count)
	local rays = {}
	local width = 0.02
	local height = 0.02
	local hsv = vec3(0.0, 0.0, 1.0)
	local color = psi.color.hsv_to_rgba(hsv)

	for i=1, ray_count do
		local depth = 1.6 + math.random()
		local ray = psi.obj.cuboid.create(color, width, height, depth)

		local tx = offset.x + math.random(-_ray_x_area, _ray_x_area)
		local ty = offset.y + math.random(-_ray_y_area, _ray_y_area)
		local tz = offset.z + math.random(_ray_z_exit, _ray_z_spawn)
		local translation = vec3(tx, ty, tz)

		ray:get_transform():set_translation(translation)
		ray:get_transform():set_scaling(vec3(1.0, 1.0, 1.0))

		_ray_initial_z[#_ray_initial_z + 1] = translation.z

		rays[#rays + 1] = ray
	end

	return rays
end

-- our main loop.
function main()
	local quit = false

	psi.internal_status("Starfield", script_version)

	if load_shaders() == false then
		os.exit(2)
	end

	psi.video:set_cursor_visible(false)

	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:set_cull_mode(psi.render.culling.BACK)
	psi.renderer:init()

	psi.input:set_movement_speed(0.15)

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camer_yaw_pitch_roll, _camera_front, 
					60.0, psi.video:get_viewport_aspect_ratio())

	-- Our scene.
	local scene = PSIRenderScene()

	-- Lightning.
	psi.lights.directional, psi.lights.ambient = create_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Skybox loading.
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

	local ctx = psi.renderer:get_context()
	local bg_color = psi.color.hsv_to_rgba(vec3(0.61, 1.0, 0.30))
	ctx.bg_color = bg_color

	local rays = {}
	local offset = vec3(0.0, 0.0, 0.0)
	for i, ray in ipairs(create_star_rays(offset, 384)) do
		scene:add(ray)
		rays[#rays + 1] = ray
	end

	local frametimer = PSIFrameTimer()

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		local t = frametimer:get_elapsed_time()
		local div = 512
		-- Animate the star rays
		for i=1, #rays do
			local ray = rays[i]
			local transform = ray:get_transform():get_translation()
			transform.z = transform.z - ctx.frametime_mult

			if transform.z < _ray_z_exit then
				transform.z = _ray_z_spawn
				transform.x = math.random(-_ray_x_area, _ray_x_area)
				transform.y = math.random(-_ray_y_area, _ray_y_area)
			end
		end

		if psi.video:should_close_window() > 0 then
			quit = true
		end

		-- translate camera point and render.
		psi.camera.translate_from_input(camera, ctx.frametime)
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		ctx.frametime = frametimer:end_frame_fixed(_frametime)
		ctx.elapsed_time = frametimer:get_elapsed_time()
		ctx.frametime_mult = (1.0 / 60.0) * ctx.frametime
	until (quit == true)
end

function key_events(camera, scene)
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_TAB) == 1) then
		psi.renderer:cycle_draw_mode();
	elseif (psi.input:key_pressed(psi.KEYS.KEY_ENTER) == 1) then
		camera:print_position_vectors()
	end
end

-- Load all of our shaders and place them in the psi scope
function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	local phong_paths = {
		{ psi.shader.type.VERTEX, 	"phong.vert", },
		{ psi.shader.type.FRAGMENT,	"phong.frag"  }
	}
	psi.shaders.phong = psi.shader.create('phong', phong_paths)

	local cubemap_paths = {
		{ psi.shader.type.VERTEX, 	"cubemap.vert", },
		{ psi.shader.type.FRAGMENT,	"cubemap.frag"  }
	}
	psi.shaders.cubemap = psi.shader.create('cubemap', cubemap_paths)

	return true
end
