#version 330 core

// We get this from the geometry shader
in vec2 f_texCoord;

uniform sampler2D u_texture0;

layout(location = 0) out vec4 fragColor;

void main() {
	fragColor = texture(u_texture0, f_texCoord);
}
