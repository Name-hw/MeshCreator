local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local AssetService = game:GetService("AssetService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Root = script.Parent.Parent
local PluginToolbar = plugin:CreateToolbar("MeshCreator")
local PluginButton = PluginToolbar:CreateButton(
	"Mesh Creator", --Text that will appear below button
	"MeshCreator by 396255584(ID)", --Text that will appear if you hover your mouse on button
	"rbxassetid://15797735617" --Button icon
)
local PluginGuiInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float, --From what side gui appears
	false, --Widget will be initially enabled
	false, --Don't overdrive previouse enabled state
	200, --default weight
	300, --default height
	200, --minimum weight (optional)
	200 --minimum height (optional)
)
local PluginGui = plugin:CreateDockWidgetPluginGui("MeshCreatorPlugin", PluginGuiInfo)
PluginGui.Name = "MeshCreator"
PluginGui.Title = "MeshCreator"
local Vender = Root.Vender
local Roact = require(Vender.Roact)
local UI = Root.UI
local MeshExplorer = require(UI.MeshExplorer)
local MeshCreator = require(Root.MeshCreator)
local Classes = require(Root.MeshCreator.Classes)
local MeshSaveLoadSystem = require(Root.MeshSaveLoadSystem)
local IsPluginEnabled = false
local IsAddSquareMeshButtonEnabled = false
local IsMeshPartSelected = false
local ToolBarGui, CurrentMeshCreator, SelectingObject

if game.StarterPlayer.StarterPlayerScripts:FindFirstChild("MeshCreator_MeshLoaderActor") then
	game.StarterPlayer.StarterPlayerScripts:FindFirstChild("MeshCreator_MeshLoaderActor"):Destroy()
end

local MeshLoaderActorClone = Root.MeshLoaderActor:Clone()
MeshLoaderActorClone.Name = "MeshCreator_MeshLoaderActor"
MeshLoaderActorClone.Parent = game.StarterPlayer.StarterPlayerScripts

function PluginExit()
	if CurrentMeshCreator then
		IsMeshPartSelected = false
		MeshSaveLoadSystem.Save(CurrentMeshCreator)
		CurrentMeshCreator = CurrentMeshCreator:Remove()
	end
	task.synchronize()
	Roact.unmount(ToolBarGui)
end

PluginButton.Click:Connect(function()
	IsPluginEnabled = not IsPluginEnabled;
	
	PluginButton:SetActive(IsPluginEnabled);
	
	if IsPluginEnabled then
		ToolBarGui = Roact.mount(Roact.createElement(MeshExplorer), PluginGui)
		
		Selection.SelectionChanged:Connect(function()
			if IsPluginEnabled then
				SelectingObject = Selection:Get()[1]
				
				if SelectingObject then
					if SelectingObject:IsA("MeshPart") and not IsMeshPartSelected then
						IsMeshPartSelected = true
						CurrentMeshCreator = MeshCreator.new(SelectingObject, MeshSaveLoadSystem.LoadMeshSaveFile(SelectingObject))
						
						if CurrentMeshCreator.EM:GetAttribute("CustomMesh") then
							CurrentMeshCreator.MeshPart.Size = Vector3.new(1, 1, 1)
							--CurrentMeshCreator:CreatePlaneMesh(5, 5, Vector3.new(0, 5, 0), Vector3.new(0, 10, 0))
							--CurrentMeshCreator:CreateCubeMesh(Vector3.new(1, 1, 1), Vector3.zero)
						end
						
						CurrentMeshCreator:AddVertexAttachments()
						
						for _, Vertex: Classes.Vertex in ipairs(CurrentMeshCreator.Vertices) do
							local VertexID = Vertex.VertexID
							local VA = Vertex.VertexAttachment
							
							VA.Changed:Connect(function(property)
								if property == "Position" then
									CurrentMeshCreator:SetVertexPosition(VertexID, VA.Position)
								end
							end)
							
							VA.AncestryChanged:Connect(function()
								if IsPluginEnabled then
									CurrentMeshCreator:RemoveVertex(Vertex)
								end
							end)
						end
					end
				end
			elseif CurrentMeshCreator and IsMeshPartSelected then
				IsMeshPartSelected = false
				MeshSaveLoadSystem.Save(CurrentMeshCreator)
				CurrentMeshCreator = CurrentMeshCreator:Remove()
			end
		end)
		--[[
		UIS.InputEnded:ConnectParallel(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				PluginExit()
			end
		end)
		]]
	else
		PluginExit()
	end
end)