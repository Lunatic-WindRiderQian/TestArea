repeat task.wait() until game:IsLoaded()
local library = {}
local ToggleUI = false
library.currentTab = nil
library.flags = {}

local services = setmetatable({}, {
  __index = function(t, k)
    return game.GetService(game, k)
  end
})

local mouse = services.Players.LocalPlayer:GetMouse()

-- 新增：配置系统
local config = {
    MainColor = Color3.fromRGB(16, 16, 16),
    TabColor = Color3.fromRGB(22, 22, 22),
    Bg_Color = Color3.fromRGB(17, 17, 17),
    Zy_Color = Color3.fromRGB(17, 17, 17), 
    Button_Color = Color3.fromRGB(22, 22, 22),
    Textbox_Color = Color3.fromRGB(22, 22, 22),
    Dropdown_Color = Color3.fromRGB(22, 22, 22),
    Keybind_Color = Color3.fromRGB(22, 22, 22),
    Label_Color = Color3.fromRGB(22, 22, 22),
    Slider_Color = Color3.fromRGB(22, 22, 22),
    SliderBar_Color = Color3.fromRGB(37, 254, 152),
    Toggle_Color = Color3.fromRGB(22, 22, 22),
    Toggle_Off = Color3.fromRGB(34, 34, 34),
    Toggle_On = Color3.fromRGB(37, 254, 152),
    AccentColor = Color3.fromRGB(37, 254, 152),
    TextColor = Color3.fromRGB(240, 240, 240),
    SecondaryTextColor = Color3.fromRGB(180, 180, 180),
    GlowColor = Color3.fromRGB(0, 200, 255),
}

-- 新增：彩虹效果
local function startRainbowEffect(object, property, speed)
    speed = speed or 0.005
    local hue = 0
    local connection
    connection = services.RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + speed) % 1
        object[property] = Color3.fromHSV(hue, 0.8, 1)
    end)
    return connection
end

-- 新增：极光效果
local function createAuroraEffect(frame, intensity)
    intensity = intensity or 1
    
    local aurora = Instance.new("Frame")
    aurora.Name = "AuroraEffect"
    aurora.BackgroundTransparency = 1
    aurora.Size = UDim2.new(1, 0, 1, 0)
    aurora.ZIndex = frame.ZIndex - 1
    aurora.Parent = frame
    aurora.ClipsDescendants = true
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.2 * intensity),
        NumberSequenceKeypoint.new(1, 0)
    })
    gradient.Parent = aurora
    
    local colors = {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(100, 50, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 0, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
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
    local xSpeed = 0.5
    local ySpeed = 0.3
    
    local heartbeatConnection
    heartbeatConnection = services.RunService.Heartbeat:Connect(function(delta)
        if not aurora or not aurora.Parent then
            heartbeatConnection:Disconnect()
            sizeConnection:Disconnect()
            return
        end
        
        xOffset = (xOffset + xSpeed * delta * xDir) % 1
        yOffset = (yOffset + ySpeed * delta * yDir) % 1
        
        if xOffset >= 0.9 or xOffset <= 0.1 then xDir = xDir * -1 end
        if yOffset >= 0.9 or yOffset <= 0.1 then yDir = yDir * -1 end
        
        aurora.Position = UDim2.new(-0.5 + xOffset, 0, -0.5 + yOffset, 0)
        
        for i, keypoint in ipairs(colors) do
            local time = tick() * 0.1 + i * 0.2
            local h = (time % 1) * 360
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV((h/360) % 1, 0.8, 1)
            )
        end
        gradient.Color = ColorSequence.new(colors)
    end)
    
    return aurora
end

-- 改进的Ripple函数
function Ripple(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://135338220004437"
        Ripple.ImageTransparency = 0.6
        Ripple.ScaleType = Enum.ScaleType.Fit
        
        local hue = tick() % 5 / 5
        Ripple.ImageColor3 = Color3.fromHSV(hue, 0.8, 1)
        
        local x = (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        Ripple.Position = UDim2.new(x, 0, y, 0)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.8, 0, -0.8, 0),
            Size = UDim2.new(2.6, 0, 2.6, 0)
        }):Play()
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 1
        }):Play()
        
        task.wait(0.8)
        Ripple:Destroy()
    end)
end

-- 改进的Tween函数
function Tween(obj, t, data)
    services.TweenService:Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data):Play()
    return true
end

-- 改进的switchTab函数
local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = library.currentTab
    if old == nil then
        new[2].Visible = true
        library.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { ImageTransparency = 0 }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    library.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { ImageTransparency = 0.5 }):Play()
    services.TweenService:Create(new[1], tweenInfo, { ImageTransparency = 0 }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { TextTransparency = 0.5 }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { TextTransparency = 0 }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.2)
    switchingTabs = false
end

-- 改进的drag函数
function drag(frame, hold)
    if not hold then
        hold = frame
    end
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function library.new(library, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "frosty" then
          v:Destroy()
        end
    end

    -- 应用主题配置
    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end

-------------------------AL------------------------------
ALTransparency = 0.6
ALcolor = Color3.fromRGB(0,255,127)
-------------------------AL------------------------------
if theme == 'dark' then
    MainColor = Color3.fromRGB(25, 25, 25)
    Background = Color3.fromRGB(25, 25, 25)
    zyColor= Color3.fromRGB(25, 25, 25)
    beijingColor = Color3.fromRGB(25, 25, 25)
else
    MainColor = config.MainColor
    Background = config.Bg_Color
    zyColor = config.Zy_Color
    beijingColor = config.Bg_Color
end

local dogent = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local TabMain = Instance.new("Frame")
local MainC = Instance.new("UICorner")
local SB = Instance.new("Frame")
local SBC = Instance.new("UICorner")
local Side = Instance.new("Frame")
local SideG = Instance.new("UIGradient")
local TabBtns = Instance.new("ScrollingFrame")
local TabBtnsL = Instance.new("UIListLayout")
local ScriptTitle = Instance.new("TextLabel")
local SBG = Instance.new("UIGradient") 
local Open = Instance.new("ImageButton")
local UIG=Instance.new("UIGradient")
local DropShadowHolder = Instance.new("Frame")
local DropShadow = Instance.new("ImageLabel")
local UICornerMain = Instance.new("UICorner")
local UIGradient=Instance.new("UIGradient")
local UIGradientTitle=Instance.new("UIGradient")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UICorner_2 = Instance.new("UICorner")
local CloseButton = Instance.new("TextButton")
local CloseCorner = Instance.new("UICorner")

if syn and syn.protect_gui then syn.protect_gui(dogent) end

dogent.Name = "frosty"
dogent.Parent = services.CoreGui

function UiDestroy()
    dogent:Destroy()
end

function ToggleUILib()
    if not ToggleUI then
        dogent.Enabled = false
        ToggleUI = true
    else
        ToggleUI = false
        dogent.Enabled = true
    end
end

Main.Name = "Main"
Main.Parent = dogent
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Background
Main.BorderColor3 = MainColor
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 572, 0, 353)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true
Main.Transparency = 0.2

-- 添加彩虹边框效果
local rainbowStroke = Instance.new("UIStroke")
rainbowStroke.Parent = Main
rainbowStroke.Thickness = 2
rainbowStroke.Transparency = 0.7
rainbowStroke.LineJoinMode = Enum.LineJoinMode.Round
startRainbowEffect(rainbowStroke, "Color", 0.01)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if Main.Visible == true then
            Main.Visible = false 
        else
            Main.Visible = true
        end
    end
end)
drag(Main)

UICornerMain.Parent = Main
UICornerMain.CornerRadius = UDim.new(0,3)

-- 添加关闭按钮
CloseButton.Name = "CloseButton"
CloseButton.Parent = Main
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.TextSize = 16
CloseButton.ZIndex = 10

CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 18,
        Position = UDim2.new(1, -26, 0, 4)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 16,
        Position = UDim2.new(1, -25, 0, 5)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    Ripple(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 14,
        Position = UDim2.new(1, -24, 0, 6)
    }):Play()
    task.wait(0.1)
    dogent:Destroy()
end)

DropShadowHolder.Name = "DropShadowHolder"
DropShadowHolder.Parent = Main
DropShadowHolder.BackgroundTransparency = 1.000
DropShadowHolder.BorderSizePixel = 0
DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
DropShadowHolder.BorderColor3 = Color3.fromRGB(255,255,255)
DropShadowHolder.ZIndex = 0

DropShadow.Name = "DropShadow"
DropShadow.Parent = DropShadowHolder
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1.000
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
DropShadow.Size = UDim2.new(1, 10, 1, 10)
DropShadow.Image = "rbxassetid://135338220004437"
DropShadow.ImageColor3 = Color3.fromRGB(255,255,255)
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 127, 0)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(139, 0, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 127, 0)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 0))}

local TweenService = game:GetService("TweenService")
local tweeninfo = TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
local tween = TweenService:Create(UIGradient, tweeninfo, {Rotation = 360})
tween:Play()

local toggled = false
function toggleui()
    toggled = not toggled
    spawn(function()
        if toggled then wait(0.3) end
    end)
    Tween(Main, {0.3, 'Sine', 'InOut'}, {
        Size = UDim2.new(0, 609, 0, (toggled and 505 or 0))
    })
end

TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
TabMain.BackgroundTransparency = 1.000
TabMain.Position = UDim2.new(0.217000037, 0, 0, 3)
TabMain.Size = UDim2.new(0, 448, 0, 353)
TabMain.Transparency = 1.0

MainC.CornerRadius = UDim.new(0, 5.5)
MainC.Name = "MainC"
MainC.Parent = Frame

SB.Name = "SB"
SB.Parent = Main
SB.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
SB.BorderColor3 = MainColor
SB.Size = UDim2.new(0, 8, 0, 353)
SB.Transparency = 1.0

SBC.CornerRadius = UDim.new(0, 6)
SBC.Name = "SBC"
SBC.Parent = SB

Side.Name = "Side"
Side.Parent = SB
Side.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
Side.BorderColor3 = Color3.fromRGB(139, 0, 255)
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(1, 0, 0, 0)
Side.Size = UDim2.new(0, 110, 0, 353)
Side.Transparency = 1.0

SideG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor)}
SideG.Rotation = 90
SideG.Name = "SideG"
SideG.Parent = Side

TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
TabBtns.BackgroundTransparency = 1.000
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0.0973535776, 0)
TabBtns.Size = UDim2.new(0, 110, 0, 318)
TabBtns.CanvasSize = UDim2.new(0, 0, 1, 0)
TabBtns.ScrollBarThickness = 0

TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 12)

ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
ScriptTitle.BackgroundTransparency = 1.000
ScriptTitle.Position = UDim2.new(0, 0, 0.00953488424, 0)
ScriptTitle.Size = UDim2.new(0, 102, 0, 20)
ScriptTitle.Font = Enum.Font.GothamSemibold
ScriptTitle.Text = name
ScriptTitle.TextColor3 = config.AccentColor
ScriptTitle.TextSize = 14.000
ScriptTitle.TextScaled = true
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

UIGradientTitle.Parent = ScriptTitle

-- 改进的标题动画效果
task.spawn(function()
    local hue = 0
    local glowEffect = Instance.new("UIGradient")
    glowEffect.Rotation = 90
    glowEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    glowEffect.Parent = ScriptTitle
    
    while ScriptTitle and ScriptTitle.Parent do
        hue = (hue + 0.02) % 1
        
        ScriptTitle.TextColor3 = Color3.fromHSV(hue, 1, 1)
        
        glowEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV((hue + 0.1) % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.1) % 1, 1, 1))
        })
        
        services.TweenService:Create(ScriptTitle, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextSize = 15 + math.sin(tick() * 2) * 1
        }):Play()
        
        task.wait(0.05)
    end
end)

SBG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor)}
SBG.Rotation = 90
SBG.Name = "SBG"
SBG.Parent = SB

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 18)
end)

-- Properties:
Frame.Parent = dogent
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.00829315186, 0, 0.31107837, 0)
Frame.Size = UDim2.new(0, 50, 0, 50)
Frame.BackgroundTransparency = 1.000

UICorner.CornerRadius = UDim.new(0, 90)
UICorner.Parent = Frame

Open.Parent = Frame
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.BorderColor3 = Color3.fromRGB(0, 0, 0)
Open.BorderSizePixel = 0
Open.Size = UDim2.new(0, 50, 0, 50)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://135338220004437"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15

-- 添加边框效果
local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(180, 180, 180)
OpenStroke.Thickness = 1.2
OpenStroke.Transparency = 0.4

startRainbowEffect(Open, "BackgroundColor3", 0.012)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
end)

UICorner_2.CornerRadius = UDim.new(0, 90)
UICorner_2.Parent = Open
UIG.Parent = Open

local window = {}
function window.Tab(window, name, icon)
    local Tab = Instance.new("ScrollingFrame")
    local TabIco = Instance.new("ImageLabel")
    local TabText = Instance.new("TextLabel")
    local TabBtn = Instance.new("TextButton")
    local TabL = Instance.new("UIListLayout")

    Tab.Name = "Tab"
    Tab.Parent = TabMain
    Tab.Active = true
    Tab.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
    Tab.BackgroundTransparency = 1.000
    Tab.Size = UDim2.new(1, 0, 1, 0)
    Tab.ScrollBarThickness = 2
    Tab.Visible = false
    
    TabIco.Name = "TabIco"
    TabIco.Parent = TabBtns
    TabIco.BackgroundTransparency = 1.000
    TabIco.BorderSizePixel = 0
    TabIco.Size = UDim2.new(0, 24, 0, 24)
    TabIco.Image = "rbxassetid://135338220004437" or icon and "rbxassetid://"..icon
    TabIco.ImageTransparency = 0.2
    
    -- 添加彩虹效果到标签图标
    startRainbowEffect(TabIco, "ImageColor3", 0.005)
    
    TabText.Name = "TabText"
    TabText.Parent = TabIco
    TabText.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
    TabText.BackgroundTransparency = 1.000
    TabText.Position = UDim2.new(1.41666663, 0, 0, 0)
    TabText.Size = UDim2.new(0, 76, 0, 24)
    TabText.Font = Enum.Font.GothamSemibold
    TabText.Text = name
    TabText.TextColor3 = config.TextColor
    TabText.TextSize = 14.000
    TabText.TextXAlignment = Enum.TextXAlignment.Left
    TabText.TextTransparency = 0.2
    
    TabBtn.Name = "TabBtn"
    TabBtn.Parent = TabIco
    TabBtn.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
    TabBtn.BackgroundTransparency = 1.000
    TabBtn.BorderSizePixel = 0
    TabBtn.Size = UDim2.new(0, 110, 0, 24)
    TabBtn.AutoButtonColor = false
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.Text = ""
    TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    TabBtn.TextSize = 14.000
    
    TabL.Name = "TabL"
    TabL.Parent = Tab
    TabL.SortOrder = Enum.SortOrder.LayoutOrder
    TabL.Padding = UDim.new(0, 4)  

    TabBtn.MouseButton1Click:Connect(function()
        spawn(function()
            Ripple(TabBtn)
        end)
        switchTab({TabIco, Tab})
    end)

    if library.currentTab == nil then switchTab({TabIco, Tab}) end

    TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
    end)

------------------------------------------------------AL.King音乐-------------------------------------------------------
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://6797864253" --音乐id
sound.Parent = game.Workspace
sound:Play()
---------------分割线-------------------------------分割线-------------------------------分割线----------------
    local tab = {}
    function tab.section(tab, name, TabVal)
        local Section = Instance.new("Frame")
        local SectionC = Instance.new("UICorner")
        local SectionText = Instance.new("TextLabel")
        local SectionOpen = Instance.new("ImageLabel")
        local SectionOpened = Instance.new("ImageLabel")
        local SectionToggle = Instance.new("ImageButton")
        local Objs = Instance.new("Frame")
        local ObjsL = Instance.new("UIListLayout")

        Section.Name = "Section"
        Section.Parent = Tab
        Section.BackgroundColor3 = config.TabColor
        Section.BackgroundTransparency = 0.2
        Section.BorderSizePixel = 0
        Section.ClipsDescendants = true
        Section.Size = UDim2.new(0.981000006, 0, 0, 36)
        
        SectionC.CornerRadius = UDim.new(0, 6)
        SectionC.Name = "SectionC"
        SectionC.Parent = Section
        
        SectionText.Name = "SectionText"
        SectionText.Parent = Section
        SectionText.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
        SectionText.BackgroundTransparency = 1.000
        SectionText.Position = UDim2.new(0.0887396261, 0, 0, 0)
        SectionText.Size = UDim2.new(0, 401, 0, 36)
        SectionText.Font = Enum.Font.GothamSemibold
        SectionText.Text = name
        SectionText.TextColor3 = config.TextColor
        SectionText.TextSize = 16.000
        SectionText.TextXAlignment = Enum.TextXAlignment.Left
        
        SectionOpen.Name = "SectionOpen"
        SectionOpen.Parent = SectionText
        SectionOpen.BackgroundTransparency = 1
        SectionOpen.BorderSizePixel = 0
        SectionOpen.Position = UDim2.new(0, -33, 0, 5)
        SectionOpen.Size = UDim2.new(0, 26, 0, 26)
        SectionOpen.Image = "rbxassetid://135338220004437"
        SectionOpen.ImageColor3 = config.SecondaryTextColor
        
        SectionOpened.Name = "SectionOpened"
        SectionOpened.Parent = SectionOpen
        SectionOpened.BackgroundTransparency = 1.000
        SectionOpened.BorderSizePixel = 0
        SectionOpened.Size = UDim2.new(0, 26, 0, 26)
        SectionOpened.Image = "rbxassetid://135338220004437"
        SectionOpened.ImageColor3 = config.AccentColor
        SectionOpened.ImageTransparency = 1.000

        SectionToggle.Name = "SectionToggle"
        SectionToggle.Parent = SectionOpen
        SectionToggle.BackgroundTransparency = 1
        SectionToggle.BorderSizePixel = 0
        SectionToggle.Size = UDim2.new(0, 26, 0, 26)
        
        Objs.Name = "Objs"
        Objs.Parent = Section
        Objs.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
        Objs.BackgroundTransparency = 1
        Objs.BorderSizePixel = 0
        Objs.Position = UDim2.new(0, 6, 0, 36)
        Objs.Size = UDim2.new(0.986347735, 0, 0, 0)

        ObjsL.Name = "ObjsL"
        ObjsL.Parent = Objs
        ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
        ObjsL.Padding = UDim.new(0, 8) 
        
        local open = TabVal
        if TabVal ~= false then
            Section.Size = UDim2.new(0.981000006, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
            SectionOpened.ImageTransparency = (open and 0 or 1)
            SectionOpen.ImageTransparency = (open and 1 or 0)
        end
        
        SectionToggle.MouseButton1Click:Connect(function()
            open = not open
            services.TweenService:Create(Section, TweenInfo.new(0.2), {
                Size = UDim2.new(0.981000006, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
            }):Play()
            
            services.TweenService:Create(SectionOpened, TweenInfo.new(0.2), {
                ImageTransparency = open and 0 or 1
            }):Play()
            
            services.TweenService:Create(SectionOpen, TweenInfo.new(0.2), {
                ImageTransparency = open and 1 or 0
            }):Play()
        end)

        ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not open then return end
            Section.Size = UDim2.new(0.981000006, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
        end)

        local section = {}
        
        -- 新增：Image功能
        function section.Image(section, imageId, sizeX, sizeY)
            local ImageModule = Instance.new("Frame")
            local ImageLabel = Instance.new("ImageLabel")
            local ImageCorner = Instance.new("UICorner")
            
            ImageModule.Name = "ImageModule"
            ImageModule.Parent = Objs
            ImageModule.BackgroundTransparency = 1
            ImageModule.BorderSizePixel = 0
            ImageModule.Size = UDim2.new(0, 428, 0, sizeY or 120)
            
            ImageLabel.Parent = ImageModule
            ImageLabel.BackgroundColor3 = config.Bg_Color
            ImageLabel.BackgroundTransparency = 0.2
            ImageLabel.BorderSizePixel = 0
            ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
            ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
            ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, 428), 0, sizeY or 120)
            ImageLabel.Image = "rbxassetid://" .. tostring(imageId)
            ImageLabel.ScaleType = Enum.ScaleType.Crop
            
            ImageCorner.CornerRadius = UDim.new(0, 6)
            ImageCorner.Parent = ImageLabel
            
            local imageGlow = Instance.new("UIStroke")
            imageGlow.Parent = ImageLabel
            imageGlow.Color = config.AccentColor
            imageGlow.Thickness = 1
            imageGlow.Transparency = 1
            
            return ImageLabel
        end
        
        function section.Button(section, text, callback)
            local callback = callback or function() end

            local BtnModule = Instance.new("Frame")
            local Btn = Instance.new("TextButton")
            local BtnC = Instance.new("UICorner")    
            
            BtnModule.Name = "BtnModule"
            BtnModule.Parent = Objs
            BtnModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            BtnModule.BackgroundTransparency = 1.000
            BtnModule.BorderSizePixel = 0
            BtnModule.Position = UDim2.new(0, 0, 0, 0)
            BtnModule.Size = UDim2.new(0, 428, 0, 38)
            BtnModule.Transparency = 0.75
            
            Btn.Name = "Btn"
            Btn.Parent = BtnModule
            Btn.BackgroundColor3 = config.Button_Color
            Btn.BackgroundTransparency = ALTransparency
            Btn.BorderSizePixel = 0
            Btn.Size = UDim2.new(0, 428, 0, 38)
            Btn.AutoButtonColor = false
            Btn.Font = Enum.Font.GothamSemibold
            Btn.Text = "   " .. text
            Btn.TextColor3 = config.TextColor
            Btn.TextSize = 16.000
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            
            BtnC.CornerRadius = UDim.new(0, 6)
            BtnC.Name = "BtnC"
            BtnC.Parent = Btn

            -- 添加发光边框效果
            local btnGlow = Instance.new("UIStroke")
            btnGlow.Parent = Btn
            btnGlow.Color = config.AccentColor
            btnGlow.Thickness = 1
            btnGlow.Transparency = 0.8
            
            startRainbowEffect(btnGlow, "Color", 0.01)
            
            Btn.MouseEnter:Connect(function()
                services.TweenService:Create(Btn, TweenInfo.new(0.2), {
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
                services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = config.Button_Color
                }):Play()
                services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                    Thickness = 1,
                    Transparency = 0.8
                }):Play()
            end)

            Btn.MouseButton1Click:Connect(function()
                spawn(function()
                    Ripple(Btn)
                end)
                
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
                
                spawn(callback)
                
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

    function section:Label(text)
        local LabelModule = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local LabelC = Instance.new("UICorner")
        
        LabelModule.Name = "LabelModule"
        LabelModule.Parent = Objs
        LabelModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
        LabelModule.BackgroundTransparency = 1.000
        LabelModule.BorderSizePixel = 0
        LabelModule.Position = UDim2.new(0, 0, NAN, 0)
        LabelModule.Size = UDim2.new(0, 428, 0, 19)
        TextLabel.Parent = LabelModule
        TextLabel.BackgroundColor3 = config.Label_Color
        TextLabel.BackgroundTransparency = ALTransparency
        TextLabel.Size = UDim2.new(0, 428, 0, 22)
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.Text = text
        TextLabel.TextColor3 = config.SecondaryTextColor
        TextLabel.TextSize = 14.000

        LabelC.CornerRadius = UDim.new(0, 6)
        LabelC.Name = "LabelC"
        LabelC.Parent = TextLabel
        return TextLabel
    end

        function section.Toggle(section, text, flag, enabled, callback)
            local callback = callback or function() end
            local enabled = enabled or false
            assert(text, "No text provided")
            assert(flag, "No flag provided")

            library.flags[flag] = enabled

            local ToggleModule = Instance.new("Frame")
            local ToggleBtn = Instance.new("TextButton")
            local ToggleBtnC = Instance.new("UICorner")
            local ToggleDisable = Instance.new("Frame")
            local ToggleSwitch = Instance.new("Frame")
            local ToggleSwitchC = Instance.new("UICorner")
            local ToggleDisableC = Instance.new("UICorner")
            
            ToggleModule.Name = "ToggleModule"
            ToggleModule.Parent = Objs
            ToggleModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            ToggleModule.BackgroundTransparency = 1.000
            ToggleModule.BorderSizePixel = 0
            ToggleModule.Position = UDim2.new(0, 0, 0, 0)
            ToggleModule.Size = UDim2.new(0, 428, 0, 38)
            
            ToggleBtn.Name = "ToggleBtn"
            ToggleBtn.Parent = ToggleModule
            ToggleBtn.BackgroundColor3 = config.Toggle_Color
            ToggleBtn.BackgroundTransparency = ALTransparency
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.Size = UDim2.new(0, 428, 0, 38)
            ToggleBtn.AutoButtonColor = false
            ToggleBtn.Font = Enum.Font.GothamSemibold
            ToggleBtn.Text = "   " .. text
            ToggleBtn.TextColor3 = config.TextColor
            ToggleBtn.TextSize = 16.000
            ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            ToggleBtnC.CornerRadius = UDim.new(0, 6)
            ToggleBtnC.Name = "ToggleBtnC"
            ToggleBtnC.Parent = ToggleBtn
            
            ToggleDisable.Name = "ToggleDisable"
            ToggleDisable.Parent = ToggleBtn
            ToggleDisable.BackgroundColor3 = config.Bg_Color
            ToggleDisable.BackgroundTransparency = 0.5
            ToggleDisable.BorderSizePixel = 0
            ToggleDisable.Position = UDim2.new(0.901869178, 0, 0.208881587, 0)
            ToggleDisable.Size = UDim2.new(0, 36, 0, 22)
            
            ToggleSwitch.Name = "ToggleSwitch"
            ToggleSwitch.Parent = ToggleDisable
            ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
            ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)
            ToggleSwitch.Position = UDim2.new(0, enabled and 14 or 0, 0, 0)
            
            ToggleSwitchC.CornerRadius = UDim.new(0, 6)
            ToggleSwitchC.Name = "ToggleSwitchC"
            ToggleSwitchC.Parent = ToggleSwitch
            
            ToggleDisableC.CornerRadius = UDim.new(0, 6)
            ToggleDisableC.Name = "ToggleDisableC"
            ToggleDisableC.Parent = ToggleDisable        

            -- 添加极光效果
            if enabled then
                createAuroraEffect(ToggleSwitch, 0.8)
            end
            
            ToggleBtn.MouseEnter:Connect(function()
                services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        math.floor(config.Toggle_Color.R * 255 * 1.1),
                        math.floor(config.Toggle_Color.G * 255 * 1.1),
                        math.floor(config.Toggle_Color.B * 255 * 1.1)
                    )
                }):Play()
            end)
            
            ToggleBtn.MouseLeave:Connect(function()
                services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = config.Toggle_Color
                }):Play()
            end)
            
            local funcs = {
                SetState = function(self, state)
                    if state == nil then state = not library.flags[flag] end
                    if library.flags[flag] == state then return end
                    
                    services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, (state and ToggleSwitch.Size.X.Offset / 2 or 0), 0, 0), 
                        BackgroundColor3 = (state and config.Toggle_On or config.Toggle_Off)
                    }):Play()
                    
                    if state then
                        createAuroraEffect(ToggleSwitch, 0.8)
                    else
                        local aurora = ToggleSwitch:FindFirstChild("AuroraEffect")
                        if aurora then
                            aurora:Destroy()
                        end
                    end
                    
                    library.flags[flag] = state
                    callback(state)
                end,
                Module = ToggleModule
            }
            
            if enabled ~= false then
                funcs:SetState(flag,true)
            end

            ToggleBtn.MouseButton1Click:Connect(function()
                Ripple(ToggleBtn)
                funcs:SetState()
            end)
            return funcs
        end

        function section.Keybind(section, text, default, callback)
            local callback = callback or function() end
            assert(text, "No text provided")
            assert(default, "No default key provided")

            local default = (typeof(default) == "string" and Enum.KeyCode[default] or default)
            local banned = {
                Return = true;
                Space = true;
                Tab = true;
                Backquote = true;
                CapsLock = true;
                Escape = true;
                Unknown = true;
            }
            local shortNames = {
                RightControl = 'Right Ctrl',
                LeftControl = 'Left Ctrl',
                LeftShift = 'Left Shift',
                RightShift = 'Right Shift',
                Semicolon = ";",
                Quote = '"',
                LeftBracket = '[',
                RightBracket = ']',
                Equals = '=',
                Minus = '-',
                RightAlt = 'Right Alt',
                LeftAlt = 'Left Alt'
            }

            local bindKey = default
            local keyTxt = (default and (shortNames[default.Name] or default.Name) or "None")

            local KeybindModule = Instance.new("Frame")
            local KeybindBtn = Instance.new("TextButton")
            local KeybindBtnC = Instance.new("UICorner")
            local KeybindValue = Instance.new("TextButton")
            local KeybindValueC = Instance.new("UICorner")
            local KeybindL = Instance.new("UIListLayout")
            local UIPadding = Instance.new("UIPadding")

            KeybindModule.Name = "KeybindModule"
            KeybindModule.Parent = Objs
            KeybindModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            KeybindModule.BackgroundTransparency = 1.000
            KeybindModule.BorderSizePixel = 0
            KeybindModule.Position = UDim2.new(0, 0, 0, 0)
            KeybindModule.Size = UDim2.new(0, 428, 0, 38)
            
            KeybindBtn.Name = "KeybindBtn"
            KeybindBtn.Parent = KeybindModule
            KeybindBtn.BackgroundColor3 = config.Keybind_Color
            KeybindBtn.BackgroundTransparency = ALTransparency
            KeybindBtn.BorderSizePixel = 0
            KeybindBtn.Size = UDim2.new(0, 428, 0, 38)
            KeybindBtn.AutoButtonColor = false
            KeybindBtn.Font = Enum.Font.GothamSemibold
            KeybindBtn.Text = "   " .. text
            KeybindBtn.TextColor3 = config.TextColor
            KeybindBtn.TextSize = 16.000
            KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            KeybindBtnC.CornerRadius = UDim.new(0, 6)
            KeybindBtnC.Name = "KeybindBtnC"
            KeybindBtnC.Parent = KeybindBtn
            
            KeybindValue.Name = "KeybindValue"
            KeybindValue.Parent = KeybindBtn
            KeybindValue.BackgroundColor3 = config.Bg_Color
            KeybindValue.BorderSizePixel = 0
            KeybindValue.Position = UDim2.new(0.763033211, 0, 0.289473683, 0)
            KeybindValue.Size = UDim2.new(0, 100, 0, 28)
            KeybindValue.AutoButtonColor = false
            KeybindValue.Font = Enum.Font.Gotham
            KeybindValue.Text = keyTxt
            KeybindValue.TextColor3 = config.TextColor
            KeybindValue.TextSize = 14.000
            
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
                services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        math.floor(config.Keybind_Color.R * 255 * 1.1),
                        math.floor(config.Keybind_Color.G * 255 * 1.1),
                        math.floor(config.Keybind_Color.B * 255 * 1.1)
                    )
                }):Play()
            end)
            
            KeybindBtn.MouseLeave:Connect(function()
                services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = config.Keybind_Color
                }):Play()
            end)
            
            services.UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                if inp.KeyCode ~= bindKey then return end
                callback(bindKey.Name)
            end)
            
            KeybindValue.MouseButton1Click:Connect(function()
                Ripple(KeybindValue)
                KeybindValue.Text = "..."
                wait()
                local key, uwu = services.UserInputService.InputEnded:Wait()
                local keyName = tostring(key.KeyCode.Name)
                if key.UserInputType ~= Enum.UserInputType.Keyboard then
                    KeybindValue.Text = keyTxt
                    return
                end
                if banned[keyName] then
                    KeybindValue.Text = keyTxt
                    return
                end
                wait()
                bindKey = Enum.KeyCode[keyName]
                KeybindValue.Text = shortNames[keyName] or keyName
            end)

            KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end)
            KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
        end

        function section.Textbox(section, text, flag, default, callback)
            local callback = callback or function() end
            assert(text, "No text provided")
            assert(flag, "No flag provided")
            assert(default, "No default text provided")

            library.flags[flag] = default

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
            TextboxModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            TextboxModule.BackgroundTransparency = 1.000
            TextboxModule.BorderSizePixel = 0
            TextboxModule.Position = UDim2.new(0, 0, 0, 0)
            TextboxModule.Size = UDim2.new(0, 428, 0, 38)
            
            TextboxBack.Name = "TextboxBack"
            TextboxBack.Parent = TextboxModule
            TextboxBack.BackgroundColor3 = config.Textbox_Color
            TextboxBack.BackgroundTransparency = ALTransparency
            TextboxBack.BorderSizePixel = 0
            TextboxBack.Size = UDim2.new(0, 428, 0, 38)
            TextboxBack.AutoButtonColor = false
            TextboxBack.Font = Enum.Font.GothamSemibold
            TextboxBack.Text = "   " .. text
            TextboxBack.TextColor3 = config.TextColor
            TextboxBack.TextSize = 16.000
            TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
            
            TextboxBackC.CornerRadius = UDim.new(0, 6)
            TextboxBackC.Name = "TextboxBackC"
            TextboxBackC.Parent = TextboxBack
            
            BoxBG.Name = "BoxBG"
            BoxBG.Parent = TextboxBack
            BoxBG.BackgroundColor3 = config.Bg_Color
            BoxBG.BorderSizePixel = 0
            BoxBG.Position = UDim2.new(0.763033211, 0, 0.289473683, 0)
            BoxBG.Size = UDim2.new(0, 100, 0, 28)
            BoxBG.AutoButtonColor = false
            BoxBG.Font = Enum.Font.Gotham
            BoxBG.Text = ""
            BoxBG.TextColor3 = config.TextColor
            BoxBG.TextSize = 14.000
            
            BoxBGC.CornerRadius = UDim.new(0, 6)
            BoxBGC.Name = "BoxBGC"
            BoxBGC.Parent = BoxBG
            
            TextBox.Parent = BoxBG
            TextBox.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            TextBox.BackgroundTransparency = 1.000
            TextBox.BorderSizePixel = 0
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = default
            TextBox.TextColor3 = config.TextColor
            TextBox.TextSize = 14.000
            TextBox.PlaceholderColor3 = config.SecondaryTextColor
            
            TextboxBackL.Name = "TextboxBackL"
            TextboxBackL.Parent = TextboxBack
            TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
            TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
            TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center
            
            TextboxBackP.Name = "TextboxBackP"
            TextboxBackP.Parent = TextboxBack
            TextboxBackP.PaddingRight = UDim.new(0, 6)
            
            TextboxBack.MouseEnter:Connect(function()
                services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        math.floor(config.Textbox_Color.R * 255 * 1.1),
                        math.floor(config.Textbox_Color.G * 255 * 1.1),
                        math.floor(config.Textbox_Color.B * 255 * 1.1)
                    )
                }):Play()
            end)
            
            TextboxBack.MouseLeave:Connect(function()
                services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                    BackgroundColor3 = config.Textbox_Color
                }):Play()
            end)

            TextBox.FocusLost:Connect(function()
                if TextBox.Text == "" then
                    TextBox.Text = default
                end
                library.flags[flag] = TextBox.Text
                callback(TextBox.Text)
            end)

            TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
            end)
            BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
        end

        function section.Slider(section, text, flag, default, min, max, precise, callback)
            local callback = callback or function() end
            local min = min or 1
            local max = max or 10
            local default = default or min
            local precise = precise or false

            library.flags[flag] = default

            assert(text, "No text provided")
            assert(flag, "No flag provided")
            assert(default, "No default value provided")
            
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
            local MinSlider = Instance.new("TextButton")
            local AddSlider = Instance.new("TextButton")   
            
            SliderModule.Name = "SliderModule"
            SliderModule.Parent = Objs
            SliderModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            SliderModule.BackgroundTransparency = 1.000
            SliderModule.BorderSizePixel = 0
            SliderModule.Position = UDim2.new(0, 0, 0, 0)
            SliderModule.Size = UDim2.new(0, 428, 0, 38)
            
            SliderBack.Name = "SliderBack"
            SliderBack.Parent = SliderModule
            SliderBack.BackgroundColor3 = config.Slider_Color
            SliderBack.BackgroundTransparency = ALTransparency
            SliderBack.BorderSizePixel = 0
            SliderBack.Size = UDim2.new(0, 428, 0, 38)
            SliderBack.AutoButtonColor = false
            SliderBack.Font = Enum.Font.GothamSemibold
            SliderBack.Text = "   " .. text
            SliderBack.TextColor3 = config.TextColor
            SliderBack.TextSize = 16.000
            SliderBack.TextXAlignment = Enum.TextXAlignment.Left
            
            SliderBackC.CornerRadius = UDim.new(0, 6)
            SliderBackC.Name = "SliderBackC"
            SliderBackC.Parent = SliderBack
            
            SliderBar.Name = "SliderBar"
            SliderBar.Parent = SliderBack
            SliderBar.AnchorPoint = Vector2.new(0, 0.5)
            SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            SliderBar.BackgroundTransparency = ALTransparency
            SliderBar.BorderSizePixel = 0
            SliderBar.Position = UDim2.new(0.369000018, 40, 0.5, 0)
            SliderBar.Size = UDim2.new(0, 140, 0, 12)
            
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
            SliderValBG.BackgroundTransparency = ALTransparency
            SliderValBG.BorderSizePixel = 0
            SliderValBG.Position = UDim2.new(0.883177578, 0, 0.131578952, 0)
            SliderValBG.Size = UDim2.new(0, 44, 0, 28)
            SliderValBG.AutoButtonColor = false
            SliderValBG.Font = Enum.Font.Gotham
            SliderValBG.Text = ""
            SliderValBG.TextColor3 = config.TextColor
            SliderValBG.TextSize = 14.000
            
            SliderValBGC.CornerRadius = UDim.new(0, 6)
            SliderValBGC.Name = "SliderValBGC"
            SliderValBGC.Parent = SliderValBG
            
            SliderValue.Name = "SliderValue"
            SliderValue.Parent = SliderValBG
            SliderValue.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            SliderValue.BackgroundTransparency = 1.000
            SliderValue.BorderSizePixel = 0
            SliderValue.Size = UDim2.new(1, 0, 1, 0)
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.Text = tostring(default)
            SliderValue.TextColor3 = config.TextColor
            SliderValue.TextSize = 14.000
            
            MinSlider.Name = "MinSlider"
            MinSlider.Parent = SliderBack
            MinSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            MinSlider.BackgroundTransparency = 0
            MinSlider.BorderSizePixel = 0
            MinSlider.Position = UDim2.new(0.296728969, 40, 0.236842096, 0)
            MinSlider.Size = UDim2.new(0, 18, 0, 18)
            MinSlider.Font = Enum.Font.Gotham
            MinSlider.Text = "-"
            MinSlider.TextColor3 = config.TextColor
            MinSlider.TextSize = 24.000
            MinSlider.TextWrapped = true
            
            local MinSliderC = Instance.new("UICorner")
            MinSliderC.CornerRadius = UDim.new(0, 4)
            MinSliderC.Parent = MinSlider
            
            AddSlider.Name = "AddSlider"
            AddSlider.Parent = SliderBack
            AddSlider.AnchorPoint = Vector2.new(0, 0.5)
            AddSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            AddSlider.BackgroundTransparency = 0
            AddSlider.BorderSizePixel = 0
            AddSlider.Position = UDim2.new(0.810906529, 0, 0.5, 0)
            AddSlider.Size = UDim2.new(0, 18, 0, 18)
            AddSlider.Font = Enum.Font.Gotham
            AddSlider.Text = "+"
            AddSlider.TextColor3 = config.TextColor
            AddSlider.TextSize = 24.000
            AddSlider.TextWrapped = true
            
            local AddSliderC = Instance.new("UICorner")
            AddSliderC.CornerRadius = UDim.new(0, 4)
            AddSliderC.Parent = AddSlider
            
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
                    library.flags[flag] = tonumber(value)
                    SliderValue.Text = tostring(value)
                    
                    services.TweenService:Create(SliderPart, TweenInfo.new(0.1), {
                        Size = UDim2.new(percent, 0, 1, 0)
                    }):Play()
                    
                    callback(tonumber(value))
                end,
                
                GetValue = function(self)
                    return library.flags[flag]
                end
            }
            
            funcs:SetValue(default)
            
            MinSlider.MouseButton1Click:Connect(function()
                Ripple(MinSlider)
                local currentValue = library.flags[flag]
                currentValue = math.clamp(currentValue - 1, min, max)
                funcs:SetValue(currentValue)
            end)

            AddSlider.MouseButton1Click:Connect(function()
                Ripple(AddSlider)
                local currentValue = library.flags[flag]
                currentValue = math.clamp(currentValue + 1, min, max)
                funcs:SetValue(currentValue)
            end)
            
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
            local allowed = {
                [""] = true,
                ["-"] = true
            }
            
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
    
            library.flags[flag] = nil
            
            local DropdownModule = Instance.new("Frame")
            local DropdownTop = Instance.new("TextButton")
            local DropdownTopC = Instance.new("UICorner")
            local DropdownOpenFrame = Instance.new("Frame")
            local DropdownOpenFrameC = Instance.new("UICorner")
            local DropdownOpen = Instance.new("TextButton")
            local DropdownText = Instance.new("TextBox")
            local DropdownModuleL = Instance.new("UIListLayout")
            local Option = Instance.new("TextButton")
            local OptionC = Instance.new("UICorner")        
    
            DropdownModule.Name = "DropdownModule"
            DropdownModule.Parent = Objs
            DropdownModule.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
            DropdownModule.BackgroundTransparency = 1.000
            DropdownModule.BorderSizePixel = 0
            DropdownModule.ClipsDescendants = true
            DropdownModule.Position = UDim2.new(0, 0, 0, 0)
            DropdownModule.Size = UDim2.new(0, 428, 0, 38)
            
            DropdownTop.Name = "DropdownTop"
            DropdownTop.Parent = DropdownModule
            DropdownTop.BackgroundColor3 = config.Dropdown_Color
            DropdownTop.BackgroundTransparency = ALTransparency
            DropdownTop.BorderSizePixel = 0
            DropdownTop.Size = UDim2.new(0, 428, 0, 38)
            DropdownTop.AutoButtonColor = false
            DropdownTop.Font = Enum.Font.GothamSemibold
            DropdownTop.Text = ""
            DropdownTop.TextColor3 = config.TextColor
            DropdownTop.TextSize = 16.000
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
            
            DropdownOpenFrame.Name = "DropdownOpenFrame"
            DropdownOpenFrame.Parent = DropdownTop
            DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
            DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
            DropdownOpenFrame.BorderSizePixel = 0
            DropdownOpenFrame.Position = UDim2.new(0.80, 0, 0.5, 0)
            DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)
            DropdownOpenFrame.ZIndex = 2
            
            createAuroraEffect(DropdownOpenFrame, 0.8)
            
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
            DropdownText.Size = UDim2.new(0, 220, 0, 38)
            DropdownText.Font = Enum.Font.GothamSemibold
            DropdownText.PlaceholderColor3 = config.SecondaryTextColor
            DropdownText.PlaceholderText = text
            DropdownText.Text = ""
            DropdownText.TextColor3 = config.TextColor
            DropdownText.TextSize = 16.000
            DropdownText.TextXAlignment = Enum.TextXAlignment.Left
            DropdownText.ZIndex = 2
            
            local Separator = Instance.new("Frame")
            Separator.Name = "Separator"
            Separator.Parent = DropdownTop
            Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            Separator.BorderSizePixel = 0
            Separator.Position = UDim2.new(0.74, 0, 0.2, 0)
            Separator.Size = UDim2.new(0, 1, 0, 22)
            Separator.ZIndex = 1
            
            DropdownModuleL.Name = "DropdownModuleL"
            DropdownModuleL.Parent = DropdownModule
            DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownModuleL.Padding = UDim.new(0, 4)
    
            local setAllVisible = function()
                local options = DropdownModule:GetChildren() 
                for i=1, #options do
                    local option = options[i]
                    if option:IsA("TextButton") and option.Name:match("Option_") then
                        option.Visible = true
                    end
                end
            end
    
            local searchDropdown = function(text)
                local options = DropdownModule:GetChildren()
                for i=1, #options do
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
                if open then setAllVisible() end
                DropdownOpen.Text = (open and "取消" or "选择")
                DropdownModule.Size = UDim2.new(0, 428, 0, (open and math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150) or 38))
            end
    
            DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)
            DropdownText.Focused:Connect(function()
                if open then return end
                ToggleDropVis()
            end)
    
            DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                if not open then return end
                searchDropdown(DropdownText.Text)
            end)
    
            DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                DropdownModule.Size = UDim2.new(0, 428, 0, math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150))
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
                Option.Size = UDim2.new(0, 400, 0, 26)
                Option.AutoButtonColor = false
                Option.Font = Enum.Font.Gotham
                Option.Text = option
                Option.TextColor3 = config.TextColor
                Option.TextSize = 14.000
                
                OptionC.CornerRadius = UDim.new(0, 6)
                OptionC.Name = "OptionC"
                OptionC.Parent = Option
    
                Option.MouseButton1Click:Connect(function()
                    Ripple(Option)
                    ToggleDropVis()
                    callback(Option.Text)
                    DropdownText.Text = Option.Text
                    library.flags[flag] = Option.Text
                end)
            end
    
            funcs.RemoveOption = function(self, option)
                local option = DropdownModule:FindFirstChild("Option_" .. option)
                if option then option:Destroy() end
            end
    
            funcs.SetOptions = function(self, options)
                for _, v in next, DropdownModule:GetChildren() do
                    if v.Name:match("Option_") then
                        v:Destroy()
                    end
                end
                for _,v in next, options do
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
return library