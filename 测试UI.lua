repeat
    task.wait()
until game:IsLoaded()

settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

local isSynapse = syn and syn.protect_gui ~= nil
local isScriptWare = secure_load ~= nil
local isKrnl = krnl and krnl.protect_gui ~= nil
local isFluxus = fluxus and fluxus.protect_gui ~= nil
local isElectron = is_sirhurt_closure ~= nil
local isComet = comet and comet.protect_gui ~= nil
local isOxygen = getexecutorname and getexecutorname():lower():find("oxygen") ~= nil
local isAlus = alus and alus.protect_gui ~= nil
local isXeno = xeno and xeno.protect_gui ~= nil

local function protectGUI(gui)
    if isSynapse then
        syn.protect_gui(gui)
    elseif isScriptWare then
        secure_load(gui)
    elseif isKrnl then
        krnl.protect_gui(gui)
    elseif isFluxus then
        fluxus.protect_gui(gui)
    elseif isElectron then
        protect_gui(gui)
    elseif isComet then
        comet.protect_gui(gui)
    elseif isOxygen then
        protect_gui(gui)
    elseif isAlus then
        alus.protect_gui(gui)
    elseif isXeno then
        xeno.protect_gui(gui)
    end
    
    local success, err = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("RobloxGui", gui)
    end
end

local FengY3 = {}
local ToggleUI = true
FengY3.currentTab = nil
FengY3.flaFengYu = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

-- 现代化配色方案
local config = {
    MainColor = Color3.fromRGB(10, 10, 12),
    TabColor = Color3.fromRGB(18, 18, 22),
    Bg_Color = Color3.fromRGB(14, 14, 18),
    Zy_Color = Color3.fromRGB(14, 14, 18), 
    Button_Color = Color3.fromRGB(25, 25, 32),
    Textbox_Color = Color3.fromRGB(25, 25, 32),
    Dropdown_Color = Color3.fromRGB(25, 25, 32),
    Keybind_Color = Color3.fromRGB(25, 25, 32),
    Label_Color = Color3.fromRGB(25, 25, 32),
    Slider_Color = Color3.fromRGB(25, 25, 32),
    SliderBar_Color = Color3.fromRGB(120, 220, 255),
    Toggle_Color = Color3.fromRGB(25, 25, 32),
    Toggle_Off = Color3.fromRGB(40, 40, 50),
    Toggle_On = Color3.fromRGB(120, 220, 255),
    AccentColor = Color3.fromRGB(120, 220, 255),
    TextColor = Color3.fromRGB(240, 240, 245),
    SecondaryTextColor = Color3.fromRGB(160, 160, 170),
    GlowColor = Color3.fromRGB(100, 180, 255),
    BorderColor = Color3.fromRGB(50, 50, 60),
    HeaderColor = Color3.fromRGB(20, 20, 25),
    SuccessColor = Color3.fromRGB(85, 255, 170),
    WarningColor = Color3.fromRGB(255, 200, 80),
    ErrorColor = Color3.fromRGB(255, 100, 100)
}

-- 现代化彩虹效果
local function startRainbowEffect(object, property, speed)
    speed = speed or 0.005
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + speed) % 1
        -- 使用更柔和的饱和度
        object[property] = Color3.fromHSV(hue, 0.6, 0.9)
    end)
    return connection
end

-- 现代化极光效果
local function createAuroraEffect(frame, intensity)
    intensity = intensity or 0.5
    
    local aurora = Instance.new("Frame")
    aurora.Name = "AuroraEffect"
    aurora.BackgroundTransparency = 1
    aurora.Size = UDim2.new(2, 0, 2, 0)
    aurora.ZIndex = frame.ZIndex - 1
    aurora.Parent = frame
    aurora.ClipsDescendants = true
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.1 * intensity),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    gradient.Parent = aurora
    
    -- 更现代化的渐变色
    local colors = {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 180, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(120, 220, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140, 240, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(120, 220, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 255))
    }
    
    gradient.Color = ColorSequence.new(colors)
    
    local sizeConnection
    sizeConnection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        aurora.Size = UDim2.new(2, 0, 2, 0)
    end)
    
    local xOffset = 0
    local yOffset = 0
    local xDir = 1
    local yDir = 1
    local xSpeed = 0.3
    local ySpeed = 0.2
    
    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function(delta)
        if not aurora or not aurora.Parent then
            heartbeatConnection:Disconnect()
            sizeConnection:Disconnect()
            return
        end
        
        xOffset = (xOffset + xSpeed * delta * xDir) % 1
        yOffset = (yOffset + ySpeed * delta * yDir) % 1
        
        if xOffset >= 0.8 or xOffset <= 0.2 then xDir = xDir * -1 end
        if yOffset >= 0.8 or yOffset <= 0.2 then yDir = yDir * -1 end
        
        aurora.Position = UDim2.new(-0.5 + xOffset, 0, -0.5 + yOffset, 0)
        
        -- 更流畅的颜色变化
        for i, keypoint in ipairs(colors) do
            local time = tick() * 0.05 + i * 0.1
            local h = (time % 1) * 180 + 180  -- 蓝色调范围
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV((h/360) % 1, 0.4, 0.9)
            )
        end
        gradient.Color = ColorSequence.new(colors)
    end)
    
    return aurora
end

-- 现代化涟漪效果
function Ripple(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://84830962019412"
        Ripple.ImageTransparency = 0.8
        Ripple.ScaleType = Enum.ScaleType.Fit
        
        -- 使用现代化的蓝色调
        Ripple.ImageColor3 = config.AccentColor
        
        local x = (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        Ripple.Position = UDim2.new(x, 0, y, 0)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.6, 0, -0.6, 0),
            Size = UDim2.new(2.2, 0, 2.2, 0)
        }):Play()
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 1
        }):Play()
        
        task.wait(0.6)
        Ripple:Destroy()
    end)
end

-- 现代化发光效果
local function createGlowEffect(frame, color, intensity)
    intensity = intensity or 0.3
    local glow = Instance.new("Frame")
    glow.Name = "GlowEffect"
    glow.BackgroundColor3 = color or config.GlowColor
    glow.BackgroundTransparency = 1
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0, -5, 0, -5)
    glow.ZIndex = frame.ZIndex - 1
    glow.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = glow
    
    services.TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
        BackgroundTransparency = intensity
    }):Play()
    
    return glow
end

local function setupSmoothScrolling(scrollingFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        
        if layout.AbsoluteContentSize.Y <= scrollingFrame.AbsoluteSize.Y then
            scrollingFrame.ScrollingEnabled = false
        else
            scrollingFrame.ScrollingEnabled = true
        end
    end)
    
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

-- 清理旧UI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- 现代化主容器
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.MainColor
Main.BackgroundTransparency = 0.05
Main.Position = UDim2.new(0.5, 0, 0.45, 0)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

-- 现代化圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- 现代化边框
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = config.BorderColor
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3

-- 现代化彩虹边框
local rainbowStroke = Instance.new("UIStroke")
rainbowStroke.Parent = Main
rainbowStroke.Thickness = 2
rainbowStroke.Transparency = 0.8
rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
startRainbowEffect(rainbowStroke, "Color", 0.008)

-- 添加发光效果
createGlowEffect(Main, config.GlowColor, 0.2)

-- 现代化头部
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = Main
Header.BackgroundColor3 = config.HeaderColor
Header.BackgroundTransparency = 0.1
Header.Size = UDim2.new(1, 0, 0, 40)
Header.ZIndex = 2

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12, 12, 0)
HeaderCorner.Parent = Header

-- 现代化标题
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "FengY3 UI"
Title.TextColor3 = config.AccentColor
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- 标题现代化特效
task.spawn(function()
    local hue = 0
    while Title and Title.Parent do
        hue = (hue + 0.015) % 1
        Title.TextColor3 = Color3.fromHSV(hue, 0.7, 1)
        
        services.TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextSize = 18 + math.sin(tick() * 2) * 1
        }):Play()
        
        task.wait(0.05)
    end
end)

-- 现代化关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Header
CloseButton.BackgroundColor3 = config.ErrorColor
CloseButton.BackgroundTransparency = 0.8
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.ZIndex = 3

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- 关闭按钮现代化特效
CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.6,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -31, 0.5, -11)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    Ripple(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        BackgroundTransparency = 0.4,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -29, 0.5, -9)
    }):Play()
    task.wait(0.1)
    FengYu:Destroy()
end)

-- 现代化侧边栏
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = Main
Sidebar.BackgroundColor3 = config.TabColor
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 120, 0, 310)

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 0, 12, 0)
SidebarCorner.Parent = Sidebar

-- 现代化选项卡按钮容器
local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Sidebar
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 10, 0, 10)
TabBtns.Size = UDim2.new(1, -20, 1, -20)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = config.AccentColor
TabBtns.ScrollBarImageTransparency = 0.7
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)

setupSmoothScrolling(TabBtns, TabBtnsL)

-- 现代化内容区域
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = Main
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 120, 0, 40)
ContentArea.Size = UDim2.new(1, -120, 1, -40)

-- 现代化底部状态栏
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Parent = Main
StatusBar.BackgroundColor3 = config.HeaderColor
StatusBar.BackgroundTransparency = 0.1
StatusBar.BorderSizePixel = 0
StatusBar.Position = UDim2.new(0, 0, 1, -25)
StatusBar.Size = UDim2.new(1, 0, 0, 25)

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 0, 0, 12)
StatusCorner.Parent = StatusBar

local StatusText = Instance.new("TextLabel")
StatusText.Name = "StatusText"
StatusText.Parent = StatusBar
StatusText.BackgroundTransparency = 1
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Font = Enum.Font.Gotham
StatusText.Text = "Ready • FengY3 UI v2.0"
StatusText.TextColor3 = config.SecondaryTextColor
StatusText.TextSize = 12
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- 现代化打开按钮
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.Position = UDim2.new(0.95, 0, 0.02, 0)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = config.BorderColor
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0.4

-- 添加打开按钮特效
startRainbowEffect(Open, "BackgroundColor3", 0.01)
createGlowEffect(Open, config.GlowColor, 0.3)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.3), {
        Rotation = Open.Rotation + 180,
        Position = Main.Visible and UDim2.new(0.95, 0, 0.02, 0) or UDim2.new(0.95, 0, 0.02, 5)
    }):Play()
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        services.TweenService:Create(Open, TweenInfo.new(0.3), {
            Rotation = Open.Rotation + 180,
            Position = Main.Visible and UDim2.new(0.95, 0, 0.02, 0) or UDim2.new(0.95, 0, 0.02, 5)
        }):Play()
    end
end)

-- 现代化选项卡切换
local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = FengY3.currentTab
    if old == nil then
        new[2].Visible = true
        FengY3.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { 
            BackgroundColor3 = config.AccentColor,
            BackgroundTransparency = 0.7
        }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { 
            TextColor3 = config.TextColor,
            TextTransparency = 0
        }):Play()
        services.TweenService:Create(new[1].TabIcon, TweenInfo.new(0.2), { 
            ImageColor3 = config.TextColor,
            ImageTransparency = 0
        }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengY3.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { 
        BackgroundColor3 = config.Button_Color,
        BackgroundTransparency = 0.8
    }):Play()
    services.TweenService:Create(new[1], tweenInfo, { 
        BackgroundColor3 = config.AccentColor,
        BackgroundTransparency = 0.7
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextColor3 = config.SecondaryTextColor,
        TextTransparency = 0.3
    }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { 
        TextColor3 = config.TextColor,
        TextTransparency = 0
    }):Play()
    services.TweenService:Create(old[1].TabIcon, tweenInfo, { 
        ImageColor3 = config.SecondaryTextColor,
        ImageTransparency = 0.3
    }):Play()
    services.TweenService:Create(new[1].TabIcon, tweenInfo, { 
        ImageColor3 = config.TextColor,
        ImageTransparency = 0
    }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.2)
    switchingTabs = false
end

function FengY3.new(FengY3, name, theme)
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

    Title.Text = name or "FengY3 UI"
    
    local window = {}
    
    function window.Tab(window, name, icon)
        local Tab = Instance.new("ScrollingFrame")
        local TabBtn = Instance.new("TextButton")
        local TabBtnCorner = Instance.new("UICorner")
        local TabIcon = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabL = Instance.new("UIListLayout")
        
        -- 现代化选项卡内容区域
        Tab.Name = "Tab"
        Tab.Parent = ContentArea
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 3
        Tab.ScrollBarImageColor3 = config.AccentColor
        Tab.ScrollBarImageTransparency = 0.7
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        
        -- 现代化选项卡按钮
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabBtns
        TabBtn.BackgroundColor3 = config.Button_Color
        TabBtn.BackgroundTransparency = 0.8
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(1, 0, 0, 45)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn
        
        -- 现代化选项卡图标
        TabIcon.Name = "TabIcon"
        TabIcon.Parent = TabBtn
        TabIcon.BackgroundTransparency = 1
        TabIcon.BorderSizePixel = 0
        TabIcon.Position = UDim2.new(0, 10, 0.5, -10)
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Image = icon or "rbxassetid://84830962019412"
        TabIcon.ImageColor3 = config.SecondaryTextColor
        TabIcon.ImageTransparency = 0.3
        
        -- 现代化选项卡文本
        TabText.Name = "TabText"
        TabText.Parent = TabBtn
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(0, 40, 0, 0)
        TabText.Size = UDim2.new(1, -40, 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.SecondaryTextColor
        TabText.TextTransparency = 0.3
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        
        -- 现代化选项卡内容布局
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 8)
        
        setupSmoothScrolling(Tab, TabL)
        
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({ TabBtn, Tab })
        end)
        
        if FengY3.currentTab == nil then
            switchTab({ TabBtn, Tab })
        end
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            -- 现代化分区设计
            local Section = Instance.new("Frame")
            local SectionCorner = Instance.new("UICorner")
            local SectionHeader = Instance.new("Frame")
            local SectionHeaderCorner = Instance.new("UICorner")
            local SectionTitle = Instance.new("TextLabel")
            local SectionToggle = Instance.new("ImageButton")
            local SectionContent = Instance.new("Frame")
            local SectionContentLayout = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.Bg_Color
            Section.BackgroundTransparency = 0.1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, -20, 0, 50)
            
            SectionCorner.CornerRadius = UDim.new(0, 10)
            SectionCorner.Parent = Section
            
            -- 现代化分区头部
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundColor3 = config.TabColor
            SectionHeader.BackgroundTransparency = 0.1
            SectionHeader.Size = UDim2.new(1, 0, 0, 40)
            
            SectionHeaderCorner.CornerRadius = UDim.new(0, 10)
            SectionHeaderCorner.Parent = SectionHeader
            
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 15, 0, 0)
            SectionTitle.Size = UDim2.new(1, -50, 1, 0)
            SectionTitle.Font = Enum.Font.GothamSemibold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.TextColor
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 现代化切换按钮
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionHeader
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Position = UDim2.new(1, -35, 0.5, -10)
            SectionToggle.Size = UDim2.new(0, 20, 0, 20)
            SectionToggle.Image = "rbxassetid://84830962019412"
            SectionToggle.ImageColor3 = config.AccentColor
            SectionToggle.Rotation = 0
            
            -- 现代化分区内容
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = Section
            SectionContent.BackgroundTransparency = 1
            SectionContent.BorderSizePixel = 0
            SectionContent.Position = UDim2.new(0, 0, 0, 45)
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            
            SectionContentLayout.Name = "SectionContentLayout"
            SectionContentLayout.Parent = SectionContent
            SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionContentLayout.Padding = UDim.new(0, 6)
            
            local isOpen = TabVal ~= false
            
            local function toggleSection()
                isOpen = not isOpen
                local targetSize = isOpen and (SectionContentLayout.AbsoluteContentSize.Y + 15) or 0
                
                services.TweenService:Create(Section, TweenInfo.new(0.3), {
                    Size = UDim2.new(1, -20, 0, 40 + targetSize)
                }):Play()
                
                services.TweenService:Create(SectionToggle, TweenInfo.new(0.3), {
                    Rotation = isOpen and 180 or 0
                }):Play()
                
                SectionContent.Visible = isOpen
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                Ripple(SectionToggle)
                toggleSection()
            end)
            
            if isOpen then
                Section.Size = UDim2.new(1, -20, 0, 40 + SectionContentLayout.AbsoluteContentSize.Y + 15)
                SectionToggle.Rotation = 180
            else
                SectionContent.Visible = false
            end
            
            SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isOpen then
                    Section.Size = UDim2.new(1, -20, 0, 40 + SectionContentLayout.AbsoluteContentSize.Y + 15)
                end
            end)
            
            local section = {}
            
            -- 现代化按钮
            function section.Button(section, text, callback)
                callback = callback or function() end
                
                local Button = Instance.new("TextButton")
                local ButtonCorner = Instance.new("UICorner")
                local ButtonStroke = Instance.new("UIStroke")
                
                Button.Name = "Button"
                Button.Parent = SectionContent
                Button.BackgroundColor3 = config.Button_Color
                Button.BackgroundTransparency = 0.1
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 0, 36)
                Button.AutoButtonColor = false
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = text
                Button.TextColor3 = config.TextColor
                Button.TextSize = 14
                
                ButtonCorner.CornerRadius = UDim.new(0, 8)
                ButtonCorner.Parent = Button
                
                ButtonStroke.Parent = Button
                ButtonStroke.Color = config.BorderColor
                ButtonStroke.Thickness = 1
                ButtonStroke.Transparency = 0.5
                
                -- 现代化按钮特效
                Button.MouseEnter:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.05,
                        Size = UDim2.new(1, -5, 0, 36)
                    }):Play()
                    services.TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {
                        Color = config.AccentColor,
                        Thickness = 1.5
                    }):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1,
                        Size = UDim2.new(1, 0, 0, 36)
                    }):Play()
                    services.TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {
                        Color = config.BorderColor,
                        Thickness = 1
                    }):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    Ripple(Button)
                    callback()
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.1), {
                        BackgroundColor3 = config.AccentColor,
                        BackgroundTransparency = 0.3
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                return Button
            end

            -- 现代化开关
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengY3.flaFengYu[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                local ToggleBtn = Instance.new("TextButton")
                local ToggleBtnC = Instance.new("UICorner")
                local ToggleDisable = Instance.new("Frame")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchC = Instance.new("UICorner")
                local ToggleDisableC = Instance.new("UICorner")
                
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = SectionContent
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(1, 0, 0, 36)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.1
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 14
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 8)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = config.Bg_Color
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.85, 0, 0.22, 0)
                ToggleDisable.Size = UDim2.new(0, 40, 0, 20)
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 18, 0, 18)
                ToggleSwitch.Position = UDim2.new(0, enabled and 20 or 2, 0, 1)
                
                ToggleSwitchC.CornerRadius = UDim.new(1, 0)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(1, 0)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                if enabled then
                    createAuroraEffect(ToggleSwitch, 0.6)
                end
                
                -- 现代化开关特效
                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.05
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengY3.flaFengYu[flag]
                        end
                        if FengY3.flaFengYu[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, state and 20 or 2, 0, 1),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        if state then
                            createAuroraEffect(ToggleSwitch, 0.6)
                        else
                            local aurora = ToggleSwitch:FindFirstChild("AuroraEffect")
                            if aurora then
                                aurora:Destroy()
                            end
                        end
                        
                        FengY3.flaFengYu[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Ripple(ToggleBtn)
                    funcs:SetState()
                end)
                
                return funcs
            end

            -- 现代化滑块
            function section.Slider(section, text, flag, default, min, max, precise, callback)
                callback = callback or function() end
                min = min or 0
                max = max or 10
                default = default or min
                precise = precise or false
                
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default value provided")
                
                FengY3.flaFengYu[flag] = default

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
                SliderModule.Parent = SectionContent
                SliderModule.BackgroundTransparency = 1
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(1, 0, 0, 50)
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.1
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(1, 0, 0, 50)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = config.TextColor
                SliderBack.TextSize = 14
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBackC.CornerRadius = UDim.new(0, 8)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
                SliderBar.Size = UDim2.new(0.7, 0, 0, 6)
                SliderBarC.CornerRadius = UDim.new(1, 0)
                SliderBarC.Name = "SliderBarC"
                SliderBarC.Parent = SliderBar
                
                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = config.SliderBar_Color
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                SliderPartC.CornerRadius = UDim.new(1, 0)
                SliderPartC.Name = "SliderPartC"
                SliderPartC.Parent = SliderPart
                
                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBack
                SliderValBG.BackgroundColor3 = config.Bg_Color
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.8, 0, 0.3, 0)
                SliderValBG.Size = UDim2.new(0, 50, 0, 22)
                SliderValBG.AutoButtonColor = false
                SliderValBG.Font = Enum.Font.Gotham
                SliderValBG.Text = ""
                
                SliderValBGC.CornerRadius = UDim.new(0, 6)
                SliderValBGC.Name = "SliderValBGC"
                SliderValBGC.Parent = SliderValBG
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundTransparency = 1
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.TextColor
                SliderValue.TextSize = 12
                
                -- 现代化滑块特效
                createAuroraEffect(SliderPart, 0.4)
                
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
                        FengY3.flaFengYu[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        
                        services.TweenService:Create(SliderPart, TweenInfo.new(0.1), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        callback(tonumber(value))
                    end,
                    
                    GetValue = function(self)
                        return FengY3.flaFengYu[flag]
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

            -- 现代化标签
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                local TextLabel = Instance.new("TextLabel")
                local LabelC = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = SectionContent
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(1, 0, 0, 24)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.1
                TextLabel.Size = UDim2.new(1, 0, 0, 28)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 14
                
                LabelC.CornerRadius = UDim.new(0, 8)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
                return TextLabel
            end

            -- 现代化图片
            function section.Image(section, imageId, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = SectionContent
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(1, 0, 0, sizeY or 120)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundColor3 = config.Bg_Color
                ImageLabel.BackgroundTransparency = 0.1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, 320), 0, sizeY or 120)
                ImageLabel.Image = "rbxassetid://" .. tostring(imageId)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 8)
                ImageCorner.Parent = ImageLabel
                
                local imageGlow = Instance.new("UIStroke")
                imageGlow.Parent = ImageLabel
                imageGlow.Color = config.AccentColor
                imageGlow.Thickness = 1
                imageGlow.Transparency = 0.7
                
                return ImageLabel
            end

            -- 现代化键位绑定
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
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = SectionContent
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(1, 0, 0, 36)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.1
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(1, 0, 0, 36)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 14
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBtnC.CornerRadius = UDim.new(0, 8)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
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
                
                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue
                
                -- 现代化键位绑定特效
                KeybindBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.05
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                KeybindValue.MouseButton1Click:Connect(function()
                    Ripple(KeybindValue)
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
                end)
                
                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
                end)
                
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
            end

            -- 现代化文本框
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                
                FengY3.flaFengYu[flag] = default
                
                local TextboxModule = Instance.new("Frame")
                local TextboxBack = Instance.new("TextButton")
                local TextboxBackC = Instance.new("UICorner")
                local BoxBG = Instance.new("TextButton")
                local BoxBGC = Instance.new("UICorner")
                local TextBox = Instance.new("TextBox")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = SectionContent
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(1, 0, 0, 36)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.1
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(1, 0, 0, 36)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 14
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 8)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.45, 0, 0.22, 0)
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
                TextBox.TextSize = 12
                TextBox.PlaceholderColor3 = config.SecondaryTextColor
                
                -- 现代化文本框特效
                TextboxBack.MouseEnter:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.05
                    }):Play()
                end)
                
                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    FengY3.flaFengYu[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)
                
                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
                end)
                
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
            end

            -- 现代化下拉框
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengY3.flaFengYu[flag] = nil
                
                local DropdownModule = Instance.new("Frame")
                local DropdownTop = Instance.new("TextButton")
                local DropdownTopC = Instance.new("UICorner")
                local DropdownOpenFrame = Instance.new("Frame")
                local DropdownOpenFrameC = Instance.new("UICorner")
                local DropdownOpen = Instance.new("TextButton")
                local DropdownText = Instance.new("TextBox")
                local DropdownModuleL = Instance.new("UIListLayout")
                
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = SectionContent
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(1, 0, 0, 36)
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0.1
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(1, 0, 0, 36)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = config.TextColor
                DropdownTop.TextSize = 14
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownTopC.CornerRadius = UDim.new(0, 8)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop
                
                DropdownOpenFrame.Name = "DropdownOpenFrame"
                DropdownOpenFrame.Parent = DropdownTop
                DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
                DropdownOpenFrame.BorderSizePixel = 0
                DropdownOpenFrame.Position = UDim2.new(0.80, 0, 0.5, 0)
                DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)
                DropdownOpenFrame.ZIndex = 2
                
                createAuroraEffect(DropdownOpenFrame, 0.8)
                
                DropdownOpenFrameC.CornerRadius = UDim.new(0, 6)
                DropdownOpenFrameC.Name = "DropdownOpenFrameC"
                DropdownOpenFrameC.Parent = DropdownOpenFrame
                
                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownOpenFrame
                DropdownOpen.BackgroundTransparency = 1
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Size = UDim2.new(1, 0, 1, 0)
                DropdownOpen.Font = Enum.Font.GothamSemibold
                DropdownOpen.Text = "选择"
                DropdownOpen.TextColor3 = config.TextColor
                DropdownOpen.TextSize = 11
                DropdownOpen.TextWrapped = true
                DropdownOpen.ZIndex = 3
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundTransparency = 1
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 230, 0, 36)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.PlaceholderColor3 = config.SecondaryTextColor
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = 14
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                DropdownText.ZIndex = 2
                
                DropdownModuleL.Name = "DropdownModuleL"
                DropdownModuleL.Parent = DropdownModule
                DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownModuleL.Padding = UDim.new(0, 4)
                
                local setAllVisible = function()
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if option:IsA("TextButton") and option.Name:match("Option_") then
                            option.Visible = true
                        end
                    end
                end
                
                local searchDropdown = function(text)
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if text == "" then
                            setAllVisible()
                        else
                            if option:IsA("TextButton") and option.Name:match("Option_") then
                                if option.Text:lower():match(text:lower()) then
                                    option.Visible = true
                                else
                                    option.Visible = false
                                end
                            end
                        end
                    end
                end
                
                local open = false
                local ToggleDropVis = function()
                    open = not open
                    if open then
                        setAllVisible()
                    end
                    DropdownOpen.Text = (open and "取消" or "选择")
                    DropdownModule.Size = UDim2.new(1, 0, 0, (open and math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150) or 36))
                end
                
                DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)
                DropdownText.Focused:Connect(function()
                    if open then
                        return
                    end
                    ToggleDropVis()
                end)
                
                DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                    if not open then
                        return
                    end
                    searchDropdown(DropdownText.Text)
                end)
                
                DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if not open then
                        return
                    end
                    DropdownModule.Size = UDim2.new(1, 0, 0, math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150))
                end)
                
                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    local OptionC = Instance.new("UICorner")
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownModule
                    Option.BackgroundColor3 = config.TabColor
                    Option.BackgroundTransparency = 0.1
                    Option.BorderSizePixel = 0
                    Option.Position = UDim2.new(0, 0, 0.328125, 0)
                    Option.Size = UDim2.new(0, 310, 0, 24)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 13
                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    Option.MouseButton1Click:Connect(function()
                        Ripple(Option)
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        FengY3.flaFengYu[flag] = Option.Text
                    end)
                end
                
                funcs.RemoveOption = function(self, option)
                    local option = DropdownModule:FindFirstChild("Option_" .. option)
                    if option then
                        option:Destroy()
                    end
                end
                
                funcs.SetOptions = function(self, options)
                    for _, v in next, DropdownModule:GetChildren() do
                        if v.Name:match("Option_") then
                            v:Destroy()
                        end
                    end
                    for _, v in next, options do
                        funcs:AddOption(v)
                    end
                end
                
                funcs:SetOptions(options)
                return funcs
            end

            return section
        end

        return tab
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
    Main.Visible = not ToggleUI
end

return FengY3