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
-- 设备检测和UI尺寸设置（完全保留原样）
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
-- 原版浅色配色（完全不变）
-- =========================================
local config = {
    MainColor = Color3.fromRGB(255, 255, 255),
    TabColor = Color3.fromRGB(240, 240, 245),
    Bg_Color = Color3.fromRGB(250, 250, 255),
    Zy_Color = Color3.fromRGB(250, 250, 255),
    Button_Color = Color3.fromRGB(240, 240, 245),
    Textbox_Color = Color3.fromRGB(240, 240, 245),
    Dropdown_Color = Color3.fromRGB(240, 240, 245),
    Keybind_Color = Color3.fromRGB(240, 240, 245),
    Label_Color = Color3.fromRGB(240, 240, 245),
    Slider_Color = Color3.fromRGB(240, 240, 245),
    SliderBar_Color = Color3.fromRGB(21, 103, 251),
    Toggle_Color = Color3.fromRGB(240, 240, 245),
    Toggle_Off = Color3.fromRGB(216, 216, 216),
    Toggle_On = Color3.fromRGB(21, 103, 251),
    AccentColor = Color3.fromRGB(21, 103, 251),
    TextColor = Color3.fromRGB(0, 0, 0),
    SecondaryTextColor = Color3.fromRGB(95, 95, 95),
    GlowColor = Color3.fromRGB(21, 103, 251),

    DeepSpaceColor = Color3.fromRGB(255, 255, 255),
    NebulaColor1 = Color3.fromRGB(245, 245, 245),
    NebulaColor2 = Color3.fromRGB(235, 235, 235),
    AccentGlow = Color3.fromRGB(21, 103, 251),
    ElementColor = Color3.fromRGB(240, 240, 245),
    ElementTransparency = 0.1,
    GlassEffect = Color3.fromRGB(255, 255, 255),
}

-- 默认图标资源（FontAwesome 箭头）
local DEFAULT_ICON_EXPAND = "rbxassetid://6031090998"   -- 向下箭头（展开时）
local DEFAULT_ICON_COLLAPSE = "rbxassetid://6031061049" -- 向右箭头（收缩时）

-- 辅助函数：确保图片ID为有效URL
local function formatImageId(id)
    if type(id) == "number" then
        return "rbxassetid://" .. tostring(id)
    elseif type(id) == "string" then
        if id:match("^rbxassetid://") or id:match("^https?://") then
            return id
        elseif id:match("^%d+$") then
            return "rbxassetid://" .. id
        else
            return id
        end
    else
        return nil
    end
end

-- =========================================
-- 从 UI.lua 移植的特效函数
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

    services.TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = 15
    }):Play()

    task.wait(duration/2)

    services.TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Rotation = 0
    }):Play()
end

local sections = {}
local workareas = {}
local visible = true
local dbcooper = false

local function tp(ins, pos, time, thing)
    services.TweenService:Create(ins, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Position = pos }):Play()
end

-- 清理旧GUI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建主ScreenGui
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- 打开按钮（原样）
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 36, 0, 36)
Open.Active = true
Open.Draggable = true
Open.Image = ""
Open.ImageTransparency = 1

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = Open

local OpenText = Instance.new("TextLabel")
OpenText.Name = "OpenText"
OpenText.Parent = Open
OpenText.BackgroundTransparency = 1
OpenText.Size = UDim2.new(1, 0, 1, 0)
OpenText.Font = Enum.Font.GothamBold
OpenText.Text = "☰"
OpenText.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenText.TextSize = 18

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

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 18)
uc.Parent = main

-- 拖拽功能（原样）
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

-- 工作区（右侧）
local workarea = Instance.new("Frame")
workarea.Name = "workarea"
workarea.Parent = main
workarea.BackgroundColor3 = config.MainColor
workarea.Position = UDim2.new(0.36403501, 0, 0, 0)
workarea.Size = UDim2.new(0, WORKAREA_WIDTH, 0, WORKAREA_HEIGHT)

local uc_2 = Instance.new("UICorner")
uc_2.CornerRadius = UDim.new(0, 18)
uc_2.Parent = workarea

local workareacornerhider = Instance.new("Frame")
workareacornerhider.Name = "workareacornerhider"
workareacornerhider.Parent = workarea
workareacornerhider.BackgroundColor3 = config.MainColor
workareacornerhider.BorderSizePixel = 0
workareacornerhider.Size = UDim2.new(0, 18, 0.99895674, 0)

-- 搜索框（原样）
local search = Instance.new("Frame")
search.Name = "search"
search.Parent = workarea
search.BackgroundColor3 = config.Textbox_Color
search.BackgroundTransparency = 0.2
search.Position = UDim2.new(isMobile and 0.1 or 0.7, 0, 0.01, 0)
search.Size = UDim2.new(0, isMobile and 120 or 120, 0, 28)

local uc_8 = Instance.new("UICorner")
uc_8.CornerRadius = UDim.new(0, 9)
uc_8.Parent = search

local searchicon = Instance.new("ImageButton")
searchicon.Name = "searchicon"
searchicon.Parent = search
searchicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchicon.BackgroundTransparency = 1
searchicon.BorderColor3 = Color3.fromRGB(27, 42, 53)
searchicon.Position = UDim2.new(0.05, 0, 0.1, 0)
searchicon.Size = UDim2.new(0, 20, 0, 20)
searchicon.Image = "rbxassetid://2804603863"
searchicon.ImageColor3 = config.SecondaryTextColor
searchicon.ScaleType = Enum.ScaleType.Fit

local searchtextbox = Instance.new("TextBox")
searchtextbox.Name = "searchtextbox"
searchtextbox.Parent = search
searchtextbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

-- 搜索过滤功能
local searchConnection
local function filterButtons()
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
end

searchtextbox:GetPropertyChangedSignal("Text"):Connect(filterButtons)
searchtextbox.Focused:Connect(function()
    if searchConnection then searchConnection:Disconnect() end
    searchConnection = RunService.RenderStepped:Connect(filterButtons)
end)
searchtextbox.FocusLost:Connect(function()
    if searchConnection then
        searchConnection:Disconnect()
        searchConnection = nil
    end
    for _, button in pairs(sidebar:GetChildren()) do
        if button:IsA("TextButton") then
            button.Visible = true
        end
    end
end)

-- 侧边栏标题（原样）
local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Name = "SidebarTitle"
SidebarTitle.Parent = main
SidebarTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.BorderSizePixel = 0
SidebarTitle.Position = UDim2.new(0.025, 0, 0.02, 0)
SidebarTitle.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, isMobile and 30 or 50)
SidebarTitle.Font = Enum.Font.GothamBold
SidebarTitle.Text = "FengUI"
SidebarTitle.TextColor3 = config.AccentColor
SidebarTitle.TextSize = isMobile and 18 or 24
SidebarTitle.TextWrapped = true
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
sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

-- 辅助函数：平滑滚动（原样）
local function setupSmoothScrolling(scrollingFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        scrollingFrame.ScrollingEnabled = layout.AbsoluteContentSize.Y > scrollingFrame.AbsoluteSize.Y
    end)
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

-- 动画效果
Open.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
        if FengUI.currentTab and FengUI.currentTab[2] then
            FengUI.currentTab[2].Visible = true
        end
    else
        tp(main, UDim2.new(0.5, 0, 2, 0), 0.5)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        main.Visible = not main.Visible
        if main.Visible then
            tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
            if FengUI.currentTab and FengUI.currentTab[2] then
                FengUI.currentTab[2].Visible = true
            end
        else
            tp(main, UDim2.new(0.5, 0, 2, 0), 0.5)
        end
    end
end)

-- 初始化动画
tp(main, UDim2.new(0.5, 0, 0.5, 0), 1)

-- =========================================
-- 标签切换函数（原样）
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
-- 重写 FengUI.new，采用 UI.lua 的 section 系统
-- =========================================
function FengUI.new(name, theme)
    -- 设置脚本名字
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

    -- ---------- 标签方法（与原测试UI相同）----------
    function window:AddTag(text, bgColor, textColor, useNeonEffect)
        if self.tagCount >= self.maxTags then
            return nil
        end

        bgColor = bgColor or Color3.fromRGB(21, 103, 251)
        textColor = textColor or Color3.fromRGB(255, 255, 255)
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
            UseNeonEffect = false,
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
                    local hue = 0
                    selfObj.RainbowBackgroundConnection = RunService.Heartbeat:Connect(function()
                        if not Tag or not Tag.Parent then
                            selfObj.RainbowBackgroundConnection:Disconnect()
                            return
                        end
                        hue = (hue + 0.01) % 1
                        Tag.BackgroundColor3 = Color3.fromHSV(hue, 0.9, 0.9)
                        TagStroke.Color = Color3.fromHSV((hue + 0.2) % 1, 0.9, 0.9)
                    end)
                    selfObj.PulseConnection = RunService.Heartbeat:Connect(function()
                        if not Tag or not Tag.Parent then
                            selfObj.PulseConnection:Disconnect()
                            return
                        end
                        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
                        TagStroke.Transparency = alpha
                    end)
                else
                    Tag.BackgroundColor3 = selfObj.Color
                    Tag.TextColor3 = selfObj.TextColor
                    TagStroke.Color = selfObj.Color
                    TagStroke.Transparency = 0.5
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

    -- ---------- Tab 创建（使用 UI.lua 的 section 系统）----------
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1

        -- 侧边栏按钮（原样式）
        local sidebar2 = Instance.new("TextButton")
        sidebar2.Name = "sidebar2_" .. name
        sidebar2.Parent = sidebar
        sidebar2.BackgroundColor3 = config.AccentColor
        sidebar2.BackgroundTransparency = 1
        sidebar2.Size = UDim2.new(0, SIDEBAR_WIDTH - 7, 0, isMobile and 28 or 37)
        sidebar2.ZIndex = 10
        sidebar2.AutoButtonColor = false
        sidebar2.Font = Enum.Font.Gotham
        sidebar2.Text = name
        sidebar2.TextColor3 = config.TextColor
        sidebar2.TextSize = isMobile and 16 or 21

        local buttonBackground = Instance.new("Frame")
        buttonBackground.Name = "buttonBackground"
        buttonBackground.Parent = sidebar2
        buttonBackground.BackgroundColor3 = config.AccentColor
        buttonBackground.BackgroundTransparency = 1
        buttonBackground.Size = UDim2.new(1, 0, 1, 0)
        buttonBackground.ZIndex = 9

        local uc_10 = Instance.new("UICorner")
        uc_10.CornerRadius = UDim.new(0, 9)
        uc_10.Parent = sidebar2
        table.insert(sections, sidebar2)

        -- 右侧工作区（滚动区域）
        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain_" .. name
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        workareamain.Position = UDim2.new(0.0393013097, 0, isMobile and 0.15 or 0.12, 0)
        workareamain.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 220 or 512)
        workareamain.ZIndex = 3
        workareamain.CanvasSize = UDim2.new(0, 0, 0, 0)
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = false
        workareamain.ScrollingEnabled = true

        -- 创建 TabContainer（用于放置 sections）
        local TabContainer = Instance.new("Frame")
        TabContainer.Name = "TabContainer"
        TabContainer.Parent = workareamain
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 0, 0) -- 初始高度为0，由内容撑开
        TabContainer.AutomaticSize = Enum.AutomaticSize.Y

        local TabL = Instance.new("UIListLayout")
        TabL.Parent = TabContainer
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)

        -- 如果 windowCount == 2，创建左右容器
        if windowCount == 2 then
            TabL:Destroy() -- 不使用列表布局
            TabContainer.Size = UDim2.new(1, 0, 1, 0) -- 填满 workareamain
            TabContainer.AutomaticSize = Enum.AutomaticSize.None

            local LeftContainer = Instance.new("ScrollingFrame")
            LeftContainer.Name = "LeftContainer"
            LeftContainer.Parent = TabContainer
            LeftContainer.BackgroundTransparency = 1
            LeftContainer.Size = UDim2.new(0.48, -2, 1, 0)
            LeftContainer.Position = UDim2.new(0, 2, 0, 0)
            LeftContainer.ScrollBarThickness = 0
            LeftContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            LeftContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            LeftContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None

            local LeftLayout = Instance.new("UIListLayout")
            LeftLayout.Parent = LeftContainer
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 4)

            local RightContainer = Instance.new("ScrollingFrame")
            RightContainer.Name = "RightContainer"
            RightContainer.Parent = TabContainer
            RightContainer.BackgroundTransparency = 1
            RightContainer.Size = UDim2.new(0.50, -2, 1, 0)
            RightContainer.Position = UDim2.new(0.48, 0, 0, 0)
            RightContainer.ScrollBarThickness = 0
            RightContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            RightContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            RightContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None

            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Parent = RightContainer
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 4)

            -- 滚动更新
            local function updateLeftScrolling()
                LeftContainer.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
                LeftContainer.ScrollingEnabled = LeftLayout.AbsoluteContentSize.Y > LeftContainer.AbsoluteSize.Y
            end
            local function updateRightScrolling()
                RightContainer.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
                RightContainer.ScrollingEnabled = RightLayout.AbsoluteContentSize.Y > RightContainer.AbsoluteSize.Y
            end
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftScrolling)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightScrolling)
            task.spawn(function()
                task.wait(0.1)
                updateLeftScrolling()
                updateRightScrolling()
            end)
        else
            -- 单列布局，使用 TabContainer 作为内容容器，并设置平滑滚动
            setupSmoothScrolling(workareamain, TabL)
        end

        table.insert(workareas, workareamain)

        local tab = {}

        -- ============= 从 UI.lua 移植的 section 实现 =============
        function tab.section(tab, name, windowPosition, TabVal)
            if type(windowPosition) == "boolean" then
                TabVal = windowPosition
                windowPosition = "Left"
            elseif not windowPosition or type(windowPosition) ~= "string" then
                windowPosition = "Left"
            end

            local TargetContainer
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    TargetContainer = TabContainer:FindFirstChild("LeftContainer")
                else
                    TargetContainer = TabContainer:FindFirstChild("RightContainer")
                end
            else
                TargetContainer = TabContainer
            end

            if not TargetContainer then
                TargetContainer = TabContainer
            end

            -- 计算元素宽度
            local elementWidth = WORKAREA_WIDTH - 56
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    elementWidth = (WORKAREA_WIDTH - 66) * 0.48
                else
                    elementWidth = (WORKAREA_WIDTH - 66) * 0.5
                end
            end

            local Section = Instance.new("Frame")
            local SectionText = Instance.new("TextLabel")
            local SectionOpen = Instance.new("ImageLabel")
            local SectionOpened = Instance.new("ImageLabel")
            local SectionToggle = Instance.new("ImageButton")
            local Objs = Instance.new("Frame")
            local ObjsL = Instance.new("UIListLayout")

            Section.Name = "Section"
            Section.Parent = TargetContainer
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true

            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0, 35, 0, 0)
            SectionText.Size = UDim2.new(1, -35, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.AccentColor
            SectionText.TextSize = isMobile and 16 or 18
            SectionText.TextXAlignment = Enum.TextXAlignment.Left

            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = Section
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, 5, 0, 5)
            SectionOpen.Size = UDim2.new(0, 22, 0, 22)
            SectionOpen.Image = "rbxassetid://6031090998" -- 向下箭头
            SectionOpen.ImageColor3 = config.SecondaryTextColor

            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(1, 0, 1, 0)
            SectionOpened.Image = "rbxassetid://6031061049" -- 向右箭头
            SectionOpened.ImageColor3 = config.AccentColor
            SectionOpened.ImageTransparency = 1

            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)

            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 0, 0, 36)
            Objs.Size = UDim2.new(1, 0, 0, 0)

            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)

            local open = true
            if TabVal ~= nil then
                if type(TabVal) == "boolean" then
                    open = TabVal
                elseif TabVal == "false" or TabVal == "0" then
                    open = false
                elseif TabVal == "true" or TabVal == "1" then
                    open = true
                end
            end

            local function updateSectionHeight()
                Section.Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
            end

            updateSectionHeight()
            SectionOpened.ImageTransparency = open and 0 or 1
            SectionOpen.ImageTransparency = open and 1 or 0

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
                }):Play()

                services.TweenService:Create(SectionOpened, TweenInfo.new(0.3), {
                    ImageTransparency = open and 0 or 1
                }):Play()

                services.TweenService:Create(SectionOpen, TweenInfo.new(0.3), {
                    ImageTransparency = open and 1 or 0
                }):Play()
            end)

            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
            end)

            local section = {}

            function section.Button(section, text, callback)
                callback = callback or function() end

                local BtnModule = Instance.new("Frame")
                local Btn = Instance.new("TextButton")
                local BtnC = Instance.new("UICorner")

                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.BorderSizePixel = 0
                BtnModule.Size = UDim2.new(0, elementWidth, 0, 36)

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
                Btn.TextSize = isMobile and 14 or 16
                Btn.TextXAlignment = Enum.TextXAlignment.Left

                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
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

                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 0.8),
                            math.floor(config.Button_Color.G * 255 * 0.8),
                            math.floor(config.Button_Color.B * 255 * 0.8)
                        )
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.1), {
                        Thickness = 3,
                        Transparency = 0.3
                    }):Play()

                    task.wait(0.1)

                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)
            end

            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")

                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, elementWidth, 0, sizeY or 120)

                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or elementWidth - 20, elementWidth), 0, sizeY or 120)
                ImageLabel.ScaleType = Enum.ScaleType.Crop

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
                                        local MarketplaceService = game:GetService("MarketplaceService")
                                        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
                                    end)

                                    if success1 and gameInfo and gameInfo.IconImageAssetId then
                                        ImageLabel.Image = "rbxassetid://" .. gameInfo.IconImageAssetId
                                        return
                                    end

                                    local success2, thumbnailUrl = pcall(function()
                                        local ThumbnailService = game:GetService("ThumbnailService")
                                        return ThumbnailService:GetGameThumbnailAsync(placeId)
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

                function imageController:SetPlayerAvatar(userId)
                    setImage({Type = "Player", UserId = userId})
                end

                function imageController:SetGameIcon(placeId)
                    setImage({Type = "Game", PlaceId = placeId})
                end

                function imageController:SetLocalPlayerAvatar()
                    local localPlayer = game.Players.LocalPlayer
                    if localPlayer then
                        setImage({Type = "Player", UserId = localPlayer.UserId})
                    end
                end

                function imageController:Destroy()
                    ImageModule:Destroy()
                end

                imageController.Instance = ImageLabel
                imageController.Module = ImageModule

                return imageController
            end

            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                local TextLabel = Instance.new("TextLabel")
                local LabelC = Instance.new("UICorner")

                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, elementWidth, 0, 24)

                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.2
                TextLabel.Size = UDim2.new(0, elementWidth, 0, 28)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = isMobile and 14 or 16

                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel

                return TextLabel
            end

            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                local ToggleBtn = Instance.new("TextButton")
                local ToggleBtnC = Instance.new("UICorner")
                local ToggleDisable = Instance.new("Frame")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchC = Instance.new("UICorner")
                local ToggleDisableC = Instance.new("UICorner")

                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(0, elementWidth, 0, 36)

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
                ToggleBtn.TextSize = isMobile and 14 or 16
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn

                local togglePosition = 0.85
                if windowCount == 2 then
                    togglePosition = 0.78
                end

                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
                ToggleDisable.BackgroundTransparency = 0.8
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(togglePosition, 0, 0.22, 0)
                ToggleDisable.Size = UDim2.new(0, 34, 0, 18)

                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 20, 0, 18)
                ToggleSwitch.Position = UDim2.new(0, enabled and 14 or 0, 0, 0)

                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch

                ToggleDisableC.CornerRadius = UDim.new(0, 9)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable

                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1,
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Toggle_Color.R * 255 * 1.1),
                            math.floor(config.Toggle_Color.G * 255 * 1.1),
                            math.floor(config.Toggle_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)

                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.2,
                        BackgroundColor3 = config.Toggle_Color
                    }):Play()
                end)

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

            function section.Keybind(section, text, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(default, "No default key provided")

                local default = typeof(default) == "string" and Enum.KeyCode[default] or default
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

                local bindKey = default
                local keyTxt = default and (shortNames[default.Name] or default.Name) or "None"

                local KeybindModule = Instance.new("Frame")
                local KeybindBtn = Instance.new("TextButton")
                local KeybindBtnC = Instance.new("UICorner")
                local KeybindValue = Instance.new("TextButton")
                local KeybindValueC = Instance.new("UICorner")
                local KeybindL = Instance.new("UIListLayout")
                local UIPadding = Instance.new("UIPadding")

                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(0, elementWidth, 0, 36)

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
                KeybindBtn.TextSize = isMobile and 14 or 16
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left

                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn

                local keybindPosition = 0.72
                if windowCount == 2 then
                    keybindPosition = 0.64
                end

                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(keybindPosition, 0, 0.22, 0)
                KeybindValue.Size = UDim2.new(0, 70, 0, 22)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = isMobile and 12 or 14

                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue

                KeybindL.Name = "KeybindL"
                KeybindL.Parent = KeybindBtn
                KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
                KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center

                UIPadding.Parent = KeybindBtn
                UIPadding.PaddingRight = UDim.new(0, 6)

                KeybindBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Keybind_Color.R * 255 * 1.1),
                            math.floor(config.Keybind_Color.G * 255 * 1.1),
                            math.floor(config.Keybind_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)

                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Keybind_Color
                    }):Play()
                end)

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

            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")

                FengUI.flags[flag] = default

                local TextboxModule = Instance.new("Frame")
                local TextboxBack = Instance.new("TextButton")
                local TextboxBackC = Instance.new("UICorner")
                local BoxBG = Instance.new("TextButton")
                local BoxBGC = Instance.new("UICorner")
                local TextBox = Instance.new("TextBox")
                local TextboxBackL = Instance.new("UIListLayout")
                local TextboxBackP = Instance.new("UIPadding")

                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, elementWidth, 0, 36)

                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.2
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, elementWidth, 0, 36)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = isMobile and 14 or 16
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left

                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack

                local textboxPosition = 0.45
                if windowCount == 2 then
                    textboxPosition = 0.36
                end

                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(textboxPosition, 0, 0.22, 0)
                BoxBG.Size = UDim2.new(0, 80, 0, 22)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.Gotham
                BoxBG.Text = ""

                BoxBGC.CornerRadius = UDim.new(0, 6)
                BoxBGC.Name = "BoxBGC"
                BoxBGC.Parent = BoxBG

                TextBox.Parent = BoxBG
                TextBox.BackgroundTransparency = 1
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = config.TextColor
                TextBox.TextSize = isMobile and 12 or 14
                TextBox.PlaceholderColor3 = config.SecondaryTextColor

                TextboxBackL.Name = "TextboxBackL"
                TextboxBackL.Parent = TextboxBack
                TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
                TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center

                TextboxBackP.Name = "TextboxBackP"
                TextboxBackP.Parent = TextboxBack
                TextboxBackP.PaddingRight = UDim.new(0, 12)

                TextboxBack.MouseEnter:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Textbox_Color.R * 255 * 1.1),
                            math.floor(config.Textbox_Color.G * 255 * 1.1),
                            math.floor(config.Textbox_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)

                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Textbox_Color
                    }):Play()
                end)

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

            function section.ColorPicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                assert(text, "No text provided")
                assert(flag, "No flag provided")

                FengUI.flags[flag] = defaultColor

                local ColorPickerModule = Instance.new("Frame")
                local ColorPickerBtn = Instance.new("TextButton")
                local ColorPickerBtnC = Instance.new("UICorner")
                local ColorPreview = Instance.new("Frame")
                local ColorPreviewC = Instance.new("UICorner")
                local ColorPickerL = Instance.new("UIListLayout")
                local ColorPickerP = Instance.new("UIPadding")

                ColorPickerModule.Name = "ColorPickerModule"
                ColorPickerModule.Parent = Objs
                ColorPickerModule.BackgroundTransparency = 1
                ColorPickerModule.BorderSizePixel = 0
                ColorPickerModule.Size = UDim2.new(0, elementWidth, 0, 36)

                ColorPickerBtn.Name = "ColorPickerBtn"
                ColorPickerBtn.Parent = ColorPickerModule
                ColorPickerBtn.BackgroundColor3 = config.Button_Color
                ColorPickerBtn.BackgroundTransparency = 0.2
                ColorPickerBtn.BorderSizePixel = 0
                ColorPickerBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                ColorPickerBtn.AutoButtonColor = false
                ColorPickerBtn.Font = Enum.Font.GothamSemibold
                ColorPickerBtn.Text = "   " .. text
                ColorPickerBtn.TextColor3 = config.TextColor
                ColorPickerBtn.TextSize = isMobile and 14 or 16
                ColorPickerBtn.TextXAlignment = Enum.TextXAlignment.Left

                ColorPickerBtnC.CornerRadius = UDim.new(0, 6)
                ColorPickerBtnC.Name = "ColorPickerBtnC"
                ColorPickerBtnC.Parent = ColorPickerBtn

                local colorPickerPosition = 0.65
                if windowCount == 2 then
                    colorPickerPosition = 0.56
                end

                ColorPreview.Name = "ColorPreview"
                ColorPreview.Parent = ColorPickerBtn
                ColorPreview.BackgroundColor3 = defaultColor
                ColorPreview.BorderSizePixel = 0
                ColorPreview.Position = UDim2.new(colorPickerPosition, 0, 0.22, 0)
                ColorPreview.Size = UDim2.new(0, 40, 0, 22)

                ColorPreviewC.CornerRadius = UDim.new(0, 6)
                ColorPreviewC.Name = "ColorPreviewC"
                ColorPreviewC.Parent = ColorPreview

                ColorPickerL.Name = "ColorPickerL"
                ColorPickerL.Parent = ColorPickerBtn
                ColorPickerL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                ColorPickerL.SortOrder = Enum.SortOrder.LayoutOrder
                ColorPickerL.VerticalAlignment = Enum.VerticalAlignment.Center

                ColorPickerP.Name = "ColorPickerP"
                ColorPickerP.Parent = ColorPickerBtn
                ColorPickerP.PaddingRight = UDim.new(0, 8)

                -- 颜色选择器弹窗（简化版，仅实现预览，完整功能可自行扩展）
                local ColorPickerPopup = Instance.new("Frame")
                ColorPickerPopup.Name = "ColorPickerPopup"
                ColorPickerPopup.Parent = Main -- 注意这里应该用主窗口，但为了简化，直接放在 FengYu 下
                ColorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
                ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
                ColorPickerPopup.BackgroundTransparency = 0.1
                ColorPickerPopup.BorderSizePixel = 0
                ColorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                ColorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
                ColorPickerPopup.Visible = false
                ColorPickerPopup.ZIndex = 1000
                ColorPickerPopup.Active = true
                ColorPickerPopup.Draggable = true

                local PopupCorner = Instance.new("UICorner")
                PopupCorner.CornerRadius = UDim.new(0, 8)
                PopupCorner.Parent = ColorPickerPopup

                local PopupTitle = Instance.new("TextLabel")
                PopupTitle.Parent = ColorPickerPopup
                PopupTitle.BackgroundTransparency = 1
                PopupTitle.Position = UDim2.new(0, 10, 0, 8)
                PopupTitle.Size = UDim2.new(1, -20, 0, 24)
                PopupTitle.Font = Enum.Font.GothamBold
                PopupTitle.Text = text
                PopupTitle.TextColor3 = config.AccentColor
                PopupTitle.TextSize = 16
                PopupTitle.TextXAlignment = Enum.TextXAlignment.Center
                PopupTitle.ZIndex = 1001

                local SatVibMap = Instance.new("ImageLabel")
                SatVibMap.Name = "SatVibMap"
                SatVibMap.Parent = ColorPickerPopup
                SatVibMap.Size = UDim2.fromOffset(150, 140)
                SatVibMap.Position = UDim2.fromOffset(15, 40)
                SatVibMap.Image = "rbxassetid://4155801252"
                SatVibMap.BackgroundColor3 = defaultColor
                SatVibMap.BackgroundTransparency = 0
                SatVibMap.ZIndex = 1001

                local SatVibCorner = Instance.new("UICorner")
                SatVibCorner.CornerRadius = UDim.new(0, 4)
                SatVibCorner.Parent = SatVibMap

                local SatCursor = Instance.new("ImageLabel")
                SatCursor.Name = "SatCursor"
                SatCursor.Size = UDim2.new(0, 16, 0, 16)
                SatCursor.ScaleType = Enum.ScaleType.Fit
                SatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SatCursor.BackgroundTransparency = 1
                SatCursor.Image = "http://www.roblox.com/asset/?id=4805639000"
                SatCursor.ZIndex = 1002
                SatCursor.Parent = SatVibMap

                local HueSlider = Instance.new("Frame")
                HueSlider.Name = "HueSlider"
                HueSlider.Parent = ColorPickerPopup
                HueSlider.Size = UDim2.fromOffset(14, 140)
                HueSlider.Position = UDim2.fromOffset(175, 40)
                HueSlider.ZIndex = 1001

                local HueSliderCorner = Instance.new("UICorner")
                HueSliderCorner.CornerRadius = UDim.new(1, 0)
                HueSliderCorner.Parent = HueSlider

                local SequenceTable = {}
                for Color = 0, 1, 0.1 do
                    table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
                end

                local HueSliderGradient = Instance.new("UIGradient")
                HueSliderGradient.Color = ColorSequence.new(SequenceTable)
                HueSliderGradient.Rotation = 90
                HueSliderGradient.Parent = HueSlider

                local HueDrag = Instance.new("ImageLabel")
                HueDrag.Name = "HueDrag"
                HueDrag.Size = UDim2.fromOffset(14, 14)
                HueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
                HueDrag.Parent = HueSlider
                HueDrag.Position = UDim2.new(0, 0, 0, -7)
                HueDrag.ZIndex = 1003

                local ConfirmBtn = Instance.new("TextButton")
                ConfirmBtn.Parent = ColorPickerPopup
                ConfirmBtn.BackgroundColor3 = config.AccentColor
                ConfirmBtn.BackgroundTransparency = 0.1
                ConfirmBtn.BorderSizePixel = 0
                ConfirmBtn.Position = UDim2.new(0.5, -60, 1, -30)
                ConfirmBtn.Size = UDim2.new(0, 80, 0, 25)
                ConfirmBtn.Font = Enum.Font.GothamBold
                ConfirmBtn.Text = "确认"
                ConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
                ConfirmBtn.TextSize = 14
                ConfirmBtn.ZIndex = 1002

                local ConfirmCorner = Instance.new("UICorner")
                ConfirmCorner.CornerRadius = UDim.new(0, 6)
                ConfirmCorner.Parent = ConfirmBtn

                local CancelBtn = Instance.new("TextButton")
                CancelBtn.Parent = ColorPickerPopup
                CancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                CancelBtn.BackgroundTransparency = 0.1
                CancelBtn.BorderSizePixel = 0
                CancelBtn.Position = UDim2.new(0.5, 30, 1, -30)
                CancelBtn.Size = UDim2.new(0, 80, 0, 25)
                CancelBtn.Font = Enum.Font.GothamBold
                CancelBtn.Text = "取消"
                CancelBtn.TextColor3 = Color3.new(1, 1, 1)
                CancelBtn.TextSize = 14
                CancelBtn.ZIndex = 1002

                local CancelCorner = Instance.new("UICorner")
                CancelCorner.CornerRadius = UDim.new(0, 6)
                CancelCorner.Parent = CancelBtn

                local currentColor = defaultColor
                local currentHue, currentSat, currentVib = Color3.toHSV(defaultColor)

                local function updateDisplay()
                    SatVibMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                    SatCursor.Position = UDim2.new(currentSat, -8, 1 - currentVib, -8)
                    HueDrag.Position = UDim2.new(0, 0, currentHue, -7)
                    currentColor = Color3.fromHSV(currentHue, currentSat, currentVib)
                end

                local function setupInteraction()
                    local satVibDragging = false
                    local function updateSatVib(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            satVibDragging = true
                            local connection
                            connection = RunService.RenderStepped:Connect(function()
                                if not satVibDragging then return end
                                local mouse = services.Players.LocalPlayer:GetMouse()
                                local minX = SatVibMap.AbsolutePosition.X
                                local maxX = minX + SatVibMap.AbsoluteSize.X
                                local minY = SatVibMap.AbsolutePosition.Y
                                local maxY = minY + SatVibMap.AbsoluteSize.Y
                                local mouseX = math.clamp(mouse.X, minX, maxX)
                                local mouseY = math.clamp(mouse.Y, minY, maxY)
                                currentSat = (mouseX - minX) / (maxX - minX)
                                currentVib = 1 - (mouseY - minY) / (maxY - minY)
                                updateDisplay()
                            end)
                            UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                    satVibDragging = false
                                end
                            end)
                        end
                    end
                    SatVibMap.InputBegan:Connect(updateSatVib)
                    SatCursor.InputBegan:Connect(updateSatVib)

                    local hueDragging = false
                    local function updateHue(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = true
                            local connection
                            connection = RunService.RenderStepped:Connect(function()
                                if not hueDragging then return end
                                local mouse = services.Players.LocalPlayer:GetMouse()
                                local minY = HueSlider.AbsolutePosition.Y
                                local maxY = minY + HueSlider.AbsoluteSize.Y
                                local mouseY = math.clamp(mouse.Y, minY, maxY)
                                currentHue = (mouseY - minY) / (maxY - minY)
                                updateDisplay()
                            end)
                            UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                    hueDragging = false
                                end
                            end)
                        end
                    end
                    HueSlider.InputBegan:Connect(updateHue)
                    HueDrag.InputBegan:Connect(updateHue)
                end

                setupInteraction()
                updateDisplay()

                ColorPickerBtn.MouseButton1Click:Connect(function()
                    ColorPickerPopup.Visible = true
                end)

                ConfirmBtn.MouseButton1Click:Connect(function()
                    FengUI.flags[flag] = currentColor
                    ColorPreview.BackgroundColor3 = currentColor
                    callback(currentColor)
                    ColorPickerPopup.Visible = false
                end)

                CancelBtn.MouseButton1Click:Connect(function()
                    ColorPickerPopup.Visible = false
                end)

                local funcs = {
                    SetColor = function(self, color)
                        if typeof(color) == "Color3" then
                            currentHue, currentSat, currentVib = Color3.toHSV(color)
                            updateDisplay()
                            FengUI.flags[flag] = color
                            ColorPreview.BackgroundColor3 = color
                            callback(color)
                        end
                    end,
                    GetColor = function(self)
                        return FengUI.flags[flag] or defaultColor
                    end,
                    Module = ColorPickerModule
                }

                return funcs
            end

            function section.Slider(section, text, flag, default, min, max, precise, callback)
                callback = callback or function() end
                min = min or 0
                max = max or 10
                default = default or min
                precise = precise or false

                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default value provided")

                FengUI.flags[flag] = default

                local SliderModule = Instance.new("Frame")
                local SliderBack = Instance.new("TextButton")
                local SliderBackC = Instance.new("UICorner")
                local SliderBar = Instance.new("Frame")
                local SliderBarC = Instance.new("UICorner")
                local SliderPart = Instance.new("Frame")
                local SliderPartC = Instance.new("UICorner")
                local SliderValBG = Instance.new("TextButton")
                local SliderValBGC = Instance.new("UICorner")
                local SliderValue = Instance.new("TextBox")

                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderModule.BackgroundTransparency = 1.000
                SliderModule.BorderSizePixel = 0
                SliderModule.Position = UDim2.new(0, 0, 0, 0)

                if windowCount == 2 then
                    SliderModule.Size = UDim2.new(0, elementWidth, 0, 52)
                else
                    SliderModule.Size = UDim2.new(0, elementWidth, 0, 36)
                end

                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.2
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(1, 0, 1, 0)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderBack.TextSize = isMobile and 14 or 16
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left

                if windowCount == 2 then
                    SliderBack.TextYAlignment = Enum.TextYAlignment.Top
                    local padding = Instance.new("UIPadding")
                    padding.Parent = SliderBack
                    padding.PaddingTop = UDim.new(0, 4)
                end

                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack

                if windowCount == 2 then
                    SliderBar.Name = "SliderBar"
                    SliderBar.Parent = SliderBack
                    SliderBar.AnchorPoint = Vector2.new(0, 0)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    SliderBar.BorderSizePixel = 0
                    SliderBar.Position = UDim2.new(0.03, 0, 0.45, 0)
                    SliderBar.Size = UDim2.new(0.65, 0, 0, 14)
                    SliderBarC.CornerRadius = UDim.new(0, 4)
                    SliderBarC.Name = "SliderBarC"
                    SliderBarC.Parent = SliderBar

                    SliderPart.Name = "SliderPart"
                    SliderPart.Parent = SliderBar
                    SliderPart.BackgroundColor3 = config.SliderBar_Color
                    SliderPart.BorderSizePixel = 0
                    SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                    SliderPartC.CornerRadius = UDim.new(0, 4)
                    SliderPartC.Name = "SliderPartC"
                    SliderPartC.Parent = SliderPart

                    SliderValBG.Name = "SliderValBG"
                    SliderValBG.Parent = SliderBack
                    SliderValBG.BackgroundColor3 = config.Bg_Color
                    SliderValBG.BorderSizePixel = 0
                    SliderValBG.Position = UDim2.new(0.72, 0, 0.42, 0)
                    SliderValBG.Size = UDim2.new(0, 36, 0, 22)
                    SliderValBG.AutoButtonColor = false
                    SliderValBG.Font = Enum.Font.Gotham
                    SliderValBG.Text = ""
                    SliderValBG.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderValBG.TextSize = isMobile and 12 or 14

                    SliderValBGC.CornerRadius = UDim.new(0, 6)
                    SliderValBGC.Name = "SliderValBGC"
                    SliderValBGC.Parent = SliderValBG

                    SliderBack.Text = "   " .. text
                else
                    local sliderBarPosition = 0.35
                    local sliderBarWidth = 120
                    local sliderValuePosition = 0.82

                    SliderBar.Name = "SliderBar"
                    SliderBar.Parent = SliderBack
                    SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    SliderBar.BorderSizePixel = 0
                    SliderBar.Position = UDim2.new(sliderBarPosition, 0, 0.5, 0)
                    SliderBar.Size = UDim2.new(0, sliderBarWidth, 0, 14)
                    SliderBarC.CornerRadius = UDim.new(0, 4)
                    SliderBarC.Name = "SliderBarC"
                    SliderBarC.Parent = SliderBar

                    SliderPart.Name = "SliderPart"
                    SliderPart.Parent = SliderBar
                    SliderPart.BackgroundColor3 = config.SliderBar_Color
                    SliderPart.BorderSizePixel = 0
                    SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                    SliderPartC.CornerRadius = UDim.new(0, 4)
                    SliderPartC.Name = "SliderPartC"
                    SliderPartC.Parent = SliderPart

                    SliderValBG.Name = "SliderValBG"
                    SliderValBG.Parent = SliderBack
                    SliderValBG.BackgroundColor3 = config.Bg_Color
                    SliderValBG.BorderSizePixel = 0
                    SliderValBG.Position = UDim2.new(sliderValuePosition, 0, 0.22, 0)
                    SliderValBG.Size = UDim2.new(0, 36, 0, 22)
                    SliderValBG.AutoButtonColor = false
                    SliderValBG.Font = Enum.Font.Gotham
                    SliderValBG.Text = ""
                    SliderValBG.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderValBG.TextSize = isMobile and 12 or 14

                    SliderValBGC.CornerRadius = UDim.new(0, 6)
                    SliderValBGC.Name = "SliderValBGC"
                    SliderValBGC.Parent = SliderValBG

                    local MinSlider = Instance.new("TextButton")
                    MinSlider.Name = "MinSlider"
                    MinSlider.Parent = SliderBack
                    MinSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    MinSlider.BackgroundTransparency = 0
                    MinSlider.BorderSizePixel = 0
                    MinSlider.Position = UDim2.new(0.28, 0, 0.25, 0)
                    MinSlider.Size = UDim2.new(0, 18, 0, 18)
                    MinSlider.Font = Enum.Font.Gotham
                    MinSlider.Text = "-"
                    MinSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                    MinSlider.TextSize = 13
                    MinSlider.TextWrapped = true
                    MinSlider.ZIndex = 2

                    local MinSliderC = Instance.new("UICorner")
                    MinSliderC.CornerRadius = UDim.new(0, 4)
                    MinSliderC.Parent = MinSlider

                    local AddSlider = Instance.new("TextButton")
                    AddSlider.Name = "AddSlider"
                    AddSlider.Parent = SliderBack
                    AddSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    AddSlider.BackgroundTransparency = 0
                    AddSlider.BorderSizePixel = 0
                    AddSlider.Position = UDim2.new(0.75, 0, 0.25, 0)
                    AddSlider.Size = UDim2.new(0, 18, 0, 18)
                    AddSlider.Font = Enum.Font.Gotham
                    AddSlider.Text = "+"
                    AddSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                    AddSlider.TextSize = 13
                    AddSlider.TextWrapped = true
                    AddSlider.ZIndex = 2

                    local AddSliderC = Instance.new("UICorner")
                    AddSliderC.CornerRadius = UDim.new(0, 4)
                    AddSliderC.Parent = AddSlider

                    MinSlider.MouseButton1Click:Connect(function()
                        local currentValue = FengUI.flags[flag]
                        currentValue = math.clamp(currentValue - 1, min, max)
                        funcs:SetValue(currentValue)
                    end)

                    AddSlider.MouseButton1Click:Connect(function()
                        local currentValue = FengUI.flags[flag]
                        currentValue = math.clamp(currentValue + 1, min, max)
                        funcs:SetValue(currentValue)
                    end)
                end

                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderValue.BackgroundTransparency = 1.000
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderValue.TextSize = isMobile and 11 or 12

                local funcs = {
                    SetValue = function(self, value)
                        local percent
                        if value then
                            percent = (value - min)/(max - min)
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
                        percent = (value - min)/(max - min)
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

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        funcs:SetValue()
                    end
                end)

                SliderPart.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        funcs:SetValue()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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

            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = nil

                local DropdownModule = Instance.new("Frame")
                local DropdownTop = Instance.new("TextButton")
                local DropdownTopC = Instance.new("UICorner")
                local DropdownOpenFrame = Instance.new("Frame")
                local DropdownOpenFrameC = Instance.new("UICorner")
                local DropdownOpen = Instance.new("TextButton")
                local DropdownText = Instance.new("TextBox")

                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownModule.BackgroundTransparency = 1.000
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Position = UDim2.new(0, 0, 0, 0)
                DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36)

                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0.2
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(1, 0, 0, 36)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = config.TextColor
                DropdownTop.TextSize = isMobile and 14 or 16
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left

                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop

                local BackgroundFill = Instance.new("Frame")
                BackgroundFill.Name = "BackgroundFill"
                BackgroundFill.Parent = DropdownTop
                BackgroundFill.BackgroundColor3 = config.Dropdown_Color
                BackgroundFill.BorderSizePixel = 0
                BackgroundFill.Position = UDim2.new(0.75, 0, 0, 0)
                BackgroundFill.Size = UDim2.new(0.25, 0, 1, 0)
                BackgroundFill.ZIndex = 0

                local dropdownFramePosition = 0.80
                local separatorPosition = 0.74
                if windowCount == 2 then
                    dropdownFramePosition = 0.71
                    separatorPosition = 0.65
                end

                DropdownOpenFrame.Name = "DropdownOpenFrame"
                DropdownOpenFrame.Parent = DropdownTop
                DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
                DropdownOpenFrame.BorderSizePixel = 0
                DropdownOpenFrame.Position = UDim2.new(dropdownFramePosition, 0, 0.5, 0)
                DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)
                DropdownOpenFrame.ZIndex = 2

                DropdownOpenFrameC.CornerRadius = UDim.new(0, 6)
                DropdownOpenFrameC.Name = "DropdownOpenFrameC"
                DropdownOpenFrameC.Parent = DropdownOpenFrame

                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownOpenFrame
                DropdownOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownOpen.BackgroundTransparency = 1.000
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Size = UDim2.new(1, 0, 1, 0)
                DropdownOpen.Font = Enum.Font.GothamSemibold
                DropdownOpen.Text = "选择"
                DropdownOpen.TextColor3 = config.TextColor
                DropdownOpen.TextSize = isMobile and 11 or 12
                DropdownOpen.TextWrapped = true
                DropdownOpen.ZIndex = 3

                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownText.BackgroundTransparency = 1.000
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 230, 1, 0)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.PlaceholderColor3 = config.SecondaryTextColor
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = isMobile and 14 or 16
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                DropdownText.ZIndex = 2

                local Separator = Instance.new("Frame")
                Separator.Name = "Separator"
                Separator.Parent = DropdownTop
                Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                Separator.BorderSizePixel = 0
                Separator.Position = UDim2.new(separatorPosition, 0, 0.2, 0)
                Separator.Size = UDim2.new(0, 1, 0, 22)
                Separator.ZIndex = 1

                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.Name = "OptionsContainer"
                OptionsContainer.Parent = DropdownModule
                OptionsContainer.BackgroundTransparency = 1
                OptionsContainer.BorderSizePixel = 0
                OptionsContainer.Position = UDim2.new(0, 0, 0, 40)
                OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                OptionsContainer.ClipsDescendants = true
                OptionsContainer.Visible = false

                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.Name = "OptionsLayout"
                OptionsLayout.Parent = OptionsContainer
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Padding = UDim.new(0, 4)

                local allOptions = {}
                local open = false

                local function updateDropdownHeight()
                    if not open then 
                        OptionsContainer.Visible = false
                        OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                        DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36)
                        return 
                    end

                    OptionsContainer.Visible = true

                    local visibleCount = 0
                    for _, option in pairs(allOptions) do
                        if option and option.Parent and option.Visible then
                            visibleCount = visibleCount + 1
                        end
                    end

                    if visibleCount == 0 then
                        OptionsContainer.Size = UDim2.new(1, 0, 0, 28)
                        DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36 + 28)
                    else
                        local optionHeight = 24
                        local padding = 4
                        local totalOptionsHeight = (optionHeight + padding) * visibleCount
                        OptionsContainer.Size = UDim2.new(1, 0, 0, totalOptionsHeight)
                        DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36 + totalOptionsHeight + 8)
                    end
                end

                local function setAllVisible()
                    for _, option in pairs(allOptions) do
                        if option then
                            option.Visible = true
                        end
                    end
                    updateDropdownHeight()
                end

                local function searchDropdown(text)
                    local visibleCount = 0
                    for _, option in pairs(allOptions) do
                        if option then
                            if text == "" then
                                option.Visible = true
                            else
                                option.Visible = option.Text:lower():match(text:lower()) ~= nil
                            end
                            if option.Visible then
                                visibleCount = visibleCount + 1
                            end
                        end
                    end
                    updateDropdownHeight()
                end

                local function toggleDropdown()
                    open = not open
                    DropdownOpen.Text = open and "取消" or "选择"
                    if open then
                        setAllVisible()
                        DropdownText:CaptureFocus()
                    end
                    updateDropdownHeight()
                    create3DFlipAnimation(DropdownOpenFrame, 0.3)
                end

                DropdownOpen.MouseButton1Click:Connect(toggleDropdown)

                DropdownText.Focused:Connect(function()
                    if not open then
                        toggleDropdown()
                    end
                end)

                DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                    if open then
                        searchDropdown(DropdownText.Text)
                    end
                end)

                OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then
                        updateDropdownHeight()
                    end
                end)

                local funcs = {}

                funcs.AddOption = function(self, optionText)
                    local Option = Instance.new("TextButton")
                    local OptionC = Instance.new("UICorner")

                    Option.Name = "Option_" .. optionText
                    Option.Parent = OptionsContainer
                    Option.BackgroundColor3 = config.TabColor
                    Option.BackgroundTransparency = 0.2
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(1, 0, 0, 24)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = optionText
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = isMobile and 13 or 14
                    Option.Visible = true
                    Option.LayoutOrder = #allOptions + 1

                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option

                    Option.MouseEnter:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.TabColor.R * 255 * 1.2),
                                math.floor(config.TabColor.G * 255 * 1.2),
                                math.floor(config.TabColor.B * 255 * 1.2)
                            )
                        }):Play()
                    end)

                    Option.MouseLeave:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                            BackgroundColor3 = config.TabColor
                        }):Play()
                    end)

                    Option.MouseButton1Click:Connect(function()
                        toggleDropdown()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        FengUI.flags[flag] = Option.Text
                    end)

                    table.insert(allOptions, Option)

                    if open then
                        updateDropdownHeight()
                    end

                    return Option
                end

                funcs.RemoveOption = function(self, optionText)
                    for i, option in pairs(allOptions) do
                        if option and option.Text == optionText then
                            option:Destroy()
                            table.remove(allOptions, i)
                            break
                        end
                    end
                    if open then
                        updateDropdownHeight()
                    end
                end

                funcs.SetOptions = function(self, newOptions)
                    for _, option in pairs(allOptions) do
                        if option then
                            option:Destroy()
                        end
                    end
                    allOptions = {}

                    for _, optionText in pairs(newOptions) do
                        funcs:AddOption(optionText)
                    end

                    if open then
                        updateDropdownHeight()
                    end
                end

                funcs.GetSelected = function(self)
                    return FengUI.flags[flag]
                end

                funcs.SetSelected = function(self, value)
                    if value then
                        for _, option in pairs(allOptions) do
                            if option and option.Text == value then
                                DropdownText.Text = value
                                FengUI.flags[flag] = value
                                break
                            end
                        end
                    else
                        DropdownText.Text = ""
                        FengUI.flags[flag] = nil
                    end
                end

                funcs.Clear = function(self)
                    for _, option in pairs(allOptions) do
                        if option then
                            option:Destroy()
                        end
                    end
                    allOptions = {}
                    DropdownText.Text = ""
                    FengUI.flags[flag] = nil
                    if open then
                        updateDropdownHeight()
                    end
                end

                funcs.Open = function(self)
                    if not open then
                        toggleDropdown()
                    end
                end

                funcs.Close = function(self)
                    if open then
                        toggleDropdown()
                    end
                end

                funcs:SetOptions(options)

                return funcs
            end

            return section
        end

        -- 标签点击事件
        sidebar2.MouseButton1Click:Connect(function()
            switchTab({ sidebar2, workareamain })
        end)

        -- 第一个标签统一通过 switchTab 激活
        if #sections == 1 then
            switchTab({ sidebar2, workareamain })
        end

        return tab
    end

    function window:DualTab(name, icon)
        return window:Tab(name, icon, 2)
    end

    -- 延迟激活第一个标签（防止初始化遗漏）
    task.defer(function()
        if FengUI.currentTab == nil and #sections > 0 then
            for _, btn in ipairs(sidebar:GetChildren()) do
                if btn:IsA("TextButton") and btn.Name:find("sidebar2_") then
                    for _, w in ipairs(workareas) do
                        if w.Name == "workareamain_" .. btn.Text then
                            switchTab({ btn, w })
                            break
                        end
                    end
                    break
                end
            end
        end
    end)

    return window
end

-- 颜色选择器相关（原样保留，但已集成在 section 中，此部分可保留为全局功能）
FengUI.ColorPickers = {}
function FengUI:CreateColorPicker(options)
    -- 简单实现，可自行扩展
    print("ColorPicker created")
end

function FengUI:ColorPicker(options)
    return self:CreateColorPicker(options)
end

function FengUI:CloseAllColorPickers()
    for _, picker in pairs(FengUI.ColorPickers) do
        if picker.Instance and picker.Instance.Parent then
            picker.Instance:Destroy()
        end
    end
    FengUI.ColorPickers = {}
end

function UiDestroy()
    if FengYu then
        FengYu:Destroy()
    end
    FengUI:CloseAllColorPickers()
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    main.Visible = ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI