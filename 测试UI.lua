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

-- 极致黑蓝配色方案
local config = {
    MainColor = Color3.fromRGB(3, 5, 15),
    DeepSpaceColor = Color3.fromRGB(1, 2, 10),
    NebulaColor1 = Color3.fromRGB(0, 40, 80),
    NebulaColor2 = Color3.fromRGB(20, 60, 120),
    AccentColor = Color3.fromRGB(0, 180, 255),
    AccentGlow = Color3.fromRGB(0, 220, 255),
    TextColor = Color3.fromRGB(240, 248, 255),
    SecondaryTextColor = Color3.fromRGB(180, 210, 240),
    ElementColor = Color3.fromRGB(15, 25, 45),
    ElementTransparency = 0.9,
    GlassEffect = Color3.fromRGB(255, 255, 255),
    
    -- 第一个文件的配置
    TabColor = Color3.fromRGB(15, 25, 45),
    Bg_Color = Color3.fromRGB(3, 5, 15),
    Zy_Color = Color3.fromRGB(3, 5, 15),
    Button_Color = Color3.fromRGB(15, 25, 45),
    Textbox_Color = Color3.fromRGB(15, 25, 45),
    Dropdown_Color = Color3.fromRGB(15, 25, 45),
    Keybind_Color = Color3.fromRGB(15, 25, 45),
    Label_Color = Color3.fromRGB(15, 25, 45),
    Slider_Color = Color3.fromRGB(15, 25, 45),
    SliderBar_Color = Color3.fromRGB(0, 180, 255),
    Toggle_Color = Color3.fromRGB(15, 25, 45),
    Toggle_Off = Color3.fromRGB(50, 60, 90),
    Toggle_On = Color3.fromRGB(0, 180, 255),
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

-- 音乐播放器函数
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

-- 数字粒子爆炸效果
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
        explosionCenter.BackgroundColor3 = config.AccentColor
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
        centerGlow.Color = config.AccentColor
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
        shockwaveStroke.Color = config.AccentColor
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

-- 霓虹灯流动效果
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

-- 极致深空背景效果
local function createUltimateSpaceBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "UltimateSpaceBackground"
    background.BackgroundColor3 = config.DeepSpaceColor
    background.BackgroundTransparency = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.ZIndex = 0
    background.Parent = parent
    
    -- 多层渐变叠加
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
    
    -- 动态星空
    local starsContainer = Instance.new("Frame")
    starsContainer.Name = "StarsContainer"
    starsContainer.BackgroundTransparency = 1
    starsContainer.Size = UDim2.new(1, 0, 1, 0)
    starsContainer.Parent = background
    
    -- 创建星光层
    local function createStarLayer(count, size, speed, brightness)
        local layer = Instance.new("Frame")
        layer.Name = "StarLayer"
        layer.BackgroundTransparency = 1
        layer.Size = UDim2.new(1, 0, 1, 0)
        layer.Parent = starsContainer
        
        local stars = {}
        
        for i = 1, count do
            local star = Instance.new("Frame")
            star.Name = "Star"
            star.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            star.BackgroundTransparency = 1 - brightness
            star.Size = UDim2.new(0, size, 0, size)
            star.Position = UDim2.new(0, math.random(0, 450), 0, math.random(0, 280))
            star.ZIndex = 1
            
            local starCorner = Instance.new("UICorner")
            starCorner.CornerRadius = UDim.new(1, 0)
            starCorner.Parent = star
            
            star.Parent = layer
            table.insert(stars, star)
        end
        
        -- 动态效果
        task.spawn(function()
            while layer and layer.Parent do
                for _, star in ipairs(stars) do
                    -- 随机闪烁
                    if math.random(1, 100) <= 5 then
                        local alpha = 0.3 + math.sin(tick() * math.random(3, 7)) * 0.5
                        star.BackgroundTransparency = 1 - (brightness * alpha)
                    end
                    
                    -- 缓慢移动
                    local currentX = star.Position.X.Offset
                    local newX = currentX - speed
                    if newX < -10 then
                        newX = 460
                        star.Position = UDim2.new(0, newX, 0, math.random(0, 280))
                    else
                        star.Position = UDim2.new(0, newX, star.Position.Y.Offset, 0)
                    end
                end
                task.wait(0.02)
            end
        end)
    end
    
    -- 创建三层不同大小和速度的星光
    createStarLayer(40, 1, 0.1, 0.8)  -- 远景星光
    createStarLayer(25, 2, 0.3, 0.9)  -- 中景星光
    createStarLayer(12, 3, 0.5, 1.0)  -- 近景星光
    
    -- 星云效果
    local nebula = Instance.new("Frame")
    nebula.Name = "Nebula"
    nebula.BackgroundTransparency = 1
    nebula.Size = UDim2.new(1, 0, 1, 0)
    nebula.Parent = background
    
    local function createNebulaCloud(color, opacity, size, position)
        local cloud = Instance.new("Frame")
        cloud.Name = "NebulaCloud"
        cloud.BackgroundColor3 = color
        cloud.BackgroundTransparency = opacity
        cloud.Size = UDim2.new(0, size, 0, size)
        cloud.Position = position
        cloud.ZIndex = 2
        
        local cloudCorner = Instance.new("UICorner")
        cloudCorner.CornerRadius = UDim.new(1, 0)
        cloudCorner.Parent = cloud
        
        local cloudGradient = Instance.new("UIGradient")
        cloudGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, opacity),
            NumberSequenceKeypoint.new(0.5, opacity - 0.3),
            NumberSequenceKeypoint.new(1, opacity)
        })
        cloudGradient.Parent = cloud
        
        cloud.Parent = nebula
        
        -- 星云缓慢飘动
        task.spawn(function()
            local direction = Vector2.new(math.random(-1, 1), math.random(-1, 1))
            local speed = math.random(1, 3) * 0.1
            
            while cloud and cloud.Parent do
                local posX = cloud.Position.X.Offset + direction.X * speed
                local posY = cloud.Position.Y.Offset + direction.Y * speed
                
                -- 边界反弹
                if posX < -100 or posX > 450 then direction = Vector2.new(-direction.X, direction.Y) end
                if posY < -100 or posY > 280 then direction = Vector2.new(direction.X, -direction.Y) end
                
                cloud.Position = UDim2.new(0, math.clamp(posX, -100, 450), 0, math.clamp(posY, -100, 280))
                
                -- 透明度波动
                local alpha = opacity + math.sin(tick() * 0.5) * 0.1
                cloud.BackgroundTransparency = alpha
                
                task.wait(0.05)
            end
        end)
    end
    
    -- 创建多个星云
    createNebulaCloud(Color3.fromRGB(0, 80, 160), 0.85, 120, UDim2.new(0, 80, 0, 40))
    createNebulaCloud(Color3.fromRGB(40, 120, 200), 0.9, 100, UDim2.new(0, 250, 0, 120))
    createNebulaCloud(Color3.fromRGB(20, 100, 180), 0.8, 140, UDim2.new(0, 40, 0, 160))
    
    -- 脉冲光晕
    local pulseContainer = Instance.new("Frame")
    pulseContainer.Name = "PulseContainer"
    pulseContainer.BackgroundTransparency = 1
    pulseContainer.Size = UDim2.new(1, 0, 1, 0)
    pulseContainer.ZIndex = 3
    pulseContainer.Parent = background
    
    local function createPulseGlow(position, color)
        local pulse = Instance.new("Frame")
        pulse.Name = "PulseGlow"
        pulse.BackgroundColor3 = color
        pulse.BackgroundTransparency = 0.9
        pulse.Size = UDim2.new(0, 0, 0, 0)
        pulse.Position = position
        pulse.AnchorPoint = Vector2.new(0.5, 0.5)
        
        local pulseCorner = Instance.new("UICorner")
        pulseCorner.CornerRadius = UDim.new(1, 0)
        pulseCorner.Parent = pulse
        
        local pulseStroke = Instance.new("UIStroke")
        pulseStroke.Color = color
        pulseStroke.Thickness = 3
        pulseStroke.Transparency = 0.7
        pulseStroke.Parent = pulse
        
        pulse.Parent = pulseContainer
        
        -- 脉冲动画
        task.spawn(function()
            while pulse and pulse.Parent do
                services.TweenService:Create(pulse, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 80, 0, 80),
                    BackgroundTransparency = 1
                }):Play()
                
                services.TweenService:Create(pulseStroke, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Thickness = 1,
                    Transparency = 1
                }):Play()
                
                task.wait(1.5)
                
                pulse.Size = UDim2.new(0, 0, 0, 0)
                pulse.BackgroundTransparency = 0.9
                pulseStroke.Thickness = 3
                pulseStroke.Transparency = 0.7
                
                task.wait(math.random(2, 5))
            end
        end)
    end
    
    -- 创建多个脉冲光晕
    createPulseGlow(UDim2.new(0.3, 0, 0.4, 0), config.AccentGlow)
    createPulseGlow(UDim2.new(0.7, 0, 0.6, 0), Color3.fromRGB(100, 200, 255))
    createPulseGlow(UDim2.new(0.2, 0, 0.8, 0), Color3.fromRGB(50, 150, 255))
    
    return background
end

-- 创建玻璃磨砂效果
local function createGlassEffect(frame, intensity)
    intensity = intensity or 0.1
    
    local glass = Instance.new("Frame")
    glass.Name = "GlassEffect"
    glass.BackgroundTransparency = 1
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.ZIndex = frame.ZIndex + 1
    glass.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.3 * intensity),
        NumberSequenceKeypoint.new(1, 0.7)
    })
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    gradient.Parent = glass
    
    return glass
end

-- 脉冲发光效果
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

-- 3D翻转动画
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

-- 粒子轨迹效果
local function createParticleTrail(startPos, endPos, parent)
    local trail = Instance.new("Frame")
    trail.Name = "ParticleTrail"
    trail.BackgroundColor3 = config.AccentColor
    trail.BackgroundTransparency = 0.3
    trail.Size = UDim2.new(0, 4, 0, 4)
    trail.Position = startPos
    trail.Parent = parent
    trail.ZIndex = 10
    
    local trailCorner = Instance.new("UICorner")
    trailCorner.CornerRadius = UDim.new(1, 0)
    trailCorner.Parent = trail
    
    local trailGlow = Instance.new("UIStroke")
    trailGlow.Color = config.AccentGlow
    trailGlow.Thickness = 2
    trailGlow.Transparency = 0.2
    trailGlow.Parent = trail
    
    services.TweenService:Create(trail, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 2, 0, 2)
    }):Play()
    
    services.TweenService:Create(trailGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Thickness = 1,
        Transparency = 1
    }):Play()
    
    delay(0.3, function()
        trail:Destroy()
    end)
end

-- 标签切换
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

-- 清理旧UI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建主UI
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- 创建主窗口（使用第一个文件的大小450x280）
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundTransparency = 1  -- 完全透明主窗口
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 450, 0, 280)  -- 使用第一个文件的大小
Main.ZIndex = 10
Main.Active = true
Main.Draggable = true

-- 极致深空背景
createUltimateSpaceBackground(Main)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

-- 霓虹灯边框
local neonStroke = Instance.new("UIStroke")
neonStroke.Parent = Main
neonStroke.Thickness = 2
neonStroke.Transparency = 0.7
neonStroke.Color = config.AccentColor
neonStroke.LineJoinMode = Enum.LineJoinMode.Round
startNeonFlowEffect(neonStroke, "Color", 0.01)

-- 标题栏（完全透明）
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundTransparency = 1  -- 完全透明
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)  -- 使用第一个文件的高度
TitleBar.ZIndex = 11

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)  -- 使用第一个文件的位置
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "FengUI"
TitleText.TextColor3 = config.AccentColor
TitleText.TextSize = 16  -- 使用第一个文件的大小
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 0

-- 标题渐变效果
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, config.AccentColor),
    ColorSequenceKeypoint.new(0.5, config.AccentGlow),
    ColorSequenceKeypoint.new(1, config.AccentColor)
})
titleGradient.Rotation = 90
titleGradient.Parent = TitleText

-- 关闭按钮（完全透明背景）
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundTransparency = 1  -- 完全透明背景
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 7)  -- 使用第一个文件的位置
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"  -- 使用第一个文件的文本
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.TextSize = 16  -- 使用第一个文件的大小
CloseButton.ZIndex = 12
CloseButton.TextTransparency = 0

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
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.4), {
        Transparency = 1
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

-- 打开按钮
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85  -- 使用第一个文件的透明度
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 40, 0, 40)  -- 使用第一个文件的大小
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15  -- 使用第一个文件的透明度

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(180, 180, 180)  -- 使用第一个文件的颜色
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

-- 内容区域（使用第一个文件的位置和大小）
local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 37)  -- 使用第一个文件的位置
TabMain.Size = UDim2.new(0, 360, 0, 243)  -- 使用第一个文件的大小
TabMain.Visible = false

-- 侧边栏（完全透明，无背景无边框，使用第一个文件的大小）
local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundTransparency = 1  -- 完全透明
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 35)  -- 使用第一个文件的位置
Side.Size = UDim2.new(0, 90, 0, 245)  -- 使用第一个文件的大小

-- 标签按钮容器（完全透明）
local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1  -- 完全透明
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 5)  -- 使用第一个文件的位置
TabBtns.Size = UDim2.new(0, 90, 0, 235)  -- 使用第一个文件的大小
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3  -- 使用第一个文件的厚度
TabBtns.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)  -- 使用第一个文件的颜色
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None
TabBtns.Visible = false

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 6)  -- 使用第一个文件的间距

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y)
    TabBtns.ScrollingEnabled = TabBtnsL.AbsoluteContentSize.Y > TabBtns.AbsoluteSize.Y
    TabBtns.ElasticBehavior = Enum.ElasticBehavior.Never
end)

-- 入场动画
local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    Side.BackgroundTransparency = 1
    neonStroke.Transparency = 1
    
    TabMain.Visible = false
    TabBtns.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 450, 0, 280)  -- 使用第一个文件的大小
    }):Play()
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.7
    }):Play()
    
    task.wait(0.2)
    
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
    
    DigitalParticleExplosion(Main)
end

task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

-- 标题动画效果
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
            TextSize = 15 + math.sin(tick() * 3) * 2  -- 使用第一个文件的基础大小
        }):Play()
        
        task.wait(0.05)
    end
end)

-- FengUI主函数
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
        TabIco.Size = UDim2.new(0, 22, 0, 22)  -- 使用第一个文件的大小
        TabIco.Image = "rbxassetid://84830962019412"
        TabIco.ImageTransparency = 0.5
        
        startNeonFlowEffect(TabIco, "ImageColor3", 0.005)
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.2, 0, 0, 0)
        TabText.Size = UDim2.new(0, 65, 0, 22)  -- 使用第一个文件的大小
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 14  -- 使用第一个文件的大小
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 90, 0, 22)  -- 使用第一个文件的大小
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)  -- 使用第一个文件的间距
        
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
            
            -- Section使用第一个文件的样式，但有透明背景
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = 0.8  -- 半透明效果
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.95, 0, 0, 36)  -- 使用第一个文件的大小
            
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.088, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 320, 0, 36)  -- 使用第一个文件的大小
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 16  -- 使用第一个文件的大小
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, -26, 0, 6)  -- 使用第一个文件的位置
            SectionOpen.Size = UDim2.new(0, 22, 0, 22)  -- 使用第一个文件的大小
            SectionOpen.Image = "rbxassetid://84830962019412"
            SectionOpen.ImageColor3 = config.SecondaryTextColor
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(0, 22, 0, 22)  -- 使用第一个文件的大小
            SectionOpened.Image = "rbxassetid://84830962019412"
            SectionOpened.ImageColor3 = config.AccentColor
            SectionOpened.ImageTransparency = 1
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(0, 22, 0, 22)  -- 使用第一个文件的大小
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 6, 0, 36)  -- 使用第一个文件的位置
            Objs.Size = UDim2.new(0.98, 0, 0, 0)  -- 使用第一个文件的大小
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 6)  -- 使用第一个文件的间距
            
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
            
            -- 音乐播放器组件（从第一个文件复制）
            function section.MusicPlayer(section, title, defaultPlaylist)
                local MusicPlayerModule = Instance.new("Frame")
                MusicPlayerModule.Name = "MusicPlayerModule"
                MusicPlayerModule.Parent = Objs
                MusicPlayerModule.BackgroundTransparency = 1
                MusicPlayerModule.BorderSizePixel = 0
                MusicPlayerModule.Size = UDim2.new(0, 330, 0, 160)  -- 使用第一个文件的大小
                
                local PlayerContainer = Instance.new("Frame")
                PlayerContainer.Name = "PlayerContainer"
                PlayerContainer.Parent = MusicPlayerModule
                PlayerContainer.BackgroundColor3 = config.ElementColor
                PlayerContainer.BackgroundTransparency = 0.8  -- 半透明效果
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
                AlbumArt.BackgroundTransparency = 0.8  -- 半透明效果
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
                    button.BackgroundTransparency = 0.8  -- 半透明效果
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
                            BackgroundTransparency = 0.6,
                            Size = UDim2.new(0, size.X.Offset + 2, 0, size.Y.Offset + 2)
                        }):Play()
                        services.TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
                            Thickness = 2,
                            Transparency = 0.3
                        }):Play()
                    end)
                    
                    button.MouseLeave:Connect(function()
                        services.TweenService:Create(button, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.8,
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
                        BackgroundTransparency = 0.6,
                        Size = UDim2.new(0, button.Size.X.Offset - 2, 0, button.Size.Y.Offset - 2)
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.8,
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
            
            -- 按钮功能（从第一个文件复制，使用透明背景）
            function section.Button(section, text, callback)
                callback = callback or function() end
                
                local BtnModule = Instance.new("Frame")
                local Btn = Instance.new("TextButton")
                local BtnC = Instance.new("UICorner")
                
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.BorderSizePixel = 0
                BtnModule.Size = UDim2.new(0, 330, 0, 36)  -- 使用第一个文件的大小
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.8  -- 半透明效果
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
                        BackgroundTransparency = 0.6,
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
                        BackgroundTransparency = 0.8,
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
                        BackgroundTransparency = 0.5,
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
                        BackgroundTransparency = 0.8,
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)
            end
            
            -- 图片组件（从第一个文件复制）
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, 330, 0, sizeY or 120)  -- 使用第一个文件的大小
                
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
            
            -- 标签功能（从第一个文件复制，使用透明背景）
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                local TextLabel = Instance.new("TextLabel")
                local LabelC = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, 330, 0, 24)  -- 使用第一个文件的大小
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.8  -- 半透明效果
                TextLabel.Size = UDim2.new(0, 330, 0, 28)  -- 使用第一个文件的大小
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 14
                
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
                return TextLabel
            end
            
            -- 开关功能（从第一个文件复制，使用透明背景）
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
                ToggleModule.Size = UDim2.new(0, 330, 0, 36)  -- 使用第一个文件的大小
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.8  -- 半透明效果
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
                ToggleDisable.BackgroundTransparency = 0.8  -- 半透明效果
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.85, 0, 0.22, 0)
                ToggleDisable.Size = UDim2.new(0, 34, 0, 18)  -- 使用第一个文件的大小
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 20, 0, 18)  -- 使用第一个文件的大小
                ToggleSwitch.Position = UDim2.new(0, enabled and 14 or 0, 0, 0)
                
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(0, 6)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                if enabled then
                    createGlassEffect(ToggleSwitch, 0.8)
                end
                
                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.6,
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Toggle_Color.R * 255 * 1.1),
                            math.floor(config.Toggle_Color.G * 255 * 1.1),
                            math.floor(config.Toggle_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.8,
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
                            createGlassEffect(ToggleSwitch, 0.8)
                        else
                            local glass = ToggleSwitch:FindFirstChild("GlassEffect")
                            if glass then
                                glass:Destroy()
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
            
            -- 按键绑定功能（从第一个文件复制，使用透明背景）
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
                KeybindModule.Size = UDim2.new(0, 330, 0, 36)  -- 使用第一个文件的大小
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.8  -- 半透明效果
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
                KeybindValue.BackgroundTransparency = 0.8  -- 半透明效果
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.72, 0, 0.22, 0)
                KeybindValue.Size = UDim2.new(0, 70, 0, 22)  -- 使用第一个文件的大小
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
                        BackgroundTransparency = 0.6,
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Keybind_Color.R * 255 * 1.1),
                            math.floor(config.Keybind_Color.G * 255 * 1.1),
                            math.floor(config.Keybind_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.8,
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
            
            -- 文本框功能（从第一个文件复制，使用透明背景）
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
                TextboxModule.Size = UDim2.new(0, 330, 0, 36)  -- 使用第一个文件的大小
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.8  -- 半透明效果
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
                BoxBG.BackgroundTransparency = 0.8  -- 半透明效果
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.45, 0, 0.22, 0)
                BoxBG.Size = UDim2.new(0, 80, 0, 22)  -- 使用第一个文件的大小
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
                        BackgroundTransparency = 0.6,
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Textbox_Color.R * 255 * 1.1),
                            math.floor(config.Textbox_Color.G * 255 * 1.1),
                            math.floor(config.Textbox_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.8,
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
            
            -- 滑块功能（从第一个文件复制，使用透明背景）
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
                SliderModule.Size = UDim2.new(0, 330, 0, 36)  -- 使用第一个文件的大小
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.8  -- 半透明效果
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
                SliderBar.Size = UDim2.new(0, 120, 0, 14)  -- 使用第一个文件的大小
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
                SliderValBG.BackgroundTransparency = 0.8  -- 半透明效果
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.82, 0, 0.22, 0)
                SliderValBG.Size = UDim2.new(0, 36, 0, 22)  -- 使用第一个文件的大小
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
                MinSlider.BackgroundTransparency = 0.8  -- 半透明效果
                MinSlider.BorderSizePixel = 0
                MinSlider.Position = UDim2.new(0.28, 0, 0.25, 0)
                MinSlider.Size = UDim2.new(0, 18, 0, 18)  -- 使用第一个文件的大小
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
                AddSlider.BackgroundTransparency = 0.8  -- 半透明效果
                AddSlider.BorderSizePixel = 0
                AddSlider.Position = UDim2.new(0.75, 0, 0.25, 0)
                AddSlider.Size = UDim2.new(0, 18, 0, 18)  -- 使用第一个文件的大小
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
            
            -- 下拉菜单功能（从第一个文件复制，使用透明背景）
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
                DropdownModule.Size = UDim2.new(0, 330, 0, 36)  -- 使用第一个文件的大小
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0.8  -- 半透明效果
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
                BackgroundFill.BackgroundTransparency = 0.8  -- 半透明效果
                BackgroundFill.BorderSizePixel = 0
                BackgroundFill.Position = UDim2.new(0.75, 0, 0, 0)
                BackgroundFill.Size = UDim2.new(0.25, 0, 1, 0)
                BackgroundFill.ZIndex = 0
                
                DropdownOpenFrame.Name = "DropdownOpenFrame"
                DropdownOpenFrame.Parent = DropdownTop
                DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
                DropdownOpenFrame.BackgroundTransparency = 0.8  -- 半透明效果
                DropdownOpenFrame.BorderSizePixel = 0
                DropdownOpenFrame.Position = UDim2.new(0.80, 0, 0.5, 0)
                DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)  -- 使用第一个文件的大小
                DropdownOpenFrame.ZIndex = 2
                
                createGlassEffect(DropdownOpenFrame, 0.8)
                
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
                DropdownText.Size = UDim2.new(0, 230, 0, 36)  -- 使用第一个文件的大小
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
                Separator.BackgroundTransparency = 0.8  -- 半透明效果
                Separator.BorderSizePixel = 0
                Separator.Position = UDim2.new(0.74, 0, 0.2, 0)
                Separator.Size = UDim2.new(0, 1, 0, 22)  -- 使用第一个文件的大小
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
                    Option.BackgroundTransparency = 0.8  -- 半透明效果
                    Option.BorderSizePixel = 0
                    Option.Position = UDim2.new(0, 0, 0.328125, 0)
                    Option.Size = UDim2.new(0, 310, 0, 24)  -- 使用第一个文件的大小
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

-- 销毁UI
function UiDestroy()
    if FengYu then
        FengYu:Destroy()
    end
end

-- 切换UI显示
function ToggleUILib()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    Main.Visible = not ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI