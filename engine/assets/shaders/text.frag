#version 330 core

uniform sampler2D u_diffuse;

in vec4 f_color;
in vec2 f_texcoord;
in float f_gamma;

layout(location = 0) out vec4 outColor;

void main() {
	float alpha = texture(u_diffuse, f_texcoord).r;
	outColor = f_color * pow(alpha, 1.0/f_gamma);
}
