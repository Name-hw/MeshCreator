--!strict
local UserEnums_Class = require(script.UserEnums)
local UserEnum_Class = require(script.UserEnum)
local UserEnumItem_Class = require(script.UserEnumItem)
local EnumList = require(script.EnumList)

assert(EnumList, "Please write a module script for 'EnumList'")

export type UserEnums = UserEnums_Class.UserEnums
export type UserEnum = UserEnum_Class.UserEnum
export type UserEnumItem = UserEnumItem_Class.UserEnumItem

local Enums_Properties: UserEnums_Class.UserEnums_Properties = {}
local Enums: UserEnums & typeof(EnumList) = UserEnums_Class.new(Enums_Properties)

for enumName: string, enumItemNames: { [string]: {} } in pairs(EnumList) do
	local newUserEnum_Properties: UserEnum_Class.UserEnum_Properties = {}
	local newUserEnum: UserEnum = UserEnum_Class.new(Enums_Properties, newUserEnum_Properties)
	local order = 0

	for name: string, _ in pairs(enumItemNames) do
		newUserEnum_Properties[name] = UserEnumItem_Class.new({ Name = name, Value = order, EnumType = newUserEnum })
		order += 1
	end

	Enums_Properties[enumName] = newUserEnum
end

return Enums
