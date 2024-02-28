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
	350, --default weight
	500, --default height
	350, --minimum weight (optional)
	500 --minimum height (optional)
)
local PluginGui = plugin:CreateDockWidgetPluginGui("MeshCreatorPlugin", PluginGuiInfo)
PluginGui.Name = "MeshCreator"
PluginGui.Title = "MeshCreator"
local Classes = require(Root.Classes)
local Enums = require(Root.Enums)
local Types = require(Root.Types)
local Settings: Types.Settings = {
	EA_Thickness = plugin:GetSetting("EA_Thickness"),
	GizmoVisible = plugin:GetSetting("GizmoVisible")
}
local DefaultSettings: Types.Settings = {
	EA_Thickness = 5,
	GizmoVisible = true
}
local TableFunctions = require(Root.TableFunctions)
local MeshCreator = require(Root.MeshCreator)
local MeshSaveLoadSystem = require(Root.MeshSaveLoadSystem)
local UIHandlers = Root.UIHandlers
--local MeshExplorer = require(UI.MeshExplorer)
local SettingsHandler = require(UIHandlers.SettingsHandler).new(PluginGui, Settings, DefaultSettings)
local lib = Root.lib
local IsPluginEnabled = false
local IsMeshPartSelected = false
local IsEdgeSelected = false
local ToolBarGui, CurrentMeshCreator, SelectingObject, SelectingObjects, EACHCoroutine, Connection: RBXScriptConnection --EAConnectHandlingCoroutine
local LastSelectedEA: LineHandleAdornment

local SelectMode = {}
local PreviousSetting: Types.Settings = {}

if game:GetService("ReplicatedFirst"):FindFirstChild("MeshCreator_MeshLoaderActor") then
	game:GetService("ReplicatedFirst"):FindFirstChild("MeshCreator_MeshLoaderActor"):Destroy()
end

local MeshLoaderActorClone = Root.MeshLoaderActor:Clone()
MeshLoaderActorClone.Name = "MeshCreator_MeshLoaderActor"
MeshLoaderActorClone.Parent = game.ReplicatedFirst

local function PluginExit()
	if CurrentMeshCreator then
		IsMeshPartSelected = false
		PluginGui.Enabled = false
		MeshSaveLoadSystem.Save(CurrentMeshCreator)
		CurrentMeshCreator:Remove()
	end
end

local function SetSelectMode(newSelectMode)
	SelectMode = Enums.SelectMode[newSelectMode]
end

local function OnEAClicked(Edge: Classes.Edge)
	local EA = Edge.EdgeAdornment

	if SelectMode == Enums.SelectMode.EdgeMode and not IsEdgeSelected then
		Selection:Set({Edge.StartVertexAttachment, Edge.EndVertexAttachment})
		EA.Color3 = Color3.new(1, 0.584314, 0)
		IsEdgeSelected = true
		LastSelectedEA = EA
	end
end

local function EAConnectHandling()
	for _, Edge: Classes.Edge in CurrentMeshCreator.MeshGizmo.Edges do
		local EA = Edge.EdgeAdornment
		
		EA.MouseButton1Down:Connect(function()
			OnEAClicked(Edge)
		end)
	end
end

local function OnSettingsChanged(attributeName)
	local Attribute = SettingsHandler.SettingsFrame:GetAttribute(attributeName)
	
	if Settings[attributeName] ~= PreviousSetting[attributeName] then
		plugin:SetSetting(attributeName, Attribute)
		Settings[attributeName] = Attribute

		if attributeName == "EA_Thickness" then
			if Settings["GizmoVisible"] then
				CurrentMeshCreator.MeshGizmo:SetEAs_Thickness(Attribute)
			end
		elseif attributeName == "SelectMode" then
			SetSelectMode(Attribute)
		elseif attributeName == "GizmoVisible" then
			if CurrentMeshCreator then
				CurrentMeshCreator.MeshGizmo:SetEAs_Visible(Attribute)
			end

			if Attribute then
				EACHCoroutine = task.spawn(EAConnectHandling)
			elseif not Attribute and EACHCoroutine then
				coroutine.close(EACHCoroutine)
			end
		end

		PreviousSetting[attributeName] = Attribute
	end
end

SetSelectMode("VertexMode")

PluginButton.Click:Connect(function()
	IsPluginEnabled = not IsPluginEnabled
	
	PluginButton:SetActive(IsPluginEnabled)
	
	if IsPluginEnabled then
		Selection.SelectionChanged:Connect(function()
			if IsPluginEnabled then
				SelectingObjects = Selection:Get()
				SelectingObject = SelectingObjects[1]
				
				if SelectingObject then
					if SelectingObject:IsA("MeshPart") and not IsMeshPartSelected then
						IsMeshPartSelected = true
						
						local MeshSaveFile = MeshSaveLoadSystem.LoadMeshSaveFile(SelectingObject)
						CurrentMeshCreator = MeshCreator.new(SelectingObject, MeshSaveFile, Settings)
						PluginGui.Enabled = IsPluginEnabled
						
						if CurrentMeshCreator.EM:GetAttribute("CustomMesh") then
							--CurrentMeshCreator.MeshPart.Size = Vector3.new(1, 1, 1)
							--CurrentMeshCreator:CreatePlaneMesh(5, 5, Vector3.new(0, 5, 0), Vector3.new(0, 10, 0))
							--CurrentMeshCreator:CreateCubeMesh(Vector3.new(1, 1, 1), Vector3.zero)
						end
						
						CurrentMeshCreator:AddVertexAttachments(MeshSaveFile)
						
						for _, Vertex: Classes.Vertex in CurrentMeshCreator.Vertices do
							local VertexID = Vertex.ID
							local VA = Vertex.VertexAttachment
							
							local function OnChanged(property)
								if property == "Position" then
									if Settings["GizmoVisible"] then
										CurrentMeshCreator.MeshGizmo:UpdateEA_PositionByVertexID(CurrentMeshCreator.Vertices, VertexID)
									end

									CurrentMeshCreator:SetVertexPosition(VertexID, VA.Position)
								end
							end
							
							local function OnAncestryChanged()
								if Settings["GizmoVisible"] then
									CurrentMeshCreator.MeshGizmo:RemoveEdgeByVertexID(VertexID)
								end

								CurrentMeshCreator:RemoveTriangleByVertexID(VertexID)
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
						
						if Settings["GizmoVisible"] then
							EACHCoroutine = task.spawn(EAConnectHandling)
						end
						
						SettingsHandler.SettingsFrame.AttributeChanged:Connect(OnSettingsChanged)
					end
					
					for _, object in SelectingObjects do
						if SelectingObject.Name == "VertexAttachment" and SelectMode ~= Enums.SelectMode.VertexMode then
							if SelectMode ~= Enums.SelectMode.VertexMode and not IsEdgeSelected then
								Selection:Set(Instance)
							end
						end
					end
				else
					if IsEdgeSelected then
						IsEdgeSelected = false
						LastSelectedEA.Color3 = Color3.new(0.0509804, 0.411765, 0.67451)
					end
				end
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

game.Close:Connect(PluginExit)
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
