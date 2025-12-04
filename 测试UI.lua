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
    MainColor = Color3.fromRGB(10, 10, 20),
    TabColor = Color3.fromRGB(15, 15, 25),
    Bg_Color = Color3.fromRGB(8, 8, 16),
    Zy_Color = Color3.fromRGB(12, 12, 20),
    Button_Color = Color3.fromRGB(20, 20, 35),
    Textbox_Color = Color3.fromRGB(20, 20, 35),
    Dropdown_Color = Color3.fromRGB(20, 20, 35),
    Keybind_Color = Color3.fromRGB(20, 20, 35),
    Label_Color = Color3.fromRGB(20, 20, 35),
    Slider_Color = Color3.fromRGB(20, 20, 35),
    SliderBar_Color = Color3.fromRGB(45, 120, 255),
    Toggle_Color = Color3.fromRGB(20, 20, 35),
    Toggle_Off = Color3.fromRGB(30, 30, 50),
    Toggle_On = Color3.fromRGB(0, 180, 255),
    AccentColor = Color3.fromRGB(0, 180, 255),
    TextColor = Color3.fromRGB(240, 240, 255),
    SecondaryTextColor = Color3.fromRGB(160, 160, 200),
    GlowColor = Color3.fromRGB(0, 150, 255),
}

local MusicPlayer = {
    currentSound = nil,
    currentTrackIndex = 1,
    isPlaying = false,
    isLooping = false,
    playlist = {},
    volume = 0.5
}

function MusicPlayer:PlayTrack(trackId)
    if self.currentSound then
        self.currentSound:Stop()
        self.currentSound:Destroy()
    end
    
    self.currentSound = Instance.new("Sound")
    self.currentSound.SoundId = "rbxassetid://" .. trackId
    self.currentSound.Volume = self.volume
    self.currentSound.Looped = false
    self.currentSound.Parent = services.SoundService
    
    self.currentSound.Ended:Connect(function()
        if self.isLooping then
            self.currentSound:Play()
        else
            self:NextTrack()
        end
    end)
    
    self.currentSound:Play()
    self.isPlaying = true
end

function MusicPlayer:Pause()
    if self.currentSound and self.isPlaying then
        self.currentSound:Pause()
        self.isPlaying = false
    end
end

function MusicPlayer:Resume()
    if self.currentSound and not self.isPlaying then
        self.currentSound:Play()
        self.isPlaying = true
    end
end

function MusicPlayer:Stop()
    if self.currentSound then
        self.currentSound:Stop()
        self.isPlaying = false
    end
end

function MusicPlayer:NextTrack()
    if #self.playlist == 0 then return end
    
    self.currentTrackIndex = self.currentTrackIndex + 1
    if self.currentTrackIndex > #self.playlist then
        self.currentTrackIndex = 1
    end
    
    self:PlayTrack(self.playlist[self.currentTrackIndex].id)
    return self.playlist[self.currentTrackIndex]
end

function MusicPlayer:PreviousTrack()
    if #self.playlist == 0 then return end
    
    self.currentTrackIndex = self.currentTrackIndex - 1
    if self.currentTrackIndex < 1 then
        self.currentTrackIndex = #self.playlist
    end
    
    self:PlayTrack(self.playlist[self.currentTrackIndex].id)
    return self.playlist[self.currentTrackIndex]
end

function MusicPlayer:SetVolume(volume)
    self.volume = volume
    if self.currentSound then
        self.currentSound.Volume = volume
    end
end

function MusicPlayer:AddToPlaylist(trackId, title, artist, imageId)
    table.insert(self.playlist, {
        id = trackId,
        title = title or "Unknown Title",
        artist = artist or "Unknown Artist",
        imageId = imageId or "84830962019412"
    })
end

function MusicPlayer:ClearPlaylist()
    self.playlist = {}
    self.currentTrackIndex = 1
    self:Stop()
end

function MusicPlayer:GetCurrentTrack()
    if #self.playlist == 0 then return nil end
    return self.playlist[self.currentTrackIndex]
end

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
        explosionCenter.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
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
        centerGlow.Color = Color3.fromRGB(0, 180, 255)
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
                math.random(100, 200),
                math.random(150, 220),
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
        shockwaveStroke.Color = Color3.fromRGB(0, 150, 255)
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
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
    if gui.Name == "QuantumUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local QuantumUI = Instance.new("ScreenGui")
QuantumUI.Name = "QuantumUI"
protectGUI(QuantumUI)
QuantumUI.Parent = services.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = QuantumUI
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.Bg_Color
Main.BackgroundTransparency = 0.05
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(40, 40, 60)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

local MainGlow = Instance.new("UIGradient")
MainGlow.Rotation = 90
MainGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
})
MainGlow.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.8),
    NumberSequenceKeypoint.new(0.5, 0.6),
    NumberSequenceKeypoint.new(1, 0.8)
})
MainGlow.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
TopBar.BackgroundTransparency = 0.1
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.ZIndex = 2

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.Parent = TopBar
LogoContainer.BackgroundTransparency = 1
LogoContainer.Size = UDim2.new(0, 160, 1, 0)

local LogoText = Instance.new("TextLabel")
LogoText.Name = "LogoText"
LogoText.Parent = LogoContainer
LogoText.BackgroundTransparency = 1
LogoText.Position = UDim2.new(0.1, 0, 0, 0)
LogoText.Size = UDim2.new(0, 150, 1, 0)
LogoText.Font = Enum.Font.GothamBold
LogoText.Text = "QUANTUM UI"
LogoText.TextColor3 = config.AccentColor
LogoText.TextSize = 20
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.TextTransparency = 0

local LogoGlow = Instance.new("UIGradient")
LogoGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 255))
})
LogoGlow.Rotation = 0
LogoGlow.Offset = Vector2.new(0, 0)
LogoGlow.Parent = LogoText

task.spawn(function()
    while LogoText and LogoText.Parent do
        LogoGlow.Offset = Vector2.new((tick() * 0.5) % 1, 0)
        task.wait()
    end
end)

local ControlButtons = Instance.new("Frame")
ControlButtons.Name = "ControlButtons"
ControlButtons.Parent = TopBar
ControlButtons.BackgroundTransparency = 1
ControlButtons.Position = UDim2.new(1, -80, 0, 0)
ControlButtons.Size = UDim2.new(0, 80, 1, 0)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = ControlButtons
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Position = UDim2.new(0, 10, 0.2, 0)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = config.SecondaryTextColor
MinimizeButton.TextSize = 18
MinimizeButton.ZIndex = 10

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = ControlButtons
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(0, 40, 0.2, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.TextSize = 24
CloseButton.ZIndex = 10

MinimizeButton.MouseEnter:Connect(function()
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
        TextColor3 = config.AccentColor,
        TextSize = 22
    }):Play()
end)

MinimizeButton.MouseLeave:Connect(function()
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
        TextColor3 = config.SecondaryTextColor,
        TextSize = 18
    }):Play()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(MinimizeButton)
    ToggleUILib()
end)

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 120, 120),
        TextSize = 28
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(255, 80, 80),
        TextSize = 24
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(CloseButton)
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        TextColor3 = Color3.fromRGB(255, 40, 40),
        TextSize = 20
    }):Play()
    
    services.TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10),
        Rotation = 360
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.5), {
        Transparency = 1
    }):Play()
    
    services.TweenService:Create(TopBar, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(LogoText, TweenInfo.new(0.5), {
        TextTransparency = 1
    }):Play()
    
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.5), {
        TextTransparency = 1
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.5), {
        TextTransparency = 1
    }):Play()
    
    task.wait(0.5)
    QuantumUI:Destroy()
end)

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = QuantumUI
OpenButton.BackgroundColor3 = config.AccentColor
OpenButton.BackgroundTransparency = 0.8
OpenButton.Position = UDim2.new(0.95, -20, 0.02, 0)
OpenButton.Size = UDim2.new(0, 44, 0, 44)
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Image = "rbxassetid://84830962019412"
OpenButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.ImageTransparency = 0.1

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenGlow = Instance.new("UIStroke")
OpenGlow.Parent = OpenButton
OpenGlow.Color = config.AccentColor
OpenGlow.Thickness = 2
OpenGlow.Transparency = 0.5

local OpenEffect = Instance.new("UIGradient")
OpenEffect.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
})
OpenEffect.Rotation = 45
OpenEffect.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 0.7)
})
OpenEffect.Parent = OpenButton

task.spawn(function()
    while OpenButton and OpenButton.Parent do
        OpenEffect.Rotation = (tick() * 30) % 360
        task.wait()
    end
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playEntranceAnimation()
    end
    create3DFlipAnimation(OpenButton, 0.5)
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
        create3DFlipAnimation(OpenButton, 0.5)
    end
end)

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = Main
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 0, 0, 40)
ContentContainer.Size = UDim2.new(1, 0, 1, -40)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = ContentContainer
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.Size = UDim2.new(0, 120, 1, 0)

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local SidebarGlow = Instance.new("UIGradient")
SidebarGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 25))
})
SidebarGlow.Rotation = 90
SidebarGlow.Transparency = NumberSequence.new(0.5)
SidebarGlow.Parent = Sidebar

local TabList = Instance.new("ScrollingFrame")
TabList.Name = "TabList"
TabList.Parent = Sidebar
TabList.Active = true
TabList.BackgroundTransparency = 1
TabList.BorderSizePixel = 0
TabList.Position = UDim2.new(0, 10, 0, 10)
TabList.Size = UDim2.new(1, -20, 1, -20)
TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
TabList.ScrollBarThickness = 3
TabList.ScrollBarImageColor3 = config.AccentColor
TabList.ScrollBarImageTransparency = 0.7
TabList.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabList.ScrollingDirection = Enum.ScrollingDirection.Y
TabList.HorizontalScrollBarInset = Enum.ScrollBarInset.None
TabList.Visible = false

local TabLayout = Instance.new("UIListLayout")
TabLayout.Name = "TabLayout"
TabLayout.Parent = TabList
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 8)

TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabList.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    
    TabList.ScrollingEnabled = TabLayout.AbsoluteContentSize.Y > TabList.AbsoluteSize.Y
    TabList.ElasticBehavior = Enum.ElasticBehavior.Never
end)

local MainContent = Instance.new("Frame")
MainContent.Name = "MainContent"
MainContent.Parent = ContentContainer
MainContent.BackgroundTransparency = 1
MainContent.Position = UDim2.new(0, 125, 0, 0)
MainContent.Size = UDim2.new(1, -125, 1, 0)
MainContent.Visible = false

local TabContentContainer = Instance.new("ScrollingFrame")
TabContentContainer.Name = "TabContentContainer"
TabContentContainer.Parent = MainContent
TabContentContainer.Active = true
TabContentContainer.BackgroundTransparency = 1
TabContentContainer.Size = UDim2.new(1, 0, 1, 0)
TabContentContainer.ScrollBarThickness = 3
TabContentContainer.ScrollBarImageColor3 = config.AccentColor
TabContentContainer.ScrollBarImageTransparency = 0.7
TabContentContainer.Visible = false
TabContentContainer.ElasticBehavior = Enum.ElasticBehavior.Never
TabContentContainer.ScrollingDirection = Enum.ScrollingDirection.Y
TabContentContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Name = "ContentLayout"
ContentLayout.Parent = TabContentContainer
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    
    TabContentContainer.ScrollingEnabled = ContentLayout.AbsoluteContentSize.Y > TabContentContainer.AbsoluteSize.Y
    TabContentContainer.ElasticBehavior = Enum.ElasticBehavior.Never
end)

local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    Main.Rotation = 0
    
    TopBar.BackgroundTransparency = 1
    LogoText.TextTransparency = 1
    MinimizeButton.TextTransparency = 1
    CloseButton.TextTransparency = 1
    Sidebar.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    
    MainContent.Visible = false
    TabList.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 0.05,
        Size = UDim2.new(0, 500, 0, 320),
        Rotation = 360
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.3
    }):Play()
    
    task.wait(0.3)
    
    services.TweenService:Create(TopBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
    
    services.TweenService:Create(LogoText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
    
    task.wait(0.2)
    
    MainContent.Visible = true
    TabList.Visible = true
    
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
    matrixEffect.Parent = LogoText
    
    while LogoText and LogoText.Parent do
        hue = (hue + 0.02) % 1
        
        LogoText.TextColor3 = Color3.fromHSV(hue, 1, 1)
        
        matrixEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV((hue + 0.2) % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue - 0.2) % 1, 1, 1))
        })
        
        services.TweenService:Create(LogoText, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 20 + math.sin(tick() * 2) * 2
        }):Play()
        
        task.wait(0.05)
    end
end)

function FengUI.new(FengUI, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "QUANTUM" then
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

    local scriptName = name or "QUANTUM UI"
    LogoText.Text = scriptName
    
    local window = {}
    
    function window.Tab(window, name, icon)
        local Tab = Instance.new("ScrollingFrame")
        local TabButton = Instance.new("TextButton")
        local TabIcon = Instance.new("ImageLabel")
        local TabLabel = Instance.new("TextLabel")
        
        Tab.Name = "Tab"
        Tab.Parent = TabContentContainer
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.ScrollBarImageTransparency = 0.7
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabButton.Name = "TabButton"
        TabButton.Parent = TabList
        TabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        TabButton.BackgroundTransparency = 0.2
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.AutoButtonColor = false
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Text = ""
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton
        
        local TabButtonGlow = Instance.new("UIStroke")
        TabButtonGlow.Parent = TabButton
        TabButtonGlow.Color = config.AccentColor
        TabButtonGlow.Thickness = 1
        TabButtonGlow.Transparency = 0.8
        
        TabIcon.Name = "TabIcon"
        TabIcon.Parent = TabButton
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0.1, 0, 0.5, -10)
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Image = icon or "rbxassetid://84830962019412"
        TabIcon.ImageTransparency = 0.5
        
        TabLabel.Name = "TabLabel"
        TabLabel.Parent = TabButton
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0.4, 0, 0, 0)
        TabLabel.Size = UDim2.new(0.6, 0, 1, 0)
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.Text = name
        TabLabel.TextColor3 = config.TextColor
        TabLabel.TextSize = 14
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.TextTransparency = 0.5
        
        TabButton.MouseEnter:Connect(function()
            services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
            services.TweenService:Create(TabIcon, TweenInfo.new(0.2), {
                ImageTransparency = 0.3
            }):Play()
            services.TweenService:Create(TabLabel, TweenInfo.new(0.2), {
                TextTransparency = 0.3
            }):Play()
        end)
        
        TabButton.MouseLeave:Connect(function()
            if FengUI.currentTab and FengUI.currentTab[1] == TabButton then return end
            services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
            services.TweenService:Create(TabIcon, TweenInfo.new(0.2), {
                ImageTransparency = 0.5
            }):Play()
            services.TweenService:Create(TabLabel, TweenInfo.new(0.2), {
                TextTransparency = 0.5
            }):Play()
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(TabButton)
            switchTab({ TabButton, Tab })
        end)
        
        if FengUI.currentTab == nil then
            switchTab({ TabButton, Tab })
        end
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Name = "ContentList"
        ContentList.Parent = Tab
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 15)
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
            
            Tab.ScrollingEnabled = ContentList.AbsoluteContentSize.Y > Tab.AbsoluteSize.Y
            Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        end)
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            local Section = Instance.new("Frame")
            local SectionCorner = Instance.new("UICorner")
            local SectionHeader = Instance.new("Frame")
            local SectionTitle = Instance.new("TextLabel")
            local SectionIcon = Instance.new("ImageLabel")
            local SectionToggle = Instance.new("TextButton")
            local SectionContent = Instance.new("Frame")
            local ContentLayout = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
            Section.BackgroundTransparency = 0.1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(1, -10, 0, 50)
            
            SectionCorner.CornerRadius = UDim.new(0, 10)
            SectionCorner.Name = "SectionCorner"
            SectionCorner.Parent = Section
            
            local SectionGlow = Instance.new("UIStroke")
            SectionGlow.Parent = Section
            SectionGlow.Color = config.AccentColor
            SectionGlow.Thickness = 1
            SectionGlow.Transparency = 0.8
            
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, 50)
            
            SectionIcon.Name = "SectionIcon"
            SectionIcon.Parent = SectionHeader
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Position = UDim2.new(0.03, 0, 0.5, -12)
            SectionIcon.Size = UDim2.new(0, 24, 0, 24)
            SectionIcon.Image = "rbxassetid://84830962019412"
            SectionIcon.ImageColor3 = config.AccentColor
            
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0.1, 0, 0, 0)
            SectionTitle.Size = UDim2.new(0.8, 0, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.TextColor
            SectionTitle.TextSize = 16
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionHeader
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Position = UDim2.new(0.9, -20, 0.5, -10)
            SectionToggle.Size = UDim2.new(0, 20, 0, 20)
            SectionToggle.Font = Enum.Font.GothamBold
            SectionToggle.Text = "+"
            SectionToggle.TextColor3 = config.AccentColor
            SectionToggle.TextSize = 20
            
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = Section
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 15, 0, 55)
            SectionContent.Size = UDim2.new(1, -30, 0, 0)
            
            ContentLayout.Name = "ContentLayout"
            ContentLayout.Parent = SectionContent
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Padding = UDim.new(0, 10)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(1, -10, 0, open and 55 + ContentLayout.AbsoluteContentSize.Y or 50)
                SectionToggle.Text = open and "−" : "+"
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -10, 0, open and 55 + ContentLayout.AbsoluteContentSize.Y or 50)
                }):Play()
                
                services.TweenService:Create(SectionToggle, TweenInfo.new(0.3), {
                    Rotation = open and 180 or 0,
                    Text = open and "−" or "+"
                }):Play()
                
                DigitalParticleExplosion(SectionToggle)
            end)
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(1, -10, 0, 55 + ContentLayout.AbsoluteContentSize.Y)
            end)
            
            local section = {}
            
            function section.MusicPlayer(section, title, defaultPlaylist)
                local MusicPlayerModule = Instance.new("Frame")
                MusicPlayerModule.Name = "MusicPlayerModule"
                MusicPlayerModule.Parent = SectionContent
                MusicPlayerModule.BackgroundTransparency = 1
                MusicPlayerModule.BorderSizePixel = 0
                MusicPlayerModule.Size = UDim2.new(1, 0, 0, 160)
                
                local PlayerContainer = Instance.new("Frame")
                PlayerContainer.Name = "PlayerContainer"
                PlayerContainer.Parent = MusicPlayerModule
                PlayerContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
                PlayerContainer.BackgroundTransparency = 0.1
                PlayerContainer.Size = UDim2.new(1, 0, 0, 160)
                
                local PlayerCorner = Instance.new("UICorner")
                PlayerCorner.CornerRadius = UDim.new(0, 10)
                PlayerCorner.Parent = PlayerContainer
                
                local playerGlow = Instance.new("UIStroke")
                playerGlow.Parent = PlayerContainer
                playerGlow.Color = config.AccentColor
                playerGlow.Thickness = 2
                playerGlow.Transparency = 0.7
                
                startNeonFlowEffect(playerGlow, "Color", 0.008)
                createPulseGlow(playerGlow)
                
                local TopSection = Instance.new("Frame")
                TopSection.Name = "TopSection"
                TopSection.Parent = PlayerContainer
                TopSection.BackgroundTransparency = 1
                TopSection.Size = UDim2.new(1, 0, 0, 70)
                
                local AlbumArt = Instance.new("ImageLabel")
                AlbumArt.Name = "AlbumArt"
                AlbumArt.Parent = TopSection
                AlbumArt.BackgroundColor3 = config.Bg_Color
                AlbumArt.BackgroundTransparency = 0.1
                AlbumArt.Position = UDim2.new(0.03, 0, 0.1, 0)
                AlbumArt.Size = UDim2.new(0, 50, 0, 50)
                
                local AlbumCorner = Instance.new("UICorner")
                AlbumCorner.CornerRadius = UDim.new(0, 8)
                AlbumCorner.Parent = AlbumArt
                
                local albumGlow = Instance.new("UIStroke")
                albumGlow.Parent = AlbumArt
                albumGlow.Color = config.AccentColor
                albumGlow.Thickness = 1
                albumGlow.Transparency = 0.8
                
                local InfoContainer = Instance.new("Frame")
                InfoContainer.Name = "InfoContainer"
                InfoContainer.Parent = TopSection
                InfoContainer.BackgroundTransparency = 1
                InfoContainer.Position = UDim2.new(0.22, 0, 0, 0)
                InfoContainer.Size = UDim2.new(0.75, 0, 1, 0)
                
                local SongTitle = Instance.new("TextLabel")
                SongTitle.Name = "SongTitle"
                SongTitle.Parent = InfoContainer
                SongTitle.BackgroundTransparency = 1
                SongTitle.Position = UDim2.new(0, 0, 0.15, 0)
                SongTitle.Size = UDim2.new(1, 0, 0, 25)
                SongTitle.Font = Enum.Font.GothamBold
                SongTitle.Text = "没有播放音乐"
                SongTitle.TextColor3 = config.TextColor
                SongTitle.TextSize = 14
                SongTitle.TextXAlignment = Enum.TextXAlignment.Left
                SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
                
                local ArtistName = Instance.new("TextLabel")
                ArtistName.Name = "ArtistName"
                ArtistName.Parent = InfoContainer
                ArtistName.BackgroundTransparency = 1
                ArtistName.Position = UDim2.new(0, 0, 0.45, 0)
                ArtistName.Size = UDim2.new(1, 0, 0, 20)
                ArtistName.Font = Enum.Font.Gotham
                ArtistName.Text = "未知艺术家"
                ArtistName.TextColor3 = config.SecondaryTextColor
                ArtistName.TextSize = 12
                ArtistName.TextXAlignment = Enum.TextXAlignment.Left
                ArtistName.TextTruncate = Enum.TextTruncate.AtEnd
                
                local BottomSection = Instance.new("Frame")
                BottomSection.Name = "BottomSection"
                BottomSection.Parent = PlayerContainer
                BottomSection.BackgroundTransparency = 1
                BottomSection.Position = UDim2.new(0, 0, 0.44, 0)
                BottomSection.Size = UDim2.new(1, 0, 0, 90)
                
                local ProgressBar = Instance.new("Frame")
                ProgressBar.Name = "ProgressBar"
                ProgressBar.Parent = BottomSection
                ProgressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                ProgressBar.BorderSizePixel = 0
                ProgressBar.Position = UDim2.new(0.03, 0, 0.05, 0)
                ProgressBar.Size = UDim2.new(0.94, 0, 0, 6)
                
                local ProgressBarCorner = Instance.new("UICorner")
                ProgressBarCorner.CornerRadius = UDim.new(1, 0)
                ProgressBarCorner.Parent = ProgressBar
                
                local ProgressFill = Instance.new("Frame")
                ProgressFill.Name = "ProgressFill"
                ProgressFill.Parent = ProgressBar
                ProgressFill.BackgroundColor3 = config.AccentColor
                ProgressFill.BorderSizePixel = 0
                ProgressFill.Size = UDim2.new(0, 0, 1, 0)
                
                local ProgressFillCorner = Instance.new("UICorner")
                ProgressFillCorner.CornerRadius = UDim.new(1, 0)
                ProgressFillCorner.Parent = ProgressFill
                
                local TimeLabel = Instance.new("TextLabel")
                TimeLabel.Name = "TimeLabel"
                TimeLabel.Parent = BottomSection
                TimeLabel.BackgroundTransparency = 1
                TimeLabel.Position = UDim2.new(0.03, 0, 0.18, 0)
                TimeLabel.Size = UDim2.new(0.94, 0, 0, 15)
                TimeLabel.Font = Enum.Font.Gotham
                TimeLabel.Text = "0:00 / 0:00"
                TimeLabel.TextColor3 = config.SecondaryTextColor
                TimeLabel.TextSize = 10
                TimeLabel.TextXAlignment = Enum.TextXAlignment.Center
                
                local ControlsContainer = Instance.new("Frame")
                ControlsContainer.Name = "ControlsContainer"
                ControlsContainer.Parent = BottomSection
                ControlsContainer.BackgroundTransparency = 1
                ControlsContainer.Position = UDim2.new(0, 0, 0.35, 0)
                ControlsContainer.Size = UDim2.new(1, 0, 0, 40)
                
                local function createControlButton(name, text, position, size, isMain)
                    local button = Instance.new("TextButton")
                    button.Name = name
                    button.Parent = ControlsContainer
                    button.BackgroundColor3 = isMain and config.AccentColor or Color3.fromRGB(70, 70, 100)
                    button.BackgroundTransparency = 0.1
                    button.Position = position
                    button.Size = size
                    button.AutoButtonColor = false
                    button.Font = Enum.Font.GothamBold
                    button.Text = text
                    button.TextColor3 = isMain and config.TextColor or Color3.fromRGB(200, 200, 220)
                    button.TextSize = isMain and 16 or 12
                    button.ZIndex = 5
                    
                    local buttonCorner = Instance.new("UICorner")
                    buttonCorner.CornerRadius = UDim.new(1, 0)
                    buttonCorner.Parent = button
                    
                    local buttonGlow = Instance.new("UIStroke")
                    buttonGlow.Parent = button
                    buttonGlow.Color = isMain and config.AccentColor or Color3.fromRGB(100, 100, 150)
                    buttonGlow.Thickness = 1
                    buttonGlow.Transparency = 0.6
                    buttonGlow.ZIndex = 4
                    
                    if isMain then
                        startNeonFlowEffect(buttonGlow, "Color", 0.01)
                    end
                    
                    button.MouseEnter:Connect(function()
                        services.TweenService:Create(button, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0,
                            Size = UDim2.new(0, size.X.Offset + 2, 0, size.Y.Offset + 2)
                        }):Play()
                        services.TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
                            Thickness = 2,
                            Transparency = 0.3
                        }):Play()
                    end)
                    
                    button.MouseLeave:Connect(function()
                        services.TweenService:Create(button, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.1,
                            Size = size
                        }):Play()
                        services.TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
                            Thickness = 1,
                            Transparency = 0.6
                        }):Play()
                    end)
                    
                    return button, buttonGlow
                end
                
                local PrevButton, prevGlow = createControlButton("PrevButton", "⏮", UDim2.new(0.15, 0, 0.2, 0), UDim2.new(0, 32, 0, 32), false)
                local PlayPauseButton, playGlow = createControlButton("PlayPauseButton", "▶", UDim2.new(0.42, 0, 0.1, 0), UDim2.new(0, 36, 0, 36), true)
                local NextButton, nextGlow = createControlButton("NextButton", "⏭", UDim2.new(0.69, 0, 0.2, 0), UDim2.new(0, 32, 0, 32), false)
                
                local LoopButton, loopGlow = createControlButton("LoopButton", "🔁", UDim2.new(0.85, 0, 0.2, 0), UDim2.new(0, 32, 0, 32), false)
                
                local loopModes = {
                    {mode = "none", text = "🔁", tooltip = "无循环"},
                    {mode = "single", text = "🔂", tooltip = "单曲循环"},
                    {mode = "all", text = "🔁", tooltip = "列表循环"}
                }
                local currentLoopMode = 1
                
                local function updateLoopMode()
                    local mode = loopModes[currentLoopMode]
                    LoopButton.Text = mode.text
                    MusicPlayer.isLooping = (mode.mode == "single" or mode.mode == "all")
                    
                    if mode.mode == "single" then
                        services.TweenService:Create(LoopButton, TweenInfo.new(0.3), {
                            BackgroundColor3 = Color3.fromRGB(80, 80, 120)
                        }):Play()
                        services.TweenService:Create(loopGlow, TweenInfo.new(0.3), {
                            Transparency = 0.3,
                            Thickness = 2
                        }):Play()
                    else
                        services.TweenService:Create(LoopButton, TweenInfo.new(0.3), {
                            BackgroundColor3 = Color3.fromRGB(70, 70, 100)
                        }):Play()
                        services.TweenService:Create(loopGlow, TweenInfo.new(0.3), {
                            Transparency = 0.6,
                            Thickness = 1
                        }):Play()
                    end
                end
                
                local function updateUI()
                    local currentTrack = MusicPlayer:GetCurrentTrack()
                    if currentTrack then
                        SongTitle.Text = currentTrack.title
                        ArtistName.Text = currentTrack.artist
                        AlbumArt.Image = "rbxassetid://" .. currentTrack.imageId
                    else
                        SongTitle.Text = "没有播放音乐"
                        ArtistName.Text = "未知艺术家"
                        AlbumArt.Image = "rbxassetid://84830962019412"
                    end
                    
                    PlayPauseButton.Text = MusicPlayer.isPlaying and "⏸" or "▶"
                    updateLoopMode()
                end
                
                task.spawn(function()
                    while PlayerContainer and PlayerContainer.Parent do
                        if MusicPlayer.currentSound and MusicPlayer.isPlaying then
                            local currentTime = MusicPlayer.currentSound.TimePosition
                            local totalTime = MusicPlayer.currentSound.TimeLength
                            
                            if totalTime > 0 then
                                local progress = currentTime / totalTime
                                ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
                                
                                local currentMinutes = math.floor(currentTime / 60)
                                local currentSeconds = math.floor(currentTime % 60)
                                local totalMinutes = math.floor(totalTime / 60)
                                local totalSeconds = math.floor(totalTime % 60)
                                
                                TimeLabel.Text = string.format("%d:%02d / %d:%02d", 
                                    currentMinutes, currentSeconds, totalMinutes, totalSeconds)
                            end
                        else
                            ProgressFill.Size = UDim2.new(0, 0, 1, 0)
                            TimeLabel.Text = "0:00 / 0:00"
                        end
                        task.wait(0.1)
                    end
                end)
                
                local function createButtonClickEffect(button, isMain)
                    services.TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3,
                        Size = UDim2.new(0, button.Size.X.Offset - 2, 0, button.Size.Y.Offset - 2)
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1,
                        Size = UDim2.new(0, button.Size.X.Offset + 2, 0, button.Size.Y.Offset + 2)
                    }):Play()
                end
                
                PlayPauseButton.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(PlayPauseButton)
                    createButtonClickEffect(PlayPauseButton, true)
                    
                    if MusicPlayer.isPlaying then
                        MusicPlayer:Pause()
                    else
                        if #MusicPlayer.playlist > 0 then
                            if not MusicPlayer.currentSound then
                                MusicPlayer:PlayTrack(MusicPlayer.playlist[MusicPlayer.currentTrackIndex].id)
                            else
                                MusicPlayer:Resume()
                            end
                        end
                    end
                    updateUI()
                end)
                
                PrevButton.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(PrevButton)
                    createButtonClickEffect(PrevButton, false)
                    local track = MusicPlayer:PreviousTrack()
                    if track then
                        updateUI()
                    end
                end)
                
                NextButton.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(NextButton)
                    createButtonClickEffect(NextButton, false)
                    local track = MusicPlayer:NextTrack()
                    if track then
                        updateUI()
                    end
                end)
                
                LoopButton.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(LoopButton)
                    createButtonClickEffect(LoopButton, false)
                    
                    currentLoopMode = currentLoopMode + 1
                    if currentLoopMode > #loopModes then
                        currentLoopMode = 1
                    end
                    
                    updateLoopMode()
                end)
                
                local originalPlayTrack = MusicPlayer.PlayTrack
                MusicPlayer.PlayTrack = function(self, trackId)
                    originalPlayTrack(self, trackId)
                    
                    if self.currentSound then
                        self.currentSound.Ended:Connect(function()
                            local currentMode = loopModes[currentLoopMode]
                            
                            if currentMode.mode == "single" then
                                self.currentSound:Play()
                            elseif currentMode.mode == "all" then
                                self:NextTrack()
                                updateUI()
                            else
                                self.isPlaying = false
                                updateUI()
                            end
                        end)
                    end
                end
                
                if defaultPlaylist then
                    for _, track in pairs(defaultPlaylist) do
                        MusicPlayer:AddToPlaylist(track.id, track.title, track.artist, track.imageId)
                    end
                end
                
                updateUI()
                
                local musicPlayerFuncs = {}
                
                function musicPlayerFuncs:AddTrack(trackId, title, artist, imageId)
                    MusicPlayer:AddToPlaylist(trackId, title, artist, imageId)
                    updateUI()
                end
                
                function musicPlayerFuncs:PlayTrack(trackId)
                    for i, track in ipairs(MusicPlayer.playlist) do
                        if track.id == trackId then
                            MusicPlayer.currentTrackIndex = i
                            MusicPlayer:PlayTrack(trackId)
                            updateUI()
                            return
                        end
                    end
                end
                
                function musicPlayerFuncs:SetVolume(volume)
                    MusicPlayer:SetVolume(volume)
                end
                
                function musicPlayerFuncs:ClearPlaylist()
                    MusicPlayer:ClearPlaylist()
                    updateUI()
                end
                
                function musicPlayerFuncs:GetCurrentTrack()
                    return MusicPlayer:GetCurrentTrack()
                end
                
                function musicPlayerFuncs:GetPlaylist()
                    return MusicPlayer.playlist
                end
                
                function musicPlayerFuncs:SetLoopMode(mode)
                    for i, loopMode in ipairs(loopModes) do
                        if loopMode.mode == mode then
                            currentLoopMode = i
                            updateLoopMode()
                            return
                        end
                    end
                end
                
                return musicPlayerFuncs
            end
            
            function section.Button(section, text, callback)
                callback = callback or function() end
                
                local ButtonModule = Instance.new("Frame")
                local Button = Instance.new("TextButton")
                local ButtonCorner = Instance.new("UICorner")
                local ButtonIcon = Instance.new("ImageLabel")
                
                ButtonModule.Name = "ButtonModule"
                ButtonModule.Parent = SectionContent
                ButtonModule.BackgroundTransparency = 1
                ButtonModule.BorderSizePixel = 0
                ButtonModule.Size = UDim2.new(1, 0, 0, 40)
                
                Button.Name = "Button"
                Button.Parent = ButtonModule
                Button.BackgroundColor3 = config.Button_Color
                Button.BackgroundTransparency = 0.1
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 0, 40)
                Button.AutoButtonColor = false
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = "   " .. text
                Button.TextColor3 = config.TextColor
                Button.TextSize = 14
                Button.TextXAlignment = Enum.TextXAlignment.Left
                
                ButtonCorner.CornerRadius = UDim.new(0, 8)
                ButtonCorner.Name = "ButtonCorner"
                ButtonCorner.Parent = Button
                
                ButtonIcon.Name = "ButtonIcon"
                ButtonIcon.Parent = Button
                ButtonIcon.BackgroundTransparency = 1
                ButtonIcon.Position = UDim2.new(0.92, -20, 0.5, -10)
                ButtonIcon.Size = UDim2.new(0, 20, 0, 20)
                ButtonIcon.Image = "rbxassetid://84830962019412"
                ButtonIcon.ImageColor3 = config.AccentColor
                ButtonIcon.ImageTransparency = 0.5
                
                local btnGlow = Instance.new("UIStroke")
                btnGlow.Parent = Button
                btnGlow.Color = config.AccentColor
                btnGlow.Thickness = 1
                btnGlow.Transparency = 0.8
                
                startNeonFlowEffect(btnGlow, "Color", 0.01)
                createPulseGlow(btnGlow)
                
                Button.MouseEnter:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.1),
                            math.floor(config.Button_Color.G * 255 * 1.1),
                            math.floor(config.Button_Color.B * 255 * 1.1)
                        )
                    }):Play()
                    services.TweenService:Create(ButtonIcon, TweenInfo.new(0.2), {
                        ImageTransparency = 0.3
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.5
                    }):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    services.TweenService:Create(ButtonIcon, TweenInfo.new(0.2), {
                        ImageTransparency = 0.5
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(Button)
                    callback()
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.1), {
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
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
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
                ImageModule.Parent = SectionContent
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(1, 0, 0, sizeY or 120)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or 300, 350), 0, sizeY or 120)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 10)
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
                local LabelCorner = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = SectionContent
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(1, 0, 0, 30)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.1
                TextLabel.Size = UDim2.new(1, 0, 0, 30)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 14
                TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                
                LabelCorner.CornerRadius = UDim.new(0, 8)
                LabelCorner.Name = "LabelCorner"
                LabelCorner.Parent = TextLabel
                
                return TextLabel
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                local ToggleButton = Instance.new("TextButton")
                local ToggleCorner = Instance.new("UICorner")
                local ToggleLabel = Instance.new("TextLabel")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchCorner = Instance.new("UICorner")
                local ToggleIcon = Instance.new("ImageLabel")
                
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = SectionContent
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(1, 0, 0, 40)
                
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = ToggleModule
                ToggleButton.BackgroundColor3 = config.Toggle_Color
                ToggleButton.BackgroundTransparency = 0.1
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Size = UDim2.new(1, 0, 0, 40)
                ToggleButton.AutoButtonColor = false
                ToggleButton.Font = Enum.Font.GothamSemibold
                ToggleButton.Text = ""
                
                ToggleCorner.CornerRadius = UDim.new(0, 8)
                ToggleCorner.Name = "ToggleCorner"
                ToggleCorner.Parent = ToggleButton
                
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Parent = ToggleButton
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
                ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                ToggleLabel.Font = Enum.Font.GothamSemibold
                ToggleLabel.Text = text
                ToggleLabel.TextColor3 = config.TextColor
                ToggleLabel.TextSize = 14
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleButton
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Position = UDim2.new(0.85, -25, 0.5, -12)
                ToggleSwitch.Size = UDim2.new(0, 50, 0, 24)
                
                ToggleSwitchCorner.CornerRadius = UDim.new(1, 0)
                ToggleSwitchCorner.Name = "ToggleSwitchCorner"
                ToggleSwitchCorner.Parent = ToggleSwitch
                
                ToggleIcon.Name = "ToggleIcon"
                ToggleIcon.Parent = ToggleSwitch
                ToggleIcon.BackgroundTransparency = 1
                ToggleIcon.Position = UDim2.new(0, enabled and 26 or 0, 0.5, -8)
                ToggleIcon.Size = UDim2.new(0, 16, 0, 16)
                ToggleIcon.Image = "rbxassetid://84830962019412"
                ToggleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                
                if enabled then
                    createHologramEffect(ToggleSwitch, 0.8)
                end
                
                ToggleButton.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Toggle_Color.R * 255 * 1.1),
                            math.floor(config.Toggle_Color.G * 255 * 1.1),
                            math.floor(config.Toggle_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                ToggleButton.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
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
                        
                        services.TweenService:Create(ToggleIcon, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, state and 26 or 0, 0.5, -8)
                        }):Play()
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
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
                
                ToggleButton.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(ToggleButton)
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
                local KeybindButton = Instance.new("TextButton")
                local KeybindCorner = Instance.new("UICorner")
                local KeybindLabel = Instance.new("TextLabel")
                local KeybindValue = Instance.new("TextButton")
                local KeybindValueCorner = Instance.new("UICorner")
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = SectionContent
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(1, 0, 0, 40)
                
                KeybindButton.Name = "KeybindButton"
                KeybindButton.Parent = KeybindModule
                KeybindButton.BackgroundColor3 = config.Keybind_Color
                KeybindButton.BackgroundTransparency = 0.1
                KeybindButton.BorderSizePixel = 0
                KeybindButton.Size = UDim2.new(1, 0, 0, 40)
                KeybindButton.AutoButtonColor = false
                KeybindButton.Font = Enum.Font.GothamSemibold
                KeybindButton.Text = ""
                
                KeybindCorner.CornerRadius = UDim.new(0, 8)
                KeybindCorner.Name = "KeybindCorner"
                KeybindCorner.Parent = KeybindButton
                
                KeybindLabel.Name = "KeybindLabel"
                KeybindLabel.Parent = KeybindButton
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Position = UDim2.new(0.05, 0, 0, 0)
                KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
                KeybindLabel.Font = Enum.Font.GothamSemibold
                KeybindLabel.Text = text
                KeybindLabel.TextColor3 = config.TextColor
                KeybindLabel.TextSize = 14
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindButton
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BackgroundTransparency = 0.1
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.7, 0, 0.5, -11)
                KeybindValue.Size = UDim2.new(0, 70, 0, 22)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 12
                
                KeybindValueCorner.CornerRadius = UDim.new(0, 6)
                KeybindValueCorner.Name = "KeybindValueCorner"
                KeybindValueCorner.Parent = KeybindValue
                
                KeybindButton.MouseEnter:Connect(function()
                    services.TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Keybind_Color.R * 255 * 1.1),
                            math.floor(config.Keybind_Color.G * 255 * 1.1),
                            math.floor(config.Keybind_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                KeybindButton.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
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
                local TextboxButton = Instance.new("TextButton")
                local TextboxCorner = Instance.new("UICorner")
                local TextboxLabel = Instance.new("TextLabel")
                local TextboxInput = Instance.new("TextBox")
                local TextboxInputCorner = Instance.new("UICorner")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = SectionContent
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(1, 0, 0, 40)
                
                TextboxButton.Name = "TextboxButton"
                TextboxButton.Parent = TextboxModule
                TextboxButton.BackgroundColor3 = config.Textbox_Color
                TextboxButton.BackgroundTransparency = 0.1
                TextboxButton.BorderSizePixel = 0
                TextboxButton.Size = UDim2.new(1, 0, 0, 40)
                TextboxButton.AutoButtonColor = false
                TextboxButton.Font = Enum.Font.GothamSemibold
                TextboxButton.Text = ""
                
                TextboxCorner.CornerRadius = UDim.new(0, 8)
                TextboxCorner.Name = "TextboxCorner"
                TextboxCorner.Parent = TextboxButton
                
                TextboxLabel.Name = "TextboxLabel"
                TextboxLabel.Parent = TextboxButton
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Position = UDim2.new(0.05, 0, 0, 0)
                TextboxLabel.Size = UDim2.new(0.4, 0, 1, 0)
                TextboxLabel.Font = Enum.Font.GothamSemibold
                TextboxLabel.Text = text
                TextboxLabel.TextColor3 = config.TextColor
                TextboxLabel.TextSize = 14
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxInput.Name = "TextboxInput"
                TextboxInput.Parent = TextboxButton
                TextboxInput.BackgroundColor3 = config.Bg_Color
                TextboxInput.BackgroundTransparency = 0.1
                TextboxInput.BorderSizePixel = 0
                TextboxInput.Position = UDim2.new(0.5, 0, 0.5, -11)
                TextboxInput.Size = UDim2.new(0, 120, 0, 22)
                TextboxInput.Font = Enum.Font.Gotham
                TextboxInput.Text = default
                TextboxInput.TextColor3 = config.TextColor
                TextboxInput.TextSize = 12
                TextboxInput.PlaceholderColor3 = config.SecondaryTextColor
                
                TextboxInputCorner.CornerRadius = UDim.new(0, 6)
                TextboxInputCorner.Name = "TextboxInputCorner"
                TextboxInputCorner.Parent = TextboxInput
                
                TextboxButton.MouseEnter:Connect(function()
                    services.TweenService:Create(TextboxButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Textbox_Color.R * 255 * 1.1),
                            math.floor(config.Textbox_Color.G * 255 * 1.1),
                            math.floor(config.Textbox_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                TextboxButton.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Textbox_Color
                    }):Play()
                end)
                
                TextboxInput.FocusLost:Connect(function()
                    if TextboxInput.Text == "" then
                        TextboxInput.Text = default
                    end
                    FengUI.flags[flag] = TextboxInput.Text
                    callback(TextboxInput.Text)
                    
                    DigitalParticleExplosion(TextboxInput)
                end)
                
                TextboxInput:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    TextboxInput.Size = UDim2.new(0, math.max(TextboxInput.TextBounds.X + 20, 80), 0, 22)
                end)
                
                TextboxInput.Size = UDim2.new(0, math.max(TextboxInput.TextBounds.X + 20, 80), 0, 22)
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
                local SliderButton = Instance.new("TextButton")
                local SliderCorner = Instance.new("UICorner")
                local SliderLabel = Instance.new("TextLabel")
                local SliderBar = Instance.new("Frame")
                local SliderBarCorner = Instance.new("UICorner")
                local SliderFill = Instance.new("Frame")
                local SliderFillCorner = Instance.new("UICorner")
                local SliderValue = Instance.new("TextLabel")
                local SliderHandle = Instance.new("Frame")
                local SliderHandleCorner = Instance.new("UICorner")
                
                SliderModule.Name = "SliderModule"
                SliderModule.Parent = SectionContent
                SliderModule.BackgroundTransparency = 1
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(1, 0, 0, 60)
                
                SliderButton.Name = "SliderButton"
                SliderButton.Parent = SliderModule
                SliderButton.BackgroundColor3 = config.Slider_Color
                SliderButton.BackgroundTransparency = 0.1
                SliderButton.BorderSizePixel = 0
                SliderButton.Size = UDim2.new(1, 0, 0, 60)
                SliderButton.AutoButtonColor = false
                SliderButton.Font = Enum.Font.GothamSemibold
                SliderButton.Text = ""
                
                SliderCorner.CornerRadius = UDim.new(0, 8)
                SliderCorner.Name = "SliderCorner"
                SliderCorner.Parent = SliderButton
                
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Parent = SliderButton
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
                SliderLabel.Size = UDim2.new(0.9, 0, 0, 20)
                SliderLabel.Font = Enum.Font.GothamSemibold
                SliderLabel.Text = text
                SliderLabel.TextColor3 = config.TextColor
                SliderLabel.TextSize = 14
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderButton
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.05, 0, 0.6, -3)
                SliderBar.Size = UDim2.new(0.7, 0, 0, 6)
                
                SliderBarCorner.CornerRadius = UDim.new(1, 0)
                SliderBarCorner.Name = "SliderBarCorner"
                SliderBarCorner.Parent = SliderBar
                
                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderBar
                SliderFill.BackgroundColor3 = config.SliderBar_Color
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Name = "SliderFillCorner"
                SliderFillCorner.Parent = SliderFill
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderButton
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(0.8, 0, 0.1, 0)
                SliderValue.Size = UDim2.new(0.15, 0, 0, 20)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.AccentColor
                SliderValue.TextSize = 14
                
                SliderHandle.Name = "SliderHandle"
                SliderHandle.Parent = SliderBar
                SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderHandle.BorderSizePixel = 0
                SliderHandle.Position = UDim2.new((default - min)/(max - min), -8, 0.5, -8)
                SliderHandle.Size = UDim2.new(0, 16, 0, 16)
                
                SliderHandleCorner.CornerRadius = UDim.new(1, 0)
                SliderHandleCorner.Name = "SliderHandleCorner"
                SliderHandleCorner.Parent = SliderHandle
                
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
                        
                        services.TweenService:Create(SliderFill, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        services.TweenService:Create(SliderHandle, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Position = UDim2.new(percent, -8, 0.5, -8)
                        }):Play()
                        
                        callback(tonumber(value))
                        
                        DigitalParticleExplosion(SliderHandle)
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
                
                SliderHandle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
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
            
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = nil
                
                local DropdownModule = Instance.new("Frame")
                local DropdownButton = Instance.new("TextButton")
                local DropdownCorner = Instance.new("UICorner")
                local DropdownLabel = Instance.new("TextLabel")
                local DropdownToggle = Instance.new("TextButton")
                local DropdownToggleCorner = Instance.new("UICorner")
                local DropdownContent = Instance.new("Frame")
                local DropdownContentCorner = Instance.new("UICorner")
                local DropdownList = Instance.new("UIListLayout")
                
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = SectionContent
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(1, 0, 0, 40)
                
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = DropdownModule
                DropdownButton.BackgroundColor3 = config.Dropdown_Color
                DropdownButton.BackgroundTransparency = 0.1
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Size = UDim2.new(1, 0, 0, 40)
                DropdownButton.AutoButtonColor = false
                DropdownButton.Font = Enum.Font.GothamSemibold
                DropdownButton.Text = ""
                
                DropdownCorner.CornerRadius = UDim.new(0, 8)
                DropdownCorner.Name = "DropdownCorner"
                DropdownCorner.Parent = DropdownButton
                
                DropdownLabel.Name = "DropdownLabel"
                DropdownLabel.Parent = DropdownButton
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0.05, 0, 0, 0)
                DropdownLabel.Size = UDim2.new(0.6, 0, 1, 0)
                DropdownLabel.Font = Enum.Font.GothamSemibold
                DropdownLabel.Text = text
                DropdownLabel.TextColor3 = config.TextColor
                DropdownLabel.TextSize = 14
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownToggle.Name = "DropdownToggle"
                DropdownToggle.Parent = DropdownButton
                DropdownToggle.BackgroundColor3 = config.Bg_Color
                DropdownToggle.BackgroundTransparency = 0.1
                DropdownToggle.BorderSizePixel = 0
                DropdownToggle.Position = UDim2.new(0.8, 0, 0.5, -11)
                DropdownToggle.Size = UDim2.new(0, 70, 0, 22)
                DropdownToggle.AutoButtonColor = false
                DropdownToggle.Font = Enum.Font.Gotham
                DropdownToggle.Text = "选择"
                DropdownToggle.TextColor3 = config.TextColor
                DropdownToggle.TextSize = 12
                
                createHologramEffect(DropdownToggle, 0.8)
                
                DropdownToggleCorner.CornerRadius = UDim.new(0, 6)
                DropdownToggleCorner.Name = "DropdownToggleCorner"
                DropdownToggleCorner.Parent = DropdownToggle
                
                DropdownContent.Name = "DropdownContent"
                DropdownContent.Parent = DropdownModule
                DropdownContent.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
                DropdownContent.BackgroundTransparency = 0.1
                DropdownContent.BorderSizePixel = 0
                DropdownContent.Position = UDim2.new(0, 0, 1, 5)
                DropdownContent.Size = UDim2.new(1, 0, 0, 0)
                
                DropdownContentCorner.CornerRadius = UDim.new(0, 8)
                DropdownContentCorner.Name = "DropdownContentCorner"
                DropdownContentCorner.Parent = DropdownContent
                
                DropdownList.Name = "DropdownList"
                DropdownList.Parent = DropdownContent
                DropdownList.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownList.Padding = UDim.new(0, 5)
                
                local open = false
                local ToggleDropVis = function()
                    open = not open
                    DropdownToggle.Text = (open and "取消" or "选择")
                    
                    services.TweenService:Create(DropdownContent, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, open and (DropdownList.AbsoluteContentSize.Y + 10) or 0)
                    }):Play()
                    
                    create3DFlipAnimation(DropdownToggle, 0.3)
                end
                
                DropdownToggle.MouseButton1Click:Connect(ToggleDropVis)
                
                DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then
                        DropdownContent.Size = UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 10)
                    end
                end)
                
                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    local OptionCorner = Instance.new("UICorner")
                    
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownContent
                    Option.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                    Option.BackgroundTransparency = 0.1
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(1, -10, 0, 30)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 13
                    
                    OptionCorner.CornerRadius = UDim.new(0, 6)
                    OptionCorner.Name = "OptionCorner"
                    OptionCorner.Parent = Option
                    
                    Option.MouseEnter:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(40, 40, 65)
                        }):Play()
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                        }):Play()
                    end)
                    
                    Option.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(Option)
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownToggle.Text = Option.Text
                        FengUI.flags[flag] = Option.Text
                    end)
                end
                
                funcs.RemoveOption = function(self, option)
                    local option = DropdownContent:FindFirstChild("Option_" .. option)
                    if option then
                        option:Destroy()
                    end
                end
                
                funcs.SetOptions = function(self, options)
                    for _, v in next, DropdownContent:GetChildren() do
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
    if QuantumUI then
        QuantumUI:Destroy()
    end
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    QuantumUI.Enabled = ToggleUI
    Main.Visible = not ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI