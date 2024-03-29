local Classes = {}

local Enums = require(script.Parent.Enums)

export type GeometryElement = {
	ID: number
}

export type Mesh = GeometryElement & {
	Name: string,
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
	VertexUV: Vector2,
	VertexAttachment: Attachment,
	VA_Position: Vector3 | string,
	VA_Normal: Vector3
}

export type EFElement = GeometryElement & { --EdgeFaceElement
	VertexIDs: {number},
	VertexAttachments: {Attachment}
}

export type Edge = EFElement & {
	EdgeAdornment: LineHandleAdornment,
	StartVertexAttachment: Attachment,
	EndVertexAttachment: Attachment
}

export type Triangle = EFElement & {
	Triangle3D: {}
}

export type Face = EFElement & {
	Triangles: {Triangle}
}

function Classes.new(className: string, data: {})
	local Class = require(script[className])
	local ParentClass = {}
	
	if Class.Parent then
		ParentClass = Classes.new(Class.Parent.Name)
	end
	
	local self = setmetatable(ParentClass, Class)
	
	if data then
		for name, value in pairs(data) do
			self[name] = value
		end
	end
	
	if self.Init then
		self:Init()
	end
	
	return self
end

return Classes