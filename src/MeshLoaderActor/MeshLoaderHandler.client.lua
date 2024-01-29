local RunService = game:GetService("RunService")
local MeshLoader = require(script.Parent.MeshLoader)

function LoadMesh(MeshPart: MeshPart)
	if MeshPart:FindFirstChildOfClass("EditableMesh") then
		MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
	end
	
	MeshLoader.new(MeshPart, MeshLoader.LoadMeshSaveFile(MeshPart))
	
	MeshPart.ChildAdded:Connect(function(child)
		if child.Name == "MeshSaveFile" then
			LoadMeshFromMeshSaveFile(child)
		end
	end)
end

function LoadMeshFromMeshSaveFile(MeshSaveFile: Configuration)
	LoadMesh(MeshSaveFile.Parent)
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end

for _, child in workspace:GetDescendants() do
	if child:IsA("MeshPart") then
		LoadMesh(child)
	end
end