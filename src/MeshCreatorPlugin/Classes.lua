local Classes = {}

local Enums = require(script.Parent.Enums)

export type Mesh = {
	MeshID: number,
	Vertices: {Vertex},
	Triangles: {Triangle},
}

export type CustomMesh = Mesh & {
	MeshType: Enums.CEnumItem
}

export type GeometryElement = {
	ID: number
}

export type Vertex = GeometryElement & {
	VertexUV: Vector2,
	VertexAttachment: Attachment,
	VA_Position: Vector3,
	VA_Normal: Vector3
}

export type EFElement = GeometryElement & { --EdgeFaceElement
	VertexIDs: {number}
}

export type Edge = EFElement & {
	EdgeAdornment: LineHandleAdornment,
	StartVertexAttachment: Attachment,
	EndVertexAttachment: Attachment
}

export type Triangle = EFElement

for _, Class in script:GetChildren() do
	Classes[Class.Name] = require(Class)
end

return Classes