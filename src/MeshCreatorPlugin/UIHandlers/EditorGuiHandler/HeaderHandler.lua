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
	self.VertexMenuButton = self.HeaderFrame.VertexMenuButton
	self.EdgeMenuButton = self.HeaderFrame.EdgeMenuButton
	self.TriangleMenuButton = self.HeaderFrame.TriangleMenuButton
	
	self.SM_Dropdown = GuiClasses.Dropdown.Create({"Vertex", "Edge", "Triangle"}, 3, self.SelectModeFrame.DropdownButton)
	


	--self.SM_Dropdown:Set(self.SM_Dropdown.ListFrame.ScrollFrame.Vertex_button)
	
    self.SM_Dropdown.Changed:Connect(function(option: TextButton)
		self.HeaderFrame:SetAttribute("SelectMode", option.Label.Text .. "Mode")
	end)
	

	
	return self
end

return HeaderHandler