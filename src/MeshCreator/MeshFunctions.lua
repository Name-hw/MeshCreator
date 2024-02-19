local MeshFunctions = {}
MeshFunctions.__index = MeshFunctions

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib
--local Table = require(lib.Table)

function MeshFunctions:AddVertexAttachments(MeshSaveFile)
	if MeshSaveFile then
		for _, Vertex: Classes.Vertex in self.Vertices do
			local VertexID = Vertex.ID
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
		local EMVIDs = self.EM:GetVertices() --EditableMeshVertexIDs
		local EMTIDs = self.EM:GetTriangles() --EditableMeshTriangleIDs

		for _, vertexID in EMVIDs do
			local VertexPosition = self.EM:GetPosition(vertexID) --VA_Position
			local VertexNormal = self.EM:GetVertexNormal(vertexID) --VA_Position
			
			local VA = Instance.new("Attachment") --VertexAttachment
			VA.Name = "VertexAttachment"
			VA.Position = VertexPosition * (self.MeshPart.Size / self.MeshPart.MeshSize)
			VA.Axis = VertexNormal
			VA.Parent = self.MeshPart
			
			local VertexClass: Classes.Vertex = {
				ID = vertexID,
				VertexUV = self.EM:GetUV(vertexID),
				VertexAttachment = VA,
			}

			self.Vertices[vertexID] = VertexClass
		end

		for _, triangleID in EMTIDs do
			local TVIDs = table.pack(self.EM:GetTriangleVertices(triangleID)) --TriangleVertexIDs
			local MeshFace = {}
			
			local TriangleClass: Classes.Triangle = {
				ID = triangleID,
				VertexIDs = TVIDs
			}

			self.Triangles[triangleID] = TriangleClass
			
			for _, triangleVertexID in ipairs(TVIDs) do
				table.insert(MeshFace, triangleVertexID)
			end
		end
	end

	self.MeshGizmo:Create(self.Vertices, self.Triangles)
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
	local VertexID = Vertex.ID
	table.remove(self.Vertices, table.find(self.Vertices, Vertex))
	
	self.EM:RemoveVertex(VertexID)
end

function MeshFunctions:RemoveTriangleByVertexID(vertexID)
	local TrianglesContainingVertex = TableFunctions.GetEFElementsByVertexID(self.Triangles, vertexID)

	for _, Triangle: Classes.Triangle in TrianglesContainingVertex do
		--task.desynchronize()
		
		if table.find(self.Triangles, Triangle) then
			local TriangleID = Triangle.ID
			table.remove(self.Triangles, table.find(self.Triangles, Triangle))
			--task.synchronize()
			self.EM:RemoveTriangle(TriangleID)
		end
	end
end

return MeshFunctions