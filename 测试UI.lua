local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local Registry = {} 
local ConfigObjects = {} 

-- SFX
local Sounds = {
    Hover = "rbxassetid://4510086912",
    Click = "rbxassetid://4510086561",
    ToggleOn = "rbxassetid://4510087425",
    ToggleOff = "rbxassetid://4510087425",
    Slide = "rbxassetid://4510087798",
    Notification = "rbxassetid://4590657391",
    Back = "rbxassetid://4510087236",
    Error = "rbxassetid://4510087545",
    Tab = "rbxassetid://4510087056" 
}

-- 图片资源（取自 maclib）
local ToggleAssets = {
    Bg = "rbxassetid://18772190202",   -- 开关背景
    Head = "rbxassetid://18772309008"  -- 滑块头
}
local SliderAssets = {
    Bar = "rbxassetid://18772615246",   -- 滑块条背景
    Head = "rbxassetid://18772834246"   -- 滑块头
}
-- 颜色选择器资源
local ColorPickerAssets = {
    ColorWheel = "rbxassetid://2849458409",
    ColorTarget = "rbxassetid://73265255323268",
    Grid = "rbxassetid://121484455191370",
    SliderBar = SliderAssets.Bar,
    SliderHead = SliderAssets.Head,
}

local function PlaySound(id)
    if not SFXEnabled then return end
    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 1
        s.Parent = SoundService
        s:Play()
        game.Debris:AddItem(s, 2)
    end)
end

-- THEMES
local Themes = {
    Dark   = {Main = Color3.fromRGB(25, 25, 25), Top = Color3.fromRGB(35, 35, 35), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(114, 137, 218), Stroke = Color3.fromRGB(60, 60, 60)},
    White  = {Main = Color3.fromRGB(240, 240, 240), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(0, 120, 215), Stroke = Color3.fromRGB(200, 200, 200)},
    Purple = {Main = Color3.fromRGB(30, 25, 35), Top = Color3.fromRGB(40, 30, 45), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(170, 0, 255), Stroke = Color3.fromRGB(80, 40, 80)},
    Blue   = {Main = Color3.fromRGB(20, 25, 40), Top = Color3.fromRGB(30, 35, 50), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 100, 255), Stroke = Color3.fromRGB(40, 50, 80)},
    Red    = {Main = Color3.fromRGB(35, 20, 20), Top = Color3.fromRGB(45, 25, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 50, 50), Stroke = Color3.fromRGB(80, 40, 40)},
    Yellow = {Main = Color3.fromRGB(35, 35, 20), Top = Color3.fromRGB(45, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 200, 50), Stroke = Color3.fromRGB(80, 80, 40)},
    Green  = {Main = Color3.fromRGB(20, 35, 20), Top = Color3.fromRGB(25, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 200, 100), Stroke = Color3.fromRGB(40, 80, 40)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeIndex)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeIndex})
    obj[prop] = CurrentTheme[themeIndex]
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, reg in pairs(Registry) do
            if reg.Object then
                Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]})
            end
        end
    end
end

-- RAINBOW
function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end

-- SFX CONTROL (public method)
function Library:SetSFXEnabled(state)
    SFXEnabled = state
end

function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "M0dzn UI"
    local Keybind = Config.Keybind 
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib_V1.2"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0) 
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Stroke")

    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    Gradient.Enabled = false

    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick()
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Gradient.Enabled = true; Gradient.Rotation = 0
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Animated/Cycling Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Gradient.Enabled = true; rot = rot + 2; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Step/Band Rainbow" then
                    Gradient.Enabled = false; local step = math.floor((t % 2) * 4) / 4; Stroke.Color = Color3.fromHSV(step, 1, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    Gradient.Enabled = false; local pulse = (math.sin(t * 3) + 1) / 2; Stroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
                elseif RainbowType == "Radial Rainbow" then
                    Gradient.Enabled = true; rot = rot + 5; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.8, 1) 
                elseif RainbowType == "Pastel Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.4, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                    Gradient.Enabled = true; Gradient.Rotation = 90; local c = Color3.fromHSV(t % 5/5, 1, 1); local c2 = Color3.fromHSV((t+1) % 5/5, 1, 1); Gradient.Color = ColorSequence.new(c, c2); Stroke.Color = Color3.new(1,1,1)
                end
            else
                Gradient.Enabled = false
                Stroke.Color = CurrentTheme.Stroke
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.Parent = MainFrame
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)
    AddToRegistry(Topbar, "BackgroundColor3", "Top")

    local Fix = Instance.new("Frame")
    Fix.Size = UDim2.new(1, 0, 0, 10)
    Fix.Position = UDim2.new(0, 0, 1, -10)
    Fix.BorderSizePixel = 0
    Fix.Parent = Topbar
    AddToRegistry(Fix, "BackgroundColor3", "Top")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -55)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 0.85, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 140, 0, 35)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -35)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Content
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 30, 0, 30)
    Avatar.Position = UDim2.new(0, 0, 0.5, -15)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
    
    local DispName = Instance.new("TextLabel"); DispName.Text = LocalPlayer.DisplayName; DispName.Size = UDim2.new(1, -35, 0, 15); DispName.Position = UDim2.new(0, 35, 0, 2); DispName.BackgroundTransparency = 1; DispName.Font = Enum.Font.GothamBold; DispName.TextSize = 12; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.Parent = ProfileFrame; AddToRegistry(DispName, "TextColor3", "Text")
    local UsrName = Instance.new("TextLabel"); UsrName.Text = "@"..LocalPlayer.Name; UsrName.Size = UDim2.new(1, -35, 0, 15); UsrName.Position = UDim2.new(0, 35, 0, 16); UsrName.BackgroundTransparency = 1; UsrName.Font = Enum.Font.Gotham; UsrName.TextSize = 11; UsrName.TextTransparency = 0.4; UsrName.TextXAlignment = Enum.TextXAlignment.Left; UsrName.Parent = ProfileFrame; AddToRegistry(UsrName, "TextColor3", "Text")

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 1, 1, 0)
    Line.Position = UDim2.new(0, 145, 0, 0)
    Line.Parent = Content
    AddToRegistry(Line, "BackgroundColor3", "Stroke")

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -155, 1, 0)
    PageContainer.Position = UDim2.new(0, 155, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    -- 窗口展开动画（尺寸 450×280）
    Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.6)

    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.2)
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
            if MainFrame.Visible then 
                MainFrame.Size = UDim2.new(0,0,0,0)
                Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.4)
            end
        end
    end)

    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame"); Notif.ZIndex = 100; Notif.Size = UDim2.new(0, 250, 0, 45); Notif.Position = UDim2.new(1, 20, 1, -60); Notif.Parent = ScreenGui; AddToRegistry(Notif, "BackgroundColor3", "Top"); Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
            local NStroke = Instance.new("UIStroke"); NStroke.Parent = Notif; AddToRegistry(NStroke, "Color", "Accent")
            local NText = Instance.new("TextLabel"); NText.ZIndex = 101; NText.Text = text; NText.Size = UDim2.new(1,0,1,0); NText.BackgroundTransparency = 1; NText.Parent = Notif; NText.Font = Enum.Font.GothamBold; NText.TextSize = 14; AddToRegistry(NText, "TextColor3", "Text")
            Tween(Notif, {Position = UDim2.new(1, -270, 1, -60)}, 0.5); task.wait(3); Tween(Notif, {Position = UDim2.new(1, 20, 1, -60)}, 0.5); task.wait(0.5); Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end

    local firstTab = true
    -- Tab 函数，图标与文字整体居中
    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        -- 容器，填满按钮，用于居中内容
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn

        -- 水平布局，整体居中
        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame

        -- 图标（如果提供）
        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 20, 0, 20)
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then
                TabIcon.Image = "rbxassetid://" .. icon
            else
                TabIcon.Image = icon
            end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
        end

        -- 文字标签，宽度根据文本内容自动计算
        local TabText = Instance.new("TextLabel")
        local textWidth = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(200, 32)).X
        TabText.Size = UDim2.new(0, textWidth, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = ContentFrame
        AddToRegistry(TabText, "TextColor3", "Text")

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 10) end)

        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab) 
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then 
                Tween(v, {BackgroundTransparency = 1})
                local content = v:FindFirstChild("ContentFrame")
                if content then
                    local textLabel = content:FindFirstChildOfClass("TextLabel")
                    if textLabel then
                        Tween(textLabel, {TextColor3 = Color3.fromRGB(150,150,150)})
                    end
                end
            end end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
        end)

        if firstTab then 
            firstTab = false
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
        end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local Elements = {}

        -- Section：可折叠容器，支持自定义图标，保留展开/收缩动画
        function Elements:Section(text, icons, defaultOpen)
            -- 默认展开状态（如果没有提供，默认展开）
            if defaultOpen == nil then defaultOpen = true end

            -- 辅助函数：将数字/字符串转换为完整 asset url
            local function formatAssetId(id)
                if type(id) == "number" then
                    return "rbxassetid://" .. tostring(id)
                elseif type(id) == "string" then
                    if tonumber(id) then
                        return "rbxassetid://" .. id
                    else
                        return id
                    end
                else
                    return nil
                end
            end

            -- 处理图标
            local iconOpen, iconClosed
            if type(icons) == "table" then
                iconOpen = formatAssetId(icons.Y or icons.open) or "rbxassetid://6031091004"
                iconClosed = formatAssetId(icons.F or icons.closed) or iconOpen
            else
                local defaultIcon = formatAssetId(icons) or "rbxassetid://6031091004"
                iconOpen = defaultIcon
                iconClosed = defaultIcon
            end

            -- Section 主框架
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 36)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = Page
            sectionFrame.ClipsDescendants = true

            -- 标题栏
            local titleBar = Instance.new("Frame")
            titleBar.Size = UDim2.new(1, 0, 0, 36)
            titleBar.BackgroundTransparency = 1
            titleBar.Parent = sectionFrame

            -- 图标
            local iconLabel = Instance.new("ImageLabel")
            iconLabel.Size = UDim2.new(0, 24, 0, 24)
            iconLabel.Position = UDim2.new(0, 5, 0.5, -12)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = defaultOpen and iconOpen or iconClosed
            iconLabel.Parent = titleBar

            -- 文字标签
            local textLabel = Instance.new("TextLabel")
            textLabel.Text = text
            textLabel.Size = UDim2.new(1, -34, 1, 0)
            textLabel.Position = UDim2.new(0, 34, 0, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextSize = 20
            textLabel.TextXAlignment = Enum.TextXAlignment.Left
            textLabel.Parent = titleBar
            AddToRegistry(textLabel, "TextColor3", "Accent")

            -- 点击按钮
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.Parent = titleBar

            -- 内容容器
            local contentContainer = Instance.new("Frame")
            contentContainer.Size = UDim2.new(1, 0, 0, 0)
            contentContainer.Position = UDim2.new(0, 0, 0, 36)
            contentContainer.BackgroundTransparency = 1
            contentContainer.ClipsDescendants = true
            contentContainer.Parent = sectionFrame

            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 6)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Parent = contentContainer

            -- 存储动画
            local currentContentTween, currentSectionTween
            local open = defaultOpen

            -- 更新 Section 高度的函数（可手动调用）
            local function updateSectionHeight(instant)
                local targetContentHeight = open and contentLayout.AbsoluteContentSize.Y or 0
                local targetSectionHeight = 36 + targetContentHeight
                if currentContentTween then currentContentTween:Cancel() end
                if currentSectionTween then currentSectionTween:Cancel() end
                local tweenInfo = TweenInfo.new(instant and 0 or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                currentContentTween = TweenService:Create(contentContainer, tweenInfo, {Size = UDim2.new(1, 0, 0, targetContentHeight)})
                currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, targetSectionHeight)})
                currentContentTween:Play()
                currentSectionTween:Play()
            end

            -- 初始化高度
            task.spawn(function()
                task.wait()
                updateSectionHeight(true)
            end)

            local function toggle()
                open = not open
                iconLabel.Image = open and iconOpen or iconClosed
                updateSectionHeight(false)
            end

            toggleBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                toggle()
            end)

            -- 监听内容变化（备用，确保高度自动适应）
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight(false)
                end
            end)

            -- 子元素表
            local child = {}

            -- Button (maclib 风格)
            child.Button = function(_, btnText, callback)
                -- 主按钮（TextButton 作为容器，背景色主题化）
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.Text = ""  -- 文本由内部 Label 控制
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

                -- 文本标签（左对齐）
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.new(1, -30, 1, 0)  -- 留出右侧图标空间
                TextLabel.Position = UDim2.new(0, 10, 0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Font = Enum.Font.Gotham
                TextLabel.Text = btnText
                TextLabel.TextSize = 14
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.Parent = Btn
                AddToRegistry(TextLabel, "TextColor3", "Text")

                -- 图标（右箭头，取自 maclib）
                local Icon = Instance.new("ImageLabel")
                Icon.Size = UDim2.new(0, 15, 0, 15)
                Icon.Position = UDim2.new(1, -20, 0.5, -7.5)
                Icon.BackgroundTransparency = 1
                Icon.Image = "rbxassetid://10709791437"  -- maclib 箭头 asset
                Icon.ImageTransparency = 0.5  -- 初始半透明
                Icon.Parent = Btn
                AddToRegistry(Icon, "ImageColor3", "Text")  -- 图标颜色跟随文本主题

                -- 悬停效果：图标透明度变化
                local function onHover()
                    Tween(Icon, {ImageTransparency = 0}, 0.2)
                end
                local function onLeave()
                    Tween(Icon, {ImageTransparency = 0.5}, 0.2)
                end

                Btn.MouseEnter:Connect(onHover)
                Btn.MouseLeave:Connect(onLeave)

                -- 点击事件（保留原缩放动画和声音）
                Btn.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    Tween(Btn, {Size = UDim2.new(0.95, 0, 0, 32)}, 0.1)
                    task.wait(0.1)
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                    callback()
                end)

                -- 返回控制方法（可选）
                local self = {}
                function self.UpdateText(newText)
                    TextLabel.Text = newText
                end
                function self.SetVisible(state)
                    Btn.Visible = state
                end
                return self
            end

            -- Toggle (maclib 风格，禁用时靠左，启用时靠右且左移8像素)
            child.Toggle = function(_, toggleText, default, callback)
                local Enabled = default or false

                -- 主按钮（背景容器）
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

                -- 文本标签
                local Title = Instance.new("TextLabel")
                Title.Text = toggleText
                Title.Size = UDim2.new(0.7, 0, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Btn
                AddToRegistry(Title, "TextColor3", "Text")

                -- 开关背景 (ImageLabel，非交互)
                local Switch = Instance.new("ImageLabel")
                Switch.Size = UDim2.new(0, 40, 0, 20)
                Switch.Position = UDim2.new(1, -50, 0.5, -10)
                Switch.BackgroundTransparency = 1
                Switch.Image = ToggleAssets.Bg
                Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
                Switch.Parent = Btn

                -- 滑块头 (ImageLabel)
                local Dot = Instance.new("ImageLabel")
                Dot.Size = UDim2.new(0, 16, 0, 16)
                Dot.BackgroundTransparency = 1
                Dot.Image = ToggleAssets.Head
                Dot.ImageColor3 = Color3.new(1, 1, 1)
                Dot.AnchorPoint = Vector2.new(0.5, 0.5)
                Dot.Parent = Switch
                -- 位置：启用时靠右且左移8像素 (1, -8)，禁用时靠左 (0, 8)
                Dot.Position = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)

                -- 更新状态函数
                local function Update()
                    if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end

                    -- 开关背景颜色
                    local targetColor = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
                    Tween(Switch, {ImageColor3 = targetColor}, 0.2)

                    -- 滑块头位置
                    local targetPos = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
                    Tween(Dot, {Position = targetPos}, 0.2)

                    -- 更新配置和回调
                    ConfigObjects[toggleText].Value = Enabled
                    callback(Enabled)
                    Window:Notification(toggleText .. ": " .. tostring(Enabled))
                end

                Btn.MouseButton1Click:Connect(function()
                    Enabled = not Enabled
                    Update()
                end)

                ConfigObjects[toggleText] = {
                    Type = "Toggle",
                    Value = Enabled,
                    Set = function(val)
                        Enabled = val
                        Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
                        Dot.Position = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
                        callback(Enabled)
                    end
                }
            end

            -- Slider (maclib 风格，支持数值/百分比显示，默认数值)
            child.Slider = function(_, sliderText, min, max, default, callback, options)
                options = options or {}
                local Val = default or min

                -- 主容器（保留背景主题色 Top）
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 60)
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                -- 第一行：标签 + 数值框
                local TopRow = Instance.new("Frame")
                TopRow.Size = UDim2.new(1, -20, 0, 30)
                TopRow.Position = UDim2.new(0, 10, 0, 5)
                TopRow.BackgroundTransparency = 1
                TopRow.Parent = Frame

                -- 标签（左对齐）
                local Lbl = Instance.new("TextLabel")
                Lbl.Text = sliderText
                Lbl.Size = UDim2.new(0.5, 0, 1, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 14
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = TopRow
                AddToRegistry(Lbl, "TextColor3", "Text")

                -- 数值框（maclib 样式，文本居中）
                local NumBox = Instance.new("TextBox")
                NumBox.Name = "SliderValue"
                NumBox.FontFace = Font.new("rbxassetid://12187365364")
                NumBox.Text = tostring(Val)
                NumBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                NumBox.TextSize = 12
                NumBox.TextTransparency = 0.1
                NumBox.TextXAlignment = Enum.TextXAlignment.Center
                NumBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                NumBox.BackgroundTransparency = 0.95
                NumBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                NumBox.BorderSizePixel = 0
                NumBox.Size = UDim2.fromOffset(41, 21)
                NumBox.AnchorPoint = Vector2.new(1, 0.5)
                NumBox.Position = UDim2.new(1, 0, 0.5, 0)
                NumBox.ClipsDescendants = true
                NumBox.Parent = TopRow

                -- 圆角
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = NumBox

                -- 边框
                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = NumBox

                -- 内边距（左右各2）
                local boxPadding = Instance.new("UIPadding")
                boxPadding.PaddingLeft = UDim.new(0, 2)
                boxPadding.PaddingRight = UDim.new(0, 2)
                boxPadding.Parent = NumBox

                -- 第二行：滑块条
                local SliderBar = Instance.new("ImageLabel")
                SliderBar.Name = "SliderBar"
                SliderBar.Image = SliderAssets.Bar
                SliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                SliderBar.BackgroundTransparency = 1
                SliderBar.Size = UDim2.new(1, -20, 0, 3)
                SliderBar.Position = UDim2.new(0, 10, 0, 40)
                SliderBar.Parent = Frame

                -- 滑块头
                local SliderHead = Instance.new("ImageButton")
                SliderHead.Name = "SliderHead"
                SliderHead.Image = SliderAssets.Head
                SliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderHead.BackgroundTransparency = 1
                SliderHead.Size = UDim2.fromOffset(16, 16)
                SliderHead.Parent = SliderBar
                local initPosX = (Val - min) / (max - min)
                SliderHead.Position = UDim2.new(initPosX, 0, 0.5, 0)

                -- 显示方法
                local DisplayMethods = {
                    Value = function(sliderValue, precision)
                        return precision and string.format("%." .. precision .. "f", sliderValue) or tostring(math.round(sliderValue * 100) / 100)  -- 保留两位小数
                    end,
                    Percent = function(sliderValue, precision)
                        local percentage = (sliderValue - min) / (max - min) * 100
                        return (precision and string.format("%." .. precision .. "f", percentage) or tostring(math.round(percentage))) .. "%"
                    end,
                }
                local displayMethod = DisplayMethods[options.DisplayMethod] or DisplayMethods.Value
                local precision = options.Precision  -- nil 或数字

                local function SetValue(input, ignorecallback)
                    local posXScale
                    if typeof(input) == "Instance" then
                        local mouseX = input.Position.X
                        local barX = SliderBar.AbsolutePosition.X
                        local barWidth = SliderBar.AbsoluteSize.X
                        posXScale = math.clamp((mouseX - barX) / barWidth, 0, 1)
                    else
                        posXScale = (input - min) / (max - min)
                    end

                    SliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
                    local newValue = min + posXScale * (max - min)
                    Val = newValue

                    -- 更新数值框
                    NumBox.Text = displayMethod(newValue, precision)

                    if not ignorecallback then
                        task.spawn(function()
                            if callback then callback(newValue) end
                        end)
                    end

                    if ConfigObjects[sliderText] then
                        ConfigObjects[sliderText].Value = newValue
                    end
                end

                -- 初始化
                SetValue(Val, true)

                -- 拖动逻辑（支持鼠标和触摸）
                local dragging = false
                SliderHead.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        PlaySound(Sounds.Slide)
                        SetValue(input)
                    end
                end)
                SliderHead.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        SetValue(input)
                    end
                end)

                -- 数值框输入处理
                NumBox.FocusLost:Connect(function(enterPressed)
                    local inputText = NumBox.Text
                    local value = tonumber(inputText:match("%d+%.?%d*"))
                    if value then
                        -- 根据显示方式处理输入
                        if options.DisplayMethod == "Percent" then
                            -- 将输入作为百分比转换为实际数值
                            value = min + (value / 100) * (max - min)
                        end
                        local newValue = math.clamp(value, min, max)
                        SetValue(newValue, false)
                    else
                        SetValue(Val, true)
                    end
                end)

                -- 注册配置对象
                ConfigObjects[sliderText] = {
                    Type = "Slider",
                    Value = Val,
                    Set = function(val)
                        SetValue(val, true)
                    end
                }
            end

            -- ==================== Textbox (添加边框) ====================
            child.Textbox = function(_, boxText, placeholder, callback)
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1,0,0,60)
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = boxText
                Lbl.Size = UDim2.new(1,0,0,20)
                Lbl.Position = UDim2.new(0,10,0,5)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 14
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Frame
                AddToRegistry(Lbl, "TextColor3", "Text")

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1,-20,0,25)
                Box.Position = UDim2.new(0,10,0,28)
                Box.Text = ""
                Box.PlaceholderText = placeholder
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 13
                Box.BorderSizePixel = 0
                Box.Parent = Frame
                Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4)
                AddToRegistry(Box, "BackgroundColor3", "Main")
                AddToRegistry(Box, "TextColor3", "Text")

                -- 添加边框 (UIStroke)
                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = Box

                Box.FocusLost:Connect(function()
                    ConfigObjects[boxText].Value = Box.Text
                    callback(Box.Text)
                end)
                ConfigObjects[boxText] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; callback(val) end}
            end
            -- =============================================================

            -- Dropdown (原版样式，图标已替换为 maclib 的 Dropdown 图标)
            child.Dropdown = function(_, dropText, options, callback)
                local Dropped = false
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1,0,0,35)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")
                local Lbl = Instance.new("TextLabel")
                Lbl.Text = dropText
                Lbl.Size = UDim2.new(1,-30,1,0)
                Lbl.Position = UDim2.new(0,10,0,0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 14
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Btn
                AddToRegistry(Lbl, "TextColor3", "Text")
                local Icon = Instance.new("ImageLabel")
                Icon.Image = "rbxassetid://18865373378"  -- 替换为 maclib 的 Dropdown 图标
                Icon.Size = UDim2.new(0,20,0,20)
                Icon.Position = UDim2.new(1,-30,0.5,-10)
                Icon.BackgroundTransparency = 1
                Icon.Parent = Btn

                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1,0,0,0)
                Container.Visible = false
                Container.ClipsDescendants = true
                Container.Parent = contentContainer
                Container.ZIndex = 10
                Instance.new("UICorner", Container).CornerRadius = UDim.new(0,6)
                AddToRegistry(Container, "BackgroundColor3", "Top")
                local List = Instance.new("UIListLayout")
                List.SortOrder = Enum.SortOrder.LayoutOrder
                List.Parent = Container

                local function Select(opt)
                    Dropped = false
                    Lbl.Text = dropText..": "..opt
                    ConfigObjects[dropText].Value = opt
                    callback(opt)
                    Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2)
                    Tween(Icon, {Rotation = 0}, 0.2)
                    task.wait(0.2)
                    Container.Visible = false
                    updateSectionHeight(false)
                end

                local function RefreshOptions(newOpts)
                    for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, opt in pairs(newOpts) do
                        local O = Instance.new("TextButton")
                        O.Size = UDim2.new(1,0,0,30)
                        O.Text = opt
                        O.TextColor3 = Color3.fromRGB(150,150,150)
                        O.Font = Enum.Font.Gotham
                        O.TextSize = 13
                        O.BackgroundTransparency = 1
                        O.Parent = Container
                        O.MouseButton1Click:Connect(function() Select(opt) end)
                    end
                end
                RefreshOptions(options)

                Btn.MouseButton1Click:Connect(function()
                    Dropped = not Dropped
                    PlaySound(Sounds.Click)
                    if Dropped then
                        Container.Visible = true
                        local targetHeight = #options * 30
                        local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, targetHeight)})
                        tweenOpt:Play()
                        Tween(Icon, {Rotation = 180}, 0.3)
                        tweenOpt.Completed:Connect(function()
                            updateSectionHeight(false)
                        end)
                    else
                        local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, 0)})
                        tweenOpt:Play()
                        Tween(Icon, {Rotation = 0}, 0.2)
                        tweenOpt.Completed:Connect(function()
                            Container.Visible = false
                            updateSectionHeight(false)
                        end)
                    end
                end)

                ConfigObjects[dropText] = {Type = "Dropdown", Value = options[1], Set = function(val) Select(val) end, Refresh = RefreshOptions}
                return {Refresh = RefreshOptions}
            end

            -- ==================== Keybind (添加边框) ====================
            child.Keybind = function(_, keyText, default, callback)
                local Key = default or Enum.KeyCode.M

                -- 主容器（保留原背景）
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

                -- 左侧标题
                local Title = Instance.new("TextLabel")
                Title.Text = keyText
                Title.Size = UDim2.new(0.6, 0, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Btn
                AddToRegistry(Title, "TextColor3", "Text")

                -- 右侧绑定框（模仿 maclib 的 TextBox，背景使用主题 Main 并降低透明度使其更明显）
                local BinderBox = Instance.new("TextBox")
                BinderBox.Name = "BinderBox"
                BinderBox.Font = Enum.Font.GothamBold
                BinderBox.Text = Key.Name
                BinderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                BinderBox.TextSize = 13
                BinderBox.TextTransparency = 0.1
                BinderBox.PlaceholderText = "..."
                BinderBox.BackgroundTransparency = 0.2  -- 降低透明度，使背景更明显
                BinderBox.BorderSizePixel = 0
                BinderBox.Size = UDim2.new(0, 80, 0, 24)
                BinderBox.Position = UDim2.new(1, -90, 0.5, -12)
                BinderBox.Parent = Btn
                Instance.new("UICorner", BinderBox).CornerRadius = UDim.new(0, 5)
                AddToRegistry(BinderBox, "BackgroundColor3", "Main")  -- 背景色跟随主题 Main
                AddToRegistry(BinderBox, "TextColor3", "Accent")

                -- 添加边框 (UIStroke)
                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = BinderBox

                -- 绑定状态控制
                local isBinding = false
                local focused = false

                -- 点击按钮时聚焦输入框，进入绑定模式
                Btn.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    BinderBox:CaptureFocus()
                end)

                -- 聚焦时进入绑定模式
                BinderBox.Focused:Connect(function()
                    focused = true
                    isBinding = true
                    BinderBox.Text = ""
                    BinderBox.PlaceholderText = "..."
                end)

                -- 失去焦点时退出绑定模式，恢复显示当前键
                BinderBox.FocusLost:Connect(function()
                    focused = false
                    isBinding = false
                    BinderBox.Text = Key.Name
                    BinderBox.PlaceholderText = ""
                end)

                -- 监听输入进行绑定
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if focused and isBinding then
                        local newKey
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            newKey = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            newKey = input.UserInputType
                        end
                        if newKey and newKey.Name ~= "Unknown" then
                            Key = newKey
                            BinderBox.Text = Key.Name
                            callback(Key)
                            Window:Notification("Keybind: " .. Key.Name)
                            -- 更新配置对象
                            ConfigObjects[keyText].Value = Key.Name
                        end
                        BinderBox:ReleaseFocus()  -- 退出绑定模式
                    end
                end)

                -- 注册配置对象
                ConfigObjects[keyText] = {
                    Type = "Keybind",
                    Value = Key.Name,
                    Set = function(val)
                        Key = Enum.KeyCode[val] or Key
                        BinderBox.Text = Key.Name
                        callback(Key)
                    end
                }

                -- 返回控制方法（保持与其他组件一致）
                local self = {}
                function self.UpdateText(newText)
                    Title.Text = newText
                end
                function self.SetVisible(state)
                    Btn.Visible = state
                end
                return self
            end
            -- =============================================================

            -- ==================== 替换 Value 为 Input (maclib 风格) ====================
            child.Input = function(_, inputText, default, callback, options)
                options = options or {}
                local placeholder = options.placeholder or ""
                local acceptedCharacters = options.acceptedCharacters or "All"
                local characterLimit = options.characterLimit
                local onChanged = options.onChanged

                -- 主容器（保留原背景）
                local InputFrame = Instance.new("Frame")
                InputFrame.Size = UDim2.new(1, 0, 0, 35)
                InputFrame.Parent = contentContainer
                Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(InputFrame, "BackgroundColor3", "Top")

                -- 标签（左对齐）
                local NameLbl = Instance.new("TextLabel")
                NameLbl.Text = inputText
                NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
                NameLbl.Position = UDim2.new(0, 10, 0, 0)
                NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                NameLbl.Font = Enum.Font.Gotham
                NameLbl.TextSize = 14
                NameLbl.BackgroundTransparency = 1
                NameLbl.Parent = InputFrame
                AddToRegistry(NameLbl, "TextColor3", "Text")

                -- 文本框（右侧）
                local InputBox = Instance.new("TextBox")
                InputBox.Text = tostring(default or "")
                InputBox.PlaceholderText = placeholder
                InputBox.Size = UDim2.new(0.3, 0, 0, 26)
                InputBox.Position = UDim2.new(0.7, -10, 0.5, -13)
                InputBox.Font = Enum.Font.GothamBold
                InputBox.TextSize = 13
                InputBox.TextXAlignment = Enum.TextXAlignment.Center
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = InputFrame

                -- 圆角
                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 5)
                boxCorner.Parent = InputBox

                -- 注册背景和文字颜色
                AddToRegistry(InputBox, "BackgroundColor3", "Main")
                AddToRegistry(InputBox, "TextColor3", "Accent")

                -- 边框（仿 maclib）
                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = InputBox

                -- 字符过滤函数
                local function filterText(text)
                    -- 先应用字符限制
                    if characterLimit then
                        text = text:sub(1, characterLimit)
                    end
                    -- 根据 acceptedCharacters 过滤
                    if type(acceptedCharacters) == "function" then
                        return acceptedCharacters(text)
                    elseif acceptedCharacters == "Numeric" then
                        -- 允许数字和可选负号（仅开头）
                        return text:gsub("[^%d-]", ""):gsub("-(.*)", function(m) return m:gsub("-", "") end) -- 简单处理，仅保留一个负号
                    elseif acceptedCharacters == "Alphabetic" then
                        return text:gsub("[^a-zA-Z]", "")
                    elseif acceptedCharacters == "AlphaNumeric" then
                        return text:gsub("[^a-zA-Z0-9]", "")
                    else -- "All" 或其他
                        return text
                    end
                end

                -- 实时过滤
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local filtered = filterText(InputBox.Text)
                    if filtered ~= InputBox.Text then
                        InputBox.Text = filtered
                    end
                    if onChanged then
                        onChanged(filtered)
                    end
                end)

                -- 焦点丢失回调
                InputBox.FocusLost:Connect(function(enterPressed)
                    local text = InputBox.Text
                    -- 过滤（确保最终文本符合规则）
                    local filtered = filterText(text)
                    if filtered ~= text then
                        InputBox.Text = filtered
                        text = filtered
                    end
                    -- 调用回调
                    if callback then
                        callback(text)
                    end
                end)

                -- 注册配置对象
                ConfigObjects[inputText] = {
                    Type = "Input",
                    Value = InputBox.Text,
                    Set = function(val)
                        InputBox.Text = tostring(val)
                    end
                }

                -- 返回控制方法（可选）
                local self = {}
                function self.UpdateText(newText)
                    InputBox.Text = tostring(newText)
                    ConfigObjects[inputText].Value = InputBox.Text
                end
                function self.GetText()
                    return InputBox.Text
                end
                function self.SetVisible(state)
                    InputFrame.Visible = state
                end
                function self.UpdatePlaceholder(newPlaceholder)
                    InputBox.PlaceholderText = newPlaceholder
                end
                return self
            end
            -- ==========================================================================

            -- ==================== Colorpicker (maclib 风格，增强按钮) ====================
            child.Colorpicker = function(_, pickerText, defaultColor, callback, options)
                options = options or {}
                local hasAlpha = options.Alpha ~= nil
                local alpha = options.Alpha or 0
                local currentColor = defaultColor or Color3.new(1,1,1)

                -- 主框架 (与 Toggle 类似，背景色 Top)
                local Main = Instance.new("TextButton")
                Main.Size = UDim2.new(1, 0, 0, 35)
                Main.Text = ""
                Main.Parent = contentContainer
                Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Main, "BackgroundColor3", "Top")

                -- 文本标签
                local Title = Instance.new("TextLabel")
                Title.Text = pickerText
                Title.Size = UDim2.new(0.7, 0, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.Gotham
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Main
                AddToRegistry(Title, "TextColor3", "Text")

                -- 当前颜色显示块 (带网格背景以支持透明度)
                local ColorPreview = Instance.new("ImageLabel")
                ColorPreview.Size = UDim2.new(0, 30, 0, 20)
                ColorPreview.Position = UDim2.new(1, -40, 0.5, -10)
                ColorPreview.BackgroundTransparency = 1
                ColorPreview.Image = ColorPickerAssets.Grid
                ColorPreview.ScaleType = Enum.ScaleType.Tile
                ColorPreview.TileSize = UDim2.fromOffset(10, 10)
                ColorPreview.Parent = Main

                local CurrentColorBlock = Instance.new("Frame")
                CurrentColorBlock.Size = UDim2.new(1, 0, 1, 0)
                CurrentColorBlock.BackgroundColor3 = currentColor
                CurrentColorBlock.BackgroundTransparency = alpha
                CurrentColorBlock.BorderSizePixel = 0
                CurrentColorBlock.Parent = ColorPreview
                Instance.new("UICorner", CurrentColorBlock).CornerRadius = UDim.new(0, 4)

                local PreviewStroke = Instance.new("UIStroke")
                PreviewStroke.Thickness = 1
                PreviewStroke.Color = Color3.new(1,1,1)
                PreviewStroke.Transparency = 0.7
                PreviewStroke.Parent = CurrentColorBlock

                -- 点击打开颜色选择器
                Main.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    ShowColorPicker()
                end)

                -- 注册配置对象
                ConfigObjects[pickerText] = {
                    Type = "Colorpicker",
                    Value = currentColor,
                    Alpha = alpha,
                    Set = function(newColor, newAlpha)
                        currentColor = newColor
                        alpha = newAlpha or alpha
                        CurrentColorBlock.BackgroundColor3 = currentColor
                        CurrentColorBlock.BackgroundTransparency = alpha
                        if callback then callback(currentColor, alpha) end
                    end
                }

                -- 颜色选择器弹出窗口函数
                function ShowColorPicker()
                    -- 创建遮罩层 (CanvasGroup 可实现淡入淡出)
                    local Canvas = Instance.new("CanvasGroup")
                    Canvas.Size = UDim2.new(1, 0, 1, 0)
                    Canvas.BackgroundTransparency = 1
                    Canvas.GroupTransparency = 1
                    Canvas.Parent = ScreenGui
                    Canvas.ZIndex = 10

                    -- 背景半透明遮罩
                    local Overlay = Instance.new("Frame")
                    Overlay.Size = UDim2.new(1, 0, 1, 0)
                    Overlay.BackgroundColor3 = Color3.new(0,0,0)
                    Overlay.BackgroundTransparency = 0.5
                    Overlay.BorderSizePixel = 0
                    Overlay.Parent = Canvas
                    Overlay.ZIndex = 10

                    -- 主弹出框
                    local PickerFrame = Instance.new("Frame")
                    PickerFrame.Size = UDim2.new(0, 360, 0, 420)  -- 稍微加大尺寸，确保按钮可见
                    PickerFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
                    PickerFrame.BackgroundColor3 = CurrentTheme.Main
                    PickerFrame.BorderSizePixel = 0
                    PickerFrame.Parent = Canvas
                    PickerFrame.ZIndex = 11
                    Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 10)
                    local Stroke = Instance.new("UIStroke", PickerFrame)
                    Stroke.Color = CurrentTheme.Stroke
                    Stroke.Thickness = 2

                    -- 内容布局
                    local UIPadding = Instance.new("UIPadding", PickerFrame)
                    UIPadding.PaddingTop = UDim.new(0, 15)
                    UIPadding.PaddingBottom = UDim.new(0, 15)
                    UIPadding.PaddingLeft = UDim.new(0, 15)
                    UIPadding.PaddingRight = UDim.new(0, 15)

                    local UIList = Instance.new("UIListLayout", PickerFrame)
                    UIList.SortOrder = Enum.SortOrder.LayoutOrder
                    UIList.Padding = UDim.new(0, 10)

                    -- 标题
                    local TitleLabel = Instance.new("TextLabel")
                    TitleLabel.Text = pickerText
                    TitleLabel.Size = UDim2.new(1, 0, 0, 25)
                    TitleLabel.BackgroundTransparency = 1
                    TitleLabel.Font = Enum.Font.GothamBold
                    TitleLabel.TextSize = 16
                    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    TitleLabel.Parent = PickerFrame
                    TitleLabel.TextColor3 = CurrentTheme.Text
                    TitleLabel.LayoutOrder = 1

                    -- 色轮 + 亮度条 + 输入区域
                    local Row1 = Instance.new("Frame")
                    Row1.Size = UDim2.new(1, 0, 0, 150)
                    Row1.BackgroundTransparency = 1
                    Row1.Parent = PickerFrame
                    Row1.LayoutOrder = 2

                    -- 色轮
                    local Wheel = Instance.new("ImageButton")
                    Wheel.Name = "Wheel"
                    Wheel.Size = UDim2.new(0, 150, 0, 150)
                    Wheel.Position = UDim2.new(0, 0, 0, 0)
                    Wheel.BackgroundTransparency = 1
                    Wheel.Image = ColorPickerAssets.ColorWheel
                    Wheel.Parent = Row1
                    Wheel.ZIndex = 12
                    -- 色轮上的指示器
                    local Target = Instance.new("ImageLabel")
                    Target.Name = "Target"
                    Target.Size = UDim2.new(0, 18, 0, 18)
                    Target.BackgroundTransparency = 1
                    Target.Image = ColorPickerAssets.ColorTarget
                    Target.Parent = Wheel
                    Target.ZIndex = 13

                    -- 亮度滑块条 (垂直)
                    local BrightnessSlider = Instance.new("ImageLabel")
                    BrightnessSlider.Name = "BrightnessSlider"
                    BrightnessSlider.Size = UDim2.new(0, 20, 0, 150)
                    BrightnessSlider.Position = UDim2.new(0, 160, 0, 0)
                    BrightnessSlider.BackgroundTransparency = 1
                    BrightnessSlider.Image = ColorPickerAssets.SliderBar
                    BrightnessSlider.ImageColor3 = Color3.fromRGB(87,86,86)
                    BrightnessSlider.Parent = Row1

                    local BrightnessHead = Instance.new("ImageButton")
                    BrightnessHead.Name = "BrightnessHead"
                    BrightnessHead.Size = UDim2.new(0, 16, 0, 16)
                    BrightnessHead.AnchorPoint = Vector2.new(0.5, 0.5)
                    BrightnessHead.BackgroundTransparency = 1
                    BrightnessHead.Image = ColorPickerAssets.SliderHead
                    BrightnessHead.Parent = BrightnessSlider
                    -- 初始位置 (根据当前颜色的明度)
                    local h, s, v = currentColor:ToHSV()
                    BrightnessHead.Position = UDim2.new(0.5, 0, 1 - v, 0)

                    -- 右侧输入区域
                    local InputColumn = Instance.new("Frame")
                    InputColumn.Size = UDim2.new(0, 140, 1, 0)
                    InputColumn.Position = UDim2.new(0, 190, 0, 0)
                    InputColumn.BackgroundTransparency = 1
                    InputColumn.Parent = Row1

                    local InputList = Instance.new("UIListLayout", InputColumn)
                    InputList.SortOrder = Enum.SortOrder.LayoutOrder
                    InputList.Padding = UDim.new(0, 5)
                    InputList.VerticalAlignment = Enum.VerticalAlignment.Top

                    -- 辅助函数：创建带边框的输入框
                    local function CreateInputBox(name, defaultText)
                        local BoxFrame = Instance.new("Frame")
                        BoxFrame.Size = UDim2.new(1, 0, 0, 30)
                        BoxFrame.BackgroundTransparency = 1
                        BoxFrame.Parent = InputColumn

                        local Label = Instance.new("TextLabel")
                        Label.Text = name
                        Label.Size = UDim2.new(0, 30, 1, 0)
                        Label.BackgroundTransparency = 1
                        Label.Font = Enum.Font.Gotham
                        Label.TextSize = 12
                        Label.TextColor3 = CurrentTheme.Text
                        Label.TextXAlignment = Enum.TextXAlignment.Left
                        Label.Parent = BoxFrame

                        local Box = Instance.new("TextBox")
                        Box.Size = UDim2.new(1, -35, 0, 25)
                        Box.Position = UDim2.new(0, 35, 0.5, -12.5)
                        Box.Text = defaultText
                        Box.Font = Enum.Font.Gotham
                        Box.TextSize = 12
                        Box.TextColor3 = CurrentTheme.Text
                        Box.BackgroundColor3 = CurrentTheme.Main
                        Box.BorderSizePixel = 0
                        Box.Parent = BoxFrame
                        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
                        local Stroke = Instance.new("UIStroke", Box)
                        Stroke.Color = CurrentTheme.Stroke
                        Stroke.Transparency = 0.5
                        return Box
                    end

                    -- 创建 RGB 和 Hex 输入
                    local RedBox = CreateInputBox("R", tostring(math.floor(currentColor.R * 255 + 0.5)))
                    local GreenBox = CreateInputBox("G", tostring(math.floor(currentColor.G * 255 + 0.5)))
                    local BlueBox = CreateInputBox("B", tostring(math.floor(currentColor.B * 255 + 0.5)))
                    local HexBox = CreateInputBox("#", string.format("#%02X%02X%02X", 
                        math.floor(currentColor.R * 255 + 0.5),
                        math.floor(currentColor.G * 255 + 0.5),
                        math.floor(currentColor.B * 255 + 0.5)))

                    local AlphaBox
                    if hasAlpha then
                        AlphaBox = CreateInputBox("A", tostring(alpha))
                    end

                    -- 新/旧颜色预览
                    local PreviewRow = Instance.new("Frame")
                    PreviewRow.Size = UDim2.new(1, 0, 0, 40)
                    PreviewRow.BackgroundTransparency = 1
                    PreviewRow.Parent = PickerFrame
                    PreviewRow.LayoutOrder = 3

                    local OldColor = Instance.new("ImageLabel")
                    OldColor.Size = UDim2.new(0.5, -5, 1, -10)
                    OldColor.Position = UDim2.new(0, 0, 0, 5)
                    OldColor.BackgroundTransparency = 1
                    OldColor.Image = ColorPickerAssets.Grid
                    OldColor.ScaleType = Enum.ScaleType.Tile
                    OldColor.TileSize = UDim2.fromOffset(10,10)
                    OldColor.Parent = PreviewRow

                    local OldColorBlock = Instance.new("Frame")
                    OldColorBlock.Size = UDim2.new(1,0,1,0)
                    OldColorBlock.BackgroundColor3 = currentColor
                    OldColorBlock.BackgroundTransparency = alpha
                    OldColorBlock.BorderSizePixel = 0
                    OldColorBlock.Parent = OldColor
                    Instance.new("UICorner", OldColorBlock).CornerRadius = UDim.new(0, 4)

                    local NewColor = Instance.new("ImageLabel")
                    NewColor.Size = UDim2.new(0.5, -5, 1, -10)
                    NewColor.Position = UDim2.new(0.5, 5, 0, 5)
                    NewColor.BackgroundTransparency = 1
                    NewColor.Image = ColorPickerAssets.Grid
                    NewColor.ScaleType = Enum.ScaleType.Tile
                    NewColor.TileSize = UDim2.fromOffset(10,10)
                    NewColor.Parent = PreviewRow

                    local NewColorBlock = Instance.new("Frame")
                    NewColorBlock.Size = UDim2.new(1,0,1,0)
                    NewColorBlock.BackgroundColor3 = currentColor
                    NewColorBlock.BackgroundTransparency = alpha
                    NewColorBlock.BorderSizePixel = 0
                    NewColorBlock.Parent = NewColor
                    Instance.new("UICorner", NewColorBlock).CornerRadius = UDim.new(0, 4)

                    -- 确认/取消按钮行（增强样式）
                    local ButtonRow = Instance.new("Frame")
                    ButtonRow.Size = UDim2.new(1, 0, 0, 40)
                    ButtonRow.BackgroundTransparency = 1
                    ButtonRow.Parent = PickerFrame
                    ButtonRow.LayoutOrder = 4

                    -- 确认按钮
                    local Confirm = Instance.new("TextButton")
                    Confirm.Size = UDim2.new(0.5, -6, 0, 35)
                    Confirm.Position = UDim2.new(0, 0, 0.5, -17)
                    Confirm.Text = "Confirm"
                    Confirm.Font = Enum.Font.GothamBold
                    Confirm.TextSize = 14
                    Confirm.TextColor3 = CurrentTheme.Text
                    Confirm.BackgroundColor3 = CurrentTheme.Top
                    Confirm.BorderSizePixel = 0
                    Confirm.Parent = ButtonRow
                    Confirm.ZIndex = 12
                    Instance.new("UICorner", Confirm).CornerRadius = UDim.new(0, 6)
                    local ConfirmStroke = Instance.new("UIStroke", Confirm)
                    ConfirmStroke.Color = CurrentTheme.Accent
                    ConfirmStroke.Thickness = 1.5
                    ConfirmStroke.Transparency = 0.3

                    -- 取消按钮
                    local Cancel = Instance.new("TextButton")
                    Cancel.Size = UDim2.new(0.5, -6, 0, 35)
                    Cancel.Position = UDim2.new(0.5, 6, 0.5, -17)
                    Cancel.Text = "Cancel"
                    Cancel.Font = Enum.Font.GothamBold
                    Cancel.TextSize = 14
                    Cancel.TextColor3 = CurrentTheme.Text
                    Cancel.BackgroundColor3 = CurrentTheme.Top
                    Cancel.BorderSizePixel = 0
                    Cancel.Parent = ButtonRow
                    Cancel.ZIndex = 12
                    Instance.new("UICorner", Cancel).CornerRadius = UDim.new(0, 6)
                    local CancelStroke = Instance.new("UIStroke", Cancel)
                    CancelStroke.Color = CurrentTheme.Stroke
                    CancelStroke.Thickness = 1.5
                    CancelStroke.Transparency = 0.3

                    -- 按钮悬停效果
                    local function onHover(btn, accent)
                        Tween(btn, {BackgroundColor3 = CurrentTheme.Accent:Lerp(CurrentTheme.Top, 0.3)}, 0.2)
                    end
                    local function onLeave(btn)
                        Tween(btn, {BackgroundColor3 = CurrentTheme.Top}, 0.2)
                    end
                    Confirm.MouseEnter:Connect(function() onHover(Confirm) end)
                    Confirm.MouseLeave:Connect(function() onLeave(Confirm) end)
                    Cancel.MouseEnter:Connect(function() onHover(Cancel) end)
                    Cancel.MouseLeave:Connect(function() onLeave(Cancel) end)

                    -- 状态变量
                    local hue, sat, val = currentColor:ToHSV()
                    local tempColor = currentColor
                    local tempAlpha = alpha
                    local wheelDragging = false
                    local sliderDragging = false

                    -- 更新 UI 的函数
                    local function UpdateFromHSV()
                        tempColor = Color3.fromHSV(hue, sat, val)
                        NewColorBlock.BackgroundColor3 = tempColor
                        NewColorBlock.BackgroundTransparency = tempAlpha

                        RedBox.Text = tostring(math.floor(tempColor.R * 255 + 0.5))
                        GreenBox.Text = tostring(math.floor(tempColor.G * 255 + 0.5))
                        BlueBox.Text = tostring(math.floor(tempColor.B * 255 + 0.5))
                        HexBox.Text = string.format("#%02X%02X%02X",
                            math.floor(tempColor.R * 255 + 0.5),
                            math.floor(tempColor.G * 255 + 0.5),
                            math.floor(tempColor.B * 255 + 0.5))

                        -- 更新滑块位置
                        Target.Position = UDim2.new(sat * math.cos(hue * 2 * math.pi) * 0.5 + 0.5, 0, -sat * math.sin(hue * 2 * math.pi) * 0.5 + 0.5, 0)
                        BrightnessHead.Position = UDim2.new(0.5, 0, 1 - val, 0)
                    end

                    -- 色轮拖动逻辑
                    local function UpdateWheelFromMouse(input)
                        local pos = input.Position
                        local absPos = Wheel.AbsolutePosition
                        local size = Wheel.AbsoluteSize
                        local center = absPos + size / 2
                        local delta = pos - center
                        local radius = size.X / 2
                        local dist = delta.Magnitude
                        if dist > radius then
                            delta = delta.Unit * radius
                        end
                        local angle = math.atan2(-delta.Y, delta.X)
                        if angle < 0 then angle = angle + 2 * math.pi end
                        hue = angle / (2 * math.pi)
                        sat = delta.Magnitude / radius
                        Target.Position = UDim2.new(0.5 + delta.X / size.X, 0, 0.5 + delta.Y / size.Y, 0)
                        UpdateFromHSV()
                    end

                    Wheel.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            wheelDragging = true
                            UpdateWheelFromMouse(input)
                        end
                    end)
                    Wheel.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            wheelDragging = false
                        end
                    end)

                    -- 亮度滑块拖动
                    local function UpdateSliderFromMouse(input)
                        local pos = input.Position.Y
                        local absY = BrightnessSlider.AbsolutePosition.Y
                        local height = BrightnessSlider.AbsoluteSize.Y
                        local relative = (pos - absY) / height
                        val = 1 - math.clamp(relative, 0, 1)
                        BrightnessHead.Position = UDim2.new(0.5, 0, 1 - val, 0)
                        UpdateFromHSV()
                    end

                    BrightnessHead.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliderDragging = true
                            UpdateSliderFromMouse(input)
                        end
                    end)
                    BrightnessHead.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            sliderDragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if wheelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateWheelFromMouse(input)
                        elseif sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateSliderFromMouse(input)
                        end
                    end)

                    -- 输入框更新
                    local function UpdateFromRGB()
                        local r = tonumber(RedBox.Text) or 0
                        local g = tonumber(GreenBox.Text) or 0
                        local b = tonumber(BlueBox.Text) or 0
                        r = math.clamp(r, 0, 255)
                        g = math.clamp(g, 0, 255)
                        b = math.clamp(b, 0, 255)
                        tempColor = Color3.fromRGB(r, g, b)
                        hue, sat, val = tempColor:ToHSV()
                        UpdateFromHSV()
                    end

                    local function UpdateFromHex()
                        local hex = HexBox.Text:gsub("#", "")
                        if #hex == 6 then
                            local r = tonumber(hex:sub(1,2), 16) or 0
                            local g = tonumber(hex:sub(3,4), 16) or 0
                            local b = tonumber(hex:sub(5,6), 16) or 0
                            tempColor = Color3.fromRGB(r, g, b)
                            hue, sat, val = tempColor:ToHSV()
                            UpdateFromHSV()
                        end
                    end

                    RedBox.FocusLost:Connect(UpdateFromRGB)
                    GreenBox.FocusLost:Connect(UpdateFromRGB)
                    BlueBox.FocusLost:Connect(UpdateFromRGB)
                    HexBox.FocusLost:Connect(UpdateFromHex)

                    if AlphaBox then
                        AlphaBox.FocusLost:Connect(function()
                            local a = tonumber(AlphaBox.Text) or tempAlpha
                            a = math.clamp(a, 0, 1)
                            tempAlpha = a
                            NewColorBlock.BackgroundTransparency = tempAlpha
                        end)
                    end

                    -- 确认/取消点击事件
                    Confirm.MouseButton1Click:Connect(function()
                        PlaySound(Sounds.Click)
                        currentColor = tempColor
                        alpha = tempAlpha
                        CurrentColorBlock.BackgroundColor3 = currentColor
                        CurrentColorBlock.BackgroundTransparency = alpha
                        if callback then callback(currentColor, alpha) end
                        ConfigObjects[pickerText].Value = currentColor
                        ConfigObjects[pickerText].Alpha = alpha
                        Tween(Canvas, {GroupTransparency = 1}, 0.2)
                        game.Debris:AddItem(Canvas, 0.3)
                    end)

                    Cancel.MouseButton1Click:Connect(function()
                        PlaySound(Sounds.Click)
                        Tween(Canvas, {GroupTransparency = 1}, 0.2)
                        game.Debris:AddItem(Canvas, 0.3)
                    end)

                    -- 淡入动画
                    Tween(Canvas, {GroupTransparency = 0}, 0.2)
                end

                -- 返回控制方法
                local self = {}
                function self.UpdateText(newText)
                    Title.Text = newText
                end
                function self.SetVisible(state)
                    Main.Visible = state
                end
                function self.SetColor(newColor, newAlpha)
                    currentColor = newColor
                    alpha = newAlpha or alpha
                    CurrentColorBlock.BackgroundColor3 = currentColor
                    CurrentColorBlock.BackgroundTransparency = alpha
                    if callback then callback(currentColor, alpha) end
                    ConfigObjects[pickerText].Value = currentColor
                    ConfigObjects[pickerText].Alpha = alpha
                end
                return self
            end
            -- =============================================================

            return child
        end

        return Elements
    end

    return Window
end

-- 公开方法：控制音效开关
function Library:SetSFXEnabled(state)
    SFXEnabled = state
end

return Library