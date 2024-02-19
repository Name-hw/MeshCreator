local MeshLoader = {}
MeshLoader.__index = MeshLoader

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Zlib128 = require(script.Parent.Zlib128)

function MeshLoader.new(MeshPart: MeshPart, MeshSaveFile: Classes.Mesh)
	if MeshSaveFile then
		task.desynchronize()
		local newMeshLoader = setmetatable({}, MeshLoader)
		newMeshLoader.MeshPart = MeshPart
		newMeshLoader.MeshSaveFile = MeshSaveFile
		task.synchronize()
		
		newMeshLoader:CreateEditableMesh()

		return newMeshLoader
	end
end

function MeshLoader.LoadMeshSaveFile(MeshPart: MeshPart)
	local MeshSaveFile = MeshPart:FindFirstChild("MeshSaveFile")

	if MeshSaveFile then
		local EncodedSaveData = MeshSaveFile:GetAttributes()

		if EncodedSaveData.Vertices and EncodedSaveData.Triangles then
			local SaveData = {
				Vertices = HttpService:JSONDecode(Zlib128.decompress(EncodedSaveData.Vertices)),
				Triangles = HttpService:JSONDecode(Zlib128.decompress(EncodedSaveData.Triangles))
			}

			for _, Vertex: Classes.Vertex in SaveData.Vertices do
				Vertex.VertexUV = Vector2.new(Vertex.VertexUV[1], Vertex.VertexUV[2])
				Vertex.VA_Position = Vector3.new(Vertex.VA_Position[1], Vertex.VA_Position[2], Vertex.VA_Position[3])
				Vertex.VA_Normal = Vector3.new(Vertex.VA_Normal[1], Vertex.VA_Normal[2], Vertex.VA_Normal[3])
			end

			return SaveData
		end
	end
end

function MeshLoader:CreateEditableMesh()
	self.EM = Instance.new("EditableMesh")
	local newVertexIDs = {}
	
	for _, Vertex: Classes.Vertex in self.MeshSaveFile.Vertices do
		local VertexUV = Vertex.VertexUV
		local VertexPosition = Vertex.VA_Position / (self.MeshPart.Size / self.MeshPart.MeshSize) --VER
		local VN = Vertex.VA_Normal --VA_Normal
		local newVertexID = self.EM:AddVertex(VertexPosition)

		self.EM:SetVertexNormal(newVertexID, VN)
		self.EM:SetUV(newVertexID, VertexUV)

		newVertexIDs[Vertex.ID] = newVertexID
		Vertex.ID = newVertexID
	end

	for _, Triangle: Classes.Triangle in self.MeshSaveFile.Triangles do
		local TriangleVertexIDs = Triangle.VertexIDs
		local newTriangleVertexIDs = {}

		for _, TriangleVertexID in ipairs(TriangleVertexIDs) do
			table.insert(newTriangleVertexIDs, newVertexIDs[TriangleVertexID])
		end

		Triangle.ID = self.EM:AddTriangle(table.unpack(newTriangleVertexIDs))
		Triangle.VertexIDs = newTriangleVertexIDs
	end
	
	self.EM.Name = "EditableMesh"
	self.EM.Parent = self.MeshPart
end

return MeshLoader