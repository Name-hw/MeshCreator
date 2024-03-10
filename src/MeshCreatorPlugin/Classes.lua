local Classes = {}

local Enums = require(script.Parent.Enums)

export type GeometryElement = {
	ID: number
}

export type Mesh = GeometryElement & {
	Vertices: {Vertex},
	Triangles: {Triangle},
	Faces: {Face}
}

export type CustomMesh = Mesh & {
	MeshType: Enums.CEnumItem
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

export type Face = EFElement & {
	FaceAdornment: handle,
	StartVertexAttachment: Attachment,
	EndVertexAttachment: Attachment
}

--[[
for _, Class in script:GetChildren() do
	Classes[Class.Name] = require(Class)
end
]]
return Classes