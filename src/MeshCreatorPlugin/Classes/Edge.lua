local EdgeClass = {
	ParentClass = script.Parent.EFElement
}
EdgeClass.__index = EdgeClass

local Classes = require(script.Parent)

function EdgeClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	local VAs = self.VertexAttachments

	local function OnChanged(propertyName)
		if propertyName == "Position" then
			if MeshCreator.Settings["EdgeVisible"] then
				local Origin = self.VertexAttachments[1].Position
				local End = self.VertexAttachments[2].Position
				--task.synchronize()
				self.EdgeAdornment.CFrame =  CFrame.new(Origin, End)
				self.EdgeAdornment.Length = (End - Origin).Magnitude
			end
		end
	end
	
	for _, VA in VAs do
		VA.Changed:Connect(function(propertyName)
			task.spawn(OnChanged, propertyName)
		end)
	end
end

function EdgeClass:Destroy()
	local MeshCreator = self.Parent.MeshCreator

	if MeshCreator.Settings["EdgeVisible"] then
		table.remove(self.Parent.Edges, table.find(self.Parent.Edges, self))
		--task.synchronize()
		self.EdgeAdornment:Destroy()
	end
end

return EdgeClass