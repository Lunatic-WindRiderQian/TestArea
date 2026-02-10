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

-- 配置颜色（使用iOS风格）
local config = {
    MainColor = Color3.fromRGB(255, 255, 255),
    TabColor = Color3.fromRGB(245, 245, 247),
    Bg_Color = Color3.fromRGB(245, 245, 247),
    Zy_Color = Color3.fromRGB(245, 245, 247),
    Button_Color = Color3.fromRGB(0, 122, 255),
    Textbox_Color = Color3.fromRGB(245, 245, 247),
    Dropdown_Color = Color3.fromRGB(245, 245, 247),
    Keybind_Color = Color3.fromRGB(245, 245, 247),
    Label_Color = Color3.fromRGB(245, 245, 247),
    Slider_Color = Color3.fromRGB(245, 245, 247),
    SliderBar_Color = Color3.fromRGB(0, 122, 255),
    Toggle_Color = Color3.fromRGB(245, 245, 247),
    Toggle_Off = Color3.fromRGB(199, 199, 204),
    Toggle_On = Color3.fromRGB(0, 122, 255),
    AccentColor = Color3.fromRGB(0, 122, 255),
    TextColor = Color3.fromRGB(0, 0, 0),
    SecondaryTextColor = Color3.fromRGB(142, 142, 147),
    GlowColor = Color3.fromRGB(0, 122, 255),
    
    ElementTransparency = 0,
    GlassEffect = Color3.fromRGB(255, 255, 255),
}

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
Open.BackgroundTransparency = 0.1
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 40, 0, 40)
Open.Active = true
Open.Draggable = true
Open.Image = ""
Open.ImageTransparency = 1

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
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
main.BackgroundTransparency = 0
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
search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
SidebarTitle.TextColor3 = config.TextColor
SidebarTitle.TextSize = isMobile and 18 or 24
SidebarTitle.TextWrapped = true
SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
SidebarTitle.TextYAlignment = Enum.TextYAlignment.Center

-- 侧边栏按钮容器
local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "sidebar"
sidebar.Parent = main
sidebar.Active = true
sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.new(0.0249653254, 0, 0.20, 0) -- 在标题下方
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

-- Tab主区域
local TabMain = Instance.new("ScrollingFrame")
TabMain.Name = "workareamain"
TabMain.Parent = workarea
TabMain.Active = true
TabMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TabMain.BackgroundTransparency = 1
TabMain.BorderSizePixel = 0
-- 调整位置，为搜索框留出空间
TabMain.Position = UDim2.new(0.0393013097, 0, isMobile and 0.15 or 0.12, 0)
TabMain.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 220 or 512)
TabMain.ZIndex = 3
TabMain.CanvasSize = UDim2.new(0, 0, 0, 0)
TabMain.ScrollBarThickness = 2
TabMain.Visible = false

local ull = Instance.new("UIListLayout")
ull.Parent = TabMain
ull.HorizontalAlignment = Enum.HorizontalAlignment.Center
ull.SortOrder = Enum.SortOrder.LayoutOrder
ull.Padding = UDim.new(0, 5)

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
-- 万能UI界面代码结束
-- 以下是苹果.lua的API功能代码
-- =========================================

-- 修复section重叠问题的函数
local function setupSmoothScrolling(scrollingFrame, layout)
    if not layout then return end
    
    local function updateScrolling()
        if not scrollingFrame or not scrollingFrame.Parent then return end
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        
        if layout.AbsoluteContentSize.Y <= scrollingFrame.AbsoluteSize.Y then
            scrollingFrame.ScrollingEnabled = false
        else
            scrollingFrame.ScrollingEnabled = true
        end
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrolling)
    
    -- 初始更新
    task.wait(0.1)
    updateScrolling()
    
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

-- 标签功能
local function UpdateTagContainerPosition()
    -- 测试UI版本没有标签容器，所以留空
end

function FengUI.new(name, theme)
    -- 设置脚本名字
    if name then
        SidebarTitle.Text = name
    else
        SidebarTitle.Text = "FengUI"
    end
    
    local window = {
        tabs = {},
        currentTab = nil,
        tags = {},
        tagObjects = {},
        tagCount = 0,
        maxTags = 3
    }
    
    -- 标签功能（简化版）
    function window:AddTag(text, bgColor, textColor)
        if self.tagCount >= self.maxTags then
            return nil
        end
        
        bgColor = bgColor or Color3.fromRGB(60, 60, 80)
        textColor = textColor or Color3.fromRGB(240, 245, 255)
        
        -- 这个版本的UI没有标签功能，只返回一个空对象
        local tagObj = {
            Text = text,
            Color = bgColor,
            TextColor = textColor,
            UseNeonEffect = false,
            
            Destroy = function()
                -- 空实现
            end,
            
            Update = function(newText, newBgColor, newTextColor, newUseNeonEffect)
                -- 空实现
            end,
            
            SetNeonEffect = function(selfObj, enabled)
                -- 空实现
            end,
            
            SetColor = function(selfObj, newColor)
                -- 空实现
            end
        }
        
        table.insert(self.tags, text)
        table.insert(self.tagObjects, tagObj)
        self.tagCount = self.tagCount + 1
        
        return tagObj
    end
    
    function window:UpdateTag(index, text, bgColor, textColor, useNeonEffect)
        if index < 1 or index > #self.tagObjects then return end
        -- 空实现
    end
    
    function window:ClearTags()
        self.tags = {}
        self.tagObjects = {}
        self.tagCount = 0
    end
    
    function window:RemoveTag(index)
        if index < 1 or index > #self.tagObjects then return end
        table.remove(self.tags, index)
        table.remove(self.tagObjects, index)
        self.tagCount = self.tagCount - 1
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
        
        -- 为这个标签页创建工作区
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
        
        local workarealayout = Instance.new("UIListLayout")
        workarealayout.Parent = workareamain
        workarealayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        workarealayout.SortOrder = Enum.SortOrder.LayoutOrder
        workarealayout.Padding = UDim.new(0, 5)
        
        table.insert(workareas, workareamain)
        
        -- 设置平滑滚动
        setupSmoothScrolling(workareamain, workarealayout)
        
        local tab = {}
        
        function tab.section(tab, name, windowPosition, TabVal)
            if type(windowPosition) == "boolean" then
                TabVal = windowPosition
                windowPosition = "Left"
            elseif not windowPosition or type(windowPosition) ~= "string" then
                windowPosition = "Left"
            end
            
            local section = {}
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "section_" .. name
            sectionFrame.Parent = workareamain
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, 0)
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Parent = sectionFrame
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, isMobile and 4 or 8)
            
            -- 分隔符标题
            local sectionDivider = Instance.new("TextLabel")
            sectionDivider.Name = "sectionDivider"
            sectionDivider.Parent = sectionFrame
            sectionDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionDivider.BackgroundTransparency = 1
            sectionDivider.BorderSizePixel = 2
            sectionDivider.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 30 or 50)
            sectionDivider.Font = Enum.Font.Gotham
            sectionDivider.LineHeight = 1.180
            sectionDivider.Text = name
            sectionDivider.TextColor3 = config.TextColor
            sectionDivider.TextSize = isMobile and 18 or 25
            sectionDivider.TextWrapped = true
            sectionDivider.TextXAlignment = Enum.TextXAlignment.Left
            sectionDivider.TextYAlignment = Enum.TextYAlignment.Bottom
            
            -- 动态更新section高度
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, sectionLayout.AbsoluteContentSize.Y)
            end)
            
            function section.Button(section, text, callback)
                local button = Instance.new("TextButton")
                button.Name = "button_" .. text
                button.Text = text
                button.Parent = sectionFrame
                button.BackgroundColor3 = config.Button_Color
                button.BackgroundTransparency = 0.8
                button.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                button.ZIndex = 2
                button.Font = Enum.Font.Gotham
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = isMobile and 16 or 21

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 9)
                buttonCorner.Parent = button

                local buttonStroke = Instance.new("UIStroke", button)
                buttonStroke.ApplyStrokeMode = "Border"
                buttonStroke.Color = config.Button_Color
                buttonStroke.Thickness = 1
                buttonStroke.Transparency = 0.5

                -- 添加悬停效果
                button.MouseEnter:Connect(function()
                    services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.7,
                        Size = UDim2.new(0, WORKAREA_WIDTH - 36 - 5, 0, isMobile and 28 or 37)
                    }):Play()
                end)
                
                button.MouseLeave:Connect(function()
                    services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.8,
                        Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                    }):Play()
                end)

                if callback then
                    button.MouseButton1Click:Connect(function() 
                        -- 点击动画
                        services.TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.5,
                            Size = UDim2.new(0, WORKAREA_WIDTH - 36 - 10, 0, isMobile and 28 or 37)
                        }):Play()
                        task.wait(0.1)
                        services.TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                            BackgroundTransparency = 0.8,
                            Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                        }):Play()
                        
                        -- 执行回调
                        callback()
                    end)
                end
                return button
            end
            
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = sectionFrame
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, sizeY or (isMobile and 80 or 100))
                
                local ImageLabel = Instance.new("ImageLabel")
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or (WORKAREA_WIDTH - 56), WORKAREA_WIDTH - 56), 0, sizeY or (isMobile and 80 or 100))
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
                
                return imageController
            end
            
            function section:Label(text)
                local label = Instance.new("TextLabel")
                label.Name = "label_" .. text
                label.Parent = sectionFrame
                label.BackgroundColor3 = config.Label_Color
                label.BackgroundTransparency = 0.5
                label.BorderSizePixel = 0
                label.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                label.Font = Enum.Font.Gotham
                label.TextColor3 = config.TextColor
                label.TextSize = isMobile and 16 or 21
                label.TextWrapped = true
                label.Text = text
                
                local labelCorner = Instance.new("UICorner")
                labelCorner.CornerRadius = UDim.new(0, 6)
                labelCorner.Parent = label
                
                return label
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = enabled
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "toggle_" .. flag
                toggleFrame.Parent = sectionFrame
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 40 or 50)
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "toggleLabel"
                toggleLabel.Parent = toggleFrame
                toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.BorderSizePixel = 2
                toggleLabel.Position = UDim2.new(0, 0, 0, 0)
                toggleLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.Text = text
                toggleLabel.TextColor3 = config.TextColor
                toggleLabel.TextSize = isMobile and 16 or 21
                toggleLabel.TextWrapped = true
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleSwitch = Instance.new("Frame")
                toggleSwitch.Name = "toggleSwitch"
                toggleSwitch.Parent = toggleFrame
                toggleSwitch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleSwitch.BackgroundTransparency = 1
                toggleSwitch.BorderSizePixel = 2
                toggleSwitch.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0, 0)
                toggleSwitch.Size = UDim2.new(0, isMobile and 90 or 118, 0, isMobile and 28 or 37)
                
                local switchFrame = Instance.new("TextButton")
                switchFrame.Parent = toggleSwitch
                switchFrame.Position = UDim2.new(0.832535863, 0, 0.0270270277, 0)
                switchFrame.Size = UDim2.new(0, isMobile and 50 or 70, 0, isMobile and 26 or 36)
                switchFrame.Text=""
                switchFrame.AutoButtonColor = false
                switchFrame.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off

                local switchCorner = Instance.new("UICorner")
                switchCorner.CornerRadius = UDim.new(5, 0)
                switchCorner.Parent = switchFrame

                local switchButton = Instance.new("TextButton")
                switchButton.Parent = switchFrame
                switchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                switchButton.Size = UDim2.new(0, isMobile and 24 or 34, 0, isMobile and 24 or 34)
                switchButton.AutoButtonColor = false
                switchButton.Text = ""

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(5, 0)
                buttonCorner.Parent = switchButton

                if enabled == false then
                    switchButton.Position = UDim2.new(0, 1, 0, 1)
                    switchFrame.BackgroundColor3 = config.Toggle_Off
                else
                    switchButton.Position = UDim2.new(0, isMobile and 25 or 35, 0, 1)
                    switchFrame.BackgroundColor3 = config.Toggle_On
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
                            services.TweenService:Create(switchButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Position = UDim2.new(0, isMobile and 25 or 35, 0, 1)
                            }):Play()
                            services.TweenService:Create(switchFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = config.Toggle_On
                            }):Play()
                        else
                            services.TweenService:Create(switchButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Position = UDim2.new(0, 1, 0, 1)
                            }):Play()
                            services.TweenService:Create(switchFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = config.Toggle_Off
                            }):Play()
                        end
                        
                        callback(state)
                    end,
                    Module = toggleFrame
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                switchFrame.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                
                switchButton.MouseButton1Click:Connect(function()
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
                
                local keybindFrame = Instance.new("Frame")
                keybindFrame.Name = "keybind_" .. text
                keybindFrame.Parent = sectionFrame
                keybindFrame.BackgroundTransparency = 1
                keybindFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 40 or 50)
                
                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Name = "keybindLabel"
                keybindLabel.Parent = keybindFrame
                keybindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.BorderSizePixel = 2
                keybindLabel.Position = UDim2.new(0, 0, 0, 0)
                keybindLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                keybindLabel.Font = Enum.Font.Gotham
                keybindLabel.Text = text
                keybindLabel.TextColor3 = config.TextColor
                keybindLabel.TextSize = isMobile and 16 or 21
                keybindLabel.TextWrapped = true
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local keybindButton = Instance.new("TextButton")
                keybindButton.Name = "keybindButton"
                keybindButton.Parent = keybindFrame
                keybindButton.BackgroundColor3 = config.Keybind_Color
                keybindButton.BackgroundTransparency = 0.2
                keybindButton.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                keybindButton.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 26 or 34)
                keybindButton.Font = Enum.Font.Gotham
                keybindButton.Text = keyTxt
                keybindButton.TextColor3 = config.TextColor
                keybindButton.TextSize = isMobile and 14 or 18
                
                local keybindCorner = Instance.new("UICorner")
                keybindCorner.CornerRadius = UDim.new(0, 9)
                keybindCorner.Parent = keybindButton
                
                -- 添加悬停效果
                keybindButton.MouseEnter:Connect(function()
                    services.TweenService:Create(keybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                keybindButton.MouseLeave:Connect(function()
                    services.TweenService:Create(keybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.2
                    }):Play()
                end)
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                keybindButton.MouseButton1Click:Connect(function()
                    keybindButton.Text = "..."
                    keybindButton.BackgroundColor3 = config.AccentColor
                    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    
                    task.wait()
                    
                    local key = UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        keybindButton.Text = keyTxt
                        keybindButton.BackgroundColor3 = config.Keybind_Color
                        keybindButton.TextColor3 = config.TextColor
                        return
                    end
                    
                    if banned[keyName] then
                        keybindButton.Text = keyTxt
                        keybindButton.BackgroundColor3 = config.Keybind_Color
                        keybindButton.TextColor3 = config.TextColor
                        return
                    end
                    
                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    keyTxt = shortNames[keyName] or keyName
                    keybindButton.Text = keyTxt
                    keybindButton.BackgroundColor3 = config.Keybind_Color
                    keybindButton.TextColor3 = config.TextColor
                end)
            end
            
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                
                FengUI.flags[flag] = default
                
                local textboxFrame = Instance.new("Frame")
                textboxFrame.Name = "textbox_" .. flag
                textboxFrame.Parent = sectionFrame
                textboxFrame.BackgroundTransparency = 1
                textboxFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 60 or 70)
                
                local textboxLabel = Instance.new("TextLabel")
                textboxLabel.Name = "textboxLabel"
                textboxLabel.Parent = textboxFrame
                textboxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textboxLabel.BackgroundTransparency = 1
                textboxLabel.BorderSizePixel = 2
                textboxLabel.Position = UDim2.new(0, 0, 0, 0)
                textboxLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                textboxLabel.Font = Enum.Font.Gotham
                textboxLabel.Text = text
                textboxLabel.TextColor3 = config.TextColor
                textboxLabel.TextSize = isMobile and 16 or 21
                textboxLabel.TextWrapped = true
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local textboxInput = Instance.new("Frame")
                textboxInput.Parent = textboxFrame
                textboxInput.BackgroundColor3 = config.Textbox_Color
                textboxInput.BackgroundTransparency = 0.2
                textboxInput.Position = UDim2.new(0, 0, 0.5, 0)
                textboxInput.Size = UDim2.new(1, 0, 0, isMobile and 26 or 34)

                local textboxCorner = Instance.new("UICorner")
                textboxCorner.CornerRadius = UDim.new(0, 9)
                textboxCorner.Parent = textboxInput

                local textbox = Instance.new("TextBox")
                textbox.Parent = textboxInput
                textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textbox.BackgroundTransparency = 1
                textbox.BorderColor3 = Color3.fromRGB(27, 42, 53)
                textbox.BorderSizePixel = 0
                textbox.ClipsDescendants = true
                textbox.Position = UDim2.new(0.0643776804, 0, 0, -2)
                textbox.Size = UDim2.new(0, WORKAREA_WIDTH - 76, 0, isMobile and 26 or 34)
                textbox.ClearTextOnFocus = false
                textbox.Font = Enum.Font.Gotham
                textbox.LineHeight = 0.870
                textbox.PlaceholderColor3 = config.SecondaryTextColor
                textbox.PlaceholderText = "Type..."
                textbox.Text = default
                textbox.TextColor3 = config.TextColor
                textbox.TextSize = isMobile and 16 or 21
                textbox.TextXAlignment = Enum.TextXAlignment.Left

                -- 添加悬停效果
                textboxInput.MouseEnter:Connect(function()
                    services.TweenService:Create(textboxInput, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                textboxInput.MouseLeave:Connect(function()
                    services.TweenService:Create(textboxInput, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.2
                    }):Play()
                end)

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

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "slider_" .. flag
                sliderFrame.Parent = sectionFrame
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 70 or 80)
                
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Name = "sliderLabel"
                sliderLabel.Parent = sliderFrame
                sliderLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.BorderSizePixel = 2
                sliderLabel.Position = UDim2.new(0, 0, 0, 0)
                sliderLabel.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.Text = text .. ": " .. tostring(default)
                sliderLabel.TextColor3 = config.TextColor
                sliderLabel.TextSize = isMobile and 16 or 21
                sliderLabel.TextWrapped = true
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local sliderBar = Instance.new("Frame")
                sliderBar.Name = "sliderBar"
                sliderBar.Parent = sliderFrame
                sliderBar.BackgroundColor3 = Color3.fromRGB(225, 225, 230)
                sliderBar.BorderSizePixel = 0
                sliderBar.Position = UDim2.new(0, 0, 0.6, 0)
                sliderBar.Size = UDim2.new(1, 0, 0, 5)
                
                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(1, 0)
                sliderBarCorner.Parent = sliderBar
                
                local sliderPart = Instance.new("Frame")
                sliderPart.Name = "sliderPart"
                sliderPart.Parent = sliderBar
                sliderPart.BackgroundColor3 = config.SliderBar_Color
                sliderPart.BorderSizePixel = 0
                sliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                local sliderPartCorner = Instance.new("UICorner")
                sliderPartCorner.CornerRadius = UDim.new(1, 0)
                sliderPartCorner.Parent = sliderPart
                
                local funcs = {
                    SetValue = function(self, value)
                        local percent
                        
                        if value then
                            percent = (value - min)/(max - min)
                        else
                            local mouse = services.Players.LocalPlayer:GetMouse()
                            local barPos = sliderBar.AbsolutePosition.X
                            local barSize = sliderBar.AbsoluteSize.X
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
                        sliderLabel.Text = text .. ": " .. tostring(value)
                        
                        services.TweenService:Create(sliderPart, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
                
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        funcs:SetValue()
                    end
                end)
                
                sliderPart.InputBegan:Connect(function(input)
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
                
                return funcs
            end
            
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = nil
                
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Name = "dropdown_" .. flag
                dropdownFrame.Parent = sectionFrame
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 70 or 80)
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "dropdownLabel"
                dropdownLabel.Parent = dropdownFrame
                dropdownLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.BorderSizePixel = 2
                dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                dropdownLabel.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.Text = text
                dropdownLabel.TextColor3 = config.TextColor
                dropdownLabel.TextSize = isMobile and 16 or 21
                dropdownLabel.TextWrapped = true
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "dropdownButton"
                dropdownButton.Parent = dropdownFrame
                dropdownButton.BackgroundColor3 = config.Dropdown_Color
                dropdownButton.BackgroundTransparency = 0.2
                dropdownButton.Position = UDim2.new(0, 0, 0.5, 0)
                dropdownButton.Size = UDim2.new(1, 0, 0, isMobile and 26 or 34)
                dropdownButton.Font = Enum.Font.Gotham
                dropdownButton.Text = "Select..."
                dropdownButton.TextColor3 = config.TextColor
                dropdownButton.TextSize = isMobile and 14 or 18
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 9)
                dropdownCorner.Parent = dropdownButton
                
                -- 添加悬停效果
                dropdownButton.MouseEnter:Connect(function()
                    services.TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                dropdownButton.MouseLeave:Connect(function()
                    services.TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.2
                    }):Play()
                end)
                
                local allOptions = {}
                local selectedOption = nil
                
                local funcs = {}
                
                funcs.AddOption = function(self, optionText)
                    table.insert(allOptions, optionText)
                end
                
                funcs.SetOptions = function(self, newOptions)
                    allOptions = newOptions or {}
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    -- 这里需要实现下拉菜单的展开逻辑
                    -- 由于万能UI没有内置下拉菜单，我们可以使用一个简单的文本选择
                    if #allOptions > 0 then
                        selectedOption = allOptions[1]
                        dropdownButton.Text = selectedOption
                        callback(selectedOption)
                        FengUI.flags[flag] = selectedOption
                    end
                end)
                
                funcs:SetOptions(options)
                
                if #options > 0 then
                    selectedOption = options[1]
                    dropdownButton.Text = selectedOption
                    FengUI.flags[flag] = selectedOption
                end
                
                return funcs
            end
            
            -- 添加颜色选择器功能
            function section.ColorPicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                FengUI.flags[flag] = defaultColor
                
                local colorPickerFrame = Instance.new("Frame")
                colorPickerFrame.Name = "colorpicker_" .. flag
                colorPickerFrame.Parent = sectionFrame
                colorPickerFrame.BackgroundTransparency = 1
                colorPickerFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 40 or 50)
                
                local colorPickerLabel = Instance.new("TextLabel")
                colorPickerLabel.Name = "colorPickerLabel"
                colorPickerLabel.Parent = colorPickerFrame
                colorPickerLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorPickerLabel.BackgroundTransparency = 1
                colorPickerLabel.BorderSizePixel = 2
                colorPickerLabel.Position = UDim2.new(0, 0, 0, 0)
                colorPickerLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                colorPickerLabel.Font = Enum.Font.Gotham
                colorPickerLabel.Text = text
                colorPickerLabel.TextColor3 = config.TextColor
                colorPickerLabel.TextSize = isMobile and 16 or 21
                colorPickerLabel.TextWrapped = true
                colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local colorPreview = Instance.new("TextButton")
                colorPreview.Name = "colorPreview"
                colorPreview.Parent = colorPickerFrame
                colorPreview.BackgroundColor3 = defaultColor
                colorPreview.BackgroundTransparency = 0
                colorPreview.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                colorPreview.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 26 or 34)
                colorPreview.Font = Enum.Font.Gotham
                colorPreview.Text = ""
                colorPreview.TextColor3 = Color3.fromRGB(255, 255, 255)
                colorPreview.TextSize = isMobile and 14 or 18
                
                local colorPreviewCorner = Instance.new("UICorner")
                colorPreviewCorner.CornerRadius = UDim.new(0, 9)
                colorPreviewCorner.Parent = colorPreview
                
                local colorStroke = Instance.new("UIStroke", colorPreview)
                colorStroke.Color = Color3.fromRGB(200, 200, 200)
                colorStroke.Thickness = 1
                
                -- 添加悬停效果
                colorPreview.MouseEnter:Connect(function()
                    services.TweenService:Create(colorPreview, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, isMobile and 85 or 105, 0, isMobile and 28 or 36)
                    }):Play()
                end)
                
                colorPreview.MouseLeave:Connect(function()
                    services.TweenService:Create(colorPreview, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 26 or 34)
                    }):Play()
                end)
                
                local funcs = {}
                
                funcs.SetColor = function(self, color)
                    if typeof(color) == "Color3" then
                        colorPreview.BackgroundColor3 = color
                        FengUI.flags[flag] = color
                        callback(color)
                    end
                end
                
                funcs.GetColor = function(self)
                    return FengUI.flags[flag] or defaultColor
                end
                
                -- 简单的点击选择颜色（在实际使用中，这里应该打开一个颜色选择器对话框）
                colorPreview.MouseButton1Click:Connect(function()
                    -- 这里可以打开一个颜色选择器
                    -- 由于测试UI版本没有内置颜色选择器，我们只切换几个预设颜色
                    local colors = {
                        Color3.fromRGB(255, 59, 48),  -- 红色
                        Color3.fromRGB(255, 149, 0),  -- 橙色
                        Color3.fromRGB(255, 204, 0),  -- 黄色
                        Color3.fromRGB(52, 199, 89),  -- 绿色
                        Color3.fromRGB(0, 122, 255),  -- 蓝色
                        Color3.fromRGB(88, 86, 214),  -- 紫色
                    }
                    
                    local currentColor = FengUI.flags[flag] or defaultColor
                    local found = false
                    
                    for i, color in ipairs(colors) do
                        if currentColor == color then
                            if i < #colors then
                                funcs:SetColor(colors[i + 1])
                            else
                                funcs:SetColor(colors[1])
                            end
                            found = true
                            break
                        end
                    end
                    
                    if not found then
                        funcs:SetColor(colors[1])
                    end
                end)
                
                return funcs
            end
            
            return section
        end

        -- 标签选择功能
        sidebar2.MouseButton1Click:Connect(function()
            for b, v in next, sections do
                v.BackgroundTransparency = 1
                v.TextColor3 = config.TextColor
            end
            sidebar2.BackgroundTransparency = 0
            sidebar2.TextColor3 = Color3.fromRGB(255, 255, 255)
            for b, v in next, workareas do
                v.Visible = false
            end
            workareamain.Visible = true
        end)
        
        -- 默认选择第一个标签
        if #sections == 1 then
            sidebar2.BackgroundTransparency = 0
            sidebar2.TextColor3 = Color3.fromRGB(255, 255, 255)
            workareamain.Visible = true
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

function UiDestroy()
    if FengYu then
        FengYu:Destroy()
    end
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    main.Visible = ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI