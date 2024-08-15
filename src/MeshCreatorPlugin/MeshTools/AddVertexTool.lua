local MeshTools = require(script.Parent)

local AddVertexTool = {} :: MeshTools.PluginMouseTool

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)

function AddVertexTool:OnEnabled()
    --AddVertexTool.PluginMouse = pluginMouse
    --MeshTools.Tool.SphereGizmo = CreateSphereGizmo(Adornee)
    --MeshTools.Tool.SphereGizmo.Parent = ToolGizmoFolder
end

function AddVertexTool:OnPluginMouse_Clicked()
    local MeshCreator = self.MeshCreator

    MeshCreator:AddVertexByWorldPosition(self.PluginMouse.Hit.Position)
end

function AddVertexTool:OnDisabled()
    print("disable")
end

return AddVertexTool