#version 330 core

#define M_PI 3.1415926535897932384626433832795
#define TWO_PI (M_PI * 2)

#define NUM_POINTS 32
#define MAX_VERTICES 65

layout(points) in;
layout(triangle_strip, max_vertices = MAX_VERTICES) out;

uniform float u_halfSize;
uniform mat4 u_projectionMatrix;

in vec4 g_color[];
out vec4 f_color;

void main() {
	// Pass the color
	f_color = g_color[0];

	vec4 origo = gl_in[0].gl_Position;

	float x, y, z;
	float angleInc;
	float angleRad;
	float radius = u_halfSize;

	vec4 vert;

	angleInc = TWO_PI / NUM_POINTS;
	angleRad = 0.0;

	// Calculate all the vertex points
	for (int i=0; i<NUM_POINTS; i++) {
		// Calculate vertex
		vert.x = sin(angleRad) * radius;
		vert.y = cos(angleRad) * radius;
		vert.z = 0.0f;

		// Push to our vertexes pointer
		gl_Position = u_projectionMatrix * vert + origo;
		EmitVertex();

		gl_Position = origo;
		EmitVertex();

		// Increase angle
		angleRad += angleInc;
	}

	// Close the strip
	gl_Position = u_projectionMatrix * vec4(0, radius, 0, 0) + origo;
	EmitVertex();

	EndPrimitive();
}
