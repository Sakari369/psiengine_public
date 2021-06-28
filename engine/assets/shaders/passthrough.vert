#version 330 core

layout (location = 0) in vec3 a_position;

uniform mat4 u_model_view_projection_matrix;

out vec4 f_color; 

void main() {
	f_color = a_color;
	gl_Position = u_model_view_projection_matrix * vec4(a_pos, 1.0);
}
