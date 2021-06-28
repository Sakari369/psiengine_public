#version 330 core

uniform mat4 u_mvp_mat;
uniform mat4 u_model_mat;
uniform mat3 u_normal_mat;

// Position of our ocular view in world space
uniform vec3 u_ocular_view_pos;
uniform vec4 u_color;

in vec3 a_pos;
in vec3 a_normal;

out vec3 f_color; 
out vec3 f_normal; 
out vec3 f_frag_pos;

void main() {
	// Output color to fragment shader
	f_color = vec3(u_color);

	// Need to multiply with the normal matrix
	f_normal = a_normal * u_normal_mat;

	f_frag_pos = vec3(u_model_mat * vec4(a_pos, 1.0));

	// Output vertex position
	gl_Position = u_mvp_mat * vec4(a_pos, 1.0);
}
