--Vertex Class
VertexClass = {
	ParentClass = script.Parent.GeometryElement
}
VertexClass.__index = VertexClass

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Root = script.Parent.Parent
local Classes = require(script.Parent)

function VertexClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	self.VertexAttachment = MeshCreator.CreateVertexAttachment(self.Parent.MeshPart, self.VA_Position, self.VA_Normal)

	local VertexID = self.ID
	local VA = self.VertexAttachment
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

function VertexClass:Destroy()
	local MeshCreator = self.Parent.MeshCreator

	table.remove(self.Parent.Vertices, table.find(self.Parent.Vertices, self))
	
	MeshCreator.EM:RemoveVertex(self.ID)
end

return VertexClass