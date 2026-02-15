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
        -- 如果已经是完整URL（以rbxassetid://或http开头），直接返回
        if id:match("^rbxassetid://") or id:match("^https?://") then
            return id
        elseif id:match("^%d+$") then
            -- 纯数字字符串
            return "rbxassetid://" .. id
        else
            -- 其他字符串，原样返回
            return id
        end
    else
        return nil
    end
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

-- 搜索框（原样，但搜索逻辑已修复）
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

-- ============= 修复搜索功能，避免干扰按钮可见性 =============
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
-- ===========================================================

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
-- 辅助函数：平滑滚动（来自UI.lua）
-- =========================================
local function setupSmoothScrolling(scrollingFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        scrollingFrame.ScrollingEnabled = layout.AbsoluteContentSize.Y > scrollingFrame.AbsoluteSize.Y
    end)
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

-- =========================================
-- 完全重写的 section 逻辑，包含完整控件
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

    -- ---------- Tab 创建（与原测试UI相同，但内部 section 完全重写）----------
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1

        -- 侧边栏按钮
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

        -- 工作区（右侧滚动区域）
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

        -- 主容器（用于放置 Section）
        local MainContainer = Instance.new("Frame")
        MainContainer.Name = "MainContainer"
        MainContainer.Parent = workareamain
        MainContainer.BackgroundTransparency = 1
        MainContainer.Size = UDim2.new(1, 0, 0, 0)

        local workarealayout = Instance.new("UIListLayout")
        workarealayout.Parent = MainContainer
        workarealayout.SortOrder = Enum.SortOrder.LayoutOrder
        workarealayout.Padding = UDim.new(0, 10)

        -- 平滑滚动设置
        setupSmoothScrolling(workareamain, workarealayout)

        table.insert(workareas, workareamain)

        local tab = {}

        -- ============= 完全重写的 section 实现，包含完整控件 =============
        -- 参数顺序：tab, name, iconAssets, TabVal
        -- iconAssets: 字符串（仅展开图标）或表格 {Y="展开图标ID", F="收缩图标ID"}（完全自定义）
        -- TabVal: 可选，默认为 true，可传布尔值或 "false"/"0" 字符串
        function tab.section(tab, name, iconAssets, TabVal)
            -- 处理默认展开状态
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

            -- 处理图标资源（使用辅助函数格式化ID）
            local expandedIcon, collapsedIcon
            if type(iconAssets) == "table" then
                -- 完全自定义：使用 Y 字段为展开图标，F 字段为收缩图标（同时支持小写 y/f 作为备选）
                expandedIcon = iconAssets.Y or iconAssets.y or DEFAULT_ICON_EXPAND
                collapsedIcon = iconAssets.F or iconAssets.f or DEFAULT_ICON_COLLAPSE
                expandedIcon = formatImageId(expandedIcon)
                collapsedIcon = formatImageId(collapsedIcon)
            elseif type(iconAssets) == "string" or type(iconAssets) == "number" then
                expandedIcon = formatImageId(iconAssets)
                collapsedIcon = DEFAULT_ICON_COLLAPSE  -- 只提供一个时，展开用自定义，收缩用默认
            else
                expandedIcon = DEFAULT_ICON_EXPAND
                collapsedIcon = DEFAULT_ICON_COLLAPSE
            end

            local elementWidth = WORKAREA_WIDTH - 56  -- 工作区可用宽度

            -- ---------- Section 主框架 ----------
            local Section = Instance.new("Frame")
            Section.Name = "Section_" .. name
            Section.Parent = MainContainer
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, 0, 0, 36)

            -- ---------- 标题栏 ----------
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, 36)

            -- 左侧图标（ImageLabel）- 修改：尺寸增大为30x30，圆角设为8（小圆角）
            local SectionIcon = Instance.new("ImageLabel")
            SectionIcon.Name = "SectionIcon"
            SectionIcon.Parent = SectionHeader
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Position = UDim2.new(0, 5, 0, 3)  -- 稍微调整垂直居中
            SectionIcon.Size = UDim2.new(0, 30, 0, 30)   -- 增大为30x30
            SectionIcon.Image = open and expandedIcon or collapsedIcon
            SectionIcon.ImageColor3 = Color3.new(1, 1, 1)  -- 白色，确保原色显示
            SectionIcon.ScaleType = Enum.ScaleType.Fit
            -- 添加小圆角（正方形四边圆形，即圆角矩形）
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)      -- 8像素圆角，保持方形但带圆角
            iconCorner.Parent = SectionIcon

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 40, 0, 0)  -- 位置左移以适应更大的图标
            SectionTitle.Size = UDim2.new(1, -45, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.AccentColor
            SectionTitle.TextSize = isMobile and 16 or 18
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

            -- 点击按钮（覆盖整个标题栏）
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "ToggleBtn"
            ToggleBtn.Parent = SectionHeader
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
            ToggleBtn.Text = ""

            -- ---------- 内容容器 ----------
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = Section
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 0, 0, 36)
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Visible = open

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Parent = SectionContent
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 8)

            -- 动态更新 Section 高度
            local function updateSectionHeight()
                if open then
                    SectionContent.Visible = true
                    local contentHeight = ContentLayout.AbsoluteContentSize.Y
                    SectionContent.Size = UDim2.new(1, 0, 0, contentHeight)
                    Section.Size = UDim2.new(1, 0, 0, 36 + contentHeight + 8)
                else
                    SectionContent.Visible = false
                    SectionContent.Size = UDim2.new(1, 0, 0, 0)
                    Section.Size = UDim2.new(1, 0, 0, 36)
                end
            end

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
            end)

            -- 点击切换
            ToggleBtn.MouseButton1Click:Connect(function()
                open = not open
                SectionIcon.Image = open and expandedIcon or collapsedIcon  -- 切换图标
                local targetHeight = open and (36 + ContentLayout.AbsoluteContentSize.Y + 8) or 36
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                }):Play()
                if open then
                    SectionContent.Visible = true
                else
                    task.delay(0.25, function()
                        if not open then
                            SectionContent.Visible = false
                        end
                    end)
                end
            end)

            updateSectionHeight()

            -- ---------- 控件工厂（完整移植原测试UI，仅调整父级为 SectionContent）----------
            local section = {}

            function section.Button(section, text, callback)
                local button = Instance.new("TextButton")
                button.Name = "button_" .. text
                button.Parent = SectionContent
                button.BackgroundColor3 = config.Button_Color
                button.BackgroundTransparency = 0.2
                button.Size = UDim2.new(1, 0, 0, isMobile and 32 or 40)
                button.Font = Enum.Font.Gotham
                button.Text = text
                button.TextColor3 = config.AccentColor
                button.TextSize = isMobile and 16 or 18

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)
                buttonCorner.Parent = button

                local buttonStroke = Instance.new("UIStroke", button)
                buttonStroke.ApplyStrokeMode = "Border"
                buttonStroke.Color = config.AccentColor
                buttonStroke.Thickness = 1
                buttonStroke.Transparency = 0.8

                if callback then
                    button.MouseButton1Click:Connect(callback)
                end
                return button
            end

            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = SectionContent
                ImageModule.BackgroundTransparency = 1
                ImageModule.Size = UDim2.new(1, 0, 0, sizeY or (isMobile and 100 or 120))

                local ImageLabel = Instance.new("ImageLabel")
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or (WORKAREA_WIDTH - 56), WORKAREA_WIDTH - 56), 0, sizeY or (isMobile and 100 or 120))
                ImageLabel.ScaleType = Enum.ScaleType.Crop

                local ImageCorner = Instance.new("UICorner")
                ImageCorner.CornerRadius = UDim.new(0, 9)
                ImageCorner.Parent = ImageLabel

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

                local imageController = {
                    SetImage = function(_, newSource) setImage(newSource) end,
                    Destroy = function() ImageModule:Destroy() end
                }
                return imageController
            end

            function section:Label(text)
                local label = Instance.new("TextLabel")
                label.Name = "label_" .. text
                label.Parent = SectionContent
                label.BackgroundColor3 = config.Label_Color
                label.BackgroundTransparency = 0.2
                label.Size = UDim2.new(1, 0, 0, isMobile and 30 or 36)
                label.Font = Enum.Font.Gotham
                label.TextColor3 = config.TextColor
                label.TextSize = isMobile and 14 or 16
                label.TextWrapped = true
                label.Text = text

                local labelCorner = Instance.new("UICorner")
                labelCorner.CornerRadius = UDim.new(0, 8)
                labelCorner.Parent = label
                return label
            end

            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                FengUI.flags[flag] = enabled

                local ToggleContainer = Instance.new("Frame")
                ToggleContainer.Name = "toggle_" .. flag
                ToggleContainer.Parent = SectionContent
                ToggleContainer.BackgroundTransparency = 1
                ToggleContainer.Size = UDim2.new(1, 0, 0, isMobile and 40 or 48)

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Parent = ToggleContainer
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.Text = text
                ToggleLabel.TextColor3 = config.TextColor
                ToggleLabel.TextSize = isMobile and 14 or 16
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

                local SwitchFrame = Instance.new("TextButton")
                SwitchFrame.Parent = ToggleContainer
                SwitchFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                SwitchFrame.Position = UDim2.new(0.85, 0, 0.5, 0)
                SwitchFrame.Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 24 or 28)
                SwitchFrame.Text = ""
                SwitchFrame.AutoButtonColor = false

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchFrame

                local SwitchButton = Instance.new("TextButton")
                SwitchButton.Parent = SwitchFrame
                SwitchButton.AnchorPoint = Vector2.new(0.5, 0.5)
                SwitchButton.Position = UDim2.new(enabled and 0.75 or 0.25, 0, 0.5, 0)
                SwitchButton.Size = UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24)
                SwitchButton.AutoButtonColor = false
                SwitchButton.Text = ""

                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(1, 0)
                ButtonCorner.Parent = SwitchButton

                if enabled then
                    SwitchFrame.BackgroundColor3 = config.Toggle_On
                else
                    SwitchFrame.BackgroundColor3 = config.Toggle_Off
                end

                local funcs = {
                    SetState = function(self, state)
                        if state == nil then state = not FengUI.flags[flag] end
                        if FengUI.flags[flag] == state then return end
                        FengUI.flags[flag] = state
                        if state then
                            SwitchButton:TweenPosition(UDim2.new(0.75, 0, 0.5, 0), "In", "Sine", 0.1, true)
                            SwitchFrame.BackgroundColor3 = config.Toggle_On
                        else
                            SwitchButton:TweenPosition(UDim2.new(0.25, 0, 0.5, 0), "In", "Sine", 0.1, true)
                            SwitchFrame.BackgroundColor3 = config.Toggle_Off
                        end
                        callback(state)
                    end,
                    Module = ToggleContainer
                }

                if enabled ~= false then
                    funcs:SetState(true)
                end

                SwitchFrame.MouseButton1Click:Connect(function() funcs:SetState() end)
                SwitchButton.MouseButton1Click:Connect(function() funcs:SetState() end)
                return funcs
            end

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

                local KeybindContainer = Instance.new("Frame")
                KeybindContainer.Name = "keybind_" .. text
                KeybindContainer.Parent = SectionContent
                KeybindContainer.BackgroundTransparency = 1
                KeybindContainer.Size = UDim2.new(1, 0, 0, isMobile and 40 or 48)

                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Name = "KeybindLabel"
                KeybindLabel.Parent = KeybindContainer
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Size = UDim2.new(0.7, 0, 1, 0)
                KeybindLabel.Font = Enum.Font.Gotham
                KeybindLabel.Text = text
                KeybindLabel.TextColor3 = config.TextColor
                KeybindLabel.TextSize = isMobile and 14 or 16
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left

                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Name = "KeybindButton"
                KeybindButton.Parent = KeybindContainer
                KeybindButton.BackgroundColor3 = config.Keybind_Color
                KeybindButton.BackgroundTransparency = 0.2
                KeybindButton.Position = UDim2.new(0.7, 0, 0.25, 0)
                KeybindButton.Size = UDim2.new(0.3, 0, 0.5, 0)
                KeybindButton.Font = Enum.Font.Gotham
                KeybindButton.Text = keyTxt
                KeybindButton.TextColor3 = config.TextColor
                KeybindButton.TextSize = isMobile and 12 or 14

                local KeybindCorner = Instance.new("UICorner")
                KeybindCorner.CornerRadius = UDim.new(0, 6)
                KeybindCorner.Parent = KeybindButton

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)

                KeybindButton.MouseButton1Click:Connect(function()
                    KeybindButton.Text = "..."
                    KeybindButton.BackgroundColor3 = config.AccentColor
                    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)

                    task.wait()

                    local key = UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)

                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        KeybindButton.Text = keyTxt
                        KeybindButton.BackgroundColor3 = config.Keybind_Color
                        KeybindButton.BackgroundTransparency = 0.2
                        KeybindButton.TextColor3 = config.TextColor
                        return
                    end

                    if banned[keyName] then
                        KeybindButton.Text = keyTxt
                        KeybindButton.BackgroundColor3 = config.Keybind_Color
                        KeybindButton.BackgroundTransparency = 0.2
                        KeybindButton.TextColor3 = config.TextColor
                        return
                    end

                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    keyTxt = shortNames[keyName] or keyName
                    KeybindButton.Text = keyTxt
                    KeybindButton.BackgroundColor3 = config.Keybind_Color
                    KeybindButton.BackgroundTransparency = 0.2
                    KeybindButton.TextColor3 = config.TextColor
                end)
            end

            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")

                FengUI.flags[flag] = default

                local TextboxContainer = Instance.new("Frame")
                TextboxContainer.Name = "textbox_" .. flag
                TextboxContainer.Parent = SectionContent
                TextboxContainer.BackgroundTransparency = 1
                TextboxContainer.Size = UDim2.new(1, 0, 0, isMobile and 60 or 70)

                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Name = "TextboxLabel"
                TextboxLabel.Parent = TextboxContainer
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Size = UDim2.new(1, 0, 0.4, 0)
                TextboxLabel.Font = Enum.Font.Gotham
                TextboxLabel.Text = text
                TextboxLabel.TextColor3 = config.TextColor
                TextboxLabel.TextSize = isMobile and 14 or 16
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left

                local TextboxInput = Instance.new("Frame")
                TextboxInput.Parent = TextboxContainer
                TextboxInput.BackgroundColor3 = config.Textbox_Color
                TextboxInput.BackgroundTransparency = 0.2
                TextboxInput.Position = UDim2.new(0, 0, 0.4, 0)
                TextboxInput.Size = UDim2.new(1, 0, 0.6, 0)

                local TextboxCorner = Instance.new("UICorner")
                TextboxCorner.CornerRadius = UDim.new(0, 8)
                TextboxCorner.Parent = TextboxInput

                local textbox = Instance.new("TextBox")
                textbox.Parent = TextboxInput
                textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textbox.BackgroundTransparency = 1
                textbox.Size = UDim2.new(1, -20, 1, 0)
                textbox.Position = UDim2.new(0, 10, 0, 0)
                textbox.ClearTextOnFocus = false
                textbox.Font = Enum.Font.Gotham
                textbox.PlaceholderColor3 = config.SecondaryTextColor
                textbox.PlaceholderText = "Type..."
                textbox.Text = default
                textbox.TextColor3 = config.TextColor
                textbox.TextSize = isMobile and 14 or 16
                textbox.TextXAlignment = Enum.TextXAlignment.Left

                textbox.FocusLost:Connect(function()
                    if textbox.Text == "" then
                        textbox.Text = default
                    end
                    FengUI.flags[flag] = textbox.Text
                    callback(textbox.Text)
                end)
            end

            function section.Slider(section, text, flag, default, min, max, precise, callback)
                callback = callback or function() end
                min = min or 0
                max = max or 100
                default = default or min
                precise = precise or false

                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default value provided")

                FengUI.flags[flag] = default

                local SliderContainer = Instance.new("Frame")
                SliderContainer.Name = "slider_" .. flag
                SliderContainer.Parent = SectionContent
                SliderContainer.BackgroundTransparency = 1
                SliderContainer.Size = UDim2.new(1, 0, 0, isMobile and 70 or 80)

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Parent = SliderContainer
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(1, 0, 0.4, 0)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.Text = text .. ": " .. tostring(default)
                SliderLabel.TextColor3 = config.TextColor
                SliderLabel.TextSize = isMobile and 14 or 16
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderContainer
                SliderBar.BackgroundColor3 = config.Slider_Color
                SliderBar.BackgroundTransparency = 0.2
                SliderBar.Position = UDim2.new(0, 0, 0.6, 0)
                SliderBar.Size = UDim2.new(1, 0, 0.2, 0)

                local SliderBarCorner = Instance.new("UICorner")
                SliderBarCorner.CornerRadius = UDim.new(1, 0)
                SliderBarCorner.Parent = SliderBar

                local SliderPart = Instance.new("Frame")
                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = config.SliderBar_Color
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)

                local SliderPartCorner = Instance.new("UICorner")
                SliderPartCorner.CornerRadius = UDim.new(1, 0)
                SliderPartCorner.Parent = SliderPart

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
                        SliderLabel.Text = text .. ": " .. tostring(value)

                        services.TweenService:Create(SliderPart, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        funcs:SetValue()
                    end
                end)

                SliderPart.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        funcs:SetValue()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        funcs:SetValue()
                    end
                end)

                return funcs
            end

            function section.Dropdown(section, text, flag, options, callback)
                callback = callback or function() end
                options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = nil

                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Name = "dropdown_" .. flag
                DropdownContainer.Parent = SectionContent
                DropdownContainer.BackgroundTransparency = 1
                DropdownContainer.Size = UDim2.new(1, 0, 0, isMobile and 60 or 70)

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Name = "DropdownLabel"
                DropdownLabel.Parent = DropdownContainer
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Size = UDim2.new(1, 0, 0.4, 0)
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.Text = text
                DropdownLabel.TextColor3 = config.TextColor
                DropdownLabel.TextSize = isMobile and 14 or 16
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = DropdownContainer
                DropdownButton.BackgroundColor3 = config.Dropdown_Color
                DropdownButton.BackgroundTransparency = 0.2
                DropdownButton.Position = UDim2.new(0, 0, 0.4, 0)
                DropdownButton.Size = UDim2.new(1, 0, 0.6, 0)
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = "Select..."
                DropdownButton.TextColor3 = config.TextColor
                DropdownButton.TextSize = isMobile and 14 or 16

                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 8)
                DropdownCorner.Parent = DropdownButton

                local allOptions = {}
                local selectedOption = nil

                local funcs = {
                    AddOption = function(self, optionText)
                        table.insert(allOptions, optionText)
                    end,
                    SetOptions = function(self, newOptions)
                        allOptions = newOptions or {}
                    end
                }

                DropdownButton.MouseButton1Click:Connect(function()
                    if #allOptions > 0 then
                        selectedOption = allOptions[1]
                        DropdownButton.Text = selectedOption
                        callback(selectedOption)
                        FengUI.flags[flag] = selectedOption
                    end
                end)

                funcs:SetOptions(options)

                if #options > 0 then
                    selectedOption = options[1]
                    DropdownButton.Text = selectedOption
                    FengUI.flags[flag] = selectedOption
                end

                return funcs
            end

            function section.ColorPicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                assert(text, "No text provided")
                assert(flag, "No flag provided")

                FengUI.flags[flag] = defaultColor

                local ColorPickerContainer = Instance.new("Frame")
                ColorPickerContainer.Name = "colorpicker_" .. flag
                ColorPickerContainer.Parent = SectionContent
                ColorPickerContainer.BackgroundTransparency = 1
                ColorPickerContainer.Size = UDim2.new(1, 0, 0, isMobile and 60 or 70)

                local ColorPickerLabel = Instance.new("TextLabel")
                ColorPickerLabel.Name = "ColorPickerLabel"
                ColorPickerLabel.Parent = ColorPickerContainer
                ColorPickerLabel.BackgroundTransparency = 1
                ColorPickerLabel.Size = UDim2.new(0.7, 0, 1, 0)
                ColorPickerLabel.Font = Enum.Font.Gotham
                ColorPickerLabel.Text = text
                ColorPickerLabel.TextColor3 = config.TextColor
                ColorPickerLabel.TextSize = isMobile and 14 or 16
                ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left

                local ColorPreview = Instance.new("TextButton")
                ColorPreview.Name = "ColorPreview"
                ColorPreview.Parent = ColorPickerContainer
                ColorPreview.BackgroundColor3 = defaultColor
                ColorPreview.Position = UDim2.new(0.7, 0, 0.25, 0)
                ColorPreview.Size = UDim2.new(0.3, 0, 0.5, 0)
                ColorPreview.Text = ""

                local ColorPreviewCorner = Instance.new("UICorner")
                ColorPreviewCorner.CornerRadius = UDim.new(0, 8)
                ColorPreviewCorner.Parent = ColorPreview

                local funcs = {
                    SetColor = function(self, color)
                        if typeof(color) == "Color3" then
                            ColorPreview.BackgroundColor3 = color
                            FengUI.flags[flag] = color
                            callback(color)
                        end
                    end,
                    GetColor = function(self)
                        return FengUI.flags[flag] or defaultColor
                    end,
                    Module = ColorPickerContainer
                }

                ColorPreview.MouseButton1Click:Connect(function()
                    print("颜色选择器功能需要完整实现")
                end)

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

-- 颜色选择器相关（原样）
FengUI.ColorPickers = {}
function FengUI:CreateColorPicker(options)
    local config = {
        title = options.title or "选择颜色",
        defaultColor = options.defaultColor or Color3.fromRGB(255, 255, 255),
        callback = options.callback or function(color) end,
        position = options.position or UDim2.new(0.5, 0, 0.5, 0),
        parent = options.parent or FengYu
    }

    local ColorPickerPopup = Instance.new("Frame")
    ColorPickerPopup.Name = "ColorPickerPopup"
    ColorPickerPopup.Parent = config.parent
    ColorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
    ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    ColorPickerPopup.BackgroundTransparency = 0.1
    ColorPickerPopup.BorderSizePixel = 0
    ColorPickerPopup.Position = config.position
    ColorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
    ColorPickerPopup.Visible = true
    ColorPickerPopup.ZIndex = 1000
    ColorPickerPopup.Active = true
    ColorPickerPopup.Draggable = true

    local PopupCorner = Instance.new("UICorner")
    PopupCorner.CornerRadius = UDim.new(0, 8)
    PopupCorner.Parent = ColorPickerPopup

    local PopupStroke = Instance.new("UIStroke")
    PopupStroke.Parent = ColorPickerPopup
    PopupStroke.Color = config.AccentColor or Color3.fromRGB(21, 103, 251)
    PopupStroke.Thickness = 1.5
    PopupStroke.Transparency = 0.2

    local colorPickerObj = {
        Instance = ColorPickerPopup,
        CurrentColor = config.defaultColor,
        Closed = false
    }

    local pickerId = #FengUI.ColorPickers + 1
    FengUI.ColorPickers[pickerId] = colorPickerObj

    return colorPickerObj
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