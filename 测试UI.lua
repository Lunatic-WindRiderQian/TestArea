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
Open.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
Open.BackgroundTransparency = 0
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
main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
main.BackgroundTransparency = 0.150
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
workarea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
workarea.Position = UDim2.new(0.36403501, 0, 0, 0)
workarea.Size = UDim2.new(0, WORKAREA_WIDTH, 0, WORKAREA_HEIGHT)

local uc_2 = Instance.new("UICorner")
uc_2.CornerRadius = UDim.new(0, 18)
uc_2.Parent = workarea

local workareacornerhider = Instance.new("Frame")
workareacornerhider.Name = "workareacornerhider"
workareacornerhider.Parent = workarea
workareacornerhider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
searchicon.ImageColor3 = Color3.fromRGB(95, 95, 95)
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
searchtextbox.TextColor3 = Color3.fromRGB(95, 95, 95)
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
SidebarTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
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

function FengUI.new(name, theme)
    -- 设置脚本名字
    if name then
        SidebarTitle.Text = name
    else
        SidebarTitle.Text = "FengUI"
    end
    
    local window = {
        tabs = {},
        currentTab = nil
    }
    
    function window:AddTag(text, bgColor, textColor)
        -- 这个版本的UI没有标签功能
        warn("测试UI版本不支持标签功能")
        return nil
    end
    
    function window:UpdateTag(index, text, bgColor, textColor)
        -- 这个版本的UI没有标签功能
        warn("测试UI版本不支持标签功能")
    end
    
    function window:ClearTags()
        -- 这个版本的UI没有标签功能
        warn("测试UI版本不支持标签功能")
    end
    
    function window:RemoveTag(index)
        -- 这个版本的UI没有标签功能
        warn("测试UI版本不支持标签功能")
    end
    
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1
        
        -- 创建侧边栏按钮
        local sidebar2 = Instance.new("TextButton")
        sidebar2.Name = "sidebar2_" .. name
        sidebar2.Parent = sidebar
        sidebar2.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
        sidebar2.BackgroundTransparency = 1
        sidebar2.Size = UDim2.new(0, SIDEBAR_WIDTH - 7, 0, isMobile and 28 or 37)
        sidebar2.ZIndex = 10 -- 提高ZIndex确保按钮在最前面
        sidebar2.AutoButtonColor = false
        sidebar2.Font = Enum.Font.Gotham
        sidebar2.Text = name
        sidebar2.TextColor3 = Color3.fromRGB(0, 0, 0)
        sidebar2.TextSize = isMobile and 16 or 21
        
        -- 添加一个透明的背景框确保点击区域
        local buttonBackground = Instance.new("Frame")
        buttonBackground.Name = "buttonBackground"
        buttonBackground.Parent = sidebar2
        buttonBackground.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
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
        
        local tab = {}
        
        function tab.section(tab, name, icon, defaultOpen)
            -- 参数说明：
            -- name: section名称
            -- icon: 图标ID（数字或字符串），如果为nil则使用默认图标
            -- defaultOpen: 默认是否展开（true/false），默认为true
            local defaultOpen = defaultOpen == nil and true or defaultOpen
            
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
            
            -- 创建一个容器用于存放标题和图标
            local headerContainer = Instance.new("Frame")
            headerContainer.Name = "headerContainer"
            headerContainer.Parent = sectionFrame
            headerContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            headerContainer.BackgroundTransparency = 1
            headerContainer.BorderSizePixel = 0
            headerContainer.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 40 or 50)
            
            -- 图标按钮（用于展开/折叠）
            local iconButton = Instance.new("ImageButton")
            iconButton.Name = "iconButton"
            iconButton.Parent = headerContainer
            iconButton.BackgroundTransparency = 1
            iconButton.Position = UDim2.new(0, 0, 0, isMobile and 10 or 15)
            iconButton.Size = UDim2.new(0, isMobile and 20 or 25, 0, isMobile and 20 or 25)
            
            -- 设置图标
            if icon then
                local iconId = tostring(icon)
                if iconId:match("^%d+$") then
                    iconButton.Image = "rbxassetid://" .. iconId
                else
                    iconButton.Image = iconId
                end
            else
                -- 默认图标（向右的箭头）
                iconButton.Image = "rbxassetid://3926305904"
                iconButton.ImageRectOffset = Vector2.new(124, 364)
                iconButton.ImageRectSize = Vector2.new(36, 36)
            end
            
            iconButton.ImageColor3 = Color3.fromRGB(21, 103, 251)
            
            -- section标题
            local sectionDivider = Instance.new("TextLabel")
            sectionDivider.Name = "sectionDivider"
            sectionDivider.Parent = headerContainer
            sectionDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionDivider.BackgroundTransparency = 1
            sectionDivider.BorderSizePixel = 2
            sectionDivider.Position = UDim2.new(0, isMobile and 30 or 35, 0, 0)
            sectionDivider.Size = UDim2.new(0, WORKAREA_WIDTH - 36 - (isMobile and 30 or 35), 0, isMobile and 40 or 50)
            sectionDivider.Font = Enum.Font.Gotham
            sectionDivider.LineHeight = 1.180
            sectionDivider.Text = name
            sectionDivider.TextColor3 = Color3.fromRGB(0, 0, 0)
            sectionDivider.TextSize = isMobile and 18 or 25
            sectionDivider.TextWrapped = true
            sectionDivider.TextXAlignment = Enum.TextXAlignment.Left
            sectionDivider.TextYAlignment = Enum.TextYAlignment.Center
            
            -- 创建一个容器用于存放section内容
            local contentContainer = Instance.new("Frame")
            contentContainer.Name = "contentContainer"
            contentContainer.Parent = sectionFrame
            contentContainer.BackgroundTransparency = 1
            contentContainer.Size = UDim2.new(1, 0, 0, 0)
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Parent = contentContainer
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, isMobile and 4 or 8)
            
            -- 控制section的展开/折叠状态
            local isExpanded = defaultOpen
            contentContainer.Visible = isExpanded
            
            -- 更新图标旋转
            local function updateIconRotation()
                if isExpanded then
                    -- 展开时图标向下（默认是向右，这里旋转90度）
                    iconButton.Rotation = 90
                else
                    -- 折叠时图标向右
                    iconButton.Rotation = 0
                end
            end
            
            updateIconRotation()
            
            -- 点击图标展开/折叠
            iconButton.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                contentContainer.Visible = isExpanded
                updateIconRotation()
            end)
            
            -- 也可以点击标题展开/折叠
            sectionDivider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isExpanded = not isExpanded
                    contentContainer.Visible = isExpanded
                    updateIconRotation()
                end
            end)
            
            -- 修改所有内部函数，使其将元素添加到contentContainer而不是sectionFrame
            function section.Button(section, text, callback)
                local button = Instance.new("TextButton")
                button.Name = "button_" .. text
                button.Text = text
                button.Parent = contentContainer  -- 改为contentContainer
                button.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
                button.BackgroundTransparency = 1
                button.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                button.ZIndex = 2
                button.Font = Enum.Font.Gotham
                button.TextColor3 = Color3.fromRGB(21, 103, 251)
                button.TextSize = isMobile and 16 or 21

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 9)
                buttonCorner.Parent = button

                local buttonStroke = Instance.new("UIStroke", button)
                buttonStroke.ApplyStrokeMode = "Border"
                buttonStroke.Color = Color3.fromRGB(21, 103, 251)
                buttonStroke.Thickness = 1

                if callback then
                    button.MouseButton1Click:Connect(function() 
                        coroutine.wrap(function()
                            button.TextSize -= 3
                            task.wait(0.06)
                            button.TextSize += 3
                        end)()
                        callback()
                    end)
                end
                return button
            end
            
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = contentContainer  -- 改为contentContainer
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
                label.Parent = contentContainer  -- 改为contentContainer
                label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                label.BackgroundTransparency = 1
                label.BorderSizePixel = 2
                label.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                label.Font = Enum.Font.Gotham
                label.TextColor3 = Color3.fromRGB(95, 95, 95)
                label.TextSize = isMobile and 16 or 21
                label.TextWrapped = true
                label.Text = text
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
                toggleFrame.Parent = contentContainer  -- 改为contentContainer
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
                toggleLabel.TextColor3 = Color3.fromRGB(95, 95, 95)
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
                    switchFrame.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
                else
                    switchButton.Position = UDim2.new(0, isMobile and 25 or 35, 0, 1)
                    switchFrame.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
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
                            switchButton:TweenPosition(UDim2.new(0, isMobile and 25 or 35, 0, 1), "In", "Sine", 0.1, true)
                            switchFrame.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
                        else
                            switchButton:TweenPosition(UDim2.new(0,1,0,1), "In", "Sine", 0.1, true)
                            switchFrame.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
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
                keybindFrame.Parent = contentContainer  -- 改为contentContainer
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
                keybindLabel.TextColor3 = Color3.fromRGB(95, 95, 95)
                keybindLabel.TextSize = isMobile and 16 or 21
                keybindLabel.TextWrapped = true
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local keybindButton = Instance.new("TextButton")
                keybindButton.Name = "keybindButton"
                keybindButton.Parent = keybindFrame
                keybindButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                keybindButton.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                keybindButton.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 26 or 34)
                keybindButton.Font = Enum.Font.Gotham
                keybindButton.Text = keyTxt
                keybindButton.TextColor3 = Color3.fromRGB(12, 12, 12)
                keybindButton.TextSize = isMobile and 14 or 18
                
                local keybindCorner = Instance.new("UICorner")
                keybindCorner.CornerRadius = UDim.new(0, 9)
                keybindCorner.Parent = keybindButton
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                keybindButton.MouseButton1Click:Connect(function()
                    keybindButton.Text = "..."
                    keybindButton.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
                    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    
                    task.wait()
                    
                    local key = UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        keybindButton.Text = keyTxt
                        keybindButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                        keybindButton.TextColor3 = Color3.fromRGB(12, 12, 12)
                        return
                    end
                    
                    if banned[keyName] then
                        keybindButton.Text = keyTxt
                        keybindButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                        keybindButton.TextColor3 = Color3.fromRGB(12, 12, 12)
                        return
                    end
                    
                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    keyTxt = shortNames[keyName] or keyName
                    keybindButton.Text = keyTxt
                    keybindButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                    keybindButton.TextColor3 = Color3.fromRGB(12, 12, 12)
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
                textboxFrame.Parent = contentContainer  -- 改为contentContainer
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
                textboxLabel.TextColor3 = Color3.fromRGB(95, 95, 95)
                textboxLabel.TextSize = isMobile and 16 or 21
                textboxLabel.TextWrapped = true
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local textboxInput = Instance.new("Frame")
                textboxInput.Parent = textboxFrame
                textboxInput.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
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
                textbox.PlaceholderColor3 = Color3.fromRGB(113, 113, 113)
                textbox.PlaceholderText = "Type..."
                textbox.Text = default
                textbox.TextColor3 = Color3.fromRGB(12, 12, 12)
                textbox.TextSize = isMobile and 16 or 21
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

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Name = "slider_" .. flag
                sliderFrame.Parent = contentContainer  -- 改为contentContainer
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
                sliderLabel.TextColor3 = Color3.fromRGB(95, 95, 95)
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
                sliderPart.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
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
                dropdownFrame.Parent = contentContainer  -- 改为contentContainer
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
                dropdownLabel.TextColor3 = Color3.fromRGB(95, 95, 95)
                dropdownLabel.TextSize = isMobile and 16 or 21
                dropdownLabel.TextWrapped = true
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "dropdownButton"
                dropdownButton.Parent = dropdownFrame
                dropdownButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                dropdownButton.Position = UDim2.new(0, 0, 0.5, 0)
                dropdownButton.Size = UDim2.new(1, 0, 0, isMobile and 26 or 34)
                dropdownButton.Font = Enum.Font.Gotham
                dropdownButton.Text = "Select..."
                dropdownButton.TextColor3 = Color3.fromRGB(12, 12, 12)
                dropdownButton.TextSize = isMobile and 14 or 18
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 9)
                dropdownCorner.Parent = dropdownButton
                
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
            
            -- 添加一个方法来控制section的展开/折叠状态
            function section:SetExpanded(expanded)
                isExpanded = expanded
                contentContainer.Visible = isExpanded
                updateIconRotation()
            end
            
            -- 添加一个方法来获取当前状态
            function section:GetExpanded()
                return isExpanded
            end
            
            -- 添加一个方法来更改图标
            function section:SetIcon(newIcon)
                if newIcon then
                    local iconId = tostring(newIcon)
                    if iconId:match("^%d+$") then
                        iconButton.Image = "rbxassetid://" .. iconId
                    else
                        iconButton.Image = iconId
                    end
                else
                    -- 恢复默认图标
                    iconButton.Image = "rbxassetid://3926305904"
                    iconButton.ImageRectOffset = Vector2.new(124, 364)
                    iconButton.ImageRectSize = Vector2.new(36, 36)
                end
            end
            
            return section
        end

        -- 标签选择功能
        sidebar2.MouseButton1Click:Connect(function()
            for b, v in next, sections do
                v.BackgroundTransparency = 1
                v.TextColor3 = Color3.fromRGB(0, 0, 0)
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