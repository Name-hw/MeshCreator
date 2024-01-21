local MeshLoader = {}
MeshLoader.__index = MeshLoader

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local Zlib128 = require(script.Parent.Zlib128)

function MeshLoader.new(MeshPart: MeshPart, MeshSaveFile: Classes.Mesh)
	if MeshSaveFile then
		local newMeshLoader = setmetatable(MeshLoader, MeshLoader)
		newMeshLoader.MeshPart = MeshPart
		newMeshLoader.MeshSaveFile = MeshSaveFile

		if newMeshLoader.MeshPart:FindFirstChildOfClass("EditableMesh") then
			newMeshLoader.EM = newMeshLoader.MeshPart:FindFirstChildOfClass("EditableMesh")
		else
			task.synchronize()
			newMeshLoader:CreateEditableMesh()
		end

		return newMeshLoader
	end
end

function MeshLoader.LoadMeshSaveFile(MeshPart: MeshPart)
	local MeshSaveFile = MeshPart:FindFirstChild("MeshSaveFile")
	if MeshSaveFile then
		local SaveData = MeshSaveFile:GetAttributes()
		
		if SaveData.Vertices and SaveData.Triangles then
			return {
				Vertices = HttpService:JSONDecode(Zlib128.decompress(SaveData.Vertices)),
				Triangles = HttpService:JSONDecode(Zlib128.decompress(SaveData.Triangles))
			}
		end
	end
end

function MeshLoader:CreateEditableMesh()
	if self.MeshPart.MeshId ~= "" then
		self.EM = AssetService:CreateEditableMeshFromPartAsync(self.MeshPart)
	else
		self.EM = Instance.new("EditableMesh")
		self.EM:SetAttribute("CustomMesh", true)
	end

	if self.MeshSaveFile then
		if self.MeshPart:FindFirstChildOfClass("EditableMesh") then
			self.MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
		end

		for _, Vertex: Classes.Vertex in self.MeshSaveFile.Vertices do
			local VID = Vertex.VertexID
			local VP: Vector3 = Vertex.VertexPosition --VertexPosition
			local VN: Vector3 = Vertex.VertexNormal --VertexNormal

			self.EM:SetPosition(VID, VP)
			self.EM:SetVertexNormal(VID, VN)
		end
	end

	self.EM.Name = "EditableMesh"
	self.EM.Parent = self.MeshPart
end

return MeshLoader