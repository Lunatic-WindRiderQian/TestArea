repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

-- 优化设置
local optimizedConfig = {
    WindowSize = {Width = 600, Height = 380}, -- 增大窗口尺寸
    SidebarWidth = 110, -- 左侧边栏宽度
    TabContainerWidth = 490, -- 右侧内容区域宽度
    CardSize = {Width = 120, Height = 120}, -- 卡片尺寸
    CardSpacing = 8, -- 卡片间距
    SectionHeight = 40, -- 分段标题高度
    AnimationSpeed = 0.25, -- 动画速度
}

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
FengUI.currentCard = nil

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    HttpService = game:GetService("HttpService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService
local HttpService = services.HttpService

-- 高级配色方案
local config = {
    -- 主色调
    PrimaryColor = Color3.fromRGB(18, 18, 30),
    SecondaryColor = Color3.fromRGB(25, 25, 40),
    TertiaryColor = Color3.fromRGB(35, 35, 55),
    
    -- UI元素颜色
    WindowBg = Color3.fromRGB(15, 15, 25),
    SidebarBg = Color3.fromRGB(20, 20, 35),
    ContentBg = Color3.fromRGB(12, 12, 20),
    CardBg = Color3.fromRGB(25, 25, 40),
    SectionBg = Color3.fromRGB(30, 30, 50),
    ButtonBg = Color3.fromRGB(40, 40, 65),
    InputBg = Color3.fromRGB(35, 35, 55),
    
    -- 功能色
    AccentColor = Color3.fromRGB(0, 200, 255),
    SuccessColor = Color3.fromRGB(0, 230, 118),
    WarningColor = Color3.fromRGB(255, 145, 0),
    DangerColor = Color3.fromRGB(255, 60, 60),
    InfoColor = Color3.fromRGB(100, 220, 255),
    
    -- 文字颜色
    PrimaryText = Color3.fromRGB(240, 245, 255),
    SecondaryText = Color3.fromRGB(180, 190, 210),
    DisabledText = Color3.fromRGB(120, 130, 150),
    
    -- 特殊效果
    GlowColor = Color3.fromRGB(0, 150, 255),
    NeonFlow = Color3.fromHSV(0.58, 0.8, 1),
    HologramTint = Color3.fromRGB(200, 220, 255),
    
    -- 开关状态
    ToggleOn = Color3.fromRGB(0, 230, 230),
    ToggleOff = Color3.fromRGB(70, 70, 100),
    
    -- 滑块
    SliderTrack = Color3.fromRGB(60, 60, 80),
    SliderFill = Color3.fromRGB(0, 200, 255),
}

-- 音乐播放器保持原样
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

-- 高级粒子效果（优化版）
function DigitalParticleExplosion(obj, intensity)
    if not obj or not obj.Parent then return end
    intensity = intensity or 1
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        
        local x = (mouse.X - obj.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - obj.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        
        -- 创建中心爆炸效果
        local explosionCenter = Instance.new("Frame")
        explosionCenter.Name = "ExplosionCenter"
        explosionCenter.Parent = obj
        explosionCenter.BackgroundColor3 = config.AccentColor
        explosionCenter.BackgroundTransparency = 0.1
        explosionCenter.ZIndex = 50
        explosionCenter.Size = UDim2.new(0, 16, 0, 16)
        explosionCenter.AnchorPoint = Vector2.new(0.5, 0.5)
        explosionCenter.Position = UDim2.new(x, 0, y, 0)
        
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1, 0)
        centerCorner.Parent = explosionCenter
        
        local centerGlow = Instance.new("UIStroke")
        centerGlow.Parent = explosionCenter
        centerGlow.Color = config.GlowColor
        centerGlow.Thickness = 3
        centerGlow.Transparency = 0.1
        
        -- 光环效果
        local halo = Instance.new("Frame")
        halo.Name = "Halo"
        halo.Parent = obj
        halo.BackgroundTransparency = 1
        halo.ZIndex = 49
        halo.Size = UDim2.new(0, 0, 0, 0)
        halo.AnchorPoint = Vector2.new(0.5, 0.5)
        halo.Position = UDim2.new(x, 0, y, 0)
        
        local haloStroke = Instance.new("UIStroke")
        haloStroke.Parent = halo
        haloStroke.Color = config.AccentColor
        haloStroke.Thickness = 2
        haloStroke.Transparency = 0.3
        
        services.TweenService:Create(halo, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 80 * intensity, 0, 80 * intensity)
        }):Play()
        
        services.TweenService:Create(haloStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 1
        }):Play()
        
        -- 数字粒子
        local particleCount = math.floor(16 * intensity)
        local particles = {}
        
        for i = 1, particleCount do
            local angle = (i / particleCount) * math.pi * 2
            local distance = math.random(30, 120) * intensity
            
            local particle = Instance.new("TextLabel")
            particle.Name = "DigitalParticle_" .. i
            particle.Parent = obj
            particle.BackgroundTransparency = 1
            particle.Text = tostring(math.random(0, 1))
            particle.TextColor3 = Color3.fromRGB(
                math.random(100, 255),
                math.random(100, 255),
                255
            )
            particle.TextSize = math.random(12, 16)
            particle.Font = Enum.Font.Code
            particle.ZIndex = 51
            particle.Size = UDim2.new(0, 24, 0, 24)
            particle.Position = UDim2.new(x, 0, y, 0)
            particle.AnchorPoint = Vector2.new(0.5, 0.5)
            
            table.insert(particles, {
                instance = particle,
                angle = angle,
                distance = distance,
                speed = math.random(200, 300),
                rotation = math.random(-180, 180)
            })
        end
        
        services.TweenService:Create(explosionCenter, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 36 * intensity, 0, 36 * intensity),
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
                halo:Destroy()
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
                particleData.instance.TextColor3 = Color3.fromRGB(
                    255,
                    255 - progress * 155,
                    255 - progress * 55
                )
                
                if math.random(1, 2) == 1 then
                    particleData.instance.Text = tostring(math.random(0, 1))
                end
            end
        end)
        
        task.wait(0.6)
        halo:Destroy()
    end)
end

-- 优化后的霓虹流光效果
local function startNeonFlowEffect(object, property, speed)
    speed = speed or 0.005
    local hue = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        hue = (hue + speed) % 1
        
        -- 使用平滑的颜色过渡
        local r = (math.sin(hue * math.pi * 2 + 0) * 0.3 + 0.7) * 0.8
        local g = (math.sin(hue * math.pi * 2 + 2.09) * 0.3 + 0.7) * 0.9
        local b = (math.sin(hue * math.pi * 2 + 4.19) * 0.3 + 0.7) * 1.0
        
        object[property] = Color3.new(r, g, b)
    end)
    
    return connection
end

-- 创建高级全息效果
local function createHologramEffect(frame, intensity)
    intensity = intensity or 1
    
    local hologram = Instance.new("Frame")
    hologram.Name = "HologramEffect"
    hologram.BackgroundTransparency = 1
    hologram.Size = UDim2.new(1, 0, 1, 0)
    hologram.ZIndex = frame.ZIndex - 1
    hologram.Parent = frame
    hologram.ClipsDescendants = true
    
    -- 扫描线效果
    local scanLines = Instance.new("Frame")
    scanLines.Name = "ScanLines"
    scanLines.BackgroundTransparency = 1
    scanLines.Size = UDim2.new(1, 0, 1, 0)
    scanLines.Parent = hologram
    
    local linePattern = Instance.new("UIGradient")
    linePattern.Rotation = 0
    linePattern.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(0.05, 0.85),
        NumberSequenceKeypoint.new(0.1, 0.95),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    linePattern.Parent = scanLines
    
    -- 彩色辉光
    local glow = Instance.new("UIGradient")
    glow.Rotation = 45
    glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.3, 0.2 * intensity),
        NumberSequenceKeypoint.new(0.7, 0.2 * intensity),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    
    local colors = {
        ColorSequenceKeypoint.new(0, config.AccentColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 220, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 255))
    }
    glow.Color = ColorSequence.new(colors)
    glow.Parent = hologram
    
    -- 网格效果
    local grid = Instance.new("Frame")
    grid.Name = "Grid"
    grid.BackgroundTransparency = 1
    grid.Size = UDim2.new(1, 0, 1, 0)
    grid.Parent = hologram
    
    local gridPattern = Instance.new("UIGridLayout")
    gridPattern.CellSize = UDim2.new(0, 20, 0, 20)
    gridPattern.CellPadding = UDim2.new(0, 1, 0, 1)
    gridPattern.Parent = grid
    
    for i = 1, 100 do
        local cell = Instance.new("Frame")
        cell.BackgroundTransparency = 0.95
        cell.BackgroundColor3 = config.HologramTint
        cell.BorderSizePixel = 0
        cell.Parent = grid
    end
    
    -- 动画连接
    local scanConnection
    scanConnection = RunService.Heartbeat:Connect(function()
        if not scanLines or not scanLines.Parent then
            scanConnection:Disconnect()
            return
        end
        linePattern.Offset = Vector2.new(0, (tick() * 0.3) % 1)
    end)
    
    local colorConnection
    colorConnection = RunService.Heartbeat:Connect(function()
        if not hologram or not hologram.Parent then
            colorConnection:Disconnect()
            return
        end
        
        local time = tick() * 0.1
        local newColors = {
            ColorSequenceKeypoint.new(0, Color3.fromHSV((time) % 1, 0.7, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((time + 0.3) % 1, 0.8, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((time + 0.6) % 1, 0.7, 1))
        }
        glow.Color = ColorSequence.new(newColors)
    end)
    
    return hologram
end

-- 创建脉动辉光
local function createPulseGlow(object)
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            pulseConnection:Disconnect()
            return
        end
        
        local alpha = 0.6 + math.sin(tick() * 2) * 0.2
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return pulseConnection
end

-- 创建平滑滚动设置
local function setupSmoothScrolling(scrollingFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        
        if layout.AbsoluteContentSize.Y <= scrollingFrame.AbsoluteSize.Y then
            scrollingFrame.ScrollingEnabled = false
        else
            scrollingFrame.ScrollingEnabled = true
        end
    end)
    
    scrollingFrame.ScrollBarImageColor3 = config.SecondaryText
    scrollingFrame.ScrollBarImageTransparency = 0.6
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

-- 标签切换功能
local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { 
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 100, 0, 32)
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
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { 
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 100, 0, 28)
    }):Play()
    services.TweenService:Create(new[1], tweenInfo, { 
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 100, 0, 32)
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.3,
        TextColor3 = config.SecondaryText
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

-- 创建主UI
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui
FengYu.Enabled = ToggleUI

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.WindowBg
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, optimizedConfig.WindowSize.Width, 0, optimizedConfig.WindowSize.Height)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

-- 窗口圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- 窗口边框
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 1

-- 霓虹边框
local neonStroke = Instance.new("UIStroke")
neonStroke.Parent = Main
neonStroke.Thickness = 2
neonStroke.Transparency = 1
neonStroke.LineJoinMode = Enum.LineJoinMode.Round
startNeonFlowEffect(neonStroke, "Color", 0.008)

createPulseGlow(neonStroke)

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.SecondaryColor
TitleBar.BackgroundTransparency = 1
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 2

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "FengUI"
TitleText.TextColor3 = config.AccentColor
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 1

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = config.DangerColor
CloseButton.BackgroundTransparency = 0.8
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.ZIndex = 10
CloseButton.TextTransparency = 1
CloseButton.AutoButtonColor = false

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 20, 0, 20)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(CloseButton, 1.2)
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 18, 0, 18)
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
        TextTransparency = 1,
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.4)
    FengYu:Destroy()
end)

-- 最小化按钮
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = config.WarningColor
MinimizeButton.BackgroundTransparency = 0.8
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -65, 0.5, -10)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.ZIndex = 10
MinimizeButton.TextTransparency = 1
MinimizeButton.AutoButtonColor = false

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(1, 0)
MinimizeCorner.Parent = MinimizeButton

MinimizeButton.MouseEnter:Connect(function()
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
end)

MinimizeButton.MouseLeave:Connect(function()
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 20, 0, 20)
    }):Play()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(MinimizeButton, 0.8)
    Main.Visible = false
    Open.Visible = true
end)

-- 打开按钮
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.Position = UDim2.new(0.95, 0, 0.02, 0)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15
Open.Visible = false

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(180, 180, 180)
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0.4

startNeonFlowEffect(Open, "BackgroundColor3", 0.01)
createPulseGlow(OpenStroke)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    Open.Visible = false
    if Main.Visible then
        playEntranceAnimation()
    end
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        Open.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
    end
end)

-- 卡片容器
local CardsContainer = Instance.new("Frame")
CardsContainer.Name = "CardsContainer"
CardsContainer.Parent = Main
CardsContainer.BackgroundTransparency = 1
CardsContainer.Position = UDim2.new(0, 0, 0, 45)
CardsContainer.Size = UDim2.new(1, 0, 1, -45)
CardsContainer.Visible = true

local CardsLayout = Instance.new("UIGridLayout")
CardsLayout.Parent = CardsContainer
CardsLayout.CellSize = UDim2.new(0, optimizedConfig.CardSize.Width, 0, optimizedConfig.CardSize.Height)
CardsLayout.CellPadding = UDim2.new(0, optimizedConfig.CardSpacing, 0, optimizedConfig.CardSpacing)
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
CardsLayout.StartCorner = Enum.StartCorner.TopLeft

-- 主容器（左右分区）
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = Main
MainContainer.BackgroundTransparency = 1
MainContainer.Position = UDim2.new(0, 0, 0, 45)
MainContainer.Size = UDim2.new(1, 0, 1, -45)
MainContainer.Visible = false

-- 左侧边栏
local LeftSidebar = Instance.new("Frame")
LeftSidebar.Name = "LeftSidebar"
LeftSidebar.Parent = MainContainer
LeftSidebar.BackgroundColor3 = config.SidebarBg
LeftSidebar.BackgroundTransparency = 0.9
LeftSidebar.BorderSizePixel = 0
LeftSidebar.Position = UDim2.new(0, 0, 0, 0)
LeftSidebar.Size = UDim2.new(0, optimizedConfig.SidebarWidth, 1, 0)
LeftSidebar.Visible = false

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = LeftSidebar

createHologramEffect(LeftSidebar, 0.2)

-- 右侧内容区域
local RightContent = Instance.new("Frame")
RightContent.Name = "RightContent"
RightContent.Parent = MainContainer
RightContent.BackgroundColor3 = config.ContentBg
RightContent.BackgroundTransparency = 0.9
RightContent.BorderSizePixel = 0
RightContent.Position = UDim2.new(0, optimizedConfig.SidebarWidth + 5, 0, 0)
RightContent.Size = UDim2.new(1, -(optimizedConfig.SidebarWidth + 5), 1, 0)
RightContent.Visible = false

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = RightContent

-- 返回卡片按钮
local ReturnToCardsButton = Instance.new("TextButton")
ReturnToCardsButton.Name = "ReturnToCardsButton"
ReturnToCardsButton.Parent = LeftSidebar
ReturnToCardsButton.BackgroundColor3 = config.ButtonBg
ReturnToCardsButton.BackgroundTransparency = 0.2
ReturnToCardsButton.BorderSizePixel = 0
ReturnToCardsButton.Position = UDim2.new(0.05, 0, 0.02, 0)
ReturnToCardsButton.Size = UDim2.new(0.9, 0, 0, 32)
ReturnToCardsButton.AutoButtonColor = false
ReturnToCardsButton.Font = Enum.Font.GothamBold
ReturnToCardsButton.Text = "← 返回首页"
ReturnToCardsButton.TextColor3 = config.PrimaryText
ReturnToCardsButton.TextSize = 12
ReturnToCardsButton.TextScaled = true

local ReturnButtonCorner = Instance.new("UICorner")
ReturnButtonCorner.CornerRadius = UDim.new(0, 6)
ReturnButtonCorner.Parent = ReturnToCardsButton

local returnGlow = Instance.new("UIStroke")
returnGlow.Parent = ReturnToCardsButton
returnGlow.Color = config.AccentColor
returnGlow.Thickness = 1.5
returnGlow.Transparency = 0.7

startNeonFlowEffect(returnGlow, "Color", 0.015)
createPulseGlow(returnGlow)

ReturnToCardsButton.MouseEnter:Connect(function()
    services.TweenService:Create(ReturnToCardsButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0.92, 0, 0, 34)
    }):Play()
    services.TweenService:Create(returnGlow, TweenInfo.new(0.2), {
        Thickness = 2,
        Transparency = 0.5
    }):Play()
end)

ReturnToCardsButton.MouseLeave:Connect(function()
    services.TweenService:Create(ReturnToCardsButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0.9, 0, 0, 32)
    }):Play()
    services.TweenService:Create(returnGlow, TweenInfo.new(0.2), {
        Thickness = 1.5,
        Transparency = 0.7
    }):Play()
end)

local function showCards()
    FengUI.showingCards = true
    CardsContainer.Visible = true
    MainContainer.Visible = false
    
    if FengUI.currentTab then
        FengUI.currentTab[2].Visible = false
        FengUI.currentTab = nil
    end
    
    if FengUI.currentCard then
        FengUI.currentCard.tabContainer.Visible = false
        FengUI.currentCard.sideContainer.Visible = false
        FengUI.currentCard = nil
    end
    
    services.TweenService:Create(CardsContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
end

ReturnToCardsButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(ReturnToCardsButton)
    showCards()
end)

-- 动画函数
local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    MinimizeButton.TextTransparency = 1
    CardsContainer.BackgroundTransparency = 1
    MainContainer.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    neonStroke.Transparency = 1
    
    MainContainer.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, optimizedConfig.WindowSize.Width, 0, optimizedConfig.WindowSize.Height)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.4
    }):Play()
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.6
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        BackgroundTransparency = 0.8
    }):Play()
    
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        BackgroundTransparency = 0.8
    }):Play()
    
    task.wait(0.2)
    
    if FengUI.showingCards then
        CardsContainer.Visible = true
        services.TweenService:Create(CardsContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
    else
        MainContainer.Visible = true
        services.TweenService:Create(MainContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.9
        }):Play()
    end
    
    DigitalParticleExplosion(Main, 1.5)
end

-- 标题动画
task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

-- 标题特效
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
        hue = (hue + 0.02) % 1
        
        TitleText.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        
        matrixEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV((hue + 0.2) % 1, 0.9, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(hue, 0.9, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue - 0.2) % 1, 0.9, 1))
        })
        
        task.wait(0.05)
    end
end)

-- 主要的UI创建函数
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
    
    -- 创建卡片
    function window.card(window, name, description, icon)
        local Card = Instance.new("TextButton")
        Card.Name = "Card_" .. name
        Card.Parent = CardsContainer
        Card.BackgroundColor3 = config.CardBg
        Card.BackgroundTransparency = 0.15
        Card.AutoButtonColor = false
        Card.Text = ""
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 14)
        CardCorner.Parent = Card
        
        local CardGlow = Instance.new("UIStroke")
        CardGlow.Parent = Card
        CardGlow.Color = config.AccentColor
        CardGlow.Thickness = 2.5
        CardGlow.Transparency = 0.6
        
        startNeonFlowEffect(CardGlow, "Color", 0.01)
        createPulseGlow(CardGlow)
        
        local CardIcon = Instance.new("ImageLabel")
        CardIcon.Name = "CardIcon"
        CardIcon.Parent = Card
        CardIcon.BackgroundTransparency = 1
        CardIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        CardIcon.Position = UDim2.new(0.5, 0, 0.35, 0)
        CardIcon.Size = UDim2.new(0, 48, 0, 48)
        CardIcon.Image = "rbxassetid://" .. tostring(icon or "84830962019412")
        CardIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        
        local CardTitle = Instance.new("TextLabel")
        CardTitle.Name = "CardTitle"
        CardTitle.Parent = Card
        CardTitle.BackgroundTransparency = 1
        CardTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        CardTitle.Position = UDim2.new(0.5, 0, 0.68, 0)
        CardTitle.Size = UDim2.new(0.85, 0, 0, 24)
        CardTitle.Font = Enum.Font.GothamBold
        CardTitle.Text = name
        CardTitle.TextColor3 = config.PrimaryText
        CardTitle.TextSize = 14
        CardTitle.TextScaled = false
        
        local CardDescription = Instance.new("TextLabel")
        CardDescription.Name = "CardDescription"
        CardDescription.Parent = Card
        CardDescription.BackgroundTransparency = 1
        CardDescription.AnchorPoint = Vector2.new(0.5, 0.5)
        CardDescription.Position = UDim2.new(0.5, 0, 0.88, 0)
        CardDescription.Size = UDim2.new(0.85, 0, 0, 18)
        CardDescription.Font = Enum.Font.Gotham
        CardDescription.Text = description or ""
        CardDescription.TextColor3 = config.SecondaryText
        CardDescription.TextSize = 11
        CardDescription.TextScaled = false
        CardDescription.TextWrapped = true
        
        local CardShadow = Instance.new("ImageLabel")
        CardShadow.Name = "CardShadow"
        CardShadow.Parent = Card
        CardShadow.BackgroundTransparency = 1
        CardShadow.Size = UDim2.new(1, 12, 1, 12)
        CardShadow.Position = UDim2.new(0, -6, 0, -6)
        CardShadow.Image = "rbxassetid://5554236805"
        CardShadow.ImageColor3 = Color3.new(0, 0, 0)
        CardShadow.ImageTransparency = 0.8
        CardShadow.ScaleType = Enum.ScaleType.Slice
        CardShadow.SliceCenter = Rect.new(23, 23, 277, 277)
        CardShadow.ZIndex = -1
        
        -- 创建标签容器（在右侧内容区域）
        local tabContainer = Instance.new("Frame")
        tabContainer.Name = "TabContainer_" .. name
        tabContainer.Parent = RightContent
        tabContainer.BackgroundTransparency = 1
        tabContainer.Size = UDim2.new(1, 0, 1, 0)
        tabContainer.Visible = false
        
        -- 创建侧边栏容器（在左侧边栏）
        local sideContainer = Instance.new("Frame")
        sideContainer.Name = "SideContainer_" .. name
        sideContainer.Parent = LeftSidebar
        sideContainer.BackgroundColor3 = config.SidebarBg
        sideContainer.BackgroundTransparency = 0.8
        sideContainer.BorderSizePixel = 0
        sideContainer.ClipsDescendants = true
        sideContainer.Size = UDim2.new(1, 0, 1, -40)
        sideContainer.Position = UDim2.new(0, 0, 0, 40)
        sideContainer.Visible = false
        
        local sideCorner = Instance.new("UICorner")
        sideCorner.CornerRadius = UDim.new(0, 8)
        sideCorner.Parent = sideContainer
        
        createHologramEffect(sideContainer, 0.2)
        
        -- 标签按钮容器
        local tabBtns = Instance.new("ScrollingFrame")
        tabBtns.Name = "TabBtns"
        tabBtns.Parent = sideContainer
        tabBtns.Active = true
        tabBtns.BackgroundTransparency = 1
        tabBtns.BorderSizePixel = 0
        tabBtns.Position = UDim2.new(0, 5, 0, 5)
        tabBtns.Size = UDim2.new(1, -10, 1, -10)
        tabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabBtns.ScrollBarThickness = 4
        
        local tabBtnsL = Instance.new("UIListLayout")
        tabBtnsL.Name = "TabBtnsL"
        tabBtnsL.Parent = tabBtns
        tabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
        tabBtnsL.Padding = UDim.new(0, 8)
        
        setupSmoothScrolling(tabBtns, tabBtnsL)
        
        -- 存储容器引用
        local cardData = {
            name = name,
            tabContainer = tabContainer,
            sideContainer = sideContainer,
            tabBtns = tabBtns
        }
        
        FengUI.tabContainers[name] = cardData
        
        -- 卡片交互效果
        Card.MouseEnter:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.05,
                Size = UDim2.new(0, optimizedConfig.CardSize.Width + 10, 0, optimizedConfig.CardSize.Height + 10)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 3.5,
                Transparency = 0.4
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 52, 0, 52),
                Rotation = 8
            }):Play()
            services.TweenService:Create(CardShadow, TweenInfo.new(0.3), {
                ImageTransparency = 0.6,
                Size = UDim2.new(1, 16, 1, 16),
                Position = UDim2.new(0, -8, 0, -8)
            }):Play()
        end)
        
        Card.MouseLeave:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.15,
                Size = UDim2.new(0, optimizedConfig.CardSize.Width, 0, optimizedConfig.CardSize.Height)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 2.5,
                Transparency = 0.6
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 48, 0, 48),
                Rotation = 0,
                ImageTransparency = 0
            }):Play()
            services.TweenService:Create(CardShadow, TweenInfo.new(0.3), {
                ImageTransparency = 0.8,
                Size = UDim2.new(1, 12, 1, 12),
                Position = UDim2.new(0, -6, 0, -6)
            }):Play()
        end)
        
        local function showTabContainer()
            for _, containerData in pairs(FengUI.tabContainers) do
                containerData.tabContainer.Visible = false
                containerData.sideContainer.Visible = false
            end
            
            tabContainer.Visible = true
            sideContainer.Visible = true
            LeftSidebar.Visible = true
            RightContent.Visible = true
            
            FengUI.showingCards = false
            FengUI.currentCard = cardData
            CardsContainer.Visible = false
            MainContainer.Visible = true
        end
        
        Card.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(Card, 1.2)
            showTabContainer()
        end)
        
        local cardObj = {}
        
        -- 创建标签页
        function cardObj.Tab(cardObj, tabName, tabIcon)
            -- 创建标签按钮
            local TabBtn = Instance.new("TextButton")
            TabBtn.Name = "TabBtn_" .. tabName
            TabBtn.Parent = tabBtns
            TabBtn.BackgroundColor3 = config.ButtonBg
            TabBtn.BackgroundTransparency = 0.3
            TabBtn.BorderSizePixel = 0
            TabBtn.Size = UDim2.new(1, 0, 0, 32)
            TabBtn.AutoButtonColor = false
            TabBtn.Text = ""
            
            local TabBtnCorner = Instance.new("UICorner")
            TabBtnCorner.CornerRadius = UDim.new(0, 6)
            TabBtnCorner.Parent = TabBtn
            
            local TabText = Instance.new("TextLabel")
            TabText.Name = "TabText"
            TabText.Parent = TabBtn
            TabText.BackgroundTransparency = 1
            TabText.Size = UDim2.new(1, 0, 1, 0)
            TabText.Font = Enum.Font.GothamSemibold
            TabText.Text = tabName
            TabText.TextColor3 = config.SecondaryText
            TabText.TextSize = 13
            TabText.TextXAlignment = Enum.TextXAlignment.Center
            
            local tabGlow = Instance.new("UIStroke")
            tabGlow.Parent = TabBtn
            tabGlow.Color = config.AccentColor
            tabGlow.Thickness = 1.5
            tabGlow.Transparency = 0.8
            
            -- 创建标签内容容器
            local Tab = Instance.new("ScrollingFrame")
            Tab.Name = "Tab_" .. tabName
            Tab.Parent = tabContainer
            Tab.Active = true
            Tab.BackgroundTransparency = 1
            Tab.Size = UDim2.new(1, 0, 1, 0)
            Tab.ScrollBarThickness = 4
            Tab.ScrollBarImageTransparency = 0.6
            Tab.Visible = false
            Tab.ElasticBehavior = Enum.ElasticBehavior.Never
            Tab.ScrollingDirection = Enum.ScrollingDirection.Y
            Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local TabL = Instance.new("UIListLayout")
            TabL.Name = "TabL"
            TabL.Parent = Tab
            TabL.SortOrder = Enum.SortOrder.LayoutOrder
            TabL.Padding = UDim.new(0, 8)
            
            setupSmoothScrolling(Tab, TabL)
            
            -- 标签按钮交互
            TabBtn.MouseEnter:Connect(function()
                services.TweenService:Create(TabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.2
                }):Play()
                services.TweenService:Create(tabGlow, TweenInfo.new(0.2), {
                    Thickness = 2,
                    Transparency = 0.6
                }):Play()
            end)
            
            TabBtn.MouseLeave:Connect(function()
                if FengUI.currentTab and FengUI.currentTab[1] == TabBtn then return end
                services.TweenService:Create(TabBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.3
                }):Play()
                services.TweenService:Create(tabGlow, TweenInfo.new(0.2), {
                    Thickness = 1.5,
                    Transparency = 0.8
                }):Play()
            end)
            
            TabBtn.MouseButton1Click:Connect(function()
                DigitalParticleExplosion(TabBtn, 0.8)
                switchTab({ TabBtn, Tab })
            end)
            
            if FengUI.currentTab == nil then
                switchTab({ TabBtn, Tab })
            end
            
            local tabObj = {}
            
            -- 创建分段（支持左右分区）
            function tabObj.section(tabObj, name, side, opened)
                side = side or "right" -- left 或 right
                opened = opened == nil and true or opened
                
                local Section = Instance.new("Frame")
                local SectionC = Instance.new("UICorner")
                local SectionText = Instance.new("TextLabel")
                local SectionToggle = Instance.new("ImageButton")
                local SectionIcon = Instance.new("ImageLabel")
                local Objs = Instance.new("Frame")
                local ObjsL = Instance.new("UIListLayout")
                
                Section.Name = "Section_" .. name
                Section.Parent = Tab
                Section.BackgroundColor3 = config.SectionBg
                Section.BackgroundTransparency = 0.15
                Section.BorderSizePixel = 0
                Section.ClipsDescendants = true
                Section.Size = UDim2.new(0.96, 0, 0, optimizedConfig.SectionHeight)
                
                SectionC.CornerRadius = UDim.new(0, 8)
                SectionC.Name = "SectionC"
                SectionC.Parent = Section
                
                SectionIcon.Name = "SectionIcon"
                SectionIcon.Parent = Section
                SectionIcon.BackgroundTransparency = 1
                SectionIcon.Position = UDim2.new(0.03, 0, 0.5, -10)
                SectionIcon.Size = UDim2.new(0, 20, 0, 20)
                SectionIcon.Image = "rbxassetid://84830962019412"
                SectionIcon.ImageColor3 = config.AccentColor
                
                SectionText.Name = "SectionText"
                SectionText.Parent = Section
                SectionText.BackgroundTransparency = 1
                SectionText.Position = UDim2.new(0.1, 0, 0, 0)
                SectionText.Size = UDim2.new(0.8, 0, 1, 0)
                SectionText.Font = Enum.Font.GothamSemibold
                SectionText.Text = name
                SectionText.TextColor3 = config.PrimaryText
                SectionText.TextSize = 14
                SectionText.TextXAlignment = Enum.TextXAlignment.Left
                
                SectionToggle.Name = "SectionToggle"
                SectionToggle.Parent = Section
                SectionToggle.BackgroundTransparency = 1
                SectionToggle.BorderSizePixel = 0
                SectionToggle.Position = UDim2.new(0.9, 0, 0.5, -10)
                SectionToggle.Size = UDim2.new(0, 20, 0, 20)
                SectionToggle.Image = opened and "rbxassetid://6031068421" or "rbxassetid://6031068426"
                SectionToggle.ImageColor3 = config.SecondaryText
                
                Objs.Name = "Objs"
                Objs.Parent = Section
                Objs.BackgroundTransparency = 1
                Objs.BorderSizePixel = 0
                Objs.Position = UDim2.new(0, 10, 0, optimizedConfig.SectionHeight + 5)
                Objs.Size = UDim2.new(0.96, -20, 0, 0)
                
                ObjsL.Name = "ObjsL"
                ObjsL.Parent = Objs
                ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
                ObjsL.Padding = UDim.new(0, 8)
                
                local open = opened
                if opened then
                    Section.Size = UDim2.new(0.96, 0, 0, optimizedConfig.SectionHeight + ObjsL.AbsoluteContentSize.Y + 10)
                    SectionToggle.Image = "rbxassetid://6031068421"
                else
                    SectionToggle.Image = "rbxassetid://6031068426"
                end
                
                SectionToggle.MouseButton1Click:Connect(function()
                    open = not open
                    DigitalParticleExplosion(SectionToggle, 0.5)
                    
                    services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0.96, 0, 0, open and (optimizedConfig.SectionHeight + ObjsL.AbsoluteContentSize.Y + 10) or optimizedConfig.SectionHeight)
                    }):Play()
                    
                    services.TweenService:Create(SectionToggle, TweenInfo.new(0.3), {
                        Image = open and "rbxassetid://6031068421" or "rbxassetid://6031068426",
                        Rotation = open and 180 or 0
                    }):Play()
                end)
                
                ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if not open then return end
                    Section.Size = UDim2.new(0.96, 0, 0, optimizedConfig.SectionHeight + ObjsL.AbsoluteContentSize.Y + 10)
                end)
                
                local section = {}
                
                -- 按钮组件
                function section.Button(section, text, callback)
                    callback = callback or function() end
                    
                    local BtnModule = Instance.new("Frame")
                    local Btn = Instance.new("TextButton")
                    local BtnC = Instance.new("UICorner")
                    local BtnIcon = Instance.new("ImageLabel")
                    
                    BtnModule.Name = "BtnModule"
                    BtnModule.Parent = Objs
                    BtnModule.BackgroundTransparency = 1
                    BtnModule.BorderSizePixel = 0
                    BtnModule.Size = UDim2.new(1, 0, 0, 38)
                    
                    Btn.Name = "Btn"
                    Btn.Parent = BtnModule
                    Btn.BackgroundColor3 = config.ButtonBg
                    Btn.BackgroundTransparency = 0.2
                    Btn.BorderSizePixel = 0
                    Btn.Size = UDim2.new(1, 0, 0, 38)
                    Btn.AutoButtonColor = false
                    Btn.Font = Enum.Font.GothamSemibold
                    Btn.Text = "  " .. text
                    Btn.TextColor3 = config.PrimaryText
                    Btn.TextSize = 13
                    Btn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    BtnIcon.Name = "BtnIcon"
                    BtnIcon.Parent = Btn
                    BtnIcon.BackgroundTransparency = 1
                    BtnIcon.Position = UDim2.new(0.92, 0, 0.5, -10)
                    BtnIcon.Size = UDim2.new(0, 20, 0, 20)
                    BtnIcon.Image = "rbxassetid://6031280882"
                    BtnIcon.ImageColor3 = config.SecondaryText
                    
                    BtnC.CornerRadius = UDim.new(0, 6)
                    BtnC.Name = "BtnC"
                    BtnC.Parent = Btn
                    
                    local btnGlow = Instance.new("UIStroke")
                    btnGlow.Parent = Btn
                    btnGlow.Color = config.AccentColor
                    btnGlow.Thickness = 1.5
                    btnGlow.Transparency = 0.7
                    
                    startNeonFlowEffect(btnGlow, "Color", 0.01)
                    createPulseGlow(btnGlow)
                    
                    Btn.MouseEnter:Connect(function()
                        services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.1,
                            Size = UDim2.new(1, 2, 0, 40)
                        }):Play()
                        services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                            Thickness = 2,
                            Transparency = 0.5
                        }):Play()
                    end)
                    
                    Btn.MouseLeave:Connect(function()
                        services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.2,
                            Size = UDim2.new(1, 0, 0, 38)
                        }):Play()
                        services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                            Thickness = 1.5,
                            Transparency = 0.7
                        }):Play()
                    end)
                    
                    Btn.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(Btn, 0.8)
                        callback()
                        
                        services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                            BackgroundTransparency = 0.3
                        }):Play()
                        services.TweenService:Create(btnGlow, TweenInfo.new(0.1), {
                            Thickness = 2.5,
                            Transparency = 0.3
                        }):Play()
                        
                        task.wait(0.1)
                        
                        services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2
                        }):Play()
                        services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                            Thickness = 1.5,
                            Transparency = 0.7
                        }):Play()
                    end)
                end
                
                -- 切换组件
                function section.Toggle(section, text, flag, enabled, callback)
                    callback = callback or function() end
                    enabled = enabled or false
                    assert(text, "No text provided")
                    assert(flag, "No flag provided")
                    FengUI.flags[flag] = enabled

                    local ToggleModule = Instance.new("Frame")
                    local ToggleBtn = Instance.new("TextButton")
                    local ToggleBtnC = Instance.new("UICorner")
                    local ToggleSwitch = Instance.new("Frame")
                    local ToggleSwitchC = Instance.new("UICorner")
                    
                    ToggleModule.Name = "ToggleModule"
                    ToggleModule.Parent = Objs
                    ToggleModule.BackgroundTransparency = 1
                    ToggleModule.BorderSizePixel = 0
                    ToggleModule.Size = UDim2.new(1, 0, 0, 38)
                    
                    ToggleBtn.Name = "ToggleBtn"
                    ToggleBtn.Parent = ToggleModule
                    ToggleBtn.BackgroundColor3 = config.ButtonBg
                    ToggleBtn.BackgroundTransparency = 0.2
                    ToggleBtn.BorderSizePixel = 0
                    ToggleBtn.Size = UDim2.new(1, 0, 0, 38)
                    ToggleBtn.AutoButtonColor = false
                    ToggleBtn.Font = Enum.Font.GothamSemibold
                    ToggleBtn.Text = "  " .. text
                    ToggleBtn.TextColor3 = config.PrimaryText
                    ToggleBtn.TextSize = 13
                    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    ToggleBtnC.CornerRadius = UDim.new(0, 6)
                    ToggleBtnC.Name = "ToggleBtnC"
                    ToggleBtnC.Parent = ToggleBtn
                    
                    ToggleSwitch.Name = "ToggleSwitch"
                    ToggleSwitch.Parent = ToggleBtn
                    ToggleSwitch.BackgroundColor3 = enabled and config.ToggleOn or config.ToggleOff
                    ToggleSwitch.BorderSizePixel = 0
                    ToggleSwitch.Position = UDim2.new(0.88, 0, 0.5, -10)
                    ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                    
                    ToggleSwitchC.CornerRadius = UDim.new(1, 0)
                    ToggleSwitchC.Name = "ToggleSwitchC"
                    ToggleSwitchC.Parent = ToggleSwitch
                    
                    -- 开关指示器
                    local switchIndicator = Instance.new("Frame")
                    switchIndicator.Name = "SwitchIndicator"
                    switchIndicator.Parent = ToggleSwitch
                    switchIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    switchIndicator.BorderSizePixel = 0
                    switchIndicator.Size = UDim2.new(0, 16, 0, 16)
                    switchIndicator.Position = UDim2.new(0, enabled and 22 or 2, 0.5, -8)
                    
                    local switchIndicatorC = Instance.new("UICorner")
                    switchIndicatorC.CornerRadius = UDim.new(1, 0)
                    switchIndicatorC.Parent = switchIndicator
                    
                    local toggleGlow = Instance.new("UIStroke")
                    toggleGlow.Parent = ToggleBtn
                    toggleGlow.Color = config.AccentColor
                    toggleGlow.Thickness = 1.5
                    toggleGlow.Transparency = 0.7
                    
                    ToggleBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.1
                        }):Play()
                    end)
                    
                    ToggleBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.2
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
                            
                            FengUI.flags[flag] = state
                            
                            services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = state and config.ToggleOn or config.ToggleOff
                            }):Play()
                            
                            services.TweenService:Create(switchIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Position = UDim2.new(0, state and 22 or 2, 0.5, -8)
                            }):Play()
                            
                            if state then
                                createHologramEffect(ToggleSwitch, 0.3)
                            else
                                local hologram = ToggleSwitch:FindFirstChild("HologramEffect")
                                if hologram then
                                    hologram:Destroy()
                                end
                            end
                            
                            callback(state)
                        end,
                        Module = ToggleModule
                    }
                    
                    if enabled ~= false then
                        funcs:SetState(true)
                    end
                    
                    ToggleBtn.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(ToggleBtn, 0.6)
                        funcs:SetState()
                    end)
                    
                    return funcs
                end
                
                -- 滑块组件
                function section.Slider(section, text, flag, default, min, max, precise, callback)
                    callback = callback or function() end
                    min = min or 0
                    max = max or 100
                    default = default or min
                    precise = precise or false
                    
                    assert(text, "No text provided")
                    assert(flag, "No flag provided")
                    
                    FengUI.flags[flag] = default

                    local SliderModule = Instance.new("Frame")
                    local SliderBack = Instance.new("Frame")
                    local SliderBackC = Instance.new("UICorner")
                    local SliderBar = Instance.new("Frame")
                    local SliderBarC = Instance.new("UICorner")
                    local SliderFill = Instance.new("Frame")
                    local SliderFillC = Instance.new("UICorner")
                    local SliderValue = Instance.new("TextLabel")
                    local SliderText = Instance.new("TextLabel")
                    
                    SliderModule.Name = "SliderModule"
                    SliderModule.Parent = Objs
                    SliderModule.BackgroundTransparency = 1
                    SliderModule.BorderSizePixel = 0
                    SliderModule.Size = UDim2.new(1, 0, 0, 60)
                    
                    SliderBack.Name = "SliderBack"
                    SliderBack.Parent = SliderModule
                    SliderBack.BackgroundColor3 = config.ButtonBg
                    SliderBack.BackgroundTransparency = 0.2
                    SliderBack.BorderSizePixel = 0
                    SliderBack.Size = UDim2.new(1, 0, 0, 60)
                    
                    SliderBackC.CornerRadius = UDim.new(0, 6)
                    SliderBackC.Name = "SliderBackC"
                    SliderBackC.Parent = SliderBack
                    
                    SliderText.Name = "SliderText"
                    SliderText.Parent = SliderBack
                    SliderText.BackgroundTransparency = 1
                    SliderText.Position = UDim2.new(0.03, 0, 0.1, 0)
                    SliderText.Size = UDim2.new(0.6, 0, 0, 20)
                    SliderText.Font = Enum.Font.GothamSemibold
                    SliderText.Text = text
                    SliderText.TextColor3 = config.PrimaryText
                    SliderText.TextSize = 13
                    SliderText.TextXAlignment = Enum.TextXAlignment.Left
                    
                    SliderBar.Name = "SliderBar"
                    SliderBar.Parent = SliderBack
                    SliderBar.BackgroundColor3 = config.SliderTrack
                    SliderBar.BorderSizePixel = 0
                    SliderBar.Position = UDim2.new(0.03, 0, 0.55, 0)
                    SliderBar.Size = UDim2.new(0.94, 0, 0, 8)
                    
                    SliderBarC.CornerRadius = UDim.new(1, 0)
                    SliderBarC.Name = "SliderBarC"
                    SliderBarC.Parent = SliderBar
                    
                    SliderFill.Name = "SliderFill"
                    SliderFill.Parent = SliderBar
                    SliderFill.BackgroundColor3 = config.SliderFill
                    SliderFill.BorderSizePixel = 0
                    SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                    
                    SliderFillC.CornerRadius = UDim.new(1, 0)
                    SliderFillC.Name = "SliderFillC"
                    SliderFillC.Parent = SliderFill
                    
                    SliderValue.Name = "SliderValue"
                    SliderValue.Parent = SliderBack
                    SliderValue.BackgroundTransparency = 1
                    SliderValue.Position = UDim2.new(0.75, 0, 0.1, 0)
                    SliderValue.Size = UDim2.new(0.2, 0, 0, 20)
                    SliderValue.Font = Enum.Font.GothamSemibold
                    SliderValue.Text = tostring(default)
                    SliderValue.TextColor3 = config.AccentColor
                    SliderValue.TextSize = 13
                    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                    
                    local sliderGlow = Instance.new("UIStroke")
                    sliderGlow.Parent = SliderBack
                    sliderGlow.Color = config.AccentColor
                    sliderGlow.Thickness = 1.5
                    sliderGlow.Transparency = 0.7
                    
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
                            
                            services.TweenService:Create(SliderFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Size = UDim2.new(percent, 0, 1, 0)
                            }):Play()
                            
                            callback(tonumber(value))
                            
                            DigitalParticleExplosion(SliderFill, 0.3)
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
                    
                    SliderFill.InputBegan:Connect(function(input)
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
                    
                    return funcs
                end
                
                -- 文本框组件
                function section.Textbox(section, text, flag, placeholder, callback)
                    callback = callback or function() end
                    assert(text, "No text provided")
                    assert(flag, "No flag provided")
                    
                    FengUI.flags[flag] = ""

                    local TextboxModule = Instance.new("Frame")
                    local TextboxBack = Instance.new("Frame")
                    local TextboxBackC = Instance.new("UICorner")
                    local TextboxLabel = Instance.new("TextLabel")
                    local TextBox = Instance.new("TextBox")
                    local TextBoxC = Instance.new("UICorner")
                    
                    TextboxModule.Name = "TextboxModule"
                    TextboxModule.Parent = Objs
                    TextboxModule.BackgroundTransparency = 1
                    TextboxModule.BorderSizePixel = 0
                    TextboxModule.Size = UDim2.new(1, 0, 0, 60)
                    
                    TextboxBack.Name = "TextboxBack"
                    TextboxBack.Parent = TextboxModule
                    TextboxBack.BackgroundColor3 = config.ButtonBg
                    TextboxBack.BackgroundTransparency = 0.2
                    TextboxBack.BorderSizePixel = 0
                    TextboxBack.Size = UDim2.new(1, 0, 0, 60)
                    
                    TextboxBackC.CornerRadius = UDim.new(0, 6)
                    TextboxBackC.Name = "TextboxBackC"
                    TextboxBackC.Parent = TextboxBack
                    
                    TextboxLabel.Name = "TextboxLabel"
                    TextboxLabel.Parent = TextboxBack
                    TextboxLabel.BackgroundTransparency = 1
                    TextboxLabel.Position = UDim2.new(0.03, 0, 0.1, 0)
                    TextboxLabel.Size = UDim2.new(0.94, 0, 0, 20)
                    TextboxLabel.Font = Enum.Font.GothamSemibold
                    TextboxLabel.Text = text
                    TextboxLabel.TextColor3 = config.PrimaryText
                    TextboxLabel.TextSize = 13
                    TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                    
                    TextBox.Parent = TextboxBack
                    TextBox.BackgroundColor3 = config.InputBg
                    TextBox.BackgroundTransparency = 0.3
                    TextBox.BorderSizePixel = 0
                    TextBox.Position = UDim2.new(0.03, 0, 0.55, 0)
                    TextBox.Size = UDim2.new(0.94, 0, 0, 24)
                    TextBox.Font = Enum.Font.Gotham
                    TextBox.Text = ""
                    TextBox.TextColor3 = config.PrimaryText
                    TextBox.TextSize = 12
                    TextBox.PlaceholderColor3 = config.SecondaryText
                    TextBox.PlaceholderText = placeholder or "输入内容..."
                    
                    TextBoxC.CornerRadius = UDim.new(0, 4)
                    TextBoxC.Parent = TextBox
                    
                    local textboxGlow = Instance.new("UIStroke")
                    textboxGlow.Parent = TextboxBack
                    textboxGlow.Color = config.AccentColor
                    textboxGlow.Thickness = 1.5
                    textboxGlow.Transparency = 0.7
                    
                    TextBox.Focused:Connect(function()
                        services.TweenService:Create(TextBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.2
                        }):Play()
                    end)
                    
                    TextBox.FocusLost:Connect(function(enterPressed)
                        services.TweenService:Create(TextBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.3
                        }):Play()
                        
                        if TextBox.Text == "" then
                            TextBox.Text = placeholder or ""
                        end
                        
                        FengUI.flags[flag] = TextBox.Text
                        callback(TextBox.Text, enterPressed)
                        
                        DigitalParticleExplosion(TextBox, 0.5)
                    end)
                end
                
                -- 标签组件
                function section.Label(section, text, color)
                    local LabelModule = Instance.new("Frame")
                    local TextLabel = Instance.new("TextLabel")
                    local LabelC = Instance.new("UICorner")
                    
                    LabelModule.Name = "LabelModule"
                    LabelModule.Parent = Objs
                    LabelModule.BackgroundTransparency = 1
                    LabelModule.BorderSizePixel = 0
                    LabelModule.Size = UDim2.new(1, 0, 0, 40)
                    
                    TextLabel.Parent = LabelModule
                    TextLabel.BackgroundColor3 = config.ButtonBg
                    TextLabel.BackgroundTransparency = 0.2
                    TextLabel.Size = UDim2.new(1, 0, 0, 40)
                    TextLabel.Font = Enum.Font.GothamSemibold
                    TextLabel.Text = text
                    TextLabel.TextColor3 = color or config.SecondaryText
                    TextLabel.TextSize = 13
                    TextLabel.TextWrapped = true
                    
                    LabelC.CornerRadius = UDim.new(0, 6)
                    LabelC.Name = "LabelC"
                    LabelC.Parent = TextLabel
                    
                    return TextLabel
                end
                
                -- 下拉框组件（简化版）
                function section.Dropdown(section, text, flag, options, callback)
                    local callback = callback or function() end
                    local options = options or {}
                    assert(text, "No text provided")
                    assert(flag, "No flag provided")
                    
                    FengUI.flags[flag] = nil

                    local DropdownModule = Instance.new("Frame")
                    local DropdownBack = Instance.new("Frame")
                    local DropdownBackC = Instance.new("UICorner")
                    local DropdownText = Instance.new("TextLabel")
                    local DropdownButton = Instance.new("TextButton")
                    local DropdownButtonC = Instance.new("UICorner")
                    local DropdownList = Instance.new("ScrollingFrame")
                    local DropdownListL = Instance.new("UIListLayout")
                    
                    DropdownModule.Name = "DropdownModule"
                    DropdownModule.Parent = Objs
                    DropdownModule.BackgroundTransparency = 1
                    DropdownModule.BorderSizePixel = 0
                    DropdownModule.ClipsDescendants = true
                    DropdownModule.Size = UDim2.new(1, 0, 0, 40)
                    
                    DropdownBack.Name = "DropdownBack"
                    DropdownBack.Parent = DropdownModule
                    DropdownBack.BackgroundColor3 = config.ButtonBg
                    DropdownBack.BackgroundTransparency = 0.2
                    DropdownBack.BorderSizePixel = 0
                    DropdownBack.Size = UDim2.new(1, 0, 0, 40)
                    
                    DropdownBackC.CornerRadius = UDim.new(0, 6)
                    DropdownBackC.Name = "DropdownBackC"
                    DropdownBackC.Parent = DropdownBack
                    
                    DropdownText.Name = "DropdownText"
                    DropdownText.Parent = DropdownBack
                    DropdownText.BackgroundTransparency = 1
                    DropdownText.Position = UDim2.new(0.03, 0, 0, 0)
                    DropdownText.Size = UDim2.new(0.7, 0, 1, 0)
                    DropdownText.Font = Enum.Font.GothamSemibold
                    DropdownText.Text = text
                    DropdownText.TextColor3 = config.PrimaryText
                    DropdownText.TextSize = 13
                    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                    
                    DropdownButton.Name = "DropdownButton"
                    DropdownButton.Parent = DropdownBack
                    DropdownButton.BackgroundColor3 = config.InputBg
                    DropdownButton.BackgroundTransparency = 0.3
                    DropdownButton.BorderSizePixel = 0
                    DropdownButton.Position = UDim2.new(0.75, 0, 0.5, -12)
                    DropdownButton.Size = UDim2.new(0.2, 0, 0, 24)
                    DropdownButton.Font = Enum.Font.Gotham
                    DropdownButton.Text = "选择"
                    DropdownButton.TextColor3 = config.PrimaryText
                    DropdownButton.TextSize = 12
                    DropdownButton.AutoButtonColor = false
                    
                    DropdownButtonC.CornerRadius = UDim.new(0, 4)
                    DropdownButtonC.Name = "DropdownButtonC"
                    DropdownButtonC.Parent = DropdownButton
                    
                    DropdownList.Name = "DropdownList"
                    DropdownList.Parent = DropdownModule
                    DropdownList.BackgroundColor3 = config.InputBg
                    DropdownList.BackgroundTransparency = 0.1
                    DropdownList.BorderSizePixel = 0
                    DropdownList.Position = UDim2.new(0, 0, 1, 5)
                    DropdownList.Size = UDim2.new(1, 0, 0, 0)
                    DropdownList.ScrollBarThickness = 4
                    DropdownList.Visible = false
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
                    
                    local ListCorner = Instance.new("UICorner")
                    ListCorner.CornerRadius = UDim.new(0, 6)
                    ListCorner.Parent = DropdownList
                    
                    DropdownListL.Name = "DropdownListL"
                    DropdownListL.Parent = DropdownList
                    DropdownListL.SortOrder = Enum.SortOrder.LayoutOrder
                    DropdownListL.Padding = UDim.new(0, 2)
                    
                    local dropdownGlow = Instance.new("UIStroke")
                    dropdownGlow.Parent = DropdownBack
                    dropdownGlow.Color = config.AccentColor
                    dropdownGlow.Thickness = 1.5
                    dropdownGlow.Transparency = 0.7
                    
                    local open = false
                    
                    local function toggleDropdown()
                        open = not open
                        DropdownList.Visible = open
                        
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, 0, 0, open and math.min(#options * 28, 140) or 0)
                        }):Play()
                        
                        DropdownButton.Text = open and "收起" or "选择"
                        
                        if open then
                            DigitalParticleExplosion(DropdownButton, 0.5)
                        end
                    end
                    
                    DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                    
                    local funcs = {}
                    funcs.AddOption = function(self, option)
                        local Option = Instance.new("TextButton")
                        Option.Name = "Option_" .. option
                        Option.Parent = DropdownList
                        Option.BackgroundColor3 = config.ButtonBg
                        Option.BackgroundTransparency = 0.3
                        Option.BorderSizePixel = 0
                        Option.Size = UDim2.new(1, -10, 0, 26)
                        Option.Position = UDim2.new(0, 5, 0, 0)
                        Option.AutoButtonColor = false
                        Option.Font = Enum.Font.Gotham
                        Option.Text = option
                        Option.TextColor3 = config.PrimaryText
                        Option.TextSize = 12
                        
                        local OptionCorner = Instance.new("UICorner")
                        OptionCorner.CornerRadius = UDim.new(0, 4)
                        OptionCorner.Parent = Option
                        
                        Option.MouseEnter:Connect(function()
                            services.TweenService:Create(Option, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0.2
                            }):Play()
                        end)
                        
                        Option.MouseLeave:Connect(function()
                            services.TweenService:Create(Option, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0.3
                            }):Play()
                        end)
                        
                        Option.MouseButton1Click:Connect(function()
                            DigitalParticleExplosion(Option, 0.4)
                            DropdownButton.Text = option
                            FengUI.flags[flag] = option
                            callback(option)
                            toggleDropdown()
                        end)
                    end
                    
                    funcs.SetOptions = function(self, options)
                        for _, v in next, DropdownList:GetChildren() do
                            if v:IsA("TextButton") then
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
                
                -- 按键绑定组件
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
                        RightControl = "RCtrl", LeftControl = "LCtrl",
                        LeftShift = "LShift", RightShift = "RShift",
                        Semicolon = ";", Quote = '"', LeftBracket = "[",
                        RightBracket = "]", Equals = "=", Minus = "-",
                        RightAlt = "RAlt", LeftAlt = "LAlt"
                    }
                    
                    local bindKey = default
                    local keyTxt = default and (shortNames[default.Name] or default.Name) or "None"
                    
                    local KeybindModule = Instance.new("Frame")
                    local KeybindBack = Instance.new("Frame")
                    local KeybindBackC = Instance.new("UICorner")
                    local KeybindText = Instance.new("TextLabel")
                    local KeybindButton = Instance.new("TextButton")
                    local KeybindButtonC = Instance.new("UICorner")
                    
                    KeybindModule.Name = "KeybindModule"
                    KeybindModule.Parent = Objs
                    KeybindModule.BackgroundTransparency = 1
                    KeybindModule.BorderSizePixel = 0
                    KeybindModule.Size = UDim2.new(1, 0, 0, 40)
                    
                    KeybindBack.Name = "KeybindBack"
                    KeybindBack.Parent = KeybindModule
                    KeybindBack.BackgroundColor3 = config.ButtonBg
                    KeybindBack.BackgroundTransparency = 0.2
                    KeybindBack.BorderSizePixel = 0
                    KeybindBack.Size = UDim2.new(1, 0, 0, 40)
                    
                    KeybindBackC.CornerRadius = UDim.new(0, 6)
                    KeybindBackC.Name = "KeybindBackC"
                    KeybindBackC.Parent = KeybindBack
                    
                    KeybindText.Name = "KeybindText"
                    KeybindText.Parent = KeybindBack
                    KeybindText.BackgroundTransparency = 1
                    KeybindText.Position = UDim2.new(0.03, 0, 0, 0)
                    KeybindText.Size = UDim2.new(0.6, 0, 1, 0)
                    KeybindText.Font = Enum.Font.GothamSemibold
                    KeybindText.Text = text
                    KeybindText.TextColor3 = config.PrimaryText
                    KeybindText.TextSize = 13
                    KeybindText.TextXAlignment = Enum.TextXAlignment.Left
                    
                    KeybindButton.Name = "KeybindButton"
                    KeybindButton.Parent = KeybindBack
                    KeybindButton.BackgroundColor3 = config.InputBg
                    KeybindButton.BackgroundTransparency = 0.3
                    KeybindButton.BorderSizePixel = 0
                    KeybindButton.Position = UDim2.new(0.7, 0, 0.5, -12)
                    KeybindButton.Size = UDim2.new(0.25, 0, 0, 24)
                    KeybindButton.Font = Enum.Font.Gotham
                    KeybindButton.Text = keyTxt
                    KeybindButton.TextColor3 = config.PrimaryText
                    KeybindButton.TextSize = 12
                    KeybindButton.AutoButtonColor = false
                    
                    KeybindButtonC.CornerRadius = UDim.new(0, 4)
                    KeybindButtonC.Name = "KeybindButtonC"
                    KeybindButtonC.Parent = KeybindButton
                    
                    local keybindGlow = Instance.new("UIStroke")
                    keybindGlow.Parent = KeybindBack
                    keybindGlow.Color = config.AccentColor
                    keybindGlow.Thickness = 1.5
                    keybindGlow.Transparency = 0.7
                    
                    KeybindButton.MouseEnter:Connect(function()
                        services.TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.2
                        }):Play()
                    end)
                    
                    KeybindButton.MouseLeave:Connect(function()
                        services.TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.3
                        }):Play()
                    end)
                    
                    UserInputService.InputBegan:Connect(function(inp, gpe)
                        if gpe then return end
                        if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if inp.KeyCode ~= bindKey then return end
                        callback(bindKey.Name)
                    end)
                    
                    KeybindButton.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(KeybindButton, 0.5)
                        KeybindButton.Text = "..."
                        KeybindButton.BackgroundColor3 = config.AccentColor
                        KeybindButton.BackgroundTransparency = 0.4
                        
                        local connection
                        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if gameProcessed then return end
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                local keyName = input.KeyCode.Name
                                
                                if not banned[keyName] then
                                    bindKey = input.KeyCode
                                    KeybindButton.Text = shortNames[keyName] or keyName
                                    callback(keyName)
                                end
                            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                                bindKey = Enum.KeyCode.LeftControl
                                KeybindButton.Text = "LCtrl"
                                callback("LeftControl")
                            end
                            
                            connection:Disconnect()
                            
                            services.TweenService:Create(KeybindButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = config.InputBg,
                                BackgroundTransparency = 0.3
                            }):Play()
                        end)
                    end)
                end
                
                -- 图片组件（支持玩家头像和游戏图标）
                function section.Image(section, imageSource, width, height)
                    width = width or 320
                    height = height or 120
                    
                    local ImageModule = Instance.new("Frame")
                    local ImageLabel = Instance.new("ImageLabel")
                    local ImageCorner = Instance.new("UICorner")
                    
                    ImageModule.Name = "ImageModule"
                    ImageModule.Parent = Objs
                    ImageModule.BackgroundTransparency = 1
                    ImageModule.BorderSizePixel = 0
                    ImageModule.Size = UDim2.new(1, 0, 0, height + 10)
                    
                    ImageLabel.Parent = ImageModule
                    ImageLabel.BackgroundColor3 = config.InputBg
                    ImageLabel.BackgroundTransparency = 0.3
                    ImageLabel.BorderSizePixel = 0
                    ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                    ImageLabel.Position = UDim2.new(0.5, 0, 0, 5)
                    ImageLabel.Size = UDim2.new(0, width, 0, height)
                    ImageLabel.ScaleType = Enum.ScaleType.Crop
                    
                    ImageCorner.CornerRadius = UDim.new(0, 8)
                    ImageCorner.Parent = ImageLabel
                    
                    local imageGlow = Instance.new("UIStroke")
                    imageGlow.Parent = ImageLabel
                    imageGlow.Color = config.AccentColor
                    imageGlow.Thickness = 1.5
                    imageGlow.Transparency = 0.7
                    
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
                                        local success, gameInfo = pcall(function()
                                            local MarketplaceService = game:GetService("MarketplaceService")
                                            return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Game)
                                        end)
                                        
                                        if success and gameInfo and gameInfo.IconImageAssetId then
                                            ImageLabel.Image = "rbxassetid://" .. gameInfo.IconImageAssetId
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
                
                -- 音乐播放器组件
                function section.MusicPlayer(section, title, defaultPlaylist)
                    -- 保持原有的音乐播放器代码，但适配新的UI风格
                    -- 由于代码较长，这里保持原样，只修改样式以匹配新UI
                    local MusicPlayerModule = Instance.new("Frame")
                    MusicPlayerModule.Name = "MusicPlayerModule"
                    MusicPlayerModule.Parent = Objs
                    MusicPlayerModule.BackgroundTransparency = 1
                    MusicPlayerModule.BorderSizePixel = 0
                    MusicPlayerModule.Size = UDim2.new(1, 0, 0, 160)
                    
                    local PlayerContainer = Instance.new("Frame")
                    PlayerContainer.Name = "PlayerContainer"
                    PlayerContainer.Parent = MusicPlayerModule
                    PlayerContainer.BackgroundColor3 = config.CardBg
                    PlayerContainer.BackgroundTransparency = 0.15
                    PlayerContainer.Size = UDim2.new(1, 0, 0, 160)
                    
                    local PlayerCorner = Instance.new("UICorner")
                    PlayerCorner.CornerRadius = UDim.new(0, 10)
                    PlayerCorner.Parent = PlayerContainer
                    
                    local playerGlow = Instance.new("UIStroke")
                    playerGlow.Parent = PlayerContainer
                    playerGlow.Color = config.AccentColor
                    playerGlow.Thickness = 2
                    playerGlow.Transparency = 0.6
                    
                    startNeonFlowEffect(playerGlow, "Color", 0.01)
                    createPulseGlow(playerGlow)
                    
                    -- ... 其余音乐播放器代码保持不变 ...
                    -- 注：这里省略了音乐播放器的完整代码以保持简洁
                    -- 实际使用时请将原始的音乐播放器代码复制到这里
                    
                    local musicPlayerFuncs = {}
                    
                    -- 音乐播放器功能函数
                    function musicPlayerFuncs:AddTrack(trackId, title, artist, imageId)
                        MusicPlayer:AddToPlaylist(trackId, title, artist, imageId)
                    end
                    
                    function musicPlayerFuncs:PlayTrack(trackId)
                        for i, track in ipairs(MusicPlayer.playlist) do
                            if track.id == trackId then
                                MusicPlayer.currentTrackIndex = i
                                MusicPlayer:PlayTrack(trackId)
                                return
                            end
                        end
                    end
                    
                    function musicPlayerFuncs:SetVolume(volume)
                        MusicPlayer:SetVolume(volume)
                    end
                    
                    function musicPlayerFuncs:ClearPlaylist()
                        MusicPlayer:ClearPlaylist()
                    end
                    
                    function musicPlayerFuncs:GetCurrentTrack()
                        return MusicPlayer:GetCurrentTrack()
                    end
                    
                    function musicPlayerFuncs:GetPlaylist()
                        return MusicPlayer.playlist
                    end
                    
                    return musicPlayerFuncs
                end
                
                return section
            end
            
            return tabObj
        end
        
        return cardObj
    end

    return window
end

-- UI控制函数
function UiDestroy()
    if FengYu then
        FengYu:Destroy()
    end
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    Open.Visible = not ToggleUI
    Main.Visible = ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

-- 添加新功能：创建左右分区的section
function FengUI:section(name, side, opened)
    -- 这个函数可以在外部调用，创建分区的section
    -- side: "left" 或 "right"
    -- opened: 是否默认打开
    return {
        name = name,
        side = side or "right",
        opened = opened == nil and true or opened
    }
end

return FengUI