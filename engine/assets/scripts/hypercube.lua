require("math")
require("os")
require("table")

-- Load our internal engine Lua scripts.
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

-- Internal script version.
-- Tells us which version of the engine this script roughly matches.
local script_version = "0.9"

-- Get interfaces to C++ side code on our engine side.
-- These are created and initialized by the C++ side of our engine.
psi.input = psi_input
psi.video = psi_video
psi.options = psi_options
psi.asset_dir = psi_asset_dir

-- Renderer and resource manager are created at runtime.
psi.renderer = PSIGLRenderer()
psi.resources = PSIResourceManager()

-- Fixed frametime.
local _frametime = (1.0/60.0) * 1000.0

-- Parameters defining position for our camera view.
local _camera_params = {
	vec3(-0.5, 0.0, 0.0),
	vec3(0.0, 1.0, 0.0),
	vec3(0.0, 0.0, 0.0),
	vec3(0.000000, 1.000000, 0.000000)
}

-- Shorthand versions.
local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

function main()
	if load_shaders() == false then
		os.exit(2)
	end

	psi.internal_status("HyperCube", script_version)

	-- Initialize video and input.
	psi.video:set_cursor_visible(false)
	psi.input:set_movement_speed(0.010)

	-- Setup renderer.
	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:set_cull_mode(psi.render.culling.NONE)
	psi.renderer:init()

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					  90.0, psi.video:get_viewport_aspect_ratio())

	-- Create scene.
	local scene = PSIRenderScene()

	-- Setup lightning.
	psi.lights.directional, psi.lights.ambient = create_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Get rendering context.
	local ctx = psi.renderer:get_context()
	ctx.bg_color = vec4(0.20, 0.20, 0.20, 1.0)

	-- Load outer cube texture.
	local texture = PSIGLTexture()
	texture:load_from_file(path.join(psi.asset_dir, "textures/HyperCube03.png"))

	-- Create outer cube material.
	local cube_mat = PSIGLMaterial()
	cube_mat:set_shader(psi.shaders.phong_textured)
	cube_mat:set_texture(texture)
	cube_mat:set_color(vec4(0.0, 0.0, 0.0, 1.0))

	-- Create outer cube mesh.
	local cube_geom = PSIGeometry.cube()
	local cube = PSIRenderMesh()
	cube:set_material(cube_mat)
	cube:set_geometry(cube_geom)

	-- Add outer cube to scene.
	cube:init()
	scene:add(cube)

	-- Load inner cube texture.
	local inv_texture = PSIGLTexture()
	inv_texture:load_from_file(path.join(psi.asset_dir, "textures/HyperCube03_inv.png"))

	-- Create inner cube material.
	local inner_mat = PSIGLMaterial()
	inner_mat:set_shader(psi.shaders.phong_textured)
	inner_mat:set_texture(inv_texture)
	inner_mat:set_color(vec4(1.0, 1.0, 1.0, 1.0))

	-- Create inner cube mesh.
	local inner_cube = PSIRenderMesh()
	inner_cube:set_material(inner_mat)
	inner_cube:set_geometry(cube_geom)

	local inner_cube_scale = 0.20
	inner_cube:get_transform():set_scaling(vec3(inner_cube_scale, inner_cube_scale, inner_cube_scale))

	inner_cube:init()
	scene:add(inner_cube)

	-- Local state.
	local quit = false
	local frametimer = PSIFrameTimer()
	local inner_cube_visible = false
	local time_div = 10.0 * 1000.0

	-- Scaler for scaling inner cube.
	local scaler = PSIScaler()
	scaler:set_max_scale(inner_cube_scale)
	scaler:set_min_scale(0)
	-- Frequency is in Hz.
	scaler:set_freq(168.0 * 0.001)

	local inner_cube_anim_scale = true
	local inner_cube_scale_finished = false
	
	repeat
		frametimer:begin_frame()

		psi.video:poll_events()

		psi.keyb.key_events()
		key_events(camera, scene)

		local rot = cube:get_transform():get_rotation()
		rot.x = math.sin(ctx.elapsed_time/time_div) * math.pi*2
		rot.z = math.cos(ctx.elapsed_time/time_div + (time_div/5.0)) * math.pi*2

		local inv_rot = inner_cube:get_transform():get_rotation()
		inv_rot.x = -rot.x
		inv_rot.z = -rot.z

		-- Show the inner cube when external cube rotated over this limit.
		if (rot.x+0.15 >= math.pi*2) and inner_cube_scale_finished == false then
			inner_cube_anim_scale = true
		end

		if inner_cube_anim_scale == true then
			-- Get cosine eased phase for inner cube scale.
			local cube_scale = scaler:get_cosine_eased_phase()

			-- Set scaling for inner cube.
			local cube_scaling = vec3(cube_scale, cube_scale, cube_scale)
			inner_cube:get_transform():set_scaling(cube_scaling)

			-- Increase scale phase.
			scaler:inc_phase(ctx.frametime)

			-- Has the scaler went past it's first half cycle.
			if scaler:get_half_cycles() == 1.0 then
				-- Don't scale anymore.
				inner_cube_anim_scale = false
				inner_cube_scale_finished = true

				scaler:reset_cycles()
			end
		end

		-- Update camera view.
		psi.camera.translate_from_input(camera, ctx.frametime)

		-- Render scene and flip video buffer.
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		-- Check if we should quit.
		if psi.video:should_close_window() > 0 then
			quit = true
		end

		-- End frame.
		ctx.frametime = frametimer:end_frame_fixed(_frametime)
		ctx.elapsed_time = frametimer:get_elapsed_time()
	until (quit == true)
end

-- Handle key events.
function key_events(camera, scene)
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)
	-- Cycle through shaded, wireframe and blended wireframe draw modes.
	elseif (psi.input:key_pressed(psi.KEYS.KEY_TAB) == 1) then
		psi.renderer:cycle_draw_mode();
	-- Print position vectors for camera view.
	elseif (psi.input:key_pressed(psi.KEYS.KEY_ENTER) == 1) then
		camera:print_position_vectors()
	-- Increase frametime, effectively making everything faster.
	elseif (psi.input:key_pressed(psi.KEYS.KEY_T) == 1) then
		_frametime = _frametime + (1.0/600.0) * 1000.0
		-- We need: fps = (1.0/60.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _frametime, 1000.0/_frametime)
	-- Decrease frametime, effectively making everything run towards slow motion.
	elseif (psi.input:key_pressed(psi.KEYS.KEY_G) == 1) then
		_frametime = _frametime - (1.0/600.0) * 1000.0
		psi.printf("frametime = %.2f ms (%.3f FPS)\n", _frametime, 1000.0/_frametime)
	end
end

-- Create ambient and directional lights for scene.
function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	ambient:set_intensity(0.8)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.6)
	directional:set_dir(vec3(-1.0, 1.0, 0.0))

	return directional, ambient
end

-- Load all of our shaders and place them in global "psi." scope.
function load_shaders()
	-- Load shaders from asset directory.
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");

	-- Load a simple texture phong shader.
	local phong_textured_paths = {
		{ psi.shader.type.VERTEX,   "phong_textured.vert", },
		{ psi.shader.type.FRAGMENT, "phong_textured.frag"  }
	}
	psi.shaders.phong_textured = psi.shader.create('phong_textured', phong_textured_paths)

	return true
end
