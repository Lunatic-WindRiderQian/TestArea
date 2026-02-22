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

-- Maclib 资源表
local Assets = {
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

-- 为了兼容原有代码，保留 ToggleAssets / SliderAssets 并指向 Assets 中的资源
local ToggleAssets = {
    Bg = Assets.toggleBackground,
    Head = Assets.togglerHead,
}
local SliderAssets = {
    Bar = Assets.sliderbar,
    Head = Assets.sliderhead,
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
    return TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, reg in pairs(Registry) do
            if reg.Object then
                Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]}):Play()
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
    Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.6):Play()

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
                Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.4):Play()
            end
        end
    end)

    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame"); Notif.ZIndex = 100; Notif.Size = UDim2.new(0, 250, 0, 45); Notif.Position = UDim2.new(1, 20, 1, -60); Notif.Parent = ScreenGui; AddToRegistry(Notif, "BackgroundColor3", "Top"); Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
            local NStroke = Instance.new("UIStroke"); NStroke.Parent = Notif; AddToRegistry(NStroke, "Color", "Accent")
            local NText = Instance.new("TextLabel"); NText.ZIndex = 101; NText.Text = text; NText.Size = UDim2.new(1,0,1,0); NText.BackgroundTransparency = 1; NText.Parent = Notif; NText.Font = Enum.Font.GothamBold; NText.TextSize = 14; AddToRegistry(NText, "TextColor3", "Text")
            Tween(Notif, {Position = UDim2.new(1, -270, 1, -60)}, 0.5):Play(); task.wait(3); Tween(Notif, {Position = UDim2.new(1, 20, 1, -60)}, 0.5):Play(); task.wait(0.5); Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end

    local firstTab = true
    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame

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
                Tween(v, {BackgroundTransparency = 1}):Play()
                local content = v:FindFirstChild("ContentFrame")
                if content then
                    local textLabel = content:FindFirstChildOfClass("TextLabel")
                    if textLabel then
                        Tween(textLabel, {TextColor3 = Color3.fromRGB(150,150,150)}):Play()
                    end
                end
            end end
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent}):Play()
            Tween(TabText, {TextColor3 = CurrentTheme.Text}):Play()
        end)

        if firstTab then 
            firstTab = false
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent}):Play()
            Tween(TabText, {TextColor3 = CurrentTheme.Text}):Play()
        end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local Elements = {}

        -- Section：可折叠容器（保持原有实现，仅替换内部元素）
        function Elements:Section(text, icons, defaultOpen)
            if defaultOpen == nil then defaultOpen = true end

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

            local iconOpen, iconClosed
            if type(icons) == "table" then
                iconOpen = formatAssetId(icons.Y or icons.open) or "rbxassetid://6031091004"
                iconClosed = formatAssetId(icons.F or icons.closed) or iconOpen
            else
                local defaultIcon = formatAssetId(icons) or "rbxassetid://6031091004"
                iconOpen = defaultIcon
                iconClosed = defaultIcon
            end

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 36)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Parent = Page
            sectionFrame.ClipsDescendants = true

            local titleBar = Instance.new("Frame")
            titleBar.Size = UDim2.new(1, 0, 0, 36)
            titleBar.BackgroundTransparency = 1
            titleBar.Parent = sectionFrame

            local iconLabel = Instance.new("ImageLabel")
            iconLabel.Size = UDim2.new(0, 24, 0, 24)
            iconLabel.Position = UDim2.new(0, 5, 0.5, -12)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = defaultOpen and iconOpen or iconClosed
            iconLabel.Parent = titleBar

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

            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""
            toggleBtn.Parent = titleBar

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

            local currentContentTween, currentSectionTween
            local open = defaultOpen

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

            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight(false)
                end
            end)

            local child = {}

            -- ==================== Button (Maclib 风格) ====================
            child.Button = function(_, btnText, callback)
                -- 主按钮容器（使用 Top 背景色）
                local Btn = Instance.new("Frame")
                Btn.Size = UDim2.new(1, 0, 0, 38)
                Btn.BackgroundTransparency = 0
                Btn.Parent = contentContainer
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Btn, "BackgroundColor3", "Top")

                -- 交互按钮（透明，覆盖整个容器）
                local Interact = Instance.new("TextButton")
                Interact.Size = UDim2.new(1, 0, 1, 0)
                Interact.BackgroundTransparency = 1
                Interact.Text = ""
                Interact.Parent = Btn

                -- 文本标签（左对齐）
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.new(1, -30, 1, 0)
                TextLabel.Position = UDim2.new(0, 10, 0, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                TextLabel.Text = btnText
                TextLabel.TextSize = 13
                TextLabel.TextTransparency = 0.5
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.Parent = Btn
                AddToRegistry(TextLabel, "TextColor3", "Text")

                -- 右侧箭头图标
                local Icon = Instance.new("ImageLabel")
                Icon.Size = UDim2.new(0, 15, 0, 15)
                Icon.Position = UDim2.new(1, -20, 0.5, -7.5)
                Icon.BackgroundTransparency = 1
                Icon.Image = Assets.buttonImage
                Icon.ImageTransparency = 0.5
                Icon.Parent = Btn
                AddToRegistry(Icon, "ImageColor3", "Text")

                -- 悬停效果
                local function onHover()
                    Tween(TextLabel, {TextTransparency = 0.3}, 0.2):Play()
                    Tween(Icon, {ImageTransparency = 0.3}, 0.2):Play()
                end
                local function onLeave()
                    Tween(TextLabel, {TextTransparency = 0.5}, 0.2):Play()
                    Tween(Icon, {ImageTransparency = 0.5}, 0.2):Play()
                end

                Interact.MouseEnter:Connect(onHover)
                Interact.MouseLeave:Connect(onLeave)

                -- 点击事件
                Interact.MouseButton1Click:Connect(function()
                    PlaySound(Sounds.Click)
                    callback()
                end)

                -- 返回控制方法
                local self = {}
                function self.UpdateText(newText)
                    TextLabel.Text = newText
                end
                function self.SetVisible(state)
                    Btn.Visible = state
                end
                return self
            end

            -- ==================== Toggle (Maclib 风格) ====================
            child.Toggle = function(_, toggleText, default, callback)
                local Enabled = default or false

                -- 主容器
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.BackgroundTransparency = 0
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                -- 文本标签
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -50, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                Title.Text = toggleText
                Title.TextSize = 13
                Title.TextTransparency = 0.5
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Frame
                AddToRegistry(Title, "TextColor3", "Text")

                -- 开关（ImageButton）
                local Switch = Instance.new("ImageButton")
                Switch.Size = UDim2.fromOffset(41, 21)
                Switch.Position = UDim2.new(1, -50, 0.5, -10.5)
                Switch.BackgroundTransparency = 1
                Switch.Image = Assets.toggleBackground
                Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(87, 86, 86)
                Switch.ImageTransparency = 0.5
                Switch.AutoButtonColor = false
                Switch.Parent = Frame

                -- 滑块头
                local Dot = Instance.new("ImageLabel")
                Dot.Size = UDim2.fromOffset(15, 15)
                Dot.BackgroundTransparency = 1
                Dot.Image = Assets.togglerHead
                Dot.ImageColor3 = Color3.new(1, 1, 1)
                Dot.ImageTransparency = Enabled and 0 or 0.85
                Dot.AnchorPoint = Vector2.new(0.5, 0.5)
                Dot.Position = Enabled and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
                Dot.Parent = Switch

                -- 更新状态函数
                local function Update()
                    Enabled = not Enabled
                    PlaySound(Enabled and Sounds.ToggleOn or Sounds.ToggleOff)

                    -- 开关背景颜色
                    local targetColor = Enabled and CurrentTheme.Accent or Color3.fromRGB(87, 86, 86)
                    Tween(Switch, {ImageColor3 = targetColor}, 0.15):Play()

                    -- 滑块头位置和透明度
                    local targetPos = Enabled and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
                    local targetTrans = Enabled and 0 or 0.85
                    Tween(Dot, {Position = targetPos, ImageTransparency = targetTrans}, 0.15):Play()

                    -- 更新配置和回调
                    ConfigObjects[toggleText].Value = Enabled
                    callback(Enabled)
                    Window:Notification(toggleText .. ": " .. tostring(Enabled))
                end

                Switch.MouseButton1Click:Connect(Update)

                -- 注册配置对象
                ConfigObjects[toggleText] = {
                    Type = "Toggle",
                    Value = Enabled,
                    Set = function(val)
                        Enabled = val
                        Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(87, 86, 86)
                        Dot.Position = Enabled and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
                        Dot.ImageTransparency = Enabled and 0 or 0.85
                        callback(Enabled)
                    end
                }

                -- 返回控制方法
                local self = {}
                function self.UpdateState(val) ConfigObjects[toggleText].Set(val) end
                function self.GetState() return Enabled end
                function self.UpdateName(new) Title.Text = new end
                function self.SetVisible(state) Frame.Visible = state end
                return self
            end

            -- ==================== Slider (Maclib 风格，一行布局) ====================
            child.Slider = function(_, sliderText, min, max, default, callback, options)
                options = options or {}
                local Val = default or min

                -- 主容器
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                -- 名称标签（左对齐）
                local NameLbl = Instance.new("TextLabel")
                NameLbl.Size = UDim2.new(0, 0, 1, 0)  -- 宽度自动
                NameLbl.Position = UDim2.new(0, 10, 0, 0)
                NameLbl.BackgroundTransparency = 1
                NameLbl.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                NameLbl.Text = sliderText
                NameLbl.TextSize = 13
                NameLbl.TextTransparency = 0.5
                NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                NameLbl.Parent = Frame
                AddToRegistry(NameLbl, "TextColor3", "Text")

                -- 右侧元素容器（滑块条 + 数值框）
                local Right = Instance.new("Frame")
                Right.Size = UDim2.new(0, 0, 1, 0)
                Right.Position = UDim2.new(1, -10, 0, 0)
                Right.AnchorPoint = Vector2.new(1, 0)
                Right.BackgroundTransparency = 1
                Right.Parent = Frame

                local RightLayout = Instance.new("UIListLayout")
                RightLayout.FillDirection = Enum.FillDirection.Horizontal
                RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                RightLayout.Padding = UDim.new(0, 20)
                RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
                RightLayout.Parent = Right

                -- 滑块条（使用图片）
                local SliderBar = Instance.new("ImageLabel")
                SliderBar.Name = "SliderBar"
                SliderBar.Image = Assets.sliderbar
                SliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
                SliderBar.BackgroundTransparency = 1
                SliderBar.Size = UDim2.fromOffset(123, 3)
                SliderBar.Parent = Right

                -- 滑块头
                local SliderHead = Instance.new("ImageButton")
                SliderHead.Name = "SliderHead"
                SliderHead.Image = Assets.sliderhead
                SliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderHead.BackgroundTransparency = 1
                SliderHead.Size = UDim2.fromOffset(12, 12)
                SliderHead.Parent = SliderBar

                -- 数值框
                local NumBox = Instance.new("TextBox")
                NumBox.Name = "SliderValue"
                NumBox.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                NumBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                NumBox.TextSize = 12
                NumBox.TextTransparency = 0.1
                NumBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                NumBox.BackgroundTransparency = 0.95
                NumBox.BorderSizePixel = 0
                NumBox.Size = UDim2.fromOffset(41, 21)
                NumBox.ClipsDescendants = true
                NumBox.Parent = Right

                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 4)
                boxCorner.Parent = NumBox

                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = NumBox

                -- 显示方法
                local DisplayMethods = {
                    Value = function(sliderValue, precision)
                        return precision and string.format("%." .. precision .. "f", sliderValue) or tostring(math.round(sliderValue * 100) / 100)
                    end,
                    Percent = function(sliderValue, precision)
                        local percentage = (sliderValue - min) / (max - min) * 100
                        return (precision and string.format("%." .. precision .. "f", percentage) or tostring(math.round(percentage))) .. "%"
                    end,
                }
                local displayMethod = DisplayMethods[options.DisplayMethod] or DisplayMethods.Value
                local precision = options.Precision

                -- 初始化滑块位置
                local initPosX = (Val - min) / (max - min)
                SliderHead.Position = UDim2.new(initPosX, 0, 0.5, 0)
                NumBox.Text = displayMethod(Val, precision)

                local function SetValue(input, ignoreCallback)
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
                    NumBox.Text = displayMethod(newValue, precision)

                    if not ignoreCallback then
                        task.spawn(function()
                            if callback then callback(newValue) end
                        end)
                    end

                    if ConfigObjects[sliderText] then
                        ConfigObjects[sliderText].Value = newValue
                    end
                end

                -- 拖动逻辑
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

                -- 数值框输入
                NumBox.FocusLost:Connect(function(enterPressed)
                    local inputText = NumBox.Text
                    local value = tonumber(inputText:match("%d+%.?%d*"))
                    if value then
                        if options.DisplayMethod == "Percent" then
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

                -- 返回控制方法
                local self = {}
                function self.UpdateName(new) NameLbl.Text = new end
                function self.SetVisible(state) Frame.Visible = state end
                function self.UpdateValue(val) SetValue(val, true) end
                function self.GetValue() return Val end
                return self
            end

            -- ==================== Keybind (Maclib 风格) ====================
            child.Keybind = function(_, keyText, default, callback)
                local Key = default or Enum.KeyCode.M

                -- 主容器
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                -- 左侧标题
                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(0.6, 0, 1, 0)
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.BackgroundTransparency = 1
                Title.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                Title.Text = keyText
                Title.TextSize = 13
                Title.TextTransparency = 0.5
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = Frame
                AddToRegistry(Title, "TextColor3", "Text")

                -- 右侧绑定框
                local BinderBox = Instance.new("TextBox")
                BinderBox.Name = "BinderBox"
                BinderBox.FontFace = Font.new(Assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                BinderBox.Text = Key.Name
                BinderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                BinderBox.TextSize = 12
                BinderBox.TextTransparency = 0.1
                BinderBox.PlaceholderText = "..."
                BinderBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                BinderBox.BackgroundTransparency = 0.95
                BinderBox.BorderSizePixel = 0
                BinderBox.Size = UDim2.fromOffset(80, 24)
                BinderBox.Position = UDim2.new(1, -90, 0.5, -12)
                BinderBox.Parent = Frame
                Instance.new("UICorner", BinderBox).CornerRadius = UDim.new(0, 5)
                AddToRegistry(BinderBox, "BackgroundColor3", "Main")
                AddToRegistry(BinderBox, "TextColor3", "Accent")

                -- 边框
                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = BinderBox

                -- 绑定状态
                local isBinding = false
                local focused = false

                -- 点击框进入绑定模式
                Frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        BinderBox:CaptureFocus()
                    end
                end)

                BinderBox.Focused:Connect(function()
                    focused = true
                    isBinding = true
                    BinderBox.Text = ""
                    BinderBox.PlaceholderText = "..."
                end)

                BinderBox.FocusLost:Connect(function()
                    focused = false
                    isBinding = false
                    BinderBox.Text = Key.Name
                    BinderBox.PlaceholderText = ""
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
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
                            ConfigObjects[keyText].Value = Key.Name
                        end
                        BinderBox:ReleaseFocus()
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

                -- 返回控制方法
                local self = {}
                function self.UpdateText(new) Title.Text = new end
                function self.SetVisible(state) Frame.Visible = state end
                function self.Bind(newKey) 
                    Key = newKey
                    BinderBox.Text = Key.Name
                    ConfigObjects[keyText].Value = Key.Name
                    callback(Key)
                end
                function self.GetBind() return Key end
                return self
            end

            -- ==================== Input (Maclib 风格) ====================
            child.Input = function(_, inputText, default, callback, options)
                options = options or {}
                local placeholder = options.placeholder or ""
                local acceptedCharacters = options.acceptedCharacters or "All"
                local characterLimit = options.characterLimit
                local onChanged = options.onChanged

                -- 主容器
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.Parent = contentContainer
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Frame, "BackgroundColor3", "Top")

                -- 左侧名称
                local NameLbl = Instance.new("TextLabel")
                NameLbl.Size = UDim2.new(0, 0, 1, 0)
                NameLbl.Position = UDim2.new(0, 10, 0, 0)
                NameLbl.BackgroundTransparency = 1
                NameLbl.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                NameLbl.Text = inputText
                NameLbl.TextSize = 13
                NameLbl.TextTransparency = 0.5
                NameLbl.TextXAlignment = Enum.TextXAlignment.Left
                NameLbl.Parent = Frame
                AddToRegistry(NameLbl, "TextColor3", "Text")

                -- 右侧输入框
                local InputBox = Instance.new("TextBox")
                InputBox.FontFace = Font.new(Assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                InputBox.Text = tostring(default or "")
                InputBox.PlaceholderText = placeholder
                InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.TextSize = 12
                InputBox.TextTransparency = 0.1
                InputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.BackgroundTransparency = 0.95
                InputBox.BorderSizePixel = 0
                InputBox.Size = UDim2.fromOffset(120, 24)
                InputBox.Position = UDim2.new(1, -10, 0.5, -12)
                InputBox.AnchorPoint = Vector2.new(1, 0.5)
                InputBox.Parent = Frame

                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 5)
                boxCorner.Parent = InputBox

                local boxStroke = Instance.new("UIStroke")
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Color = Color3.fromRGB(255, 255, 255)
                boxStroke.Transparency = 0.9
                boxStroke.Parent = InputBox

                -- 字符过滤函数
                local function filterText(text)
                    if characterLimit then text = text:sub(1, characterLimit) end
                    if type(acceptedCharacters) == "function" then
                        return acceptedCharacters(text)
                    elseif acceptedCharacters == "Numeric" then
                        return text:gsub("[^%d-]", ""):gsub("-(.*)", function(m) return m:gsub("-", "") end)
                    elseif acceptedCharacters == "Alphabetic" then
                        return text:gsub("[^a-zA-Z]", "")
                    elseif acceptedCharacters == "AlphaNumeric" then
                        return text:gsub("[^a-zA-Z0-9]", "")
                    else
                        return text
                    end
                end

                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local filtered = filterText(InputBox.Text)
                    if filtered ~= InputBox.Text then
                        InputBox.Text = filtered
                    end
                    if onChanged then onChanged(filtered) end
                end)

                InputBox.FocusLost:Connect(function()
                    local text = InputBox.Text
                    local filtered = filterText(text)
                    if filtered ~= text then InputBox.Text = filtered end
                    if callback then callback(filtered) end
                end)

                -- 注册配置对象
                ConfigObjects[inputText] = {
                    Type = "Input",
                    Value = InputBox.Text,
                    Set = function(val) InputBox.Text = tostring(val) end
                }

                -- 返回控制方法
                local self = {}
                function self.UpdateText(new) InputBox.Text = tostring(new) end
                function self.GetText() return InputBox.Text end
                function self.SetVisible(state) Frame.Visible = state end
                function self.UpdatePlaceholder(new) InputBox.PlaceholderText = new end
                return self
            end

            -- ==================== 原有 Textbox (保留) ====================
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

            -- ==================== 原有 Dropdown (保留) ====================
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
                Icon.Image = "rbxassetid://18865373378"
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
                    Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2):Play()
                    Tween(Icon, {Rotation = 0}, 0.2):Play()
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
                        Tween(Icon, {Rotation = 180}, 0.3):Play()
                        tweenOpt.Completed:Connect(function()
                            updateSectionHeight(false)
                        end)
                    else
                        local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, 0)})
                        tweenOpt:Play()
                        Tween(Icon, {Rotation = 0}, 0.2):Play()
                        tweenOpt.Completed:Connect(function()
                            Container.Visible = false
                            updateSectionHeight(false)
                        end)
                    end
                end)

                ConfigObjects[dropText] = {Type = "Dropdown", Value = options[1], Set = function(val) Select(val) end, Refresh = RefreshOptions}
                return {Refresh = RefreshOptions}
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