local MeshFunctions = {}
MeshFunctions.__index = MeshFunctions

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib
--local Table = require(lib.Table)

function MeshFunctions.CreateVertexAttachment(MeshPart, VP)
	local VA = Instance.new("Attachment") --VertexAttachment
			VA.Visible = true
			VA.Archivable = false
			VA.Name = "VertexAttachment"
			VA.Position = VP
			VA.Parent = MeshPart
	return VA
end

function MeshFunctions:AddVertexAttachments(MeshSaveFile)
	if not MeshSaveFile then
		local EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
		local EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs

		for _, EMVertexID in EMVIDs do
			local VertexPosition = self.EM:GetPosition(EMVertexID)
			local VertexNormal = self.EM:GetVertexNormal(EMVertexID)
			local IsVertexExists = false

			for _, Vertex: Classes.Vertex in self.Mesh.Vertices do
				if Vertex.VA_Position == VertexPosition * self.Mesh.VA_Offset then
					IsVertexExists = true

					table.insert(Vertex.EMVertexIDs, EMVertexID)
					table.insert(Vertex.VertexNormals, VertexNormal)
				end
			end

			if not IsVertexExists then
				local VertexClass: Classes.Vertex = Classes.new("Vertex", {
					ID = #self.Mesh.Vertices + 1,
					Parent = self.Mesh,
					EMVertexIDs = {EMVertexID},
					VertexNormals = {VertexNormal},
					VertexUV = self.EM:GetUV(EMVertexID),
					VA_Position = VertexPosition * self.Mesh.VA_Offset
				})
				
				table.insert(self.Mesh.Vertices, VertexClass)
			end
		end

		for _, EMTriangleID in EMTIDs do
			local EMTVIDs = table.pack(self.EM:GetTriangleVertices(EMTriangleID)) --EditableMesh TriangleVertexIDs
			local TVIDs = {} --TriangleVertexIDs
			local MeshFace = {}
			
			for _, EMTriangleVertexID in ipairs(EMTVIDs) do
				local TriangleVertexID = TableFunctions.GetVertexIDByEMVertexID(self.Mesh.Vertices, EMTriangleVertexID)

				table.insert(TVIDs, TriangleVertexID)
			end

			local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
				ID = EMTriangleID,
				Parent = self.Mesh,
				VertexIDs = TVIDs,
				EMVertexIDs = EMTVIDs,
			})
			
			self.Mesh.Triangles[EMTriangleID] = TriangleClass
			
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
	
	for _, vertexID in Vertex.EMVertexIDs do
		self.EM:SetPosition(vertexID, VA_Position / self.Mesh.VA_Offset)
	end
end

function MeshFunctions:AddVertex(vertexPosition: Vector3)
	local VertexID = self.EM:AddVertex(vertexPosition)
	
	local VertexClass: Classes.Vertex = Classes.new("Vertex", {
		ID = VertexID,
		Parent = self.Mesh,
		VertexUV = Vector3.zero,
		VA_Position = vertexPosition * self.Mesh.VA_Offset,
		VA_Normal = Vector3.zero
	})
	
	table.insert(self.Mesh.Vertices, VertexClass)
	
	return VertexClass
end

function MeshFunctions:AddVertexByVertexAttachmentPosition(vertexAttachmentPosition: Vector3, IsVertexExists: boolean)
	local EMVertexID = self.EM:AddVertex(vertexAttachmentPosition / self.Mesh.VA_Offset)
	local VertexClass: Classes.Vertex

	if IsVertexExists ~= false then
		for _, Vertex: Classes.Vertex in self.Mesh.Vertices do
			if Vertex.VA_Position == vertexAttachmentPosition then
				IsVertexExists = true
	
				table.insert(Vertex.EMVertexIDs, EMVertexID)
				table.insert(Vertex.VertexNormals, self.EM:GetVertexNormal(EMVertexID))
	
				VertexClass = Vertex

				return VertexClass
			end
		end
	end

	if not IsVertexExists then
		VertexClass = Classes.new("Vertex", {
			ID = #self.Mesh.Vertices + 1,
			Parent = self.Mesh,
			EMVertexIDs = {EMVertexID},
			VertexNormals = {self.EM:GetVertexNormal(EMVertexID)},
			VertexUV = Vector3.zero,
			VA_Position = vertexAttachmentPosition,
		})
		
		table.insert(self.Mesh.Vertices, VertexClass)
	
		return VertexClass
	end
end

function MeshFunctions:AddVertexByWorldPosition(worldPosition: Vector3)
	local VertexPosition = worldPosition - self.MeshPart.Position / self.Mesh.VA_Offset
	
	return self:AddVertex(VertexPosition)
end

--[[
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
]]

function MeshFunctions:AddTriangleFromVertices(Vertices: {Classes.Vertex})
	local TVIDs = TableFunctions.FindDatasFromElements(Vertices, "ID") -- TrinagleVertexIDs
	local EMVIDsArray = TableFunctions.FindDatasFromElements(Vertices, "EMVertexIDs") -- EditableMesh VertexIDs Array
	local TVAs = TableFunctions.FindDatasFromElements(Vertices, "VertexAttachment") -- TrinagleVertexAttachments
	local EMTVIDs = {} -- EditableMesh TrinagleVertexIDs

	for _, EMVIDs: table in ipairs(EMVIDsArray) do
		for _, EMVertexID: number in ipairs(EMVIDs) do
			if not table.find(EMTVIDs, EMVertexID) then
				table.insert(EMTVIDs, EMVertexID)
			end
		end
	end

	local TriangleID = self.EM:AddTriangle(table.unpack(EMTVIDs))

	local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
		ID = TriangleID,
		Parent = self.Mesh,
		VertexIDs = TVIDs,
		EMVertexIDs = EMTVIDs,
		VertexAttachments = TVAs,
	})
	
	self.Mesh.Triangles[TriangleID] = TriangleClass

	self.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)
	
	return TriangleClass
end

function MeshFunctions:AddTriangleByVertexAttachmentPositions(vertexAttachmentPositions: {Vector3})
	local TVs = {} -- TriangleVertices
	local TVIDs = {} -- TrinagleVertexIDs
	local EMTVIDs = {} -- EditableMesh TrinagleVertexIDs
	local TVAs = {} -- TrinagleVertexAttachments

	for _, vertexAttachmentPosition in vertexAttachmentPositions do
		local Vertex: Classes.Vertex = self:AddVertexByVertexAttachmentPosition(vertexAttachmentPosition, false)

		table.insert(TVs, Vertex)
		table.insert(TVIDs, Vertex.ID)
		table.insert(EMTVIDs, Vertex.EMVertexIDs[1])
		table.insert(TVAs, Vertex.VertexAttachment)
	end

	local TriangleID = self.EM:AddTriangle(table.unpack(EMTVIDs))

	local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
		ID = TriangleID,
		Parent = self.Mesh,
		VertexIDs = TVIDs,
		EMVertexIDs = EMTVIDs,
		VertexAttachments = TVAs,
	})
	
	self.Mesh.Triangles[TriangleID] = TriangleClass

	self.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)
	
	return TriangleClass, TVs
end

return MeshFunctions