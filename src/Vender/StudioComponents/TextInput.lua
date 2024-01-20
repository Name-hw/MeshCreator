local TextService = game:GetService("TextService")

local Vendor = script.Parent.Parent
local Roact = require(Vendor.Roact)
local Hooks = require(Vendor.RoactHooks)

local joinDictionaries = require(script.Parent.joinDictionaries)
local withTheme = require(script.Parent.withTheme)

local Constants = require(script.Parent.Constants)

local PLACEHOLDER_TEXT_COLOR = Color3.fromRGB(102, 102, 102) -- works for both themes
local EDGE_PADDING_PX = 5

local defaultProps = {
	Size = UDim2.new(1, 0, 0, 21),
	Disabled = false,
	Text = "",
	PlaceholderText = "",
	OnFocused = function() end,
	OnFocusLost = function() end,
	OnChanged = function() end,
}

local function getTextWidth(text)
	local frameSize = Vector2.new(math.huge, math.huge)
	if #text == 0 then
		return 0
	end
	return TextService:GetTextSize(text, Constants.TextSize, Constants.Font, frameSize).X + 1
end

local function TextInput(props, hooks)
	local hovered, setHovered = hooks.useState(false)
	local focused, setFocused = hooks.useState(false)

	local containerRef = hooks.useValue(Roact.createRef())
	local innerOffset = hooks.useValue(0)
	local cursorPosition, setCursorPosition = hooks.useState(-1)

	local mainModifier = Enum.StudioStyleGuideModifier.Default
	local borderModifier = Enum.StudioStyleGuideModifier.Default
	if props.Disabled then
		mainModifier = Enum.StudioStyleGuideModifier.Disabled
		borderModifier = Enum.StudioStyleGuideModifier.Disabled
	elseif focused then
		borderModifier = Enum.StudioStyleGuideModifier.Selected
	elseif hovered then
		borderModifier = Enum.StudioStyleGuideModifier.Hover
	end

	local function onInputBegan(_, inputObject)
		if props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(true)
		end
	end

	local function onInputEnded(_, inputObject)
		if props.Disabled then
			return
		elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			setHovered(false)
		end
	end

	local function onFocused()
		setFocused(true)
		props.OnFocused()
	end

	local function onFocusLost(rbx, enterPressed, inputObject)
		setFocused(false)
		props.OnFocusLost(rbx.Text, enterPressed, inputObject)
	end

	local function onTextChanged(rbx)
		props.OnChanged(rbx.Text)
	end

	local function onCursorChanged(rbx)
		setCursorPosition(rbx.CursorPosition)
	end

	local container = containerRef.value:getValue()
	if not props.Disabled and container then
		local min = EDGE_PADDING_PX
		local max = container.AbsoluteSize.X - EDGE_PADDING_PX

		local text = string.sub(props.Text, 1, cursorPosition - 1)
		local offset = getTextWidth(text) + EDGE_PADDING_PX

		local innerArea = max - min
		local fullOffset = offset + innerOffset.value
		local fullTextWidth = getTextWidth(props.Text)
		if fullTextWidth <= innerArea or not focused then
			innerOffset.value = 0
		else
			if fullOffset < min then
				innerOffset.value += min - fullOffset
			elseif fullOffset > max then
				innerOffset.value -= fullOffset - max
			end
			innerOffset.value = math.max(innerOffset.value, innerArea - fullTextWidth)
		end
	else
		innerOffset.value = 0
	end

	local textFieldSize = UDim2.fromScale(1, 1)
	if container and focused then
		local fullTextWidth = getTextWidth(props.Text)
		textFieldSize = UDim2.new(
			UDim.new(0, math.max(container.AbsoluteSize.X, fullTextWidth + EDGE_PADDING_PX * 2)),
			UDim.new(1, 0)
		)
	end

	local padding = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, EDGE_PADDING_PX),
		PaddingRight = UDim.new(0, EDGE_PADDING_PX),
	})

	return withTheme(function(theme)
		local textFieldProps = {
			Size = textFieldSize,
			Position = UDim2.fromOffset(innerOffset.value, 0),
			BackgroundTransparency = 1,
			Font = Constants.Font,
			Text = props.Text,
			TextSize = Constants.TextSize,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText, mainModifier),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = if focused then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd,
		}

		local textField = props.Disabled and Roact.createElement("TextLabel", textFieldProps, { Padding = padding })
			or Roact.createElement(
				"TextBox",
				joinDictionaries(textFieldProps, {
					PlaceholderText = props.PlaceholderText,
					PlaceholderColor3 = PLACEHOLDER_TEXT_COLOR,
					ClearTextOnFocus = props.ClearTextOnFocus,
					MultiLine = false,
					[Roact.Event.Focused] = onFocused,
					[Roact.Event.FocusLost] = onFocusLost,
					[Roact.Event.InputBegan] = onInputBegan,
					[Roact.Event.InputEnded] = onInputEnded,
					[Roact.Change.Text] = onTextChanged,
					[Roact.Change.CursorPosition] = onCursorChanged,
				}),
				{ Padding = padding }
			)

		return Roact.createElement("Frame", {
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			Size = props.Size,
			LayoutOrder = props.LayoutOrder,
			ZIndex = props.ZIndex,
			BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground, mainModifier),
			BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder, borderModifier),
			BorderMode = Enum.BorderMode.Inset,
			ClipsDescendants = true,
			[Roact.Ref] = containerRef.value,
		}, {
			TextField = textField,
			Children = Roact.createFragment(props[Roact.Children]),
		})
	end)
end

return Hooks.new(Roact)(TextInput, {
	defaultProps = defaultProps,
})
