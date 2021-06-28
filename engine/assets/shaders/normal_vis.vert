#version 330 core

layout (location = 0) in vec3 a_position;
layout (location = 1) in vec4 a_color;
layout (location = 3) in vec3 a_normal;

out vec3 g_vertex_normal;

void main() {
    g_vertex_normal = a_normal;
    gl_Position = vec4(a_position, 1.0);
}

