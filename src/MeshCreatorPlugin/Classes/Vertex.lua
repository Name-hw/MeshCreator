--Vertex Class
VertexClass = {
	ParentClass = script.Parent.GeometryElement
}
VertexClass.__index = VertexClass

local Classes = require(script.Parent)

local function SetVA_Offset(MeshPart: MeshPart)
	local VA_Offset

	if MeshPart.MeshSize ~= Vector3.zero then
		VA_Offset = (MeshPart.Size / MeshPart.MeshSize)
	else
		VA_Offset = MeshPart.Size
	end

	return VA_Offset
end

function VertexClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	local VertexID = self.ID
	local VA = self.VertexAttachment

	local function OnChanged(propertyName)
		local PropertyValue = VA[propertyName]
		
		if propertyName == "Position" then
			MeshCreator:SetVertexPosition(self, PropertyValue)
			
			if MeshCreator.Settings["GizmoVisible"] then
				MeshCreator.MeshGizmo:UpdateEA_PositionByVertexID(VertexID)
			end
			
			MeshCreator.MeshGizmo:UpdateTP_PositionByVertexID(VertexID)
		end
	end
	
	local function OnAncestryChanged()
		if MeshCreator.Settings["GizmoVisible"] then
			MeshCreator.MeshGizmo:RemoveEdgeByVertexID(VertexID)
		end
		
		MeshCreator:RemoveTriangleByVertexID(VertexID)
		MeshCreator:RemoveVertex(self)
	end
	
	VA.Changed:Connect(function(propertyName)
		task.spawn(OnChanged, propertyName)
	end)
	
	VA.AncestryChanged:Connect(function()
		if MeshCreator.IsPluginEnabled then
			task.spawn(OnAncestryChanged)
		end
	end)
end

return VertexClass