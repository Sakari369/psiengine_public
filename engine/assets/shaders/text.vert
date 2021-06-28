#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 2) in vec2 a_texcoord;

uniform sampler2D u_diffuse;
uniform mat4 u_model_view_projection_matrix;
uniform vec4 u_color;

out vec4 f_color;
out vec2 f_texcoord;
out float f_gamma;

void main() {
	f_gamma = 1.0;
	f_color = u_color;
	f_texcoord = a_texcoord;

	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}
