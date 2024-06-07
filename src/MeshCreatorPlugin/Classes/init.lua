local Classes = {}

local Enums = require(script.Parent.Enums)

export type GeometryElement = {
	ID: number,
	Parent: GeometryElement
}

export type Mesh = GeometryElement & {
	Name: string,
	MeshCreator: {},
	Vertices: {Vertex},
	Egdes: {Edge},
	Triangles: {Triangle},
	Faces: {Face},
	MeshPart: MeshPart,
	VA_Offset: Vector3
}

export type CustomMesh = Mesh & {
	MeshType: Enums.CEnumItem
}

export type Vertex = GeometryElement & {
	EMVertexIDs: {number},
	VertexNormals: {Vector3},
	VertexUV: Vector2,
	VertexAttachment: Attachment,
	VA_Position: Vector3 | string,
}

export type EFElement = GeometryElement & { --EdgeFaceElement
	VertexIDs: {number},
	EMVertexIDs: {number},
	VertexAttachments: {Attachment}
}

export type Edge = EFElement & {
	EdgeAdornment: LineHandleAdornment
}

export type Triangle = EFElement & {
	Triangle3D: {},
	TrianleNormal: Vector3
}

export type Face = EFElement & {
	Triangles: {Triangle}
}

function Classes.new(className: string, data: {}, NoInit: boolean)
	local Class = require(script[className])
	local ParentClass = {}
	
	if Class.ParentClass then
		ParentClass = Classes.new(Class.ParentClass.Name)
	end
	
	local self = setmetatable(ParentClass, Class)
	
	if data then
		for name, value in pairs(data) do
			self[name] = value
		end
	end
	
	if self.Init and not NoInit then
		self:Init()
	end
	
	return self
end

return Classes