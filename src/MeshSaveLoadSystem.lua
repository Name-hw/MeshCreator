local SaveLoadSystem = {}
SaveLoadSystem.__index = SaveLoadSystem

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local Zlib128 = require(script.Parent.Vender.Zlib128)

function SaveLoadSystem.Save(MeshCreator)
	local MeshSaveFile = MeshCreator.MeshPart:FindFirstChild("MeshSaveFile")
	local SaveData = {
		Vertices = {},
		Triangles = {}
	}

	for _, Vertex in MeshCreator.Vertices do
		local VertexSaveData = table.clone(Vertex)

		VertexSaveData.VertexPosition = tostring(VertexSaveData.VertexAttachment.Position)
		VertexSaveData.VertexNormal = tostring(VertexSaveData.VertexAttachment.Axis)
		VertexSaveData.VertexAttachment = nil

		table.insert(SaveData.Vertices, VertexSaveData)
	end

	for _, Triangle in MeshCreator.Triangles do
		local TriangleSaveData = table.clone(Triangle)

		TriangleSaveData.TriangleVertices = SaveData.Vertices[TriangleSaveData]

		table.insert(SaveData.Triangles, TriangleSaveData)
	end

	if not MeshSaveFile then
		MeshSaveFile = Instance.new("Configuration")
		MeshSaveFile.Name = "MeshSaveFile"
		MeshSaveFile.Parent = MeshCreator.MeshPart
	end

	MeshSaveFile:SetAttribute("Vertices", Zlib128.compress(HttpService:JSONEncode(SaveData.Vertices), 9))
	MeshSaveFile:SetAttribute("Triangles", Zlib128.compress(HttpService:JSONEncode(SaveData.Triangles), 9))
end

function SaveLoadSystem.LoadMeshSaveFile(MeshPart: MeshPart)
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

return SaveLoadSystem