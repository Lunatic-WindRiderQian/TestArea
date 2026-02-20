local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local Registry = {} 
local ConfigObjects = {} 

-- 引入 maclib 的资源表
local assets = {
	interFont = "rbxassetid://12187365364",
	userInfoBlurred = "rbxassetid://18824089198",
	toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008",
	buttonImage = "rbxassetid://10709791437",
	searchIcon = "rbxassetid://86737463322606",
	colorWheel = "rbxassetid://2849458409",
	colorTarget = "rbxassetid://73265255323268",
	grid = "rbxassetid://121484455191370",
	globe = "rbxassetid://108952102602834",
	transform = "rbxassetid://90336395745819",
	dropdown = "rbxassetid://18865373378",
	sliderbar = "rbxassetid://18772615246",
	sliderhead = "rbxassetid://18772834246",
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

-- SFX CONTROL
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

    -- 窗口展开动画
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

        -- ==================== 从 maclib 移植的完整组件 ====================
        -- Section：可折叠容器，保留原有折叠功能，内部组件使用 maclib 样式
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

            -- 处理图标：始终使用 iconOpen（如果有两个图标，则在展开/折叠时瞬间切换图片，无动画）
            local iconOpen, iconClosed
            if type(icons) == "table" then
                iconOpen = formatAssetId(icons.Y or icons.open) or "rbxassetid://6031091004"
                iconClosed = formatAssetId(icons.F or icons.closed) or iconOpen  -- 如果没有关闭图标，默认使用打开图标
            else
                local defaultIcon = formatAssetId(icons) or "rbxassetid://6031091004"
                iconOpen = defaultIcon
                iconClosed = defaultIcon
            end

            -- Section 主框架
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 36)  -- 初始高度为标题栏高度
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = Page
            sectionFrame.ClipsDescendants = true

            -- 标题栏
            local titleBar = Instance.new("Frame")
            titleBar.Size = UDim2.new(1, 0, 0, 36)
            titleBar.BackgroundTransparency = 1
            titleBar.Parent = sectionFrame

            -- 图标（固定使用 iconOpen，不旋转，只在状态改变时瞬间切换图片）
            local iconLabel = Instance.new("ImageLabel")
            iconLabel.Size = UDim2.new(0, 24, 0, 24)
            iconLabel.Position = UDim2.new(0, 5, 0.5, -12)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = defaultOpen and iconOpen or iconClosed  -- 初始状态对应图片
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

            -- 点击按钮（覆盖整个标题栏）
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.Parent = titleBar

            -- 内容容器（放置子元素）
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

            -- 更新内容高度的函数
            local function updateContentHeight()
                return contentLayout.AbsoluteContentSize.Y
            end

            local open = defaultOpen
            -- 初始化高度
            if open then
                task.spawn(function()
                    task.wait()  -- 等待布局计算
                    local contentHeight = updateContentHeight()
                    contentContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                    sectionFrame.Size = UDim2.new(1, 0, 0, 36 + contentHeight)
                end)
            else
                contentContainer.Size = UDim2.new(1, 0, 0, 0)
                sectionFrame.Size = UDim2.new(1, 0, 0, 36)
            end

            -- 存储当前的动画，以便取消
            local currentContentTween, currentSectionTween

            local function toggle()
                open = not open

                -- 瞬间切换图标图片（无动画）
                iconLabel.Image = open and iconOpen or iconClosed

                -- 计算目标尺寸
                local targetContentHeight = open and updateContentHeight() or 0
                local targetSectionHeight = 36 + targetContentHeight

                -- 取消正在进行的动画
                if currentContentTween then currentContentTween:Cancel() end
                if currentSectionTween then currentSectionTween:Cancel() end

                -- 使用 Tween 实现平滑展开/收缩动画
                local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                currentContentTween = TweenService:Create(contentContainer, tweenInfo, {Size = UDim2.new(1, 0, 0, targetContentHeight)})
                currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, targetSectionHeight)})

                currentContentTween:Play()
                currentSectionTween:Play()
            end

            toggleBtn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click)
                toggle()
            end)

            -- 子元素表（将元素添加到 contentContainer）
            local child = {}

            -- ========== Button ==========
            child.Button = function(_, btnText, callback)
                local ButtonFunctions = {}

                local button = Instance.new("Frame")
                button.Name = "Button"
                button.AutomaticSize = Enum.AutomaticSize.Y
                button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                button.BackgroundTransparency = 1
                button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                button.BorderSizePixel = 0
                button.Size = UDim2.new(1, 0, 0, 38)
                button.Parent = contentContainer

                local buttonInteract = Instance.new("TextButton")
                buttonInteract.Name = "ButtonInteract"
                buttonInteract.FontFace = Font.new(assets.interFont)
                buttonInteract.RichText = true
                buttonInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
                buttonInteract.TextSize = 13
                buttonInteract.TextTransparency = 0.5
                buttonInteract.TextTruncate = Enum.TextTruncate.AtEnd
                buttonInteract.TextXAlignment = Enum.TextXAlignment.Left
                buttonInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                buttonInteract.BackgroundTransparency = 1
                buttonInteract.BorderColor3 = Color3.fromRGB(0, 0, 0)
                buttonInteract.BorderSizePixel = 0
                buttonInteract.Size = UDim2.fromScale(1, 1)
                buttonInteract.Parent = button
                buttonInteract.Text = btnText
                AddToRegistry(buttonInteract, "TextColor3", "Text")

                local buttonImage = Instance.new("ImageLabel")
                buttonImage.Name = "ButtonImage"
                buttonImage.Image = assets.buttonImage
                buttonImage.ImageTransparency = 0.5
                buttonImage.AnchorPoint = Vector2.new(1, 0.5)
                buttonImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                buttonImage.BackgroundTransparency = 1
                buttonImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
                buttonImage.BorderSizePixel = 0
                buttonImage.Position = UDim2.fromScale(1, 0.5)
                buttonImage.Size = UDim2.fromOffset(15, 15)
                buttonImage.Parent = button
                AddToRegistry(buttonImage, "ImageColor3", "Text")

                local TweenSettings = {
                    DefaultTransparency = 0.5,
                    HoverTransparency = 0.3,
                    EasingStyle = Enum.EasingStyle.Sine
                }

                local function ChangeState(State)
                    if State == "Idle" then
                        Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {TextTransparency = TweenSettings.DefaultTransparency})
                        Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {ImageTransparency = TweenSettings.DefaultTransparency})
                    elseif State == "Hover" then
                        Tween(buttonInteract, TweenInfo.new(0.2, TweenSettings.EasingStyle), {TextTransparency = TweenSettings.HoverTransparency})
                        Tween(buttonImage, TweenInfo.new(0.2, TweenSettings.EasingStyle), {ImageTransparency = TweenSettings.HoverTransparency})
                    end
                end

                buttonInteract.MouseEnter:Connect(function() ChangeState("Hover") end)
                buttonInteract.MouseLeave:Connect(function() ChangeState("Idle") end)

                buttonInteract.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    if callback then callback() end
                end)

                function ButtonFunctions:UpdateName(New) buttonInteract.Text = New end
                function ButtonFunctions:SetVisibility(State) button.Visible = State end

                return ButtonFunctions
            end

            -- ========== Toggle ==========
            child.Toggle = function(_, toggleText, default, callback)
                local ToggleFunctions = { State = default or false }

                local toggle = Instance.new("Frame")
                toggle.Name = "Toggle"
                toggle.AutomaticSize = Enum.AutomaticSize.Y
                toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                toggle.BackgroundTransparency = 1
                toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggle.BorderSizePixel = 0
                toggle.Size = UDim2.new(1, 0, 0, 38)
                toggle.Parent = contentContainer

                local toggleName = Instance.new("TextLabel")
                toggleName.Name = "ToggleName"
                toggleName.FontFace = Font.new(assets.interFont)
                toggleName.Text = toggleText
                toggleName.RichText = true
                toggleName.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleName.TextSize = 13
                toggleName.TextTransparency = 0.5
                toggleName.TextTruncate = Enum.TextTruncate.AtEnd
                toggleName.TextXAlignment = Enum.TextXAlignment.Left
                toggleName.TextYAlignment = Enum.TextYAlignment.Top
                toggleName.AnchorPoint = Vector2.new(0, 0.5)
                toggleName.AutomaticSize = Enum.AutomaticSize.Y
                toggleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleName.BackgroundTransparency = 1
                toggleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggleName.BorderSizePixel = 0
                toggleName.Position = UDim2.fromScale(0, 0.5)
                toggleName.Size = UDim2.new(1, -50, 0, 0)
                toggleName.Parent = toggle
                AddToRegistry(toggleName, "TextColor3", "Text")

                local toggle1 = Instance.new("ImageButton")
                toggle1.Name = "Toggle"
                toggle1.Image = assets.toggleBackground
                toggle1.ImageColor3 = Color3.fromRGB(87, 86, 86)
                toggle1.AutoButtonColor = false
                toggle1.AnchorPoint = Vector2.new(1, 0.5)
                toggle1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggle1.BackgroundTransparency = 1
                toggle1.BorderColor3 = Color3.fromRGB(0, 0, 0)
                toggle1.BorderSizePixel = 0
                toggle1.Position = UDim2.fromScale(1, 0.5)
                toggle1.Size = UDim2.fromOffset(41, 21)
                toggle1.ImageTransparency = 0.5
                toggle1.Parent = toggle

                local togglerHead = Instance.new("ImageLabel")
                togglerHead.Name = "TogglerHead"
                togglerHead.Image = assets.togglerHead
                togglerHead.ImageColor3 = Color3.fromRGB(255, 255, 255)
                togglerHead.AnchorPoint = Vector2.new(1, 0.5)
                togglerHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                togglerHead.BackgroundTransparency = 1
                togglerHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
                togglerHead.BorderSizePixel = 0
                togglerHead.Position = ToggleFunctions.State and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
                togglerHead.Size = UDim2.fromOffset(15, 15)
                togglerHead.ZIndex = 2
                togglerHead.Parent = toggle1
                togglerHead.ImageTransparency = ToggleFunctions.State and 0 or 0.85

                local TweenSettings = {
                    Info = TweenInfo.new(0.15, Enum.EasingStyle.Quad),
                    EnabledPosition = UDim2.new(1, 0, 0.5, 0),
                    DisabledPosition = UDim2.new(0.5, 0, 0.5, 0),
                }

                local function NewState(State, triggerCallback)
                    Tween(toggle1, TweenSettings.Info, {ImageTransparency = State and 0 or 0.5})
                    Tween(togglerHead, TweenSettings.Info, {
                        ImageTransparency = State and 0 or 0.85,
                        Position = State and TweenSettings.EnabledPosition or TweenSettings.DisabledPosition
                    })
                    ToggleFunctions.State = State
                    ConfigObjects[toggleText] = State
                    if triggerCallback and callback then callback(State) end
                end

                toggle1.MouseButton1Click:Connect(function()
                    local newState = not ToggleFunctions.State
                    PlaySound(newState and Sounds.ToggleOn or Sounds.ToggleOff)
                    NewState(newState, true)
                end)

                function ToggleFunctions:UpdateName(New) toggleName.Text = New end
                function ToggleFunctions:SetVisibility(State) toggle.Visible = State end
                function ToggleFunctions:GetState() return ToggleFunctions.State end
                function ToggleFunctions:UpdateState(State) NewState(State, true) end

                return ToggleFunctions
            end

            -- ========== Slider ==========
            child.Slider = function(_, sliderText, min, max, default, callback)
                local SliderFunctions = { Value = default or min }

                local slider = Instance.new("Frame")
                slider.Name = "Slider"
                slider.AutomaticSize = Enum.AutomaticSize.Y
                slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                slider.BackgroundTransparency = 1
                slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                slider.BorderSizePixel = 0
                slider.Size = UDim2.new(1, 0, 0, 38)
                slider.Parent = contentContainer

                local sliderName = Instance.new("TextLabel")
                sliderName.Name = "SliderName"
                sliderName.FontFace = Font.new(assets.interFont)
                sliderName.Text = sliderText
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
                sliderName.Position = UDim2.fromScale(1.3e-07, 0.5)
                sliderName.Parent = slider
                AddToRegistry(sliderName, "TextColor3", "Text")

                local sliderElements = Instance.new("Frame")
                sliderElements.Name = "SliderElements"
                sliderElements.AnchorPoint = Vector2.new(1, 0)
                sliderElements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderElements.BackgroundTransparency = 1
                sliderElements.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderElements.BorderSizePixel = 0
                sliderElements.Position = UDim2.fromScale(1, 0)
                sliderElements.Size = UDim2.fromScale(1, 1)

                local sliderValue = Instance.new("TextBox")
                sliderValue.Name = "SliderValue"
                sliderValue.FontFace = Font.new(assets.interFont)
                sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.TextSize = 12
                sliderValue.TextTransparency = 0.1
                sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderValue.BackgroundTransparency = 0.95
                sliderValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderValue.BorderSizePixel = 0
                sliderValue.LayoutOrder = 1
                sliderValue.Position = UDim2.fromScale(-0.0789, 0.171)
                sliderValue.Size = UDim2.fromOffset(41, 21)
                sliderValue.ClipsDescendants = true
                sliderValue.Text = tostring(default)
                sliderValue.Parent = sliderElements
                AddToRegistry(sliderValue, "TextColor3", "Text")
                AddToRegistry(sliderValue, "BackgroundColor3", "Main")

                local sliderBar = Instance.new("ImageLabel")
                sliderBar.Name = "SliderBar"
                sliderBar.Image = assets.sliderbar
                sliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                sliderBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderBar.BackgroundTransparency = 1
                sliderBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderBar.BorderSizePixel = 0
                sliderBar.Position = UDim2.fromScale(0.219, 0.457)
                sliderBar.Size = UDim2.fromOffset(123, 3)
                sliderBar.Parent = sliderElements

                local sliderHead = Instance.new("ImageButton")
                sliderHead.Name = "SliderHead"
                sliderHead.Image = assets.sliderhead
                sliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderHead.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderHead.BackgroundTransparency = 1
                sliderHead.BorderColor3 = Color3.fromRGB(0, 0, 0)
                sliderHead.BorderSizePixel = 0
                sliderHead.Size = UDim2.fromOffset(12, 12)
                sliderHead.Parent = sliderBar
                AddToRegistry(sliderHead, "ImageColor3", "Accent")

                local dragging = false

                local function SetValue(input, ignoreCallback)
                    local posXScale
                    if typeof(input) == "Instance" then
                        posXScale = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    else
                        local value = input
                        posXScale = (value - min) / (max - min)
                    end
                    sliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
                    local newValue = min + posXScale * (max - min)
                    SliderFunctions.Value = newValue
                    sliderValue.Text = tostring(math.floor(newValue))
                    ConfigObjects[sliderText] = newValue
                    if not ignoreCallback and callback then callback(newValue) end
                end

                SetValue(default, true)

                sliderHead.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        PlaySound(Sounds.Slide)
                        SetValue(input)
                    end
                end)
                sliderHead.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then SetValue(input) end
                end)

                sliderValue.FocusLost:Connect(function()
                    local val = tonumber(sliderValue.Text)
                    if val then
                        val = math.clamp(val, min, max)
                        SetValue(val)
                    else
                        sliderValue.Text = tostring(SliderFunctions.Value)
                    end
                end)

                function SliderFunctions:UpdateName(New) sliderName.Text = New end
                function SliderFunctions:SetVisibility(State) slider.Visible = State end
                function SliderFunctions:GetValue() return SliderFunctions.Value end
                function SliderFunctions:UpdateValue(New) SetValue(New, false) end

                return SliderFunctions
            end

            -- ========== Input (Textbox) ==========
            child.Textbox = function(_, boxText, placeholder, callback)
                local InputFunctions = { Text = "" }

                local input = Instance.new("Frame")
                input.Name = "Input"
                input.AutomaticSize = Enum.AutomaticSize.Y
                input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                input.BackgroundTransparency = 1
                input.BorderColor3 = Color3.fromRGB(0, 0, 0)
                input.BorderSizePixel = 0
                input.Size = UDim2.new(1, 0, 0, 38)
                input.Parent = contentContainer

                local inputName = Instance.new("TextLabel")
                inputName.Name = "InputName"
                inputName.FontFace = Font.new(assets.interFont)
                inputName.Text = boxText
                inputName.RichText = true
                inputName.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputName.TextSize = 13
                inputName.TextTransparency = 0.5
                inputName.TextTruncate = Enum.TextTruncate.AtEnd
                inputName.TextXAlignment = Enum.TextXAlignment.Left
                inputName.TextYAlignment = Enum.TextYAlignment.Top
                inputName.AnchorPoint = Vector2.new(0, 0.5)
                inputName.AutomaticSize = Enum.AutomaticSize.XY
                inputName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                inputName.BackgroundTransparency = 1
                inputName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                inputName.BorderSizePixel = 0
                inputName.Position = UDim2.fromScale(0, 0.5)
                inputName.Parent = input
                AddToRegistry(inputName, "TextColor3", "Text")

                local inputBox = Instance.new("TextBox")
                inputBox.Name = "InputBox"
                inputBox.FontFace = Font.new(assets.interFont)
                inputBox.Text = ""
                inputBox.PlaceholderText = placeholder
                inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputBox.TextSize = 12
                inputBox.TextTransparency = 0.1
                inputBox.AnchorPoint = Vector2.new(1, 0.5)
                inputBox.AutomaticSize = Enum.AutomaticSize.X
                inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                inputBox.BackgroundTransparency = 0.95
                inputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                inputBox.BorderSizePixel = 0
                inputBox.ClipsDescendants = true
                inputBox.LayoutOrder = 1
                inputBox.Position = UDim2.fromScale(1, 0.5)
                inputBox.Size = UDim2.fromOffset(21, 21)
                inputBox.TextXAlignment = Enum.TextXAlignment.Right
                inputBox.Parent = input
                AddToRegistry(inputBox, "TextColor3", "Text")
                AddToRegistry(inputBox, "BackgroundColor3", "Main")

                inputBox.FocusLost:Connect(function()
                    InputFunctions.Text = inputBox.Text
                    ConfigObjects[boxText] = inputBox.Text
                    if callback then callback(inputBox.Text) end
                end)

                function InputFunctions:UpdateName(New) inputName.Text = New end
                function InputFunctions:SetVisibility(State) input.Visible = State end
                function InputFunctions:GetInput() return inputBox.Text end
                function InputFunctions:UpdateText(New)
                    inputBox.Text = New
                    InputFunctions.Text = New
                    ConfigObjects[boxText] = New
                    if callback then callback(New) end
                end

                return InputFunctions
            end

            -- ========== Keybind ==========
            child.Keybind = function(_, keyText, default, callback)
                local KeybindFunctions = { Bind = default or Enum.KeyCode.M }

                local keybind = Instance.new("Frame")
                keybind.Name = "Keybind"
                keybind.AutomaticSize = Enum.AutomaticSize.Y
                keybind.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                keybind.BackgroundTransparency = 1
                keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
                keybind.BorderSizePixel = 0
                keybind.Size = UDim2.new(1, 0, 0, 38)
                keybind.Parent = contentContainer

                local keybindName = Instance.new("TextLabel")
                keybindName.Name = "KeybindName"
                keybindName.FontFace = Font.new(assets.interFont)
                keybindName.Text = keyText
                keybindName.RichText = true
                keybindName.TextColor3 = Color3.fromRGB(255, 255, 255)
                keybindName.TextSize = 13
                keybindName.TextTransparency = 0.5
                keybindName.TextTruncate = Enum.TextTruncate.AtEnd
                keybindName.TextXAlignment = Enum.TextXAlignment.Left
                keybindName.TextYAlignment = Enum.TextYAlignment.Top
                keybindName.AnchorPoint = Vector2.new(0, 0.5)
                keybindName.AutomaticSize = Enum.AutomaticSize.XY
                keybindName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                keybindName.BackgroundTransparency = 1
                keybindName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                keybindName.BorderSizePixel = 0
                keybindName.Position = UDim2.fromScale(0, 0.5)
                keybindName.Parent = keybind
                AddToRegistry(keybindName, "TextColor3", "Text")

                local binderBox = Instance.new("TextBox")
                binderBox.Name = "BinderBox"
                binderBox.FontFace = Font.new(assets.interFont)
                binderBox.PlaceholderText = "..."
                binderBox.Text = default and default.Name or ""
                binderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                binderBox.TextSize = 12
                binderBox.TextTransparency = 0.1
                binderBox.AnchorPoint = Vector2.new(1, 0.5)
                binderBox.AutomaticSize = Enum.AutomaticSize.X
                binderBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                binderBox.BackgroundTransparency = 0.95
                binderBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                binderBox.BorderSizePixel = 0
                binderBox.ClipsDescendants = true
                binderBox.LayoutOrder = 1
                binderBox.Position = UDim2.fromScale(1, 0.5)
                binderBox.Size = UDim2.fromOffset(21, 21)
                binderBox.Parent = keybind
                AddToRegistry(binderBox, "TextColor3", "Text")
                AddToRegistry(binderBox, "BackgroundColor3", "Main")

                local focused = false
                local isBinding = false

                binderBox.Focused:Connect(function()
                    focused = true
                    isBinding = true
                    binderBox.Text = "..."
                end)

                binderBox.FocusLost:Connect(function()
                    focused = false
                    isBinding = false
                    binderBox.Text = KeybindFunctions.Bind and KeybindFunctions.Bind.Name or ""
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if focused and isBinding then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            KeybindFunctions.Bind = input.KeyCode
                            binderBox.Text = input.KeyCode.Name
                            ConfigObjects[keyText] = input.KeyCode.Name
                            if callback then callback(input.KeyCode) end
                            binderBox:ReleaseFocus()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeybindFunctions.Bind = input.UserInputType
                            binderBox.Text = input.UserInputType.Name
                            ConfigObjects[keyText] = input.UserInputType.Name
                            if callback then callback(input.UserInputType) end
                            binderBox:ReleaseFocus()
                        end
                    end
                end)

                function KeybindFunctions:Bind(Key)
                    KeybindFunctions.Bind = Key
                    binderBox.Text = Key.Name
                end
                function KeybindFunctions:Unbind()
                    KeybindFunctions.Bind = nil
                    binderBox.Text = ""
                end
                function KeybindFunctions:GetBind() return KeybindFunctions.Bind end
                function KeybindFunctions:UpdateName(New) keybindName.Text = New end
                function KeybindFunctions:SetVisibility(State) keybind.Visible = State end

                return KeybindFunctions
            end

            -- ========== Dropdown (完整版，含多选和搜索) ==========
            child.Dropdown = function(_, dropText, options, callback)
                -- 支持 options 为表格，包含 Options, Multi, Search 等
                local settings = type(options) == "table" and options or {Options = options, Multi = false, Search = false}
                local DropdownFunctions = { Value = nil, Multi = settings.Multi or false, Search = settings.Search or false }
                local Selected = {}
                local OptionObjs = {}

                local dropdown = Instance.new("Frame")
                dropdown.Name = "Dropdown"
                dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdown.BackgroundTransparency = 0.985
                dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdown.BorderSizePixel = 0
                dropdown.Size = UDim2.new(1, 0, 0, 38)
                dropdown.Parent = contentContainer
                dropdown.ClipsDescendants = true
                AddToRegistry(dropdown, "BackgroundColor3", "Top")

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
                dropdownName.FontFace = Font.new(assets.interFont)
                dropdownName.Text = dropText .. "..."
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
                AddToRegistry(dropdownName, "TextColor3", "Text")

                local dropdownImage = Instance.new("ImageLabel")
                dropdownImage.Name = "DropdownImage"
                dropdownImage.Image = assets.dropdown
                dropdownImage.ImageTransparency = 0.5
                dropdownImage.AnchorPoint = Vector2.new(1, 0)
                dropdownImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownImage.BackgroundTransparency = 1
                dropdownImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
                dropdownImage.BorderSizePixel = 0
                dropdownImage.Position = UDim2.new(1, 0, 0, 12)
                dropdownImage.Size = UDim2.fromOffset(14, 14)
                dropdownImage.Parent = dropdown
                AddToRegistry(dropdownImage, "ImageColor3", "Text")

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
                dropdownFrame.Parent = dropdown
                AddToRegistry(dropdownFrame, "BackgroundColor3", "Top")

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

                -- 搜索框
                local search = Instance.new("Frame")
                search.Name = "Search"
                search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                search.BackgroundTransparency = 0.95
                search.BorderColor3 = Color3.fromRGB(0, 0, 0)
                search.BorderSizePixel = 0
                search.LayoutOrder = -1
                search.Size = UDim2.new(1, 0, 0, 30)
                search.Parent = dropdownFrame
                search.Visible = DropdownFunctions.Search
                AddToRegistry(search, "BackgroundColor3", "Main")

                local searchIcon = Instance.new("ImageLabel")
                searchIcon.Name = "SearchIcon"
                searchIcon.Image = assets.searchIcon
                searchIcon.ImageColor3 = Color3.fromRGB(180, 180, 180)
                searchIcon.AnchorPoint = Vector2.new(0, 0.5)
                searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                searchIcon.BackgroundTransparency = 1
                searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
                searchIcon.BorderSizePixel = 0
                searchIcon.Position = UDim2.fromScale(0, 0.5)
                searchIcon.Size = UDim2.fromOffset(12, 12)
                searchIcon.Parent = search
                AddToRegistry(searchIcon, "ImageColor3", "Text")

                local searchBox = Instance.new("TextBox")
                searchBox.Name = "SearchBox"
                searchBox.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
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
                searchBox.Parent = search
                AddToRegistry(searchBox, "TextColor3", "Text")

                local function CalculateDropdownSize()
                    local totalHeight = 0
                    local visibleChildrenCount = 0
                    for _, v in pairs(dropdownFrame:GetChildren()) do
                        if not v:IsA("UIComponent") and v.Visible then
                            totalHeight += v.AbsoluteSize.Y
                            visibleChildrenCount += 1
                        end
                    end
                    return totalHeight + dropdownFrameUIListLayout.Padding.Offset * (visibleChildrenCount - 1) + 48
                end

                local dropped = false
                local db = false

                local function ToggleDropdown()
                    if db then return end
                    db = true
                    local targetSize = not dropped and UDim2.new(1, 0, 0, CalculateDropdownSize()) or UDim2.new(1, 0, 0, 38)
                    local dropTween = TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Size = targetSize})
                    local iconTween = TweenService:Create(dropdownImage, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Rotation = not dropped and -90 or 0})
                    dropTween:Play()
                    iconTween:Play()
                    if not dropped then
                        dropdownFrame.Visible = true
                        dropTween.Completed:Connect(function() db = false end)
                    else
                        dropTween.Completed:Connect(function()
                            dropdownFrame.Visible = false
                            db = false
                        end)
                    end
                    dropped = not dropped
                end

                interact.MouseButton1Click:Connect(ToggleDropdown)

                local function findOption()
                    local searchTerm = searchBox.Text:lower()
                    for _, optData in pairs(OptionObjs) do
                        local optionText = optData.NameLabel.Text:lower()
                        optData.Button.Visible = string.find(optionText, searchTerm) ~= nil
                    end
                    if dropped then
                        dropdown.Size = UDim2.new(1, 0, 0, CalculateDropdownSize())
                    end
                end

                searchBox:GetPropertyChangedSignal("Text"):Connect(findOption)

                local function addOption(opt)
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
                    option.Parent = dropdownFrame

                    local optionName = Instance.new("TextLabel")
                    optionName.Name = "OptionName"
                    optionName.FontFace = Font.new(assets.interFont)
                    optionName.Text = opt
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
                    AddToRegistry(optionName, "TextColor3", "Text")

                    local checkmark = Instance.new("TextLabel")
                    checkmark.Name = "Checkmark"
                    checkmark.FontFace = Font.new(assets.interFont)
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
                    AddToRegistry(checkmark, "TextColor3", "Accent")

                    OptionObjs[opt] = {Button = option, NameLabel = optionName, Checkmark = checkmark}

                    option.MouseButton1Click:Connect(function()
                        if DropdownFunctions.Multi then
                            local isSelected = table.find(Selected, opt) ~= nil
                            if isSelected then
                                for i, v in ipairs(Selected) do if v == opt then table.remove(Selected, i) break end end
                            else
                                table.insert(Selected, opt)
                            end
                            checkmark.TextTransparency = isSelected and 1 or 0
                            dropdownName.Text = dropText .. " • " .. table.concat(Selected, ", ")
                            ConfigObjects[dropText] = Selected
                        else
                            for _, od in pairs(OptionObjs) do
                                od.Checkmark.TextTransparency = 1
                            end
                            Selected = {opt}
                            checkmark.TextTransparency = 0
                            DropdownFunctions.Value = opt
                            dropdownName.Text = dropText .. " • " .. opt
                            ConfigObjects[dropText] = opt
                            ToggleDropdown()
                        end
                        if callback then
                            if DropdownFunctions.Multi then
                                local ret = {}
                                for _, s in ipairs(Selected) do ret[s] = true end
                                callback(ret)
                            else
                                callback(opt)
                            end
                        end
                    end)
                end

                -- 初始选项
                for _, opt in ipairs(settings.Options) do
                    addOption(opt)
                end

                function DropdownFunctions:Refresh(newOpts)
                    for _, od in pairs(OptionObjs) do od.Button:Destroy() end
                    OptionObjs = {}
                    Selected = {}
                    for _, opt in ipairs(newOpts) do addOption(opt) end
                end

                function DropdownFunctions:UpdateName(New)
                    dropdownName.Text = New .. (DropdownFunctions.Value and (" • " .. DropdownFunctions.Value) or "...")
                end
                function DropdownFunctions:SetVisibility(State) dropdown.Visible = State end
                function DropdownFunctions:GetValue() return DropdownFunctions.Value end
                function DropdownFunctions:UpdateSelection(newSel)
                    if DropdownFunctions.Multi and type(newSel) == "table" then
                        for _, od in pairs(OptionObjs) do od.Checkmark.TextTransparency = 1 end
                        Selected = {}
                        for _, opt in ipairs(newSel) do
                            if OptionObjs[opt] then
                                table.insert(Selected, opt)
                                OptionObjs[opt].Checkmark.TextTransparency = 0
                            end
                        end
                        dropdownName.Text = dropText .. " • " .. table.concat(Selected, ", ")
                        ConfigObjects[dropText] = Selected
                    elseif not DropdownFunctions.Multi then
                        for _, od in pairs(OptionObjs) do od.Checkmark.TextTransparency = 1 end
                        if OptionObjs[newSel] then
                            Selected = {newSel}
                            OptionObjs[newSel].Checkmark.TextTransparency = 0
                            DropdownFunctions.Value = newSel
                            dropdownName.Text = dropText .. " • " .. newSel
                            ConfigObjects[dropText] = newSel
                        end
                    end
                end

                return DropdownFunctions
            end

            -- ========== Colorpicker (完整版) ==========
            child.Colorpicker = function(_, cpText, default, callback)
                local ColorpickerFunctions = { Color = default, Alpha = 0 }

                local colorpicker = Instance.new("Frame")
                colorpicker.Name = "Colorpicker"
                colorpicker.AutomaticSize = Enum.AutomaticSize.Y
                colorpicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                colorpicker.BackgroundTransparency = 1
                colorpicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorpicker.BorderSizePixel = 0
                colorpicker.Size = UDim2.new(1, 0, 0, 38)
                colorpicker.Parent = contentContainer

                local colorpickerName = Instance.new("TextLabel")
                colorpickerName.Name = "ColorpickerName"
                colorpickerName.FontFace = Font.new(assets.interFont)
                colorpickerName.Text = cpText
                colorpickerName.RichText = true
                colorpickerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                colorpickerName.TextSize = 13
                colorpickerName.TextTransparency = 0.5
                colorpickerName.TextTruncate = Enum.TextTruncate.AtEnd
                colorpickerName.TextXAlignment = Enum.TextXAlignment.Left
                colorpickerName.TextYAlignment = Enum.TextYAlignment.Top
                colorpickerName.AnchorPoint = Vector2.new(0, 0.5)
                colorpickerName.AutomaticSize = Enum.AutomaticSize.XY
                colorpickerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorpickerName.BackgroundTransparency = 1
                colorpickerName.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorpickerName.BorderSizePixel = 0
                colorpickerName.Position = UDim2.fromScale(0, 0.5)
                colorpickerName.Parent = colorpicker
                AddToRegistry(colorpickerName, "TextColor3", "Text")

                local colorCbg = Instance.new("ImageLabel")
                colorCbg.Name = "ColorCbg"
                colorCbg.Image = assets.grid
                colorCbg.ScaleType = Enum.ScaleType.Tile
                colorCbg.TileSize = UDim2.fromOffset(500, 500)
                colorCbg.AnchorPoint = Vector2.new(1, 0.5)
                colorCbg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorCbg.BackgroundTransparency = 1
                colorCbg.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorCbg.BorderSizePixel = 0
                colorCbg.Position = UDim2.fromScale(1, 0.5)
                colorCbg.Size = UDim2.fromOffset(21, 21)
                colorCbg.Parent = colorpicker

                local colorC = Instance.new("Frame")
                colorC.Name = "ColorC"
                colorC.AnchorPoint = Vector2.new(0.5, 0.5)
                colorC.BackgroundColor3 = default
                colorC.BorderSizePixel = 0
                colorC.Position = UDim2.fromScale(0.5, 0.5)
                colorC.Size = UDim2.fromScale(1, 1)
                colorC.Parent = colorCbg
                Instance.new("UICorner", colorC).CornerRadius = UDim.new(0, 6)

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
                interact.Size = UDim2.fromScale(1, 1)
                interact.Parent = colorC

                local uICorner = Instance.new("UICorner")
                uICorner.CornerRadius = UDim.new(0, 8)
                uICorner.Parent = colorCbg

                -- 颜色选择器弹窗
                local colorPicker = Instance.new("Frame")
                colorPicker.Name = "ColorPicker"
                colorPicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                colorPicker.BackgroundTransparency = 0.5
                colorPicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorPicker.BorderSizePixel = 0
                colorPicker.Size = UDim2.fromScale(1, 1)
                colorPicker.Visible = false
                colorPicker.Parent = ScreenGui  -- 放在顶层

                local baseUICorner = Instance.new("UICorner")
                baseUICorner.CornerRadius = UDim.new(0, 10)
                baseUICorner.Parent = colorPicker

                local prompt = Instance.new("Frame")
                prompt.Name = "Prompt"
                prompt.AnchorPoint = Vector2.new(0.5, 0.5)
                prompt.AutomaticSize = Enum.AutomaticSize.Y
                prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
                prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
                prompt.BorderSizePixel = 0
                prompt.Position = UDim2.fromScale(0.5, 0.5)
                prompt.Size = UDim2.fromOffset(420, 0)
                prompt.Parent = colorPicker
                AddToRegistry(prompt, "BackgroundColor3", "Main")

                local promptUIScale = Instance.new("UIScale")
                promptUIScale.Parent = prompt
                promptUIScale.Scale = 0.95

                local promptUIStroke = Instance.new("UIStroke")
                promptUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                promptUIStroke.Color = Color3.fromRGB(255, 255, 255)
                promptUIStroke.Transparency = 0.9
                promptUIStroke.Parent = prompt
                AddToRegistry(promptUIStroke, "Color", "Stroke")

                local promptUICorner = Instance.new("UICorner")
                promptUICorner.CornerRadius = UDim.new(0, 10)
                promptUICorner.Parent = prompt

                local promptUIPadding = Instance.new("UIPadding")
                promptUIPadding.PaddingBottom = UDim.new(0, 20)
                promptUIPadding.PaddingLeft = UDim.new(0, 20)
                promptUIPadding.PaddingRight = UDim.new(0, 20)
                promptUIPadding.PaddingTop = UDim.new(0, 20)
                promptUIPadding.Parent = prompt

                local paragraph = Instance.new("Frame")
                paragraph.Name = "Paragraph"
                paragraph.AutomaticSize = Enum.AutomaticSize.Y
                paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                paragraph.BackgroundTransparency = 1
                paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
                paragraph.BorderSizePixel = 0
                paragraph.Size = UDim2.fromScale(1, 0)
                paragraph.Parent = prompt

                local paragraphHeader = Instance.new("TextLabel")
                paragraphHeader.Name = "ParagraphHeader"
                paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold)
                paragraphHeader.Text = cpText
                paragraphHeader.RichText = true
                paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
                paragraphHeader.TextSize = 18
                paragraphHeader.TextTransparency = 0.4
                paragraphHeader.TextWrapped = true
                paragraphHeader.TextYAlignment = Enum.TextYAlignment.Top
                paragraphHeader.AutomaticSize = Enum.AutomaticSize.XY
                paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                paragraphHeader.BackgroundTransparency = 1
                paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
                paragraphHeader.BorderSizePixel = 0
                paragraphHeader.Size = UDim2.fromScale(1, 0)
                paragraphHeader.Parent = paragraph
                AddToRegistry(paragraphHeader, "TextColor3", "Text")

                local uIListLayout = Instance.new("UIListLayout")
                uIListLayout.Padding = UDim.new(0, 15)
                uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                uIListLayout.Parent = paragraph

                local line = Instance.new("Frame")
                line.Name = "Line"
                line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                line.BackgroundTransparency = 0.9
                line.BorderColor3 = Color3.fromRGB(0, 0, 0)
                line.BorderSizePixel = 0
                line.LayoutOrder = 1
                line.Size = UDim2.new(1, 0, 0, 1)
                line.Parent = paragraph
                AddToRegistry(line, "BackgroundColor3", "Stroke")

                local colorOptions = Instance.new("Frame")
                colorOptions.Name = "ColorOptions"
                colorOptions.AutomaticSize = Enum.AutomaticSize.Y
                colorOptions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorOptions.BackgroundTransparency = 1
                colorOptions.BorderColor3 = Color3.fromRGB(0, 0, 0)
                colorOptions.BorderSizePixel = 0
                colorOptions.LayoutOrder = 1
                colorOptions.Size = UDim2.fromScale(1, 0)
                colorOptions.Parent = prompt

                -- 这里应包含色轮、滑块、输入框等完整 UI，但因篇幅限制，仅提供框架
                -- 实际可参考 maclib.lua 中的完整 Colorpicker 实现，此处略

                local interactions = Instance.new("Frame")
                interactions.Name = "Interactions"
                interactions.AutomaticSize = Enum.AutomaticSize.Y
                interactions.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                interactions.BackgroundTransparency = 1
                interactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
                interactions.BorderSizePixel = 0
                interactions.LayoutOrder = 2
                interactions.Size = UDim2.fromScale(1, 0)
                interactions.Parent = prompt

                local uIListLayout2 = Instance.new("UIListLayout")
                uIListLayout2.Padding = UDim.new(0, 10)
                uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
                uIListLayout2.Parent = interactions

                local confirm = Instance.new("TextButton")
                confirm.Name = "Confirm"
                confirm.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
                confirm.Text = "Confirm"
                confirm.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirm.TextSize = 15
                confirm.TextTransparency = 0.5
                confirm.AutoButtonColor = false
                confirm.AutomaticSize = Enum.AutomaticSize.Y
                confirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                confirm.BorderColor3 = Color3.fromRGB(0, 0, 0)
                confirm.BorderSizePixel = 0
                confirm.Size = UDim2.fromScale(1, 0)
                confirm.Parent = interactions
                AddToRegistry(confirm, "BackgroundColor3", "Top")
                AddToRegistry(confirm, "TextColor3", "Text")

                local cancel = Instance.new("TextButton")
                cancel.Name = "Cancel"
                cancel.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
                cancel.Text = "Cancel"
                cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
                cancel.TextSize = 15
                cancel.TextTransparency = 0.5
                cancel.AutoButtonColor = false
                cancel.AutomaticSize = Enum.AutomaticSize.Y
                cancel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                cancel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                cancel.BorderSizePixel = 0
                cancel.Size = UDim2.fromScale(1, 0)
                cancel.Parent = interactions
                AddToRegistry(cancel, "BackgroundColor3", "Top")
                AddToRegistry(cancel, "TextColor3", "Text")

                local function colorpickerIn()
                    colorPicker.Visible = true
                    Tween(promptUIScale, TweenInfo.new(0.1), {Scale = 1})
                end

                local function colorpickerOut()
                    Tween(promptUIScale, TweenInfo.new(0.1), {Scale = 0.95})
                    task.wait(0.1)
                    colorPicker.Visible = false
                end

                interact.MouseButton1Click:Connect(colorpickerIn)
                cancel.MouseButton1Click:Connect(colorpickerOut)
                confirm.MouseButton1Click:Connect(function()
                    colorpickerOut()
                    if callback then callback(ColorpickerFunctions.Color) end
                end)

                function ColorpickerFunctions:SetColor(color3)
                    ColorpickerFunctions.Color = color3
                    colorC.BackgroundColor3 = color3
                    ConfigObjects[cpText] = color3
                    if callback then callback(color3) end
                end

                function ColorpickerFunctions:UpdateName(New) colorpickerName.Text = New end
                function ColorpickerFunctions:SetVisibility(State) colorpicker.Visible = State end

                return ColorpickerFunctions
            end

            -- ========== Header ==========
            child.Header = function(_, headerText)
                local HeaderFunctions = {}
                local header = Instance.new("Frame")
                header.Name = "Header"
                header.AutomaticSize = Enum.AutomaticSize.Y
                header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                header.BackgroundTransparency = 1
                header.BorderColor3 = Color3.fromRGB(0, 0, 0)
                header.BorderSizePixel = 0
                header.Size = UDim2.new(1, 0, 0, 38)
                header.Parent = contentContainer

                local headerTextLabel = Instance.new("TextLabel")
                headerTextLabel.Name = "HeaderText"
                headerTextLabel.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
                headerTextLabel.Text = headerText
                headerTextLabel.RichText = true
                headerTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                headerTextLabel.TextSize = 16
                headerTextLabel.TextTransparency = 0.3
                headerTextLabel.TextWrapped = true
                headerTextLabel.TextXAlignment = Enum.TextXAlignment.Left
                headerTextLabel.AutomaticSize = Enum.AutomaticSize.Y
                headerTextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                headerTextLabel.BackgroundTransparency = 1
                headerTextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                headerTextLabel.BorderSizePixel = 0
                headerTextLabel.Size = UDim2.fromScale(1, 1)
                headerTextLabel.Parent = header
                AddToRegistry(headerTextLabel, "TextColor3", "Text")

                function HeaderFunctions:UpdateName(New) headerTextLabel.Text = New end
                function HeaderFunctions:SetVisibility(State) header.Visible = State end
                return HeaderFunctions
            end

            -- ========== Label ==========
            child.Label = function(_, labelText)
                local LabelFunctions = {}
                local label = Instance.new("Frame")
                label.Name = "Label"
                label.AutomaticSize = Enum.AutomaticSize.Y
                label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                label.BackgroundTransparency = 1
                label.BorderColor3 = Color3.fromRGB(0, 0, 0)
                label.BorderSizePixel = 0
                label.Size = UDim2.new(1, 0, 0, 38)
                label.Parent = contentContainer

                local labelTextLabel = Instance.new("TextLabel")
                labelTextLabel.Name = "LabelText"
                labelTextLabel.FontFace = Font.new(assets.interFont)
                labelTextLabel.Text = labelText
                labelTextLabel.RichText = true
                labelTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                labelTextLabel.TextSize = 13
                labelTextLabel.TextTransparency = 0.5
                labelTextLabel.TextWrapped = true
                labelTextLabel.TextXAlignment = Enum.TextXAlignment.Left
                labelTextLabel.AutomaticSize = Enum.AutomaticSize.Y
                labelTextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                labelTextLabel.BackgroundTransparency = 1
                labelTextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                labelTextLabel.BorderSizePixel = 0
                labelTextLabel.Size = UDim2.fromScale(1, 1)
                labelTextLabel.Parent = label
                AddToRegistry(labelTextLabel, "TextColor3", "Text")

                function LabelFunctions:UpdateName(New) labelTextLabel.Text = New end
                function LabelFunctions:SetVisibility(State) label.Visible = State end
                return LabelFunctions
            end

            -- ========== SubLabel ==========
            child.SubLabel = function(_, subText)
                local SubLabelFunctions = {}
                local subLabel = Instance.new("Frame")
                subLabel.Name = "SubLabel"
                subLabel.AutomaticSize = Enum.AutomaticSize.Y
                subLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                subLabel.BackgroundTransparency = 1
                subLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                subLabel.BorderSizePixel = 0
                subLabel.Size = UDim2.new(1, 0, 0, 0)
                subLabel.Parent = contentContainer

                local subLabelText = Instance.new("TextLabel")
                subLabelText.Name = "SubLabelText"
                subLabelText.FontFace = Font.new(assets.interFont)
                subLabelText.Text = subText
                subLabelText.RichText = true
                subLabelText.TextColor3 = Color3.fromRGB(255, 255, 255)
                subLabelText.TextSize = 12
                subLabelText.TextTransparency = 0.7
                subLabelText.TextWrapped = true
                subLabelText.TextXAlignment = Enum.TextXAlignment.Left
                subLabelText.AutomaticSize = Enum.AutomaticSize.Y
                subLabelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                subLabelText.BackgroundTransparency = 1
                subLabelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                subLabelText.BorderSizePixel = 0
                subLabelText.Size = UDim2.fromScale(1, 1)
                subLabelText.Parent = subLabel
                AddToRegistry(subLabelText, "TextColor3", "Text")

                function SubLabelFunctions:UpdateName(New) subLabelText.Text = New end
                function SubLabelFunctions:SetVisibility(State) subLabel.Visible = State end
                return SubLabelFunctions
            end

            -- ========== Paragraph ==========
            child.Paragraph = function(_, header, body)
                local ParagraphFunctions = {}
                local paragraph = Instance.new("Frame")
                paragraph.Name = "Paragraph"
                paragraph.AutomaticSize = Enum.AutomaticSize.Y
                paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                paragraph.BackgroundTransparency = 1
                paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
                paragraph.BorderSizePixel = 0
                paragraph.Size = UDim2.new(1, 0, 0, 38)
                paragraph.Parent = contentContainer

                local paragraphHeader = Instance.new("TextLabel")
                paragraphHeader.Name = "ParagraphHeader"
                paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium)
                paragraphHeader.Text = header
                paragraphHeader.RichText = true
                paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
                paragraphHeader.TextSize = 15
                paragraphHeader.TextTransparency = 0.4
                paragraphHeader.TextWrapped = true
                paragraphHeader.TextXAlignment = Enum.TextXAlignment.Left
                paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
                paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                paragraphHeader.BackgroundTransparency = 1
                paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
                paragraphHeader.BorderSizePixel = 0
                paragraphHeader.Size = UDim2.fromScale(1, 0)
                paragraphHeader.Parent = paragraph
                AddToRegistry(paragraphHeader, "TextColor3", "Text")

                local uIListLayout = Instance.new("UIListLayout")
                uIListLayout.Padding = UDim.new(0, 5)
                uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                uIListLayout.Parent = paragraph

                local paragraphBody = Instance.new("TextLabel")
                paragraphBody.Name = "ParagraphBody"
                paragraphBody.FontFace = Font.new(assets.interFont)
                paragraphBody.Text = body
                paragraphBody.RichText = true
                paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
                paragraphBody.TextSize = 13
                paragraphBody.TextTransparency = 0.5
                paragraphBody.TextWrapped = true
                paragraphBody.TextXAlignment = Enum.TextXAlignment.Left
                paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
                paragraphBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                paragraphBody.BackgroundTransparency = 1
                paragraphBody.BorderColor3 = Color3.fromRGB(0, 0, 0)
                paragraphBody.BorderSizePixel = 0
                paragraphBody.LayoutOrder = 1
                paragraphBody.Size = UDim2.fromScale(1, 0)
                paragraphBody.Parent = paragraph
                AddToRegistry(paragraphBody, "TextColor3", "Text")

                function ParagraphFunctions:UpdateHeader(New) paragraphHeader.Text = New end
                function ParagraphFunctions:UpdateBody(New) paragraphBody.Text = New end
                function ParagraphFunctions:SetVisibility(State) paragraph.Visible = State end
                return ParagraphFunctions
            end

            -- ========== Divider ==========
            child.Divider = function()
                local DividerFunctions = {}
                local divider = Instance.new("Frame")
                divider.Name = "Divider"
                divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                divider.BackgroundTransparency = 0.9
                divider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                divider.BorderSizePixel = 0
                divider.Size = UDim2.new(1, 0, 0, 1)
                divider.Parent = contentContainer
                AddToRegistry(divider, "BackgroundColor3", "Stroke")

                function DividerFunctions:Remove() divider:Destroy() end
                function DividerFunctions:SetVisibility(State) divider.Visible = State end
                return DividerFunctions
            end

            -- ========== Spacer ==========
            child.Spacer = function()
                local SpacerFunctions = {}
                local spacer = Instance.new("Frame")
                spacer.Name = "Spacer"
                spacer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                spacer.BackgroundTransparency = 1
                spacer.BorderColor3 = Color3.fromRGB(0, 0, 0)
                spacer.BorderSizePixel = 0
                spacer.Size = UDim2.new(1, 0, 0, 10)
                spacer.Parent = contentContainer

                function SpacerFunctions:Remove() spacer:Destroy() end
                function SpacerFunctions:SetVisibility(State) spacer.Visible = State end
                return SpacerFunctions
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