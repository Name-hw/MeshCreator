local TableFunctions = {}

function TableFunctions.Compare(Table1, Table2)
	local IsSame
	
	for i, v in Table1 do
		if Table2[i] == v then
			IsSame = true
		else
			--IsSame = false
		end
	end
	
	return IsSame
end

return TableFunctions