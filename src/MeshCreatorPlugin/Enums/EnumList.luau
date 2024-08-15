local UserEnums_Class = require(script.Parent.UserEnums)
local UserEnum_Class = require(script.Parent.UserEnum)
local UserEnumItem_Class = require(script.Parent.UserEnumItem)

type UserEnums = UserEnums_Class.UserEnums
type UserEnum = UserEnum_Class.UserEnum
type UserEnumItem = UserEnumItem_Class.UserEnumItem

local EnumList = {
	--Please write the Enum you want to add here.

	SelectMode = {
		VertexMode = {} :: UserEnumItem, 
		EdgeMode = {} :: UserEnumItem,
		TriangleMode = {} :: UserEnumItem,
		FaceMode = {} :: UserEnumItem
	},
	ToolType = {
		AddVertexTool = {} :: UserEnumItem,
		ExtrudeRegionTool = {} :: UserEnumItem,
		
		UndoTool = {} :: UserEnumItem,
		RedoTool = {} :: UserEnumItem
	},
	MeshType = {
		Plane = {} :: UserEnumItem, 
		Cube = {} :: UserEnumItem, 
		Sphere = {} :: UserEnumItem
	}
}

return EnumList
