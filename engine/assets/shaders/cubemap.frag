#version 330 core

in vec3 f_texcoord;

layout(location = 0) out vec4 outColor;

uniform samplerCube u_diffuse;

void main() {
    outColor = vec4(texture(u_diffuse, f_texcoord).rgb, 1.0);
}
