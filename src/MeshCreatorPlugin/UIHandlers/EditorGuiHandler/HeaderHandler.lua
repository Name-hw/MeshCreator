local HeaderHandler = {}

local Root = script.Parent.Parent.Parent
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI

function HeaderHandler.new(HeaderFrame)
	local self = setmetatable(HeaderHandler, {})

	self.HeaderFrame = HeaderFrame
	self.SelectModeFrame = self.HeaderFrame.SelectModeFrame
	self.MenuFrame = self.HeaderFrame.MenuFrame
	
	self.SM_Dropdown = GuiClasses.Dropdown.Create({"Vertex", "Edge"}, 2, self.SelectModeFrame.DropdownButton)
	self.AddMenu_Dropdown = GuiClasses.Dropdown.Create({"Plane", "Cube"}, 2, self.MenuFrame.AddMenu_Dropdown)
	
	--self.SM_Dropdown:Set(self.SM_Dropdown.ListFrame.ScrollFrame.Vertex_button)
	
    self.SM_Dropdown.Changed:Connect(function(option: TextButton)
		self.HeaderFrame:SetAttribute("SelectMode", option.Label.Text .. "Mode")
	end)
	
	self.AddMenu_Dropdown.Changed:Connect(function(option: TextButton)
		self.HeaderFrame:SetAttribute("Menu", option.Label.Text .. "Mode")
	end)
	
	return self
end

return HeaderHandler