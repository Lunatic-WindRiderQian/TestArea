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

-- 从 maclib.lua 中提取的资源 ID
local Assets = {
	interFont = "rbxassetid://12187365364",
	toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008",
	buttonImage = "rbxassetid://10709791437",
	dropdown = "rbxassetid://18865373378",
	sliderbar = "rbxassetid://18772615246",
	sliderhead = "rbxassetid://18772834246",
	searchIcon = "rbxassetid://86737463322606",
	grid = "rbxassetid://121484455191370",
	colorWheel = "rbxassetid://2849458409",
	colorTarget = "rbxassetid://73265255323268",
	globe = "rbxassetid://108952102602834",
	transform = "rbxassetid://90336395745819",
}

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

            -- ==================== 组件替换开始 ====================
            -- 使用 maclib.lua 的实现，但保留测试UI的背景色（通过 AddToRegistry 注册 Top 色）

            -- Button
            child.Button = function(_, btnText, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.Text = ""
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

                -- 文字标签
                local Label = Instance.new("TextLabel")
                Label.Text = btnText
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 14
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Btn
                AddToRegistry(Label, "TextColor3", "Text")

                -- 箭头图标 (maclib 风格)
                local Icon = Instance.new("ImageLabel")
                Icon.Image = Assets.buttonImage
                Icon.ImageTransparency = 0.5
                Icon.Size = UDim2.fromOffset(15, 15)
                Icon.Position = UDim2.new(1, -30, 0.5, -7.5)
                Icon.BackgroundTransparency = 1
                Icon.Parent = Btn
                AddToRegistry(Icon, "ImageColor3", "Text")

                -- 悬停效果
                local function ChangeState(state)
                    local targetTrans = (state == "Hover") and 0.3 or 0.5
                    Tween(Label, {TextTransparency = targetTrans}, 0.2)
                    Tween(Icon, {ImageTransparency = targetTrans}, 0.2)
                end

                Btn.MouseEnter:Connect(function() ChangeState("Hover") end)
                Btn.MouseLeave:Connect(function() ChangeState("Idle") end)

                Btn.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    Tween(Btn, {Size = UDim2.new(0.95, 0, 0, 32)}, 0.1)
                    task.wait(0.1)
                    Tween(Btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                    if callback then callback() end
                end)
            end

            -- Toggle
            child.Toggle = function(_, toggleText, default, callback)
                local Enabled = default or false
                local Btn = Instance.new("Frame")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.BackgroundTransparency = 1
                Btn.Parent = contentContainer

                -- 背景框 (Top色)
                local Background = Instance.new("Frame")
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.BackgroundTransparency = 0
                Background.Parent = Btn
                Instance.new("UICorner", Background).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Background, "BackgroundColor3", "Top")

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

                -- 开关 (maclib 图片)
                local Switch = Instance.new("ImageButton")
                Switch.Image = Assets.toggleBackground
                Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(87, 86, 86)
                Switch.AutoButtonColor = false
                Switch.BackgroundTransparency = 1
                Switch.Size = UDim2.fromOffset(41, 21)
                Switch.Position = UDim2.new(1, -50, 0.5, -10)
                Switch.Parent = Btn

                local Dot = Instance.new("ImageLabel")
                Dot.Image = Assets.togglerHead
                Dot.ImageColor3 = Color3.new(1, 1, 1)
                Dot.BackgroundTransparency = 1
                Dot.Size = UDim2.fromOffset(15, 15)
                Dot.Parent = Switch
                Dot.Position = Enabled and UDim2.new(1, -18, 0.5, -7.5) or UDim2.new(0, 2, 0.5, -7.5)

                -- 状态更新
                local function UpdateState(newState)
                    Enabled = newState
                    Tween(Switch, {ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(87,86,86)}, 0.15)
                    Tween(Dot, {Position = Enabled and UDim2.new(1, -18, 0.5, -7.5) or UDim2.new(0, 2, 0.5, -7.5)}, 0.15)
                    ConfigObjects[toggleText].Value = Enabled
                    if callback then callback(Enabled) end
                    if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end
                end

                Switch.MouseButton1Click:Connect(function()
                    UpdateState(not Enabled)
                end)

                ConfigObjects[toggleText] = {
                    Type = "Toggle",
                    Value = Enabled,
                    Set = function(val) UpdateState(val) end
                }
            end

            -- Slider
            child.Slider = function(_, sliderText, min, max, default, callback)
                local Val = default or min
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 60)  -- 高度增加以容纳输入框
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                -- 文本标签
                local Lbl = Instance.new("TextLabel")
                Lbl.Text = sliderText
                Lbl.Size = UDim2.new(1, -20, 0, 20)
                Lbl.Position = UDim2.new(0, 10, 0, 5)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 14
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Frame
                AddToRegistry(Lbl, "TextColor3", "Text")

                -- 数值输入框 (maclib 风格)
                local NumBox = Instance.new("TextBox")
                NumBox.Size = UDim2.fromOffset(50, 25)
                NumBox.Position = UDim2.new(1, -60, 0, 5)
                NumBox.Text = tostring(Val)
                NumBox.Font = Enum.Font.GothamBold
                NumBox.TextSize = 13
                NumBox.TextXAlignment = Enum.TextXAlignment.Center
                NumBox.Parent = Frame
                Instance.new("UICorner", NumBox).CornerRadius = UDim.new(0, 4)
                AddToRegistry(NumBox, "BackgroundColor3", "Main")
                AddToRegistry(NumBox, "TextColor3", "Accent")

                -- 滑块条 (maclib 图片)
                local Bar = Instance.new("ImageLabel")
                Bar.Image = Assets.sliderbar
                Bar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                Bar.Size = UDim2.new(1, -80, 0, 3)
                Bar.Position = UDim2.new(0, 10, 0, 40)
                Bar.BackgroundTransparency = 1
                Bar.Parent = Frame

                -- 滑块头
                local Head = Instance.new("ImageButton")
                Head.Image = Assets.sliderhead
                Head.Size = UDim2.fromOffset(12, 12)
                Head.BackgroundTransparency = 1
                Head.Parent = Bar
                Head.Position = UDim2.new((Val-min)/(max-min), 0, 0.5, 0)

                -- 更新滑块位置和数值
                local function UpdateValueFromPos(input)
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    local newVal = min + (max - min) * pos
                    newVal = math.floor(newVal)  -- 取整
                    Val = newVal
                    Head.Position = UDim2.new(pos, 0, 0.5, 0)
                    NumBox.Text = tostring(Val)
                    ConfigObjects[sliderText].Value = Val
                    if callback then callback(Val) end
                end

                local sliding = false
                Head.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        PlaySound(Sounds.Slide)
                        UpdateValueFromPos(i)
                    end
                end)
                Head.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateValueFromPos(i)
                    end
                end)

                -- 输入框手动输入
                NumBox.FocusLost:Connect(function()
                    local newVal = tonumber(NumBox.Text)
                    if newVal then
                        Val = math.clamp(newVal, min, max)
                    end
                    local pos = (Val - min) / (max - min)
                    Head.Position = UDim2.new(pos, 0, 0.5, 0)
                    NumBox.Text = tostring(Val)
                    ConfigObjects[sliderText].Value = Val
                    if callback then callback(Val) end
                end)

                ConfigObjects[sliderText] = {
                    Type = "Slider",
                    Value = Val,
                    Set = function(val)
                        Val = val
                        local pos = (Val - min) / (max - min)
                        Head.Position = UDim2.new(pos, 0, 0.5, 0)
                        NumBox.Text = tostring(Val)
                    end
                }
            end

            -- Dropdown (简化版，单选，带搜索)
            child.Dropdown = function(_, dropText, options, callback)
                local Dropped = false
                local Selected = options[1] or ""
                local OptionObjs = {}

                -- 主按钮 (显示当前选择)
                local MainBtn = Instance.new("TextButton")
                MainBtn.Size = UDim2.new(1, 0, 0, 35)
                MainBtn.Text = ""
                MainBtn.Parent = contentContainer
                Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(MainBtn, "BackgroundColor3", "Top")

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = dropText .. ": " .. Selected
                Lbl.Size = UDim2.new(1, -30, 1, 0)
                Lbl.Position = UDim2.new(0, 10, 0, 0)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 14
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = MainBtn
                AddToRegistry(Lbl, "TextColor3", "Text")

                local Icon = Instance.new("ImageLabel")
                Icon.Image = Assets.dropdown
                Icon.ImageTransparency = 0.5
                Icon.Size = UDim2.fromOffset(14, 14)
                Icon.Position = UDim2.new(1, -30, 0.5, -7)
                Icon.BackgroundTransparency = 1
                Icon.Parent = MainBtn
                AddToRegistry(Icon, "ImageColor3", "Text")

                -- 下拉容器
                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1, 0, 0, 0)
                Container.Visible = false
                Container.ClipsDescendants = true
                Container.Parent = contentContainer
                Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Container, "BackgroundColor3", "Top")

                -- 搜索框 (可选，为简洁默认不启用，但保留结构)
                local SearchBox = Instance.new("TextBox")
                SearchBox.Size = UDim2.new(1, -20, 0, 30)
                SearchBox.Position = UDim2.new(0, 10, 0, 5)
                SearchBox.Visible = false  -- 设为 false 隐藏搜索
                SearchBox.PlaceholderText = "Search..."
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.TextSize = 13
                SearchBox.Parent = Container
                Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)
                AddToRegistry(SearchBox, "BackgroundColor3", "Main")
                AddToRegistry(SearchBox, "TextColor3", "Text")

                -- 选项列表布局
                local List = Instance.new("UIListLayout")
                List.Padding = UDim.new(0, 2)
                List.SortOrder = Enum.SortOrder.LayoutOrder
                List.Parent = Container

                -- 创建选项
                local function CreateOptions(opts)
                    for _, opt in ipairs(opts) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, -20, 0, 30)
                        OptBtn.Position = UDim2.new(0, 10, 0, 0)
                        OptBtn.Text = opt
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 13
                        OptBtn.BackgroundTransparency = 1
                        OptBtn.Parent = Container
                        AddToRegistry(OptBtn, "TextColor3", "Text")

                        -- 选中标记 (勾)
                        local Check = Instance.new("TextLabel")
                        Check.Text = "✓"
                        Check.TextTransparency = (opt == Selected) and 0 or 1
                        Check.Size = UDim2.fromOffset(20, 20)
                        Check.Position = UDim2.new(0, 5, 0.5, -10)
                        Check.BackgroundTransparency = 1
                        Check.Font = Enum.Font.GothamBold
                        Check.TextSize = 14
                        Check.Parent = OptBtn
                        AddToRegistry(Check, "TextColor3", "Accent")

                        OptionObjs[opt] = {Button = OptBtn, Check = Check}

                        OptBtn.MouseButton1Click:Connect(function()
                            -- 更新选中状态
                            for _, obj in pairs(OptionObjs) do
                                obj.Check.TextTransparency = 1
                            end
                            Check.TextTransparency = 0
                            Selected = opt
                            Lbl.Text = dropText .. ": " .. opt
                            -- 折叠
                            Dropped = false
                            Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2)
                            Tween(Icon, {Rotation = 0}, 0.2)
                            task.wait(0.2)
                            Container.Visible = false
                            ConfigObjects[dropText].Value = opt
                            if callback then callback(opt) end
                            PlaySound(Sounds.Click)
                        end)
                    end
                end
                CreateOptions(options)

                -- 点击主按钮展开/折叠
                MainBtn.MouseButton1Click:Connect(function()
                    Dropped = not Dropped
                    PlaySound(Sounds.Click)
                    if Dropped then
                        Container.Visible = true
                        local targetHeight = #options * 32 + (SearchBox.Visible and 35 or 0) + 10
                        Tween(Container, {Size = UDim2.new(1,0,0,targetHeight)}, 0.3)
                        Tween(Icon, {Rotation = 180}, 0.3)
                    else
                        Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2)
                        Tween(Icon, {Rotation = 0}, 0.2)
                        task.wait(0.2)
                        Container.Visible = false
                    end
                end)

                ConfigObjects[dropText] = {
                    Type = "Dropdown",
                    Value = Selected,
                    Set = function(val)
                        for _, obj in pairs(OptionObjs) do
                            obj.Check.TextTransparency = (obj.Button.Text == val) and 0 or 1
                        end
                        Selected = val
                        Lbl.Text = dropText .. ": " .. val
                    end,
                    Refresh = function(newOpts)
                        -- 清空并重新创建选项
                        for _, obj in pairs(OptionObjs) do
                            obj.Button:Destroy()
                        end
                        OptionObjs = {}
                        CreateOptions(newOpts)
                    end
                }

                return {Refresh = function(newOpts) ConfigObjects[dropText].Refresh(newOpts) end}
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
                KeyLabel.Size = UDim2.fromOffset(80, 24)
                KeyLabel.Position = UDim2.new(1, -90, 0.5, -12)
                KeyLabel.Font = Enum.Font.GothamBold
                KeyLabel.TextSize = 13
                KeyLabel.Parent = Btn
                Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 5)
                AddToRegistry(KeyLabel, "BackgroundColor3", "Main")
                AddToRegistry(KeyLabel, "TextColor3", "Accent")

                local binding = false
                Btn.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    KeyLabel.Text = "..."
                    binding = true
                    local con
                    con = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Key = input.KeyCode
                            KeyLabel.Text = Key.Name
                            binding = false
                            con:Disconnect()
                            ConfigObjects[keyText].Value = Key.Name
                            if callback then callback(Key) end
                        end
                    end)
                end)

                -- 点击外部取消绑定
                UserInputService.InputBegan:Connect(function(input)
                    if binding and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        binding = false
                        KeyLabel.Text = Key.Name
                    end
                end)

                ConfigObjects[keyText] = {
                    Type = "Keybind",
                    Value = Key.Name,
                    Set = function(val)
                        Key = Enum.KeyCode[val] or Key
                        KeyLabel.Text = Key.Name
                    end
                }
            end

            -- Textbox
            child.Textbox = function(_, boxText, placeholder, callback)
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 60)
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                local Lbl = Instance.new("TextLabel")
                Lbl.Text = boxText
                Lbl.Size = UDim2.new(1, 0, 0, 20)
                Lbl.Position = UDim2.new(0, 10, 0, 5)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.Gotham
                Lbl.TextSize = 14
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Frame
                AddToRegistry(Lbl, "TextColor3", "Text")

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1, -20, 0, 25)
                Box.Position = UDim2.new(0, 10, 0, 28)
                Box.Text = ""
                Box.PlaceholderText = placeholder
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 13
                Box.Parent = Frame
                Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
                AddToRegistry(Box, "BackgroundColor3", "Main")
                AddToRegistry(Box, "TextColor3", "Text")

                Box.FocusLost:Connect(function()
                    ConfigObjects[boxText].Value = Box.Text
                    if callback then callback(Box.Text) end
                end)

                ConfigObjects[boxText] = {
                    Type = "Textbox",
                    Value = "",
                    Set = function(val) Box.Text = val end
                }
            end

            -- Value (与 Textbox 相同)
            child.Value = child.Textbox

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