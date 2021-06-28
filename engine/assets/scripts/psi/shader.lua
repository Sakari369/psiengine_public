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

function psi.shader.add(shader, shader_type, shader_path)
	if (path.exists(shader_path)) then
		if shader:add_from_file(shader_type, shader_path) == false then
			return false
		end
	else
		psi.printf("[loading] Shader file '%s' does not exist or is not readable!\n", shader_path)
	end
end

function psi.shader.create(name, paths)
	local shader = PSIGLShader()
	shader:set_name(name)
	shader:create_program()

	local path_one = path.join(psi.shader.shader_dir, paths[1][2])
	local path_two = path.join(psi.shader.shader_dir, paths[2][2])
	local type_one = paths[1][1]
	local type_two = paths[2][1]

	-- Load two shaders by default
	if (psi.shader.add(shader, type_one, path_one) == false) then
		psi.printf("[loading] Failed loading shader '%s'\n", name)
	end

	if (psi.shader.add(shader, type_two, path_two) == false) then
		psi.printf("[loading] Failed loading shader '%s'\n", name)
	end

	if (shader:compile() == psi.shader.type.INVALID) then
		psi.printf("[loading] Failed compiling shader '%s'\n", name)
		return false
	end

	shader:add_uniforms()

	--psi.printf("[loading] Loaded shader '%s' (%s, %s)\n", name, paths[1][2], paths[2][2]);

	return shader
end

function psi.shader.create_geometry(name, paths)
	local shader = PSIGLShader()
	shader:set_name(name)
	shader:create_program()

	local path_one = path.join(psi.shader.shader_dir, paths[1][2])
	local path_two = path.join(psi.shader.shader_dir, paths[2][2])
	local path_three = path.join(psi.shader.shader_dir, paths[3][2])
	local type_one = paths[1][1]
	local type_two = paths[2][1]
	local type_three = paths[3][1]

	-- Load two shaders by default
	if (psi.shader.add(shader, type_one, path_one) == false) then
		psi.printf("[loading] Failed loading shader '%s'\n", name)
	end

	if (psi.shader.add(shader, type_two, path_two) == false) then
		psi.printf("[loading] Failed loading shader '%s'\n", name)
	end

	if (psi.shader.add(shader, type_three, path_three) == false) then
		psi.printf("[loading] Failed loading shader '%s'\n", name)
	end

	if (shader:compile() == psi.shader.type.INVALID) then
		psi.printf("[loading] Failed compiling shader '%s'\n", name)
		return false
	end

	shader:add_uniforms()

	--psi.printf("[loading] Loaded shader '%s' (%s, %s)\n", name, paths[1][2], paths[2][2]);

	return shader
end

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

	--psi.printf("[loading] Loaded shader '%s' (%s, %s)\n", name, paths[1][2], paths[2][2]);

	return shader
end
