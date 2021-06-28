#version 330 core

uniform mat4 u_model_mat;
uniform vec3 u_ocular_view_pos;

uniform struct Light {
	vec3 ambient;
	vec3 pos;
	vec3 color;
	float specular;
} u_light;

in vec3 f_color;
in vec3 f_normal;
in vec3 f_frag_pos;

layout(location = 0) out vec4 outColor;

// TODO: the diffuse part in this lightning is causing flickering
void main() {
	// Ambient
	vec3 ambient = u_light.ambient * u_light.color;

	// Diffuse
	vec3 norm = normalize(f_normal);
	vec3 light_dir = normalize(u_light.pos - f_frag_pos);

	float diff = max(dot(norm, light_dir), 0.0);
	vec3 diffuse = diff * u_light.color;

	// Specular
	float specular_strength = u_light.specular;

	// View direction related to the fragment position
	vec3 view_dir = normalize(u_ocular_view_pos - f_frag_pos);

	// Reflection direction. Light dir must point away from the fragment.
	vec3 reflect_dir = reflect(-light_dir, norm);
	float spec = pow( max( dot(view_dir, reflect_dir), 0.0), 32);
	vec3 specular = specular_strength * spec * u_light.color;
	
	vec3 result = (ambient + diffuse + specular) * f_color;
	outColor = vec4(result, 1.0f);
}
