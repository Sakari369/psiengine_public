#include "LuaAPI.h"

namespace LuaIntf {
	LUA_USING_SHARED_PTR_TYPE(std::shared_ptr)
	LUA_USING_LIST_TYPE(std::vector)
}

bool LuaAPI::bind_lua() {
	assert(_lua != nullptr);

	psilog(PSILog::LOAD, "Binding Lua -interface");

	LuaIntf::LuaBinding(_lua).beginClass<glm::vec2>("vec2")
		.addConstructor(LUA_ARGS(GLfloat, GLfloat))
		.addVariable("x", &glm::vec2::x, true)
		.addVariable("y", &glm::vec2::y, true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<glm::ivec2>("ivec2")
		.addConstructor(LUA_ARGS(GLfloat, GLfloat))
		.addVariable("x", &glm::ivec2::x, true)
		.addVariable("y", &glm::ivec2::y, true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<glm::vec3>("vec3")
		.addConstructor(LUA_ARGS(GLfloat, GLfloat, GLfloat))
		.addVariable("x", &glm::vec3::x, true)
		.addVariable("y", &glm::vec3::y, true)
		.addVariable("z", &glm::vec3::z, true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<glm::vec4>("vec4")
		.addConstructor(LUA_ARGS(GLfloat, GLfloat, GLfloat, GLfloat))
		.addVariable("x", &glm::vec4::x, true)
		.addVariable("y", &glm::vec4::y, true)
		.addVariable("z", &glm::vec4::z, true)
		.addVariable("w", &glm::vec4::w, true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<glm::vec4>("c_vec4")
		.addConstructor(LUA_ARGS(GLfloat, GLfloat, GLfloat, GLfloat))
		.addVariable("r", &glm::vec4::r, true)
		.addVariable("g", &glm::vec4::g, true)
		.addVariable("b", &glm::vec4::b, true)
		.addVariable("a", &glm::vec4::a, true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<glm::mat4>("mat4")
		.addConstructor(LUA_ARGS(GLfloat))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<ProgramOptions>("ProgramOptions")
		.addConstructor(LUA_ARGS())
		.addVariable("fullscreen", 		&ProgramOptions::fullscreen, 		true)
		.addVariable("vsync", 			&ProgramOptions::vsync, 		true)
		.addVariable("screen_width", 		&ProgramOptions::screen_width, 		true)
		.addVariable("screen_height", 		&ProgramOptions::screen_height,		true)
		.addVariable("msaa_samples", 		&ProgramOptions::msaa_samples, 		true)
		.addVariable("monitor_index", 		&ProgramOptions::monitor_index,		true)
		.addVariable("exit_after_one_frame", 	&ProgramOptions::exit_after_one_frame, 	true)
		.addVariable("main_script_name", 	&ProgramOptions::main_script_name, 	true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLTransform>("PSIGLTransform")
		.addConstructor(LUA_ARGS())
		.addFunction("get_translation",		&PSIGLTransform::get_translation)
		.addFunction("set_translation",		&PSIGLTransform::set_translation,	LUA_ARGS(glm::vec3 &))
		.addFunction("get_scaling",		&PSIGLTransform::get_scaling)
		.addFunction("set_scaling",		&PSIGLTransform::set_scaling,		LUA_ARGS(glm::vec3 &))
		.addFunction("get_rotation",		&PSIGLTransform::get_rotation)
		.addFunction("get_rotation_deg",	&PSIGLTransform::get_rotation_deg)
		.addFunction("set_rotation",		&PSIGLTransform::set_rotation,		LUA_ARGS(glm::vec3 &))
		.addFunction("set_rotation_deg",	&PSIGLTransform::set_rotation_deg,	LUA_ARGS(glm::vec3 &))
		.addFunction("add_rotation_deg",	&PSIGLTransform::add_rotation_deg,	LUA_ARGS(glm::vec3 &))
		.addFunction("get_model",		&PSIGLTransform::get_model)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIScaler>("PSIScaler")
		.addConstructor(LUA_ARGS())
		.addFunction("get_max_scale",		&PSIScaler::get_max_scale)
		.addFunction("set_max_scale",		&PSIScaler::set_max_scale,		LUA_ARGS(GLfloat))
		.addFunction("get_min_scale",		&PSIScaler::get_min_scale)
		.addFunction("set_min_scale",		&PSIScaler::set_min_scale,		LUA_ARGS(GLfloat))
		.addFunction("get_freq",		&PSIScaler::get_freq)
		.addFunction("set_freq",		&PSIScaler::set_freq,			LUA_ARGS(GLfloat))
		.addFunction("get_phase",		&PSIScaler::get_phase)
		.addFunction("set_phase",		&PSIScaler::set_phase,			LUA_ARGS(GLfloat))
		.addFunction("get_half_cycles",		&PSIScaler::get_half_cycles)
		.addFunction("reset_cycles",		&PSIScaler::reset_cycles)
		.addFunction("inv_phase_dir",		&PSIScaler::inv_phase_dir)
		.addFunction("get_phase_dir",		&PSIScaler::get_phase_dir)
		.addFunction("get_cosine_eased_phase",	&PSIScaler::get_cosine_eased_phase)
		.addFunction("inc_phase",		&PSIScaler::inc_phase)
		.addFunction("reset",			&PSIScaler::reset)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSICycler>("PSICycler")
		.addConstructor(LUA_ARGS())
		.addFunction("reset",			&PSICycler::reset)
		.addFunction("completed_half_cycle",	&PSICycler::completed_half_cycle)
		.addFunction("passed_min",		&PSICycler::passed_min)
		.addFunction("passed_max",		&PSICycler::passed_max)
		.addFunction("get_phase",		&PSICycler::get_phase)
		.addFunction("set_phase",		&PSICycler::set_phase,			LUA_ARGS(GLfloat))
		.addFunction("get_max_limit",		&PSICycler::get_max_limit)
		.addFunction("set_max_limit",		&PSICycler::set_max_limit,		LUA_ARGS(GLfloat))
		.addFunction("get_min_limit",		&PSICycler::get_min_limit)
		.addFunction("set_min_limit",		&PSICycler::set_min_limit,		LUA_ARGS(GLfloat))
		.addFunction("get_threshold",		&PSICycler::get_threshold)
		.addFunction("set_threshold",		&PSICycler::set_threshold,		LUA_ARGS(GLfloat))
		.addFunction("get_half_cycles",		&PSICycler::get_half_cycles)
		.addFunction("inv_phase_dir",		&PSICycler::inv_phase_dir)
		.addFunction("get_phase_dir",		&PSICycler::get_phase_dir)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSICamera>("PSICamera")
		.addConstructor(LUA_SP(CameraSharedPtr), LUA_ARGS())
		.addFunction("set_pos",			&PSICamera::set_pos,			LUA_ARGS(const glm::vec3 &))
		.addFunction("get_pos",			&PSICamera::get_pos)
		.addFunction("set_up",			&PSICamera::set_up,				LUA_ARGS(const glm::vec3 &))
		.addFunction("get_up",			&PSICamera::get_up)
		.addFunction("set_front",		&PSICamera::set_front,			LUA_ARGS(const glm::vec3 &))
		.addFunction("get_front",		&PSICamera::get_front)
		.addFunction("set_fov",			&PSICamera::set_fov,			LUA_ARGS(GLfloat))
		.addFunction("get_fov",			&PSICamera::get_fov)

		.addFunction("set_yaw",			&PSICamera::set_yaw,			LUA_ARGS(GLfloat))
		.addFunction("get_yaw",			&PSICamera::get_yaw)

		.addFunction("set_pitch",		&PSICamera::set_pitch,			LUA_ARGS(GLfloat))
		.addFunction("get_pitch",		&PSICamera::get_pitch)

		.addFunction("set_roll",		&PSICamera::set_roll,			LUA_ARGS(GLfloat))
		.addFunction("get_roll",		&PSICamera::get_roll)

		.addFunction("set_far_plane",		&PSICamera::set_far_plane,			LUA_ARGS(GLfloat))
		.addFunction("get_far_plane",		&PSICamera::get_far_plane)

		.addFunction("set_near_plane",		&PSICamera::set_near_plane,			LUA_ARGS(GLfloat))
		.addFunction("get_near_plane",		&PSICamera::get_near_plane)

		.addFunction("set_planes",		&PSICamera::set_planes,			LUA_ARGS(GLfloat, GLfloat))
		.addFunction("set_viewport_aspect_ratio",&PSICamera::set_viewport_aspect_ratio,	LUA_ARGS(GLfloat))
		.addFunction("translate",		&PSICamera::translate,			LUA_ARGS(const glm::vec3 &))
		.addFunction("rotate",			&PSICamera::rotate,				LUA_ARGS(GLfloat, const glm::vec3 &))

		.addFunction("inc_axis_rotation",	&PSICamera::inc_axis_rotation,		LUA_ARGS(const glm::vec3 &))
		.addFunction("set_axis_rotation",	&PSICamera::set_axis_rotation,		LUA_ARGS(const glm::vec3 &))
		.addFunction("get_axis_rotation",	&PSICamera::get_axis_rotation)

		.addFunction("get_yaw",			&PSICamera::get_yaw)
		.addFunction("set_yaw",			&PSICamera::set_yaw,			LUA_ARGS(GLfloat))
		.addFunction("get_pitch",		&PSICamera::get_pitch)
		.addFunction("set_pitch",		&PSICamera::set_pitch,			LUA_ARGS(GLfloat))
		.addFunction("get_roll",		&PSICamera::get_roll)
		.addFunction("set_roll",		&PSICamera::set_roll,			LUA_ARGS(GLfloat))

		.addFunction("calc_front",		&PSICamera::calc_front)
		.addFunction("print_position_vectors",	&PSICamera::print_position_vectors)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIRenderContext>("PSIRenderContext")
		.addConstructor(LUA_ARGS())
		.addVariable("camera_view", 		&PSIRenderContext::camera_view,		true)
		.addVariable("bg_color", 		&PSIRenderContext::bg_color, 		true)
		.addVariable("elapsed_time", 		&PSIRenderContext::elapsed_time, 	true)
		.addVariable("elapsed_frames", 		&PSIRenderContext::elapsed_frames, 	true)
		.addVariable("frametime", 		&PSIRenderContext::frametime, 		true)
		.addVariable("frametime_mult", 		&PSIRenderContext::frametime_mult, 		true)
		.addVariable("opacity", 		&PSIRenderContext::opacity, 		true)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLShader>("PSIGLShader")
		.addConstructor(LUA_SP(ShaderSharedPtr), LUA_ARGS())
		.addFunction("add_from_file",			&PSIGLShader::add_from_file,			LUA_ARGS(PSIGLShader::ShaderType, std::string))
		.addFunction("add_from_string",			&PSIGLShader::add_from_string,			LUA_ARGS(PSIGLShader::ShaderType, std::string))
		.addFunction("compile",				&PSIGLShader::compile)
		.addFunction("create_program",			&PSIGLShader::create_program)
		.addFunction("get_program",			&PSIGLShader::get_program)
		.addFunction("add_uniforms",			&PSIGLShader::add_uniforms)
		.addFunction("add_transform_feedback_varyings",	&PSIGLShader::add_transform_feedback_varyings,	LUA_ARGS(std::vector<std::string>, bool))
		.addFunction("get_name",			&PSIGLShader::get_name)
		.addFunction("set_name",			&PSIGLShader::set_name,				LUA_ARGS(std::string))
		.addFunction("get_info_str",			&PSIGLShader::get_info_str)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLMaterial>("PSIGLMaterial")
		.addConstructor(LUA_SP(GLMaterialSharedPtr), LUA_ARGS())
		.addFunction("set_color",			&PSIGLMaterial::set_color,		LUA_ARGS(glm::vec4))
		.addFunction("get_color",			&PSIGLMaterial::get_color)
		.addFunction("set_opacity",			&PSIGLMaterial::set_opacity,		LUA_ARGS(GLfloat))
		.addFunction("get_opacity",			&PSIGLMaterial::get_opacity)
		.addFunction("set_wireframe",			&PSIGLMaterial::set_wireframe,		LUA_ARGS(bool))
		.addFunction("get_wireframe",			&PSIGLMaterial::get_wireframe)
		.addFunction("set_lit",				&PSIGLMaterial::set_lit,		LUA_ARGS(bool))
		.addFunction("is_lit",				&PSIGLMaterial::is_lit)
		.addFunction("get_textured",			&PSIGLMaterial::get_textured)
		.addFunction("set_textured",			&PSIGLMaterial::set_textured,		LUA_ARGS(bool))
		.addFunction("set_shader",			&PSIGLMaterial::set_shader,		LUA_ARGS(ShaderSharedPtr))
		.addFunction("get_shader",			&PSIGLMaterial::get_shader)
		.addFunction("get_texture", 			&PSIGLMaterial::get_texture)
		.addFunction("set_texture", 			&PSIGLMaterial::set_texture,		LUA_ARGS(GLTextureSharedPtr))
		.addFunction("set_needs_update", 		&PSIGLMaterial::set_needs_update,	LUA_ARGS(bool))
		.addFunction("clone",				&PSIGLMaterial::clone)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIAABB>("PSIAABB")
		.addConstructor(LUA_ARGS())
		.addFunction("contains_point",			&PSIAABB::contains_point,		LUA_ARGS(glm::vec3))
		.addFunction("intersect",			&PSIAABB::intersect,			LUA_ARGS(PSIAABB aabb))
		.addFunction("transform_to_matrix",		&PSIAABB::transform_to_matrix,		LUA_ARGS(const glm::mat4 matrix))
		.addFunction("set_min",				&PSIAABB::set_min,			LUA_ARGS(glm::vec3))
		.addFunction("get_min",				&PSIAABB::get_min)
		.addFunction("set_max",				&PSIAABB::set_max,			LUA_ARGS(glm::vec3))
		.addFunction("get_max",				&PSIAABB::get_max)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIRenderObj>("PSIRenderObj")
		.addConstructor(LUA_ARGS())
		.addFunction("set_geometry",			&PSIRenderObj::set_geometry_data,		LUA_ARGS(GeometryDataSharedPtr))
		.addFunction("get_geometry",			&PSIRenderObj::get_geometry_data)
		.addFunction("set_gl_mesh",			&PSIRenderObj::set_gl_mesh,			LUA_ARGS(GLMeshSharedPtr &))
		.addFunction("get_gl_mesh",			&PSIRenderObj::get_gl_mesh)
		.addFunction("create_gl_mesh",			&PSIRenderObj::create_gl_mesh,			LUA_ARGS(GeometryDataSharedPtr))
		.addFunction("get_transform",			&PSIRenderObj::get_transform)
		.addFunction("set_transform",			&PSIRenderObj::set_transform,			LUA_ARGS(PSIGLTransform))
		.addFunction("get_material",			&PSIRenderObj::get_material)
		.addFunction("set_material",			&PSIRenderObj::set_material,			LUA_ARGS(GLMaterialSharedPtr))
		.addFunction("get_aabb",			&PSIRenderObj::get_aabb)
		.addFunction("add_child",			&PSIRenderObj::add_child,			LUA_ARGS(RenderObjSharedPtr))
		.addFunction("get_child",			&PSIRenderObj::get_child,			LUA_ARGS(GLuint))
		.addFunction("get_children",			&PSIRenderObj::get_children)
		.addFunction("get_child_count",			&PSIRenderObj::get_child_count)
		.addFunction("has_children",			&PSIRenderObj::has_children)
		.addFunction("is_depth_tested",			&PSIRenderObj::is_depth_tested)
		.addFunction("set_depth_tested",		&PSIRenderObj::set_depth_tested,		LUA_ARGS(bool))
		.addFunction("is_translated_by_camera",		&PSIRenderObj::is_translated_by_camera)
		.addFunction("set_translated_by_camera",	&PSIRenderObj::set_translated_by_camera,	LUA_ARGS(bool))
		.addFunction("is_visible",			&PSIRenderObj::is_visible)
		.addFunction("set_visible",			&PSIRenderObj::set_visible,			LUA_ARGS(bool))
		.addFunction("get_sort_index",			&PSIRenderObj::get_sort_index)
		.addFunction("set_sort_index",			&PSIRenderObj::set_sort_index,			LUA_ARGS(GLfloat))
		.addFunction("set_modules",			&PSIRenderObj::set_modules,			LUA_ARGS(GLint))
		.addFunction("get_scene_index",			&PSIRenderObj::get_scene_index)
		.addFunction("set_draw_mode",			&PSIRenderObj::set_draw_mode, 	       		LUA_ARGS(GLuint))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSILight>("PSILight")
		.addConstructor(LUA_SP(LightSharedPtr), LUA_ARGS())
		.addFunction("set_type",			&PSILight::set_type,		LUA_ARGS(PSILight::LightType))
		.addFunction("get_type",			&PSILight::get_type)
		.addFunction("set_color",			&PSILight::set_color,		LUA_ARGS(glm::vec4))
		.addFunction("get_color",			&PSILight::get_color)
		.addFunction("set_intensity",			&PSILight::set_intensity,	LUA_ARGS(GLfloat))
		.addFunction("get_intensity",			&PSILight::get_intensity)
		.addFunction("set_dir",				&PSILight::set_dir,			LUA_ARGS(glm::vec3))
		.addFunction("get_dir",				&PSILight::get_dir)
		.addFunction("set_pos",				&PSILight::set_pos,			LUA_ARGS(glm::vec3))
		.addFunction("get_pos",				&PSILight::get_pos)
		.addConstant("TYPE_DIRECTIONAL",		PSILight::LightType::DIRECTIONAL)
		.addConstant("TYPE_AMBIENT",			PSILight::LightType::AMBIENT)
		.addConstant("TYPE_POINT",			PSILight::LightType::POINT)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGeometryData>("PSIGeometryData")
		.addConstructor(LUA_SP(GeometryDataSharedPtr), LUA_ARGS())
		.addVariable("positions",			&PSIGeometryData::positions,	true)
		.addVariable("texcoords", 			&PSIGeometryData::texcoords,	true)
		.addVariable("normals", 			&PSIGeometryData::normals,	true)
		.addVariable("indexes",				&PSIGeometryData::indexes,	true)
		.addFunction("print_data",			&PSIGeometryData::print_data)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginModule("PSIGeometry")
		.addFunction("cube",				&PSIGeometry::cube)
		.addFunction("cube_inverted",			&PSIGeometry::cube_inverted)
		.addFunction("tetrahedron",			&PSIGeometry::tetrahedron)
		.addFunction("cube_tetrahedron",		&PSIGeometry::cube_tetrahedron)
		.addFunction("cuboid",				&PSIGeometry::cuboid,		LUA_ARGS(GLfloat, GLfloat, GLfloat))
		.addFunction("plane",				&PSIGeometry::plane,		LUA_ARGS(GLint, bool))
		.addFunction("prism",				&PSIGeometry::prism,		LUA_ARGS(GLfloat, GLfloat))
		.addFunction("icosahedron",			&PSIGeometry::icosahedron,	LUA_ARGS(GLint))
		.addFunction("create_poly",			&PSIGeometry::create_poly,	LUA_ARGS(GLint, GLfloat, GLfloat))
	.endModule();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLTexture>("PSIGLTexture")
		.addConstructor(LUA_SP(GLTextureSharedPtr), LUA_ARGS())
		.addFunction("load_cube_map",			&PSIGLTexture::load_cube_map,	LUA_ARGS(std::vector<std::string>))
		.addFunction("load_from_file",			&PSIGLTexture::load_from_file,	LUA_ARGS(std::string))
		.addFunction("set_sample_mode",			&PSIGLTexture::set_sample_mode,	LUA_ARGS(GLint))
		.addFunction("bind",				&PSIGLTexture::bind)
		.addFunction("unbind",				&PSIGLTexture::unbind)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginExtendClass<PSIRenderMesh, PSIRenderObj>("PSIRenderMesh")
		.addConstructor(LUA_SP(RenderMeshSharedPtr), LUA_ARGS())
		.addFunction("init",				&PSIRenderMesh::init)
		.addFunction("clone",				&PSIRenderMesh::clone)
		.addFunction("set_has_normal_matrix",		&PSIRenderMesh::set_has_normal_matrix, LUA_ARGS(bool))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIResourceManager>("PSIResourceManager")
		.addConstructor(LUA_ARGS())
		.addFunction("load_shader",			&PSIResourceManager::load_shader,	LUA_ARGS(std::string, std::string, std::string, LuaIntf::_opt<std::string>))
		.addFunction("get_shader", 			&PSIResourceManager::get_shader,	LUA_ARGS(std::string))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIVideo>("PSIVideo")
		.addConstructor(LUA_ARGS())
		.addFunction("set_window_size",			&PSIVideo::set_window_size,		LUA_ARGS(GLint, GLint))
		.addFunction("set_fullscreen",			&PSIVideo::set_fullscreen,		LUA_ARGS(bool))
		.addFunction("is_fullscreen",			&PSIVideo::is_fullscreen)
		.addFunction("set_cursor_visible",		&PSIVideo::set_cursor_visible,		LUA_ARGS(bool))
		.addFunction("is_cursor_visible",		&PSIVideo::is_cursor_visible)
		.addFunction("set_window_title",		&PSIVideo::set_window_title,		LUA_ARGS(std::string))
		.addFunction("get_viewport_aspect_ratio", 	&PSIVideo::get_viewport_aspect_ratio)
		.addFunction("set_msaa_samples",		&PSIVideo::set_msaa_samples,		LUA_ARGS(GLint))
		.addFunction("get_msaa_samples",		&PSIVideo::get_msaa_samples)
		.addFunction("init",				&PSIVideo::init)
		.addFunction("flip",   				&PSIVideo::flip)
		.addFunction("poll_events",   			&PSIVideo::poll_events)
		.addFunction("should_close_window",		&PSIVideo::should_close_window)
		.addFunction("set_window_should_close",		&PSIVideo::set_window_should_close)
		.addFunction("print_opengl_extensions",		&PSIVideo::print_opengl_extensions)
		.addFunction("get_opengl_version_str",		&PSIVideo::get_opengl_version_str)
		.addFunction("get_window_width",		&PSIVideo::get_window_width)
		.addFunction("get_window_height",		&PSIVideo::get_window_height)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIAudio>("PSIAudio")
		.addConstructor(LUA_ARGS())
		.addFunction("init",				&PSIAudio::init)
		.addFunction("stop",				&PSIAudio::stop)
		.addFunction("play",				&PSIAudio::play)
		.addFunction("set_playing",			&PSIAudio::set_playing,			LUA_ARGS(bool))
		.addFunction("set_loop",			&PSIAudio::set_loop,			LUA_ARGS(bool))
		.addFunction("load_file",			&PSIAudio::load_file,			LUA_ARGS(std::string))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginExtendClass<PSIFontAtlas, PSIRenderObj>("PSIFontAtlas")
		.addConstructor(LUA_SP(FontAtlasSharedPtr), LUA_ARGS())
		.addFunction("init",   				&PSIFontAtlas::init)
		.addFunction("set_size",  			&PSIFontAtlas::set_size,		LUA_ARGS(glm::ivec2))
		.addFunction("get_size",  			&PSIFontAtlas::get_size)
		.addFunction("set_font_size",  			&PSIFontAtlas::set_font_size,		LUA_ARGS(GLuint))
		.addFunction("get_font_size",  			&PSIFontAtlas::get_font_size)
		.addFunction("set_font_color",  		&PSIFontAtlas::set_font_color,		LUA_ARGS(glm::vec4))
		.addFunction("get_font_color",  		&PSIFontAtlas::get_font_color)
		.addFunction("set_font_path",  			&PSIFontAtlas::set_font_path,		LUA_ARGS(std::string))
		.addFunction("get_font_path",  			&PSIFontAtlas::get_font_path)
		.addFunction("set_charset",  			&PSIFontAtlas::set_charset,		LUA_ARGS(std::string))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginExtendClass<PSITextRenderer, PSIRenderObj>("PSITextRenderer")
		.addConstructor(LUA_SP(TextRendererSharedPtr), LUA_ARGS())
		.addFunction("init",   				&PSITextRenderer::init)
		.addFunction("set_text",  			&PSITextRenderer::set_text,		LUA_ARGS(std::string))
		.addFunction("get_text",  			&PSITextRenderer::get_text)
		.addFunction("set_font_atlas", 			&PSITextRenderer::set_font_atlas,	LUA_ARGS(FontAtlasSharedPtr))
		.addFunction("get_font_atlas", 			&PSITextRenderer::get_font_atlas)
		.addFunction("set_draw_offset",			&PSITextRenderer::set_draw_offset,	LUA_ARGS(GLuint))
		.addFunction("set_draw_count",			&PSITextRenderer::set_draw_count,	LUA_ARGS(GLuint))
		.addFunction("draw",   				&PSITextRenderer::draw,			LUA_ARGS(const RenderContextSharedPtr))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLRenderer>("PSIGLRenderer")
		.addConstructor(LUA_ARGS())
		.addFunction("init",   			&PSIGLRenderer::init)
		.addFunction("render",  		&PSIGLRenderer::render,	LUA_ARGS(const RenderSceneSharedPtr &, const RenderContextSharedPtr &, const CameraSharedPtr &))
		.addFunction("get_context",   		&PSIGLRenderer::get_context)
		.addFunction("cycle_draw_mode", 	&PSIGLRenderer::cycle_draw_mode)
		.addFunction("set_msaa_samples",	&PSIGLRenderer::set_msaa_samples,	LUA_ARGS(GLint))
		.addFunction("set_cull_mode",		&PSIGLRenderer::set_cull_mode,		LUA_ARGS(GLint))
		.addFunction("set_sorting",		&PSIGLRenderer::set_sorting,		LUA_ARGS(bool))
		.addFunction("set_wireframe",		&PSIGLRenderer::set_wireframe,		LUA_ARGS(bool))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIRenderScene>("PSIRenderScene")
		.addConstructor(LUA_SP(RenderSceneSharedPtr), LUA_ARGS())
		.addFunction("add",   			&PSIRenderScene::add,			LUA_ARGS(RenderObjSharedPtr))
		.addFunction("remove",   		&PSIRenderScene::remove,		LUA_ARGS(RenderObjSharedPtr))
		.addFunction("reset",   		&PSIRenderScene::reset)
		.addFunction("get_render_objs",   	&PSIRenderScene::get_render_objs)
		.addFunction("add_light",   		&PSIRenderScene::add_light,		LUA_ARGS(LightSharedPtr))
		.addFunction("get_lights",   		&PSIRenderScene::get_lights)
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLMesh>("PSIGLMesh")
		.addConstructor(LUA_SP(GLMeshSharedPtr), LUA_ARGS())
		.addFunction("set_draw_mode",		&PSIGLMesh::set_draw_mode,		LUA_ARGS(GLint))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIGLTFLoader>("PSIGLTFLoader")
		.addConstructor(LUA_SP(GLTFLoaderSharedPtr), LUA_ARGS())
		.addFunction("load_gl_mesh",		&PSIGLTFLoader::load_gl_mesh,		LUA_ARGS(const ShaderSharedPtr &, std::string))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<InputHandler>("InputHandler")
		.addConstructor(LUA_ARGS())
		.addFunction("key_held", 		&InputHandler::key_held,		LUA_ARGS(GLint))
		.addFunction("key_pressed", 		&InputHandler::key_pressed,		LUA_ARGS(GLint))
		.addFunction("get_modifiers", 		&InputHandler::get_modifiers)
		.addFunction("mouse_button_held", 	&InputHandler::mouse_button_held, 	LUA_ARGS(GLint))
		.addFunction("mouse_button_pressed", 	&InputHandler::mouse_button_pressed,	LUA_ARGS(GLint))
		.addFunction("set_movement_speed", 	&InputHandler::set_movement_speed,	LUA_ARGS(GLfloat))
		.addFunction("get_mouse_delta", 	&InputHandler::get_mouse_delta)
		.addFunction("get_key_movement", 	&InputHandler::get_key_movement,	LUA_ARGS(glm::vec3 &, glm::vec3 &, GLfloat))
	.endClass();

	LuaIntf::LuaBinding(_lua).beginClass<PSIFrameTimer>("PSIFrameTimer")
		.addConstructor(LUA_ARGS())
		.addFunction("begin_frame",		&PSIFrameTimer::begin_frame)
		.addFunction("end_frame",		&PSIFrameTimer::end_frame)
		.addFunction("end_frame_fixed",		&PSIFrameTimer::end_frame_fixed, LUA_ARGS(GLfloat))
		.addFunction("get_elapsed_time",	&PSIFrameTimer::get_elapsed_time)
		.addFunction("set_elapsed_frames",	&PSIFrameTimer::set_elapsed_frames, 	LUA_ARGS(GLint))
		.addFunction("get_elapsed_frames",	&PSIFrameTimer::get_elapsed_frames)
		.addFunction("reset",			&PSIFrameTimer::reset)
	.endClass();

	psilog(PSILog::LOAD, "Lua interface bound");

	return true;
}

int LuaAPI::run_main() {
	const char *func_name = "main";
	lua_getglobal(_lua, func_name);

	psilog(PSILog::LUA, "[C++] Calling function '%s'", func_name);
	if (lua_pcall(_lua, 0, 0, 0) != 0) {
		fprintf(stderr, "[C++] Failed calling '%s': %s\n", 
			func_name, lua_tostring(_lua, -1));
		lua_pop(_lua, 1);

		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}

static int append_lua_path( lua_State* L, std::string path) {
	lua_getglobal( L, "package" );
	lua_getfield( L, -1, "path" );

	std::string curr_path = lua_tostring( L, -1 );
	curr_path.append( path );

	lua_pop( L, 1 );
	lua_pushstring( L, curr_path.c_str() );
	lua_setfield( L, -2, "path" );
	lua_pop( L, 1 );

	/*
	lua_getglobal( L, "package" );
	lua_getfield( L, -1, "path" ); // get field "path" from table at top of stack (-1)
	curr_path = lua_tostring( L, -1 ); // grab path string from top of stack
	plog_s("curr_path = %s", curr_path.c_str());
	*/

	return 0; // all done!
}

int LuaAPI::init() {
	assert(_video != nullptr);
	assert(_input != nullptr);
	assert(_options != nullptr);
	assert(_audio != nullptr);

	std::string script_file_name = _options->main_script_name;
	std::string asset_dir = _options->asset_dir;

	assert(!script_file_name.empty());
	assert(!asset_dir.empty());

	// Create our Lua State
	_lua = luaL_newstate();
	luaL_openlibs(_lua);

	// Set our asset dir to load the scripts from
	std::string lua_path = ";" + asset_dir + "/?.lua";
	append_lua_path(_lua, lua_path);

	// Bind classes to it
	bind_lua();

	// Register our global variables to the lua state
	LuaIntf::Lua::setGlobal(_lua, "psi_asset_dir",	asset_dir);
	LuaIntf::Lua::setGlobal(_lua, "psi_video",	_video);
	LuaIntf::Lua::setGlobal(_lua, "psi_input",	_input);
	LuaIntf::Lua::setGlobal(_lua, "psi_options",	_options);
	LuaIntf::Lua::setGlobal(_lua, "psi_audio",	_audio);

	if (_loading_script_from_string == false) {
		std::string script_path = asset_dir + "/scripts/" + script_file_name + ".lua";
		const char *path = script_path.c_str();

		psilog(PSILog::LUA, "[C++] Loading script from '%s'", path);
		if (luaL_loadfile(_lua, path) != 0) {
			fprintf(stderr, "[C++] Loading script '%s' failed: %s\n", 
				path, lua_tostring(_lua, -1));

			return EXIT_FAILURE;
		}

		psilog(PSILog::LUA, "[C++] Loaded script from '%s'", path);
	} else {
		const char *script_contents = _script_str.c_str();
		if (luaL_loadstring(_lua, script_contents) != 0) {
			fprintf(stderr, "[C++] Loading script from string failed: %s\n", lua_tostring(_lua, -1));
			return EXIT_FAILURE;
		}

		psilog(PSILog::LUA, "[C++] Loaded script from string, size = %d characters", _script_str.size());
	}

	psilog(PSILog::LUA, "[C++] Executing script");
	if (lua_pcall(_lua, 0, LUA_MULTRET, 0) != 0) {
		fprintf(stderr, "[C++] Failed executing! %s\n", lua_tostring(_lua, -1));
		lua_pop(_lua, 1);

		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
