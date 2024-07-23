--!strict
local UserEnumItem_Class = require(script.Parent.UserEnumItem)

export type UserEnum_Properties = { [string]: UserEnumItem_Class.UserEnumItem }
export type UserEnum_Methods = { GetEnumItems: (self: UserEnum) -> { UserEnumItem_Class.UserEnumItem } }
export type UserEnum = typeof(newproxy(true)) & UserEnum_Properties & UserEnum_Methods

local UserEnum = {}

function UserEnum.new(Enums, UserEnum_Properties: UserEnum_Properties)
	local newUserEnum: UserEnum = newproxy(true)
	local newUserEnum_Methods: UserEnum_Methods = {
		GetEnumItems = function(): { UserEnumItem_Class.UserEnumItem }
			local EnumItems = {}

			for _, value: UserEnumItem_Class.UserEnumItem in pairs(UserEnum_Properties) do
				table.insert(EnumItems, value)
			end

			return EnumItems
		end,
	}
	local newUserEnum_Metatable = getmetatable(newUserEnum)
	newUserEnum_Metatable.__index = function(_, index: string | UserEnumItem_Class.UserEnumItem)
		local Property = UserEnum_Properties[index] or newUserEnum_Methods[index]

		if Property then
			return Property
		else
			error(index .. " is not a valid member of " .. '"' .. "Enum." .. tostring(newUserEnum) .. '"', 2)
		end
	end
	newUserEnum_Metatable.__tostring = function(self: UserEnum): string
		local EnumName: string

		for name: string, enum: UserEnum in Enums do
			if enum == self then
				EnumName = name
			end
		end

		return EnumName
	end
	newUserEnum_Metatable.__metatable = "The metatable is locked"

	return newUserEnum
end

return UserEnum
