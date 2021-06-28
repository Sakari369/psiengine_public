require("scripts.psi.shader")

Player = {}

-- What is this pos ?
Player.CEILING_LOW = -2.38
Player.CEILING_HIGH = 2.38
Player.DEF_SPEED = 0.33
Player.DEF_SPEED_MULT = 0.993
Player.__index = Player

setmetatable(Player, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})

function Player.new()
	local self = setmetatable({}, Player)
	self:init_values()
	return self
end

function Player:get_class_name()
	return "Player"
end

function Player:init_values()
	self.pos = vec3(-12.0, 0.0, 0.0)
	self.target_pos = vec3(0.0, 0.0, 0.0)
	self.score = 0
	self.color = vec4(0.8, 0.8, 1.0, 1.0)
	self.size = vec3(0.300, 1.618*2, 2.00)
	self.translation = vec3(-8.0, 0.0, 0.0)
	self:reset_speed()
end

function Player:reset_speed()
	self.speed = Player.DEF_SPEED
	self.speed_mult = Player.DEF_SPEED_MULT
	self.speed_mult_cycle_completed = false
end

function Player:set_pos(pos)
	self.pos = vec3(pos.x, pos.y, pos.z)
	self.target_pos = vec3(pos.x, pos.y, pos.z)

	self.mesh:get_transform():set_translation(self.pos)
end

function Player:add_score(score)
	self.score = self.score + score
	return self.score
end

function Player:get_score()
	return self.score
end

function Player:collides_with(obj)
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

	-- Now we have the minimum and maximums for the bounding boxes for
	-- both objects, we can check for collision
	-- 
	--  -min.x |min.y
	--       \.___/.
	--        |    |    
	--        |    |    
	--        |    |  
	--        |    | ,o.
	--        |    | o:o < --- obj, width = 3, height = 3
	--        |    | 'o'       min.x .. max.x
	--        |    |           min.y .. max.y
	--        |    |           collides if 
	--        |    |	        obj_min.x < p_max.x
	--        |    |           &&   obj_min.y < p.max.y
	--        /----\
	--    max.y  max.x
	--
	if obj_min.x < p_max.x and obj_min.y < p_max.y and
	   obj_max.x > p_min.x and obj_max.y > p_min.y then
	   	obj:on_collision(self)
		collides = true
	end

	return collides
end

function Player:init(shader)
	local mesh = PSIRenderMesh()

	local texture = PSIGLTexture()
	texture:load_from_file(path.join(psi.asset_dir, "textures/scifi_512x512.jpg"))

	local material = PSIGLMaterial()
	material:set_shader(shader)
	material:set_color(self.color)
	material:set_texture(texture)
	mesh:set_material(material)

	local geom = PSIGeometry.cube()
	mesh:set_geometry(geom)
	mesh:get_transform():set_scaling(self.size)
	mesh:get_transform():set_translation(self.translation)
	mesh:init()

	self.mesh = mesh
	self.material = material
	self.texture = texture

	self.mesh:get_transform():set_translation(self.pos)
	self.mesh:get_transform():get_translation().y = self.pos.y
end

function Player:get_mesh()
	return self.mesh
end

function Player:set_target_pos(target_pos)
	self.target_pos = target_pos
	self:limit_pos(self.target_pos)
end

function Player:limit_pos(pos)
	if (pos.y < Player.CEILING_LOW) then
		pos.y = Player.CEILING_LOW
	elseif (pos.y > Player.CEILING_HIGH) then
		pos.y = Player.CEILING_HIGH
	end
end

function Player:get_target_pos()
	return self.target_pos
end

function Player:logic(ctx)
	if self.speed_mult_cycle_completed == false then
		self.speed_mult = self.speed_mult - 0.005 * math.abs(0.5 * math.cos(ctx.elapsed_time/4))

		if (self.speed_mult < 0) then
			self.speed_mult = 0
			self.speed_mult_cycle_completed = true
		end
	end

	--psi.printf("Doing player logic, frametime = %f\n", frametime)
	if (self.pos.y + 0.01) < self.target_pos.y or (self.pos.y - 0.01) > self.target_pos.y then
		--psi.printf("Going towards target %f, now at %f\n", self.target_pos.y, self.pos.y)
		local dir
		if self.pos.y <= self.target_pos.y then
			dir = 1.0
		else 
			dir = -1.0
		end

		self.speed = self.speed * self.speed_mult
		if self.speed == 0 then
			self.speed = 0.001
		end

		self.pos.y = self.pos.y + (ctx.frametime_mult * self.speed * dir)
		self:limit_pos(self.pos)

		-- Translate towards the target position
		self.mesh:get_transform():get_translation().y = self.pos.y
	end
end

function Player:get_pos()
	return self.pos
end
