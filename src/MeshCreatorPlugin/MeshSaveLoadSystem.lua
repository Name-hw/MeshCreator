local SaveLoadSystem = {}
SaveLoadSystem.__index = SaveLoadSystem

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local Root = script.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib
local Zlib128 = require(lib.Zlib128)
--local Table = require(lib.Table)

function SaveLoadSystem.Save(MeshCreator)
	task.desynchronize()
	local MeshSaveFile = MeshCreator.MeshPart:FindFirstChild("MeshSaveFile")
	local SaveData = {
		Vertices = {},
		Triangles = {}
	}

	for _, Vertex: Classes.Vertex in MeshCreator.Mesh.Vertices do
		local VertexSaveData = table.clone(Vertex)

		VertexSaveData.Parent = nil
		VertexSaveData.VertexUV = {VertexSaveData.VertexUV.X, VertexSaveData.VertexUV.Y}
		VertexSaveData.VA_Position = {Vertex.VertexAttachment.Position.X, Vertex.VertexAttachment.Position.Y, Vertex.VertexAttachment.Position.Z}
		VertexSaveData.VertexAttachment = nil
		
		for index, vertexNormal: Vector3 in VertexSaveData.VertexNormals do
			VertexSaveData.VertexNormals[index] = {vertexNormal.X, vertexNormal.Y, vertexNormal.Z}
		end

		table.insert(SaveData.Vertices, VertexSaveData)
	end

	for _, Triangle: Classes.Triangle in MeshCreator.Mesh.Triangles do
		local TriangleSaveData = table.clone(Triangle)
		--[[
		local TriangleVertexIDs = {}
		
		for _, TriangleVertex: Classes.Vertex in Triangle.TriangleVertices do
			table.insert(TriangleVertices, TableFunctions.GetVertexByVertexID(SaveData.Vertices, TriangleVertex.ID))
		end
		
		TriangleSaveData.VertexIDs = TriangleVertices
		]]

		TriangleSaveData.Parent = nil

		table.insert(SaveData.Triangles, TriangleSaveData)
	end
	task.synchronize()
	if not MeshSaveFile then
		MeshSaveFile = Instance.new("Configuration")
		MeshSaveFile.Name = "MeshSaveFile"
		MeshSaveFile.Parent = MeshCreator.MeshPart
	end
	
	MeshSaveFile:SetAttribute("Vertices", Zlib128.compress(HttpService:JSONEncode(SaveData.Vertices)))
	MeshSaveFile:SetAttribute("Triangles", Zlib128.compress(HttpService:JSONEncode(SaveData.Triangles)))
end

function SaveLoadSystem.LoadMeshSaveFile(MeshPart: MeshPart)
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

				for index, vertexNormal: {} in Vertex.VertexNormals do
					Vertex.VertexNormals[index] = Vector3.new(vertexNormal[1], vertexNormal[2], vertexNormal[3])
				end
			end
			
			return SaveData
		end
	end
end

return SaveLoadSystem