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
FengUI.tabContainers = {} -- 存储不同卡片的Tab容器

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
Main.BackgroundColor3 = config.Bg_Color
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 450, 0, 280)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

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
CardsContainer.Size = UDim2.new(1, 0, 1, 0)
CardsContainer.Visible = false

local CardsLayout = Instance.new("UIGridLayout")
CardsLayout.Parent = CardsContainer
CardsLayout.CellSize = UDim2.new(0, 120, 0, 120)
CardsLayout.CellPadding = UDim2.new(0, 10, 0, 10)
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
CardsLayout.StartCorner = Enum.StartCorner.TopLeft

-- 主Tab容器（用于存放所有卡片的Tab内容）
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
MainSideContainer.Size = UDim2.new(0, 90, 0, 245)
MainSideContainer.Visible = false

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = MainSideContainer

createHologramEffect(MainSideContainer, 0.3)

-- 删除原来的ScriptTitle，改为返回按钮
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
ReturnToCardsButton.Text = "← 返回卡片"
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

ReturnToCardsButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(ReturnToCardsButton)
    showCards()  -- 调用显示卡片的函数
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
        BackgroundTransparency = 0.2,
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
        BackgroundTransparency = 0.2
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
            BackgroundTransparency = 0.2
        }):Play()
    end
    
    task.wait(0.2)
    
    if not FengUI.showingCards then
        MainTabContainer.Visible = true
        MainSideContainer.Visible = true
    end
    
    DigitalParticleExplosion(Main)
end

local function showCards()
    FengUI.showingCards = true
    CardsContainer.Visible = true
    MainSideContainer.Visible = false
    MainTabContainer.Visible = false
    
    services.TweenService:Create(CardsContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(MainSideContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
end

local function hideCards()
    FengUI.showingCards = false
    services.TweenService:Create(CardsContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.4)
    CardsContainer.Visible = false
    MainSideContainer.Visible = true
    MainTabContainer.Visible = true
    
    services.TweenService:Create(MainSideContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2
    }):Play()
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
    
    -- 添加 card 方法
    function window.card(window, name, description, icon)
        -- 创建卡片
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
        CardIcon.Size = UDim2.new(0, 50, 0, 50)
        CardIcon.Image = "rbxassetid://" .. tostring(icon or "84830962019412")
        CardIcon.ImageColor3 = config.AccentColor
        
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
        CardTitle.TextSize = 14
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
        CardDescription.TextSize = 11
        CardDescription.TextScaled = false
        CardDescription.TextWrapped = true
        
        -- 为这个卡片创建一个对应的Tab容器和侧边栏
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
        tabBtns.Position = UDim2.new(0, 0, 0, 25)  -- 给返回按钮留出空间
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
        
        -- 存储容器引用
        FengUI.tabContainers[name] = {
            tabContainer = tabContainer,
            sideContainer = sideContainer,
            tabBtns = tabBtns
        }
        
        -- 在Tab容器中添加左侧图片
        local TabImageContainer = Instance.new("Frame")
        TabImageContainer.Name = "TabImageContainer"
        TabImageContainer.Parent = tabContainer
        TabImageContainer.BackgroundTransparency = 1
        TabImageContainer.Size = UDim2.new(0, 100, 1, 0)
        
        local TabImage = Instance.new("ImageLabel")
        TabImage.Name = "TabImage"
        TabImage.Parent = TabImageContainer
        TabImage.BackgroundColor3 = config.Bg_Color
        TabImage.BackgroundTransparency = 0.2
        TabImage.AnchorPoint = Vector2.new(0.5, 0.5)
        TabImage.Position = UDim2.new(0.5, 0, 0.5, 0)
        TabImage.Size = UDim2.new(0, 80, 0, 80)
        TabImage.Image = "rbxassetid://" .. tostring(icon or "84830962019412")
        TabImage.ImageColor3 = config.AccentColor
        
        local TabImageCorner = Instance.new("UICorner")
        TabImageCorner.CornerRadius = UDim.new(0, 12)
        TabImageCorner.Parent = TabImage
        
        local tabImageGlow = Instance.new("UIStroke")
        tabImageGlow.Parent = TabImage
        tabImageGlow.Color = config.AccentColor
        tabImageGlow.Thickness = 2
        tabImageGlow.Transparency = 0.7
        
        startNeonFlowEffect(tabImageGlow, "Color", 0.008)
        createPulseGlow(tabImageGlow)
        
        -- 在Tab容器中添加功能区域
        local TabContent = Instance.new("Frame")
        TabContent.Name = "TabContent"
        TabContent.Parent = tabContainer
        TabContent.BackgroundTransparency = 1
        TabContent.Position = UDim2.new(0, 100, 0, 0)
        TabContent.Size = UDim2.new(0, 260, 1, 0)
        
        -- 在功能区域中添加返回按钮
        local ReturnButton = Instance.new("TextButton")
        ReturnButton.Name = "ReturnButton"
        ReturnButton.Parent = TabContent
        ReturnButton.BackgroundColor3 = config.Button_Color
        ReturnButton.BackgroundTransparency = 0.2
        ReturnButton.BorderSizePixel = 0
        ReturnButton.Size = UDim2.new(0, 260, 0, 25)
        ReturnButton.AutoButtonColor = false
        ReturnButton.Font = Enum.Font.GothamBold
        ReturnButton.Text = "← 返回卡片选择"
        ReturnButton.TextColor3 = config.TextColor
        ReturnButton.TextSize = 12
        ReturnButton.TextScaled = true
        
        local ReturnButtonCorner = Instance.new("UICorner")
        ReturnButtonCorner.CornerRadius = UDim.new(0, 6)
        ReturnButtonCorner.Parent = ReturnButton
        
        local returnGlow = Instance.new("UIStroke")
        returnGlow.Parent = ReturnButton
        returnGlow.Color = config.AccentColor
        returnGlow.Thickness = 1
        returnGlow.Transparency = 0.8
        
        startNeonFlowEffect(returnGlow, "Color", 0.01)
        createPulseGlow(returnGlow)
        
        ReturnButton.MouseEnter:Connect(function()
            services.TweenService:Create(ReturnButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
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
        
        ReturnButton.MouseLeave:Connect(function()
            services.TweenService:Create(ReturnButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                BackgroundColor3 = config.Button_Color
            }):Play()
            services.TweenService:Create(returnGlow, TweenInfo.new(0.2), {
                Thickness = 1,
                Transparency = 0.8
            }):Play()
        end)
        
        ReturnButton.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(ReturnButton)
            showCards()  -- 调用显示卡片的函数
        end)
        
        Card.MouseEnter:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 125, 0, 125)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 3,
                Transparency = 0.4
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 55, 0, 55)
            }):Play()
        end)
        
        Card.MouseLeave:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 120, 0, 120)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 2,
                Transparency = 0.7
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
        end)
        
        local function showTabContainer()
            -- 隐藏所有其他容器
            for _, containerData in pairs(FengUI.tabContainers) do
                containerData.tabContainer.Visible = false
                containerData.sideContainer.Visible = false
            end
            
            -- 显示当前卡片的容器
            tabContainer.Visible = true
            sideContainer.Visible = true
        end
        
        Card.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(Card)
            hideCards()
            task.wait(0.4)
            showTabContainer()
        end)
        
        -- 返回一个可以添加Tab的对象
        local cardObj = {}
        
        function cardObj.Tab(cardObj, tabName, tabIcon)
            -- 创建Tab按钮
            local TabIco = Instance.new("ImageLabel")
            local TabText = Instance.new("TextLabel")
            local TabBtn = Instance.new("TextButton")
            
            TabIco.Name = "TabIco"
            TabIco.Parent = tabBtns
            TabIco.BackgroundTransparency = 1
            TabIco.BorderSizePixel = 0
            TabIco.Size = UDim2.new(0, 22, 0, 22)
            TabIco.Image = tabIcon or "rbxassetid://84830962019412"
            TabIco.ImageTransparency = 0.5
            
            startNeonFlowEffect(TabIco, "ImageColor3", 0.005)
            
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
            
            TabBtn.Name = "TabBtn"
            TabBtn.Parent = TabIco
            TabBtn.BackgroundTransparency = 1
            TabBtn.BorderSizePixel = 0
            TabBtn.Size = UDim2.new(0, 90, 0, 22)
            TabBtn.AutoButtonColor = false
            TabBtn.Font = Enum.Font.SourceSans
            TabBtn.Text = ""
            
            -- 创建Tab内容容器
            local Tab = Instance.new("ScrollingFrame")
            Tab.Name = "Tab_" .. tabName
            Tab.Parent = TabContent
            Tab.Active = true
            Tab.BackgroundTransparency = 1
            Tab.Size = UDim2.new(1, 0, 1, -30)  -- 给返回按钮留出空间
            Tab.Position = UDim2.new(0, 0, 0, 30)
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
            
            -- 返回Tab对象，可以添加section等
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
                SectionText.Size = UDim2.new(0, 240, 0, 36)  -- 调整宽度适应新布局
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
                    BtnModule.Size = UDim2.new(0, 250, 0, 36)  -- 调整宽度适应新布局
                    
                    Btn.Name = "Btn"
                    Btn.Parent = BtnModule
                    Btn.BackgroundColor3 = config.Button_Color
                    Btn.BackgroundTransparency = 0.2
                    Btn.BorderSizePixel = 0
                    Btn.Size = UDim2.new(0, 250, 0, 36)
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
                
                -- 其他section方法（Toggle, Slider, Textbox, Dropdown等）可以按照类似方式实现
                -- 由于代码过长，这里省略具体实现，你可以将原来的section方法复制到这里
                -- 只需要调整宽度为250以适应新布局
                
                return section
            end
            
            return tabObj
        end
        
        return cardObj
    end
    
    function window.Tab(window, name, icon)
        -- 为每个卡片创建独立的Tab容器和侧边栏
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
        tabBtns.Position = UDim2.new(0, 0, 0, 25)  -- 给返回按钮留出空间
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
        
        -- 存储容器引用
        FengUI.tabContainers[name] = {
            tabContainer = tabContainer,
            sideContainer = sideContainer,
            tabBtns = tabBtns
        }
        
        -- 在Tab容器中添加左侧图片
        local TabImageContainer = Instance.new("Frame")
        TabImageContainer.Name = "TabImageContainer"
        TabImageContainer.Parent = tabContainer
        TabImageContainer.BackgroundTransparency = 1
        TabImageContainer.Size = UDim2.new(0, 100, 1, 0)
        
        local TabImage = Instance.new("ImageLabel")
        TabImage.Name = "TabImage"
        TabImage.Parent = TabImageContainer
        TabImage.BackgroundColor3 = config.Bg_Color
        TabImage.BackgroundTransparency = 0.2
        TabImage.AnchorPoint = Vector2.new(0.5, 0.5)
        TabImage.Position = UDim2.new(0.5, 0, 0.5, 0)
        TabImage.Size = UDim2.new(0, 80, 0, 80)
        TabImage.Image = "rbxassetid://" .. tostring(icon or "84830962019412")
        TabImage.ImageColor3 = config.AccentColor
        
        local TabImageCorner = Instance.new("UICorner")
        TabImageCorner.CornerRadius = UDim.new(0, 12)
        TabImageCorner.Parent = TabImage
        
        local tabImageGlow = Instance.new("UIStroke")
        tabImageGlow.Parent = TabImage
        tabImageGlow.Color = config.AccentColor
        tabImageGlow.Thickness = 2
        tabImageGlow.Transparency = 0.7
        
        startNeonFlowEffect(tabImageGlow, "Color", 0.008)
        createPulseGlow(tabImageGlow)
        
        -- 在Tab容器中添加功能区域
        local TabContent = Instance.new("Frame")
        TabContent.Name = "TabContent"
        TabContent.Parent = tabContainer
        TabContent.BackgroundTransparency = 1
        TabContent.Position = UDim2.new(0, 100, 0, 0)
        TabContent.Size = UDim2.new(0, 260, 1, 0)
        
        -- 在功能区域中添加返回按钮
        local ReturnButton = Instance.new("TextButton")
        ReturnButton.Name = "ReturnButton"
        ReturnButton.Parent = TabContent
        ReturnButton.BackgroundColor3 = config.Button_Color
        ReturnButton.BackgroundTransparency = 0.2
        ReturnButton.BorderSizePixel = 0
        ReturnButton.Size = UDim2.new(0, 260, 0, 25)
        ReturnButton.AutoButtonColor = false
        ReturnButton.Font = Enum.Font.GothamBold
        ReturnButton.Text = "← 返回卡片选择"
        ReturnButton.TextColor3 = config.TextColor
        ReturnButton.TextSize = 12
        ReturnButton.TextScaled = true
        
        local ReturnButtonCorner = Instance.new("UICorner")
        ReturnButtonCorner.CornerRadius = UDim.new(0, 6)
        ReturnButtonCorner.Parent = ReturnButton
        
        local returnGlow = Instance.new("UIStroke")
        returnGlow.Parent = ReturnButton
        returnGlow.Color = config.AccentColor
        returnGlow.Thickness = 1
        returnGlow.Transparency = 0.8
        
        startNeonFlowEffect(returnGlow, "Color", 0.01)
        createPulseGlow(returnGlow)
        
        ReturnButton.MouseEnter:Connect(function()
            services.TweenService:Create(ReturnButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
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
        
        ReturnButton.MouseLeave:Connect(function()
            services.TweenService:Create(ReturnButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                BackgroundColor3 = config.Button_Color
            }):Play()
            services.TweenService:Create(returnGlow, TweenInfo.new(0.2), {
                Thickness = 1,
                Transparency = 0.8
            }):Play()
        end)
        
        ReturnButton.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(ReturnButton)
            showCards()  -- 调用显示卡片的函数
        end)
        
        local Tab = Instance.new("ScrollingFrame")
        local TabIco = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabBtn = Instance.new("TextButton")
        local TabL = Instance.new("UIListLayout")
        
        Tab.Name = "Tab"
        Tab.Parent = TabContent
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, -30)  -- 给返回按钮留出空间
        Tab.Position = UDim2.new(0, 0, 0, 30)
        Tab.ScrollBarThickness = 2
        Tab.ScrollBarImageTransparency = 0.5
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabIco.Name = "TabIco"
        TabIco.Parent = tabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 22, 0, 22)
        TabIco.Image = icon or "rbxassetid://84830962019412"
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
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
        -- 创建卡片
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
        CardIcon.Position = UDim2.new(0.5, 0, 0.4, 0)
        CardIcon.Size = UDim2.new(0, 50, 0, 50)
        CardIcon.Image = icon or "rbxassetid://84830962019412"
        CardIcon.ImageColor3 = config.AccentColor
        
        local CardTitle = Instance.new("TextLabel")
        CardTitle.Name = "CardTitle"
        CardTitle.Parent = Card
        CardTitle.BackgroundTransparency = 1
        CardTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        CardTitle.Position = UDim2.new(0.5, 0, 0.8, 0)
        CardTitle.Size = UDim2.new(0.8, 0, 0, 25)
        CardTitle.Font = Enum.Font.GothamBold
        CardTitle.Text = name
        CardTitle.TextColor3 = config.TextColor
        CardTitle.TextSize = 14
        CardTitle.TextScaled = true
        
        Card.MouseEnter:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 125, 0, 125)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 3,
                Transparency = 0.4
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 55, 0, 55)
            }):Play()
        end)
        
        Card.MouseLeave:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 120, 0, 120)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 2,
                Transparency = 0.7
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
        end)
        
        local function showTabContainer()
            -- 隐藏所有其他容器
            for _, containerData in pairs(FengUI.tabContainers) do
                containerData.tabContainer.Visible = false
                containerData.sideContainer.Visible = false
            end
            
            -- 显示当前卡片的容器
            tabContainer.Visible = true
            sideContainer.Visible = true
            
            -- 切换到第一个Tab
            if FengUI.currentTab == nil then
                switchTab({ TabIco, Tab })
            end
        end
        
        Card.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(Card)
            hideCards()
            task.wait(0.4)
            showTabContainer()
        end)
        
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
            Section.Size = UDim2.new(0.95, 0, 0, 36)
            
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.088, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 240, 0, 36)  -- 调整宽度适应新布局
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
            
            -- 这里省略了section的其他方法（Button, Toggle, Slider等）
            -- 你需要将这些方法从原来的代码中复制过来，并调整宽度为250以适应新布局
            
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

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI