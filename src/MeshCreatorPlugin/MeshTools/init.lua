local MeshTools = {
    Tool = {} :: ArrowGizmoTool | PluginMouseTool,
    ToolType = nil
}
local BaseMeshTool = require(script.BaseMeshTool)

export type BaseMeshTool = BaseMeshTool.BaseMeshTool
export type ArrowGizmoTool = BaseMeshTool & {
    ArrowGizmo: Handles,
    OnEnable: (self: ArrowGizmoTool) -> (),
    OnArrowGizmo_MouseEntered: (self: ArrowGizmoTool) -> (),
    OnArrowGizmo_MouseLeaved: (self: ArrowGizmoTool) -> (),
    OnArrowGizmo_Dragged: (self: ArrowGizmoTool, face: Enum.NormalId, distance: number) -> (),
    OnDisabled: (self: PluginMouseTool) -> ()
}
export type PluginMouseTool = BaseMeshTool & {
    PluginMouse: PluginMouse,
    OnEnabled: (self: PluginMouseTool) -> (),
    OnPluginMouse_Clicked: () -> (),
    OnDisabled: (self: PluginMouseTool) -> ()
}

local Root = script.Parent
local Enums = require(Root.Enums)

function MeshTools.Enable(MeshCreator, ToolTpye: Enums.UserEnumItem, pluginMouse: PluginMouse)
    MeshTools.IsToolEnabled = true
    MeshTools.Tool = setmetatable(require(script[ToolTpye.Name]), BaseMeshTool) :: ArrowGizmoTool | PluginMouseTool
    MeshTools.ToolType = ToolTpye

    MeshTools.Tool:Enable(MeshCreator, pluginMouse)
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
    MeshTools.IsToolEnabled = false

    MeshTools.Tool:Disable()
    
    MeshTools.Tool = nil
    MeshTools.ToolType = nil
end

return MeshTools