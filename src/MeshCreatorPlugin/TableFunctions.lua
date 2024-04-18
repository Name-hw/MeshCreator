local TableFunctions = {}

local Root = script.Parent
local Classes = require(Root.Classes)
local lib = Root.lib
--local Table = require(lib.Table)

function TableFunctions.GetSetting(Settings, Setting)
	if Settings[Setting] then return Settings[Setting] end
end

function TableFunctions.VerticesToVertexIDs(Vertices: {Classes.Vertex}, vertexID)
	
end

function TableFunctions.GetVertexByVertexID(Vertices: {Classes.Vertex}, vertexID)
	for _, Vertex in Vertices do
		if Vertex.ID == vertexID then
			return Vertex
		end
	end
end

function TableFunctions.GetEFElementsByVertexID(EFElements: Classes.EFElement, vertexID)
	local EFElementsContainingVertex: {Classes.EFElement} = {}
	
	for _, EFElement: Classes.EFElement in EFElements do
		local ElementVertexIDs = EFElement.VertexIDs

		for _, ElementVertexID in ipairs(ElementVertexIDs) do
			if ElementVertexID == vertexID then
				table.insert(EFElementsContainingVertex, EFElement)
			end
		end
	end
	
	return EFElementsContainingVertex
end

function TableFunctions.GetVertexFromEFElement(Vertices: {Classes.Vertex}, EFElement: Classes.EFElement)
	local VerticesInEFElement: {Classes.EFElement} = {}
	
	for _, EFElementVertexID in ipairs(EFElement.VertexIDs) do
		table.insert(VerticesInEFElement, TableFunctions.GetVertexByVertexID(Vertices, EFElementVertexID))
	end
	
	return VerticesInEFElement
end

function TableFunctions.FindDatasFromElements(ElementsToFind: {}, DataToFind: string)
	local Datas = {}
	
	for _, Element in ipairs(ElementsToFind) do
		table.insert(Datas, Element[DataToFind])
	end
	
	return Datas
end

function TableFunctions.FindVertexAttachmentsFromEFElement(Vertices: {Classes.Vertex}, EFElement: Classes.EFElement)
	local VerticesInEFElement = TableFunctions.GetVertexFromEFElement(Vertices, EFElement)
	local VertexAttachments = TableFunctions.FindDatasFromElements(VerticesInEFElement, "VertexAttachment")
	
	return VertexAttachments
end

return TableFunctions