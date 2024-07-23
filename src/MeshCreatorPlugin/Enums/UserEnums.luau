--!strict
local UserEnum_Class = require(script.Parent.UserEnum)

export type UserEnums_Properties = { [string | UserEnum_Class.UserEnum]: UserEnum_Class.UserEnum }
export type UserEnums_Methods = { GetEnums: (self: UserEnums) -> { UserEnum_Class.UserEnum } }
export type UserEnums = typeof(newproxy(true)) & UserEnums_Properties & UserEnums_Methods

local UserEnums = {}

function UserEnums.new(UserEnums_Properties: UserEnums_Properties): UserEnums
	local newUserEnums: UserEnums = newproxy(true)
	local newUserEnums_Methods = {
		GetEnums = function(_: UserEnums): { UserEnum_Class.UserEnum }
			local Enums = {}

			for _, value: UserEnum_Class.UserEnum_Properties in pairs(UserEnums_Properties) do
				table.insert(Enums, value)
			end

			return Enums
		end,
	}
	local newUserEnums_Metatable = getmetatable(newUserEnums)
	newUserEnums_Metatable.__index = function(_, index: string | UserEnum_Class.UserEnum): string
		local value = rawget(UserEnums_Properties, tostring(index)) or rawget(newUserEnums_Methods, tostring(index))

		if value then
			return value
		else
			error(index .. " is not a valid member of " .. '"Enums"', 2)
		end
	end
	newUserEnums_Metatable.__tostring = function(): string
		return "UserEnums"
	end
	newUserEnums_Metatable.__metatable = "The metatable is locked"

	return newUserEnums
end

return UserEnums
