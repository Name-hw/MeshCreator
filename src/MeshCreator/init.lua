local MeshCreator = {}
MeshCreator.__index = MeshCreator

local AssetService = game:GetService("AssetService")
local MeshFunctions = require(script.MeshFunctions)
local Classes = require(script.Classes)
local Enums = require(script.Enums)

function MeshCreator.new(MeshPart: Instance, MeshSaveFile: Classes.Mesh)
	local newMeshCreator = setmetatable(MeshCreator, MeshFunctions)
	
	newMeshCreator.MeshPart = MeshPart
	newMeshCreator.Vertices = {}
	newMeshCreator.Triangles = {}
	
	if newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh") then
		newMeshCreator.EM = newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh")
	else
		newMeshCreator:CreateEditableMesh(MeshSaveFile)
	end
	
	return newMeshCreator
end

function MeshCreator:CreateEditableMesh(MeshSaveFile)
	if self.MeshPart.MeshId ~= "" then
		self.EM = AssetService:CreateEditableMeshFromPartAsync(self.MeshPart)
	else
		self.EM = Instance.new("EditableMesh")
		self.EM:SetAttribute("CustomMesh", true)
	end

	if MeshSaveFile then
		if self.MeshPart:FindFirstChildOfClass("EditableMesh") then
			self.MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
		end

		for _, Vertex: Classes.Vertex in MeshSaveFile.Vertices do
			local VID = Vertex.VertexID
			local VP: Vector3 = Vertex.VertexPosition --VertexPosition
			local VN: Vector3 = Vertex.VertexNormal --VertexNormal
			
			self.EM:SetPosition(VID, VP)
			self.EM:SetVertexNormal(VID, VN)
		end
	end
	
	self.EM.Name = "EditableMesh"
	self.EM.Parent = self.MeshPart
end

function MeshCreator:AddTriangles(vertexIDs)
	local TriangleIDs = {}
	
	for _, vertexID in vertexIDs do
		if vertexIDs[vertexID + 2] then
			table.insert(TriangleIDs, self.EM:AddTriangle(vertexIDs[vertexID], vertexIDs[vertexID + 1], vertexIDs[vertexID + 2]))
		elseif vertexIDs[vertexID + 1] then
			table.insert(TriangleIDs, self.EM:AddTriangle(vertexIDs[vertexID], vertexIDs[vertexID + 1], vertexIDs[vertexID - 2]))
		end
	end
	
	return TriangleIDs
end

function MeshCreator:CreatePlaneMesh(width, height, offset: Vector3, normal: Vector3)
	local VertexIDs = {
		self.EM:AddVertex(Vector3.new(-width/2, 0, -height/2) + offset), 
		self.EM:AddVertex(Vector3.new(-width/2, 0, height/2) + offset),
		self.EM:AddVertex(Vector3.new(width/2, 0, height/2) + offset), 
		self.EM:AddVertex(Vector3.new(width/2, 0, -height/2) + offset)
	}
	local TriangleIDs = self:AddTriangles(VertexIDs)
	
	for _, vertexID in VertexIDs do
		self.EM:SetVertexNormal(vertexID, normal)
	end
	
	local newPlaneMesh: Classes.CustomMesh = {
		MeshID = 1,
		MeshType = Enums.MeshType.Plane,
		Vertices = VertexIDs,
		Triangles = TriangleIDs
	}

	return newPlaneMesh
end

--Not Completed
function MeshCreator:CreateCubeMesh(scale: Vector3, offset: Vector3)
	local HalfScale = scale/2
	
	local VertexIDs = {
		self.EM:AddVertex(Vector3.new(-HalfScale.X, -HalfScale.Y, -HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(-HalfScale.X, HalfScale.Y, HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(HalfScale.X, HalfScale.Y, -HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(-HalfScale.X, -HalfScale.Y, HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(HalfScale.X, HalfScale.Y, -HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(-HalfScale.X, HalfScale.Y, -HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(-HalfScale.X, HalfScale.Y, -HalfScale.Z) + offset),
		self.EM:AddVertex(Vector3.new(HalfScale.X, HalfScale.Y, HalfScale.Z) + offset)
	}
	local TriangleIDs = self:AddTriangles(VertexIDs)
	
	local newCubeMesh: Classes.CubeMesh = {
		MeshID = 1,
		Vertices = VertexIDs,
		Triangles = TriangleIDs
	}

	return newCubeMesh
end

function MeshCreator:Remove()
	self:RemoveVertexAttachments()
end

return MeshCreator