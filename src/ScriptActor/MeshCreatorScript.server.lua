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
--[[
local Vendor = Root.Vendor
local Roact = require(Vendor.Roact)
]]
local UI = Root.UI
--local MeshExplorer = require(UI.MeshExplorer)
local Classes = require(Root.Classes)
local MeshCreator = require(Root.MeshCreator)
local MeshSaveLoadSystem = require(Root.MeshSaveLoadSystem)
local lib = Root.lib
local IsPluginEnabled = false
local IsAddSquareMeshButtonEnabled = false
local IsMeshPartSelected = false
local VertexPositions = {}
local ToolBarGui, CurrentMeshCreator, SelectingObject

if game:GetService("ReplicatedFirst"):FindFirstChild("MeshCreator_MeshLoaderActor") then
	game:GetService("ReplicatedFirst"):FindFirstChild("MeshCreator_MeshLoaderActor"):Destroy()
end

local MeshLoaderActorClone = Root.MeshLoaderActor:Clone()
MeshLoaderActorClone.Name = "MeshCreator_MeshLoaderActor"
MeshLoaderActorClone.Parent = game.ReplicatedFirst

function PluginExit()
	if CurrentMeshCreator then
		IsMeshPartSelected = false
		MeshSaveLoadSystem.Save(CurrentMeshCreator)
		CurrentMeshCreator = CurrentMeshCreator:Remove()
	end
	task.synchronize()
	--Roact.unmount(ToolBarGui)
end

PluginButton.Click:Connect(function()
	IsPluginEnabled = not IsPluginEnabled;
	
	PluginButton:SetActive(IsPluginEnabled);
	
	if IsPluginEnabled then
		--ToolBarGui = Roact.mount(Roact.createElement(MeshExplorer), PluginGui)
		
		Selection.SelectionChanged:Connect(function()
			if IsPluginEnabled then
				SelectingObject = Selection:Get()[1]
				
				if SelectingObject then
					if SelectingObject:IsA("MeshPart") and not IsMeshPartSelected then
						IsMeshPartSelected = true
						
						local MeshSaveFile = MeshSaveLoadSystem.LoadMeshSaveFile(SelectingObject)
						CurrentMeshCreator = MeshCreator.new(SelectingObject, MeshSaveFile)
						
						if CurrentMeshCreator.EM:GetAttribute("CustomMesh") then
							CurrentMeshCreator.MeshPart.Size = Vector3.new(1, 1, 1)
							--CurrentMeshCreator:CreatePlaneMesh(5, 5, Vector3.new(0, 5, 0), Vector3.new(0, 10, 0))
							--CurrentMeshCreator:CreateCubeMesh(Vector3.new(1, 1, 1), Vector3.zero)
						end
						
						CurrentMeshCreator:AddVertexAttachments(MeshSaveFile)
						
						for _, Vertex: Classes.Vertex in CurrentMeshCreator.Vertices do
							local VertexID = Vertex.ID
							local VA = Vertex.VertexAttachment
							
							local function OnChanged(property)
								if property == "Position" then
									CurrentMeshCreator.MeshGizmo:UpdateByVertexID(CurrentMeshCreator.Vertices, VertexID)
									CurrentMeshCreator:SetVertexPosition(VertexID, VA.Position)
								end
							end
							
							local function OnAncestryChanged()
								CurrentMeshCreator:RemoveTriangleByVertexID(VertexID)
								CurrentMeshCreator.MeshGizmo:RemoveEdgeByVertexID(VertexID)
								CurrentMeshCreator:RemoveVertex(Vertex)
							end
							
							VA.Changed:Connect(function(property)
								task.spawn(OnChanged, property)
							end)
							
							VA.AncestryChanged:Connect(function()
								if IsPluginEnabled then
									task.spawn(OnAncestryChanged)
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
--[[
RunService.PostSimulation:Connect(function()
	if CurrentMeshCreator and CurrentMeshCreator.MeshGizmo then
		for _, Vertex: Classes.Vertex in CurrentMeshCreator.Vertices do
			if Vertex.VertexAttachment.Position ~= VertexPositions[Vertex.ID] then
				CurrentMeshCreator.MeshGizmo:UpdateByVertexID(CurrentMeshCreator.Vertices, Vertex.ID)
			end
			
			VertexPositions[Vertex.ID] = Vertex.VertexAttachment.Position
			task.synchronize()
		end
	end
end)
]]
