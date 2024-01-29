local TableFunctions = {}

local Root = script.Parent
local Classes = require(Root.Classes)
local lib = Root.lib
local Table = require(lib.Table)

function TableFunctions.VerticesToVertexIDs(Vertices, vertexID)
	
end

function TableFunctions.GetVertexByVertexID(Vertices, vertexID)
	for _, Vertex in Vertices do
		if Vertex.VertexID == vertexID then
			return Vertex
		end
	end
end

function TableFunctions.GetTrianglesByVertexID(Triangles, vertexID)
	local TrianglesContainingVertex = {}
	
	for _, Triangle: Classes.Triangle in Triangles do
		local TriangleVertexIDs = Triangle.TriangleVertexIDs
		
		for _, TriangleVertexID in ipairs(TriangleVertexIDs) do
			if TriangleVertexID == vertexID then
				table.insert(TrianglesContainingVertex, Triangle)
			end
		end
	end
	
	return TrianglesContainingVertex
end

return TableFunctions