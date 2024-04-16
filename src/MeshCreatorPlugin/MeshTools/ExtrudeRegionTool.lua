local ExtrudeRegionTool = {}
ExtrudeRegionTool.IsExtruded = false

local Root = script.Parent.Parent

function ExtrudeRegionTool.CreateToolGizmo(Adornee: BasePart)
    --[[
    local ToolGizmoModel = Instance.new("Model")
    ToolGizmoModel.Name = "ToolGizmo"

    local CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
    CylinderHandleAdornment.Adornee = Adornee
    CylinderHandleAdornment.AlwaysOnTop = true
    CylinderHandleAdornment.Height = 5
    --CylinderHandleAdornment.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(CylinderHandleAdornment.Height * math.cos(math.pi/2), CylinderHandleAdornment.Height * math.sin(math.pi/2)))
    CylinderHandleAdornment.CFrame = CFrame.new(0, 0, -0.25)
    CylinderHandleAdornment.Radius = 0.1
    CylinderHandleAdornment.ZIndex = 1
    CylinderHandleAdornment.Parent = ToolGizmoModel

    local ConeHandleAdornment = Instance.new("ConeHandleAdornment")
    ConeHandleAdornment.Adornee = Adornee
    ConeHandleAdornment.AlwaysOnTop = true
    ConeHandleAdornment.Height = 1
    --ConeHandleAdornment.CFrame = Adornee:GetPivot():ToObjectSpace(CFrame.new(0, 0, -5))
    --ConeHandleAdornment.CFrame = CFrame.new(0, 0, 0):Lerp(CFrame.new(0, 0, -5) * Adornee:GetPivot().Rotation, 0.5)
    --ConeHandleAdornment.CFrame = CFrame.new(CylinderHandleAdornment.CFrame.Position, )
    ConeHandleAdornment.CFrame = CFrame.new(0, 0, -2.5)
    ConeHandleAdornment.Radius = 0.25
    ConeHandleAdornment.ZIndex = 1
    ConeHandleAdornment.Parent = ToolGizmoModel

    return ToolGizmoModel
    ]]

    local ToolGizmoHandles = Instance.new("Handles")
    ToolGizmoHandles.Name = "ToolGizmoHandles"
    ToolGizmoHandles.Style = Enum.HandlesStyle.Movement
    ToolGizmoHandles.Adornee = Adornee
    ToolGizmoHandles.Faces = Faces.new(Enum.NormalId.Left)

    return ToolGizmoHandles
end

function ExtrudeRegionTool.OnMouseEnter(MeshCreator)
    
end

function ExtrudeRegionTool.OnMouseLeave(MeshCreator)
    ExtrudeRegionTool.IsExtruded = false
    ExtrudeRegionTool.ExtrudedTriangle = nil
end

function ExtrudeRegionTool.OnDragged(MeshCreator, face: Faces, distance: number)
    if ExtrudeRegionTool.IsExtruded then
        for tablePosition, vertexAttachment: Attachment in ExtrudeRegionTool.ExtrudedTriangle.VertexAttachments do
            ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model:MoveTo(ExtrudeRegionTool.OriginalTriangle.Triangle3D.Model:GetPivot() * Vector3.new(distance, 0, 0))

            vertexAttachment.Position = ExtrudeRegionTool.OriginalTriangle.VertexAttachments[tablePosition].Position + ExtrudeRegionTool.OriginalTriangle.Triangle3D.Model:GetPivot().RightVector * distance
        end
    else
        ExtrudeRegionTool.IsExtruded = true
        
        local SelectedTriangle = MeshCreator.LastSelectedTriangle
        local TriangleVertexPositions = {}
        
        for _, vertexAttachment in SelectedTriangle.VertexAttachments do
            table.insert(TriangleVertexPositions, vertexAttachment.WorldPosition)
        end
        
        ExtrudeRegionTool.ExtrudedTriangle = MeshCreator:AddTriangle(TriangleVertexPositions)
        ExtrudeRegionTool.ToolGizmo.Adornee = ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        ExtrudeRegionTool.OriginalTriangle = SelectedTriangle

        MeshCreator:SelectTriangle(ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model, false)
    end
end

function ExtrudeRegionTool.Disable()
    ExtrudeRegionTool.IsExtruded = false
end

return ExtrudeRegionTool