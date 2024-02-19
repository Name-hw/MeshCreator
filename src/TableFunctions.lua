local TableFunctions = {}

local Root = script.Parent
local Classes = require(Root.Classes)
local lib = Root.lib
--local Table = require(lib.Table)

function TableFunctions.VerticesToVertexIDs(Vertices, vertexID)
	
end

function TableFunctions.GetVertexByVertexID(Vertices, vertexID)
	for _, Vertex in Vertices do
		if Vertex.ID == vertexID then
			return Vertex
		end
	end
end

function TableFunctions.GetEFElementsByVertexID(EFElements, vertexID)
	local ElementsContainingVertex: {Classes.EFElement} = {}
	
	for _, EFElement: Classes.EFElement in EFElements do
		local ElementVertexIDs = EFElement.VertexIDs

		for _, ElementVertexID in ipairs(ElementVertexIDs) do
			if ElementVertexID == vertexID then
				table.insert(ElementsContainingVertex, EFElement)
			end
		end
	end
	
	return ElementsContainingVertex
end

return TableFunctions