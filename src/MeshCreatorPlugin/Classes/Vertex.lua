--Vertex Class
VertexClass = {
	ParentClass = script.Parent.GeometryElement
}
VertexClass.__index = VertexClass

local Root = script.Parent.Parent
local Classes = require(script.Parent)

function VertexClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	self.VertexAttachment = MeshCreator.CreateVertexAttachment(self.Parent.MeshPart, self.VA_Position, self.VA_Normal)

	local VertexID = self.ID
	local VA = self.VertexAttachment

	local function OnChanged(propertyName)
		local PropertyValue = VA[propertyName]
		
		if propertyName == "Position" then
			MeshCreator:SetVertexPosition(self, PropertyValue)
		end
	end
	
	local function OnAncestryChanged()
		if MeshCreator.IspluginEnabled then
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

function VertexClass:Destroy()
	table.remove(self.Mesh.Vertices, table.find(self.Mesh.Vertices, self))
	
	self.EM:RemoveVertex(self.ID)
end

return VertexClass