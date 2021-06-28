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

-- Get interfaces to C++ side code.
psi.input = psi_input
psi.video = psi_video
psi.options = psi_options
psi.asset_dir = psi_asset_dir

-- And create some dynamically.
psi.renderer = PSIGLRenderer()
psi.resources = PSIResourceManager()

local _camera_params = {
	vec3(2.367164, 2.375369, -2.431371),
	vec3(132.35, -24.55, 0),
	vec3(-0.612759, -0.415487, 0.672233),
	vec3(0.000000, 1.000000, 0.000000)
}

local _camera_pos = _camera_params[1]
local _camera_yaw_pitch_roll = _camera_params[2]
local _camera_front = _camera_params[3]

-- Create PSIRenderMesh from gl_mesh.
function create_obj(gl_mesh, shader)
	local mesh = PSIRenderMesh()
	mesh:set_gl_mesh(gl_mesh)

	local mat = PSIGLMaterial()
	mat:set_color(vec4(0.0, 0.3, 1.0, 1.0))
	mat:set_shader(shader);
	mesh:set_material(mat)

	return mesh;
end

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
	psi.input:set_movement_speed(0.030)

	-- Show internal status message.
	psi.internal_status("Icosahedron", script_version)

	-- Our view into the world.
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					90.0, psi.video:get_viewport_aspect_ratio())

	-- Our scene of objects.
	local scene = PSIRenderScene()

	-- Lightning.
	psi.lights.directional, psi.lights.ambient = create_lights()

	-- Add directional and ambient light.
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Setup rendering context.
	local ctx = psi.renderer:get_context()
	ctx.bg_color = vec4(0.40, 0.40, 0.40, 1.00)

	local gltf_loader = PSIGLTFLoader()

	-- Load duck model.
	local shader = psi.shaders.phong_textured
	local duck_gl_mesh = gltf_loader:load_gl_mesh(shader, path.join(psi.asset_dir, "models/Duck.gltf"))
	local duck = create_obj(duck_gl_mesh, psi.shaders.phong_textured)

	-- Load duck texture.
	local duck_tex = PSIGLTexture()
	duck_tex:load_from_file(path.join(psi.asset_dir, "textures/DuckCM.png"))
	duck:get_material():set_needs_update(false)
	duck:get_material():set_texture(duck_tex)
	scene:add(duck)

	-- Load smiley face model.
	local smiley_gl_mesh = gltf_loader:load_gl_mesh(shader, path.join(psi.asset_dir, "models/SmilingFace.gltf"))
	local smiley = create_obj(smiley_gl_mesh, shader)

	-- Load smiley face texture.
	local smiley_tex = PSIGLTexture()
	smiley_tex:load_from_file(path.join(psi.asset_dir, "textures/SmilingFace_texture_0002.jpg"))
	smiley:get_material():set_needs_update(false)
	smiley:get_material():set_texture(smiley_tex)

	-- Transform and rotate.
	local smiley_offset = 3.5
	smiley:get_transform():get_translation().x = smiley_offset
	local rotation = vec3(0.0, 90.0, 45.0)
	smiley:get_transform():set_rotation_deg(rotation)
	scene:add(smiley)

	local frametimer = PSIFrameTimer()

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		-- Animate objects.
		local t = ctx.elapsed_time * 0.001
		--psi.printf("frametime = %.3f frametime_mult = %.3f t = %.3f\n", frametime, ctx.frametime_mult, t)
		psi.lights.directional:set_dir(vec3(math.sin(t), 1.0, math.cos(t)))
		smiley:get_transform():get_rotation().x = 0.30 * math.sin(t)
		smiley:get_transform():get_translation().x = smiley_offset * math.sin(t)
		smiley:get_transform():get_translation().z = smiley_offset * math.cos(t)

		-- Should we quit ?
		if psi.video:should_close_window() > 0 then
			quit = true
		end

		-- Translate camera point and render.
		psi.camera.translate_from_input(camera, ctx.frametime)
		psi.renderer:render(scene, ctx, camera)
		psi.video:flip()

		-- Update context variables.
		ctx.frametime = frametimer:end_frame()
		ctx.elapsed_time = frametimer:get_elapsed_time()
		ctx.frametime_mult = (1.0 / 60.0) * ctx.frametime
	until (quit == true)
end

-- Keyevent handler.
function key_events(camera, scene)
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)

	elseif (psi.input:key_pressed(psi.KEYS.KEY_TAB) == 1) then
		psi.renderer:cycle_draw_mode();

	elseif (psi.input:key_pressed(psi.KEYS.KEY_ENTER) == 1) then
		camera:print_position_vectors()
	end
end

-- Load all of our shaders and place them in the psi scope.
function load_shaders()
	psi.shader.shader_dir = path.join(psi.asset_dir, "shaders");
	local phong_textured_paths = {
		{ psi.shader.type.VERTEX, 	"phong_textured.vert", },
		{ psi.shader.type.FRAGMENT, "phong_textured.frag"  }
	}
	psi.shaders.phong_textured = psi.shader.create('phong_textured', phong_textured_paths)

	return true
end

-- Create scene lights.
function create_lights()
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
