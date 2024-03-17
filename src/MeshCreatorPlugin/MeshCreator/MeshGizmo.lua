local MeshGizmo = {}
MeshGizmo.__index = MeshGizmo

local CoreGui = game:GetService("CoreGui")
local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local Vendor = Root.Vendor
local Triangle3D = require(Vendor.Triangle3D)
local EdgeGizmoFolder = CoreGui:FindFirstChild("MeshCreator_EdgeGizmoFolder")
local TriangleGizmoFolder = workspace.Camera:FindFirstChild("MeshCreator_TriangleGizmoFolder")

if not EdgeGizmoFolder then
	EdgeGizmoFolder = Instance.new("Folder")
	EdgeGizmoFolder.Name = "MeshCreator_EdgeGizmoFolder"
	EdgeGizmoFolder.Parent = CoreGui
end

if not TriangleGizmoFolder then
	TriangleGizmoFolder = Instance.new("Folder")
	TriangleGizmoFolder.Name = "MeshCreator_TriangleGizmoFolder"
	TriangleGizmoFolder.Parent = workspace.Camera
end

local TriangleDrawPreset = {
	build = true, -- Build?
	render = true, -- Render?
	draw = true, -- Draw? requires "build" and "render"
	parent = TriangleGizmoFolder -- Parent? requires "build"
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

function MeshGizmo:DrawLine(startVertex: Classes.Vertex, endVertex: Classes.Vertex)
	local Origin = startVertex.VA_Position
	local End = endVertex.VA_Position
	local Redundant = false
	
	for _, Edge: Classes.Edge in self.Edges do
		if table.find(Edge.VertexIDs, startVertex.ID) and table.find(Edge.VertexIDs, endVertex.ID) then
			Redundant = true
		end
	end
	
	if not Redundant then
		local LineAdornment: LineHandleAdornment

		if self.Settings["GizmoVisible"] then
			LineAdornment = self:CreateEdgeAdornment(Origin, End)
		end
		
		local EdgeClass: Classes.Edge = Classes.new("Edge", {
			ID = (#self.Edges + 1),
			VertexIDs = {startVertex.ID, endVertex.ID},
			EdgeAdornment = LineAdornment,
			StartVertexAttachment = startVertex.VertexAttachment,
			EndVertexAttachment = endVertex.VertexAttachment
		})
		
		self.Edges[EdgeClass.ID] = EdgeClass
	end
end

function MeshGizmo.new(Mesh: Classes.Mesh, Settings)
	local self = setmetatable({}, MeshGizmo)
	
	self.Edges = {}
	self.Mesh = Mesh
	self.Adornee = Mesh.MeshPart
	self.Settings = Settings
	
	return self
end

function MeshGizmo:Create(Vertices: {Classes.Vertex}, Triangles: {Classes.Triangle})
	for _, Triangle: Classes.Triangle in Triangles do
		local TriangleVertices = {}
		
		for _, triangleVertexID in ipairs(Triangle.VertexIDs) do
			table.insert(TriangleVertices, TableFunctions.GetVertexByVertexID(Vertices, triangleVertexID))
		end
		
		local TV1 = TriangleVertices[1]
		local TV2 = TriangleVertices[2]
		local TV3 = TriangleVertices[3]
		
		self:DrawLine(TV1, TV2)
		self:DrawLine(TV2, TV3)
		self:DrawLine(TV3, TV1)
		
		Triangle.Triangle3D = Triangle3D.new(
			TV1.VertexAttachment.WorldPosition,
			TV2.VertexAttachment.WorldPosition,
			TV3.VertexAttachment.WorldPosition,
			TriangleDrawPreset)
		Triangle.Triangle3D:Transparency(1)
	end
end

function MeshGizmo:RemoveGizmo()
	self:RemoveTriangleParts()
	self:RemoveEdgeAdornments()
end

function MeshGizmo:RemoveEdge(Edge: Classes.Edge)
	table.remove(self.Edges, table.find(self.Edges, Edge))
	--task.synchronize()
	Edge.EdgeAdornment:Destroy()
end

function MeshGizmo:RemoveEdgeByVertexID(vertexID)
	local EdgesContainingVertex = TableFunctions.GetEFElementsByVertexID(self.Edges, vertexID)
	
	for _, Edge: Classes.Edge in EdgesContainingVertex do
		--task.desynchronize()
		self:RemoveEdge(Edge)
	end
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
	for _, Edge: Classes.Edge in self.Edges do
		Edge.EdgeAdornment.Thickness = thickness
	end
end

function MeshGizmo:SetEAs_Visible(GizmoVisible)
	if GizmoVisible then
		for _, Edge: Classes.Edge in self.Edges do
			local Origin = Edge.StartVertexAttachment.Position
			local End = Edge.EndVertexAttachment.Position
			
			Edge.EdgeAdornment = self:CreateEdgeAdornment(Origin, End)
		end
	elseif not GizmoVisible then
		self:RemoveEdgeAdornments()
	end
end

function MeshGizmo:SetTPs_Visible(Triangles, TPsVisible)
	if TPsVisible then
		for _, Triangle: Classes.Triangle in Triangles do
			Triangle.Triangle3D:Transparency(0)
			Triangle.Triangle3D:Set("Locked", false)
		end
		
		self.Adornee.Transparency = 1
	elseif not TPsVisible then
		for _, Triangle: Classes.Triangle in Triangles do
			Triangle.Triangle3D:Transparency(1)
			Triangle.Triangle3D:Set("Locked", true)
		end
		
		self.Adornee.Transparency = 0
	end
end

function MeshGizmo.SetEA_Position(Edge: Classes.Edge) --SetEdgeAdornmentPosition
	local Origin = Edge.StartVertexAttachment.Position
	local End = Edge.EndVertexAttachment.Position
	--task.synchronize()
	Edge.EdgeAdornment.CFrame =  CFrame.new(Origin, End)
	Edge.EdgeAdornment.Length = (End - Origin).Magnitude
end

function MeshGizmo.SetTP_Position(Vertices: {Classes.Vertex}, Triangle: Classes.Triangle)
	local TriangleVertices = {}

	for _, triangleVertexID in ipairs(Triangle.VertexIDs) do
		table.insert(TriangleVertices, TableFunctions.GetVertexByVertexID(Vertices, triangleVertexID))
	end

	local TV1 = TriangleVertices[1]
	local TV2 = TriangleVertices[2]
	local TV3 = TriangleVertices[3]
	--task.synchronize()
	Triangle.Triangle3D:AnimateVertices(
		TV1.VertexAttachment.WorldPosition,
		TV2.VertexAttachment.WorldPosition,
		TV3.VertexAttachment.WorldPosition
	)
end

function MeshGizmo:UpdateEA_PositionByVertexID(vertexID)
	local EdgesContainingVertex = TableFunctions.GetEFElementsByVertexID(self.Edges, vertexID)

	for _, Edge: Classes.Edge in EdgesContainingVertex do
		--task.desynchronize()
		MeshGizmo.SetEA_Position(Edge)
	end
end

function MeshGizmo:UpdateTP_PositionByVertexID(Vertices: {Classes.Vertex}, Triangles: {Classes.Triangle}, vertexID)
	local TrianglesContainingVertex = TableFunctions.GetEFElementsByVertexID(Triangles, vertexID)
	
	for _, Triangle: Classes.Triangle in TrianglesContainingVertex do
		--task.desynchronize()
		MeshGizmo.SetTP_Position(Vertices, Triangle)
	end
end

return MeshGizmo