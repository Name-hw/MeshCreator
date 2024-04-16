local LocalizationService = game:GetService("LocalizationService")
local MeshFunctions = {}
MeshFunctions.__index = MeshFunctions

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib
--local Table = require(lib.Table)

local function CreateVertexAttachment(MeshPart, VP, VN)
	local VA = Instance.new("Attachment") --VertexAttachment
			VA.Visible = true
			VA.Archivable = false
			VA.Name = "VertexAttachment"
			VA.Position = VP
			VA.Axis = VN or Vector3.zero
			VA.Parent = MeshPart
	return VA
end

function MeshFunctions:AddVertexAttachments(MeshSaveFile)
	if MeshSaveFile then
		for _, Vertex: Classes.Vertex in self.Mesh.Vertices do
			local VertexID = Vertex.ID
			local VP = Vertex.VA_Position --VA_Position
			local VN = Vertex.VA_Normal --VA_Normal
			
			local VA = CreateVertexAttachment(self.MeshPart, VP, VN)
			
			Vertex.VertexAttachment = VA
		end
		
		for _, Triangle: Classes.Triangle in self.Mesh.Triangles do
			Triangle.VertexAttachments = TableFunctions.FindVertexAttachmentsFromEFElement(self.Mesh.Vertices, Triangle)
		end
	else
		local EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
		local EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs

		for _, vertexID in EMVIDs do
			local VertexPosition = self.EM:GetPosition(vertexID)
			local VertexNormal = self.EM:GetVertexNormal(vertexID)
			local VA = CreateVertexAttachment(self.MeshPart, VertexPosition * self.Mesh.VA_Offset, VertexNormal) --VertexAttachment
			
			local VertexClass: Classes.Vertex = Classes.new("Vertex", {
				ID = vertexID,
				Parent = self.Mesh,
				VertexUV = self.EM:GetUV(vertexID),
				VertexAttachment = VA,
				VA_Position = VA.Position,
				VA_Normal = VertexNormal
			})

			self.Mesh.Vertices[vertexID] = VertexClass
		end

		for _, triangleID in EMTIDs do
			local TVIDs = table.pack(self.EM:GetTriangleVertices(triangleID)) --TriangleVertexIDs
			local MeshFace = {}
			
			local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
				ID = triangleID,
				Parent = self.Mesh,
				VertexIDs = TVIDs
			})
						
			TriangleClass.VertexAttachments = TableFunctions.FindVertexAttachmentsFromEFElement(self.Mesh.Vertices, TriangleClass)
			
			self.Mesh.Triangles[triangleID] = TriangleClass
			
			--[[
			for _, triangleVertexID in ipairs(TVIDs) do
				table.insert(MeshFace, triangleVertexID)
			end
			]]
		end
	end
	
	self.MeshGizmo:Create()
end

function MeshFunctions:RemoveVertexAttachments()
	for _, Vertex: Classes.Vertex in self.Mesh.Vertices do
		Vertex.VertexAttachment:Destroy()
	end
end
   
function MeshFunctions:SetVertexPosition(Vertex: Classes.Vertex, VA_Position)
	Vertex.VA_Position = VA_Position
	self.EM:SetPosition(Vertex.ID, VA_Position / self.Mesh.VA_Offset)
end

function MeshFunctions:AddVertex(worldPosition: Vector3)
	local VertexID = self.EM:AddVertex((worldPosition - self.MeshPart.Position) / self.Mesh.VA_Offset)
	local VA = CreateVertexAttachment(self.MeshPart, worldPosition - self.MeshPart.Position)
	
	local VertexClass: Classes.Vertex = {
		ID = VertexID,
		VertexUV = Vector3.zero,
		VertexAttachment = VA
	}
	
	self.Mesh.Vertices[VertexID] = VertexClass
	
	return VertexClass
end

function MeshFunctions:RemoveVertex(Vertex: Classes.Vertex)
	local VertexID = Vertex.ID
	table.remove(self.Mesh.Vertices, table.find(self.Mesh.Vertices, Vertex))
	
	self.EM:RemoveVertex(VertexID)
end

function MeshFunctions:RemoveTriangleByVertexID(vertexID)
	local TrianglesContainingVertex = TableFunctions.GetEFElementsByVertexID(self.Mesh.Triangles, vertexID)

	for _, Triangle: Classes.Triangle in TrianglesContainingVertex do
		--task.desynchronize()
		
		if table.find(self.Mesh.Triangles, Triangle) then
			local TriangleID = Triangle.ID
			table.remove(self.Mesh.Triangles, table.find(self.Mesh.Triangles, Triangle))
			--task.synchronize()
			self.EM:RemoveTriangle(TriangleID)
			Triangle.Triangle3D.Model:Destroy()
		end
	end
end

function MeshFunctions:AddTriangle(vertexPositions: {Vector3})
	local TVIDs = {} -- TrinagleVertexIDs
	local TVAs = {} -- TrinagleVertexAttachments

	for _, vertexPosition in vertexPositions do
		local Vertex: Classes.Vertex = self:AddVertex(vertexPosition)

		table.insert(TVIDs, Vertex.ID)
		table.insert(TVAs, Vertex.VertexAttachment)
	end

	local TriangleID = self.EM:AddTriangle(table.unpack(TVIDs))

	local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
		ID = TriangleID,
		Parent = self.Mesh,
		VertexIDs = TVIDs
	})
				
	TriangleClass.VertexAttachments = TVAs
	
	self.Mesh.Triangles[TriangleID] = TriangleClass

	self.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)

	return TriangleClass
end

return MeshFunctions