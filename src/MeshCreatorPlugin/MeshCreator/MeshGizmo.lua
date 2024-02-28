local MeshGizmo = {}
MeshGizmo.__index = MeshGizmo

local CoreGui = game:GetService("CoreGui")
local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib
local GizmoFolder = CoreGui:FindFirstChild("MeshCreator_GizmoFolder")

if not GizmoFolder then
	GizmoFolder = Instance.new("Folder")
	GizmoFolder.Name = "MeshCreator_GizmoFolder"
	GizmoFolder.Parent = CoreGui
end

function MeshGizmo:CreateEdgeAdornment(Origin, End)
	local LineAdornment = Instance.new("LineHandleAdornment")
		LineAdornment.Name = "EdgeAdornment"
		LineAdornment.Adornee = self.Adornee
		LineAdornment.CFrame =  CFrame.new(Origin, End)
		LineAdornment.Length = (End - Origin).Magnitude
		LineAdornment.Thickness = TableFunctions.GetSetting(self.Settings, "EA_Thickness")
		LineAdornment.ZIndex = 1
		LineAdornment.Parent = GizmoFolder
	
	return LineAdornment
end

function MeshGizmo:DrawLine(startVertex: Classes.Vertex, endVertex: Classes.Vertex)
	local Origin = startVertex.VertexAttachment.Position
	local End = endVertex.VertexAttachment.Position
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
		
		local EdgeClass: Classes.Edge = {
			ID = (#self.Edges + 1),
			VertexIDs = {startVertex.ID, endVertex.ID},
			EdgeAdornment = LineAdornment,
			StartVertexAttachment = startVertex.VertexAttachment,
			EndVertexAttachment = endVertex.VertexAttachment
		}
		
		self.Edges[EdgeClass.ID] = EdgeClass
	end
end

function MeshGizmo.new(Adornee, Settings)
	local self = setmetatable({}, MeshGizmo)
	
	self.Edges = {}
	self.Adornee = Adornee
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
	end
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
	for _, EdgeAdornment: LineHandleAdornment in GizmoFolder:GetChildren() do
		EdgeAdornment:Destroy()
	end
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

function MeshGizmo.SetEA_Position(Edge: Classes.Edge) --SetEdgeAdornmentPosition
	local Origin = Edge.StartVertexAttachment.Position
	local End = Edge.EndVertexAttachment.Position
	--task.synchronize()
	Edge.EdgeAdornment.CFrame =  CFrame.new(Origin, End)
	Edge.EdgeAdornment.Length = (End - Origin).Magnitude
end

function MeshGizmo.UpdateEA_Position(Edge: Classes.Edge, Vertices: {Classes.Vertex})
	--[[
	local VerticesInEdge = TableFunctions.GetVertexFromEFElement(Vertices, Edge)
	Edge.StartVertex = VerticesInEdge[1]
	Edge.EndVertex = VerticesInEdge[2]
	]]
	MeshGizmo.SetEA_Position(Edge)
end

function MeshGizmo:UpdateEA_PositionByVertexID(Vertices: {Classes.Vertex}, vertexID)
	local EdgesContainingVertex = TableFunctions.GetEFElementsByVertexID(self.Edges, vertexID)

	for _, Edge: Classes.Edge in EdgesContainingVertex do
		--task.desynchronize()
		--MeshGizmo.UpdateEA_Position(Edge, Vertices)
		MeshGizmo.SetEA_Position(Edge)
	end
end

return MeshGizmo