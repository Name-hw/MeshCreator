export type CEnumItem = {
	Value: number, 
	EnumType: CEnum
}

local Enums = {}

Enums.MeshType = {
	Plane = {
		Value = 1,
		EnumType = Enums.Plane
	}::CEnumItem, 
	Cube = {
		Value = 2,
		EnumType = Enums.Plane
	}::CEnumItem, 
	Sphere = {
		Value = 3,
		EnumType = Enums.Plane
	}::CEnumItem
}

return Enums