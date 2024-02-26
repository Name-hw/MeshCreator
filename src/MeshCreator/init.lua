local MeshCreator = {}

local AssetService = game:GetService("AssetService")
local MeshFunctions = require(script.MeshFunctions)
local MeshGizmo = require(script.MeshGizmo)
local Classes = require(script.Parent.Classes)
local Enums = require(script.Parent.Enums)
local TableFunctions = require(script.Parent.TableFunctions)
local lib = script.Parent.lib
--local Table = require(script.Parent.lib.Table)

function MeshCreator.new(MeshPart: Instance, MeshSaveFile: Classes.Mesh, Settings)
	local newMeshCreator = setmetatable(MeshCreator, MeshFunctions)
	
	newMeshCreator.Settings = Settings
	newMeshCreator.MeshPart = MeshPart
	newMeshCreator.MeshPart.Locked = true
	newMeshCreator.Vertices = {}
	newMeshCreator.Triangles = {}
	newMeshCreator.MeshGizmo = MeshGizmo.new(MeshPart, newMeshCreator.Settings)
	
	if newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh") and not MeshSaveFile then
		newMeshCreator.EM = newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh")
	else
		newMeshCreator:CreateEditableMesh(MeshSaveFile)
	end
	
	return newMeshCreator
end

function MeshCreator:CreateEditableMesh(MeshSaveFile)
	self.EM = Instance.new("EditableMesh")

	if MeshSaveFile then
		local newVertexIDs = {}
		
		if self.MeshPart:FindFirstChildOfClass("EditableMesh") then
			self.MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
		end
		
		for _, Vertex: Classes.Vertex in MeshSaveFile.Vertices do
			local VertexUV = Vertex.VertexUV
			local VertexPosition = Vertex.VA_Position / (self.MeshPart.Size / self.MeshPart.MeshSize)
			local VN = Vertex.VA_Normal
			local newVertexID = self.EM:AddVertex(VertexPosition)
			
			self.EM:SetVertexNormal(newVertexID, VN)
			self.EM:SetUV(newVertexID, VertexUV)
			
			newVertexIDs[Vertex.ID] = newVertexID
			Vertex.ID = newVertexID
			
			table.insert(self.Vertices, Vertex)
		end
		
		for _, Triangle: Classes.Triangle in MeshSaveFile.Triangles do
			local TriangleVertexIDs = Triangle.VertexIDs
			local newTriangleVertexIDs = {}
			
			for _, TriangleVertexID in ipairs(TriangleVertexIDs) do
				table.insert(newTriangleVertexIDs, newVertexIDs[TriangleVertexID])
			end
			
			Triangle.ID = self.EM:AddTriangle(table.unpack(newTriangleVertexIDs))
			Triangle.VertexIDs = newTriangleVertexIDs
			
			table.insert(self.Triangles, Triangle)
		end
	elseif self.MeshPart.MeshId ~= "" then
		self.EM = AssetService:CreateEditableMeshFromPartAsync(self.MeshPart)
	else
		self.EM:SetAttribute("CustomMesh", true)
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
		self.EM:SetVA_Normal(vertexID, normal)
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
	
	local newCubeMesh: Classes.CustomMesh = {
		MeshID = 1,
		MeshType = Enums.MeshType.Cube,
		Vertices = VertexIDs,
		Triangles = TriangleIDs
	}

	return newCubeMesh
end

function MeshCreator:Remove()
	self:RemoveVertexAttachments()
	self.MeshGizmo:RemoveEdgeAdornments()
	
	self.MeshPart.Locked = false
	self = nil
end

return MeshCreator