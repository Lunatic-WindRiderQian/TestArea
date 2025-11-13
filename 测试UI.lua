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

-- 高级背景纹理
local function createAdvancedBackground(parent)
    local backgroundContainer = Instance.new("Frame")
    backgroundContainer.Name = "AdvancedBackground"
    backgroundContainer.BackgroundTransparency = 1
    backgroundContainer.Size = UDim2.new(1, 0, 1, 0)
    backgroundContainer.ZIndex = 0
    backgroundContainer.Parent = parent
    
    -- 网格线效果
    local gridPattern = Instance.new("Frame")
    gridPattern.Name = "GridPattern"
    gridPattern.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    gridPattern.BackgroundTransparency = 0.8
    gridPattern.Size = UDim2.new(1, 0, 1, 0)
    gridPattern.ZIndex = 1
    gridPattern.Parent = backgroundContainer
    
    local gridUIStroke = Instance.new("UIStroke")
    gridUIStroke.Color = Color3.fromRGB(40, 40, 40)
    gridUIStroke.Thickness = 1
    gridUIStroke.Transparency = 0.7
    gridUIStroke.Parent = gridPattern
    
    -- 渐变覆盖层
    local gradientOverlay = Instance.new("Frame")
    gradientOverlay.Name = "GradientOverlay"
    gradientOverlay.BackgroundTransparency = 1
    gradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    gradientOverlay.ZIndex = 2
    gradientOverlay.Parent = backgroundContainer
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.3, 0.6),
        NumberSequenceKeypoint.new(0.7, 0.6),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 10)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
    })
    gradient.Parent = gradientOverlay
    
    return backgroundContainer
end

-- 进场特效函数
local function createEntranceEffect(mainFrame)
    -- 初始状态：缩小并透明
    mainFrame.Size = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Visible = true
    
    -- 第一阶段：快速放大并淡入
    services.TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 320),
        BackgroundTransparency = 0.5
    }):Play()
    
    task.wait(0.4)
    
    -- 第二阶段：调整到最终大小并完全显示
    services.TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 280),
        BackgroundTransparency = 0.2
    }):Play()
    
    -- 添加粒子进场效果
    task.spawn(function()
        for i = 1, 8 do
            local particle = Instance.new("Frame")
            particle.Name = "EntranceParticle"
            particle.BackgroundColor3 = config.AccentColor
            particle.BackgroundTransparency = 0.3
            particle.Size = UDim2.new(0, 4, 0, 4)
            particle.Position = UDim2.new(0.5, 0, 0.5, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            particle.ZIndex = 20
            particle.Parent = mainFrame
            
            local angle = (i / 8) * math.pi * 2
            local distance = 100
            
            services.TweenService:Create(particle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    0.5, math.cos(angle) * distance,
                    0.5, math.sin(angle) * distance
                ),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 2)
            }):Play()
            
            delay(0.6, function()
                particle:Destroy()
            end)
        end
    end)
end

-- 出场特效函数
local function createExitEffect(mainFrame, callback)
    -- 添加粒子出场效果
    task.spawn(function()
        for i = 1, 8 do
            local particle = Instance.new("Frame")
            particle.Name = "ExitParticle"
            particle.BackgroundColor3 = config.AccentColor
            particle.BackgroundTransparency = 0.3
            particle.Size = UDim2.new(0, 4, 0, 4)
            particle.Position = UDim2.new(
                0.5, math.cos((i / 8) * math.pi * 2) * 100,
                0.5, math.sin((i / 8) * math.pi * 2) * 100
            )
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            particle.ZIndex = 20
            particle.Parent = mainFrame
            
            services.TweenService:Create(particle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 2, 0, 2)
            }):Play()
            
            delay(0.6, function()
                particle:Destroy()
            end)
        end
    end)
    
    -- 缩小并淡出
    services.TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    }):Play()
    
    delay(0.4, function()
        if callback then
            callback()
        end
    end)
end

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
Main.BackgroundTransparency = 1 -- 初始完全透明，用于进场特效
Main.Position = UDim2.new(0.5, 0, 0.4, 0)
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
MainStroke.Transparency = 0.5

local neonStroke = Instance.new("UIStroke")
neonStroke.Parent = Main
neonStroke.Thickness = 2
neonStroke.Transparency = 0.7
neonStroke.LineJoinMode = Enum.LineJoinMode.Round
startNeonFlowEffect(neonStroke, "Color", 0.01)

createPulseGlow(neonStroke)

-- 创建高级背景
createAdvancedBackground(Main)

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 32) -- 标题栏高度调整为32
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

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 6) -- 调整位置以适应新高度
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.TextSize = 16
CloseButton.ZIndex = 10

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 18,
        Position = UDim2.new(1, -26, 0, 5)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 16,
        Position = UDim2.new(1, -25, 0, 6)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 14,
        Position = UDim2.new(1, -24, 0, 7)
    }):Play()
    
    -- 关闭时使用出场特效
    createExitEffect(Main, function()
        FengYu:Destroy()
    end)
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 34) -- 调整位置以适应新的标题栏高度
TabMain.Size = UDim2.new(0, 360, 0, 246) -- 调整高度以适应新的标题栏高度

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.2
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 32) -- 调整位置以适应新的标题栏高度
Side.Size = UDim2.new(0, 90, 0, 248) -- 调整高度以适应新的标题栏高度

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Side

createHologramEffect(Side, 0.3)

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 5)
TabBtns.Size = UDim2.new(0, 90, 0, 238) -- 调整高度以适应新的Side高度
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None

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

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.009, 0)
ScriptTitle.Size = UDim2.new(0, 90, 0, 20)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.Text = "傻逼谁让你破解我的UI了"
ScriptTitle.TextColor3 = config.AccentColor
ScriptTitle.TextSize = 16
ScriptTitle.TextScaled = false
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Center
ScriptTitle.Visible = false

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

-- 添加进场特效
createEntranceEffect(Main)

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
    
    function window.Tab(window, name, icon)
        local Tab = Instance.new("ScrollingFrame")
        local TabIco = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabBtn = Instance.new("TextButton")
        local TabL = Instance.new("UIListLayout")
        
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
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
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
            
            function section.MusicPlayer(section, title, defaultPlaylist)
    local MusicPlayerModule = Instance.new("Frame")
    MusicPlayerModule.Name = "MusicPlayerModule"
    MusicPlayerModule.Parent = Objs
    MusicPlayerModule.BackgroundTransparency = 1
    MusicPlayerModule.BorderSizePixel = 0
    MusicPlayerModule.Size = UDim2.new(0, 330, 0, 160)
    
    local PlayerContainer = Instance.new("Frame")
    PlayerContainer.Name = "PlayerContainer"
    PlayerContainer.Parent = MusicPlayerModule
    PlayerContainer.BackgroundColor3 = config.TabColor
    PlayerContainer.BackgroundTransparency = 0.2
    PlayerContainer.Size = UDim2.new(1, 0, 0, 160)
    
    local PlayerCorner = Instance.new("UICorner")
    PlayerCorner.CornerRadius = UDim.new(0, 8)
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
    AlbumArt.BackgroundTransparency = 0.2
    AlbumArt.Position = UDim2.new(0.03, 0, 0.1, 0)
    AlbumArt.Size = UDim2.new(0, 50, 0, 50)
    
    local AlbumCorner = Instance.new("UICorner")
    AlbumCorner.CornerRadius = UDim.new(0, 6)
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
    ProgressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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
        button.BackgroundColor3 = isMain and config.AccentColor or Color3.fromRGB(180, 180, 180)
        button.BackgroundTransparency = 0.1
        button.Position = position
        button.Size = size
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = isMain and config.TextColor or Color3.fromRGB(50, 50, 50)
        button.TextSize = isMain and 16 or 12
        button.ZIndex = 5
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = button
        
        local buttonGlow = Instance.new("UIStroke")
        buttonGlow.Parent = button
        buttonGlow.Color = isMain and config.AccentColor or Color3.fromRGB(150, 150, 150)
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
                BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            }):Play()
            services.TweenService:Create(loopGlow, TweenInfo.new(0.3), {
                Transparency = 0.3,
                Thickness = 2
            }):Play()
        else
            services.TweenService:Create(LoopButton, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(180, 180, 180)
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
            
            function section.Image(section, imageId, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, 330, 0, sizeY or 120)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundColor3 = config.Bg_Color
                ImageLabel.BackgroundTransparency = 0.2
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, 320), 0, sizeY or 120)
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
                    DropdownModule.Size = UDim2.new(0, 330, 0, (open and math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150) or 36))
                    
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
                    if not open then
                        return
                    end
                    DropdownModule.Size = UDim2.new(0, 330, 0, math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150))
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