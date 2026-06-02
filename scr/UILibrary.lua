--[[
    ╔══════════════════════════════════════════╗
    ║         NOVA UI LIBRARY v1.0             ║
    ║    Modern Minimal Roblox UI Framework    ║
    ╚══════════════════════════════════════════╝

    USAGE:
        local Nova = require(path.to.UILibrary)
        local Window = Nova:CreateWindow({ Title = "My App" })
        local Tab = Window:AddTab("Home")
        Tab:AddButton({ Text = "Click Me", Callback = function() print("Clicked!") end })

    COMPONENTS:
        Window, Tab, Button, Toggle, Slider,
        TextInput, Dropdown, Label, Separator,
        Notification, Modal, ColorPicker, Keybind

    THEMES:
        Nova:SetTheme("Dark")   -- Default dark theme
        Nova:SetTheme("Light")  -- Light theme
        Nova:SetTheme("Ocean")  -- Blue ocean theme
        Nova:SetTheme("Rose")   -- Pink rose theme
        Nova:SetTheme(customThemeTable) -- Custom theme
]]

local Nova = {}
Nova.__index = Nova

-- ─── Services ───────────────────────────────────────────────────────────────
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local TextService     = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Utility ────────────────────────────────────────────────────────────────
local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration  = duration  or 0.25
    local info = TweenInfo.new(duration, style, direction)
    local t    = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function MakeRipple(button, color)
    button.ClipsDescendants = true
    button.MouseButton1Down:Connect(function(x, y)
        local absPos  = button.AbsolutePosition
        local absSize = button.AbsoluteSize
        local relX    = x - absPos.X
        local relY    = y - absPos.Y
        local maxDist = math.sqrt(absSize.X^2 + absSize.Y^2)

        local ripple = Create("Frame", {
            Parent           = button,
            BackgroundColor3 = color or Color3.fromRGB(255,255,255),
            BackgroundTransparency = 0.7,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 0, 0, 0),
            Position         = UDim2.new(0, relX, 0, relY),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            ZIndex           = button.ZIndex + 1,
        })
        Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = ripple })

        Tween(ripple, {
            Size = UDim2.new(0, maxDist*2, 0, maxDist*2),
            BackgroundTransparency = 1
        }, 0.5, Enum.EasingStyle.Quad)

        task.delay(0.5, function() ripple:Destroy() end)
    end)
end

-- ─── Built-in Themes ────────────────────────────────────────────────────────
local Themes = {
    Dark = {
        Name              = "Dark",
        Background        = Color3.fromRGB(14,  14,  18),
        Surface           = Color3.fromRGB(22,  22,  28),
        SurfaceLight      = Color3.fromRGB(30,  30,  38),
        Border            = Color3.fromRGB(45,  45,  58),
        Accent            = Color3.fromRGB(99,  102, 241),  -- Indigo
        AccentHover       = Color3.fromRGB(79,  82,  221),
        AccentText        = Color3.fromRGB(255, 255, 255),
        TextPrimary       = Color3.fromRGB(240, 240, 248),
        TextSecondary     = Color3.fromRGB(140, 140, 165),
        TextMuted         = Color3.fromRGB(80,  80,  100),
        Success           = Color3.fromRGB(52,  211, 153),
        Warning           = Color3.fromRGB(251, 191, 36),
        Error             = Color3.fromRGB(248, 113, 113),
        ToggleOff         = Color3.fromRGB(45,  45,  58),
        ToggleOn          = Color3.fromRGB(99,  102, 241),
        SliderTrack       = Color3.fromRGB(45,  45,  58),
        SliderFill        = Color3.fromRGB(99,  102, 241),
        InputBackground   = Color3.fromRGB(18,  18,  24),
        ScrollBar         = Color3.fromRGB(60,  60,  78),
        WindowShadow      = Color3.fromRGB(0,   0,   0),
        TabActive         = Color3.fromRGB(99,  102, 241),
        TabInactive       = Color3.fromRGB(22,  22,  28),
        NotifBackground   = Color3.fromRGB(26,  26,  34),
        CornerRadius      = UDim.new(0, 8),
        CornerRadiusSmall = UDim.new(0, 5),
        Font              = Enum.Font.GothamMedium,
        FontBold          = Enum.Font.GothamBold,
        FontLight         = Enum.Font.Gotham,
    },

    Light = {
        Name              = "Light",
        Background        = Color3.fromRGB(245, 245, 252),
        Surface           = Color3.fromRGB(255, 255, 255),
        SurfaceLight      = Color3.fromRGB(248, 248, 255),
        Border            = Color3.fromRGB(220, 220, 235),
        Accent            = Color3.fromRGB(99,  102, 241),
        AccentHover       = Color3.fromRGB(79,  82,  221),
        AccentText        = Color3.fromRGB(255, 255, 255),
        TextPrimary       = Color3.fromRGB(20,  20,  35),
        TextSecondary     = Color3.fromRGB(90,  90,  120),
        TextMuted         = Color3.fromRGB(160, 160, 185),
        Success           = Color3.fromRGB(16,  185, 129),
        Warning           = Color3.fromRGB(245, 158, 11),
        Error             = Color3.fromRGB(239, 68,  68),
        ToggleOff         = Color3.fromRGB(200, 200, 218),
        ToggleOn          = Color3.fromRGB(99,  102, 241),
        SliderTrack       = Color3.fromRGB(210, 210, 228),
        SliderFill        = Color3.fromRGB(99,  102, 241),
        InputBackground   = Color3.fromRGB(240, 240, 250),
        ScrollBar         = Color3.fromRGB(180, 180, 205),
        WindowShadow      = Color3.fromRGB(100, 100, 130),
        TabActive         = Color3.fromRGB(99,  102, 241),
        TabInactive       = Color3.fromRGB(255, 255, 255),
        NotifBackground   = Color3.fromRGB(255, 255, 255),
        CornerRadius      = UDim.new(0, 8),
        CornerRadiusSmall = UDim.new(0, 5),
        Font              = Enum.Font.GothamMedium,
        FontBold          = Enum.Font.GothamBold,
        FontLight         = Enum.Font.Gotham,
    },

    Ocean = {
        Name              = "Ocean",
        Background        = Color3.fromRGB(8,   18,  35),
        Surface           = Color3.fromRGB(12,  26,  48),
        SurfaceLight      = Color3.fromRGB(16,  34,  62),
        Border            = Color3.fromRGB(25,  55,  90),
        Accent            = Color3.fromRGB(14,  165, 233),
        AccentHover       = Color3.fromRGB(2,   132, 199),
        AccentText        = Color3.fromRGB(255, 255, 255),
        TextPrimary       = Color3.fromRGB(224, 242, 255),
        TextSecondary     = Color3.fromRGB(125, 175, 220),
        TextMuted         = Color3.fromRGB(60,  110, 160),
        Success           = Color3.fromRGB(52,  211, 153),
        Warning           = Color3.fromRGB(251, 191, 36),
        Error             = Color3.fromRGB(248, 113, 113),
        ToggleOff         = Color3.fromRGB(25,  55,  90),
        ToggleOn          = Color3.fromRGB(14,  165, 233),
        SliderTrack       = Color3.fromRGB(25,  55,  90),
        SliderFill        = Color3.fromRGB(14,  165, 233),
        InputBackground   = Color3.fromRGB(8,   20,  38),
        ScrollBar         = Color3.fromRGB(35,  75,  120),
        WindowShadow      = Color3.fromRGB(0,   0,   0),
        TabActive         = Color3.fromRGB(14,  165, 233),
        TabInactive       = Color3.fromRGB(12,  26,  48),
        NotifBackground   = Color3.fromRGB(14,  30,  55),
        CornerRadius      = UDim.new(0, 8),
        CornerRadiusSmall = UDim.new(0, 5),
        Font              = Enum.Font.GothamMedium,
        FontBold          = Enum.Font.GothamBold,
        FontLight         = Enum.Font.Gotham,
    },

    Rose = {
        Name              = "Rose",
        Background        = Color3.fromRGB(20,  10,  15),
        Surface           = Color3.fromRGB(30,  15,  22),
        SurfaceLight      = Color3.fromRGB(40,  20,  30),
        Border            = Color3.fromRGB(70,  35,  52),
        Accent            = Color3.fromRGB(244, 63,  94),
        AccentHover       = Color3.fromRGB(225, 29,  72),
        AccentText        = Color3.fromRGB(255, 255, 255),
        TextPrimary       = Color3.fromRGB(255, 230, 238),
        TextSecondary     = Color3.fromRGB(200, 130, 155),
        TextMuted         = Color3.fromRGB(120, 70,  90),
        Success           = Color3.fromRGB(52,  211, 153),
        Warning           = Color3.fromRGB(251, 191, 36),
        Error             = Color3.fromRGB(248, 113, 113),
        ToggleOff         = Color3.fromRGB(70,  35,  52),
        ToggleOn          = Color3.fromRGB(244, 63,  94),
        SliderTrack       = Color3.fromRGB(70,  35,  52),
        SliderFill        = Color3.fromRGB(244, 63,  94),
        InputBackground   = Color3.fromRGB(18,  8,   13),
        ScrollBar         = Color3.fromRGB(90,  45,  65),
        WindowShadow      = Color3.fromRGB(0,   0,   0),
        TabActive         = Color3.fromRGB(244, 63,  94),
        TabInactive       = Color3.fromRGB(30,  15,  22),
        NotifBackground   = Color3.fromRGB(35,  18,  26),
        CornerRadius      = UDim.new(0, 8),
        CornerRadiusSmall = UDim.new(0, 5),
        Font              = Enum.Font.GothamMedium,
        FontBold          = Enum.Font.GothamBold,
        FontLight         = Enum.Font.Gotham,
    },
}

-- ─── Nova State ─────────────────────────────────────────────────────────────
Nova._theme        = Themes.Dark
Nova._windows      = {}
Nova._notifCount   = 0
Nova._notifContainer = nil

-- ─── Theme API ───────────────────────────────────────────────────────────────
function Nova:SetTheme(theme)
    if type(theme) == "string" then
        assert(Themes[theme], "Theme '"..theme.."' not found. Available: Dark, Light, Ocean, Rose")
        self._theme = Themes[theme]
    elseif type(theme) == "table" then
        -- Merge with Dark as base so missing keys are filled
        local merged = {}
        for k, v in pairs(Themes.Dark) do merged[k] = v end
        for k, v in pairs(theme)       do merged[k] = v end
        self._theme = merged
    end
end

function Nova:GetTheme()
    return self._theme
end

function Nova:GetThemes()
    local names = {}
    for k in pairs(Themes) do table.insert(names, k) end
    return names
end

-- ─── Notification System ─────────────────────────────────────────────────────
local function EnsureNotifContainer(t)
    if Nova._notifContainer and Nova._notifContainer.Parent then
        return Nova._notifContainer
    end
    local gui = Create("ScreenGui", {
        Name            = "NovaNotifications",
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        Parent          = PlayerGui,
    })
    local container = Create("Frame", {
        Name            = "Container",
        BackgroundTransparency = 1,
        Size            = UDim2.new(0, 320, 1, 0),
        Position        = UDim2.new(1, -330, 0, 0),
        Parent          = gui,
    })
    Create("UIListLayout", {
        SortOrder       = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding         = UDim.new(0, 8),
        Parent          = container,
    })
    Create("UIPadding", {
        PaddingBottom   = UDim.new(0, 16),
        Parent          = container,
    })
    Nova._notifContainer = container
    return container
end

function Nova:Notify(options)
    local t = self._theme
    options = options or {}
    local title    = options.Title    or "Notification"
    local message  = options.Message  or ""
    local duration = options.Duration or 4
    local ntype    = options.Type     or "info" -- info, success, warning, error

    local iconMap = {
        info    = "rbxassetid://7733960981",
        success = "rbxassetid://7734053495",
        warning = "rbxassetid://7734053491",
        error   = "rbxassetid://7733998090",
    }
    local colorMap = {
        info    = t.Accent,
        success = t.Success,
        warning = t.Warning,
        error   = t.Error,
    }
    local accentColor = colorMap[ntype] or t.Accent
    local container   = EnsureNotifContainer(t)

    Nova._notifCount += 1
    local card = Create("Frame", {
        Name            = "Notif_"..Nova._notifCount,
        BackgroundColor3 = t.NotifBackground,
        BorderSizePixel = 0,
        Size            = UDim2.new(1, 0, 0, 72),
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Parent          = container,
    })
    Create("UICorner",   { CornerRadius = t.CornerRadius, Parent = card })
    Create("UIStroke",   { Color = t.Border, Thickness = 1, Parent = card })

    -- Left accent bar
    local bar = Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 3, 1, 0),
        Parent           = card,
    })
    Create("UICorner", { CornerRadius = UDim.new(0,4), Parent = bar })

    -- Icon
    Create("ImageLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 16, 0.5, -10),
        Image    = iconMap[ntype] or iconMap.info,
        ImageColor3 = accentColor,
        Parent   = card,
    })

    -- Title
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -52, 0, 18),
        Position = UDim2.new(0, 48, 0, 14),
        Text     = title,
        TextColor3 = t.TextPrimary,
        TextSize = 13,
        Font     = t.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent   = card,
    })

    -- Message
    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size     = UDim2.new(1, -52, 0, 28),
        Position = UDim2.new(0, 48, 0, 34),
        Text     = message,
        TextColor3 = t.TextSecondary,
        TextSize = 11,
        Font     = t.FontLight,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped    = true,
        Parent   = card,
    })

    -- Progress bar
    local progress = Create("Frame", {
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Size  = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = card,
    })

    -- Appear
    Tween(card, { BackgroundTransparency = 0 }, 0.3)
    Tween(card, { Size = UDim2.new(1, 0, 0, 72) }, 0.3)
    Tween(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(card, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.3)
        card:Destroy()
    end)

    return card
end

-- ─── Window ──────────────────────────────────────────────────────────────────
function Nova:CreateWindow(options)
    options = options or {}
    local t = self._theme

    local windowTitle  = options.Title  or "Nova Window"
    local windowSize   = options.Size   or UDim2.new(0, 560, 0, 420)
    local windowPos    = options.Position or UDim2.new(0.5, -280, 0.5, -210)
    local showTitle    = options.ShowTitle ~= false

    -- Screen GUI
    local screenGui = Create("ScreenGui", {
        Name           = "Nova_"..windowTitle:gsub("%s",""),
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = PlayerGui,
    })

    -- Main window frame
    local mainFrame = Create("Frame", {
        Name             = "MainFrame",
        BackgroundColor3 = t.Background,
        BorderSizePixel  = 0,
        Size             = windowSize,
        Position         = windowPos,
        ClipsDescendants = false,
        Parent           = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = mainFrame })

    -- Shadow
    local shadow = Create("ImageLabel", {
        Name                   = "Shadow",
        BackgroundTransparency = 1,
        Image                  = "rbxassetid://6014261993",
        ImageColor3            = t.WindowShadow,
        ImageTransparency      = 0.4,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(49,49,450,450),
        Size                   = UDim2.new(1, 40, 1, 40),
        Position               = UDim2.new(0, -20, 0, -20),
        ZIndex                 = mainFrame.ZIndex - 1,
        Parent                 = mainFrame,
    })

    -- Title bar
    local titleBar = Create("Frame", {
        Name             = "TitleBar",
        BackgroundColor3 = t.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 48),
        Position         = UDim2.new(0, 0, 0, 0),
        Parent           = mainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = titleBar })

    -- Fix bottom corners of titlebar
    Create("Frame", {
        BackgroundColor3 = t.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        Parent           = titleBar,
    })

    -- Accent dot
    local accentDot = Create("Frame", {
        BackgroundColor3 = t.Accent,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 8, 0, 8),
        Position         = UDim2.new(0, 16, 0.5, -4),
        Parent           = titleBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = accentDot })

    -- Title label
    if showTitle then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -100, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            Text     = windowTitle,
            TextColor3 = t.TextPrimary,
            TextSize   = 14,
            Font       = t.FontBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent   = titleBar,
        })
    end

    -- Close button
    local closeBtn = Create("TextButton", {
        Name             = "CloseBtn",
        BackgroundColor3 = Color3.fromRGB(248,113,113),
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(1, -18, 0.5, -7),
        Text             = "",
        Parent           = titleBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function()
        Tween(mainFrame, { Size = UDim2.new(0, windowSize.X.Offset, 0, 0), BackgroundTransparency = 1 }, 0.2)
        task.wait(0.2)
        screenGui:Destroy()
    end)

    -- Minimize button
    local minBtn = Create("TextButton", {
        Name             = "MinBtn",
        BackgroundColor3 = Color3.fromRGB(251,191,36),
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(1, -36, 0.5, -7),
        Text             = "",
        Parent           = titleBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = minBtn })

    local minimized = false
    local fullSize  = windowSize
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            fullSize = mainFrame.Size
            Tween(mainFrame, { Size = UDim2.new(fullSize.X.Scale, fullSize.X.Offset, 0, 48) }, 0.25)
        else
            Tween(mainFrame, { Size = fullSize }, 0.25)
        end
    end)

    MakeDraggable(mainFrame, titleBar)

    -- Left sidebar (tabs)
    local sidebar = Create("Frame", {
        Name             = "Sidebar",
        BackgroundColor3 = t.Surface,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 140, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        ClipsDescendants = true,
        Parent           = mainFrame,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = sidebar })
    Create("Frame", { -- Fix top-right corner
        BackgroundColor3 = t.Surface, BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 1, 0), Position = UDim2.new(1, -12, 0, 0), Parent = sidebar
    })
    Create("Frame", { -- Fix top corners
        BackgroundColor3 = t.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 0), Parent = sidebar
    })

    local tabList = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, -16),
        Position               = UDim2.new(0, 0, 0, 16),
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        Parent                 = sidebar,
    })
    Create("UIListLayout", {
        SortOrder  = Enum.SortOrder.LayoutOrder,
        Padding    = UDim.new(0, 2),
        Parent     = tabList,
    })
    Create("UIPadding", {
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent       = tabList,
    })

    -- Content area
    local contentArea = Create("Frame", {
        Name             = "ContentArea",
        BackgroundColor3 = t.Background,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -148, 1, -56),
        Position         = UDim2.new(0, 148, 0, 56),
        ClipsDescendants = true,
        Parent           = mainFrame,
    })

    -- Bottom divider
    Create("Frame", {
        BackgroundColor3 = t.Border,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, -148, 0, 1),
        Position         = UDim2.new(0, 148, 0, 55),
        Parent           = mainFrame,
    })

    -- Animate window in
    mainFrame.Size = UDim2.new(0, windowSize.X.Offset, 0, 0)
    mainFrame.BackgroundTransparency = 1
    Tween(mainFrame, { Size = windowSize, BackgroundTransparency = 0 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Window object
    local Window   = {}
    Window._tabs   = {}
    Window._active = nil
    Window._nova   = self
    Window.Frame   = mainFrame
    Window.Gui     = screenGui

    function Window:SetTitle(text)
        local lbl = titleBar:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = text end
    end

    function Window:Close()
        screenGui:Destroy()
    end

    function Window:AddTab(name, icon)
        local tabIndex = #self._tabs + 1
        local isFirst  = tabIndex == 1

        -- Tab button
        local tabBtn = Create("TextButton", {
            Name             = "Tab_"..name,
            BackgroundColor3 = isFirst and t.TabActive or t.TabInactive,
            BackgroundTransparency = isFirst and 0 or 1,
            BorderSizePixel  = 0,
            Size             = UDim2.new(1, 0, 0, 36),
            Text             = "",
            LayoutOrder      = tabIndex,
            Parent           = tabList,
        })
        Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = tabBtn })

        if icon then
            Create("ImageLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 10, 0.5, -8),
                Image    = icon,
                ImageColor3 = isFirst and t.AccentText or t.TextSecondary,
                Name     = "Icon",
                Parent   = tabBtn,
            })
        end

        local tabLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, -(icon and 36 or 12), 1, 0),
            Position = UDim2.new(0, icon and 34 or 12, 0, 0),
            Text     = name,
            TextColor3 = isFirst and t.AccentText or t.TextSecondary,
            TextSize   = 12,
            Font       = isFirst and t.FontBold or t.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            Name     = "Label",
            Parent   = tabBtn,
        })

        -- Active indicator
        local indicator = Create("Frame", {
            BackgroundColor3 = t.AccentText,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 3, 0, 16),
            Position         = UDim2.new(1, -3, 0.5, -8),
            BackgroundTransparency = isFirst and 0 or 1,
            Parent           = tabBtn,
        })
        Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = indicator })

        -- Tab content page
        local page = Create("ScrollingFrame", {
            Name                   = "Page_"..name,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Position               = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness     = 4,
            ScrollBarImageColor3   = t.ScrollBar,
            CanvasSize             = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize    = Enum.AutomaticSize.Y,
            Visible                = isFirst,
            Parent                 = contentArea,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 6),
            Parent    = page,
        })
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft   = UDim.new(0, 12),
            PaddingRight  = UDim.new(0, 12),
            Parent        = page,
        })

        local Tab = {}
        Tab._page  = page
        Tab._nova  = self._nova
        Tab._btn   = tabBtn
        Tab._name  = name

        -- Switch tab on click
        tabBtn.MouseButton1Click:Connect(function()
            if Window._active == Tab then return end

            -- Deactivate current
            if Window._active then
                local prev = Window._active
                prev._page.Visible = false
                Tween(prev._btn, { BackgroundTransparency = 1 }, 0.2)
                local pl = prev._btn:FindFirstChild("Label")
                local pi = prev._btn:FindFirstChild("Icon")
                local pind = prev._btn:FindFirstChildOfClass("Frame")
                if pl then
                    pl.Font = t.Font
                    Tween(pl, { TextColor3 = t.TextSecondary }, 0.2)
                end
                if pi then Tween(pi, { ImageColor3 = t.TextSecondary }, 0.2) end
                if pind then Tween(pind, { BackgroundTransparency = 1 }, 0.2) end
            end

            -- Activate this
            Window._active = Tab
            page.Visible   = true
            page.Position  = UDim2.new(0.05, 0, 0, 0)
            page.BackgroundTransparency = 1
            Tween(page, { Position = UDim2.new(0,0,0,0) }, 0.2)
            Tween(tabBtn, { BackgroundTransparency = 0, BackgroundColor3 = t.TabActive }, 0.2)
            local lbl = tabBtn:FindFirstChild("Label")
            local ico = tabBtn:FindFirstChild("Icon")
            local ind = tabBtn:FindFirstChildOfClass("Frame")
            if lbl then
                lbl.Font = t.FontBold
                Tween(lbl, { TextColor3 = t.AccentText }, 0.2)
            end
            if ico then Tween(ico, { ImageColor3 = t.AccentText }, 0.2) end
            if ind then Tween(ind, { BackgroundTransparency = 0 }, 0.2) end
        end)

        if isFirst then
            Window._active = Tab
        end

        table.insert(Window._tabs, Tab)

        -- ── Component Methods ──────────────────────────────────────────────

        function Tab:AddSection(title)
            local order = #page:GetChildren()

            -- Section header
            local header = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size     = UDim2.new(1, 0, 0, 28),
                LayoutOrder = order,
                Parent   = page,
            })
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, 0, 1, 0),
                Text     = title:upper(),
                TextColor3 = t.Accent,
                TextSize   = 10,
                Font       = t.FontBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = header,
            })

            local Section = {}
            Section._page = page
            Section._tab  = Tab
            setmetatable(Section, { __index = Tab })
            return Section
        end

        function Tab:AddButton(options)
            options = options or {}
            local label    = options.Text     or "Button"
            local desc     = options.Desc     or nil
            local callback = options.Callback or function() end
            local order    = #page:GetChildren()
            local btnStyle = options.Style    or "default" -- default, accent, ghost

            local height = desc and 56 or 40

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, height),
                LayoutOrder = order,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            if btnStyle == "accent" then
                container.BackgroundColor3 = t.Accent
            elseif btnStyle == "ghost" then
                container.BackgroundTransparency = 1
                Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = container })
            end

            local textColor = btnStyle == "accent" and t.AccentText or t.TextPrimary

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -40, 0, 20),
                Position = UDim2.new(0, 14, 0.5, desc and -14 or -10),
                Text     = label,
                TextColor3 = textColor,
                TextSize   = 13,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            if desc then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -40, 0, 16),
                    Position = UDim2.new(0, 14, 0.5, 4),
                    Text     = desc,
                    TextColor3 = t.TextSecondary,
                    TextSize   = 11,
                    Font       = t.FontLight,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent   = container,
                })
            end

            -- Arrow icon
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -28, 0, 0),
                Text     = "›",
                TextColor3 = btnStyle == "accent" and t.AccentText or t.TextMuted,
                TextSize   = 18,
                Font       = t.FontBold,
                Parent   = container,
            })

            local clickBtn = Create("TextButton", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size   = UDim2.new(1, 0, 1, 0),
                Text   = "",
                ZIndex = container.ZIndex + 1,
                Parent = container,
            })
            MakeRipple(clickBtn, btnStyle == "accent" and Color3.fromRGB(255,255,255) or t.Accent)

            clickBtn.MouseEnter:Connect(function()
                if btnStyle == "accent" then
                    Tween(container, { BackgroundColor3 = t.AccentHover }, 0.15)
                else
                    Tween(container, { BackgroundColor3 = t.SurfaceLight }, 0.15)
                end
            end)
            clickBtn.MouseLeave:Connect(function()
                if btnStyle == "accent" then
                    Tween(container, { BackgroundColor3 = t.Accent }, 0.15)
                elseif btnStyle == "ghost" then
                    Tween(container, { BackgroundTransparency = 1 }, 0.15)
                else
                    Tween(container, { BackgroundColor3 = t.Surface }, 0.15)
                end
            end)
            clickBtn.MouseButton1Click:Connect(callback)

            return container
        end

        function Tab:AddToggle(options)
            options = options or {}
            local label    = options.Text     or "Toggle"
            local desc     = options.Desc     or nil
            local default  = options.Default  ~= nil and options.Default or false
            local callback = options.Callback or function() end
            local order    = #page:GetChildren()
            local height   = desc and 56 or 40

            local state = default

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, height),
                LayoutOrder = order,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -70, 0, 20),
                Position = UDim2.new(0, 14, 0.5, desc and -14 or -10),
                Text     = label,
                TextColor3 = t.TextPrimary,
                TextSize   = 13,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            if desc then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -70, 0, 16),
                    Position = UDim2.new(0, 14, 0.5, 4),
                    Text     = desc,
                    TextColor3 = t.TextSecondary,
                    TextSize   = 11,
                    Font       = t.FontLight,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent   = container,
                })
            end

            -- Toggle track
            local track = Create("Frame", {
                BackgroundColor3 = state and t.ToggleOn or t.ToggleOff,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -56, 0.5, -11),
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = track })

            -- Toggle knob
            local knob = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                Parent   = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })

            local clickBtn = Create("TextButton", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size   = UDim2.new(1, 0, 1, 0),
                Text   = "",
                ZIndex = container.ZIndex + 1,
                Parent = container,
            })

            local Toggle = {}
            function Toggle:Set(value)
                state = value
                if state then
                    Tween(track, { BackgroundColor3 = t.ToggleOn }, 0.2)
                    Tween(knob,  { Position = UDim2.new(1,-19,0.5,-8) }, 0.2, Enum.EasingStyle.Back)
                else
                    Tween(track, { BackgroundColor3 = t.ToggleOff }, 0.2)
                    Tween(knob,  { Position = UDim2.new(0,3,0.5,-8) }, 0.2, Enum.EasingStyle.Back)
                end
                callback(state)
            end
            function Toggle:Get() return state end

            clickBtn.MouseButton1Click:Connect(function()
                Toggle:Set(not state)
            end)

            return Toggle
        end

        function Tab:AddSlider(options)
            options = options or {}
            local label    = options.Text    or "Slider"
            local desc     = options.Desc    or nil
            local min      = options.Min     or 0
            local max      = options.Max     or 100
            local default  = options.Default or min
            local suffix   = options.Suffix  or ""
            local step     = options.Step    or 1
            local callback = options.Callback or function() end
            local order    = #page:GetChildren()

            local value = math.clamp(default, min, max)
            local pct   = (value - min) / (max - min)

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, 60),
                LayoutOrder = order,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            -- Label row
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -80, 0, 18),
                Position = UDim2.new(0, 14, 0, 10),
                Text     = label,
                TextColor3 = t.TextPrimary,
                TextSize   = 13,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            local valLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 70, 0, 18),
                Position = UDim2.new(1, -84, 0, 10),
                Text     = tostring(value)..suffix,
                TextColor3 = t.Accent,
                TextSize   = 12,
                Font       = t.FontBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent   = container,
            })

            -- Track background
            local track = Create("Frame", {
                BackgroundColor3 = t.SliderTrack,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, -28, 0, 4),
                Position = UDim2.new(0, 14, 1, -20),
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = track })

            -- Track fill
            local fill = Create("Frame", {
                BackgroundColor3 = t.SliderFill,
                BorderSizePixel  = 0,
                Size     = UDim2.new(pct, 0, 1, 0),
                Parent   = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = fill })

            -- Knob
            local knob = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(pct, -7, 0.5, -7),
                ZIndex   = track.ZIndex + 1,
                Parent   = track,
            })
            Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = knob })

            -- Drag logic
            local dragging = false
            local function UpdateSlider(inputX)
                local absPos  = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local newPct  = math.clamp((inputX - absPos) / absSize, 0, 1)
                local raw     = min + (max - min) * newPct
                local stepped = math.round(raw / step) * step
                value = math.clamp(stepped, min, max)
                pct   = (value - min) / (max - min)
                fill.Size     = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -7, 0.5, -7)
                valLabel.Text = tostring(math.round(value * 100) / 100)..suffix
                callback(value)
            end

            local trackBtn = Create("TextButton", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size   = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0.5, -10),
                Text   = "",
                ZIndex = knob.ZIndex + 1,
                Parent = track,
            })
            trackBtn.MouseButton1Down:Connect(function(x)
                dragging = true
                UpdateSlider(x)
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            local Slider = {}
            function Slider:Set(v)
                value = math.clamp(v, min, max)
                pct   = (value - min) / (max - min)
                Tween(fill, { Size = UDim2.new(pct,0,1,0) }, 0.15)
                Tween(knob, { Position = UDim2.new(pct,-7,0.5,-7) }, 0.15)
                valLabel.Text = tostring(value)..suffix
                callback(value)
            end
            function Slider:Get() return value end
            return Slider
        end

        function Tab:AddTextInput(options)
            options = options or {}
            local label       = options.Text        or "Input"
            local placeholder = options.Placeholder or "Type here..."
            local default     = options.Default     or ""
            local callback    = options.Callback    or function() end
            local order       = #page:GetChildren()

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, 64),
                LayoutOrder = order,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -20, 0, 16),
                Position = UDim2.new(0, 14, 0, 10),
                Text     = label,
                TextColor3 = t.TextSecondary,
                TextSize   = 11,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            local inputBox = Create("Frame", {
                BackgroundColor3 = t.InputBackground,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, -28, 0, 26),
                Position = UDim2.new(0, 14, 0, 30),
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = inputBox })

            local stroke = Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = inputBox })

            local textBox = Create("TextBox", {
                BackgroundTransparency = 1,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text     = default,
                PlaceholderText = placeholder,
                PlaceholderColor3 = t.TextMuted,
                TextColor3 = t.TextPrimary,
                TextSize   = 12,
                Font       = t.FontLight,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent   = inputBox,
            })

            textBox.Focused:Connect(function()
                Tween(stroke, { Color = t.Accent }, 0.2)
            end)
            textBox.FocusLost:Connect(function(enter)
                Tween(stroke, { Color = t.Border }, 0.2)
                callback(textBox.Text, enter)
            end)

            local Input = {}
            function Input:Set(v) textBox.Text = v end
            function Input:Get() return textBox.Text end
            return Input
        end

        function Tab:AddDropdown(options)
            options = options or {}
            local label    = options.Text     or "Dropdown"
            local items    = options.Items    or {}
            local default  = options.Default  or (items[1] or "Select...")
            local callback = options.Callback or function() end
            local order    = #page:GetChildren()

            local selected = default
            local open     = false

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = order,
                ClipsDescendants = false,
                ZIndex   = 5,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                Text     = label,
                TextColor3 = t.TextPrimary,
                TextSize   = 13,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            local selFrame = Create("Frame", {
                BackgroundColor3 = t.InputBackground,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 130, 0, 28),
                Position = UDim2.new(1, -142, 0.5, -14),
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = selFrame })
            Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = selFrame })

            local selLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text     = selected,
                TextColor3 = t.TextPrimary,
                TextSize   = 11,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = selFrame,
            })

            local arrow = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -22, 0, 0),
                Text     = "▾",
                TextColor3 = t.TextSecondary,
                TextSize   = 11,
                Font       = t.FontBold,
                Parent   = selFrame,
            })

            -- Dropdown list (appears below)
            local dropList = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 130, 0, 0),
                Position = UDim2.new(1, -142, 1, 4),
                ClipsDescendants = true,
                ZIndex   = 20,
                Visible  = false,
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = dropList })
            Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = dropList })
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = dropList })

            local function BuildItems()
                for _, child in ipairs(dropList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, item in ipairs(items) do
                    local btn = Create("TextButton", {
                        BackgroundTransparency = item == selected and 0 or 1,
                        BackgroundColor3 = t.SurfaceLight,
                        BorderSizePixel  = 0,
                        Size     = UDim2.new(1, 0, 0, 28),
                        Text     = item,
                        TextColor3 = item == selected and t.Accent or t.TextPrimary,
                        TextSize   = 11,
                        Font       = item == selected and t.FontBold or t.Font,
                        ZIndex     = 21,
                        LayoutOrder = i,
                        Parent   = dropList,
                    })
                    btn.MouseEnter:Connect(function() Tween(btn, { BackgroundTransparency = 0, BackgroundColor3 = t.SurfaceLight }, 0.1) end)
                    btn.MouseLeave:Connect(function()
                        if item ~= selected then Tween(btn, { BackgroundTransparency = 1 }, 0.1) end
                    end)
                    btn.MouseButton1Click:Connect(function()
                        selected     = item
                        selLabel.Text = item
                        callback(item)
                        -- Close
                        open = false
                        Tween(dropList, { Size = UDim2.new(0,130,0,0) }, 0.2)
                        task.wait(0.2)
                        dropList.Visible = false
                        BuildItems()
                    end)
                end
            end
            BuildItems()

            local totalH = #items * 28
            local toggleBtn = Create("TextButton", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size   = UDim2.new(1,0,1,0),
                Text   = "",
                ZIndex = selFrame.ZIndex + 1,
                Parent = selFrame,
            })
            toggleBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    dropList.Visible = true
                    dropList.Size    = UDim2.new(0,130,0,0)
                    Tween(dropList, { Size = UDim2.new(0,130,0,math.min(totalH,120)) }, 0.2)
                    Tween(arrow, { Rotation = 180 }, 0.2)
                else
                    Tween(dropList, { Size = UDim2.new(0,130,0,0) }, 0.2)
                    Tween(arrow, { Rotation = 0 }, 0.2)
                    task.delay(0.2, function() dropList.Visible = false end)
                end
            end)

            local Dropdown = {}
            function Dropdown:Set(v)
                selected = v
                selLabel.Text = v
                BuildItems()
                callback(v)
            end
            function Dropdown:Get() return selected end
            function Dropdown:SetItems(newItems)
                items = newItems
                totalH = #items * 28
                BuildItems()
            end
            return Dropdown
        end

        function Tab:AddLabel(options)
            options = options or {}
            local text  = options.Text  or "Label"
            local color = options.Color or t.TextPrimary
            local size  = options.Size  or 13
            local order = #page:GetChildren()

            local frame = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size     = UDim2.new(1, 0, 0, 24),
                LayoutOrder = order,
                Parent   = page,
            })

            local lbl = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                Text     = text,
                TextColor3 = color,
                TextSize   = size,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped    = true,
                Parent   = frame,
            })

            local Label = {}
            function Label:Set(v) lbl.Text = v end
            function Label:Get() return lbl.Text end
            function Label:SetColor(c) lbl.TextColor3 = c end
            return Label
        end

        function Tab:AddSeparator(title)
            local order = #page:GetChildren()
            local h     = title and 30 or 14

            local frame = Create("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size     = UDim2.new(1, 0, 0, h),
                LayoutOrder = order,
                Parent   = page,
            })

            if title then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 14, 0, 0),
                    Text     = title,
                    TextColor3 = t.TextMuted,
                    TextSize   = 10,
                    Font       = t.FontBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent   = frame,
                })
            end

            Create("Frame", {
                BackgroundColor3 = t.Border,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, -28, 0, 1),
                Position = UDim2.new(0, 14, title and 1 or 0.5, title and -1 or 0),
                Parent   = frame,
            })
        end

        function Tab:AddKeybind(options)
            options = options or {}
            local label    = options.Text     or "Keybind"
            local default  = options.Default  or Enum.KeyCode.Unknown
            local callback = options.Callback or function() end
            local order    = #page:GetChildren()

            local bound    = default
            local listening = false

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, 40),
                LayoutOrder = order,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -130, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                Text     = label,
                TextColor3 = t.TextPrimary,
                TextSize   = 13,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            local keyBtn = Create("TextButton", {
                BackgroundColor3 = t.InputBackground,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 90, 0, 26),
                Position = UDim2.new(1, -104, 0.5, -13),
                Text     = bound == Enum.KeyCode.Unknown and "None" or bound.Name,
                TextColor3 = t.Accent,
                TextSize   = 11,
                Font       = t.FontBold,
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = keyBtn })
            Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = keyBtn })

            keyBtn.MouseButton1Click:Connect(function()
                listening         = true
                keyBtn.Text       = "..."
                keyBtn.TextColor3 = t.Warning
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening         = false
                    bound             = input.KeyCode
                    keyBtn.Text       = bound.Name
                    keyBtn.TextColor3 = t.Accent
                end
                if not listening and not gameProcessed and input.KeyCode == bound and bound ~= Enum.KeyCode.Unknown then
                    callback(bound)
                end
            end)

            local Keybind = {}
            function Keybind:Set(keyCode) bound = keyCode; keyBtn.Text = keyCode.Name end
            function Keybind:Get() return bound end
            return Keybind
        end

        function Tab:AddColorPicker(options)
            options = options or {}
            local label    = options.Text     or "Color"
            local default  = options.Default  or Color3.fromRGB(99,102,241)
            local callback = options.Callback or function() end
            local order    = #page:GetChildren()

            local hue, sat, val = Color3.toHSV(default)
            local currentColor  = default

            local container = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(1, 0, 0, 44),
                LayoutOrder = order,
                ClipsDescendants = false,
                ZIndex   = 4,
                Parent   = page,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = container })

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                Text     = label,
                TextColor3 = t.TextPrimary,
                TextSize   = 13,
                Font       = t.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent   = container,
            })

            local preview = Create("TextButton", {
                BackgroundColor3 = currentColor,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 60, 0, 28),
                Position = UDim2.new(1, -74, 0.5, -14),
                Text     = "",
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = preview })
            Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = preview })

            -- Color picker popup
            local picker = Create("Frame", {
                BackgroundColor3 = t.Surface,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 200, 0, 0),
                Position = UDim2.new(1, -214, 1, 8),
                ClipsDescendants = true,
                ZIndex   = 30,
                Visible  = false,
                Parent   = container,
            })
            Create("UICorner", { CornerRadius = t.CornerRadius, Parent = picker })
            Create("UIStroke", { Color = t.Border, Thickness = 1, Parent = picker })

            local pickerOpen = false

            -- Hue sliders (simple H/S/V approach)
            local labels = {"H", "S", "V"}
            local vals   = {hue, sat, val}
            local sliders = {}

            for i, lname in ipairs(labels) do
                local row = Create("Frame", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(1, -20, 0, 32),
                    Position = UDim2.new(0, 10, 0, 10 + (i-1)*36),
                    ZIndex   = 31,
                    Parent   = picker,
                })
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size     = UDim2.new(0, 14, 1, 0),
                    Text     = lname,
                    TextColor3 = t.TextSecondary,
                    TextSize   = 11,
                    Font       = t.FontBold,
                    ZIndex     = 31,
                    Parent   = row,
                })
                local sTrack = Create("Frame", {
                    BackgroundColor3 = t.SliderTrack,
                    BorderSizePixel  = 0,
                    Size     = UDim2.new(1, -24, 0, 4),
                    Position = UDim2.new(0, 18, 0.5, -2),
                    ZIndex   = 31,
                    Parent   = row,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = sTrack })
                local sFill = Create("Frame", {
                    BackgroundColor3 = t.Accent,
                    BorderSizePixel  = 0,
                    Size     = UDim2.new(vals[i], 0, 1, 0),
                    ZIndex   = 32,
                    Parent   = sTrack,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = sFill })
                local sKnob = Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255,255,255),
                    BorderSizePixel  = 0,
                    Size     = UDim2.new(0,12,0,12),
                    Position = UDim2.new(vals[i],-6,0.5,-6),
                    ZIndex   = 33,
                    Parent   = sTrack,
                })
                Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = sKnob })

                local sBtn = Create("TextButton", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size   = UDim2.new(1,0,0,16),
                    Position = UDim2.new(0,0,0.5,-8),
                    Text   = "",
                    ZIndex = 34,
                    Parent = sTrack,
                })
                local draggingS = false
                sBtn.MouseButton1Down:Connect(function(x)
                    draggingS = true
                    local p = math.clamp((x - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1)
                    vals[i] = p
                    sFill.Size     = UDim2.new(p,0,1,0)
                    sKnob.Position = UDim2.new(p,-6,0.5,-6)
                    currentColor = Color3.fromHSV(vals[1],vals[2],vals[3])
                    preview.BackgroundColor3 = currentColor
                    callback(currentColor)
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if draggingS and (input.UserInputType == Enum.UserInputType.MouseMovement) then
                        local p = math.clamp((input.Position.X - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1)
                        vals[i] = p
                        sFill.Size     = UDim2.new(p,0,1,0)
                        sKnob.Position = UDim2.new(p,-6,0.5,-6)
                        currentColor = Color3.fromHSV(vals[1],vals[2],vals[3])
                        preview.BackgroundColor3 = currentColor
                        callback(currentColor)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingS = false end
                end)
                table.insert(sliders, { fill = sFill, knob = sKnob })
            end

            preview.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    picker.Visible = true
                    picker.Size    = UDim2.new(0,200,0,0)
                    Tween(picker, { Size = UDim2.new(0,200,0,130) }, 0.2)
                else
                    Tween(picker, { Size = UDim2.new(0,200,0,0) }, 0.2)
                    task.delay(0.2, function() picker.Visible = false end)
                end
            end)

            local CP = {}
            function CP:Set(color)
                currentColor = color
                local h,s,v = Color3.toHSV(color)
                vals = {h,s,v}
                preview.BackgroundColor3 = color
                for i, sl in ipairs(sliders) do
                    sl.fill.Size     = UDim2.new(vals[i],0,1,0)
                    sl.knob.Position = UDim2.new(vals[i],-6,0.5,-6)
                end
                callback(color)
            end
            function CP:Get() return currentColor end
            return CP
        end

        -- Notify shortcut on Tab level
        function Tab:Notify(options)
            return self._nova:Notify(options)
        end

        return Tab
    end

    -- Modal method on Window
    function Window:CreateModal(options)
        options = options or {}
        local title   = options.Title   or "Confirm"
        local message = options.Message or "Are you sure?"
        local onYes   = options.OnConfirm or function() end
        local onNo    = options.OnCancel  or function() end

        local overlay = Create("Frame", {
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size   = UDim2.new(1,0,1,0),
            ZIndex = 50,
            Parent = mainFrame,
        })
        Tween(overlay, { BackgroundTransparency = 0.5 }, 0.2)

        local modal = Create("Frame", {
            BackgroundColor3 = t.Surface,
            BorderSizePixel  = 0,
            Size     = UDim2.new(0, 300, 0, 0),
            Position = UDim2.new(0.5, -150, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            ClipsDescendants = true,
            ZIndex   = 51,
            Parent   = overlay,
        })
        Create("UICorner", { CornerRadius = t.CornerRadius, Parent = modal })

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1,-28,0,22),
            Position = UDim2.new(0,14,0,16),
            Text     = title,
            TextColor3 = t.TextPrimary,
            TextSize   = 15,
            Font       = t.FontBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex   = 52,
            Parent   = modal,
        })

        Create("TextLabel", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1,-28,0,40),
            Position = UDim2.new(0,14,0,44),
            Text     = message,
            TextColor3 = t.TextSecondary,
            TextSize   = 12,
            Font       = t.FontLight,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped    = true,
            ZIndex   = 52,
            Parent   = modal,
        })

        local function makeBtn(txt, xPos, bgColor, textCol, cb)
            local b = Create("TextButton", {
                BackgroundColor3 = bgColor,
                BorderSizePixel  = 0,
                Size     = UDim2.new(0, 120, 0, 34),
                Position = UDim2.new(0, xPos, 0, 96),
                Text     = txt,
                TextColor3 = textCol,
                TextSize   = 13,
                Font       = t.FontBold,
                ZIndex     = 52,
                Parent     = modal,
            })
            Create("UICorner", { CornerRadius = t.CornerRadiusSmall, Parent = b })
            b.MouseButton1Click:Connect(function()
                Tween(modal, { Size = UDim2.new(0,300,0,0) }, 0.2)
                Tween(overlay, { BackgroundTransparency = 1 }, 0.2)
                task.delay(0.2, function() overlay:Destroy() end)
                cb()
            end)
        end
        makeBtn("Cancel", 14,    t.SurfaceLight, t.TextPrimary,  onNo)
        makeBtn("Confirm",148,   t.Accent,       t.AccentText,   onYes)

        Tween(modal, { Size = UDim2.new(0,300,0,142) }, 0.25, Enum.EasingStyle.Back)
    end

    table.insert(Nova._windows, Window)
    return Window
end

return Nova
