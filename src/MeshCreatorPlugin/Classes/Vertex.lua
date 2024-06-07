local Classes = require(script.Parent)

local VertexClass: Classes.Vertex = {
	ParentClass = script.Parent.GeometryElement
}
VertexClass.__index = VertexClass

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Root = script.Parent.Parent

function VertexClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	self.VertexAttachment = MeshCreator.CreateVertexAttachment(self.Parent.MeshPart, self.VA_Position)
	
	local EMVertexIDs = self.EMVertexIDs
	local VA: Attachment = self.VertexAttachment
	local LastVAPosition: Vector3
	local VAMovedRecording

	local function OnChanged(propertyName)
		local PropertyValue = VA[propertyName]
		
		if propertyName == "Position" then
			MeshCreator:SetVertexPosition(self, PropertyValue)
		end
	end
	
	local function OnAncestryChanged()
		if MeshCreator.IsPluginEnabled then
			self:Destroy()
		end
	end
	
	VA.Changed:Connect(function(propertyName)
		task.spawn(OnChanged, propertyName)
	end)
	
	VA.AncestryChanged:Connect(function()
		task.spawn(OnAncestryChanged)
	end)
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

	table.remove(self.Parent.Vertices, table.find(self.Parent.Vertices, self))
	
	for _, EMVertexID in self.EMVertexIDs do
		MeshCreator.EM:RemoveVertex(EMVertexID)
	end
end

return VertexClass