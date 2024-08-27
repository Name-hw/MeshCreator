local Mesh = {
	ParentClass = script.Parent.GeometryElement
}
Mesh.__index = Mesh

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

local function CCW(A: Vector3, B: Vector3, C: Vector3, normal: Vector3)
	local AB = B - A
    local AC = C - A

    return normal:Dot(AB:Cross(AC))
end

local function IsCCW(A: Vector3, B: Vector3, C: Vector3, Normal: Vector3)
    return CCW(A, B, C, Normal) > 0
end

local function CalculateNormal(A, B, C): Vector3
    local AB = B - A
    local AC = C - A
	local Normal = AB:Cross(AC).Unit:Abs()
	local MaxDecimalPlace: number = 0
	
	for _, vector3Value: Vector3 in {A, B, C} do
		for _, value: number in {vector3Value.X, vector3Value.Y, vector3Value.Z} do
			local _, FractionalPart = math.modf(value)
			local DecimalPlace = 0
	
			if FractionalPart ~= 0 then
				DecimalPlace = #(tostring(value):split(".")[2])
			end

			if MaxDecimalPlace < DecimalPlace then
				MaxDecimalPlace = DecimalPlace
			end
		end
	end
	
	local RoundedNormal = Vector3.new(
		TableFunctions.Round(Normal.X, MaxDecimalPlace),
		TableFunctions.Round(Normal.Y, MaxDecimalPlace),
		TableFunctions.Round(Normal.Z, MaxDecimalPlace)
	)
	
    return RoundedNormal
end

local function IsPointInTriangle(point: Vector3, prevVertex: Vector3, centerVertex: Vector3, nextVertex: Vector3)
	local Normal = CalculateNormal(prevVertex, centerVertex, nextVertex)
    local IsCCW1 = IsCCW(point, prevVertex, centerVertex, Normal)
    local IsCCW2 = IsCCW(point, centerVertex, nextVertex, Normal)
    local IsCCW3 = IsCCW(point, nextVertex, prevVertex, Normal)

	return IsCCW1 == IsCCW2 and IsCCW2 == IsCCW3
end

local function IsEar(prevVertex: Vector3, centerVertex: Vector3, nextVertex: Vector3, vertexPositions: {Vector3})
	for _, point: Vector3 in ipairs(vertexPositions) do
		if point ~= prevVertex and point ~= centerVertex and point ~= nextVertex then
			if IsPointInTriangle(point, prevVertex, centerVertex, nextVertex) then
				return false
			end
		end
    end

    return true
end

local function FindEar(vertexPositions: {Vector3}, vertexIndices: {number}): (number, number, number, number)
	local VertexCount = #vertexIndices

    for i = 1, VertexCount do
		local PrevVertexIndex = vertexIndices[(i - 2 + VertexCount) % VertexCount + 1]
		local CenterVertexIndex = vertexIndices[i]
		local NextVertexIndex = vertexIndices[(i % VertexCount) + 1]
		local PrevVertex = vertexPositions[PrevVertexIndex]
		local CenterVertex = vertexPositions[CenterVertexIndex]
		local NextVertex = vertexPositions[NextVertexIndex]

		if IsEar(PrevVertex, CenterVertex, NextVertex, vertexPositions) then
			return i, PrevVertexIndex, CenterVertexIndex, NextVertexIndex
		end
    end

	return 0, 0, 0, 0
end

local function Triangulate(vertexPositions: {Vector3})
    local Triangles = {}
	local VertexIndices = {}

	for i = 1, #vertexPositions do
        table.insert(VertexIndices, i)
    end

    while #VertexIndices >= 3 do
        local EarIndex, PrevVertexIndex, CenterVertexIndex, NextVertexIndex = FindEar(vertexPositions, VertexIndices)
		
		if EarIndex then
			table.insert(Triangles, {PrevVertexIndex, CenterVertexIndex, NextVertexIndex})
			table.remove(VertexIndices, EarIndex)
		else
			break
		end
    end

    return Triangles
end

function Mesh:Init()
	self.VA_Offset = SetVA_Offset(self.MeshPart)
	
	self.MeshPart:GetPropertyChangedSignal("Size"):Connect(function()
		self.VA_Offset = SetVA_Offset(self.MeshPart)
	end)
end

function Mesh:SortVerticesCCW(vertices: {Classes.Vertex}): {Classes.Vertex}
    local Reference = vertices[1].VA_Position
	
    table.sort(vertices, function(a: Classes.Vertex, b: Classes.Vertex)
		local A = a.VA_Position
		local B = b.VA_Position
		local Normal = CalculateNormal(A, B, Reference)

		return CCW(A, B, Reference, Normal) >= 0
	end)

    return vertices
end

function Mesh:NewFaceFromVertices(vertices: {Classes.Vertex})
	local MeshCreator = self.MeshCreator
	--local NewFace: Classes.Face = {}
	local NewTriangles: {Classes.Triangle} = {}
	local AddedEMVertexIDs: {number} = {}

	if #vertices > 3 then
		local Normal = CalculateNormal(vertices[1].VA_Position, vertices[2].VA_Position, vertices[3].VA_Position)
		
		for i = 4, #vertices do
			local D = vertices[i].VA_Position
			local AD = D - vertices[1].VA_Position
	
			if Normal:Dot(AD) ~= 0 then
				error("The vertices are not in one plane")
			end
		end
	end

	self:SortVerticesCCW(vertices)

	for order, vertex: Classes.Vertex in vertices do
		AddedEMVertexIDs[order] = vertex:AddEMVertex()
	end

	local Triangles: {{[number]: number}} = Triangulate(TableFunctions.FindDatasFromElements(vertices, "VA_Position"))

	for _, triangle: {[number]: number} in ipairs(Triangles) do
		local TVID1 = triangle[1]
		local TVID2 = triangle[2]
		local TVID3 = triangle[3]

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

		MeshCreator.MeshGizmo:DrawLineFromVertexData(table.unpack(TriangleVertices))
		MeshCreator.MeshGizmo:DrawTriangle(TriangleClass, TriangleClass.VertexAttachments)

		table.insert(self.Triangles, TriangleClass)
		table.insert(NewTriangles, TriangleClass)
	end
	
	--[[
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
	]]

	--return NewFace
	return NewTriangles
end

return Mesh