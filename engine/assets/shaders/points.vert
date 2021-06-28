#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec3 a_color;

// Uniforms
uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;
uniform vec3 u_color;
uniform float u_opacity;

out vec4 g_color;

void main() {
	g_color = vec4(u_color, u_opacity);
    	gl_Position = u_projectionMatrix * u_modelViewMatrix * vec4(a_position, 1.0);
}
