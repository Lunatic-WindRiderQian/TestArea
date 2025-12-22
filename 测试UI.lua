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
FengUI.colors = {} -- 存储所有颜色配置

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

-- 默认颜色配置
local config = {
    MainColor = Color3.fromRGB(18, 18, 30),
    TabColor = Color3.fromRGB(25, 25, 40),
    Bg_Color = Color3.fromRGB(20, 20, 35),
    Zy_Color = Color3.fromRGB(20, 20, 35),
    Button_Color = Color3.fromRGB(30, 30, 50),
    Textbox_Color = Color3.fromRGB(30, 30, 50),
    Dropdown_Color = Color3.fromRGB(30, 30, 50),
    Keybind_Color = Color3.fromRGB(30, 30, 50),
    Label_Color = Color3.fromRGB(30, 30, 50),
    Slider_Color = Color3.fromRGB(30, 30, 50),
    SliderBar_Color = Color3.fromRGB(0, 200, 255),
    Toggle_Color = Color3.fromRGB(30, 30, 50),
    Toggle_Off = Color3.fromRGB(50, 50, 70),
    Toggle_On = Color3.fromRGB(0, 230, 230),
    AccentColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(240, 245, 255),
    SecondaryTextColor = Color3.fromRGB(180, 190, 210),
    GlowColor = Color3.fromRGB(0, 150, 255),
    
    DeepSpaceColor = Color3.fromRGB(1, 2, 10),
    NebulaColor1 = Color3.fromRGB(0, 40, 80),
    NebulaColor2 = Color3.fromRGB(20, 60, 120),
    AccentGlow = Color3.fromRGB(0, 220, 255),
    ElementColor = Color3.fromRGB(30, 30, 50),
    ElementTransparency = 0.2,
    GlassEffect = Color3.fromRGB(255, 255, 255),
    
    -- ESP颜色配置
    ESP_BoxColor = Color3.fromRGB(0, 255, 0),
    ESP_TextColor = Color3.fromRGB(255, 255, 255),
    ESP_TracerColor = Color3.fromRGB(255, 0, 0),
    ESP_HealthBarColor = Color3.fromRGB(0, 255, 0),
    ESP_HealthBarBGColor = Color3.fromRGB(255, 0, 0),
}

-- 将配置复制到FengUI.colors中，便于外部访问
for k, v in pairs(config) do
    FengUI.colors[k] = v
end

-- 颜色预设
local colorPresets = {
    {"深空蓝", Color3.fromRGB(18, 18, 30), Color3.fromRGB(0, 200, 255)},
    {"霓虹紫", Color3.fromRGB(25, 10, 35), Color3.fromRGB(180, 0, 255)},
    {"暗夜绿", Color3.fromRGB(10, 25, 15), Color3.fromRGB(0, 255, 150)},
    {"熔岩红", Color3.fromRGB(30, 10, 10), Color3.fromRGB(255, 60, 0)},
    {"优雅金", Color3.fromRGB(30, 25, 15), Color3.fromRGB(255, 215, 0)},
    {"赛博粉", Color3.fromRGB(25, 5, 25), Color3.fromRGB(255, 0, 200)},
    {"深海青", Color3.fromRGB(5, 20, 25), Color3.fromRGB(0, 255, 255)},
    {"午夜黑", Color3.fromRGB(5, 5, 10), Color3.fromRGB(150, 150, 150)},
}

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
        local r = math.sin(hue * 6 + 0) * 0.5 + 0.5
        local g = math.sin(hue * 6 + 2) * 0.5 + 0.5
        local b = math.sin(hue * 6 + 4) * 0.5 + 0.5
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createSpaceBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "SpaceBackground"
    background.BackgroundColor3 = config.DeepSpaceColor
    background.BackgroundTransparency = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.ZIndex = -100
    
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 10)
    backgroundCorner.Parent = background
    
    background.Parent = parent
    
    local gradient1 = Instance.new("UIGradient")
    gradient1.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.DeepSpaceColor),
        ColorSequenceKeypoint.new(0.3, config.NebulaColor1),
        ColorSequenceKeypoint.new(0.7, config.NebulaColor2),
        ColorSequenceKeypoint.new(1, config.DeepSpaceColor)
    })
    gradient1.Rotation = 45
    gradient1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    gradient1.Parent = background
    
    local gradient2 = Instance.new("UIGradient")
    gradient2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 150))
    })
    gradient2.Rotation = 135
    gradient2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    gradient2.Parent = background
    
    return background
end

local function createPulseGlow(object)
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            pulseConnection:Disconnect()
            return
        end
        
        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return pulseConnection
end

local function createHologramEffect(frame, intensity)
    intensity = intensity or 1
    
    local hologram = Instance.new("Frame")
    hologram.Name = "HologramEffect"
    hologram.BackgroundTransparency = 1
    hologram.Size = UDim2.new(1, 0, 1, 0)
    hologram.ZIndex = frame.ZIndex - 1
    hologram.Parent = frame
    hologram.ClipsDescendants = true
    
    local scanLines = Instance.new("Frame")
    scanLines.Name = "ScanLines"
    scanLines.BackgroundTransparency = 1
    scanLines.Size = UDim2.new(1, 0, 1, 0)
    scanLines.Parent = hologram
    
    local linePattern = Instance.new("UIGradient")
    linePattern.Rotation = 0
    linePattern.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.1, 0.7),
        NumberSequenceKeypoint.new(0.2, 0.9),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    linePattern.Parent = scanLines
    
    local glow = Instance.new("UIGradient")
    glow.Rotation = 45
    glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.3, 0.3 * intensity),
        NumberSequenceKeypoint.new(0.7, 0.3 * intensity),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    
    local colors = {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
    }
    glow.Color = ColorSequence.new(colors)
    glow.Parent = hologram
    
    local scanConnection
    scanConnection = RunService.Heartbeat:Connect(function(delta)
        if not scanLines or not scanLines.Parent then
            scanConnection:Disconnect()
            return
        end
        linePattern.Offset = Vector2.new(0, (tick() * 0.5) % 1)
    end)
    
    local colorConnection
    colorConnection = RunService.Heartbeat:Connect(function(delta)
        if not hologram or not hologram.Parent then
            colorConnection:Disconnect()
            return
        end
        
        local time = tick()
        for i, keypoint in ipairs(colors) do
            local hue = (time * 0.2 + i * 0.3) % 1
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV(hue, 0.8, 1)
            )
        end
        glow.Color = ColorSequence.new(colors)
    end)
    
    return hologram
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

local function createParticleTrail(startPos, endPos, parent)
    local trail = Instance.new("Frame")
    trail.Name = "ParticleTrail"
    trail.BackgroundColor3 = Color3.new(1, 1, 1)
    trail.BackgroundTransparency = 0.3
    trail.Size = UDim2.new(0, 4, 0, 4)
    trail.Position = startPos
    trail.Parent = parent
    trail.ZIndex = 10
    
    local trailCorner = Instance.new("UICorner")
    trailCorner.CornerRadius = UDim.new(1, 0)
    trailCorner.Parent = trail
    
    services.TweenService:Create(trail, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 2, 0, 2)
    }):Play()
    
    delay(0.3, function()
        trail:Destroy()
    end)
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

local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
            ImageTransparency = 0,
            Size = UDim2.new(0, 25, 0, 25)
        }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.3), { 
            TextTransparency = 0,
            TextColor3 = config.AccentColor
        }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengUI.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { 
        ImageTransparency = 0.5,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
    services.TweenService:Create(new[1], tweenInfo, { 
        ImageTransparency = 0,
        Size = UDim2.new(0, 25, 0, 25)
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.5,
        TextColor3 = config.TextColor
    }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { 
        TextTransparency = 0,
        TextColor3 = config.AccentColor
        }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.3)
    switchingTabs = false
end

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 450, 0, 280)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

createSpaceBackground(Main)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 1

local neonStroke = Instance.new("UIStroke")
neonStroke.Parent = Main
neonStroke.Thickness = 2
neonStroke.Transparency = 1
neonStroke.LineJoinMode = Enum.LineJoinMode.Round
startNeonFlowEffect(neonStroke, "Color", 0.01)

createPulseGlow(neonStroke)

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = 1
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.ZIndex = 2

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 10)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "FengUI"
TitleText.TextColor3 = config.AccentColor
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 1

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 7)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.TextSize = 16
CloseButton.ZIndex = 10
CloseButton.TextTransparency = 1

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 18,
        Position = UDim2.new(1, -26, 0, 6)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 16,
        Position = UDim2.new(1, -25, 0, 7)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 14,
        Position = UDim2.new(1, -24, 0, 8)
    }):Play()
    
    services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4), {
        TextTransparency = 1
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4), {
        TextTransparency = 1
    }):Play()
    
    task.wait(0.4)
    FengYu:Destroy()
end)

local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 40, 0, 40)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(180, 180, 180)
OpenStroke.Thickness = 1.2
OpenStroke.Transparency = 0.4

startNeonFlowEffect(Open, "BackgroundColor3", 0.012)
createPulseGlow(OpenStroke)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playEntranceAnimation()
    end
    create3DFlipAnimation(Open, 0.5)
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
        create3DFlipAnimation(Open, 0.5)
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 37)
TabMain.Size = UDim2.new(0, 360, 0, 243)
TabMain.Visible = false

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 1
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 35)
Side.Size = UDim2.new(0, 90, 0, 245)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Side

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 5)
TabBtns.Size = UDim2.new(0, 90, 0, 235)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None
TabBtns.Visible = false

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 6)

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y)
    
    TabBtns.ScrollingEnabled = TabBtnsL.AbsoluteContentSize.Y > TabBtns.AbsoluteSize.Y
    TabBtns.ElasticBehavior = Enum.ElasticBehavior.Never
end)

local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    Side.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    neonStroke.Transparency = 1
    
    TabMain.Visible = false
    TabBtns.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 450, 0, 280)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.5
    }):Play()
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.7
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(Side, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.2)
    
    TabMain.Visible = true
    TabBtns.Visible = true
end

task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

task.spawn(function()
    local hue = 0
    local matrixEffect = Instance.new("UIGradient")
    matrixEffect.Rotation = 90
    matrixEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })
    matrixEffect.Parent = TitleText
    
    while TitleText and TitleText.Parent do
        hue = (hue + 0.03) % 1
        
        TitleText.TextColor3 = Color3.fromHSV(hue, 1, 1)
        
        matrixEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV((hue + 0.2) % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue - 0.2) % 1, 1, 1))
        })
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 15 + math.sin(tick() * 3) * 2
        }):Play()
        
        task.wait(0.05)
    end
end)

-- 颜色选择器工具函数
local function hexToColor(hex)
    hex = hex:gsub("#", "")
    if #hex == 3 then
        hex = hex:gsub("(.)", "%1%1")
    end
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return Color3.new(r, g, b)
end

local function colorToHex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

-- 颜色选择器主函数
local function createColorPickerUI(parentElement, defaultColor, onColorChanged, presetColors)
    local colorPickerOpen = false
    local currentColor = defaultColor or Color3.new(1, 1, 1)
    local colorPickerFrame
    
    -- 创建颜色选择器框架
    local function createColorPickerFrame()
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Name = "ColorPickerFrame"
        pickerFrame.BackgroundColor3 = config.TabColor
        pickerFrame.BackgroundTransparency = 0.1
        pickerFrame.BorderSizePixel = 0
        pickerFrame.Position = UDim2.new(0, 0, 1, 5)
        pickerFrame.Size = UDim2.new(0, 280, 0, 200)
        pickerFrame.ZIndex = 100
        pickerFrame.Visible = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = pickerFrame
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = config.AccentColor
        stroke.Thickness = 2
        stroke.Transparency = 0.3
        stroke.Parent = pickerFrame
        
        -- 颜色预览
        local previewFrame = Instance.new("Frame")
        previewFrame.Name = "ColorPreview"
        previewFrame.BackgroundColor3 = currentColor
        previewFrame.BorderSizePixel = 0
        previewFrame.Position = UDim2.new(0, 10, 0, 10)
        previewFrame.Size = UDim2.new(0, 60, 0, 60)
        previewFrame.ZIndex = 101
        
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 6)
        previewCorner.Parent = previewFrame
        
        local previewStroke = Instance.new("UIStroke")
        previewStroke.Color = Color3.new(1, 1, 1)
        previewStroke.Thickness = 2
        previewStroke.Transparency = 0.5
        previewStroke.Parent = previewFrame
        
        -- 十六进制输入框
        local hexInput = Instance.new("TextBox")
        hexInput.Name = "HexInput"
        hexInput.BackgroundColor3 = config.Button_Color
        hexInput.BackgroundTransparency = 0.2
        hexInput.BorderSizePixel = 0
        hexInput.Position = UDim2.new(0, 80, 0, 10)
        hexInput.Size = UDim2.new(0, 100, 0, 30)
        hexInput.Font = Enum.Font.Gotham
        hexInput.PlaceholderText = "#FFFFFF"
        hexInput.Text = colorToHex(currentColor)
        hexInput.TextColor3 = config.TextColor
        hexInput.TextSize = 14
        hexInput.ZIndex = 101
        
        local hexCorner = Instance.new("UICorner")
        hexCorner.CornerRadius = UDim.new(0, 6)
        hexCorner.Parent = hexInput
        
        hexInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local text = hexInput.Text
                if text:match("^#?[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$") then
                    local newColor = hexToColor(text)
                    currentColor = newColor
                    previewFrame.BackgroundColor3 = newColor
                    if onColorChanged then
                        onColorChanged(newColor)
                    end
                end
            end
        end)
        
        -- RGB滑块
        local sliders = {}
        local rgbLabels = {"R", "G", "B"}
        
        for i, label in ipairs(rgbLabels) do
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = label .. "Slider"
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Position = UDim2.new(0, 80, 0, 50 + (i-1)*35)
            sliderFrame.Size = UDim2.new(0, 190, 0, 25)
            sliderFrame.ZIndex = 101
            
            local labelText = Instance.new("TextLabel")
            labelText.Name = "Label"
            labelText.BackgroundTransparency = 1
            labelText.Position = UDim2.new(0, 0, 0, 0)
            labelText.Size = UDim2.new(0, 20, 1, 0)
            labelText.Font = Enum.Font.GothamBold
            labelText.Text = label
            labelText.TextColor3 = config.TextColor
            labelText.TextSize = 14
            labelText.TextXAlignment = Enum.TextXAlignment.Left
            labelText.ZIndex = 101
            labelText.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "SliderBar"
            sliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            sliderBar.BorderSizePixel = 0
            sliderBar.Position = UDim2.new(0, 25, 0.5, 0)
            sliderBar.AnchorPoint = Vector2.new(0, 0.5)
            sliderBar.Size = UDim2.new(0, 140, 0, 10)
            sliderBar.ZIndex = 101
            
            local sliderBarCorner = Instance.new("UICorner")
            sliderBarCorner.CornerRadius = UDim.new(0, 5)
            sliderBarCorner.Parent = sliderBar
            
            local sliderPart = Instance.new("Frame")
            sliderPart.Name = "SliderPart"
            sliderPart.BackgroundColor3 = (function()
                if label == "R" then return Color3.new(1, 0, 0)
                elseif label == "G" then return Color3.new(0, 1, 0)
                else return Color3.new(0, 0, 1) end
            end)()
            sliderPart.BorderSizePixel = 0
            sliderPart.Size = UDim2.new(0, 140, 1, 0)
            sliderPart.ZIndex = 102
            
            local sliderPartCorner = Instance.new("UICorner")
            sliderPartCorner.CornerRadius = UDim.new(0, 5)
            sliderPartCorner.Parent = sliderPart
            
            local sliderHandle = Instance.new("Frame")
            sliderHandle.Name = "SliderHandle"
            sliderHandle.BackgroundColor3 = Color3.new(1, 1, 1)
            sliderHandle.BorderSizePixel = 0
            sliderHandle.Position = UDim2.new(0, 135, 0.5, 0)
            sliderHandle.AnchorPoint = Vector2.new(0, 0.5)
            sliderHandle.Size = UDim2.new(0, 15, 0, 15)
            sliderHandle.ZIndex = 103
            
            local sliderHandleCorner = Instance.new("UICorner")
            sliderHandleCorner.CornerRadius = UDim.new(1, 0)
            sliderHandleCorner.Parent = sliderHandle
            
            local valueText = Instance.new("TextLabel")
            valueText.Name = "ValueText"
            valueText.BackgroundTransparency = 1
            valueText.Position = UDim2.new(0, 170, 0, 0)
            valueText.Size = UDim2.new(0, 20, 1, 0)
            valueText.Font = Enum.Font.Gotham
            valueText.Text = "255"
            valueText.TextColor3 = config.TextColor
            valueText.TextSize = 12
            valueText.ZIndex = 101
            valueText.Parent = sliderFrame
            
            sliderPart.Parent = sliderBar
            sliderBar.Parent = sliderFrame
            sliderHandle.Parent = sliderBar
            sliderFrame.Parent = pickerFrame
            
            sliders[label] = {
                bar = sliderBar,
                part = sliderPart,
                handle = sliderHandle,
                valueText = valueText,
                dragging = false
            }
        end
        
        -- 更新滑块函数
        local function updateSlidersFromColor(color)
            local r = math.floor(color.R * 255)
            local g = math.floor(color.G * 255)
            local b = math.floor(color.B * 255)
            
            sliders["R"].valueText.Text = tostring(r)
            sliders["G"].valueText.Text = tostring(g)
            sliders["B"].valueText.Text = tostring(b)
            
            sliders["R"].part.Size = UDim2.new(r/255, 0, 1, 0)
            sliders["G"].part.Size = UDim2.new(g/255, 0, 1, 0)
            sliders["B"].part.Size = UDim2.new(b/255, 0, 1, 0)
            
            sliders["R"].handle.Position = UDim2.new(r/255, -7.5, 0.5, 0)
            sliders["G"].handle.Position = UDim2.new(g/255, -7.5, 0.5, 0)
            sliders["B"].handle.Position = UDim2.new(b/255, -7.5, 0.5, 0)
        end
        
        -- 更新颜色函数
        local function updateColorFromSliders()
            local r = tonumber(sliders["R"].valueText.Text) or 0
            local g = tonumber(sliders["G"].valueText.Text) or 0
            local b = tonumber(sliders["B"].valueText.Text) or 0
            
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            
            currentColor = Color3.fromRGB(r, g, b)
            previewFrame.BackgroundColor3 = currentColor
            hexInput.Text = colorToHex(currentColor)
            
            if onColorChanged then
                onColorChanged(currentColor)
            end
        end
        
        -- 预设颜色网格
        local presetGrid = Instance.new("Frame")
        presetGrid.Name = "PresetGrid"
        presetGrid.BackgroundTransparency = 1
        presetGrid.Position = UDim2.new(0, 10, 0, 140)
        presetGrid.Size = UDim2.new(1, -20, 0, 50)
        presetGrid.ZIndex = 101
        
        local presetUIListLayout = Instance.new("UIListLayout")
        presetUIListLayout.FillDirection = Enum.FillDirection.Horizontal
        presetUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        presetUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        presetUIListLayout.Padding = UDim.new(0, 5)
        presetUIListLayout.Parent = presetGrid
        
        -- 添加预设颜色
        local presetsToUse = presetColors or colorPresets
        for i, preset in ipairs(presetsToUse) do
            local presetBtn = Instance.new("TextButton")
            presetBtn.Name = "Preset_" .. i
            presetBtn.BackgroundColor3 = preset[2]
            presetBtn.BorderSizePixel = 0
            presetBtn.Size = UDim2.new(0, 30, 0, 30)
            presetBtn.AutoButtonColor = false
            presetBtn.Text = ""
            presetBtn.ZIndex = 102
            
            local presetCorner = Instance.new("UICorner")
            presetCorner.CornerRadius = UDim.new(0, 6)
            presetCorner.Parent = presetBtn
            
            local presetStroke = Instance.new("UIStroke")
            presetStroke.Color = preset[3]
            presetStroke.Thickness = 2
            presetStroke.Parent = presetBtn
            
            presetBtn.MouseButton1Click:Connect(function()
                currentColor = preset[2]
                previewFrame.BackgroundColor3 = currentColor
                hexInput.Text = colorToHex(currentColor)
                updateSlidersFromColor(currentColor)
                if onColorChanged then
                    onColorChanged(currentColor)
                end
            end)
            
            presetBtn.Parent = presetGrid
        end
        
        -- 滑块交互逻辑
        for label, slider in pairs(sliders) do
            local function updateSliderValue(input)
                if slider.dragging then
                    local mouse = services.Players.LocalPlayer:GetMouse()
                    local barPos = slider.bar.AbsolutePosition.X
                    local barSize = slider.bar.AbsoluteSize.X
                    local mouseX = math.clamp(mouse.X, barPos, barPos + barSize)
                    local percent = (mouseX - barPos) / barSize
                    
                    local value = math.floor(percent * 255 + 0.5)
                    value = math.clamp(value, 0, 255)
                    
                    slider.valueText.Text = tostring(value)
                    slider.part.Size = UDim2.new(percent, 0, 1, 0)
                    slider.handle.Position = UDim2.new(percent, -7.5, 0.5, 0)
                    
                    updateColorFromSliders()
                end
            end
            
            slider.handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slider.dragging = true
                    updateSliderValue(input)
                end
            end)
            
            slider.bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slider.dragging = true
                    updateSliderValue(input)
                end
            end)
            
            services.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    slider.dragging = false
                end
            end)
            
            services.UserInputService.InputChanged:Connect(function(input)
                if slider.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSliderValue(input)
                end
            end)
        end
        
        -- 初始化滑块
        updateSlidersFromColor(currentColor)
        
        -- 关闭按钮
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseButton"
        closeBtn.BackgroundColor3 = config.Button_Color
        closeBtn.BackgroundTransparency = 0.2
        closeBtn.BorderSizePixel = 0
        closeBtn.Position = UDim2.new(0.5, -35, 1, -40)
        closeBtn.AnchorPoint = Vector2.new(0.5, 0)
        closeBtn.Size = UDim2.new(0, 70, 0, 25)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Text = "关闭"
        closeBtn.TextColor3 = config.TextColor
        closeBtn.TextSize = 14
        closeBtn.ZIndex = 101
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            pickerFrame.Visible = false
            colorPickerOpen = false
        end)
        
        closeBtn.Parent = pickerFrame
        previewFrame.Parent = pickerFrame
        hexInput.Parent = pickerFrame
        
        return pickerFrame
    end
    
    -- 创建颜色选择器按钮
    local colorPickerBtn = Instance.new("TextButton")
    colorPickerBtn.Name = "ColorPickerBtn"
    colorPickerBtn.BackgroundColor3 = config.Button_Color
    colorPickerBtn.BackgroundTransparency = 0.2
    colorPickerBtn.BorderSizePixel = 0
    colorPickerBtn.Size = UDim2.new(0, parentElement.Size.X.Offset, 0, 36)
    colorPickerBtn.AutoButtonColor = false
    colorPickerBtn.Font = Enum.Font.GothamSemibold
    colorPickerBtn.Text = "  选择颜色"
    colorPickerBtn.TextColor3 = config.TextColor
    colorPickerBtn.TextSize = 14
    colorPickerBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local colorPickerCorner = Instance.new("UICorner")
    colorPickerCorner.CornerRadius = UDim.new(0, 6)
    colorPickerCorner.Parent = colorPickerBtn
    
    -- 颜色预览框
    local colorPreview = Instance.new("Frame")
    colorPreview.Name = "ColorPreview"
    colorPreview.BackgroundColor3 = currentColor
    colorPreview.BorderSizePixel = 0
    colorPreview.Position = UDim2.new(0.85, 0, 0.22, 0)
    colorPreview.Size = UDim2.new(0, 34, 0, 22)
    
    local colorPreviewCorner = Instance.new("UICorner")
    colorPreviewCorner.CornerRadius = UDim.new(0, 6)
    colorPreviewCorner.Parent = colorPreview
    
    local colorPreviewStroke = Instance.new("UIStroke")
    colorPreviewStroke.Color = Color3.new(1, 1, 1)
    colorPreviewStroke.Thickness = 2
    colorPreviewStroke.Transparency = 0.5
    colorPreviewStroke.Parent = colorPreview
    
    colorPreview.Parent = colorPickerBtn
    
    -- 创建颜色选择器框架
    colorPickerFrame = createColorPickerFrame()
    colorPickerFrame.Parent = colorPickerBtn
    
    -- 按钮交互
    colorPickerBtn.MouseEnter:Connect(function()
        services.TweenService:Create(colorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(config.Button_Color.R * 255 * 1.1),
                math.floor(config.Button_Color.G * 255 * 1.1),
                math.floor(config.Button_Color.B * 255 * 1.1)
            )
        }):Play()
    end)
    
    colorPickerBtn.MouseLeave:Connect(function()
        services.TweenService:Create(colorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            BackgroundColor3 = config.Button_Color
        }):Play()
    end)
    
    -- 切换颜色选择器显示
    colorPickerBtn.MouseButton1Click:Connect(function()
        colorPickerOpen = not colorPickerOpen
        colorPickerFrame.Visible = colorPickerOpen
        
        if colorPickerOpen then
            create3DFlipAnimation(colorPreview, 0.3)
        end
    end)
    
    -- 点击外部关闭颜色选择器
    local function onInputBegan(input)
        if colorPickerOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = services.Players.LocalPlayer:GetMouse()
            if colorPickerFrame then
                local framePos = colorPickerFrame.AbsolutePosition
                local frameSize = colorPickerFrame.AbsoluteSize
                
                if mouse.X < framePos.X or mouse.X > framePos.X + frameSize.X or
                   mouse.Y < framePos.Y or mouse.Y > framePos.Y + frameSize.Y then
                    colorPickerOpen = false
                    colorPickerFrame.Visible = false
                end
            end
        end
    end
    
    services.UserInputService.InputBegan:Connect(onInputBegan)
    
    -- 返回控制函数
    local colorPickerController = {
        SetColor = function(self, newColor)
            currentColor = newColor
            colorPreview.BackgroundColor3 = newColor
            if colorPickerFrame then
                local preview = colorPickerFrame:FindFirstChild("ColorPreview")
                if preview then
                    preview.BackgroundColor3 = newColor
                end
                local hexInput = colorPickerFrame:FindFirstChild("HexInput")
                if hexInput then
                    hexInput.Text = colorToHex(newColor)
                end
            end
            if onColorChanged then
                onColorChanged(newColor)
            end
        end,
        
        GetColor = function(self)
            return currentColor
        end,
        
        Destroy = function(self)
            if colorPickerFrame then
                colorPickerFrame:Destroy()
            end
            colorPickerBtn:Destroy()
            services.UserInputService.InputBegan:Disconnect(onInputBegan)
        end
    }
    
    return colorPickerBtn, colorPickerController
end

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
    TitleText.Text = scriptName
    
    local window = {}
    
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1
        
        local Tab = Instance.new("ScrollingFrame")
        local TabIco = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabBtn = Instance.new("TextButton")
        local TabL = Instance.new("UIListLayout")
        local TabContainer = Instance.new("Frame")
        
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.ScrollBarImageTransparency = 0.5
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabContainer.Name = "TabContainer"
        TabContainer.Parent = Tab
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        
        if windowCount == 2 then
    TabContainer.Size = UDim2.new(1, 0, 0, 0)
    
    local LeftContainer = Instance.new("ScrollingFrame")
    LeftContainer.Name = "LeftContainer"
    LeftContainer.Parent = TabContainer
    LeftContainer.BackgroundTransparency = 1
    LeftContainer.Size = UDim2.new(0.48, -2, 1, 0)
    LeftContainer.Position = UDim2.new(0, 2, 0, 0)
    LeftContainer.ScrollBarThickness = 2
    LeftContainer.ScrollBarImageTransparency = 0.5
    LeftContainer.ElasticBehavior = Enum.ElasticBehavior.Never
    LeftContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    LeftContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.Name = "LeftLayout"
    LeftLayout.Parent = LeftContainer
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 4)
    
    local RightContainer = Instance.new("ScrollingFrame")
    RightContainer.Name = "RightContainer"
    RightContainer.Parent = TabContainer
    RightContainer.BackgroundTransparency = 1
    RightContainer.Size = UDim2.new(0.50, -2, 1, 0)
    RightContainer.Position = UDim2.new(0.48, 0, 0, 0)
    RightContainer.ScrollBarThickness = 2
    RightContainer.ScrollBarImageTransparency = 0.5
    RightContainer.ElasticBehavior = Enum.ElasticBehavior.Never
    RightContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    RightContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
    
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.Name = "RightLayout"
    RightLayout.Parent = RightContainer
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 4)
    
    setupSmoothScrolling(LeftContainer, LeftLayout)
    setupSmoothScrolling(RightContainer, RightLayout)
end
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 22, 0, 22)
        TabIco.Image = "rbxassetid://84830962019412"
        TabIco.ImageTransparency = 0.5
        
        startNeonFlowEffect(TabIco, "ImageColor3", 0.005)
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.2, 0, 0, 0)
        TabText.Size = UDim2.new(0, 65, 0, 22)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 90, 0, 22)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = TabContainer
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
        if windowCount == 2 then
            TabL:Destroy()
        else
            setupSmoothScrolling(Tab, TabL)
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            switchTab({ TabIco, Tab })
        end)
        
        if FengUI.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        if windowCount == 2 then
            local function updateContainerHeight()
                local leftHeight = TabContainer:FindFirstChild("LeftContainer"):FindFirstChild("LeftLayout").AbsoluteContentSize.Y
                local rightHeight = TabContainer:FindFirstChild("RightContainer"):FindFirstChild("RightLayout").AbsoluteContentSize.Y
                local maxHeight = math.max(leftHeight, rightHeight) + 10
                
                TabContainer.Size = UDim2.new(1, 0, 0, maxHeight)
                Tab.CanvasSize = UDim2.new(0, 0, 0, maxHeight)
            end
            
            TabContainer:FindFirstChild("LeftContainer"):FindFirstChild("LeftLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContainerHeight)
            TabContainer:FindFirstChild("RightContainer"):FindFirstChild("RightLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateContainerHeight)
        end
        
        local tab = {}
        
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
            Section.Size = UDim2.new(1, 0, 0, 36)
            
            local elementWidth = 330
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    elementWidth = 162
                else
                    elementWidth = 168
                end
            end
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0, 35, 0, 0)
            SectionText.Size = UDim2.new(1, -35, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.AccentColor
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = Section
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, 5, 0, 5)
            SectionOpen.Size = UDim2.new(0, 22, 0, 22)
            SectionOpen.Image = "rbxassetid://84830962019412"
            SectionOpen.ImageColor3 = config.SecondaryTextColor
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(1, 0, 1, 0)
            SectionOpened.Image = "rbxassetid://84830962019412"
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
            
            Section.Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
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
                    Section.Size = UDim2.new(1, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
                end
            end)
            
            local section = {}
            
            -- 新增：颜色选择器组件
            function section.ColorPicker(section, text, flag, defaultColor, callback, colorType)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.new(1, 1, 1)
                assert(text, "No text provided")
                if flag then
                    FengUI.flags[flag] = defaultColor
                end
                
                local ColorPickerModule = Instance.new("Frame")
                ColorPickerModule.Name = "ColorPickerModule"
                ColorPickerModule.Parent = Objs
                ColorPickerModule.BackgroundTransparency = 1
                ColorPickerModule.BorderSizePixel = 0
                ColorPickerModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                local colorType = colorType or "UI"
                local presets = colorPresets
                
                -- 如果是ESP颜色，使用不同的预设
                if colorType:lower():find("esp") then
                    presets = {
                        {"绿色", Color3.fromRGB(0, 255, 0), Color3.fromRGB(50, 255, 50)},
                        {"红色", Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 50, 50)},
                        {"蓝色", Color3.fromRGB(0, 100, 255), Color3.fromRGB(50, 150, 255)},
                        {"黄色", Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 100)},
                        {"紫色", Color3.fromRGB(180, 0, 255), Color3.fromRGB(200, 50, 255)},
                        {"青色", Color3.fromRGB(0, 255, 255), Color3.fromRGB(50, 255, 255)},
                        {"白色", Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220)},
                        {"粉色", Color3.fromRGB(255, 100, 180), Color3.fromRGB(255, 130, 200)},
                    }
                end
                
                -- 创建颜色选择器
                local colorPickerBtn, colorController = createColorPickerUI(ColorPickerModule, defaultColor, function(newColor)
                    if flag then
                        FengUI.flags[flag] = newColor
                        -- 更新config中的对应颜色
                        if config[flag] ~= nil then
                            config[flag] = newColor
                            FengUI.colors[flag] = newColor
                            
                            -- 如果是主要颜色，更新UI外观
                            if flag == "AccentColor" then
                                -- 更新标题颜色
                                services.TweenService:Create(TitleText, TweenInfo.new(0.3), {
                                    TextColor3 = newColor
                                }):Play()
                                
                                -- 更新当前标签颜色
                                if FengUI.currentTab then
                                    services.TweenService:Create(FengUI.currentTab[1].TabText, TweenInfo.new(0.3), {
                                        TextColor3 = newColor
                                    }):Play()
                                end
                                
                                -- 更新打开按钮
                                startNeonFlowEffect(Open, "BackgroundColor3", 0.012)
                            end
                        end
                    end
                    callback(newColor, colorType)
                end, presets)
                
                colorPickerBtn.Text = "   " .. text
                colorPickerBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                
                -- 添加颜色类型标签
                local typeLabel = Instance.new("TextLabel")
                typeLabel.Name = "TypeLabel"
                typeLabel.BackgroundTransparency = 1
                typeLabel.Position = UDim2.new(0.7, 0, 0, 0)
                typeLabel.Size = UDim2.new(0, 60, 1, 0)
                typeLabel.Font = Enum.Font.Gotham
                typeLabel.Text = "[" .. colorType .. "]"
                typeLabel.TextColor3 = colorType:lower():find("esp") and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 200, 255)
                typeLabel.TextSize = 10
                typeLabel.TextXAlignment = Enum.TextXAlignment.Right
                typeLabel.Parent = colorPickerBtn
                
                -- 创建控制函数
                local funcs = {
                    SetColor = function(self, newColor)
                        colorController:SetColor(newColor)
                    end,
                    GetColor = function(self)
                        return colorController:GetColor()
                    end,
                    Destroy = function(self)
                        colorController:Destroy()
                        ColorPickerModule:Destroy()
                    end,
                    Module = ColorPickerModule
                }
                
                return funcs
            end
            
            -- 新增：UI主题颜色选择器（方便使用的快捷函数）
            function section.UIThemePicker(section, text, flag, callback)
                return section:ColorPicker(text, flag or "AccentColor", config.AccentColor, function(newColor, colorType)
                    if callback then
                        callback(newColor)
                    end
                end, "UI主题")
            end
            
            -- 新增：ESP颜色选择器（方便使用的快捷函数）
            function section.ESPColorPicker(section, text, flag, callback)
                return section:ColorPicker(text, flag or "ESP_BoxColor", config.ESP_BoxColor, function(newColor, colorType)
                    if callback then
                        callback(newColor)
                    end
                end, "ESP颜色")
            end
            
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
                Btn.TextSize = 14
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
    
    ImageLabel.Parent = ImageModule
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.BorderSizePixel = 0
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
    ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
    ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, elementWidth), 0, sizeY or 120)
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
            ImageLabel.Image = "rbxassetid://" .. tostring(source)
        end
    end
    
    setImage(imageSource)
    
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
                TextLabel.TextSize = 14
                
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
                ToggleBtn.TextSize = 14
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
                KeybindBtn.TextSize = 14
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
                KeybindValue.TextSize = 12
                
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
                TextboxBack.TextSize = 14
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
    TextBox.TextSize = 12
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
    SliderBack.TextSize = 14.000
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
        SliderValBG.TextSize = 14.000
        
        SliderValBGC.CornerRadius = UDim.new(0, 6)
        SliderValBGC.Name = "SliderValBGC"
        SliderValBGC.Parent = SliderValBG
        
        SliderBack.Text = "   " .. text
    else
        local sliderBarPosition = 0.35
        local sliderBarWidth = 120
        local sliderValuePosition = 0.82
        local minSliderPosition = 0.28
        local addSliderPosition = 0.75
        
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
        SliderValBG.TextSize = 14.000
        
        SliderValBGC.CornerRadius = UDim.new(0, 6)
        SliderValBGC.Name = "SliderValBGC"
        SliderValBGC.Parent = SliderValBG
        
        local MinSlider = Instance.new("TextButton")
        MinSlider.Name = "MinSlider"
        MinSlider.Parent = SliderBack
        MinSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        MinSlider.BackgroundTransparency = 0
        MinSlider.BorderSizePixel = 0
        MinSlider.Position = UDim2.new(minSliderPosition, 0, 0.25, 0)
        MinSlider.Size = UDim2.new(0, 18, 0, 18)
        MinSlider.Font = Enum.Font.Gotham
        MinSlider.Text = "减"
        MinSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinSlider.TextSize = 13.000
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
        AddSlider.Position = UDim2.new(addSliderPosition, 0, 0.25, 0)
        AddSlider.Size = UDim2.new(0, 18, 0, 18)
        AddSlider.Font = Enum.Font.Gotham
        AddSlider.Text = "加"
        AddSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        AddSlider.TextSize = 13.000
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
    SliderValue.TextSize = 11.000
    
    if windowCount == 2 then
        SliderValue.TextSize = 12
        SliderValue.Font = Enum.Font.Gotham
    end
    
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
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            funcs:SetValue()
        end
    end)
    
    services.UserInputService.InputEnded:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            funcs:SetValue()
        end
    end)
    
    local boxFocused = false
    local allowed = { [""] = true, ["-"] = true }
    
    SliderValue.Focused:Connect(function()
        boxFocused = true
    end)
    
    SliderValue.FocusLost:Connect(function()
        boxFocused = false
        if SliderValue.Text == "" then
            funcs:SetValue(default)
            return
        end
        
        local numValue = tonumber(SliderValue.Text)
        if numValue then
            numValue = math.clamp(numValue, min, max)
            funcs:SetValue(numValue)
        else
            funcs:SetValue(default)
        end
    end)
    
    SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
        if not boxFocused then
            return
        end
        
        local text = SliderValue.Text
        local newText = ""
        
        for i = 1, #text do
            local char = text:sub(i, i)
            if char:match("%d") or (char == "." and precise) then
                newText = newText .. char
            end
        end
        
        local dotCount = 0
        local finalText = ""
        for i = 1, #newText do
            local char = newText:sub(i, i)
            if char == "." then
                dotCount = dotCount + 1
                if dotCount <= 1 then
                    finalText = finalText .. char
                end
            else
                finalText = finalText .. char
            end
        end
        
        SliderValue.Text = finalText
        
        local text = SliderValue.Text
        if not tonumber(text) and not allowed[text] then
            SliderValue.Text = SliderValue.Text:gsub("%D+", "")
        elseif not allowed[text] then
            if tonumber(text) > max then
                text = max
                SliderValue.Text = tostring(max)
            end
            funcs:SetValue(tonumber(text))
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
    local DropdownModuleL = Instance.new("UIListLayout")
    
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
    DropdownTop.Size = UDim2.new(0, elementWidth, 0, 36)
    DropdownTop.AutoButtonColor = false
    DropdownTop.Font = Enum.Font.GothamSemibold
    DropdownTop.Text = ""
    DropdownTop.TextColor3 = config.TextColor
    DropdownTop.TextSize = 14.000
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
    
    DropdownOpenFrameC.CornerRadius = UDim.new(0, 4)
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
    DropdownOpen.TextSize = 11.000
    DropdownOpen.TextWrapped = true
    DropdownOpen.ZIndex = 3
    
    DropdownText.Name = "DropdownText"
    DropdownText.Parent = DropdownTop
    DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.BackgroundTransparency = 1.000
    DropdownText.BorderSizePixel = 0
    DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
    DropdownText.Size = UDim2.new(0, 230, 0, 36)
    DropdownText.Font = Enum.Font.GothamSemibold
    DropdownText.PlaceholderColor3 = config.SecondaryTextColor
    DropdownText.PlaceholderText = text
    DropdownText.Text = ""
    DropdownText.TextColor3 = config.TextColor
    DropdownText.TextSize = 14.000
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
        
        DropdownModule.Size = UDim2.new(0, elementWidth, 0, open and (36 + DropdownModuleL.AbsoluteContentSize.Y + 4) or 36)
        
        create3DFlipAnimation(DropdownOpenFrame, 0.3)
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
        if open then
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36 + DropdownModuleL.AbsoluteContentSize.Y + 4)
        end
    end)
    
    local funcs = {}
    funcs.AddOption = function(self, option)
        local Option = Instance.new("TextButton")
        local OptionC = Instance.new("UICorner")
        Option.Name = "Option_" .. option
        Option.Parent = DropdownModule
        Option.BackgroundColor3 = config.TabColor
        Option.BackgroundTransparency = 0.2
        Option.BorderSizePixel = 0
        Option.Position = UDim2.new(0, 0, 0.328125, 0)
        Option.Size = UDim2.new(0, elementWidth - 20, 0, 24)
        Option.AutoButtonColor = false
        Option.Font = Enum.Font.Gotham
        Option.Text = option
        Option.TextColor3 = config.TextColor
        Option.TextSize = 13.000
        OptionC.CornerRadius = UDim.new(0, 6)
        OptionC.Name = "OptionC"
        OptionC.Parent = Option
        
        Option.MouseButton1Click:Connect(function()
            ToggleDropVis()
            callback(Option.Text)
            DropdownText.Text = Option.Text
            FengUI.flags[flag] = Option.Text
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
    
    function window:DualTab(name, icon)
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
    Main.Visible = not ToggleUI
end

-- 新增：获取颜色配置函数
function FengUI:GetColors()
    return FengUI.colors
end

-- 新增：设置颜色函数
function FengUI:SetColor(key, color)
    if config[key] ~= nil then
        config[key] = color
        FengUI.colors[key] = color
        return true
    end
    return false
end

-- 新增：应用UI颜色主题
function FengUI:ApplyTheme(themeName)
    local themes = {
        ["默认"] = {
            MainColor = Color3.fromRGB(18, 18, 30),
            AccentColor = Color3.fromRGB(0, 200, 255),
            TextColor = Color3.fromRGB(240, 245, 255)
        },
        ["暗黑"] = {
            MainColor = Color3.fromRGB(10, 10, 15),
            AccentColor = Color3.fromRGB(100, 100, 120),
            TextColor = Color3.fromRGB(200, 200, 200)
        },
        ["霓虹"] = {
            MainColor = Color3.fromRGB(5, 5, 20),
            AccentColor = Color3.fromRGB(0, 255, 255),
            TextColor = Color3.fromRGB(255, 255, 255)
        },
        ["熔岩"] = {
            MainColor = Color3.fromRGB(20, 5, 5),
            AccentColor = Color3.fromRGB(255, 80, 0),
            TextColor = Color3.fromRGB(255, 240, 220)
        },
        ["森林"] = {
            MainColor = Color3.fromRGB(5, 15, 8),
            AccentColor = Color3.fromRGB(0, 255, 100),
            TextColor = Color3.fromRGB(220, 255, 230)
        }
    }
    
    local theme = themes[themeName]
    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
                FengUI.colors[k] = v
            end
        end
        return true
    end
    return false
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI