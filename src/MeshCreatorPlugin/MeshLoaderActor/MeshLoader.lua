local MeshLoader = {}
MeshLoader.__index = MeshLoader

local HttpService = game:GetService("HttpService")
local Zlib128 = require(script.Parent.Zlib128)

function MeshLoader.new(MeshPart: MeshPart, MeshSaveFile)
	if MeshSaveFile then
		--task.desynchronize()
		local newMeshLoader = setmetatable({}, MeshLoader)
		newMeshLoader.MeshPart = MeshPart
		newMeshLoader.MeshSaveFile = MeshSaveFile
		--task.synchronize()
		
		if newMeshLoader.MeshPart.MeshSize ~= Vector3.zero then
			newMeshLoader.VA_Offset = (newMeshLoader.MeshPart.Size / newMeshLoader.MeshPart.MeshSize)
		else
			newMeshLoader.VA_Offset = newMeshLoader.MeshPart.Size
		end
		
		newMeshLoader:CreateEditableMesh()
		
		return newMeshLoader
	end
end

function MeshLoader.LoadMeshSaveFile(MeshPart: MeshPart)
	local MeshSaveFile = MeshPart:FindFirstChild("MeshSaveFile")

	if MeshSaveFile then
		local EncodedSaveData = MeshSaveFile:GetAttributes()

		if EncodedSaveData.Version == "v0.2.5" or "v0.2.6" then
			if EncodedSaveData.Vertices and EncodedSaveData.Triangles then
				local SaveData = {
					Vertices = HttpService:JSONDecode(Zlib128.decompress(EncodedSaveData.Vertices)),
					Triangles = HttpService:JSONDecode(Zlib128.decompress(EncodedSaveData.Triangles))
				}
				
				for _, Vertex in SaveData.Vertices do
					Vertex.VertexUV = Vector2.new(Vertex.VertexUV[1], Vertex.VertexUV[2])
					Vertex.VA_Position = Vector3.new(Vertex.VA_Position[1], Vertex.VA_Position[2], Vertex.VA_Position[3])
	
					for index, vertexNormal: {} in Vertex.VertexNormals do
						Vertex.VertexNormals[index] = Vector3.new(vertexNormal[1], vertexNormal[2], vertexNormal[3])
					end
				end
				
				return SaveData
			end
		else
			if EncodedSaveData.Vertices and EncodedSaveData.Triangles then
				local SaveData = {
					Vertices = HttpService:JSONDecode(Zlib128.decompress(EncodedSaveData.Vertices)),
					Triangles = HttpService:JSONDecode(Zlib128.decompress(EncodedSaveData.Triangles))
				}
				
				for _, Vertex in SaveData.Vertices do
					Vertex.EMVertexIDs = {Vertex.ID}
					Vertex.VertexUV = Vector2.new(Vertex.VertexUV[1], Vertex.VertexUV[2])
					Vertex.VA_Position = Vector3.new(Vertex.VA_Position[1], Vertex.VA_Position[2], Vertex.VA_Position[3])
					Vertex.VertexNormals = {Vector3.new(Vertex.VA_Normal[1], Vertex.VA_Normal[2], Vertex.VA_Normal[3])}
				end
				
				for _, Triangle in SaveData.Triangles do
					Triangle.EMVertexIDs = Triangle.VertexIDs
				end

				return SaveData
			end
		end
	end
end

function MeshLoader:CreateEditableMesh()
	self.EM = Instance.new("EditableMesh")

	local newEMVertexIDsArray = {}
	
	assert(pcall(function()
		self.EM:GetVertices()
	end), "Please enable EditableImage and EditableMesh in the beta features.")
	
	for i, Vertex in self.MeshSaveFile.Vertices do
		local VertexNormals = Vertex.VertexNormals
		local VertexUV = Vertex.VertexUV
		local VertexPosition = Vertex.VA_Position / self.VA_Offset
		local newEMVertexIDs = {}

		for _ = 1, #Vertex.EMVertexIDs do
			table.insert(newEMVertexIDs, self.EM:AddVertex(VertexPosition))
		end

		for index, newEMVertexID in newEMVertexIDs do
			self.EM:SetVertexNormal(newEMVertexID, VertexNormals[index])
			self.EM:SetUV(newEMVertexID, VertexUV)
		end

		for index, EMVertexID in ipairs(Vertex.EMVertexIDs) do
			newEMVertexIDsArray[EMVertexID] = newEMVertexIDs[index]
		end

		if i % 100 == 0 then --waits 0.01 seconds every 100 attachments spawned
			task.wait(0.01)
		end
	end

	for i, Triangle in self.MeshSaveFile.Triangles do
		local newTriangleEMVertexIDs = {}
		
		for _, TriangleEMVertexID in ipairs(Triangle.EMVertexIDs) do
			table.insert(newTriangleEMVertexIDs, newEMVertexIDsArray[TriangleEMVertexID])
		end

		self.EM:AddTriangle(table.unpack(newTriangleEMVertexIDs))

		if i % 100 == 0 then
			task.wait(0.01)
		end
	end

	self.EM.Name = "EditableMesh"
	self.EM.Parent = self.MeshPart
end

return MeshLoader