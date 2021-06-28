#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec4 a_color;

uniform mat4 u_model_view_projection_matrix;
out vec3 f_texcoord;

void main() {
	f_texcoord = a_position;
	gl_Position = u_model_view_projection_matrix * vec4(a_position, 1.0);
}  
