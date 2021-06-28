function createCircularGrid(shader)
	local distanceCovered = 100
	local numCircles = 10
	local radiusStep = distanceCovered / numCircles

	-- Lets generate from the largest to the smallest
	local radius = distanceCovered
	local lineWidth = 1.0
	local rotation = vec3(90.0, 0.0, 0.0)
	local numPoints = 360/3

	-- Same material for all circles in our grid
	local lineMaterial = PSIGLMaterial()
	lineMaterial:set_shader(shader)
	lineMaterial:set_lit(false)
	lineMaterial:set_color(vec3(1.0, 1.0, 1.0))
	lineMaterial:set_opacity(0.6)

	-- Create the parent object
	-- The parent is the largest object
	local parent = PSIPolyLines()
	local vertexes = PSIGeometry.create_poly(numPoints, 0, radius)
	parent:set_vertexes(vertexes)
	parent:set_material(lineMaterial)
	parent:get_transform():setRotationDeg(rotation)
	parent:set_line_width(lineWidth)
	parent:init()

	-- Generate rest of the circles
	for i=1, numCircles do
		local child = PSIPolyLines()

		vertexes = PSIGeometry.create_poly(numPoints, 0, radius)

		child:set_vertexes(vertexes)
		child:set_material(lineMaterial)
		child:get_transform():set_rotation_deg(rotation)
		child:set_line_width(lineWidth)
		child:init()

		parent:add_child(child)

		radius = radius - radiusStep
	end

	local lines = createCrossLines(shader, distanceCovered, lineWidth)
	parent:add_child(lines)

	return parent
end

function createCrossLines(shader, distance, lineWidth) 
	-- Generate and add the cross lines
	-- Horizontal
	local horiLine = PSIPolyLines()
	local hLineVert = {}

	hLineVert[1] = vec3(-distance, 0, 0)
	hLineVert[2] = vec3(distance, 0, 0)

	local hlineMaterial = PSIGLMaterial()
	hlineMaterial:set_shader(shader)
	hlineMaterial:set_lit(false)
	hlineMaterial:set_color(vec3(1.0, 0.0, 0.0))

	horiLine:set_vertexes(hLineVert)
	horiLine:set_material(hlineMaterial)
	horiLine:set_line_width(lineWidth)
	horiLine:init()

	-- Vertical
	local vertLine = PSIPolyLines()
	local vLineVert = {}

	vLineVert[1] = vec3(0, distance, 0)
	vLineVert[2] = vec3(0, -distance, 0)

	local vlineMaterial = PSIGLMaterial()
	vlineMaterial:set_shader(shader)
	vlineMaterial:set_lit(false)
	vlineMaterial:set_color(vec3(0.0, 0.0, 1.0))

	vertLine:set_vertexes(vLineVert)
	vertLine:set_material(vlineMaterial)
	vertLine:set_line_width(lineWidth)
	
	local rotation = vec3(90.0, 0.0, 0.0)
	vertLine:get_transform():set_rotation_deg(rotation)

	vertLine:init()

	horiLine:add_child(vertLine)

	-- Middle center pole
	local poleLine = PSIPolyLines()
	local pLineVert = {}

	pLineVert[1] = vec3(0, distance, 0)
	pLineVert[2] = vec3(0, -distance, 0)

	local plineMaterial = PSIGLMaterial()
	plineMaterial:set_shader(shader)
	plineMaterial:set_lit(false)
	plineMaterial:set_color(vec3(0.0, 1.0, 0.0))

	poleLine:set_vertexes(pLineVert)
	poleLine:set_material(plineMaterial)
	poleLine:set_line_width(lineWidth)
	poleLine:init()

	horiLine:add_child(poleLine)

	return horiLine
end

function createUniformGrid(shader, rows, scale, color)
	local gridMat = PSIGLMaterial()
	gridMat:set_color(color)
	gridMat:set_wireframe(true)
	gridMat:set_opacity(0.9)
	gridMat:set_shader(shader)

	local gridMesh = PSIRenderMesh()
	local gridGeom = PSIGeometry.grid(rows)

	gridMesh:set_material(gridMat)
	gridMesh:set_geometry(gridGeom)
	gridMesh:init()

	gridMesh:get_transform():get_scaling().x = scale.x
	gridMesh:get_transform():get_scaling().y = scale.y
	gridMesh:get_transform():get_scaling().z = scale.z

	return gridMesh
end

function createUniformGrids(shader, scale)
	local rows = 8

	local hori = createUniformGrid(shader, rows, scale, vec3(0.0, 0.0, 1.0))
	local vert = createUniformGrid(shader, rows, scale, vec3(0.0, 1.0, 0.0))

	hori:get_transform():get_rotation().x = math.rad(90)
	vert:get_transform():get_rotation().z = math.rad(90)

	hori:add_child(vert)

	return hori
end

