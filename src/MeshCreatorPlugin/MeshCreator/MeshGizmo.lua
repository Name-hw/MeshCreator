local MeshGizmo = {}
MeshGizmo.__index = MeshGizmo

local CoreGui = game:GetService("CoreGui")
local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local Vendor = Root.Vendor
local Triangle3D = require(Vendor.Triangle3D)
local EdgeGizmoFolder = CoreGui:FindFirstChild("MeshCreator_EdgeGizmoFolder") or Instance.new("Folder", CoreGui)
local TriangleGizmoFolder: Folder

EdgeGizmoFolder.Name = "MeshCreator_EdgeGizmoFolder"

local TriangleDrawPreset = {
	build = true, -- Build?
	render = true, -- Render?
	draw = true, -- Draw? requires "build" and "render"
	--parent = TriangleGizmoFolder -- Parent? requires "build"
}

function MeshGizmo:CreateEdgeAdornment(Origin, End)
	local LineAdornment = Instance.new("LineHandleAdornment")
		LineAdornment.Name = "EdgeAdornment"
		LineAdornment.Adornee = self.Adornee
		LineAdornment.CFrame =  CFrame.new(Origin, End)
		LineAdornment.Length = (End - Origin).Magnitude
		LineAdornment.Thickness = TableFunctions.GetSetting(self.Settings, "EA_Thickness")
		LineAdornment.ZIndex = 1
		LineAdornment.Parent = EdgeGizmoFolder
	
	return LineAdornment
end

function MeshGizmo:DrawLine(startVertexData: Classes.Vertex, endVertexData: Classes.Vertex)
	local Origin = startVertexData.VA_Position
	local End = endVertexData.VA_Position
	local Redundant = false
	
	for _, Edge: Classes.Edge in self.Mesh.Edges do
		if table.find(Edge.VertexIDs, startVertexData.ID) and table.find(Edge.VertexIDs, endVertexData.ID) then
			Redundant = true
		end
	end
	
	if not Redundant then
		local LineAdornment: LineHandleAdornment

		if self.Settings["EdgeVisible"] then
			LineAdornment = self:CreateEdgeAdornment(Origin, End)
		end
		
		local EdgeClass: Classes.Edge = Classes.new("Edge", {
			ID = (#self.Mesh.Edges + 1),
			Parent = self.Mesh,
			VertexIDs = {startVertexData.ID, endVertexData.ID},
			EdgeAdornment = LineAdornment,
			VertexAttachments = {startVertexData.VertexAttachment, endVertexData.VertexAttachment}
		})
		
		self.Mesh.Edges[EdgeClass.ID] = EdgeClass
	end
end

function MeshGizmo:DrawLineFromVertexData(vertexData1, vertexData2, vertexData3)
	self:DrawLine(vertexData1, vertexData2)
	self:DrawLine(vertexData2, vertexData3)
	self:DrawLine(vertexData3, vertexData1)
	
	return self
end

function MeshGizmo:DrawLineFromTriangle(Triangle: Classes.Triangle)
	local TVD1: Classes.Vertex = { --TriangleVertexData
		ID = Triangle.VertexIDs[1],
		VertexAttachment = Triangle.VertexAttachments[1],
		VA_Position = Triangle.VertexAttachments[1].Position
	}
	local TVD2: Classes.Vertex = { --TriangleVertexData
		ID = Triangle.VertexIDs[2],
		VertexAttachment = Triangle.VertexAttachments[2],
		VA_Position = Triangle.VertexAttachments[2].Position
	}
	local TVD3: Classes.Vertex = { --TriangleVertexData
		ID = Triangle.VertexIDs[3],
		VertexAttachment = Triangle.VertexAttachments[3],
		VA_Position = Triangle.VertexAttachments[3].Position
	}
	
	self:DrawLineFromVertexData(TVD1, TVD2, TVD3)
	
	return self
end

function MeshGizmo:DrawTriangle(Triangle: Classes.Triangle, TriangleVertexAttachments: {Attachment})
	local TVA1 = TriangleVertexAttachments[1]
	local TVA2 = TriangleVertexAttachments[2]
	local TVA3 = TriangleVertexAttachments[3]

	Triangle.Triangle3D = Triangle3D.new(
		TVA1.WorldPosition,
		TVA2.WorldPosition,
		TVA3.WorldPosition,
		TriangleDrawPreset)

	Triangle:SetTriangle3DPrimaryPart()
end

function MeshGizmo.new(Mesh: Classes.Mesh, Settings, EditorGuiHandler)
	local self = setmetatable({}, MeshGizmo)
	
	self.Mesh = Mesh
	self.Adornee = Mesh.MeshPart
	self.Settings = Settings
	self.EditorGuiHandler = EditorGuiHandler
	
	TriangleGizmoFolder = workspace:FindFirstChild("TriangleGizmoFolder")
	TriangleDrawPreset.parent = TriangleGizmoFolder
	
	return self
end

function MeshGizmo:Create()
	self.EditorGuiHandler.LoadingWindowHandler:SetTask("Creating edges and triangle parts", #self.Mesh.Triangles)

	for i, Triangle: Classes.Triangle in self.Mesh.Triangles do
		self:DrawLineFromTriangle(Triangle)
		self:DrawTriangle(Triangle, Triangle.VertexAttachments)
		Triangle.Triangle3D:Transparency(1)

		self.EditorGuiHandler.LoadingWindowHandler:UpdateProgressByCurrentProgress(i)

		if i % 100 == 0 then
   			task.wait(0.1)
 		end
	end
end

function MeshGizmo:RemoveGizmo()
	self:RemoveTriangleParts()
	self:RemoveEdgeAdornments()

	TriangleGizmoFolder:Destroy()
end

function MeshGizmo:RemoveEdgeAdornments()
	for _, EdgeAdornment: LineHandleAdornment in EdgeGizmoFolder:GetChildren() do
		EdgeAdornment:Destroy()
	end
end

function MeshGizmo:RemoveTriangleParts()
	for _, TrianglePart: MeshPart in TriangleGizmoFolder:GetChildren() do
		TrianglePart:Destroy()
	end
	
	self.Adornee.Transparency = 0
end

function MeshGizmo:SetEAs_Thickness(thickness)
	for _, Edge: Classes.Edge in self.Mesh.Edges do
		Edge.EdgeAdornment.Thickness = thickness
	end
end

function MeshGizmo:SetEAs_Visible(EdgeVisible)
	if EdgeVisible then
		for _, Edge: Classes.Edge in self.Mesh.Edges do
			local Origin = Edge.VertexAttachments[1].Position
			local End = Edge.VertexAttachments[2].Position
			
			Edge.EdgeAdornment = self:CreateEdgeAdornment(Origin, End)
		end
	elseif not EdgeVisible then
		self:RemoveEdgeAdornments()
	end
end

function MeshGizmo:SetTPs_Visible(TPsVisible)
	if TPsVisible then
		for _, Triangle: Classes.Triangle in self.Mesh.Triangles do
			Triangle.Triangle3D:Transparency(0)
			Triangle.Triangle3D:Set("Locked", false)
		end
		
		self.Adornee.Transparency = 1
	elseif not TPsVisible then
		for _, Triangle: Classes.Triangle in self.Mesh.Triangles do
			Triangle.Triangle3D:Transparency(1)
			Triangle.Triangle3D:Set("Locked", true)
		end
		
		self.Adornee.Transparency = 0
	end
end

return MeshGizmo