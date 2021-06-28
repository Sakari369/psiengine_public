#version 330 core

layout(points) in;
layout(line_strip, max_vertices = 2) out;

uniform mat4 u_model_view_projection_matrix;
uniform mat3 u_normal_matrix;
uniform sampler2D u_diffuse;
uniform float u_elapsed_time;

uniform float length = 0.5;
uniform vec3 color = vec3(1.0, 1.0, 1.0);

in vec3 g_vertex_normal[];
out vec3 f_vertex_color;

void main()
{
    vec3 normal = g_vertex_normal[0];
    vec3 c = vec3(0.25 + normal.x*0.75, 0.25 + normal.y*0.75, 0.25 + normal.z*0.75);
    f_vertex_color = c;

    vec4 v0 = gl_in[0].gl_Position;
    gl_Position = u_model_view_projection_matrix * v0;
    EmitVertex();

    vec4 v1 = v0 + vec4(normal * length, 0.0);
    gl_Position = u_model_view_projection_matrix * v1;
    EmitVertex();

    EndPrimitive();
}
