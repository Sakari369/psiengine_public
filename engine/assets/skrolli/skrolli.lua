-- Sources for the Skrollightenment intro that was released for Skrolli Party 2017.
-- Uses an older version of PSIEngine so does not work with this codebase.
-- Here for preservation purposes. Contains all the scripts required to run the demo.
-- combined in one file. 
--
-- Copyright (c) 2017, 2021 Sakari Lehtonen

require("math")
require("os")
require("table")

psi = {}
path = {}
psi.video = {}

function psi.video.set(video)
	psi.video = video
end

--- is this an absolute path?.
-- @param P A file path
function path.isabs(P)
	return string.sub(P,1,1) == '/'
end

-- !constant sep is the directory separator for this platform.
path.sep = package.config:sub(1, 1)

--- return the path resulting from combining the individual paths.
-- if the second path is absolute, we return that path.
-- @param p1 A file path
-- @param p2 A file path
-- @param ... more file paths
function path.join(p1,p2,...)
	if select('#',...) > 0 then
		local p = path.join(p1,p2)
		local args = {...}
		for i = 1,#args do
			p = path.join(p,args[i])
		end
		return p
	end

	if path.isabs(p2) then return p2 end

	local endc = string.sub(p1,#p1,#p1)
	if endc ~= path.sep and endc ~= other_sep then
		p1 = p1..path.sep
	end

	return p1..p2
end

psi.renderer = {}

psi.version = "Version 0.500"
psi.copyright = "Copyright (C) 2017 Sakari Lehtonen <sakari@psitriangle.net>"

psi.math = {}
psi.math.phi = ((1 + 2.23606797749979) / 2)

function psi.printf(s, ...)
	return io.write(s:format(...))
end

function psi.internal_status(name, version_str)
	psi.printf("[loading] script '%s' version %s\n", name, version_str)

	psi.printf("[video] %s\n", psi.video:get_opengl_version_str())
	psi.printf("[video] %d MSAA samples\n", psi.video:get_msaa_samples())
	psi.printf("[video] viewport: %d x %d px\n", psi.video:get_window_width(), psi.video:get_window_height())

	if (psi.video:get_fullscreen() > 0) then
		psi.printf("[video] running in fullscreen\n") 
	end

	psi.printf("[done] Initialized successfully !\n")
end

psi.KEYS = {
   RELEASE               =  0,
   PRESS                 =  1,
   KEY_SPACE             = 32,
   KEY_APOSTROPHE        = 39,
   KEY_COMMA             = 44,
   KEY_MINUS             = 45,
   KEY_PERIOD            = 46,
   KEY_SLASH             = 47,
   KEY_0                 = 48,
   KEY_1                 = 49,
   KEY_2                 = 50,
   KEY_3                 = 51,
   KEY_4                 = 52,
   KEY_5                 = 53,
   KEY_6                 = 54,
   KEY_7                 = 55,
   KEY_8                 = 56,
   KEY_9                 = 57,
   KEY_SEMICOLON         = 59,
   KEY_EQUAL             = 61,
   KEY_A                 = 65,
   KEY_B                 = 66,
   KEY_C                 = 67,
   KEY_D                 = 68,
   KEY_E                 = 69,
   KEY_F                 = 70,
   KEY_G                 = 71,
   KEY_H                 = 72,
   KEY_I                 = 73,
   KEY_J                 = 74,
   KEY_K                 = 75,
   KEY_L                 = 76,
   KEY_M                 = 77,
   KEY_N                 = 78,
   KEY_O                 = 79,
   KEY_P                 = 80,
   KEY_Q                 = 81,
   KEY_R                 = 82,
   KEY_S                 = 83,
   KEY_T                 = 84,
   KEY_U                 = 85,
   KEY_V                 = 86,
   KEY_W                 = 87,
   KEY_X                 = 88,
   KEY_Y                 = 89,
   KEY_Z                 = 90,
   KEY_LEFT_BRACKET      = 91,
   KEY_BACKSLASH         = 92,
   KEY_RIGHT_BRACKET     = 93,
   KEY_GRAVE_ACCENT      = 96,
   KEY_WORLD_1           = 161,
   KEY_WORLD_2           = 162,
   KEY_ESCAPE            = 256,
   KEY_ENTER             = 257,
   KEY_TAB               = 258,
   KEY_BACKSPACE         = 259,
   KEY_INSERT            = 260,
   KEY_DELETE            = 261,
   KEY_RIGHT             = 262,
   KEY_LEFT              = 263,
   KEY_DOWN              = 264,
   KEY_UP                = 265,
   KEY_PAGE_UP           = 266,
   KEY_PAGE_DOWN         = 267,
   KEY_HOME              = 268,
   KEY_END               = 269,
   KEY_CAPS_LOCK         = 280,
   KEY_SCROLL_LOCK       = 281,
   KEY_NUM_LOCK          = 282,
   KEY_PRINT_SCREEN      = 283,
   KEY_PAUSE             = 284,
   KEY_F1                = 290,
   KEY_F2                = 291,
   KEY_F3                = 292,
   KEY_F4                = 293,
   KEY_F5                = 294,
   KEY_F6                = 295,
   KEY_F7                = 296,
   KEY_F8                = 297,
   KEY_F9                = 298,
   KEY_F10               = 299,
   KEY_F11               = 300,
   KEY_F12               = 301,
   KEY_F13               = 302,
   KEY_F14               = 303,
   KEY_F15               = 304,
   KEY_F16               = 305,
   KEY_F17               = 306,
   KEY_F18               = 307,
   KEY_F19               = 308,
   KEY_F20               = 309,
   KEY_F21               = 310,
   KEY_F22               = 311,
   KEY_F23               = 312,
   KEY_F24               = 313,
   KEY_F25               = 314,
   KEY_KP_0              = 320,
   KEY_KP_1              = 321,
   KEY_KP_2              = 322,
   KEY_KP_3              = 323,
   KEY_KP_4              = 324,
   KEY_KP_5              = 325,
   KEY_KP_6              = 326,
   KEY_KP_7              = 327,
   KEY_KP_8              = 328,
   KEY_KP_9              = 329,
   KEY_KP_DECIMAL        = 330,
   KEY_KP_DIVIDE         = 331,
   KEY_KP_MULTIPLY       = 332,
   KEY_KP_SUBTRACT       = 333,
   KEY_KP_ADD            = 334,
   KEY_KP_ENTER          = 335,
   KEY_KP_EQUAL          = 336,
   KEY_LEFT_SHIFT        = 340,
   KEY_LEFT_CONTROL      = 341,
   KEY_LEFT_ALT          = 342,
   KEY_LEFT_SUPER        = 343,
   KEY_RIGHT_SHIFT       = 344,
   KEY_RIGHT_CONTROL     = 345,
   KEY_RIGHT_ALT         = 346,
   KEY_RIGHT_SUPER       = 347,
   KEY_MENU              = 348,
   KEY_LAST              = KEY_MENU
}

psi.MODS = {
   MOD_SHIFT             = 0x1,
   MOD_CONTROL           = 0x2,
   MOD_ALT               = 0x4,
   MOD_SUPER             = 0x8
}

psi.JOYSTICK = {
   JOYSTICK_1            = 0,
   JOYSTICK_2            = 1,
   JOYSTICK_3            = 2,
   JOYSTICK_4            = 3,
   JOYSTICK_5            = 4,
   JOYSTICK_6            = 5,
   JOYSTICK_7            = 6,
   JOYSTICK_8            = 7,
   JOYSTICK_9            = 8,
   JOYSTICK_10           = 9,
   JOYSTICK_11           = 10,
   JOYSTICK_12           = 11,
   JOYSTICK_13           = 12,
   JOYSTICK_14           = 13,
   JOYSTICK_15           = 14,
   JOYSTICK_16           = 15,
   JOYSTICK_LAST         = JOYSTICK_16,
}

psi.MOUSE = {
   MOUSE_BUTTON_1        = 0,
   MOUSE_BUTTON_2        = 1,
   MOUSE_BUTTON_3        = 2,
   MOUSE_BUTTON_4        = 3,
   MOUSE_BUTTON_5        = 4,
   MOUSE_BUTTON_6        = 5,
   MOUSE_BUTTON_7        = 6,
   MOUSE_BUTTON_8        = 7,
   MOUSE_BUTTON_LAST     = MOUSE_BUTTON_8,
   MOUSE_BUTTON_LEFT     = MOUSE_BUTTON_1,
   MOUSE_BUTTON_RIGHT    = MOUSE_BUTTON_2,
   MOUSE_BUTTON_MIDDLE   = MOUSE_BUTTON_3,
}

psi.color = {}

function psi.color.rgba_to_hsv(rgba)
	local r = rgba.x;
	local g = rgba.y;
	local b = rgba.z;

	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v
	v = max

	local d = max - min
	if max == 0 then s = 0 else s = d / max end

	if max == min then
		h = 0 -- achromatic
	else
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return vec3(h, s, v)
end

function psi.color.hsv_to_rgba(hsv)
	local h = hsv.x
	local s = hsv.y
	local v = hsv.z
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return vec4(r, g, b, 1.0)
end

psi.render = {}

psi.render.culling = { 
	NONE = 0,
	FRONT = 1,
	BACK = 2
} 

psi.shader = {}

-- List of global shaders used
-- Used to pass shaders to all the modules
psi.shaders = {}

-- compatibility
psi.shader.shaders = psi.shaders

-- default shader dir
psi.shader.shader_dir = "assets/shaders"

-- Store global lights
psi.lights = {}

psi.shader.type = {
	INVALID = -1,
	VERTEX = 0,
	GEOMETRY = 1,
	FRAGMENT = 2
}

function psi.shader.create_from_strings(name, strings)
	local shader = PSIGLShader()
	shader:set_name(name)
	shader:create_program()

	-- Load two shaders by default
	if shader:add_from_string(strings[1][1], strings[1][2]) == false then
		return false
	end

	if shader:add_from_string(strings[2][1], strings[2][2]) == false then
		return false
	end

	if (shader:compile() == psi.shader.type.INVALID) then
		psi.printf("[loading] Failed compiling shader '%s'\n", name)
		return false
	end

	shader:add_uniforms()

	return shader
end

psi.obj = {}
psi.obj.ocular = {}
psi.obj.skybox = {}
psi.obj.poly = {}
psi.obj.plane = {}

function psi.obj.ocular.create(pos, yaw, pitch, fov, aspect_ratio)
	local ocular = PSIOcularView()
	ocular:set_pos  (pos)
	ocular:set_up	(vec3(0.0, 1.0, 0.0))

	ocular:set_yaw(yaw)
	ocular:set_pitch(pitch)
	ocular:calc_front()

	ocular:set_fov(fov)
	ocular:set_viewport_aspect_ratio(aspect_ratio)

	return ocular
end

function psi.obj.skybox.create(shader, texture_paths)
	local mesh = PSIRenderMesh()

	local texture = PSIGLTexture()

	local base_dir = texture_paths[1]
	local tex_paths = {
		path.join(base_dir, texture_paths[2]),
		path.join(base_dir, texture_paths[3]),
		path.join(base_dir, texture_paths[4]),
		path.join(base_dir, texture_paths[5]),
		path.join(base_dir, texture_paths[6]),
		path.join(base_dir, texture_paths[7])
	}

	texture:load_cube_map(tex_paths)

	local material = PSIGLMaterial()
	material:set_shader(shader)
	material:set_texture(texture)

	material:set_lit(false)
	mesh:set_material(material)

	local geometry = PSIGeometry.cube_inverted()
	mesh:set_geometry(geometry)
	mesh:set_depth_tested(false)
	mesh:set_translated_by_ocular(false)
	mesh:set_has_normal_matrix(false)
	
	mesh:set_sort_index(-1000.0)

	mesh:init()
	
	return mesh
end

function psi.obj.plane.create(shader, color, rows, repeat_texture)
	local material = PSIGLMaterial()
	material:set_shader(shader)
	material:set_color(color)

	local geometry = PSIGeometry.plane(rows, repeat_texture)

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:init()

	return mesh
end

-- helper to create poly
function psi.obj.poly.create(recursion_depth, num_points, radius, child_radius_ratio, line_color, line_width)
	local cfg = PolyConfig()
	cfg.recursion_depth = recursion_depth
	cfg.radius = radius
	cfg.num_points = num_points
	cfg.line_color = line_color
	cfg.line_width = line_width
	cfg.draw_base = 1.0
	cfg.point_radius = 0.05
	cfg.draw_points = 0.0
	cfg.draw_lines = 1.0
	cfg.child_num_points_ratio = 1
	cfg.child_radius_ratio = child_radius_ratio

	local line_material = PSIGLMaterial()
	line_material:set_shader(psi.shaders.poly)
	line_material:set_color(line_color)
	line_material:set_wireframe(false)
	line_material:set_opacity(1.0)

	local point_material = PSIGLMaterial()
	point_material:set_shader(psi.shaders.point)
	point_material:set_color(line_color)
	point_material:set_wireframe(false)
	point_material:set_opacity(1.0)

	local poly = Poly()
	poly:set_config(cfg)
	poly:set_feedback_shader(psi.shaders.feedback)
	poly:set_line_material(line_material)
	poly:set_point_material(point_material)
	poly:init()

	return poly
end

psi.poly_container = {}

-- Keep our polys here
local polys = {}

function psi.poly_container.add(poly)
	polys[#polys + 1] = poly
end

function psi.poly_container.get_poly(index)
	return polys[index]
end

function psi.poly_container.get_polys()
	return polys
end

function psi.poly_container.get_poly_count()
	return #polys
end

-- internal script version
local script_version = "1.0 release"

-- class references
local _input	 = geometrify_input
local _video	 = geometrify_video
local _audio	 = geometrify_audio
local _options	 = geometrify_options
local _asset_dir = geometrify_asset_dir

local _quit = false

local _resources = PSIResourceManager()
local _renderer = PSIGLRenderer()

local _animate = false
local _paused = false

local _frametime = (1.0/60.0) * 1000.0

-- Keyboard control
local _speeds = { 0.0025, 0.005, 0.01, 0.02, 0.03, 0.05, 0.07, 0.10, 0.15, 0.20, 0.30, 0.50, 0.70, 1.0, 2.0 }
local _active_speed = 11 
local _speed = _speeds[_active_speed]
_input:set_movement_speed(_speed)

local _run_scene = true
local _load_textures = true
local _audio_playback = true
local _seek_audio = true

local _audio_seek_pos

local _start_index = 1

if (_start_index == 1) then
	_seek_audio = false
elseif (_start_index == 9) then
	_audio_seek_pos = math.floor(58.065952 * 1000.0)
elseif (_start_index == 13) then
	_audio_seek_pos = math.floor(85.019394 * 1000.0)
elseif (_start_index == 19) then
	_audio_seek_pos = 153173
elseif (_start_index == 21) then
	_audio_seek_pos = 170000
end

local _state_timer

local _text_atlas
local _text
local _fade_text
local _end_text_cycle_count = 0

local _text_hsv = vec3(1.0, 1.0, 1.0)

local _geometry_start_depth = 100.0
local _geometry_slow_depth = _geometry_start_depth - 0.333

local _objs = {}

local _ocular_scaler
local _last_poly_depth = 0

local _oc_speed = 0.02
local _oc_axis = vec3(0.0, 0.0, 1.0)
local _oc_target = vec3(0.092563, -2.038455, -3.048009)
local _oc_target_rot = vec3(0.0, 0.0, 0.0)
local _oc_rot_axis = vec3(0.0, 0.0, 0.0)
local _oc_trans = vec3(1.0, 1.0, 1.0)

-- This functions sets up the scene
-- Beginning camera position, objects, etc 
function setup_scene(scene, ocular, ctx, index)
	local pos
	local rot

	-- First scene:
	-- We have the buddha showing and we zoom slowly to show that we have a buddha
	if index == 1 then
		pos = vec3(0.092563, -2.755527, -2.078926)
		rot = vec3(-90, 36.5, 0.0)
		
		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.005
		_oc_axis = vec3(0.0, 0.1, -1.0)
		_oc_target = vec3(0.092563, -2.420551, -5.428957)

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	elseif index == 2 then
		pos = vec3(0.042803, 3.399600, -6.798569)
		rot = vec3(-91.85, -8.60001, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.0040
		_oc_axis = vec3(0.0, -1.0, 1.0)
		_oc_target = vec3(0.042803, 0.722106, -4.121008)

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	elseif index == 3 then
		pos = vec3(0.114864, 0.988136, -13.303073)
		rot = vec3(-269.8, 19.3, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.016
		_oc_axis = vec3(0.0, 0.488, 0.288)
		_oc_rot_axis = vec3(0.0, 0.3, 0.0)
		_oc_target = vec3(-0.033486, 6.402674, -11.507290)
		_oc_target_rot = vec3(-271.3, -52, 0)

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	-- zoom into magazine
	elseif index == 4 then
		pos = vec3(0.114864, 9.046052, -8.547458)
		rot = vec3(-269.8, -52.0298, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.05
		_oc_axis = vec3(0.0, -0.396, 0.400)
		_oc_rot_axis = vec3(0.0, 0.4, 0.0)

		_oc_target = vec3(0.124051, 1.079425, -1.188522)
		_oc_target_rot = vec3(-269.85, -79.0602, 0)

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	-- magazine in view, increase lighting
	elseif index == 5 then
		-- no setup, we are just increasing the lights
	-- increase lighting
	elseif index == 6 then
	-- magazine effect 1
	elseif index == 7 then
	-- zoom through magazine
	elseif index == 8 then
		_oc_speed = 0.180
		_oc_axis = vec3(0.0, -0.7, 0.4)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	-- geometry zoom in
	elseif index == 9 then
		reset_lighting()

		pos = vec3(0.0, 0.0, 0.0)
		rot = vec3(90, 0.0, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.280
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_target = vec3(0.0, 0.0, 10.0)

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		scene:remove(_objs.buddha)
		scene:remove(_objs.plane)

		create_polys(scene, 1, _geometry_start_depth)

		_ocular_scaler:set_min_scale(0.0)
		_ocular_scaler:set_max_scale(1.0)
		_ocular_scaler:set_freq(0.05)
	-- geometry slow zoom
	elseif index == 10 then
		pos = vec3(0.0, 0.0, _geometry_slow_depth)
		rot = vec3(90, 0.0, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.012
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_target = vec3(0.0, 0.0, 10.0)

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	elseif index == 11 then
		create_polys(scene, 2, _geometry_start_depth)
	elseif index == 12 then
		create_polys(scene, 3, 135.320000/2.0)
	-- six formation
	elseif index == 13 then
		pos = vec3(0.000000, 0.000000, 116.768478)
		rot = vec3(90, 0.0, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_speed = 0.020
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 4, 160.320000/2.0)
	-- six stage 2
	elseif index == 14 then
		_oc_speed = 0.018
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 5, 195.320000/2.0)
	elseif index == 15 then
		_oc_speed = 0.010
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 6, 220.320000/2.0)
	elseif index == 16 then
		_oc_speed = 0.008
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 7, 260.00/2.0)
	elseif index == 17 then
		_oc_speed = 0.006
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 8, 280.00/2.0)
	elseif index == 18 then
		_oc_speed = 0.005
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 9, 300.00/2.0)
	elseif index == 19 then
		_oc_speed = 0.004
		_oc_axis = vec3(0.0, 0.0, 1.0)

		pos = vec3(0.000000, 0.000000, 157.041931)
		rot = vec3(90, 0.0, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed

		create_polys(scene, 10, 300.00/2.0)
	-- end geometry
	elseif index == 20 then
		_oc_speed = 0.030
		_oc_axis = vec3(0.0, 0.0, 1.0)
		_oc_trans.x = _oc_axis.x * _oc_speed
		_oc_trans.y = _oc_axis.y * _oc_speed
		_oc_trans.z = _oc_axis.z * _oc_speed
	-- credits sakari
	elseif index == 21 then
		-- hack: jump to far away distance to hide the polys
		pos = vec3(0.000000, 0.000000, 600.000)
		rot = vec3(90, 0.0, 0)

		ocular:set_pos(pos)
		ocular:set_axis_rotation(rot)
		ocular:calc_front()

		scene:add(_text)
		scene:add(_fade_text)

		_text_vis = false

		reset_text_anim()

		local text_trans = vec3(12.0, 0.0, 8.0)
		local text_rotation = vec3(0.0, 180.0, 0.0)

		_text:get_transform():set_translation(text_trans)
		_text:get_transform():set_rotation_deg(text_rotation)
		_fade_text:get_transform():set_translation(text_trans)
		_fade_text:get_transform():set_rotation_deg(text_rotation)
	-- credits imre
	elseif index == 22 then
		reset_text_anim()

		_active_text_str = "throat singing: imre peemot"
		_text:set_text(_active_text_str)
		_fade_text:set_text(_active_text_str)
		_fade_text:get_material():set_color(vec4(1.0/(255.0/196), 1.0/(255.0/72.0), 1.0/(255.0/30.0), 1.0))

		local text_trans = vec3(13.0, 0.0, 8.0)
		_text:get_transform():set_translation(text_trans)
		_fade_text:get_transform():set_translation(text_trans)
	elseif index == 23 then
		reset_text_anim()

		_active_text_str = "Powered by PsiTriangle Engine"
		_text:set_text(_active_text_str)
		_fade_text:set_text(_active_text_str)

		_fade_text:get_material():set_color(psi.color.hsv_to_rgba(_text_hsv))

		local text_trans = vec3(15.0, 0.0, 8.0)
		_text:get_transform():set_translation(text_trans)
		_fade_text:get_transform():set_translation(text_trans)
	elseif index == 24 then
		reset_text_anim()

		_active_text_str = "http://PsiTriangle.NET"
		_text:set_text(_active_text_str)
		_fade_text:set_text(_active_text_str)

		_fade_text:get_material():set_color(psi.color.hsv_to_rgba(_text_hsv))

		local text_trans = vec3(12.0, 0.0, 8.0)
		_text:get_transform():set_translation(text_trans)
		_fade_text:get_transform():set_translation(text_trans)
	elseif index == 25 then
		reset_text_anim()

		_active_text_str = "read skrolli, get enlightened"
		_text:set_text(_active_text_str)
		_fade_text:set_text(_active_text_str)
		_fade_text:get_material():set_color(vec4(1.0/(255.0/233), 1.0/(255.0/141.0), 1.0/(255.0/50.0), 1.0))

		local text_trans = vec3(15.0, 0.0, 8.0)
		_text:get_transform():set_translation(text_trans)
		_fade_text:get_transform():set_translation(text_trans)
	end
end

-- This function runs the scene
-- Contains the conditions that end the scene
function run_scene(scene, ocular, ctx, index)
	-- How do we know if we have reached the target ?
	local pos = ocular:get_pos()

	ocular:calc_front()

	if index == 1 then
		-- advance the camera py _oc_speed
		ocular:translate(_oc_trans)

		if (ctx.elapsed_time > 12.00) then
			return true
		end
		-- 25 sec
	elseif index == 2 then
		ocular:translate(_oc_trans)

		if (ctx.elapsed_time > 25.00 - 12.00) then
			return true
		end
		-- 33.3
	elseif index == 3 then
		if (ctx.elapsed_time < 30.20 - (25.00 - 12.00)) then
			ocular:translate(_oc_trans)

			local pitch = ocular:get_pitch()
			local pitch_delta = 0.07

			if pitch >= _oc_target_rot.y then
				pitch = pitch - pitch_delta
				ocular:set_pitch(pitch)
			end
		else
			return true
		end
	-- zoom into magazine
	elseif index == 4 then
		ocular:translate(_oc_trans)
		-- Increase axis rotation
		-- We only need the pitch though
		local pitch = ocular:get_pitch()
		local pitch_delta = 0.08

		if pitch >= _oc_target_rot.y then
			pitch = pitch - pitch_delta
			ocular:set_pitch(pitch)
		end

		if (pos.y <= _oc_target.y and pos.z >= _oc_target.z and pitch <= _oc_target_rot.y) then
			return true
		end
	-- increase lighting
	elseif index == 5 then
		local amb = psi.lights.ambient:get_intensity()
		if (amb < 0.9) then
			psi.lights.ambient:set_intensity(amb + 0.0025)
		else
			return true
		end
	elseif index == 6 then
		_objs.plane:set_modules(1)
		return true
	-- shatter magazine
	elseif index == 7 then
		if (_state_timer:get_elapsed_time() > 5.0) then
			return true
		end
	-- zoom in magazine
	elseif index == 8 then
		ocular:translate(_oc_trans)
		if (pos.z > 5.482547) then
			return true
		end
	-- geometry zoom in fast
	elseif index == 9 then
		-- apply sinusoidal zoom in here
		_ocular_scaler:inc_phase(ctx.frametime)
		local phase = _ocular_scaler:get_cosine_eased_phase()
		_oc_trans.z = math.abs(0.600 - _ocular_scaler:get_cosine_eased_phase())
		ocular:translate(_oc_trans)

		if (ocular:get_pos().z > _geometry_slow_depth) then
			return true
		end
	-- geometry zoom in slow
	elseif index == 10 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 69.80) then
			return true
		end
	-- geometry zoom part 2 (square)
	elseif index == 11 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 80.885178) then
			return true
		end
	-- geometry zoom part 3
	elseif index == 12 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 85.30) then
			return true
		end
	-- geometry zoom part 4 (end of square)
	elseif index == 13 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 94.40) then
			return true
		end
	elseif index == 14 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 101.3) then
			return true
		end
	elseif index == 15 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 117.0) then
			return true
		end
	elseif index == 16 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 129.0) then
			return true
		end
	elseif index == 17 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 138.0) then
			return true
		end
	elseif index == 18 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 153.0) then
			return true
		end
	elseif index == 19 then
		ocular:translate(_oc_trans)
		if (_audio:get_position() > 1000 * 165.0) then
			return true
		end
	elseif index == 20 then
		ocular:translate(_oc_trans)

		if (_audio:get_position() > 1000.0 * 170.0) then
			ctx.opacity = ctx.opacity - 0.0023
			if (ctx.opacity <= 0.0) then
				return true
			end
		end
	-- credits sakari
	elseif index == 21 then
		local text_cycle_completed

		if (_audio:get_position() > 1000.0 * 172.0 and _text_vis == false) then
			_text_vis = true
			_text:set_visible(true)
			_fade_text:set_visible(true)
		end

		if (_text_vis == true) then
			if ctx.elapsed_frames % 6 == 0 then
				text_cycle_completed = run_text_anim(false)
				return text_cycle_completed
			end
		end
	-- credits imre
	elseif index == 22 then
		local text_cycle_completed
		if (_text_vis == true) then
			if ctx.elapsed_frames % 5 == 0 then
				text_cycle_completed = run_text_anim(false)
				return text_cycle_completed
			end
		end
	-- powered by
	elseif index == 23 then
		local text_cycle_completed

		if (_text_vis == true) then
			if ctx.elapsed_frames % 6 == 0 then
				text_cycle_completed = run_text_anim(false)

				local color = psi.color.hsv_to_rgba(_text_hsv)
				_text_hsv.x = _text_hsv.x + (1.0 / 18.0)
				_fade_text:get_material():set_color(color)

				return text_cycle_completed
			end
		end
	-- psitriangle.net
	elseif index == 24 then
		local text_cycle_completed

		if (_text_vis == true) then
			if ctx.elapsed_frames % 6 == 0 then
				text_cycle_completed = run_text_anim(false)

				local color = psi.color.hsv_to_rgba(_text_hsv)
				_text_hsv.x = _text_hsv.x + (1.0 / 18.0)
				_fade_text:get_material():set_color(color)

				return text_cycle_completed
			end
		end
	-- read skrolli, get enlightened
	elseif index == 25 then
		local text_cycle_completed

		if (_end_text_cycle_count >= 1) then
			local text_trans = _text:get_transform():get_translation()
			text_trans.z = text_trans.z + 0.02
			_text:get_transform():set_translation(text_trans)
			_fade_text:get_transform():set_translation(text_trans)
		end

		if (_text_vis == true) then
			if ctx.elapsed_frames % 4 == 0 then
				text_cycle_completed = run_text_anim(false)
				if (text_cycle_completed == true) then
					_end_text_cycle_count = _end_text_cycle_count + 1
					if (_end_text_cycle_count > 3) then
						return true
					end

					reset_text_anim()
				end
			end
		end
	end

	return false
end

function reset_lighting()
	psi.lights.ambient:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	psi.lights.ambient:set_intensity(0.5)
	psi.lights.directional:set_color(vec4(1.0, 1.0, 1.0, 1.0))
	psi.lights.directional:set_intensity(0.9)
	psi.lights.directional:set_dir(vec3(-0.8, 0.8, 0.0))
end

function create_lights(scene)
	-- Ambient
	local ambient = PSILight()
	ambient:set_type(PSILight.TYPE_AMBIENT)
	scene:add_light(ambient)
	psi.lights.ambient = ambient

	-- Directional
	local directional = PSILight()
	directional:set_type(PSILight.TYPE_DIRECTIONAL)
	scene:add_light(directional);
	psi.lights.directional = directional
end

function create_gltf_obj(gl_mesh, shader)
	local mesh = PSIRenderMesh()
	mesh:set_gl_mesh(gl_mesh)

	local mat = PSIGLMaterial()
	mat:set_color(vec4(0.0, 0.3, 1.0, 1.0))
	mat:set_shader(shader);
	mesh:set_material(mat)
	mesh:add_default_uniforms()

	return mesh;
end

-- helper to create poly
function create_poly(recursion_depth, num_points, radius, child_radius_ratio, line_color, line_width)
	local cfg = PolyConfig()
	cfg.recursion_depth = recursion_depth
	cfg.radius = radius
	cfg.num_points = num_points
	cfg.line_color = line_color
	cfg.line_width = line_width
	cfg.draw_base = 1.0
	cfg.point_radius = 0.05
	cfg.draw_points = 0.0
	cfg.draw_lines = 1.0
	cfg.child_num_points_ratio = 1
	cfg.child_radius_ratio = child_radius_ratio

	local line_mat = PSIGLMaterial()
	line_mat:set_shader(psi.shaders.poly)
	line_mat:set_color(line_color)
	line_mat:set_wireframe(false)
	line_mat:set_opacity(1.0)

	local poly = Poly()
	poly:set_config(cfg)
	poly:set_feedback_shader(psi.shaders.feedback)
	poly:set_line_material(line_mat)
	poly:init()

	return poly
end

-- What we would like to do .. 
--
-- Create more polys in the depth field
local _last_num_points = 0

function create_polys(scene, set_idx, depth_offset)
	local settings = {
		{ 1, 256, 1, 4, 5.0, 260, 1.333, 0.9, 1.0, 0.6, 1.08, 0.02, 0.6, 1.2 },
		{ 2, 256, 1, 4, 5.0, 260, 1.333, 0.7, 1.0, 0.25, 1.40, 0.01, 0.3, 1.2 },
		{ 3, 256, 1, 4, 5.0, 260, 1.333, 0.9, 1.2, 0.16, 1.60, 0.01, 0.3, 1.2 },
		{ 4, 256, 1, 6, 4.5, 260, 2.200, 0.8, 1.0, 0.0230, 0.42, 0.03, 0.3, 1.2 },
		{ 5, 256, 1, 6, 4.5, 260, 2.200, 0.8, 1.0, 0.03, 0.70, 0.03, 0.3, 1.2 },
		{ 6, 256, 1, 9, 0.65, 110, 1.618, 1.0, 1.618, 0.06, 0.60, 0.0070, 0.26, 0.8 },
		{ 7, 256, 1, 16, 0.5, 130, 2.000, 0.8, 2.666, 0.005, 0.81, 0.02, 0.3, 0.7 },
		{ 8, 256, 1, 16, 0.5, 160, 2.160, 1.618, 3.000, 0.03, 0.70, 0.0160, 0.4, 0.6 },
		{ 9, 256, 1, 23, 0.36, 230, 1.618, 1.618, 4.000, 0.0015, 0.80, 0.033, 0.369, 1.0 },
		{ 10,256, 1, 24, 0.80, 320, 2.000, 1.000, 1.618, 0.0333, 0.127, 0.014, 0.369, 1.0 }
	}

	local set 		 = settings[set_idx]
	local num_polys          = set[2]
	local recursion_depth	 = set[3]
	local num_points	 = set[4]
	local line_width	 = set[5]
	local radius		 = set[6]
	local child_radius_ratio = set[7]
	local scale_min 	 = set[8]
	local scale_max 	 = set[9]
	local scale_freq 	 = set[10]
	local hue 		 = set[11]
	local hue_step 		 = set[12]
	local depth_delta 	 = set[13]
	local depth_ratio 	 = set[14]

	--psi.printf("setting for index = %d\n", set_idx)

	local set_num_points = false
	if (_last_num_points ~= num_points) then
		set_num_points = true
		_last_num_points = num_points
	end

	local polys = {}

	local depth = 0.0

	local saturation = 1.0
	local value = 0.8
	local poly_depth

	for i=1, num_polys do
		hue = hue + hue_step
		local color = psi.color.hsv_to_rgba(vec3(hue, saturation, value))

		local poly
		local created = false

		depth = depth + (depth_ratio * depth_delta)

		if i > psi.poly_container.get_poly_count() then
			poly = create_poly(recursion_depth, num_points, radius, 
					   child_radius_ratio, color, line_width)
			created = true
		else
			poly = psi.poly_container.get_poly(i)
			-- These values are updated on all stages
			poly:set_line_color(color)
		end

		-- Only change these values when changing the number of points
		-- At this point, we would like to re-zoom the polys also ..
		if (set_num_points == true and created == false) then
			poly:reset_animation()

			poly:set_batch_mode(true)
				poly:set_radius(radius)
				poly:set_child_radius_ratio(child_radius_ratio)
				poly:set_line_width(line_width)
				poly:set_num_points(num_points)
			poly:set_batch_mode(false)
			poly:update_feedback_buffers()
		end

		poly_depth = depth_offset + depth
		poly:set_depth(poly_depth)

		if (set_idx == 10) then
			local freq

			if (i%2 == 0) then
				poly:set_scale_min(scale_min)
				poly:set_scale_max(scale_max)
				poly:set_scale_freq(scale_freq/6)
			else
				poly:set_scale_min(scale_min)
				poly:set_scale_max(scale_max)
				poly:set_scale_freq(scale_freq)
			end
		else
			poly:set_scale_min(scale_min - (i * 0.0025))
			poly:set_scale_max(scale_max)
			poly:set_scale_freq(scale_freq + (i * 0.001))
		end
		poly:set_animating(1.0)

		if created == true then
			scene:add(poly)
			psi.poly_container.add(poly)
		end
	end

	_last_poly_depth = poly_depth

	--psi.printf("_last_poly_depth = %f\n", _last_poly_depth)
end

local _head_offset
local _tail_offset
local _draw_length

local _active_text_str

local _text_vis = false

function run_text_anim(cycle)
	local len = string.len(_active_text_str)
	local cycle_completed = false

	if _head_offset < len then
		_head_offset = _head_offset + 1
	end

	if _head_offset > _draw_length then
		_tail_offset = _tail_offset + 1

		if _tail_offset > len then
			if (cycle == true) then
				_head_offset = 0
				_tail_offset = 0
			end

			--psi.printf("cycle completed!\n")
			cycle_completed = true
		end
	end

	local draw_count = _head_offset - _tail_offset

	--psi.printf("_head_offset = %d _tail_offset = %d draw_count = %d\n", _head_offset, _tail_offset, draw_count)

	_fade_text:set_draw_offset(_head_offset)
	_text:set_draw_count(draw_count)
	_text:set_draw_offset(_tail_offset)

	return cycle_completed
end

function load_text()
	local atlas_charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ0123456789!@#$%^_&*/\\()+-=[]{},.;':\""

	-- Text atlas
	_text_atlas = PSIFontAtlas()
	_text_atlas:set_size(ivec2(2048, 2048))
	_text_atlas:set_font_size(230)
	_text_atlas:set_font_color(vec4(1.0, 1.0, 1.0, 1.0))
	_text_atlas:set_font_path(path.join(_asset_dir, "fonts/UnicaOne-Regular.ttf"))
	_text_atlas:set_charset(atlas_charset)
	_text_atlas:init()

	_active_text_str = "code: Deeku / inDigiNeous        "

	-- Normal text
	local text_material = PSIGLMaterial()
	text_material:set_shader(psi.shaders.text)
	text_material:set_color(vec4(1.0, 1.0, 1.0, 1.0))

	_text = PSITextRenderer()
	_text:set_material(text_material)
	_text:set_font_atlas(_text_atlas)
	_text:set_text(_active_text_str)
	_text:set_translated_by_ocular(false)
	_text:set_visible(false)

	-- Fade text
	local fade_material = PSIGLMaterial()
	fade_material:set_shader(psi.shaders.text)
	fade_material:set_color(vec4(0.4, 0.5, 0.8, 1.0))

	_fade_text = PSITextRenderer()
	_fade_text:set_material(fade_material)
	_fade_text:set_font_atlas(_text_atlas)
	_fade_text:set_text(_active_text_str)
	_fade_text:set_translated_by_ocular(false)
	_fade_text:set_visible(false)

	local text_trans = vec3(-19.0, 1.5, -10.0)
	_text:get_transform():set_translation(text_trans)
	_fade_text:get_transform():set_translation(text_trans)

	_text:init()
	_fade_text:init()

	reset_text_anim()
end

function reset_text_anim()
	_head_offset = 0
	_tail_offset = 0
	_draw_length = 23

	_fade_text:set_draw_count(1)
	_fade_text:set_draw_offset(_head_offset)

	_text:set_draw_count(1)
	_text:set_draw_offset(_head_offset)
end

function main()
	setup_video()

	psi.internal_status("Skrollightenment by inDigiNeous & Imre Peemot", script_version)

	if load_shaders() == false then
		os.exit(2)
	end
	
	if (_audio_playback == true) then
		local audio_path = path.join(_asset_dir, "skrolli/Demo_final.flac")
		if (_audio:load_file(audio_path) == false) then
			psi.printf("Failed reading audio file '%s'\n", audio_path)
			_audio_playback = false
		end
	end

	-- our view into the world
	local ocular = psi.obj.ocular.create(vec3(0.092563, -1.387435, -3.927794),
				-90.0, 36.5, 100.0, _video:get_viewport_aspect_ratio())
	local scene = PSIRenderScene()

	-- get rendering context
	local ctx = _renderer:get_context()

	-- set bg color
	ctx.bg_color = vec4(1.0/(255/11), 1.0/(255/35), 1.0/(255/74), 1.0)

	-- state
	_state_timer = PSIFrameTimer()
	local frametime = 1.0/60.0
	local frames = 0

	_ocular_scaler = PSIScaler()

	-- Load text and font
	load_text()

	-- Lighting
	create_lights(scene)
	reset_lighting()

	-- Skybox
	if _load_textures == true then
		local skybox_tex_paths = {
			path.join(_asset_dir, "textures/skybox/stars/blue"),
			"starsLF.png", "starsRT.png", "starsUP.png",
			"starsDN.png", "starsBK.png", "starsFT.png",
		}
		local skybox = psi.obj.skybox.create(psi.shaders.cubemap, skybox_tex_paths)
		_objs.skybox = skybox
		scene:add(skybox)
	end

	-- Buddha
	local gltf_loader = PSIGLTFLoader()
	local buddha_path = path.join(_asset_dir, "skrolli/buddha.gltf")
	local shader = psi.shaders.phong_textured
	local buddha_gl_mesh = gltf_loader:load_gl_mesh(shader, buddha_path)

	local buddha = create_gltf_obj(buddha_gl_mesh, shader)
	local buddha_tex = PSIGLTexture()

	buddha_tex:load_from_file(path.join(_asset_dir, "skrolli/UV_Grid_Sm.jpg"))
	buddha:get_material():set_needs_update(false)
	buddha:get_material():set_texture(buddha_tex)

	local scaling = vec3(0.01, 0.01, 0.01)
	buddha:get_transform():set_scaling(scaling)
	local translation = vec3(5.0, 0.0, -8.0)
	buddha:get_transform():set_translation(translation)

	scene:add(buddha)
	_objs.buddha = buddha

	-- Magazine
	local plane = psi.obj.plane.create(psi.shaders.phong_textured_anim, 
					  vec4(1.0, 1.0, 1.0, 1.0), 80, false)
	local plane_scaling = vec3(10.0, 10.0, 14.0)

	local plane_tex = PSIGLTexture()
	plane_tex:load_from_file(path.join(_asset_dir, "skrolli/kansi.png"))
	plane:get_material():set_needs_update(false)
	plane:get_material():set_texture(plane_tex)

	local plane_trans = vec3(0.0, -4.5, 2.5)
	local plane_rot_deg = vec3(-90.0, 0.0, -180.0)

	plane:get_transform():set_scaling(plane_scaling)
	plane:get_transform():set_translation(plane_trans)
	plane:get_transform():set_rotation_deg(plane_rot_deg)
	scene:add(plane)

	_objs.plane = plane

	local scene_index = _start_index
	setup_scene(scene, ocular, ctx, scene_index)

	if _audio_playback == true then
		_audio:start_playback()

		if (_seek_audio) then
			_audio:seek(_audio_seek_pos)
		end
	end

	repeat
		_state_timer:begin_frame()
		_video:poll_events()

		handle_custom_key_events(ocular, scene)

		if _paused == false then
			-- start time
			local elapsed_time = _state_timer:get_elapsed_time()

			-- update context variables
			ctx.elapsed_time = elapsed_time
			ctx.elapsed_frames = frames
			ctx.frame_mul = (1.0 / 60.0) * _frametime
			ctx.frametime = _frametime

			-- Move the camera forwards until we reach wanted point
			if _run_scene == true then
				if (run_scene(scene, ocular, ctx, scene_index) == true) then
					scene_index = scene_index + 1
					--psi.printf("advancing scene to %d\n", scene_index)

					if (scene_index ~= 8) then
						_state_timer:reset()
					end

					if (scene_index < 26) then
						setup_scene(scene, ocular, ctx, scene_index)
					else
						_quit = true
					end
				end
			end
			
			_renderer:render(scene, ctx, ocular)

			if (_video:should_close_window() > 0) then
				_quit = true
			end

			_video:flip()
			_state_timer:end_frame(frametime)
			frames = frames + 1
		end
	until (_quit == true)
end

function setup_video()
	psi.video = _video

	psi.video:set_cursor_visible(false)
	psi.renderer = _renderer
	psi.renderer:set_msaa_samples(psi.video:get_msaa_samples())
	psi.renderer:set_sorting(true)

	psi.renderer:init()
end

local _shader_str = {}

-- Shaders
_shader_str.cubemap = {}
_shader_str.cubemap.vert = [[
#version 330 core
layout (location = 0) in vec3 a_position;
layout (location = 1) in vec4 a_color;
uniform mat4 u_model_view_projection_matrix;
out vec3 f_texcoord;
void main() {
	f_texcoord = a_position;
	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}  
]]
_shader_str.cubemap.frag = [[
#version 330 core
in vec3 f_texcoord;
layout(location = 0) out vec4 outColor;
uniform samplerCube u_diffuse;
void main() {
    outColor = vec4(texture(u_diffuse, f_texcoord).rgb, 1.0);
}
]]

_shader_str.phong_textured = {}
_shader_str.phong_textured.vert = [[
#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec4 a_color;
layout (location = 2) in vec2 a_texcoord;
layout (location = 3) in vec3 a_normal;

uniform mat4 u_model_view_projection_matrix;
uniform float u_elapsed_time;

out vec4 f_color; 
out vec3 f_normal;
out vec2 f_texcoord;

void main() {
	f_color = vec4(1.0, 1.0, 1.0, 1.0);
	f_normal = a_normal;
	f_texcoord = a_texcoord;
	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}
]]

_shader_str.phong_textured.frag = [[
#version 330 core

struct lightSource {
	vec3 pos;
	vec3 dir;
	vec3 color;
	float intensity;
};

uniform mat3 u_normal_matrix;
uniform lightSource u_ambient;
uniform lightSource u_light;
uniform sampler2D u_diffuse;

in vec4 f_color;
in vec3 f_normal;
in vec2 f_texcoord;

layout(location = 0) out vec4 outColor;

vec3 apply_light(lightSource light, vec4 diffuse, vec3 normal) {
	vec3 ambient = u_ambient.color * u_ambient.intensity;
	float light_diffuse = max(0.0, dot(normal, light.dir));
	vec3 scattered_light = ambient + (light_diffuse * light.color * light.intensity);
	vec3 rgb = min(diffuse.rgb * scattered_light, vec3(1.0));
	return rgb;
}

void main() {
	vec4 diffuse = texture(u_diffuse, f_texcoord);
	vec3 normal = normalize(u_normal_matrix * f_normal);
	vec3 rgb = apply_light(u_light, diffuse, normal);
	outColor = vec4(rgb, f_color.a);
}
]]

_shader_str.phong_textured_anim = {}
_shader_str.phong_textured_anim.vert = [[
#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 2) in vec2 a_texcoord;
layout (location = 3) in vec3 a_normal;

uniform mat4 u_model_view_projection_matrix;

uniform float u_elapsed_time;

out vec3 f_normal;
out vec2 f_texcoord;

void main() {
	f_normal = a_normal;
	f_texcoord = a_texcoord;
	vec3 f_position = a_position;

	float idx = gl_VertexID / 2560.0;

	if (u_elapsed_time > 0.0) {
		float mult_z = min(0.10 * (1.0 - exp(0.05 * u_elapsed_time)), 0.02);
		f_position.z += mult_z * sin(8 * u_elapsed_time + idx);

		float mult_x = min(0.13 * (1.0 - exp(0.30 * u_elapsed_time)), 0.06);
		f_position.x += mult_x * sin(2.8 * u_elapsed_time + idx);

		float mult_y = min(0.03 * (1.0 - exp(0.30 * u_elapsed_time)), 0.04);
		f_position.y += mult_y * cos(2.8 * u_elapsed_time + idx);
	}

	gl_Position = u_model_view_projection_matrix * vec4(f_position, 1.0);
}
]]
_shader_str.phong_textured_anim.frag = [[
#version 330 core

struct lightSource {
	vec3 pos;
	vec3 dir;
	vec3 color;
	float intensity;
};

uniform mat3 u_normal_matrix;
uniform float u_elapsed_time;
uniform lightSource u_ambient;
uniform lightSource u_light;
uniform sampler2D u_diffuse;

in vec3 f_normal;
in vec2 f_texcoord;

layout(location = 0) out vec4 outColor;

vec3 apply_light(lightSource light, vec4 diffuse, vec3 normal) {
	vec3 ambient = u_ambient.color * u_ambient.intensity;
	float light_diffuse = max(0.0, dot(normal, light.dir));
	vec3 scattered_light = ambient + (light_diffuse * light.color * light.intensity);
	vec3 rgb = min(diffuse.rgb * scattered_light, vec3(1.0));

	return rgb;
}

void main() {
	vec4 diffuse = texture(u_diffuse, f_texcoord);
	vec3 normal = normalize(u_normal_matrix * f_normal);
	vec3 rgb = apply_light(u_light, diffuse, normal);

	outColor = vec4(rgb, 1.0);
}
]]

_shader_str.text = {}
_shader_str.text.vert = [[
#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 2) in vec2 a_texcoord;

uniform sampler2D u_diffuse;
uniform mat4 u_model_view_projection_matrix;
uniform vec4 u_color;

out vec4 f_color;
out vec2 f_texcoord;
out float f_gamma;

void main() {
	f_gamma = 1.0;
	f_color = u_color;
	f_texcoord = a_texcoord;

	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}
]]
_shader_str.text.frag = [[
#version 330 core

uniform sampler2D u_diffuse;

in vec4 f_color;
in vec2 f_texcoord;
in float f_gamma;

layout(location = 0) out vec4 outColor;

void main() {
	float alpha = texture(u_diffuse, f_texcoord).r;
	outColor = f_color * pow(alpha, 1.0/f_gamma);
}
]]

_shader_str.poly = {}
_shader_str.poly.vert = [[
#version 330 core
void main() {
	gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
}
]]
_shader_str.poly.geom = [[
#version 330 core

const float M_PI = 3.1415926;
const float TWO_PI = 6.2831853;

layout(points) in;
layout(triangle_strip, max_vertices = 256) out;

uniform int u_num_points;
uniform float u_radius;
uniform float u_linewidth;

void main() {
	int num_points = u_num_points;
	float radius = u_radius;
	float half_line_width = u_linewidth / 2.0;

	float angle_step = TWO_PI / num_points;
	float angle = 0;

	vec4 origo = gl_in[0].gl_Position;
	vec4 angles = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 point;

	for (int i=0; i<=num_points; i++) {
		angles.x = sin(angle);
		angles.y = cos(angle);
		point = origo + angles * radius;
		vec4 vert_offset = angles * half_line_width;
		gl_Position = (point - vert_offset);
		EmitVertex();
		gl_Position = (point + vert_offset);
		EmitVertex();

		angle = angle + angle_step;
	}

	EndPrimitive();
}
]]

_shader_str.feedback = {}
_shader_str.feedback.vert = [[
#version 330 core

layout (location = 0) in vec4 a_position;

out vec4 f_color;

uniform vec4 u_color;
uniform float u_opacity;
uniform mat4 u_model_matrix;
uniform mat4 u_view_matrix;
uniform mat4 u_projection_matrix;

void main() {
	f_color = vec4(u_color.rgb, u_opacity);
	gl_Position = u_projection_matrix * u_view_matrix * u_model_matrix * a_position;
}
]]
_shader_str.feedback.frag = [[
#version 330 core

layout (location = 0) out vec4 fragColor;

in vec4 f_color;

void main() {
	fragColor = f_color;
}
]]

function load_shaders()
	local retval
	local shader

	-- Phong textured
	local phong_textured_strings = {
		{ psi.shader.type.VERTEX,	_shader_str.phong_textured.vert },
		{ psi.shader.type.FRAGMENT,	_shader_str.phong_textured.frag }
	}

	psi.shaders.phong_textured = psi.shader.create_from_strings('phong_textured', phong_textured_strings)
	if (psi.shaders.phong_textured == false) then
		return false
	end

	local phong_textured_anim_strings = {
		{ psi.shader.type.VERTEX,	_shader_str.phong_textured_anim.vert },
		{ psi.shader.type.FRAGMENT,	_shader_str.phong_textured_anim.frag }
	}
	psi.shaders.phong_textured_anim = psi.shader.create_from_strings('phong_textured_anim', phong_textured_anim_strings)
	if (psi.shaders.phong_textured_anim == false) then
		return false
	end

	local cubemap_strings = {
		{ psi.shader.type.VERTEX, 	_shader_str.cubemap.vert },
		{ psi.shader.type.FRAGMENT, 	_shader_str.cubemap.frag }
	}
	psi.shaders.cubemap = psi.shader.create_from_strings('cubemap', cubemap_strings)
	if (psi.shaders.cubemap == false) then
		return false
	end

	local text_strings = {
		{ psi.shader.type.VERTEX, 	_shader_str.text.vert },
		{ psi.shader.type.FRAGMENT, 	_shader_str.text.frag }
	}
	psi.shaders.text = psi.shader.create_from_strings('text', text_strings)
	if (psi.shaders.text == false) then
		return false
	end

	-- Load the poly shader manually
	psi.shaders.poly = PSIGLShader()
	psi.shaders.poly:set_name("poly")
	psi.shaders.poly:create_program()

	psi.shaders.poly:add_from_string(psi.shader.type.VERTEX, _shader_str.poly.vert)
	psi.shaders.poly:add_from_string(psi.shader.type.GEOMETRY, _shader_str.poly.geom)

	-- Need to capture the variable gl_Position
	-- So that we only render the polyform once, and use the transform feedback shader
	-- to render that geometry, and only re-render with poly shader when the layer changes
	psi.shaders.poly:add_transform_feedback_varyings({ "gl_Position" });
	if (psi.shaders.poly:compile() == psi.shader.type.INVALID) then
		return false
	end

	psi.shaders.poly:add_uniforms()

	-- Transform feedback for poly
	local feedback_strings = {
		{ psi.shader.type.VERTEX,	_shader_str.feedback.vert },
		{ psi.shader.type.FRAGMENT,	_shader_str.feedback.frag }
	}
	psi.shaders.feedback = psi.shader.create_from_strings('feedback', feedback_strings)
	if (psi.shaders.feedback == false) then
		return false
	end

	return true
end

function handle_custom_key_events(ocular, scene)
	if (_input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		_quit = true
	end
end
