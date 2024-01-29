local Selection = game:GetService("Selection")
local Root = script.Parent.Parent
local Vendor = Root.Vendor
local Roact = require(Vendor.Roact)
local StudioComponents = require(Vendor.StudioComponents)
local ToolBar = Roact.Component:extend("ToolBar")
local ToolList = require(script.ToolList)

function ToolBar:init()
	self.Visibility, self.UpdateVisibility = Roact.createBinding(true)
end

function ToolBar:render()
	return Roact.createElement("Frame",{
		AnchorPoint = Vector2.new(1, 0.5);
		BackgroundTransparency = 1;
		Position = UDim2.new(1, -10, 0.5, 0);
		Size = UDim2.new(0, 200, 0, 300);
		Visible = self.Visibility;
	}, {
		Roact.createElement("UIListLayout",{
			Padding = UDim.new(0, 1);
			FillDirection = Enum.FillDirection.Vertical;
			HorizontalAlignment = Enum.HorizontalAlignment.Left;
			VerticalAlignment = Enum.VerticalAlignment.Top;
			SortOrder = Enum.SortOrder.LayoutOrder;
		});
		ToolList = Roact.createElement(ToolList);
	})
end
--[[
function ToolBar:f()
	local IsSphere = Iris.State(false)
	--local EM = Iris:State(5):get()

	Iris.Window({"Mesh Creator"})
	Iris.Text({"Hello, World"})

	if Iris.Button({"Add Editable Mesh"}).clicked() then
		local Clicked = Iris.State(1)

		if Clicked == true then
			self:RemoveVertexAttachments()

			Iris.Button({"Add Editable Mesh"}).arguments.Text = "End"
		else
			local SelectingObject = Selection:Get()[1]

			if SelectingObject:IsA("MeshPart") then
				self.MeshPart = SelectingObject

				self:AddVertexAttachments()
			end

			Iris.Button({"Add Editable Mesh"}).arguments.Text = "End"
		end

		Clicked = not Clicked
	end

	Iris.Checkbox({"IsSphere"}, {isChecked = IsSphere})
	--Iris.InputNum({"Input"})
	Iris.End()
end
]]
return ToolBar