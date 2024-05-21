--Mesh Class
MeshClass = {
	ParentClass = script.Parent.GeometryElement
}
MeshClass.__index = MeshClass

local Classes = require(script.Parent)

local Root = script.Parent.Parent
local TableFunctions = require(Root.TableFunctions)

local function SetVA_Offset(MeshPart: MeshPart)
	local VA_Offset

	if MeshPart.MeshSize ~= Vector3.zero then
		VA_Offset = (MeshPart.Size / MeshPart.MeshSize)
	else
		VA_Offset = MeshPart.Size
	end

	return VA_Offset
end

function MeshClass:Init()
	self.VA_Offset = SetVA_Offset(self.MeshPart)
	
	self.MeshPart:GetPropertyChangedSignal("Size"):Connect(function()
		self.VA_Offset = SetVA_Offset(self.MeshPart)
	end)
end

function MeshClass:NewFaceFromVertices(vertices: {Classes.Vertex})
	local MeshCreator = self.MeshCreator
	--local NewFace: Classes.Face = {}
	local NewTriangles: {Classes.Triangle} = {}
	local AddedEMVertexIDs: {number} = {}

	for _, vertex: Classes.Vertex in vertices do
		table.insert(AddedEMVertexIDs, vertex:AddEMVertex())
	end

	for i = 1, #vertices - 2, 1 do
		local TriangleVertices: {Classes.Vertex} = {vertices[i], vertices[i + 1], vertices[#vertices]}
		local TriangleEMVertexIDs: {number} = {AddedEMVertexIDs[i], AddedEMVertexIDs[#vertices], AddedEMVertexIDs[i + 1]}

		local TriangleID: number = MeshCreator.EM:AddTriangle(table.unpack(TriangleEMVertexIDs))

		local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
			ID = TriangleID,
			Parent = self,
			VertexIDs = TableFunctions.FindDatasFromElements(TriangleVertices, "ID"),
			EMVertexIDs = TriangleEMVertexIDs,
			VertexAttachments = TableFunctions.FindDatasFromElements(TriangleVertices, "VertexAttachment"),
		})

		MeshCreator.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)
		--MeshCreator.MeshGizmo:DrawLineFromVertexData(TriangleVertices)

        TriangleClass.Triangle3D:Set("Locked", false)

		table.insert(self.Triangles, TriangleClass)
	end

	--return NewFace
	return NewTriangles
end

return MeshClass