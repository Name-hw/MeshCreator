local EditorGuiHandler = {}

local Root = script.Parent.Parent
local Vendor = Root.Vendor
local GuiLib = require(Vendor.GuiLib.LazyLoader)
local GuiClasses = GuiLib.Classes
local UI = Root.UI
local EditorGui = UI.MeshCreator_EditorGui
local UIHandlers = Root.UIHandlers
local HeaderHandler = require(UIHandlers.HeaderHandler)

function EditorGuiHandler.new(parent)
	local self = setmetatable(EditorGuiHandler, {})

    self.EditorGui = EditorGui:Clone()
	self.HeaderHandler = HeaderHandler.new(self.EditorGui.HeaderFrame)

	self.EditorGui.Parent = parent
	
	return self
end

return EditorGuiHandler