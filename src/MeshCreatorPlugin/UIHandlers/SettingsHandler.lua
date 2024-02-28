local SettingsHandler = {}

local Root = script.Parent.Parent
local Enums = require(Root.Enums)
local Types = require(Root.Types)
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI
local SettingsFrame = UI.Settings
local CurrentSettings: Types.Settings = {}
local PreviousSettings: Types.Settings = {}

function SettingsHandler.new(parent, pluginSettings: {}, defaultSettings: {})
	local function checkSetting(settingName, Object)
		if pluginSettings[settingName] then
			Object.Frame.Text = pluginSettings[settingName]
		else
			Object.Frame.Text = defaultSettings[settingName]
		end
	end

	local self = SettingsHandler

	self.SettingsFrame = SettingsFrame
	self.ControlFrame = self.SettingsFrame.ControlFrame
	self.MenuFrame = self.SettingsFrame.MenuFrame
	self.EdgeThicknessFrame = self.MenuFrame.EdgeThicknessFrame
	self.GizmoVisibleFrame = self.MenuFrame.GizmoVisibleFrame

	--local EdgeThicknessSlider = GuiClasses.Slider.new(self.MenuFrame.EdgeThicknessFrame.SliderFrameX, "x")
	self.ET_TextMask = GuiClasses.TextMask.new(self.MenuFrame.EdgeThicknessFrame.TextBox)
	self.ET_TextMask:SetMaxLength(2)
	self.ET_TextMask:SetMaskType("Number")
	--self.SM_Dropdown = GuiClasses.Dropdown.new(self.SelectModeFrame.DropdownButton, self.SelectModeFrame.DropdownButton.ListFrame)
	self.GV_Checkbox = GuiClasses.CheckboxLabel.new(self.GizmoVisibleFrame)

	checkSetting("EA_Thickness", self.ET_TextMask)
	self.GV_Checkbox:SetValue(pluginSettings["GizmoVisible"])
	
	self.SettingsFrame.Parent = parent
	
	PreviousSettings = pluginSettings
	
	--[[
	EdgeThicknessSlider.Changed:Connect(function(value)
		ET_TextMask.Frame.Text = math.round(value * 50)
	end)
	]]
	self.ET_TextMask.Frame:GetPropertyChangedSignal("Text"):Connect(function()
		if self.ET_TextMask.Frame.Text then
			CurrentSettings["EA_Thickness"] = self.ET_TextMask.Frame.Text
		end
	end)
	--[[
	self.SM_Dropdown.Changed:Connect(function(option: TextButton)
		CurrentSettings["SelectMode"] = option.Label.Text .. "Mode"
	end)
	]]
	self.GV_Checkbox.Changed:Connect(function(bool: boolean)
		CurrentSettings["GizmoVisible"] = bool
	end)

	self.ControlFrame.ApplyButton.Activated:Connect(function()
		self:ApplySettings()
	end)
	
	self.ControlFrame.ResetButton.Activated:Connect(function()
		self.ET_TextMask.Frame.Text = defaultSettings["EA_Thickness"]
		self.GV_Checkbox:SetValue(defaultSettings["GizmoVisible"])
		
		for settingName, value in pairs(defaultSettings) do
			CurrentSettings[settingName] = value
		end

		self:ApplySettings()
	end)
	
	return self
end

function SettingsHandler:ApplySettings()
	for settingName, value in pairs(CurrentSettings) do
		if PreviousSettings[settingName] ~= value then
			self.SettingsFrame:SetAttribute(settingName, value)
			PreviousSettings[settingName] = value
			print(settingName, value)
		end
	end
end

return SettingsHandler