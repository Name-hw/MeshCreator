local HeaderHandler = {}

local Root = script.Parent.Parent
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI

function HeaderHandler.new(HeaderFrame)
	local self = setmetatable(HeaderHandler, {})

	self.HeaderFrame = HeaderFrame
	self.SelectModeFrame = self.HeaderFrame.SelectModeFrame

	self.SM_Dropdown = GuiClasses.Dropdown.new(self.SelectModeFrame.DropdownButton, self.SelectModeFrame.DropdownButton.ListFrame)
	
    self.SM_Dropdown.Changed:Connect(function(option: TextButton)
		self.HeaderFrame:SetAttribute("SelectMode", option.Label.Text .. "Mode")
	end)
	
	return self
end

return HeaderHandler