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
