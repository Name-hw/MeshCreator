local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Root = script.Parent.Parent
local PluginToolbar = plugin:CreateToolbar("MeshCreator")
local PluginButton = PluginToolbar:CreateButton(
	"MeshCreator " .. script.Parent.Parent.Version.Value, --Text that will appear below button
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
local PluginMouse: PluginMouse = plugin:GetMouse()

--PluginActions(MeshTools)
local ExtrudeRegionAction: PluginAction = plugin:CreatePluginAction(
	"ExtrudeRegionAction",
	"MeshCreator_Extrude Region",
	"Extrude the triangle.",
	"rbxassetid://11295291707",
	true
)

local NewFaceFromVerticesAction: PluginAction = plugin:CreatePluginAction(
	"NewFaceFromVertices",
	"MeshCreator_New Face From Vertices",
	"Create New Face from Vertices"
)

--PluginMenus
local VertexMenu: PluginMenu = plugin:CreatePluginMenu(
	"VertexMenu",
	"Extrude Region"
)
VertexMenu:AddAction(NewFaceFromVerticesAction)

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
local MeshTools = require(Root.MeshTools)
local IsMeshPartSelected = false
local IsEdgeSelected = false
local IsTriangleSelected = false
local ToolBarGui, CurrentMeshCreator, SelectingObject, SelectingObjects, EACHCoroutine --EAConnectHandlingCoroutine
local LastSelectedEA: LineHandleAdornment

local SelectMode = {}
local CurrentTool = {}
local PreviousSetting: Types.Settings = {}
local HeldInputs = {}

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
		EditorGuiHandler.HeaderHandler.HeaderFrame.Visible = false
		EditorGuiHandler.ToolBarHandler.ToolBarFrame.Visible = false
		EditorGuiHandler.EditorGui.Enabled = false
		PluginMouse.TargetFilter = nil
		plugin:Deactivate()
		MeshSaveLoadSystem.Save(CurrentMeshCreator)
		CurrentMeshCreator:Remove()
		MeshTools.Disable()
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
		Selection:Set(Edge.VertexAttachments)
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
	MeshCreator.IsPluginEnabled = not MeshCreator.IsPluginEnabled
	
	PluginButton:SetActive(MeshCreator.IsPluginEnabled)
	
	if MeshCreator.IsPluginEnabled then
		Selection.SelectionChanged:Connect(function()
			if MeshCreator.IsPluginEnabled then
				SelectingObjects = Selection:Get()
				SelectingObject = SelectingObjects[1]
				
				if SelectingObject then
					if SelectingObject:IsA("MeshPart") and not IsMeshPartSelected then
						IsMeshPartSelected = true
						
						local MeshSaveFile = MeshSaveLoadSystem.LoadMeshSaveFile(SelectingObject)
						CurrentMeshCreator = MeshCreator.new(SelectingObject, MeshSaveFile, Settings, EditorGuiHandler)
						EditorGuiHandler.EditorGui.Enabled = MeshCreator.IsPluginEnabled
						--PluginMouse.TargetFilter = SelectingObject
						
						CurrentMeshCreator.MeshPart:SetAttribute("EditedByMeshCreator", true)
						
						if CurrentMeshCreator.EM:GetAttribute("NoMeshID") then
							CurrentMeshCreator:CreateCubeMesh(Vector3.one, Vector3.zero)
						end
						
						CurrentMeshCreator:AddVertexAttachments(MeshSaveFile)
						
						PluginGui.Enabled = MeshCreator.IsPluginEnabled
						EditorGuiHandler.HeaderHandler.HeaderFrame.Visible = MeshCreator.IsPluginEnabled
						EditorGuiHandler.ToolBarHandler.ToolBarFrame.Visible = MeshCreator.IsPluginEnabled

						if Settings["GizmoVisible"] then
							EACHCoroutine = task.spawn(EAConnectHandling)
						end
						
						if EditorGuiHandler.HeaderHandler.HeaderFrame:GetAttribute("SelectMode") then
							SetSelectMode(EditorGuiHandler.HeaderHandler.HeaderFrame:GetAttribute("SelectMode"))
						end

						SettingsHandler.SettingsFrame.AttributeChanged:Connect(OnSettingsChanged)
						EditorGuiHandler.HeaderHandler.HeaderFrame.AttributeChanged:Connect(OnHeaderChanged)
						EditorGuiHandler.ToolBarHandler.ToolBarFrame.AttributeChanged:Connect(OnToolChanged)
					end
					
					if CurrentMeshCreator then
						for _, SelectingObject in SelectingObjects do
							local IsSelectingObjectInLST --IsSelectingObjectInLastSelectedTriangle

							if CurrentMeshCreator.LastSelectedTriangle and table.find(CurrentMeshCreator.LastSelectedTriangle.VertexAttachments, SelectingObject) then
								IsSelectingObjectInLST = true
							else
								IsSelectingObjectInLST = false
							end

							if SelectingObject.Name == "VertexAttachment" and SelectMode ~= Enums.SelectMode.VertexMode then
								if not IsEdgeSelected and not IsSelectingObjectInLST then
									Selection:Set(Instance)
									MeshTools.Disable()
								end
							elseif SelectingObject.Parent == MeshCreator.EM:FindFirstChild("TriangleGizmoFolder") then
								IsTriangleSelected = true

								if CurrentMeshCreator.LastSelectedTriangle and SelectingObject ~= CurrentMeshCreator.LastSelectedTriangle.Triangle3D.Model and not HeldInputs[Enum.KeyCode.LeftShift] then
									for _, Triangle: Classes.Triangle in CurrentMeshCreator.SelectedTriangles do
										Triangle.Triangle3D:Set("Color", CurrentMeshCreator.MeshPart.Color)
									end

									MeshCreator:SelectTriangle(SelectingObject, false)
									MeshTools.Disable()
								else
									MeshCreator:SelectTriangle(SelectingObject, true)
								end

								if CurrentTool == Enums.Tool.ExtrudeRegionTool and not MeshTools.IsToolEnabled then
									MeshTools.Enable(CurrentMeshCreator, "ExtrudeRegionTool", CurrentMeshCreator.LastSelectedTriangle.Triangle3D.Model.PrimaryPart)
								end
							elseif CurrentMeshCreator.SelectedTriangles[1] and not IsSelectingObjectInLST and SelectingObject == CurrentMeshCreator.LastSelectedTriangle.Triangle3D.Model then
								print("Bug?")
								if IsTriangleSelected then
									Selection:Set({CurrentMeshCreator.LastSelectedTriangle.VertexAttachments[1],
									CurrentMeshCreator.LastSelectedTriangle.VertexAttachments[2],
									CurrentMeshCreator.LastSelectedTriangle.VertexAttachments[3],
									CurrentMeshCreator.LastSelectedTriangle.Triangle3D.Model})
								end
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
						
						for position, Triangle: Classes.Triangle in CurrentMeshCreator.SelectedTriangles do
							Triangle.Triangle3D:Set("Color", CurrentMeshCreator.MeshPart.Color)
							CurrentMeshCreator.SelectedTriangles[position] = nil
						end
						
						CurrentMeshCreator.LastSelectedTriangle = nil

						MeshTools.Disable()
					end
				end
			end
		end)

		PluginMouse.Button1Down:Connect(function()
			if CurrentMeshCreator then
				if PluginMouse.Target and not PluginMouse.Target.Locked and PluginMouse.Target.Parent.Name == "TriangleModel" then
					Selection:Add({PluginMouse.Target.Parent})
				else
					Selection:Set(Instance)
				end
			end
		end)
		--[[
		PluginMouse.DragEnter:Connect(function(instances)
			local Object = instances[1]
			print("DragEntered")
			if MeshTools.Tool.IsSphereGizmoClicked then
				CurrentMeshCreator.LastSelectedTriangle.Triangle3D.Model:TranslateBy(PluginMouse.Origin.Position)
			end
		end)
		]]
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

	--[[
	if input.UserInputType == Enum.UserInputType.MouseButton2 then

	end
	]]
end)

UIS.InputEnded:Connect(function(input)
	HeldInputs[input.KeyCode] = false

	--[[
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if MeshCreator.IsPluginEnabled then
			if SelectMode == Enums.SelectMode.VertexMode then
				VertexMenu:ShowAsync()
			end
		end
	end
	]]
end)

EditorGuiHandler.HeaderHandler.VertexMenuButton.MouseButton1Click:Connect(function()
	VertexMenu:ShowAsync()
end)

NewFaceFromVerticesAction.Triggered:Connect(function()
	if MeshCreator.IsPluginEnabled then
		local Vertices: {Classes.Vertex} = {}

		for _, SelectingObject: Instance | Attachment in SelectingObjects do
			assert(SelectingObject:IsA("Attachment"), "Please select only VertexAttachment.")

			table.insert(Vertices, TableFunctions.GetVertexFromVertexAttachment(MeshCreator.Mesh.Vertices, SelectingObject))
		end

		local NewTriangles = MeshCreator.Mesh:NewFaceFromVertices(Vertices)

		for _, Triangle: Classes.Triangle in NewTriangles do
			Triangle.Triangle3D:Transparency(1)
		end
	end
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
