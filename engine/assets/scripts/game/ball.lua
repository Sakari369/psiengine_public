require("scripts.psi.obj")

Ball = {}

Ball.MIN_VELOCITY = 0.01
Ball.MAX_VELOCITY = 0.3
Ball.VELOCITY_ACCEL_TIME = 3

Ball.__index = Ball

setmetatable(Ball, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function Ball.new()
	local self = setmetatable({}, Ball)
	self:init_values()

	self.scaler = PSIScaler()

	-- What values do we want for our scaler ?
	-- This is for scaling the velocity for the ball
	self.scaler:set_max_scale(Ball.MAX_VELOCITY)
	self.scaler:set_min_scale(Ball.MIN_VELOCITY)

	-- The time it takes for the scaler to go from min to max ..
	-- frequency is 1 / s
	-- We are using half cycles for acceleration, so multiply time by 2
	local scale_freq = 1.0 / (Ball.VELOCITY_ACCEL_TIME * 2.0)
	--psi.printf("scale_freq = %f\n", scale_freq)
	self.scaler:set_freq(scale_freq)

	return self
end

function Ball:get_class_name()
	return "Ball"
end

function Ball:init_values()
	self.pos = vec3(-9.0, 2.0, 0.0)
	self.velocity = vec3(0.3, 0.3, 0)
	self.dir = vec3(1.0, 1.0, 0.0)
	self.area = vec3(32.0, 3.55, 0.0)
	self.size = vec3(0.4, 0.4, 0.4)
	self.color = vec4(0.2, 0.8, 0.2, 1.0)
	self.outside_dead_zone = true
	self.accelerating = true
end

function Ball:on_collision(collide_obj)
	--psi.printf("%s on collision with %s\n", self:get_class_name(), collide_obj.get_class_name())
	
	-- We should immediately change our x direction
	self.dir.x = -1.0 * self.dir.x
end

function Ball:init(shader)
	local mesh = psi.obj.icosahedron.create(2, self.color)
	mesh:get_transform():set_scaling(self.size)
	self.mesh = mesh

	local texture = PSIGLTexture()
	texture:load_from_file(path.join(psi.asset_dir, "textures/blue_plasma_512x512.jpg"))

	local material = PSIGLMaterial()
	material:set_shader(shader)
	material:set_color(self.color)
	material:set_texture(texture)
	material:set_opacity(1.0)

	mesh:set_material(material)
	self.material = material

	self.mesh:get_transform():set_translation(self.pos)
end

function Ball:get_mesh()
	return self.mesh
end

function Ball:set_pos(pos)
	self.pos = pos
	self.mesh:get_transform():set_translation(pos)
end

function Ball:get_pos()
	return self.pos
end

function Ball:get_size()
	return self.size
end

function Ball:set_size(size)
	self.size = size
end

function Ball:respawn()
	self:init_values()
	self:set_pos(self.pos)
end

function Ball:collides_with(obj)
	local collides = false
	local p_max = vec3(self.pos.x + self.size.x/2.0,
			   self.pos.y + self.size.y/2.0,
			   self.pos.z + self.size.z/2.0)

	local p_min = vec3(self.pos.x - self.size.x/2.0,
			   self.pos.y - self.size.y/2.0,
			   self.pos.z - self.size.z/2.0)

	-- We must check if object comes within the range of p_min .. p_max
	-- If the obj is inside that range, then it is colliding with the player
	local obj_size = obj:get_size()
	local obj_pos = obj:get_pos()

	local obj_max = vec3(obj_pos.x + obj_size.x/2.0,
			     obj_pos.y + obj_size.y/2.0,
			     obj_pos.z + obj_size.z/2.0)

	local obj_min = vec3(obj_pos.x - obj_size.x/2.0,
			     obj_pos.y - obj_size.y/2.0,
			     obj_pos.z - obj_size.z/2.0)

	--[[
	psi.print_vec3("p_max", p_max)
	psi.print_vec3("p_min", p_min)
	psi.print_vec3("obj_max", obj_max)
	psi.print_vec3("obj_min", obj_min)
	--]]

	if obj_min.x < p_max.x and obj_min.y < p_max.y and
	   obj_max.x > p_min.x and obj_max.y > p_min.y then
	   	obj:on_collision(self)
		collides = true
	end

	return collides
end

function Ball:logic(ctx)
	-- Check for collision
	local min = vec3(-12.0, -3.0, 0.0)
	local max = vec3( 0.1, 3.0, 0.0)

	-- So, we are accelerating the velocity of the ball
	-- should adjust the velocity from the scaler
	if self.accelerating == true then
		self.scaler:inc_phase(ctx.frametime)
		local vel_cycles = self.scaler:get_half_cycles()
		local phase = self.scaler:get_cosine_eased_phase()
		local velocity = vec2(phase, phase)
		self.velocity = velocity

		if vel_cycles >= 1 then
			self.accelerating = false
			self.velocity = vec2(Ball.MAX_VELOCITY, Ball.MAX_VELOCITY)
		end
	end

	-- Do movement logic
	-- x
	if self.outside_dead_zone == true then
		self.pos.x = self.pos.x + (ctx.frametime_mult * self.velocity.x * self.dir.x)
		if self.pos.x >= self.area.x then
			self.dir.x = -1.0 * self.dir.x
		elseif self.pos.x <= -(self.area.x + 5.0) then
			self.outside_dead_zone = false
		end

		-- y
		self.pos.y = self.pos.y + (ctx.frametime_mult * self.velocity.y * self.dir.y)
		if self.pos.y >= self.area.y or self.pos.y <= -self.area.y then
			self.dir.y = -1.0 * self.dir.y
		end
	else
		self.pos.x = self.pos.x + (ctx.frametime_mult * self.velocity.x * self.dir.x)
		self.pos.y = self.pos.y + (ctx.frametime_mult * self.velocity.y * self.dir.y)

		if self.pos.y < -6.0 or self.pos.y > 6.0 then
			self:respawn()
		end
	end

	--psi.printf("self.pos.x = %f self.pos.y = %f\n", self.pos.x, self.pos.y)
	if self.outside_dead_zone == true and self.pos.x <= min.x then
		--psi.printf("going to dead zone\n")
		self.outside_dead_zone = false
	end

	-- Update mesh translation
	self.mesh:get_transform():set_translation(self.pos)
end
