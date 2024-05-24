local LoadingWindowHandler = {}

local Root = script.Parent.Parent.Parent
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI

function LoadingWindowHandler.new(LoadingWindowFrame: Frame)
	local self = setmetatable(LoadingWindowHandler, {})

	self.LoadingWindowFrame = LoadingWindowFrame
	self.ProgressBarFrame = self.LoadingWindowFrame.ProgressBarFrame
	self.ProgressBarLabel = self.ProgressBarFrame.ProgressBarLabel
	self.ProgressLabel = self.ProgressBarFrame.ProgressLabel
	self.TaskLabel = self.ProgressBarFrame.TaskLabel
	
	return self
end

function LoadingWindowHandler:SetTask(taskName: string, maximumProgress: number)
	self.taskName = taskName
	self.maximumProgress = maximumProgress
	self.LoadingWindowFrame.Visible = true
	self.ProgressBarLabel.Size = UDim2.new(0, 0, 1, 0)
	self.ProgressLabel.Text = "0"
	self.TaskLabel.Text = taskName
end

function LoadingWindowHandler:UpdateProgress(progressPercentage: number)
	self.ProgressBarLabel.Size = UDim2.new(progressPercentage/100, 0, 1, 0)
	self.ProgressLabel.Text = progressPercentage .. "/100"
end

function LoadingWindowHandler:UpdateProgressByCurrentProgress(currentProgress: number)
	self:UpdateProgress(math.floor(currentProgress/self.maximumProgress * 100))
end

function LoadingWindowHandler:Close()
	self.LoadingWindowFrame.Visible = false
end

return LoadingWindowHandler