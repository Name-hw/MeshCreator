local Selection = game:GetService("Selection")
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
local EditorGuiHandler = require(UIHandlers.EditorGuiHandler).new(CoreGui)
local lib = Root.lib
local IsPluginEnabled = false
local IsMeshPartSelected = false
local IsEdgeSelected = false
local IsTriangleSelected = false
local ToolBarGui, CurrentMeshCreator, SelectingObject, SelectingObjects, EACHCoroutine --EAConnectHandlingCoroutine
local LastSelectedEA: LineHandleAdornment
local LastSelectedTriangle: Classes.Triangle

local SelectMode = {}
local CurrentTool = {}
local PreviousSetting: Types.Settings = {}
local HeldInputs = {}
local SelectedTriangles: {Classes.Triangle} = {}

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
		EditorGuiHandler.EditorGui.Enabled = false
		plugin:Deactivate()
		MeshSaveLoadSystem.Save(CurrentMeshCreator)
		CurrentMeshCreator:Remove()
	end
end

local function SetSelectMode(newSelectModeName)
	SelectMode = Enums.SelectMode[newSelectModeName]
	
	if CurrentMeshCreator then
		CurrentMeshCreator.MeshGizmo:SetTPs_Visible(SelectMode == Enums.SelectMode.TriangleMode)
	end
end

local function SetCurrentTool(CurrentToolName)
	CurrentTool = Enums.Tool[CurrentToolName]
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
	for _, Edge: Classes.Edge in CurrentMeshCreator.Mesh.Edges do
		local EA = Edge.EdgeAdornment
		
		EA.MouseButton1Down:Connect(function()
			OnEAClicked(Edge)
		end)
	end
end

local function SelectTriangle(SelectingObject, IsShiftHeld)
	for _, Triangle: Classes.Triangle in CurrentMeshCreator.Mesh.Triangles do
		if SelectingObject == Triangle.Triangle3D.Model then
			if IsShiftHeld then
				Selection:Add(Triangle.VertexAttachments)
			else
				Selection:Set({Triangle.VertexAttachments[1], Triangle.VertexAttachments[2], Triangle.VertexAttachments[3], Triangle.Triangle3D.Model})
			end
			Triangle.Triangle3D:Set("BrickColor", BrickColor.new("Deep orange"))
			LastSelectedTriangle = Triangle
			
			table.insert(SelectedTriangles, Triangle)
		end
	end
end

local function OnSettingsChanged(attributeName)
	local Attribute = SettingsHandler.SettingsFrame:GetAttribute(attributeName)
	
	if Settings[attributeName] ~= PreviousSetting[attributeName] then
		if attributeName == "EA_Thickness" then
			if Settings["GizmoVisible"] then
				CurrentMeshCreator.MeshGizmo:SetEAs_Thickness(Attribute)
			end
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

		plugin:SetSetting(attributeName, Attribute)
		Settings[attributeName] = Attribute
		PreviousSetting[attributeName] = Attribute
	end
end

local function OnHeaderChanged(attributeName)
	local Attribute = EditorGuiHandler.HeaderHandler.HeaderFrame:GetAttribute(attributeName)

	if attributeName == "SelectMode" then
		SetSelectMode(Attribute)
	end
end

local function OnToolChanged(attributeName)
	local Attribute = EditorGuiHandler.ToolBarHandler.ToolBarFrame:GetAttribute(attributeName)
	
	if attributeName == "CurrentTool" then
		SetCurrentTool(Attribute)
	end
	
	plugin:Activate(false)
end

SetSelectMode("VertexMode")

PluginButton.Click:Connect(function()
	IsPluginEnabled = not IsPluginEnabled
	
	PluginButton:SetActive(IsPluginEnabled)
	
	if IsPluginEnabled then
		Selection.SelectionChanged:Connect(function()
			if IsPluginEnabled then
				local PluginMouse: PluginMouse = plugin:GetMouse()
				SelectingObjects = Selection:Get()
				SelectingObject = SelectingObjects[1]
				
				if SelectingObject then
					if SelectingObject:IsA("MeshPart") and not IsMeshPartSelected then
						IsMeshPartSelected = true
						
						local MeshSaveFile = MeshSaveLoadSystem.LoadMeshSaveFile(SelectingObject)
						CurrentMeshCreator = MeshCreator.new(SelectingObject, MeshSaveFile, Settings)
						PluginGui.Enabled = IsPluginEnabled
						EditorGuiHandler.EditorGui.Enabled = IsPluginEnabled
						
						CurrentMeshCreator.MeshPart:SetAttribute("EditedByMeshCreator", true)
						
						if CurrentMeshCreator.EM:GetAttribute("NoMeshID") then
							CurrentMeshCreator:CreateCubeMesh(Vector3.one, Vector3.zero)
						end
						
						CurrentMeshCreator:AddVertexAttachments(MeshSaveFile)
						
						for _, Vertex: Classes.Vertex in CurrentMeshCreator.Mesh.Vertices do
							local VertexID = Vertex.ID
							local VA = Vertex.VertexAttachment
							
							local function OnChanged(propertyName)
								local PropertyValue = VA[propertyName]
								
								if propertyName == "Position" then
									CurrentMeshCreator:SetVertexPosition(Vertex, PropertyValue)
									
									if Settings["GizmoVisible"] then
										CurrentMeshCreator.MeshGizmo:UpdateEA_PositionByVertexID(VertexID)
									end
									
									CurrentMeshCreator.MeshGizmo:UpdateTP_PositionByVertexID(VertexID)
								end
							end
							
							local function OnAncestryChanged()
								if Settings["GizmoVisible"] then
									CurrentMeshCreator.MeshGizmo:RemoveEdgeByVertexID(VertexID)
								end

								CurrentMeshCreator:RemoveTriangleByVertexID(VertexID)
								CurrentMeshCreator:RemoveVertex(Vertex)
							end
							
							VA.Changed:Connect(function(propertyName)
								task.spawn(OnChanged, propertyName)
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
						EditorGuiHandler.HeaderHandler.HeaderFrame.AttributeChanged:Connect(OnHeaderChanged)
						EditorGuiHandler.ToolBarHandler.ToolBarFrame.AttributeChanged:Connect(OnToolChanged)
					end
					
					for _, SelectingObject in SelectingObjects do
						local IsSelectingObjectInLST --IsSelectingObjectInLastSelectedTriangle

						if LastSelectedTriangle and table.find(LastSelectedTriangle.VertexAttachments, SelectingObject) then
							IsSelectingObjectInLST = true
						else
							IsSelectingObjectInLST = false
						end

						if SelectingObject.Name == "VertexAttachment" and SelectMode ~= Enums.SelectMode.VertexMode then
							if not IsEdgeSelected and not IsSelectingObjectInLST then
								Selection:Set(Instance)
							end
						elseif SelectingObject.Parent == workspace.Camera.MeshCreator_TriangleGizmoFolder then
							IsTriangleSelected = true
							
							if LastSelectedTriangle and SelectingObject ~= LastSelectedTriangle.Triangle3D.Model and not HeldInputs[Enum.KeyCode.LeftShift] then
								for _, Triangle: Classes.Triangle in SelectedTriangles do
									Triangle.Triangle3D:Set("Color", CurrentMeshCreator.MeshPart.Color)
								end

								SelectTriangle(SelectingObject, false)
							else
								SelectTriangle(SelectingObject, true)
								
								if CurrentTool == Enums.Tool.ExtrudeRegionTool then
									plugin:SelectRibbonTool(Enum.RibbonTool.Move, UDim2.new())
								end
							end
						elseif SelectedTriangles[1] and not IsSelectingObjectInLST and SelectingObject == LastSelectedTriangle.Triangle3D.Model then
							print(2)
							if IsTriangleSelected then
								Selection:Set({LastSelectedTriangle.VertexAttachments[1], LastSelectedTriangle.VertexAttachments[2], LastSelectedTriangle.VertexAttachments[3], LastSelectedTriangle.Triangle3D.Model})
							end
						end
					end
				else
					if IsEdgeSelected then
						IsEdgeSelected = false
						LastSelectedEA.Color3 = Color3.new(0.0509804, 0.411765, 0.67451)
					end
					
					if IsTriangleSelected then
						IsTriangleSelected = false
						
						for position, Triangle: Classes.Triangle in SelectedTriangles do
							Triangle.Triangle3D:Set("Color", CurrentMeshCreator.MeshPart.Color)
							SelectedTriangles[position] = nil
						end
						
						LastSelectedTriangle = nil
					end
				end
				
				PluginMouse.Button1Down:Connect(function()
					if CurrentMeshCreator then
						--[[
						if CurrentTool == Enums.Tool.AddVertexTool then
							CurrentMeshCreator:AddVertex(PluginMouse.Hit.Position)
							print("ToolActivated")
						end
						]]
						if CurrentTool == Enums.Tool.AddVertexTool then
							--CurrentMeshCreator:AddVertex(PluginMouse.Hit.Position)
							print("ToolActivated")
						end
					end
				end)
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

UIS.InputBegan:Connect(function(input)
	HeldInputs[input.KeyCode] = true
end)

UIS.InputEnded:Connect(function(input)
	HeldInputs[input.KeyCode] = false
end)

plugin.Deactivation:Connect(function()
	if EditorGuiHandler then
		plugin:Deactivate()
		EditorGuiHandler.ToolBarHandler:DisableAllToolButton()
	end
end)

plugin.Unloading:Connect(PluginExit)

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
