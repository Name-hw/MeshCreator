--Mesh Class
MeshClass = {
	ParentClass = script.Parent.GeometryElement
}
MeshClass.__index = MeshClass

local Classes = require(script.Parent)

local Root = script.Parent.Parent
local TableFunctions = require(Root.TableFunctions)

local function SetVA_Offset(MeshPart: MeshPart)
	local VA_Offset

	if MeshPart.MeshSize ~= Vector3.zero then
		VA_Offset = (MeshPart.Size / MeshPart.MeshSize)
	else
		VA_Offset = MeshPart.Size
	end

	return VA_Offset
end
--[[
local function IsCCW(A: Vector3, B: Vector3, C: Vector3)
    local crossProduct = (B.X - A.X) * (C.Y - A.Y) - (B.Y - A.Y) * (C.X - A.X)

    if crossProduct > 0 then
        return true  --CCW
    elseif crossProduct < 0 then
        return false   --CW
    else
        return false  --Collinear
    end
end

local function isEar(p1, p2, p3, vertices)
    local ax, ay = vertices[p1].X, vertices[p1].Y
    local bx, by = vertices[p2].X, vertices[p2].Y
    local cx, cy = vertices[p3].X, vertices[p3].Y

    -- 삼각형의 외적을 이용해 CCW 방향 확인
    if (bx - ax) * (cy - ay) - (by - ay) * (cx - ax) <= 0 then
        return false
    end

    -- 삼각형 내부에 다른 정점이 있는지 확인
    for i = 1, #vertices do
        if i ~= p1 and i ~= p2 and i ~= p3 then
            local px, py = vertices[i].X, vertices[i].Y
            local isInside = (px - ax) * (by - ay) - (py - ay) * (bx - ax) >= 0 and
                             (px - bx) * (cy - by) - (py - by) * (cx - bx) >= 0 and
                             (px - cx) * (ay - cy) - (py - cy) * (ax - cx) >= 0
            if isInside then
                return false
            end
        end
    end

    return true
end

-- Ear Clipping 알고리즘을 사용해 다각형을 삼각형으로 분할
local function triangulate(vertices)
    local triangles = {}
    local vertexCount = #vertices

    if vertexCount < 3 then
        return triangles
    end

    local indices = {}
    for i = 1, vertexCount do
        table.insert(indices, i)
    end

    while #indices > 3 do
        for i = 1, #indices do
            local p1 = indices[i]
            local p2 = indices[(i % #indices) + 1]
            local p3 = indices[(i + 1) % #indices + 1]
            if isEar(p1, p2, p3, vertices) then
                table.insert(triangles, {p1, p2, p3})
                table.remove(indices, (i % #indices) + 1)
                break
            end
        end
    end

    table.insert(triangles, {indices[1], indices[2], indices[3]})
    return triangles
end
]]
function MeshClass:Init()
	self.VA_Offset = SetVA_Offset(self.MeshPart)
	
	self.MeshPart:GetPropertyChangedSignal("Size"):Connect(function()
		self.VA_Offset = SetVA_Offset(self.MeshPart)
	end)
end

function MeshClass:NewFaceFromVertices(vertices: {Classes.Vertex})
	local MeshCreator = self.MeshCreator
	--local NewFace: Classes.Face = {}
	local NewTriangles: {Classes.Triangle} = {}
	local AddedEMVertexIDs: {number} = {}

	for _, vertex: Classes.Vertex in vertices do
		table.insert(AddedEMVertexIDs, vertex:AddEMVertex())
	end

	--[[
	local triangles = triangulate(TableFunctions.FindDatasFromElements(vertices, "VA_Position"))

	for _, triangle: {[number]: number} in ipairs(triangles) do
		local TVID1 = triangle[1]
		local TVID2 = triangle[2]
		local TVID3 = triangle[3]

		print(string.format("Triangle: %d, %d, %d", triangle[1], triangle[2], triangle[3]))
		--[[
		local TriangleVertices: {Classes.Vertex} = {vertices[TVID1], vertices[TVID2], vertices[TVID3]}
		local TriangleEMVertexIDs: {number} = {AddedEMVertexIDs[TVID1], AddedEMVertexIDs[TVID2], AddedEMVertexIDs[TVID3]}

		local TriangleID: number = MeshCreator.EM:AddTriangle(table.unpack(TriangleEMVertexIDs))
		task.wait()
		local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
			ID = TriangleID,
			Parent = self,
			VertexIDs = TableFunctions.FindDatasFromElements(TriangleVertices, "ID"),
			EMVertexIDs = TriangleEMVertexIDs,
			VertexAttachments = TableFunctions.FindDatasFromElements(TriangleVertices, "VertexAttachment"),
		})

		--MeshCreator.MeshGizmo:DrawLineFromVertexData(TriangleVertices)
		MeshCreator.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)

		table.insert(self.Triangles, TriangleClass)
		table.insert(NewTriangles, TriangleClass)
		]]
	--end
	
	for i = 1, #vertices - 2, 1 do
		local TriangleVertices: {Classes.Vertex} = {vertices[1], vertices[i + 2], vertices[i + 1]}
		local TriangleEMVertexIDs: {number} = {AddedEMVertexIDs[1], AddedEMVertexIDs[i + 2], AddedEMVertexIDs[i + 1]}

		local TriangleID: number = MeshCreator.EM:AddTriangle(table.unpack(TriangleEMVertexIDs))
		task.wait()
		local TriangleClass: Classes.Triangle = Classes.new("Triangle", {
			ID = TriangleID,
			Parent = self,
			VertexIDs = TableFunctions.FindDatasFromElements(TriangleVertices, "ID"),
			EMVertexIDs = TriangleEMVertexIDs,
			VertexAttachments = TableFunctions.FindDatasFromElements(TriangleVertices, "VertexAttachment"),
		})

		--MeshCreator.MeshGizmo:DrawLineFromVertexData(TriangleVertices)
		MeshCreator.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)

		table.insert(self.Triangles, TriangleClass)
		table.insert(NewTriangles, TriangleClass)
	end

	--return NewFace
	return NewTriangles
end

return MeshClass