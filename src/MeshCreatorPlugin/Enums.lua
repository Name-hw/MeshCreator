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
	TriangleMode = {
		Value = 3,
		EnumType = Enums.SelectMode
	}::CEnumItem,
	FaceMode = {
		Value = 4,
		EnumType = Enums.SelectMode
	}::CEnumItem
}

Enums.Tool = {
	AddVertexTool = {
		Value = 0,
		EnumType = Enums.Tool
	}::CEnumItem,
	ExtrudeRegionTool = {
		Value = 1,
		EnumType = Enums.Tool
	}::CEnumItem,


	UndoTool = {
		Value = 11,
		EnumType = Enums.Tool
	}::CEnumItem,
	RedoTool = {
		Value = 12,
		EnumType = Enums.Tool
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