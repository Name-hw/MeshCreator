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
	for _, Vertex: Classes.Vertex in Vertices do
		if Vertex.ID == vertexID then
			return Vertex
		end
	end
end

function TableFunctions.GetVertexIDByEMVertexID(Vertices: {Classes.Vertex}, EMVertexID: number)
	for _, Vertex: Classes.Vertex in Vertices do
		for _, emVertexID: number in Vertex.EMVertexIDs do
			if emVertexID == EMVertexID then
				return Vertex.ID
			end
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

function TableFunctions.GetVertexFromVertexAttachment(Vertices: {Classes.Vertex}, vertexAttachment: Attachment)
	for _, Vertex: Classes.Vertex in Vertices do
		if Vertex.VertexAttachment == vertexAttachment then
			return Vertex
		end
	end
end

function TableFunctions.GetVerticesFromEFElement(Vertices: {Classes.Vertex}, EFElement: Classes.EFElement)
	local VerticesInEFElement: {Classes.Vertex} = {}
	
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

function TableFunctions.FindVertexDataFromEFElement(Vertices: {Classes.Vertex}, EFElement: Classes.EFElement, DataToFind: string)
	local VerticesInEFElement = TableFunctions.GetVerticesFromEFElement(Vertices, EFElement)
	local VertexAttachments = TableFunctions.FindDatasFromElements(VerticesInEFElement, DataToFind)
	
	return VertexAttachments
end

return TableFunctions