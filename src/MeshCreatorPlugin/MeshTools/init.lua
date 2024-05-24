local MeshTools = {}

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local CoreGui = game:GetService("CoreGui")
local Root = script.Parent
local Enums = require(Root.Enums)
local ToolGizmoFolder = CoreGui:FindFirstChild("MeshCreator_ToolGizmoFolder") or Instance.new("Folder", CoreGui)

ToolGizmoFolder.Name = "MeshCreator_ToolGizmoFolder"

function MeshTools.ChangeGizmoAdornmentProperty(ToolGizmo, propertyName, propertyValue)
    --[[
    for _, gizmoAdornment: HandleAdornment in ToolGizmo:GetChildren() do
        gizmoAdornment[propertyName] = propertyValue
    end
    ]]

    ToolGizmo[propertyName] = propertyValue
end

local function CreateArrowGizmo(Adornee: BasePart)
    local ArrowGizmo = Instance.new("Handles")
    ArrowGizmo.Name = "ToolGizmoHandles"
    ArrowGizmo.Style = Enum.HandlesStyle.Movement
    ArrowGizmo.Adornee = Adornee
    ArrowGizmo.Faces = Faces.new(Enum.NormalId.Left)

    return ArrowGizmo
end

local function CreateSphereGizmo(Adornee)
    local SphereGizmo = Instance.new("SphereHandleAdornment")
    SphereGizmo.Name = "ToolGizmoHandles"
    SphereGizmo.Adornee = Adornee
    SphereGizmo.AlwaysOnTop = true
    SphereGizmo.Color3 = Color3.new(0.5, 0.5, 0.5)
    SphereGizmo.Transparency = 0.5
    SphereGizmo.Radius = 5
    SphereGizmo.ZIndex = 1

    return SphereGizmo
end

function MeshTools.Enable(MeshCreator, ToolName: string, Adornee: BasePart)
    local Tool = require(script:FindFirstChild(ToolName))

    MeshTools.Tool = Tool
    MeshTools.Tool.ToolTpye = Enums.Tool[ToolName]
    MeshTools.Tool.ArrowGizmo = CreateArrowGizmo(Adornee)
    --MeshTools.Tool.SphereGizmo = CreateSphereGizmo(Adornee)
    MeshTools.Tool.ArrowGizmo.Parent = ToolGizmoFolder
    --MeshTools.Tool.SphereGizmo.Parent = ToolGizmoFolder
    MeshTools.MeshCreator = MeshCreator

    MeshTools.IsToolEnabled = true
    
    --local Recording

    --[[
    for _, gizmoAdornment: HandleAdornment in Tool.ArrowGizmo:GetChildren() do
        gizmoAdornment.MouseEnter:Connect(function()
            MeshTools.ChangeGizmoAdornmentProperty(Tool.ArrowGizmo, "Color3", Color3.new(1, 0.690196, 0))
        end)

        gizmoAdornment.MouseLeave:Connect(function()
            MeshTools.ChangeGizmoAdornmentProperty(Tool.ArrowGizmo, "Color3", Color3.new(0.0509804, 0.411765, 0.67451))
        end)
    end
    ]]

    MeshTools.Tool.ArrowGizmo.MouseEnter:Connect(function()
        MeshTools.Tool.IsMouseEntered = true

        MeshTools.ChangeGizmoAdornmentProperty(Tool.ArrowGizmo, "Color3", Color3.new(1, 0.690196, 0))
        MeshTools.Tool.OnMouseEnter(MeshTools.MeshCreator)
    end)

    MeshTools.Tool.ArrowGizmo.MouseLeave:Connect(function()
        if not MeshTools.Tool.IsMouseClicked then
            MeshTools.Tool.IsMouseEntered = false

            MeshTools.ChangeGizmoAdornmentProperty(Tool.ArrowGizmo, "Color3", Color3.new(0.0509804, 0.411765, 0.67451))
            MeshTools.Tool.OnMouseLeave(MeshTools.MeshCreator)
        end
    end)

    MeshTools.Tool.ArrowGizmo.MouseButton1Down:Connect(function()
        MeshTools.Tool.IsMouseClicked = true
    end)

    MeshTools.Tool.ArrowGizmo.MouseButton1Up:Connect(function()
        MeshTools.Tool.IsMouseClicked = false
        --[[
        if Recording then
            print(Recording)
            ChangeHistoryService:FinishRecording(Recording, Enum.FinishRecordingOperation.Commit)
            Recording = nil
        end
        ]]
        --ChangeHistoryService:SetWaypoint("ToolName")
    end)

    MeshTools.Tool.ArrowGizmo.MouseDrag:Connect(function(face: Faces, distance: number)
        --[[
        if not Recording then
            Recording = ChangeHistoryService:TryBeginRecording(ToolName)
            print(Recording, ChangeHistoryService:IsRecordingInProgress())
        end
        ]]
        MeshTools.Tool.SelectedTriangle = MeshTools.MeshCreator.LastSelectedTriangle
        
        MeshTools.Tool.OnDragged(MeshTools.MeshCreator, face, distance)
    end)
    --[[
    MeshTools.Tool.SphereGizmo.MouseEnter:Connect(function()
        MeshTools.ChangeGizmoAdornmentProperty(Tool.SphereGizmo, "Color3", Color3.new(0.25, 0.25, 0.25))
        MeshTools.Tool.IsSphereGizmoClicked = true
    end)

    MeshTools.Tool.SphereGizmo.MouseLeave:Connect(function()
        MeshTools.ChangeGizmoAdornmentProperty(Tool.SphereGizmo, "Color3", Color3.new(0.5, 0.5, 0.5))
        MeshTools.Tool.IsSphereGizmoClicked = false
    end)
    ]]
end

function MeshTools.Disable()
    if MeshTools.IsToolEnabled then
        MeshTools.IsToolEnabled = false
        MeshTools.Tool.IsMouseEntered = false
        
        MeshTools.Tool.OnMouseLeave(MeshTools.MeshCreator)
        MeshTools.Tool.ArrowGizmo:Destroy()
        --MeshTools.Tool.SphereGizmo:Destroy()
        MeshTools.Tool.Disable()
        MeshTools.Tool = nil
    end
end

return MeshTools