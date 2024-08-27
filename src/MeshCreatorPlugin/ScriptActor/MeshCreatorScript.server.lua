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

--PluginActions
--[[
local ExtrudeRegionAction: PluginAction = plugin:CreatePluginAction(
	"MeshCreator_ExtrudeRegionAction",
	"Extrude Region",
	"Extrude the triangle.",
	"rbxassetid://11295291707",
	true
)
]]
local NewFaceFromVerticesAction: PluginAction = plugin:CreatePluginAction(
	"MeshCreator_NewFaceFromVertices",
	"New Face From Vertices",
	"Create New Face from Vertices"
)
local DeleteVerticesAction: PluginAction = plugin:CreatePluginAction(
	"MeshCreator_DeleteVertices",
	"Delete Vertices",
	"Delete Vertices"
)
local DeleteEdgesAction: PluginAction = plugin:CreatePluginAction(
	"MeshCreator_DeleteEdges",
	"Delete Edges",
	"Delete Edges"
)
local DeleteTrianglesAction: PluginAction = plugin:CreatePluginAction(
	"MeshCreator_DeleteTriangles",
	"Delete Triangles",
	"Delete Triangles"
)

--PluginMenus
local VertexMenu: PluginMenu = plugin:CreatePluginMenu(
	"VertexMenu",
	"Vertex Menu"
)
VertexMenu:AddAction(NewFaceFromVerticesAction)
VertexMenu:AddAction(DeleteVerticesAction)
local EdgeMenu: PluginMenu = plugin:CreatePluginMenu(
	"EdgeMenu",
	"Edge Menu"
)
EdgeMenu:AddAction(DeleteEdgesAction)
local TriangleMenu: PluginMenu = plugin:CreatePluginMenu(
	"TriangleMenu",
	"Triangle Menu"
)
TriangleMenu:AddAction(DeleteTrianglesAction)

local Classes = require(Root.Classes)
local Enums = require(Root.Enums)
local Types = require(Root.Types)
local Settings: Types.Settings = {
	EA_Thickness = plugin:GetSetting("EA_Thickness"),
	EdgeVisible = plugin:GetSetting("EdgeVisible")
}
local DefaultSettings: Types.Settings = {
	EA_Thickness = 5,
	EdgeVisible = true
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
local CurrentMeshCreator, SelectingObject, SelectingObjects, EACHCoroutine --EAConnectHandlingCoroutine
local LastSelectedEA: LineHandleAdornment

local SelectMode = {}
local PreviousSetting: Types.Settings = {}
local HeldInputs = {}
local Connections: {RBXScriptConnection} = {}

if game:GetService("ReplicatedFirst"):FindFirstChild("MeshCreator_MeshLoaderActor") then
	game:GetService("ReplicatedFirst"):FindFirstChild("MeshCreator_MeshLoaderActor"):Destroy()
end

--local MeshLoaderActorClone = Root.MeshLoaderActor:Clone()
--MeshLoaderActorClone.Name = "MeshCreator_MeshLoaderActor"
--MeshLoaderActorClone.Parent = game.ReplicatedFirst

local function PluginExit()
	if CurrentMeshCreator then
		IsMeshPartSelected = false
		PluginGui.Enabled = false
		EditorGuiHandler.HeaderHandler.HeaderFrame.Visible = false
		EditorGuiHandler.ToolBarHandler.ToolBarFrame.Visible = false
		EditorGuiHandler.EditorGui.Enabled = false
		EditorGuiHandler.ToolBarHandler:DisableAllToolButton()
		task.wait()
		for _, connection: RBXScriptConnection in Connections do
			connection:Disconnect()
		end

		MeshSaveLoadSystem.Save(CurrentMeshCreator)
		CurrentMeshCreator:Remove()
		plugin:Deactivate()
	end
end

local function SetSelectMode(newSelectModeName)
	SelectMode = Enums.SelectMode[newSelectModeName]
	
	if CurrentMeshCreator then
		CurrentMeshCreator.MeshGizmo:SetTPs_Visible(SelectMode == Enums.SelectMode.TriangleMode)
	end
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
			if Settings["EdgeVisible"] then
				CurrentMeshCreator.MeshGizmo:SetEAs_Thickness(Attribute)
			end
		elseif attributeName == "EdgeVisible" then
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

local function OnToolBarChanged(attributeName: string)
	local Attribute = EditorGuiHandler.ToolBarHandler.ToolBarFrame:GetAttribute(attributeName)
	
	if attributeName == "CurrentTool" then
		if Attribute == "" and MeshTools.IsToolEnabled then
			MeshTools.Disable()
		elseif Attribute ~= "" then
			plugin:Activate(false)
			MeshTools.Enable(CurrentMeshCreator, Enums.ToolType[Attribute], plugin:GetMouse())
		end
	end
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

						CurrentMeshCreator.MeshPart:SetAttribute("EditedByMeshCreator", true)
						
						if CurrentMeshCreator.EM:GetAttribute("NoMeshID") then
							CurrentMeshCreator:CreateCubeMesh(Vector3.one, Vector3.zero)
						end
						
						CurrentMeshCreator:AddVertexAttachments(MeshSaveFile)
						
						PluginGui.Enabled = MeshCreator.IsPluginEnabled
						EditorGuiHandler.HeaderHandler.HeaderFrame.Visible = MeshCreator.IsPluginEnabled
						EditorGuiHandler.ToolBarHandler.ToolBarFrame.Visible = MeshCreator.IsPluginEnabled

						if Settings["EdgeVisible"] then
							EACHCoroutine = task.spawn(EAConnectHandling)
						end
						
						if EditorGuiHandler.HeaderHandler.HeaderFrame:GetAttribute("SelectMode") then
							SetSelectMode(EditorGuiHandler.HeaderHandler.HeaderFrame:GetAttribute("SelectMode"))
						end

						table.insert(Connections, SettingsHandler.SettingsFrame.AttributeChanged:Connect(OnSettingsChanged))
						table.insert(Connections, EditorGuiHandler.HeaderHandler.HeaderFrame.AttributeChanged:Connect(OnHeaderChanged))
						table.insert(Connections, EditorGuiHandler.ToolBarHandler.ToolBarFrame.AttributeChanged:Connect(OnToolBarChanged))
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
								if not IsEdgeSelected and not IsSelectingObjectInLST and not CurrentMeshCreator.IsTriangleSelected then
									Selection:Set(Instance)
								end
							end

							if SelectingObject == CurrentMeshCreator.MeshPart then
								Selection:Remove({SelectingObject})
							end
						end
					end
				elseif CurrentMeshCreator then
					if IsEdgeSelected then
						IsEdgeSelected = false
						LastSelectedEA.Color3 = Color3.new(0.0509804, 0.411765, 0.67451)
					end
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
	else
		PluginExit()
	end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	HeldInputs[input.KeyCode] = true
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
	HeldInputs[input.KeyCode] = false

	if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
		if CurrentMeshCreator then
			local mousePosition = UIS:GetMouseLocation()

        	-- 화면 좌표를 월드 좌표로 변환하여 레이케스트 시작점과 방향을 얻기
        	local unitRay = workspace.Camera:ScreenPointToRay(mousePosition.X, mousePosition.Y)

       	 	-- RaycastParameters 설정
        	local raycastParams = RaycastParams.new()
        	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
       	 	raycastParams.FilterDescendantsInstances = {CurrentMeshCreator.MeshPart}

        	-- 레이캐스트 시작점과 방향
       		local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams)
			local Target = raycastResult.Instance

			if Target then
				if SelectMode == Enums.SelectMode.TriangleMode then
					if Target.Parent.Name == "TriangleModel" then
						local TriangleModel = Target.Parent
		
						for _, Triangle in ipairs(CurrentMeshCreator.Mesh.Triangles) do
							local isSelected = TriangleModel == Triangle.Triangle3D.Model and not table.find(CurrentMeshCreator.SelectedTriangles, Triangle)
		
							if isSelected then
								local isMultipleSelection = HeldInputs[Enum.KeyCode.LeftShift]
	
								Triangle:SelectTriangle(isMultipleSelection)
	
								break
							end
						end
					elseif CurrentMeshCreator.IsTriangleSelected then
						for _, Triangle: Classes.Triangle in CurrentMeshCreator.SelectedTriangles do
							Triangle.Triangle3D:Set("Color", CurrentMeshCreator.MeshPart.Color)
						end

						CurrentMeshCreator.SelectedTriangles = {}

						Selection:Set({})

						CurrentMeshCreator.IsTriangleSelected = false
						CurrentMeshCreator.LastSelectedTriangle = nil
					end
				end
			end
		end
	end
end)

EditorGuiHandler.HeaderHandler.VertexMenuButton.MouseButton1Click:Connect(function()
	VertexMenu:ShowAsync()
end)

EditorGuiHandler.HeaderHandler.EdgeMenuButton.MouseButton1Click:Connect(function()
	EdgeMenu:ShowAsync()
end)

EditorGuiHandler.HeaderHandler.TriangleMenuButton.MouseButton1Click:Connect(function()
	TriangleMenu:ShowAsync()
end)

NewFaceFromVerticesAction.Triggered:Connect(function()
	local Vertices: {Classes.Vertex} = {}

	for _, SelectingObject: Instance | Attachment in SelectingObjects do
		assert(SelectingObject:IsA("Attachment"), "Please select only VertexAttachment.")

		table.insert(Vertices, TableFunctions.GetVertexFromVertexAttachment(MeshCreator.Mesh.Vertices, SelectingObject))
	end
	
	assert((#Vertices <= 4), "Please select 4 or fewer vertices.")

	local NewTriangles = MeshCreator.Mesh:NewFaceFromVertices(Vertices)

	for _, Triangle: Classes.Triangle in NewTriangles do
		Triangle.Triangle3D:Transparency(1)
	end
end)

DeleteVerticesAction.Triggered:Connect(function()
	for _, SelectingObject: Instance | Attachment in SelectingObjects do
		if SelectingObject:IsA("Attachment") then
			TableFunctions.GetVertexFromVertexAttachment(MeshCreator.Mesh.Vertices, SelectingObject):Destroy()
		end
	end
end)

DeleteEdgesAction.Triggered:Connect(function()
	if IsEdgeSelected then
		for _, Edge: Classes.Edge in CurrentMeshCreator.Mesh.Edges do
			if Edge.EdgeAdornment == LastSelectedEA then
				Edge:Destroy()
			end
		end
	end
end)

DeleteTrianglesAction.Triggered:Connect(function()
	for _, Triangle: Classes.Triangle in CurrentMeshCreator.SelectedTriangles do
		Triangle:Destroy()
	end

	CurrentMeshCreator.SelectedTriangles = {}
end)

plugin.Unloading:Connect(PluginExit)

game.Close:Connect(PluginExit)