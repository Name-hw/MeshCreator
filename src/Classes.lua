local Enums = require(script.Parent.Enums)

export type Mesh = {
	MeshID: number,
	Vertices: Vertex?,
	Triangles: Triangle?,
}

export type CustomMesh = {
	MeshID: number,
	MeshType: Enums.MeshType,
	Vertices: Vertex?,
	Triangles: Triangle?,
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
	TriangleVertexIDs: {
		TriangleVertexID1: number,
		TriangleVertexID2: number,
		TriangleVertexID3: number
	},
	TriangleVertices: {
		Vertex1: Vertex,
		Vertex2: Vertex,
		Vertex3: Vertex
	}
}

return nil