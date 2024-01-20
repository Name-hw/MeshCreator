local MeshFunctions = {}
MeshFunctions.__index = MeshFunctions

local Classes = require(script.Parent.Classes)

function MeshFunctions:GetVertex(vertexID)
	for _, Vertex: Classes.Vertex in self.Vertices do
		if Vertex.VertexID == vertexID then
			return Vertex
		end
	end
end

function MeshFunctions:GetTriangle()
	
end

function MeshFunctions:AddVertexAttachments()
	--[[
	if self.MeshSaveFile then
		self.EMV = self.MeshSaveFile.Vertices --EditableMeshVertices
		self.EMT = self.MeshSaveFile.Triangles --EditableMeshTriangles
		
		for _, Vertex: Classes.Vertex in self.EMV do
			print(Vertex.VertexPosition)
			local VID = Vertex.VertexID
			local VP: Vector3 = Vertex.VertexPosition --VertexPosition
			local VN = Vertex.VertexNormal --VertexNormal
			local VA = Instance.new("Attachment") --VertexAttachment
			VA.Name = "VertexAttachment"
			VA.Position = VP * self.MeshPart.Size / self.MeshPart.MeshSize
			VA.Axis = VN
			VA.Parent = self.MeshPart

			self.Vertices[VID] = Vertex
		end

		for _, Triangle: Classes.Triangle in ipairs(self.EMT) do
			local TID = Triangle.TriangleID
			local TVs = Triangle.TriangleVertices

			self.Triangles[TID] = Triangle
		end
	else
		self.EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
		self.EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs
		
		for _, vertexID in self.EMVIDs do
			local VP = self.EM:GetPosition(vertexID) --VertexPosition
			local VA = Instance.new("Attachment") --VertexAttachment
			VA.Name = "VertexAttachment"
			VA.Position = VP * self.MeshPart.Size / self.MeshPart.MeshSize
			VA.Axis = self.EM:GetVertexNormal(vertexID)
			VA.Parent = self.MeshPart

			local VertexClass: Classes.Vertex = {
				VertexID = vertexID,
				VertexPosition = VP,
				VertexNormal = self.EM:GetVertexNormal(vertexID),
				VertexAttachment = VA
			}

			self.Vertices[vertexID] = VertexClass
		end

		for _, triangleID in ipairs(self.EMTIDs) do
			local TV = table.pack(self.EM:GetTriangleVertices(triangleID)) --TriangleVertices
			local TVs = {}

			for _, vertexID in TV do
				local Vertex: Classes.Vertex = self.Vertices[vertexID]

				table.insert(TVs, self.Vertices[vertexID])
			end

			local TriangleClass: Classes.Triangle = {
				TriangleID = triangleID,
				TriangleVertices = TVs
			}

			self.Triangles[triangleID] = TriangleClass
		end
	end
	]]
	
	self.EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
	self.EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs

	for _, vertexID in self.EMVIDs do
		local VP = self.EM:GetPosition(vertexID) --VertexPosition
		local VA = Instance.new("Attachment") --VertexAttachment
		VA.Name = "VertexAttachment"
		VA.Position = VP * self.MeshPart.Size / self.MeshPart.MeshSize
		VA.Axis = self.EM:GetVertexNormal(vertexID)
		VA.Parent = self.MeshPart

		local VertexClass: Classes.Vertex = {
			VertexID = vertexID,
			VertexAttachment = VA
		}

		self.Vertices[vertexID] = VertexClass
	end

	for _, triangleID in ipairs(self.EMTIDs) do
		local TV = table.pack(self.EM:GetTriangleVertices(triangleID)) --TriangleVertices
		local TVs = {}

		for _, vertexID in TV do
			local Vertex: Classes.Vertex = self.Vertices[vertexID]

			table.insert(TVs, self.Vertices[vertexID])
		end

		local TriangleClass: Classes.Triangle = {
			TriangleID = triangleID,
			TriangleVertices = TVs
		}

		self.Triangles[triangleID] = TriangleClass
	end
end

function MeshFunctions:RemoveVertexAttachments()
	for _, Vertex: Classes.Vertex in self.Vertices do
		Vertex.VertexAttachment:Destroy()
	end
end

function MeshFunctions:SetVertexPosition(vertexID, VA_Position)
	self.EM:SetPosition(vertexID, VA_Position / (self.MeshPart.Size / self.MeshPart.MeshSize))
end

function MeshFunctions:GetTrianglesContaining(vertexID)
	local TrianglesContainingVertex = {}
	
	for _, Triangle: Classes.Triangle in self.Triangles do
		for _, Vertex: Classes.Vertex in Triangle.TriangleVertices do
			if vertexID == Vertex.VertexID then
				table.insert(TrianglesContainingVertex, Triangle)
			end
		end
	end
	
	return TrianglesContainingVertex
end

function MeshFunctions:RemoveVertex(Vertex: Classes.Vertex)
	local VertexID = Vertex.VertexID
	
	for _, Triangle: Classes.Triangle in self:GetTrianglesContaining(VertexID) do
		local TriangleID = Triangle.TriangleID
		
		table.remove(self.Triangles, table.find(self.Triangles, Triangle))
		self.EM:RemoveTriangle(TriangleID)
	end
	
	table.remove(self.Vertices, table.find(self.Vertices, Vertex))
	self.EM:RemoveVertex(VertexID)
end
--[[
function MeshFunctions:RemoveVertex(vertexID)
	for _, TriangleID in self:GetTrianglesContaining(vertexID) do
		table.remove(self.TVs, TriangleID)
		self.EM:RemoveTriangle(TriangleID)
	end

	self.EM:RemoveVertex(vertexID)
end
]]
return MeshFunctions