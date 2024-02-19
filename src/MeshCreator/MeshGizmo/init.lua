local MeshGizmo = {}
MeshGizmo.__index = MeshGizmo

local Root = script.Parent.Parent
local Classes = require(Root.Classes)
local TableFunctions = require(Root.TableFunctions)
local lib = Root.lib

function MeshGizmo:DrawLine(StartVertex: Classes.Vertex, EndVertex: Classes.Vertex)
	local Origin = StartVertex.VertexAttachment.Position
	local End = EndVertex.VertexAttachment.Position
	local Redundant = false
	
	for _, Edge: Classes.Edge in self.Edges do
		if table.find(Edge.VertexIDs, StartVertex.ID) and table.find(Edge.VertexIDs, EndVertex.ID) then
			Redundant = true
		end
	end
	
	if not Redundant then
		local LineAdornment = Instance.new("LineHandleAdornment")
		LineAdornment.Name = "EdgeAdornment"
		LineAdornment.Adornee = self.Adornee
		LineAdornment.CFrame =  CFrame.new(Origin, End)
		LineAdornment.Length = (End - Origin).Magnitude
		LineAdornment.Thickness = 5
		LineAdornment.Parent = workspace.Terrain
		
		local EdgeClass: Classes.Edge = {
			ID = (#self.Edges + 1),
			VertexIDs = {StartVertex.ID, EndVertex.ID},
			EdgeAdornment = LineAdornment
		}
		
		self.Edges[EdgeClass.ID] = EdgeClass
	end
end

function MeshGizmo.new(Adornee)
	local self = setmetatable({}, MeshGizmo)
	
	self.Edges = {}
	self.Adornee = Adornee
	
	return self
end

function MeshGizmo:Create(Vertices, Triangles)
	for _, Triangle: Classes.Triangle in Triangles do
		local TriangleVertices = {}
		
		for _, TriangleVertexID in ipairs(Triangle.VertexIDs) do
			table.insert(TriangleVertices, TableFunctions.GetVertexByVertexID(Vertices, TriangleVertexID))
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
	--task.synchronize()
	for _, Edge: Classes.Edge in self.Edges do
		Edge.EdgeAdornment:Destroy()
	end
end

function MeshGizmo:SetEA_Position(Edge: Classes.Edge) --SetEdgeAdornmentPosition
	local Origin = Edge.StartVertex.VertexAttachment.Position
	local End = Edge.EndVertex.VertexAttachment.Position
	--task.synchronize()
	Edge.EdgeAdornment.CFrame =  CFrame.new(Origin, End)
	Edge.EdgeAdornment.Length = (End - Origin).Magnitude
end

function MeshGizmo:Update(Edge: Classes.Edge, Vertices)
	Edge.StartVertex = TableFunctions.GetVertexByVertexID(Vertices, Edge.VertexIDs[1])
	Edge.EndVertex = TableFunctions.GetVertexByVertexID(Vertices, Edge.VertexIDs[2])
	
	self:SetEA_Position(Edge)
end

function MeshGizmo:UpdateByVertexID(Vertices, vertexID)
	local EdgesContainingVertex = TableFunctions.GetEFElementsByVertexID(self.Edges, vertexID)

	for _, Edge: Classes.Edge in EdgesContainingVertex do
		--task.desynchronize()
		self:Update(Edge, Vertices)
	end
end

return MeshGizmo