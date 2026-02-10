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

-- 清理旧的UI
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
search.Parent = workarea
search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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

-- 侧边栏标题（脚本名字）
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
sidebar.Position = UDim2.new(0.0249653254, 0, 0.20, 0)
sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, isMobile and 150 or 400)
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
-- FengUI API 功能代码（从UI.lua移植，但使用iOS样式）
-- =========================================

local config = {
    MainColor = Color3.fromRGB(255, 255, 255),
    TabColor = Color3.fromRGB(21, 103, 251),
    Bg_Color = Color3.fromRGB(240, 240, 240),
    Zy_Color = Color3.fromRGB(240, 240, 240),
    Button_Color = Color3.fromRGB(216, 216, 216),
    Textbox_Color = Color3.fromRGB(240, 240, 240),
    Dropdown_Color = Color3.fromRGB(240, 240, 240),
    Keybind_Color = Color3.fromRGB(240, 240, 240),
    Label_Color = Color3.fromRGB(240, 240, 240),
    Slider_Color = Color3.fromRGB(240, 240, 240),
    SliderBar_Color = Color3.fromRGB(21, 103, 251),
    Toggle_Color = Color3.fromRGB(240, 240, 240),
    Toggle_Off = Color3.fromRGB(216, 216, 216),
    Toggle_On = Color3.fromRGB(21, 103, 251),
    AccentColor = Color3.fromRGB(21, 103, 251),
    TextColor = Color3.fromRGB(12, 12, 12),
    SecondaryTextColor = Color3.fromRGB(95, 95, 95),
}

function FengUI.new(FengUI, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "REN" then
            v:Destroy()
        end
    end

    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end

    local scriptName = name or "FengUI"
    SidebarTitle.Text = scriptName
    
    local window = {
    tabs = {},
    currentTab = nil
    }
    
    function window:AddTag(text, bgColor, textColor)
        -- iOS版本不支持标签功能
        warn("iOS版本UI不支持标签功能")
        return nil
    end
    
    function window:UpdateTag(index, text, bgColor, textColor)
        warn("iOS版本UI不支持标签功能")
    end
    
    function window:ClearTags()
        warn("iOS版本UI不支持标签功能")
    end
    
    function window:RemoveTag(index)
        warn("iOS版本UI不支持标签功能")
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
        sidebar2.ZIndex = 10
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
        
        function tab.section(tab, name, windowPosition, TabVal)
            if type(windowPosition) == "boolean" then
                TabVal = windowPosition
                windowPosition = "Left"
            elseif not windowPosition or type(windowPosition) ~= "string" then
                windowPosition = "Left"
            end
            
            -- iOS版本不支持双窗口，忽略windowPosition参数
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
            sectionDivider.TextColor3 = Color3.fromRGB(0, 0, 0)
            sectionDivider.TextSize = isMobile and 18 or 25
            sectionDivider.TextWrapped = true
            sectionDivider.TextXAlignment = Enum.TextXAlignment.Left
            sectionDivider.TextYAlignment = Enum.TextYAlignment.Bottom
            
            function section.Button(section, text, callback)
                callback = callback or function() end
                
                local button = Instance.new("TextButton")
                button.Name = "button_" .. text
                button.Text = text
                button.Parent = sectionFrame
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

                button.MouseButton1Click:Connect(function() 
                    coroutine.wrap(function()
                        button.TextSize -= 3
                        task.wait(0.06)
                        button.TextSize += 3
                    end)()
                    callback()
                end)
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
                
                -- 下拉菜单容器
                local dropdownContainer = Instance.new("Frame")
                dropdownContainer.Name = "dropdownContainer"
                dropdownContainer.Parent = dropdownFrame
                dropdownContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownContainer.BorderSizePixel = 0
                dropdownContainer.Position = UDim2.new(0, 0, 1, 5)
                dropdownContainer.Size = UDim2.new(1, 0, 0, 0)
                dropdownContainer.Visible = false
                dropdownContainer.ClipsDescendants = true
                
                local dropdownContainerCorner = Instance.new("UICorner")
                dropdownContainerCorner.CornerRadius = UDim.new(0, 9)
                dropdownContainerCorner.Parent = dropdownContainer
                
                local dropdownList = Instance.new("UIListLayout")
                dropdownList.Parent = dropdownContainer
                dropdownList.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownList.Padding = UDim.new(0, 2)
                
                local dropdownPadding = Instance.new("UIPadding")
                dropdownPadding.Parent = dropdownContainer
                dropdownPadding.PaddingTop = UDim.new(0, 5)
                dropdownPadding.PaddingBottom = UDim.new(0, 5)
                
                local allOptions = {}
                local selectedOption = nil
                local isOpen = false
                
                local function updateDropdownHeight()
                    local optionCount = 0
                    for _, child in pairs(dropdownContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            optionCount = optionCount + 1
                        end
                    end
                    
                    dropdownContainer.Size = UDim2.new(1, 0, 0, optionCount * (isMobile and 30 or 36) + 10)
                    dropdownFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 70 + (isOpen and optionCount * 30 + 15 or 0) or 80 + (isOpen and optionCount * 36 + 15 or 0))
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    dropdownContainer.Visible = isOpen
                    updateDropdownHeight()
                end
                
                local funcs = {}
                
                funcs.AddOption = function(self, optionText)
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "option_" .. optionText
                    optionButton.Parent = dropdownContainer
                    optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    optionButton.BackgroundTransparency = 1
                    optionButton.Size = UDim2.new(1, -10, 0, isMobile and 30 or 36)
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Text = optionText
                    optionButton.TextColor3 = Color3.fromRGB(95, 95, 95)
                    optionButton.TextSize = isMobile and 14 or 16
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = optionText
                        dropdownButton.Text = optionText
                        FengUI.flags[flag] = optionText
                        callback(optionText)
                        toggleDropdown()
                    end)
                    
                    optionButton.MouseEnter:Connect(function()
                        optionButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    end)
                    
                    table.insert(allOptions, optionButton)
                    updateDropdownHeight()
                    
                    return optionButton
                end
                
                funcs.RemoveOption = function(self, optionText)
                    for i, option in pairs(allOptions) do
                        if option and option.Text == optionText then
                            option:Destroy()
                            table.remove(allOptions, i)
                            break
                        end
                    end
                    updateDropdownHeight()
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
                    
                    updateDropdownHeight()
                end
                
                funcs.GetSelected = function(self)
                    return FengUI.flags[flag]
                end
                
                funcs.SetSelected = function(self, value)
                    if value then
                        for _, option in pairs(allOptions) do
                            if option and option.Text == value then
                                selectedOption = value
                                dropdownButton.Text = value
                                FengUI.flags[flag] = value
                                break
                            end
                        end
                    else
                        selectedOption = nil
                        dropdownButton.Text = "Select..."
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
                    selectedOption = nil
                    dropdownButton.Text = "Select..."
                    FengUI.flags[flag] = nil
                    updateDropdownHeight()
                end
                
                funcs.Open = function(self)
                    if not isOpen then
                        toggleDropdown()
                    end
                end
                
                funcs.Close = function(self)
                    if isOpen then
                        toggleDropdown()
                    end
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    toggleDropdown()
                end)
                
                -- 点击外部关闭下拉菜单
                services.UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = services.Players.LocalPlayer:GetMouse()
                        local dropdownPos = dropdownContainer.AbsolutePosition
                        local dropdownSize = dropdownContainer.AbsoluteSize
                        
                        if isOpen and (mouse.X < dropdownPos.X or mouse.X > dropdownPos.X + dropdownSize.X or mouse.Y < dropdownPos.Y or mouse.Y > dropdownPos.Y + dropdownSize.Y) then
                            local buttonPos = dropdownButton.AbsolutePosition
                            local buttonSize = dropdownButton.AbsoluteSize
                            
                            if mouse.X < buttonPos.X or mouse.X > buttonPos.X + buttonSize.X or mouse.Y < buttonPos.Y or mouse.Y > buttonPos.Y + buttonSize.Y then
                                toggleDropdown()
                            end
                        end
                    end
                end)
                
                funcs:SetOptions(options)
                
                if #options > 0 then
                    funcs:SetSelected(options[1])
                end
                
                return funcs
            end
            
            function section.ColorPicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(21, 103, 251)
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
                colorPickerLabel.TextColor3 = Color3.fromRGB(95, 95, 95)
                colorPickerLabel.TextSize = isMobile and 16 or 21
                colorPickerLabel.TextWrapped = true
                colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local colorPreview = Instance.new("Frame")
                colorPreview.Name = "colorPreview"
                colorPreview.Parent = colorPickerFrame
                colorPreview.BackgroundColor3 = defaultColor
                colorPreview.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                colorPreview.Size = UDim2.new(0, isMobile and 60 or 80, 0, isMobile and 26 or 34)
                
                local colorPreviewCorner = Instance.new("UICorner")
                colorPreviewCorner.CornerRadius = UDim.new(0, 9)
                colorPreviewCorner.Parent = colorPreview
                
                local colorPreviewButton = Instance.new("TextButton")
                colorPreviewButton.Name = "colorPreviewButton"
                colorPreviewButton.Parent = colorPreview
                colorPreviewButton.BackgroundTransparency = 1
                colorPreviewButton.Size = UDim2.new(1, 0, 1, 0)
                colorPreviewButton.Text = ""
                
                -- 颜色选择器弹出窗口
                local colorPickerPopup = Instance.new("Frame")
                colorPickerPopup.Name = "colorPickerPopup"
                colorPickerPopup.Parent = FengYu
                colorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
                colorPickerPopup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorPickerPopup.BackgroundTransparency = 0.1
                colorPickerPopup.BorderSizePixel = 0
                colorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                colorPickerPopup.Size = UDim2.new(0, 300, 0, 240)
                colorPickerPopup.Visible = false
                colorPickerPopup.ZIndex = 100
                
                local popupCorner = Instance.new("UICorner")
                popupCorner.CornerRadius = UDim.new(0, 18)
                popupCorner.Parent = colorPickerPopup
                
                local popupTitle = Instance.new("TextLabel")
                popupTitle.Name = "popupTitle"
                popupTitle.Parent = colorPickerPopup
                popupTitle.BackgroundTransparency = 1
                popupTitle.Position = UDim2.new(0, 10, 0, 10)
                popupTitle.Size = UDim2.new(1, -20, 0, 30)
                popupTitle.Font = Enum.Font.GothamBold
                popupTitle.Text = "选择颜色"
                popupTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
                popupTitle.TextSize = 18
                popupTitle.TextXAlignment = Enum.TextXAlignment.Center
                
                local hueSlider = Instance.new("Frame")
                hueSlider.Name = "hueSlider"
                hueSlider.Parent = colorPickerPopup
                hueSlider.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
                hueSlider.Position = UDim2.new(0.1, 0, 0.2, 0)
                hueSlider.Size = UDim2.new(0.8, 0, 0, 20)
                
                local hueSliderCorner = Instance.new("UICorner")
                hueSliderCorner.CornerRadius = UDim.new(1, 0)
                hueSliderCorner.Parent = hueSlider
                
                local hueGradient = Instance.new("UIGradient")
                hueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }
                hueGradient.Parent = hueSlider
                
                local hueSliderThumb = Instance.new("Frame")
                hueSliderThumb.Name = "hueSliderThumb"
                hueSliderThumb.Parent = hueSlider
                hueSliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueSliderThumb.Size = UDim2.new(0, 10, 0, 24)
                hueSliderThumb.Position = UDim2.new(0.5, -5, -0.1, 0)
                
                local hueSliderThumbCorner = Instance.new("UICorner")
                hueSliderThumbCorner.CornerRadius = UDim.new(0, 2)
                hueSliderThumbCorner.Parent = hueSliderThumb
                
                local currentColor = defaultColor
                local currentHue, currentSat, currentVal = Color3.toHSV(defaultColor)
                
                local function updateColorDisplay()
                    colorPreview.BackgroundColor3 = currentColor
                end
                
                local function updateHueSlider()
                    hueSliderThumb.Position = UDim2.new(currentHue, -5, -0.1, 0)
                end
                
                local function openColorPicker()
                    colorPickerPopup.Visible = true
                    colorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                    updateHueSlider()
                end
                
                local function closeColorPicker(save)
                    colorPickerPopup.Visible = false
                    if save then
                        FengUI.flags[flag] = currentColor
                        callback(currentColor)
                    end
                end
                
                colorPreviewButton.MouseButton1Click:Connect(openColorPicker)
                
                -- 色相滑块交互
                local hueDragging = false
                
                hueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                    end
                end)
                
                hueSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                services.UserInputService.InputChanged:Connect(function(input)
                    if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouse = services.Players.LocalPlayer:GetMouse()
                        local sliderPos = hueSlider.AbsolutePosition.X
                        local sliderSize = hueSlider.AbsoluteSize.X
                        local mouseX = math.clamp(mouse.X, sliderPos, sliderPos + sliderSize)
                        
                        currentHue = (mouseX - sliderPos) / sliderSize
                        currentColor = Color3.fromHSV(currentHue, currentSat, currentVal)
                        updateColorDisplay()
                        updateHueSlider()
                    end
                end)
                
                -- 添加确认和取消按钮
                local confirmButton = Instance.new("TextButton")
                confirmButton.Name = "confirmButton"
                confirmButton.Parent = colorPickerPopup
                confirmButton.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
                confirmButton.Position = UDim2.new(0.1, 0, 0.8, 0)
                confirmButton.Size = UDim2.new(0.35, 0, 0, 30)
                confirmButton.Font = Enum.Font.GothamBold
                confirmButton.Text = "确认"
                confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirmButton.TextSize = 14
                
                local confirmCorner = Instance.new("UICorner")
                confirmCorner.CornerRadius = UDim.new(0, 9)
                confirmCorner.Parent = confirmButton
                
                local cancelButton = Instance.new("TextButton")
                cancelButton.Name = "cancelButton"
                cancelButton.Parent = colorPickerPopup
                cancelButton.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
                cancelButton.Position = UDim2.new(0.55, 0, 0.8, 0)
                cancelButton.Size = UDim2.new(0.35, 0, 0, 30)
                cancelButton.Font = Enum.Font.GothamBold
                cancelButton.Text = "取消"
                cancelButton.TextColor3 = Color3.fromRGB(12, 12, 12)
                cancelButton.TextSize = 14
                
                local cancelCorner = Instance.new("UICorner")
                cancelCorner.CornerRadius = UDim.new(0, 9)
                cancelCorner.Parent = cancelButton
                
                confirmButton.MouseButton1Click:Connect(function()
                    closeColorPicker(true)
                end)
                
                cancelButton.MouseButton1Click:Connect(function()
                    closeColorPicker(false)
                end)
                
                -- 点击外部关闭
                local closeClickArea = Instance.new("TextButton")
                closeClickArea.Name = "closeClickArea"
                closeClickArea.Parent = FengYu
                closeClickArea.BackgroundTransparency = 1
                closeClickArea.Size = UDim2.new(1, 0, 1, 0)
                closeClickArea.Text = ""
                closeClickArea.Visible = false
                closeClickArea.ZIndex = 99
                
                colorPreviewButton.MouseButton1Click:Connect(function()
                    openColorPicker()
                    closeClickArea.Visible = true
                end)
                
                closeClickArea.MouseButton1Click:Connect(function()
                    colorPickerPopup.Visible = false
                    closeClickArea.Visible = false
                end)
                
                confirmButton.MouseButton1Click:Connect(function()
                    colorPickerPopup.Visible = false
                    closeClickArea.Visible = false
                    closeColorPicker(true)
                end)
                
                cancelButton.MouseButton1Click:Connect(function()
                    colorPickerPopup.Visible = false
                    closeClickArea.Visible = false
                    closeColorPicker(false)
                end)
                
                updateColorDisplay()
                
                local funcs = {
                    SetColor = function(self, color)
                        if typeof(color) == "Color3" then
                            currentColor = color
                            currentHue, currentSat, currentVal = Color3.toHSV(color)
                            updateColorDisplay()
                            updateHueSlider()
                            FengUI.flags[flag] = color
                            callback(color)
                        end
                    end,
                    
                    GetColor = function(self)
                        return FengUI.flags[flag] or defaultColor
                    end,
                    
                    Module = colorPickerFrame
                }
                
                return funcs
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
        -- iOS版本不支持双窗口，但保持API兼容性
        warn("iOS版本UI不支持双窗口，使用单窗口替代")
        return window:Tab(name, icon, 1)
    end

    return window
end

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