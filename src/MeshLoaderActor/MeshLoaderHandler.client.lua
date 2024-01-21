local RunService = game:GetService("RunService")
local MeshLoader = require(script.Parent.MeshLoader)


function LoadMesh(MeshPart: MeshPart)
	MeshLoader.new(MeshPart, MeshLoader.LoadMeshSaveFile(MeshPart))
	
	MeshPart.ChildAdded:ConnectParallel(function(child)
		if child:IsA("Configuration") then
			LoadMeshFromMeshSaveFile(child)
		end
	end)
end

function LoadMeshFromMeshSaveFile(MeshSaveFile: Configuration)
	LoadMesh(MeshSaveFile.Parent)
end

for _, child in workspace:GetDescendants() do
	if child:IsA("MeshPart") then
		LoadMesh(child)
	end
end