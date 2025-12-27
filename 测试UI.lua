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
        Tab.ScrollBarThickness = 0  -- 移除主Tab滚动条
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabContainer.Name = "TabContainer"
        TabContainer.Parent = Tab
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        
        if windowCount == 2 then
            TabContainer.Size = UDim2.new(1, 0, 1, 0)
            
            local LeftContainer = Instance.new("ScrollingFrame")
            LeftContainer.Name = "LeftContainer"
            LeftContainer.Parent = TabContainer
            LeftContainer.BackgroundTransparency = 1
            LeftContainer.Size = UDim2.new(0.48, -2, 1, 0)
            LeftContainer.Position = UDim2.new(0, 2, 0, 0)
            LeftContainer.ScrollBarThickness = 0  -- 移除左容器滚动条
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
            RightContainer.ScrollBarThickness = 0  -- 移除右容器滚动条
            RightContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            RightContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            RightContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Name = "RightLayout"
            RightLayout.Parent = RightContainer
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 4)
            
            -- 修复双窗口滚动问题
            local function updateLeftScrolling()
                LeftContainer.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
                LeftContainer.ScrollingEnabled = LeftLayout.AbsoluteContentSize.Y > LeftContainer.AbsoluteSize.Y
            end
            
            local function updateRightScrolling()
                RightContainer.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
                RightContainer.ScrollingEnabled = RightLayout.AbsoluteContentSize.Y > RightContainer.AbsoluteSize.Y
            end
            
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftScrolling)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightScrolling)
            
            -- 初始化滚动设置
            task.spawn(function()
                task.wait(0.1)
                updateLeftScrolling()
                updateRightScrolling()
            end)
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
            Tab.ScrollingEnabled = false
            Tab.CanvasSize = UDim2.new(0, 0, 1, 0)
            Tab.ScrollBarThickness = 0  -- 确保主Tab也没有滚动条
        else
            Tab.ScrollBarThickness = 0  -- 单窗口模式也移除滚动条
            setupSmoothScrolling(Tab, TabL)
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            switchTab({ TabIco, Tab })
        end)
        
        if FengUI.currentTab == nil then
            switchTab({ TabIco, Tab })
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
            
            local elementWidth = 330
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    elementWidth = 160
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
            
            local function updateSectionHeight()
                Section.Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
            end
            
            updateSectionHeight()
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
                    updateSectionHeight()
                end
            end)
            
            local section = {}
            
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
                
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or elementWidth - 20, elementWidth), 0, sizeY or 120)
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
    
    -- 存储所有选项的表
    local allOptions = {}
    
    local function updateDropdownHeight()
        if not open then return end
        
        local visibleCount = 0
        for _, option in pairs(allOptions) do
            if option and option.Parent and option.Visible then
                visibleCount = visibleCount + 1
            end
        end
        
        if visibleCount == 0 then
            -- 如果没有可见选项，显示一个提示选项
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36 + 28)
        else
            -- 计算总高度：顶部36 + 每个选项28 + 最后一个选项的额外边距4
            local totalHeight = 36 + (visibleCount * 28) + 4
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, totalHeight)
        end
    end
    
    local function setAllVisible()
        for _, option in pairs(allOptions) do
            if option then
                option.Visible = true
            end
        end
        updateDropdownHeight()
    end
    
    local function searchDropdown(text)
        local visibleCount = 0
        
        for _, option in pairs(allOptions) do
            if option then
                if text == "" then
                    option.Visible = true
                else
                    option.Visible = option.Text:lower():match(text:lower()) ~= nil
                end
                
                if option.Visible then
                    visibleCount = visibleCount + 1
                end
            end
        end
        
        -- 如果没有可见选项，显示提示
        if visibleCount == 0 and text ~= "" then
            -- 可以在这里添加"无结果"提示
        end
        
        updateDropdownHeight()
    end
    
    local open = false
    local function toggleDropdown()
        open = not open
        DropdownOpen.Text = open and "取消" or "选择"
        
        if open then
            setAllVisible()
            updateDropdownHeight()
        else
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36)
        end
        
        create3DFlipAnimation(DropdownOpenFrame, 0.3)
    end
    
    DropdownOpen.MouseButton1Click:Connect(toggleDropdown)
    
    DropdownText.Focused:Connect(function()
        if not open then
            toggleDropdown()
        end
    end)
    
    DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
        if open then
            searchDropdown(DropdownText.Text)
        end
    end)
    
    DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateDropdownHeight()
    end)
    
    local funcs = {}
    
    funcs.AddOption = function(self, optionText)
        local Option = Instance.new("TextButton")
        local OptionC = Instance.new("UICorner")
        
        Option.Name = "Option_" .. optionText
        Option.Parent = DropdownModule
        Option.BackgroundColor3 = config.TabColor
        Option.BackgroundTransparency = 0.2
        Option.BorderSizePixel = 0
        Option.Position = UDim2.new(0, 0, 0.328125, 0)
        Option.Size = UDim2.new(0, elementWidth - 20, 0, 24)
        Option.AutoButtonColor = false
        Option.Font = Enum.Font.Gotham
        Option.Text = optionText
        Option.TextColor3 = config.TextColor
        Option.TextSize = 13.000
        Option.Visible = open  -- 根据下拉状态设置初始可见性
        
        OptionC.CornerRadius = UDim.new(0, 6)
        OptionC.Name = "OptionC"
        OptionC.Parent = Option
        
        -- 存储到所有选项表
        table.insert(allOptions, Option)
        
        Option.MouseButton1Click:Connect(function()
            toggleDropdown()
            callback(Option.Text)
            DropdownText.Text = Option.Text
            FengUI.flags[flag] = Option.Text
        end)
        
        updateDropdownHeight()
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
        -- 清除现有选项
        for _, option in pairs(allOptions) do
            if option then
                option:Destroy()
            end
        end
        allOptions = {}
        
        -- 添加新选项
        for _, optionText in pairs(newOptions) do
            funcs:AddOption(optionText)
        end
        
        updateDropdownHeight()
    end
    
    funcs:SetOptions(options)
    
    return funcs
end

-- ... (前面所有代码保持不变，直到找到 section 函数的末尾)

-- 在 section 函数中，找到所有控件函数定义的位置
-- 在 section.Dropdown 函数之后，添加 section.Colorpicker 函数

function section.Colorpicker(section, text, flag, default, callback)
    callback = callback or function() end
    default = default or Color3.fromRGB(255, 255, 255)
    assert(text, "No text provided")
    assert(flag, "No flag provided")
    FengUI.flags[flag] = default
    
    local ColorpickerModule = Instance.new("Frame")
    local ColorpickerBtn = Instance.new("TextButton")
    local ColorpickerBtnC = Instance.new("UICorner")
    local ColorDisplay = Instance.new("Frame")
    local ColorDisplayC = Instance.new("UICorner")
    local ColorValue = Instance.new("TextButton")
    local ColorValueC = Instance.new("UICorner")
    
    ColorpickerModule.Name = "ColorpickerModule"
    ColorpickerModule.Parent = Objs
    ColorpickerModule.BackgroundTransparency = 1
    ColorpickerModule.BorderSizePixel = 0
    ColorpickerModule.Size = UDim2.new(0, elementWidth, 0, 36)
    
    ColorpickerBtn.Name = "ColorpickerBtn"
    ColorpickerBtn.Parent = ColorpickerModule
    ColorpickerBtn.BackgroundColor3 = config.Dropdown_Color
    ColorpickerBtn.BackgroundTransparency = 0.2
    ColorpickerBtn.BorderSizePixel = 0
    ColorpickerBtn.Size = UDim2.new(0, elementWidth, 0, 36)
    ColorpickerBtn.AutoButtonColor = false
    ColorpickerBtn.Font = Enum.Font.GothamSemibold
    ColorpickerBtn.Text = "   " .. text
    ColorpickerBtn.TextColor3 = config.TextColor
    ColorpickerBtn.TextSize = 14
    ColorpickerBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    ColorpickerBtnC.CornerRadius = UDim.new(0, 6)
    ColorpickerBtnC.Name = "ColorpickerBtnC"
    ColorpickerBtnC.Parent = ColorpickerBtn
    
    local colorpickerPosition = 0.75
    if windowCount == 2 then
        colorpickerPosition = 0.67
    end
    
    ColorDisplay.Name = "ColorDisplay"
    ColorDisplay.Parent = ColorpickerBtn
    ColorDisplay.BackgroundColor3 = default
    ColorDisplay.BorderSizePixel = 0
    ColorDisplay.Position = UDim2.new(colorpickerPosition, 0, 0.22, 0)
    ColorDisplay.Size = UDim2.new(0, 22, 0, 22)
    
    ColorDisplayC.CornerRadius = UDim.new(0, 4)
    ColorDisplayC.Name = "ColorDisplayC"
    ColorDisplayC.Parent = ColorDisplay
    
    local colorDisplayStroke = Instance.new("UIStroke")
    colorDisplayStroke.Parent = ColorDisplay
    colorDisplayStroke.Color = Color3.fromRGB(255, 255, 255)
    colorDisplayStroke.Thickness = 1
    colorDisplayStroke.Transparency = 0.3
    
    local colorDisplayGlow = Instance.new("UIStroke")
    colorDisplayGlow.Parent = ColorDisplay
    colorDisplayGlow.Color = Color3.fromRGB(255, 255, 255)
    colorDisplayGlow.Thickness = 2
    colorDisplayGlow.Transparency = 0.8
    
    createPulseGlow(colorDisplayGlow)
    
    ColorValue.Name = "ColorValue"
    ColorValue.Parent = ColorpickerBtn
    ColorValue.BackgroundColor3 = config.Bg_Color
    ColorValue.BorderSizePixel = 0
    ColorValue.Position = UDim2.new(colorpickerPosition + 0.08, 0, 0.22, 0)
    ColorValue.Size = UDim2.new(0, 50, 0, 22)
    ColorValue.AutoButtonColor = false
    ColorValue.Font = Enum.Font.Gotham
    ColorValue.Text = "#" .. default:ToHex():upper()
    ColorValue.TextColor3 = config.TextColor
    ColorValue.TextSize = 12
    
    ColorValueC.CornerRadius = UDim.new(0, 6)
    ColorValueC.Name = "ColorValueC"
    ColorValueC.Parent = ColorValue
    
    ColorpickerBtn.MouseEnter:Connect(function()
        services.TweenService:Create(ColorpickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(config.Dropdown_Color.R * 255 * 1.1),
                math.floor(config.Dropdown_Color.G * 255 * 1.1),
                math.floor(config.Dropdown_Color.B * 255 * 1.1)
            )
        }):Play()
    end)
    
    ColorpickerBtn.MouseLeave:Connect(function()
        services.TweenService:Create(ColorpickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            BackgroundColor3 = config.Dropdown_Color
        }):Play()
    end)
    
    -- 创建颜色选择器对话框
    local function createColorPickerDialog()
        local dialog = Instance.new("Frame")
        dialog.Name = "ColorPickerDialog"
        dialog.BackgroundColor3 = config.TabColor
        dialog.BackgroundTransparency = 0
        dialog.BorderSizePixel = 0
        dialog.Size = UDim2.new(0, 300, 0, 350)
        dialog.Position = UDim2.new(0.5, -150, 0.5, -175)
        dialog.Parent = FengYu
        dialog.ZIndex = 100
        dialog.Visible = false
        
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 10)
        dialogCorner.Parent = dialog
        
        local dialogStroke = Instance.new("UIStroke")
        dialogStroke.Parent = dialog
        dialogStroke.Color = config.AccentColor
        dialogStroke.Thickness = 2
        dialogStroke.Transparency = 0.3
        
        local titleBar = Instance.new("Frame")
        titleBar.Name = "TitleBar"
        titleBar.Parent = dialog
        titleBar.BackgroundColor3 = config.Button_Color
        titleBar.BackgroundTransparency = 0
        titleBar.Size = UDim2.new(1, 0, 0, 35)
        
        local titleText = Instance.new("TextLabel")
        titleText.Name = "TitleText"
        titleText.Parent = titleBar
        titleText.BackgroundTransparency = 1
        titleText.Position = UDim2.new(0, 10, 0, 0)
        titleText.Size = UDim2.new(1, -20, 1, 0)
        titleText.Font = Enum.Font.GothamBold
        titleText.Text = "Color Picker"
        titleText.TextColor3 = config.AccentColor
        titleText.TextSize = 14
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "CloseButton"
        closeButton.Parent = titleBar
        closeButton.BackgroundTransparency = 1
        closeButton.Position = UDim2.new(1, -25, 0, 5)
        closeButton.Size = UDim2.new(0, 25, 0, 25)
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
        closeButton.TextSize = 16
        
        closeButton.MouseButton1Click:Connect(function()
            dialog:Destroy()
        end)
        
        -- 颜色预览
        local previewFrame = Instance.new("Frame")
        previewFrame.Name = "PreviewFrame"
        previewFrame.Parent = dialog
        previewFrame.BackgroundColor3 = default
        previewFrame.BorderSizePixel = 0
        previewFrame.Position = UDim2.new(0, 10, 0, 45)
        previewFrame.Size = UDim2.new(0, 280, 0, 40)
        
        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 6)
        previewCorner.Parent = previewFrame
        
        local previewStroke = Instance.new("UIStroke")
        previewStroke.Parent = previewFrame
        previewStroke.Color = Color3.fromRGB(255, 255, 255)
        previewStroke.Thickness = 1
        previewStroke.Transparency = 0.5
        
        -- 色相选择器
        local hueFrame = Instance.new("Frame")
        hueFrame.Name = "HueFrame"
        hueFrame.Parent = dialog
        hueFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        hueFrame.BorderSizePixel = 0
        hueFrame.Position = UDim2.new(0, 10, 0, 100)
        hueFrame.Size = UDim2.new(0, 280, 0, 30)
        
        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(0, 6)
        hueCorner.Parent = hueFrame
        
        -- 色相渐变
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
        hueGradient.Parent = hueFrame
        
        local hueSelector = Instance.new("Frame")
        hueSelector.Name = "HueSelector"
        hueSelector.Parent = hueFrame
        hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueSelector.BorderSizePixel = 0
        hueSelector.Size = UDim2.new(0, 4, 1, 0)
        hueSelector.Position = UDim2.new(0, 0, 0, 0)
        
        -- 饱和度/亮度选择器
        local svFrame = Instance.new("Frame")
        svFrame.Name = "SVFrame"
        svFrame.Parent = dialog
        svFrame.BackgroundColor3 = default
        svFrame.BorderSizePixel = 0
        svFrame.Position = UDim2.new(0, 10, 0, 140)
        svFrame.Size = UDim2.new(0, 280, 0, 120)
        
        local svCorner = Instance.new("UICorner")
        svCorner.CornerRadius = UDim.new(0, 6)
        svCorner.Parent = svFrame
        
        local svGradientH = Instance.new("UIGradient")
        svGradientH.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(default:ToHSV()))
        })
        svGradientH.Parent = svFrame
        
        local svGradientV = Instance.new("UIGradient")
        svGradientV.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
        })
        svGradientV.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        svGradientV.Rotation = 90
        svGradientV.Parent = svFrame
        
        local svSelector = Instance.new("Frame")
        svSelector.Name = "SVSelector"
        svSelector.Parent = svFrame
        svSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        svSelector.BorderSizePixel = 0
        svSelector.Size = UDim2.new(0, 10, 0, 10)
        svSelector.Position = UDim2.new(0.5, -5, 0.5, -5)
        
        local svSelectorCorner = Instance.new("UICorner")
        svSelectorCorner.CornerRadius = UDim.new(1, 0)
        svSelectorCorner.Parent = svSelector
        
        local svSelectorStroke = Instance.new("UIStroke")
        svSelectorStroke.Parent = svSelector
        svSelectorStroke.Color = Color3.fromRGB(0, 0, 0)
        svSelectorStroke.Thickness = 2
        
        -- RGB 输入框
        local rgbFrame = Instance.new("Frame")
        rgbFrame.Name = "RGBFrame"
        rgbFrame.Parent = dialog
        rgbFrame.BackgroundTransparency = 1
        rgbFrame.Position = UDim2.new(0, 10, 0, 270)
        rgbFrame.Size = UDim2.new(1, -20, 0, 70)
        
        local rLabel = Instance.new("TextLabel")
        rLabel.Name = "RLabel"
        rLabel.Parent = rgbFrame
        rLabel.BackgroundTransparency = 1
        rLabel.Position = UDim2.new(0, 0, 0, 0)
        rLabel.Size = UDim2.new(0, 20, 0, 20)
        rLabel.Font = Enum.Font.Gotham
        rLabel.Text = "R:"
        rLabel.TextColor3 = config.TextColor
        rLabel.TextSize = 12
        rLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local rInput = Instance.new("TextBox")
        rInput.Name = "RInput"
        rInput.Parent = rgbFrame
        rInput.BackgroundColor3 = config.Bg_Color
        rInput.BorderSizePixel = 0
        rInput.Position = UDim2.new(0, 25, 0, 0)
        rInput.Size = UDim2.new(0, 60, 0, 20)
        rInput.Font = Enum.Font.Gotham
        rInput.Text = tostring(math.floor(default.R * 255))
        rInput.TextColor3 = config.TextColor
        rInput.TextSize = 12
        
        local gLabel = Instance.new("TextLabel")
        gLabel.Name = "GLabel"
        gLabel.Parent = rgbFrame
        gLabel.BackgroundTransparency = 1
        gLabel.Position = UDim2.new(0, 100, 0, 0)
        gLabel.Size = UDim2.new(0, 20, 0, 20)
        gLabel.Font = Enum.Font.Gotham
        gLabel.Text = "G:"
        gLabel.TextColor3 = config.TextColor
        gLabel.TextSize = 12
        gLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local gInput = Instance.new("TextBox")
        gInput.Name = "GInput"
        gInput.Parent = rgbFrame
        gInput.BackgroundColor3 = config.Bg_Color
        gInput.BorderSizePixel = 0
        gInput.Position = UDim2.new(0, 125, 0, 0)
        gInput.Size = UDim2.new(0, 60, 0, 20)
        gInput.Font = Enum.Font.Gotham
        gInput.Text = tostring(math.floor(default.G * 255))
        gInput.TextColor3 = config.TextColor
        gInput.TextSize = 12
        
        local bLabel = Instance.new("TextLabel")
        bLabel.Name = "BLabel"
        bLabel.Parent = rgbFrame
        bLabel.BackgroundTransparency = 1
        bLabel.Position = UDim2.new(0, 200, 0, 0)
        bLabel.Size = UDim2.new(0, 20, 0, 20)
        bLabel.Font = Enum.Font.Gotham
        bLabel.Text = "B:"
        bLabel.TextColor3 = config.TextColor
        bLabel.TextSize = 12
        bLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local bInput = Instance.new("TextBox")
        bInput.Name = "BInput"
        bInput.Parent = rgbFrame
        bInput.BackgroundColor3 = config.Bg_Color
        bInput.BorderSizePixel = 0
        bInput.Position = UDim2.new(0, 225, 0, 0)
        bInput.Size = UDim2.new(0, 60, 0, 20)
        bInput.Font = Enum.Font.Gotham
        bInput.Text = tostring(math.floor(default.B * 255))
        bInput.TextColor3 = config.TextColor
        bInput.TextSize = 12
        
        -- 十六进制输入
        local hexLabel = Instance.new("TextLabel")
        hexLabel.Name = "HexLabel"
        hexLabel.Parent = rgbFrame
        hexLabel.BackgroundTransparency = 1
        hexLabel.Position = UDim2.new(0, 0, 0, 30)
        hexLabel.Size = UDim2.new(0, 30, 0, 20)
        hexLabel.Font = Enum.Font.Gotham
        hexLabel.Text = "Hex:"
        hexLabel.TextColor3 = config.TextColor
        hexLabel.TextSize = 12
        hexLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local hexInput = Instance.new("TextBox")
        hexInput.Name = "HexInput"
        hexInput.Parent = rgbFrame
        hexInput.BackgroundColor3 = config.Bg_Color
        hexInput.BorderSizePixel = 0
        hexInput.Position = UDim2.new(0, 40, 0, 30)
        hexInput.Size = UDim2.new(0, 120, 0, 20)
        hexInput.Font = Enum.Font.Gotham
        hexInput.Text = "#" .. default:ToHex():upper()
        hexInput.TextColor3 = config.TextColor
        hexInput.TextSize = 12
        
        -- 确定按钮
        local confirmButton = Instance.new("TextButton")
        confirmButton.Name = "ConfirmButton"
        confirmButton.Parent = dialog
        confirmButton.BackgroundColor3 = config.AccentColor
        confirmButton.BackgroundTransparency = 0.2
        confirmButton.BorderSizePixel = 0
        confirmButton.Position = UDim2.new(0, 10, 1, -40)
        confirmButton.Size = UDim2.new(0.5, -15, 0, 30)
        confirmButton.Font = Enum.Font.GothamBold
        confirmButton.Text = "确认"
        confirmButton.TextColor3 = config.TextColor
        confirmButton.TextSize = 14
        
        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 6)
        confirmCorner.Parent = confirmButton
        
        -- 取消按钮
        local cancelButton = Instance.new("TextButton")
        cancelButton.Name = "CancelButton"
        cancelButton.Parent = dialog
        cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
        cancelButton.BackgroundTransparency = 0.2
        cancelButton.BorderSizePixel = 0
        cancelButton.Position = UDim2.new(0.5, 5, 1, -40)
        cancelButton.Size = UDim2.new(0.5, -15, 0, 30)
        cancelButton.Font = Enum.Font.GothamBold
        cancelButton.Text = "取消"
        cancelButton.TextColor3 = config.TextColor
        cancelButton.TextSize = 14
        
        local cancelCorner = Instance.new("UICorner")
        cancelCorner.CornerRadius = UDim.new(0, 6)
        cancelCorner.Parent = cancelButton
        
        -- 更新颜色函数
        local function updateColor(h, s, v)
            local newColor = Color3.fromHSV(h, s, v)
            ColorDisplay.BackgroundColor3 = newColor
            previewFrame.BackgroundColor3 = newColor
            svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svGradientH.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
            })
            
            rInput.Text = tostring(math.floor(newColor.R * 255))
            gInput.Text = tostring(math.floor(newColor.G * 255))
            bInput.Text = tostring(math.floor(newColor.B * 255))
            hexInput.Text = "#" .. newColor:ToHex():upper()
        end
        
        -- 从RGB更新
        local function updateFromRGB()
            local r = tonumber(rInput.Text) or 0
            local g = tonumber(gInput.Text) or 0
            local b = tonumber(bInput.Text) or 0
            
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            
            local newColor = Color3.fromRGB(r, g, b)
            local h, s, v = newColor:ToHSV()
            
            hueSelector.Position = UDim2.new(h, 0, 0, 0)
            svSelector.Position = UDim2.new(s, -5, 1 - v, -5)
            updateColor(h, s, v)
        end
        
        -- 从HEX更新
        local function updateFromHex()
            local hex = hexInput.Text
            hex = hex:gsub("#", "")
            
            if #hex == 6 then
                local r = tonumber("0x" .. hex:sub(1, 2)) or 0
                local g = tonumber("0x" .. hex:sub(3, 4)) or 0
                local b = tonumber("0x" .. hex:sub(5, 6)) or 0
                
                local newColor = Color3.fromRGB(r, g, b)
                local h, s, v = newColor:ToHSV()
                
                hueSelector.Position = UDim2.new(h, 0, 0, 0)
                svSelector.Position = UDim2.new(s, -5, 1 - v, -5)
                updateColor(h, s, v)
            end
        end
        
        -- 色相滑块事件
        local hueDragging = false
        hueFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = true
            end
        end)
        
        hueFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hueDragging = false
            end
        end)
        
        services.UserInputService.InputChanged:Connect(function(input)
            if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position
                local framePos = hueFrame.AbsolutePosition
                local frameSize = hueFrame.AbsoluteSize
                
                local x = math.clamp(mousePos.X - framePos.X, 0, frameSize.X)
                local h = x / frameSize.X
                
                hueSelector.Position = UDim2.new(h, 0, 0, 0)
                
                local currentH, currentS, currentV = ColorDisplay.BackgroundColor3:ToHSV()
                updateColor(h, currentS, currentV)
            end
        end)
        
        -- 饱和度/亮度选择器事件
        local svDragging = false
        svFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDragging = true
            end
        end)
        
        svFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                svDragging = false
            end
        end)
        
        services.UserInputService.InputChanged:Connect(function(input)
            if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = input.Position
                local framePos = svFrame.AbsolutePosition
                local frameSize = svFrame.AbsoluteSize
                
                local x = math.clamp(mousePos.X - framePos.X, 0, frameSize.X)
                local y = math.clamp(mousePos.Y - framePos.Y, 0, frameSize.Y)
                
                local s = x / frameSize.X
                local v = 1 - (y / frameSize.Y)
                
                svSelector.Position = UDim2.new(s, -5, 1 - v, -5)
                
                local currentH = hueSelector.Position.X.Scale
                updateColor(currentH, s, v)
            end
        end)
        
        -- RGB输入事件
        rInput.FocusLost:Connect(updateFromRGB)
        gInput.FocusLost:Connect(updateFromRGB)
        bInput.FocusLost:Connect(updateFromRGB)
        
        -- HEX输入事件
        hexInput.FocusLost:Connect(updateFromHex)
        
        -- 按钮事件
        confirmButton.MouseButton1Click:Connect(function()
            local finalColor = ColorDisplay.BackgroundColor3
            FengUI.flags[flag] = finalColor
            ColorValue.Text = "#" .. finalColor:ToHex():upper()
            callback(finalColor)
            dialog:Destroy()
        end)
        
        cancelButton.MouseButton1Click:Connect(function()
            dialog:Destroy()
        end)
        
        -- 显示对话框
        dialog.Visible = true
        
        -- 添加淡入动画
        dialog.BackgroundTransparency = 1
        services.TweenService:Create(dialog, TweenInfo.new(0.3), {
            BackgroundTransparency = 0
        }):Play()
        
        return dialog
    end
    
    ColorDisplay.MouseButton1Click:Connect(function()
        createColorPickerDialog()
    end)
    
    ColorValue.MouseButton1Click:Connect(function()
        createColorPickerDialog()
    end)
    
    local colorpickerController = {}
    
    function colorpickerController:SetColor(newColor)
        if typeof(newColor) == "Color3" then
            ColorDisplay.BackgroundColor3 = newColor
            ColorValue.Text = "#" .. newColor:ToHex():upper()
            FengUI.flags[flag] = newColor
            callback(newColor)
        end
    end
    
    function colorpickerController:GetColor()
        return ColorDisplay.BackgroundColor3
    end
    
    function colorpickerController:Destroy()
        ColorpickerModule:Destroy()
    end
    
    colorpickerController.Instance = ColorDisplay
    colorpickerController.Module = ColorpickerModule
    
    return colorpickerController
end

-- ... (后面所有代码保持不变，直到文件结束)
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

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI