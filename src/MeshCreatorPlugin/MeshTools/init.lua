local MeshTools = {}

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

function MeshTools.Enable(MeshCreator, ToolName: string, Adornee: BasePart)
    local Tool = require(script:FindFirstChild(ToolName))

    MeshTools.Tool = Tool
    MeshTools.Tool.ToolTpye = Enums.Tool[ToolName]
    MeshTools.Tool.ToolGizmo = Tool.CreateToolGizmo(Adornee)
    MeshTools.Tool.ToolGizmo.Parent = ToolGizmoFolder

    MeshTools.IsToolEnabled = true

    --[[
    for _, gizmoAdornment: HandleAdornment in Tool.ToolGizmo:GetChildren() do
        gizmoAdornment.MouseEnter:Connect(function()
            MeshTools.ChangeGizmoAdornmentProperty(Tool.ToolGizmo, "Color3", Color3.new(1, 0.690196, 0))
        end)

        gizmoAdornment.MouseLeave:Connect(function()
            MeshTools.ChangeGizmoAdornmentProperty(Tool.ToolGizmo, "Color3", Color3.new(0.0509804, 0.411765, 0.67451))
        end)
    end
    ]]

    MeshTools.Tool.ToolGizmo.MouseEnter:Connect(function()
        MeshTools.Tool.IsMouseEntered = true

        MeshTools.ChangeGizmoAdornmentProperty(Tool.ToolGizmo, "Color3", Color3.new(1, 0.690196, 0))
        MeshTools.Tool.OnMouseEnter(MeshCreator)
    end)

    MeshTools.Tool.ToolGizmo.MouseLeave:Connect(function()
        if not MeshTools.Tool.IsMouseClicked then
            MeshTools.Tool.IsMouseEntered = false

            MeshTools.ChangeGizmoAdornmentProperty(Tool.ToolGizmo, "Color3", Color3.new(0.0509804, 0.411765, 0.67451))
            MeshTools.Tool.OnMouseLeave(MeshCreator)
        end
    end)

    MeshTools.Tool.ToolGizmo.MouseButton1Down:Connect(function()
        MeshTools.Tool.IsMouseClicked = true
    end)

    MeshTools.Tool.ToolGizmo.MouseButton1Up:Connect(function()
        MeshTools.Tool.IsMouseClicked = false
    end)

    MeshTools.Tool.ToolGizmo.MouseDrag:Connect(function(face: Faces, distance: number)
        MeshTools.Tool.OnDragged(MeshCreator, face, distance)
    end)
end

function MeshTools.Disable()
    if MeshTools.IsToolEnabled then
        MeshTools.IsToolEnabled = false
        MeshTools.Tool.ToolGizmo:Destroy()
        MeshTools.Tool.Disable()
        MeshTools.Tool = nil
    end
end

return MeshTools