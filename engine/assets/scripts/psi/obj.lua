psi.obj = {}

-- Assign global objects to psi namespace, so can be easily accessed from scripts.
psi.obj.skybox = {}
psi.obj.icosahedron = {}
psi.obj.cube = {}
psi.obj.prism = {}
psi.obj.tetrahedron = {}
psi.obj.cube_tetrahedron = {}
psi.obj.cuboid = {}
psi.obj.plane = {}
psi.obj.axis = {}

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

	-- The cubemap has no sense of being not textured
	-- So, we just disable texture, cubemap class knows how to
	-- render width the texture set above with set_texture()
	--
	-- This is needed so that we don't set the uniform unnecessary
	--material:set_textured(false)
	material:set_lit(false)
	mesh:set_material(material)

	local geometry = PSIGeometry.cube_inverted()
	mesh:set_geometry(geometry)
	mesh:set_depth_tested(false)
	mesh:set_translated_by_camera(false)
	mesh:set_has_normal_matrix(false)
	
	-- Set the z-index to something ridiculous, it doesn't matter
	-- but affects draw sorting order
	mesh:set_sort_index(-1000.0)

	mesh:init()
	
	return mesh
end

function psi.obj.icosahedron.create(recursion, color)
	local material = PSIGLMaterial()
	material:set_shader(psi.shader.shaders.phong)
	material:set_lit(true)
	material:set_color(color)

	local geometry = PSIGeometry.icosahedron(recursion)

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:set_has_normal_matrix(true)
	mesh:init()

	return mesh
end

function psi.obj.cube.create(color)
	local material = PSIGLMaterial()
	material:set_shader(psi.shader.shaders.phong)
	material:set_color(color)

	local geometry = PSIGeometry.cube()

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:init()

	return mesh
end

function psi.obj.prism.create(radius, depth, color)
	local material = PSIGLMaterial()
	material:set_shader(psi.shader.shaders.phong)
	material:set_color(color)

	local geometry = PSIGeometry.prism(radius, depth)

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:init()

	return mesh
end

function psi.obj.cube_tetrahedron.create(color)
	local material = PSIGLMaterial()
	material:set_shader(psi.shader.shaders.phong)
	material:set_lit(true)
	material:set_color(color)

	local geometry = PSIGeometry.cube_tetrahedron()

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:init()

	return mesh
end

function psi.obj.tetrahedron.create(color)
	local material = PSIGLMaterial()
	material:set_shader(psi.shader.shaders.phong)
	material:set_lit(true)
	material:set_color(color)

	local geometry = PSIGeometry.tetrahedron()

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:init()

	return mesh
end

function psi.obj.cuboid.create(color, width, height, depth)
	local material = PSIGLMaterial()
	material:set_shader(psi.shader.shaders.phong)
	material:set_color(color)

	local geometry = PSIGeometry.cuboid(width, height, depth)

	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	mesh:set_geometry(geometry)
	mesh:init()

	return mesh
end

function psi.obj.axis.create(size)
	local line_width = 0.010

	local xline = psi.obj.cuboid.create(vec4(0.8, 0.0, 0.0, 1.0), size, line_width, line_width)
	local yline = psi.obj.cuboid.create(vec4(0.0, 0.8, 0.0, 1.0), line_width, size, line_width)
	local zline = psi.obj.cuboid.create(vec4(0.0, 0.0, 0.8, 1.0), line_width, line_width, size)

	xline:add_child(yline)
	xline:add_child(zline)

	return xline
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
