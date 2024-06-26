EdgeClass = {
	ParentClass = script.Parent.EFElement
}
EdgeClass.__index = EdgeClass

local Classes = require(script.Parent)

function EdgeClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	local VAs = self.VertexAttachments

	local function OnChanged(propertyName)
		if propertyName == "Position" then
			if MeshCreator.Settings["GizmoVisible"] then
				local Origin = self.VertexAttachments[1].Position
				local End = self.VertexAttachments[2].Position
				--task.synchronize()
				self.EdgeAdornment.CFrame =  CFrame.new(Origin, End)
				self.EdgeAdornment.Length = (End - Origin).Magnitude
			end
		end
	end
	
	local function OnAncestryChanged()
		if MeshCreator.Settings["GizmoVisible"] then
			table.remove(self.Parent.Edges, table.find(self.Parent.Edges, self))
			--task.synchronize()
			self.EdgeAdornment:Destroy()
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

return EdgeClass