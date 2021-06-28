#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec4 a_color;
layout (location = 3) in vec3 a_normal;

uniform mat4 u_model_view_projection_matrix;
uniform mat3 u_normal_matrix;

// Common uniform variables for all shaders
uniform sampler2D u_diffuse;
uniform float u_elapsed_time;

out vec4 f_color; 
out vec3 f_normal;
out vec2 f_texcoord;

void main() {
	f_color = a_color;
	f_normal = a_normal;

	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}
