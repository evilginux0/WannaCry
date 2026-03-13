--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              Nova UI Library - Luau / Roblox             ║
    ║         مكتبة واجهات متكاملة لـ Roblox بلغة Luau         ║
    ╚══════════════════════════════════════════════════════════╝
    
    المميزات:
    - نافذة دائرية مع خلفية صورة
    - أزرار تكبير (+) وتصغير (-)
    - نظام تابات (قوائم) بتصميم مميز
    - مربعات متحركة (Animated Cards)
    - دخوليات سلسة (Tween Intro)
    - ضبط الدنيا (World/Lighting Settings)
    - سحب النافذة (Draggable)
    - أزرار، تبديلات (Toggles)، شرائط (Sliders)، حقول نص
]]

local Library = {}
Library.__index = Library

-- ═══════════════════════════════════════════
--  الخدمات
-- ═══════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")

-- ═══════════════════════════════════════════
--  ثوابت التصميم
-- ═══════════════════════════════════════════
local COLORS = {
    Background    = Color3.fromRGB(18, 18, 24),
    TopBar        = Color3.fromRGB(12, 12, 18),
    TabBar        = Color3.fromRGB(14, 14, 20),
    TabActive     = Color3.fromRGB(80, 120, 255),
    TabInactive   = Color3.fromRGB(30, 30, 40),
    Element       = Color3.fromRGB(28, 28, 38),
    ElementHover  = Color3.fromRGB(38, 38, 52),
    Accent        = Color3.fromRGB(80, 120, 255),
    AccentDark    = Color3.fromRGB(50, 80, 200),
    Text          = Color3.fromRGB(240, 240, 255),
    SubText       = Color3.fromRGB(160, 160, 180),
    ToggleOff     = Color3.fromRGB(50, 50, 65),
    ToggleOn      = Color3.fromRGB(80, 120, 255),
    SliderFill    = Color3.fromRGB(80, 120, 255),
    SliderBg      = Color3.fromRGB(40, 40, 55),
    CardColors    = {
        Color3.fromRGB(80, 120, 255),
        Color3.fromRGB(120, 80, 255),
        Color3.fromRGB(80, 200, 180),
        Color3.fromRGB(255, 120, 80),
    }
}

-- ═══════════════════════════════════════════
--  دالة مساعدة: إنشاء UICorner
-- ═══════════════════════════════════════════
local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- ═══════════════════════════════════════════
--  دالة مساعدة: إنشاء UIStroke
-- ═══════════════════════════════════════════
local function AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(80, 120, 255)
    s.Thickness = thickness or 1.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- ═══════════════════════════════════════════
--  دالة مساعدة: Tween سريع
-- ═══════════════════════════════════════════
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

-- ═══════════════════════════════════════════
--  دالة مساعدة: تأثير نبضة على عنصر
-- ═══════════════════════════════════════════
local function PulseEffect(frame, color1, color2)
    spawn(function()
        while frame and frame.Parent do
            Tween(frame, {BackgroundColor3 = color2}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1.2)
            Tween(frame, {BackgroundColor3 = color1}, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            wait(1.2)
        end
    end)
end

-- ═══════════════════════════════════════════
--  إنشاء نافذة رئيسية
-- ═══════════════════════════════════════════
function Library:CreateWindow(options)
    options = options or {}
    local Title           = options.Title           or "Nova UI"
    local SubTitle        = options.SubTitle        or "v1.0"
    local BackgroundImage = options.BackgroundImage or ""
    local ImageTransparency = options.ImageTransparency or 0.6
    local IntroEnabled    = options.IntroEnabled    ~= false
    local Size            = options.Size            or UDim2.new(0, 560, 0, 340)
    local Position        = options.Position        or UDim2.new(0.5, -280, 0.5, -170)

    local Window = {}

    -- ─── ScreenGui ───────────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NovaUILibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999

    -- محاولة وضعها في CoreGui أو PlayerGui
    local success = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ─── الإطار الرئيسي ───────────────────────────────────────
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = COLORS.Background
    Main.Position = Position
    Main.Size = Size
    Main.ClipsDescendants = true
    AddCorner(Main, 18)
    AddStroke(Main, Color3.fromRGB(60, 80, 180), 1.5)

    -- ─── خلفية الصورة ─────────────────────────────────────────
    local BgImage = Instance.new("ImageLabel")
    BgImage.Name = "BackgroundImage"
    BgImage.Parent = Main
    BgImage.BackgroundTransparency = 1
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.ZIndex = 1
    BgImage.Image = BackgroundImage
    BgImage.ImageTransparency = ImageTransparency
    BgImage.ScaleType = Enum.ScaleType.Crop

    -- ─── تأثير Gradient خفيف فوق الصورة ──────────────────────
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 18)),
    })
    Gradient.Rotation = 135
    Gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0.1),
    })
    Gradient.Parent = BgImage

    -- ─── شريط العنوان (TopBar) ────────────────────────────────
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = COLORS.TopBar
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.ZIndex = 5
    AddCorner(TopBar, 18)

    -- تمديد لإخفاء الزوايا السفلية للـ TopBar
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Parent = TopBar
    TopBarFix.BackgroundColor3 = COLORS.TopBar
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Position = UDim2.new(0, 0, 0.5, 0)
    TopBarFix.Size = UDim2.new(1, 0, 0.5, 0)
    TopBarFix.ZIndex = 5

    -- نقاط الزخرفة (Dots)
    for i = 1, 3 do
        local dot = Instance.new("Frame")
        dot.Parent = TopBar
        dot.Size = UDim2.new(0, 10, 0, 10)
        dot.Position = UDim2.new(0, 10 + (i - 1) * 16, 0.5, -5)
        dot.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 80, 80)
                            or i == 2 and Color3.fromRGB(255, 200, 0)
                            or Color3.fromRGB(80, 200, 80)
        dot.ZIndex = 6
        AddCorner(dot, 10)
    end

    -- عنوان النافذة
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 60, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.ZIndex = 6
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = COLORS.Text
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Parent = TopBar
    SubLabel.BackgroundTransparency = 1
    SubLabel.Position = UDim2.new(0, 60 + TitleLabel.TextBounds.X + 8, 0, 0)
    SubLabel.Size = UDim2.new(0, 60, 1, 0)
    SubLabel.ZIndex = 6
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.Text = SubTitle
    SubLabel.TextColor3 = COLORS.SubText
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- ─── أزرار التحكم (- و +) ─────────────────────────────────
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Parent = TopBar
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Position = UDim2.new(1, -80, 0, 0)
    ControlsFrame.Size = UDim2.new(0, 70, 1, 0)
    ControlsFrame.ZIndex = 6

    local function MakeControlBtn(symbol, posX, color)
        local btn = Instance.new("TextButton")
        btn.Parent = ControlsFrame
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.Position = UDim2.new(0, posX, 0.5, -12)
        btn.Size = UDim2.new(0, 26, 0, 24)
        btn.ZIndex = 7
        btn.Font = Enum.Font.GothamBold
        btn.Text = symbol
        btn.TextColor3 = color
        btn.TextSize = 16
        AddCorner(btn, 6)

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.15)
        end)
        return btn
    end

    local MinimizeBtn = MakeControlBtn("-", 0,  Color3.fromRGB(255, 200, 0))
    local MaximizeBtn = MakeControlBtn("+", 34, Color3.fromRGB(80, 200, 80))

    -- منطق التصغير والتكبير
    local isMinimized = false
    local fullSize = Size

    MinimizeBtn.MouseButton1Click:Connect(function()
        if not isMinimized then
            isMinimized = true
            Tween(Main, {Size = UDim2.new(0, fullSize.X.Offset, 0, 38)}, 0.35, Enum.EasingStyle.Quart)
        end
    end)

    MaximizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then
            isMinimized = false
            Tween(Main, {Size = fullSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    -- ─── Dragging (سحب النافذة) ───────────────────────────────
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- ─── دخولية الواجهة (Intro Animation) ────────────────────
    if IntroEnabled then
        Main.Size     = UDim2.new(0, 0, 0, 0)
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Main.BackgroundTransparency = 1
        Tween(Main, {
            Size     = Size,
            Position = Position,
            BackgroundTransparency = 0
        }, 0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    -- ─── شريط التابات (Tabs Bar) ──────────────────────────────
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Parent = Main
    TabBar.BackgroundColor3 = COLORS.TabBar
    TabBar.Position = UDim2.new(0, 0, 0, 38)
    TabBar.Size = UDim2.new(0, 130, 1, -38)
    TabBar.ZIndex = 4
    AddCorner(TabBar, 10)

    local TabBarFix = Instance.new("Frame")
    TabBarFix.Parent = TabBar
    TabBarFix.BackgroundColor3 = COLORS.TabBar
    TabBarFix.BorderSizePixel = 0
    TabBarFix.Position = UDim2.new(0, 0, 0, 0)
    TabBarFix.Size = UDim2.new(0, 10, 1, 0)
    TabBarFix.ZIndex = 4

    local TabBarFix2 = Instance.new("Frame")
    TabBarFix2.Parent = TabBar
    TabBarFix2.BackgroundColor3 = COLORS.TabBar
    TabBarFix2.BorderSizePixel = 0
    TabBarFix2.Position = UDim2.new(1, -10, 0, 0)
    TabBarFix2.Size = UDim2.new(0, 10, 0, 18)
    TabBarFix2.ZIndex = 4

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabBar
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 6)

    local TabPad = Instance.new("UIPadding")
    TabPad.Parent = TabBar
    TabPad.PaddingTop    = UDim.new(0, 12)
    TabPad.PaddingLeft   = UDim.new(0, 8)
    TabPad.PaddingRight  = UDim.new(0, 8)
    TabPad.PaddingBottom = UDim.new(0, 8)

    -- ─── منطقة المحتوى ────────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = Main
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 138, 0, 42)
    ContentArea.Size = UDim2.new(1, -142, 1, -46)
    ContentArea.ZIndex = 3
    ContentArea.ClipsDescendants = true

    -- ─── خط فاصل عمودي ───────────────────────────────────────
    local Divider = Instance.new("Frame")
    Divider.Parent = Main
    Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Divider.Position = UDim2.new(0, 133, 0, 42)
    Divider.Size = UDim2.new(0, 1, 1, -46)
    Divider.ZIndex = 5

    -- ─── نظام التابات ─────────────────────────────────────────
    local allTabs = {}
    local activeTab = nil

    function Window:CreateTab(tabName, tabIcon)
        local Tab = {}

        -- زر التاب
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. tabName
        TabBtn.Parent = TabBar
        TabBtn.BackgroundColor3 = COLORS.TabInactive
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.ZIndex = 5
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.Text = (tabIcon and tabIcon .. "  " or "") .. tabName
        TabBtn.TextColor3 = COLORS.SubText
        TabBtn.TextSize = 13
        AddCorner(TabBtn, 7)

        -- مؤشر التاب النشط
        local ActiveIndicator = Instance.new("Frame")
        ActiveIndicator.Parent = TabBtn
        ActiveIndicator.BackgroundColor3 = COLORS.Accent
        ActiveIndicator.Position = UDim2.new(0, 0, 0.15, 0)
        ActiveIndicator.Size = UDim2.new(0, 3, 0.7, 0)
        ActiveIndicator.Visible = false
        ActiveIndicator.ZIndex = 6
        AddCorner(ActiveIndicator, 3)

        -- محتوى التاب
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "Content_" .. tabName
        TabContent.Parent = ContentArea
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = COLORS.Accent
        TabContent.Visible = false
        TabContent.ZIndex = 3
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local ContentList = Instance.new("UIListLayout")
        ContentList.Parent = TabContent
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 8)

        local ContentPad = Instance.new("UIPadding")
        ContentPad.Parent = TabContent
        ContentPad.PaddingTop    = UDim.new(0, 8)
        ContentPad.PaddingLeft   = UDim.new(0, 6)
        ContentPad.PaddingRight  = UDim.new(0, 6)
        ContentPad.PaddingBottom = UDim.new(0, 8)

        local function ActivateTab()
            -- إخفاء كل التابات
            for _, t in pairs(allTabs) do
                t.Content.Visible = false
                Tween(t.Btn, {BackgroundColor3 = COLORS.TabInactive, TextColor3 = COLORS.SubText}, 0.2)
                t.Indicator.Visible = false
            end
            -- تفعيل هذا التاب
            TabContent.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(40, 50, 80), TextColor3 = COLORS.Text}, 0.2)
            ActiveIndicator.Visible = true
            activeTab = tabName
        end

        table.insert(allTabs, {Btn = TabBtn, Content = TabContent, Indicator = ActiveIndicator})

        TabBtn.MouseButton1Click:Connect(ActivateTab)
        TabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                Tween(TabBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                Tween(TabBtn, {BackgroundColor3 = COLORS.TabInactive}, 0.15)
            end
        end)

        -- تفعيل أول تاب تلقائياً
        if #allTabs == 1 then
            ActivateTab()
        end

        -- ─── زر عادي ──────────────────────────────────────────
        function Tab:CreateButton(text, desc, callback)
            callback = callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Parent = TabContent
            Btn.BackgroundColor3 = COLORS.Element
            Btn.Size = UDim2.new(1, 0, 0, 38)
            Btn.ZIndex = 4
            Btn.Font = Enum.Font.GothamSemibold
            Btn.Text = ""
            AddCorner(Btn, 8)

            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Parent = Btn
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Position = UDim2.new(0, 12, 0, 0)
            BtnLabel.Size = UDim2.new(1, -60, 0.6, 0)
            BtnLabel.ZIndex = 5
            BtnLabel.Font = Enum.Font.GothamSemibold
            BtnLabel.Text = text
            BtnLabel.TextColor3 = COLORS.Text
            BtnLabel.TextSize = 13
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left

            if desc then
                local DescLabel = Instance.new("TextLabel")
                DescLabel.Parent = Btn
                DescLabel.BackgroundTransparency = 1
                DescLabel.Position = UDim2.new(0, 12, 0.55, 0)
                DescLabel.Size = UDim2.new(1, -60, 0.45, 0)
                DescLabel.ZIndex = 5
                DescLabel.Font = Enum.Font.Gotham
                DescLabel.Text = desc
                DescLabel.TextColor3 = COLORS.SubText
                DescLabel.TextSize = 11
                DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            end

            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = Btn
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.Size = UDim2.new(0, 24, 1, 0)
            Arrow.ZIndex = 5
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "›"
            Arrow.TextColor3 = COLORS.Accent
            Arrow.TextSize = 20

            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = COLORS.Element}, 0.15)
            end)
            Btn.MouseButton1Down:Connect(function()
                Tween(Btn, {Size = UDim2.new(0.98, 0, 0, 36)}, 0.1)
            end)
            Btn.MouseButton1Up:Connect(function()
                Tween(Btn, {Size = UDim2.new(1, 0, 0, 38)}, 0.15)
                callback()
            end)
        end

        -- ─── Toggle ────────────────────────────────────────────
        function Tab:CreateToggle(text, desc, default, callback)
            callback = callback or function() end
            local state = default or false

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Parent = TabContent
            ToggleFrame.BackgroundColor3 = COLORS.Element
            ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
            ToggleFrame.ZIndex = 4
            AddCorner(ToggleFrame, 8)

            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.Size = UDim2.new(1, -70, 0.6, 0)
            Label.ZIndex = 5
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = text
            Label.TextColor3 = COLORS.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            if desc then
                local D = Instance.new("TextLabel")
                D.Parent = ToggleFrame
                D.BackgroundTransparency = 1
                D.Position = UDim2.new(0, 12, 0.55, 0)
                D.Size = UDim2.new(1, -70, 0.45, 0)
                D.ZIndex = 5
                D.Font = Enum.Font.Gotham
                D.Text = desc
                D.TextColor3 = COLORS.SubText
                D.TextSize = 11
                D.TextXAlignment = Enum.TextXAlignment.Left
            end

            local Track = Instance.new("Frame")
            Track.Parent = ToggleFrame
            Track.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
            Track.Position = UDim2.new(1, -52, 0.5, -10)
            Track.Size = UDim2.new(0, 42, 0, 20)
            Track.ZIndex = 5
            AddCorner(Track, 10)

            local Knob = Instance.new("Frame")
            Knob.Parent = Track
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.ZIndex = 6
            AddCorner(Knob, 10)

            local ClickArea = Instance.new("TextButton")
            ClickArea.Parent = ToggleFrame
            ClickArea.BackgroundTransparency = 1
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.ZIndex = 7
            ClickArea.Text = ""

            ClickArea.MouseButton1Click:Connect(function()
                state = not state
                if state then
                    Tween(Track, {BackgroundColor3 = COLORS.ToggleOn}, 0.2)
                    Tween(Knob, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                else
                    Tween(Track, {BackgroundColor3 = COLORS.ToggleOff}, 0.2)
                    Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
                callback(state)
            end)
        end

        -- ─── Slider ────────────────────────────────────────────
        function Tab:CreateSlider(text, desc, min, max, default, callback)
            callback = callback or function() end
            min = min or 0; max = max or 100
            local value = default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = TabContent
            SliderFrame.BackgroundColor3 = COLORS.Element
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.ZIndex = 4
            AddCorner(SliderFrame, 8)

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.Size = UDim2.new(0.7, 0, 0, 18)
            Label.ZIndex = 5
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = text
            Label.TextColor3 = COLORS.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(1, -50, 0, 4)
            ValueLabel.Size = UDim2.new(0, 44, 0, 18)
            ValueLabel.ZIndex = 5
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(value)
            ValueLabel.TextColor3 = COLORS.Accent
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local SliderBg = Instance.new("Frame")
            SliderBg.Parent = SliderFrame
            SliderBg.BackgroundColor3 = COLORS.SliderBg
            SliderBg.Position = UDim2.new(0, 12, 0, 30)
            SliderBg.Size = UDim2.new(1, -24, 0, 8)
            SliderBg.ZIndex = 5
            AddCorner(SliderBg, 4)

            local Fill = Instance.new("Frame")
            Fill.Parent = SliderBg
            Fill.BackgroundColor3 = COLORS.SliderFill
            Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
            Fill.ZIndex = 6
            AddCorner(Fill, 4)

            local Knob = Instance.new("Frame")
            Knob.Parent = SliderBg
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0)
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.ZIndex = 7
            AddCorner(Knob, 10)
            AddStroke(Knob, COLORS.Accent, 2)

            local draggingSlider = false
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X
                    rel = math.clamp(rel, 0, 1)
                    value = math.floor(min + (max - min) * rel)
                    Fill.Size = UDim2.new(rel, 0, 1, 0)
                    Knob.Position = UDim2.new(rel, 0, 0.5, 0)
                    ValueLabel.Text = tostring(value)
                    callback(value)
                end
            end)
        end

        -- ─── Label / Section Header ────────────────────────────
        function Tab:CreateLabel(text)
            local Lbl = Instance.new("TextLabel")
            Lbl.Parent = TabContent
            Lbl.BackgroundTransparency = 1
            Lbl.Size = UDim2.new(1, 0, 0, 22)
            Lbl.ZIndex = 4
            Lbl.Font = Enum.Font.GothamBold
            Lbl.Text = "  " .. text
            Lbl.TextColor3 = COLORS.Accent
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
        end

        -- ─── مربع متحرك (Animated Card) ───────────────────────
        function Tab:CreateAnimatedCard(title, value, colorIndex)
            local col = COLORS.CardColors[colorIndex or 1]

            local Card = Instance.new("Frame")
            Card.Parent = TabContent
            Card.BackgroundColor3 = col
            Card.Size = UDim2.new(1, 0, 0, 60)
            Card.ZIndex = 4
            Card.ClipsDescendants = true
            AddCorner(Card, 10)

            -- تأثير shimmer
            local Shimmer = Instance.new("Frame")
            Shimmer.Parent = Card
            Shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Shimmer.BackgroundTransparency = 0.85
            Shimmer.Position = UDim2.new(-0.5, 0, 0, 0)
            Shimmer.Size = UDim2.new(0.3, 0, 1, 0)
            Shimmer.Rotation = 15
            Shimmer.ZIndex = 5

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Parent = Card
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Position = UDim2.new(0, 14, 0, 8)
            TitleLbl.Size = UDim2.new(1, -14, 0, 20)
            TitleLbl.ZIndex = 6
            TitleLbl.Font = Enum.Font.GothamBold
            TitleLbl.Text = title
            TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLbl.TextSize = 15
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLbl = Instance.new("TextLabel")
            ValueLbl.Parent = Card
            ValueLbl.BackgroundTransparency = 1
            ValueLbl.Position = UDim2.new(0, 14, 0, 30)
            ValueLbl.Size = UDim2.new(1, -14, 0, 20)
            ValueLbl.ZIndex = 6
            ValueLbl.Font = Enum.Font.Gotham
            ValueLbl.Text = value or ""
            ValueLbl.TextColor3 = Color3.fromRGB(220, 220, 255)
            ValueLbl.TextSize = 12
            ValueLbl.TextXAlignment = Enum.TextXAlignment.Left

            -- تأثير shimmer متكرر
            spawn(function()
                while Card and Card.Parent do
                    Tween(Shimmer, {Position = UDim2.new(1.2, 0, 0, 0)}, 1.2, Enum.EasingStyle.Linear)
                    wait(1.2)
                    Shimmer.Position = UDim2.new(-0.5, 0, 0, 0)
                    wait(2)
                end
            end)

            -- نبضة لون خفيفة
            local darkerCol = Color3.fromRGB(
                math.max(col.R * 255 - 20, 0),
                math.max(col.G * 255 - 20, 0),
                math.max(col.B * 255 - 20, 0)
            )
            PulseEffect(Card, col, darkerCol)

            local CardObj = {}
            function CardObj:SetValue(v)
                ValueLbl.Text = v
            end
            return CardObj
        end

        -- ─── حقل نص (TextBox) ─────────────────────────────────
        function Tab:CreateTextBox(placeholder, callback)
            callback = callback or function() end

            local BoxFrame = Instance.new("Frame")
            BoxFrame.Parent = TabContent
            BoxFrame.BackgroundColor3 = COLORS.Element
            BoxFrame.Size = UDim2.new(1, 0, 0, 38)
            BoxFrame.ZIndex = 4
            AddCorner(BoxFrame, 8)

            local Box = Instance.new("TextBox")
            Box.Parent = BoxFrame
            Box.BackgroundTransparency = 1
            Box.Position = UDim2.new(0, 12, 0, 0)
            Box.Size = UDim2.new(1, -24, 1, 0)
            Box.ZIndex = 5
            Box.Font = Enum.Font.Gotham
            Box.PlaceholderText = placeholder or "اكتب هنا..."
            Box.PlaceholderColor3 = COLORS.SubText
            Box.Text = ""
            Box.TextColor3 = COLORS.Text
            Box.TextSize = 13
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.ClearTextOnFocus = false

            Box.FocusLost:Connect(function(enter)
                if enter then callback(Box.Text) end
            end)

            Box.Focused:Connect(function()
                Tween(BoxFrame, {BackgroundColor3 = COLORS.ElementHover}, 0.15)
                AddStroke(BoxFrame, COLORS.Accent, 1.5)
            end)
            Box.FocusLost:Connect(function()
                Tween(BoxFrame, {BackgroundColor3 = COLORS.Element}, 0.15)
                local s = BoxFrame:FindFirstChildOfClass("UIStroke")
                if s then s:Destroy() end
            end)
        end

        -- ─── Separator ─────────────────────────────────────────
        function Tab:CreateSeparator()
            local Sep = Instance.new("Frame")
            Sep.Parent = TabContent
            Sep.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            Sep.Size = UDim2.new(1, 0, 0, 1)
            Sep.ZIndex = 4
        end

        return Tab
    end

    -- ═══════════════════════════════════════════
    --  ضبط الدنيا (World / Lighting Settings)
    -- ═══════════════════════════════════════════
    function Window:SetWorldLighting(options)
        options = options or {}
        if options.TimeOfDay      then Lighting.TimeOfDay      = options.TimeOfDay      end
        if options.Brightness     then Lighting.Brightness     = options.Brightness     end
        if options.Ambient        then Lighting.Ambient        = options.Ambient        end
        if options.OutdoorAmbient then Lighting.OutdoorAmbient = options.OutdoorAmbient end
        if options.FogEnd         then Lighting.FogEnd         = options.FogEnd         end
        if options.FogStart       then Lighting.FogStart       = options.FogStart       end
        if options.FogColor       then Lighting.FogColor       = options.FogColor       end
        if options.ClockTime      then Lighting.ClockTime      = options.ClockTime      end
        if options.GeographicLatitude then Lighting.GeographicLatitude = options.GeographicLatitude end
        if options.ShadowSoftness then Lighting.ShadowSoftness = options.ShadowSoftness end
        if options.ExposureCompensation then Lighting.ExposureCompensation = options.ExposureCompensation end
    end

    -- تأثير Tween لضبط الدنيا تدريجياً
    function Window:TweenWorldLighting(options, duration)
        duration = duration or 2
        options = options or {}
        local props = {}
        if options.Brightness     then props.Brightness     = options.Brightness     end
        if options.Ambient        then props.Ambient        = options.Ambient        end
        if options.OutdoorAmbient then props.OutdoorAmbient = options.OutdoorAmbient end
        if options.FogEnd         then props.FogEnd         = options.FogEnd         end
        if options.FogColor       then props.FogColor       = options.FogColor       end
        if options.ClockTime      then props.ClockTime      = options.ClockTime      end
        if options.ExposureCompensation then props.ExposureCompensation = options.ExposureCompensation end
        Tween(Lighting, props, duration, Enum.EasingStyle.Sine)
    end

    -- ═══════════════════════════════════════════
    --  تدمير الواجهة
    -- ═══════════════════════════════════════════
    function Window:Destroy()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.35)
        wait(0.4)
        ScreenGui:Destroy()
    end

    -- ═══════════════════════════════════════════
    --  تغيير صورة الخلفية
    -- ═══════════════════════════════════════════
    function Window:SetBackground(imageId, transparency)
        BgImage.Image = imageId or ""
        BgImage.ImageTransparency = transparency or 0.6
    end

    return Window
end

return Library

--[[
    ╔══════════════════════════════════════════════════════════╗
    ║           Nova UI Library - مثال الاستخدام              ║
    ║     ضع هذا الكود في LocalScript داخل StarterPlayerScripts ║
    ╚══════════════════════════════════════════════════════════╝
]]

-- استدعاء المكتبة (ضع المكتبة في ModuleScript باسم NovaUI)
local NovaUI = require(game.ReplicatedStorage.NovaUI)

-- ═══════════════════════════════════════════
--  إنشاء النافذة الرئيسية
-- ═══════════════════════════════════════════
local Window = NovaUI:CreateWindow({
    Title           = "Nova Menu",          -- عنوان النافذة
    SubTitle        = "v2.0",               -- عنوان فرعي
    BackgroundImage = "rbxassetid://XXXXXXX", -- ضع ID الصورة هنا
    ImageTransparency = 0.5,                -- شفافية الصورة (0 = واضحة, 1 = مخفية)
    IntroEnabled    = true,                 -- تفعيل دخولية الواجهة
    Size            = UDim2.new(0, 560, 0, 340),
    Position        = UDim2.new(0.5, -280, 0.5, -170),
})

-- ═══════════════════════════════════════════
--  ضبط الدنيا (World Settings)
-- ═══════════════════════════════════════════
Window:TweenWorldLighting({
    ClockTime      = 14,                                -- الساعة 2 ظهراً
    Brightness     = 2,
    Ambient        = Color3.fromRGB(70, 70, 100),
    OutdoorAmbient = Color3.fromRGB(100, 100, 140),
    FogEnd         = 1000,
    FogColor       = Color3.fromRGB(180, 180, 220),
}, 3) -- مدة التأثير 3 ثواني

-- ═══════════════════════════════════════════
--  تاب الرئيسية
-- ═══════════════════════════════════════════
local HomeTab = Window:CreateTab("الرئيسية", "🏠")

HomeTab:CreateLabel("معلومات اللاعب")

HomeTab:CreateAnimatedCard("مرحباً!", "أهلاً بك في Nova UI", 1)
HomeTab:CreateAnimatedCard("الإصدار", "Nova UI v2.0 - Roblox", 2)

HomeTab:CreateSeparator()
HomeTab:CreateLabel("الإجراءات السريعة")

HomeTab:CreateButton("إعادة التشغيل", "أعد تشغيل الشخصية", function()
    game:GetService("Players").LocalPlayer.Character:BreakJoints()
end)

HomeTab:CreateButton("الإضاءة الليلية", "تغيير الوقت إلى الليل", function()
    Window:TweenWorldLighting({ClockTime = 0, Brightness = 0.5}, 2)
end)

HomeTab:CreateButton("الإضاءة النهارية", "تغيير الوقت إلى النهار", function()
    Window:TweenWorldLighting({ClockTime = 14, Brightness = 2}, 2)
end)

-- ═══════════════════════════════════════════
--  تاب الإعدادات
-- ═══════════════════════════════════════════
local SettingsTab = Window:CreateTab("الإعدادات", "⚙️")

SettingsTab:CreateLabel("إعدادات اللعبة")

SettingsTab:CreateToggle("الطيران", "تفعيل أو إيقاف الطيران", false, function(state)
    if state then
        -- كود الطيران هنا
        print("الطيران: مفعّل")
    else
        print("الطيران: موقوف")
    end
end)

SettingsTab:CreateToggle("السرعة الفائقة", "تضاعف سرعة الشخصية", false, function(state)
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        char.Humanoid.WalkSpeed = state and 50 or 16
    end
end)

SettingsTab:CreateToggle("القفز العالي", "زيادة ارتفاع القفز", false, function(state)
    local char = game:GetService("Players").LocalPlayer.Character
    if char then
        char.Humanoid.JumpPower = state and 100 or 50
    end
end)

SettingsTab:CreateSeparator()
SettingsTab:CreateLabel("ضبط الدنيا")

SettingsTab:CreateSlider("سطوع الإضاءة", "اضبط سطوع العالم", 0, 5, 2, function(value)
    Window:SetWorldLighting({Brightness = value})
end)

SettingsTab:CreateSlider("وقت اليوم", "اضبط ساعة اليوم", 0, 24, 14, function(value)
    Window:SetWorldLighting({ClockTime = value})
end)

SettingsTab:CreateSlider("الضباب", "اضبط مسافة الضباب", 100, 5000, 1000, function(value)
    Window:SetWorldLighting({FogEnd = value})
end)

-- ═══════════════════════════════════════════
--  تاب المشغّل
-- ═══════════════════════════════════════════
local PlayerTab = Window:CreateTab("المشغّل", "👤")

PlayerTab:CreateLabel("تخصيص المشغّل")

PlayerTab:CreateTextBox("اكتب اسم اللاعب...", function(text)
    print("اسم اللاعب:", text)
end)

PlayerTab:CreateSeparator()
PlayerTab:CreateLabel("بطاقات الإحصائيات")

local ScoreCard = PlayerTab:CreateAnimatedCard("النقاط", "0", 3)
local KillsCard = PlayerTab:CreateAnimatedCard("الإزالات", "0", 4)

-- تحديث بطاقات الإحصائيات كل ثانية
spawn(function()
    local score = 0
    local kills = 0
    while wait(1) do
        score = score + math.random(1, 10)
        kills = kills + math.random(0, 1)
        ScoreCard:SetValue(tostring(score) .. " نقطة")
        KillsCard:SetValue(tostring(kills) .. " إزالة")
    end
end)

-- ═══════════════════════════════════════════
--  تاب الخلفية
-- ═══════════════════════════════════════════
local BgTab = Window:CreateTab("الخلفية", "🖼️")

BgTab:CreateLabel("تغيير خلفية الواجهة")

BgTab:CreateButton("خلفية فضائية", "تعيين خلفية الفضاء", function()
    Window:SetBackground("rbxassetid://1234567890", 0.4)
end)

BgTab:CreateButton("خلفية طبيعة", "تعيين خلفية الطبيعة", function()
    Window:SetBackground("rbxassetid://0987654321", 0.4)
end)

BgTab:CreateButton("إزالة الخلفية", "إزالة صورة الخلفية", function()
    Window:SetBackground("", 1)
end)

BgTab:CreateSlider("شفافية الخلفية", "اضبط شفافية الصورة", 0, 10, 5, function(value)
    Window:SetBackground(nil, value / 10)
end)
