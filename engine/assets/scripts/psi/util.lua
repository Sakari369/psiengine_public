function psi.print_vec3(name, vec)
	io.write(string.format("%s = %.3f %.3f %.3f\n", name, vec.x, vec.y, vec.z));
end

function psi.print_float(name, val)
	io.write(string.format("%s = %.8f\n", name, val))
end

function psi.printf(s, ...)
	return io.write(s:format(...))
end

function psi.internal_status(name, version_str)
	psi.printf("[loading] Running script '%s' version %s\n", name, version_str)

	psi.printf("[video] %s\n", psi.video:get_opengl_version_str())
	psi.printf("[video] %d MSAA samples\n", psi.video:get_msaa_samples())
	psi.printf("[video] viewport: %d x %d px\n", psi.video:get_window_width(), psi.video:get_window_height())

	if (psi.video:is_fullscreen()) then
		psi.printf("[video] running in fullscreen\n") 
	end
end
