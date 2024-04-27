local ExtrudeRegionTool = {}

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local IsExtruded = false
local ExtrudedVertices = {}
local OriginalVertexAttachments = {}

local OriginalTriangleModelCFrame

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
            vertexAttachment.Position = OriginalVertexAttachments[tablePosition].Position + OriginalTriangleModelCFrame.RightVector * distance
        end

        for tablePosition, Vertex: Classes.Vertex in ExtrudedVertices do
            local VA: Attachment = Vertex.VertexAttachment
            local OriginalVertexAttachment
            
            if tablePosition == 1 or tablePosition == 6 then
                OriginalVertexAttachment = OriginalVertexAttachments[1]
            elseif tablePosition == 2 or tablePosition == 3 then
                OriginalVertexAttachment = OriginalVertexAttachments[2]
            elseif tablePosition == 4 or tablePosition == 5 then
                OriginalVertexAttachment = OriginalVertexAttachments[3]
            end

            VA.Position = OriginalVertexAttachment.Position + OriginalTriangleModelCFrame.RightVector * distance
        end
    else
        IsExtruded = true
        
        local TVAPositions = {} --TriangleVertexAttachmentPositions
        
        for _, vertexAttachment in ExtrudeRegionTool.SelectedTriangle.VertexAttachments do
            table.insert(TVAPositions, vertexAttachment.Position)
        end
        
        ExtrudeRegionTool.ExtrudedTriangle = MeshCreator:AddTriangleByVertexAttachmentPositions(TVAPositions)
        ExtrudeRegionTool.ArrowGizmo.Adornee = ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        --ExtrudeRegionTool.SphereGizmo.Adornee = ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        OriginalTriangleModelCFrame = ExtrudeRegionTool.SelectedTriangle.Triangle3D.Model:GetPivot()
        OriginalVertexAttachments = ExtrudeRegionTool.SelectedTriangle.VertexAttachments

        ExtrudeRegionTool.ExtrudedTriangle.Triangle3D:Set("Locked", false)
        MeshCreator.MeshGizmo:DrawLineFromTriangle(ExtrudeRegionTool.ExtrudedTriangle)

        for i = 1, 3, 1 do
            local VAPositions: {Vector3} = {} --VertexAttachmentPositions

            if i < 3 then
                VAPositions = {
                    TVAPositions[i],
                    TVAPositions[i + 1],
                    TVAPositions[i + 1],
                    TVAPositions[i]
                }
            else
                VAPositions = {
                    TVAPositions[3],
                    TVAPositions[1],
                    TVAPositions[1],
                    TVAPositions[3]
                }
            end

            local Vertices: {Classes.Vertex} = {}

            for _, VAPosition in VAPositions do
                local Vertex: Classes.Vertex = MeshCreator:AddVertexByVertexAttachmentPosition(VAPosition)
                --Vertex:SetUV()
                table.insert(Vertices, Vertex)
            end
            
            local Triangle1: Classes.Triangle = MeshCreator:AddTriangleFromVertices({Vertices[1], Vertices[4], Vertices[2]})
            local Triangle2: Classes.Triangle = MeshCreator:AddTriangleFromVertices({Vertices[3], Vertices[2], Vertices[4]})

            MeshCreator.MeshGizmo:DrawLineFromVertexData(Vertices[1], Vertices[4], Vertices[2])
            MeshCreator.MeshGizmo:DrawLineFromVertexData(Vertices[3], Vertices[2], Vertices[4])

            Triangle1.Triangle3D:Set("Locked", false)
            Triangle2.Triangle3D:Set("Locked", false)

            table.insert(ExtrudedVertices, Vertices[1])
            table.insert(ExtrudedVertices, Vertices[2])
        end

        ExtrudeRegionTool.SelectedTriangle:Destroy()
        MeshCreator:SelectTriangle(ExtrudeRegionTool.ExtrudedTriangle.Triangle3D.Model, false)
    end
end

function ExtrudeRegionTool.Disable()
    IsExtruded = false
end

return ExtrudeRegionTool