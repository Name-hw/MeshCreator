--Triangle Class
TriangleClass = {
	ParentClass = script.Parent.EFElement
}
TriangleClass.__index = TriangleClass

local Root = script.Parent.Parent
local Classes = require(script.Parent)
local TableFunctions = require(Root.TableFunctions)

function TriangleClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	if not self.VertexAttachments then
		self.VertexAttachments = TableFunctions.FindVertexAttachmentsFromEFElement(self.Parent.Vertices, self)
	end

	local VAs = self.VertexAttachments

	local function OnChanged(propertyName)
		if propertyName == "Position" then
			self.Triangle3D:AnimateVertices(
				VAs[1].WorldPosition,
				VAs[2].WorldPosition,
				VAs[3].WorldPosition
			)
		end
	end
	
	local function OnAncestryChanged()
		if table.find(self.Parent.Triangles, self) then
			self:Destroy()
		end
	end
	
	for _, VA in VAs do
		VA.Changed:Connect(function(propertyName)
			task.spawn(OnChanged, propertyName)
		end)
		
		VA.AncestryChanged:Connect(function()
			task.spawn(OnAncestryChanged)
		end)
	end
end

function TriangleClass:Destroy()
	local TriangleID = self.ID
	table.remove(self.Parent.Triangles, table.find(self.Parent.Triangles, self))
	--task.synchronize()
	self.Parent.MeshCreator.EM:RemoveTriangle(TriangleID)
	self.Triangle3D.Model:Destroy()
end

return TriangleClass