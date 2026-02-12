repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

local function protectGUI(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif get_hidden_gui then
        get_hidden_gui(gui)
    end

    local success, err = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)

    if not success then
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("RobloxGui", gui)
    end
end

local FengUI = {}
local ToggleUI = true
FengUI.currentTab = nil
FengUI.flags = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

-- =========================================
-- 设备检测和UI尺寸设置
-- =========================================
local isMobile = UserInputService.TouchEnabled
local isConsole = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled
local isDesktop = not isMobile and not isConsole

local MAIN_WIDTH, MAIN_HEIGHT
local WORKAREA_WIDTH, WORKAREA_HEIGHT
local SIDEBAR_WIDTH

if isMobile then
    MAIN_WIDTH = 450
    MAIN_HEIGHT = 280
    WORKAREA_WIDTH = 280
    WORKAREA_HEIGHT = 280
    SIDEBAR_WIDTH = 150
else
    MAIN_WIDTH = 721
    MAIN_HEIGHT = 584
    WORKAREA_WIDTH = 458
    WORKAREA_HEIGHT = 584
    SIDEBAR_WIDTH = 233
end

-- =========================================
-- 现代化配色方案（模仿 UI.lua 暗色科技风）
-- =========================================
local config = {
    MainColor = Color3.fromRGB(18, 18, 30),        -- 主背景深空色
    TabColor = Color3.fromRGB(25, 25, 40),
    Bg_Color = Color3.fromRGB(20, 20, 35),
    Button_Color = Color3.fromRGB(30, 30, 50),
    Textbox_Color = Color3.fromRGB(30, 30, 50),
    Dropdown_Color = Color3.fromRGB(30, 30, 50),
    Keybind_Color = Color3.fromRGB(30, 30, 50),
    Label_Color = Color3.fromRGB(30, 30, 50),
    Slider_Color = Color3.fromRGB(30, 30, 50),
    SliderBar_Color = Color3.fromRGB(255, 60, 60), -- 热力红
    Toggle_Color = Color3.fromRGB(30, 30, 50),
    Toggle_Off = Color3.fromRGB(50, 50, 70),
    Toggle_On = Color3.fromRGB(255, 60, 60),
    AccentColor = Color3.fromRGB(255, 60, 60),
    TextColor = Color3.fromRGB(240, 245, 255),
    SecondaryTextColor = Color3.fromRGB(180, 190, 210),
    GlowColor = Color3.fromRGB(255, 80, 80),

    DeepSpaceColor = Color3.fromRGB(1, 2, 10),
    NebulaColor1 = Color3.fromRGB(40, 40, 40),
    NebulaColor2 = Color3.fromRGB(60, 60, 60),
    ElementColor = Color3.fromRGB(30, 30, 50),
    ElementTransparency = 0.2,
    GlassEffect = Color3.fromRGB(255, 255, 255),
}

-- =========================================
-- 特效函数（从 UI.lua 移植）
-- =========================================
local function startNeonFlowEffect(object, property, speed)
    speed = speed or 0.008
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + speed) % 1
        local r = math.sin(hue * 3 + 0) * 0.3 + 0.7
        local g = math.sin(hue * 3 + 2) * 0.1
        local b = math.sin(hue * 3 + 4) * 0.1
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createRainbowFlowEffect(object, property, speed)
    speed = speed or 0.008
    local timeOffset = math.random() * 10
    local connection
    local isRunning = true

    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent or not isRunning then
            if connection then
                connection:Disconnect()
            end
            return
        end
        local time = tick() + timeOffset
        local r = math.sin(time * 0.5 + 0) * 0.5 + 0.5
        local g = math.sin(time * 0.5 + 2) * 0.5 + 0.5
        local b = math.sin(time * 0.5 + 4) * 0.5 + 0.5
        object[property] = Color3.new(r, g, b)
    end)

    return {
        Disconnect = function()
            isRunning = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        IsRunning = function()
            return isRunning and object and object.Parent
        end
    }
end

local function createPulseGlow(object)
    local connection
    local isRunning = true

    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent or not isRunning then
            if connection then
                connection:Disconnect()
            end
            return
        end
        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)

    return {
        Disconnect = function()
            isRunning = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        IsRunning = function()
            return isRunning and object and object.Parent
        end
    }
end

local function create3DFlipAnimation(object, duration)
    duration = duration or 0.5
    services.TweenService:Create(object, TweenInfo.new(duration / 2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = 15
    }):Play()
    task.wait(duration / 2)
    services.TweenService:Create(object, TweenInfo.new(duration / 2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Rotation = 0
    }):Play()
end

local function setupSmoothScrolling(scrollingFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        scrollingFrame.ScrollingEnabled = layout.AbsoluteContentSize.Y > scrollingFrame.AbsoluteSize.Y
    end)
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

-- =========================================
-- 清理旧GUI
-- =========================================
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- =========================================
-- 创建主界面 (基于测试UI布局，但采用UI.lua风格)
-- =========================================
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- 打开按钮（带霓虹效果）
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 40, 0, 40)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"  -- 抽象图标
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(180, 180, 180)
OpenStroke.Thickness = 1.2
OpenStroke.Transparency = 0.4
startNeonFlowEffect(Open, "BackgroundColor3", 0.012)
createPulseGlow(OpenStroke)

-- 主窗口
local main = Instance.new("Frame")
main.Name = "main"
main.Parent = FengYu
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = config.MainColor
main.BackgroundTransparency = 0.05
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
main.Visible = false
main.Active = true
main.Draggable = true

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 10)
uc.Parent = main

-- 添加星空渐变背景（从UI.lua移植）
local function createSpaceBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "SpaceBackground"
    background.BackgroundColor3 = config.DeepSpaceColor
    background.BackgroundTransparency = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.ZIndex = -100

    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 10)
    backgroundCorner.Parent = background

    background.Parent = parent

    local gradient1 = Instance.new("UIGradient")
    gradient1.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.DeepSpaceColor),
        ColorSequenceKeypoint.new(0.3, config.NebulaColor1),
        ColorSequenceKeypoint.new(0.7, config.NebulaColor2),
        ColorSequenceKeypoint.new(1, config.DeepSpaceColor)
    })
    gradient1.Rotation = 45
    gradient1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    gradient1.Parent = background

    local gradient2 = Instance.new("UIGradient")
    gradient2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 90, 90))
    })
    gradient2.Rotation = 135
    gradient2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    gradient2.Parent = background

    return background
end
createSpaceBackground(main)

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = main
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 1

local neonStroke = Instance.new("UIStroke")
neonStroke.Parent = main
neonStroke.Thickness = 2
neonStroke.Transparency = 1
neonStroke.LineJoinMode = Enum.LineJoinMode.Round
startNeonFlowEffect(neonStroke, "Color", 0.01)
createPulseGlow(neonStroke)

-- 拖拽功能
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- 工作区 (右侧)
local workarea = Instance.new("Frame")
workarea.Name = "workarea"
workarea.Parent = main
workarea.BackgroundColor3 = config.MainColor
workarea.BackgroundTransparency = 0.1
workarea.Position = UDim2.new(0.36403501, 0, 0, 0)
workarea.Size = UDim2.new(0, WORKAREA_WIDTH, 0, WORKAREA_HEIGHT)

local uc_2 = Instance.new("UICorner")
uc_2.CornerRadius = UDim.new(0, 10)
uc_2.Parent = workarea

local workareacornerhider = Instance.new("Frame")
workareacornerhider.Name = "workareacornerhider"
workareacornerhider.Parent = workarea
workareacornerhider.BackgroundColor3 = config.MainColor
workareacornerhider.BorderSizePixel = 0
workareacornerhider.Size = UDim2.new(0, 18, 0.99895674, 0)

-- 搜索框 (右上角)
local search = Instance.new("Frame")
search.Name = "search"
search.Parent = workarea
search.BackgroundColor3 = config.Textbox_Color
search.BackgroundTransparency = 0.2
search.Position = UDim2.new(isMobile and 0.1 or 0.7, 0, 0.01, 0)
search.Size = UDim2.new(0, isMobile and 120 or 120, 0, 28)

local uc_8 = Instance.new("UICorner")
uc_8.CornerRadius = UDim.new(0, 6)
uc_8.Parent = search

local searchicon = Instance.new("ImageButton")
searchicon.Name = "searchicon"
searchicon.Parent = search
searchicon.BackgroundTransparency = 1
searchicon.Position = UDim2.new(0.05, 0, 0.1, 0)
searchicon.Size = UDim2.new(0, 20, 0, 20)
searchicon.Image = "rbxassetid://2804603863"
searchicon.ImageColor3 = config.SecondaryTextColor
searchicon.ScaleType = Enum.ScaleType.Fit

local searchtextbox = Instance.new("TextBox")
searchtextbox.Name = "searchtextbox"
searchtextbox.Parent = search
searchtextbox.BackgroundTransparency = 1
searchtextbox.ClipsDescendants = true
searchtextbox.Position = UDim2.new(0.3, 0, 0, 0)
searchtextbox.Size = UDim2.new(0, isMobile and 80 or 85, 0, 28)
searchtextbox.Font = Enum.Font.Gotham
searchtextbox.LineHeight = 0.870
searchtextbox.PlaceholderText = "Search"
searchtextbox.PlaceholderColor3 = config.SecondaryTextColor
searchtextbox.Text = ""
searchtextbox.TextColor3 = config.TextColor
searchtextbox.TextSize = isMobile and 14 or 16
searchtextbox.TextXAlignment = Enum.TextXAlignment.Left

searchicon.MouseButton1Click:Connect(function()
    searchtextbox:CaptureFocus()
end)

-- 侧边栏标题（脚本名）
local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Name = "SidebarTitle"
SidebarTitle.Parent = main
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.Position = UDim2.new(0.025, 0, 0.02, 0)
SidebarTitle.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, isMobile and 30 or 50)
SidebarTitle.Font = Enum.Font.GothamBold
SidebarTitle.Text = "FengUI"
SidebarTitle.TextColor3 = config.AccentColor
SidebarTitle.TextSize = isMobile and 18 or 24
SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
SidebarTitle.TextYAlignment = Enum.TextYAlignment.Center

-- 标签容器
local TagContainer = Instance.new("Frame")
TagContainer.Name = "TagContainer"
TagContainer.Parent = main
TagContainer.BackgroundTransparency = 1
TagContainer.Position = UDim2.new(0.025, 0, 0.12, 0)
TagContainer.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, 30)
TagContainer.ZIndex = 5

local TagLayout = Instance.new("UIListLayout")
TagLayout.Parent = TagContainer
TagLayout.FillDirection = Enum.FillDirection.Horizontal
TagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TagLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TagLayout.SortOrder = Enum.SortOrder.LayoutOrder
TagLayout.Padding = UDim.new(0, 5)

-- 侧边栏按钮容器
local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "sidebar"
sidebar.Parent = main
sidebar.Active = true
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.new(0.0249653254, 0, isMobile and 0.25 or 0.20, 0)
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, isMobile and 150 or 400)
sidebar.AutomaticCanvasSize = "Y"
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.ScrollBarThickness = 2

local ull_2 = Instance.new("UIListLayout")
ull_2.Parent = sidebar
ull_2.SortOrder = Enum.SortOrder.LayoutOrder
ull_2.Padding = UDim.new(0, 5)

-- 搜索功能
RunService:BindToRenderStep("search", 1, function()
    if not searchtextbox:IsFocused() then
        for _, v in next, sidebar:GetChildren() do
            if v:IsA("TextButton") then
                v.Visible = true
            end
        end
    end
    local InputText = string.upper(searchtextbox.Text)
    for _, button in pairs(sidebar:GetChildren()) do
        if button:IsA("TextButton") then
            if InputText == "" or string.find(string.upper(button.Text), InputText) ~= nil then
                button.Visible = true
            else
                button.Visible = false
            end
        end
    end
end)

-- 打开/关闭动画
Open.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        services.TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
    else
        services.TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 2, 0)
        }):Play()
    end
    create3DFlipAnimation(Open, 0.5)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        main.Visible = not main.Visible
        if main.Visible then
            services.TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        else
            services.TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 2, 0)
            }):Play()
        end
        create3DFlipAnimation(Open, 0.5)
    end
end)

-- 初始化显示动画
services.TweenService:Create(main, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()
main.Visible = true

-- =========================================
-- 标签切换逻辑
-- =========================================
local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end

    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        return
    end

    if old[1] == new[1] then return end

    switchingTabs = true
    FengUI.currentTab = new

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, {
        BackgroundTransparency = 1,
        TextColor3 = config.TextColor
    }):Play()
    services.TweenService:Create(new[1], tweenInfo, {
        BackgroundTransparency = 0,
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()

    old[2].Visible = false
    new[2].Visible = true

    task.wait(0.3)
    switchingTabs = false
end

-- =========================================
-- FengUI 构造函数（完全重写section，模仿UI.lua）
-- =========================================
function FengUI.new(name, theme)
    if name then
        SidebarTitle.Text = name
    else
        SidebarTitle.Text = "FengUI"
    end

    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end

    local window = {
        tabs = {},
        currentTab = nil,
        tags = {},
        tagObjects = {},
        tagCount = 0,
        maxTags = 3,
    }

    -- ---------- 标签方法 ----------
    function window:AddTag(text, bgColor, textColor, useNeonEffect)
        if self.tagCount >= self.maxTags then
            return nil
        end

        bgColor = bgColor or Color3.fromRGB(60, 60, 80)
        textColor = textColor or Color3.fromRGB(240, 245, 255)
        useNeonEffect = useNeonEffect or false

        local Tag = Instance.new("TextLabel")
        Tag.Name = "Tag_" .. text
        Tag.Parent = TagContainer
        Tag.BackgroundColor3 = bgColor
        Tag.BackgroundTransparency = 0.3
        Tag.Text = text
        Tag.Font = Enum.Font.GothamSemibold
        Tag.TextColor3 = textColor
        Tag.TextSize = 11
        Tag.TextWrapped = true
        Tag.Size = UDim2.new(0, 50, 0, 20)
        Tag.ZIndex = 6

        local TagCorner = Instance.new("UICorner")
        TagCorner.CornerRadius = UDim.new(0, 6)
        TagCorner.Parent = Tag

        local TagStroke = Instance.new("UIStroke")
        TagStroke.Parent = Tag
        TagStroke.Color = bgColor
        TagStroke.Thickness = 1
        TagStroke.Transparency = 0.5

        local textSize = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.GothamSemibold, Vector2.new(200, 20))
        Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 20)

        local tagObj = {
            Instance = Tag,
            Stroke = TagStroke,
            Text = text,
            Color = bgColor,
            TextColor = textColor,
            UseNeonEffect = useNeonEffect,

            RainbowBackgroundConnection = nil,
            RainbowBorderConnection = nil,
            PulseConnection = nil,
            InnerGlow = nil,

            Destroy = function()
                if tagObj.RainbowBackgroundConnection then
                    tagObj.RainbowBackgroundConnection:Disconnect()
                    tagObj.RainbowBackgroundConnection = nil
                end
                if tagObj.RainbowBorderConnection then
                    tagObj.RainbowBorderConnection:Disconnect()
                    tagObj.RainbowBorderConnection = nil
                end
                if tagObj.PulseConnection then
                    tagObj.PulseConnection:Disconnect()
                    tagObj.PulseConnection = nil
                end
                if tagObj.InnerGlow then
                    tagObj.InnerGlow:Destroy()
                    tagObj.InnerGlow = nil
                end
                Tag:Destroy()
            end,

            Update = function(newText, newBgColor, newTextColor, newUseNeonEffect)
                if newText then
                    Tag.Text = newText
                    tagObj.Text = newText
                    local textSize = game:GetService("TextService"):GetTextSize(newText, 11, Enum.Font.GothamSemibold, Vector2.new(200, 20))
                    Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 20)
                end
                if newBgColor then
                    tagObj.Color = newBgColor
                    if not tagObj.UseNeonEffect then
                        Tag.BackgroundColor3 = newBgColor
                        TagStroke.Color = newBgColor
                    end
                end
                if newTextColor then
                    Tag.TextColor3 = newTextColor
                    tagObj.TextColor = newTextColor
                end
                if newUseNeonEffect ~= nil then
                    tagObj:SetNeonEffect(newUseNeonEffect)
                end
                UpdateTagContainerPosition()
            end,

            SetNeonEffect = function(selfObj, enabled)
                if selfObj.RainbowBackgroundConnection then
                    selfObj.RainbowBackgroundConnection:Disconnect()
                    selfObj.RainbowBackgroundConnection = nil
                end
                if selfObj.RainbowBorderConnection then
                    selfObj.RainbowBorderConnection:Disconnect()
                    selfObj.RainbowBorderConnection = nil
                end
                if selfObj.PulseConnection then
                    selfObj.PulseConnection:Disconnect()
                    selfObj.PulseConnection = nil
                end
                if selfObj.InnerGlow then
                    selfObj.InnerGlow:Destroy()
                    selfObj.InnerGlow = nil
                end

                selfObj.UseNeonEffect = enabled

                if enabled then
                    selfObj.RainbowBackgroundConnection = createRainbowFlowEffect(Tag, "BackgroundColor3", 0.01)
                    selfObj.RainbowBorderConnection = createRainbowFlowEffect(TagStroke, "Color", 0.015)
                    selfObj.PulseConnection = createPulseGlow(TagStroke)

                    local innerGlow = Instance.new("UIGradient")
                    innerGlow.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 255, 100)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 255))
                    })
                    innerGlow.Rotation = 90
                    innerGlow.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.7),
                        NumberSequenceKeypoint.new(0.5, 0.3),
                        NumberSequenceKeypoint.new(1, 0.7)
                    })
                    innerGlow.Parent = Tag
                    selfObj.InnerGlow = innerGlow
                else
                    Tag.BackgroundColor3 = selfObj.Color
                    Tag.TextColor3 = selfObj.TextColor
                    TagStroke.Color = selfObj.Color
                    TagStroke.Transparency = 0.5

                    for _, child in ipairs(Tag:GetChildren()) do
                        if child:IsA("UIGradient") and child.Name ~= "InnerGlow" then
                            child:Destroy()
                        end
                    end
                end
            end,

            SetColor = function(selfObj, newColor)
                selfObj.Color = newColor
                if not selfObj.UseNeonEffect then
                    Tag.BackgroundColor3 = newColor
                    TagStroke.Color = newColor
                end
            end
        }

        if useNeonEffect then
            tagObj:SetNeonEffect(true)
        else
            Tag.BackgroundColor3 = tagObj.Color
            TagStroke.Color = tagObj.Color
        end

        table.insert(self.tags, Tag)
        table.insert(self.tagObjects, tagObj)
        self.tagCount = self.tagCount + 1

        UpdateTagContainerPosition()

        return tagObj
    end

    function window:UpdateTag(index, text, bgColor, textColor, useNeonEffect)
        if index < 1 or index > #self.tagObjects then return end
        local tagObj = self.tagObjects[index]
        if not tagObj or not tagObj.Instance or not tagObj.Instance.Parent then return end
        tagObj:Update(text, bgColor, textColor, useNeonEffect)
    end

    function window:ClearTags()
        for i = #self.tagObjects, 1, -1 do
            self:RemoveTag(i)
        end
        self.tagCount = 0
    end

    function window:RemoveTag(index)
        if index < 1 or index > #self.tagObjects then return end
        local tagObj = self.tagObjects[index]
        if tagObj then
            tagObj:Destroy()
            table.remove(self.tagObjects, index)
            table.remove(self.tags, index)
            self.tagCount = self.tagCount - 1
        end
    end

    -- ---------- Tab 创建 ----------
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1

        -- 侧边栏按钮（模仿UI.lua，带图标和文字）
        local sidebarBtn = Instance.new("ImageButton")
        sidebarBtn.Name = "sidebar2_" .. name
        sidebarBtn.Parent = sidebar
        sidebarBtn.BackgroundTransparency = 1
        sidebarBtn.Size = UDim2.new(0, SIDEBAR_WIDTH - 7, 0, isMobile and 28 or 37)
        sidebarBtn.AutoButtonColor = false
        sidebarBtn.Image = icon and (type(icon) == "string" and (icon:match("^%d+$") and "rbxassetid://" .. icon or icon) or "rbxassetid://84830962019412") or "rbxassetid://84830962019412"
        sidebarBtn.ImageColor3 = config.TextColor
        sidebarBtn.ImageTransparency = 0.5

        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = sidebarBtn
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.2, 0, 0, 0)
        TabText.Size = UDim2.new(0, 100, 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = isMobile and 14 or 16
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = sidebarBtn
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 1, 0)
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""

        -- 工作区主体
        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain_" .. name
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        workareamain.Position = UDim2.new(0.0393013097, 0, isMobile and 0.15 or 0.12, 0)
        workareamain.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 220 or 512)
        workareamain.ZIndex = 3
        workareamain.CanvasSize = UDim2.new(0, 0, 0, 0)
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = false
        workareamain.ScrollingEnabled = true
        workareamain.ElasticBehavior = Enum.ElasticBehavior.Never

        local MainContainer = Instance.new("Frame")
        MainContainer.Name = "MainContainer"
        MainContainer.Parent = workareamain
        MainContainer.BackgroundTransparency = 1
        MainContainer.Size = UDim2.new(1, 0, 0, 0)

        local workarealayout = Instance.new("UIListLayout")
        workarealayout.Parent = MainContainer
        workarealayout.SortOrder = Enum.SortOrder.LayoutOrder
        workarealayout.Padding = UDim.new(0, 10)

        setupSmoothScrolling(workareamain, workarealayout)

        table.insert(workareas, workareamain)

        local tab = {}

        -- ---------- 核心：模仿UI.lua的section，完全重写，解决重叠问题 ----------
        function tab.section(tab, name, TabVal)
            -- 参数处理：支持默认展开
            local open = true
            if TabVal ~= nil then
                if type(TabVal) == "boolean" then
                    open = TabVal
                elseif TabVal == "false" or TabVal == "0" then
                    open = false
                else
                    open = true
                end
            end

            local elementWidth = WORKAREA_WIDTH - 56  -- 工作区可用宽度
            if windowCount == 2 then
                -- 双栏模式宽度调整（保留但当前未启用）
                elementWidth = (WORKAREA_WIDTH - 56) / 2 - 8
            end

            -- ---------- Section 主框架 ----------
            local Section = Instance.new("Frame")
            Section.Name = "Section_" .. name
            Section.Parent = MainContainer
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 36)  -- 初始高度，随后动态调整

            -- ---------- 标题栏（带折叠图标）----------
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, 36)

            local SectionIcon = Instance.new("ImageLabel")
            SectionIcon.Name = "SectionIcon"
            SectionIcon.Parent = SectionHeader
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Position = UDim2.new(0, 5, 0, 5)
            SectionIcon.Size = UDim2.new(0, 22, 0, 22)
            SectionIcon.Image = "rbxassetid://84830962019412"  -- 通用图标
            SectionIcon.ImageColor3 = config.AccentColor

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 35, 0, 0)
            SectionTitle.Size = UDim2.new(1, -35, 1, 0)
            SectionTitle.Font = Enum.Font.GothamSemibold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.AccentColor
            SectionTitle.TextSize = isMobile and 14 or 16
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

            -- 折叠图标（两个状态：展开/折叠）
            local SectionOpenIcon = Instance.new("ImageLabel")
            SectionOpenIcon.Name = "SectionOpenIcon"
            SectionOpenIcon.Parent = SectionHeader
            SectionOpenIcon.BackgroundTransparency = 1
            SectionOpenIcon.Position = UDim2.new(1, -30, 0, 5)
            SectionOpenIcon.Size = UDim2.new(0, 22, 0, 22)
            SectionOpenIcon.Image = "rbxassetid://84830962019412"  -- 实际替换为箭头图标更好
            SectionOpenIcon.ImageColor3 = config.SecondaryTextColor
            SectionOpenIcon.Rotation = open and 0 or 180  -- 向下为展开，向上为折叠

            local SectionToggle = Instance.new("TextButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionHeader
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            SectionToggle.Text = ""

            -- ---------- 内容容器 ----------
            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 0, 0, 36)
            Objs.Size = UDim2.new(1, 0, 0, 0)
            Objs.Visible = open

            local ObjsL = Instance.new("UIListLayout")
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)

            -- 动态更新Section高度
            local function updateSectionHeight()
                local contentHeight = open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36
                Section.Size = UDim2.new(1, 0, 0, contentHeight)
            end

            updateSectionHeight()

            -- 监听内容变化
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
            end)

            -- 折叠/展开功能（带动画）
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
                }):Play()
                services.TweenService:Create(SectionOpenIcon, TweenInfo.new(0.3), {
                    Rotation = open and 0 or 180
                }):Play()
                Objs.Visible = open  -- 为了动画效果，直接修改可见性会突变，但配合size动画可接受
                if open then
                    Objs.Visible = true
                else
                    -- 延迟隐藏以等待收缩动画完成
                    task.delay(0.25, function()
                        if not open then Objs.Visible = false end
                    end)
                end
            end)

            -- ---------- 功能注入（模仿UI.lua，每个功能都添加霓虹效果和动画）----------
            local section = {}

            -- ---- Button ----
            function section.Button(section, text, callback)
                callback = callback or function() end

                local BtnModule = Instance.new("Frame")
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.Size = UDim2.new(0, elementWidth, 0, 36)

                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.2
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, elementWidth, 0, 36)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = isMobile and 12 or 14
                Btn.TextXAlignment = Enum.TextXAlignment.Left

                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Parent = Btn

                local btnGlow = Instance.new("UIStroke")
                btnGlow.Parent = Btn
                btnGlow.Color = config.AccentColor
                btnGlow.Thickness = 1
                btnGlow.Transparency = 0.8
                startNeonFlowEffect(btnGlow, "Color", 0.01)
                createPulseGlow(btnGlow)

                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.1),
                            math.floor(config.Button_Color.G * 255 * 1.1),
                            math.floor(config.Button_Color.B * 255 * 1.1)
                        )
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.5
                    }):Play()
                end)

                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)

                Btn.MouseButton1Click:Connect(function()
                    callback()
                    create3DFlipAnimation(Btn, 0.3)
                end)

                return Btn
            end

            -- ---- Image ----
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.Size = UDim2.new(0, elementWidth, 0, sizeY or 120)

                local ImageLabel = Instance.new("ImageLabel")
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or elementWidth - 20, elementWidth), 0, sizeY or 120)
                ImageLabel.ScaleType = Enum.ScaleType.Crop

                local ImageCorner = Instance.new("UICorner")
                ImageCorner.CornerRadius = UDim.new(0, 6)
                ImageCorner.Parent = ImageLabel

                local imageGlow = Instance.new("UIStroke")
                imageGlow.Parent = ImageLabel
                imageGlow.Color = config.AccentColor
                imageGlow.Thickness = 1
                imageGlow.Transparency = 0.8

                local function setImage(source)
                    if type(source) == "table" then
                        if source.Type == "Player" then
                            local userId = source.UserId
                            if userId then
                                task.spawn(function()
                                    local success, result = pcall(function()
                                        return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                                    end)
                                    if success and result then
                                        ImageLabel.Image = result
                                    else
                                        ImageLabel.Image = "rbxassetid://0"
                                    end
                                end)
                            end
                        elseif source.Type == "Game" then
                            local placeId = source.PlaceId
                            if placeId then
                                task.spawn(function()
                                    local success1, gameInfo = pcall(function()
                                        return game:GetService("MarketplaceService"):GetProductInfo(placeId, Enum.InfoType.Asset)
                                    end)
                                    if success1 and gameInfo and gameInfo.IconImageAssetId then
                                        ImageLabel.Image = "rbxassetid://" .. gameInfo.IconImageAssetId
                                        return
                                    end
                                    local success2, thumbnailUrl = pcall(function()
                                        return game:GetService("ThumbnailService"):GetGameThumbnailAsync(placeId)
                                    end)
                                    if success2 and thumbnailUrl then
                                        ImageLabel.Image = thumbnailUrl
                                        return
                                    end
                                    ImageLabel.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. placeId
                                end)
                            end
                        end
                    else
                        local imageId = tostring(source)
                        if imageId:match("^%d+$") then
                            ImageLabel.Image = "rbxassetid://" .. imageId
                        else
                            ImageLabel.Image = imageId
                        end
                    end
                end

                if imageSource then
                    setImage(imageSource)
                end

                local imageController = {}
                function imageController:SetImage(newSource)
                    setImage(newSource)
                end
                function imageController:Destroy()
                    ImageModule:Destroy()
                end
                return imageController
            end

            -- ---- Label ----
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.Size = UDim2.new(0, elementWidth, 0, 28)

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.2
                TextLabel.Size = UDim2.new(0, elementWidth, 0, 28)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = isMobile and 12 or 14

                local LabelC = Instance.new("UICorner")
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Parent = TextLabel

                return TextLabel
            end

            -- ---- Toggle ----
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                ToggleModule.Name = "toggle_" .. flag
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.Size = UDim2.new(0, elementWidth, 0, 36)

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.2
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = isMobile and 12 or 14
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Parent = ToggleBtn

                -- 开关滑块
                local ToggleDisable = Instance.new("Frame")
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
                ToggleDisable.BackgroundTransparency = 0.8
                ToggleDisable.Position = UDim2.new(0.78, 0, 0.22, 0)  -- 位置适应
                ToggleDisable.Size = UDim2.new(0, 34, 0, 18)

                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 20, 0, 18)
                ToggleSwitch.Position = UDim2.new(0, enabled and 14 or 0, 0, 0)

                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Parent = ToggleSwitch

                local ToggleDisableC = Instance.new("UICorner")
                ToggleDisableC.CornerRadius = UDim.new(0, 9)
                ToggleDisableC.Parent = ToggleDisable

                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengUI.flags[flag]
                        end
                        if FengUI.flags[flag] == state then
                            return
                        end
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, state and 14 or 0, 0, 0),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        FengUI.flags[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule
                }

                if enabled ~= false then
                    funcs:SetState(true)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)

                return funcs
            end

            -- ---- Keybind ----
            function section.Keybind(section, text, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(default, "No default key provided")

                local defaultKey = typeof(default) == "string" and Enum.KeyCode[default] or default
                local banned = {
                    Return = true, Space = true, Tab = true,
                    Backquote = true, CapsLock = true, Escape = true,
                    Unknown = true
                }

                local shortNames = {
                    RightControl = "Right Ctrl", LeftControl = "Left Ctrl",
                    LeftShift = "Left Shift", RightShift = "Right Shift",
                    Semicolon = ";", Quote = '"', LeftBracket = "[",
                    RightBracket = "]", Equals = "=", Minus = "-",
                    RightAlt = "Right Alt", LeftAlt = "Left Alt"
                }

                local bindKey = defaultKey
                local keyTxt = defaultKey and (shortNames[defaultKey.Name] or defaultKey.Name) or "None"

                local KeybindModule = Instance.new("Frame")
                KeybindModule.Name = "keybind_" .. text
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.Size = UDim2.new(0, elementWidth, 0, 36)

                local KeybindBtn = Instance.new("TextButton")
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.2
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = isMobile and 12 or 14
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left

                local KeybindBtnC = Instance.new("UICorner")
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Parent = KeybindBtn

                local KeybindValue = Instance.new("TextButton")
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.72, 0, 0.22, 0)
                KeybindValue.Size = UDim2.new(0, 70, 0, 22)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 12

                local KeybindValueC = Instance.new("UICorner")
                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Parent = KeybindValue

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)

                KeybindValue.MouseButton1Click:Connect(function()
                    KeybindValue.Text = "..."
                    task.wait()

                    local key = UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)

                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        KeybindValue.Text = keyTxt
                        return
                    end

                    if banned[keyName] then
                        KeybindValue.Text = keyTxt
                        return
                    end

                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    KeybindValue.Text = shortNames[keyName] or keyName
                    create3DFlipAnimation(KeybindValue, 0.3)
                end)

                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
                end)
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
            end

            -- ---- Textbox ----
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")

                FengUI.flags[flag] = default

                local TextboxModule = Instance.new("Frame")
                TextboxModule.Name = "textbox_" .. flag
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.Size = UDim2.new(0, elementWidth, 0, 36)

                local TextboxBtn = Instance.new("TextButton")
                TextboxBtn.Name = "TextboxBtn"
                TextboxBtn.Parent = TextboxModule
                TextboxBtn.BackgroundColor3 = config.Textbox_Color
                TextboxBtn.BackgroundTransparency = 0.2
                TextboxBtn.BorderSizePixel = 0
                TextboxBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                TextboxBtn.AutoButtonColor = false
                TextboxBtn.Font = Enum.Font.GothamSemibold
                TextboxBtn.Text = "   " .. text
                TextboxBtn.TextColor3 = config.TextColor
                TextboxBtn.TextSize = isMobile and 12 or 14
                TextboxBtn.TextXAlignment = Enum.TextXAlignment.Left

                local TextboxBtnC = Instance.new("UICorner")
                TextboxBtnC.CornerRadius = UDim.new(0, 6)
                TextboxBtnC.Parent = TextboxBtn

                local BoxBG = Instance.new("Frame")
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBtn
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.55, 0, 0.22, 0)
                BoxBG.Size = UDim2.new(0, 100, 0, 22)

                local BoxBGC = Instance.new("UICorner")
                BoxBGC.CornerRadius = UDim.new(0, 6)
                BoxBGC.Parent = BoxBG

                local TextBox = Instance.new("TextBox")
                TextBox.Parent = BoxBG
                TextBox.BackgroundTransparency = 1
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2.new(1, -10, 1, 0)
                TextBox.Position = UDim2.new(0, 5, 0, 0)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = config.TextColor
                TextBox.TextSize = 12
                TextBox.PlaceholderColor3 = config.SecondaryTextColor

                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    FengUI.flags[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)

                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
                end)
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
            end

            -- ---- Slider ----
            function section.Slider(section, text, flag, default, min, max, precise, callback)
                callback = callback or function() end
                min = min or 0
                max = max or 10
                default = default or min
                precise = precise or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = default

                local SliderModule = Instance.new("Frame")
                SliderModule.Name = "slider_" .. flag
                SliderModule.Parent = Objs
                SliderModule.BackgroundTransparency = 1
                SliderModule.Size = UDim2.new(0, elementWidth, 0, 36)

                local SliderBtn = Instance.new("TextButton")
                SliderBtn.Name = "SliderBtn"
                SliderBtn.Parent = SliderModule
                SliderBtn.BackgroundColor3 = config.Slider_Color
                SliderBtn.BackgroundTransparency = 0.2
                SliderBtn.BorderSizePixel = 0
                SliderBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                SliderBtn.AutoButtonColor = false
                SliderBtn.Font = Enum.Font.GothamSemibold
                SliderBtn.Text = "   " .. text
                SliderBtn.TextColor3 = config.TextColor
                SliderBtn.TextSize = isMobile and 12 or 14
                SliderBtn.TextXAlignment = Enum.TextXAlignment.Left

                local SliderBtnC = Instance.new("UICorner")
                SliderBtnC.CornerRadius = UDim.new(0, 6)
                SliderBtnC.Parent = SliderBtn

                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBtn
                SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.45, 0, 0.3, 0)
                SliderBar.Size = UDim2.new(0, 120, 0, 14)

                local SliderBarC = Instance.new("UICorner")
                SliderBarC.CornerRadius = UDim.new(0, 4)
                SliderBarC.Parent = SliderBar

                local SliderPart = Instance.new("Frame")
                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = config.SliderBar_Color
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)

                local SliderPartC = Instance.new("UICorner")
                SliderPartC.CornerRadius = UDim.new(0, 4)
                SliderPartC.Parent = SliderPart

                local SliderValBG = Instance.new("Frame")
                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBtn
                SliderValBG.BackgroundColor3 = config.Bg_Color
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.8, 0, 0.22, 0)
                SliderValBG.Size = UDim2.new(0, 40, 0, 22)

                local SliderValBGC = Instance.new("UICorner")
                SliderValBGC.CornerRadius = UDim.new(0, 6)
                SliderValBGC.Parent = SliderValBG

                local SliderValue = Instance.new("TextBox")
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundTransparency = 1
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.TextColor
                SliderValue.TextSize = 11
                SliderValue.TextXAlignment = Enum.TextXAlignment.Center

                local funcs = {
                    SetValue = function(self, value)
                        local percent
                        if value then
                            percent = (value - min) / (max - min)
                        else
                            local mouse = services.Players.LocalPlayer:GetMouse()
                            local barPos = SliderBar.AbsolutePosition.X
                            local barSize = SliderBar.AbsoluteSize.X
                            local mouseX = math.clamp(mouse.X, barPos, barPos + barSize)
                            percent = (mouseX - barPos) / barSize
                            value = min + (max - min) * percent
                        end

                        if precise then
                            value = tonumber(string.format("%.2f", value))
                        else
                            value = math.floor(value + 0.5)
                        end
                        value = math.clamp(value, min, max)
                        percent = (value - min) / (max - min)
                        FengUI.flags[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)

                        services.TweenService:Create(SliderPart, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        callback(tonumber(value))
                    end,
                    GetValue = function(self)
                        return FengUI.flags[flag]
                    end
                }

                funcs:SetValue(default)

                local dragging = false
                local function startDrag(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        funcs:SetValue()
                    end
                end

                SliderBar.InputBegan:Connect(startDrag)
                SliderPart.InputBegan:Connect(startDrag)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        funcs:SetValue()
                    end
                end)

                return funcs
            end

            -- ---- Dropdown (简化版，模仿UI.lua风格) ----
            function section.Dropdown(section, text, flag, options, callback)
                callback = callback or function() end
                options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = nil

                local DropdownModule = Instance.new("Frame")
                DropdownModule.Name = "dropdown_" .. flag
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36)

                local DropdownBtn = Instance.new("TextButton")
                DropdownBtn.Name = "DropdownBtn"
                DropdownBtn.Parent = DropdownModule
                DropdownBtn.BackgroundColor3 = config.Dropdown_Color
                DropdownBtn.BackgroundTransparency = 0.2
                DropdownBtn.BorderSizePixel = 0
                DropdownBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                DropdownBtn.AutoButtonColor = false
                DropdownBtn.Font = Enum.Font.GothamSemibold
                DropdownBtn.Text = "   " .. text
                DropdownBtn.TextColor3 = config.TextColor
                DropdownBtn.TextSize = isMobile and 12 or 14
                DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left

                local DropdownBtnC = Instance.new("UICorner")
                DropdownBtnC.CornerRadius = UDim.new(0, 6)
                DropdownBtnC.Parent = DropdownBtn

                local DropdownValue = Instance.new("TextButton")
                DropdownValue.Name = "DropdownValue"
                DropdownValue.Parent = DropdownBtn
                DropdownValue.BackgroundColor3 = config.Bg_Color
                DropdownValue.BorderSizePixel = 0
                DropdownValue.Position = UDim2.new(0.72, 0, 0.22, 0)
                DropdownValue.Size = UDim2.new(0, 70, 0, 22)
                DropdownValue.AutoButtonColor = false
                DropdownValue.Font = Enum.Font.Gotham
                DropdownValue.Text = "选择"
                DropdownValue.TextColor3 = config.TextColor
                DropdownValue.TextSize = 12

                local DropdownValueC = Instance.new("UICorner")
                DropdownValueC.CornerRadius = UDim.new(0, 6)
                DropdownValueC.Parent = DropdownValue

                -- 下拉选项容器（在模块下方弹出）
                local OptionsFrame = Instance.new("Frame")
                OptionsFrame.Name = "OptionsFrame"
                OptionsFrame.Parent = DropdownModule
                OptionsFrame.BackgroundColor3 = config.TabColor
                OptionsFrame.BackgroundTransparency = 0.1
                OptionsFrame.BorderSizePixel = 0
                OptionsFrame.Position = UDim2.new(0, 0, 1, 5)
                OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                OptionsFrame.Visible = false
                OptionsFrame.ZIndex = 10
                OptionsFrame.ClipsDescendants = true

                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 6)
                OptionsCorner.Parent = OptionsFrame

                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.Parent = OptionsFrame
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Padding = UDim.new(0, 2)

                local function closeDropdown()
                    OptionsFrame.Visible = false
                end

                local function openDropdown()
                    OptionsFrame.Visible = true
                    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                    local contentHeight = OptionsLayout.AbsoluteContentSize.Y
                    OptionsFrame.Size = UDim2.new(1, 0, 0, contentHeight + 10)
                end

                DropdownValue.MouseButton1Click:Connect(function()
                    if OptionsFrame.Visible then
                        closeDropdown()
                    else
                        openDropdown()
                    end
                end)

                local allOptions = {}
                local funcs = {}

                funcs.AddOption = function(self, optionText)
                    local Option = Instance.new("TextButton")
                    Option.Name = "Option_" .. optionText
                    Option.Parent = OptionsFrame
                    Option.BackgroundColor3 = config.TabColor
                    Option.BackgroundTransparency = 0.2
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(1, 0, 0, 24)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = optionText
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 13
                    Option.ZIndex = 11

                    local OptionC = Instance.new("UICorner")
                    OptionC.CornerRadius = UDim.new(0, 4)
                    OptionC.Parent = Option

                    Option.MouseButton1Click:Connect(function()
                        DropdownValue.Text = optionText
                        FengUI.flags[flag] = optionText
                        callback(optionText)
                        closeDropdown()
                    end)

                    table.insert(allOptions, Option)
                    return Option
                end

                funcs.SetOptions = function(self, newOptions)
                    for _, opt in pairs(allOptions) do
                        opt:Destroy()
                    end
                    allOptions = {}
                    for _, optText in pairs(newOptions) do
                        funcs:AddOption(optText)
                    end
                end

                funcs:SetOptions(options)
                return funcs
            end

            -- 可继续添加ColorPicker等（根据需要）

            return section
        end

        -- 绑定点击切换标签
        TabBtn.MouseButton1Click:Connect(function()
            switchTab({ sidebarBtn, workareamain })
        end)

        -- 默认选择第一个标签
        if #sections == 0 then  -- 使用外部sections计数，这里简单处理
            sidebarBtn.BackgroundTransparency = 0
            sidebarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            workareamain.Visible = true
            FengUI.currentTab = { sidebarBtn, workareamain }
        end
        table.insert(sections, sidebarBtn)  -- 注意：需要在外部定义sections，这里为简化，直接使用局部变量，实际可放在window对象里
        -- 此处为了兼容，我们在window中添加一个sections表
        window.sections = window.sections or {}
        table.insert(window.sections, sidebarBtn)

        return tab
    end

    function window:DualTab(name, icon)
        return window:Tab(name, icon, 2)
    end

    return window
end

-- 全局变量（用于外部访问）
getgenv().FengUI = FengUI

return FengUI