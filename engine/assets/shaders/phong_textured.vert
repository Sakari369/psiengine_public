#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 2) in vec2 a_texcoord;
layout (location = 3) in vec3 a_normal;

uniform mat4 u_model_view_projection_matrix;
uniform float u_elapsed_time;

out vec4 f_color; 
out vec3 f_normal;
out vec2 f_texcoord;

void main() {
	f_color = vec4(1.0, 1.0, 1.0, 1.0);
	f_normal = a_normal;
	f_texcoord = a_texcoord;

	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}
