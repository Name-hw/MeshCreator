local MeshCreator = {}
MeshCreator.IsPluginEnabled = false

local Selection = game:GetService("Selection")
local AssetService = game:GetService("AssetService")
local Root = script.Parent
local MeshFunctions = require(script.MeshFunctions)
local MeshGizmo = require(script.MeshGizmo)
local Classes = require(Root.Classes)
local Enums = require(Root.Enums)
local Types = require(Root.Types)
local TableFunctions = require(Root.TableFunctions)
local Vendor = Root.Vendor
local Triangle3D = require(Vendor.Triangle3D)
local lib = Root.lib
--local Table = require(script.Parent.lib.Table)

function MeshCreator.new(MeshPart: MeshPart, MeshSaveFile: Classes.Mesh, Settings)
	local newMeshCreator = setmetatable(MeshCreator, MeshFunctions)
	
	newMeshCreator.Settings = Settings
	newMeshCreator.MeshPart = MeshPart
	newMeshCreator.MeshPart.Locked = true
	newMeshCreator.Mesh = Classes.new("Mesh", {ID = 1, MeshCreator = newMeshCreator, Vertices = {}, Edges = {}, Triangles = {}, MeshPart = MeshPart})
	newMeshCreator.MeshGizmo = MeshGizmo.new(newMeshCreator.Mesh, newMeshCreator.Settings)
	newMeshCreator.SelectedTriangles = {}
	
	if newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh") and not MeshSaveFile then
		newMeshCreator.EM = newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh")
		newMeshCreator.EM:SetAttribute("NoMeshID", false)
	else
		newMeshCreator:CreateEditableMesh(MeshSaveFile)
	end
	
	return newMeshCreator
end

function MeshCreator:CreateEditableMesh(MeshSaveFile)
	self.EM = Instance.new("EditableMesh")
	
	assert(xpcall(function()
		self.EM:GetVertices()
	end, function()
		self:Remove()
	end), "Please enable EditableImage and EditableMesh in the beta features.")
	
	if MeshSaveFile then
		local newVertexIDs = {}
		
		if self.MeshPart:FindFirstChildOfClass("EditableMesh") then
			self.MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
		end
		
		for _, Vertex: Classes.Vertex in MeshSaveFile.Vertices do
			local VertexUV = Vertex.VertexUV
			local VertexPosition = Vertex.VA_Position / self.Mesh.VA_Offset
			local VN = Vertex.VA_Normal
			local newVertexID = self.EM:AddVertex(VertexPosition)
			
			local VertexClass: Classes.Vertex = Classes.new("Vertex", {
				ID = newVertexID,
				Parent = self.Mesh,
				VertexUV = Vertex.VertexUV,
				VA_Position = Vertex.VA_Position,
				VA_Normal = VN
			})
			
			self.EM:SetVertexNormal(newVertexID, VN)
			self.EM:SetUV(newVertexID, VertexUV)
			
			newVertexIDs[Vertex.ID] = newVertexID

			table.insert(self.Mesh.Vertices, VertexClass)
		end
		
		for _, Triangle: Classes.Triangle in MeshSaveFile.Triangles do
			local TriangleVertexIDs = Triangle.VertexIDs
			local newTriangleVertexIDs = {}
			
			for _, TriangleVertexID in ipairs(TriangleVertexIDs) do
				table.insert(newTriangleVertexIDs, newVertexIDs[TriangleVertexID])
			end
			
			local TriangleClass: Classes.Vertex = Classes.new("Triangle", {
				ID = self.EM:AddTriangle(table.unpack(newTriangleVertexIDs)),
				Parent = self.Mesh,
				VertexIDs = newTriangleVertexIDs
			})

			table.insert(self.Mesh.Triangles, TriangleClass)
		end
	elseif self.MeshPart.MeshId ~= "" then
		self.EM = AssetService:CreateEditableMeshFromPartAsync(self.MeshPart)
	else
		--self.EM:SetAttribute("CustomMesh", true)
		self.EM:SetAttribute("NoMeshID", true)
	end
	
	self.EM.Name = "EditableMesh"
	self.EM.Parent = self.MeshPart
end

function MeshCreator:AddPlaneMeshFromVertexIDs(vertexIDs)
	local TriangleIDs = {}
	
	table.insert(TriangleIDs, self.EM:AddTriangle(vertexIDs[1], vertexIDs[4], vertexIDs[2]))
	table.insert(TriangleIDs, self.EM:AddTriangle(vertexIDs[3], vertexIDs[2], vertexIDs[4]))
	
	return TriangleIDs
end

function MeshCreator:CreatePlaneMesh(width, height, offset: Vector3, normal: Vector3)
	local VertexIDs = {
		self.EM:AddVertex(Vector3.new(width/2, 0, height/2) + offset),
		self.EM:AddVertex(Vector3.new(-width/2, 0, height/2) + offset),
		self.EM:AddVertex(Vector3.new(-width/2, 0, -height/2) + offset),
		self.EM:AddVertex(Vector3.new(width/2, 0, -height/2) + offset)
	}
	local TriangleIDs = self:AddPlaneMeshFromVertexIDs(VertexIDs)
	
	for _, vertexID in VertexIDs do
		self.EM:SetVertexNormal(vertexID, normal)
	end
	
	local newPlaneMesh: Classes.CustomMesh = {
		MeshID = 1,
		MeshType = Enums.MeshType.Plane,
		--Vertices = VertexIDs,
		--Triangles = TriangleIDs
	}

	return newPlaneMesh
end

function MeshCreator:CreateCubeMesh(scale: Vector3, offset: Vector3)
	local HalfScale = scale/2
	local HalfScaleX = HalfScale.X
	local HalfScaleY = HalfScale.Y
	local HalfScaleZ = HalfScale.Z
	local VertexIDs = {}
	
	local VertexPositions = {
		Vector3.new(HalfScaleX, HalfScaleY, HalfScaleZ) + offset,
		Vector3.new(-HalfScaleX, HalfScaleY, HalfScaleZ) + offset,
		Vector3.new(-HalfScaleX, HalfScaleY, -HalfScaleZ) + offset,
		Vector3.new(HalfScaleX, HalfScaleY, -HalfScaleZ) + offset,
		Vector3.new(HalfScaleX, -HalfScaleY, -HalfScaleZ) + offset,
		Vector3.new(-HalfScaleX, -HalfScaleY, -HalfScaleZ) + offset,
		Vector3.new(-HalfScaleX, -HalfScaleY, HalfScaleZ) + offset,
		Vector3.new(HalfScaleX, -HalfScaleY, HalfScaleZ) + offset
	}

	for _, vertexPosition in VertexPositions do
		table.insert(VertexIDs, self.EM:AddVertex(vertexPosition))
	end

	self:AddPlaneMeshFromVertexIDs({VertexIDs[1], VertexIDs[2], VertexIDs[3], VertexIDs[4]}) --Top
	self:AddPlaneMeshFromVertexIDs({VertexIDs[4], VertexIDs[3], VertexIDs[6], VertexIDs[5]}) --Front
	self:AddPlaneMeshFromVertexIDs({VertexIDs[5], VertexIDs[6], VertexIDs[7], VertexIDs[8]}) --Bottom
	self:AddPlaneMeshFromVertexIDs({VertexIDs[2], VertexIDs[1], VertexIDs[8], VertexIDs[7]}) --Back
	self:AddPlaneMeshFromVertexIDs({VertexIDs[1], VertexIDs[4], VertexIDs[5], VertexIDs[8]}) --Right
	self:AddPlaneMeshFromVertexIDs({VertexIDs[3], VertexIDs[2], VertexIDs[7], VertexIDs[6]}) --Left
	
	--local TriangleIDs = self:AddTriangles(VertexIDs)
	
	for position, vertexID in VertexIDs do
		self.EM:SetVertexNormal(vertexID, VertexPositions[position].Unit)
	end
	
	local newCubeMesh: Classes.CustomMesh = {
		MeshID = 1,
		MeshType = Enums.MeshType.Cube,
		--Vertices = VertexIDs,
		--Triangles = TriangleIDs
	}

	return newCubeMesh
end

function MeshCreator:SelectTriangle(SelectingObject, IsShiftHeld)
	for _, Triangle: Classes.Triangle in self.Mesh.Triangles do
		if SelectingObject == Triangle.Triangle3D.Model then
			Triangle.Triangle3D:Set("BrickColor", BrickColor.new("Deep orange"))
			self.LastSelectedTriangle = Triangle
			
			table.insert(self.SelectedTriangles, Triangle)
			
			if IsShiftHeld then
				Selection:Add(Triangle.VertexAttachments)
			else
				Selection:Set({Triangle.VertexAttachments[1], Triangle.VertexAttachments[2], Triangle.VertexAttachments[3], Triangle.Triangle3D.Model})
			end
		end
	end
end

function MeshCreator:Remove()
	self.MeshGizmo:RemoveGizmo()
	
	self:RemoveVertexAttachments()
	
	self.MeshPart.Locked = false
	self = nil
end

return MeshCreator