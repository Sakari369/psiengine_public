#version 330 core


//#define MAX_LIGHTS 8

// Structs
struct lightSource {
	vec3 pos;
	vec3 dir;
	vec3 color;
	float intensity;
};

//lightSource lights[MAX_LIGHTS];

// Uniforms

uniform mat3 u_normal_mat;

// Light sources

// We have ambient lightning
uniform lightSource u_ambient;

// And other light sources
uniform lightSource u_light;

uniform samplerCube u_texture0;
uniform bool u_isTextured;

// Inputs and outputs
in vec4 f_color;
in vec3 f_normal;
in vec3 f_texcoord;

layout(location = 0) out vec4 outColor;

vec3 applyLight(lightSource light, vec3 surfaceColor, vec3 normal) {
	// Ambient
	vec3 ambient = u_ambient.color * u_ambient.intensity;

	// Diffuse lightning that is interpolated based on the normals
	float diffuse = max(0.0, dot(normal, light.dir));

	// Scattered is our total light for this fragment
	vec3 scatteredLight = ambient + (diffuse * light.color * light.intensity);

	// Limit to 1.0
	vec3 rgb = min(surfaceColor.rgb * scatteredLight, vec3(1.0));

	return rgb;
}

void main() {
	vec3 surfaceColor;
	surfaceColor = texture(u_texture0, f_texcoord).rgb;

	// Need to multiply the normal with the inverted normal matrix to 
	// calculate the light direction correctly
	vec3 normal = normalize(u_normal_mat * f_normal);
	vec3 rgb = applyLight(u_light, surfaceColor, normal);

	//vec3 rgb = applyLight(u_light, f_color.rgb, f_normal);
	outColor = vec4(rgb, f_color.a);
}
