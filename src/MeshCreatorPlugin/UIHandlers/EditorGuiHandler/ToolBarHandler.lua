local ToolBarHandler = {}

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Root = script.Parent.Parent.Parent
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI
local SelectedToolButton

function ToolBarHandler.new(ToolBarFrame: Frame)
	local self = setmetatable(ToolBarHandler, {})
	
	self.ToolBarFrame = ToolBarFrame
	self.ToolListFrame = self.ToolBarFrame.ToolListFrame

	self.ToolButtons = {}
	
	for _, toolButton: ImageButton? in self.ToolBarFrame.ToolListFrame:GetChildren() do
		if toolButton:IsA("ImageButton") then
			local HintLabel: TextLabel = toolButton:FindFirstChild("HintLabel")
			local IsToolSelected = false

			table.insert(self.ToolButtons, toolButton)
			
			local function OnActivated(inputObject: InputObject, clickCount: number)
				IsToolSelected = not IsToolSelected
				
				if IsToolSelected then
					if SelectedToolButton then
						self:DisableToolButton(SelectedToolButton)
					end

					self:EnableToolButton(toolButton)
					SelectedToolButton = toolButton
				else
					self:DisableToolButton(toolButton)
				end
			end
			
			local function OnMouseEnter(inputObject: InputObject, clickCount: number)
				HintLabel.Visible = true
			end

			local function OnMouseLeave(inputObject: InputObject, clickCount: number)
				HintLabel.Visible = false
			end

			toolButton.Activated:Connect(OnActivated)
			toolButton.MouseEnter:Connect(OnMouseEnter)
			toolButton.MouseLeave:Connect(OnMouseLeave)
		end
	end

	for _, historyButton: ImageButton? in self.ToolBarFrame.HistoryFrame:GetChildren() do
		if historyButton:IsA("ImageButton") then
			local HintLabel: TextLabel = historyButton:FindFirstChild("HintLabel")

			table.insert(self.ToolButtons, historyButton)
			
			local function OnActivated(inputObject: InputObject, clickCount: number)
				if historyButton.Name == "UndoButton" then
					if ChangeHistoryService:GetCanUndo() then
						ChangeHistoryService:Undo()
					end
				elseif historyButton.Name == "RedoButton" then
					if ChangeHistoryService:GetCanRedo() then
						ChangeHistoryService:Redo()
					end
				end
			end
			
			local function OnMouseEnter(inputObject: InputObject, clickCount: number)
				HintLabel.Visible = true
			end

			local function OnMouseLeave(inputObject: InputObject, clickCount: number)
				HintLabel.Visible = false
			end

			historyButton.Activated:Connect(OnActivated)
			historyButton.MouseEnter:Connect(OnMouseEnter)
			historyButton.MouseLeave:Connect(OnMouseLeave)
		end
	end
	
	return self
end

function ToolBarHandler:EnableToolButton(toolButton: ImageButton)
	toolButton.BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647)
	self.ToolBarFrame:SetAttribute("CurrentTool", string.gsub(toolButton.Name, "Button", ""))
end

function ToolBarHandler:DisableToolButton(toolButton: ImageButton)
	toolButton.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
	self.ToolBarFrame:SetAttribute("CurrentTool", nil)
end

function ToolBarHandler:DisableAllToolButton()
	for _, toolButton: ImageButton in self.ToolButtons do
		self:DisableToolButton(toolButton)
	end
end

return ToolBarHandler