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

-- iOS风格配置
local config = {
    MainColor = Color3.fromRGB(245, 245, 247),  -- iOS浅灰背景
    TabColor = Color3.fromRGB(255, 255, 255),   -- 白色标签背景
    Bg_Color = Color3.fromRGB(242, 242, 247),   -- iOS系统灰色
    Button_Color = Color3.fromRGB(0, 122, 255),  -- iOS蓝色
    Textbox_Color = Color3.fromRGB(255, 255, 255), -- 白色
    Dropdown_Color = Color3.fromRGB(255, 255, 255), -- 白色
    Keybind_Color = Color3.fromRGB(255, 255, 255),  -- 白色
    Label_Color = Color3.fromRGB(255, 255, 255),    -- 白色
    Slider_Color = Color3.fromRGB(255, 255, 255),   -- 白色
    SliderBar_Color = Color3.fromRGB(0, 122, 255),  -- iOS蓝色
    Toggle_Color = Color3.fromRGB(255, 255, 255),   -- 白色
    Toggle_Off = Color3.fromRGB(230, 230, 235),     -- iOS关闭状态灰色
    Toggle_On = Color3.fromRGB(52, 199, 89),        -- iOS绿色
    AccentColor = Color3.fromRGB(0, 122, 255),      -- iOS蓝色
    TextColor = Color3.fromRGB(0, 0, 0),            -- 黑色文字
    SecondaryTextColor = Color3.fromRGB(110, 110, 115), -- iOS次要文字颜色
    BorderColor = Color3.fromRGB(230, 230, 235),    -- iOS边框颜色
    
    -- 新增iOS风格配置
    SectionColor = Color3.fromRGB(255, 255, 255),   -- 白色分区背景
    ShadowColor = Color3.fromRGB(0, 0, 0, 0.1),     -- iOS阴影
    SelectedColor = Color3.fromRGB(230, 230, 235),  -- 选中状态颜色
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
Open.BackgroundColor3 = config.AccentColor  -- iOS蓝色
Open.BackgroundTransparency = 0.9
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 44, 0, 44)  -- 增大按钮大小
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://3926305904"  -- iOS风格图标
Open.ImageRectOffset = Vector2.new(964, 324)
Open.ImageRectSize = Vector2.new(36, 36)
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = Open

local OpenShadow = Instance.new("UIStroke")
OpenShadow.Parent = Open
OpenShadow.Color = Color3.fromRGB(0, 0, 0, 0.1)
OpenShadow.Thickness = 1
OpenShadow.Transparency = 0.5

-- 创建主窗口（根据设备类型调整大小）
local main = Instance.new("Frame")
main.Name = "main"
main.Parent = FengYu
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = config.MainColor  -- iOS浅灰背景
main.BackgroundTransparency = 0
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
main.Visible = false

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 18)
uc.Parent = main

-- iOS风格阴影
local mainShadow = Instance.new("UIStroke")
mainShadow.Parent = main
mainShadow.Color = config.ShadowColor
mainShadow.Thickness = 1
mainShadow.Transparency = 0

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
workarea.BackgroundColor3 = config.SectionColor  -- iOS白色背景
workarea.Position = UDim2.new(0.36403501, 0, 0, 0)
workarea.Size = UDim2.new(0, WORKAREA_WIDTH, 0, WORKAREA_HEIGHT)

local uc_2 = Instance.new("UICorner")
uc_2.CornerRadius = UDim.new(0, 18)
uc_2.Parent = workarea

-- iOS风格边框
local workareaBorder = Instance.new("UIStroke")
workareaBorder.Parent = workarea
workareaBorder.Color = config.BorderColor
workareaBorder.Thickness = 1
workareaBorder.Transparency = 0

-- 搜索框移动到侧边栏右边的最上面（工作区的右上角）
local search = Instance.new("Frame")
search.Name = "search"
search.Parent = workarea  -- 父级改为workarea
search.BackgroundColor3 = config.Textbox_Color  -- 白色
search.Position = UDim2.new(isMobile and 0.1 or 0.7, 0, 0.01, 0) -- 右上角位置
search.Size = UDim2.new(0, isMobile and 120 or 120, 0, 32) -- iOS风格高度

local uc_8 = Instance.new("UICorner")
uc_8.CornerRadius = UDim.new(0, 8)  -- iOS圆角
uc_8.Parent = search

local searchBorder = Instance.new("UIStroke")
searchBorder.Parent = search
searchBorder.Color = config.BorderColor
searchBorder.Thickness = 1
searchBorder.Transparency = 0

local searchicon = Instance.new("ImageButton")
searchicon.Name = "searchicon"
searchicon.Parent = search
searchicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchicon.BackgroundTransparency = 1
searchicon.BorderColor3 = Color3.fromRGB(27, 42, 53)
searchicon.Position = UDim2.new(0.05, 0, 0.15, 0)
searchicon.Size = UDim2.new(0, 18, 0, 18) -- 缩小图标
searchicon.Image = "rbxassetid://3926305904"  -- iOS搜索图标
searchicon.ImageRectOffset = Vector2.new(84, 204)
searchicon.ImageRectSize = Vector2.new(36, 36)
searchicon.ImageColor3 = config.SecondaryTextColor
searchicon.ScaleType = Enum.ScaleType.Fit

local searchtextbox = Instance.new("TextBox")
searchtextbox.Name = "searchtextbox"
searchtextbox.Parent = search
searchtextbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchtextbox.BackgroundTransparency = 1
searchtextbox.ClipsDescendants = true
searchtextbox.Position = UDim2.new(0.25, 0, 0, 0)
searchtextbox.Size = UDim2.new(0, isMobile and 80 or 85, 0, 32)
searchtextbox.Font = Enum.Font.SourceSans  -- iOS字体
searchtextbox.LineHeight = 0.870
searchtextbox.PlaceholderText = "搜索..."
searchtextbox.PlaceholderColor3 = config.SecondaryTextColor
searchtextbox.Text = ""
searchtextbox.TextColor3 = config.TextColor
searchtextbox.TextSize = isMobile and 14 or 16
searchtextbox.TextXAlignment = Enum.TextXAlignment.Left

searchicon.MouseButton1Click:Connect(function()
    searchtextbox:CaptureFocus()
end)

-- 侧边栏标题（脚本名字） - 放在最上面
local SidebarTitle = Instance.new("TextLabel")
SidebarTitle.Name = "SidebarTitle"
SidebarTitle.Parent = main
SidebarTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SidebarTitle.BackgroundTransparency = 1
SidebarTitle.BorderSizePixel = 0
SidebarTitle.Position = UDim2.new(0.025, 0, 0.06, 0)
SidebarTitle.Size = UDim2.new(0, SIDEBAR_WIDTH, 0, isMobile and 30 or 50)
SidebarTitle.Font = Enum.Font.SourceSansBold  -- iOS粗体
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
sidebar.ScrollBarImageColor3 = config.SecondaryTextColor

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
        currentTab = nil,
        tags = {},
        tagObjects = {},
        tagCount = 0,
        maxTags = 3,
    }
    
    function window:AddTag(text, bgColor, textColor)
        if self.tagCount >= self.maxTags then
            return nil
        end
        
        bgColor = bgColor or config.AccentColor
        textColor = textColor or Color3.fromRGB(255, 255, 255)
        
        local TagContainer = main:FindFirstChild("TagContainer")
        if not TagContainer then
            TagContainer = Instance.new("Frame")
            TagContainer.Name = "TagContainer"
            TagContainer.Parent = main
            TagContainer.BackgroundTransparency = 1
            TagContainer.Position = UDim2.new(0.7, 0, 0.06, 0)
            TagContainer.Size = UDim2.new(0, 120, 0, 30)
        end
        
        local Tag = Instance.new("TextLabel")
        Tag.Name = "Tag_" .. text
        Tag.Parent = TagContainer
        Tag.BackgroundColor3 = bgColor
        Tag.BackgroundTransparency = 0.3
        Tag.Text = text
        Tag.Font = Enum.Font.SourceSansSemibold
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
        
        local textSize = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.SourceSansSemibold, Vector2.new(200, 20))
        Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 20)
        
        local tagObj = {
            Instance = Tag,
            Stroke = TagStroke,
            Text = text,
            Color = bgColor,
            TextColor = textColor,
            
            Destroy = function()
                Tag:Destroy()
            end,
            
            Update = function(newText, newBgColor, newTextColor)
                if newText then
                    Tag.Text = newText
                    tagObj.Text = newText
                    local textSize = game:GetService("TextService"):GetTextSize(newText, 11, Enum.Font.SourceSansSemibold, Vector2.new(200, 20))
                    Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 20)
                end
                
                if newBgColor then
                    tagObj.Color = newBgColor
                    Tag.BackgroundColor3 = newBgColor
                    TagStroke.Color = newBgColor
                end
                
                if newTextColor then
                    Tag.TextColor3 = newTextColor
                    tagObj.TextColor = newTextColor
                end
            end
        }
        
        table.insert(self.tags, Tag)
        table.insert(self.tagObjects, tagObj)
        self.tagCount = self.tagCount + 1
        
        return tagObj
    end
    
    function window:UpdateTag(index, text, bgColor, textColor)
        if index < 1 or index > #self.tagObjects then return end
        
        local tagObj = self.tagObjects[index]
        if not tagObj or not tagObj.Instance or not tagObj.Instance.Parent then return end
        
        tagObj:Update(text, bgColor, textColor)
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
        sidebar2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- iOS白色
        sidebar2.BackgroundTransparency = 1
        sidebar2.Size = UDim2.new(0, SIDEBAR_WIDTH - 7, 0, isMobile and 36 or 44)  -- iOS高度
        sidebar2.ZIndex = 2
        sidebar2.AutoButtonColor = false
        sidebar2.Font = Enum.Font.SourceSansSemibold  -- iOS字体
        sidebar2.Text = name
        sidebar2.TextColor3 = config.TextColor
        sidebar2.TextSize = isMobile and 16 or 18
        
        local uc_10 = Instance.new("UICorner")
        uc_10.CornerRadius = UDim.new(0, 8)  -- iOS圆角
        uc_10.Parent = sidebar2
        
        local sidebar2Stroke = Instance.new("UIStroke")
        sidebar2Stroke.Parent = sidebar2
        sidebar2Stroke.Color = config.BorderColor
        sidebar2Stroke.Thickness = 1
        sidebar2Stroke.Transparency = 0.8
        
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
            
            -- iOS风格分隔符标题
            local sectionDivider = Instance.new("TextLabel")
            sectionDivider.Name = "sectionDivider"
            sectionDivider.Parent = sectionFrame
            sectionDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sectionDivider.BackgroundTransparency = 1
            sectionDivider.BorderSizePixel = 2
            sectionDivider.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 30 or 50)
            sectionDivider.Font = Enum.Font.SourceSansSemibold  -- iOS字体
            sectionDivider.LineHeight = 1.180
            sectionDivider.Text = name
            sectionDivider.TextColor3 = config.SecondaryTextColor  -- iOS次要颜色
            sectionDivider.TextSize = isMobile and 14 or 16
            sectionDivider.TextWrapped = true
            sectionDivider.TextXAlignment = Enum.TextXAlignment.Left
            sectionDivider.TextYAlignment = Enum.TextYAlignment.Bottom
            
            -- iOS风格分隔线
            local sectionLine = Instance.new("Frame")
            sectionLine.Name = "sectionLine"
            sectionLine.Parent = sectionDivider
            sectionLine.BackgroundColor3 = config.BorderColor
            sectionLine.BorderSizePixel = 0
            sectionLine.Position = UDim2.new(0, 0, 1, 0)
            sectionLine.Size = UDim2.new(1, 0, 0, 1)
            
            function section.Button(section, text, callback)
                local button = Instance.new("TextButton")
                button.Name = "button_" .. text
                button.Text = text
                button.Parent = sectionFrame
                button.BackgroundColor3 = config.Button_Color
                button.BackgroundTransparency = 0.9
                button.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 36 or 44)
                button.ZIndex = 2
                button.Font = Enum.Font.SourceSansSemibold
                button.TextColor3 = config.AccentColor  -- iOS蓝色文字
                button.TextSize = isMobile and 16 or 18

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)  -- iOS圆角
                buttonCorner.Parent = button

                local buttonBorder = Instance.new("UIStroke")
                buttonBorder.Parent = button
                buttonBorder.Color = config.BorderColor
                buttonBorder.Thickness = 1
                buttonBorder.Transparency = 0

                if callback then
                    button.MouseButton1Click:Connect(function() 
                        coroutine.wrap(function()
                            services.TweenService:Create(button, TweenInfo.new(0.1), {
                                BackgroundTransparency = 0.8
                            }):Play()
                            task.wait(0.06)
                            services.TweenService:Create(button, TweenInfo.new(0.1), {
                                BackgroundTransparency = 0.9
                            }):Play()
                        end)()
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
                ImageCorner.CornerRadius = UDim.new(0, 8)  -- iOS圆角
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
                label.Font = Enum.Font.SourceSans
                label.TextColor3 = config.SecondaryTextColor
                label.TextSize = isMobile and 14 or 16
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
                toggleFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 44 or 52)  -- iOS高度
                
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Name = "toggleLabel"
                toggleLabel.Parent = toggleFrame
                toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.BorderSizePixel = 2
                toggleLabel.Position = UDim2.new(0, 0, 0, 0)
                toggleLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                toggleLabel.Font = Enum.Font.SourceSans
                toggleLabel.Text = text
                toggleLabel.TextColor3 = config.TextColor
                toggleLabel.TextSize = isMobile and 14 or 16
                toggleLabel.TextWrapped = true
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleSwitch = Instance.new("Frame")
                toggleSwitch.Name = "toggleSwitch"
                toggleSwitch.Parent = toggleFrame
                toggleSwitch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleSwitch.BackgroundTransparency = 0.9
                toggleSwitch.BorderSizePixel = 0
                toggleSwitch.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                toggleSwitch.Size = UDim2.new(0, isMobile and 60 or 68, 0, isMobile and 32 or 36)  -- iOS开关尺寸
                
                local switchCorner = Instance.new("UICorner")
                switchCorner.CornerRadius = UDim.new(1, 0)  -- 圆形开关
                switchCorner.Parent = toggleSwitch
                
                local switchBorder = Instance.new("UIStroke")
                switchBorder.Parent = toggleSwitch
                switchBorder.Color = config.BorderColor
                switchBorder.Thickness = 1
                switchBorder.Transparency = 0
                
                local switchButton = Instance.new("TextButton")
                switchButton.Parent = toggleSwitch
                switchButton.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                switchButton.Size = UDim2.new(0, isMobile and 28 or 32, 0, isMobile and 28 or 32)
                switchButton.AutoButtonColor = false
                switchButton.Text = ""
                switchButton.Position = UDim2.new(0, enabled and (isMobile and 30 or 34) or 2, 0, 2)

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(1, 0)
                buttonCorner.Parent = switchButton
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengUI.flags[flag]
                        end
                        if FengUI.flags[flag] == state then
                            return
                        end
                        
                        FengUI.flags[flag] = state
                        
                        services.TweenService:Create(switchButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, state and (isMobile and 30 or 34) or 2, 0, 2),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        callback(state)
                    end,
                    Module = toggleFrame
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                switchButton.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                
                toggleSwitch.MouseButton1Click:Connect(function()
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
                keybindFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 44 or 52)  -- iOS高度
                
                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Name = "keybindLabel"
                keybindLabel.Parent = keybindFrame
                keybindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.BorderSizePixel = 2
                keybindLabel.Position = UDim2.new(0, 0, 0, 0)
                keybindLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                keybindLabel.Font = Enum.Font.SourceSans
                keybindLabel.Text = text
                keybindLabel.TextColor3 = config.TextColor
                keybindLabel.TextSize = isMobile and 14 or 16
                keybindLabel.TextWrapped = true
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local keybindButton = Instance.new("TextButton")
                keybindButton.Name = "keybindButton"
                keybindButton.Parent = keybindFrame
                keybindButton.BackgroundColor3 = config.Bg_Color
                keybindButton.BackgroundTransparency = 0.9
                keybindButton.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                keybindButton.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 32 or 36)
                keybindButton.Font = Enum.Font.SourceSans
                keybindButton.Text = keyTxt
                keybindButton.TextColor3 = config.TextColor
                keybindButton.TextSize = isMobile and 14 or 16
                
                local keybindCorner = Instance.new("UICorner")
                keybindCorner.CornerRadius = UDim.new(0, 8)  -- iOS圆角
                keybindCorner.Parent = keybindButton
                
                local keybindBorder = Instance.new("UIStroke")
                keybindBorder.Parent = keybindButton
                keybindBorder.Color = config.BorderColor
                keybindBorder.Thickness = 1
                keybindBorder.Transparency = 0
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                keybindButton.MouseButton1Click:Connect(function()
                    keybindButton.Text = "..."
                    keybindButton.BackgroundColor3 = config.AccentColor
                    keybindButton.BackgroundTransparency = 0.8
                    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    
                    task.wait()
                    
                    local key = UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        keybindButton.Text = keyTxt
                        keybindButton.BackgroundColor3 = config.Bg_Color
                        keybindButton.BackgroundTransparency = 0.9
                        keybindButton.TextColor3 = config.TextColor
                        return
                    end
                    
                    if banned[keyName] then
                        keybindButton.Text = keyTxt
                        keybindButton.BackgroundColor3 = config.Bg_Color
                        keybindButton.BackgroundTransparency = 0.9
                        keybindButton.TextColor3 = config.TextColor
                        return
                    end
                    
                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    keyTxt = shortNames[keyName] or keyName
                    keybindButton.Text = keyTxt
                    keybindButton.BackgroundColor3 = config.Bg_Color
                    keybindButton.BackgroundTransparency = 0.9
                    keybindButton.TextColor3 = config.TextColor
                end)
                
                -- 返回一个控制器对象
                local controller = {}
                function controller:SetKey(key)
                    if typeof(key) == "string" then
                        bindKey = Enum.KeyCode[key]
                    else
                        bindKey = key
                    end
                    keyTxt = bindKey and (shortNames[bindKey.Name] or bindKey.Name) or "None"
                    keybindButton.Text = keyTxt
                end
                
                function controller:GetKey()
                    return bindKey
                end
                
                return controller
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
                textboxLabel.Font = Enum.Font.SourceSans
                textboxLabel.Text = text
                textboxLabel.TextColor3 = config.TextColor
                textboxLabel.TextSize = isMobile and 14 or 16
                textboxLabel.TextWrapped = true
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local textboxInput = Instance.new("Frame")
                textboxInput.Parent = textboxFrame
                textboxInput.BackgroundColor3 = config.Textbox_Color
                textboxInput.BackgroundTransparency = 0.9
                textboxInput.Position = UDim2.new(0, 0, 0.5, 0)
                textboxInput.Size = UDim2.new(1, 0, 0, isMobile and 32 or 36)

                local textboxCorner = Instance.new("UICorner")
                textboxCorner.CornerRadius = UDim.new(0, 8)  -- iOS圆角
                textboxCorner.Parent = textboxInput

                local textboxBorder = Instance.new("UIStroke")
                textboxBorder.Parent = textboxInput
                textboxBorder.Color = config.BorderColor
                textboxBorder.Thickness = 1
                textboxBorder.Transparency = 0

                local textbox = Instance.new("TextBox")
                textbox.Parent = textboxInput
                textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                textbox.BackgroundTransparency = 1
                textbox.BorderColor3 = Color3.fromRGB(27, 42, 53)
                textbox.BorderSizePixel = 0
                textbox.ClipsDescendants = true
                textbox.Position = UDim2.new(0.0643776804, 0, 0, -2)
                textbox.Size = UDim2.new(0, WORKAREA_WIDTH - 76, 0, isMobile and 32 or 36)
                textbox.ClearTextOnFocus = false
                textbox.Font = Enum.Font.SourceSans
                textbox.LineHeight = 0.870
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
                
                -- 返回一个控制器对象
                local controller = {}
                function controller:SetText(newText)
                    textbox.Text = newText
                    FengUI.flags[flag] = newText
                end
                
                function controller:GetText()
                    return FengUI.flags[flag]
                end
                
                return controller
            end
            
            -- windUI风格的滑块
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
                sliderLabel.Font = Enum.Font.SourceSans
                sliderLabel.Text = text .. ": " .. tostring(default)
                sliderLabel.TextColor3 = config.TextColor
                sliderLabel.TextSize = isMobile and 14 or 16
                sliderLabel.TextWrapped = true
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local sliderContainer = Instance.new("Frame")
                sliderContainer.Name = "sliderContainer"
                sliderContainer.Parent = sliderFrame
                sliderContainer.BackgroundTransparency = 1
                sliderContainer.Position = UDim2.new(0, 0, 0.5, 0)
                sliderContainer.Size = UDim2.new(1, 0, 0, isMobile and 32 or 36)
                
                local sliderBar = Instance.new("Frame")
                sliderBar.Name = "sliderBar"
                sliderBar.Parent = sliderContainer
                sliderBar.BackgroundColor3 = config.Toggle_Off  -- iOS灰色
                sliderBar.BorderSizePixel = 0
                sliderBar.Position = UDim2.new(0, 0, 0.5, -2)
                sliderBar.Size = UDim2.new(1, 0, 0, 4)
                
                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(1, 0)
                sliderBarCorner.Parent = sliderBar
                
                local sliderProgress = Instance.new("Frame")
                sliderProgress.Name = "sliderProgress"
                sliderProgress.Parent = sliderBar
                sliderProgress.BackgroundColor3 = config.SliderBar_Color  -- iOS蓝色
                sliderProgress.BorderSizePixel = 0
                sliderProgress.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                local sliderProgressCorner = Instance.new("UICorner")
                sliderProgressCorner.CornerRadius = UDim.new(1, 0)
                sliderProgressCorner.Parent = sliderProgress
                
                local sliderThumb = Instance.new("Frame")
                sliderThumb.Name = "sliderThumb"
                sliderThumb.Parent = sliderBar
                sliderThumb.BackgroundColor3 = config.SliderBar_Color  -- iOS蓝色
                sliderThumb.BorderSizePixel = 0
                sliderThumb.Size = UDim2.new(0, isMobile and 20 or 24, 0, isMobile and 20 or 24)
                sliderThumb.Position = UDim2.new((default - min)/(max - min), -(isMobile and 10 or 12), 0.5, -(isMobile and 10 or 12))
                sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
                
                local sliderThumbCorner = Instance.new("UICorner")
                sliderThumbCorner.CornerRadius = UDim.new(1, 0)
                sliderThumbCorner.Parent = sliderThumb
                
                local sliderValue = Instance.new("TextLabel")
                sliderValue.Name = "sliderValue"
                sliderValue.Parent = sliderContainer
                sliderValue.BackgroundTransparency = 1
                sliderValue.Size = UDim2.new(0, 40, 1, 0)
                sliderValue.Position = UDim2.new(1, -40, 0, 0)
                sliderValue.Font = Enum.Font.SourceSans
                sliderValue.Text = tostring(default)
                sliderValue.TextColor3 = config.SecondaryTextColor
                sliderValue.TextSize = isMobile and 14 or 16
                sliderValue.TextXAlignment = Enum.TextXAlignment.Right
                
                local funcs = {
                    SetValue = function(self, value)
                        if value == nil then
                            return
                        end
                        
                        if precise then
                            value = tonumber(string.format("%.2f", value))
                        else
                            value = math.floor(value + 0.5)
                        end
                        
                        value = math.clamp(value, min, max)
                        local percent = (value - min)/(max - min)
                        
                        FengUI.flags[flag] = tonumber(value)
                        sliderLabel.Text = text .. ": " .. tostring(value)
                        sliderValue.Text = tostring(value)
                        
                        services.TweenService:Create(sliderProgress, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        services.TweenService:Create(sliderThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Position = UDim2.new(percent, -(isMobile and 10 or 12), 0.5, -(isMobile and 10 or 12))
                        }):Play()
                        
                        callback(tonumber(value))
                    end,
                    
                    GetValue = function(self)
                        return FengUI.flags[flag]
                    end,
                    
                    SetMin = function(self, newMin)
                        min = newMin
                        if FengUI.flags[flag] < min then
                            funcs:SetValue(min)
                        end
                    end,
                    
                    SetMax = function(self, newMax)
                        max = newMax
                        if FengUI.flags[flag] > max then
                            funcs:SetValue(max)
                        end
                    end,
                    
                    SetRange = function(self, newMin, newMax)
                        min = newMin
                        max = newMax
                        local current = FengUI.flags[flag]
                        if current < min then
                            funcs:SetValue(min)
                        elseif current > max then
                            funcs:SetValue(max)
                        end
                    end
                }
                
                funcs:SetValue(default)
                
                local dragging = false
                local function updateFromMouse()
                    if not dragging then return end
                    
                    local mouse = services.Players.LocalPlayer:GetMouse()
                    local barPos = sliderBar.AbsolutePosition.X
                    local barSize = sliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(mouse.X, barPos, barPos + barSize)
                    local percent = (mouseX - barPos) / barSize
                    local value = min + (max - min) * percent
                    
                    funcs:SetValue(value)
                end
                
                sliderThumb.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateFromMouse()
                    end
                end)
                
                sliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateFromMouse()
                    end
                end)
                
                services.UserInputService.InputEnded:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
                        dragging = false
                    end
                end)
                
                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromMouse()
                    end
                end)
                
                return funcs
            end
            
            -- windUI风格的下拉菜单
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
                dropdownFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 44 or 52)
                
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Name = "dropdownLabel"
                dropdownLabel.Parent = dropdownFrame
                dropdownLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.BorderSizePixel = 2
                dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
                dropdownLabel.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 28 or 37)
                dropdownLabel.Font = Enum.Font.SourceSans
                dropdownLabel.Text = text
                dropdownLabel.TextColor3 = config.TextColor
                dropdownLabel.TextSize = isMobile and 14 or 16
                dropdownLabel.TextWrapped = true
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Name = "dropdownButton"
                dropdownButton.Parent = dropdownFrame
                dropdownButton.BackgroundColor3 = config.Bg_Color
                dropdownButton.BackgroundTransparency = 0.9
                dropdownButton.Position = UDim2.new(isMobile and 0.5 or 0.6, 0, 0, 0)
                dropdownButton.Size = UDim2.new(0, isMobile and 140 or 160, 0, isMobile and 32 or 36)
                dropdownButton.Font = Enum.Font.SourceSans
                dropdownButton.Text = "Select..."
                dropdownButton.TextColor3 = config.SecondaryTextColor
                dropdownButton.TextSize = isMobile and 14 or 16
                dropdownButton.AutoButtonColor = false
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 8)  -- iOS圆角
                dropdownCorner.Parent = dropdownButton
                
                local dropdownBorder = Instance.new("UIStroke")
                dropdownBorder.Parent = dropdownButton
                dropdownBorder.Color = config.BorderColor
                dropdownBorder.Thickness = 1
                dropdownBorder.Transparency = 0
                
                local dropdownArrow = Instance.new("ImageLabel")
                dropdownArrow.Name = "dropdownArrow"
                dropdownArrow.Parent = dropdownButton
                dropdownArrow.BackgroundTransparency = 1
                dropdownArrow.Size = UDim2.new(0, 16, 0, 16)
                dropdownArrow.Position = UDim2.new(1, -24, 0.5, -8)
                dropdownArrow.Image = "rbxassetid://3926305904"
                dropdownArrow.ImageRectOffset = Vector2.new(964, 324)
                dropdownArrow.ImageRectSize = Vector2.new(36, 36)
                dropdownArrow.ImageColor3 = config.SecondaryTextColor
                
                local dropdownOptionsFrame = Instance.new("Frame")
                dropdownOptionsFrame.Name = "dropdownOptionsFrame"
                dropdownOptionsFrame.Parent = dropdownFrame
                dropdownOptionsFrame.BackgroundColor3 = config.SectionColor
                dropdownOptionsFrame.BackgroundTransparency = 0
                dropdownOptionsFrame.Position = UDim2.new(0, 0, 1, 5)
                dropdownOptionsFrame.Size = UDim2.new(0, isMobile and 140 or 160, 0, 0)
                dropdownOptionsFrame.Visible = false
                dropdownOptionsFrame.ClipsDescendants = true
                
                local dropdownOptionsCorner = Instance.new("UICorner")
                dropdownOptionsCorner.CornerRadius = UDim.new(0, 8)
                dropdownOptionsCorner.Parent = dropdownOptionsFrame
                
                local dropdownOptionsBorder = Instance.new("UIStroke")
                dropdownOptionsBorder.Parent = dropdownOptionsFrame
                dropdownOptionsBorder.Color = config.BorderColor
                dropdownOptionsBorder.Thickness = 1
                dropdownOptionsBorder.Transparency = 0
                
                local dropdownOptionsLayout = Instance.new("UIListLayout")
                dropdownOptionsLayout.Parent = dropdownOptionsFrame
                dropdownOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownOptionsLayout.Padding = UDim.new(0, 1)
                
                local allOptions = {}
                local selectedOption = nil
                local isOpen = false
                
                local function updateOptionsHeight()
                    local optionCount = #allOptions
                    local optionHeight = isMobile and 32 or 36
                    local maxHeight = isMobile and 160 or 200
                    local totalHeight = math.min(optionCount * optionHeight, maxHeight)
                    
                    services.TweenService:Create(dropdownOptionsFrame, TweenInfo.new(0.2), {
                        Size = UDim2.new(dropdownOptionsFrame.Size.X.Scale, dropdownOptionsFrame.Size.X.Offset, 0, totalHeight)
                    }):Play()
                end
                
                local function toggleDropdown()
                    isOpen = not isOpen
                    dropdownOptionsFrame.Visible = isOpen
                    
                    if isOpen then
                        updateOptionsHeight()
                        services.TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
                            Rotation = 180
                        }):Play()
                    else
                        services.TweenService:Create(dropdownOptionsFrame, TweenInfo.new(0.2), {
                            Size = UDim2.new(dropdownOptionsFrame.Size.X.Scale, dropdownOptionsFrame.Size.X.Offset, 0, 0)
                        }):Play()
                        
                        services.TweenService:Create(dropdownArrow, TweenInfo.new(0.2), {
                            Rotation = 0
                        }):Play()
                    end
                end
                
                local funcs = {}
                
                funcs.AddOption = function(self, optionText, optionValue)
                    optionValue = optionValue or optionText
                    
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "option_" .. optionText
                    optionButton.Parent = dropdownOptionsFrame
                    optionButton.BackgroundColor3 = config.SectionColor
                    optionButton.BackgroundTransparency = 1
                    optionButton.Size = UDim2.new(1, 0, 0, isMobile and 32 or 36)
                    optionButton.Font = Enum.Font.SourceSans
                    optionButton.Text = optionText
                    optionButton.TextColor3 = config.TextColor
                    optionButton.TextSize = isMobile and 14 or 16
                    optionButton.AutoButtonColor = false
                    
                    optionButton.MouseEnter:Connect(function()
                        services.TweenService:Create(optionButton, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.9,
                            BackgroundColor3 = config.SelectedColor
                        }):Play()
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        services.TweenService:Create(optionButton, TweenInfo.new(0.2), {
                            BackgroundTransparency = 1
                        }):Play()
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = {
                            text = optionText,
                            value = optionValue
                        }
                        dropdownButton.Text = optionText
                        dropdownButton.TextColor3 = config.TextColor
                        FengUI.flags[flag] = optionValue
                        callback(optionValue)
                        toggleDropdown()
                    end)
                    
                    table.insert(allOptions, {
                        button = optionButton,
                        text = optionText,
                        value = optionValue
                    })
                    
                    if isOpen then
                        updateOptionsHeight()
                    end
                    
                    return optionButton
                end
                
                funcs.RemoveOption = function(self, optionText)
                    for i, option in ipairs(allOptions) do
                        if option.text == optionText then
                            option.button:Destroy()
                            table.remove(allOptions, i)
                            break
                        end
                    end
                    
                    if isOpen then
                        updateOptionsHeight()
                    end
                end
                
                funcs.SetOptions = function(self, newOptions)
                    -- 清除现有选项
                    for _, option in ipairs(allOptions) do
                        option.button:Destroy()
                    end
                    allOptions = {}
                    
                    -- 添加新选项
                    if type(newOptions) == "table" then
                        for _, option in ipairs(newOptions) do
                            if type(option) == "table" then
                                funcs:AddOption(option.text or option[1], option.value or option[2] or option[1])
                            else
                                funcs:AddOption(option, option)
                            end
                        end
                    end
                    
                    if isOpen then
                        updateOptionsHeight()
                    end
                end
                
                funcs.GetSelected = function(self)
                    return FengUI.flags[flag]
                end
                
                funcs.SetSelected = function(self, value)
                    for _, option in ipairs(allOptions) do
                        if option.value == value then
                            selectedOption = option
                            dropdownButton.Text = option.text
                            dropdownButton.TextColor3 = config.TextColor
                            FengUI.flags[flag] = value
                            break
                        end
                    end
                end
                
                funcs.Clear = function(self)
                    for _, option in ipairs(allOptions) do
                        option.button:Destroy()
                    end
                    allOptions = {}
                    selectedOption = nil
                    dropdownButton.Text = "Select..."
                    dropdownButton.TextColor3 = config.SecondaryTextColor
                    FengUI.flags[flag] = nil
                    
                    if isOpen then
                        updateOptionsHeight()
                    end
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
                
                funcs.IsOpen = function(self)
                    return isOpen
                end
                
                dropdownButton.MouseButton1Click:Connect(function()
                    toggleDropdown()
                end)
                
                -- 点击外部关闭下拉菜单
                local function handleOutsideClick(input)
                    if isOpen and dropdownOptionsFrame.Visible then
                        local mousePos = input.Position
                        local framePos = dropdownOptionsFrame.AbsolutePosition
                        local frameSize = dropdownOptionsFrame.AbsoluteSize
                        
                        if mousePos.X < framePos.X or mousePos.X > framePos.X + frameSize.X or
                           mousePos.Y < framePos.Y or mousePos.Y > framePos.Y + frameSize.Y then
                            toggleDropdown()
                        end
                    end
                end
                
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        handleOutsideClick(input)
                    end
                end)
                
                -- 初始化选项
                funcs:SetOptions(options)
                
                return funcs
            end
            
            function section.ColorPicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                FengUI.flags[flag] = defaultColor
                
                local colorPickerFrame = Instance.new("Frame")
                colorPickerFrame.Name = "colorPicker_" .. flag
                colorPickerFrame.Parent = sectionFrame
                colorPickerFrame.BackgroundTransparency = 1
                colorPickerFrame.Size = UDim2.new(0, WORKAREA_WIDTH - 36, 0, isMobile and 44 or 52)
                
                local colorPickerLabel = Instance.new("TextLabel")
                colorPickerLabel.Name = "colorPickerLabel"
                colorPickerLabel.Parent = colorPickerFrame
                colorPickerLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                colorPickerLabel.BackgroundTransparency = 1
                colorPickerLabel.BorderSizePixel = 2
                colorPickerLabel.Position = UDim2.new(0, 0, 0, 0)
                colorPickerLabel.Size = UDim2.new(0, isMobile and 200 or 300, 0, isMobile and 28 or 37)
                colorPickerLabel.Font = Enum.Font.SourceSans
                colorPickerLabel.Text = text
                colorPickerLabel.TextColor3 = config.TextColor
                colorPickerLabel.TextSize = isMobile and 14 or 16
                colorPickerLabel.TextWrapped = true
                colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local colorPickerButton = Instance.new("TextButton")
                colorPickerButton.Name = "colorPickerButton"
                colorPickerButton.Parent = colorPickerFrame
                colorPickerButton.BackgroundColor3 = config.Bg_Color
                colorPickerButton.BackgroundTransparency = 0.9
                colorPickerButton.Position = UDim2.new(isMobile and 0.5 or 0.7, 0, 0.1, 0)
                colorPickerButton.Size = UDim2.new(0, isMobile and 80 or 100, 0, isMobile and 32 or 36)
                colorPickerButton.Font = Enum.Font.SourceSans
                colorPickerButton.Text = ""
                colorPickerButton.AutoButtonColor = false
                
                local colorPickerCorner = Instance.new("UICorner")
                colorPickerCorner.CornerRadius = UDim.new(0, 8)
                colorPickerCorner.Parent = colorPickerButton
                
                local colorPickerBorder = Instance.new("UIStroke")
                colorPickerBorder.Parent = colorPickerButton
                colorPickerBorder.Color = config.BorderColor
                colorPickerBorder.Thickness = 1
                colorPickerBorder.Transparency = 0
                
                local colorPreview = Instance.new("Frame")
                colorPreview.Name = "colorPreview"
                colorPreview.Parent = colorPickerButton
                colorPreview.BackgroundColor3 = defaultColor
                colorPreview.BorderSizePixel = 0
                colorPreview.Size = UDim2.new(1, -10, 1, -10)
                colorPreview.Position = UDim2.new(0.5, -colorPreview.Size.X.Offset/2, 0.5, -colorPreview.Size.Y.Offset/2)
                colorPreview.AnchorPoint = Vector2.new(0.5, 0.5)
                
                local colorPreviewCorner = Instance.new("UICorner")
                colorPreviewCorner.CornerRadius = UDim.new(0, 4)
                colorPreviewCorner.Parent = colorPreview
                
                -- 颜色选择器弹窗
                local colorPickerPopup = Instance.new("Frame")
                colorPickerPopup.Name = "colorPickerPopup_" .. flag
                colorPickerPopup.Parent = FengYu
                colorPickerPopup.BackgroundColor3 = config.SectionColor
                colorPickerPopup.BackgroundTransparency = 0
                colorPickerPopup.Position = UDim2.new(0.5, -160, 0.5, -130)
                colorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
                colorPickerPopup.Visible = false
                colorPickerPopup.ZIndex = 100
                colorPickerPopup.Active = true
                colorPickerPopup.Draggable = true
                
                local popupCorner = Instance.new("UICorner")
                popupCorner.CornerRadius = UDim.new(0, 16)
                popupCorner.Parent = colorPickerPopup
                
                local popupBorder = Instance.new("UIStroke")
                popupBorder.Parent = colorPickerPopup
                popupBorder.Color = config.BorderColor
                popupBorder.Thickness = 1
                popupBorder.Transparency = 0
                
                local popupTitle = Instance.new("TextLabel")
                popupTitle.Name = "popupTitle"
                popupTitle.Parent = colorPickerPopup
                popupTitle.BackgroundTransparency = 1
                popupTitle.Size = UDim2.new(1, 0, 0, 40)
                popupTitle.Font = Enum.Font.SourceSansSemibold
                popupTitle.Text = "选择颜色"
                popupTitle.TextColor3 = config.TextColor
                popupTitle.TextSize = 18
                popupTitle.TextXAlignment = Enum.TextXAlignment.Center
                
                local closeButton = Instance.new("TextButton")
                closeButton.Name = "closeButton"
                closeButton.Parent = colorPickerPopup
                closeButton.BackgroundTransparency = 1
                closeButton.Size = UDim2.new(0, 40, 0, 40)
                closeButton.Position = UDim2.new(1, -40, 0, 0)
                closeButton.Font = Enum.Font.SourceSansBold
                closeButton.Text = "×"
                closeButton.TextColor3 = config.SecondaryTextColor
                closeButton.TextSize = 24
                
                local hueSlider = Instance.new("Frame")
                hueSlider.Name = "hueSlider"
                hueSlider.Parent = colorPickerPopup
                hueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueSlider.Position = UDim2.new(0.05, 0, 0.2, 0)
                hueSlider.Size = UDim2.new(0.9, 0, 0, 20)
                
                local hueSliderCorner = Instance.new("UICorner")
                hueSliderCorner.CornerRadius = UDim.new(0, 10)
                hueSliderCorner.Parent = hueSlider
                
                local hueGradient = Instance.new("UIGradient")
                hueGradient.Parent = hueSlider
                hueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }
                
                local hueThumb = Instance.new("Frame")
                hueThumb.Name = "hueThumb"
                hueThumb.Parent = hueSlider
                hueThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                hueThumb.BorderSizePixel = 0
                hueThumb.Size = UDim2.new(0, 10, 1, 4)
                hueThumb.Position = UDim2.new(0.5, -5, 0, -2)
                
                local hueThumbCorner = Instance.new("UICorner")
                hueThumbCorner.CornerRadius = UDim.new(0, 5)
                hueThumbCorner.Parent = hueThumb
                
                local hueThumbBorder = Instance.new("UIStroke")
                hueThumbBorder.Parent = hueThumb
                hueThumbBorder.Color = Color3.fromRGB(0, 0, 0)
                hueThumbBorder.Thickness = 2
                
                local colorPreviewLarge = Instance.new("Frame")
                colorPreviewLarge.Name = "colorPreviewLarge"
                colorPreviewLarge.Parent = colorPickerPopup
                colorPreviewLarge.BackgroundColor3 = defaultColor
                colorPreviewLarge.Position = UDim2.new(0.05, 0, 0.4, 0)
                colorPreviewLarge.Size = UDim2.new(0.9, 0, 0, 80)
                
                local colorPreviewCornerLarge = Instance.new("UICorner")
                colorPreviewCornerLarge.CornerRadius = UDim.new(0, 12)
                colorPreviewCornerLarge.Parent = colorPreviewLarge
                
                local confirmButton = Instance.new("TextButton")
                confirmButton.Name = "confirmButton"
                confirmButton.Parent = colorPickerPopup
                confirmButton.BackgroundColor3 = config.AccentColor
                confirmButton.BackgroundTransparency = 0
                confirmButton.Position = UDim2.new(0.05, 0, 0.85, 0)
                confirmButton.Size = UDim2.new(0.9, 0, 0, 40)
                confirmButton.Font = Enum.Font.SourceSansSemibold
                confirmButton.Text = "确认"
                confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                confirmButton.TextSize = 16
                
                local confirmCorner = Instance.new("UICorner")
                confirmCorner.CornerRadius = UDim.new(0, 8)
                confirmCorner.Parent = confirmButton
                
                local currentHue = 0
                local currentColor = defaultColor
                
                local function updateColorFromHue(hue)
                    currentHue = hue
                    currentColor = Color3.fromHSV(hue, 1, 1)
                    colorPreviewLarge.BackgroundColor3 = currentColor
                end
                
                local function setColor(color)
                    currentColor = color
                    colorPreview.BackgroundColor3 = color
                    colorPreviewLarge.BackgroundColor3 = color
                    FengUI.flags[flag] = color
                    
                    -- 更新色调滑块位置
                    local h, s, v = Color3.toHSV(color)
                    if s > 0 or v > 0 then
                        currentHue = h
                        hueThumb.Position = UDim2.new(currentHue, -5, 0, -2)
                    end
                end
                
                -- 初始化颜色
                setColor(defaultColor)
                
                -- 色调滑块交互
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
                
                UserInputService.InputChanged:Connect(function(input)
                    if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouse = services.Players.LocalPlayer:GetMouse()
                        local sliderPos = hueSlider.AbsolutePosition.X
                        local sliderSize = hueSlider.AbsoluteSize.X
                        local mouseX = math.clamp(mouse.X, sliderPos, sliderPos + sliderSize)
                        local hue = (mouseX - sliderPos) / sliderSize
                        
                        currentHue = hue
                        hueThumb.Position = UDim2.new(hue, -5, 0, -2)
                        updateColorFromHue(hue)
                    end
                end)
                
                colorPickerButton.MouseButton1Click:Connect(function()
                    colorPickerPopup.Visible = true
                    colorPickerPopup.Position = UDim2.new(0.5, -160, 0.5, -130)
                end)
                
                closeButton.MouseButton1Click:Connect(function()
                    colorPickerPopup.Visible = false
                end)
                
                confirmButton.MouseButton1Click:Connect(function()
                    setColor(currentColor)
                    callback(currentColor)
                    colorPickerPopup.Visible = false
                end)
                
                local funcs = {
                    SetColor = function(self, color)
                        setColor(color)
                    end,
                    
                    GetColor = function(self)
                        return FengUI.flags[flag]
                    end
                }
                
                return funcs
            end
            
            return section
        end

        -- 标签选择功能
        sidebar2.MouseButton1Click:Connect(function()
            for b, v in next, sections do
                v.BackgroundTransparency = 1
                v.TextColor3 = config.TextColor
                local stroke = v:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = config.BorderColor
                end
            end
            sidebar2.BackgroundTransparency = 0
            sidebar2.BackgroundColor3 = config.SelectedColor
            sidebar2.TextColor3 = config.AccentColor
            local stroke = sidebar2:FindFirstChild("UIStroke")
            if stroke then
                stroke.Color = config.AccentColor
            end
            for b, v in next, workareas do
                v.Visible = false
            end
            workareamain.Visible = true
        end)
        
        -- 默认选择第一个标签
        if #sections == 1 then
            sidebar2.BackgroundTransparency = 0
            sidebar2.BackgroundColor3 = config.SelectedColor
            sidebar2.TextColor3 = config.AccentColor
            local stroke = sidebar2:FindFirstChild("UIStroke")
            if stroke then
                stroke.Color = config.AccentColor
            end
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