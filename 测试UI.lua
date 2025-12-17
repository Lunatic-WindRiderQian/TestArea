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
        explosionCenter.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
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
        centerGlow.Color = Color3.fromRGB(0, 255, 255)
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
                math.random(150, 255),
                math.random(150, 255),
                math.random(200, 255)
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
        shockwaveStroke.Color = Color3.fromRGB(0, 200, 255)
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
    
    if old[1].AbsolutePosition and new[1].AbsolutePosition then
        createParticleTrail(
            UDim2.new(0, old[1].AbsolutePosition.X, 0, old[1].AbsolutePosition.Y),
            UDim2.new(0, new[1].AbsolutePosition.X, 0, new[1].AbsolutePosition.Y),
            old[1].Parent
        )
    end
    
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

local MainTabContainer = Instance.new("Frame")
MainTabContainer.Name = "MainTabContainer"
MainTabContainer.Parent = Main
MainTabContainer.BackgroundTransparency = 1
MainTabContainer.Position = UDim2.new(0.2, 0, 0, 37)
MainTabContainer.Size = UDim2.new(0, 360, 0, 243)
MainTabContainer.Visible = false

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

createHologramEffect(MainSideContainer, 0.3)

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
        
        createHologramEffect(sideContainer, 0.3)
        
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
        
        function cardObj.Tab(cardObj, tabName, tabIcon)
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
            
            local TabL = Instance.new("UIListLayout")
            TabL.Name = "TabL"
            TabL.Parent = Tab
            TabL.SortOrder = Enum.SortOrder.LayoutOrder
            TabL.Padding = UDim.new(0, 4)
            
            setupSmoothScrolling(Tab, TabL)
            
            TabBtn.MouseButton1Click:Connect(function()
                DigitalParticleExplosion(TabBtn)
                switchTab({ TabIco, Tab })
            end)
            
            if FengUI.currentTab == nil then
                switchTab({ TabIco, Tab })
            end
            
            TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
                
                Tab.ScrollingEnabled = TabL.AbsoluteContentSize.Y > Tab.AbsoluteSize.Y
                Tab.ElasticBehavior = Enum.ElasticBehavior.Never
            end)
            
            local tabObj = {}
            
            function tabObj.section(tabObj, name, TabVal)
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
                Section.Size = UDim2.new(0.95, 0, 0, 36)
                
                SectionC.CornerRadius = UDim.new(0, 6)
                SectionC.Name = "SectionC"
                SectionC.Parent = Section
                
                SectionText.Name = "SectionText"
                SectionText.Parent = Section
                SectionText.BackgroundTransparency = 1
                SectionText.Position = UDim2.new(0.088, 0, 0, 0)
                SectionText.Size = UDim2.new(0, 320, 0, 36)
                SectionText.Font = Enum.Font.GothamSemibold
                SectionText.Text = name
                SectionText.TextColor3 = config.TextColor
                SectionText.TextSize = 16
                SectionText.TextXAlignment = Enum.TextXAlignment.Left
                
                SectionOpen.Name = "SectionOpen"
                SectionOpen.Parent = SectionText
                SectionOpen.BackgroundTransparency = 1
                SectionOpen.BorderSizePixel = 0
                SectionOpen.Position = UDim2.new(0, -26, 0, 6)
                SectionOpen.Size = UDim2.new(0, 22, 0, 22)
                SectionOpen.Image = "rbxassetid://84830962019412"
                SectionOpen.ImageColor3 = config.SecondaryTextColor
                
                SectionOpened.Name = "SectionOpened"
                SectionOpened.Parent = SectionOpen
                SectionOpened.BackgroundTransparency = 1
                SectionOpened.BorderSizePixel = 0
                SectionOpened.Size = UDim2.new(0, 22, 0, 22)
                SectionOpened.Image = "rbxassetid://84830962019412"
                SectionOpened.ImageColor3 = config.AccentColor
                SectionOpened.ImageTransparency = 1
                
                SectionToggle.Name = "SectionToggle"
                SectionToggle.Parent = SectionOpen
                SectionToggle.BackgroundTransparency = 1
                SectionToggle.BorderSizePixel = 0
                SectionToggle.Size = UDim2.new(0, 22, 0, 22)
                
                Objs.Name = "Objs"
                Objs.Parent = Section
                Objs.BackgroundTransparency = 1
                Objs.BorderSizePixel = 0
                Objs.Position = UDim2.new(0, 6, 0, 36)
                Objs.Size = UDim2.new(0.98, 0, 0, 0)
                
                ObjsL.Name = "ObjsL"
                ObjsL.Parent = Objs
                ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
                ObjsL.Padding = UDim.new(0, 6)
                
                local open = TabVal ~= false
                if TabVal ~= false then
                    Section.Size = UDim2.new(0.95, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 6 or 36)
                    SectionOpened.ImageTransparency = open and 0 or 1
                    SectionOpen.ImageTransparency = open and 1 or 0
                end
                
                SectionToggle.MouseButton1Click:Connect(function()
                    open = not open
                    services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0.95, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 6 or 36)
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
                    if not open then return end
                    Section.Size = UDim2.new(0.95, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 6)
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
                    BtnModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    Btn.Name = "Btn"
                    Btn.Parent = BtnModule
                    Btn.BackgroundColor3 = config.Button_Color
                    Btn.BackgroundTransparency = 0.2
                    Btn.BorderSizePixel = 0
                    Btn.Size = UDim2.new(0, 330, 0, 36)
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
    ImageModule.Size = UDim2.new(0, 330, 0, sizeY or 120)
    
    ImageLabel.Parent = ImageModule
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.BorderSizePixel = 0
    ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
    ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
    ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, 320), 0, sizeY or 120)
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
                    LabelModule.Size = UDim2.new(0, 330, 0, 24)
                    
                    TextLabel.Parent = LabelModule
                    TextLabel.BackgroundColor3 = config.Label_Color
                    TextLabel.BackgroundTransparency = 0.2
                    TextLabel.Size = UDim2.new(0, 330, 0, 28)
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
                    ToggleModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    ToggleBtn.Name = "ToggleBtn"
                    ToggleBtn.Parent = ToggleModule
                    ToggleBtn.BackgroundColor3 = config.Toggle_Color
                    ToggleBtn.BackgroundTransparency = 0.2
                    ToggleBtn.BorderSizePixel = 0
                    ToggleBtn.Size = UDim2.new(0, 330, 0, 36)
                    ToggleBtn.AutoButtonColor = false
                    ToggleBtn.Font = Enum.Font.GothamSemibold
                    ToggleBtn.Text = "   " .. text
                    ToggleBtn.TextColor3 = config.TextColor
                    ToggleBtn.TextSize = 14
                    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    ToggleBtnC.CornerRadius = UDim.new(0, 6)
                    ToggleBtnC.Name = "ToggleBtnC"
                    ToggleBtnC.Parent = ToggleBtn
                    
                    ToggleDisable.Name = "ToggleDisable"
                    ToggleDisable.Parent = ToggleBtn
                    ToggleDisable.BackgroundColor3 = config.Bg_Color
                    ToggleDisable.BorderSizePixel = 0
                    ToggleDisable.Position = UDim2.new(0.85, 0, 0.22, 0)
                    ToggleDisable.Size = UDim2.new(0, 34, 0, 18)
                    
                    ToggleSwitch.Name = "ToggleSwitch"
                    ToggleSwitch.Parent = ToggleDisable
                    ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                    ToggleSwitch.Size = UDim2.new(0, 20, 0, 18)
                    ToggleSwitch.Position = UDim2.new(0, enabled and 14 or 0, 0, 0)
                    
                    ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                    ToggleSwitchC.Name = "ToggleSwitchC"
                    ToggleSwitchC.Parent = ToggleSwitch
                    
                    ToggleDisableC.CornerRadius = UDim.new(0, 6)
                    ToggleDisableC.Name = "ToggleDisableC"
                    ToggleDisableC.Parent = ToggleDisable
                    
                    if enabled then
                        createHologramEffect(ToggleSwitch, 0.8)
                    end
                    
                    ToggleBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.Toggle_Color.R * 255 * 1.1),
                                math.floor(config.Toggle_Color.G * 255 * 1.1),
                                math.floor(config.Toggle_Color.B * 255 * 1.1)
                            )
                        }):Play()
                    end)
                    
                    ToggleBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
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
                            
                            if state then
                                createHologramEffect(ToggleSwitch, 0.8)
                            else
                                local hologram = ToggleSwitch:FindFirstChild("HologramEffect")
                                if hologram then
                                    hologram:Destroy()
                                end
                            end
                            
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
                    KeybindModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    KeybindBtn.Name = "KeybindBtn"
                    KeybindBtn.Parent = KeybindModule
                    KeybindBtn.BackgroundColor3 = config.Keybind_Color
                    KeybindBtn.BackgroundTransparency = 0.2
                    KeybindBtn.BorderSizePixel = 0
                    KeybindBtn.Size = UDim2.new(0, 330, 0, 36)
                    KeybindBtn.AutoButtonColor = false
                    KeybindBtn.Font = Enum.Font.GothamSemibold
                    KeybindBtn.Text = "   " .. text
                    KeybindBtn.TextColor3 = config.TextColor
                    KeybindBtn.TextSize = 14
                    KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    KeybindBtnC.CornerRadius = UDim.new(0, 6)
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
                    TextboxModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    TextboxBack.Name = "TextboxBack"
                    TextboxBack.Parent = TextboxModule
                    TextboxBack.BackgroundColor3 = config.Textbox_Color
                    TextboxBack.BackgroundTransparency = 0.2
                    TextboxBack.BorderSizePixel = 0
                    TextboxBack.Size = UDim2.new(0, 330, 0, 36)
                    TextboxBack.AutoButtonColor = false
                    TextboxBack.Font = Enum.Font.GothamSemibold
                    TextboxBack.Text = "   " .. text
                    TextboxBack.TextColor3 = config.TextColor
                    TextboxBack.TextSize = 14
                    TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                    
                    TextboxBackC.CornerRadius = UDim.new(0, 6)
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
                    SliderModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    SliderBack.Name = "SliderBack"
                    SliderBack.Parent = SliderModule
                    SliderBack.BackgroundColor3 = config.Slider_Color
                    SliderBack.BackgroundTransparency = 0.2
                    SliderBack.BorderSizePixel = 0
                    SliderBack.Size = UDim2.new(0, 330, 0, 36)
                    SliderBack.AutoButtonColor = false
                    SliderBack.Font = Enum.Font.GothamSemibold
                    SliderBack.Text = "   " .. text
                    SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderBack.TextSize = 14.000
                    SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                    
                    SliderBackC.CornerRadius = UDim.new(0, 6)
                    SliderBackC.Name = "SliderBackC"
                    SliderBackC.Parent = SliderBack
                    
                    SliderBar.Name = "SliderBar"
                    SliderBar.Parent = SliderBack
                    SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    SliderBar.BorderSizePixel = 0
                    SliderBar.Position = UDim2.new(0.35, 0, 0.5, 0)
                    SliderBar.Size = UDim2.new(0, 120, 0, 14)
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
                    SliderValBG.Position = UDim2.new(0.82, 0, 0.22, 0)
                    SliderValBG.Size = UDim2.new(0, 36, 0, 22)
                    SliderValBG.AutoButtonColor = false
                    SliderValBG.Font = Enum.Font.Gotham
                    SliderValBG.Text = ""
                    SliderValBG.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderValBG.TextSize = 14.000
                    
                    SliderValBGC.CornerRadius = UDim.new(0, 6)
                    SliderValBGC.Name = "SliderValBGC"
                    SliderValBGC.Parent = SliderValBG
                    
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
                    
                    local MinSlider = Instance.new("TextButton")
                    MinSlider.Name = "MinSlider"
                    MinSlider.Parent = SliderBack
                    MinSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    MinSlider.BackgroundTransparency = 0
                    MinSlider.BorderSizePixel = 0
                    MinSlider.Position = UDim2.new(0.28, 0, 0.25, 0)
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
                    AddSlider.Position = UDim2.new(0.75, 0, 0.25, 0)
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
                            
                            DigitalParticleExplosion(SliderPart)
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
                    DropdownModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    DropdownTop.Name = "DropdownTop"
                    DropdownTop.Parent = DropdownModule
                    DropdownTop.BackgroundColor3 = config.Dropdown_Color
                    DropdownTop.BackgroundTransparency = 0.2
                    DropdownTop.BorderSizePixel = 0
                    DropdownTop.Size = UDim2.new(0, 330, 0, 36)
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
                    
                    DropdownOpenFrame.Name = "DropdownOpenFrame"
                    DropdownOpenFrame.Parent = DropdownTop
                    DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
                    DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
                    DropdownOpenFrame.BorderSizePixel = 0
                    DropdownOpenFrame.Position = UDim2.new(0.80, 0, 0.5, 0)
                    DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)
                    DropdownOpenFrame.ZIndex = 2
                    
                    createHologramEffect(DropdownOpenFrame, 0.8)
                    
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
                    Separator.Position = UDim2.new(0.74, 0, 0.2, 0)
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
                        
                        DropdownModule.Size = UDim2.new(0, 330, 0, open and (36 + DropdownModuleL.AbsoluteContentSize.Y + 4) or 36)
                        
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
                            DropdownModule.Size = UDim2.new(0, 330, 0, 36 + DropdownModuleL.AbsoluteContentSize.Y + 4)
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
                        Option.Size = UDim2.new(0, 310, 0, 24)
                        Option.AutoButtonColor = false
                        Option.Font = Enum.Font.Gotham
                        Option.Text = option
                        Option.TextColor3 = config.TextColor
                        Option.TextSize = 13.000
                        OptionC.CornerRadius = UDim.new(0, 6)
                        OptionC.Name = "OptionC"
                        OptionC.Parent = Option
                        
                        Option.MouseButton1Click:Connect(function()
                            DigitalParticleExplosion(Option)
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
                
function section.ColorPicker(section, text, flag, default, callback)
    callback = callback or function() end
    default = default or Color3.fromRGB(255, 255, 255)
    assert(text, "No text provided")
    assert(flag, "No flag provided")
    FengUI.flags[flag] = default
    
    local ColorPickerModule = Instance.new("Frame")
    local ColorPickerTop = Instance.new("TextButton")
    local ColorPickerTopC = Instance.new("UICorner")
    local ColorPickerPreview = Instance.new("Frame")
    local ColorPickerPreviewC = Instance.new("UICorner")
    local ColorPickerButton = Instance.new("TextButton")
    local ColorPickerText = Instance.new("TextLabel")
    
    ColorPickerModule.Name = "ColorPickerModule"
    ColorPickerModule.Parent = Objs
    ColorPickerModule.BackgroundTransparency = 1
    ColorPickerModule.BorderSizePixel = 0
    ColorPickerModule.Size = UDim2.new(0, 330, 0, 36)
    
    ColorPickerTop.Name = "ColorPickerTop"
    ColorPickerTop.Parent = ColorPickerModule
    ColorPickerTop.BackgroundColor3 = config.Dropdown_Color
    ColorPickerTop.BackgroundTransparency = 0.2
    ColorPickerTop.BorderSizePixel = 0
    ColorPickerTop.Size = UDim2.new(0, 330, 0, 36)
    ColorPickerTop.AutoButtonColor = false
    ColorPickerTop.Font = Enum.Font.GothamSemibold
    ColorPickerTop.Text = "   " .. text
    ColorPickerTop.TextColor3 = config.TextColor
    ColorPickerTop.TextSize = 14
    ColorPickerTop.TextXAlignment = Enum.TextXAlignment.Left
    
    ColorPickerTopC.CornerRadius = UDim.new(0, 6)
    ColorPickerTopC.Name = "ColorPickerTopC"
    ColorPickerTopC.Parent = ColorPickerTop
    
    ColorPickerPreview.Name = "ColorPickerPreview"
    ColorPickerPreview.Parent = ColorPickerTop
    ColorPickerPreview.BackgroundColor3 = default
    ColorPickerPreview.BorderSizePixel = 0
    ColorPickerPreview.Position = UDim2.new(0.82, 0, 0.22, 0)
    ColorPickerPreview.Size = UDim2.new(0, 22, 0, 22)
    
    ColorPickerPreviewC.CornerRadius = UDim.new(0, 4)
    ColorPickerPreviewC.Name = "ColorPickerPreviewC"
    ColorPickerPreviewC.Parent = ColorPickerPreview
    
    local previewGlow = Instance.new("UIStroke")
    previewGlow.Parent = ColorPickerPreview
    previewGlow.Color = Color3.new(1, 1, 1)
    previewGlow.Thickness = 1
    previewGlow.Transparency = 0.5
    
    ColorPickerButton.Name = "ColorPickerButton"
    ColorPickerButton.Parent = ColorPickerTop
    ColorPickerButton.BackgroundTransparency = 1
    ColorPickerButton.BorderSizePixel = 0
    ColorPickerButton.Position = ColorPickerPreview.Position
    ColorPickerButton.Size = ColorPickerPreview.Size
    ColorPickerButton.AutoButtonColor = false
    ColorPickerButton.Font = Enum.Font.Gotham
    ColorPickerButton.Text = ""
    ColorPickerButton.ZIndex = 10
    
    ColorPickerText.Name = "ColorPickerText"
    ColorPickerText.Parent = ColorPickerTop
    ColorPickerText.BackgroundTransparency = 1
    ColorPickerText.Position = UDim2.new(0.65, 0, 0, 0)
    ColorPickerText.Size = UDim2.new(0, 50, 0, 36)
    ColorPickerText.Font = Enum.Font.GothamSemibold
    ColorPickerText.Text = string.format("#%02X%02X%02X", 
        math.floor(default.R * 255), 
        math.floor(default.G * 255), 
        math.floor(default.B * 255))
    ColorPickerText.TextColor3 = config.SecondaryTextColor
    ColorPickerText.TextSize = 12
    ColorPickerText.TextXAlignment = Enum.TextXAlignment.Right
    
    -- 颜色选择器窗口（初始隐藏）- 直接放在ScreenGui下
    local ColorPickerWindow = Instance.new("Frame")
    ColorPickerWindow.Name = "ColorPickerWindow_" .. flag
    ColorPickerWindow.Parent = FengYu  -- 直接放在ScreenGui下
    ColorPickerWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    ColorPickerWindow.BackgroundTransparency = 0.05
    ColorPickerWindow.BorderSizePixel = 0
    ColorPickerWindow.Size = UDim2.new(0, 300, 0, 220)
    ColorPickerWindow.Visible = false
    ColorPickerWindow.ZIndex = 9999  -- 设置很高的ZIndex确保在最前
    ColorPickerWindow.Active = false
    ColorPickerWindow.Draggable = false
    
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 8)
    WindowCorner.Parent = ColorPickerWindow
    
    local WindowStroke = Instance.new("UIStroke")
    WindowStroke.Parent = ColorPickerWindow
    WindowStroke.Color = config.AccentColor
    WindowStroke.Thickness = 2
    WindowStroke.Transparency = 0.3
    
    -- 标题区域
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = ColorPickerWindow
    TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.ZIndex = 10000
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8, 0, 0)
    TitleBarCorner.Parent = TitleBar
    
    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = TitleBar
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Position = UDim2.new(0, 10, 0, 0)
    WindowTitle.Size = UDim2.new(1, -20, 1, 0)
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = text .. " - 颜色选择器"
    WindowTitle.TextColor3 = config.AccentColor
    WindowTitle.TextSize = 14
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.ZIndex = 10001
    
    -- 颜色选择区域
    local ColorCanvas = Instance.new("Frame")
    ColorCanvas.Name = "ColorCanvas"
    ColorCanvas.Parent = ColorPickerWindow
    ColorCanvas.BackgroundColor3 = Color3.new(1, 1, 1)
    ColorCanvas.BorderSizePixel = 0
    ColorCanvas.Position = UDim2.new(0, 10, 0, 40)
    ColorCanvas.Size = UDim2.new(0, 180, 0, 120)
    ColorCanvas.ZIndex = 10000
    ColorCanvas.Active = true  -- 确保触摸输入
    
    local ColorCanvasCorner = Instance.new("UICorner")
    ColorCanvasCorner.CornerRadius = UDim.new(0, 4)
    ColorCanvasCorner.Parent = ColorCanvas
    
    -- 创建颜色渐变（色相）
    local HueGradient = Instance.new("UIGradient")
    HueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    HueGradient.Parent = ColorCanvas
    
    -- 创建亮度渐变（从上到下，从白色到黑色）
    local ValueGradient = Instance.new("UIGradient")
    ValueGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    ValueGradient.Parent = ColorCanvas
    
    -- 饱和度渐变（从左到右，从透明到不透明）
    local SaturationGradient = Instance.new("UIGradient")
    SaturationGradient.Rotation = 90
    SaturationGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    SaturationGradient.Parent = ColorCanvas
    
    -- 选择器指示器
    local Selector = Instance.new("Frame")
    Selector.Name = "Selector"
    Selector.Parent = ColorCanvas
    Selector.BackgroundColor3 = Color3.new(1, 1, 1)
    Selector.BackgroundTransparency = 1
    Selector.BorderSizePixel = 0
    Selector.Size = UDim2.new(0, 8, 0, 8)
    Selector.AnchorPoint = Vector2.new(0.5, 0.5)
    Selector.ZIndex = 10001
    
    local SelectorCorner = Instance.new("UICorner")
    SelectorCorner.CornerRadius = UDim.new(1, 0)
    SelectorCorner.Parent = Selector
    
    local SelectorStroke = Instance.new("UIStroke")
    SelectorStroke.Parent = Selector
    SelectorStroke.Color = Color3.new(0, 0, 0)
    SelectorStroke.Thickness = 2
    
    -- 色相选择条
    local HueSlider = Instance.new("Frame")
    HueSlider.Name = "HueSlider"
    HueSlider.Parent = ColorPickerWindow
    HueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    HueSlider.BorderSizePixel = 0
    HueSlider.Position = UDim2.new(0, 195, 0, 40)
    HueSlider.Size = UDim2.new(0, 15, 0, 120)
    HueSlider.ZIndex = 10000
    HueSlider.Active = true  -- 确保触摸输入
    
    local HueSliderCorner = Instance.new("UICorner")
    HueSliderCorner.CornerRadius = UDim.new(0, 4)
    HueSliderCorner.Parent = HueSlider
    
    local HueGradientSlider = Instance.new("UIGradient")
    HueGradientSlider.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    HueGradientSlider.Parent = HueSlider
    
    -- 色相选择指示器
    local HueSelector = Instance.new("Frame")
    HueSelector.Name = "HueSelector"
    HueSelector.Parent = HueSlider
    HueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
    HueSelector.BackgroundTransparency = 1
    HueSelector.BorderSizePixel = 0
    HueSelector.Size = UDim2.new(2, 0, 0, 3)
    HueSelector.AnchorPoint = Vector2.new(0.5, 0.5)
    HueSelector.ZIndex = 10001
    HueSelector.Position = UDim2.new(0.5, 0, 0, 0)
    
    local HueSelectorCorner = Instance.new("UICorner")
    HueSelectorCorner.CornerRadius = UDim.new(0, 2)
    HueSelectorCorner.Parent = HueSelector
    
    local HueSelectorStroke = Instance.new("UIStroke")
    HueSelectorStroke.Parent = HueSelector
    HueSelectorStroke.Color = Color3.new(1, 1, 1)
    HueSelectorStroke.Thickness = 1
    
    -- 当前颜色预览
    local CurrentColorPreview = Instance.new("Frame")
    CurrentColorPreview.Name = "CurrentColorPreview"
    CurrentColorPreview.Parent = ColorPickerWindow
    CurrentColorPreview.BackgroundColor3 = default
    CurrentColorPreview.BorderSizePixel = 0
    CurrentColorPreview.Position = UDim2.new(0, 220, 0, 40)
    CurrentColorPreview.Size = UDim2.new(0, 70, 0, 40)
    CurrentColorPreview.ZIndex = 10000
    
    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 4)
    PreviewCorner.Parent = CurrentColorPreview
    
    local PreviewStroke = Instance.new("UIStroke")
    PreviewStroke.Parent = CurrentColorPreview
    PreviewStroke.Color = Color3.new(1, 1, 1)
    PreviewStroke.Thickness = 2
    PreviewStroke.Transparency = 0.3
    
    -- RGB输入框
    local RInput = Instance.new("TextBox")
    RInput.Name = "RInput"
    RInput.Parent = ColorPickerWindow
    RInput.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    RInput.BackgroundTransparency = 0.2
    RInput.BorderSizePixel = 0
    RInput.Position = UDim2.new(0, 220, 0, 90)
    RInput.Size = UDim2.new(0, 70, 0, 22)
    RInput.Font = Enum.Font.Gotham
    RInput.Text = tostring(math.floor(default.R * 255))
    RInput.TextColor3 = Color3.new(1, 1, 1)
    RInput.TextSize = 12
    RInput.PlaceholderText = "R"
    RInput.ZIndex = 10000
    
    local RCorner = Instance.new("UICorner")
    RCorner.CornerRadius = UDim.new(0, 4)
    RCorner.Parent = RInput
    
    local GInput = Instance.new("TextBox")
    GInput.Name = "GInput"
    GInput.Parent = ColorPickerWindow
    GInput.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    GInput.BackgroundTransparency = 0.2
    GInput.BorderSizePixel = 0
    GInput.Position = UDim2.new(0, 220, 0, 117)
    GInput.Size = UDim2.new(0, 70, 0, 22)
    GInput.Font = Enum.Font.Gotham
    GInput.Text = tostring(math.floor(default.G * 255))
    GInput.TextColor3 = Color3.new(1, 1, 1)
    GInput.TextSize = 12
    GInput.PlaceholderText = "G"
    GInput.ZIndex = 10000
    
    local GCorner = Instance.new("UICorner")
    GCorner.CornerRadius = UDim.new(0, 4)
    GCorner.Parent = GInput
    
    local BInput = Instance.new("TextBox")
    BInput.Name = "BInput"
    BInput.Parent = ColorPickerWindow
    BInput.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    BInput.BackgroundTransparency = 0.2
    BInput.BorderSizePixel = 0
    BInput.Position = UDim2.new(0, 220, 0, 144)
    BInput.Size = UDim2.new(0, 70, 0, 22)
    BInput.Font = Enum.Font.Gotham
    BInput.Text = tostring(math.floor(default.B * 255))
    BInput.TextColor3 = Color3.new(1, 1, 1)
    BInput.TextSize = 12
    BInput.PlaceholderText = "B"
    BInput.ZIndex = 10000
    
    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 4)
    BCorner.Parent = BInput
    
    -- HEX输入框
    local HexInput = Instance.new("TextBox")
    HexInput.Name = "HexInput"
    HexInput.Parent = ColorPickerWindow
    HexInput.BackgroundColor3 = Color3.fromRGB(60, 60, 85)
    HexInput.BackgroundTransparency = 0.2
    HexInput.BorderSizePixel = 0
    HexInput.Position = UDim2.new(0, 10, 0, 170)
    HexInput.Size = UDim2.new(0, 135, 0, 22)
    HexInput.Font = Enum.Font.Gotham
    HexInput.Text = string.format("#%02X%02X%02X", 
        math.floor(default.R * 255), 
        math.floor(default.G * 255), 
        math.floor(default.B * 255))
    HexInput.TextColor3 = Color3.new(1, 1, 1)
    HexInput.TextSize = 12
    HexInput.PlaceholderText = "HEX颜色码"
    HexInput.ZIndex = 10000
    
    local HexCorner = Instance.new("UICorner")
    HexCorner.CornerRadius = UDim.new(0, 4)
    HexCorner.Parent = HexInput
    
    -- 确认按钮
    local ConfirmButton = Instance.new("TextButton")
    ConfirmButton.Name = "ConfirmButton"
    ConfirmButton.Parent = ColorPickerWindow
    ConfirmButton.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
    ConfirmButton.BackgroundTransparency = 0.2
    ConfirmButton.BorderSizePixel = 0
    ConfirmButton.Position = UDim2.new(0, 155, 0, 170)
    ConfirmButton.Size = UDim2.new(0, 60, 0, 22)
    ConfirmButton.Font = Enum.Font.GothamSemibold
    ConfirmButton.Text = "应用"
    ConfirmButton.TextColor3 = Color3.new(1, 1, 1)
    ConfirmButton.TextSize = 12
    ConfirmButton.ZIndex = 10000
    
    local ConfirmCorner = Instance.new("UICorner")
    ConfirmCorner.CornerRadius = UDim.new(0, 4)
    ConfirmCorner.Parent = ConfirmButton
    
    -- 取消按钮
    local CancelButton = Instance.new("TextButton")
    CancelButton.Name = "CancelButton"
    CancelButton.Parent = ColorPickerWindow
    CancelButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    CancelButton.BackgroundTransparency = 0.2
    CancelButton.BorderSizePixel = 0
    CancelButton.Position = UDim2.new(0, 220, 0, 170)
    CancelButton.Size = UDim2.new(0, 70, 0, 22)
    CancelButton.Font = Enum.Font.GothamSemibold
    CancelButton.Text = "取消"
    CancelButton.TextColor3 = Color3.new(1, 1, 1)
    CancelButton.TextSize = 12
    CancelButton.ZIndex = 10000
    
    local CancelCorner = Instance.new("UICorner")
    CancelCorner.CornerRadius = UDim.new(0, 4)
    CancelCorner.Parent = CancelButton
    
    -- 初始选择器位置
    local currentHue, currentSaturation, currentValue = default:ToHSV()
    Selector.Position = UDim2.new(currentSaturation, 0, 1 - currentValue, 0)
    HueSelector.Position = UDim2.new(0.5, 0, currentHue, 0)
    
    -- 更新预览颜色
    local function updatePreviewColor(color)
        CurrentColorPreview.BackgroundColor3 = color
        ColorPickerPreview.BackgroundColor3 = color
        ColorPickerText.Text = string.format("#%02X%02X%02X", 
            math.floor(color.R * 255), 
            math.floor(color.G * 255), 
            math.floor(color.B * 255))
        RInput.Text = tostring(math.floor(color.R * 255))
        GInput.Text = tostring(math.floor(color.G * 255))
        BInput.Text = tostring(math.floor(color.B * 255))
        HexInput.Text = string.format("#%02X%02X%02X", 
            math.floor(color.R * 255), 
            math.floor(color.G * 255), 
            math.floor(color.B * 255))
    end
    
    -- 从HSV更新颜色
    local function updateColorFromHSV(h, s, v)
        local color = Color3.fromHSV(h, s, v)
        updatePreviewColor(color)
        return color
    end
    
    -- 从RGB更新颜色
    local function updateColorFromRGB(r, g, b)
        r = math.clamp(tonumber(r) or 0, 0, 255) / 255
        g = math.clamp(tonumber(g) or 0, 0, 255) / 255
        b = math.clamp(tonumber(b) or 0, 0, 255) / 255
        local color = Color3.new(r, g, b)
        local h, s, v = color:ToHSV()
        Selector.Position = UDim2.new(s, 0, 1 - v, 0)
        HueSelector.Position = UDim2.new(0.5, 0, h, 0)
        updatePreviewColor(color)
        return color, h, s, v
    end
    
    -- 从HEX更新颜色
    local function updateColorFromHex(hex)
        hex = hex:gsub("#", "")
        if #hex == 3 then
            hex = hex:sub(1,1)..hex:sub(1,1)..hex:sub(2,2)..hex:sub(2,2)..hex:sub(3,3)..hex:sub(3,3)
        end
        
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) or 0
            local g = tonumber(hex:sub(3,4), 16) or 0
            local b = tonumber(hex:sub(5,6), 16) or 0
            return updateColorFromRGB(r, g, b)
        end
        return nil
    end
    
    -- 颜色画布交互（支持手机和电脑）
    local colorSelecting = false
    ColorCanvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            colorSelecting = true
            local mousePos = services.UserInputService:GetMouseLocation()
            local canvasPos = ColorCanvas.AbsolutePosition
            local canvasSize = ColorCanvas.AbsoluteSize
            
            local x = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
            local y = math.clamp((mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
            
            Selector.Position = UDim2.new(x, 0, y, 0)
            local h = HueSelector.Position.Y.Scale
            local color = updateColorFromHSV(h, x, 1 - y)
        end
    end)
    
    ColorCanvas.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) and colorSelecting then
            local mousePos = services.UserInputService:GetMouseLocation()
            local canvasPos = ColorCanvas.AbsolutePosition
            local canvasSize = ColorCanvas.AbsoluteSize
            
            local x = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
            local y = math.clamp((mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
            
            Selector.Position = UDim2.new(x, 0, y, 0)
            local h = HueSelector.Position.Y.Scale
            local color = updateColorFromHSV(h, x, 1 - y)
        end
    end)
    
    ColorCanvas.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            colorSelecting = false
        end
    end)
    
    -- 色相滑块交互（支持手机和电脑）
    local hueSelecting = false
    HueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            hueSelecting = true
            local mousePos = services.UserInputService:GetMouseLocation()
            local sliderPos = HueSlider.AbsolutePosition
            local sliderSize = HueSlider.AbsoluteSize
            
            local y = math.clamp((mousePos.Y - sliderPos.Y) / sliderSize.Y, 0, 1)
            HueSelector.Position = UDim2.new(0.5, 0, y, 0)
            
            local h = y
            local s = Selector.Position.X.Scale
            local v = 1 - Selector.Position.Y.Scale
            local color = updateColorFromHSV(h, s, v)
        end
    end)
    
    HueSlider.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) and hueSelecting then
            local mousePos = services.UserInputService:GetMouseLocation()
            local sliderPos = HueSlider.AbsolutePosition
            local sliderSize = HueSlider.AbsoluteSize
            
            local y = math.clamp((mousePos.Y - sliderPos.Y) / sliderSize.Y, 0, 1)
            HueSelector.Position = UDim2.new(0.5, 0, y, 0)
            
            local h = y
            local s = Selector.Position.X.Scale
            local v = 1 - Selector.Position.Y.Scale
            local color = updateColorFromHSV(h, s, v)
        end
    end)
    
    HueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            hueSelecting = false
        end
    end)
    
    -- RGB输入框事件
    RInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local color = updateColorFromRGB(RInput.Text, GInput.Text, BInput.Text)
        end
    end)
    
    GInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local color = updateColorFromRGB(RInput.Text, GInput.Text, BInput.Text)
        end
    end)
    
    BInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local color = updateColorFromRGB(RInput.Text, GInput.Text, BInput.Text)
        end
    end)
    
    -- HEX输入框事件
    HexInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local hex = HexInput.Text
            local color = updateColorFromHex(hex)
        end
    end)
    
    -- 按钮事件
    local windowOpen = false
    ColorPickerButton.MouseButton1Click:Connect(function()
        if not windowOpen then
            DigitalParticleExplosion(ColorPickerButton)
            
            -- 确保主界面显示
            if not Main.Visible then
                Main.Visible = true
                playEntranceAnimation()
                task.wait(0.3) -- 等待动画完成
            end
            
            ColorPickerWindow.Visible = true
            windowOpen = true
            
            -- 计算位置：确保在主界面内部
            local mainPos = Main.AbsolutePosition
            local mainSize = Main.AbsoluteSize
            local windowSize = ColorPickerWindow.AbsoluteSize
            
            -- 尝试将窗口放在颜色预览按钮附近
            local buttonPos = ColorPickerButton.AbsolutePosition
            local buttonSize = ColorPickerButton.AbsoluteSize
            
            -- 计算窗口位置（相对于屏幕）
            local x = buttonPos.X + buttonSize.X + 10
            local y = buttonPos.Y
            
            -- 如果窗口会超出屏幕右侧，则放在左侧
            local screenSize = services.CoreGui.AbsoluteSize
            if x + windowSize.X > screenSize.X then
                x = buttonPos.X - windowSize.X - 10
            end
            
            -- 如果窗口会超出屏幕底部，则向上调整
            if y + windowSize.Y > screenSize.Y then
                y = screenSize.Y - windowSize.Y - 10
            end
            
            -- 确保窗口在屏幕内
            x = math.max(10, math.min(x, screenSize.X - windowSize.X - 10))
            y = math.max(10, math.min(y, screenSize.Y - windowSize.Y - 10))
            
            ColorPickerWindow.Position = UDim2.new(0, x, 0, y)
        end
    end)
    
    ConfirmButton.MouseButton1Click:Connect(function()
        local currentColor = CurrentColorPreview.BackgroundColor3
        FengUI.flags[flag] = currentColor
        callback(currentColor)
        ColorPickerWindow.Visible = false
        windowOpen = false
        DigitalParticleExplosion(ConfirmButton)
    end)
    
    CancelButton.MouseButton1Click:Connect(function()
        ColorPickerWindow.Visible = false
        windowOpen = false
        DigitalParticleExplosion(CancelButton)
    end)
    
    -- 点击外部关闭窗口
    local function isMouseOverWindow()
        if not ColorPickerWindow.Visible then return false end
        
        local mousePos = services.UserInputService:GetMouseLocation()
        local windowPos = ColorPickerWindow.AbsolutePosition
        local windowSize = ColorPickerWindow.AbsoluteSize
        
        return mousePos.X >= windowPos.X and mousePos.X <= windowPos.X + windowSize.X and
               mousePos.Y >= windowPos.Y and mousePos.Y <= windowPos.Y + windowSize.Y
    end
    
    services.UserInputService.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
            input.UserInputType == Enum.UserInputType.Touch) and windowOpen then
            if not isMouseOverWindow() then
                ColorPickerWindow.Visible = false
                windowOpen = false
            end
        end
    end)
    
    -- 触摸结束事件
    services.UserInputService.TouchEnded:Connect(function(input, processed)
        if windowOpen and not isMouseOverWindow() then
            ColorPickerWindow.Visible = false
            windowOpen = false
        end
    end)
    
    local funcs = {
        SetColor = function(self, color)
            local h, s, v = color:ToHSV()
            Selector.Position = UDim2.new(s, 0, 1 - v, 0)
            HueSelector.Position = UDim2.new(0.5, 0, h, 0)
            updatePreviewColor(color)
            FengUI.flags[flag] = color
            callback(color)
        end,
        
        GetColor = function(self)
            return FengUI.flags[flag]
        end,
        
        Module = ColorPickerModule,
        
        Destroy = function(self)
            ColorPickerWindow:Destroy()
            ColorPickerModule:Destroy()
        end
    }
    
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