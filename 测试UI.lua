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
    Bar = "rbxassetid://18772615246",  -- 滑块条背景
    Head = "rbxassetid://18772834246"  -- 滑块头
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
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.new(1, -30, 1, 0)
                TextLabel.Position = UDim2.new(0, 10, 0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Font = Enum.Font.Gotham
                TextLabel.Text = btnText
                TextLabel.TextSize = 14
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.Parent = Btn
                AddToRegistry(TextLabel, "TextColor3", "Text")

                local Icon = Instance.new("ImageLabel")
                Icon.Size = UDim2.new(0, 15, 0, 15)
                Icon.Position = UDim2.new(1, -20, 0.5, -7.5)
                Icon.BackgroundTransparency = 1
                Icon.Image = "rbxassetid://10709791437"
                Icon.ImageTransparency = 0.5
                Icon.Parent = Btn
                AddToRegistry(Icon, "ImageColor3", "Text")

                local function onHover()
                    Tween(Icon, {ImageTransparency = 0}, 0.2)
                end
                local function onLeave()
                    Tween(Icon, {ImageTransparency = 0.5}, 0.2)
                end

                Btn.MouseEnter:Connect(onHover)
                Btn.MouseLeave:Connect(onLeave)

                Btn.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    Tween(Btn, {Size = UDim2.new(0.95, 0, 0, 32)}, 0.1)
                    task.wait(0.1)
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                    callback()
                end)

                local self = {}
                function self.UpdateText(newText)
                    TextLabel.Text = newText
                end
                function self.SetVisible(state)
                    Btn.Visible = state
                end
                return self
            end

            -- Toggle (maclib 风格)
            child.Toggle = function(_, toggleText, default, callback)
                local Enabled = default or false

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

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

                local Switch = Instance.new("ImageLabel")
                Switch.Size = UDim2.new(0, 40, 0, 20)
                Switch.Position = UDim2.new(1, -50, 0.5, -10)
                Switch.BackgroundTransparency = 1
                Switch.Image = ToggleAssets.Bg
                Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
                Switch.Parent = Btn

                local Dot = Instance.new("ImageLabel")
                Dot.Size = UDim2.new(0, 16, 0, 16)
                Dot.BackgroundTransparency = 1
                Dot.Image = ToggleAssets.Head
                Dot.ImageColor3 = Color3.new(1, 1, 1)
                Dot.AnchorPoint = Vector2.new(0.5, 0.5)
                Dot.Parent = Switch
                Dot.Position = Enabled and UDim2.new(0, 32, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)

                local function Update()
                    if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end
                    local targetColor = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
                    Tween(Switch, {ImageColor3 = targetColor}, 0.2)
                    local targetPos = Enabled and UDim2.new(0, 32, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
                    Tween(Dot, {Position = targetPos}, 0.2)
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
                        Dot.Position = Enabled and UDim2.new(0, 32, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
                        callback(Enabled)
                    end
                }
            end

            -- Slider (完整移植 maclib 实现，采用上下布局)
            child.Slider = function(_, sliderText, min, max, default, callback)
                -- 将参数转换为 maclib 的 Settings 表
                local Settings = {
                    Name = sliderText,
                    Minimum = min,
                    Maximum = max,
                    Default = default,
                    Callback = callback,
                    DisplayMethod = "Value",      -- 可改为 "Percent" 等，这里保持原样
                    Precision = 2,                -- 保留两位小数
                    Prefix = "",
                    Suffix = "",
                    onInputComplete = nil
                }

                -- 创建主容器（背景色 Top，高度 60，与测试.lua 一致）
                local slider = Instance.new("Frame")
                slider.Size = UDim2.new(1, 0, 0, 60)
                slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                slider.BackgroundTransparency = 0.98  -- 半透明，与 maclib 一致
                slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                slider.BorderSizePixel = 0
                slider.Parent = contentContainer
                Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 6)
                AddToRegistry(slider, "BackgroundColor3", "Top")  -- 注册主题色

                -- 顶部区域：标题和数值框
                local topFrame = Instance.new("Frame")
                topFrame.Size = UDim2.new(1, 0, 0, 25)
                topFrame.BackgroundTransparency = 1
                topFrame.Parent = slider

                -- 标题标签（左对齐）
                local sliderName = Instance.new("TextLabel")
                sliderName.Name = "SliderName"
                sliderName.FontFace = Font.new(assets.interFont or "rbxasset://fonts/families/GothamSSm.json")  -- 使用原 maclib 字体
                sliderName.Text = Settings.Name
                sliderName.RichText = true
                sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderName.TextSize = 13
                sliderName.TextTransparency = 0.5
                sliderName.TextTruncate = Enum.TextTruncate.AtEnd
                sliderName.TextXAlignment = Enum.TextXAlignment.Left
                sliderName.TextYAlignment = Enum.TextYAlignment.Top
                sliderName.AnchorPoint = Vector2.new(0, 0.5)
                sliderName.AutomaticSize = Enum.AutomaticSize.XY
                sliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderName.BackgroundTransparency = 1
                sliderName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderName.BorderSizePixel = 0
                sliderName.Position = UDim2.new(0, 10, 0.5, 0)
                sliderName.Parent = topFrame
                AddToRegistry(sliderName, "TextColor3", "Text")

                -- 数值框 (TextBox，完全照搬 maclib 样式)
                local sliderValue = Instance.new("TextBox")
                sliderValue.Name = "SliderValue"
                sliderValue.FontFace = Font.new(assets.interFont or "rbxasset://fonts/families/GothamSSm.json")
                sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.TextSize = 12
                sliderValue.TextTransparency = 0.1
                sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.BackgroundTransparency = 0.95
                sliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderValue.BorderSizePixel = 0
                sliderValue.ClipsDescendants = true
                sliderValue.Size = UDim2.fromOffset(60, 25)  -- 固定宽度
                sliderValue.AnchorPoint = Vector2.new(1, 0.5)
                sliderValue.Position = UDim2.new(1, -15, 0.5, 0)
                sliderValue.Parent = topFrame

                -- 数值框装饰
                local sliderValueUICorner = Instance.new("UICorner")
                sliderValueUICorner.Name = "SliderValueUICorner"
                sliderValueUICorner.CornerRadius = UDim.new(0, 4)
                sliderValueUICorner.Parent = sliderValue

                local sliderValueUIStroke = Instance.new("UIStroke")
                sliderValueUIStroke.Name = "SliderValueUIStroke"
                sliderValueUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                sliderValueUIStroke.Color = Color3.fromRGB(255, 255, 255)
                sliderValueUIStroke.Transparency = 0.9
                sliderValueUIStroke.Parent = sliderValue

                local sliderValueUIPadding = Instance.new("UIPadding")
                sliderValueUIPadding.Name = "SliderValueUIPadding"
                sliderValueUIPadding.PaddingLeft = UDim.new(0, 5)
                sliderValueUIPadding.PaddingRight = UDim.new(0, 5)
                sliderValueUIPadding.Parent = sliderValue

                -- 底部区域：滑块条
                local bottomFrame = Instance.new("Frame")
                bottomFrame.Size = UDim2.new(1, 0, 0, 25)
                bottomFrame.Position = UDim2.new(0, 0, 1, -25)
                bottomFrame.BackgroundTransparency = 1
                bottomFrame.Parent = slider

                -- 滑块条背景（图片）
                local sliderBar = Instance.new("ImageLabel")
                sliderBar.Name = "SliderBar"
                sliderBar.Image = SliderAssets.Bar
                sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                sliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderBar.BackgroundTransparency = 1
                sliderBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderBar.BorderSizePixel = 0
                sliderBar.Size = UDim2.new(1, -20, 0, 3)
                sliderBar.Position = UDim2.new(0, 10, 0.5, 0)
                sliderBar.AnchorPoint = Vector2.new(0, 0.5)
                sliderBar.Parent = bottomFrame

                -- 滑块头（可拖动按钮）
                local sliderHead = Instance.new("ImageButton")
                sliderHead.Name = "SliderHead"
                sliderHead.Image = SliderAssets.Head
                sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderHead.BackgroundTransparency = 1
                sliderHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderHead.BorderSizePixel = 0
                sliderHead.Position = UDim2.fromScale(1, 0.5)  -- 初始位置，稍后更新
                sliderHead.Size = UDim2.fromOffset(12, 12)
                sliderHead.Parent = sliderBar

                -- 显示方法表（完全复制 maclib）
                local DisplayMethods = {
                    Hundredths = function(sliderValue)
                        return string.format("%.2f", sliderValue)
                    end,
                    Tenths = function(sliderValue)
                        return string.format("%.1f", sliderValue)
                    end,
                    Round = function(sliderValue, precision)
                        if precision then
                            return string.format("%." .. precision .. "f", sliderValue)
                        else
                            return tostring(math.round(sliderValue))
                        end
                    end,
                    Degrees = function(sliderValue, precision)
                        local formattedValue = precision and string.format("%." .. precision .. "f", sliderValue) or tostring(sliderValue)
                        return formattedValue .. "°"
                    end,
                    Percent = function(sliderValue, precision)
                        local percentage = (sliderValue - Settings.Minimum) / (Settings.Maximum - Settings.Minimum) * 100
                        return precision and string.format("%." .. precision .. "f", percentage) .. "%" or tostring(math.round(percentage)) .. "%"
                    end,
                    Value = function(sliderValue, precision)
                        return precision and string.format("%." .. precision .. "f", sliderValue) or tostring(sliderValue)
                    end
                }

                local ValueDisplayMethod = DisplayMethods[Settings.DisplayMethod] or DisplayMethods.Value
                local finalValue

                -- 设置值函数（核心逻辑）
                local function SetValue(val, ignorecallback)
                    local posXScale
                    if typeof(val) == "Instance" then
                        local input = val
                        posXScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    else
                        local value = val
                        posXScale = (value - Settings.Minimum) / (Settings.Maximum - Settings.Minimum)
                    end

                    local pos = UDim2.new(posXScale, 0, 0.5, 0)
                    sliderHead.Position = pos

                    finalValue = posXScale * (Settings.Maximum - Settings.Minimum) + Settings.Minimum

                    sliderValue.Text = (Settings.Prefix or "") .. ValueDisplayMethod(finalValue, Settings.Precision) .. (Settings.Suffix or "")

                    if not ignorecallback then
                        task.spawn(function()
                            if Settings.Callback then
                                Settings.Callback(finalValue)
                            end
                        end)
                    end

                    -- 更新配置对象
                    if ConfigObjects[sliderText] then
                        ConfigObjects[sliderText].Value = finalValue
                    end
                end

                -- 初始化
                SetValue(Settings.Default, true)

                -- 拖动逻辑
                local dragging = false

                sliderHead.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        PlaySound(Sounds.Slide)
                        SetValue(input)
                    end
                end)

                sliderHead.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        if Settings.onInputComplete then
                            Settings.onInputComplete(finalValue)
                        end
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        SetValue(input)
                    end
                end)

                -- 文本框输入处理（支持百分比等）
                sliderValue.FocusLost:Connect(function(enterPressed)
                    local inputText = sliderValue.Text
                    local value, isPercent = inputText:match("^(%-?%d+%.?%d*)(%%?)$")

                    if value then
                        value = tonumber(value)
                        isPercent = isPercent == "%"

                        if isPercent then
                            value = Settings.Minimum + (value / 100) * (Settings.Maximum - Settings.Minimum)
                        end

                        local newValue = math.clamp(value, Settings.Minimum, Settings.Maximum)
                        SetValue(newValue)
                    else
                        sliderValue.Text = ValueDisplayMethod(finalValue, Settings.Precision)
                    end

                    if Settings.onInputComplete then
                        Settings.onInputComplete(finalValue)
                    end
                end)

                -- 注册配置对象
                ConfigObjects[sliderText] = {
                    Type = "Slider",
                    Value = finalValue,
                    Set = function(val)
                        SetValue(val, true)
                    end
                }

                -- 返回控制方法（可选）
                local self = {}
                function self.UpdateValue(newVal)
                    SetValue(newVal, true)
                end
                function self.GetValue()
                    return finalValue
                end
                function self.SetVisible(state)
                    slider.Visible = state
                end
                return self
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

            -- Dropdown (原版样式)
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
                Icon.Image = "rbxassetid://6031091004"
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