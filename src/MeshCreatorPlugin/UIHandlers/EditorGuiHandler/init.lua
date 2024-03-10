local EditorGuiHandler = {}

local Root = script.Parent.Parent
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI
local EditorGui = UI.MeshCreator_EditorGui
local HeaderHandler = require(script.HeaderHandler)
local ToolBarHandler = require(script.ToolBarHandler)

function EditorGuiHandler.new(parent)
	local self = setmetatable(EditorGuiHandler, {})
	
	self.EditorGui = EditorGui:Clone()
	self.HeaderHandler = HeaderHandler.new(self.EditorGui.HeaderFrame)
	self.ToolBarHandler = ToolBarHandler.new(self.EditorGui.ToolBarFrame)

	if parent:FindFirstChild("MeshCreator_EditorGui") then
		parent:FindFirstChild("MeshCreator_EditorGui"):Destroy()
	end

	self.EditorGui.Parent = parent
	
	return self
end

return EditorGuiHandler