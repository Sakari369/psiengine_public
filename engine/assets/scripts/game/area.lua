require("scripts.psi.shader")
require("scripts.psi.texture")

Area = {}
Area.__index = Area

setmetatable(Area, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function Area.new()
	local self = setmetatable({}, Area)

	self.pos = vec3(12.0, 0.0, 0.0)
	self.score = 0

	return self
end

function Area:init(shader)
	local mesh = PSIRenderMesh()

	local texture = PSIGLTexture()
	texture:load_from_file(path.join(psi.asset_dir, "textures/scifi_512x512.jpg"))
	texture:bind()
	texture:set_sample_mode(psi.texture.sampleMode.REPEAT)
	texture:unbind()
	self.texture = texture

	local material = PSIGLMaterial()
	material:set_shader(shader)
	material:set_color(vec4(0.5, 0.5, 0.5, 1.0))
	material:set_texture(texture)
	self.material = material

	-- Backside wall
	local mesh = PSIRenderMesh()
	mesh:set_material(material)
	local geom = PSIGeometry.cuboid(10.0, 10.0, 8.0)	
	mesh:set_geometry(geom)
	mesh:get_transform():set_scaling(vec3(1.0, 1.0, 1.0))
	mesh:get_transform():set_translation(vec3(40.0, 0.0, 0.0))
	mesh:init()

	self.mesh = mesh

	geom = PSIGeometry.cube()
	self.geometry = geom

	-- Top wall
	local mesh_top = PSIRenderMesh()
	mesh_top:set_material(material)
	mesh_top:set_geometry(geom)
	mesh_top:get_transform():set_scaling(vec3(26.0, 1.0, 1.0))
	mesh_top:get_transform():set_translation(vec3(16.5, -4.5, 0.0))
	mesh_top:init()

	self.mesh:add_child(mesh_top)

	-- Bottom wall
	local mesh_bottom = PSIRenderMesh()
	mesh_bottom:set_material(material)
	mesh_bottom:set_geometry(geom)
	mesh_bottom:get_transform():set_scaling(vec3(26.0, 1.0, 1.0))
	mesh_bottom:get_transform():set_translation(vec3(16.5, 4.5, 0.0))
	mesh_bottom:init()
	self.mesh:add_child(mesh_bottom)

	-- Next two planks
	local plank_material = PSIGLMaterial()
	plank_material:set_shader(shader)
	plank_material:set_color(vec4(0.6, 0.9, 0.8, 1.0))
	plank_material:set_texture(texture)
	self.plank_material = plank_material

	local mesh_plank_top = PSIRenderMesh()
	mesh_plank_top:set_material(plank_material)
	mesh_plank_top:set_geometry(geom)
	mesh_plank_top:get_transform():set_scaling(vec3(12.0, 1.0, 1.0))
	mesh_plank_top:get_transform():set_translation(vec3(-6.3, 4.5, 0.0))
	mesh_plank_top:init()

	self.mesh:add_child(mesh_plank_top)
	self.mesh_plank_top = mesh_plank_top

	local mesh_plank_bottom = PSIRenderMesh()
	mesh_plank_bottom:set_material(plank_material)
	mesh_plank_bottom:set_geometry(geom)
	mesh_plank_bottom:get_transform():set_scaling(vec3(12.0, 1.0, 1.0))
	mesh_plank_bottom:get_transform():set_translation(vec3(-6.3, -4.5, 0.0))
	mesh_plank_bottom:init()

	self.mesh:add_child(mesh_plank_bottom)
	self.mesh_plank_bottom = mesh_plank_bottom
end

function Area:do_logic(frametime)
end

function Area:get_mesh()
	return self.mesh
end

function Area:set_pos(pos)
	self.pos = pos
end

function Area:get_pos()
	return self.pos
end
