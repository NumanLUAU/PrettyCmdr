-- >> services
const TweenService = game:GetService("TweenService")

-- >> constants
const VALID_TEXT_COLOR = Color3.fromRGB(242, 245, 247)
const INVALID_TEXT_COLOR = Color3.fromRGB(255, 92, 108)
const TEXT_MEASUREMENT_SIZE = Vector2.new(1000, 1000)

const ROW_HEIGHT = 30
const LIST_PADDING = 4
const FRAME_PADDING = 8
const HEADER_GAP = 1
const MAX_HEIGHT = 300
const ENTRY_GAP = 8

const OPEN_TWEEN = TweenInfo.new(
	0.28,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
)

const CLOSE_TWEEN = TweenInfo.new(
	0.2,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.In
)

const RESIZE_TWEEN = TweenInfo.new(
	0.22,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

const POSITION_TWEEN = TweenInfo.new(
	0.18,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

const ROW_IN_TWEEN = TweenInfo.new(
	0.22,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

const ROW_OUT_TWEEN = TweenInfo.new(
	0.18,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.In
)

const TEXT_FADE_TWEEN = TweenInfo.new(
	0.14,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

-- >> functions

return function(CmdrClient)
	const autoCompleteFrame = CmdrClient.Gui:WaitForChild("Autocomplete") :: ScrollingFrame
	const defaultBarThickness = autoCompleteFrame.ScrollBarThickness

	const AutoComplete = {
		_autoItem = autoCompleteFrame:WaitForChild("TextButton") :: TextButton,
		_title = autoCompleteFrame:WaitForChild("Title") :: Frame,
		_description = autoCompleteFrame:WaitForChild("Description") :: Frame,
		_entry = CmdrClient.Gui.Frame:WaitForChild("Entry") :: Frame,

		Items = {},
		SelectedItem = 1,

		Prefix = "",
		LastItem = false,

		Command = nil,
		Arg = nil,
		NumArgs = nil,
		IsPartial = false,

		_positionOffset = 0,
		_context = nil :: string?,
		_generation = 0,
	}

	autoCompleteFrame.AnchorPoint = Vector2.new(0, 1)
	autoCompleteFrame.ScrollBarThickness = defaultBarThickness

	--// creates a stable key for a suggestion.
	const function getItemKey(item: any): string
		return tostring(item[2])
	end

	--// removes duplicate suggestions while preserving their first occurrence.
	const function cleanItems(items: any): { any }
		const result = {}
		const seen = {}

		for _, item in ipairs(items) do
			const key = getItemKey(item)

			if not seen[key] then
				seen[key] = true
				result[#result + 1] = item
			end
		end

		return result
	end

	--// calculates the total height required by the autocomplete contents.
	const function getContentHeight(): number
		const description = AutoComplete._description

		const rowCount = #AutoComplete.Items

		local height = FRAME_PADDING
		height += AutoComplete._title.Size.Y.Offset
		height += LIST_PADDING
		height += description.Size.Y.Offset

		if rowCount > 0 then
			height += LIST_PADDING
			height += rowCount * ROW_HEIGHT
			height += math.max(0, rowCount - 1) * LIST_PADDING
		end

		height += FRAME_PADDING

		return height
	end

	--// returns the maximum height available above the command entry.
	const function getMaximumHeight(): number
		const entryPosition = AutoComplete._entry.AbsolutePosition.Y
		return math.max(80, entryPosition - 16)
	end

	--// updates autocomplete dimensions without changing its anchor.
	const function updateContainerSize(animate: boolean?)
		const field = AutoComplete._title:FindFirstChild("Field") :: TextLabel?
		const type = field and field:FindFirstChild("Type") :: TextLabel?

		--// keeps type attached to the current field text.
		local function updateTypePosition()
			type.Position = UDim2.new(1, (field.TextBounds.X - field.Size.X.Offset) + 11, 0, 0)
		end

		field:GetPropertyChangedSignal("TextBounds"):Connect(updateTypePosition)
		updateTypePosition()

		local width = 220

		if field then
			width = math.max(width, field.TextBounds.X + 30)
		end

		if type then
			width = math.max(
				width,
				field and field.TextBounds.X + type.TextBounds.X + 30 or 220
			)
		end

		for _, item in ipairs(AutoComplete.Items) do
			const button = item.gui

			if button then
				width = math.max(
					width,
					button.Typed.TextBounds.X + button.Suggest.TextBounds.X + 25
				)
			end
		end

		const contentHeight = getContentHeight()
		const targetHeight = math.min(
			contentHeight,
			getMaximumHeight()
		)

		autoCompleteFrame.CanvasSize = UDim2.fromOffset(
			0,
			contentHeight
		)

		const targetSize = UDim2.fromOffset(
			width,
			targetHeight
		)

		if animate and autoCompleteFrame.Visible then
			TweenService:Create(
				autoCompleteFrame,
				RESIZE_TWEEN,
				{
					Size = targetSize,
				}
			):Play()
		else
			autoCompleteFrame.Size = targetSize
		end
	end

	--// moves autocomplete above the argument being edited.
	function AutoComplete:_updateContainerPosition(animateX: boolean?)
		if not autoCompleteFrame.Visible then
			return
		end

		const textBox = self._entry.TextBox
		const entryPosition = textBox.AbsolutePosition

		const characterCount = math.clamp(
			self._positionOffset,
			0,
			#textBox.Text + 1
		)

		const prefixText = textBox.Text:sub(
			1,
			math.max(0, characterCount - 1)
		)

		const textSize = CmdrClient.Util.GetTextSize(
			prefixText,
			textBox,
			TEXT_MEASUREMENT_SIZE
		)

		const targetX = entryPosition.X + textSize.X - 10
		const targetY = entryPosition.Y - ENTRY_GAP

		const currentPosition = autoCompleteFrame.AbsolutePosition

		if animateX and math.abs(currentPosition.X - targetX) > 1 then
			TweenService:Create(
				autoCompleteFrame,
				POSITION_TWEEN,
				{
					Position = UDim2.fromOffset(
						targetX,
						targetY
					),
				}
			):Play()
		else
			autoCompleteFrame.Position = UDim2.fromOffset(
				targetX,
				targetY
			)
		end
	end

	--// swaps text using the real label so there are never two competing labels.
	const function swapText(
		textObject: TextLabel,
		newText: string
	)
		if textObject.Text == newText then
			return
		end

		const oldText = textObject.Text

		if oldText == "" then
			textObject.Text = newText
			textObject.TextTransparency = 1

			TweenService:Create(
				textObject,
				TEXT_FADE_TWEEN,
				{
					TextTransparency = 0,
				}
			):Play()

			return
		end

		const oldPosition = textObject.Position

		TweenService:Create(
			textObject,
			TweenInfo.new(
				0.12,
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.In
			),
			{
				Position = oldPosition + UDim2.fromOffset(-14, 0),
				TextTransparency = 1,
			}
		):Play()

		task.delay(0.12, function()
			textObject.Text = newText
			textObject.Position = oldPosition

			TweenService:Create(
				textObject,
				TEXT_FADE_TWEEN,
				{
					TextTransparency = 0,
				}
			):Play()
		end)
	end

	--// updates the autocomplete header information.
	function AutoComplete:_updateInfoDisplay(options: any)
		const field = self._title:FindFirstChild("Field") :: TextLabel
		const type = field:FindFirstChild("Type") :: TextLabel
		const label = self._description:FindFirstChild("Label") :: TextLabel

		const typeName = options.type
			and `{options.type:sub(1, 1):upper()}{options.type:sub(2)}`

		const typeText = typeName
			and `: {typeName}`
			or ""

		swapText(
			field,
			options.name or ""
		)

		swapText(
			type,
			typeText
		)

		swapText(
			label,
			options.description or ""
		)

		label.TextColor3 = if options.invalid
			then INVALID_TEXT_COLOR
			else VALID_TEXT_COLOR

		self._description.Size = UDim2.new(
			1,
			0,
			0,
			40
		)

		while not label.TextFits do
			self._description.Size += UDim2.fromOffset(
				0,
				2
			)

			if self._description.Size.Y.Offset > 500 then
				break
			end
		end
	end

	--// creates a stable row that can expand or collapse without fighting the list layout.
	const function createRow(item: any, index: number, animate: boolean)
		const button = AutoComplete._autoItem:Clone()

		button.Name = `Suggestion_{item[2]}`
		button.LayoutOrder = 1
		button.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
		button.Position = UDim2.fromOffset(
			if animate then 36 else 0,
			0
		)
		button.BackgroundTransparency = 1

		const typedText = item[1]
		const suggestionText = item[2]

		const start, stop = suggestionText:lower():find(
			typedText:lower(),
			1,
			true
		)

		const matchStart = start or 1
		const matchStop = stop or #suggestionText

		const prefix = suggestionText:sub(1, matchStart - 1)
		const suffix = suggestionText:sub(matchStop + 1)

		button.Typed.Text =
			`{(" "):rep(matchStart - 1)}{typedText}`

		button.Suggest.Text =
			`{prefix}{(" "):rep(#typedText)}{suffix}`

		button.Typed.TextTransparency = if animate then 1 else 0
		button.Suggest.TextTransparency = if animate then 1 else 0

		const holder = Instance.new("Frame")
		holder.Name = "SuggestionHolder"
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.ClipsDescendants = true
		holder.Size = if animate
			then UDim2.new(1, 0, 0, 0)
			else UDim2.new(1, 0, 0, ROW_HEIGHT)
		holder.LayoutOrder = index
		holder.Parent = autoCompleteFrame

		button.Parent = holder

		item.gui = button
		item.holder = holder
		item.key = getItemKey(item)

		if not animate then
			button.BackgroundTransparency =
				if index == AutoComplete.SelectedItem
				then 0.22
				else 1

			return
		end

		TweenService:Create(
			holder,
			ROW_IN_TWEEN,
			{
				Size = UDim2.new(
					1,
					0,
					0,
					ROW_HEIGHT
				),
			}
		):Play()

		TweenService:Create(
			button,
			ROW_IN_TWEEN,
			{
				Position = UDim2.fromOffset(0, 0),
				BackgroundTransparency =
					if index == AutoComplete.SelectedItem
					then 0.22
					else 1,
			}
		):Play()

		TweenService:Create(
			button.Typed,
			TEXT_FADE_TWEEN,
			{
				TextTransparency = 0,
			}
		):Play()

		TweenService:Create(
			button.Suggest,
			TEXT_FADE_TWEEN,
			{
				TextTransparency = 0,
			}
		):Play()
	end

	--// slides a removed row left while its layout space collapses.
	const function removeRow(item: any)
		const button = item.gui
		const holder = item.holder

		if not holder or not holder.Parent then
			return
		end

		if not button or not button.Parent then
			holder:Destroy()
			return
		end

		TweenService:Create(
			button,
			ROW_OUT_TWEEN,
			{
				Position = UDim2.fromOffset(-36, 0),
				BackgroundTransparency = 1,
			}
		):Play()

		TweenService:Create(
			button.Typed,
			TEXT_FADE_TWEEN,
			{
				TextTransparency = 1,
			}
		):Play()

		TweenService:Create(
			button.Suggest,
			TEXT_FADE_TWEEN,
			{
				TextTransparency = 1,
			}
		):Play()

		const collapse = TweenService:Create(
			holder,
			ROW_OUT_TWEEN,
			{
				Size = UDim2.new(1, 0, 0, 0),
			}
		)

		collapse:Play()

		collapse.Completed:Once(function()
			if holder.Parent then
				holder:Destroy()
			end
		end)
	end

	--// keeps selected rows inside the currently visible viewport.
	const function updateCanvasPosition()
		if not autoCompleteFrame.Visible then
			return
		end

		const selected = AutoComplete.Items[AutoComplete.SelectedItem]

		if not selected or not selected.holder then
			return
		end

		const holder = selected.holder

		task.defer(function()
			if not autoCompleteFrame.Visible then
				return
			end

			if not holder.Parent then
				return
			end

			const frameTop = autoCompleteFrame.AbsolutePosition.Y
			const currentCanvas = autoCompleteFrame.CanvasPosition.Y
			const viewportHeight = autoCompleteFrame.AbsoluteSize.Y

			const itemTop =
				holder.AbsolutePosition.Y
			- frameTop
				+ currentCanvas

			const itemBottom =
				itemTop + holder.AbsoluteSize.Y

			local targetCanvas = currentCanvas

			if itemTop < currentCanvas then
				targetCanvas = itemTop
			elseif itemBottom > currentCanvas + viewportHeight then
				targetCanvas =
					itemBottom - viewportHeight
			end

			const maxCanvas =
				math.max(
					0,
					autoCompleteFrame.CanvasSize.Y.Offset
					- viewportHeight
				)

			targetCanvas = math.clamp(
				targetCanvas,
				0,
				maxCanvas
			)

			autoCompleteFrame.CanvasPosition =
				Vector2.new(
					0,
					targetCanvas
				)
		end)
	end

	--// reconciles the visible rows without recreating unchanged suggestions.
	function AutoComplete:_updateSuggestionRows(items: any)
		items = cleanItems(items)

		const existing = {}

		for _, item in ipairs(self.Items) do
			if item.holder and item.holder.Parent then
				existing[item.key or getItemKey(item)] = item
			end
		end

		const newItems = table.create(#items)

		for index, item in ipairs(items) do
			const key = getItemKey(item)
			const oldItem = existing[key]

			if oldItem then
				oldItem[1] = item[1]
				oldItem[2] = item[2]
				oldItem.options = item.options
				oldItem.key = key

				oldItem.holder.LayoutOrder = index

				const typedText = item[1]
				const suggestionText = item[2]

				const start, stop = suggestionText:lower():find(
					typedText:lower(),
					1,
					true
				)

				const matchStart = start or 1
				const matchStop = stop or #suggestionText

				const prefix = suggestionText:sub(
					1,
					matchStart - 1
				)

				const suffix = suggestionText:sub(
					matchStop + 1
				)

				--// update the actual row instead of creating another label.
				oldItem.gui.Typed.Text =
					`{(" "):rep(matchStart - 1)}{typedText}`

				oldItem.gui.Suggest.Text =
					`{prefix}{(" "):rep(#typedText)}{suffix}`

				TweenService:Create(
					oldItem.gui,
					RESIZE_TWEEN,
					{
						BackgroundTransparency =
							if index == self.SelectedItem
							then 0.22
							else 1,
					}
				):Play()

				newItems[index] = oldItem
				existing[key] = nil
			else
				item.key = key
				createRow(
					item,
					index,
					true
				)

				newItems[index] = item
			end
		end

		for _, removedItem in existing do
			task.spawn(
				removeRow,
				removedItem
			)
		end

		self.Items = newItems

		updateContainerSize(true)
		updateCanvasPosition()
	end

	--// opens the autocomplete container from its bottom anchor.
	function AutoComplete:_open()
		if autoCompleteFrame.Visible then
			return
		end

		autoCompleteFrame.Visible = true
		autoCompleteFrame.BackgroundTransparency = 1

		const targetSize = autoCompleteFrame.Size

		autoCompleteFrame.Size =
			UDim2.fromOffset(
				targetSize.X.Offset,
				0
			)

		TweenService:Create(
			autoCompleteFrame,
			OPEN_TWEEN,
			{
				Size = targetSize,
				BackgroundTransparency = 0.04,
			}
		):Play()
	end

	--// shows autocomplete while only opening the outer container when necessary.
	function AutoComplete:Show(items: any, options: any)
		options = options or {}

		items = cleanItems(items)

		if #items == 0 then
			self:Hide()
			return
		end

		self.Prefix = options.prefix or ""
		self.LastItem = options.isLast or false

		self.Command = options.command
		self.Arg = options.arg
		self.NumArgs = options.numArgs
		self.IsPartial = options.isPartial

		self.SelectedItem = math.clamp(
			self.SelectedItem,
			1,
			#items
		)

		const text = self._entry.TextBox.Text
		const words = CmdrClient.Util.SplitString(text)

		if text:sub(#text, #text) == " "
			and not options.at
		then
			words[#words + 1] = "e"
		end

		table.remove(
			words,
			#words
		)

		self._positionOffset =
			options.at
			or (#table.concat(words, " ") + 1)

		self:_updateInfoDisplay(
			if items[1] and items[1].options
				then items[1].options
				else options
		)

		self:_updateSuggestionRows(items)

		const wasVisible =
			autoCompleteFrame.Visible

		self._context = table.concat({
			tostring(options.command),
			tostring(options.arg),
			tostring(options.type),
		}, "|")

		updateContainerSize(
			wasVisible
		)

		self:_updateContainerPosition(
			wasVisible
		)

		if not wasVisible then
			self:_updateContainerPosition(false)
			self:_open()
		end

		updateCanvasPosition()
	end

	--// returns the selected autocomplete item.
	function AutoComplete:GetSelectedItem()
		if not autoCompleteFrame.Visible then
			return nil
		end

		return self.Items[self.SelectedItem]
	end

	--// closes the entire autocomplete menu.
	function AutoComplete:Hide()
		self._generation += 1
		self._context = nil

		if not autoCompleteFrame.Visible then
			return
		end

		for _, item in ipairs(self.Items) do
			if item.holder then
				item.holder:Destroy()
			end
		end

		self.Items = {}

		const tween = TweenService:Create(
			autoCompleteFrame,
			CLOSE_TWEEN,
			{
				Size = UDim2.fromOffset(
					autoCompleteFrame.Size.X.Offset,
					0
				),
				BackgroundTransparency = 1,
			}
		)

		tween:Play()

		tween.Completed:Once(function()
			autoCompleteFrame.Visible = false
			autoCompleteFrame.CanvasPosition =
				Vector2.new(0, 0)
		end)
	end

	--// returns whether autocomplete is currently visible.
	function AutoComplete:IsVisible()
		return autoCompleteFrame.Visible
	end

	--// changes the selected row and keeps it inside the viewport.
	function AutoComplete:Select(delta: number)
		if not autoCompleteFrame.Visible
			or #self.Items == 0
		then
			return
		end

		self.SelectedItem += delta

		if self.SelectedItem > #self.Items then
			self.SelectedItem = 1
		elseif self.SelectedItem < 1 then
			self.SelectedItem = #self.Items
		end

		for index, item in ipairs(self.Items) do
			if not item.gui then
				continue
			end

			const selected =
				index == self.SelectedItem

			TweenService:Create(
				item.gui,
				TweenInfo.new(
					0.12,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),
				{
					BackgroundTransparency =
						if selected
						then 0.22
						else 1,
				}
			):Play()
		end

		const selectedItem =
			self.Items[self.SelectedItem]

		if selectedItem
			and selectedItem.options
		then
			self:_updateInfoDisplay(
				selectedItem.options
			)
		end

		updateCanvasPosition()
	end

	AutoComplete._autoItem.Parent = nil

	autoCompleteFrame:GetPropertyChangedSignal(
		"AbsoluteSize"
	):Connect(function()
		if autoCompleteFrame.Visible then
			AutoComplete:_updateContainerPosition(false)
		end
	end)

	AutoComplete._entry:GetPropertyChangedSignal(
		"AbsolutePosition"
	):Connect(function()
		if autoCompleteFrame.Visible then
			AutoComplete:_updateContainerPosition(false)
		end
	end)

	AutoComplete._entry:GetPropertyChangedSignal(
		"AbsoluteSize"
	):Connect(function()
		if autoCompleteFrame.Visible then
			AutoComplete:_updateContainerPosition(false)
		end
	end)

	AutoComplete._entry.TextBox:GetPropertyChangedSignal(
		"AbsolutePosition"
	):Connect(function()
		if autoCompleteFrame.Visible then
			AutoComplete:_updateContainerPosition(false)
		end
	end)

	return AutoComplete
end
