repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().ModernUI = {}

-- 性能优化
settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

-- 保护GUI函数
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

-- ModernUI主表
local ModernUI = {}
ModernUI.currentTab = nil
ModernUI.flags = {}
ModernUI.open = true
ModernUI.minimized = false

-- 服务
local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService")
}

-- 高级配色方案
local config = {
    -- 主色调
    Primary = Color3.fromRGB(10, 132, 255),      -- 苹果蓝
    PrimaryDark = Color3.fromRGB(0, 122, 255),   -- 深蓝
    PrimaryLight = Color3.fromRGB(90, 200, 255), -- 浅蓝
    
    -- 背景色
    Background = Color3.fromRGB(18, 18, 24),
    BackgroundLight = Color3.fromRGB(28, 28, 34),
    BackgroundDark = Color3.fromRGB(8, 8, 12),
    
    -- 表面色
    Surface = Color3.fromRGB(28, 28, 34),
    SurfaceHover = Color3.fromRGB(38, 38, 44),
    
    -- 文字色
    TextPrimary = Color3.fromRGB(242, 242, 247),
    TextSecondary = Color3.fromRGB(142, 142, 147),
    TextDisabled = Color3.fromRGB(99, 99, 102),
    
    -- 功能色
    Success = Color3.fromRGB(52, 199, 89),
    Warning = Color3.fromRGB(255, 149, 0),
    Danger = Color3.fromRGB(255, 59, 48),
    Info = Color3.fromRGB(0, 199, 190),
    
    -- 透明度
    Transparency = 0.15,
    HighTransparency = 0.3,
    FullTransparency = 0.95,
    
    -- 边框
    Border = Color3.fromRGB(44, 44, 56),
    BorderLight = Color3.fromRGB(64, 64, 76),
    
    -- 特殊效果
    Glow = Color3.fromRGB(0, 200, 255),
    Hologram = Color3.fromRGB(100, 210, 255),
}

-- 清除旧UI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "ModernUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建主GUI
local ModernUIGui = Instance.new("ScreenGui")
ModernUIGui.Name = "ModernUI"
ModernUIGui.DisplayOrder = 999
protectGUI(ModernUIGui)
ModernUIGui.Parent = services.CoreGui

-- 主容器（悬浮侧边栏）
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = ModernUIGui
MainContainer.AnchorPoint = Vector2.new(0, 0.5)
MainContainer.BackgroundColor3 = config.Background
MainContainer.BackgroundTransparency = config.Transparency
MainContainer.Position = UDim2.new(0, 10, 0.5, 0)
MainContainer.Size = UDim2.new(0, 50, 0, 400)
MainContainer.ZIndex = 100
MainContainer.Visible = true

-- 毛玻璃效果
local blurEffect = Instance.new("BlurEffect")
blurEffect.Parent = MainContainer
blurEffect.Size = 12
blurEffect.Enabled = true

-- 圆角
local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 16)
containerCorner.Parent = MainContainer

-- 边框
local containerStroke = Instance.new("UIStroke")
containerStroke.Parent = MainContainer
containerStroke.Color = config.Border
containerStroke.Thickness = 1
containerStroke.Transparency = 0.3

-- 阴影效果
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Parent = MainContainer
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.ZIndex = -1

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainContainer
TitleBar.BackgroundTransparency = 1
TitleBar.Size = UDim2.new(1, 0, 0, 50)

-- 标题文字
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(1, -15, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "Modern UI"
TitleText.TextColor3 = config.TextPrimary
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 0
TitleText.Rotation = -90
TitleText.AnchorPoint = Vector2.new(0, 1)
TitleText.Position = UDim2.new(0, 15, 0, 350)

-- 切换按钮
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainContainer
ToggleButton.BackgroundColor3 = config.Primary
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.Position = UDim2.new(0.5, 0, 1, -30)
ToggleButton.AnchorPoint = Vector2.new(0.5, 0)
ToggleButton.Size = UDim2.new(0, 30, 0, 30)
ToggleButton.AutoButtonColor = false

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = ToggleButton

local toggleIcon = Instance.new("ImageLabel")
toggleIcon.Name = "Icon"
toggleIcon.Parent = ToggleButton
toggleIcon.BackgroundTransparency = 1
toggleIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
toggleIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
toggleIcon.Image = "rbxassetid://3926305904"
toggleIcon.ImageRectOffset = Vector2.new(964, 324)
toggleIcon.ImageRectSize = Vector2.new(36, 36)
toggleIcon.ImageColor3 = config.TextPrimary

-- 标签按钮容器
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Parent = MainContainer
TabButtons.BackgroundTransparency = 1
TabButtons.Position = UDim2.new(0, 0, 0, 50)
TabButtons.Size = UDim2.new(1, 0, 1, -80)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabButtons
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)

-- 内容容器（展开时显示）
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = ModernUIGui
ContentContainer.AnchorPoint = Vector2.new(0, 0.5)
ContentContainer.BackgroundColor3 = config.Background
ContentContainer.BackgroundTransparency = config.Transparency
ContentContainer.Position = UDim2.new(0, 70, 0.5, 0)
ContentContainer.Size = UDim2.new(0, 320, 0, 400)
ContentContainer.Visible = false
ContentContainer.ZIndex = 99

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 16)
contentCorner.Parent = ContentContainer

local contentStroke = Instance.new("UIStroke")
contentStroke.Parent = ContentContainer
contentStroke.Color = config.Border
contentStroke.Thickness = 1
contentStroke.Transparency = 0.3

local contentShadow = Instance.new("ImageLabel")
contentShadow.Name = "Shadow"
contentShadow.Parent = ContentContainer
contentShadow.BackgroundTransparency = 1
contentShadow.Image = "rbxassetid://5554236805"
contentShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
contentShadow.ImageTransparency = 0.8
contentShadow.ScaleType = Enum.ScaleType.Slice
contentShadow.SliceCenter = Rect.new(10, 10, 118, 118)
contentShadow.Size = UDim2.new(1, 20, 1, 20)
contentShadow.Position = UDim2.new(0, -10, 0, -10)
contentShadow.ZIndex = -1

-- 内容滚动框
local ContentScroller = Instance.new("ScrollingFrame")
ContentScroller.Name = "ContentScroller"
ContentScroller.Parent = ContentContainer
ContentScroller.BackgroundTransparency = 1
ContentScroller.BorderSizePixel = 0
ContentScroller.Size = UDim2.new(1, -20, 1, -20)
ContentScroller.Position = UDim2.new(0, 10, 0, 10)
ContentScroller.ScrollBarThickness = 4
ContentScroller.ScrollBarImageColor3 = config.TextSecondary
ContentScroller.ScrollBarImageTransparency = 0.5
ContentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentScroller
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 12)

-- 自动调整滚动框大小
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroller.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)

-- 悬浮提示系统
local TooltipSystem = Instance.new("Frame")
TooltipSystem.Name = "TooltipSystem"
TooltipSystem.Parent = ModernUIGui
TooltipSystem.BackgroundColor3 = config.BackgroundDark
TooltipSystem.BackgroundTransparency = 0.1
TooltipSystem.Size = UDim2.new(0, 200, 0, 60)
TooltipSystem.Position = UDim2.new(0, 100, 0, 100)
TooltipSystem.Visible = false
TooltipSystem.ZIndex = 1000

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 8)
tooltipCorner.Parent = TooltipSystem

local tooltipTitle = Instance.new("TextLabel")
tooltipTitle.Name = "Title"
tooltipTitle.Parent = TooltipSystem
tooltipTitle.BackgroundTransparency = 1
tooltipTitle.Position = UDim2.new(0, 10, 0, 8)
tooltipTitle.Size = UDim2.new(1, -20, 0, 20)
tooltipTitle.Font = Enum.Font.GothamBold
tooltipTitle.Text = "提示"
tooltipTitle.TextColor3 = config.TextPrimary
tooltipTitle.TextSize = 14
tooltipTitle.TextXAlignment = Enum.TextXAlignment.Left

local tooltipDesc = Instance.new("TextLabel")
tooltipDesc.Name = "Description"
tooltipDesc.Parent = TooltipSystem
tooltipDesc.BackgroundTransparency = 1
tooltipDesc.Position = UDim2.new(0, 10, 0, 30)
tooltipDesc.Size = UDim2.new(1, -20, 0, 20)
tooltipDesc.Font = Enum.Font.Gotham
tooltipDesc.Text = "描述信息"
tooltipDesc.TextColor3 = config.TextSecondary
tooltipDesc.TextSize = 12
tooltipDesc.TextXAlignment = Enum.TextXAlignment.Left
tooltipDesc.TextWrapped = true

-- 显示提示函数
local function showTooltip(title, description, position)
    if not title then
        TooltipSystem.Visible = false
        return
    end
    
    tooltipTitle.Text = title
    tooltipDesc.Text = description
    
    -- 计算大小
    local textSize = game:GetService("TextService"):GetTextSize(
        description,
        12,
        Enum.Font.Gotham,
        Vector2.new(180, 1000)
    )
    
    TooltipSystem.Size = UDim2.new(0, 200, 0, math.max(60, textSize.Y + 40))
    TooltipSystem.Position = UDim2.new(0, position.X, 0, position.Y + 20)
    TooltipSystem.Visible = true
end

-- 动画切换UI状态
local function toggleUI()
    ModernUI.minimized = not ModernUI.minimized
    
    if ModernUI.minimized then
        -- 最小化：只显示侧边栏
        services.TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 400)
        }):Play()
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        
        ContentContainer.Visible = false
        toggleIcon.ImageRectOffset = Vector2.new(4, 484) -- 右箭头
    else
        -- 展开：显示内容区域
        services.TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 70, 0, 400)
        }):Play()
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = 1
        }):Play()
        
        ContentContainer.Visible = true
        toggleIcon.ImageRectOffset = Vector2.new(964, 324) -- 左箭头
    end
end

-- 切换按钮事件
ToggleButton.MouseButton1Click:Connect(function()
    toggleUI()
end)

ToggleButton.MouseEnter:Connect(function()
    services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0
    }):Play()
end)

ToggleButton.MouseLeave:Connect(function()
    services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.1
    }):Play()
end)

-- 全局快捷键：Ctrl+Shift+P
services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P and 
       services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and
       services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        toggleUI()
    end
end)

-- 创建标签按钮的函数
function ModernUI.new(windowName, theme)
    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end
    
    local window = {}
    local tabs = {}
    
    function window:Tab(tabName, tabIcon)
        local tabData = {}
        tabData.name = tabName
        tabData.icon = tabIcon or "rbxassetid://3926305904"
        tabData.sections = {}
        
        -- 创建标签按钮
        local TabButton = Instance.new("ImageButton")
        TabButton.Name = "TabButton_" .. tabName
        TabButton.Parent = TabButtons
        TabButton.BackgroundColor3 = config.Surface
        TabButton.BackgroundTransparency = 0.8
        TabButton.Size = UDim2.new(0, 40, 0, 40)
        TabButton.AutoButtonColor = false
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 10)
        tabCorner.Parent = TabButton
        
        local tabIconLabel = Instance.new("ImageLabel")
        tabIconLabel.Name = "Icon"
        tabIconLabel.Parent = TabButton
        tabIconLabel.BackgroundTransparency = 1
        tabIconLabel.Size = UDim2.new(0.6, 0, 0.6, 0)
        tabIconLabel.Position = UDim2.new(0.2, 0, 0.2, 0)
        tabIconLabel.Image = tabData.icon
        tabIconLabel.ImageColor3 = config.TextSecondary
        
        -- 标签内容容器
        local TabContent = Instance.new("Frame")
        TabContent.Name = "TabContent_" .. tabName
        TabContent.Parent = ContentScroller
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 0, 0)
        TabContent.Visible = false
        
        -- 鼠标交互效果
        TabButton.MouseEnter:Connect(function()
            if ModernUI.currentTab ~= tabData then
                services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.6,
                    Size = UDim2.new(0, 42, 0, 42)
                }):Play()
                
                services.TweenService:Create(tabIconLabel, TweenInfo.new(0.2), {
                    ImageColor3 = config.TextPrimary
                }):Play()
                
                showTooltip(tabName, "点击打开此标签", TabButton.AbsolutePosition)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if ModernUI.currentTab ~= tabData then
                services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.8,
                    Size = UDim2.new(0, 40, 0, 40)
                }):Play()
                
                services.TweenService:Create(tabIconLabel, TweenInfo.new(0.2), {
                    ImageColor3 = config.TextSecondary
                }):Play()
                
                showTooltip()
            end
        end)
        
        -- 切换标签
        TabButton.MouseButton1Click:Connect(function()
            if ModernUI.currentTab == tabData then return end
            
            -- 更新当前标签
            if ModernUI.currentTab then
                -- 隐藏旧标签内容
                ModernUI.currentTab.content.Visible = false
                
                -- 重置旧标签按钮样式
                local oldButton = TabButtons:FindFirstChild("TabButton_" .. ModernUI.currentTab.name)
                if oldButton then
                    services.TweenService:Create(oldButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Surface,
                        BackgroundTransparency = 0.8,
                        Size = UDim2.new(0, 40, 0, 40)
                    }):Play()
                    
                    local oldIcon = oldButton:FindFirstChild("Icon")
                    if oldIcon then
                        services.TweenService:Create(oldIcon, TweenInfo.new(0.2), {
                            ImageColor3 = config.TextSecondary
                        }):Play()
                    end
                end
            end
            
            -- 设置新标签
            ModernUI.currentTab = tabData
            TabContent.Visible = true
            
            -- 更新标签按钮样式
            services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = config.Primary,
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 44, 0, 44)
            }):Play()
            
            services.TweenService:Create(tabIconLabel, TweenInfo.new(0.2), {
                ImageColor3 = config.TextPrimary
            }):Play()
            
            showTooltip()
        end)
        
        -- 存储标签数据
        tabData.button = TabButton
        tabData.content = TabContent
        tabData.sectionContainer = TabContent
        tabs[tabName] = tabData
        
        -- 如果是第一个标签，自动选中
        if not ModernUI.currentTab then
            TabButton.MouseButton1Click:Fire()
        end
        
        local tab = {}
        
        function tab:Section(sectionName)
            local sectionData = {}
            
            -- 创建分区
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section_" .. sectionName
            SectionFrame.Parent = TabContent
            SectionFrame.BackgroundColor3 = config.Surface
            SectionFrame.BackgroundTransparency = 0.2
            SectionFrame.Size = UDim2.new(1, 0, 0, 40)
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 12)
            sectionCorner.Parent = SectionFrame
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Parent = SectionFrame
            sectionStroke.Color = config.BorderLight
            sectionStroke.Thickness = 1
            sectionStroke.Transparency = 0.5
            
            -- 分区标题
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Parent = SectionFrame
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 15, 0, 0)
            SectionTitle.Size = UDim2.new(1, -30, 0, 40)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = config.TextPrimary
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 控件容器
            local ControlsContainer = Instance.new("Frame")
            ControlsContainer.Name = "Controls"
            ControlsContainer.Parent = SectionFrame
            ControlsContainer.BackgroundTransparency = 1
            ControlsContainer.Position = UDim2.new(0, 0, 0, 45)
            ControlsContainer.Size = UDim2.new(1, 0, 0, 0)
            ControlsContainer.Visible = true
            
            local controlsLayout = Instance.new("UIListLayout")
            controlsLayout.Parent = ControlsContainer
            controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            controlsLayout.Padding = UDim.new(0, 8)
            
            -- 自动调整分区大小
            controlsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local contentHeight = controlsLayout.AbsoluteContentSize.Y
                ControlsContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                SectionFrame.Size = UDim2.new(1, 0, 0, 45 + contentHeight + 10)
            end)
            
            local section = {}
            
            -- 创建按钮控件
            function section:Button(buttonText, callback, tooltip)
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = "Button_" .. buttonText
                ButtonFrame.Parent = ControlsContainer
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
                
                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.Parent = ButtonFrame
                Button.BackgroundColor3 = config.Primary
                Button.BackgroundTransparency = 0.1
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.AutoButtonColor = false
                Button.Font = Enum.Font.GothamBold
                Button.Text = buttonText
                Button.TextColor3 = config.TextPrimary
                Button.TextSize = 14
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)
                buttonCorner.Parent = Button
                
                -- 悬停效果
                Button.MouseEnter:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 2, 1, 2),
                        Position = UDim2.new(0, -1, 0, -1)
                    }):Play()
                    
                    if tooltip then
                        showTooltip(buttonText, tooltip, Button.AbsolutePosition)
                    end
                end)
                
                Button.MouseLeave:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                    
                    showTooltip()
                end)
                
                -- 点击效果
                Button.MouseButton1Click:Connect(function()
                    -- 点击动画
                    services.TweenService:Create(Button, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3,
                        Size = UDim2.new(1, -4, 1, -4),
                        Position = UDim2.new(0, 2, 0, 2)
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                    
                    -- 执行回调
                    if callback then
                        callback()
                    end
                end)
            end
            
            -- 创建开关控件
            function section:Toggle(toggleText, defaultValue, callback, tooltip)
                local toggleFlag = toggleText:gsub("%s+", "_")
                ModernUI.flags[toggleFlag] = defaultValue or false
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = "Toggle_" .. toggleText
                ToggleFrame.Parent = ControlsContainer
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = ToggleFrame
                ToggleButton.BackgroundColor3 = config.SurfaceHover
                ToggleButton.BackgroundTransparency = 0.2
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.AutoButtonColor = false
                ToggleButton.Font = Enum.Font.Gotham
                ToggleButton.Text = "   " .. toggleText
                ToggleButton.TextColor3 = config.TextPrimary
                ToggleButton.TextSize = 14
                ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 8)
                toggleCorner.Parent = ToggleButton
                
                -- 开关指示器
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "Indicator"
                ToggleIndicator.Parent = ToggleButton
                ToggleIndicator.AnchorPoint = Vector2.new(1, 0.5)
                ToggleIndicator.BackgroundColor3 = defaultValue and config.Success or config.TextDisabled
                ToggleIndicator.Position = UDim2.new(1, -15, 0.5, 0)
                ToggleIndicator.Size = UDim2.new(0, 24, 0, 14)
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(1, 0)
                indicatorCorner.Parent = ToggleIndicator
                
                local ToggleKnob = Instance.new("Frame")
                ToggleKnob.Name = "Knob"
                ToggleKnob.Parent = ToggleIndicator
                ToggleKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                ToggleKnob.BackgroundColor3 = config.TextPrimary
                ToggleKnob.Position = UDim2.new(defaultValue and 0.75 or 0.25, 0, 0.5, 0)
                ToggleKnob.Size = UDim2.new(0, 10, 0, 10)
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = ToggleKnob
                
                -- 悬停效果
                ToggleButton.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                    
                    if tooltip then
                        showTooltip(toggleText, tooltip, ToggleButton.AbsolutePosition)
                    end
                end)
                
                ToggleButton.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.2
                    }):Play()
                    
                    showTooltip()
                end)
                
                -- 切换状态函数
                local function setState(newState)
                    local state = newState or not ModernUI.flags[toggleFlag]
                    ModernUI.flags[toggleFlag] = state
                    
                    services.TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = state and config.Success or config.TextDisabled
                    }):Play()
                    
                    services.TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                        Position = UDim2.new(state and 0.75 or 0.25, 0, 0.5, 0)
                    }):Play()
                    
                    if callback then
                        callback(state)
                    end
                end
                
                -- 点击切换
                ToggleButton.MouseButton1Click:Connect(function()
                    setState()
                end)
                
                -- 返回控制函数
                local toggleControl = {}
                
                function toggleControl:Set(state)
                    setState(state)
                end
                
                function toggleControl:Get()
                    return ModernUI.flags[toggleFlag]
                end
                
                function toggleControl:Toggle()
                    setState()
                end
                
                return toggleControl
            end
            
            -- 创建滑块控件
            function section:Slider(sliderText, minValue, maxValue, defaultValue, callback, tooltip)
                local sliderFlag = sliderText:gsub("%s+", "_")
                local value = defaultValue or minValue
                ModernUI.flags[sliderFlag] = value
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = "Slider_" .. sliderText
                SliderFrame.Parent = ControlsContainer
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Size = UDim2.new(1, 0, 0, 60)
                
                -- 标题
                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Name = "Title"
                SliderTitle.Parent = SliderFrame
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Position = UDim2.new(0, 0, 0, 0)
                SliderTitle.Size = UDim2.new(1, 0, 0, 20)
                SliderTitle.Font = Enum.Font.Gotham
                SliderTitle.Text = sliderText .. ": " .. value
                SliderTitle.TextColor3 = config.TextPrimary
                SliderTitle.TextSize = 14
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 滑块背景
                local SliderBackground = Instance.new("Frame")
                SliderBackground.Name = "Background"
                SliderBackground.Parent = SliderFrame
                SliderBackground.BackgroundColor3 = config.SurfaceHover
                SliderBackground.BackgroundTransparency = 0.3
                SliderBackground.Position = UDim2.new(0, 0, 0, 25)
                SliderBackground.Size = UDim2.new(1, 0, 0, 8)
                
                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(1, 0)
                bgCorner.Parent = SliderBackground
                
                -- 滑块填充
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Parent = SliderBackground
                SliderFill.BackgroundColor3 = config.Primary
                SliderFill.Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0)
                
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(1, 0)
                fillCorner.Parent = SliderFill
                
                -- 滑块手柄
                local SliderHandle = Instance.new("Frame")
                SliderHandle.Name = "Handle"
                SliderHandle.Parent = SliderBackground
                SliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderHandle.BackgroundColor3 = config.TextPrimary
                SliderHandle.Position = UDim2.new((value - minValue) / (maxValue - minValue), 0, 0.5, 0)
                SliderHandle.Size = UDim2.new(0, 16, 0, 16)
                
                local handleCorner = Instance.new("UICorner")
                handleCorner.CornerRadius = UDim.new(1, 0)
                handleCorner.Parent = SliderHandle
                
                local dragging = false
                
                -- 更新值函数
                local function updateValue(newValue)
                    newValue = math.clamp(newValue, minValue, maxValue)
                    value = newValue
                    ModernUI.flags[sliderFlag] = value
                    
                    local percent = (value - minValue) / (maxValue - minValue)
                    
                    services.TweenService:Create(SliderFill, TweenInfo.new(0.1), {
                        Size = UDim2.new(percent, 0, 1, 0)
                    }):Play()
                    
                    services.TweenService:Create(SliderHandle, TweenInfo.new(0.1), {
                        Position = UDim2.new(percent, 0, 0.5, 0)
                    }):Play()
                    
                    SliderTitle.Text = sliderText .. ": " .. value
                    
                    if callback then
                        callback(value)
                    end
                end
                
                -- 鼠标拖动
                local function onInputChanged(input)
                    if dragging then
                        local mousePos = input.Position
                        local sliderPos = SliderBackground.AbsolutePosition
                        local sliderSize = SliderBackground.AbsoluteSize
                        
                        local relativeX = (mousePos.X - sliderPos.X) / sliderSize.X
                        relativeX = math.clamp(relativeX, 0, 1)
                        
                        local newValue = minValue + (maxValue - minValue) * relativeX
                        updateValue(newValue)
                    end
                end
                
                -- 开始拖动
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        onInputChanged(input)
                    end
                end)
                
                -- 结束拖动
                services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                -- 拖动中
                services.UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        onInputChanged(input)
                    end
                end)
                
                -- 悬停提示
                SliderBackground.MouseEnter:Connect(function()
                    if tooltip then
                        showTooltip(sliderText, tooltip, SliderBackground.AbsolutePosition)
                    end
                end)
                
                SliderBackground.MouseLeave:Connect(function()
                    showTooltip()
                end)
                
                -- 控制函数
                local sliderControl = {}
                
                function sliderControl:Set(newValue)
                    updateValue(newValue)
                end
                
                function sliderControl:Get()
                    return value
                end
                
                return sliderControl
            end
            
            -- 创建下拉框
            function section:Dropdown(dropdownText, options, defaultIndex, callback, tooltip)
                local dropdownFlag = dropdownText:gsub("%s+", "_")
                local selectedIndex = defaultIndex or 1
                local selectedValue = options[selectedIndex]
                ModernUI.flags[dropdownFlag] = selectedValue
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = "Dropdown_" .. dropdownText
                DropdownFrame.Parent = ControlsContainer
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = DropdownFrame
                DropdownButton.BackgroundColor3 = config.SurfaceHover
                DropdownButton.BackgroundTransparency = 0.2
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.AutoButtonColor = false
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Text = dropdownText .. ": " .. selectedValue
                DropdownButton.TextColor3 = config.TextPrimary
                DropdownButton.TextSize = 14
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                
                local dropdownCorner = Instance.new("UICorner")
                dropdownCorner.CornerRadius = UDim.new(0, 8)
                dropdownCorner.Parent = DropdownButton
                
                local DropdownIcon = Instance.new("ImageLabel")
                DropdownIcon.Name = "Icon"
                DropdownIcon.Parent = DropdownButton
                DropdownIcon.AnchorPoint = Vector2.new(1, 0.5)
                DropdownIcon.BackgroundTransparency = 1
                DropdownIcon.Position = UDim2.new(1, -15, 0.5, 0)
                DropdownIcon.Size = UDim2.new(0, 16, 0, 16)
                DropdownIcon.Image = "rbxassetid://3926305904"
                DropdownIcon.ImageRectOffset = Vector2.new(284, 364)
                DropdownIcon.ImageRectSize = Vector2.new(24, 24)
                DropdownIcon.ImageColor3 = config.TextSecondary
                
                -- 下拉选项容器
                local OptionsContainer = Instance.new("Frame")
                OptionsContainer.Name = "Options"
                OptionsContainer.Parent = ModernUIGui
                OptionsContainer.BackgroundColor3 = config.BackgroundDark
                OptionsContainer.BackgroundTransparency = 0.1
                OptionsContainer.Size = UDim2.new(0, 200, 0, 0)
                OptionsContainer.Position = UDim2.new(0, 0, 0, 0)
                OptionsContainer.Visible = false
                OptionsContainer.ZIndex = 1001
                
                local optionsCorner = Instance.new("UICorner")
                optionsCorner.CornerRadius = UDim.new(0, 8)
                optionsCorner.Parent = OptionsContainer
                
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.Parent = OptionsContainer
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                local open = false
                
                -- 显示/隐藏选项
                local function toggleOptions()
                    open = not open
                    
                    if open then
                        -- 创建选项按钮
                        for i, option in ipairs(options) do
                            local OptionButton = Instance.new("TextButton")
                            OptionButton.Name = "Option_" .. i
                            OptionButton.Parent = OptionsContainer
                            OptionButton.BackgroundColor3 = i == selectedIndex and config.Primary or config.Surface
                            OptionButton.BackgroundTransparency = i == selectedIndex and 0.2 or 0.5
                            OptionButton.Size = UDim2.new(1, 0, 0, 32)
                            OptionButton.AutoButtonColor = false
                            OptionButton.Font = Enum.Font.Gotham
                            OptionButton.Text = option
                            OptionButton.TextColor3 = config.TextPrimary
                            OptionButton.TextSize = 14
                            
                            local optionCorner = Instance.new("UICorner")
                            optionCorner.CornerRadius = UDim.new(0, 6)
                            optionCorner.Parent = OptionButton
                            
                            -- 选择选项
                            OptionButton.MouseButton1Click:Connect(function()
                                selectedIndex = i
                                selectedValue = option
                                ModernUI.flags[dropdownFlag] = selectedValue
                                DropdownButton.Text = dropdownText .. ": " .. selectedValue
                                
                                if callback then
                                    callback(selectedValue, i)
                                end
                                
                                toggleOptions()
                            end)
                            
                            -- 悬停效果
                            OptionButton.MouseEnter:Connect(function()
                                if i ~= selectedIndex then
                                    services.TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                                        BackgroundTransparency = 0.3
                                    }):Play()
                                end
                            end)
                            
                            OptionButton.MouseLeave:Connect(function()
                                if i ~= selectedIndex then
                                    services.TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                                        BackgroundTransparency = 0.5
                                    }):Play()
                                end
                            end)
                        end
                        
                        -- 更新容器大小和位置
                        OptionsContainer.Size = UDim2.new(0, 200, 0, #options * 32 + 10)
                        OptionsContainer.Position = UDim2.new(
                            0, DropdownButton.AbsolutePosition.X,
                            0, DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y + 5
                        )
                        
                        OptionsContainer.Visible = true
                        
                        -- 旋转图标
                        services.TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                            Rotation = 180
                        }):Play()
                    else
                        OptionsContainer.Visible = false
                        OptionsContainer:ClearAllChildren()
                        
                        services.TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                            Rotation = 0
                        }):Play()
                    end
                end
                
                -- 点击打开下拉
                DropdownButton.MouseButton1Click:Connect(function()
                    toggleOptions()
                end)
                
                -- 悬停效果
                DropdownButton.MouseEnter:Connect(function()
                    services.TweenService:Create(DropdownButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                    
                    if tooltip then
                        showTooltip(dropdownText, tooltip, DropdownButton.AbsolutePosition)
                    end
                end)
                
                DropdownButton.MouseLeave:Connect(function()
                    services.TweenService:Create(DropdownButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.2
                    }):Play()
                    
                    showTooltip()
                end)
                
                -- 点击其他地方关闭下拉
                services.UserInputService.InputBegan:Connect(function(input)
                    if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = input.Position
                        local dropdownPos = DropdownButton.AbsolutePosition
                        local dropdownSize = DropdownButton.AbsoluteSize
                        
                        -- 检查是否点击了下拉按钮之外的地方
                        if mousePos.X < dropdownPos.X or 
                           mousePos.X > dropdownPos.X + dropdownSize.X or
                           mousePos.Y < dropdownPos.Y or 
                           mousePos.Y > dropdownPos.Y + dropdownSize.Y + OptionsContainer.AbsoluteSize.Y then
                            toggleOptions()
                        end
                    end
                end)
                
                -- 控制函数
                local dropdownControl = {}
                
                function dropdownControl:Select(index)
                    if index >= 1 and index <= #options then
                        selectedIndex = index
                        selectedValue = options[index]
                        ModernUI.flags[dropdownFlag] = selectedValue
                        DropdownButton.Text = dropdownText .. ": " .. selectedValue
                        
                        if callback then
                            callback(selectedValue, index)
                        end
                    end
                end
                
                function dropdownControl:Get()
                    return selectedValue, selectedIndex
                end
                
                function dropdownControl:UpdateOptions(newOptions)
                    options = newOptions
                    if selectedIndex > #options then
                        dropdownControl:Select(1)
                    end
                end
                
                return dropdownControl
            end
            
            -- 创建文本框
            function section:Textbox(textboxText, placeholder, defaultValue, callback, tooltip)
                local textboxFlag = textboxText:gsub("%s+", "_")
                local value = defaultValue or ""
                ModernUI.flags[textboxFlag] = value
                
                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Name = "Textbox_" .. textboxText
                TextboxFrame.Parent = ControlsContainer
                TextboxFrame.BackgroundTransparency = 1
                TextboxFrame.Size = UDim2.new(1, 0, 0, 50)
                
                -- 标题
                local TextboxTitle = Instance.new("TextLabel")
                TextboxTitle.Name = "Title"
                TextboxTitle.Parent = TextboxFrame
                TextboxTitle.BackgroundTransparency = 1
                TextboxTitle.Position = UDim2.new(0, 0, 0, 0)
                TextboxTitle.Size = UDim2.new(1, 0, 0, 20)
                TextboxTitle.Font = Enum.Font.Gotham
                TextboxTitle.Text = textboxText
                TextboxTitle.TextColor3 = config.TextPrimary
                TextboxTitle.TextSize = 14
                TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 输入框
                local TextboxInput = Instance.new("TextBox")
                TextboxInput.Name = "Input"
                TextboxInput.Parent = TextboxFrame
                TextboxInput.BackgroundColor3 = config.SurfaceHover
                TextboxInput.BackgroundTransparency = 0.2
                TextboxInput.Position = UDim2.new(0, 0, 0, 25)
                TextboxInput.Size = UDim2.new(1, 0, 0, 25)
                TextboxInput.Font = Enum.Font.Gotham
                TextboxInput.Text = value
                TextboxInput.PlaceholderText = placeholder or "输入文本..."
                TextboxInput.TextColor3 = config.TextPrimary
                TextboxInput.PlaceholderColor3 = config.TextSecondary
                TextboxInput.TextSize = 14
                TextboxInput.ClearTextOnFocus = false
                
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 8)
                inputCorner.Parent = TextboxInput
                
                -- 悬停效果
                TextboxInput.MouseEnter:Connect(function()
                    services.TweenService:Create(TextboxInput, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                    
                    if tooltip then
                        showTooltip(textboxText, tooltip, TextboxInput.AbsolutePosition)
                    end
                end)
                
                TextboxInput.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxInput, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.2
                    }):Play()
                    
                    showTooltip()
                end)
                
                -- 聚焦效果
                TextboxInput.Focused:Connect(function()
                    services.TweenService:Create(TextboxInput, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Primary,
                        BackgroundTransparency = 0.3
                    }):Play()
                end)
                
                TextboxInput.FocusLost:Connect(function()
                    services.TweenService:Create(TextboxInput, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.SurfaceHover,
                        BackgroundTransparency = 0.2
                    }):Play()
                    
                    value = TextboxInput.Text
                    ModernUI.flags[textboxFlag] = value
                    
                    if callback then
                        callback(value)
                    end
                end)
                
                -- 控制函数
                local textboxControl = {}
                
                function textboxControl:Set(newValue)
                    TextboxInput.Text = newValue
                    value = newValue
                    ModernUI.flags[textboxFlag] = value
                end
                
                function textboxControl:Get()
                    return value
                end
                
                function textboxControl:Clear()
                    textboxControl:Set("")
                end
                
                return textboxControl
            end
            
            -- 创建标签
            function section:Label(labelText, description)
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Name = "Label_" .. labelText
                LabelFrame.Parent = ControlsContainer
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Size = UDim2.new(1, 0, 0, description and 40 or 25)
                
                -- 主标签
                local MainLabel = Instance.new("TextLabel")
                MainLabel.Name = "MainLabel"
                MainLabel.Parent = LabelFrame
                MainLabel.BackgroundTransparency = 1
                MainLabel.Position = UDim2.new(0, 0, 0, 0)
                MainLabel.Size = UDim2.new(1, 0, 0, 20)
                MainLabel.Font = Enum.Font.GothamBold
                MainLabel.Text = labelText
                MainLabel.TextColor3 = config.TextPrimary
                MainLabel.TextSize = 14
                MainLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 描述文本
                if description then
                    local DescLabel = Instance.new("TextLabel")
                    DescLabel.Name = "Description"
                    DescLabel.Parent = LabelFrame
                    DescLabel.BackgroundTransparency = 1
                    DescLabel.Position = UDim2.new(0, 0, 0, 20)
                    DescLabel.Size = UDim2.new(1, 0, 0, 20)
                    DescLabel.Font = Enum.Font.Gotham
                    DescLabel.Text = description
                    DescLabel.TextColor3 = config.TextSecondary
                    DescLabel.TextSize = 12
                    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
                    DescLabel.TextWrapped = true
                end
            end
            
            return section
        end
        
        return tab
    end
    
    -- 销毁UI
    function window:Destroy()
        ModernUIGui:Destroy()
    end
    
    -- 显示/隐藏UI
    function window:Toggle(visible)
        if visible == nil then
            ModernUI.open = not ModernUI.open
        else
            ModernUI.open = visible
        end
        
        MainContainer.Visible = ModernUI.open
        ContentContainer.Visible = ModernUI.open and not ModernUI.minimized
    end
    
    -- 获取标志值
    function window:GetFlag(flag)
        return ModernUI.flags[flag]
    end
    
    -- 设置标志值
    function window:SetFlag(flag, value)
        ModernUI.flags[flag] = value
    end
    
    return window
end

-- 全局访问
if not getgenv then getgenv = function() return _G end end
getgenv().ModernUI = ModernUI

return ModernUI