local MeshFunctions = {}
MeshFunctions.__index = MeshFunctions

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib
--local Table = require(lib.Table)

function MeshFunctions:AddVertexAttachments(MeshSaveFile)
	if MeshSaveFile then
		--[[
		self.EMV = MeshSaveFile.Vertices --EditableMeshVertices
		self.EMT = MeshSaveFile.Triangles --EditableMeshTriangles
		]] 
		for _, Vertex: Classes.Vertex in self.Vertices do
			local VertexID = Vertex.VertexID
			local VP = Vertex.VA_Position --VA_Position
			local VN = Vertex.VA_Normal --VA_Normal
			local VA = Instance.new("Attachment") --VertexAttachment
			VA.Name = "VertexAttachment"
			VA.Position = VP
			VA.Axis = VN
			VA.Parent = self.MeshPart
			
			Vertex.VertexAttachment = VA
		end
	else
		self.EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
		self.EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs

		for _, vertexID in self.EMVIDs do
			local VertexPosition = self.EM:GetPosition(vertexID) --VA_Position
			local VA = Instance.new("Attachment") --VertexAttachment
			VA.Name = "VertexAttachment"
			VA.Position = VertexPosition * self.MeshPart.Size / self.MeshPart.MeshSize
			VA.Axis = self.EM:GetVertexNormal(vertexID)
			VA.Parent = self.MeshPart

			local VertexClass: Classes.Vertex = {
				VertexID = vertexID,
				VertexUV = self.EM:GetUV(vertexID),
				VertexAttachment = VA,
			}

			self.Vertices[vertexID] = VertexClass
		end

		for _, triangleID in self.EMTIDs do
			local TVIDs, _ = table.pack(self.EM:GetTriangleVertices(triangleID)) --TriangleVertexIDs
			--[[
			local TVs = {}

			for _, vertexID in ipairs(TV) do
				table.insert(TVs, self.Vertices[vertexID])
			end
			]]
			
			local TriangleClass: Classes.Triangle = {
				TriangleID = triangleID,
				TriangleVertexIDs = TVIDs
			}

			self.Triangles[triangleID] = TriangleClass
		end
	end
	
	--[[
	self.EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
	self.EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs

	for _, vertexID in self.EMVIDs do
		local VP = self.EM:GetPosition(vertexID) --VA_Position
		local VA = Instance.new("Attachment") --VertexAttachment
		VA.Name = "VertexAttachment"
		VA.Position = VP * self.MeshPart.Size / self.MeshPart.MeshSize
		VA.Axis = self.EM:GetVertexNormal(vertexID)
		VA.Parent = self.MeshPart

		local VertexClass: Classes.Vertex = {
			VertexID = vertexID,
			VertexUV = self.EM:GetUV(vertexID),
			VertexAttachment = VA,
			VA_Position = VP,
			VA_Normal = self.EM:GetVertexNormal(vertexID)
		}

		self.Vertices[vertexID] = VertexClass
	end

	for _, triangleID in ipairs(self.EMTIDs) do
		local TV = table.pack(self.EM:GetTriangleVertices(triangleID)) --TriangleVertices
		local TVs = {}
		
		for _, vertexID in ipairs(TV) do
			table.insert(TVs, self.Vertices[vertexID])
		end
		
		local TriangleClass: Classes.Triangle = {
			TriangleID = triangleID,
			TriangleVertices = TVs
		}

		self.Triangles[triangleID] = TriangleClass
	end
	]]
end

function MeshFunctions:RemoveVertexAttachments()
	for _, Vertex: Classes.Vertex in self.Vertices do
		Vertex.VertexAttachment:Destroy()
	end
end

function MeshFunctions:SetVertexPosition(vertexID, VA_Position)
	self.EM:SetPosition(vertexID, VA_Position / (self.MeshPart.Size / self.MeshPart.MeshSize))
end

function MeshFunctions:RemoveVertex(Vertex: Classes.Vertex)
	local VertexID = Vertex.VertexID
	local TrianglesContainingVertex = TableFunctions.GetTrianglesByVertexID(self.Triangles, VertexID)
	
	for _, Triangle: Classes.Triangle in TrianglesContainingVertex do
		local TriangleID = Triangle.TriangleID
		
		self.EM:RemoveTriangle(TriangleID)
		table.remove(self.Triangles, table.find(self.Triangles, Triangle))
	end
	
	self.EM:RemoveVertex(VertexID)
	table.remove(self.Vertices, table.find(self.Vertices, Vertex))
end

return MeshFunctions