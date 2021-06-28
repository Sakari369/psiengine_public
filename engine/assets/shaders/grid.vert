#version 330 core

// Uniforms
uniform mat4 u_mvp_mat;
uniform mat3 u_normal_mat;

// TODO: this should probably be an attribute
uniform vec4 u_color;

// Attributes
in vec3 a_pos;
in vec3 a_normal;

// Outputs to the fragment shader
out vec4 f_color; 
out vec3 f_normal;

void main() {
	// Output vertex position
	gl_Position = u_mvp_mat * vec4(a_pos, 1.0);

	f_normal = normalize(u_normal_mat * a_normal);

	// Output color to fragment shader
	f_color = u_color;
}
