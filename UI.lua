repeat
    task.wait()
until game:IsLoaded()

local library = {}
local ToggleUI = false
library.currentTab = nil
library.flags = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
}

-- 高级颜色配置
local config = {
    -- 主色调
    MainColor = Color3.fromRGB(10, 10, 10),
    BgColor = Color3.fromRGB(15, 15, 15),
    TabColor = Color3.fromRGB(20, 20, 20),
    SidebarColor = Color3.fromRGB(25, 25, 25),
    
    -- 强调色 (霓虹渐变)
    AccentColor1 = Color3.fromRGB(37, 254, 152),
    AccentColor2 = Color3.fromRGB(0, 162, 255),
    
    -- 控件颜色
    ButtonColor = Color3.fromRGB(30, 30, 30),
    TextboxColor = Color3.fromRGB(30, 30, 30),
    DropdownColor = Color3.fromRGB(30, 30, 30),
    KeybindColor = Color3.fromRGB(30, 30, 30),
    LabelColor = Color3.fromRGB(30, 30, 30),
    SliderColor = Color3.fromRGB(30, 30, 30),
    
    -- 特殊效果
    SliderBarColor = Color3.fromRGB(37, 254, 152),
    ToggleOnColor = Color3.fromRGB(37, 254, 152),
    ToggleOffColor = Color3.fromRGB(40, 40, 40),
    
    -- 文字颜色
    TextColor = Color3.fromRGB(220, 220, 220),
    AccentTextColor = Color3.fromRGB(37, 254, 152),
    
    -- 阴影设置
    ShadowIntensity = 0.5
}

-- 高级Tween函数
function Tween(obj, t, data)
    local easingStyle = Enum.EasingStyle[t[2]] or Enum.EasingStyle.Quad
    local easingDir = Enum.EasingDirection[t[3]] or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(t[1], easingStyle, easingDir)
    
    local tween = services.TweenService:Create(obj, tweenInfo, data)
    tween:Play()
    return tween
end

-- 改进的Ripple效果
function Ripple(obj)
    spawn(function()
        obj.ClipsDescendants = true
        
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.ZIndex = 10
        Ripple.Image = "rbxassetid://8990984302"  -- 圆形波纹纹理
        Ripple.ImageTransparency = 0.8
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = config.AccentColor1
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        Ripple.Position = UDim2.new(
            (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X,
            0,
            (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y,
            0
        )
        
        Tween(Ripple, {0.4, "Quad", "Out"}, {
            Position = UDim2.new(-0.5, 0, -0.5, 0),
            Size = UDim2.new(2, 0, 2, 0)
        })
        
        Tween(Ripple, {0.3, "Quad", "Out"}, {
            ImageTransparency = 1
        })
        
        wait(0.4)
        Ripple:Destroy()
    end)
end

-- 创建主UI框架
function library.new(name)
    -- 清理旧UI
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "FengYuUI" then
            v:Destroy()
        end
    end

    -- 创建主ScreenGui
    local FengYu = Instance.new("ScreenGui")
    FengYu.Name = "FengYuUI"
    FengYu.ResetOnSpawn = false
    
    -- 保护UI
    if syn and syn.protect_gui then
        syn.protect_gui(FengYu)
    elseif gethui then
        FengYu.Parent = gethui()
    else
        FengYu.Parent = services.CoreGui
    end

    -- 主窗口框架
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = FengYu
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundTransparency = 1
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.ZIndex = 1
    Main.Active = true

    -- 背景容器
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Parent = Main
    Background.BackgroundColor3 = config.MainColor
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 0

    -- 高级背景渐变
    local BackgroundGradient = Instance.new("UIGradient")
    BackgroundGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.MainColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
    })
    BackgroundGradient.Rotation = 90
    BackgroundGradient.Parent = Background

    -- 网格纹理背景
    local GridPattern = Instance.new("ImageLabel")
    GridPattern.Name = "GridPattern"
    GridPattern.Parent = Background
    GridPattern.BackgroundTransparency = 1
    GridPattern.Size = UDim2.new(1, 0, 1, 0)
    GridPattern.Image = "rbxassetid://8990984299"
    GridPattern.ImageTransparency = 0.95
    GridPattern.ImageColor3 = config.AccentColor1
    GridPattern.ScaleType = Enum.ScaleType.Tile
    GridPattern.TileSize = UDim2.new(0, 50, 0, 50)
    GridPattern.ZIndex = 1

    -- 霓虹光效
    local GlowEffect = Instance.new("ImageLabel")
    GlowEffect.Name = "GlowEffect"
    GlowEffect.Parent = Background
    GlowEffect.BackgroundTransparency = 1
    GlowEffect.Size = UDim2.new(1, 100, 1, 100)
    GlowEffect.Position = UDim2.new(-0.5, 0, -0.5, 0)
    GlowEffect.Image = "rbxassetid://8990984300"
    GlowEffect.ImageTransparency = 0.9
    GlowEffect.ImageColor3 = config.AccentColor1
    GlowEffect.ZIndex = -1

    -- 现代阴影效果
    local ModernShadow = Instance.new("ImageLabel")
    ModernShadow.Name = "ModernShadow"
    ModernShadow.Parent = Main
    ModernShadow.BackgroundTransparency = 1
    ModernShadow.Size = UDim2.new(1, 40, 1, 40)
    ModernShadow.Position = UDim2.new(-0.5, 0, -0.5, 0)
    ModernShadow.Image = "rbxassetid://8990984301"
    ModernShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ModernShadow.ScaleType = Enum.ScaleType.Slice
    ModernShadow.SliceCenter = Rect.new(20, 20, 20, 20)
    ModernShadow.ZIndex = -1

    -- 圆角效果
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Background

    -- 侧边栏
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = config.SidebarColor
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.ZIndex = 2

    -- 侧边栏渐变
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.SidebarColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
    })
    SidebarGradient.Rotation = 90
    SidebarGradient.Parent = Sidebar

    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Sidebar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = name or "FengYu HUB"
    Title.TextColor3 = config.AccentTextColor
    Title.TextSize = 18
    Title.ZIndex = 3

    -- 标题装饰线
    local TitleLine = Instance.new("Frame")
    TitleLine.Name = "TitleLine"
    TitleLine.Parent = Sidebar
    TitleLine.BackgroundColor3 = config.AccentColor1
    TitleLine.BorderSizePixel = 0
    TitleLine.Position = UDim2.new(0.1, 0, 0, 50)
    TitleLine.Size = UDim2.new(0.8, 0, 0, 1)
    TitleLine.ZIndex = 3

    -- 标签按钮容器
    local TabButtons = Instance.new("ScrollingFrame")
    TabButtons.Name = "TabButtons"
    TabButtons.Parent = Sidebar
    TabButtons.BackgroundTransparency = 1
    TabButtons.Position = UDim2.new(0, 0, 0, 60)
    TabButtons.Size = UDim2.new(1, 0, 1, -60)
    TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtons.ScrollBarThickness = 0
    TabButtons.ZIndex = 2

    -- 标签页容器
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 125, 0, 10)
    TabContainer.Size = UDim2.new(1, -135, 1, -20)
    TabContainer.ZIndex = 2

    -- 拖拽功能
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- UI控制函数
    function UiDestroy()
        FengYu:Destroy()
    end

    function ToggleUIVisibility()
        FengYu.Enabled = not FengYu.Enabled
    end

    -- 窗口功能
    local window = {}
    
    function window:CreateTab(name, icon)
        -- 标签按钮
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "TabButton"
        TabButton.Parent = TabButtons
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = "  " .. name
        TabButton.TextColor3 = config.TextColor
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.ZIndex = 3
        
        -- 标签页
        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = name .. "Tab"
        TabFrame.Parent = TabContainer
        TabFrame.BackgroundTransparency = 1
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 3
        TabFrame.ZIndex = 2
        
        -- 标签内容布局
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Parent = TabFrame
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 10)
        
        -- 更新标签按钮交互
        TabButton.MouseButton1Click:Connect(function()
            -- 隐藏所有标签页
            for _, tab in ipairs(TabContainer:GetChildren()) do
                if tab:IsA("ScrollingFrame") then
                    tab.Visible = false
                end
            end
            
            -- 显示当前标签页
            TabFrame.Visible = true
            
            -- 更新按钮状态
            for _, btn in ipairs(TabButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.TextColor3 = config.TextColor
                end
            end
            TabButton.TextColor3 = config.AccentTextColor
            
            -- 播放动画
            Tween(TabButton, {0.1, "Quad", "Out"}, {
                TextColor3 = config.AccentTextColor
            })
        end)
        
        -- 如果是第一个标签，默认显示
        if #TabContainer:GetChildren() == 1 then
            TabFrame.Visible = true
            TabButton.TextColor3 = config.AccentTextColor
        end
        
        -- 更新CanvasSize
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- 标签功能
        local tab = {}
        
        function tab:CreateSection(title)
            local Section = Instance.new("Frame")
            Section.Name = title .. "Section"
            Section.Parent = TabFrame
            Section.BackgroundColor3 = config.TabColor
            Section.Size = UDim2.new(1, 0, 0, 40)
            Section.ZIndex = 3
            
            -- 圆角
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = Section
            
            -- 标题
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Parent = Section
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 15, 0, 0)
            SectionTitle.Size = UDim2.new(1, -15, 1, 0)
            SectionTitle.Font = Enum.Font.GothamSemibold
            SectionTitle.Text = title
            SectionTitle.TextColor3 = config.TextColor
            SectionTitle.TextSize = 16
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.ZIndex = 4
            
            -- 内容容器
            local Content = Instance.new("Frame")
            Content.Name = "Content"
            Content.Parent = Section
            Content.BackgroundTransparency = 1
            Content.Position = UDim2.new(0, 0, 0, 40)
            Content.Size = UDim2.new(1, 0, 0, 0)
            Content.ClipsDescendants = true
            Content.ZIndex = 3
            
            -- 内容布局
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Parent = Content
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 5)
            
            -- 切换按钮
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = Section
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.Text = ""
            ToggleButton.ZIndex = 5
            
            local isExpanded = false
            ToggleButton.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                
                if isExpanded then
                    Section.Size = UDim2.new(1, 0, 0, 40 + ContentLayout.AbsoluteContentSize.Y)
                else
                    Section.Size = UDim2.new(1, 0, 0, 40)
                end
            end)
            
            -- 更新内容大小
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isExpanded then
                    Section.Size = UDim2.new(1, 0, 0, 40 + ContentLayout.AbsoluteContentSize.Y)
                end
            end)
            
            -- 分区功能
            local section = {}
            
            function section:AddButton(text, callback)
                local Button = Instance.new("TextButton")
                Button.Name = text .. "Button"
                Button.Parent = Content
                Button.BackgroundColor3 = config.ButtonColor
                Button.Size = UDim2.new(1, 0, 0, 35)
                Button.Font = Enum.Font.Gotham
                Button.Text = "  " .. text
                Button.TextColor3 = config.TextColor
                Button.TextSize = 14
                Button.TextXAlignment = Enum.TextXAlignment.Left
                Button.ZIndex = 4
                
                -- 圆角
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 4)
                Corner.Parent = Button
                
                -- 悬停效果
                Button.MouseEnter:Connect(function()
                    Tween(Button, {0.1, "Quad", "Out"}, {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.ButtonColor.R * 255 + 10),
                            math.floor(config.ButtonColor.G * 255 + 10),
                            math.floor(config.ButtonColor.B * 255 + 10)
                        )
                    })
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {0.1, "Quad", "Out"}, {
                        BackgroundColor3 = config.ButtonColor
                    })
                end)
                
                -- 点击效果
                Button.MouseButton1Click:Connect(function()
                    Ripple(Button)
                    if callback then callback() end
                end)
                
                return Button
            end
            
            -- 其他控件函数 (Toggle, Slider, Dropdown等) 可以按照类似模式添加
            
            return section
        end
        
        return tab
    end
    
    return window
end

return library