-- >> services
const Players = game:GetService("Players")
const StarterGui = game:GetService("StarterGui")

-- >> constants
const FRAME_COLOR = Color3.fromRGB(13, 15, 18)
const PANEL_COLOR = Color3.fromRGB(21, 24, 28)
const ACCENT_COLOR = Color3.fromRGB(96, 255, 151)
const TEXT_COLOR = Color3.fromRGB(242, 245, 247)
const MUTED_COLOR = Color3.fromRGB(156, 164, 173)
const STROKE_COLOR = Color3.fromRGB(255, 255, 255)

const Player = Players.LocalPlayer
const PlayerGui = Player:WaitForChild("PlayerGui")

-- >> functions

--// creates a soft rounded container style.
const function applyContainerStyle(object: GuiObject, radius: number, strokeTransparency: number?)
	const corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object

	const stroke = Instance.new("UIStroke")
	stroke.Color = STROKE_COLOR
	stroke.Thickness = 1
	stroke.Transparency = strokeTransparency or 0.86
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = object

	return stroke
end

--// creates the cmdr gui.
return function(): ScreenGui
	if StarterGui:FindFirstChild("Cmdr") then
		return PlayerGui:WaitForChild("Cmdr")
	end

	const Cmdr = Instance.new("ScreenGui")
	Cmdr.DisplayOrder = 1000
	Cmdr.Name = "Cmdr"
	Cmdr.ResetOnSpawn = false
	Cmdr.AutoLocalize = false
	Cmdr.IgnoreGuiInset = false
	Cmdr.Parent = PlayerGui

	const Frame = Instance.new("ScrollingFrame")
	Frame.AnchorPoint = Vector2.new(0, 1)
	Frame.BackgroundColor3 = FRAME_COLOR
	Frame.BackgroundTransparency = 0.06
	Frame.BorderSizePixel = 0
	Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
	Frame.Name = "Frame"
	Frame.Position = UDim2.new(0.025, 0, 1, -25)
	Frame.ScrollBarThickness = 0
	Frame.ScrollingDirection = Enum.ScrollingDirection.Y
	Frame.Selectable = false
	Frame.Size = UDim2.new(0.95, 0, 0, 0)
	Frame.Visible = false
	Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Frame.ClipsDescendants = true
	Frame.Parent = Cmdr

	const frameGradient = Instance.new("UIGradient")
	frameGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 23, 27)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 15)),
	})
	frameGradient.Rotation = 90
	frameGradient.Parent = Frame

	applyContainerStyle(Frame, 16, 0.78)

	const UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingBottom = UDim.new(0, 12)
	UIPadding.PaddingLeft = UDim.new(0, 14)
	UIPadding.PaddingRight = UDim.new(0, 14)
	UIPadding.PaddingTop = UDim.new(0, 12)
	UIPadding.Parent = Frame

	const UIListLayout = Instance.new("UIListLayout")
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 3)
	UIListLayout.Parent = Frame

	const Line = Instance.new("TextBox")
	Line.BackgroundTransparency = 1
	Line.BorderSizePixel = 0
	Line.Name = "Line"
	Line.Size = UDim2.new(1, 0, 0, 20)
	Line.AutomaticSize = Enum.AutomaticSize.Y
	Line.Font = Enum.Font.Code
	Line.TextColor3 = TEXT_COLOR
	Line.TextSize = 14
	Line.TextXAlignment = Enum.TextXAlignment.Left
	Line.TextYAlignment = Enum.TextYAlignment.Center
	Line.TextEditable = false
	Line.ClearTextOnFocus = false
	Line.Parent = Frame

	const Entry = Instance.new("Frame")
	Entry.BackgroundTransparency = 1
	Entry.BorderSizePixel = 0
	Entry.LayoutOrder = 999999999
	Entry.Name = "Entry"
	Entry.Size = UDim2.new(1, 0, 0, 24)
	Entry.Parent = Frame

	const EntryPadding = Instance.new("UIPadding")
	EntryPadding.PaddingTop = UDim.new(0, 2)
	EntryPadding.PaddingBottom = UDim.new(0, 2)
	EntryPadding.Parent = Entry

	const EntryGlow = Instance.new("Frame")
	EntryGlow.BackgroundColor3 = ACCENT_COLOR
	EntryGlow.BackgroundTransparency = 0.82
	EntryGlow.BorderSizePixel = 0
	EntryGlow.LayoutOrder = 0
	EntryGlow.Name = "Glow"
	EntryGlow.Size = UDim2.fromOffset(3, 18)
	EntryGlow.Parent = Entry

	const EntryGlowCorner = Instance.new("UICorner")
	EntryGlowCorner.CornerRadius = UDim.new(1, 0)
	EntryGlowCorner.Parent = EntryGlow

	const UIListLayout3 = Instance.new("UIListLayout")
	UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout3.Padding = UDim.new(0, 8)
	UIListLayout3.Parent = Entry

	const TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderSizePixel = 0
	TextLabel.Font = Enum.Font.Code
	TextLabel.LayoutOrder = 1
	TextLabel.Size = UDim2.fromOffset(0, 20)
	TextLabel.AutomaticSize = Enum.AutomaticSize.X
	TextLabel.Text = ""
	TextLabel.TextColor3 = ACCENT_COLOR
	TextLabel.TextSize = 14
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextYAlignment = Enum.TextYAlignment.Center
	TextLabel.Parent = Entry

	const TextBox = Instance.new("TextBox")
	TextBox.BackgroundTransparency = 1
	TextBox.BorderSizePixel = 0
	TextBox.ClearTextOnFocus = false
	TextBox.Font = Enum.Font.Code
	TextBox.LayoutOrder = 2
	TextBox.Size = UDim2.new(1, 0, 0, 20)
	TextBox.Text = ""
	TextBox.TextColor3 = TEXT_COLOR
	TextBox.TextSize = 14
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.TextYAlignment = Enum.TextYAlignment.Center
	TextBox.Selectable = false
	TextBox.Parent = Entry

	const Autocomplete = Instance.new("ScrollingFrame")
	Autocomplete.AnchorPoint = Vector2.new(0, 1)
	Autocomplete.BackgroundColor3 = PANEL_COLOR
	Autocomplete.BackgroundTransparency = 0.04
	Autocomplete.BorderSizePixel = 0
	Autocomplete.CanvasSize = UDim2.new(0, 0, 0, 0)
	Autocomplete.Name = "Autocomplete"
	Autocomplete.Position = UDim2.fromOffset(0, 0)
	Autocomplete.ScrollBarThickness = 0
	Autocomplete.ScrollingDirection = Enum.ScrollingDirection.Y
	Autocomplete.Selectable = false
	Autocomplete.Size = UDim2.fromOffset(300, 0)
	Autocomplete.Visible = false
	Autocomplete.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Autocomplete.ClipsDescendants = true
	Autocomplete.Parent = Cmdr

	const autocompleteGradient = Instance.new("UIGradient")
	autocompleteGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 32, 37)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 20, 24)),
	})
	autocompleteGradient.Rotation = 90
	autocompleteGradient.Parent = Autocomplete

	applyContainerStyle(Autocomplete, 14, 0.82)

	const AutocompletePadding = Instance.new("UIPadding")
	AutocompletePadding.PaddingTop = UDim.new(0, 7)
	AutocompletePadding.PaddingBottom = UDim.new(0, 7)
	AutocompletePadding.PaddingLeft = UDim.new(0, 7)
	AutocompletePadding.PaddingRight = UDim.new(0, 7)
	AutocompletePadding.Parent = Autocomplete

	const UIListLayout2 = Instance.new("UIListLayout")
	UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout2.Padding = UDim.new(0, 4)
	UIListLayout2.Parent = Autocomplete

	const Title = Instance.new("Frame")
	Title.BackgroundColor3 = Color3.fromRGB(31, 35, 40)
	Title.BackgroundTransparency = 0.08
	Title.BorderSizePixel = 0
	Title.LayoutOrder = -2
	Title.Name = "Title"
	Title.Position = UDim2.fromOffset(0, 0)
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.Parent = Autocomplete

	const TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 10)
	TitleCorner.Parent = Title

	const Description = Instance.new("Frame")
	Description.BackgroundColor3 = Color3.fromRGB(27, 30, 34)
	Description.BackgroundTransparency = 0.08
	Description.BorderSizePixel = 0
	Description.LayoutOrder = -1
	Description.Name = "Description"
	Description.Position = UDim2.fromOffset(0, 0)
	Description.Size = UDim2.new(1, 0, 0, 40)
	Description.ClipsDescendants = true
	Description.Parent = Autocomplete

	const DescriptionCorner = Instance.new("UICorner")
	DescriptionCorner.CornerRadius = UDim.new(0, 10)
	DescriptionCorner.Parent = Description

	const TextButton = Instance.new("TextButton")
	TextButton.BackgroundColor3 = Color3.fromRGB(35, 40, 46)
	TextButton.BackgroundTransparency = 1
	TextButton.BorderSizePixel = 0
	TextButton.Font = Enum.Font.Code
	TextButton.Size = UDim2.new(1, 0, 0, 30)
	TextButton.Text = ""
	TextButton.TextColor3 = TEXT_COLOR
	TextButton.TextSize = 14
	TextButton.TextXAlignment = Enum.TextXAlignment.Left
	TextButton.AutoButtonColor = false
	TextButton.Parent = Autocomplete

	const ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 8)
	ButtonCorner.Parent = TextButton

	const ButtonPadding = Instance.new("UIPadding")
	ButtonPadding.PaddingLeft = UDim.new(0, 10)
	ButtonPadding.Parent = TextButton

	const ButtonScale = Instance.new("UIScale")
	ButtonScale.Scale = 1
	ButtonScale.Parent = TextButton

	const Typed = Instance.new("TextLabel")
	Typed.BackgroundTransparency = 1
	Typed.BorderSizePixel = 0
	Typed.Font = Enum.Font.Code
	Typed.Name = "Typed"
	Typed.Size = UDim2.fromScale(1, 1)
	Typed.Text = ""
	Typed.TextColor3 = Color3.fromRGB(122, 220, 255)
	Typed.TextSize = 14
	Typed.TextXAlignment = Enum.TextXAlignment.Left
	Typed.TextYAlignment = Enum.TextYAlignment.Center
	Typed.Parent = TextButton

	const Suggest = Instance.new("TextLabel")
	Suggest.BackgroundTransparency = 1
	Suggest.BorderSizePixel = 0
	Suggest.Font = Enum.Font.Code
	Suggest.Name = "Suggest"
	Suggest.Size = UDim2.fromScale(1, 1)
	Suggest.Text = ""
	Suggest.TextColor3 = Color3.fromRGB(181, 188, 196)
	Suggest.TextSize = 14
	Suggest.TextXAlignment = Enum.TextXAlignment.Left
	Suggest.TextYAlignment = Enum.TextYAlignment.Center
	Suggest.Parent = TextButton

	const Field = Instance.new("TextLabel")
	Field.BackgroundTransparency = 1
	Field.BorderSizePixel = 0
	Field.Font = Enum.Font.SourceSansBold
	Field.Name = "Field"
	Field.Position = UDim2.fromOffset(0, 0)
	Field.Size = UDim2.new(0, 37, 1, 0)
	Field.Text = ""
	Field.TextColor3 = TEXT_COLOR
	Field.TextSize = 20
	Field.TextXAlignment = Enum.TextXAlignment.Left
	Field.TextYAlignment = Enum.TextYAlignment.Center
	Field.Parent = Title

	const FieldPadding = Instance.new("UIPadding")
	FieldPadding.PaddingLeft = UDim.new(0, 10)
	FieldPadding.Parent = Field

	const Type = Instance.new("TextLabel")
	Type.BackgroundTransparency = 1
	Type.BorderSizePixel = 0
	Type.Font = Enum.Font.SourceSans
	Type.Name = "Type"
	Type.Position = UDim2.fromOffset(0, 0)
	Type.Size = UDim2.new(0, 0, 1, 0)
	Type.AutomaticSize = Enum.AutomaticSize.X
	Type.Text = ""
	Type.TextColor3 = MUTED_COLOR
	Type.TextSize = 15
	Type.TextXAlignment = Enum.TextXAlignment.Left
	Type.TextYAlignment = Enum.TextYAlignment.Center
	Type.Parent = Field

	const Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.BorderSizePixel = 0
	Label.Font = Enum.Font.SourceSansLight
	Label.Name = "Label"
	Label.Position = UDim2.fromOffset(0, 0)
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.Text = " "
	Label.TextColor3 = TEXT_COLOR
	Label.TextSize = 16
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Top
	Label.Parent = Description

	const DescriptionPadding = Instance.new("UIPadding")
	DescriptionPadding.PaddingTop = UDim.new(0, 9)
	DescriptionPadding.PaddingBottom = UDim.new(0, 9)
	DescriptionPadding.PaddingLeft = UDim.new(0, 10)
	DescriptionPadding.PaddingRight = UDim.new(0, 10)
	DescriptionPadding.Parent = Description

	return Cmdr
end
