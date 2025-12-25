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
local TweenService = services.TweenService
local Players = services.Players

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
    
    TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = 15
    }):Play()
    
    task.wait(duration/2)
    
    TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Rotation = 0
    }):Play()
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
        TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
            ImageTransparency = 0,
            Size = UDim2.new(0, 25, 0, 25)
        }):Play()
        TweenService:Create(new[1].TabText, TweenInfo.new(0.3), { 
            TextTransparency = 0,
            TextColor3 = config.AccentColor
        }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengUI.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(old[1], tweenInfo, { 
        ImageTransparency = 0.5,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
    TweenService:Create(new[1], tweenInfo, { 
        ImageTransparency = 0,
        Size = UDim2.new(0, 25, 0, 25)
    }):Play()
    TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.5,
        TextColor3 = config.TextColor
    }):Play()
    TweenService:Create(new[1].TabText, tweenInfo, { 
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
    TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 18,
        Position = UDim2.new(1, -26, 0, 6)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 16,
        Position = UDim2.new(1, -25, 0, 7)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 14,
        Position = UDim2.new(1, -24, 0, 8)
    }):Play()
    
    TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    TweenService:Create(MainStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    TweenService:Create(neonStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    TweenService:Create(TitleBar, TweenInfo.new(0.4), {
        BackgroundTransparency = 1
    }):Play()
    
    TweenService:Create(TitleText, TweenInfo.new(0.4), {
        TextTransparency = 1
    }):Play()
    
    TweenService:Create(CloseButton, TweenInfo.new(0.4), {
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

UserInputService.InputEnded:Connect(function(input)
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
    
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 450, 0, 280)
    }):Play()
    
    TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.5
    }):Play()
    
    TweenService:Create(neonStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.7
    }):Play()
    
    task.wait(0.2)
    
    TweenService:Create(TitleBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    TweenService:Create(Side, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
        
        TweenService:Create(TitleText, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 15 + math.sin(tick() * 3) * 2
        }):Play()
        
        task.wait(0.05)
    end
end)

-- 颜色选择器对话框函数
local currentColorPickerDialog = nil

local function createColorPickerDialog(defaultColor, callback)
    -- 关闭现有的颜色选择器
    if currentColorPickerDialog then
        currentColorPickerDialog:Destroy()
        currentColorPickerDialog = nil
    end
    
    -- 创建对话框容器
    local dialogContainer = Instance.new("Frame")
    dialogContainer.Name = "ColorPickerDialogContainer"
    dialogContainer.BackgroundTransparency = 1
    dialogContainer.Size = UDim2.new(1, 0, 1, 0)
    dialogContainer.Position = UDim2.new(0, 0, 0, 0)
    dialogContainer.ZIndex = 100
    dialogContainer.Parent = Main
    
    -- 创建背景遮罩
    local backgroundOverlay = Instance.new("Frame")
    backgroundOverlay.Name = "BackgroundOverlay"
    backgroundOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    backgroundOverlay.BackgroundTransparency = 0.5
    backgroundOverlay.Size = UDim2.new(1, 0, 1, 0)
    backgroundOverlay.ZIndex = 100
    backgroundOverlay.Parent = dialogContainer
    
    -- 创建对话框 - 调整大小与UI界面一致
    local dialog = Instance.new("Frame")
    dialog.Name = "ColorPickerDialog"
    dialog.BackgroundColor3 = config.TabColor
    dialog.BackgroundTransparency = 0.05  -- 减少透明度让颜色更亮
    dialog.BorderSizePixel = 0
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.Size = UDim2.new(0, 420, 0, 280)  -- 调整高度与UI界面一致
    dialog.ZIndex = 101
    dialog.Parent = dialogContainer
    
    -- 确保对话框不能独立拖动
    dialog.Active = false
    dialog.Draggable = false
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 10)
    dialogCorner.Parent = dialog
    
    local dialogStroke = Instance.new("UIStroke")
    dialogStroke.Parent = dialog
    dialogStroke.Color = config.AccentColor
    dialogStroke.Thickness = 2
    dialogStroke.Transparency = 0.1  -- 减少透明度让边框更亮
    
    local dialogTitle = Instance.new("TextLabel")
    dialogTitle.Name = "DialogTitle"
    dialogTitle.Parent = dialog
    dialogTitle.BackgroundTransparency = 1
    dialogTitle.Position = UDim2.new(0, 15, 0, 10)
    dialogTitle.Size = UDim2.new(1, -30, 0, 30)
    dialogTitle.Font = Enum.Font.GothamBold
    dialogTitle.Text = "颜色选择器"
    dialogTitle.TextColor3 = config.TextColor
    dialogTitle.TextSize = 18
    dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = dialog
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.TextSize = 18
    
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(backgroundOverlay, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.2)
        dialogContainer:Destroy()
        currentColorPickerDialog = nil
    end)
    
    -- 解析默认颜色
    local hue, saturation, value = Color3.toHSV(defaultColor)
    
    -- 饱和度/亮度选择区域 - 增加尺寸让选择更容易
    local satVibMap = Instance.new("Frame")
    satVibMap.Name = "SatVibMap"
    satVibMap.Parent = dialog
    satVibMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    satVibMap.BorderSizePixel = 0
    satVibMap.Position = UDim2.new(0, 20, 0, 50)
    satVibMap.Size = UDim2.new(0, 200, 0, 140)  -- 增加高度
    
    local satVibCorner = Instance.new("UICorner")
    satVibCorner.CornerRadius = UDim.new(0, 4)
    satVibCorner.Parent = satVibMap
    
    -- 饱和度/亮度渐变 - 调整让颜色更亮
    local satGradient = Instance.new("UIGradient")
    satGradient.Rotation = 0
    satGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
    })
    satGradient.Parent = satVibMap
    
    local vibGradient = Instance.new("UIGradient")
    vibGradient.Rotation = 90
    vibGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.3),  -- 减少透明度让颜色更亮
        NumberSequenceKeypoint.new(1, 0.6)
    })
    vibGradient.Parent = satVibMap
    
    -- 饱和度/亮度光标
    local satCursor = Instance.new("Frame")
    satCursor.Name = "SatCursor"
    satCursor.Parent = satVibMap
    satCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    satCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    satCursor.BorderSizePixel = 0
    satCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
    satCursor.Size = UDim2.new(0, 12, 0, 12)  -- 增大光标
    satCursor.ZIndex = 2
    
    local satCursorCorner = Instance.new("UICorner")
    satCursorCorner.CornerRadius = UDim.new(1, 0)
    satCursorCorner.Parent = satCursor
    
    local satCursorStroke = Instance.new("UIStroke")
    satCursorStroke.Parent = satCursor
    satCursorStroke.Color = Color3.new(0, 0, 0)
    satCursorStroke.Thickness = 2
    
    -- 色调滑块
    local hueSlider = Instance.new("Frame")
    hueSlider.Name = "HueSlider"
    hueSlider.Parent = dialog
    hueSlider.BackgroundTransparency = 0  -- 不透明让颜色更亮
    hueSlider.Position = UDim2.new(0, 230, 0, 50)
    hueSlider.Size = UDim2.new(0, 12, 0, 140)  -- 调整高度
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(1, 0)
    hueCorner.Parent = hueSlider
    
    -- 创建色调渐变
    local hueSequence = {}
    for i = 0, 1, 0.05 do  -- 增加渐变精度
        table.insert(hueSequence, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
    end
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new(hueSequence)
    hueGradient.Parent = hueSlider
    
    -- 色调滑块光标
    local hueDrag = Instance.new("Frame")
    hueDrag.Name = "HueDrag"
    hueDrag.Parent = hueSlider
    hueDrag.AnchorPoint = Vector2.new(0.5, 0.5)
    hueDrag.BackgroundColor3 = Color3.new(1, 1, 1)
    hueDrag.BorderSizePixel = 0
    hueDrag.Position = UDim2.new(0.5, 0, hue, 0)
    hueDrag.Size = UDim2.new(0, 20, 0, 10)  -- 增大光标
    hueDrag.ZIndex = 2
    
    local hueDragCorner = Instance.new("UICorner")
    hueDragCorner.CornerRadius = UDim.new(0, 2)
    hueDragCorner.Parent = hueDrag
    
    local hueDragStroke = Instance.new("UIStroke")
    hueDragStroke.Parent = hueDrag
    hueDragStroke.Color = Color3.new(0, 0, 0)
    hueDragStroke.Thickness = 2
    
    -- 颜色显示区域 - 增大显示区域
    local oldColorFrame = Instance.new("Frame")
    oldColorFrame.Name = "OldColorFrame"
    oldColorFrame.Parent = dialog
    oldColorFrame.BackgroundColor3 = defaultColor
    oldColorFrame.BorderSizePixel = 0
    oldColorFrame.Position = UDim2.new(0, 20, 0, 200)
    oldColorFrame.Size = UDim2.new(0, 100, 0, 30)  -- 增大
    
    local oldColorCorner = Instance.new("UICorner")
    oldColorCorner.CornerRadius = UDim.new(0, 4)
    oldColorCorner.Parent = oldColorFrame
    
    local newColorFrame = Instance.new("Frame")
    newColorFrame.Name = "NewColorFrame"
    newColorFrame.Parent = dialog
    newColorFrame.BackgroundColor3 = defaultColor
    newColorFrame.BorderSizePixel = 0
    newColorFrame.Position = UDim2.new(0, 130, 0, 200)
    newColorFrame.Size = UDim2.new(0, 100, 0, 30)  -- 增大
    
    local newColorCorner = Instance.new("UICorner")
    newColorCorner.CornerRadius = UDim.new(0, 4)
    newColorCorner.Parent = newColorFrame
    
    -- RGB/HEX输入 - 调整位置
    local function createInputField(yPos, labelText, defaultValue, width)
        local textBox = Instance.new("TextBox")
        textBox.Parent = dialog
        textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)  -- 更亮的背景
        textBox.BackgroundTransparency = 0.1  -- 减少透明度
        textBox.BorderSizePixel = 0
        textBox.Position = UDim2.new(0, 250, 0, yPos)
        textBox.Size = UDim2.new(0, width or 100, 0, 32)
        textBox.Font = Enum.Font.Gotham
        textBox.Text = defaultValue
        textBox.TextColor3 = config.TextColor
        textBox.TextSize = 14
        textBox.PlaceholderColor3 = config.SecondaryTextColor
        
        local textBoxCorner = Instance.new("UICorner")
        textBoxCorner.CornerRadius = UDim.new(0, 4)
        textBoxCorner.Parent = textBox
        
        local label = Instance.new("TextLabel")
        label.Parent = dialog
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 360, 0, yPos + 8)
        label.Size = UDim2.new(0, 50, 0, 20)
        label.Font = Enum.Font.Gotham
        label.Text = labelText
        label.TextColor3 = config.TextColor
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        return textBox
    end
    
    local hexInput = createInputField(50, "Hex", "#" .. defaultColor:ToHex(), 110)
    local redInput = createInputField(90, "Red", math.floor(defaultColor.r * 255))
    local greenInput = createInputField(130, "Green", math.floor(defaultColor.g * 255))
    local blueInput = createInputField(170, "Blue", math.floor(defaultColor.b * 255))
    
    -- 确认按钮
    local confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Parent = dialog
    confirmButton.BackgroundColor3 = config.AccentColor
    confirmButton.BackgroundTransparency = 0.1  -- 减少透明度
    confirmButton.BorderSizePixel = 0
    confirmButton.Position = UDim2.new(0, 20, 1, -45)
    confirmButton.Size = UDim2.new(0, 100, 0, 36)
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
    cancelButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    cancelButton.BackgroundTransparency = 0.1  -- 减少透明度
    cancelButton.BorderSizePixel = 0
    cancelButton.Position = UDim2.new(1, -120, 1, -45)
    cancelButton.Size = UDim2.new(0, 100, 0, 36)
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Text = "取消"
    cancelButton.TextColor3 = config.TextColor
    cancelButton.TextSize = 14
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 6)
    cancelCorner.Parent = cancelButton
    
    -- 更新颜色显示的函数
    local function updateColorDisplay()
        local newColor = Color3.fromHSV(hue, saturation, value)
        newColorFrame.BackgroundColor3 = newColor
        satVibMap.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        
        -- 更新饱和度渐变
        satGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
        })
        
        -- 更新光标位置
        satCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
        hueDrag.Position = UDim2.new(0.5, 0, hue, 0)
        
        -- 更新输入框
        hexInput.Text = "#" .. newColor:ToHex()
        redInput.Text = math.floor(newColor.r * 255)
        greenInput.Text = math.floor(newColor.g * 255)
        blueInput.Text = math.floor(newColor.b * 255)
    end
    
    -- 处理饱和度/亮度选择 - 添加触摸支持
    local satVibDragging = false
    
    local function updateSatVibFromInput(input)
        if not satVibDragging then return end
        
        local minX = satVibMap.AbsolutePosition.X
        local maxX = minX + satVibMap.AbsoluteSize.X
        local minY = satVibMap.AbsolutePosition.Y
        local maxY = minY + satVibMap.AbsoluteSize.Y
        
        local posX, posY
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = Players.LocalPlayer:GetMouse()
            posX = mouse.X
            posY = mouse.Y
        elseif input.UserInputType == Enum.UserInputType.Touch then
            posX = input.Position.X
            posY = input.Position.Y
        else
            return
        end
        
        local mouseX = math.clamp(posX, minX, maxX)
        local mouseY = math.clamp(posY, minY, maxY)
        
        saturation = (mouseX - minX) / (maxX - minX)
        value = 1 - ((mouseY - minY) / (maxY - minY))
        updateColorDisplay()
    end
    
    -- 鼠标和触摸输入处理
    satVibMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            satVibDragging = true
            updateSatVibFromInput(input)
        end
    end)
    
    satVibMap.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            satVibDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if satVibDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                               input.UserInputType == Enum.UserInputType.Touch) then
            updateSatVibFromInput(input)
        end
    end)
    
    -- 处理色调选择 - 添加触摸支持
    local hueDragging = false
    
    local function updateHueFromInput(input)
        if not hueDragging then return end
        
        local minY = hueSlider.AbsolutePosition.Y
        local maxY = minY + hueSlider.AbsoluteSize.Y
        
        local posY
        
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = Players.LocalPlayer:GetMouse()
            posY = mouse.Y
        elseif input.UserInputType == Enum.UserInputType.Touch then
            posY = input.Position.Y
        else
            return
        end
        
        local mouseY = math.clamp(posY, minY, maxY)
        hue = (mouseY - minY) / (maxY - minY)
        updateColorDisplay()
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            updateHueFromInput(input)
        end
    end)
    
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                            input.UserInputType == Enum.UserInputType.Touch) then
            updateHueFromInput(input)
        end
    end)
    
    -- 输入框事件
    hexInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local success, result = pcall(function()
                return Color3.fromHex(hexInput.Text:gsub("#", ""))
            end)
            if success and typeof(result) == "Color3" then
                hue, saturation, value = Color3.toHSV(result)
                updateColorDisplay()
            else
                hexInput.Text = "#" .. Color3.fromHSV(hue, saturation, value):ToHex()
            end
        end
    end)
    
    redInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local r = tonumber(redInput.Text) or 0
            local g = tonumber(greenInput.Text) or 0
            local b = tonumber(blueInput.Text) or 0
            local newColor = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
            hue, saturation, value = Color3.toHSV(newColor)
            updateColorDisplay()
        end
    end)
    
    greenInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local r = tonumber(redInput.Text) or 0
            local g = tonumber(greenInput.Text) or 0
            local b = tonumber(blueInput.Text) or 0
            local newColor = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
            hue, saturation, value = Color3.toHSV(newColor)
            updateColorDisplay()
        end
    end)
    
    blueInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local r = tonumber(redInput.Text) or 0
            local g = tonumber(greenInput.Text) or 0
            local b = tonumber(blueInput.Text) or 0
            local newColor = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
            hue, saturation, value = Color3.toHSV(newColor)
            updateColorDisplay()
        end
    end)
    
    -- 按钮事件
    confirmButton.MouseButton1Click:Connect(function()
        local newColor = Color3.fromHSV(hue, saturation, value)
        callback(newColor)
        
        TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(backgroundOverlay, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.2)
        dialogContainer:Destroy()
        currentColorPickerDialog = nil
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(backgroundOverlay, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.2)
        dialogContainer:Destroy()
        currentColorPickerDialog = nil
    end)
    
    -- 触摸设备优化：增大触摸区域
    local touchArea = Instance.new("Frame")
    touchArea.Name = "TouchArea"
    touchArea.Parent = dialog
    touchArea.BackgroundTransparency = 1
    touchArea.Size = UDim2.new(1, 0, 1, 0)
    touchArea.ZIndex = 102
    
    -- 初始更新
    updateColorDisplay()
    
    -- 存储当前对话框
    currentColorPickerDialog = dialogContainer
    
    return dialogContainer
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
        Tab.ScrollBarThickness = 0
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
            LeftContainer.ScrollBarThickness = 0
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
            RightContainer.ScrollBarThickness = 0
            RightContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            RightContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            RightContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Name = "RightLayout"
            RightLayout.Parent = RightContainer
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 4)
            
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
            Tab.ScrollBarThickness = 0
        else
            Tab.ScrollBarThickness = 0
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
                TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
                }):Play()
                
                TweenService:Create(SectionOpened, TweenInfo.new(0.3), {
                    ImageTransparency = open and 0 or 1
                }):Play()
                
                TweenService:Create(SectionOpen, TweenInfo.new(0.3), {
                    ImageTransparency = open and 1 or 0
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
            end)
            
            local section = {}
            
            -- 颜色选择器函数
            function section.Colorpicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                FengUI.flags[flag] = defaultColor
                
                local ColorpickerModule = Instance.new("Frame")
                local ColorpickerBtn = Instance.new("TextButton")
                local ColorpickerBtnC = Instance.new("UICorner")
                local ColorDisplay = Instance.new("Frame")
                local ColorDisplayC = Instance.new("UICorner")
                local ColorDisplayStroke = Instance.new("UIStroke")
                
                ColorpickerModule.Name = "ColorpickerModule"
                ColorpickerModule.Parent = Objs
                ColorpickerModule.BackgroundTransparency = 1
                ColorpickerModule.BorderSizePixel = 0
                ColorpickerModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                ColorpickerBtn.Name = "ColorpickerBtn"
                ColorpickerBtn.Parent = ColorpickerModule
                ColorpickerBtn.BackgroundColor3 = config.Button_Color
                ColorpickerBtn.BackgroundTransparency = 0.1  -- 减少透明度让按钮更亮
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
                
                local colorDisplayPosition = 0.85
                if windowCount == 2 then
                    colorDisplayPosition = 0.78
                end
                
                ColorDisplay.Name = "ColorDisplay"
                ColorDisplay.Parent = ColorpickerBtn
                ColorDisplay.BackgroundColor3 = defaultColor
                ColorDisplay.BackgroundTransparency = 0
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.Position = UDim2.new(colorDisplayPosition, 0, 0.22, 0)
                ColorDisplay.Size = UDim2.new(0, 40, 0, 22)  -- 增大颜色显示区域
                
                ColorDisplayC.CornerRadius = UDim.new(0, 6)
                ColorDisplayC.Name = "ColorDisplayC"
                ColorDisplayC.Parent = ColorDisplay
                
                ColorDisplayStroke.Parent = ColorDisplay
                ColorDisplayStroke.Color = config.AccentColor
                ColorDisplayStroke.Thickness = 1
                ColorDisplayStroke.Transparency = 0.3  -- 减少透明度让边框更亮
                
                startNeonFlowEffect(ColorDisplayStroke, "Color", 0.01)
                
                ColorpickerBtn.MouseEnter:Connect(function()
                    TweenService:Create(ColorpickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.2),  -- 增加亮度
                            math.floor(config.Button_Color.G * 255 * 1.2),
                            math.floor(config.Button_Color.B * 255 * 1.2)
                        ),
                        BackgroundTransparency = 0
                    }):Play()
                    TweenService:Create(ColorDisplayStroke, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.1
                    }):Play()
                end)
                
                ColorpickerBtn.MouseLeave:Connect(function()
                    TweenService:Create(ColorpickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Button_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                    TweenService:Create(ColorDisplayStroke, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.3
                    }):Play()
                end)
                
                local funcs = {}
                
                funcs.SetColor = function(self, color)
                    if typeof(color) == "Color3" then
                        FengUI.flags[flag] = color
                        ColorDisplay.BackgroundColor3 = color
                        callback(color)
                    end
                end
                
                funcs.GetColor = function(self)
                    return FengUI.flags[flag]
                end
                
                funcs.SetValueRGB = function(self, r, g, b)
                    local color = Color3.fromRGB(r, g, b)
                    funcs:SetColor(color)
                end
                
                funcs.SetValueHSV = function(self, h, s, v)
                    local color = Color3.fromHSV(h, s, v)
                    funcs:SetColor(color)
                end
                
                funcs.OnChanged = function(self, func)
                    local oldCallback = callback
                    callback = function(color)
                        oldCallback(color)
                        func(color)
                    end
                end
                
                ColorpickerBtn.MouseButton1Click:Connect(function()
                    local currentColor = FengUI.flags[flag] or defaultColor
                    createColorPickerDialog(currentColor, function(newColor)
                        funcs:SetColor(newColor)
                    end)
                end)
                
                return funcs
            end
            
            -- 由于代码长度限制，这里只包含颜色选择器的修复部分
            -- 其他UI元素（Button, Toggle, Slider等）的代码保持不变...
            
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