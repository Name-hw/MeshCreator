local Enums = require(script.Parent.Enums)

export type Mesh = {
	MeshID: number,
	Vertices: Vertex,
	Triangles: Triangle,
}

export type CustomMesh = Mesh & {
	MeshType: Enums.CEnumItem
}

export type Vertex = {
	VertexID: number,
	VertexUV: Vector2,
	VertexAttachment: Attachment,
	VA_Position: Vector3,
	VA_Normal: Vector3
}

export type Triangle = {
	TriangleID: number,
	TriangleVertexIDs: {number},
}

return nil