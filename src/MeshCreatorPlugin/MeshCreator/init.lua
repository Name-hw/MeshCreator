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

function MeshCreator.new(MeshPart: MeshPart, MeshSaveFile: Classes.Mesh, Settings, EditorGuiHandler)
	local newMeshCreator = setmetatable(MeshCreator, MeshFunctions)
	
	newMeshCreator.Settings = Settings
	newMeshCreator.MeshPart = MeshPart
	newMeshCreator.MeshPart.Locked = true
	newMeshCreator.Mesh = Classes.new("Mesh", {ID = 1, MeshCreator = newMeshCreator, Vertices = {}, Edges = {}, Triangles = {}, MeshPart = MeshPart})
	newMeshCreator.EditorGuiHandler = EditorGuiHandler
	newMeshCreator.SelectedTriangles = {}
	
	if newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh") and not MeshSaveFile then
		newMeshCreator.EM = newMeshCreator.MeshPart:FindFirstChildOfClass("EditableMesh")
		newMeshCreator.EM:SetAttribute("NoMeshID", false)
	else
		newMeshCreator:CreateEditableMesh(MeshSaveFile)
	end
	
	newMeshCreator.Mesh.EM = newMeshCreator.EM

	--[[
	newMeshCreator.VertexAttachmentFolder = Instance.new("Folder", newMeshCreator.EM)
	newMeshCreator.VertexAttachmentFolder.Name = "VertexAttachmentFolder"
	]]

	newMeshCreator.TriangleGizmoFolder = Instance.new("Folder", newMeshCreator.EM)
	newMeshCreator.TriangleGizmoFolder.Name = "TriangleGizmoFolder"

	newMeshCreator.MeshGizmo = MeshGizmo.new(newMeshCreator.Mesh, newMeshCreator.Settings, newMeshCreator.EditorGuiHandler)

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
		local newEMVertexIDsArray = {}
		
		if self.MeshPart:FindFirstChildOfClass("EditableMesh") then
			self.MeshPart:FindFirstChildOfClass("EditableMesh"):Destroy()
		end
		
		self.EditorGuiHandler.LoadingWindowHandler:SetTask("Creating vertex attachments", #MeshSaveFile.Vertices)

		for i, Vertex: Classes.Vertex in MeshSaveFile.Vertices do
			local VertexNormals = Vertex.VertexNormals
			local VertexUV = Vertex.VertexUV
			local VertexPosition = Vertex.VA_Position / self.Mesh.VA_Offset
			local newEMVertexIDs = {}

			for _ = 1, #Vertex.EMVertexIDs do
				table.insert(newEMVertexIDs, self.EM:AddVertex(VertexPosition))
			end
			
			local VertexClass: Classes.Vertex = Classes.new("Vertex", {
				ID = #self.Mesh.Vertices + 1,
				Parent = self.Mesh,
				EMVertexIDs = newEMVertexIDs,
				VertexNormals = VertexNormals,
				VertexUV = Vertex.VertexUV,
				VA_Position = Vertex.VA_Position
			})

			for index, newEMVertexID in newEMVertexIDs do
				self.EM:SetVertexNormal(newEMVertexID, VertexNormals[index])
				self.EM:SetUV(newEMVertexID, VertexUV)
			end
			
			newVertexIDs[Vertex.ID] = VertexClass.ID

			for index, EMVertexID in ipairs(Vertex.EMVertexIDs) do
				newEMVertexIDsArray[EMVertexID] = newEMVertexIDs[index]
			end
			
			table.insert(self.Mesh.Vertices, VertexClass)

			self.EditorGuiHandler.LoadingWindowHandler:UpdateProgressByCurrentProgress(i)

			if i % 100 == 0 then --waits 0.01 seconds every 100 attachments spawned
   				task.wait(0.01)
 			end
		end
		
		self.EditorGuiHandler.LoadingWindowHandler:SetTask("Loading triangle datas", #MeshSaveFile.Triangles)

		for i, Triangle: Classes.Triangle in MeshSaveFile.Triangles do
			local TriangleVertexIDs = Triangle.VertexIDs
			local newTriangleVertexIDs = {}
			local newTriangleEMVertexIDs = {}
			
			for _, TriangleVertexID in ipairs(TriangleVertexIDs) do
				table.insert(newTriangleVertexIDs, newVertexIDs[TriangleVertexID])
			end
			
			for _, TriangleEMVertexID in ipairs(Triangle.EMVertexIDs) do
				table.insert(newTriangleEMVertexIDs, newEMVertexIDsArray[TriangleEMVertexID])
			end

			local newTriangleID = self.EM:AddTriangle(table.unpack(newTriangleEMVertexIDs))
			
			local TriangleClass: Classes.Vertex = Classes.new("Triangle", {
				ID = newTriangleID,
				Parent = self.Mesh,
				VertexIDs = newTriangleVertexIDs,
				EMVertexIDs = newTriangleEMVertexIDs
			})

			table.insert(self.Mesh.Triangles, TriangleClass)

			self.EditorGuiHandler.LoadingWindowHandler:UpdateProgressByCurrentProgress(i)

			if i % 100 == 0 then
   				task.wait(0.01)
 			end
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
	
	table.insert(TriangleIDs, self.EM:AddTriangle(vertexIDs[1], vertexIDs[2], vertexIDs[3]))
	table.insert(TriangleIDs, self.EM:AddTriangle(vertexIDs[1], vertexIDs[4], vertexIDs[2]))
	
	return TriangleIDs
end

function MeshCreator:CreatePlaneMesh(width: number, height: number, orientation: Vector3, localUp: number, offset: Vector3)
	local OffsetCFrame = CFrame.new(offset) * CFrame.fromEulerAnglesYXZ(math.rad(orientation.X), math.rad(orientation.Y), math.rad(orientation.Z))
	local OffsetCFrameTable = table.pack(OffsetCFrame:GetComponents())
	local MaxDecimalPlace: number = 0

	for _, value: number in {width, height, localUp} do
		local _, FractionalPart = math.modf(value)
		local DecimalPlace = 0

		if FractionalPart ~= 0 then
			DecimalPlace = #(tostring(value):split(".")[2])
		end

		if MaxDecimalPlace < DecimalPlace then
			MaxDecimalPlace = DecimalPlace
		end
	end
	
	for index, value in pairs(OffsetCFrameTable) do
		OffsetCFrameTable[index] = math.round(value * 10^MaxDecimalPlace)/10^MaxDecimalPlace
	end

	OffsetCFrame = CFrame.new(table.unpack(OffsetCFrameTable))

	local VertexIDs = {
		self.EM:AddVertex((OffsetCFrame * Vector3.new(-width/2, height/2, localUp))),
		self.EM:AddVertex((OffsetCFrame * Vector3.new(width/2, -height/2, localUp))),
		self.EM:AddVertex((OffsetCFrame * Vector3.new(width/2, height/2, localUp))),
		self.EM:AddVertex((OffsetCFrame * Vector3.new(-width/2, -height/2, localUp))),
	}
	
	--local TriangleIDs = self:AddPlaneMeshFromVertexIDs(VertexIDs)
	self:AddPlaneMeshFromVertexIDs(VertexIDs)
	
	local newPlaneMesh: Classes.CustomMesh = {
		MeshID = 1,
		MeshType = Enums.MeshType.Plane,
		--Vertices = VertexIDs,
		--Triangles = TriangleIDs
	}

	return newPlaneMesh
end

function MeshCreator:CreateCubeMesh(scale: Vector3, offset: Vector3)
	self:CreatePlaneMesh(scale.X, scale.Z, Vector3.new(90, 0, 0), scale.Y/2, offset) --Top
	self:CreatePlaneMesh(scale.X, scale.Z, Vector3.new(-90, 0, 0), scale.Y/2, offset) --Bottom
	self:CreatePlaneMesh(scale.Z, scale.Y, Vector3.new(0, 0, 0), scale.Z/2, offset) --Back
	self:CreatePlaneMesh(scale.X, scale.Y, Vector3.new(0, 180, 0), scale.Z/2, offset) --Front
	self:CreatePlaneMesh(scale.Z, scale.Y, Vector3.new(0, 90, 0), scale.X/2, offset) --Left
	self:CreatePlaneMesh(scale.Z, scale.Y, Vector3.new(0, -90, 0), scale.X/2, offset) --Right

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