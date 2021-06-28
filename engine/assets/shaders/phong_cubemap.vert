#version 330 core

uniform mat4 u_model_view_projection_matrix;
uniform mat3 u_normal_matrix;

// Material block
uniform vec3 u_color;
uniform float u_opacity;
uniform bool u_material_override;
uniform bool u_isTextured;

in vec3 a_pos;
in vec3 a_normal;
in vec2 a_texcoord;

out vec3 f_normal;
out vec4 f_color; 
out vec3 f_texcoord;

void main() {
	// TODO: get this from the attributes
	vec3 color = vec3(1.0, 1.0, 1.0);

	f_color = vec4(color, u_opacity);
	f_normal = a_normal;
	f_texcoord = a_pos;

	gl_Position = u_model_view_projection_matrix * vec4(a_pos, 1.0);
}
