#version 330 core

layout (location = 0) in vec4 a_position;

out vec4 f_color;

uniform vec4 u_color;
uniform float u_opacity;
uniform mat4 u_model_matrix;
uniform mat4 u_view_matrix;
uniform mat4 u_projection_matrix;

void main() {
	vec3 gamma_corrected = pow(u_color.rgb, vec3(1.0 / 2.2));
	f_color = vec4(gamma_corrected, u_opacity);
	gl_Position = u_projection_matrix * u_view_matrix * u_model_matrix * a_position;
}
