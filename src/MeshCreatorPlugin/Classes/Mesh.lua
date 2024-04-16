--Mesh Class
MeshClass = {
	ParentClass = script.Parent.GeometryElement
}
MeshClass.__index = MeshClass

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

function MeshClass:Init()
	self.VA_Offset = SetVA_Offset(self.MeshPart)
	
	self.MeshPart:GetPropertyChangedSignal("Size"):Connect(function()
		self.VA_Offset = SetVA_Offset(self.MeshPart)
	end)
end

return MeshClass