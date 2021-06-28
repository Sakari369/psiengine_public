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
local _camera_params = 
{
	vec3(6.235939, 6.725660, -7.599140),
	vec3(90.0, 1.0, 0),
	vec3(0.002617, 0.020942, 0.999777),
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
	psi.renderer:set_cull_mode(psi.render.culling.NONE)
	--psi.renderer:set_cull_mode(psi.render.culling.BACK)
	psi.renderer:init()

	-- Set input options.
	psi.input:set_movement_speed(0.08)
	
	-- Show internal status message.
	psi.internal_status("prism grid", script_version)

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

	local rows = 30
	local cols = 20
	local radius = 0.5
	local depth = 0.05
	local prisms = {}

	for i, prism in ipairs(create_prism_grid(rows, cols, radius,depth)) do
		scene:add(prism)
		prisms[#prisms + 1] = prism
	end

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


function create_prism_grid(rows, cols, radius,depth) 
	local prisms = {}
	local x = 0.0
	local y = 0.0
	local z = 0.0

	local color = psi.color.hsv_to_rgba(vec3(0.3, 0.8, 0.8))
	local color2 = psi.color.hsv_to_rgba(vec3(0.6, 0.8, 0.8))

	local i = 0

	local x_inc = radius * 0.88
	local y_inc = radius * 1.52
	local y_off = 0.125
	local ty = 0

	for col=1, cols do
		for row=1, rows do

			local prism = psi.obj.prism.create(radius, depth, color)
			prisms[#prisms + 1] = prism

			if i % 2 == 0 then
				prism:get_transform():set_rotation_deg(vec3(0, 0, 180))
				prism:get_material():set_color(color2)
			end

			local trans = vec3(x, ty, z)
			prism:get_transform():set_translation(trans)

			y_off = -1 * y_off
			ty = y + y_off

			--psi.printf("i = %d x = %.2f y = %.2f ty = %.2f y_off = %.2f\n", i, x, y, ty, y_off)

			x = x + x_inc
			i = i + 1

		end
		x = 0
		y = y + y_inc
	end

	return prisms
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
	local phong_paths = {
		{ psi.shader.type.VERTEX, "phong.vert", },
		{ psi.shader.type.FRAGMENT, "phong.frag"  }
	}
	-- Assign to psi.shaders namespace for easy access.
	psi.shaders.phong = psi.shader.create('phong', phong_paths)

	return true
end

-- Create scene lights.
function create_lights()
	local ambient = PSILight()
	ambient:set_type(0)
	ambient:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	ambient:set_intensity(0.6)

	local directional = PSILight()
	directional:set_type(1)
	directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	directional:set_intensity(0.2)
	directional:set_dir(vec3(math.pi, 0.0, -math.pi))

	return directional, ambient
end
