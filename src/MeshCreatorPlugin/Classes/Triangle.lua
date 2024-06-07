local Classes = require(script.Parent)

local TriangleClass: Classes.Triangle = {
	ParentClass = script.Parent.EFElement
}
TriangleClass.__index = TriangleClass

local Root = script.Parent.Parent
local TableFunctions = require(Root.TableFunctions)

local function getMaxAbsComponent(vector: Vector3)
    local absX = math.abs(vector.X)
    local absY = math.abs(vector.Y)
    local absZ = math.abs(vector.Z)

    local maxAbs = math.max(absX, absY, absZ)
    
    if maxAbs == absX then
        return vector.X
    elseif maxAbs == absY then
        return vector.Y
    else
        return vector.Z
    end
end


function TriangleClass:Init()
	local MeshCreator = self.Parent.MeshCreator

	if not self.VertexAttachments then
		self.VertexAttachments = TableFunctions.FindVertexDataFromEFElement(self.Parent.Vertices, self, "VertexAttachment")
	end

	local VAs: {Attachment} = self.VertexAttachments

	task.wait()
	self:UpdateTriangleNormal()

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
		if MeshCreator.IsPluginEnabled and table.find(self.Parent.Triangles, self) then
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

function TriangleClass:SetTriangle3DPrimaryPart()
	local TransformedTriangleNormal1: Vector3 = ((self.Parent.MeshPart.CFrame:ToObjectSpace(self.Triangle3D.Wedge1.CFrame)):VectorToObjectSpace(self.TriangleNormal))
	local TransformedTriangleNormal2: Vector3 = ((self.Parent.MeshPart.CFrame:ToObjectSpace(self.Triangle3D.Wedge2.CFrame)):VectorToObjectSpace(self.TriangleNormal))

	print(self.Triangle3D.Wedge1.CFrame, self.TriangleNormal)
	print(getMaxAbsComponent(TransformedTriangleNormal1))
	print(getMaxAbsComponent(TransformedTriangleNormal2))
	if getMaxAbsComponent(TransformedTriangleNormal1) > 0 then
		self.Triangle3D.Model.PrimaryPart = self.Triangle3D.Wedge1
	elseif getMaxAbsComponent(TransformedTriangleNormal2) > 0 then
		self.Triangle3D.Model.PrimaryPart = self.Triangle3D.Wedge2
	else
		warn("Problems with creating triangles. You will not be able to use MeshTools.")
	end
end

function TriangleClass:UpdateTriangleNormal()
	local MeshCreator = self.Parent.MeshCreator
	local v1: Vector3 = (MeshCreator.EM:GetPosition(self.EMVertexIDs[1]) - MeshCreator.EM:GetPosition(self.EMVertexIDs[2])).Unit
	local v2: Vector3 = (MeshCreator.EM:GetPosition(self.EMVertexIDs[1]) - MeshCreator.EM:GetPosition(self.EMVertexIDs[3])).Unit
	
	self.TriangleNormal = v1:Cross(v2)
end

function TriangleClass:Destroy()
	local TriangleID = self.ID
	table.remove(self.Parent.Triangles, table.find(self.Parent.Triangles, self))
	--task.synchronize()
	self.Parent.MeshCreator.EM:RemoveTriangle(TriangleID)
	self.Triangle3D.Model:Destroy()
end

return TriangleClass