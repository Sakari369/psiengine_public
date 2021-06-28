require("scripts.psi.obj")

Target = {}
Target.__index = Target
Target.STATE_IDLE = 0
Target.STATE_DISAPPEARING = 1
Target.STATE_DESTROY = 2
Target.STATE_DELETED = 3
Target.DESTROY_DIST = 100.0

setmetatable(Target, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function Target.new()
	local self = setmetatable({}, Target)
	self:init_values()
	return self
end

function Target:get_class_name()
	return "Target"
end

function Target:init_values()
	self.pos = vec3(0.0, 0.0, 0.0)
	self.size = vec3(0.45, 0.45, 0.45)
	self.color = vec4(0.9, 0.9, 0.9, 1.0)
	self.state = Target.STATE_IDLE
end

function Target:on_collision(collide_obj)
	--psi.printf("%s on collision with %s\n", self:get_class_name(), collide_obj.get_class_name())
	self.state = Target.STATE_DISAPPEARING
end

function Target:init(shader)
	local mesh = psi.obj.icosahedron.create(0, self.color)
	mesh:get_transform():set_scaling(self.size)
	self.mesh = mesh
	self.mesh:get_transform():set_translation(self.pos)
	self.material = mesh:get_material()
end

function Target:get_mesh()
	return self.mesh
end

function Target:set_pos(pos)
	self.pos = vec3(pos.x, pos.y, pos.z)
	self.mesh:get_transform():set_translation(self.pos)
end

function Target:get_pos()
	return self.pos
end

function Target:get_size()
	return self.size
end

function Target:set_size(size)
	self.size = size
end

function Target:respawn()
	--psi.printf("%s respawning!\n", self:get_class_name())
	self:init_values()
	self:set_pos(self.pos)
end

function Target:state_idle(ctx)
	local rot_trans = self.mesh:get_transform():get_rotation()
	rot_trans.y = rot_trans.y + -0.09 * ctx.frametime_mult

	if (rot_trans.y > 2*math.pi) then
		rot_trans.y = 0
	end
end

function Target:is_deleted()
	return self.state == Target.STATE_DELETED
end

function Target:state_disappearing(ctx)
	if (self.material:get_wireframe() == 0) then
		self.material:set_wireframe(1)
	end

	local pos = self:get_pos()
	pos.z = pos.z + 0.1 * ctx.frametime_mult

	if pos.z > Target.DESTROY_DIST then
		self.state = Target.STATE_DESTROY
	else
		self:set_pos(pos)
	end
end

function Target:logic(ctx)
	if self.state == Target.STATE_HIDDEN or self.state == Target.STATE_DELETED then
		-- Do nothing when hidden or deleted
	elseif self.state == Target.STATE_IDLE then
		-- Idle anim
		self:state_idle(ctx)
	elseif self.state == Target.STATE_DISAPPEARING then
		-- Idle and disappear
		self:state_idle(ctx)
		self:state_disappearing(ctx)
	elseif self.state == Target.STATE_DESTROY then
		self.mesh:set_visible(false)
		self.state = Target.STATE_DELETED
	end
end
