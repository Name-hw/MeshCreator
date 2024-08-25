local Classes = require(script.Parent)

local VertexClass = {
	ParentClass = script.Parent.GeometryElement
}
VertexClass.__index = VertexClass

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Root = script.Parent.Parent
local TableFunctions = require(Root.TableFunctions)

function VertexClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	self.VertexAttachment = MeshCreator.CreateVertexAttachment(self.Parent.MeshPart, self.VA_Position)
	self.Connections = {}

	local EMVertexIDs = self.EMVertexIDs
	local VA: Attachment = self.VertexAttachment
	local LastVAPosition: Vector3

	local function OnChanged(propertyName)
		local PropertyValue = VA[propertyName]
		
		if propertyName == "Position" then
			MeshCreator:SetVertexPosition(self, PropertyValue)

			--[[
			-- Try to begin a recording with a specific identifier
			local VAMovedRecording: string? = ChangeHistoryService:TryBeginRecording("VertexAttachment moved")

			-- Check if recording was successfully initiated
			if not VAMovedRecording then
				print(">")
				return
			end
		
			-- Finish the recording, committing the changes to the history
			ChangeHistoryService:FinishRecording(VAMovedRecording, Enum.FinishRecordingOperation.Commit)
			]]
		end
	end
	
	local function OnAncestryChanged()
		if MeshCreator.IsPluginEnabled then
			self:Destroy()
		end
	end
	
	table.insert(self.Connections, VA.Changed:Connect(function(propertyName)
		task.spawn(OnChanged, propertyName)
	end))
	
	table.insert(self.Connections, VA.AncestryChanged:Connect(function()
		task.spawn(OnAncestryChanged)
	end))
end

function VertexClass:SetUV(VertexUV: Vector2)
	local MeshCreator = self.Parent.MeshCreator
	self.VertexUV = VertexUV

	MeshCreator.EM:SetUV(VertexUV)
end

function VertexClass:AddEMVertex()
	local MeshCreator = self.Parent.MeshCreator
	local AddedEMVertexID = MeshCreator.EM:AddVertex(self.VA_Position / self.Parent.VA_Offset)

	table.insert(self.EMVertexIDs, AddedEMVertexID)
	table.insert(self.VertexNormals, MeshCreator.EM:GetVertexNormal(AddedEMVertexID))

	return AddedEMVertexID
end

function VertexClass:SetVAPosition(position: Vector3)
	self.VertexAttachment.Position = position
end

function VertexClass:Destroy()
	local MeshCreator = self.Parent.MeshCreator
	
	for _, connection: RBXScriptConnection in self.Connections do
		connection:Disconnect()
	end

	for _, IncludedEdge in ipairs(TableFunctions.GetEFElementsByVertexID(MeshCreator.Mesh.Edges, self.ID)) do
		IncludedEdge:Destroy()
	end

	for _, IncludedTriangle in ipairs(TableFunctions.GetEFElementsByVertexID(MeshCreator.Mesh.Triangles, self.ID)) do
		IncludedTriangle:Destroy()
	end

	table.remove(self.Parent.Vertices, table.find(self.Parent.Vertices, self))
	
	for _, EMVertexID in self.EMVertexIDs do
		MeshCreator.EM:RemoveVertex(EMVertexID)
	end

	if self.VertexAttachment then
		self.VertexAttachment:Destroy()
	end
end

return VertexClass