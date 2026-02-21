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
-- 新增 Dropdown 资源（从 maclib 移植）
local DropdownAssets = {
    DropdownIcon = "rbxassetid://18865373378",  -- 下拉箭头
    SearchIcon = "rbxassetid://86737463322606", -- 搜索图标
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

            -- Textbox
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
                Box.Parent = Frame
                Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4)
                AddToRegistry(Box, "BackgroundColor3", "Main")
                AddToRegistry(Box, "TextColor3", "Text")

                Box.FocusLost:Connect(function()
                    ConfigObjects[boxText].Value = Box.Text
                    callback(Box.Text)
                end)
                ConfigObjects[boxText] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; callback(val) end}
            end

            -- ========== 替换为从 maclib.lua 移植的 Dropdown ==========
            child.Dropdown = function(_, dropText, options, callback)
                local Settings = {
                    Name = dropText,
                    Options = options,
                    Callback = callback,
                    Multi = false,      -- 默认单选
                    Required = false,
                    Search = false,
                    Default = nil,
                }
                -- 如果需要多选等特性，可通过额外参数传递，这里简化
                local Flag = dropText   -- 用于 ConfigObjects

                local DropdownFunctions = { Settings = Settings, IgnoreConfig = false, Class = "Dropdown" }
                local Selected = {}
                local OptionObjs = {}

                -- 创建主框架
                local dropdown = Instance.new("Frame")
                dropdown.Name = "Dropdown"
                dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdown.BackgroundTransparency = 0.985
                dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdown.BorderSizePixel = 0
                dropdown.Size = UDim2.new(1, 0, 0, 38)
                dropdown.Parent = contentContainer   -- 添加到内容容器
                dropdown.ClipsDescendants = true

                local dropdownUIPadding = Instance.new("UIPadding")
                dropdownUIPadding.Name = "DropdownUIPadding"
                dropdownUIPadding.PaddingLeft = UDim.new(0, 15)
                dropdownUIPadding.PaddingRight = UDim.new(0, 15)
                dropdownUIPadding.Parent = dropdown

                local interact = Instance.new("TextButton")
                interact.Name = "Interact"
                interact.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
                interact.Text = ""
                interact.TextColor3 = Color3.fromRGB(0, 0, 0)
                interact.TextSize = 14
                interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                interact.BackgroundTransparency = 1
                interact.BorderColor3 = Color3.fromRGB(0, 0, 0)
                interact.BorderSizePixel = 0
                interact.Size = UDim2.new(1, 0, 0, 38)
                interact.Parent = dropdown

                local dropdownName = Instance.new("TextLabel")
                dropdownName.Name = "DropdownName"
                dropdownName.FontFace = Font.new("rbxassetid://12187365364")  -- Inter 字体
                dropdownName.Text = Settings.Default and (DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ")) or (DropdownFunctions.Settings.Name .. "...")
                dropdownName.RichText = true
                dropdownName.TextColor3 = Color3.fromRGB(255, 255, 255)
                dropdownName.TextSize = 13
                dropdownName.TextTransparency = 0.5
                dropdownName.TextTruncate = Enum.TextTruncate.SplitWord
                dropdownName.TextXAlignment = Enum.TextXAlignment.Left
                dropdownName.AutomaticSize = Enum.AutomaticSize.Y
                dropdownName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownName.BackgroundTransparency = 1
                dropdownName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownName.BorderSizePixel = 0
                dropdownName.Size = UDim2.new(1, -20, 0, 38)
                dropdownName.Parent = dropdown

                local dropdownUIStroke = Instance.new("UIStroke")
                dropdownUIStroke.Name = "DropdownUIStroke"
                dropdownUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                dropdownUIStroke.Color = Color3.fromRGB(255, 255, 255)
                dropdownUIStroke.Transparency = 0.95
                dropdownUIStroke.Parent = dropdown

                local dropdownUICorner = Instance.new("UICorner")
                dropdownUICorner.Name = "DropdownUICorner"
                dropdownUICorner.CornerRadius = UDim.new(0, 6)
                dropdownUICorner.Parent = dropdown

                local dropdownImage = Instance.new("ImageLabel")
                dropdownImage.Name = "DropdownImage"
                dropdownImage.Image = DropdownAssets.DropdownIcon
                dropdownImage.ImageTransparency = 0.5
                dropdownImage.AnchorPoint = Vector2.new(1, 0)
                dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownImage.BackgroundTransparency = 1
                dropdownImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownImage.BorderSizePixel = 0
                dropdownImage.Position = UDim2.new(1, 0, 0, 12)
                dropdownImage.Size = UDim2.fromOffset(14, 14)
                dropdownImage.Parent = dropdown

                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "DropdownFrame"
                dropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownFrame.BorderSizePixel = 0
                dropdownFrame.ClipsDescendants = true
                dropdownFrame.Size = UDim2.fromScale(1, 1)
                dropdownFrame.Visible = false
                dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y

                local dropdownFrameUIPadding = Instance.new("UIPadding")
                dropdownFrameUIPadding.Name = "DropdownFrameUIPadding"
                dropdownFrameUIPadding.PaddingTop = UDim.new(0, 38)
                dropdownFrameUIPadding.PaddingBottom = UDim.new(0, 10)
                dropdownFrameUIPadding.Parent = dropdownFrame

                local dropdownFrameUIListLayout = Instance.new("UIListLayout")
                dropdownFrameUIListLayout.Name = "DropdownFrameUIListLayout"
                dropdownFrameUIListLayout.Padding = UDim.new(0, 5)
                dropdownFrameUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownFrameUIListLayout.Parent = dropdownFrame

                -- 搜索框（如果需要）
                local search = Instance.new("Frame")
                search.Name = "Search"
                search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                search.BackgroundTransparency = 0.95
                search.BorderColor3 = Color3.fromRGB(0, 0, 0)
                search.BorderSizePixel = 0
                search.LayoutOrder = -1
                search.Size = UDim2.new(1, 0, 0, 30)
                search.Parent = dropdownFrame
                search.Visible = DropdownFunctions.Settings.Search

                local sectionUICorner = Instance.new("UICorner")
                sectionUICorner.Name = "SectionUICorner"
                sectionUICorner.Parent = search

                local searchIcon = Instance.new("ImageLabel")
                searchIcon.Name = "SearchIcon"
                searchIcon.Image = DropdownAssets.SearchIcon
                searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
                searchIcon.AnchorPoint = Vector2.new(0, 0.5)
                searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                searchIcon.BackgroundTransparency = 1
                searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                searchIcon.BorderSizePixel = 0
                searchIcon.Position = UDim2.fromScale(0, 0.5)
                searchIcon.Size = UDim2.fromOffset(12, 12)
                searchIcon.Parent = search

                local uIPadding = Instance.new("UIPadding")
                uIPadding.Name = "UIPadding"
                uIPadding.PaddingLeft = UDim.new(0, 15)
                uIPadding.Parent = search

                local searchBox = Instance.new("TextBox")
                searchBox.Name = "SearchBox"
                searchBox.CursorPosition = -1
                searchBox.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                searchBox.PlaceholderText = "Search..."
                searchBox.Text = ""
                searchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
                searchBox.TextSize = 14
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                searchBox.BackgroundTransparency = 1
                searchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                searchBox.BorderSizePixel = 0
                searchBox.Size = UDim2.fromScale(1, 1)

                local uIPadding1 = Instance.new("UIPadding")
                uIPadding1.Name = "UIPadding"
                uIPadding1.PaddingLeft = UDim.new(0, 23)
                uIPadding1.Parent = searchBox

                searchBox.Parent = search

                -- 计算下拉列表总高度的函数
                local function CalculateDropdownSize()
                    local totalHeight = 0
                    local visibleChildrenCount = 0
                    local padding = dropdownFrameUIPadding.PaddingTop.Offset + dropdownFrameUIPadding.PaddingBottom.Offset

                    for _, v in pairs(dropdownFrame:GetChildren()) do
                        if not v:IsA("UIComponent") and v.Visible then
                            totalHeight = totalHeight + v.AbsoluteSize.Y
                            visibleChildrenCount = visibleChildrenCount + 1
                        end
                    end

                    local spacing = dropdownFrameUIListLayout.Padding.Offset * (visibleChildrenCount - 1)

                    return totalHeight + spacing + padding
                end

                -- 搜索功能
                local function findOption()
                    local searchTerm = searchBox.Text:lower()

                    for _, v in pairs(OptionObjs) do
                        local optionText = v.NameLabel.Text:lower()
                        local isVisible = string.find(optionText, searchTerm) ~= nil

                        if v.Button.Visible ~= isVisible then
                            v.Button.Visible = isVisible
                        end
                    end

                    dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                end

                searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)

                -- 动画设置
                local tweensettings = {
                    duration = 0.2,
                    easingStyle = Enum.EasingStyle.Quint,
                    transparencyIn = 0.2,
                    transparencyOut = 0.5,
                    checkSizeIncrease = 12,
                    checkSizeDecrease = -13,
                    waitTime = 1
                }

                -- 切换选项选中状态的函数
                local function Toggle(optionName, State)
                    local option = OptionObjs[optionName]

                    if not option then return end

                    local checkmark = option.Checkmark
                    local optionNameLabel = option.NameLabel

                    if State then
                        if DropdownFunctions.Settings.Multi then
                            if not table.find(Selected, optionName) then
                                table.insert(Selected, optionName)
                                DropdownFunctions.Value = Selected
                            end
                        else
                            for name, opt in pairs(OptionObjs) do
                                if name ~= optionName then
                                    Tween(opt.Checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                        Size = UDim2.new(opt.Checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, opt.Checkmark.Size.Y.Scale, opt.Checkmark.Size.Y.Offset)
                                    }):Play()
                                    Tween(opt.NameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                                        TextTransparency = tweensettings.transparencyOut
                                    }):Play()
                                    opt.Checkmark.TextTransparency = 1
                                end
                            end
                            Selected = {optionName}
                            DropdownFunctions.Value = Selected[1]
                        end
                        Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                            Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                        }):Play()
                        Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                            TextTransparency = tweensettings.transparencyIn
                        }):Play()
                        checkmark.TextTransparency = 0
                    else
                        if DropdownFunctions.Settings.Multi then
                            local idx = table.find(Selected, optionName)
                            if idx then
                                table.remove(Selected, idx)
                            end
                        else
                            Selected = {}
                        end
                        Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                            Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
                        }):Play()
                        Tween(optionNameLabel, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
                            TextTransparency = tweensettings.transparencyOut
                        }):Play()
                        checkmark.TextTransparency = 1
                    end

                    if Settings.Required and #Selected == 0 and not State then
                        return
                    end

                    if #Selected > 0 then
                        dropdownName.Text = DropdownFunctions.Settings.Name .. " • " .. table.concat(Selected, ", ")
                    else
                        dropdownName.Text = DropdownFunctions.Settings.Name .. "..."
                    end
                end

                local dropped = false
                local db = false

                local function ToggleDropdown()
                    if db then return end
                    db = true
                    local defaultDropdownSize = 38
                    local isDropdownOpen = not dropped
                    local targetSize = isDropdownOpen and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, defaultDropdownSize)

                    local dropTween = Tween(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Size = targetSize
                    })
                    local iconTween = Tween(dropdownImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = isDropdownOpen and -90 or 0
                    })

                    dropTween:Play()
                    iconTween:Play()

                    if isDropdownOpen then
                        dropdownFrame.Visible = true
                        dropTween.Completed:Connect(function()
                            db = false
                        end)
                    else
                        dropTween.Completed:Connect(function()
                            dropdownFrame.Visible = false
                            db = false
                        end)
                    end

                    dropped = isDropdownOpen
                end

                interact.MouseButton1Click:Connect(ToggleDropdown)

                -- 添加选项的函数
                local function addOption(i, v)
                    local option = Instance.new("TextButton")
                    option.Name = "Option"
                    option.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
                    option.Text = ""
                    option.TextColor3 = Color3.fromRGB(0, 0, 0)
                    option.TextSize = 14
                    option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    option.BackgroundTransparency = 1
                    option.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    option.BorderSizePixel = 0
                    option.Size = UDim2.new(1, 0, 0, 30)

                    local optionUIPadding = Instance.new("UIPadding")
                    optionUIPadding.Name = "OptionUIPadding"
                    optionUIPadding.PaddingLeft = UDim.new(0, 15)
                    optionUIPadding.Parent = option

                    local optionName = Instance.new("TextLabel")
                    optionName.Name = "OptionName"
                    optionName.FontFace = Font.new("rbxassetid://12187365364")
                    optionName.Text = v
                    optionName.RichText = true
                    optionName.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionName.TextSize = 13
                    optionName.TextTransparency = 0.5
                    optionName.TextTruncate = Enum.TextTruncate.AtEnd
                    optionName.TextXAlignment = Enum.TextXAlignment.Left
                    optionName.TextYAlignment = Enum.TextYAlignment.Top
                    optionName.AnchorPoint = Vector2.new(0, 0.5)
                    optionName.AutomaticSize = Enum.AutomaticSize.XY
                    optionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    optionName.BackgroundTransparency = 1
                    optionName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    optionName.BorderSizePixel = 0
                    optionName.Position = UDim2.fromScale(1.3e-07, 0.5)
                    optionName.Parent = option

                    local optionUIListLayout = Instance.new("UIListLayout")
                    optionUIListLayout.Name = "OptionUIListLayout"
                    optionUIListLayout.Padding = UDim.new(0, 10)
                    optionUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                    optionUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    optionUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    optionUIListLayout.Parent = option

                    local checkmark = Instance.new("TextLabel")
                    checkmark.Name = "Checkmark"
                    checkmark.FontFace = Font.new("rbxassetid://12187365364")
                    checkmark.Text = "✓"
                    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                    checkmark.TextSize = 13
                    checkmark.TextTransparency = 1
                    checkmark.TextXAlignment = Enum.TextXAlignment.Left
                    checkmark.TextYAlignment = Enum.TextYAlignment.Top
                    checkmark.AnchorPoint = Vector2.new(0, 0.5)
                    checkmark.AutomaticSize = Enum.AutomaticSize.Y
                    checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    checkmark.BackgroundTransparency = 1
                    checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    checkmark.BorderSizePixel = 0
                    checkmark.LayoutOrder = -1
                    checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
                    checkmark.Size = UDim2.fromOffset(-10, 0)
                    checkmark.Parent = option

                    option.Parent = dropdownFrame

                    OptionObjs[v] = {
                        Index = i,
                        Button = option,
                        NameLabel = optionName,
                        Checkmark = checkmark
                    }

                    -- 初始化选中状态
                    local isSelected = false
                    if DropdownFunctions.Settings.Default then
                        if DropdownFunctions.Settings.Multi then
                            isSelected = table.find(DropdownFunctions.Settings.Default, v) and true or false
                        else
                            isSelected = (DropdownFunctions.Settings.Default == i) and true or false
                        end
                    end
                    Toggle(v, isSelected)

                    local option = OptionObjs[v].Button

                    option.MouseButton1Click:Connect(function()
                        local isSelected = table.find(Selected, v) and true or false
                        local newSelected = not isSelected

                        if DropdownFunctions.Settings.Required and not newSelected and #Selected <= 1 then
                            return
                        end

                        Toggle(v, newSelected)

                        task.spawn(function()
                            if DropdownFunctions.Settings.Multi then
                                local Return = {}
                                for _, opt in ipairs(Selected) do
                                    Return[opt] = true
                                end
                                if DropdownFunctions.Settings.Callback then
                                    DropdownFunctions.Settings.Callback(Return)
                                end
                            else
                                if newSelected and DropdownFunctions.Settings.Callback then
                                    DropdownFunctions.Settings.Callback(Selected[1] or nil)
                                end
                            end
                        end)
                    end)

                    if dropped then
                        dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end
                end

                if DropdownFunctions.Settings.Options then
                    for i, v in pairs(DropdownFunctions.Settings.Options) do
                        addOption(i, v)
                    end
                end

                dropdownFrame.Parent = dropdown

                -- 返回的方法表
                local selfObj = {}

                function selfObj:UpdateName(New)
                    dropdownName.Text = New
                end
                function selfObj:SetVisibility(State)
                    dropdown.Visible = State
                end
                function selfObj:UpdateSelection(newSelection)
                    if not newSelection then return end

                    for option, _ in pairs(OptionObjs) do
                        Toggle(option, false)
                    end

                    local selectedOptions = {}
                    if type(newSelection) == "number" then
                        for option, data in pairs(OptionObjs) do
                            local isSelected = data.Index == newSelection
                            Toggle(option, isSelected)
                            if isSelected then
                                table.insert(selectedOptions, option)
                            end
                        end
                    elseif type(newSelection) == "string" then
                        for option, data in pairs(OptionObjs) do
                            local isSelected = option == newSelection
                            Toggle(option, isSelected)
                            if isSelected then
                                table.insert(selectedOptions, option)
                            end
                        end
                    elseif type(newSelection) == "table" then
                        for option, _ in pairs(OptionObjs) do
                            local isSelected = table.find(newSelection, option) ~= nil
                            Toggle(option, isSelected)
                            if isSelected then
                                table.insert(selectedOptions, option)
                            end
                        end
                    end

                    if DropdownFunctions.Settings.Callback then
                        if DropdownFunctions.Settings.Multi then
                            local Return = {}
                            for _, opt in ipairs(selectedOptions) do
                                Return[opt] = true
                            end
                            DropdownFunctions.Settings.Callback(Return)
                        else
                            DropdownFunctions.Settings.Callback(selectedOptions[1] or nil)
                        end
                    end
                end
                function selfObj:InsertOptions(newOptions)
                    if not newOptions then return end
                    DropdownFunctions.Settings.Options = newOptions
                    for i, v in pairs(newOptions) do
                        addOption(i, v)
                    end
                end
                function selfObj:ClearOptions()
                    for _, optionData in pairs(OptionObjs) do
                        optionData.Button:Destroy()
                    end
                    OptionObjs = {}
                    Selected = {}

                    if dropped then
                        dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end
                end
                function selfObj:GetOptions()
                    local optionsStatus = {}
                    for option, data in pairs(OptionObjs) do
                        local isSelected = table.find(Selected, option) and true or false
                        optionsStatus[option] = isSelected
                    end
                    return optionsStatus
                end
                function selfObj:RemoveOptions(remove)
                    if not remove then return end
                    for _, optionName in ipairs(remove) do
                        local optionData = OptionObjs[optionName]
                        if optionData then
                            for i = #Selected, 1, -1 do
                                if Selected[i] == optionName then
                                    table.remove(Selected, i)
                                end
                            end
                            optionData.Button:Destroy()
                            OptionObjs[optionName] = nil
                        end
                    end
                    if dropped then
                        dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end
                end
                function selfObj:IsOption(optionName)
                    if not optionName then return end
                    return OptionObjs[optionName] ~= nil
                end

                -- 注册到 ConfigObjects
                ConfigObjects[dropText] = {
                    Type = "Dropdown",
                    Value = Selected,  -- 根据多选情况存储
                    Set = function(val)
                        selfObj:UpdateSelection(val)
                    end,
                    Refresh = function(newOpts)
                        selfObj:ClearOptions()
                        selfObj:InsertOptions(newOpts)
                    end
                }

                return selfObj
            end
            -- ========== Dropdown 移植结束 ==========

            -- Keybind
            child.Keybind = function(_, keyText, default, callback)
                local Key = default or Enum.KeyCode.M
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")
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
                local KeyLabel = Instance.new("TextLabel")
                KeyLabel.Text = Key.Name
                KeyLabel.Size = UDim2.new(0, 80, 0, 24)
                KeyLabel.Position = UDim2.new(1, -90, 0.5, -12)
                KeyLabel.Font = Enum.Font.GothamBold
                KeyLabel.TextSize = 13
                KeyLabel.Parent = Btn
                Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 5)
                AddToRegistry(KeyLabel, "BackgroundColor3", "Main")
                AddToRegistry(KeyLabel, "TextColor3", "Accent")

                Btn.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    KeyLabel.Text = "..."
                    local input = UserInputService.InputBegan:Wait()
                    if input.KeyCode.Name ~= "Unknown" then
                        Key = input.KeyCode
                        KeyLabel.Text = Key.Name
                        ConfigObjects[keyText] = {Type = "Keybind", Value = Key.Name}
                        callback(Key)
                        Window:Notification("Keybind: "..Key.Name)
                    else
                        KeyLabel.Text = Key.Name
                    end
                end)
                ConfigObjects[keyText] = {Type = "Keybind", Value = Key.Name, Set = function(val) Key = Enum.KeyCode[val] or Key; KeyLabel.Text = Key.Name; callback(Key) end}
            end

            -- Value (文本输入)
            child.Value = function(_, valText, default, callback)
                local ValFrame = Instance.new("Frame")
                ValFrame.Size = UDim2.new(1,0,0,35)
                ValFrame.Parent = contentContainer
                Instance.new("UICorner", ValFrame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(ValFrame, "BackgroundColor3", "Top")

                local NameLbl = Instance.new("TextLabel")
                NameLbl.Text = valText
                NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
                NameLbl.Position = UDim2.new(0, 10, 0, 0)
                NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                NameLbl.Font = Enum.Font.Gotham
                NameLbl.TextSize = 14
                NameLbl.BackgroundTransparency = 1
                NameLbl.Parent = ValFrame
                AddToRegistry(NameLbl, "TextColor3", "Text")

                local ValBox = Instance.new("TextBox")
                ValBox.Text = tostring(default)
                ValBox.Size = UDim2.new(0.3, 0, 0, 26)
                ValBox.Position = UDim2.new(0.7, -10, 0.5, -13)
                ValBox.Font = Enum.Font.GothamBold
                ValBox.TextSize = 13
                ValBox.TextXAlignment = Enum.TextXAlignment.Center
                ValBox.Parent = ValFrame
                Instance.new("UICorner", ValBox).CornerRadius = UDim.new(0, 5)
                AddToRegistry(ValBox, "BackgroundColor3", "Main")
                AddToRegistry(ValBox, "TextColor3", "Accent")

                ValBox.FocusLost:Connect(function()
                    PlaySound(Sounds.Click)
                    ConfigObjects[valText] = {Type = "Value", Value = ValBox.Text}
                    if callback then callback(ValBox.Text) end
                    Window:Notification(valText..": "..ValBox.Text)
                end)

                ConfigObjects[valText] = {Type = "Value", Value = default, Set = function(val) ValBox.Text = val end}
            end

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