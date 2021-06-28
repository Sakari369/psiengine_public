#version 330 core

// We get this from the geometry shader
in vec2 f_texCoord;
in vec4 f_color;

uniform sampler2D u_texture0;
uniform float u_opacity;

layout(location = 0) out vec4 fragColor;

void main() {
	fragColor = f_color;
}
