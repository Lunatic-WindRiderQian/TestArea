-- 高级定制版 FengUI - "CyberNova" 主题
repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

-- 高级渲染设置
settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true
settings().Rendering.GlobalShadows = true

-- 高级配置
local config = {
    MainColor = Color3.fromRGB(8, 10, 28),           -- 深空蓝
    TabColor = Color3.fromRGB(12, 15, 40),           -- 宇宙紫
    Bg_Color = Color3.fromRGB(5, 7, 25),             -- 深空背景
    Zy_Color = Color3.fromRGB(8, 10, 35), 
    Button_Color = Color3.fromRGB(15, 18, 50),
    Textbox_Color = Color3.fromRGB(20, 25, 60),
    Dropdown_Color = Color3.fromRGB(18, 22, 55),
    Keybind_Color = Color3.fromRGB(22, 28, 65),
    Label_Color = Color3.fromRGB(25, 30, 70),
    Slider_Color = Color3.fromRGB(20, 25, 60),
    SliderBar_Color = Color3.fromRGB(0, 255, 255),   -- 青色霓虹
    Toggle_Color = Color3.fromRGB(18, 22, 55),
    Toggle_Off = Color3.fromRGB(30, 35, 80),
    Toggle_On = Color3.fromRGB(0, 255, 200),        -- 青色霓虹
    AccentColor = Color3.fromRGB(0, 255, 255),      -- 主色调：青色霓虹
    SecondaryAccent = Color3.fromRGB(255, 50, 255), -- 次要色调：品红霓虹
    TextColor = Color3.fromRGB(240, 245, 255),      -- 亮白色
    SecondaryTextColor = Color3.fromRGB(180, 190, 220),
    GlowColor = Color3.fromRGB(0, 200, 255),
    ErrorColor = Color3.fromRGB(255, 50, 100),
    SuccessColor = Color3.fromRGB(50, 255, 150),
    WarningColor = Color3.fromRGB(255, 200, 50),
    
    -- 新增高级特效设置
    BlurEnabled = true,
    ParticleEffects = true,
    HologramIntensity = 0.8,
    AnimationSpeed = 1.2,
    GlowIntensity = 0.6,
    
    -- 新增主题选项
    Theme = "Cyberpunk",
    ColorMode = "Dynamic",  -- Dynamic, Static, Gradient
}

-- 高级音乐播放器配置
local MusicPlayer = {
    currentSound = nil,
    currentTrackIndex = 1,
    isPlaying = false,
    isLooping = false,
    playlist = {},
    volume = 0.5,
    effects = {
        Reverb = 0,
        Pitch = 1,
        Distortion = 0
    },
    visualizerEnabled = true,
    spectrumBars = 32
}

-- 高级视觉特效系统
local VisualEffects = {
    activeEffects = {},
    
    createRainEffect = function(parent, intensity)
        intensity = intensity or 1
        local rain = Instance.new("Frame")
        rain.Name = "RainEffect"
        rain.BackgroundTransparency = 1
        rain.Size = UDim2.new(1, 0, 1, 0)
        rain.Parent = parent
        rain.ZIndex = -1
        
        local drops = {}
        for i = 1, math.floor(50 * intensity) do
            local drop = Instance.new("Frame")
            drop.Name = "RainDrop_" .. i
            drop.Parent = rain
            drop.BackgroundColor3 = config.AccentColor
            drop.BackgroundTransparency = 0.3
            drop.Size = UDim2.new(0, 1, 0, math.random(10, 30))
            drop.Position = UDim2.new(0, math.random(0, parent.AbsoluteSize.X), 0, -30)
            
            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(1, 0)
            dropCorner.Parent = drop
            
            local speed = math.random(500, 800) * intensity
            drops[i] = drop
        end
        
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function(delta)
            for _, drop in ipairs(drops) do
                if drop and drop.Parent then
                    local y = drop.Position.Y.Offset + (speed * delta)
                    if y > parent.AbsoluteSize.Y then
                        drop.Position = UDim2.new(0, math.random(0, parent.AbsoluteSize.X), 0, -30)
                    else
                        drop.Position = UDim2.new(drop.Position.X.Scale, drop.Position.X.Offset, 0, y)
                    end
                end
            end
        end)
        
        return {instance = rain, connection = connection}
    end,
    
    createMatrixEffect = function(parent)
        local matrix = Instance.new("Frame")
        matrix.Name = "MatrixEffect"
        matrix.BackgroundTransparency = 1
        matrix.Size = UDim2.new(1, 0, 1, 0)
        matrix.Parent = parent
        matrix.ZIndex = -1
        
        local columns = {}
        local chars = {"0", "1", "▓", "▒", "░", "█", "▄", "▀", "■", "□", "▢", "▣"}
        
        for x = 1, 20 do
            local column = {}
            for y = 1, 30 do
                local char = Instance.new("TextLabel")
                char.Name = "MatrixChar_" .. x .. "_" .. y
                char.Parent = matrix
                char.BackgroundTransparency = 1
                char.Text = chars[math.random(1, #chars)]
                char.TextColor3 = Color3.fromHSV(0.4, 1, math.random(0.3, 1))
                char.TextSize = math.random(12, 16)
                char.Font = Enum.Font.Code
                char.Size = UDim2.new(0, 20, 0, 20)
                char.Position = UDim2.new(0, (x-1)*20, 0, (y-1)*20)
                char.TextTransparency = (y/30) * 0.8
                
                column[y] = char
            end
            columns[x] = column
        end
        
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            for x, column in ipairs(columns) do
                for y, char in ipairs(column) do
                    if char and char.Parent then
                        char.Text = chars[math.random(1, #chars)]
                        local brightness = math.sin(tick() + x + y) * 0.3 + 0.7
                        char.TextColor3 = Color3.fromHSV(0.4, 1, brightness)
                    end
                end
            end
        end)
        
        return {instance = matrix, connection = connection}
    end,
    
    createNebulaEffect = function(parent)
        local nebula = Instance.new("Frame")
        nebula.Name = "NebulaEffect"
        nebula.BackgroundTransparency = 1
        nebula.Size = UDim2.new(1, 0, 1, 0)
        nebula.Parent = parent
        nebula.ZIndex = -1
        
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 45
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 255)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 0, 255)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 0, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.8),
            NumberSequenceKeypoint.new(0.5, 0.4),
            NumberSequenceKeypoint.new(1, 0.8)
        })
        gradient.Parent = nebula
        
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            gradient.Rotation = (tick() * 10) % 360
        end)
        
        return {instance = nebula, connection = connection}
    end
}

-- 高级通知系统
local NotificationSystem = {
    notifications = {},
    
    send = function(title, message, duration, type)
        duration = duration or 5
        type = type or "Info"
        
        local colors = {
            Info = config.AccentColor,
            Success = config.SuccessColor,
            Warning = config.WarningColor,
            Error = config.ErrorColor
        }
        
        local notification = Instance.new("Frame")
        notification.Name = "Notification_" .. tick()
        notification.Parent = game:GetService("CoreGui")
        notification.BackgroundColor3 = config.TabColor
        notification.BackgroundTransparency = 0.2
        notification.BorderSizePixel = 0
        notification.Position = UDim2.new(1, -350, 1, -100)
        notification.Size = UDim2.new(0, 320, 0, 80)
        notification.ZIndex = 1000
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = notification
        
        local stroke = Instance.new("UIStroke")
        stroke.Parent = notification
        stroke.Color = colors[type]
        stroke.Thickness = 2
        stroke.Transparency = 0.3
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Parent = notification
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 15, 0, 10)
        titleLabel.Size = UDim2.new(1, -30, 0, 25)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = colors[type]
        titleLabel.TextSize = 16
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Parent = notification
        messageLabel.BackgroundTransparency = 1
        messageLabel.Position = UDim2.new(0, 15, 0, 35)
        messageLabel.Size = UDim2.new(1, -30, 1, -45)
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.Text = message
        messageLabel.TextColor3 = config.TextColor
        messageLabel.TextSize = 13
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.TextYAlignment = Enum.TextYAlignment.Top
        messageLabel.TextWrapped = true
        
        local progressBar = Instance.new("Frame")
        progressBar.Parent = notification
        progressBar.BackgroundColor3 = colors[type]
        progressBar.BorderSizePixel = 0
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        
        local progressCorner = Instance.new("UICorner")
        progressCorner.CornerRadius = UDim.new(0, 2)
        progressCorner.Parent = progressBar
        
        local closeBtn = Instance.new("TextButton")
        closeBtn.Parent = notification
        closeBtn.BackgroundTransparency = 1
        closeBtn.Position = UDim2.new(1, -30, 0, 10)
        closeBtn.Size = UDim2.new(0, 20, 0, 20)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Text = "×"
        closeBtn.TextColor3 = config.SecondaryTextColor
        closeBtn.TextSize = 20
        closeBtn.TextTransparency = 0.3
        
        closeBtn.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(closeBtn, TweenInfo.new(0.2), {
                TextTransparency = 0,
                TextColor3 = config.ErrorColor
            }):Play()
        end)
        
        closeBtn.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(closeBtn, TweenInfo.new(0.2), {
                TextTransparency = 0.3,
                TextColor3 = config.SecondaryTextColor
            }):Play()
        end)
        
        closeBtn.MouseButton1Click:Connect(function()
            notification:Destroy()
        end)
        
        local startTime = tick()
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            if elapsed >= duration then
                connection:Disconnect()
                notification:Destroy()
            else
                local progress = 1 - (elapsed / duration)
                progressBar.Size = UDim2.new(progress, 0, 0, 3)
            end
        end)
        
        table.insert(NotificationSystem.notifications, notification)
        return notification
    end
}

-- 高级粒子效果（修改DigitalParticleExplosion使其更炫酷）
function DigitalParticleExplosion(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        
        local x = (mouse.X - obj.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - obj.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        
        -- 创建中心爆炸效果
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
        
        -- 增强版粒子效果
        local particleCount = 24
        local particles = {}
        local symbols = {"0", "1", "▓", "▒", "░", "█", "▄", "▀", "■", "□", "▢", "▣"}
        
        for i = 1, particleCount do
            local angle = (i / particleCount) * math.pi * 2
            local distance = math.random(50, 150)
            
            local particle = Instance.new("TextLabel")
            particle.Name = "DigitalParticle_" .. i
            particle.Parent = obj
            particle.BackgroundTransparency = 1
            particle.Text = symbols[math.random(1, #symbols)]
            particle.TextColor3 = Color3.fromHSV(
                (tick() * 0.1) % 1,
                0.8,
                1
            )
            particle.TextSize = math.random(12, 18)
            particle.Font = Enum.Font.Code
            particle.ZIndex = 9
            particle.Size = UDim2.new(0, 20, 0, 20)
            particle.Position = UDim2.new(x, 0, y, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            
            table.insert(particles, {
                instance = particle,
                angle = angle,
                distance = distance,
                speed = math.random(200, 400),
                rotation = math.random(-360, 360),
                rotationSpeed = math.random(-720, 720),
                symbolChange = math.random(2, 5)
            })
        end
        
        -- 添加冲击波
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
        shockwaveStroke.Thickness = 5
        shockwaveStroke.Transparency = 0.3
        
        -- 添加光环效果
        local halo = Instance.new("Frame")
        halo.Name = "Halo"
        halo.Parent = obj
        halo.BackgroundTransparency = 1
        halo.ZIndex = 6
        halo.Size = UDim2.new(0, 0, 0, 0)
        halo.AnchorPoint = Vector2.new(0.5, 0.5)
        halo.Position = UDim2.new(x, 0, y, 0)
        
        local haloStroke = Instance.new("UIStroke")
        haloStroke.Parent = halo
        haloStroke.Color = config.SecondaryAccent
        haloStroke.Thickness = 2
        haloStroke.Transparency = 0.5
        
        -- 动画开始
        local tweenService = game:GetService("TweenService")
        
        tweenService:Create(explosionCenter, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 60, 0, 60),
            BackgroundTransparency = 1
        }):Play()
        
        tweenService:Create(centerGlow, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 15,
            Transparency = 1
        }):Play()
        
        tweenService:Create(shockwave, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, 200)
        }):Play()
        
        tweenService:Create(shockwaveStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 1,
            Transparency = 1
        }):Play()
        
        tweenService:Create(halo, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 300)
        }):Play()
        
        tweenService:Create(haloStroke, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 0.5,
            Transparency = 1
        }):Play()
        
        local startTime = tick()
        local connection
        connection = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            
            if elapsed > 1.5 then
                connection:Disconnect()
                explosionCenter:Destroy()
                shockwave:Destroy()
                halo:Destroy()
                for _, particleData in ipairs(particles) do
                    particleData.instance:Destroy()
                end
                return
            end
            
            local progress = elapsed / 1.5
            
            for _, particleData in ipairs(particles) do
                local moveProgress = progress * particleData.speed / 100
                local currentDistance = particleData.distance * moveProgress
                
                local offsetX = math.cos(particleData.angle) * currentDistance
                local offsetY = math.sin(particleData.angle) * currentDistance
                
                particleData.instance.Position = UDim2.new(
                    x, offsetX,
                    y, offsetY
                )
                
                particleData.instance.Rotation = particleData.rotation + (particleData.rotationSpeed * progress)
                particleData.instance.TextTransparency = progress
                particleData.instance.TextStrokeTransparency = progress * 0.5
                
                if math.random(1, particleData.symbolChange) == 1 then
                    particleData.instance.Text = symbols[math.random(1, #symbols)]
                end
                
                local hue = (elapsed * 0.5 + particleData.angle) % 1
                particleData.instance.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
            end
            
            explosionCenter.Size = UDim2.new(0, 60 + progress * 40, 0, 60 + progress * 40)
        end)
        
        task.wait(1.5)
        shockwave:Destroy()
        halo:Destroy()
    end)
end

-- 增强版霓虹流光效果
local function startNeonFlowEffect(object, property, speed)
    speed = speed or 0.008
    local hue = 0
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
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

-- 高级全息效果
local function createAdvancedHologramEffect(frame, intensity)
    intensity = intensity or 1
    
    local hologram = Instance.new("Frame")
    hologram.Name = "AdvancedHologramEffect"
    hologram.BackgroundTransparency = 1
    hologram.Size = UDim2.new(1, 0, 1, 0)
    hologram.ZIndex = frame.ZIndex - 1
    hologram.Parent = frame
    hologram.ClipsDescendants = true
    
    -- 扫描线
    local scanLines = Instance.new("Frame")
    scanLines.Name = "ScanLines"
    scanLines.BackgroundTransparency = 1
    scanLines.Size = UDim2.new(1, 0, 1, 0)
    scanLines.Parent = hologram
    
    local linePattern = Instance.new("UIGradient")
    linePattern.Rotation = 90
    linePattern.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.1, 0.7),
        NumberSequenceKeypoint.new(0.2, 0.9),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    linePattern.Parent = scanLines
    
    -- 噪点效果
    local noise = Instance.new("ImageLabel")
    noise.Name = "Noise"
    noise.BackgroundTransparency = 1
    noise.Size = UDim2.new(1, 0, 1, 0)
    noise.Image = "rbxassetid://8669701343"
    noise.ImageTransparency = 0.1
    noise.ScaleType = Enum.ScaleType.Tile
    noise.TileSize = UDim2.new(0, 20, 0, 20)
    noise.Parent = hologram
    
    -- 动态渐变光晕
    local glow = Instance.new("UIGradient")
    glow.Rotation = 45
    glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.3, 0.2 * intensity),
        NumberSequenceKeypoint.new(0.7, 0.2 * intensity),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    
    local colors = {
        ColorSequenceKeypoint.new(0, config.AccentColor),
        ColorSequenceKeypoint.new(0.3, config.SecondaryAccent),
        ColorSequenceKeypoint.new(0.6, config.AccentColor),
        ColorSequenceKeypoint.new(1, config.SecondaryAccent)
    }
    glow.Color = ColorSequence.new(colors)
    glow.Parent = hologram
    
    -- 网格线
    local grid = Instance.new("Frame")
    grid.Name = "Grid"
    grid.BackgroundTransparency = 1
    grid.Size = UDim2.new(1, 0, 1, 0)
    grid.Parent = hologram
    
    for i = 1, 10 do
        local verticalLine = Instance.new("Frame")
        verticalLine.BackgroundColor3 = config.AccentColor
        verticalLine.BackgroundTransparency = 0.8
        verticalLine.BorderSizePixel = 0
        verticalLine.Size = UDim2.new(0, 1, 1, 0)
        verticalLine.Position = UDim2.new(i/10, 0, 0, 0)
        verticalLine.Parent = grid
        
        local horizontalLine = Instance.new("Frame")
        horizontalLine.BackgroundColor3 = config.AccentColor
        horizontalLine.BackgroundTransparency = 0.8
        horizontalLine.BorderSizePixel = 0
        horizontalLine.Size = UDim2.new(1, 0, 0, 1)
        horizontalLine.Position = UDim2.new(0, 0, i/10, 0)
        horizontalLine.Parent = grid
    end
    
    -- 动画连接
    local scanConnection
    scanConnection = game:GetService("RunService").Heartbeat:Connect(function(delta)
        if not scanLines or not scanLines.Parent then
            scanConnection:Disconnect()
            return
        end
        linePattern.Offset = Vector2.new(0, (tick() * 0.3) % 1)
    end)
    
    local colorConnection
    colorConnection = game:GetService("RunService").Heartbeat:Connect(function(delta)
        if not hologram or not hologram.Parent then
            colorConnection:Disconnect()
            return
        end
        
        local time = tick()
        for i, keypoint in ipairs(colors) do
            local hue = (time * 0.1 + i * 0.2) % 1
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV(hue, 0.9, 1)
            )
        end
        glow.Color = ColorSequence.new(colors)
        
        -- 动态网格透明度
        for _, line in ipairs(grid:GetChildren()) do
            line.BackgroundTransparency = 0.7 + math.sin(time * 2 + line.Position.X.Scale * 10) * 0.2
        end
    end)
    
    -- 噪点动画
    local noiseConnection
    noiseConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if noise and noise.Parent then
            noise.Offset = Vector2.new(
                math.random(-100, 100),
                math.random(-100, 100)
            )
        end
    end)
    
    return {instance = hologram, connections = {scanConnection, colorConnection, noiseConnection}}
end

-- 高级脉冲发光效果
local function createAdvancedPulseGlow(object)
    local pulseConnection
    pulseConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not object or not object.Parent then
            pulseConnection:Disconnect()
            return
        end
        
        local alpha = 0.4 + math.sin(tick() * 2.5) * 0.4
        local size = 1 + math.sin(tick() * 1.5) * 0.2
        
        if object:IsA("UIStroke") then
            object.Transparency = alpha
            object.Thickness = 1.5 + math.sin(tick() * 2) * 0.5
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
            object.ImageTransparency = alpha
        end
    end)
    return pulseConnection
end

-- 创建高级UI
local function createAdvancedUI()
    local services = {
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService"),
        CoreGui = game:GetService("CoreGui"),
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        SoundService = game:GetService("SoundService"),
        Lighting = game:GetService("Lighting")
    }
    
    -- 清理旧UI
    for _, gui in ipairs(services.CoreGui:GetChildren()) do
        if gui.Name == "CyberNovaUI" and gui:IsA("ScreenGui") then
            gui:Destroy()
        end
    end
    
    -- 创建主UI
    local CyberNova = Instance.new("ScreenGui")
    CyberNova.Name = "CyberNovaUI"
    CyberNova.Parent = services.CoreGui
    CyberNova.ResetOnSpawn = false
    
    -- 添加背景模糊效果
    if config.BlurEnabled then
        local blur = Instance.new("BlurEffect")
        blur.Name = "UIBlur"
        blur.Size = 8
        blur.Parent = services.Lighting
    end
    
    -- 主容器
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = CyberNova
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = config.MainColor
    Main.BackgroundTransparency = 0.2
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.Size = UDim2.new(0, 500, 0, 320)  -- 稍微扩大尺寸
    Main.ZIndex = 1
    Main.Active = true
    Main.Draggable = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main
    
    -- 高级描边效果
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = Main
    MainStroke.Color = config.AccentColor
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.5
    
    local InnerGlow = Instance.new("UIStroke")
    InnerGlow.Parent = Main
    InnerGlow.Color = config.SecondaryAccent
    InnerGlow.Thickness = 1
    InnerGlow.Transparency = 0.7
    
    -- 动态霓虹描边
    local neonStroke = Instance.new("UIStroke")
    neonStroke.Parent = Main
    neonStroke.Thickness = 3
    neonStroke.Transparency = 0.8
    neonStroke.LineJoinMode = Enum.LineJoinMode.Round
    startNeonFlowEffect(neonStroke, "Color", 0.01)
    createAdvancedPulseGlow(neonStroke)
    
    -- 标题栏
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = config.TabColor
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.ZIndex = 2
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12)
    TitleBarCorner.Parent = TitleBar
    
    -- 高级全息标题栏效果
    createAdvancedHologramEffect(TitleBar, 0.5)
    
    -- 动态标题文本
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.Font = Enum.Font.GothamBlack
    TitleText.Text = "CYBER NOVA"
    TitleText.TextColor3 = config.AccentColor
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.TextTransparency = 0
    
    -- 标题文本渐变效果
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.AccentColor),
        ColorSequenceKeypoint.new(0.5, config.SecondaryAccent),
        ColorSequenceKeypoint.new(1, config.AccentColor)
    })
    titleGradient.Rotation = 0
    titleGradient.Parent = TitleText
    
    -- 标题文本动画
    task.spawn(function()
        while TitleText and TitleText.Parent do
            local time = tick()
            titleGradient.Rotation = math.sin(time * 0.5) * 30
            TitleText.TextColor3 = Color3.fromHSV((time * 0.1) % 1, 1, 1)
            task.wait(0.05)
        end
    end)
    
    -- 高级控制按钮
    local ControlButtons = Instance.new("Frame")
    ControlButtons.Name = "ControlButtons"
    ControlButtons.Parent = TitleBar
    ControlButtons.BackgroundTransparency = 1
    ControlButtons.Position = UDim2.new(1, -100, 0, 0)
    ControlButtons.Size = UDim2.new(0, 90, 1, 0)
    
    -- 最小化按钮
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = ControlButtons
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    MinimizeButton.BackgroundTransparency = 0.2
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(0, 0, 0.25, 0)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 16
    MinimizeButton.ZIndex = 10
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    MinimizeCorner.Parent = MinimizeButton
    
    createAdvancedPulseGlow(MinimizeButton)
    
    -- 关闭按钮
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = ControlButtons
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BackgroundTransparency = 0.2
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0, 30, 0.25, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.ZIndex = 10
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    createAdvancedPulseGlow(CloseButton)
    
    -- 设置按钮
    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Parent = ControlButtons
    SettingsButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    SettingsButton.BackgroundTransparency = 0.2
    SettingsButton.BorderSizePixel = 0
    SettingsButton.Position = UDim2.new(0, 60, 0.25, 0)
    SettingsButton.Size = UDim2.new(0, 25, 0, 25)
    SettingsButton.Font = Enum.Font.GothamBold
    SettingsButton.Text = "⚙"
    SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsButton.TextSize = 16
    SettingsButton.ZIndex = 10
    
    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 6)
    SettingsCorner.Parent = SettingsButton
    
    createAdvancedPulseGlow(SettingsButton)
    
    -- 按钮悬停效果
    local function setupButtonHover(button, hoverColor)
        button.MouseEnter:Connect(function()
            services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 28, 0, 28)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 25, 0, 25)
            }):Play()
        end)
    end
    
    setupButtonHover(MinimizeButton, Color3.fromRGB(50, 150, 255))
    setupButtonHover(CloseButton, Color3.fromRGB(255, 100, 100))
    setupButtonHover(SettingsButton, Color3.fromRGB(100, 100, 255))
    
    -- 侧边栏
    local Side = Instance.new("Frame")
    Side.Name = "Side"
    Side.Parent = Main
    Side.BackgroundColor3 = config.TabColor
    Side.BackgroundTransparency = 0.1
    Side.BorderSizePixel = 0
    Side.ClipsDescendants = true
    Side.Position = UDim2.new(0, 0, 0, 40)
    Side.Size = UDim2.new(0, 100, 0, 280)  -- 扩大侧边栏
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 12)
    SideCorner.Parent = Side
    
    -- 侧边栏全息效果
    createAdvancedHologramEffect(Side, 0.3)
    
    -- 标签按钮容器
    local TabBtns = Instance.new("ScrollingFrame")
    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundTransparency = 1
    TabBtns.BorderSizePixel = 0
    TabBtns.Position = UDim2.new(0, 0, 0, 5)
    TabBtns.Size = UDim2.new(0, 100, 0, 270)
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBtns.ScrollBarThickness = 0
    
    local TabBtnsL = Instance.new("UIListLayout")
    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 8)
    
    -- 主内容区域
    local TabMain = Instance.new("Frame")
    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundTransparency = 1
    TabMain.Position = UDim2.new(0.2, 0, 0, 42)
    TabMain.Size = UDim2.new(0, 400, 0, 278)
    TabMain.Visible = false
    
    -- 打开/关闭按钮
    local Open = Instance.new("ImageButton")
    Open.Name = "Open"
    Open.Parent = CyberNova
    Open.BackgroundColor3 = config.AccentColor
    Open.BackgroundTransparency = 0.8
    Open.Position = UDim2.new(0.95, 0, 0.02, 0)
    Open.Size = UDim2.new(0, 45, 0, 45)
    Open.Active = true
    Open.Draggable = true
    Open.Image = "rbxassetid://84830962019412"
    Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
    Open.ImageTransparency = 0.2
    
    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0, 10)
    OpenCorner.Parent = Open
    
    local OpenStroke = Instance.new("UIStroke")
    OpenStroke.Parent = Open
    OpenStroke.Color = config.AccentColor
    OpenStroke.Thickness = 2
    OpenStroke.Transparency = 0.4
    
    startNeonFlowEffect(Open, "BackgroundColor3", 0.015)
    createAdvancedPulseGlow(OpenStroke)
    
    -- 状态指示器
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Name = "StatusIndicator"
    StatusIndicator.Parent = TitleBar
    StatusIndicator.BackgroundColor3 = config.SuccessColor
    StatusIndicator.BackgroundTransparency = 0.3
    StatusIndicator.Position = UDim2.new(0.7, 0, 0.25, 0)
    StatusIndicator.Size = UDim2.new(0, 10, 0, 10)
    StatusIndicator.ZIndex = 5
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator
    
    createAdvancedPulseGlow(StatusIndicator)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = TitleBar
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.72, 0, 0, 0)
    StatusLabel.Size = UDim2.new(0, 100, 1, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "● 在线"
    StatusLabel.TextColor3 = config.SuccessColor
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 按钮功能
    MinimizeButton.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(MinimizeButton)
        Main.Visible = not Main.Visible
        Open.Visible = true
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(CloseButton)
        NotificationSystem.send("系统", "CyberNova UI 已关闭", 3, "Info")
        
        services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, 0, 0.3, 0),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 10, 0, 10)
        }):Play()
        
        services.TweenService:Create(TitleBar, TweenInfo.new(0.4), {
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.4)
        CyberNova:Destroy()
        if config.BlurEnabled then
            local blur = services.Lighting:FindFirstChild("UIBlur")
            if blur then
                blur:Destroy()
            end
        end
    end)
    
    SettingsButton.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(SettingsButton)
        NotificationSystem.send("设置", "打开设置面板", 2, "Info")
        -- 这里可以添加设置面板
    end)
    
    Open.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
        create3DFlipAnimation(Open, 0.5)
    end)
    
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
            if Main.Visible then
                playEntranceAnimation()
            end
            create3DFlipAnimation(Open, 0.5)
        end
    end)
    
    -- 入场动画
    local function playEntranceAnimation()
        Main.Position = UDim2.new(0.5, 0, 0.35, 0)
        Main.BackgroundTransparency = 1
        Main.Size = UDim2.new(0, 10, 0, 10)
        
        TitleBar.BackgroundTransparency = 1
        TitleText.TextTransparency = 1
        Side.BackgroundTransparency = 1
        MainStroke.Transparency = 1
        neonStroke.Transparency = 1
        InnerGlow.Transparency = 1
        
        TabMain.Visible = false
        TabBtns.Visible = false
        
        services.TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.4, 0),
            BackgroundTransparency = 0.2,
            Size = UDim2.new(0, 500, 0, 320)
        }):Play()
        
        services.TweenService:Create(MainStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 0.5
        }):Play()
        
        services.TweenService:Create(neonStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 0.8
        }):Play()
        
        services.TweenService:Create(InnerGlow, TweenInfo.new(0.8), {
            Transparency = 0.7
        }):Play()
        
        task.wait(0.3)
        
        services.TweenService:Create(TitleBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1
        }):Play()
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.5), {
            TextTransparency = 0
        }):Play()
        
        task.wait(0.3)
        
        services.TweenService:Create(Side, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1
        }):Play()
        
        task.wait(0.3)
        
        TabMain.Visible = true
        TabBtns.Visible = true
        
        DigitalParticleExplosion(Main)
        
        -- 播放音效
        if config.ParticleEffects then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://3570577341"  -- 科幻音效
            sound.Volume = 0.3
            sound.Parent = Main
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 2)
        end
    end
    
    -- 自动播放入场动画
    task.spawn(function()
        task.wait(1)
        playEntranceAnimation()
    end)
    
    -- 创建标签切换系统
    local switchingTabs = false
    local currentTab = nil
    
    local function switchTab(new)
        if switchingTabs then return end
        
        local old = currentTab
        if old == nil then
            new[2].Visible = true
            currentTab = new
            services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
                ImageTransparency = 0,
                Size = UDim2.new(0, 30, 0, 30)
            }):Play()
            services.TweenService:Create(new[1].TabText, TweenInfo.new(0.3), { 
                TextTransparency = 0,
                TextColor3 = config.AccentColor
            }):Play()
            return
        end
        
        if old[1] == new[1] then return end
        
        switchingTabs = true
        currentTab = new
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        services.TweenService:Create(old[1], tweenInfo, { 
            ImageTransparency = 0.5,
            Size = UDim2.new(0, 25, 0, 25)
        }):Play()
        services.TweenService:Create(new[1], tweenInfo, { 
            ImageTransparency = 0,
            Size = UDim2.new(0, 30, 0, 30)
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
    
    -- 创建高级标签
    function createAdvancedTab(name, icon)
        local Tab = Instance.new("ScrollingFrame")
        local TabBtnContainer = Instance.new("Frame")
        local TabIcon = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabBtn = Instance.new("TextButton")
        
        -- 标签内容
        Tab.Name = name .. "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 0
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Parent = Tab
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 8)
        
        -- 标签按钮
        TabBtnContainer.Name = name .. "Btn"
        TabBtnContainer.Parent = TabBtns
        TabBtnContainer.BackgroundTransparency = 1
        TabBtnContainer.Size = UDim2.new(1, 0, 0, 40)
        
        TabIcon.Name = "TabIcon"
        TabIcon.Parent = TabBtnContainer
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0.1, 0, 0.2, 0)
        TabIcon.Size = UDim2.new(0, 25, 0, 25)
        TabIcon.Image = icon or "rbxassetid://84830962019412"
        TabIcon.ImageTransparency = 0.5
        
        startNeonFlowEffect(TabIcon, "ImageColor3", 0.008)
        
        TabText.Name = "TabText"
        TabText.Parent = TabBtnContainer
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(0.4, 0, 0, 0)
        TabText.Size = UDim2.new(0.6, 0, 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabBtnContainer
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 1, 0)
        TabBtn.Text = ""
        
        TabBtn.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(TabBtn)
            switchTab({ TabIcon, Tab })
            NotificationSystem.send("标签切换", "切换到 " .. name, 1, "Info")
        end)
        
        if currentTab == nil then
            switchTab({ TabIcon, Tab })
        end
        
        -- 标签内容管理
        local tab = {}
        
        function tab:Section(sectionName, isOpen)
            local Section = Instance.new("Frame")
            local SectionCorner = Instance.new("UICorner")
            local SectionTitle = Instance.new("TextLabel")
            local SectionToggle = Instance.new("ImageButton")
            local SectionContent = Instance.new("Frame")
            local SectionLayout = Instance.new("UIListLayout")
            
            Section.Name = sectionName .. "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = 0.15
            Section.Size = UDim2.new(1, 0, 0, 40)
            
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = Section
            
            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Parent = Section
            sectionStroke.Color = config.AccentColor
            sectionStroke.Thickness = 1
            sectionStroke.Transparency = 0.7
            
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = Section
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0.05, 0, 0, 0)
            SectionTitle.Size = UDim2.new(0.8, 0, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = config.TextColor
            SectionTitle.TextSize = 16
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = Section
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Position = UDim2.new(0.9, 0, 0.2, 0)
            SectionToggle.Size = UDim2.new(0, 25, 0, 25)
            SectionToggle.Image = "rbxassetid://6031091003"  -- 箭头图标
            SectionToggle.ImageColor3 = config.AccentColor
            
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = Section
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 10, 1, 0)
            SectionContent.Size = UDim2.new(1, -20, 0, 0)
            SectionContent.ClipsDescendants = true
            
            SectionLayout.Parent = SectionContent
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 6)
            
            local open = isOpen or false
            if open then
                SectionToggle.Rotation = 180
                Section.Size = UDim2.new(1, 0, 0, 40 + SectionLayout.AbsoluteContentSize.Y + 10)
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                
                services.TweenService:Create(SectionToggle, TweenInfo.new(0.3), {
                    Rotation = open and 180 or 0
                }):Play()
                
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and (40 + SectionLayout.AbsoluteContentSize.Y + 10) or 40)
                }):Play()
                
                DigitalParticleExplosion(SectionToggle)
            end)
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    Section.Size = UDim2.new(1, 0, 0, 40 + SectionLayout.AbsoluteContentSize.Y + 10)
                end
            end)
            
            local section = {}
            
            function section:Button(buttonText, callback)
                callback = callback or function() end
                
                local Button = Instance.new("TextButton")
                local ButtonCorner = Instance.new("UICorner")
                
                Button.Name = buttonText .. "Button"
                Button.Parent = SectionContent
                Button.BackgroundColor3 = config.Button_Color
                Button.BackgroundTransparency = 0.15
                Button.Size = UDim2.new(1, 0, 0, 36)
                Button.AutoButtonColor = false
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = buttonText
                Button.TextColor3 = config.TextColor
                Button.TextSize = 14
                
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                local buttonStroke = Instance.new("UIStroke")
                buttonStroke.Parent = Button
                buttonStroke.Color = config.AccentColor
                buttonStroke.Thickness = 1
                buttonStroke.Transparency = 0.7
                
                createAdvancedPulseGlow(buttonStroke)
                
                Button.MouseEnter:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 2, 0, 38)
                    }):Play()
                    services.TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.5
                    }):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.15,
                        Size = UDim2.new(1, 0, 0, 36)
                    }):Play()
                    services.TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.7
                    }):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(Button)
                    callback()
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 0.7),
                            math.floor(config.Button_Color.G * 255 * 0.7),
                            math.floor(config.Button_Color.B * 255 * 0.7)
                        )
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                end)
            end
            
            function section:Toggle(toggleText, flag, defaultValue, callback)
                callback = callback or function() end
                defaultValue = defaultValue or false
                getgenv().FengUI = getgenv().FengUI or {}
                getgenv().FengUI.flags = getgenv().FengUI.flags or {}
                getgenv().FengUI.flags[flag] = defaultValue
                
                local ToggleContainer = Instance.new("Frame")
                local ToggleBackground = Instance.new("Frame")
                local ToggleCircle = Instance.new("Frame")
                local ToggleText = Instance.new("TextLabel")
                
                ToggleContainer.Name = toggleText .. "Toggle"
                ToggleContainer.Parent = SectionContent
                ToggleContainer.BackgroundTransparency = 1
                ToggleContainer.Size = UDim2.new(1, 0, 0, 30)
                
                ToggleBackground.Name = "ToggleBackground"
                ToggleBackground.Parent = ToggleContainer
                ToggleBackground.BackgroundColor3 = defaultValue and config.Toggle_On or config.Toggle_Off
                ToggleBackground.BackgroundTransparency = 0.2
                ToggleBackground.Position = UDim2.new(0.85, 0, 0, 5)
                ToggleBackground.Size = UDim2.new(0, 50, 0, 20)
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleBackground
                
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Parent = ToggleBackground
                ToggleCircle.BackgroundColor3 = config.TextColor
                ToggleCircle.BackgroundTransparency = 0
                ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
                ToggleCircle.Position = UDim2.new(0, defaultValue and 32 or 2, 0, 2)
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = ToggleCircle
                
                ToggleText.Name = "ToggleText"
                ToggleText.Parent = ToggleContainer
                ToggleText.BackgroundTransparency = 1
                ToggleText.Position = UDim2.new(0, 0, 0, 0)
                ToggleText.Size = UDim2.new(0.8, 0, 1, 0)
                ToggleText.Font = Enum.Font.Gotham
                ToggleText.Text = toggleText
                ToggleText.TextColor3 = config.TextColor
                ToggleText.TextSize = 14
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                
                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Parent = ToggleContainer
                toggleBtn.BackgroundTransparency = 1
                toggleBtn.Size = UDim2.new(1, 0, 1, 0)
                toggleBtn.Text = ""
                
                local function setState(state)
                    getgenv().FengUI.flags[flag] = state
                    
                    services.TweenService:Create(ToggleBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                    }):Play()
                    
                    services.TweenService:Create(ToggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, state and 32 or 2, 0, 2)
                    }):Play()
                    
                    if state then
                        createAdvancedHologramEffect(ToggleCircle, 0.5)
                    else
                        local hologram = ToggleCircle:FindFirstChild("AdvancedHologramEffect")
                        if hologram then
                            hologram.instance:Destroy()
                        end
                    end
                    
                    callback(state)
                end
                
                toggleBtn.MouseButton1Click:Connect(function()
                    DigitalParticleExplosion(toggleBtn)
                    setState(not getgenv().FengUI.flags[flag])
                end)
                
                return {
                    SetState = function(self, state)
                        setState(state)
                    end,
                    GetState = function(self)
                        return getgenv().FengUI.flags[flag]
                    end
                }
            end
            
            -- 更多控件可以在这里添加...
            
            return section
        end
        
        return tab
    end
    
    -- 创建一些示例标签
    local mainTab = createAdvancedTab("主页", "rbxassetid://6031075938")
    local combatTab = createAdvancedTab("战斗", "rbxassetid://6031075921")
    local visualTab = createAdvancedTab("视觉", "rbxassetid://6031075927")
    local miscTab = createAdvancedTab("其他", "rbxassetid://6031075932")
    
    -- 添加一些示例内容
    local mainSection = mainTab:Section("欢迎", true)
    mainSection:Button("显示通知", function()
        NotificationSystem.send("CyberNova", "高级UI系统已启动！", 3, "Success")
    end)
    
    mainSection:Button("粒子特效", function()
        DigitalParticleExplosion(Main)
    end)
    
    mainSection:Toggle("启用特效", "EnableEffects", true, function(state)
        config.ParticleEffects = state
        NotificationSystem.send("特效设置", state and "特效已启用" or "特效已禁用", 2, state and "Success" or "Warning")
    end)
    
    local combatSection = combatTab:Section("战斗设置", true)
    combatSection:Toggle("自动攻击", "AutoAttack", false, function(state)
        NotificationSystem.send("战斗", state and "自动攻击已启用" or "自动攻击已禁用", 2, state and "Success" or "Warning")
    end)
    
    combatSection:Toggle("瞄准辅助", "AimAssist", true, function(state)
        NotificationSystem.send("战斗", state and "瞄准辅助已启用" or "瞄准辅助已禁用", 2, state and "Success" or "Warning")
    end)
    
    local visualSection = visualTab:Section("视觉特效", true)
    visualSection:Toggle("霓虹效果", "NeonEffects", true, function(state)
        config.GlowIntensity = state and 0.6 or 0
        NotificationSystem.send("视觉", state and "霓虹效果已启用" or "霓虹效果已禁用", 2, state and "Success" or "Warning")
    end)
    
    visualSection:Toggle("动态背景", "DynamicBackground", true, function(state)
        NotificationSystem.send("视觉", state and "动态背景已启用" or "动态背景已禁用", 2, state and "Success" or "Warning")
    end)
    
    return {
        UI = CyberNova,
        Notifications = NotificationSystem,
        VisualEffects = VisualEffects,
        createTab = createAdvancedTab,
        sendNotification = NotificationSystem.send
    }
end

-- 导出API
local AdvancedFengUI = createAdvancedUI()

-- 添加全局访问
if not getgenv then getgenv = function() return _G end end
getgenv().CyberNova = AdvancedFengUI
getgenv().FengUI = AdvancedFengUI  -- 保持向后兼容

-- 示例用法
task.wait(2)
AdvancedFengUI.sendNotification("系统就绪", "CyberNova UI 已加载完成！", 4, "Success")

return AdvancedFengUI