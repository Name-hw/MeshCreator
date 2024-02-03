local Enums = {}

export type CEnumItem = {
	Value: number, 
	EnumType: Enum
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