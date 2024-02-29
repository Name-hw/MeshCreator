local Root = script.Parent.Parent
local Version = Root.Version.Value
local s = "[MeshCreator] - "

local function CheckBetaFeatureEnabled()
	local EM = Instance.new("EditableMesh")

	EM:AddVertex(Vector3.one)
end

Root.ScriptActor.MeshCreatorScript.Enabled = false
Root.MeshLoaderActor.MeshLoaderHandler.Enabled = false

print(s .. Version)

if pcall(CheckBetaFeatureEnabled) then
	Root.ScriptActor.MeshCreatorScript.Enabled = true
	Root.MeshLoaderActor.MeshLoaderHandler.Enabled = true
else
	Root.ScriptActor.MeshCreatorScript.Enabled = false
	Root.MeshLoaderActor.MeshLoaderHandler.Enabled = false
	warn(s .. "Please enable EditableImage and EditableMesh in the beta features.")
end