psi.camera = {} 

function psi.camera.create(pos, yaw_pitch_roll, front, fov, aspect_ratio)
	local camera = PSICamera()

	camera:set_pos	(pos)
	camera:set_up	(vec3(0.0, 1.0, 0.0))
	camera:set_front(front)

	camera:set_yaw(yaw_pitch_roll.x)
	camera:set_pitch(yaw_pitch_roll.y)
	camera:set_roll(yaw_pitch_roll.z)

	camera:set_fov(fov)
	camera:set_viewport_aspect_ratio(aspect_ratio)

	return camera
end

function psi.camera.set(camera, pos, yaw_pitch_roll, front)
	camera:set_pos	(pos)
	camera:set_up	(vec3(0.0, 1.0, 0.0))
	camera:set_front(front)

	camera:set_yaw(yaw_pitch_roll.x)
	camera:set_pitch(yaw_pitch_roll.y)
	camera:set_roll(yaw_pitch_roll.z)
end

function psi.camera.center(camera)
	local pos = camera:get_pos()
	pos.x = 0
	pos.y = 0
	camera:set_pos(pos)
end

function psi.camera.translate_from_input(camera, frametime)
	local mouse_delta = psi.input:get_mouse_delta()
	local front = camera:inc_axis_rotation(mouse_delta)
	local translation = psi.input:get_key_movement(front, camera:get_up(), frametime)

	camera:translate(translation)
end
