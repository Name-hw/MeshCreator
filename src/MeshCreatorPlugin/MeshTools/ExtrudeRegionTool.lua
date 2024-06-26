local ExtrudeRegionTool = {}

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local IsExtruded = false
local ExtrudedVertices: {Classes.Vertex} = {}
local OriginalVertexAttachments = {}

--[[
function ExtrudeRegionTool.CreateToolGizmo(Adornee: BasePart)
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
    
    local ToolGizmoHandles = Instance.new("Handles")
    ToolGizmoHandles.Name = "ToolGizmoHandles"
    ToolGizmoHandles.Style = Enum.HandlesStyle.Movement
    ToolGizmoHandles.Adornee = Adornee
    ToolGizmoHandles.Faces = Faces.new(Enum.NormalId.Left)
    
    return ToolGizmoHandles
end
]]

function ExtrudeRegionTool.OnMouseEnter(MeshCreator)
    
end

function ExtrudeRegionTool.OnMouseLeave(MeshCreator)
    IsExtruded = false
    ExtrudeRegionTool.ExtrudedTriangle = nil
    ExtrudedVertices = {}
end

function ExtrudeRegionTool.OnDragged(MeshCreator, face: Faces, distance: number)
    if IsExtruded then
        for tablePosition, vertexAttachment: Attachment in ExtrudeRegionTool.ExtrudedTriangle.VertexAttachments do
            vertexAttachment.Position = OriginalVertexAttachments[tablePosition].Position + ExtrudeRegionTool.ExtrudedTriangle.TriangleNormal / MeshCreator.Mesh.VA_Offset * distance * 5
        end
    else
        IsExtruded = true
        
        local TVs = TableFunctions.GetVerticesFromEFElement(MeshCreator.Mesh.Vertices, ExtrudeRegionTool.SelectedTriangle) --TriangleVertices
        local TVAPositions = {} --TriangleVertexAttachmentPositions
        
        for _, vertexAttachment in ExtrudeRegionTool.SelectedTriangle.VertexAttachments do
            table.insert(TVAPositions, vertexAttachment.Position)
        end
        
        ExtrudeRegionTool.ExtrudedTriangle, ExtrudedVertices = MeshCreator:AddTriangleByVertexAttachmentPositions(TVAPositions)
        ExtrudeRegionTool.ArrowGizmo.Adornee = ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        --ExtrudeRegionTool.SphereGizmo.Adornee = ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        OriginalVertexAttachments = ExtrudeRegionTool.SelectedTriangle.VertexAttachments

        ExtrudeRegionTool.ExtrudedTriangle.Triangle3D:Set("Locked", false)
        MeshCreator.MeshGizmo:DrawLineFromTriangle(ExtrudeRegionTool.ExtrudedTriangle)

        for _, Vertex: Classes.Vertex in ExtrudedVertices do
            Vertex:SetVAPosition(Vertex.VertexAttachment.Position + ExtrudeRegionTool.ExtrudedTriangle.TriangleNormal / MeshCreator.Mesh.VA_Offset * distance)
        end

        for i = 1, 3, 1 do
            if i ~= 3 then
                local NewTriangles: {Classes.Triangle} = MeshCreator.Mesh:NewFaceFromVertices({ExtrudedVertices[i], ExtrudedVertices[i + 1], TVs[i + 1], TVs[i]})

                for _, Triangle: Classes.Triangle in NewTriangles do
                    Triangle.Triangle3D:Set("Locked", false)
                    Triangle.Triangle3D:Transparency(0)
                end
            else
                local NewTriangles: {Classes.Triangle} = MeshCreator.Mesh:NewFaceFromVertices({ExtrudedVertices[i], ExtrudedVertices[1], TVs[1], TVs[i]})

                for _, Triangle: Classes.Triangle in NewTriangles do
                    Triangle.Triangle3D:Set("Locked", false)
                    Triangle.Triangle3D:Transparency(0)
                end
            end
        end

        ExtrudeRegionTool.SelectedTriangle:Destroy()
        MeshCreator:SelectTriangle(ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model, false)
    end
end

function ExtrudeRegionTool.Disable()
    IsExtruded = false
end

return ExtrudeRegionTool