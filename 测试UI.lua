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
-- 检测是否为手机/平板设备
local isMobile = UserInputService.TouchEnabled
local isConsole = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled
local isDesktop = not isMobile and not isConsole

-- 设置UI尺寸
local MAIN_WIDTH, MAIN_HEIGHT
local WORKAREA_WIDTH, WORKAREA_HEIGHT
local SIDEBAR_WIDTH

if isMobile then
    -- 手机端尺寸
    MAIN_WIDTH = 450
    MAIN_HEIGHT = 280
    WORKAREA_WIDTH = 280
    WORKAREA_HEIGHT = 280
    SIDEBAR_WIDTH = 150
else
    -- 电脑端尺寸
    MAIN_WIDTH = 721
    MAIN_HEIGHT = 584
    WORKAREA_WIDTH = 458
    WORKAREA_HEIGHT = 584
    SIDEBAR_WIDTH = 233
end

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

local sections = {}
local workareas = {}
local visible = true
local dbcooper = false

local function tp(ins, pos, time, thing)
    game:GetService("TweenService"):Create(ins, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),{Position = pos}):Play()
end

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建万能UI的ScreenGui
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- 添加打开按钮
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

-- 创建主窗口（根据设备类型调整大小）
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

-- workarea right side setup
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

-- 搜索框移动到侧边栏右边的最上面（工作区的右上角）
local search = Instance.new("Frame")
search.Name = "search"
search.Parent = workarea  -- 父级改为workarea
search.BackgroundColor3 = config.Textbox_Color
search.BackgroundTransparency = 0.2
search.Position = UDim2.new(isMobile and 0.1 or 0.7, 0, 0.01, 0) -- 右上角位置
search.Size = UDim2.new(0, isMobile and 120 or 120, 0, 28) -- 适当缩小大小

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
searchicon.Size = UDim2.new(0, 20, 0, 20) -- 缩小图标
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

-- 侧边栏标题（脚本名字） - 放在最上面，位置更靠上
local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Name = "SidebarTitle"
SidebarTitle.Parent = main
SidebarTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.BorderSizePixel = 0
SidebarTitle.Position = UDim2.new(0.025, 0, 0.02, 0) -- 从0.06改为0.02，更靠上
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
TagContainer.Position = UDim2.new(0.025, 0, 0.12, 0) -- 在标题下方
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
sidebar.Position = UDim2.new(0.0249653254, 0, isMobile and 0.25 or 0.20, 0) -- 在标题下方
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, isMobile and 150 or 400) -- 调整高度
sidebar.AutomaticCanvasSize = "Y"
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.ScrollBarThickness = 2

local ull_2 = Instance.new("UIListLayout")
ull_2.Parent = sidebar
ull_2.SortOrder = Enum.SortOrder.LayoutOrder
ull_2.Padding = UDim.new(0, 5)

-- 搜索功能
game:GetService("RunService"):BindToRenderStep("search", 1, function()
    if not searchtextbox:IsFocused() then 
        for b,v in next, sidebar:GetChildren() do
            if not v:IsA("TextButton") then return end
            v.Visible = true
        end
    end
    local InputText=string.upper(searchtextbox.Text)
    for _,button in pairs(sidebar:GetChildren())do
        if button:IsA("TextButton")then
            if InputText==""or string.find(string.upper(button.Text),InputText)~=nil then
                button.Visible=true
            else
                button.Visible=false
            end
        end
    end
end)

-- 动画效果
Open.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
    if main.Visible then
        tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
    else
        tp(main, UDim2.new(0.5, 0, 2, 0), 0.5)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        main.Visible = not main.Visible
        if main.Visible then
            tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
        else
            tp(main, UDim2.new(0.5, 0, 2, 0), 0.5)
        end
    end
end)

-- 初始化动画
tp(main, UDim2.new(0.5, 0, 0.5, 0), 1)

-- =========================================
-- 功能函数
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
                    -- 创建彩虹效果
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
                    
                    -- 创建脉动效果
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
        
        local Tag = tagObj.Instance
        local TagStroke = tagObj.Stroke
        
        if text then
            Tag.Text = text
            tagObj.Text = text
            local textSize = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.GothamSemibold, Vector2.new(200, 20))
            Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 20)
        end
        
        if bgColor then
            tagObj.Color = bgColor
            if not tagObj.UseNeonEffect then
                Tag.BackgroundColor3 = bgColor
                TagStroke.Color = bgColor
            end
        end
        
        if textColor then
            Tag.TextColor3 = textColor
            tagObj.TextColor = textColor
        end
        
        if useNeonEffect ~= nil then
            tagObj:SetNeonEffect(useNeonEffect)
        end
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
    
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1
        
        -- 创建侧边栏按钮
        local sidebar2 = Instance.new("TextButton")
        sidebar2.Name = "sidebar2_" .. name
        sidebar2.Parent = sidebar
        sidebar2.BackgroundColor3 = config.AccentColor
        sidebar2.BackgroundTransparency = 1
        sidebar2.Size = UDim2.new(0, SIDEBAR_WIDTH - 7, 0, isMobile and 28 or 37)
        sidebar2.ZIndex = 10 -- 提高ZIndex确保按钮在最前面
        sidebar2.AutoButtonColor = false
        sidebar2.Font = Enum.Font.Gotham
        sidebar2.Text = name
        sidebar2.TextColor3 = config.TextColor
        sidebar2.TextSize = isMobile and 16 or 21
        
        -- 添加一个透明的背景框确保点击区域
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
        
        -- 为这个标签页创建工作区 - 直接放在workarea下
        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain_" .. name
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        -- 调整位置，为搜索框留出空间
        workareamain.Position = UDim2.new(0.0393013097, 0, isMobile and 0.15 or 0.12, 0)
        workareamain.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 220 or 512)
        workareamain.ZIndex = 3
        workareamain.CanvasSize = UDim2.new(0, 0, 0, 0)
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = false
        workareamain.ScrollingEnabled = true
        
        -- 创建主容器
        local MainContainer = Instance.new("Frame")
        MainContainer.Name = "MainContainer"
        MainContainer.Parent = workareamain
        MainContainer.BackgroundTransparency = 1
        MainContainer.Size = UDim2.new(1, 0, 0, 0)
        
        local workarealayout = Instance.new("UIListLayout")
        workarealayout.Parent = MainContainer
        workarealayout.SortOrder = Enum.SortOrder.LayoutOrder
        workarealayout.Padding = UDim.new(0, 10)
        
        -- 自动调整容器大小
        workarealayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            MainContainer.Size = UDim2.new(1, 0, 0, workarealayout.AbsoluteContentSize.Y)
            workareamain.CanvasSize = UDim2.new(0, 0, 0, workarealayout.AbsoluteContentSize.Y + 20)
        end)
        
        table.insert(workareas, workareamain)
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            -- 简化参数处理
            local open = TabVal
            if open == nil then
                open = true  -- 默认展开
            end
            
            local section = {}
            
            -- 创建Section主容器
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "Section_" .. name
            SectionContainer.Parent = MainContainer
            SectionContainer.BackgroundTransparency = 1
            SectionContainer.Size = UDim2.new(1, 0, 0, 0)
            
            -- Section标题
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = SectionContainer
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, isMobile and 40 or 50)
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Size = UDim2.new(0.8, 0, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.AccentColor
            SectionTitle.TextSize = isMobile and 18 or 22
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 展开/折叠按钮
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = SectionHeader
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Position = UDim2.new(0.85, 0, 0, 0)
            ToggleButton.Size = UDim2.new(0.15, 0, 1, 0)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.Text = open and "▲" or "▼"
            ToggleButton.TextColor3 = config.AccentColor
            ToggleButton.TextSize = isMobile and 16 or 20
            
            -- Section内容区域
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = SectionContainer
            SectionContent.BackgroundTransparency = 1
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Visible = open
            
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Parent = SectionContent
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 8)
            
            -- 更新Section高度
            local function updateSectionHeight()
                if open then
                    ToggleButton.Text = "▲"
                    SectionContent.Visible = true
                    local contentHeight = ContentLayout.AbsoluteContentSize.Y
                    SectionContent.Size = UDim2.new(1, 0, 0, contentHeight)
                else
                    ToggleButton.Text = "▼"
                    SectionContent.Visible = false
                    SectionContent.Size = UDim2.new(1, 0, 0, 0)
                end
                local sectionHeight = SectionHeader.AbsoluteSize.Y + (open and ContentLayout.AbsoluteContentSize.Y or 0)
                SectionContainer.Size = UDim2.new(1, 0, 0, sectionHeight)
            end
            
            -- 监听内容变化
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
            end)
            
            -- 初始更新高度
            updateSectionHeight()
            
            -- 切换展开/折叠
            ToggleButton.MouseButton1Click:Connect(function()
                open = not open
                updateSectionHeight()
            end)
            
            -- 功能函数
            function section.Button(section, text, callback)
                local button = Instance.new("TextButton")
                button.Name = "button_" .. text
                button.Text = text
                button.Parent = SectionContent
                button.BackgroundColor3 = config.Button_Color
                button.BackgroundTransparency = 0.2
                button.Size = UDim2.new(1, 0, 0, isMobile and 32 or 40)
                button.Font = Enum.Font.Gotham
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
                    button.MouseButton1Click:Connect(function() 
                        callback()
                    end)
                end
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
                return button
            end
            
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = SectionContent
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(1, 0, 0, sizeY or (isMobile and 100 or 120))
                
                local ImageLabel = Instance.new("ImageLabel")
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
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
                
                local imageController = {}
                
                function imageController:SetImage(newSource)
                    setImage(newSource)
                end
                
                function imageController:Destroy()
                    ImageModule:Destroy()
                end
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
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
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
                return label
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
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
                
                local ToggleButton = Instance.new("Frame")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = ToggleContainer
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Position = UDim2.new(0.7, 0, 0, 0)
                ToggleButton.Size = UDim2.new(0.3, 0, 1, 0)
                
                local SwitchFrame = Instance.new("TextButton")
                SwitchFrame.Parent = ToggleButton
                SwitchFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                SwitchFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                SwitchFrame.Size = UDim2.new(0, isMobile and 50 or 60, 0, isMobile and 24 or 28)
                SwitchFrame.Text=""
                SwitchFrame.AutoButtonColor = false

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchFrame

                local SwitchButton = Instance.new("TextButton")
                SwitchButton.Parent = SwitchFrame
                SwitchButton.AnchorPoint = Vector2.new(0.5, 0.5)
                SwitchButton.Position = UDim2.new(0.5, 0, 0.5, 0)
                SwitchButton.Size = UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24)
                SwitchButton.AutoButtonColor = false
                SwitchButton.Text = ""

                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(1, 0)
                ButtonCorner.Parent = SwitchButton

                if enabled == false then
                    SwitchButton.Position = UDim2.new(0.25, 0, 0.5, 0)
                    SwitchFrame.BackgroundColor3 = config.Toggle_Off
                else
                    SwitchButton.Position = UDim2.new(0.75, 0, 0.5, 0)
                    SwitchFrame.BackgroundColor3 = config.Toggle_On
                end
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengUI.flags[flag]
                        end
                        if FengUI.flags[flag] == state then
                            return
                        end
                        
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
                
                SwitchFrame.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                
                SwitchButton.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
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
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
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
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
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
                
                services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        funcs:SetValue()
                    end
                end)
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
                return funcs
            end
            
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
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
                
                local funcs = {}
                
                funcs.AddOption = function(self, optionText)
                    table.insert(allOptions, optionText)
                end
                
                funcs.SetOptions = function(self, newOptions)
                    allOptions = newOptions or {}
                end
                
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
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
                return funcs
            end
            
            -- 颜色选择器功能
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
                
                -- 延迟更新高度
                task.wait(0.05)
                updateSectionHeight()
                
                return funcs
            end
            
            return section
        end

        -- 标签选择功能
        sidebar2.MouseButton1Click:Connect(function()
            switchTab({sidebar2, workareamain})
        end)
        
        -- 默认选择第一个标签
        if #sections == 1 then
            sidebar2.BackgroundTransparency = 0
            sidebar2.TextColor3 = Color3.fromRGB(255, 255, 255)
            workareamain.Visible = true
            FengUI.currentTab = {sidebar2, workareamain}
        end

        return tab
    end
    
    function window:DualTab(name, icon)
        if type(icon) == "number" then
            icon = tostring(icon)
        end
        
        return window:Tab(name, icon, 2)
    end

    return window
end

-- 颜色选择器相关功能
FengUI.ColorPickers = {}

function FengUI:CreateColorPicker(options)
    -- 这是一个简化版本的颜色选择器
    -- 完整的颜色选择器实现需要更多代码
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
    PopupStroke.Color = config.AccentColor
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