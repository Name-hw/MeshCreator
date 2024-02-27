local Enums = {}

export type CEnumItem = {
	Value: number, 
	EnumType: Enum
}

Enums.SelectMode = {
	VertexMode = {
		Value = 1,
		EnumType = Enums.SelectMode
	}::CEnumItem, 
	EdgeMode = {
		Value = 2,
		EnumType = Enums.SelectMode
	}::CEnumItem, 
	FaceMode = {
		Value = 3,
		EnumType = Enums.SelectMode
	}::CEnumItem
}

Enums.MeshType = {
	Plane = {
		Value = 1,
		EnumType = Enums.MeshType
	}::CEnumItem, 
	Cube = {
		Value = 2,
		EnumType = Enums.MeshType
	}::CEnumItem, 
	Sphere = {
		Value = 3,
		EnumType = Enums.MeshType
	}::CEnumItem
}

return Enums