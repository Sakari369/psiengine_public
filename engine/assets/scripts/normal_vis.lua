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
	vec3(2.424888, 3.099859, -2.370928),
	vec3(136.25, -39.5, 0),
	vec3(-0.557394, -0.636078, 0.533588),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

local _frametime = (1.0/60.0) * 1000.0

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
	psi.input:set_movement_speed(0.08)

	-- Show internal status message.
	psi.internal_status("normals visualization", script_version)

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
	ctx.bg_color = vec4(0.15, 0.15, 0.15, 1.0)

	-- Add cube.
	local cube = psi.obj.cube.create(vec4((1.0/255)*111, (1.0/255)*188, (1.0/255)*241, 1.0))
	scene:add(cube)

	-- Add cube with normal visualization.
	local cube_normal_mat = PSIGLMaterial()
	cube_normal_mat:set_shader(psi.shader.shaders.normal_vis)
	cube_normal_mat:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	local cube_geom = PSIGeometry.cube()
	local cube_normal_mesh = PSIRenderMesh()
	cube_normal_mesh:set_material(cube_normal_mat)
	cube_normal_mesh:set_geometry(cube_geom)
	cube_normal_mesh:init()
	cube_normal_mesh:set_draw_mode(0)
	scene:add(cube_normal_mesh)

	-- Add tetra.
	local tetra = psi.obj.tetrahedron.create(vec4((1.0/255)*238, (1.0/255)*65, (1.0/255)*95, 1.0))
	tetra:get_transform():set_translation(vec3(-3.0, 0.0, 3.0))
	scene:add(tetra)

	-- Add tetra with normal visualization.
	local tetra_normal_mat = PSIGLMaterial()
	tetra_normal_mat:set_shader(psi.shader.shaders.normal_vis)
	tetra_normal_mat:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	local tetra_geom = PSIGeometry.tetrahedron()
	local tetra_normal_mesh = PSIRenderMesh()
	tetra_normal_mesh:set_material(tetra_normal_mat)
	tetra_normal_mesh:set_geometry(tetra_geom)
	tetra_normal_mesh:init()
	tetra_normal_mesh:set_draw_mode(0)
	tetra_normal_mesh:get_transform():set_translation(vec3(-3.0, 0.0, 3.0))
	scene:add(tetra_normal_mesh)

	-- Add icosa.
	local icosa_recursion = 1
	local icosa_translation = vec3(-3.0, 0.0, -3.0)
	local icosa = psi.obj.icosahedron.create(icosa_recursion, vec4((1.0/255)*233, (1.0/255)*233, (1.0/255)*95, 1.0))
	icosa:get_transform():set_translation(icosa_translation)
	scene:add(icosa)

	-- Add icosa with normal visualization.
	local icosa_normal_mat = PSIGLMaterial()
	icosa_normal_mat:set_shader(psi.shader.shaders.normal_vis)
	icosa_normal_mat:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	local icosa_geom = PSIGeometry.icosahedron(icosa_recursion)
	local icosa_normal_mesh = PSIRenderMesh()
	icosa_normal_mesh:set_material(icosa_normal_mat)
	icosa_normal_mesh:set_geometry(icosa_geom)
	icosa_normal_mesh:init()
	icosa_normal_mesh:set_draw_mode(0)
	icosa_normal_mesh:get_transform():set_translation(icosa_translation)
	scene:add(icosa_normal_mesh)

	-- Add prism.
	local prism_radius = 1.0
	local prism_depth = 1.0
	local prism = psi.obj.prism.create(prism_radius, prism_depth, vec4((1.0/255) * 53, (1.0/255) * 221, (1.0/255)*165, 1.0))
	prism:get_transform():set_translation(vec3(3.0, 0.0, 3.0))
	scene:add(prism)

	-- Add prism with normal visualization.
	local prism_normal_mat = PSIGLMaterial()
	prism_normal_mat:set_shader(psi.shader.shaders.normal_vis)
	prism_normal_mat:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	local prism_geom = PSIGeometry.prism(prism_radius, prism_depth)
	local prism_normal_mesh = PSIRenderMesh()
	prism_normal_mesh:set_material(prism_normal_mat)
	prism_normal_mesh:set_geometry(prism_geom)
	prism_normal_mesh:init()
	prism_normal_mesh:set_draw_mode(0)
	prism_normal_mesh:get_transform():set_translation(vec3(3.0, 0.0, 3.0))
	scene:add(prism_normal_mesh)

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

		-- Render scene with current context and camera.
		psi.renderer:render(scene, ctx, camera)
		-- Flip OpenGL buffer to screen.
		psi.video:flip()

		-- Check if application should quit.
		if psi.video:should_close_window() > 0 then
			quit = true
		end

		ctx.frametime = frametimer:end_frame_fixed(_frametime)
		ctx.elapsed_time = frametimer:get_elapsed_time()
	until (quit == true)
end

local _dir_index = 0

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
	elseif (psi.input:key_pressed(psi.KEYS.KEY_L) == 1) then
		_dir_index = _dir_index + 1
		if _dir_index > 5 then
			_dir_index = 0
		end

		local dir
		if _dir_index == 0 then
			dir = vec3(0.0, 0.0, math.pi)
		elseif _dir_index == 1 then
			dir = vec3(0.0, 0.0, -math.pi)
		elseif _dir_index == 2 then
			dir = vec3(math.pi, 0.0, 0.0)
		elseif _dir_index == 3 then
			dir = vec3(-math.pi, 0.0, 0.0)
		elseif _dir_index == 4 then
			dir = vec3(0.0, math.pi, 0.0)
		elseif _dir_index == 5 then
			dir = vec3(0.0, -math.pi, 0.0)
		end

		psi.lights.directional:set_dir(dir)
	end
end

-- Load all shaders for this script.
function load_shaders()
	-- Load a simple phong shader.
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");
	local phong_paths = {
		{ psi.shader.type.VERTEX, "phong.vert", },
		{ psi.shader.type.FRAGMENT, "phong.frag"  }
	}
	-- Assign to psi.shaders namespace for easy access.
	psi.shaders.phong = psi.shader.create('phong', phong_paths)

	local normal_vis_paths = {
		{ psi.shader.type.VERTEX, "normal_vis.vert", },
		{ psi.shader.type.GEOMETRY, "normal_vis.geom" },
		{ psi.shader.type.FRAGMENT, "normal_vis.frag", },
	}
	-- Assign to psi.shaders namespace for easy access.
	psi.shaders.normal_vis = psi.shader.create_geometry('normal_vis', normal_vis_paths)

	return true
end

-- Create scene lights.
function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	ambient:set_intensity(0.8)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.2)
	directional:set_dir(vec3(0.0, 0.0, -math.pi))

	return directional, ambient
end
