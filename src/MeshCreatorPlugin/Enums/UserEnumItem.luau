--!strict
local UserEnumItem = {}

export type UserEnumItem_Properties = {
	Name: string,
	Value: number,
	EnumType: { [string]: UserEnumItem },
}
export type UserEnumItem = typeof(newproxy(true)) & UserEnumItem_Properties

function UserEnumItem.new(newUserEnumItem_Properties: UserEnumItem_Properties)
	local newUserEnumItem: UserEnumItem = newproxy(true)
	local newUserEnumItem_Metatable = getmetatable(newUserEnumItem)
	newUserEnumItem_Metatable.__index = function(_, index: string)
		local Property = newUserEnumItem_Properties[index]

		if Property then
			return Property
		else
			error(index .. "is not a valid member of" .. '"' .. tostring(newUserEnumItem) .. '"')
		end
	end
	newUserEnumItem_Metatable.__tostring = function(self): string
		return "Enum." .. tostring(self.EnumType) .. "." .. self.Name
	end
	newUserEnumItem_Metatable.__metatable = "The metatable is locked"

	return newUserEnumItem
end

return UserEnumItem
