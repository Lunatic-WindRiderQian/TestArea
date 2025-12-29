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
FengUI.showingCards = true
FengUI.tabContainers = {}
FengUI.ColorPickers = {}

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

-- 红灰色主题配置
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
    SliderBar_Color = Color3.fromRGB(255, 60, 60),
    Toggle_Color = Color3.fromRGB(30, 30, 50),
    Toggle_Off = Color3.fromRGB(50, 50, 70),
    Toggle_On = Color3.fromRGB(255, 60, 60),
    AccentColor = Color3.fromRGB(255, 60, 60),
    TextColor = Color3.fromRGB(240, 245, 255),
    SecondaryTextColor = Color3.fromRGB(180, 190, 210),
    GlowColor = Color3.fromRGB(255, 60, 60),
    
    DeepSpaceColor = Color3.fromRGB(1, 2, 10),
    NebulaColor1 = Color3.fromRGB(40, 40, 40),
    NebulaColor2 = Color3.fromRGB(60, 60, 60),
    AccentGlow = Color3.fromRGB(255, 80, 80),
    ElementColor = Color3.fromRGB(30, 30, 50),
    ElementTransparency = 0.2,
    GlassEffect = Color3.fromRGB(255, 255, 255),
}

-- 保留mainUI的粒子爆炸效果
function DigitalParticleExplosion(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        
        local x = (mouse.X - obj.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - obj.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        
        local explosionCenter = Instance.new("Frame")
        explosionCenter.Name = "ExplosionCenter"
        explosionCenter.Parent = obj
        explosionCenter.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        explosionCenter.BackgroundTransparency = 0.3
        explosionCenter.ZIndex = 8
        explosionCenter.Size = UDim2.new(0, 20, 0, 20)
        explosionCenter.AnchorPoint = Vector2.new(0.5, 0.5)
        explosionCenter.Position = UDim2.new(x, 0, y, 0)
        
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1, 0)
        centerCorner.Parent = explosionCenter
        
        local centerGlow = Instance.new("UIStroke")
        centerGlow.Parent = explosionCenter
        centerGlow.Color = Color3.fromRGB(255, 60, 60)
        centerGlow.Thickness = 3
        centerGlow.Transparency = 0.2
        
        local particleCount = 12
        local particles = {}
        
        for i = 1, particleCount do
            local angle = (i / particleCount) * math.pi * 2
            local distance = math.random(30, 80)
            
            local particle = Instance.new("TextLabel")
            particle.Name = "DigitalParticle_" .. i
            particle.Parent = obj
            particle.BackgroundTransparency = 1
            particle.Text = tostring(math.random(0, 1))
            particle.TextColor3 = Color3.fromRGB(
                math.random(200, 255),
                math.random(50, 100),
                math.random(50, 100)
            )
            particle.TextSize = math.random(10, 14)
            particle.Font = Enum.Font.Code
            particle.ZIndex = 9
            particle.Size = UDim2.new(0, 20, 0, 20)
            particle.Position = UDim2.new(x, 0, y, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            
            table.insert(particles, {
                instance = particle,
                angle = angle,
                distance = distance,
                speed = math.random(150, 250),
                rotation = math.random(-180, 180)
            })
        end
        
        services.TweenService:Create(explosionCenter, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundTransparency = 1
        }):Play()
        
        services.TweenService:Create(centerGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 8,
            Transparency = 1
        }):Play()
        
        local startTime = tick()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            
            if elapsed > 0.8 then
                connection:Disconnect()
                explosionCenter:Destroy()
                for _, particleData in ipairs(particles) do
                    particleData.instance:Destroy()
                end
                return
            end
            
            local progress = elapsed / 0.8
            
            for _, particleData in ipairs(particles) do
                local moveProgress = progress * particleData.speed / 100
                local currentDistance = particleData.distance * moveProgress
                
                local offsetX = math.cos(particleData.angle) * currentDistance
                local offsetY = math.sin(particleData.angle) * currentDistance
                
                particleData.instance.Position = UDim2.new(
                    x, offsetX,
                    y, offsetY
                )
                
                particleData.instance.Rotation = particleData.rotation * progress
                particleData.instance.TextTransparency = progress
                
                if math.random(1, 3) == 1 then
                    particleData.instance.Text = tostring(math.random(0, 1))
                end
            end
            
            explosionCenter.Size = UDim2.new(0, 40 + progress * 20, 0, 40 + progress * 20)
        end)
        
        local shockwave = Instance.new("Frame")
        shockwave.Name = "Shockwave"
        shockwave.Parent = obj
        shockwave.BackgroundTransparency = 1
        shockwave.ZIndex = 7
        shockwave.Size = UDim2.new(0, 0, 0, 0)
        shockwave.AnchorPoint = Vector2.new(0.5, 0.5)
        shockwave.Position = UDim2.new(x, 0, y, 0)
        
        local shockwaveStroke = Instance.new("UIStroke")
        shockwaveStroke.Parent = shockwave
        shockwaveStroke.Color = Color3.fromRGB(255, 80, 80)
        shockwaveStroke.Thickness = 3
        shockwaveStroke.Transparency = 0.3
        
        services.TweenService:Create(shockwave, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 120, 0, 120)
        }):Play()
        
        services.TweenService:Create(shockwaveStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 1,
            Transparency = 1
        }):Play()
        
        task.wait(0.6)
        shockwave:Destroy()
    end)
end

-- UI.lua 中的关键功能函数
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
        local r = math.sin(hue * 3 + 0) * 0.3 + 0.7
        local g = math.sin(hue * 3 + 2) * 0.1
        local b = math.sin(hue * 3 + 4) * 0.1
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 90, 90))
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

-- 切换标签页功能
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
    DigitalParticleExplosion(CloseButton)
    
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

-- 卡片容器
local CardsContainer = Instance.new("Frame")
CardsContainer.Name = "CardsContainer"
CardsContainer.Parent = Main
CardsContainer.BackgroundTransparency = 1
CardsContainer.Position = UDim2.new(0, 0, 0, 35)
CardsContainer.Size = UDim2.new(1, 0, 1, -35)
CardsContainer.Visible = true

local CardsLayout = Instance.new("UIGridLayout")
CardsLayout.Parent = CardsContainer
CardsLayout.CellSize = UDim2.new(0, 100, 0, 100)
CardsLayout.CellPadding = UDim2.new(0, 5, 0, 5)
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
CardsLayout.StartCorner = Enum.StartCorner.TopLeft

-- 主标签页容器
local MainTabContainer = Instance.new("Frame")
MainTabContainer.Name = "MainTabContainer"
MainTabContainer.Parent = Main
MainTabContainer.BackgroundTransparency = 1
MainTabContainer.Position = UDim2.new(0.2, 0, 0, 37)
MainTabContainer.Size = UDim2.new(0, 360, 0, 243)
MainTabContainer.Visible = false

-- 主侧边栏容器
local MainSideContainer = Instance.new("Frame")
MainSideContainer.Name = "MainSideContainer"
MainSideContainer.Parent = Main
MainSideContainer.BackgroundTransparency = 1
MainSideContainer.Position = UDim2.new(0, 0, 0, 35)
MainSideContainer.Size = UDim2.new(0, 90, 1, -35)
MainSideContainer.Visible = false

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = MainSideContainer

-- 返回卡片按钮
local ReturnToCardsButton = Instance.new("TextButton")
ReturnToCardsButton.Name = "ReturnToCardsButton"
ReturnToCardsButton.Parent = MainSideContainer
ReturnToCardsButton.BackgroundColor3 = config.Button_Color
ReturnToCardsButton.BackgroundTransparency = 0.2
ReturnToCardsButton.BorderSizePixel = 0
ReturnToCardsButton.Position = UDim2.new(0, 0, 0, 0)
ReturnToCardsButton.Size = UDim2.new(1, 0, 0, 25)
ReturnToCardsButton.AutoButtonColor = false
ReturnToCardsButton.Font = Enum.Font.GothamBold
ReturnToCardsButton.Text = "← 返回页面"
ReturnToCardsButton.TextColor3 = config.TextColor
ReturnToCardsButton.TextSize = 12
ReturnToCardsButton.TextScaled = true

local ReturnButtonCorner = Instance.new("UICorner")
ReturnButtonCorner.CornerRadius = UDim.new(0, 6)
ReturnButtonCorner.Parent = ReturnToCardsButton

local returnGlow = Instance.new("UIStroke")
returnGlow.Parent = ReturnToCardsButton
returnGlow.Color = config.AccentColor
returnGlow.Thickness = 1
returnGlow.Transparency = 0.8

startNeonFlowEffect(returnGlow, "Color", 0.01)
createPulseGlow(returnGlow)

ReturnToCardsButton.MouseEnter:Connect(function()
    services.TweenService:Create(ReturnToCardsButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(
            math.floor(config.Button_Color.R * 255 * 1.1),
            math.floor(config.Button_Color.G * 255 * 1.1),
            math.floor(config.Button_Color.B * 255 * 1.1)
        )
    }):Play()
    services.TweenService:Create(returnGlow, TweenInfo.new(0.2), {
        Thickness = 2,
        Transparency = 0.5
    }):Play()
end)

ReturnToCardsButton.MouseLeave:Connect(function()
    services.TweenService:Create(ReturnToCardsButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        BackgroundColor3 = config.Button_Color
    }):Play()
    services.TweenService:Create(returnGlow, TweenInfo.new(0.2), {
        Thickness = 1,
        Transparency = 0.8
    }):Play()
end)

local function showCards()
    FengUI.showingCards = true
    CardsContainer.Visible = true
    MainSideContainer.Visible = false
    MainTabContainer.Visible = false
    
    if FengUI.currentTab then
        FengUI.currentTab[2].Visible = false
        FengUI.currentTab = nil
    end
    
    services.TweenService:Create(CardsContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(MainSideContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
end

ReturnToCardsButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(ReturnToCardsButton)
    showCards()
end)

-- 入场动画
local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    MainSideContainer.BackgroundTransparency = 1
    CardsContainer.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    neonStroke.Transparency = 1
    
    MainTabContainer.Visible = false
    MainSideContainer.Visible = false
    
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
    
    if FengUI.showingCards then
        CardsContainer.Visible = true
        services.TweenService:Create(CardsContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
    else
        services.TweenService:Create(MainSideContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
    end
    
    task.wait(0.2)
    
    if not FengUI.showingCards then
        MainTabContainer.Visible = true
        MainSideContainer.Visible = true
    end
    
    DigitalParticleExplosion(Main)
end

task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

-- 标题动画
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

-- 主要UI创建函数
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
    
    -- 卡片创建函数（mainUI风格）
    function window.card(window, name, description, icon)
        local Card = Instance.new("TextButton")
        Card.Name = "Card_" .. name
        Card.Parent = CardsContainer
        Card.BackgroundColor3 = config.TabColor
        Card.BackgroundTransparency = 0.2
        Card.AutoButtonColor = false
        Card.Text = ""
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 12)
        CardCorner.Parent = Card
        
        local CardGlow = Instance.new("UIStroke")
        CardGlow.Parent = Card
        CardGlow.Color = config.AccentColor
        CardGlow.Thickness = 2
        CardGlow.Transparency = 0.7
        
        startNeonFlowEffect(CardGlow, "Color", 0.008)
        createPulseGlow(CardGlow)
        
        local CardIcon = Instance.new("ImageLabel")
        CardIcon.Name = "CardIcon"
        CardIcon.Parent = Card
        CardIcon.BackgroundTransparency = 1
        CardIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        CardIcon.Position = UDim2.new(0.5, 0, 0.3, 0)
        CardIcon.Size = UDim2.new(0, 40, 0, 40)
        CardIcon.Image = "rbxassetid://" .. tostring(icon or "84830962019412")
        CardIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        
        local CardTitle = Instance.new("TextLabel")
        CardTitle.Name = "CardTitle"
        CardTitle.Parent = Card
        CardTitle.BackgroundTransparency = 1
        CardTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        CardTitle.Position = UDim2.new(0.5, 0, 0.65, 0)
        CardTitle.Size = UDim2.new(0.8, 0, 0, 20)
        CardTitle.Font = Enum.Font.GothamBold
        CardTitle.Text = name
        CardTitle.TextColor3 = config.TextColor
        CardTitle.TextSize = 12
        CardTitle.TextScaled = false
        
        local CardDescription = Instance.new("TextLabel")
        CardDescription.Name = "CardDescription"
        CardDescription.Parent = Card
        CardDescription.BackgroundTransparency = 1
        CardDescription.AnchorPoint = Vector2.new(0.5, 0.5)
        CardDescription.Position = UDim2.new(0.5, 0, 0.85, 0)
        CardDescription.Size = UDim2.new(0.8, 0, 0, 15)
        CardDescription.Font = Enum.Font.Gotham
        CardDescription.Text = description or ""
        CardDescription.TextColor3 = config.SecondaryTextColor
        CardDescription.TextSize = 10
        CardDescription.TextScaled = false
        CardDescription.TextWrapped = true
        
        local CardShadow = Instance.new("ImageLabel")
        CardShadow.Name = "CardShadow"
        CardShadow.Parent = Card
        CardShadow.BackgroundTransparency = 1
        CardShadow.Size = UDim2.new(1, 10, 1, 10)
        CardShadow.Position = UDim2.new(0, -5, 0, -5)
        CardShadow.Image = "rbxassetid://5554236805"
        CardShadow.ImageColor3 = Color3.new(0, 0, 0)
        CardShadow.ImageTransparency = 0.8
        CardShadow.ScaleType = Enum.ScaleType.Slice
        CardShadow.SliceCenter = Rect.new(23, 23, 277, 277)
        CardShadow.ZIndex = -1
        
        local tabContainer = Instance.new("Frame")
        tabContainer.Name = "TabContainer_" .. name
        tabContainer.Parent = MainTabContainer
        tabContainer.BackgroundTransparency = 1
        tabContainer.Size = UDim2.new(1, 0, 1, 0)
        tabContainer.Visible = false
        
        local sideContainer = Instance.new("Frame")
        sideContainer.Name = "SideContainer_" .. name
        sideContainer.Parent = MainSideContainer
        sideContainer.BackgroundColor3 = config.TabColor
        sideContainer.BackgroundTransparency = 0.2
        sideContainer.BorderSizePixel = 0
        sideContainer.ClipsDescendants = true
        sideContainer.Size = UDim2.new(1, 0, 1, 0)
        sideContainer.Visible = false
        
        local sideCorner = Instance.new("UICorner")
        sideCorner.CornerRadius = UDim.new(0, 10)
        sideCorner.Parent = sideContainer
        
        local tabBtns = Instance.new("ScrollingFrame")
        tabBtns.Name = "TabBtns"
        tabBtns.Parent = sideContainer
        tabBtns.Active = true
        tabBtns.BackgroundTransparency = 1
        tabBtns.BorderSizePixel = 0
        tabBtns.Position = UDim2.new(0, 0, 0, 25)
        tabBtns.Size = UDim2.new(0, 90, 0, 220)
        tabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabBtns.ScrollBarThickness = 3
        tabBtns.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        tabBtns.ScrollBarImageTransparency = 0.5
        tabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
        tabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
        tabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        tabBtns.Visible = true
        
        local tabBtnsL = Instance.new("UIListLayout")
        tabBtnsL.Name = "TabBtnsL"
        tabBtnsL.Parent = tabBtns
        tabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
        tabBtnsL.Padding = UDim.new(0, 6)
        
        setupSmoothScrolling(tabBtns, tabBtnsL)
        
        FengUI.tabContainers[name] = {
            tabContainer = tabContainer,
            sideContainer = sideContainer,
            tabBtns = tabBtns
        }
        
        Card.MouseEnter:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 105, 0, 105)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 3,
                Transparency = 0.4
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 45, 0, 45),
                Rotation = 5
            }):Play()
            services.TweenService:Create(CardShadow, TweenInfo.new(0.3), {
                ImageTransparency = 0.6,
                Size = UDim2.new(1, 15, 1, 15),
                Position = UDim2.new(0, -7, 0, -7)
            }):Play()
            
            services.TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, Card.Position.X.Offset, 0, Card.Position.Y.Offset - 3)
            }):Play()
            
            local pulseConnection
            pulseConnection = RunService.Heartbeat:Connect(function()
                if not CardIcon or not CardIcon.Parent then
                    pulseConnection:Disconnect()
                    return
                end
                CardIcon.ImageTransparency = 0.1 + math.sin(tick() * 8) * 0.1
            end)
            
            Card:SetAttribute("PulseConnection", pulseConnection)
        end)
        
        Card.MouseLeave:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 100, 0, 100)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 2,
                Transparency = 0.7
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 40, 0, 40),
                Rotation = 0,
                ImageTransparency = 0
            }):Play()
            services.TweenService:Create(CardShadow, TweenInfo.new(0.3), {
                ImageTransparency = 0.8,
                Size = UDim2.new(1, 10, 1, 10),
                Position = UDim2.new(0, -5, 0, -5)
            }):Play()
            
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            local pulseConnection = Card:GetAttribute("PulseConnection")
            if pulseConnection then
                pulseConnection:Disconnect()
            end
        end)
        
        local function showTabContainer()
            for _, containerData in pairs(FengUI.tabContainers) do
                containerData.tabContainer.Visible = false
                containerData.sideContainer.Visible = false
            end
            
            tabContainer.Visible = true
            sideContainer.Visible = true
            
            FengUI.showingCards = false
            CardsContainer.Visible = false
            MainTabContainer.Visible = true
            MainSideContainer.Visible = true
        end
        
        Card.MouseButton1Click:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 95, 0, 95),
                BackgroundTransparency = 0.3
            }):Play()
            
            services.TweenService:Create(CardIcon, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 35, 0, 35)
            }):Play()
            
            task.wait(0.1)
            
            services.TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 105, 0, 105),
                BackgroundTransparency = 0.1
            }):Play()
            
            services.TweenService:Create(CardIcon, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 45, 0, 45)
            }):Play()
            
            DigitalParticleExplosion(Card)
            showTabContainer()
        end)
        
        local cardObj = {}
        
        -- 单窗口标签页
        function cardObj.Tab(cardObj, tabName, tabIcon)
            return createTab(cardObj, tabName, tabIcon, 1)
        end
        
        -- 双窗口标签页（使用DualTab方法）
        function cardObj.DualTab(cardObj, tabName, tabIcon)
            return createTab(cardObj, tabName, tabIcon, 2)
        end
        
        -- 创建标签页的内部函数
        function createTab(cardObj, tabName, tabIcon, windowCount)
            windowCount = windowCount or 1
            
            local TabIco = Instance.new("ImageLabel")
            TabIco.Name = "TabIco"
            TabIco.Parent = tabBtns
            TabIco.BackgroundTransparency = 1
            TabIco.BorderSizePixel = 0
            TabIco.Size = UDim2.new(0, 22, 0, 22)
            TabIco.Image = "rbxassetid://" .. tostring(tabIcon or "84830962019412")
            TabIco.ImageTransparency = 0.5
            
            startNeonFlowEffect(TabIco, "ImageColor3", 0.005)
            
            local TabText = Instance.new("TextLabel")
            TabText.Name = "TabText"
            TabText.Parent = TabIco
            TabText.BackgroundTransparency = 1
            TabText.Position = UDim2.new(1.2, 0, 0, 0)
            TabText.Size = UDim2.new(0, 65, 0, 22)
            TabText.Font = Enum.Font.GothamSemibold
            TabText.Text = tabName
            TabText.TextColor3 = config.TextColor
            TabText.TextSize = 14
            TabText.TextXAlignment = Enum.TextXAlignment.Left
            TabText.TextTransparency = 0.5
            
            local TabBtn = Instance.new("TextButton")
            TabBtn.Name = "TabBtn"
            TabBtn.Parent = TabIco
            TabBtn.BackgroundTransparency = 1
            TabBtn.BorderSizePixel = 0
            TabBtn.Size = UDim2.new(0, 90, 0, 22)
            TabBtn.AutoButtonColor = false
            TabBtn.Font = Enum.Font.SourceSans
            TabBtn.Text = ""
            
            local Tab = Instance.new("ScrollingFrame")
            Tab.Name = "Tab_" .. tabName
            Tab.Parent = tabContainer
            Tab.Active = true
            Tab.BackgroundTransparency = 1
            Tab.Size = UDim2.new(1, 0, 1, 0)
            Tab.ScrollBarThickness = 2
            Tab.ScrollBarImageTransparency = 0.5
            Tab.Visible = false
            Tab.ElasticBehavior = Enum.ElasticBehavior.Never
            Tab.ScrollingDirection = Enum.ScrollingDirection.Y
            Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            -- 双窗口布局
            if windowCount == 2 then
                local TabContainer = Instance.new("Frame")
                TabContainer.Name = "TabContainer"
                TabContainer.Parent = Tab
                TabContainer.BackgroundTransparency = 1
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
            else
                local TabL = Instance.new("UIListLayout")
                TabL.Name = "TabL"
                TabL.Parent = Tab
                TabL.SortOrder = Enum.SortOrder.LayoutOrder
                TabL.Padding = UDim.new(0, 4)
                
                setupSmoothScrolling(Tab, TabL)
            end
            
            TabBtn.MouseButton1Click:Connect(function()
                DigitalParticleExplosion(TabBtn)
                switchTab({ TabIco, Tab })
            end)
            
            if FengUI.currentTab == nil then
                switchTab({ TabIco, Tab })
            end
            
            local tabObj = {}
            
            -- 重写的section函数（来自UI.lua）
            function tabObj.section(tabObj, name, windowPosition, TabVal)
                if type(windowPosition) == "boolean" then
                    TabVal = windowPosition
                    windowPosition = "Left"
                elseif not windowPosition or type(windowPosition) ~= "string" then
                    windowPosition = "Left"
                end
                
                local TargetContainer
                local elementWidth
                
                if windowCount == 2 then
                    if windowPosition:lower() == "left" then
                        TargetContainer = Tab:FindFirstChild("TabContainer"):FindFirstChild("LeftContainer")
                        elementWidth = 160
                    else
                        TargetContainer = Tab:FindFirstChild("TabContainer"):FindFirstChild("RightContainer")
                        elementWidth = 168
                    end
                else
                    TargetContainer = Tab
                    elementWidth = 330
                end
                
                if not TargetContainer then
                    TargetContainer = Tab
                    elementWidth = 330
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
                    
                    DigitalParticleExplosion(SectionToggle)
                end)
                
                ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then
                        updateSectionHeight()
                    end
                end)
                
                local section = {}
                
                -- 按钮
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
                        DigitalParticleExplosion(Btn)
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
                
                -- 标签
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
                
                -- 开关
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
                        DigitalParticleExplosion(ToggleBtn)
                        funcs:SetState()
                    end)
                    
                    return funcs
                end
                
                -- 键位绑定
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
                        DigitalParticleExplosion(KeybindValue)
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
                
                -- 文本框
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
                        
                        DigitalParticleExplosion(BoxBG)
                    end)
                    
                    TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
                    end)
                    
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
                end
                
                -- 颜色选择器（来自UI.lua）
                function section.ColorPicker(section, text, flag, defaultColor, callback)
                    callback = callback or function() end
                    defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
                    assert(text, "No text provided")
                    assert(flag, "No flag provided")
                    
                    FengUI.flags[flag] = defaultColor
                    
                    local ColorPickerModule = Instance.new("Frame")
                    local ColorPickerBtn = Instance.new("TextButton")
                    local ColorPickerBtnC = Instance.new("UICorner")
                    local ColorPreview = Instance.new("Frame")
                    local ColorPreviewC = Instance.new("UICorner")
                    local ColorPickerL = Instance.new("UIListLayout")
                    local ColorPickerP = Instance.new("UIPadding")
                    
                    ColorPickerModule.Name = "ColorPickerModule"
                    ColorPickerModule.Parent = Objs
                    ColorPickerModule.BackgroundTransparency = 1
                    ColorPickerModule.BorderSizePixel = 0
                    ColorPickerModule.Size = UDim2.new(0, elementWidth, 0, 36)
                    
                    ColorPickerBtn.Name = "ColorPickerBtn"
                    ColorPickerBtn.Parent = ColorPickerModule
                    ColorPickerBtn.BackgroundColor3 = config.Button_Color
                    ColorPickerBtn.BackgroundTransparency = 0.2
                    ColorPickerBtn.BorderSizePixel = 0
                    ColorPickerBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                    ColorPickerBtn.AutoButtonColor = false
                    ColorPickerBtn.Font = Enum.Font.GothamSemibold
                    ColorPickerBtn.Text = "   " .. text
                    ColorPickerBtn.TextColor3 = config.TextColor
                    ColorPickerBtn.TextSize = 14
                    ColorPickerBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    ColorPickerBtnC.CornerRadius = UDim.new(0, 6)
                    ColorPickerBtnC.Name = "ColorPickerBtnC"
                    ColorPickerBtnC.Parent = ColorPickerBtn
                    
                    local colorPickerPosition = 0.65
                    if windowCount == 2 then
                        colorPickerPosition = 0.56
                    end
                    
                    ColorPreview.Name = "ColorPreview"
                    ColorPreview.Parent = ColorPickerBtn
                    ColorPreview.BackgroundColor3 = defaultColor
                    ColorPreview.BorderSizePixel = 0
                    ColorPreview.Position = UDim2.new(colorPickerPosition, 0, 0.22, 0)
                    ColorPreview.Size = UDim2.new(0, 40, 0, 22)
                    
                    ColorPreviewC.CornerRadius = UDim.new(0, 6)
                    ColorPreviewC.Name = "ColorPreviewC"
                    ColorPreviewC.Parent = ColorPreview
                    
                    ColorPickerL.Name = "ColorPickerL"
                    ColorPickerL.Parent = ColorPickerBtn
                    ColorPickerL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    ColorPickerL.SortOrder = Enum.SortOrder.LayoutOrder
                    ColorPickerL.VerticalAlignment = Enum.VerticalAlignment.Center
                    
                    ColorPickerP.Name = "ColorPickerP"
                    ColorPickerP.Parent = ColorPickerBtn
                    ColorPickerP.PaddingRight = UDim.new(0, 8)
                    
                    local ColorPickerPopup = Instance.new("Frame")
                    ColorPickerPopup.Name = "ColorPickerPopup"
                    ColorPickerPopup.Parent = Main
                    ColorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
                    ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
                    ColorPickerPopup.BackgroundTransparency = 0.1
                    ColorPickerPopup.BorderSizePixel = 0
                    ColorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                    ColorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
                    ColorPickerPopup.Visible = false
                    ColorPickerPopup.ZIndex = 1000
                    ColorPickerPopup.Active = false
                    ColorPickerPopup.Draggable = false
                    
                    local PopupCorner = Instance.new("UICorner")
                    PopupCorner.CornerRadius = UDim.new(0, 8)
                    PopupCorner.Parent = ColorPickerPopup
                    
                    local PopupStroke = Instance.new("UIStroke")
                    PopupStroke.Parent = ColorPickerPopup
                    PopupStroke.Color = Color3.fromRGB(255, 60, 60)
                    PopupStroke.Thickness = 1.5
                    PopupStroke.Transparency = 0.2
                    
                    startNeonFlowEffect(PopupStroke, "Color", 0.01)
                    
                    local PopupTitle = Instance.new("TextLabel")
                    PopupTitle.Name = "PopupTitle"
                    PopupTitle.Parent = ColorPickerPopup
                    PopupTitle.BackgroundTransparency = 1
                    PopupTitle.Position = UDim2.new(0, 10, 0, 8)
                    PopupTitle.Size = UDim2.new(1, -20, 0, 24)
                    PopupTitle.Font = Enum.Font.GothamBold
                    PopupTitle.Text = text
                    PopupTitle.TextColor3 = Color3.fromRGB(255, 60, 60)
                    PopupTitle.TextSize = 16
                    PopupTitle.TextXAlignment = Enum.TextXAlignment.Center
                    PopupTitle.ZIndex = 1001
                    
                    local SatVibMap = Instance.new("ImageLabel")
                    SatVibMap.Name = "SatVibMap"
                    SatVibMap.Parent = ColorPickerPopup
                    SatVibMap.Size = UDim2.fromOffset(150, 140)
                    SatVibMap.Position = UDim2.fromOffset(15, 40)
                    SatVibMap.Image = "rbxassetid://4155801252"
                    SatVibMap.BackgroundColor3 = defaultColor
                    SatVibMap.BackgroundTransparency = 0
                    SatVibMap.ZIndex = 1001
                    
                    local SatVibCorner = Instance.new("UICorner")
                    SatVibCorner.CornerRadius = UDim.new(0, 4)
                    SatVibCorner.Parent = SatVibMap
                    
                    local SatCursor = Instance.new("ImageLabel")
                    SatCursor.Name = "SatCursor"
                    SatCursor.Size = UDim2.new(0, 16, 0, 16)
                    SatCursor.ScaleType = Enum.ScaleType.Fit
                    SatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                    SatCursor.BackgroundTransparency = 1
                    SatCursor.Image = "http://www.roblox.com/asset/?id=4805639000"
                    SatCursor.ZIndex = 1002
                    SatCursor.Parent = SatVibMap
                    
                    local HueSlider = Instance.new("Frame")
                    HueSlider.Name = "HueSlider"
                    HueSlider.Parent = ColorPickerPopup
                    HueSlider.Size = UDim2.fromOffset(14, 140)
                    HueSlider.Position = UDim2.fromOffset(175, 40)
                    HueSlider.ZIndex = 1001
                    
                    local HueSliderCorner = Instance.new("UICorner")
                    HueSliderCorner.CornerRadius = UDim.new(1, 0)
                    HueSliderCorner.Parent = HueSlider
                    
                    local SequenceTable = {}
                    for Color = 0, 1, 0.1 do
                        table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
                    end
                    
                    local HueSliderGradient = Instance.new("UIGradient")
                    HueSliderGradient.Color = ColorSequence.new(SequenceTable)
                    HueSliderGradient.Rotation = 90
                    HueSliderGradient.Parent = HueSlider
                    
                    local HueDragHolder = Instance.new("Frame")
                    HueDragHolder.Name = "HueDragHolder"
                    HueDragHolder.Size = UDim2.new(1, 0, 1, -10)
                    HueDragHolder.Position = UDim2.fromOffset(0, 5)
                    HueDragHolder.BackgroundTransparency = 1
                    HueDragHolder.Parent = HueSlider
                    HueDragHolder.ZIndex = 1002
                    
                    local HueDrag = Instance.new("ImageLabel")
                    HueDrag.Name = "HueDrag"
                    HueDrag.Size = UDim2.fromOffset(14, 14)
                    HueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
                    HueDrag.Parent = HueDragHolder
                    HueDrag.ImageColor3 = Color3.new(1, 1, 1)
                    HueDrag.ZIndex = 1003
                    
                    local RGBInputs = Instance.new("Frame")
                    RGBInputs.Name = "RGBInputs"
                    RGBInputs.Parent = ColorPickerPopup
                    RGBInputs.BackgroundTransparency = 1
                    RGBInputs.Position = UDim2.new(0, 200, 0, 40)
                    RGBInputs.Size = UDim2.new(0, 110, 0, 140)
                    RGBInputs.ZIndex = 1001
                    
                    local function createRGBInput(label, position, defaultValue)
                        local InputFrame = Instance.new("Frame")
                        InputFrame.Name = label .. "Input"
                        InputFrame.Parent = RGBInputs
                        InputFrame.BackgroundTransparency = 1
                        InputFrame.Position = position
                        InputFrame.Size = UDim2.new(1, 0, 0, 28)
                        InputFrame.ZIndex = 1002
                        
                        local InputLabel = Instance.new("TextLabel")
                        InputLabel.Name = "Label"
                        InputLabel.Parent = InputFrame
                        InputLabel.BackgroundTransparency = 1
                        InputLabel.Position = UDim2.new(0, 0, 0, 0)
                        InputLabel.Size = UDim2.new(0, 25, 1, 0)
                        InputLabel.Font = Enum.Font.GothamSemibold
                        InputLabel.Text = label .. ":"
                        InputLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
                        InputLabel.TextSize = 13
                        InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                        InputLabel.ZIndex = 1002
                        
                        local InputBox = Instance.new("TextBox")
                        InputBox.Name = "InputBox"
                        InputBox.Parent = InputFrame
                        InputBox.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
                        InputBox.BackgroundTransparency = 0.1
                        InputBox.BorderSizePixel = 0
                        InputBox.Position = UDim2.new(0, 30, 0, 0)
                        InputBox.Size = UDim2.new(0, 75, 0, 28)
                        InputBox.Font = Enum.Font.Gotham
                        InputBox.Text = tostring(defaultValue)
                        InputBox.TextColor3 = Color3.new(1, 1, 1)
                        InputBox.TextSize = 13
                        InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                        InputBox.ZIndex = 1002
                        
                        local InputCorner = Instance.new("UICorner")
                        InputCorner.CornerRadius = UDim.new(0, 4)
                        InputCorner.Parent = InputBox
                        
                        return InputBox
                    end
                    
                    local RInput = createRGBInput("R", UDim2.new(0, 0, 0, 0), math.floor(defaultColor.R * 255))
                    local GInput = createRGBInput("G", UDim2.new(0, 0, 0, 32), math.floor(defaultColor.G * 255))
                    local BInput = createRGBInput("B", UDim2.new(0, 0, 0, 64), math.floor(defaultColor.B * 255))
                    local HexInput = createRGBInput("Hex", UDim2.new(0, 0, 0, 96), "#" .. defaultColor:ToHex())
                    
                    local PreviewContainer = Instance.new("Frame")
                    PreviewContainer.Name = "PreviewContainer"
                    PreviewContainer.Parent = ColorPickerPopup
                    PreviewContainer.BackgroundTransparency = 1
                    PreviewContainer.Position = UDim2.new(0, 15, 0, 190)
                    PreviewContainer.Size = UDim2.new(1, -30, 0, 30)
                    PreviewContainer.ZIndex = 1001
                    
                    local OldColorFrame = Instance.new("Frame")
                    OldColorFrame.Name = "OldColorFrame"
                    OldColorFrame.Parent = PreviewContainer
                    OldColorFrame.BackgroundColor3 = defaultColor
                    OldColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
                    OldColorFrame.Position = UDim2.new(0, 0, 0, 0)
                    OldColorFrame.BackgroundTransparency = 0
                    OldColorFrame.ZIndex = 1002
                    
                    local OldColorFrameCorner = Instance.new("UICorner")
                    OldColorFrameCorner.CornerRadius = UDim.new(0, 4)
                    OldColorFrameCorner.Parent = OldColorFrame
                    
                    local OldColorLabel = Instance.new("TextLabel")
                    OldColorLabel.Name = "OldColorLabel"
                    OldColorLabel.Parent = OldColorFrame
                    OldColorLabel.BackgroundTransparency = 1
                    OldColorLabel.Size = UDim2.new(1, 0, 1, 0)
                    OldColorLabel.Font = Enum.Font.Gotham
                    OldColorLabel.Text = "原色"
                    OldColorLabel.TextColor3 = Color3.new(1, 1, 1)
                    OldColorLabel.TextSize = 12
                    OldColorLabel.TextXAlignment = Enum.TextXAlignment.Center
                    OldColorLabel.ZIndex = 1003
                    
                    local CurrentColorFrame = Instance.new("Frame")
                    CurrentColorFrame.Name = "CurrentColorFrame"
                    CurrentColorFrame.Parent = PreviewContainer
                    CurrentColorFrame.BackgroundColor3 = defaultColor
                    CurrentColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
                    CurrentColorFrame.Position = UDim2.new(0.52, 0, 0, 0)
                    CurrentColorFrame.BackgroundTransparency = 0
                    CurrentColorFrame.ZIndex = 1002
                    
                    local CurrentColorFrameCorner = Instance.new("UICorner")
                    CurrentColorFrameCorner.CornerRadius = UDim.new(0, 4)
                    CurrentColorFrameCorner.Parent = CurrentColorFrame
                    
                    local CurrentColorLabel = Instance.new("TextLabel")
                    CurrentColorLabel.Name = "CurrentColorLabel"
                    CurrentColorLabel.Parent = CurrentColorFrame
                    CurrentColorLabel.BackgroundTransparency = 1
                    CurrentColorLabel.Size = UDim2.new(1, 0, 1, 0)
                    CurrentColorLabel.Font = Enum.Font.Gotham
                    CurrentColorLabel.Text = "新色"
                    CurrentColorLabel.TextColor3 = Color3.new(1, 1, 1)
                    CurrentColorLabel.TextSize = 12
                    CurrentColorLabel.TextXAlignment = Enum.TextXAlignment.Center
                    CurrentColorLabel.ZIndex = 1003
                    
                    local ButtonContainer = Instance.new("Frame")
                    ButtonContainer.Name = "ButtonContainer"
                    ButtonContainer.Parent = ColorPickerPopup
                    ButtonContainer.BackgroundTransparency = 1
                    ButtonContainer.Position = UDim2.new(0, 15, 1, -40)
                    ButtonContainer.Size = UDim2.new(1, -30, 0, 30)
                    ButtonContainer.ZIndex = 1001
                    
                    local ConfirmBtn = Instance.new("TextButton")
                    ConfirmBtn.Name = "ConfirmBtn"
                    ConfirmBtn.Parent = ButtonContainer
                    ConfirmBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                    ConfirmBtn.BackgroundTransparency = 0.1
                    ConfirmBtn.BorderSizePixel = 0
                    ConfirmBtn.Position = UDim2.new(0, 0, 0, 0)
                    ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
                    ConfirmBtn.Font = Enum.Font.GothamBold
                    ConfirmBtn.Text = "确认"
                    ConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
                    ConfirmBtn.TextSize = 14
                    ConfirmBtn.AutoButtonColor = true
                    ConfirmBtn.ZIndex = 1002
                    ConfirmBtn.Modal = true
                    
                    local ConfirmCorner = Instance.new("UICorner")
                    ConfirmCorner.CornerRadius = UDim.new(0, 6)
                    ConfirmCorner.Parent = ConfirmBtn
                    
                    local CancelBtn = Instance.new("TextButton")
                    CancelBtn.Name = "CancelBtn"
                    CancelBtn.Parent = ButtonContainer
                    CancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                    CancelBtn.BackgroundTransparency = 0.1
                    CancelBtn.BorderSizePixel = 0
                    CancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
                    CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
                    CancelBtn.Font = Enum.Font.GothamBold
                    CancelBtn.Text = "取消"
                    CancelBtn.TextColor3 = Color3.new(1, 1, 1)
                    CancelBtn.TextSize = 14
                    CancelBtn.AutoButtonColor = true
                    CancelBtn.ZIndex = 1002
                    CancelBtn.Modal = true
                    
                    local CancelCorner = Instance.new("UICorner")
                    CancelCorner.CornerRadius = UDim.new(0, 6)
                    CancelCorner.Parent = CancelBtn
                    
                    local CloseClickArea = Instance.new("TextButton")
                    CloseClickArea.Name = "CloseClickArea"
                    CloseClickArea.Parent = FengYu
                    CloseClickArea.BackgroundTransparency = 1
                    CloseClickArea.BorderSizePixel = 0
                    CloseClickArea.Size = UDim2.new(1, 0, 1, 0)
                    CloseClickArea.Text = ""
                    CloseClickArea.Visible = false
                    CloseClickArea.ZIndex = 99
                    CloseClickArea.Modal = true
                    
                    local currentColor = defaultColor
                    local currentHue, currentSat, currentVib = Color3.toHSV(defaultColor)
                    
                    local function updateDisplay()
                        SatVibMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                        
                        SatCursor.Position = UDim2.new(currentSat, 0, 1 - currentVib, 0)
                        HueDrag.Position = UDim2.new(0, 0, currentHue, -7)
                        
                        currentColor = Color3.fromHSV(currentHue, currentSat, currentVib)
                        CurrentColorFrame.BackgroundColor3 = currentColor
                        ColorPreview.BackgroundColor3 = currentColor
                        
                        local oldBrightness = (OldColorFrame.BackgroundColor3.R * 0.299 + OldColorFrame.BackgroundColor3.G * 0.587 + OldColorFrame.BackgroundColor3.B * 0.114)
                        OldColorLabel.TextColor3 = oldBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                        
                        local currentBrightness = (currentColor.R * 0.299 + currentColor.G * 0.587 + currentColor.B * 0.114)
                        CurrentColorLabel.TextColor3 = currentBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                        
                        local rgb = {
                            R = math.floor(currentColor.R * 255),
                            G = math.floor(currentColor.G * 255),
                            B = math.floor(currentColor.B * 255)
                        }
                        
                        HexInput.Text = "#" .. currentColor:ToHex()
                        RInput.Text = tostring(rgb.R)
                        GInput.Text = tostring(rgb.G)
                        BInput.Text = tostring(rgb.B)
                    end
                    
                    local function setupInteraction()
                        local satVibDragging = false
                        
                        local function updateSatVib(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                satVibDragging = true
                                
                                local connection
                                connection = services.RunService.RenderStepped:Connect(function()
                                    if not satVibDragging then
                                        connection:Disconnect()
                                        return
                                    end
                                    
                                    local mouse = services.Players.LocalPlayer:GetMouse()
                                    local minX = SatVibMap.AbsolutePosition.X
                                    local maxX = minX + SatVibMap.AbsoluteSize.X
                                    local mouseX = math.clamp(mouse.X, minX, maxX)
                                    
                                    local minY = SatVibMap.AbsolutePosition.Y
                                    local maxY = minY + SatVibMap.AbsoluteSize.Y
                                    local mouseY = math.clamp(mouse.Y, minY, maxY)
                                    
                                    currentSat = (mouseX - minX) / (maxX - minX)
                                    currentVib = 1 - ((mouseY - minY) / (maxY - minY))
                                    
                                    updateDisplay()
                                end)
                                
                                services.UserInputService.InputEnded:Connect(function(endInput)
                                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                        satVibDragging = false
                                    end
                                end)
                            end
                        end
                        
                        SatVibMap.InputBegan:Connect(updateSatVib)
                        SatCursor.InputBegan:Connect(updateSatVib)
                        
                        local hueDragging = false
                        
                        local function updateHue(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                hueDragging = true
                                
                                local connection
                                connection = services.RunService.RenderStepped:Connect(function()
                                    if not hueDragging then
                                        connection:Disconnect()
                                        return
                                    end
                                    
                                    local mouse = services.Players.LocalPlayer:GetMouse()
                                    local minY = HueSlider.AbsolutePosition.Y
                                    local maxY = minY + HueSlider.AbsoluteSize.Y
                                    local mouseY = math.clamp(mouse.Y, minY, maxY)
                                    
                                    currentHue = ((mouseY - minY) / (maxY - minY))
                                    
                                    updateDisplay()
                                end)
                                
                                services.UserInputService.InputEnded:Connect(function(endInput)
                                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                        hueDragging = false
                                    end
                                end)
                            end
                        end
                        
                        HueSlider.InputBegan:Connect(updateHue)
                        HueDragHolder.InputBegan:Connect(updateHue)
                        HueDrag.InputBegan:Connect(updateHue)
                    end
                    
                    local function setupRGBInputs()
                        local function validateRGBInput(inputBox, maxValue)
                            inputBox.FocusLost:Connect(function(enterPressed)
                                local text = inputBox.Text
                                
                                if inputBox == HexInput then
                                    local hex = text:gsub("#", "")
                                    if hex:match("^[0-9A-Fa-f]+$") and #hex == 6 then
                                        local success, color = pcall(Color3.fromHex, hex)
                                        if success then
                                            currentHue, currentSat, currentVib = Color3.toHSV(color)
                                            updateDisplay()
                                            return
                                        end
                                    end
                                    inputBox.Text = "#" .. currentColor:ToHex()
                                else
                                    local num = tonumber(text)
                                    
                                    if num then
                                        num = math.clamp(num, 0, maxValue)
                                        inputBox.Text = tostring(num)
                                        
                                        local r = tonumber(RInput.Text) or 255
                                        local g = tonumber(GInput.Text) or 255
                                        local b = tonumber(BInput.Text) or 255
                                        local color = Color3.fromRGB(r, g, b)
                                        currentHue, currentSat, currentVib = Color3.toHSV(color)
                                        updateDisplay()
                                    else
                                        if inputBox == RInput then
                                            inputBox.Text = tostring(math.floor(currentColor.R * 255))
                                        elseif inputBox == GInput then
                                            inputBox.Text = tostring(math.floor(currentColor.G * 255))
                                        elseif inputBox == BInput then
                                            inputBox.Text = tostring(math.floor(currentColor.B * 255))
                                        end
                                    end
                                end
                            end)
                        end
                    
                        validateRGBInput(HexInput, 255)
                        validateRGBInput(RInput, 255)
                        validateRGBInput(GInput, 255)
                        validateRGBInput(BInput, 255)
                    end
                    
                    ColorPickerBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.Button_Color.R * 255 * 1.1),
                                math.floor(config.Button_Color.G * 255 * 1.1),
                                math.floor(config.Button_Color.B * 255 * 1.1)
                            )
                        }):Play()
                    end)
                    
                    ColorPickerBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                            BackgroundColor3 = config.Button_Color
                        }):Play()
                    end)
                    
                    ConfirmBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(ConfirmBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.05,
                            Size = UDim2.new(0.48, 2, 1.1, 0)
                        }):Play()
                    end)
                    
                    ConfirmBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(ConfirmBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.1,
                            Size = UDim2.new(0.48, 0, 1, 0)
                        }):Play()
                    end)
                    
                    CancelBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(CancelBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.05,
                            Size = UDim2.new(0.48, 2, 1.1, 0)
                        }):Play()
                    end)
                    
                    CancelBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(CancelBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.1,
                            Size = UDim2.new(0.48, 0, 1, 0)
                        }):Play()
                    end)
                    
                    updateDisplay()
                    setupInteraction()
                    setupRGBInputs()
                    
                    ColorPickerBtn.MouseButton1Click:Connect(function()
                        OldColorFrame.BackgroundColor3 = FengUI.flags[flag] or defaultColor
                        
                        ColorPickerPopup.Visible = true
                        CloseClickArea.Visible = true
                        
                        ColorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                        ColorPickerPopup.BackgroundTransparency = 0.8
                        
                        services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.1
                        }):Play()
                        
                        DigitalParticleExplosion(ColorPickerBtn)
                    end)
                    
                    ConfirmBtn.MouseButton1Click:Connect(function()
                        FengUI.flags[flag] = currentColor
                        callback(currentColor)
                        
                        services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            BackgroundTransparency = 0.8
                        }):Play()
                        
                        task.wait(0.2)
                        ColorPickerPopup.Visible = false
                        CloseClickArea.Visible = false
                    end)
                    
                    CancelBtn.MouseButton1Click:Connect(function()
                        local originalColor = FengUI.flags[flag] or defaultColor
                        currentHue, currentSat, currentVib = Color3.toHSV(originalColor)
                        currentColor = originalColor
                        updateDisplay()
                        
                        services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            BackgroundTransparency = 0.8
                        }):Play()
                        
                        task.wait(0.2)
                        ColorPickerPopup.Visible = false
                        CloseClickArea.Visible = false
                    end)
                    
                    CloseClickArea.MouseButton1Click:Connect(function()
                        CancelBtn.MouseButton1Click:Fire()
                    end)
                    
                    local funcs = {
                        SetColor = function(self, color)
                            if typeof(color) == "Color3" then
                                currentHue, currentSat, currentVib = Color3.toHSV(color)
                                currentColor = color
                                updateDisplay()
                                FengUI.flags[flag] = color
                                callback(color)
                            end
                        end,
                        
                        GetColor = function(self)
                            return FengUI.flags[flag] or defaultColor
                        end,
                        
                        Module = ColorPickerModule
                    }
                    
                    return funcs
                end
                
                -- 滑块
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
                            DigitalParticleExplosion(MinSlider)
                            local currentValue = FengUI.flags[flag]
                            currentValue = math.clamp(currentValue - 1, min, max)
                            funcs:SetValue(currentValue)
                        end)
                        
                        AddSlider.MouseButton1Click:Connect(function()
                            DigitalParticleExplosion(AddSlider)
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
                
                -- 下拉框
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
                            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36 + 28)
                        else
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
                    
                    DropdownOpen.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(DropdownOpen)
                        toggleDropdown()
                    end)
                    
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
                        Option.Visible = open
                        
                        OptionC.CornerRadius = UDim.new(0, 6)
                        OptionC.Name = "OptionC"
                        OptionC.Parent = Option
                        
                        table.insert(allOptions, Option)
                        
                        Option.MouseButton1Click:Connect(function()
                            DigitalParticleExplosion(Option)
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
                    
                    funcs:SetOptions(options)
                    
                    return funcs
                end

                return section
            end
            
            return tabObj
        end
        
        return cardObj
    end

    return window
end

-- 颜色选择器全局函数（来自UI.lua）
function FengUI:CreateColorPicker(options)
    local config = {
        title = options.title or "选择颜色",
        defaultColor = options.defaultColor or Color3.fromRGB(255, 255, 255),
        callback = options.callback or function(color) end,
        position = options.position or UDim2.new(0.5, 0, 0.5, 0),
        parent = options.parent or FengYu
    }
    
    local ColorPickerPopup = Instance.new("Frame")
    ColorPickerPopup.Name = "ColorPickerPopup"
    ColorPickerPopup.Parent = config.parent
    ColorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
    ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    ColorPickerPopup.BackgroundTransparency = 0.1
    ColorPickerPopup.BorderSizePixel = 0
    ColorPickerPopup.Position = config.position
    ColorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
    ColorPickerPopup.Visible = true
    ColorPickerPopup.ZIndex = 1000
    ColorPickerPopup.Active = true
    ColorPickerPopup.Draggable = true
    
    local PopupCorner = Instance.new("UICorner")
    PopupCorner.CornerRadius = UDim.new(0, 8)
    PopupCorner.Parent = ColorPickerPopup
    
    local PopupStroke = Instance.new("UIStroke")
    PopupStroke.Parent = ColorPickerPopup
    PopupStroke.Color = config.AccentColor or Color3.fromRGB(255, 60, 60)
    PopupStroke.Thickness = 1.5
    PopupStroke.Transparency = 0.2
    
    startNeonFlowEffect(PopupStroke, "Color", 0.01)
    
    local PopupTitle = Instance.new("TextLabel")
    PopupTitle.Name = "PopupTitle"
    PopupTitle.Parent = ColorPickerPopup
    PopupTitle.BackgroundTransparency = 1
    PopupTitle.Position = UDim2.new(0, 10, 0, 8)
    PopupTitle.Size = UDim2.new(1, -20, 0, 24)
    PopupTitle.Font = Enum.Font.GothamBold
    PopupTitle.Text = config.title
    PopupTitle.TextColor3 = config.AccentColor or Color3.fromRGB(255, 60, 60)
    PopupTitle.TextSize = 16
    PopupTitle.TextXAlignment = Enum.TextXAlignment.Center
    PopupTitle.ZIndex = 1001
    
    local SatVibMap = Instance.new("ImageLabel")
    SatVibMap.Name = "SatVibMap"
    SatVibMap.Parent = ColorPickerPopup
    SatVibMap.Size = UDim2.fromOffset(150, 140)
    SatVibMap.Position = UDim2.fromOffset(15, 40)
    SatVibMap.Image = "rbxassetid://4155801252"
    SatVibMap.BackgroundColor3 = config.defaultColor
    SatVibMap.BackgroundTransparency = 0
    SatVibMap.ZIndex = 1001
    
    local SatVibCorner = Instance.new("UICorner")
    SatVibCorner.CornerRadius = UDim.new(0, 4)
    SatVibCorner.Parent = SatVibMap
    
    local SatCursor = Instance.new("ImageLabel")
    SatCursor.Name = "SatCursor"
    SatCursor.Size = UDim2.new(0, 16, 0, 16)
    SatCursor.ScaleType = Enum.ScaleType.Fit
    SatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    SatCursor.BackgroundTransparency = 1
    SatCursor.Image = "http://www.roblox.com/asset/?id=4805639000"
    SatCursor.ZIndex = 1002
    SatCursor.Parent = SatVibMap
    
    local HueSlider = Instance.new("Frame")
    HueSlider.Name = "HueSlider"
    HueSlider.Parent = ColorPickerPopup
    HueSlider.Size = UDim2.fromOffset(14, 140)
    HueSlider.Position = UDim2.fromOffset(175, 40)
    HueSlider.ZIndex = 1001
    
    local HueSliderCorner = Instance.new("UICorner")
    HueSliderCorner.CornerRadius = UDim.new(1, 0)
    HueSliderCorner.Parent = HueSlider
    
    local SequenceTable = {}
    for Color = 0, 1, 0.1 do
        table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
    end
    
    local HueSliderGradient = Instance.new("UIGradient")
    HueSliderGradient.Color = ColorSequence.new(SequenceTable)
    HueSliderGradient.Rotation = 90
    HueSliderGradient.Parent = HueSlider
    
    local HueDragHolder = Instance.new("Frame")
    HueDragHolder.Name = "HueDragHolder"
    HueDragHolder.Size = UDim2.new(1, 0, 1, -10)
    HueDragHolder.Position = UDim2.fromOffset(0, 5)
    HueDragHolder.BackgroundTransparency = 1
    HueDragHolder.Parent = HueSlider
    HueDragHolder.ZIndex = 1002
    
    local HueDrag = Instance.new("ImageLabel")
    HueDrag.Name = "HueDrag"
    HueDrag.Size = UDim2.fromOffset(14, 14)
    HueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
    HueDrag.Parent = HueDragHolder
    HueDrag.ImageColor3 = Color3.new(1, 1, 1)
    HueDrag.ZIndex = 1003
    
    local RGBInputs = Instance.new("Frame")
    RGBInputs.Name = "RGBInputs"
    RGBInputs.Parent = ColorPickerPopup
    RGBInputs.BackgroundTransparency = 1
    RGBInputs.Position = UDim2.new(0, 200, 0, 40)
    RGBInputs.Size = UDim2.new(0, 110, 0, 140)
    RGBInputs.ZIndex = 1001
    
    local function createRGBInput(label, position, defaultValue)
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = label .. "Input"
        InputFrame.Parent = RGBInputs
        InputFrame.BackgroundTransparency = 1
        InputFrame.Position = position
        InputFrame.Size = UDim2.new(1, 0, 0, 28)
        InputFrame.ZIndex = 1002
        
        local InputLabel = Instance.new("TextLabel")
        InputLabel.Name = "Label"
        InputLabel.Parent = InputFrame
        InputLabel.BackgroundTransparency = 1
        InputLabel.Position = UDim2.new(0, 0, 0, 0)
        InputLabel.Size = UDim2.new(0, 25, 1, 0)
        InputLabel.Font = Enum.Font.GothamSemibold
        InputLabel.Text = label .. ":"
        InputLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        InputLabel.TextSize = 13
        InputLabel.TextXAlignment = Enum.TextXAlignment.Left
        InputLabel.ZIndex = 1002
        
        local InputBox = Instance.new("TextBox")
        InputBox.Name = "InputBox"
        InputBox.Parent = InputFrame
        InputBox.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
        InputBox.BackgroundTransparency = 0.1
        InputBox.BorderSizePixel = 0
        InputBox.Position = UDim2.new(0, 30, 0, 0)
        InputBox.Size = UDim2.new(0, 75, 0, 28)
        InputBox.Font = Enum.Font.Gotham
        InputBox.Text = tostring(defaultValue)
        InputBox.TextColor3 = Color3.new(1, 1, 1)
        InputBox.TextSize = 13
        InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        InputBox.ZIndex = 1002
        
        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = InputBox
        
        return InputBox
    end
    
    local RInput = createRGBInput("R", UDim2.new(0, 0, 0, 0), math.floor(config.defaultColor.R * 255))
    local GInput = createRGBInput("G", UDim2.new(0, 0, 0, 32), math.floor(config.defaultColor.G * 255))
    local BInput = createRGBInput("B", UDim2.new(0, 0, 0, 64), math.floor(config.defaultColor.B * 255))
    local HexInput = createRGBInput("Hex", UDim2.new(0, 0, 0, 96), "#" .. config.defaultColor:ToHex())
    
    local PreviewContainer = Instance.new("Frame")
    PreviewContainer.Name = "PreviewContainer"
    PreviewContainer.Parent = ColorPickerPopup
    PreviewContainer.BackgroundTransparency = 1
    PreviewContainer.Position = UDim2.new(0, 15, 0, 190)
    PreviewContainer.Size = UDim2.new(1, -30, 0, 30)
    PreviewContainer.ZIndex = 1001
    
    local OldColorFrame = Instance.new("Frame")
    OldColorFrame.Name = "OldColorFrame"
    OldColorFrame.Parent = PreviewContainer
    OldColorFrame.BackgroundColor3 = config.defaultColor
    OldColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
    OldColorFrame.Position = UDim2.new(0, 0, 0, 0)
    OldColorFrame.BackgroundTransparency = 0
    OldColorFrame.ZIndex = 1002
    
    local OldColorFrameCorner = Instance.new("UICorner")
    OldColorFrameCorner.CornerRadius = UDim.new(0, 4)
    OldColorFrameCorner.Parent = OldColorFrame
    
    local OldColorLabel = Instance.new("TextLabel")
    OldColorLabel.Name = "OldColorLabel"
    OldColorLabel.Parent = OldColorFrame
    OldColorLabel.BackgroundTransparency = 1
    OldColorLabel.Size = UDim2.new(1, 0, 1, 0)
    OldColorLabel.Font = Enum.Font.Gotham
    OldColorLabel.Text = "原色"
    OldColorLabel.TextColor3 = Color3.new(1, 1, 1)
    OldColorLabel.TextSize = 12
    OldColorLabel.TextXAlignment = Enum.TextXAlignment.Center
    OldColorLabel.ZIndex = 1003
    
    local CurrentColorFrame = Instance.new("Frame")
    CurrentColorFrame.Name = "CurrentColorFrame"
    CurrentColorFrame.Parent = PreviewContainer
    CurrentColorFrame.BackgroundColor3 = config.defaultColor
    CurrentColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
    CurrentColorFrame.Position = UDim2.new(0.52, 0, 0, 0)
    CurrentColorFrame.BackgroundTransparency = 0
    CurrentColorFrame.ZIndex = 1002
    
    local CurrentColorFrameCorner = Instance.new("UICorner")
    CurrentColorFrameCorner.CornerRadius = UDim.new(0, 4)
    CurrentColorFrameCorner.Parent = CurrentColorFrame
    
    local CurrentColorLabel = Instance.new("TextLabel")
    CurrentColorLabel.Name = "CurrentColorLabel"
    CurrentColorLabel.Parent = CurrentColorFrame
    CurrentColorLabel.BackgroundTransparency = 1
    CurrentColorLabel.Size = UDim2.new(1, 0, 1, 0)
    CurrentColorLabel.Font = Enum.Font.Gotham
    CurrentColorLabel.Text = "新色"
    CurrentColorLabel.TextColor3 = Color3.new(1, 1, 1)
    CurrentColorLabel.TextSize = 12
    CurrentColorLabel.TextXAlignment = Enum.TextXAlignment.Center
    CurrentColorLabel.ZIndex = 1003
    
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Parent = ColorPickerPopup
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Position = UDim2.new(0, 15, 1, -40)
    ButtonContainer.Size = UDim2.new(1, -30, 0, 30)
    ButtonContainer.ZIndex = 1001
    
    local ConfirmBtn = Instance.new("TextButton")
    ConfirmBtn.Name = "ConfirmBtn"
    ConfirmBtn.Parent = ButtonContainer
    ConfirmBtn.BackgroundColor3 = config.AccentColor or Color3.fromRGB(255, 60, 60)
    ConfirmBtn.BackgroundTransparency = 0.1
    ConfirmBtn.BorderSizePixel = 0
    ConfirmBtn.Position = UDim2.new(0, 0, 0, 0)
    ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
    ConfirmBtn.Font = Enum.Font.GothamBold
    ConfirmBtn.Text = "确认"
    ConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
    ConfirmBtn.TextSize = 14
    ConfirmBtn.AutoButtonColor = true
    ConfirmBtn.ZIndex = 1002
    ConfirmBtn.Modal = true
    
    local ConfirmCorner = Instance.new("UICorner")
    ConfirmCorner.CornerRadius = UDim.new(0, 6)
    ConfirmCorner.Parent = ConfirmBtn
    
    local CancelBtn = Instance.new("TextButton")
    CancelBtn.Name = "CancelBtn"
    CancelBtn.Parent = ButtonContainer
    CancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    CancelBtn.BackgroundTransparency = 0.1
    CancelBtn.BorderSizePixel = 0
    CancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
    CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
    CancelBtn.Font = Enum.Font.GothamBold
    CancelBtn.Text = "取消"
    CancelBtn.TextColor3 = Color3.new(1, 1, 1)
    CancelBtn.TextSize = 14
    CancelBtn.AutoButtonColor = true
    CancelBtn.ZIndex = 1002
    CancelBtn.Modal = true
    
    local CancelCorner = Instance.new("UICorner")
    CancelCorner.CornerRadius = UDim.new(0, 6)
    CancelCorner.Parent = CancelBtn
    
    local currentColor = config.defaultColor
    local currentHue, currentSat, currentVib = Color3.toHSV(config.defaultColor)
    
    local function updateDisplay()
        SatVibMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
        
        local cursorX = currentSat
        local cursorY = 1 - currentVib
        SatCursor.Position = UDim2.new(cursorX, -8, cursorY, -8)
        
        HueDrag.Position = UDim2.new(0, 0, currentHue, -7)
        
        currentColor = Color3.fromHSV(currentHue, currentSat, currentVib)
        CurrentColorFrame.BackgroundColor3 = currentColor
        
        local oldBrightness = (OldColorFrame.BackgroundColor3.R * 0.299 + OldColorFrame.BackgroundColor3.G * 0.587 + OldColorFrame.BackgroundColor3.B * 0.114)
        OldColorLabel.TextColor3 = oldBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        
        local currentBrightness = (currentColor.R * 0.299 + currentColor.G * 0.587 + currentColor.B * 0.114)
        CurrentColorLabel.TextColor3 = currentBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        
        local rgb = {
            R = math.floor(currentColor.R * 255),
            G = math.floor(currentColor.G * 255),
            B = math.floor(currentColor.B * 255)
        }
        
        HexInput.Text = "#" .. currentColor:ToHex()
        RInput.Text = tostring(rgb.R)
        GInput.Text = tostring(rgb.G)
        BInput.Text = tostring(rgb.B)
    end
    
    local function setupInteraction()
        local satVibDragging = false
        
        local function updateSatVib(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                satVibDragging = true
                
                local connection
                connection = services.RunService.RenderStepped:Connect(function()
                    if not satVibDragging then
                        connection:Disconnect()
                        return
                    end
                    
                    local mouse = services.Players.LocalPlayer:GetMouse()
                    local minX = SatVibMap.AbsolutePosition.X
                    local maxX = minX + SatVibMap.AbsoluteSize.X
                    local mouseX = math.clamp(mouse.X, minX, maxX)
                    
                    local minY = SatVibMap.AbsolutePosition.Y
                    local maxY = minY + SatVibMap.AbsoluteSize.Y
                    local mouseY = math.clamp(mouse.Y, minY, maxY)
                    
                    currentSat = (mouseX - minX) / (maxX - minX)
                    currentVib = 1 - ((mouseY - minY) / (maxY - minY))
                    
                    updateDisplay()
                end)
                
                services.UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        satVibDragging = false
                    end
                end)
            end
        end
        
        SatVibMap.InputBegan:Connect(updateSatVib)
        SatCursor.InputBegan:Connect(updateSatVib)
        
        local hueDragging = false
        
        local function updateHue(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                hueDragging = true
                
                local connection
                connection = services.RunService.RenderStepped:Connect(function()
                    if not hueDragging then
                        connection:Disconnect()
                        return
                    end
                    
                    local mouse = services.Players.LocalPlayer:GetMouse()
                    local minY = HueSlider.AbsolutePosition.Y
                    local maxY = minY + HueSlider.AbsoluteSize.Y
                    local mouseY = math.clamp(mouse.Y, minY, maxY)
                    
                    currentHue = ((mouseY - minY) / (maxY - minY))
                    
                    updateDisplay()
                end)
                
                services.UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        hueDragging = false
                    end
                end)
            end
        end
        
        HueSlider.InputBegan:Connect(updateHue)
        HueDragHolder.InputBegan:Connect(updateHue)
        HueDrag.InputBegan:Connect(updateHue)
    end
    
    local function setupRGBInputs()
        local function validateRGBInput(inputBox, maxValue)
            inputBox.FocusLost:Connect(function(enterPressed)
                local text = inputBox.Text
                
                if inputBox == HexInput then
                    local hex = text:gsub("#", "")
                    if hex:match("^[0-9A-Fa-f]+$") and #hex == 6 then
                        local success, color = pcall(Color3.fromHex, hex)
                        if success then
                            currentHue, currentSat, currentVib = Color3.toHSV(color)
                            updateDisplay()
                            return
                        end
                    end
                    inputBox.Text = "#" .. currentColor:ToHex()
                else
                    local num = tonumber(text)
                    
                    if num then
                        num = math.clamp(num, 0, maxValue)
                        inputBox.Text = tostring(num)
                        
                        local r = tonumber(RInput.Text) or 255
                        local g = tonumber(GInput.Text) or 255
                        local b = tonumber(BInput.Text) or 255
                        local color = Color3.fromRGB(r, g, b)
                        currentHue, currentSat, currentVib = Color3.toHSV(color)
                        updateDisplay()
                    else
                        if inputBox == RInput then
                            inputBox.Text = tostring(math.floor(currentColor.R * 255))
                        elseif inputBox == GInput then
                            inputBox.Text = tostring(math.floor(currentColor.G * 255))
                        elseif inputBox == BInput then
                            inputBox.Text = tostring(math.floor(currentColor.B * 255))
                        end
                    end
                end
            end)
        end
    
        validateRGBInput(HexInput, 255)
        validateRGBInput(RInput, 255)
        validateRGBInput(GInput, 255)
        validateRGBInput(BInput, 255)
    end
    
    updateDisplay()
    setupInteraction()
    setupRGBInputs()
    
    local colorPickerObj = {
        Instance = ColorPickerPopup,
        CurrentColor = currentColor,
        Closed = false
    }
    
    local pickerId = #FengUI.ColorPickers + 1
    FengUI.ColorPickers[pickerId] = colorPickerObj
    
    local function closePicker(saveColor)
        if colorPickerObj.Closed then return end
        
        colorPickerObj.Closed = true
        
        services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 0.8,
            Size = UDim2.new(0, 10, 0, 10)
        }):Play()
        
        task.wait(0.2)
        
        if saveColor then
            config.callback(currentColor)
        end
        
        ColorPickerPopup:Destroy()
        FengUI.ColorPickers[pickerId] = nil
    end
    
    ConfirmBtn.MouseButton1Click:Connect(function()
        closePicker(true)
    end)
    
    CancelBtn.MouseButton1Click:Connect(function()
        closePicker(false)
    end)
    
    local ClosePickerBtn = Instance.new("TextButton")
    ClosePickerBtn.Name = "ClosePickerBtn"
    ClosePickerBtn.Parent = ColorPickerPopup
    ClosePickerBtn.BackgroundTransparency = 1
    ClosePickerBtn.BorderSizePixel = 0
    ClosePickerBtn.Position = UDim2.new(1, -25, 0, 5)
    ClosePickerBtn.Size = UDim2.new(0, 20, 0, 20)
    ClosePickerBtn.Font = Enum.Font.GothamBold
    ClosePickerBtn.Text = "X"
    ClosePickerBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
    ClosePickerBtn.TextSize = 16
    ClosePickerBtn.ZIndex = 1002
    
    ClosePickerBtn.MouseButton1Click:Connect(function()
        closePicker(false)
    end)
    
    return colorPickerObj
end

function FengUI:ColorPicker(options)
    return self:CreateColorPicker(options)
end

function FengUI:PickColor(title, defaultColor)
    defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
    
    local colorSelected = false
    local selectedColor = defaultColor
    
    local picker = self:CreateColorPicker({
        title = title or "选择颜色",
        defaultColor = defaultColor,
        callback = function(color)
            selectedColor = color
            colorSelected = true
        end,
        position = UDim2.new(0.5, 0, 0.4, 0)
    })
    
    while not picker.Closed do
        task.wait()
    end
    
    return selectedColor
end

function FengUI:BindColorPicker(button, options)
    local currentColor = options.defaultColor or Color3.fromRGB(255, 255, 255)
    
    local previewFrame = Instance.new("Frame")
    previewFrame.Name = "ColorPreview"
    previewFrame.Parent = button
    previewFrame.BackgroundColor3 = currentColor
    previewFrame.BorderSizePixel = 0
    previewFrame.Position = UDim2.new(0.8, 0, 0.2, 0)
    previewFrame.Size = UDim2.new(0, 40, 0, 22)
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = previewFrame
    
    button.MouseButton1Click:Connect(function()
        local picker = FengUI:CreateColorPicker({
            title = options.title or "选择颜色",
            defaultColor = currentColor,
            callback = function(color)
                currentColor = color
                previewFrame.BackgroundColor3 = color
                if options.callback then
                    options.callback(color)
                end
            end,
            position = UDim2.new(0.5, 0, 0.5, 0)
        })
    end)
    
    return {
        GetColor = function()
            return currentColor
        end,
        SetColor = function(color)
            currentColor = color
            previewFrame.BackgroundColor3 = color
            if options.callback then
                options.callback(color)
            end
        end
    }
end

function FengUI:CloseAllColorPickers()
    for _, picker in pairs(FengUI.ColorPickers) do
        if picker.Instance and picker.Instance.Parent then
            picker.Instance:Destroy()
        end
    end
    FengUI.ColorPickers = {}
end

-- 其他函数
function UiDestroy()
    if FengYu then
        FengYu:Destroy()
    end
    FengUI:CloseAllColorPickers()
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    Main.Visible = not ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI