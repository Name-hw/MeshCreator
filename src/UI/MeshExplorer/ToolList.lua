local Selection = game:GetService("Selection")
local Root = script.Parent.Parent.Parent
local Vender = Root.Vender
local Roact = require(Vender.Roact)
local StudioComponents = require(Vender.StudioComponents)
local ToolList = Roact.Component:extend("ToolList")
local MeshCreator = require(Root.MeshCreator)

function ToolList:init()
	self.clickCount, self.updateClickCount = Roact.createBinding(0)
end

function ToolList:render()
	return Roact.createElement("Frame",{
		BackgroundColor3 = Color3.new(0.313725, 0.313725, 0.313725);
		Position = UDim2.new(1, 0, 0, 0);
		Size = UDim2.new(0, 200 ,0, 300);
	}, {
		Roact.createElement("UIListLayout",{
			Padding = UDim.new(0, 1);
			FillDirection = Enum.FillDirection.Vertical;
			HorizontalAlignment = Enum.HorizontalAlignment.Left;
			VerticalAlignment = Enum.VerticalAlignment.Top;
			SortOrder = Enum.SortOrder.LayoutOrder;
		});
		Roact.createElement("TextButton",{
			Size = UDim2.new(0,200,0,50);
			Text = "Tool";
			[Roact.Event.Activated] = function(object,inputObject,clickCount)
				self.updateClickCount(self.clickCount:getValue()+1)
			end
		});
		["Fixed Position Checkbox"] = Roact.createElement(StudioComponents.Checkbox, {
			LayoutOrder = 2,
			Value = self.state.ModeY,
			Label = "CheckBox",
			OnActivated = function()
				self:setState({
					FixedPosition = not self.state.FixedPosition
				})
			end,
		});
	});
end

return ToolList