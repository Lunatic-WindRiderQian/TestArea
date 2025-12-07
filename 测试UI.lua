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

-- 极致高级蓝紫配色方案
local config = {
    -- 主色调 - 深邃黑蓝紫
    MainColor = Color3.fromRGB(8, 10, 25),
    TabColor = Color3.fromRGB(12, 15, 35),
    Bg_Color = Color3.fromRGB(15, 18, 40),
    Zy_Color = Color3.fromRGB(18, 20, 45),
    
    -- 元素颜色 - 镭射蓝紫
    Button_Color = Color3.fromRGB(30, 32, 65),
    Textbox_Color = Color3.fromRGB(32, 34, 68),
    Dropdown_Color = Color3.fromRGB(34, 36, 72),
    Keybind_Color = Color3.fromRGB(36, 38, 75),
    Label_Color = Color3.fromRGB(38, 40, 78),
    Slider_Color = Color3.fromRGB(40, 42, 82),
    
    -- 动态效果色 - 霓虹蓝紫
    SliderBar_Color = Color3.fromRGB(140, 110, 240),
    Toggle_Color = Color3.fromRGB(42, 44, 85),
    Toggle_Off = Color3.fromRGB(60, 62, 100),
    Toggle_On = Color3.fromRGB(150, 120, 250),
    
    -- 强调色 - 全息蓝紫
    AccentColor = Color3.fromRGB(150, 120, 250),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryTextColor = Color3.fromRGB(200, 210, 255),
    GlowColor = Color3.fromRGB(120, 90, 220),
    
    -- 新增顶级效果颜色
    CyberBlue = Color3.fromRGB(30, 144, 255),      -- 赛博蓝
    NeonPurple = Color3.fromRGB(147, 51, 234),    -- 霓虹紫
    HologramBlue = Color3.fromRGB(64, 224, 208),  -- 全息蓝
    GlitchPurple = Color3.fromRGB(186, 85, 211),  -- 故障紫
    MatrixGreen = Color3.fromRGB(0, 255, 128),    -- 矩阵绿（点缀）
    EnergyCyan = Color3.fromRGB(0, 255, 255),     -- 能量青
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

-- 赛博朋克数字粒子爆炸效果
function DigitalParticleExplosion(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        
        local x = (mouse.X - obj.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - obj.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        
        -- 创建多层爆炸中心
        for i = 1, 3 do
            local explosionCenter = Instance.new("Frame")
            explosionCenter.Name = "ExplosionCenter_" .. i
            explosionCenter.Parent = obj
            explosionCenter.BackgroundColor3 = i == 1 and config.NeonPurple or 
                                             i == 2 and config.HologramBlue or 
                                             config.EnergyCyan
            explosionCenter.BackgroundTransparency = 0.2
            explosionCenter.ZIndex = 8 + i
            explosionCenter.Size = UDim2.new(0, 10 * i, 0, 10 * i)
            explosionCenter.AnchorPoint = Vector2.new(0.5, 0.5)
            explosionCenter.Position = UDim2.new(x, 0, y, 0)
            
            local centerCorner = Instance.new("UICorner")
            centerCorner.CornerRadius = UDim.new(1, 0)
            centerCorner.Parent = explosionCenter
            
            local centerGlow = Instance.new("UIStroke")
            centerGlow.Parent = explosionCenter
            centerGlow.Color = explosionCenter.BackgroundColor3
            centerGlow.Thickness = 3
            centerGlow.Transparency = 0.1
            
            -- 创建流光效果
            local flowConnection
            local hue = 0
            flowConnection = RunService.Heartbeat:Connect(function()
                if not explosionCenter or not explosionCenter.Parent then
                    flowConnection:Disconnect()
                    return
                end
                hue = (hue + 0.05) % 1
                local newColor = Color3.fromHSV(hue, 0.8, 1)
                explosionCenter.BackgroundColor3 = newColor
                centerGlow.Color = newColor
            end)
            
            services.TweenService:Create(explosionCenter, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 40 * i, 0, 40 * i),
                BackgroundTransparency = 1
            }):Play()
            
            services.TweenService:Create(centerGlow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Thickness = 8,
                Transparency = 1
            }):Play()
            
            delay(0.4, function()
                if explosionCenter then
                    explosionCenter:Destroy()
                end
                flowConnection:Disconnect()
            end)
        end
        
        -- 创建大量数字粒子
        local particleCount = 24
        local particles = {}
        
        for i = 1, particleCount do
            local angle = (i / particleCount) * math.pi * 2
            local distance = math.random(50, 120)
            
            local particle = Instance.new("TextLabel")
            particle.Name = "DigitalParticle_" .. i
            particle.Parent = obj
            particle.BackgroundTransparency = 1
            particle.Text = tostring(math.random(0, 1))
            particle.TextColor3 = i % 3 == 0 and config.NeonPurple or 
                                 i % 3 == 1 and config.HologramBlue or 
                                 config.EnergyCyan
            particle.TextSize = math.random(12, 18)
            particle.Font = Enum.Font.Code
            particle.ZIndex = 9
            particle.Size = UDim2.new(0, 24, 0, 24)
            particle.Position = UDim2.new(x, 0, y, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            
            -- 添加粒子发光
            local particleGlow = Instance.new("UIStroke")
            particleGlow.Parent = particle
            particleGlow.Color = particle.TextColor3
            particleGlow.Thickness = 2
            particleGlow.Transparency = 0.5
            
            table.insert(particles, {
                instance = particle,
                glow = particleGlow,
                angle = angle,
                distance = distance,
                speed = math.random(150, 300),
                rotation = math.random(-180, 180),
                colorIndex = i % 3
            })
        end
        
        local startTime = tick()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local elapsed = tick() - startTime
            
            if elapsed > 1.0 then
                connection:Disconnect()
                for _, particleData in ipairs(particles) do
                    particleData.instance:Destroy()
                end
                return
            end
            
            local progress = elapsed / 1.0
            
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
                particleData.glow.Transparency = 0.5 + progress * 0.5
                
                -- 随机改变数字
                if math.random(1, 4) == 1 then
                    particleData.instance.Text = tostring(math.random(0, 1))
                end
                
                -- 粒子颜色变化
                local colorCycle = tick() * 2 + particleData.angle
                local hue = (colorCycle + particleData.colorIndex * 0.3) % 1
                particleData.instance.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
                particleData.glow.Color = particleData.instance.TextColor3
            end
        end)
        
        -- 创建冲击波效果
        for i = 1, 2 do
            local shockwave = Instance.new("Frame")
            shockwave.Name = "Shockwave_" .. i
            shockwave.Parent = obj
            shockwave.BackgroundTransparency = 1
            shockwave.ZIndex = 7
            shockwave.Size = UDim2.new(0, 0, 0, 0)
            shockwave.AnchorPoint = Vector2.new(0.5, 0.5)
            shockwave.Position = UDim2.new(x, 0, y, 0)
            
            local shockwaveStroke = Instance.new("UIStroke")
            shockwaveStroke.Parent = shockwave
            shockwaveStroke.Color = i == 1 and config.NeonPurple or config.HologramBlue
            shockwaveStroke.Thickness = 3
            shockwaveStroke.Transparency = 0.2
            
            services.TweenService:Create(shockwave, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 150 + i * 30, 0, 150 + i * 30)
            }):Play()
            
            services.TweenService:Create(shockwaveStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Thickness = 1,
                Transparency = 1
            }):Play()
            
            delay(0.8, function()
                shockwave:Destroy()
            end)
        end
    end)
end

-- 高级赛博流光效果
local function startCyberFlowEffect(object, property, speed, isComplex)
    speed = speed or 0.005
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        hue = (hue + speed) % 1
        
        if isComplex then
            -- 复杂赛博渐变：在蓝紫青之间流动
            local time = tick() * 0.3
            local r = 0.2 + 0.2 * math.sin(time + hue * math.pi * 2)
            local g = 0.1 + 0.3 * math.sin(time * 1.3 + hue * math.pi * 2 + 1)
            local b = 0.8 + 0.2 * math.sin(time * 1.7 + hue * math.pi * 2 + 2)
            
            object[property] = Color3.new(
                math.clamp(r, 0.1, 0.4),
                math.clamp(g, 0.05, 0.5),
                math.clamp(b, 0.6, 1.0)
            )
        else
            -- 简约蓝紫渐变
            local baseHue = 0.75  -- 蓝紫色
            local saturation = 0.8
            local value = 0.9 + 0.1 * math.sin(hue * math.pi * 4)
            
            object[property] = Color3.fromHSV(
                (baseHue + 0.1 * math.sin(hue * math.pi * 2)) % 1,
                saturation,
                value
            )
        end
    end)
    return connection
end

-- 脉冲发光效果
local function createPulseGlow(object)
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            pulseConnection:Disconnect()
            return
        end
        
        local alpha = 0.3 + math.sin(tick() * 4) * 0.4
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return pulseConnection
end

-- 全息扫描线效果
local function createHologramScanline(parent)
    local scanline = Instance.new("Frame")
    scanline.Name = "HologramScanline"
    scanline.Parent = parent
    scanline.BackgroundColor3 = config.EnergyCyan
    scanline.BackgroundTransparency = 0.9
    scanline.BorderSizePixel = 0
    scanline.Size = UDim2.new(1, 0, 0, 2)
    scanline.Position = UDim2.new(0, 0, 0, -2)
    scanline.ZIndex = 100
    
    -- 扫描动画
    services.TweenService:Create(scanline, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
        Position = UDim2.new(0, 0, 1, 0)
    }):Play()
    
    -- 透明度动画
    local alphaConnection
    alphaConnection = RunService.Heartbeat:Connect(function()
        if not scanline or not scanline.Parent then
            alphaConnection:Disconnect()
            return
        end
        local position = scanline.Position.Y.Scale
        local alpha = 0.1 + position * 0.3
        scanline.BackgroundTransparency = alpha
    end)
    
    return scanline
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

-- 赛博粒子轨迹
local function createCyberParticleTrail(startPos, endPos, parent)
    local trailCount = 3
    for i = 1, trailCount do
        local trail = Instance.new("Frame")
        trail.Name = "CyberParticleTrail_" .. i
        trail.BackgroundColor3 = i == 1 and config.NeonPurple or 
                                i == 2 and config.HologramBlue or 
                                config.EnergyCyan
        trail.BackgroundTransparency = 0.4
        trail.Size = UDim2.new(0, 6, 0, 6)
        trail.Position = startPos
        trail.Parent = parent
        trail.ZIndex = 100
        
        local trailCorner = Instance.new("UICorner")
        trailCorner.CornerRadius = UDim.new(1, 0)
        trailCorner.Parent = trail
        
        -- 添加发光
        local trailGlow = Instance.new("UIStroke")
        trailGlow.Parent = trail
        trailGlow.Color = trail.BackgroundColor3
        trailGlow.Thickness = 2
        trailGlow.Transparency = 0.3
        
        local delayTime = (i-1) * 0.05
        delay(delayTime, function()
            services.TweenService:Create(trail, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = endPos,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 3, 0, 3)
            }):Play()
            
            services.TweenService:Create(trailGlow, TweenInfo.new(0.3), {
                Thickness = 0,
                Transparency = 1
            }):Play()
            
            delay(0.3, function()
                trail:Destroy()
            end)
        end)
    end
end

-- 创建高级边框效果
local function createPremiumBorder(parent)
    local border = Instance.new("Frame")
    border.Name = "PremiumBorder"
    border.Parent = parent
    border.BackgroundTransparency = 1
    border.Size = UDim2.new(1, 4, 1, 4)
    border.Position = UDim2.new(0, -2, 0, -2)
    border.ZIndex = 999
    
    -- 多层发光边框
    local borderGlow1 = Instance.new("UIStroke")
    borderGlow1.Parent = border
    borderGlow1.Color = config.NeonPurple
    borderGlow1.Thickness = 2
    borderGlow1.Transparency = 0.3
    borderGlow1.LineJoinMode = Enum.LineJoinMode.Round
    
    local borderGlow2 = Instance.new("UIStroke")
    borderGlow2.Parent = border
    borderGlow2.Color = config.HologramBlue
    borderGlow2.Thickness = 4
    borderGlow2.Transparency = 0.7
    borderGlow2.LineJoinMode = Enum.LineJoinMode.Round
    
    local borderGlow3 = Instance.new("UIStroke")
    borderGlow3.Parent = border
    borderGlow3.Color = config.EnergyCyan
    borderGlow3.Thickness = 6
    borderGlow3.Transparency = 0.9
    borderGlow3.LineJoinMode = Enum.LineJoinMode.Round
    
    -- 添加流光效果
    startCyberFlowEffect(borderGlow1, "Color", 0.003, true)
    startCyberFlowEffect(borderGlow2, "Color", 0.005, true)
    startCyberFlowEffect(borderGlow3, "Color", 0.007, true)
    
    -- 添加脉冲效果
    createPulseGlow(borderGlow1)
    
    return border
end

-- 创建矩阵雨效果背景
local function createMatrixRainBackground(parent)
    local matrixContainer = Instance.new("Frame")
    matrixContainer.Name = "MatrixRainBackground"
    matrixContainer.Parent = parent
    matrixContainer.BackgroundTransparency = 1
    matrixContainer.Size = UDim2.new(1, 0, 1, 0)
    matrixContainer.ZIndex = 0
    matrixContainer.ClipsDescendants = true
    
    -- 创建多个雨柱
    local rainColumns = {}
    local columnWidth = 20
    local columnCount = math.floor(parent.AbsoluteSize.X / columnWidth)
    
    for i = 1, columnCount do
        local rainColumn = Instance.new("Frame")
        rainColumn.Name = "RainColumn_" .. i
        rainColumn.Parent = matrixContainer
        rainColumn.BackgroundTransparency = 1
        rainColumn.Size = UDim2.new(0, columnWidth, 1, 0)
        rainColumn.Position = UDim2.new((i-1)/columnCount, 0, 0, 0)
        
        table.insert(rainColumns, rainColumn)
        
        -- 创建雨滴
        coroutine.wrap(function()
            while rainColumn and rainColumn.Parent do
                local dropCount = math.random(3, 8)
                for j = 1, dropCount do
                    local drop = Instance.new("TextLabel")
                    drop.Parent = rainColumn
                    drop.BackgroundTransparency = 1
                    drop.Text = string.char(math.random(33, 126))
                    drop.TextColor3 = config.MatrixGreen
                    drop.TextSize = math.random(10, 16)
                    drop.Font = Enum.Font.Code
                    drop.Size = UDim2.new(1, 0, 0, 20)
                    drop.Position = UDim2.new(0, 0, 0, -20)
                    
                    -- 随机速度
                    local speed = math.random(100, 300)
                    
                    -- 下降动画
                    services.TweenService:Create(drop, TweenInfo.new(speed/100, Enum.EasingStyle.Linear), {
                        Position = UDim2.new(0, 0, 1, 0)
                    }):Play()
                    
                    -- 透明度变化
                    services.TweenService:Create(drop, TweenInfo.new(speed/200, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextTransparency = 0.8
                    }):Play()
                    
                    -- 延迟销毁
                    delay(speed/100 + 0.1, function()
                        drop:Destroy()
                    end)
                end
                
                task.wait(math.random(0.2, 0.8))
            end
        end)()
    end
    
    return matrixContainer
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
            Size = UDim2.new(0, 28, 0, 28)
        }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.3), { 
            TextTransparency = 0,
            TextColor3 = config.NeonPurple
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
        Size = UDim2.new(0, 28, 0, 28)
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.5,
        TextColor3 = config.TextColor
    }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { 
        TextTransparency = 0,
        TextColor3 = config.NeonPurple
    }):Play()
    
    if old[1].AbsolutePosition and new[1].AbsolutePosition then
        createCyberParticleTrail(
            UDim2.new(0, old[1].AbsolutePosition.X + old[1].AbsoluteSize.X/2, 
                      0, old[1].AbsolutePosition.Y + old[1].AbsoluteSize.Y/2),
            UDim2.new(0, new[1].AbsolutePosition.X + new[1].AbsoluteSize.X/2, 
                      0, new[1].AbsolutePosition.Y + new[1].AbsoluteSize.Y/2),
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

-- 创建主窗口
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.MainColor
Main.BackgroundTransparency = 0.1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 480, 0, 300)  -- 稍微放大
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

-- 添加矩阵雨背景
createMatrixRainBackground(Main)

-- 添加主窗口渐变
local mainGradient = Instance.new("UIGradient")
mainGradient.Rotation = 135
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 8, 20)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(10, 15, 35)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(12, 18, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 25))
})
mainGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(1, 0.4)
})
mainGradient.Parent = Main

-- 添加噪点纹理
local noiseTexture = Instance.new("ImageLabel")
noiseTexture.Name = "NoiseTexture"
noiseTexture.Parent = Main
noiseTexture.BackgroundTransparency = 1
noiseTexture.Size = UDim2.new(1, 0, 1, 0)
noiseTexture.Image = "rbxassetid://8881037035"
noiseTexture.ImageTransparency = 0.95
noiseTexture.ImageColor3 = Color3.fromRGB(20, 20, 40)
noiseTexture.ScaleType = Enum.ScaleType.Tile
noiseTexture.TileSize = UDim2.new(0, 100, 0, 100)
noiseTexture.ZIndex = 2

-- 添加扫描线效果
createHologramScanline(Main)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- 添加高级边框
createPremiumBorder(Main)

-- 添加主边框
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(40, 45, 80)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.6
MainStroke.LineJoinMode = Enum.LineJoinMode.Round

-- 添加霓虹发光边框
local neonGlow = Instance.new("UIStroke")
neonGlow.Parent = Main
neonGlow.Thickness = 3
neonGlow.Transparency = 0.8
neonGlow.LineJoinMode = Enum.LineJoinMode.Round

-- 添加流光效果到霓虹边框
startCyberFlowEffect(neonGlow, "Color", 0.004, true)
createPulseGlow(neonGlow)

-- 创建标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 5

-- 标题栏渐变
local titleGradient = Instance.new("UIGradient")
titleGradient.Rotation = 90
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 45)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 30, 65)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 45))
})
titleGradient.Parent = TitleBar

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

-- 标题栏发光
local titleGlow = Instance.new("UIStroke")
titleGlow.Parent = TitleBar
titleGlow.Color = config.NeonPurple
titleGlow.Thickness = 1
titleGlow.Transparency = 0.7
startCyberFlowEffect(titleGlow, "Color", 0.006, true)

-- 标题文字
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "CYBER UI"
TitleText.TextColor3 = config.NeonPurple
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 1

-- 标题文字发光
local titleTextGlow = Instance.new("UIStroke")
titleTextGlow.Parent = TitleText
titleTextGlow.Color = config.NeonPurple
titleTextGlow.Thickness = 2
titleTextGlow.Transparency = 0.8
startCyberFlowEffect(titleTextGlow, "Color", 0.008, true)

-- 标题文字渐变
local titleTextGradient = Instance.new("UIGradient")
titleTextGradient.Rotation = 0
titleTextGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, config.NeonPurple),
    ColorSequenceKeypoint.new(0.5, config.HologramBlue),
    ColorSequenceKeypoint.new(1, config.NeonPurple)
})
titleTextGradient.Parent = TitleText

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.TextSize = 20
CloseButton.ZIndex = 10
CloseButton.TextTransparency = 1

-- 关闭按钮发光
local closeGlow = Instance.new("UIStroke")
closeGlow.Parent = CloseButton
closeGlow.Color = Color3.fromRGB(255, 60, 60)
closeGlow.Thickness = 2
closeGlow.Transparency = 0.7

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 22,
        Size = UDim2.new(0, 28, 0, 28)
    }):Play()
    
    services.TweenService:Create(closeGlow, TweenInfo.new(0.2), {
        Thickness = 3,
        Transparency = 0.3
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 20,
        Size = UDim2.new(0, 25, 0, 25)
    }):Play()
    
    services.TweenService:Create(closeGlow, TweenInfo.new(0.2), {
        Thickness = 2,
        Transparency = 0.7
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(CloseButton)
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 18,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
    
    services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    services.TweenService:Create(neonGlow, TweenInfo.new(0.4), {
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

-- 打开按钮
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.NeonPurple
Open.BackgroundTransparency = 0.8
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.1

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = Open

-- 打开按钮发光
local openGlow = Instance.new("UIStroke")
openGlow.Parent = Open
openGlow.Color = config.NeonPurple
openGlow.Thickness = 2
openGlow.Transparency = 0.5

startCyberFlowEffect(Open, "BackgroundColor3", 0.01, true)
startCyberFlowEffect(openGlow, "Color", 0.008, true)
createPulseGlow(openGlow)

-- 添加扫描线到打开按钮
createHologramScanline(Open)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playEntranceAnimation()
    end
    create3DFlipAnimation(Open, 0.5)
    DigitalParticleExplosion(Open)
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
        create3DFlipAnimation(Open, 0.5)
        DigitalParticleExplosion(Open)
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 45)
TabMain.Size = UDim2.new(0, 380, 0, 255)
TabMain.Visible = false

-- 侧边栏
local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = Color3.fromRGB(15, 18, 40)
Side.BackgroundTransparency = 0.2
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 40)
Side.Size = UDim2.new(0, 95, 0, 260)

-- 侧边栏发光
local sideGlow = Instance.new("UIStroke")
sideGlow.Parent = Side
sideGlow.Color = config.NeonPurple
sideGlow.Thickness = 1
sideGlow.Transparency = 0.7
startCyberFlowEffect(sideGlow, "Color", 0.006, true)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Side

-- 标签按钮容器
local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 10)
TabBtns.Size = UDim2.new(0, 95, 0, 240)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = config.NeonPurple
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None
TabBtns.Visible = false

-- 添加扫描线到标签容器
createHologramScanline(TabBtns)

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y)
    
    TabBtns.ScrollingEnabled = TabBtnsL.AbsoluteContentSize.Y > TabBtns.AbsoluteSize.Y
    TabBtns.ElasticBehavior = Enum.ElasticBehavior.Never
end)

-- 脚本标题
local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.009, 0)
ScriptTitle.Size = UDim2.new(0, 95, 0, 20)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.Text = "CYBER UI"
ScriptTitle.TextColor3 = config.NeonPurple
ScriptTitle.TextSize = 16
ScriptTitle.TextScaled = false
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Center
ScriptTitle.Visible = false

-- 标题发光
local scriptTitleGlow = Instance.new("UIStroke")
scriptTitleGlow.Parent = ScriptTitle
scriptTitleGlow.Color = config.NeonPurple
scriptTitleGlow.Thickness = 1
scriptTitleGlow.Transparency = 0.7
startCyberFlowEffect(scriptTitleGlow, "Color", 0.008, true)

-- 入场动画
local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    Side.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    neonGlow.Transparency = 1
    
    TabMain.Visible = false
    TabBtns.Visible = false
    
    -- 全屏粒子爆炸效果
    for i = 1, 5 do
        delay((i-1) * 0.1, function()
            DigitalParticleExplosion(Main)
        end)
    end
    
    services.TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 480, 0, 300)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.6
    }):Play()
    
    services.TweenService:Create(neonGlow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.8
    }):Play()
    
    task.wait(0.3)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.3)
    
    services.TweenService:Create(Side, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2
    }):Play()
    
    task.wait(0.2)
    
    TabMain.Visible = true
    TabBtns.Visible = true
    
    -- 标签按钮逐个出现动画
    for _, tab in ipairs(TabBtns:GetChildren()) do
        if tab:IsA("ImageLabel") and tab.Name == "TabIco" then
            tab.ImageTransparency = 1
            tab.Size = UDim2.new(0, 0, 0, 0)
            delay(0.1, function()
                services.TweenService:Create(tab, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    ImageTransparency = 0.5,
                    Size = UDim2.new(0, 22, 0, 22)
                }):Play()
            end)
        end
    end
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
        
        -- 复杂颜色变化
        local time = tick() * 0.5
        local r = 0.5 + 0.3 * math.sin(time)
        local g = 0.2 + 0.3 * math.sin(time * 1.3 + 1)
        local b = 0.8 + 0.2 * math.sin(time * 1.7 + 2)
        
        TitleText.TextColor3 = Color3.new(
            math.clamp(r, 0.4, 0.8),
            math.clamp(g, 0.1, 0.5),
            math.clamp(b, 0.6, 1.0)
        )
        
        matrixEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, config.NeonPurple),
            ColorSequenceKeypoint.new(0.5, config.HologramBlue),
            ColorSequenceKeypoint.new(1, config.EnergyCyan)
        })
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 18 + math.sin(tick() * 2) * 3
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

    local scriptName = name or "CYBER UI"
    TitleText.Text = scriptName
    ScriptTitle.Text = scriptName
    
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
        Tab.ScrollBarImageColor3 = config.NeonPurple
        Tab.ScrollBarImageTransparency = 0.5
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        -- 添加扫描线到标签内容
        createHologramScanline(Tab)
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 22, 0, 22)
        TabIco.Image = "rbxassetid://84830962019412"
        TabIco.ImageTransparency = 0.5
        
        -- 图标流光效果
        startCyberFlowEffect(TabIco, "ImageColor3", 0.008, true)
        
        -- 图标发光
        local icoGlow = Instance.new("UIStroke")
        icoGlow.Parent = TabIco
        icoGlow.Color = config.NeonPurple
        icoGlow.Thickness = 2
        icoGlow.Transparency = 0.7
        startCyberFlowEffect(icoGlow, "Color", 0.01, true)
        createPulseGlow(icoGlow)
        
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
        
        -- 标签文字发光
        local tabTextGlow = Instance.new("UIStroke")
        tabTextGlow.Parent = TabText
        tabTextGlow.Color = config.TextColor
        tabTextGlow.Thickness = 1
        tabTextGlow.Transparency = 0.8
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 95, 0, 22)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 6)
        
        TabBtn.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(TabBtn)
            switchTab({ TabIco, Tab })
        end)
        
        TabBtn.MouseEnter:Connect(function()
            services.TweenService:Create(TabIco, TweenInfo.new(0.2), {
                ImageTransparency = 0.2,
                Size = UDim2.new(0, 25, 0, 25)
            }):Play()
            
            services.TweenService:Create(TabText, TweenInfo.new(0.2), {
                TextTransparency = 0.2,
                TextColor3 = config.NeonPurple
            }):Play()
            
            services.TweenService:Create(icoGlow, TweenInfo.new(0.2), {
                Thickness = 3,
                Transparency = 0.5
            }):Play()
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if FengUI.currentTab and FengUI.currentTab[1] ~= TabIco then
                services.TweenService:Create(TabIco, TweenInfo.new(0.2), {
                    ImageTransparency = 0.5,
                    Size = UDim2.new(0, 22, 0, 22)
                }):Play()
                
                services.TweenService:Create(TabText, TweenInfo.new(0.2), {
                    TextTransparency = 0.5,
                    TextColor3 = config.TextColor
                }):Play()
                
                services.TweenService:Create(icoGlow, TweenInfo.new(0.2), {
                    Thickness = 2,
                    Transparency = 0.7
                }):Play()
            end
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
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.95, 0, 0, 40)
            
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.088, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 320, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 区域文字发光
            local sectionTextGlow = Instance.new("UIStroke")
            sectionTextGlow.Parent = SectionText
            sectionTextGlow.Color = config.NeonPurple
            sectionTextGlow.Thickness = 1
            sectionTextGlow.Transparency = 0.8
            startCyberFlowEffect(sectionTextGlow, "Color", 0.006, true)
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, -30, 0, 8)
            SectionOpen.Size = UDim2.new(0, 24, 0, 24)
            SectionOpen.Image = "rbxassetid://84830962019412"
            SectionOpen.ImageColor3 = config.SecondaryTextColor
            
            -- 打开图标发光
            local sectionOpenGlow = Instance.new("UIStroke")
            sectionOpenGlow.Parent = SectionOpen
            sectionOpenGlow.Color = config.SecondaryTextColor
            sectionOpenGlow.Thickness = 2
            sectionOpenGlow.Transparency = 0.7
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(0, 24, 0, 24)
            SectionOpened.Image = "rbxassetid://84830962019412"
            SectionOpened.ImageColor3 = config.NeonPurple
            SectionOpened.ImageTransparency = 1
            
            -- 打开图标发光
            local sectionOpenedGlow = Instance.new("UIStroke")
            sectionOpenedGlow.Parent = SectionOpened
            sectionOpenedGlow.Color = config.NeonPurple
            sectionOpenedGlow.Thickness = 2
            sectionOpenedGlow.Transparency = 0.7
            startCyberFlowEffect(sectionOpenedGlow, "Color", 0.008, true)
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(0, 24, 0, 24)
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 6, 0, 40)
            Objs.Size = UDim2.new(0.98, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 8 or 40)
                SectionOpened.ImageTransparency = open and 0 or 1
                SectionOpen.ImageTransparency = open and 1 or 0
                sectionOpenedGlow.Transparency = open and 0.7 or 1
                sectionOpenGlow.Transparency = open and 1 or 0.7
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                
                DigitalParticleExplosion(SectionToggle)
                
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 8 or 40)
                }):Play()
                
                services.TweenService:Create(SectionOpened, TweenInfo.new(0.3), {
                    ImageTransparency = open and 0 or 1
                }):Play()
                
                services.TweenService:Create(SectionOpen, TweenInfo.new(0.3), {
                    ImageTransparency = open and 1 or 0
                }):Play()
                
                services.TweenService:Create(sectionOpenedGlow, TweenInfo.new(0.3), {
                    Transparency = open and 0.7 or 1
                }):Play()
                
                services.TweenService:Create(sectionOpenGlow, TweenInfo.new(0.3), {
                    Transparency = open and 1 or 0.7
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(0.95, 0, 0, 40 + ObjsL.AbsoluteContentSize.Y + 8)
            end)
            
            local section = {}
            
            function section.MusicPlayer(section, title, defaultPlaylist)
                local MusicPlayerModule = Instance.new("Frame")
                MusicPlayerModule.Name = "MusicPlayerModule"
                MusicPlayerModule.Parent = Objs
                MusicPlayerModule.BackgroundTransparency = 1
                MusicPlayerModule.BorderSizePixel = 0
                MusicPlayerModule.Size = UDim2.new(0, 350, 0, 180)
                
                local PlayerContainer = Instance.new("Frame")
                PlayerContainer.Name = "PlayerContainer"
                PlayerContainer.Parent = MusicPlayerModule
                PlayerContainer.BackgroundColor3 = config.TabColor
                PlayerContainer.BackgroundTransparency = 0.3
                PlayerContainer.Size = UDim2.new(1, 0, 0, 180)
                
                -- 播放器边框
                local playerCorner = Instance.new("UICorner")
                playerCorner.CornerRadius = UDim.new(0, 10)
                playerCorner.Parent = PlayerContainer
                
                -- 播放器发光
                local playerGlow = Instance.new("UIStroke")
                playerGlow.Parent = PlayerContainer
                playerGlow.Color = config.NeonPurple
                playerGlow.Thickness = 2
                playerGlow.Transparency = 0.6
                startCyberFlowEffect(playerGlow, "Color", 0.008, true)
                createPulseGlow(playerGlow)
                
                -- 添加高级边框
                createPremiumBorder(PlayerContainer)
                
                -- 添加扫描线
                createHologramScanline(PlayerContainer)
                
                local TopSection = Instance.new("Frame")
                TopSection.Name = "TopSection"
                TopSection.Parent = PlayerContainer
                TopSection.BackgroundTransparency = 1
                TopSection.Size = UDim2.new(1, 0, 0, 80)
                
                local AlbumArt = Instance.new("ImageLabel")
                AlbumArt.Name = "AlbumArt"
                AlbumArt.Parent = TopSection
                AlbumArt.BackgroundColor3 = config.Bg_Color
                AlbumArt.BackgroundTransparency = 0.2
                AlbumArt.Position = UDim2.new(0.03, 0, 0.1, 0)
                AlbumArt.Size = UDim2.new(0, 60, 0, 60)
                
                local AlbumCorner = Instance.new("UICorner")
                AlbumCorner.CornerRadius = UDim.new(0, 8)
                AlbumCorner.Parent = AlbumArt
                
                -- 专辑封面发光
                local albumGlow = Instance.new("UIStroke")
                albumGlow.Parent = AlbumArt
                albumGlow.Color = config.NeonPurple
                albumGlow.Thickness = 2
                albumGlow.Transparency = 0.7
                startCyberFlowEffect(albumGlow, "Color", 0.01, true)
                
                -- 添加扫描线到专辑封面
                createHologramScanline(AlbumArt)
                
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
                SongTitle.Size = UDim2.new(1, 0, 0, 30)
                SongTitle.Font = Enum.Font.GothamBold
                SongTitle.Text = "没有播放音乐"
                SongTitle.TextColor3 = config.TextColor
                SongTitle.TextSize = 16
                SongTitle.TextXAlignment = Enum.TextXAlignment.Left
                SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
                
                -- 歌曲标题发光
                local songTitleGlow = Instance.new("UIStroke")
                songTitleGlow.Parent = SongTitle
                songTitleGlow.Color = config.NeonPurple
                songTitleGlow.Thickness = 1
                songTitleGlow.Transparency = 0.8
                startCyberFlowEffect(songTitleGlow, "Color", 0.01, true)
                
                local ArtistName = Instance.new("TextLabel")
                ArtistName.Name = "ArtistName"
                ArtistName.Parent = InfoContainer
                ArtistName.BackgroundTransparency = 1
                ArtistName.Position = UDim2.new(0, 0, 0.45, 0)
                ArtistName.Size = UDim2.new(1, 0, 0, 25)
                ArtistName.Font = Enum.Font.Gotham
                ArtistName.Text = "未知艺术家"
                ArtistName.TextColor3 = config.SecondaryTextColor
                ArtistName.TextSize = 14
                ArtistName.TextXAlignment = Enum.TextXAlignment.Left
                ArtistName.TextTruncate = Enum.TextTruncate.AtEnd
                
                local BottomSection = Instance.new("Frame")
                BottomSection.Name = "BottomSection"
                BottomSection.Parent = PlayerContainer
                BottomSection.BackgroundTransparency = 1
                BottomSection.Position = UDim2.new(0, 0, 0.44, 0)
                BottomSection.Size = UDim2.new(1, 0, 0, 100)
                
                local ProgressBar = Instance.new("Frame")
                ProgressBar.Name = "ProgressBar"
                ProgressBar.Parent = BottomSection
                ProgressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                ProgressBar.BorderSizePixel = 0
                ProgressBar.Position = UDim2.new(0.03, 0, 0.05, 0)
                ProgressBar.Size = UDim2.new(0.94, 0, 0, 8)
                
                local ProgressBarCorner = Instance.new("UICorner")
                ProgressBarCorner.CornerRadius = UDim.new(1, 0)
                ProgressBarCorner.Parent = ProgressBar
                
                -- 进度条发光
                local progressBarGlow = Instance.new("UIStroke")
                progressBarGlow.Parent = ProgressBar
                progressBarGlow.Color = config.NeonPurple
                progressBarGlow.Thickness = 1
                progressBarGlow.Transparency = 0.7
                
                local ProgressFill = Instance.new("Frame")
                ProgressFill.Name = "ProgressFill"
                ProgressFill.Parent = ProgressBar
                ProgressFill.BackgroundColor3 = config.NeonPurple
                ProgressFill.BorderSizePixel = 0
                ProgressFill.Size = UDim2.new(0, 0, 1, 0)
                
                -- 进度填充发光
                startCyberFlowEffect(ProgressFill, "BackgroundColor3", 0.015, true)
                
                local ProgressFillCorner = Instance.new("UICorner")
                ProgressFillCorner.CornerRadius = UDim.new(1, 0)
                ProgressFillCorner.Parent = ProgressFill
                
                local TimeLabel = Instance.new("TextLabel")
                TimeLabel.Name = "TimeLabel"
                TimeLabel.Parent = BottomSection
                TimeLabel.BackgroundTransparency = 1
                TimeLabel.Position = UDim2.new(0.03, 0, 0.18, 0)
                TimeLabel.Size = UDim2.new(0.94, 0, 0, 20)
                TimeLabel.Font = Enum.Font.Gotham
                TimeLabel.Text = "0:00 / 0:00"
                TimeLabel.TextColor3 = config.SecondaryTextColor
                TimeLabel.TextSize = 12
                TimeLabel.TextXAlignment = Enum.TextXAlignment.Center
                
                local ControlsContainer = Instance.new("Frame")
                ControlsContainer.Name = "ControlsContainer"
                ControlsContainer.Parent = BottomSection
                ControlsContainer.BackgroundTransparency = 1
                ControlsContainer.Position = UDim2.new(0, 0, 0.35, 0)
                ControlsContainer.Size = UDim2.new(1, 0, 0, 50)
                
                local function createControlButton(name, text, position, size, isMain)
                    local button = Instance.new("TextButton")
                    button.Name = name
                    button.Parent = ControlsContainer
                    button.BackgroundColor3 = isMain and config.NeonPurple or Color3.fromRGB(180, 180, 180)
                    button.BackgroundTransparency = isMain and 0.2 or 0.1
                    button.Position = position
                    button.Size = size
                    button.AutoButtonColor = false
                    button.Font = Enum.Font.GothamBold
                    button.Text = text
                    button.TextColor3 = isMain and config.TextColor or Color3.fromRGB(50, 50, 50)
                    button.TextSize = isMain and 18 or 14
                    button.ZIndex = 5
                    
                    local buttonCorner = Instance.new("UICorner")
                    buttonCorner.CornerRadius = UDim.new(1, 0)
                    buttonCorner.Parent = button
                    
                    -- 按钮发光
                    local buttonGlow = Instance.new("UIStroke")
                    buttonGlow.Parent = button
                    buttonGlow.Color = isMain and config.NeonPurple or Color3.fromRGB(150, 150, 150)
                    buttonGlow.Thickness = isMain and 2 or 1
                    buttonGlow.Transparency = isMain and 0.6 or 0.7
                    buttonGlow.ZIndex = 4
                    
                    if isMain then
                        startCyberFlowEffect(buttonGlow, "Color", 0.015, true)
                        createPulseGlow(buttonGlow)
                    end
                    
                    -- 悬停效果
                    button.MouseEnter:Connect(function()
                        DigitalParticleExplosion(button)
                        
                        services.TweenService:Create(button, TweenInfo.new(0.2), {
                            BackgroundTransparency = isMain and 0.1 or 0,
                            Size = UDim2.new(0, size.X.Offset + 4, 0, size.Y.Offset + 4)
                        }):Play()
                        
                        services.TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
                            Thickness = isMain and 3 or 2,
                            Transparency = isMain and 0.3 or 0.4
                        }):Play()
                    end)
                    
                    button.MouseLeave:Connect(function()
                        services.TweenService:Create(button, TweenInfo.new(0.2), {
                            BackgroundTransparency = isMain and 0.2 or 0.1,
                            Size = size
                        }):Play()
                        
                        services.TweenService:Create(buttonGlow, TweenInfo.new(0.2), {
                            Thickness = isMain and 2 or 1,
                            Transparency = isMain and 0.6 or 0.7
                        }):Play()
                    end)
                    
                    return button, buttonGlow
                end
                
                -- 创建控制按钮
                local PrevButton, prevGlow = createControlButton("PrevButton", "⏮", UDim2.new(0.15, 0, 0.2, 0), UDim2.new(0, 36, 0, 36), false)
                local PlayPauseButton, playGlow = createControlButton("PlayPauseButton", "▶", UDim2.new(0.42, 0, 0.1, 0), UDim2.new(0, 40, 0, 40), true)
                local NextButton, nextGlow = createControlButton("NextButton", "⏭", UDim2.new(0.69, 0, 0.2, 0), UDim2.new(0, 36, 0, 36), false)
                local LoopButton, loopGlow = createControlButton("LoopButton", "🔁", UDim2.new(0.85, 0, 0.2, 0), UDim2.new(0, 36, 0, 36), false)
                
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
                
                -- 更新进度条
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
                    DigitalParticleExplosion(button)
                    
                    services.TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundTransparency = isMain and 0.3 or 0.2,
                        Size = UDim2.new(0, button.Size.X.Offset - 2, 0, button.Size.Y.Offset - 2)
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(button, TweenInfo.new(0.2), {
                        BackgroundTransparency = isMain and 0.2 or 0.1,
                        Size = UDim2.new(0, button.Size.X.Offset + 4, 0, button.Size.Y.Offset + 4)
                    }):Play()
                end
                
                PlayPauseButton.MouseButton1Click:Connect(function()
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
                    createButtonClickEffect(PrevButton, false)
                    local track = MusicPlayer:PreviousTrack()
                    if track then
                        updateUI()
                    end
                end)
                
                NextButton.MouseButton1Click:Connect(function()
                    createButtonClickEffect(NextButton, false)
                    local track = MusicPlayer:NextTrack()
                    if track then
                        updateUI()
                    end
                end)
                
                LoopButton.MouseButton1Click:Connect(function()
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
                BtnModule.Size = UDim2.new(0, 350, 0, 40)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.2
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, 350, 0, 40)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 16
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                
                BtnC.CornerRadius = UDim.new(0, 8)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                -- 按钮发光
                local btnGlow = Instance.new("UIStroke")
                btnGlow.Parent = Btn
                btnGlow.Color = config.NeonPurple
                btnGlow.Thickness = 2
                btnGlow.Transparency = 0.6
                
                startCyberFlowEffect(btnGlow, "Color", 0.01, true)
                createPulseGlow(btnGlow)
                
                -- 添加扫描线
                createHologramScanline(Btn)
                
                Btn.MouseEnter:Connect(function()
                    DigitalParticleExplosion(Btn)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.2),
                            math.floor(config.Button_Color.G * 255 * 1.2),
                            math.floor(config.Button_Color.B * 255 * 1.2)
                        ),
                        BackgroundTransparency = 0.1
                    }):Play()
                    
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 3,
                        Transparency = 0.4,
                        Color = config.HologramBlue
                    }):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Button_Color,
                        BackgroundTransparency = 0.2
                    }):Play()
                    
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.6,
                        Color = config.NeonPurple
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
                        Thickness = 4,
                        Transparency = 0.2
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.6
                    }):Play()
                end)
                
                local btnFuncs = {}
                
                function btnFuncs:SetText(newText)
                    Btn.Text = "   " .. newText
                end
                
                function btnFuncs:SetCallback(newCallback)
                    callback = newCallback or function() end
                end
                
                function btnFuncs:Module()
                    return BtnModule
                end
                
                return btnFuncs
            end
            
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, 350, 0, sizeY or 140)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or 150, 340), 0, sizeY or 140)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 8)
                ImageCorner.Parent = ImageLabel
                
                -- 图片发光
                local imageGlow = Instance.new("UIStroke")
                imageGlow.Parent = ImageLabel
                imageGlow.Color = config.NeonPurple
                imageGlow.Thickness = 2
                imageGlow.Transparency = 0.6
                startCyberFlowEffect(imageGlow, "Color", 0.008, true)
                
                -- 添加扫描线
                createHologramScanline(ImageLabel)
                
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
                LabelModule.Size = UDim2.new(0, 350, 0, 28)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.2
                TextLabel.Size = UDim2.new(0, 350, 0, 32)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 14
                
                -- 标签发光
                local labelGlow = Instance.new("UIStroke")
                labelGlow.Parent = TextLabel
                labelGlow.Color = config.NeonPurple
                labelGlow.Thickness = 1
                labelGlow.Transparency = 0.7
                startCyberFlowEffect(labelGlow, "Color", 0.006, true)
                
                LabelC.CornerRadius = UDim.new(0, 8)
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
                ToggleModule.Size = UDim2.new(0, 350, 0, 40)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.2
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, 350, 0, 40)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 16
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 开关发光
                local toggleBtnGlow = Instance.new("UIStroke")
                toggleBtnGlow.Parent = ToggleBtn
                toggleBtnGlow.Color = config.NeonPurple
                toggleBtnGlow.Thickness = 2
                toggleBtnGlow.Transparency = 0.6
                startCyberFlowEffect(toggleBtnGlow, "Color", 0.01, true)
                
                ToggleBtnC.CornerRadius = UDim.new(0, 8)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = config.Bg_Color
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.85, 0, 0.22, 0)
                ToggleDisable.Size = UDim2.new(0, 40, 0, 22)
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)
                ToggleSwitch.Position = UDim2.new(0, enabled and 16 or 0, 0, 0)
                
                -- 开关滑块发光
                local switchGlow = Instance.new("UIStroke")
                switchGlow.Parent = ToggleSwitch
                switchGlow.Color = enabled and config.NeonPurple or Color3.fromRGB(100, 100, 100)
                switchGlow.Thickness = 2
                switchGlow.Transparency = 0.7
                
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(0, 6)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                -- 悬停效果
                ToggleBtn.MouseEnter:Connect(function()
                    DigitalParticleExplosion(ToggleBtn)
                    
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Toggle_Color.R * 255 * 1.15),
                            math.floor(config.Toggle_Color.G * 255 * 1.15),
                            math.floor(config.Toggle_Color.B * 255 * 1.15)
                        )
                    }):Play()
                    
                    services.TweenService:Create(toggleBtnGlow, TweenInfo.new(0.2), {
                        Thickness = 3,
                        Transparency = 0.4
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Toggle_Color
                    }):Play()
                    
                    services.TweenService:Create(toggleBtnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.6
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
                        
                        DigitalParticleExplosion(ToggleSwitch)
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, state and 16 or 0, 0, 0),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        services.TweenService:Create(switchGlow, TweenInfo.new(0.3), {
                            Color = state and config.NeonPurple or Color3.fromRGB(100, 100, 100)
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
                KeybindModule.Size = UDim2.new(0, 350, 0, 40)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.2
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, 350, 0, 40)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 16
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 键绑发光
                local keybindBtnGlow = Instance.new("UIStroke")
                keybindBtnGlow.Parent = KeybindBtn
                keybindBtnGlow.Color = config.NeonPurple
                keybindBtnGlow.Thickness = 2
                keybindBtnGlow.Transparency = 0.6
                startCyberFlowEffect(keybindBtnGlow, "Color", 0.01, true)
                
                KeybindBtnC.CornerRadius = UDim.new(0, 8)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.72, 0, 0.22, 0)
                KeybindValue.Size = UDim2.new(0, 80, 0, 25)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 14
                
                -- 键值发光
                local keybindValueGlow = Instance.new("UIStroke")
                keybindValueGlow.Parent = KeybindValue
                keybindValueGlow.Color = config.NeonPurple
                keybindValueGlow.Thickness = 2
                keybindValueGlow.Transparency = 0.7
                
                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue
                
                KeybindL.Name = "KeybindL"
                KeybindL.Parent = KeybindBtn
                KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
                KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center
                
                UIPadding.Parent = KeybindBtn
                UIPadding.PaddingRight = UDim.new(0, 10)
                
                -- 悬停效果
                KeybindBtn.MouseEnter:Connect(function()
                    DigitalParticleExplosion(KeybindBtn)
                    
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Keybind_Color.R * 255 * 1.15),
                            math.floor(config.Keybind_Color.G * 255 * 1.15),
                            math.floor(config.Keybind_Color.B * 255 * 1.15)
                        )
                    }):Play()
                    
                    services.TweenService:Create(keybindBtnGlow, TweenInfo.new(0.2), {
                        Thickness = 3,
                        Transparency = 0.4
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Keybind_Color
                    }):Play()
                    
                    services.TweenService:Create(keybindBtnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.6
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
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 25)
                end)
                
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 25)
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
                TextboxModule.Size = UDim2.new(0, 350, 0, 40)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.2
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, 350, 0, 40)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 16
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 文本框发光
                local textboxBackGlow = Instance.new("UIStroke")
                textboxBackGlow.Parent = TextboxBack
                textboxBackGlow.Color = config.NeonPurple
                textboxBackGlow.Thickness = 2
                textboxBackGlow.Transparency = 0.6
                startCyberFlowEffect(textboxBackGlow, "Color", 0.01, true)
                
                TextboxBackC.CornerRadius = UDim.new(0, 8)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.45, 0, 0.22, 0)
                BoxBG.Size = UDim2.new(0, 100, 0, 25)
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
                TextBox.TextSize = 14
                TextBox.PlaceholderColor3 = config.SecondaryTextColor
                
                TextboxBackL.Name = "TextboxBackL"
                TextboxBackL.Parent = TextboxBack
                TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
                TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center
                
                TextboxBackP.Name = "TextboxBackP"
                TextboxBackP.Parent = TextboxBack
                TextboxBackP.PaddingRight = UDim.new(0, 15)
                
                -- 悬停效果
                TextboxBack.MouseEnter:Connect(function()
                    DigitalParticleExplosion(TextboxBack)
                    
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Textbox_Color.R * 255 * 1.15),
                            math.floor(config.Textbox_Color.G * 255 * 1.15),
                            math.floor(config.Textbox_Color.B * 255 * 1.15)
                        )
                    }):Play()
                    
                    services.TweenService:Create(textboxBackGlow, TweenInfo.new(0.2), {
                        Thickness = 3,
                        Transparency = 0.4
                    }):Play()
                end)
                
                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Textbox_Color
                    }):Play()
                    
                    services.TweenService:Create(textboxBackGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.6
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
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 25)
                end)
                
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 25)
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
                SliderModule.Size = UDim2.new(0, 350, 0, 40)
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.2
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(0, 350, 0, 40)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderBack.TextSize = 16.000
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 滑块发光
                local sliderBackGlow = Instance.new("UIStroke")
                sliderBackGlow.Parent = SliderBack
                sliderBackGlow.Color = config.NeonPurple
                sliderBackGlow.Thickness = 2
                sliderBackGlow.Transparency = 0.6
                startCyberFlowEffect(sliderBackGlow, "Color", 0.01, true)
                
                SliderBackC.CornerRadius = UDim.new(0, 8)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.35, 0, 0.5, 0)
                SliderBar.Size = UDim2.new(0, 130, 0, 16)
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
                
                -- 滑块填充发光
                startCyberFlowEffect(SliderPart, "BackgroundColor3", 0.015, true)
                
                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBack
                SliderValBG.BackgroundColor3 = config.Bg_Color
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.82, 0, 0.22, 0)
                SliderValBG.Size = UDim2.new(0, 40, 0, 25)
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
                SliderValue.TextSize = 12.000
                
                local MinSlider = Instance.new("TextButton")
                MinSlider.Name = "MinSlider"
                MinSlider.Parent = SliderBack
                MinSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                MinSlider.BackgroundTransparency = 0
                MinSlider.BorderSizePixel = 0
                MinSlider.Position = UDim2.new(0.28, 0, 0.25, 0)
                MinSlider.Size = UDim2.new(0, 20, 0, 20)
                MinSlider.Font = Enum.Font.Gotham
                MinSlider.Text = "-"
                MinSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                MinSlider.TextSize = 16.000
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
                AddSlider.Size = UDim2.new(0, 20, 0, 20)
                AddSlider.Font = Enum.Font.Gotham
                AddSlider.Text = "+"
                AddSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
                AddSlider.TextSize = 16.000
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
                DropdownModule.Size = UDim2.new(0, 350, 0, 40)
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0.2
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(0, 350, 0, 40)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = config.TextColor
                DropdownTop.TextSize = 16.000
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 下拉框发光
                local dropdownTopGlow = Instance.new("UIStroke")
                dropdownTopGlow.Parent = DropdownTop
                dropdownTopGlow.Color = config.NeonPurple
                dropdownTopGlow.Thickness = 2
                dropdownTopGlow.Transparency = 0.6
                startCyberFlowEffect(dropdownTopGlow, "Color", 0.01, true)
                
                DropdownTopC.CornerRadius = UDim.new(0, 8)
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
                DropdownOpenFrame.Size = UDim2.new(0, 40, 0, 25)
                DropdownOpenFrame.ZIndex = 2
                
                -- 打开按钮发光
                local openFrameGlow = Instance.new("UIStroke")
                openFrameGlow.Parent = DropdownOpenFrame
                openFrameGlow.Color = config.NeonPurple
                openFrameGlow.Thickness = 2
                openFrameGlow.Transparency = 0.7
                
                DropdownOpenFrameC.CornerRadius = UDim.new(0, 6)
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
                DropdownOpen.TextSize = 12.000
                DropdownOpen.TextWrapped = true
                DropdownOpen.ZIndex = 3
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownText.BackgroundTransparency = 1.000
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 240, 0, 40)
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
                Separator.Size = UDim2.new(0, 1, 0, 25)
                Separator.ZIndex = 1
                
                DropdownModuleL.Name = "DropdownModuleL"
                DropdownModuleL.Parent = DropdownModule
                DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownModuleL.Padding = UDim.new(0, 6)
                
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
                    
                    DropdownModule.Size = UDim2.new(0, 350, 0, open and (40 + DropdownModuleL.AbsoluteContentSize.Y + 6) or 40)
                    
                    create3DFlipAnimation(DropdownOpenFrame, 0.3)
                    DigitalParticleExplosion(DropdownOpenFrame)
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
                        DropdownModule.Size = UDim2.new(0, 350, 0, 40 + DropdownModuleL.AbsoluteContentSize.Y + 6)
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
                    Option.Size = UDim2.new(0, 330, 0, 28)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 14.000
                    
                    -- 选项发光
                    local optionGlow = Instance.new("UIStroke")
                    optionGlow.Parent = Option
                    optionGlow.Color = config.NeonPurple
                    optionGlow.Thickness = 1
                    optionGlow.Transparency = 0.7
                    
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
                    
                    -- 悬停效果
                    Option.MouseEnter:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.TabColor.R * 255 * 1.15),
                                math.floor(config.TabColor.G * 255 * 1.15),
                                math.floor(config.TabColor.B * 255 * 1.15)
                            )
                        }):Play()
                        
                        services.TweenService:Create(optionGlow, TweenInfo.new(0.2), {
                            Thickness = 2,
                            Transparency = 0.5
                        }):Play()
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = config.TabColor
                        }):Play()
                        
                        services.TweenService:Create(optionGlow, TweenInfo.new(0.2), {
                            Thickness = 1,
                            Transparency = 0.7
                        }):Play()
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