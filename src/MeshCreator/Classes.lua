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
	VertexPosition: Vector3,
	VertexNormal: Vector3,
	VertexAttachment: Attachment
}

export type Triangle = {
	TriangleID: number,
	TriangleVertices: {
		Vertex1: Vertex,
		Vertex2: Vertex,
		Vertex3: Vertex
	}
}

return nil