local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local ContentProvider = game:GetService("ContentProvider")
local LocalPlayer = Players.LocalPlayer

local Library = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local Registry = {} 
local ConfigObjects = {} 

-- SFX (仅保留 Notification 音效)
local Sounds = {
    Hover = "",          -- 已删除
    Click = "",          -- 已删除
    ToggleOn = "",       -- 已删除
    ToggleOff = "",      -- 已删除
    Slide = "",          -- 已删除
    Notification = "rbxassetid://4590657391",  -- 保留
    Back = "",           -- 已删除
    Error = "",          -- 已删除
    Tab = ""             -- 已删除
}

-- 图片资源
local ToggleAssets = {
    Bg = "rbxassetid://18772190202",
    Head = "rbxassetid://18772309008"
}
local SliderAssets = {
    Bar = "rbxassetid://18772615246",
    Head = "rbxassetid://18772834246"
}
local ColorPickerAssets = {
    Wheel = "rbxassetid://2849458409",
    Target = "rbxassetid://73265255323268",
    Grid = "rbxassetid://121484455191370"
}

ContentProvider:PreloadAsync({
    ToggleAssets.Bg,
    ToggleAssets.Head,
    SliderAssets.Bar,
    SliderAssets.Head,
    ColorPickerAssets.Wheel,
    ColorPickerAssets.Target,
    ColorPickerAssets.Grid,
    "rbxassetid://10709791437",
    "rbxassetid://18865373378",
})

local function PlaySound(id)
    if not SFXEnabled then return end
    if id == nil or id == "" then return end  -- 空 ID 不播放
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

function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end
function Library:SetSFXEnabled(state) SFXEnabled = state end

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
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0) 
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)  -- 位置居中
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

    -- 窗口展开动画（宽度500，高度299）
    Tween(MainFrame, {Size = UDim2.new(0, 500, 0, 299)}, 0.6)

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
                Tween(MainFrame, {Size = UDim2.new(0, 500, 0, 299)}, 0.4)
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

    -- ==================== 可折叠区域创建函数 ====================
    local function createSection(parent, text, icons, defaultOpen)
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
        sectionFrame.Parent = parent
        sectionFrame.ClipsDescendants = true

        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 36)
        titleBar.BackgroundTransparency = 1
        titleBar.Parent = sectionFrame

        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, 28, 0, 28)  -- [!] 从 24x24 增大到 28x28
        iconLabel.Position = UDim2.new(0, 5, 0.5, -14)  -- 调整位置使垂直居中
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = defaultOpen and iconOpen or iconClosed
        iconLabel.Parent = titleBar
        -- [!] 添加圆角矩形效果 (圆角半径 8)
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 8)
        iconCorner.Parent = iconLabel

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = text
        textLabel.Size = UDim2.new(1, -38, 1, 0)  -- 左边距调整 (原34 + 4)
        textLabel.Position = UDim2.new(0, 38, 0, 0)  -- 图标28+边距5+间隔=38
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

        child.Button = function(_, btnText, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.Text = ""
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
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
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) Btn.Visible = state end
            return self
        end

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
            Dot.Position = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)

            local function Update()
                if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end

                local targetColor = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
                Tween(Switch, {ImageColor3 = targetColor}, 0.2)

                local targetPos = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
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
                    Dot.Position = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
                    callback(Enabled)
                end
            }
        end

        child.Slider = function(_, sliderText, min, max, default, callback, options)
            options = options or {}
            local Val = default or min

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 60)
            Frame.Parent = contentContainer
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Frame, "BackgroundColor3", "Top")

            local TopRow = Instance.new("Frame")
            TopRow.Size = UDim2.new(1, -20, 0, 30)
            TopRow.Position = UDim2.new(0, 10, 0, 5)
            TopRow.BackgroundTransparency = 1
            TopRow.Parent = Frame

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = sliderText
            Lbl.Size = UDim2.new(0.5, 0, 1, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 14
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = TopRow
            AddToRegistry(Lbl, "TextColor3", "Text")

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

            local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0, 4); boxCorner.Parent = NumBox
            local boxStroke = Instance.new("UIStroke"); boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; boxStroke.Color = Color3.fromRGB(255, 255, 255); boxStroke.Transparency = 0.9; boxStroke.Parent = NumBox
            local boxPadding = Instance.new("UIPadding"); boxPadding.PaddingLeft = UDim.new(0, 2); boxPadding.PaddingRight = UDim.new(0, 2); boxPadding.Parent = NumBox

            local SliderBar = Instance.new("ImageLabel")
            SliderBar.Name = "SliderBar"
            SliderBar.Image = SliderAssets.Bar
            SliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
            SliderBar.BackgroundTransparency = 1
            SliderBar.Size = UDim2.new(1, -20, 0, 3)
            SliderBar.Position = UDim2.new(0, 10, 0, 40)
            SliderBar.Parent = Frame

            local SliderHead = Instance.new("ImageButton")
            SliderHead.Name = "SliderHead"
            SliderHead.Image = SliderAssets.Head
            SliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderHead.BackgroundTransparency = 1
            SliderHead.Size = UDim2.fromOffset(16, 16)
            SliderHead.Parent = SliderBar
            local initPosX = (Val - min) / (max - min)
            SliderHead.Position = UDim2.new(initPosX, 0, 0.5, 0)

            local DisplayMethods = {
                Value = function(sv, p) return p and string.format("%."..p.."f", sv) or tostring(math.round(sv*100)/100) end,
                Percent = function(sv, p) local perc = (sv-min)/(max-min)*100; return (p and string.format("%."..p.."f", perc) or tostring(math.round(perc))).."%" end,
            }
            local displayMethod = DisplayMethods[options.DisplayMethod] or DisplayMethods.Value
            local precision = options.Precision

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
                NumBox.Text = displayMethod(newValue, precision)
                if not ignorecallback then task.spawn(function() if callback then callback(newValue) end end) end
                if ConfigObjects[sliderText] then ConfigObjects[sliderText].Value = newValue end
            end
            SetValue(Val, true)

            local dragging = false
            SliderHead.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; PlaySound(Sounds.Slide); SetValue(input)
                end
            end)
            SliderHead.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then SetValue(input) end
            end)

            NumBox.FocusLost:Connect(function()
                local v = tonumber(NumBox.Text:match("%d+%.?%d*"))
                if v then
                    if options.DisplayMethod == "Percent" then v = min + (v/100)*(max-min) end
                    SetValue(math.clamp(v, min, max), false)
                else SetValue(Val, true) end
            end)

            ConfigObjects[sliderText] = {Type = "Slider", Value = Val, Set = function(val) SetValue(val, true) end}
        end

        child.Textbox = function(_, boxText, placeholder, callback)
            local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,0,0,60); Frame.Parent = contentContainer; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6); AddToRegistry(Frame, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = boxText; Lbl.Size = UDim2.new(1,0,0,20); Lbl.Position = UDim2.new(0,10,0,5); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame; AddToRegistry(Lbl, "TextColor3", "Text")
            local Box = Instance.new("TextBox"); Box.Size = UDim2.new(1,-20,0,25); Box.Position = UDim2.new(0,10,0,28); Box.Text = ""; Box.PlaceholderText = placeholder; Box.Font = Enum.Font.Gotham; Box.TextSize = 13; Box.BorderSizePixel = 0; Box.Parent = Frame; Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4); AddToRegistry(Box, "BackgroundColor3", "Main"); AddToRegistry(Box, "TextColor3", "Text")
            local boxStroke = Instance.new("UIStroke"); boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; boxStroke.Color = Color3.fromRGB(255,255,255); boxStroke.Transparency = 0.9; boxStroke.Parent = Box
            Box.FocusLost:Connect(function() ConfigObjects[boxText].Value = Box.Text; callback(Box.Text) end)
            ConfigObjects[boxText] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; callback(val) end}
        end

        child.Dropdown = function(_, dropText, options, callback)
            local Dropped = false
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,0,35); Btn.Text = ""; Btn.Parent = contentContainer; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = dropText; Lbl.Size = UDim2.new(1,-30,1,0); Lbl.Position = UDim2.new(0,10,0,0); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Btn; AddToRegistry(Lbl, "TextColor3", "Text")
            local Icon = Instance.new("ImageLabel"); Icon.Image = "rbxassetid://18865373378"; Icon.Size = UDim2.new(0,20,0,20); Icon.Position = UDim2.new(1,-30,0.5,-10); Icon.BackgroundTransparency = 1; Icon.Parent = Btn
            local Container = Instance.new("Frame"); Container.Size = UDim2.new(1,0,0,0); Container.Visible = false; Container.ClipsDescendants = true; Container.Parent = contentContainer; Container.ZIndex = 10; Instance.new("UICorner", Container).CornerRadius = UDim.new(0,6); AddToRegistry(Container, "BackgroundColor3", "Top")
            local List = Instance.new("UIListLayout"); List.SortOrder = Enum.SortOrder.LayoutOrder; List.Parent = Container

            local function Select(opt)
                Dropped = false; Lbl.Text = dropText..": "..opt; ConfigObjects[dropText].Value = opt; callback(opt)
                Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2); Tween(Icon, {Rotation = 0}, 0.2); task.wait(0.2); Container.Visible = false; updateSectionHeight(false)
            end
            local function RefreshOptions(newOpts)
                for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton"); O.Size = UDim2.new(1,0,0,30); O.Text = opt; O.TextColor3 = Color3.fromRGB(150,150,150); O.Font = Enum.Font.Gotham; O.TextSize = 13; O.BackgroundTransparency = 1; O.Parent = Container
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                end
            end
            RefreshOptions(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped; PlaySound(Sounds.Click)
                if Dropped then
                    Container.Visible = true
                    local targetHeight = #options * 30
                    local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, targetHeight)})
                    tweenOpt:Play(); Tween(Icon, {Rotation = 180}, 0.3)
                    tweenOpt.Completed:Connect(function() updateSectionHeight(false) end)
                else
                    local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, 0)})
                    tweenOpt:Play(); Tween(Icon, {Rotation = 0}, 0.2)
                    tweenOpt.Completed:Connect(function() Container.Visible = false; updateSectionHeight(false) end)
                end
            end)
            ConfigObjects[dropText] = {Type = "Dropdown", Value = options[1], Set = function(val) Select(val) end, Refresh = RefreshOptions}
            return {Refresh = RefreshOptions}
        end

        child.Keybind = function(_, keyText, default, callback)
            local Key = default or Enum.KeyCode.M
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Text = ""; Btn.Parent = contentContainer; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Title = Instance.new("TextLabel"); Title.Text = keyText; Title.Size = UDim2.new(0.6, 0, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.Gotham; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Btn; AddToRegistry(Title, "TextColor3", "Text")
            local BinderBox = Instance.new("TextBox"); BinderBox.Name = "BinderBox"; BinderBox.Font = Enum.Font.GothamBold; BinderBox.Text = Key.Name; BinderBox.TextColor3 = Color3.fromRGB(255,255,255); BinderBox.TextSize = 13; BinderBox.TextTransparency = 0.1; BinderBox.PlaceholderText = "..."; BinderBox.BackgroundTransparency = 0.2; BinderBox.BorderSizePixel = 0; BinderBox.Size = UDim2.new(0,80,0,24); BinderBox.Position = UDim2.new(1,-90,0.5,-12); BinderBox.Parent = Btn; Instance.new("UICorner", BinderBox).CornerRadius = UDim.new(0,5); AddToRegistry(BinderBox, "BackgroundColor3", "Main"); AddToRegistry(BinderBox, "TextColor3", "Accent")
            local boxStroke = Instance.new("UIStroke"); boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; boxStroke.Color = Color3.fromRGB(255,255,255); boxStroke.Transparency = 0.9; boxStroke.Parent = BinderBox
            local isBinding = false; local focused = false
            Btn.MouseButton1Click:Connect(function() PlaySound(Sounds.Click); BinderBox:CaptureFocus() end)
            BinderBox.Focused:Connect(function() focused = true; isBinding = true; BinderBox.Text = ""; BinderBox.PlaceholderText = "..." end)
            BinderBox.FocusLost:Connect(function() focused = false; isBinding = false; BinderBox.Text = Key.Name; BinderBox.PlaceholderText = "" end)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if focused and isBinding then
                    local newKey
                    if input.UserInputType == Enum.UserInputType.Keyboard then newKey = input.KeyCode
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then newKey = input.UserInputType end
                    if newKey and newKey.Name ~= "Unknown" then
                        Key = newKey; BinderBox.Text = Key.Name; callback(Key); Window:Notification("Keybind: " .. Key.Name)
                        ConfigObjects[keyText].Value = Key.Name
                    end
                    BinderBox:ReleaseFocus()
                end
            end)
            ConfigObjects[keyText] = {Type = "Keybind", Value = Key.Name, Set = function(val) Key = Enum.KeyCode[val] or Key; BinderBox.Text = Key.Name; callback(Key) end}
            local self = {}; function self.UpdateText(newText) Title.Text = newText end; function self.SetVisible(state) Btn.Visible = state end; return self
        end

        child.Input = function(_, inputText, default, callback, options)
            options = options or {}
            local placeholder = options.placeholder or ""; local acceptedCharacters = options.acceptedCharacters or "All"; local characterLimit = options.characterLimit; local onChanged = options.onChanged
            local InputFrame = Instance.new("Frame"); InputFrame.Size = UDim2.new(1, 0, 0, 35); InputFrame.Parent = contentContainer; Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6); AddToRegistry(InputFrame, "BackgroundColor3", "Top")
            local NameLbl = Instance.new("TextLabel"); NameLbl.Text = inputText; NameLbl.Size = UDim2.new(0.6,0,1,0); NameLbl.Position = UDim2.new(0,10,0,0); NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.Font = Enum.Font.Gotham; NameLbl.TextSize = 14; NameLbl.BackgroundTransparency = 1; NameLbl.Parent = InputFrame; AddToRegistry(NameLbl, "TextColor3", "Text")
            local InputBox = Instance.new("TextBox"); InputBox.Text = tostring(default or ""); InputBox.PlaceholderText = placeholder; InputBox.Size = UDim2.new(0.3,0,0,26); InputBox.Position = UDim2.new(0.7,-10,0.5,-13); InputBox.Font = Enum.Font.GothamBold; InputBox.TextSize = 13; InputBox.TextXAlignment = Enum.TextXAlignment.Center; InputBox.ClearTextOnFocus = false; InputBox.Parent = InputFrame
            local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0,5); boxCorner.Parent = InputBox
            AddToRegistry(InputBox, "BackgroundColor3", "Main"); AddToRegistry(InputBox, "TextColor3", "Accent")
            local boxStroke = Instance.new("UIStroke"); boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; boxStroke.Color = Color3.fromRGB(255,255,255); boxStroke.Transparency = 0.9; boxStroke.Parent = InputBox
            local function filterText(text)
                if characterLimit then text = text:sub(1,characterLimit) end
                if type(acceptedCharacters)=="function" then return acceptedCharacters(text)
                elseif acceptedCharacters=="Numeric" then return text:gsub("[^%d-]",""):gsub("-(.*)",function(m) return m:gsub("-","") end)
                elseif acceptedCharacters=="Alphabetic" then return text:gsub("[^a-zA-Z]","")
                elseif acceptedCharacters=="AlphaNumeric" then return text:gsub("[^a-zA-Z0-9]","")
                else return text end
            end
            InputBox:GetPropertyChangedSignal("Text"):Connect(function() local filtered = filterText(InputBox.Text); if filtered~=InputBox.Text then InputBox.Text=filtered end; if onChanged then onChanged(filtered) end end)
            InputBox.FocusLost:Connect(function() local text = InputBox.Text; local filtered = filterText(text); if filtered~=text then InputBox.Text = filtered; text = filtered end; if callback then callback(text) end end)
            ConfigObjects[inputText] = {Type = "Input", Value = InputBox.Text, Set = function(val) InputBox.Text = tostring(val) end}
            local self = {}; function self.UpdateText(newText) InputBox.Text = tostring(newText); ConfigObjects[inputText].Value = InputBox.Text end; function self.GetText() return InputBox.Text end; function self.SetVisible(state) InputFrame.Visible = state end; function self.UpdatePlaceholder(newPlaceholder) InputBox.PlaceholderText = newPlaceholder end; return self
        end

        -- ==================== 颜色选择器 ====================
        child.Colorpicker = function(_, pickerText, default, callback, options)
            options = options or {}
            local isAlpha = options.Alpha ~= nil
            local Color = default or Color3.new(1,1,1)
            local Alpha = isAlpha and options.Alpha or 0

            -- 主容器
            local Main = Instance.new("TextButton")
            Main.Size = UDim2.new(1, 0, 0, 35)
            Main.Text = ""
            Main.Parent = contentContainer
            Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Main, "BackgroundColor3", "Top")

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

            local PreviewBg = Instance.new("ImageLabel")
            PreviewBg.Name = "ColorPreviewBg"
            PreviewBg.Image = ColorPickerAssets.Grid
            PreviewBg.ScaleType = Enum.ScaleType.Tile
            PreviewBg.TileSize = UDim2.fromOffset(20, 20)
            PreviewBg.Size = UDim2.new(0, 30, 0, 20)
            PreviewBg.Position = UDim2.new(1, -40, 0.5, -10)
            PreviewBg.BackgroundTransparency = 1
            PreviewBg.Parent = Main

            local previewCorner = Instance.new("UICorner")
            previewCorner.CornerRadius = UDim.new(0, 6)
            previewCorner.Parent = PreviewBg

            local PreviewColor = Instance.new("Frame")
            PreviewColor.Name = "PreviewColor"
            PreviewColor.Size = UDim2.new(1, 0, 1, 0)
            PreviewColor.BackgroundColor3 = Color
            PreviewColor.BackgroundTransparency = Alpha
            PreviewColor.BorderSizePixel = 0
            PreviewColor.Parent = PreviewBg
            Instance.new("UICorner", PreviewColor).CornerRadius = UDim.new(0, 6)

            local previewStroke = Instance.new("UIStroke")
            previewStroke.Thickness = 1
            previewStroke.Parent = PreviewBg
            AddToRegistry(previewStroke, "Color", "Stroke")

            -- 打开选择器
            local colorPickerOpen = false
            local function openColorPicker()
                if colorPickerOpen then return end
                colorPickerOpen = true

                -- 创建遮罩 CanvasGroup
                local canvas = Instance.new("CanvasGroup")
                canvas.Name = "ColorPickerCanvas"
                canvas.Size = UDim2.new(1, 0, 1, 0)
                canvas.BackgroundTransparency = 1
                canvas.GroupTransparency = 1
                canvas.ZIndex = 200
                canvas.Parent = ScreenGui

                -- 遮罩背景
                local overlay = Instance.new("Frame")
                overlay.Size = UDim2.new(1, 0, 1, 0)
                overlay.BackgroundColor3 = Color3.new(0,0,0)
                overlay.BackgroundTransparency = 0.5
                overlay.ZIndex = 1
                overlay.Parent = canvas
                
                -- 选择器主框
                local prompt = Instance.new("Frame")
                prompt.Name = "ColorPickerPrompt"
                prompt.AnchorPoint = Vector2.new(0.5, 0.5)
                prompt.Position = UDim2.new(0.5, 0, 0.5, 0)
                prompt.Size = UDim2.fromOffset(340, 0)
                prompt.AutomaticSize = Enum.AutomaticSize.Y
                prompt.BackgroundColor3 = CurrentTheme.Main
                prompt.BorderSizePixel = 0
                prompt.ZIndex = 2
                prompt.Parent = canvas

                canvas.GroupTransparency = 0

                local promptCorner = Instance.new("UICorner"); promptCorner.CornerRadius = UDim.new(0, 10); promptCorner.Parent = prompt
                local promptStroke = Instance.new("UIStroke"); promptStroke.Thickness = 2; promptStroke.Parent = prompt; AddToRegistry(promptStroke, "Color", "Stroke")

                -- 内部布局
                local list = Instance.new("UIListLayout")
                list.Padding = UDim.new(0, 8)
                list.HorizontalAlignment = Enum.HorizontalAlignment.Center
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Parent = prompt

                local padding = Instance.new("UIPadding")
                padding.PaddingBottom = UDim.new(0, 15)
                padding.PaddingLeft = UDim.new(0, 8)
                padding.PaddingRight = UDim.new(0, 15)
                padding.PaddingTop = UDim.new(0, 15)
                padding.Parent = prompt

                -- 颜色轮 + 输入区
                local wheelRow = Instance.new("Frame")
                wheelRow.Size = UDim2.new(1, 0, 0, 170)
                wheelRow.BackgroundTransparency = 1
                wheelRow.Parent = prompt

                -- 颜色轮
                local wheel = Instance.new("ImageButton")
                wheel.Name = "ColorWheel"
                wheel.Image = ColorPickerAssets.Wheel
                wheel.AutoButtonColor = false
                wheel.Size = UDim2.fromOffset(170, 170)
                wheel.Position = UDim2.new(0, 0, 0.5, -85)
                wheel.BackgroundTransparency = 1
                wheel.Parent = wheelRow

                local target = Instance.new("ImageLabel")
                target.Name = "Target"
                target.Image = ColorPickerAssets.Target
                target.AnchorPoint = Vector2.new(0.5, 0.5)
                target.Size = UDim2.fromOffset(20, 20)
                target.BackgroundTransparency = 1
                target.Parent = wheel
                target.Position = UDim2.new(0.5, 0, 0.5, 0)

                -- 右侧输入区
                local inputs = Instance.new("Frame")
                inputs.Size = UDim2.new(0, 140, 1, 0)
                inputs.Position = UDim2.new(1, -140, 0, 0)
                inputs.BackgroundTransparency = 1
                inputs.Parent = wheelRow

                local inputList = Instance.new("UIListLayout")
                inputList.Padding = UDim.new(0, 4)
                inputList.SortOrder = Enum.SortOrder.LayoutOrder
                inputList.Parent = inputs

                local function createInputRow(labelText, defaultText)
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 26)
                    row.BackgroundTransparency = 1
                    row.Parent = inputs

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0, 30, 1, 0)
                    label.Text = labelText
                    label.TextColor3 = CurrentTheme.Text
                    label.BackgroundTransparency = 1
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 12
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Parent = row
                    AddToRegistry(label, "TextColor3", "Text")

                    local box = Instance.new("TextBox")
                    box.Size = UDim2.new(1, -35, 0, 22)
                    box.Position = UDim2.new(0, 35, 0.5, -11)
                    box.Text = defaultText
                    box.TextColor3 = CurrentTheme.Accent
                    box.BackgroundColor3 = CurrentTheme.Main
                    box.BackgroundTransparency = 0.2
                    box.BorderSizePixel = 0
                    box.Font = Enum.Font.Gotham
                    box.TextSize = 11
                    box.Parent = row

                    local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0, 4); boxCorner.Parent = box
                    local boxStroke = Instance.new("UIStroke"); boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; boxStroke.Color = Color3.fromRGB(255,255,255); boxStroke.Transparency = 0.9; boxStroke.Parent = box
                    return box
                end

                local redBox = createInputRow("R", tostring(math.floor(Color.R * 255 + 0.5)))
                local greenBox = createInputRow("G", tostring(math.floor(Color.G * 255 + 0.5)))
                local blueBox = createInputRow("B", tostring(math.floor(Color.B * 255 + 0.5)))
                local alphaBox = isAlpha and createInputRow("A", tostring(Alpha)) or nil
                local hexBox = createInputRow("Hex", string.format("#%02X%02X%02X", math.floor(Color.R*255+0.5), math.floor(Color.G*255+0.5), math.floor(Color.B*255+0.5)))

                -- 亮度滑块
                local valueSliderRow = Instance.new("Frame")
                valueSliderRow.Size = UDim2.new(1, 0, 0, 28)
                valueSliderRow.BackgroundTransparency = 1
                valueSliderRow.Parent = prompt

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 30, 1, 0)
                valueLabel.Text = "V"
                valueLabel.TextColor3 = CurrentTheme.Text
                valueLabel.BackgroundTransparency = 1
                valueLabel.Font = Enum.Font.GothamBold
                valueLabel.TextSize = 12
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.Parent = valueSliderRow
                AddToRegistry(valueLabel, "TextColor3", "Text")

                local valueSlider = Instance.new("Frame")
                valueSlider.Size = UDim2.new(1, -40, 0, 12)
                valueSlider.Position = UDim2.new(0, 20, 0.5, -6)
                valueSlider.BackgroundColor3 = Color3.new(1,1,1)
                valueSlider.BackgroundTransparency = 0.2
                valueSlider.Parent = valueSliderRow
                Instance.new("UICorner", valueSlider).CornerRadius = UDim.new(1,0)

                local valueGradient = Instance.new("UIGradient")
                valueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
                })
                valueGradient.Rotation = 180
                valueGradient.Parent = valueSlider

                local valueThumb = Instance.new("ImageButton")
                valueThumb.Size = UDim2.new(0, 18, 0, 18)
                valueThumb.AnchorPoint = Vector2.new(0.5, 0.5)
                valueThumb.Position = UDim2.new(1, 0, 0.5, 0)
                valueThumb.BackgroundColor3 = Color3.new(1,1,1)
                valueThumb.AutoButtonColor = false
                valueThumb.Parent = valueSlider
                Instance.new("UICorner", valueThumb).CornerRadius = UDim.new(1,0)

                -- 新旧颜色对比
                local colorWells = Instance.new("Frame")
                colorWells.Size = UDim2.new(1, 0, 0, 32)
                colorWells.BackgroundTransparency = 1
                colorWells.Parent = prompt

                local gridLayout = Instance.new("UIGridLayout")
                gridLayout.CellSize = UDim2.new(0.5, -5, 1, 0)
                gridLayout.CellPadding = UDim2.new(0, 8, 0, 0)
                gridLayout.Parent = colorWells

                -- 新颜色块
                local newColorWell = Instance.new("ImageLabel")
                newColorWell.Image = ColorPickerAssets.Grid
                newColorWell.ScaleType = Enum.ScaleType.Tile
                newColorWell.TileSize = UDim2.fromOffset(20,20)
                newColorWell.BackgroundTransparency = 1
                newColorWell.Parent = colorWells
                local newWellCorner = Instance.new("UICorner")
                newWellCorner.CornerRadius = UDim.new(0, 12)
                newWellCorner.Parent = newColorWell

                local newColorInner = Instance.new("Frame")
                newColorInner.Size = UDim2.new(1,0,1,0)
                newColorInner.BackgroundColor3 = Color
                newColorInner.BackgroundTransparency = Alpha
                newColorInner.BorderSizePixel = 0
                newColorInner.Parent = newColorWell
                local newInnerCorner = Instance.new("UICorner")
                newInnerCorner.CornerRadius = UDim.new(0, 12)
                newInnerCorner.Parent = newColorInner

                -- 旧颜色块
                local oldColorWell = Instance.new("ImageLabel")
                oldColorWell.Image = ColorPickerAssets.Grid
                oldColorWell.ScaleType = Enum.ScaleType.Tile
                oldColorWell.TileSize = UDim2.fromOffset(20,20)
                oldColorWell.BackgroundTransparency = 1
                oldColorWell.Parent = colorWells
                local oldWellCorner = Instance.new("UICorner")
                oldWellCorner.CornerRadius = UDim.new(0, 12)
                oldWellCorner.Parent = oldColorWell

                local oldColorInner = Instance.new("Frame")
                oldColorInner.Size = UDim2.new(1,0,1,0)
                oldColorInner.BackgroundColor3 = Color
                oldColorInner.BackgroundTransparency = Alpha
                oldColorInner.BorderSizePixel = 0
                oldColorInner.Parent = oldColorWell
                local oldInnerCorner = Instance.new("UICorner")
                oldInnerCorner.CornerRadius = UDim.new(0, 12)
                oldInnerCorner.Parent = oldColorInner

                -- 确认按钮
                local buttonRow = Instance.new("Frame")
                buttonRow.Size = UDim2.new(1, 0, 0, 30)
                buttonRow.BackgroundTransparency = 1
                buttonRow.Parent = prompt

                local confirm = Instance.new("TextButton")
                confirm.Size = UDim2.new(1, 0, 1, 0)
                confirm.Position = UDim2.new(0, 0, 0, 0)
                confirm.Text = "Confirm"
                confirm.Font = Enum.Font.GothamBold
                confirm.TextSize = 12
                confirm.BackgroundColor3 = CurrentTheme.Accent
                confirm.TextColor3 = CurrentTheme.Text
                confirm.Parent = buttonRow
                Instance.new("UICorner", confirm).CornerRadius = UDim.new(0, 5)

                -- 颜色选择逻辑
                local hue, saturation, value = Color3.toHSV(Color)
                if not hue then hue = 0; saturation = 0; value = 1 end

                local function updateColorFromHSV()
                    local c = Color3.fromHSV(hue, saturation, value)
                    PreviewColor.BackgroundColor3 = c
                    PreviewColor.BackgroundTransparency = Alpha
                    newColorInner.BackgroundColor3 = c
                    newColorInner.BackgroundTransparency = Alpha
                    redBox.Text = tostring(math.floor(c.R * 255 + 0.5))
                    greenBox.Text = tostring(math.floor(c.G * 255 + 0.5))
                    blueBox.Text = tostring(math.floor(c.B * 255 + 0.5))
                    hexBox.Text = string.format("#%02X%02X%02X", math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
                end

                local function updateWheelPosition()
                    local r = wheel.AbsoluteSize.X / 2
                    local phi = hue * 2 * math.pi - math.pi
                    local len = saturation * r
                    local dx = len * math.cos(phi)
                    local dy = -len * math.sin(phi)
                    target.Position = UDim2.new(0.5, dx, 0.5, dy)
                    valueSlider.BackgroundColor3 = Color3.fromHSV(hue, saturation, 1)
                end

                local function updateHueSatFromMouse(mouseX, mouseY)
                    local center = wheel.AbsolutePosition + wheel.AbsoluteSize / 2
                    local dx = mouseX - center.X
                    local dy = mouseY - center.Y
                    local r = wheel.AbsoluteSize.X / 2
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist > r then
                        dx = dx / dist * r
                        dy = dy / dist * r
                    end
                    target.Position = UDim2.new(0.5, dx, 0.5, dy)

                    local phi = math.atan2(-dy, dx)
                    hue = (phi + math.pi) / (2 * math.pi)
                    saturation = math.min(dist / r, 1)
                    updateColorFromHSV()
                    valueSlider.BackgroundColor3 = Color3.fromHSV(hue, saturation, 1)
                end

                local function UpdateSlide(iX)
                    local sliderX = valueSlider.AbsolutePosition.X
                    local sliderW = valueSlider.AbsoluteSize.X
                    local thumbW = valueThumb.AbsoluteSize.X
                    local relativeX = iX - sliderX
                    local left = math.clamp(relativeX - thumbW/2, 0, sliderW - thumbW)
                    valueThumb.Position = UDim2.new(0, left + thumbW/2, 0.5, 0)
                    value = 1 - left / (sliderW - thumbW)
                    updateColorFromHSV()
                end

                local function updateFromRGB()
                    local r = tonumber(redBox.Text) or 0; local g = tonumber(greenBox.Text) or 0; local b = tonumber(blueBox.Text) or 0
                    r = math.clamp(r,0,255)/255; g = math.clamp(g,0,255)/255; b = math.clamp(b,0,255)/255
                    local c = Color3.new(r,g,b)
                    hue, saturation, value = c:ToHSV()
                    updateWheelPosition()
                    updateSliderPosition()
                    updateColorFromHSV()
                end

                local function updateSliderPosition()
                    local left = (1 - value) * (valueSlider.AbsoluteSize.X - valueThumb.AbsoluteSize.X)
                    valueThumb.Position = UDim2.new(0, left + valueThumb.AbsoluteSize.X/2, 0.5, 0)
                end

                local function updateFromHex()
                    local hex = hexBox.Text:gsub("#","")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2),16) or 0; local g = tonumber(hex:sub(3,4),16) or 0; local b = tonumber(hex:sub(5,6),16) or 0
                        r = math.clamp(r,0,255)/255; g = math.clamp(g,0,255)/255; b = math.clamp(b,0,255)/255
                        local c = Color3.new(r,g,b)
                        hue, saturation, value = c:ToHSV()
                        updateWheelPosition()
                        updateSliderPosition()
                        updateColorFromHSV()
                    end
                end

                local wheelDragging = false
                wheel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        wheelDragging = true
                        updateHueSatFromMouse(input.Position.X, input.Position.Y)
                    end
                end)
                wheel.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        wheelDragging = false
                    end
                end)

                local valueDragging = false
                valueThumb.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        valueDragging = true
                        UpdateSlide(input.Position.X)
                    end
                end)
                valueThumb.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        valueDragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if wheelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateHueSatFromMouse(input.Position.X, input.Position.Y)
                    elseif valueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlide(input.Position.X)
                    end
                end)

                local function onFocusEnter(box) local t = box.Text; box.Text = ""; box.PlaceholderText = t end
                redBox.Focused:Connect(function() onFocusEnter(redBox) end)
                greenBox.Focused:Connect(function() onFocusEnter(greenBox) end)
                blueBox.Focused:Connect(function() onFocusEnter(blueBox) end)
                if isAlpha then alphaBox.Focused:Connect(function() onFocusEnter(alphaBox) end) end
                hexBox.Focused:Connect(function() onFocusEnter(hexBox) end)

                redBox.FocusLost:Connect(updateFromRGB)
                greenBox.FocusLost:Connect(updateFromRGB)
                blueBox.FocusLost:Connect(updateFromRGB)
                hexBox.FocusLost:Connect(updateFromHex)
                if isAlpha then
                    alphaBox.FocusLost:Connect(function()
                        Alpha = math.clamp(tonumber(alphaBox.Text) or 0, 0, 1)
                        PreviewColor.BackgroundTransparency = Alpha
                        newColorInner.BackgroundTransparency = Alpha
                    end)
                end

                confirm.MouseButton1Click:Connect(function()
                    Color = PreviewColor.BackgroundColor3
                    Alpha = PreviewColor.BackgroundTransparency
                    callback(Color, Alpha)
                    ConfigObjects[pickerText] = {Type = "Colorpicker", Value = Color, Alpha = Alpha}
                    canvas:Destroy()
                    colorPickerOpen = false
                end)

                overlay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        canvas:Destroy()
                        colorPickerOpen = false
                    end
                end)

                RunService.RenderStepped:Wait()
                updateWheelPosition()
                updateSliderPosition()
            end

            Main.MouseButton1Click:Connect(openColorPicker)

            ConfigObjects[pickerText] = {
                Type = "Colorpicker",
                Value = Color,
                Alpha = Alpha,
                Set = function(color, alpha)
                    Color = color or Color
                    Alpha = alpha or Alpha
                    PreviewColor.BackgroundColor3 = Color
                    PreviewColor.BackgroundTransparency = Alpha
                    if callback then callback(Color, Alpha) end
                end
            }

            local self = {}
            function self.UpdateText(newText) Title.Text = newText end
            function self.SetVisible(state) Main.Visible = state end
            function self.SetColor(color, alpha)
                Color = color or Color
                Alpha = alpha or Alpha
                PreviewColor.BackgroundColor3 = Color
                PreviewColor.BackgroundTransparency = Alpha
                callback(Color, Alpha)
                ConfigObjects[pickerText].Value = Color
                ConfigObjects[pickerText].Alpha = Alpha
            end
            return self
        end

        -- ==================== Label ====================
        child.Label = function(_, labelText)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 35)
            LabelFrame.Parent = contentContainer
            Instance.new("UICorner", LabelFrame).CornerRadius = UDim.new(0, 6)
            AddToRegistry(LabelFrame, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -20, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.Gotham
            TextLabel.Text = labelText
            TextLabel.TextSize = 14
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TextLabel.Parent = LabelFrame
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) LabelFrame.Visible = state end
            return self
        end

        -- ==================== SubLabel ====================
        child.SubLabel = function(_, subLabelText)
            local SubLabelFrame = Instance.new("Frame")
            SubLabelFrame.Size = UDim2.new(1, 0, 0, 35)
            SubLabelFrame.Parent = contentContainer
            Instance.new("UICorner", SubLabelFrame).CornerRadius = UDim.new(0, 6)
            AddToRegistry(SubLabelFrame, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -20, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.Gotham
            TextLabel.Text = subLabelText
            TextLabel.TextSize = 12
            TextLabel.TextTransparency = 0.5
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TextLabel.Parent = SubLabelFrame
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) SubLabelFrame.Visible = state end
            return self
        end

        -- ==================== Paragraph ====================
        child.Paragraph = function(_, headerText, bodyText)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.Parent = contentContainer
            Instance.new("UICorner", ParaFrame).CornerRadius = UDim.new(0, 6)
            AddToRegistry(ParaFrame, "BackgroundColor3", "Top")

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 10)
            Padding.PaddingRight = UDim.new(0, 10)
            Padding.PaddingTop = UDim.new(0, 10)
            Padding.PaddingBottom = UDim.new(0, 10)
            Padding.Parent = ParaFrame

            local Layout = Instance.new("UIListLayout")
            Layout.Padding = UDim.new(0, 5)
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Parent = ParaFrame

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Size = UDim2.new(1, 0, 0, 0)
            HeaderLabel.AutomaticSize = Enum.AutomaticSize.Y
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.Text = headerText
            HeaderLabel.TextSize = 16
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.TextWrapped = true
            HeaderLabel.Parent = ParaFrame
            AddToRegistry(HeaderLabel, "TextColor3", "Accent")

            local BodyLabel = Instance.new("TextLabel")
            BodyLabel.Size = UDim2.new(1, 0, 0, 0)
            BodyLabel.AutomaticSize = Enum.AutomaticSize.Y
            BodyLabel.BackgroundTransparency = 1
            BodyLabel.Font = Enum.Font.Gotham
            BodyLabel.Text = bodyText
            BodyLabel.TextSize = 13
            BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
            BodyLabel.TextWrapped = true
            BodyLabel.Parent = ParaFrame
            AddToRegistry(BodyLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateHeader(newHeader) HeaderLabel.Text = newHeader end
            function self.UpdateBody(newBody) BodyLabel.Text = newBody end
            function self.SetVisible(state) ParaFrame.Visible = state end
            return self
        end

        return child
    end

    -- ==================== 普通单列标签 ====================
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
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame

        -- 添加左边距
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.Parent = ContentFrame

        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 28, 0, 28)  -- [!] 从 24x24 增大到 28x28
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then
                TabIcon.Image = "rbxassetid://" .. icon
            else
                TabIcon.Image = icon
            end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            -- [!] 添加圆角矩形效果 (圆角半径 8)
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
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

        -- 创建滚动页面
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.Visible = false
        Page.Parent = PageContainer

        -- 创建内容容器（用于避免滚动条遮挡）
        local ContentHolder = Instance.new("Frame")
        ContentHolder.Name = "Content"
        ContentHolder.Size = UDim2.new(1, 0, 0, 0)
        ContentHolder.AutomaticSize = Enum.AutomaticSize.Y
        ContentHolder.BackgroundTransparency = 1
        ContentHolder.Parent = Page

        local HolderPadding = Instance.new("UIPadding")
        HolderPadding.PaddingRight = UDim.new(0, 2) -- 滚动条厚度
        HolderPadding.Parent = ContentHolder

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = ContentHolder

        -- 更新画布高度
        local function updateCanvas()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.spawn(function() task.wait(); updateCanvas() end)

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
        function Elements:Section(text, icons, defaultOpen)
            return createSection(ContentHolder, text, icons, defaultOpen)
        end

        return Elements
    end

    -- ==================== 双窗口标签 ====================
    function Window:DualTab(name, icon)
        -- 创建标签按钮（与普通 Tab 相同）
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
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame

        -- 添加左边距
        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.Parent = ContentFrame

        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 28, 0, 28)  -- [!] 从 24x24 增大到 28x28
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then
                TabIcon.Image = "rbxassetid://" .. icon
            else
                TabIcon.Image = icon
            end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            -- [!] 添加圆角矩形效果 (圆角半径 8)
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
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

        -- 创建页面容器
        local PageFrame = Instance.new("Frame")
        PageFrame.Size = UDim2.new(1, 0, 1, 0)
        PageFrame.BackgroundTransparency = 1
        PageFrame.Visible = false
        PageFrame.Parent = PageContainer

        -- 左右列容器（水平布局）
        local Columns = Instance.new("Frame")
        Columns.Size = UDim2.new(1, 0, 1, 0)
        Columns.BackgroundTransparency = 1
        Columns.Parent = PageFrame

        local ColumnsLayout = Instance.new("UIListLayout")
        ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
        ColumnsLayout.Padding = UDim.new(0, 10)
        ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ColumnsLayout.Parent = Columns

        local ColumnsPadding = Instance.new("UIPadding")
        ColumnsPadding.PaddingLeft = UDim.new(0, 5)
        ColumnsPadding.PaddingRight = UDim.new(0, 5)
        ColumnsPadding.Parent = Columns

        -- 左列（ScrollingFrame）
        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollingDirection = Enum.ScrollingDirection.Y
        LeftColumn.ScrollBarThickness = 2
        LeftColumn.BottomImage = ""
        LeftColumn.TopImage = ""
        LeftColumn.Parent = Columns

        -- 左列内容容器
        local LeftHolder = Instance.new("Frame")
        LeftHolder.Name = "Content"
        LeftHolder.Size = UDim2.new(1, 0, 0, 0)
        LeftHolder.AutomaticSize = Enum.AutomaticSize.Y
        LeftHolder.BackgroundTransparency = 1
        LeftHolder.Parent = LeftColumn

        local LeftHolderPadding = Instance.new("UIPadding")
        LeftHolderPadding.PaddingRight = UDim.new(0, 2)
        LeftHolderPadding.Parent = LeftHolder

        local LeftList = Instance.new("UIListLayout")
        LeftList.Padding = UDim.new(0, 6)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Parent = LeftHolder

        -- 右列（ScrollingFrame）
        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollingDirection = Enum.ScrollingDirection.Y
        RightColumn.ScrollBarThickness = 2
        RightColumn.BottomImage = ""
        RightColumn.TopImage = ""
        RightColumn.Parent = Columns

        -- 右列内容容器
        local RightHolder = Instance.new("Frame")
        RightHolder.Name = "Content"
        RightHolder.Size = UDim2.new(1, 0, 0, 0)
        RightHolder.AutomaticSize = Enum.AutomaticSize.Y
        RightHolder.BackgroundTransparency = 1
        RightHolder.Parent = RightColumn

        local RightHolderPadding = Instance.new("UIPadding")
        RightHolderPadding.PaddingRight = UDim.new(0, 2)
        RightHolderPadding.Parent = RightHolder

        local RightList = Instance.new("UIListLayout")
        RightList.Padding = UDim.new(0, 6)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Parent = RightHolder

        -- 更新画布
        local function updateLeftCanvas()
            LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftList.AbsoluteContentSize.Y + 10)
        end
        local function updateRightCanvas()
            RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightList.AbsoluteContentSize.Y + 10)
        end
        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftCanvas)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightCanvas)
        task.spawn(function() task.wait(); updateLeftCanvas(); updateRightCanvas() end)

        -- 标签切换逻辑
        TabBtn.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab)
            for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    Tween(v, {BackgroundTransparency = 1})
                    local content = v:FindFirstChild("ContentFrame")
                    if content then
                        local textLabel = content:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            Tween(textLabel, {TextColor3 = Color3.fromRGB(150,150,150)})
                        end
                    end
                end
            end
            PageFrame.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
        end)

        if firstTab then
            firstTab = false
            PageFrame.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
        end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local DualElements = {}
        function DualElements:section(side, text, icons, defaultOpen)
            local holder = side == "Left" and LeftHolder or RightHolder
            return createSection(holder, text, icons, defaultOpen)
        end

        return DualElements
    end

    return Window
end

function Library:SetSFXEnabled(state) SFXEnabled = state end
return Library