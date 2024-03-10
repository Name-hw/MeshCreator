local RunService = game:GetService("RunService")
local MeshLoader = require(script.Parent.MeshLoader)

function OnMeshAdded(child)
	if child:IsA("MeshPart") then
		LoadMesh(child)
	end
end

function OnMeshSaveFileAdded(child)
	if child.Name == "MeshSaveFile" then
		LoadMeshFromMeshSaveFile(child)
	end
end

function LoadMesh(MeshPart: MeshPart)
	if MeshPart:FindFirstChildOfClass("EditableMesh") then
		MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
	end

	MeshLoader.new(MeshPart, MeshLoader.LoadMeshSaveFile(MeshPart))

	MeshPart.ChildAdded:Connect(OnMeshSaveFileAdded)
end

function LoadMeshFromMeshSaveFile(MeshSaveFile: Configuration)
	local MeshPart = MeshSaveFile.Parent
	
	if MeshPart:FindFirstChildOfClass("EditableMesh") then
		MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
	end

	MeshLoader.new(MeshPart, MeshLoader.LoadMeshSaveFile(MeshPart))
end

if RunService:IsRunning() and not plugin then
	workspace.DescendantAdded:Connect(OnMeshAdded)
elseif RunService:IsEdit() and plugin then
	for _, child in workspace:GetDescendants() do
		OnMeshAdded(child)
	end

	workspace.DescendantAdded:Connect(OnMeshAdded)
end