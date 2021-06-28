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

-- Import our local game scripts.
require("scripts.game.player")
require("scripts.game.ball")
require("scripts.game.area")
require("scripts.game.target")

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

-- Global class references.
local _paused = false
local _fixed_frametime = (1.0/60.0) * 1000.0

function create_targets()
	-- Create a grid of targets.
	-- Starting from top left corner, and going to bottom right.
	local count = 144
	local cols = 24
	local targets_on_row = 0
	local origin = vec3(1.0, 3.35, 0.0)

	local pos = vec3(0.0, 0.0, 0.0)
	pos.x = origin.x
	pos.y = origin.y
	pos.z = origin.z

	local targets = {}
	for i=1, count do
		local target = Target()
		target:init(psi.shaders.phong)

		local target_size = target:get_size()
		target:set_pos(pos)

		pos.x = pos.x + target_size.x * 3

		targets_on_row = targets_on_row + 1
		if (targets_on_row >= cols) then
			targets_on_row = 0
			pos.x = origin.x
			pos.y = pos.y - target_size.y * 3
		end

		targets[#targets + 1] = target
	end

	return targets
end

local _camera_pos = vec3(27.383385, 0.228406, 17.690498)
local _camera_yaw_pitch_roll = vec3(-120.35, 1.7, 0)
local _camera_front = vec3(-0.505060, 0.029666, -0.862574)

local _load_skybox = true

-- our main loop
function main()
	local quit = false

	if load_shaders() == false then
		os.exit(2)
	end

	psi.video:set_cursor_visible(false)

	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:set_cull_mode(psi.render.culling.NONE)
	psi.renderer:init()

	psi.input:set_movement_speed(0.5)
	psi.internal_status("Game test", script_version)

	-- Our view into the world
	local camera = psi.camera.create(_camera_pos, _camera_yaw_pitch_roll, _camera_front, 
					90.0, psi.video:get_viewport_aspect_ratio())

	-- Our scene
	local scene = PSIRenderScene()

	-- Lightning
	psi.lights.directional, psi.lights.ambient = get_lights()
	scene:add_light(psi.lights.directional)
	scene:add_light(psi.lights.ambient)

	-- Skybox loading
	if (_load_skybox == true) then
		local texture_paths = {
			path.join(psi.asset_dir, "textures/skybox/stars/blue"),
			"starsLF.png",
			"starsRT.png",
			"starsUP.png",
			"starsDN.png",
			"starsBK.png",
			"starsFT.png",
		}
		local skybox = psi.obj.skybox.create(psi.shaders.cubemap, texture_paths)
		scene:add(skybox)
	end

	-- Text rendering
	local hud_atlas = psi.fonts.create_atlas(path.join(psi.asset_dir, "fonts/AppleGothic.ttf"),
						  96, 4096, vec4(1.0, 1.0, 1.0, 1.0))

	local hud_mat = PSIGLMaterial()
	hud_mat:set_shader(psi.shaders.text)
	hud_mat:set_color(vec4(1.0, 1.0, 1.0, 1.0))

	local hud_text = PSITextRenderer()
	hud_text:set_material(hud_mat)
	hud_text:set_font_atlas(hud_atlas)
	hud_text:set_text("Score : 0")
	hud_text:init()

	hud_text:get_transform():set_translation(vec3(4.5, 6.5, 0.0))

	scene:add(hud_text)

	local p1 = Player()
	p1:init(psi.shaders.phong_textured)
	scene:add(p1:get_mesh())

	local ball = Ball()
	ball:init(psi.shaders.phong_textured)
	scene:add(ball:get_mesh())

	local area = Area()
	area:init(psi.shaders.phong_textured)
	scene:add(area:get_mesh())

	local targets = create_targets()
	for i=1, #targets do
		scene:add(targets[i]:get_mesh())
	end

	local frametimer = PSIFrameTimer()
	local ctx = psi.renderer:get_context()

	ctx.bg_color = vec4(0.10, 0.10, 0.10, 1.0)

	repeat
		frametimer:begin_frame()

		psi.video:poll_events()
		psi.keyb.key_events()
		key_events(camera, scene)

		-- --> begin frame
		if _paused == false then
			-- events
			handle_player_input(p1)

			-- game logic
			ball:logic(ctx)
			p1  :logic(ctx)

			p1:collides_with(ball)

			local update_score = false

			for i=1, #targets do
				local target = targets[i]
				target:logic(ctx)

				if ball:collides_with(target) == true then
					-- Add to player score
					local score = p1:add_score(3)
					update_score = true
				end
			end

			-- Update the text
			if update_score then
				hud_text:set_text("Score : " .. p1:get_score())
			end
		end

		-- translate camera point and render
		psi.camera.translate_from_input(camera, _fixed_frametime)
		psi.renderer:render(scene, ctx, camera)

		if psi.video:should_close_window() > 0 
		or (psi.options.exit_after_one_frame == 1 and frames > 1) then
			quit = true
		end

		psi.video:flip()

		-- --> end frame
		if _paused == false then
			frametimer:end_frame()
			ctx.elapsed_time = frametimer:get_elapsed_time()
			-- We run logic with a fixed frametime in this case.
			ctx.frametime = _fixed_frametime
			ctx.frametime_mult = (1.0 / 60.0) * _fixed_frametime
		end
	until (quit == true)
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

function handle_player_input(player)
	local dy = 0.15
	local dir = 0

	if (psi.input:key_held(psi.KEYS.KEY_UP) == 1) then
		dir = 1
	elseif (psi.input:key_held(psi.KEYS.KEY_DOWN) == 1) then
		dir = -1
	end

	if dir ~= 0 then
		local pos = player:get_target_pos()
		pos.y = pos.y + (dy * dir)
		player:set_target_pos(pos)
		player:reset_speed()
	end
end

-- Load all of our shaders and place them in the psi scope.
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

	local text_paths = {
		{ psi.shader.type.VERTEX, 	"text.vert", },
		{ psi.shader.type.FRAGMENT, 	"text.frag"  }
	}
	psi.shaders.text = psi.shader.create('text', text_paths)

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

