local OrbitHub = {}
OrbitHub.__index = OrbitHub
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local function Tween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quart
	dir = dir or Enum.EasingDirection.Out
	t = t or 0.2
	local tw = TweenService:Create(obj, TweenInfo.new(t, style, dir), props)
	tw:Play()
	return tw
end
local function New(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then obj[k] = v end
	end
	if props and props.Parent then obj.Parent = props.Parent end
	return obj
end
local function Clone(template, parent)
	local c = template:Clone()
	c.Visible = true
	c.Parent = parent
	return c
end
OrbitHub._notifCount = 0
OrbitHub._notifGui = nil
OrbitHub._windows = {}
local function GetNotifGui()
	if OrbitHub._notifGui and OrbitHub._notifGui.Parent then
		return OrbitHub._notifGui
	end
	local sg = New("ScreenGui", {
		Name = "OrbitNotifs",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})
	local holder = New("Frame", {
		Name = "Holder",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 280, 1, 0),
		Position = UDim2.new(1, -295, 0, 0),
		Parent = sg,
	})
	New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 6),
		Parent = holder,
	})
	New("UIPadding", { PaddingBottom = UDim.new(0, 14), Parent = holder })
	OrbitHub._notifGui = holder
	return holder
end
function OrbitHub:Notify(opts)
	opts = opts or {}
	local title = opts.Title or "Notificação"
	local msg = opts.Message or ""
	local dur = opts.Duration or 4
	local ntype = opts.Type or "info"
	local colorMap = {
		info = Color3.fromRGB(170, 85, 255),
		success = Color3.fromRGB(85, 255, 127),
		warning = Color3.fromRGB(255, 200, 50),
		error = Color3.fromRGB(255, 80, 80),
	}
	local accent = colorMap[ntype] or colorMap.info
	local holder = GetNotifGui()
	OrbitHub._notifCount += 1
	local card = New("Frame", {
		Name = "Notif_" .. OrbitHub._notifCount,
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 70),
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		Parent = holder,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
	New("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Parent = card })
	New("Frame", {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = card,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.new(0, 12, 0, 10),
		Text = title,
		TextColor3 = accent,
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.new(0, 12, 0, 32),
		Text = msg,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.3,
		TextScaled = true,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = card,
	})
	local bar = New("Frame", {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		Parent = card,
	})
	Tween(card, { BackgroundTransparency = 0.2 }, 0.25)
	Tween(bar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)
	task.delay(dur, function()
		Tween(card, { BackgroundTransparency = 1 }, 0.25)
		task.wait(0.3)
		card:Destroy()
	end)
end
function OrbitHub:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "OrbitHub"
	local toggleKey = opts.ToggleKey or Enum.KeyCode.K
	local sg = New("ScreenGui", {
		Name = "OrbitUI_" .. title:gsub("%s", ""),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})
	local canvas = New("CanvasGroup", {
		Name = "CanvasMain",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.287, 0, 0.171, 0),
		Size = UDim2.new(0.375, 0, 0.626, 0),
		Parent = sg,
	})
	local main = New("Frame", {
		Name = "Main",
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = canvas,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = main })
	local titleLbl = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.026, 0, 0.016, 0),
		Size = UDim2.new(0.375, 0, 0.04, 0),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main,
	})
	local playerLbl = New("TextLabel", {
		Name = "Player",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.026, 0, 0.056, 0),
		Size = UDim2.new(0.375, 0, 0.027, 0),
		Font = Enum.Font.Gotham,
		Text = "Conectado: @" .. LocalPlayer.Name,
		TextColor3 = Color3.fromRGB(170, 85, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = main,
	})
	local btnFechar = New("ImageButton", {
		Name = "ButtonFechar",
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0.950, 0, 0.024, 0),
		Size = UDim2.new(0.02, 0, 0.032, 0),
		Parent = main,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btnFechar })
	local btnMin = New("ImageButton", {
		Name = "ButtonMinimizar",
		BackgroundColor3 = Color3.fromRGB(255, 255, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.new(0.919, 0, 0.024, 0),
		Size = UDim2.new(0.02, 0, 0.032, 0),
		Parent = main,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btnMin })
	local tabsFrame = New("Frame", {
		Name = "Tabs",
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Position = UDim2.new(0.024, 0, 0.099, 0),
		Size = UDim2.new(0.226, 0, 0.867, 0),
		Parent = main,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tabsFrame })
	local tabsScroll = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BottomImage = "",
		MidImage = "",
		TopImage = "",
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
		Parent = tabsFrame,
	})
	New("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 5),
		Parent = tabsScroll,
	})
	New("UIPadding", { PaddingTop = UDim.new(0.01, 0), Parent = tabsScroll })
	local listFrame = New("Frame", {
		Name = "List",
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Position = UDim2.new(0.276, 0, 0.099, 0),
		Size = UDim2.new(0.694, 0, 0.867, 0),
		Parent = main,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = listFrame })
	local listScroll = New("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BottomImage = "",
		MidImage = "",
		TopImage = "",
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
		Parent = listFrame,
	})
	New("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5),
		Parent = listScroll,
	})
	New("UIPadding", { PaddingTop = UDim.new(0.01, 0), Parent = listScroll })
	local templates = New("Folder", { Name = "Templates", Parent = canvas })
	local tBtn = New("Frame", {
		Name = "TemplateButton",
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(0.948, 0, 0, 44),
		Visible = false,
		Parent = templates,
	})
	New("UICorner", { Parent = tBtn })
	New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.1, 0),
		Size = UDim2.new(0.59, 0, 0.38, 0),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.fromRGB(170, 85, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tBtn,
	})
	New("TextLabel", {
		Name = "SubTitle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.5, 0),
		Size = UDim2.new(0.59, 0, 0.5, 0),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.7,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = tBtn,
	})
	New("TextLabel", {
		Name = "Info",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.504, 0, 0.325, 0),
		Size = UDim2.new(0.445, 0, 0.325, 0),
		Font = Enum.Font.GothamBold,
		Text = "Button",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextTransparency = 0.04,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = tBtn,
	})
	New("ImageButton", {
		Name = "Button",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = tBtn,
	})
	local tToggle = New("Frame", {
		Name = "TemplateToggle",
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(0.948, 0, 0, 44),
		Visible = false,
		Parent = templates,
	})
	New("UICorner", { Parent = tToggle })
	New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.1, 0),
		Size = UDim2.new(0.59, 0, 0.38, 0),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.fromRGB(170, 85, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tToggle,
	})
	New("TextLabel", {
		Name = "SubTitle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.5, 0),
		Size = UDim2.new(0.59, 0, 0.5, 0),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.7,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = tToggle,
	})
	New("ImageButton", {
		Name = "Button",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = tToggle,
	})
	local toggleTrack = New("Frame", {
		Name = "Toggle",
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Position = UDim2.new(0.834, 0, 0.3, 0),
		Size = UDim2.new(0.117, 0, 0.4, 0),
		Parent = tToggle,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleTrack })
	local toggleBall = New("Frame", {
		Name = "Bolinha",
		BackgroundColor3 = Color3.fromRGB(80, 80, 80),
		BorderSizePixel = 0,
		Position = UDim2.new(0.05, 0, 0.1, 0),
		Size = UDim2.new(0.44, 0, 0.8, 0),
		Parent = toggleTrack,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBall })
	local tSlide = New("Frame", {
		Name = "TemplateSlide",
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(0.948, 0, 0, 44),
		Visible = false,
		Parent = templates,
	})
	New("UICorner", { Parent = tSlide })
	New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.08, 0),
		Size = UDim2.new(0.59, 0, 0.32, 0),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.fromRGB(170, 85, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tSlide,
	})
	New("TextLabel", {
		Name = "SubTitle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.55, 0),
		Size = UDim2.new(0.59, 0, 0.38, 0),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.7,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = tSlide,
	})
	local slideTrack = New("Frame", {
		Name = "Slide",
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BorderSizePixel = 0,
		Position = UDim2.new(0.214, 0, 0.42, 0),
		Size = UDim2.new(0.736, 0, 0.16, 0),
		Parent = tSlide,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slideTrack })
	local slideFill = New("Frame", {
		Name = "Fill",
		BackgroundColor3 = Color3.fromRGB(170, 85, 255),
		BorderSizePixel = 0,
		Size = UDim2.new(0.5, 0, 1, 0),
		Parent = slideTrack,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slideFill })
	local slideBall = New("Frame", {
		Name = "Bolinha",
		BackgroundColor3 = Color3.fromRGB(170, 85, 255),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -6, -1.2, 0),
		Size = UDim2.new(0, 12, 0, 12),
		ZIndex = 2,
		Parent = slideTrack,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = slideBall })
	New("ImageButton", {
		Name = "Button",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 3,
		Parent = slideBall,
	})
	local tCategoria = New("Frame", {
		Name = "TemplateCategoria",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.948, 0, 0, 24),
		Visible = false,
		Parent = templates,
	})
	New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.1, 0),
		Size = UDim2.new(0.9, 0, 0.8, 0),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.fromRGB(170, 85, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tCategoria,
	})
	local tTab = New("Frame", {
		Name = "TemplateTabs",
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(0.893, 0, 0, 36),
		Visible = false,
		Parent = templates,
	})
	New("UICorner", { Parent = tTab })
	New("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.09, 0, 0.3, 0),
		Size = UDim2.new(0.15, 0, 0.38, 0),
		Image = "rbxassetid://2795572800",
		Parent = tTab,
	})
	New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.39, 0, 0.3, 0),
		Size = UDim2.new(0.6, 0, 0.38, 0),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tTab,
	})
	New("ImageButton", {
		Name = "Button",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = tTab,
	})
	local tSelect = New("Frame", {
		Name = "TemplateSelecionar",
		BackgroundColor3 = Color3.fromRGB(13, 13, 13),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Size = UDim2.new(0.948, 0, 0, 44),
		Visible = false,
		Parent = templates,
	})
	New("UICorner", { Parent = tSelect })
	New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.1, 0),
		Size = UDim2.new(0.59, 0, 0.38, 0),
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.fromRGB(170, 85, 255),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tSelect,
	})
	New("TextLabel", {
		Name = "SubTitle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.035, 0, 0.5, 0),
		Size = UDim2.new(0.51, 0, 0.5, 0),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextTransparency = 0.7,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = tSelect,
	})
	New("TextLabel", {
		Name = "Info",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.504, 0, 0.325, 0),
		Size = UDim2.new(0.445, 0, 0.325, 0),
		Font = Enum.Font.GothamBold,
		Text = "Selecionar ▾",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextTransparency = 0.04,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = tSelect,
	})
	New("ImageButton", {
		Name = "Button",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		Parent = tSelect,
	})
	local visible = true
	local minimized = false
	local fullSize = canvas.Size
	local function animateIn()
		canvas.GroupTransparency = 1
		canvas.Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 0)
		canvas.Visible = true
		Tween(canvas, { GroupTransparency = 0, Size = fullSize }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end
	local function animateOut(cb)
		Tween(canvas, { GroupTransparency = 1, Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 0) }, 0.2)
		task.delay(0.22, function()
			canvas.Visible = false
			if cb then cb() end
		end)
	end
	animateIn()
	btnFechar.MouseButton1Click:Connect(function()
		animateOut(function() sg:Destroy() end)
	end)
	btnMin.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			fullSize = canvas.Size
			Tween(canvas, { Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 48) }, 0.25)
		else
			Tween(canvas, { Size = fullSize }, 0.25, Enum.EasingStyle.Back)
		end
	end)
	do
		local dragging, dStart, dPos
		main.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dStart = inp.Position
				dPos = canvas.Position
			end
		end)
		main.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local d = inp.Position - dStart
				canvas.Position = UDim2.new(dPos.X.Scale, dPos.X.Offset + d.X, dPos.Y.Scale, dPos.Y.Offset + d.Y)
			end
		end)
	end
	UserInputService.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == toggleKey then
			visible = not visible
			if visible then animateIn() else animateOut() end
		end
	end)
	local Window = {}
	Window._tabs = {}
	Window._activePage = nil
	Window._gui = sg
	Window._canvas = canvas
	Window._lib = self
	function Window:AddTab(name, icon)
		local tabBtn = Clone(tTab, tabsScroll)
		tabBtn.Title.Text = name
		if icon then tabBtn.Icon.Image = icon end
		local page = New("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 2,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BottomImage = "",
			MidImage = "",
			TopImage = "",
			VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
			Visible = false,
			Parent = listScroll,
		})
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
			Parent = page,
		})
		New("UIPadding", { PaddingTop = UDim.new(0.01, 0), Parent = page })
		local Tab = {}
		Tab._page = page
		Tab._btn = tabBtn
		Tab._win = self
		local function activate()
			for _, t in ipairs(self._tabs) do
				t._page.Visible = false
				Tween(t._btn, { BackgroundTransparency = 0.7 }, 0.15)
				t._btn.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
			page.Visible = true
			Tween(tabBtn, { BackgroundTransparency = 0 }, 0.15)
			tabBtn.Title.TextColor3 = Color3.fromRGB(170, 85, 255)
			self._activePage = page
		end
		tabBtn.Button.MouseButton1Click:Connect(activate)
		table.insert(self._tabs, Tab)
		if #self._tabs == 1 then
			task.defer(activate)
		end
		function Tab:AddSection(sectionTitle)
			local c = Clone(tCategoria, page)
			c.Title.Text = sectionTitle
			return self
		end
		function Tab:AddButton(opts)
			opts = opts or {}
			local c = Clone(tBtn, page)
			c.Title.Text = opts.Text or "Button"
			c.SubTitle.Text = opts.Desc or ""
			c.Info.Text = opts.Info or "Clique"
			local btn = c.Button
			btn.MouseEnter:Connect(function() Tween(c, { BackgroundTransparency = 0.1 }, 0.1) end)
			btn.MouseLeave:Connect(function() Tween(c, { BackgroundTransparency = 0.4 }, 0.1) end)
			btn.MouseButton1Down:Connect(function() Tween(c, { BackgroundTransparency = 0.6 }, 0.08) end)
			btn.MouseButton1Up:Connect(function()
				Tween(c, { BackgroundTransparency = 0.1 }, 0.08)
				if opts.Callback then opts.Callback() end
			end)
		end
		function Tab:AddToggle(opts)
			opts = opts or {}
			local state = opts.Default or false
			local c = Clone(tToggle, page)
			c.Title.Text = opts.Text or "Toggle"
			c.SubTitle.Text = opts.Desc or ""
			local track = c.Toggle
			local ball = track.Bolinha
			local btn = c.Button
			local function updateVisual(s, anim)
				local t = anim and 0.2 or 0
				if s then
					Tween(ball, { Position = UDim2.new(0.51, 0, 0.1, 0), BackgroundColor3 = Color3.fromRGB(170, 85, 255) }, t, Enum.EasingStyle.Back)
					Tween(track, { BackgroundColor3 = Color3.fromRGB(40, 25, 55) }, t)
				else
					Tween(ball, { Position = UDim2.new(0.05, 0, 0.1, 0), BackgroundColor3 = Color3.fromRGB(80, 80, 80) }, t, Enum.EasingStyle.Back)
					Tween(track, { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }, t)
				end
			end
			updateVisual(state, false)
			btn.MouseButton1Click:Connect(function()
				state = not state
				updateVisual(state, true)
				if opts.Callback then opts.Callback(state) end
			end)
			local T = {}
			function T:Set(v) state = v; updateVisual(v, true) end
			function T:Get() return state end
			return T
		end
		function Tab:AddSlider(opts)
			opts = opts or {}
			local min = opts.Min or 0
			local max = opts.Max or 100
			local default = math.clamp(opts.Default or min, min, max)
			local step = opts.Step or 1
			local suffix = opts.Suffix or ""
			local c = Clone(tSlide, page)
			c.Title.Text = opts.Text or "Slider"
			c.SubTitle.Text = tostring(default) .. suffix
			local track = c.Slide
			local fill = track.Fill
			local ball = track.Bolinha
			local ballBtn = ball.Button
			local value = default
			local pct = (value - min) / (max - min)
			fill.Size = UDim2.new(pct, 0, 1, 0)
			ball.Position = UDim2.new(pct, -6, -1.2, 0)
			local dragging = false
			local function update(x)
				local abs = track.AbsolutePosition.X
				local sz = track.AbsoluteSize.X
				local p = math.clamp((x - abs) / sz, 0, 1)
				local raw = min + (max - min) * p
				local stepped = math.round(raw / step) * step
				value = math.clamp(stepped, min, max)
				pct = (value - min) / (max - min)
				fill.Size = UDim2.new(pct, 0, 1, 0)
				ball.Position = UDim2.new(pct, -6, -1.2, 0)
				c.SubTitle.Text = tostring(math.round(value * 100) / 100) .. suffix
				if opts.Callback then opts.Callback(value) end
			end
			ballBtn.MouseButton1Down:Connect(function() dragging = true end)
			UserInputService.InputChanged:Connect(function(inp)
				if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
					update(inp.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)
			track.InputBegan:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					update(inp.Position.X)
				end
			end)
			local S = {}
			function S:Set(v)
				value = math.clamp(v, min, max)
				pct = (value - min) / (max - min)
				Tween(fill, { Size = UDim2.new(pct, 0, 1, 0) }, 0.15)
				ball.Position = UDim2.new(pct, -6, -1.2, 0)
				c.SubTitle.Text = tostring(value) .. suffix
				if opts.Callback then opts.Callback(value) end
			end
			function S:Get() return value end
			return S
		end
		function Tab:AddDropdown(opts)
			opts = opts or {}
			local items = opts.Items or {}
			local selected = opts.Default or (items[1] or "Selecionar")
			local open = false
			local c = Clone(tSelect, page)
			c.Title.Text = opts.Text or "Dropdown"
			c.SubTitle.Text = opts.Desc or ""
			c.Info.Text = selected .. " ▾"
			local dropFrame = New("Frame", {
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				ClipsDescendants = true,
				ZIndex = 5,
				Visible = false,
				Parent = c,
			})
			New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropFrame })
			New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropFrame })
			local function buildItems()
				for _, ch in ipairs(dropFrame:GetChildren()) do
					if ch:IsA("TextButton") then ch:Destroy() end
				end
				for i, item in ipairs(items) do
					local row = New("TextButton", {
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						BackgroundTransparency = item == selected and 0.2 or 0.6,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 28),
						Text = item,
						TextColor3 = item == selected and Color3.fromRGB(170, 85, 255) or Color3.fromRGB(220, 220, 220),
						TextScaled = true,
						Font = item == selected and Enum.Font.GothamBold or Enum.Font.Gotham,
						ZIndex = 6,
						LayoutOrder = i,
						Parent = dropFrame,
					})
					row.MouseButton1Click:Connect(function()
						selected = item
						c.Info.Text = item .. " ▾"
						open = false
						Tween(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
						task.delay(0.16, function() dropFrame.Visible = false end)
						buildItems()
						if opts.Callback then opts.Callback(item) end
					end)
				end
			end
			buildItems()
			local totalH = #items * 28
			c.Button.MouseButton1Click:Connect(function()
				open = not open
				if open then
					dropFrame.Visible = true
					dropFrame.Size = UDim2.new(1, 0, 0, 0)
					c.Info.Text = selected .. " ▴"
					Tween(dropFrame, { Size = UDim2.new(1, 0, 0, math.min(totalH, 112)) }, 0.2)
				else
					c.Info.Text = selected .. " ▾"
					Tween(dropFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.15)
					task.delay(0.16, function() dropFrame.Visible = false end)
				end
			end)
			local D = {}
			function D:Set(v) selected = v; c.Info.Text = v .. " ▾"; buildItems() end
			function D:Get() return selected end
			function D:SetItems(list) items = list; totalH = #list * 28; buildItems() end
			return D
		end
		function Tab:Notify(opts)
			return Window._lib:Notify(opts)
		end
		return Tab
	end
	table.insert(OrbitHub._windows, Window)
	return Window
end
return OrbitHub
