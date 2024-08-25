local Classes = require(script.Parent)

local TriangleClass = {
	ParentClass = script.Parent.EFElement
}
TriangleClass.__index = TriangleClass

local Selection = game:GetService("Selection")
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

	self.Connections = {}

	if not self.VertexAttachments then
		self.VertexAttachments = TableFunctions.FindVertexDataFromEFElement(self.Parent.Vertices, self, "VertexAttachment")
	end

	local VAs: {Attachment} = self.VertexAttachments
	
	self:UpdateTriangleNormal()

	local function OnVAChanged(propertyName)
		if propertyName == "Position" then
			self.Triangle3D:AnimateVertices(
				VAs[1].WorldPosition,
				VAs[2].WorldPosition,
				VAs[3].WorldPosition
			)
		end
	end
	
	for _, VA in VAs do
		table.insert(self.Connections, VA.Changed:Connect(function(propertyName)
			task.spawn(OnVAChanged, propertyName)
		end))
	end
end

function TriangleClass:SelectTriangle(isMultipleSelection: boolean)
	local MeshCreator = self.Parent.MeshCreator
	MeshCreator.IsTriangleSelected = true
	MeshCreator.LastSelectedTriangle = self

	self.Triangle3D:Set("BrickColor", BrickColor.new("Deep orange"))

	if isMultipleSelection then
		table.insert(MeshCreator.SelectedTriangles, self)
		Selection:Add({self.VertexAttachments[1], self.VertexAttachments[2], self.VertexAttachments[3], self.Triangle3D.Model})
	else
		for _, SelectedTriangle in MeshCreator.SelectedTriangles do
			SelectedTriangle:DeSelectTriangle()
		end

		table.insert(MeshCreator.SelectedTriangles, self)
		Selection:Set({self.VertexAttachments[1], self.VertexAttachments[2], self.VertexAttachments[3], self.Triangle3D.Model})
	end

	for _, t:Classes.Triangle in MeshCreator.SelectedTriangles do
		print(t.ID)
	end
end

function TriangleClass:DeSelectTriangle()
	local MeshCreator = self.Parent.MeshCreator

	self.Triangle3D:Set("Color", MeshCreator.MeshPart.Color)
	
	table.remove(MeshCreator.SelectedTriangles, table.find(MeshCreator.SelectedTriangles, self))
	
	Selection:Remove({self.VertexAttachments[1], self.VertexAttachments[2], self.VertexAttachments[3], self.Triangle3D.Model})
	
	for _, t:Classes.Triangle in MeshCreator.SelectedTriangles do
		print(t.ID)
	end
end

function TriangleClass:SetTriangle3DPrimaryPart()
	local TransformedTriangleNormal1: Vector3 = ((self.Parent.MeshPart.CFrame:ToObjectSpace(self.Triangle3D.Wedge1.CFrame)):VectorToObjectSpace(self.TriangleNormal))
	local TransformedTriangleNormal2: Vector3 = ((self.Parent.MeshPart.CFrame:ToObjectSpace(self.Triangle3D.Wedge2.CFrame)):VectorToObjectSpace(self.TriangleNormal))

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

	for _, connection: RBXScriptConnection in self.Connections do
		connection:Disconnect()
	end

	table.remove(self.Parent.Triangles, table.find(self.Parent.Triangles, self))
	--task.synchronize()
	self.Parent.MeshCreator.EM:RemoveTriangle(TriangleID)
	self.Triangle3D.Model:Destroy()
end

return TriangleClass