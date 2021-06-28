#version 330 core

// Uniforms

// ambient lightning level, same across multiple vertexes
uniform vec3 u_light_pos;
uniform vec3 u_light_color;
uniform vec3 u_ambient;
uniform vec3 u_light_dir;
uniform vec3 u_half_vec;
uniform float u_shininess;
uniform float u_strength;

// Inputs from the vertex shader
in vec4 f_color;
in vec3 f_normal;
in vec3 f_pos;

// Output color
layout(location = 0) out vec4 outColor;

void main() {
	// compute cosine of the directions
	// surface normal and light direction
	float diffuse = max(0.0, dot(f_normal, u_light_dir));

	// surface normal and eye direction half vector ?
	float specular = max(0.0, dot(f_normal, u_half_vec));

	if (diffuse == 0.0) {
		specular = 0.0;
	} else {
		specular = pow(specular, u_shininess);
	}

	// This is the only light
	vec3 scattered_light = u_ambient + u_light_color * diffuse;
	vec3 reflected_light = u_light_color * specular * u_strength;

	// modulate surface color with light, but saturate at white
	// ignore the alpha component to get opaque lightning and not affect the original color
	vec3 rgb = min(f_color.rgb * scattered_light + reflected_light, vec3(1.0));

	outColor = vec4(rgb, f_color.a);
}
