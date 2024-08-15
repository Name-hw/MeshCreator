local MeshTools = require(script.Parent)

local ExtrudeRegionTool = {} :: MeshTools.MeshTool_ArrowGizmo

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local IsExtruded = false
local ExtrudedVertices: {Classes.Vertex} = {}
local ExtrudedTriangle: Classes.Triangle | nil
local OriginalVertexAttachments = {}

function ExtrudeRegionTool.Enable(MeshCreator, adornee)
    ExtrudeRegionTool.MeshCreator = MeshCreator
    MeshTools.CreateArrowGizmo(adornee)
    --MeshTools.Tool.SphereGizmo = CreateSphereGizmo(Adornee)
    --MeshTools.Tool.SphereGizmo.Parent = ToolGizmoFolder
end

function ExtrudeRegionTool.OnArrowGizmo_MouseEntered()
    
end

function ExtrudeRegionTool.OnArrowGizmo_MouseLeaved()
    IsExtruded = false
    ExtrudedTriangle = nil
    ExtrudedVertices = {}
end

function ExtrudeRegionTool.OnArrowGizmo_Dragged(face: Enum.NormalId, distance: number)
    local MeshCreator = ExtrudeRegionTool.MeshCreator

    if IsExtruded and ExtrudedTriangle then
        for tablePosition, vertexAttachment: Attachment in ipairs(ExtrudedTriangle.VertexAttachments) do
            vertexAttachment.Position = OriginalVertexAttachments[tablePosition].Position + ExtrudedTriangle.TriangleNormal / MeshCreator.Mesh.VA_Offset * distance * 5
        end
    else
        IsExtruded = true
        
        local TVs = TableFunctions.GetVerticesFromEFElement(MeshCreator.Mesh.Vertices, ExtrudeRegionTool.SelectedElement) --TriangleVertices
        local TVAPositions = {} --TriangleVertexAttachmentPositions
        
        for _, vertexAttachment in ExtrudeRegionTool.SelectedElement.VertexAttachments do
            table.insert(TVAPositions, vertexAttachment.Position)
        end
        
        ExtrudedTriangle, ExtrudedVertices = MeshCreator:AddTriangleByVertexAttachmentPositions(TVAPositions)
        ExtrudeRegionTool.ArrowGizmo.Adornee = ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        --ExtrudeRegionTool.SphereGizmo.Adornee = ExtrudedTriangle.Triangle3D.Model.TriangleMesh
        OriginalVertexAttachments = ExtrudeRegionTool.SelectedElement.VertexAttachments

        ExtrudedTriangle.Triangle3D:Set("Locked", false)
        MeshCreator.MeshGizmo:DrawLineFromTriangle(ExtrudedTriangle)

        for _, Vertex: Classes.Vertex in ExtrudedVertices do
            Vertex:SetVAPosition(Vertex.VertexAttachment.Position + ExtrudedTriangle.TriangleNormal / MeshCreator.Mesh.VA_Offset * distance)
        end

        task.wait()

        for i = 1, 3, 1 do
            local NewTriangles: {Classes.Triangle}

            if i ~= 3 then
                NewTriangles = MeshCreator.Mesh:NewFaceFromVertices({ExtrudedVertices[i], ExtrudedVertices[i + 1], TVs[i + 1], TVs[i]})
            else
                NewTriangles = MeshCreator.Mesh:NewFaceFromVertices({ExtrudedVertices[i], ExtrudedVertices[1], TVs[1], TVs[i]})
            end

            for _, Triangle: Classes.Triangle in NewTriangles do
                Triangle.Triangle3D:Set("Locked", false)
                Triangle.Triangle3D:Transparency(0)
            end
        end

        ExtrudeRegionTool.SelectedElement:Destroy()
        MeshCreator:SelectTriangle(ExtrudedTriangle.Triangle3D.Model, false)
    end
end

function ExtrudeRegionTool.Disable()
    print("disable")
    IsExtruded = false
    ExtrudedTriangle = nil
    ExtrudedVertices = {}
end



return ExtrudeRegionTool