#version 330 core

#define M_PI 3.1415926535897932384626433832795
#define TWO_PI (M_PI * 2)

#define NUM_POINTS 4
#define MAX_VERTICES 4

layout(points) in;
layout(triangle_strip, max_vertices = MAX_VERTICES) out;

uniform float u_halfSize;
uniform mat4 u_projectionMatrix;

out vec2 f_texCoord;

void main() {
	vec4 point = gl_in[0].gl_Position;

	// Emit our 4 vertexes for the quad we are generating at the center of the point
	gl_Position = u_projectionMatrix * vec4(-u_halfSize, -u_halfSize, 0.0, 0.0) + point;
	f_texCoord = vec2(0.0, 0.0);
	EmitVertex();

	gl_Position = u_projectionMatrix * vec4(u_halfSize, -u_halfSize, 0.0, 0.0) + point;
	f_texCoord = vec2(1.0, 0.0);
	EmitVertex();

	gl_Position = u_projectionMatrix * vec4(-u_halfSize, u_halfSize, 0.0, 0.0) + point;
	f_texCoord = vec2(0.0, 1.0);
	EmitVertex();

	gl_Position = u_projectionMatrix * vec4(u_halfSize, u_halfSize, 0.0, 0.0) + point;
	f_texCoord = vec2(1.0, 1.0);
	EmitVertex();

	EndPrimitive();
}
