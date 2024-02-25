local SettingsPanel = {}
local Root = script.Parent.Parent
local Enums = require(Root.Enums)
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local SettingsFrame = script.Parent.Settings

function SettingsPanel.new(parent, pluginSettings: {})
	local self = {}
	
	self.SettingsFrame = SettingsFrame
	self.ControlFrame = self.SettingsFrame.ControlFrame
	self.MenuFrame = self.SettingsFrame.MenuFrame
	self.EdgeThicknessFrame = self.MenuFrame.EdgeThicknessFrame
	self.SelectModeFrame = self.MenuFrame.SelectModeFrame
	
	--local EdgeThicknessSlider = GuiClasses.Slider.new(self.MenuFrame.EdgeThicknessFrame.SliderFrameX, "x")
	self.ET_TextMask = GuiClasses.TextMask.new(self.MenuFrame.EdgeThicknessFrame.TextBox)
	self.ET_TextMask:SetMaxLength(2)
	self.ET_TextMask:SetMaskType("Number")
	self.SM_Dropdown = GuiClasses.Dropdown.new(self.SelectModeFrame.DropdownButton, self.SelectModeFrame.DropdownButton.ListFrame)
	
	if pluginSettings["EA_Thickness"] then
		self.ET_TextMask.Frame.Text = pluginSettings["EA_Thickness"]
	else
		self.ET_TextMask.Frame.Text = 5
	end
	
	self.SettingsFrame.Parent = parent
	
	--[[
	EdgeThicknessSlider.Changed:Connect(function(value)
		ET_TextMask.Frame.Text = math.round(value * 50)
	end)
	
	self.ET_TextMask.Frame.FocusLost:Connect(function()
		if self.ET_TextMask.Frame.Text then
			--EdgeThicknessSlider:Set(tonumber(self.ET_TextMask.Frame.Text) / 50, false)
		end
	end)
	]]
	
	self.SM_Dropdown.Changed:Connect(function(option: TextButton)
		self.SettingsFrame:SetAttribute("SelectMode", option.Label.Text .. "Mode")
	end)
	
	self.ControlFrame.ApplyButton.Activated:Connect(function()
		self.SettingsFrame:SetAttribute("EA_Thickness", self.ET_TextMask.Frame.Text)
	end)
	
	self.ControlFrame.ResetButton.Activated:Connect(function()
		self.ET_TextMask.Frame.Text = self.SettingsFrame:GetAttribute("EA_Thickness")
	end)
	
	return self
end

return SettingsPanel