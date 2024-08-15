--!strict
local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")
local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local Enums = require(Root.Enums)

export type BaseMeshTool = {
    __index: BaseMeshTool,
    Adornee: BasePart?,
    PluginMouse: PluginMouse?,
    ArrowGizmo: Handles?,
    SphereGizmo: SphereHandleAdornment?,
    SelectedElement: Classes.GeometryElement?,
    ToolGizmoFolder: Folder,
    MeshCreator: any,
    IsArrowGizmo_MouseEntered: boolean,
    IsArrowGizmo_MouseClicked: boolean,
    Connections: {RBXScriptConnection},
    Enable: (self: typeof(setmetatable({}::BaseMeshTool, {}::any)), MeshCreator: any, pluginMouse: PluginMouse) -> (),
    CreateArrowGizmo: (self: typeof(setmetatable({}::BaseMeshTool, {}::any)), adornee: BasePart | nil) -> (),
    CreateSphereGizmo: (self: typeof(setmetatable({}::BaseMeshTool, {}::any)), adornee: BasePart | nil) -> (),
    ChangeAdornee: (self: typeof(setmetatable({}::BaseMeshTool, {}::any)), adornee: BasePart | nil) -> (),
    DestroyGizmo: (self: typeof(setmetatable({}::BaseMeshTool, {}::any))) -> (),
    Disable: (self: typeof(setmetatable({}::BaseMeshTool, {}::any))) -> ()
}

local BaseMeshTool = {} :: BaseMeshTool
BaseMeshTool.__index = BaseMeshTool

BaseMeshTool.ToolGizmoFolder = CoreGui:FindFirstChild("MeshCreator_ToolGizmoFolder") or Instance.new("Folder", CoreGui)
BaseMeshTool.ToolGizmoFolder.Name = "MeshCreator_ToolGizmoFolder"

function BaseMeshTool:CreateArrowGizmo()
    self.ArrowGizmo = Instance.new("Handles", self.ToolGizmoFolder)
    self.ArrowGizmo.Name = "ToolGizmoHandles"
    self.ArrowGizmo.Style = Enum.HandlesStyle.Movement
    self.ArrowGizmo.Adornee = self.Adornee
    self.ArrowGizmo.Faces = Faces.new(Enum.NormalId.Right)
    print("ArrowGizmo")
end

function BaseMeshTool:CreateSphereGizmo()
    self.SphereGizmo = Instance.new("SphereHandleAdornment", self.ToolGizmoFolder)
    self.SphereGizmo.Name = "ToolGizmoHandles"
    self.SphereGizmo.Adornee = self.Adornee
    self.SphereGizmo.AlwaysOnTop = true
    self.SphereGizmo.Color3 = Color3.new(0.5, 0.5, 0.5)
    self.SphereGizmo.Transparency = 0.5
    self.SphereGizmo.Radius = 5
    self.SphereGizmo.ZIndex = 1
end

function BaseMeshTool:ChangeAdornee(adornee)
    self.Adornee = adornee

    if self.ArrowGizmo then
        self.ArrowGizmo.Adornee = self.Adornee
    end

    if self.SphereGizmo then
        self.SphereGizmo.Adornee = self.Adornee
    end
end

function BaseMeshTool:DestroyGizmo()
    if self.ArrowGizmo then
        self.ArrowGizmo:Destroy()
    end

    if self.SphereGizmo then
        self.SphereGizmo:Destroy()
    end

    self.ArrowGizmo = nil
    self.SphereGizmo = nil
end

function BaseMeshTool:Enable(MeshCreator, pluginMouse)
    local IsSelectedObjectExists = false
    self.MeshCreator = MeshCreator

    if MeshCreator.LastSelectedTriangle then
        self.SelectedElement = MeshCreator.LastSelectedTriangle
        self.Adornee = MeshCreator.LastSelectedTriangle.Triangle3D.Model.PrimaryPart
    end

    self.PluginMouse = pluginMouse
    self.Connections = {}

    self:OnEnabled()
    
    --local Recording

    --[[
    for _, gizmoAdornment: HandleAdornment in Tool.ArrowGizmo:GetChildren() do
        gizmoAdornment.MouseEnter:Connect(function()
            self.ChangeGizmoAdornmentProperty(Tool.ArrowGizmo, "Color3", Color3.new(1, 0.690196, 0))
        end)

        gizmoAdornment.MouseLeave:Connect(function()
            self.ChangeGizmoAdornmentProperty(Tool.ArrowGizmo, "Color3", Color3.new(0.0509804, 0.411765, 0.67451))
        end)
    end
    ]]
    
    table.insert(self.Connections, Selection.SelectionChanged:Connect(function()
        if IsSelectedObjectExists then
            IsSelectedObjectExists = false
            self.SelectedElement = nil
            self:ChangeAdornee(nil)
        else
            if MeshCreator.LastSelectedTriangle then
                IsSelectedObjectExists = true
                self.SelectedElement = MeshCreator.LastSelectedTriangle
                self:ChangeAdornee(MeshCreator.LastSelectedTriangle.Triangle3D.Model.PrimaryPart)
            end
        end
    end))

    if self.ArrowGizmo :: Handles then
        table.insert(self.Connections, self.ArrowGizmo.MouseEnter:Connect(function()
            self.IsArrowGizmo_MouseEntered = true
            print(self.ArrowGizmo)
            self.ArrowGizmo.Color3 = Color3.new(1, 0.690196, 0)
            self:OnArrowGizmo_MouseEntered()
        end))
    
        table.insert(self.Connections, self.ArrowGizmo.MouseLeave:Connect(function()
            if not self.IsArrowGizmo_MouseClicked then
                self.IsArrowGizmo_MouseEntered = false
    
                self.ArrowGizmo.Color3 = Color3.new(0.0509804, 0.411765, 0.67451)
                self:OnArrowGizmo_MouseLeaved()
            end
        end))
    
        table.insert(self.Connections, self.ArrowGizmo.MouseButton1Down:Connect(function()
            self.IsArrowGizmo_MouseClicked = true
        end))
    
        table.insert(self.Connections, self.ArrowGizmo.MouseButton1Up:Connect(function()
            self.IsArrowGizmo_MouseClicked = false
            --[[
            if Recording then
                print(Recording)
                ChangeHistoryService:FinishRecording(Recording, Enum.FinishRecordingOperation.Commit)
                Recording = nil
            end
            ]]
            --ChangeHistoryService:SetWaypoint("ToolName")
        end))
    
        table.insert(self.Connections, self.ArrowGizmo.MouseDrag:Connect(function(...)
            --[[
            if not Recording then
                Recording = ChangeHistoryService:TryBeginRecording(ToolName)
                print(Recording, ChangeHistoryService:IsRecordingInProgress())
            end
            ]]
            self:OnArrowGizmo_Dragged(...)
        end))
    end
    
    if self.PluginMouse :: PluginMouse then
        table.insert(self.Connections, self.PluginMouse.Button1Down:Connect(function()
            if self.OnPluginMouse_Clicked then
                self:OnPluginMouse_Clicked()
            end
        end))
    end
    --[[
    self.SphereGizmo.MouseEnter:Connect(function()
        self.ChangeGizmoAdornmentProperty(Tool.SphereGizmo, "Color3", Color3.new(0.25, 0.25, 0.25))
        self.IsSphereGizmoClicked = true
    end)

    self.SphereGizmo.MouseLeave:Connect(function()
        self.ChangeGizmoAdornmentProperty(Tool.SphereGizmo, "Color3", Color3.new(0.5, 0.5, 0.5))
        self.IsSphereGizmoClicked = false
    end)
    ]]
end

function BaseMeshTool:Disable()
    self.IsArrowGizmo_MouseEntered = false
    
	for _, connection: RBXScriptConnection in self.Connections do
		connection:Disconnect()
	end
    
    self:DestroyGizmo()
    
    self:OnDisabled()

    self.Adornee = nil
    self.PluginMouse = nil
    self.MeshCreator = nil
    self.SelectedElement = nil
    self.Connections = {}
end

return BaseMeshTool