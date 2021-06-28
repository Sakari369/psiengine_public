#version 330 core

in vec4 f_color;

layout(location = 0) out vec4 outColor;

void main() {
	outColor = f_color;
}
