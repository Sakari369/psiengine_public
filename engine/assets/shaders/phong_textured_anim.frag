#version 330 core

// Structs
struct lightSource {
	vec3 pos;
	vec3 dir;
	vec3 color;
	float intensity;
};

// Uniforms
uniform mat3 u_normal_matrix;
uniform float u_elapsed_time;

// Light sources
// We have ambient lightning
uniform lightSource u_ambient;

// And other light sources
uniform lightSource u_light;

uniform sampler2D u_diffuse;

// Inputs and outputs
in vec3 f_normal;
in vec2 f_texcoord;

layout(location = 0) out vec4 outColor;

vec3 apply_light(lightSource light, vec4 diffuse, vec3 normal) {
	// Ambient
	vec3 ambient = u_ambient.color * u_ambient.intensity;

	// Diffuse lightning that is interpolated based on the normals
	float light_diffuse = max(0.0, dot(normal, light.dir));

	// Scattered is our total light for this fragment
	vec3 scattered_light = ambient + (light_diffuse * light.color * light.intensity);

	// Limit to 1.0
	vec3 rgb = min(diffuse.rgb * scattered_light, vec3(1.0));

	return rgb;
}

void main() {
	vec4 diffuse = texture(u_diffuse, f_texcoord);

	// Need to multiply the normal with the inverted normal matrix to 
	// calculate the light direction correctly
	vec3 normal = normalize(u_normal_matrix * f_normal);
	vec3 rgb = apply_light(u_light, diffuse, normal);

	outColor = vec4(rgb, 1.0);
}
