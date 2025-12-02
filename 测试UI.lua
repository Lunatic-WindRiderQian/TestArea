repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

-- 新增：性能优化设置
local PerformanceMode = false
local function optimizePerformance()
    if PerformanceMode then
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        settings().Rendering.QualityLevel = 1
    end
end

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
    SoundService = game:GetService("SoundService"),
    Lighting = game:GetService("Lighting")
}

local UserInputService = services.UserInputService
local RunService = services.RunService
local Lighting = services.Lighting

-- 升级后的颜色配置
local config = {
    -- 主色调
    PrimaryColor = Color3.fromRGB(12, 12, 20),
    SecondaryColor = Color3.fromRGB(18, 18, 30),
    AccentColor = Color3.fromRGB(0, 180, 255),
    AccentColor2 = Color3.fromRGB(150, 0, 255),
    
    -- UI元素颜色
    WindowBg = Color3.fromRGB(15, 15, 25),
    CardBg = Color3.fromRGB(22, 22, 38),
    TabBg = Color3.fromRGB(25, 25, 45),
    ButtonBg = Color3.fromRGB(35, 35, 60),
    InputBg = Color3.fromRGB(28, 28, 48),
    
    -- 文本颜色
    PrimaryText = Color3.fromRGB(240, 245, 255),
    SecondaryText = Color3.fromRGB(180, 190, 210),
    AccentText = Color3.fromRGB(0, 200, 255),
    
    -- 特殊效果颜色
    GlowColor = Color3.fromRGB(0, 150, 255),
    NeonColor = Color3.fromRGB(0, 255, 255),
    HologramColor = Color3.fromRGB(100, 255, 255),
    
    -- 状态颜色
    SuccessColor = Color3.fromRGB(0, 255, 100),
    WarningColor = Color3.fromRGB(255, 200, 0),
    ErrorColor = Color3.fromRGB(255, 50, 50),
    
    -- 透明度设置
    WindowTransparency = 0.05,
    CardTransparency = 0.1,
    BlurIntensity = 0.8
}

-- 新增：高级音乐播放器
local AdvancedMusicPlayer = {
    currentSound = nil,
    currentTrackIndex = 1,
    isPlaying = false,
    isLooping = false,
    playlist = {},
    volume = 0.5,
    spectrumData = {},
    visualizerActive = false
}

function AdvancedMusicPlayer:PlayTrack(trackId)
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
    
    -- 启动音频可视化
    self:StartVisualizer()
end

function AdvancedMusicPlayer:StartVisualizer()
    if self.visualizerActive then return end
    
    self.visualizerActive = true
    task.spawn(function()
        while self.visualizerActive and self.currentSound do
            self:UpdateSpectrum()
            task.wait(0.05)
        end
    end)
end

function AdvancedMusicPlayer:UpdateSpectrum()
    -- 模拟频谱数据
    for i = 1, 32 do
        self.spectrumData[i] = math.random() * (math.sin(tick() * 5 + i * 0.3) * 0.5 + 0.5)
    end
end

-- 新增：高级粒子效果
local function createCyberParticleExplosion(position, parent)
    local explosion = Instance.new("Frame")
    explosion.Name = "CyberExplosion"
    explosion.BackgroundTransparency = 1
    explosion.Size = UDim2.new(0, 0, 0, 0)
    explosion.Position = position
    explosion.Parent = parent
    explosion.ZIndex = 999
    
    local particles = {}
    local particleCount = 24
    
    for i = 1, particleCount do
        local angle = math.random() * math.pi * 2
        local speed = math.random(50, 150)
        local size = math.random(8, 20)
        local life = math.random(0.5, 1.5)
        
        local particle = Instance.new("Frame")
        particle.Name = "Particle_" .. i
        particle.BackgroundColor3 = Color3.fromHSV(i/particleCount, 0.8, 1)
        particle.BackgroundTransparency = 0.3
        particle.Size = UDim2.new(0, size, 0, 2)
        particle.Position = position
        particle.Parent = explosion
        particle.ZIndex = 1000
        
        local glow = Instance.new("UIGradient")
        glow.Rotation = 90
        glow.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(i/particleCount, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.white),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(i/particleCount, 1, 1))
        })
        glow.Parent = particle
        
        particles[i] = {
            instance = particle,
            angle = angle,
            speed = speed,
            size = size,
            life = life,
            startTime = tick()
        }
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local alive = false
        
        for _, p in ipairs(particles) do
            if p.instance and p.instance.Parent then
                local elapsed = currentTime - p.startTime
                local progress = elapsed / p.life
                
                if progress < 1 then
                    alive = true
                    local distance = p.speed * progress
                    local x = math.cos(p.angle) * distance
                    local y = math.sin(p.angle) * distance
                    
                    p.instance.Position = UDim2.new(
                        position.X.Scale, position.X.Offset + x,
                        position.Y.Scale, position.Y.Offset + y
                    )
                    
                    p.instance.BackgroundTransparency = 0.3 + progress * 0.7
                    p.instance.Rotation = progress * 360
                else
                    p.instance:Destroy()
                end
            end
        end
        
        if not alive then
            connection:Disconnect()
            explosion:Destroy()
        end
    end)
end

-- 新增：霓虹流动效果
local function createNeonFlowEffect(object, property, speed)
    speed = speed or 0.005
    local hue = 0
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        hue = (hue + speed) % 1
        local r = math.sin(hue * 6.28 + 0) * 0.5 + 0.5
        local g = math.sin(hue * 6.28 + 2.09) * 0.5 + 0.5
        local b = math.sin(hue * 6.28 + 4.18) * 0.5 + 0.5
        
        object[property] = Color3.new(r, g, b)
    end)
    
    return connection
end

-- 新增：高级全息效果
local function createAdvancedHologramEffect(frame, intensity)
    intensity = intensity or 1
    
    local hologram = Instance.new("Frame")
    hologram.Name = "AdvancedHologram"
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
    linePattern.Rotation = 0
    linePattern.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.05, 0.4),
        NumberSequenceKeypoint.new(0.1, 0.8),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    linePattern.Parent = scanLines
    
    -- 脉动光晕
    local pulseGlow = Instance.new("Frame")
    pulseGlow.Name = "PulseGlow"
    pulseGlow.BackgroundTransparency = 1
    pulseGlow.Size = UDim2.new(1, 0, 1, 0)
    pulseGlow.Parent = hologram
    
    local glowGradient = Instance.new("UIGradient")
    glowGradient.Rotation = 45
    glowGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.2, 0.4 * intensity),
        NumberSequenceKeypoint.new(0.8, 0.4 * intensity),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    
    local colors = {
        ColorSequenceKeypoint.new(0, config.HologramColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 255))
    }
    glowGradient.Color = ColorSequence.new(colors)
    glowGradient.Parent = pulseGlow
    
    -- 网格效果
    local grid = Instance.new("Frame")
    grid.Name = "Grid"
    grid.BackgroundTransparency = 1
    grid.Size = UDim2.new(1, 0, 1, 0)
    grid.Parent = hologram
    
    -- 动画连接
    local scanConnection = RunService.Heartbeat:Connect(function()
        if not scanLines.Parent then
            scanConnection:Disconnect()
            return
        end
        linePattern.Offset = Vector2.new(0, (tick() * 0.3) % 1)
    end)
    
    local colorConnection = RunService.Heartbeat:Connect(function()
        if not hologram.Parent then
            colorConnection:Disconnect()
            return
        end
        
        local time = tick() * 0.5
        for i, keypoint in ipairs(colors) do
            local hue = (time + i * 0.2) % 1
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV(hue, 0.8, 1)
            )
        end
        glowGradient.Color = ColorSequence.new(colors)
    end)
    
    return hologram
end

-- 新增：高级切换动画
local function advancedSwitchTab(oldTab, newTab)
    if FengUI.currentTab == newTab then return end
    
    local switchingTabs = false
    if switchingTabs then return end
    switchingTabs = true
    
    local oldData = FengUI.currentTab
    FengUI.currentTab = newTab
    
    if oldData then
        -- 旧标签退出动画
        services.TweenService:Create(oldData.tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.8,
            Size = UDim2.new(0, 35, 0, 35)
        }):Play()
        
        services.TweenService:Create(oldData.tabButton.TabText, TweenInfo.new(0.3), {
            TextTransparency = 0.5,
            TextColor3 = config.SecondaryText
        }):Play()
        
        oldData.content.Visible = false
    end
    
    -- 新标签进入动画
    services.TweenService:Create(newTab.tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 45, 0, 45)
    }):Play()
    
    services.TweenService:Create(newTab.tabButton.TabText, TweenInfo.new(0.3), {
        TextTransparency = 0,
        TextColor3 = config.AccentText
    }):Play()
    
    -- 粒子轨迹效果
    if oldData and newTab.tabButton.AbsolutePosition and oldData.tabButton.AbsolutePosition then
        createCyberParticleExplosion(
            UDim2.new(0, oldData.tabButton.AbsolutePosition.X, 0, oldData.tabButton.AbsolutePosition.Y),
            newTab.tabButton.Parent
        )
    end
    
    newTab.content.Visible = true
    
    task.wait(0.3)
    switchingTabs = false
end

-- 清理现有UI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建高级主UI
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui
FengYu.ResetOnSpawn = false

-- 主窗口
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.WindowBg
Main.BackgroundTransparency = config.WindowTransparency
Main.Position = UDim2.new(0.5, 0, 0.4, 0)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

-- 主窗口圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

-- 主窗口描边
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = config.AccentColor
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

-- 霓虹流光描边
local neonGlow = Instance.new("UIStroke")
neonGlow.Parent = Main
neonGlow.Color = config.NeonColor
neonGlow.Thickness = 3
neonGlow.Transparency = 0.5
createNeonFlowEffect(neonGlow, "Color", 0.008)

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabBg
TitleBar.BackgroundTransparency = 0.1
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 2

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

-- 标题文本
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "FengUI Premium"
TitleText.TextColor3 = config.AccentText
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- 标题流光效果
local titleGradient = Instance.new("UIGradient")
titleGradient.Rotation = 90
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, config.AccentColor),
    ColorSequenceKeypoint.new(0.5, config.AccentColor2),
    ColorSequenceKeypoint.new(1, config.AccentColor)
})
titleGradient.Parent = TitleText

-- 关闭按钮
local CloseButton = Instance.new("ImageButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Image = "rbxassetid://3926305904"
CloseButton.ImageRectOffset = Vector2.new(924, 724)
CloseButton.ImageRectSize = Vector2.new(36, 36)
CloseButton.ZIndex = 10

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- 关闭按钮动画
CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.2,
        Size = UDim2.new(0, 20, 0, 20)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    createCyberParticleExplosion(
        UDim2.new(0, CloseButton.AbsolutePosition.X, 0, CloseButton.AbsolutePosition.Y),
        TitleBar
    )
    
    services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    task.wait(0.4)
    FengYu:Destroy()
end)

-- 打开按钮
local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.8
Open.Position = UDim2.new(0.95, 0, 0.02, 0)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://7072718366"
Open.ImageColor3 = Color3.white

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = config.AccentColor
OpenStroke.Thickness = 2
createNeonFlowEffect(OpenStroke, "Color", 0.01)

-- 脉冲动画
task.spawn(function()
    while Open and Open.Parent do
        services.TweenService:Create(Open, TweenInfo.new(1, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.7
        }):Play()
        task.wait(1)
        services.TweenService:Create(Open, TweenInfo.new(1, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.9
        }):Play()
        task.wait(1)
    end
end)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playAdvancedEntranceAnimation()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        if Main.Visible then
            playAdvancedEntranceAnimation()
        end
    end
end)

-- 卡片容器
local CardsContainer = Instance.new("ScrollingFrame")
CardsContainer.Name = "CardsContainer"
CardsContainer.Parent = Main
CardsContainer.BackgroundTransparency = 1
CardsContainer.Position = UDim2.new(0, 0, 0, 45)
CardsContainer.Size = UDim2.new(1, 0, 1, -45)
CardsContainer.ScrollBarThickness = 3
CardsContainer.ScrollBarImageColor3 = config.AccentColor
CardsContainer.ScrollBarImageTransparency = 0.5

local CardsLayout = Instance.new("UIGridLayout")
CardsLayout.Parent = CardsContainer
CardsLayout.CellSize = UDim2.new(0, 110, 0, 110)
CardsLayout.CellPadding = UDim2.new(0, 10, 0, 10)
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.StartCorner = Enum.StartCorner.TopLeft

-- 主标签容器
local MainTabContainer = Instance.new("Frame")
MainTabContainer.Name = "MainTabContainer"
MainTabContainer.Parent = Main
MainTabContainer.BackgroundTransparency = 1
MainTabContainer.Position = UDim2.new(0, 100, 0, 45)
MainTabContainer.Size = UDim2.new(0, 395, 0, 270)
MainTabContainer.Visible = false

-- 侧边栏容器
local MainSideContainer = Instance.new("Frame")
MainSideContainer.Name = "MainSideContainer"
MainSideContainer.Parent = Main
MainSideContainer.BackgroundColor3 = config.TabBg
MainSideContainer.BackgroundTransparency = 0.1
MainSideContainer.Position = UDim2.new(0, 0, 0, 45)
MainSideContainer.Size = UDim2.new(0, 95, 1, -45)
MainSideContainer.Visible = false

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 16)
SideCorner.Parent = MainSideContainer

-- 侧边栏全息效果
createAdvancedHologramEffect(MainSideContainer, 0.4)

-- 返回卡片按钮
local ReturnToCardsButton = Instance.new("TextButton")
ReturnToCardsButton.Name = "ReturnToCardsButton"
ReturnToCardsButton.Parent = MainSideContainer
ReturnToCardsButton.BackgroundColor3 = config.ButtonBg
ReturnToCardsButton.BackgroundTransparency = 0.2
ReturnToCardsButton.Size = UDim2.new(1, 0, 0, 35)
ReturnToCardsButton.AutoButtonColor = false
ReturnToCardsButton.Font = Enum.Font.GothamBold
ReturnToCardsButton.Text = "← 返回"
ReturnToCardsButton.TextColor3 = config.PrimaryText
ReturnToCardsButton.TextSize = 12

local ReturnCorner = Instance.new("UICorner")
ReturnCorner.CornerRadius = UDim.new(0, 8)
ReturnCorner.Parent = ReturnToCardsButton

local returnGlow = Instance.new("UIStroke")
returnGlow.Parent = ReturnToCardsButton
returnGlow.Color = config.AccentColor
returnGlow.Thickness = 1
createNeonFlowEffect(returnGlow, "Color", 0.01)

-- 高级入场动画
local function playAdvancedEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 0, 0, 0)
    
    MainStroke.Transparency = 1
    neonGlow.Transparency = 1
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.BackgroundTransparency = 1
    CloseButton.ImageTransparency = 1
    
    services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = config.WindowTransparency,
        Size = UDim2.new(0, 500, 0, 320)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.6), {
        Transparency = 0.3
    }):Play()
    
    services.TweenService:Create(neonGlow, TweenInfo.new(0.6), {
        Transparency = 0.5
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4), {
        BackgroundTransparency = 0.1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4), {
        BackgroundTransparency = 0.2,
        ImageTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    if FengUI.showingCards then
        CardsContainer.Visible = true
        services.TweenService:Create(CardsContainer, TweenInfo.new(0.4), {
            BackgroundTransparency = 1
        }):Play()
    else
        MainSideContainer.Visible = true
        MainTabContainer.Visible = true
        services.TweenService:Create(MainSideContainer, TweenInfo.new(0.4), {
            BackgroundTransparency = 0.1
        }):Play()
    end
    
    createCyberParticleExplosion(
        UDim2.new(0.5, 0, 0.5, 0),
        Main
    )
end

-- 延迟播放入场动画
task.spawn(function()
    task.wait(1)
    playAdvancedEntranceAnimation()
end)

-- 标题动画
task.spawn(function()
    local hue = 0
    while TitleText and TitleText.Parent do
        hue = (hue + 0.02) % 1
        TitleText.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        
        titleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.3) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1))
        })
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.5), {
            TextSize = 18 + math.sin(tick() * 2) * 2
        }):Play()
        
        task.wait(0.1)
    end
end)

-- 主UI构造函数
function FengUI.new(uiName, theme)
    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end
    
    TitleText.Text = uiName or "FengUI Premium"
    
    local window = {}
    
    function window.card(window, name, description, icon)
        local Card = Instance.new("TextButton")
        Card.Name = "Card_" .. name
        Card.Parent = CardsContainer
        Card.BackgroundColor3 = config.CardBg
        Card.BackgroundTransparency = 0.2
        Card.AutoButtonColor = false
        Card.Text = ""
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 14)
        CardCorner.Parent = Card
        
        local CardGlow = Instance.new("UIStroke")
        CardGlow.Parent = Card
        CardGlow.Color = config.AccentColor
        CardGlow.Thickness = 2
        CardGlow.Transparency = 0.6
        createNeonFlowEffect(CardGlow, "Color", 0.008)
        
        -- 卡片图标
        local CardIcon = Instance.new("ImageLabel")
        CardIcon.Name = "CardIcon"
        CardIcon.Parent = Card
        CardIcon.BackgroundTransparency = 1
        CardIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        CardIcon.Position = UDim2.new(0.5, 0, 0.35, 0)
        CardIcon.Size = UDim2.new(0, 50, 0, 50)
        CardIcon.Image = "rbxassetid://" .. tostring(icon or "7072718366")
        CardIcon.ImageColor3 = Color3.white
        
        -- 卡片标题
        local CardTitle = Instance.new("TextLabel")
        CardTitle.Name = "CardTitle"
        CardTitle.Parent = Card
        CardTitle.BackgroundTransparency = 1
        CardTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        CardTitle.Position = UDim2.new(0.5, 0, 0.65, 0)
        CardTitle.Size = UDim2.new(0.9, 0, 0, 20)
        CardTitle.Font = Enum.Font.GothamBold
        CardTitle.Text = name
        CardTitle.TextColor3 = config.PrimaryText
        CardTitle.TextSize = 13
        
        -- 卡片描述
        local CardDescription = Instance.new("TextLabel")
        CardDescription.Name = "CardDescription"
        CardDescription.Parent = Card
        CardDescription.BackgroundTransparency = 1
        CardDescription.AnchorPoint = Vector2.new(0.5, 0.5)
        CardDescription.Position = UDim2.new(0.5, 0, 0.85, 0)
        CardDescription.Size = UDim2.new(0.9, 0, 0, 15)
        CardDescription.Font = Enum.Font.Gotham
        CardDescription.Text = description or ""
        CardDescription.TextColor3 = config.SecondaryText
        CardDescription.TextSize = 11
        CardDescription.TextWrapped = true
        
        -- 卡片阴影
        local CardShadow = Instance.new("ImageLabel")
        CardShadow.Name = "CardShadow"
        CardShadow.Parent = Card
        CardShadow.BackgroundTransparency = 1
        CardShadow.Size = UDim2.new(1, 15, 1, 15)
        CardShadow.Position = UDim2.new(0, -7, 0, -7)
        CardShadow.Image = "rbxassetid://5554236805"
        CardShadow.ImageColor3 = Color3.new(0, 0, 0)
        CardShadow.ImageTransparency = 0.8
        CardShadow.ScaleType = Enum.ScaleType.Slice
        CardShadow.SliceCenter = Rect.new(23, 23, 277, 277)
        CardShadow.ZIndex = -1
        
        -- 卡片悬停动画
        Card.MouseEnter:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 115, 0, 115)
            }):Play()
            
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 3,
                Transparency = 0.3
            }):Play()
            
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 55, 0, 55),
                Rotation = 10
            }):Play()
        end)
        
        Card.MouseLeave:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 110, 0, 110)
            }):Play()
            
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 2,
                Transparency = 0.6
            }):Play()
            
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 50, 0, 50),
                Rotation = 0
            }):Play()
        end)
        
        -- 卡片点击效果
        Card.MouseButton1Click:Connect(function()
            createCyberParticleExplosion(
                UDim2.new(0.5, 0, 0.5, 0),
                Card
            )
            
            services.TweenService:Create(Card, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 105, 0, 105)
            }):Play()
            
            task.wait(0.1)
            
            services.TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Elastic), {
                Size = UDim2.new(0, 115, 0, 115)
            }):Play()
            
            -- 显示标签页
            CardsContainer.Visible = false
            MainTabContainer.Visible = true
            MainSideContainer.Visible = true
            FengUI.showingCards = false
        end)
        
        -- 创建标签容器
        local tabContainer = Instance.new("ScrollingFrame")
        tabContainer.Name = "TabContainer_" .. name
        tabContainer.Parent = MainTabContainer
        tabContainer.BackgroundTransparency = 1
        tabContainer.Size = UDim2.new(1, 0, 1, 0)
        tabContainer.ScrollBarThickness = 3
        tabContainer.ScrollBarImageColor3 = config.AccentColor
        tabContainer.ScrollBarImageTransparency = 0.5
        tabContainer.Visible = false
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Parent = tabContainer
        tabLayout.Padding = UDim.new(0, 8)
        tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        -- 创建标签按钮
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton_" .. name
        tabButton.Parent = MainSideContainer
        tabButton.BackgroundColor3 = config.ButtonBg
        tabButton.BackgroundTransparency = 0.2
        tabButton.Size = UDim2.new(0, 85, 0, 40)
        tabButton.Position = UDim2.new(0, 5, 0, 40)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = name
        tabButton.TextColor3 = config.PrimaryText
        tabButton.TextSize = 12
        tabButton.Visible = false
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 8)
        tabButtonCorner.Parent = tabButton
        
        local tabButtonGlow = Instance.new("UIStroke")
        tabButtonGlow.Parent = tabButton
        tabButtonGlow.Color = config.AccentColor
        tabButtonGlow.Thickness = 1
        tabButtonGlow.Transparency = 0.7
        
        -- 存储标签数据
        FengUI.tabContainers[name] = {
            content = tabContainer,
            tabButton = tabButton
        }
        
        local cardObj = {}
        
        function cardObj.Tab(cardObj, tabName, tabIcon)
            -- 创建标签内容
            local TabContent = Instance.new("Frame")
            TabContent.Name = "Tab_" .. tabName
            TabContent.Parent = tabContainer
            TabContent.BackgroundTransparency = 1
            TabContent.Size = UDim2.new(1, 0, 0, 0)
            TabContent.AutomaticSize = Enum.AutomaticSize.Y
            
            local TabLayout = Instance.new("UIListLayout")
            TabLayout.Parent = TabContent
            TabLayout.Padding = UDim.new(0, 10)
            TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local tabObj = {}
            
            function tabObj.section(tabObj, name, isOpen)
                local Section = Instance.new("Frame")
                Section.Name = "Section"
                Section.Parent = TabContent
                Section.BackgroundColor3 = config.CardBg
                Section.BackgroundTransparency = 0.2
                Section.Size = UDim2.new(1, 0, 0, 0)
                Section.AutomaticSize = Enum.AutomaticSize.Y
                
                local SectionCorner = Instance.new("UICorner")
                SectionCorner.CornerRadius = UDim.new(0, 12)
                SectionCorner.Parent = Section
                
                local SectionGlow = Instance.new("UIStroke")
                SectionGlow.Parent = Section
                SectionGlow.Color = config.AccentColor
                SectionGlow.Thickness = 1
                SectionGlow.Transparency = 0.6
                
                -- 标题栏
                local Header = Instance.new("Frame")
                Header.Name = "Header"
                Header.Parent = Section
                Header.BackgroundTransparency = 1
                Header.Size = UDim2.new(1, 0, 0, 40)
                
                local Title = Instance.new("TextLabel")
                Title.Name = "Title"
                Title.Parent = Header
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 15, 0, 0)
                Title.Size = UDim2.new(0, 300, 0, 40)
                Title.Font = Enum.Font.GothamBold
                Title.Text = name
                Title.TextColor3 = config.PrimaryText
                Title.TextSize = 14
                Title.TextXAlignment = Enum.TextXAlignment.Left
                
                -- 折叠按钮
                local ToggleButton = Instance.new("ImageButton")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = Header
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Position = UDim2.new(1, -40, 0, 10)
                ToggleButton.Size = UDim2.new(0, 20, 0, 20)
                ToggleButton.Image = isOpen and "rbxassetid://3926305904" or "rbxassetid://3926305904"
                ToggleButton.ImageRectOffset = isOpen and Vector2.new(324, 364) or Vector2.new(124, 364)
                ToggleButton.ImageRectSize = Vector2.new(36, 36)
                
                -- 内容容器
                local Content = Instance.new("Frame")
                Content.Name = "Content"
                Content.Parent = Section
                Content.BackgroundTransparency = 1
                Content.Position = UDim2.new(0, 10, 0, 45)
                Content.Size = UDim2.new(1, -20, 0, 0)
                Content.AutomaticSize = Enum.AutomaticSize.Y
                Content.Visible = isOpen
                
                local ContentLayout = Instance.new("UIListLayout")
                ContentLayout.Parent = Content
                ContentLayout.Padding = UDim.new(0, 8)
                ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                -- 更新高度
                ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    Content.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                    Section.Size = UDim2.new(1, 0, 0, Content.Visible and (45 + ContentLayout.AbsoluteContentSize.Y + 10) or 40)
                end)
                
                -- 折叠/展开动画
                ToggleButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Content.Visible = isOpen
                    
                    ToggleButton.ImageRectOffset = isOpen and Vector2.new(324, 364) or Vector2.new(124, 364)
                    
                    services.TweenService:Create(Section, TweenInfo.new(0.3), {
                        Size = UDim2.new(1, 0, 0, Content.Visible and (45 + ContentLayout.AbsoluteContentSize.Y + 10) or 40)
                    }):Play()
                    
                    createCyberParticleExplosion(
                        UDim2.new(0.5, 0, 0, ToggleButton.AbsolutePosition.Y),
                        Section
                    )
                end)
                
                local sectionObj = {}
                
                function sectionObj.Button(sectionObj, text, callback)
                    local Button = Instance.new("TextButton")
                    Button.Name = "Button"
                    Button.Parent = Content
                    Button.BackgroundColor3 = config.ButtonBg
                    Button.BackgroundTransparency = 0.2
                    Button.Size = UDim2.new(1, 0, 0, 35)
                    Button.AutoButtonColor = false
                    Button.Font = Enum.Font.GothamBold
                    Button.Text = text
                    Button.TextColor3 = config.PrimaryText
                    Button.TextSize = 13
                    
                    local ButtonCorner = Instance.new("UICorner")
                    ButtonCorner.CornerRadius = UDim.new(0, 8)
                    ButtonCorner.Parent = Button
                    
                    local ButtonGlow = Instance.new("UIStroke")
                    ButtonGlow.Parent = Button
                    ButtonGlow.Color = config.AccentColor
                    ButtonGlow.Thickness = 1
                    ButtonGlow.Transparency = 0.6
                    createNeonFlowEffect(ButtonGlow, "Color", 0.01)
                    
                    -- 悬停动画
                    Button.MouseEnter:Connect(function()
                        services.TweenService:Create(Button, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.1,
                            Size = UDim2.new(1, 5, 0, 40)
                        }):Play()
                        
                        services.TweenService:Create(ButtonGlow, TweenInfo.new(0.2), {
                            Thickness = 2,
                            Transparency = 0.3
                        }):Play()
                    end)
                    
                    Button.MouseLeave:Connect(function()
                        services.TweenService:Create(Button, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2,
                            Size = UDim2.new(1, 0, 0, 35)
                        }):Play()
                        
                        services.TweenService:Create(ButtonGlow, TweenInfo.new(0.2), {
                            Thickness = 1,
                            Transparency = 0.6
                        }):Play()
                    end)
                    
                    -- 点击效果
                    Button.MouseButton1Click:Connect(function()
                        createCyberParticleExplosion(
                            UDim2.new(0.5, 0, 0.5, 0),
                            Button
                        )
                        
                        services.TweenService:Create(Button, TweenInfo.new(0.1), {
                            BackgroundTransparency = 0.3,
                            Size = UDim2.new(1, -5, 0, 30)
                        }):Play()
                        
                        task.wait(0.1)
                        
                        services.TweenService:Create(Button, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2,
                            Size = UDim2.new(1, 0, 0, 35)
                        }):Play()
                        
                        if callback then
                            pcall(callback)
                        end
                    end)
                    
                    return Button
                end
                
                function sectionObj.Toggle(sectionObj, text, flag, default, callback)
                    default = default or false
                    FengUI.flags[flag] = default
                    
                    local Toggle = Instance.new("Frame")
                    Toggle.Name = "Toggle"
                    Toggle.Parent = Content
                    Toggle.BackgroundTransparency = 1
                    Toggle.Size = UDim2.new(1, 0, 0, 35)
                    
                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Parent = Toggle
                    Label.BackgroundTransparency = 1
                    Label.Position = UDim2.new(0, 0, 0, 0)
                    Label.Size = UDim2.new(0, 200, 1, 0)
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = config.PrimaryText
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local Switch = Instance.new("Frame")
                    Switch.Name = "Switch"
                    Switch.Parent = Toggle
                    Switch.BackgroundColor3 = default and config.AccentColor or Color3.fromRGB(60, 60, 80)
                    Switch.Position = UDim2.new(1, -50, 0, 7)
                    Switch.Size = UDim2.new(0, 40, 0, 20)
                    
                    local SwitchCorner = Instance.new("UICorner")
                    SwitchCorner.CornerRadius = UDim.new(1, 0)
                    SwitchCorner.Parent = Switch
                    
                    local Knob = Instance.new("Frame")
                    Knob.Name = "Knob"
                    Knob.Parent = Switch
                    Knob.BackgroundColor3 = Color3.white
                    Knob.Position = default and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
                    Knob.Size = UDim2.new(0, 16, 0, 16)
                    
                    local KnobCorner = Instance.new("UICorner")
                    KnobCorner.CornerRadius = UDim.new(1, 0)
                    KnobCorner.Parent = Knob
                    
                    -- 切换动画
                    local function toggleState()
                        default = not default
                        FengUI.flags[flag] = default
                        
                        services.TweenService:Create(Knob, TweenInfo.new(0.2), {
                            Position = default and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
                        }):Play()
                        
                        services.TweenService:Create(Switch, TweenInfo.new(0.2), {
                            BackgroundColor3 = default and config.AccentColor or Color3.fromRGB(60, 60, 80)
                        }):Play()
                        
                        if default then
                            createCyberParticleExplosion(
                                UDim2.new(0.5, 0, 0.5, 0),
                                Switch
                            )
                        end
                        
                        if callback then
                            pcall(callback, default)
                        end
                    end
                    
                    Switch.MouseButton1Click:Connect(toggleState)
                    Knob.MouseButton1Click:Connect(toggleState)
                    
                    local toggleObj = {}
                    
                    function toggleObj.SetState(self, state)
                        if FengUI.flags[flag] ~= state then
                            toggleState()
                        end
                    end
                    
                    function toggleObj.GetState(self)
                        return FengUI.flags[flag]
                    end
                    
                    return toggleObj
                end
                
                function sectionObj.Slider(sectionObj, text, flag, min, max, default, callback)
                    default = default or min
                    FengUI.flags[flag] = default
                    
                    local Slider = Instance.new("Frame")
                    Slider.Name = "Slider"
                    Slider.Parent = Content
                    Slider.BackgroundTransparency = 1
                    Slider.Size = UDim2.new(1, 0, 0, 50)
                    
                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Parent = Slider
                    Label.BackgroundTransparency = 1
                    Label.Position = UDim2.new(0, 0, 0, 0)
                    Label.Size = UDim2.new(0, 200, 0, 20)
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = config.PrimaryText
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local Value = Instance.new("TextLabel")
                    Value.Name = "Value"
                    Value.Parent = Slider
                    Value.BackgroundTransparency = 1
                    Value.Position = UDim2.new(1, -60, 0, 0)
                    Value.Size = UDim2.new(0, 60, 0, 20)
                    Value.Font = Enum.Font.GothamBold
                    Value.Text = tostring(default)
                    Value.TextColor3 = config.AccentText
                    Value.TextSize = 13
                    Value.TextXAlignment = Enum.TextXAlignment.Right
                    
                    local Track = Instance.new("Frame")
                    Track.Name = "Track"
                    Track.Parent = Slider
                    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                    Track.Position = UDim2.new(0, 0, 0, 25)
                    Track.Size = UDim2.new(1, 0, 0, 6)
                    
                    local TrackCorner = Instance.new("UICorner")
                    TrackCorner.CornerRadius = UDim.new(1, 0)
                    TrackCorner.Parent = Track
                    
                    local Fill = Instance.new("Frame")
                    Fill.Name = "Fill"
                    Fill.Parent = Track
                    Fill.BackgroundColor3 = config.AccentColor
                    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    
                    local FillCorner = Instance.new("UICorner")
                    FillCorner.CornerRadius = UDim.new(1, 0)
                    FillCorner.Parent = Fill
                    
                    local Thumb = Instance.new("Frame")
                    Thumb.Name = "Thumb"
                    Thumb.Parent = Track
                    Thumb.BackgroundColor3 = Color3.white
                    Thumb.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
                    Thumb.Size = UDim2.new(0, 16, 0, 16)
                    
                    local ThumbCorner = Instance.new("UICorner")
                    ThumbCorner.CornerRadius = UDim.new(1, 0)
                    ThumbCorner.Parent = Thumb
                    
                    local dragging = false
                    
                    local function updateValue(x)
                        local percent = math.clamp((x - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        value = math.floor(value * 10) / 10
                        
                        FengUI.flags[flag] = value
                        Value.Text = tostring(value)
                        
                        services.TweenService:Create(Fill, TweenInfo.new(0.1), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        services.TweenService:Create(Thumb, TweenInfo.new(0.1), {
                            Position = UDim2.new(percent, -8, 0, -5)
                        }):Play()
                        
                        if callback then
                            pcall(callback, value)
                        end
                    end
                    
                    Track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            updateValue(input.Position.X)
                        end
                    end)
                    
                    Track.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateValue(input.Position.X)
                        end
                    end)
                    
                    local sliderObj = {}
                    
                    function sliderObj.SetValue(self, value)
                        value = math.clamp(value, min, max)
                        updateValue(Track.AbsolutePosition.X + Track.AbsoluteSize.X * ((value - min) / (max - min)))
                    end
                    
                    function sliderObj.GetValue(self)
                        return FengUI.flags[flag]
                    end
                    
                    return sliderObj
                end
                
                function sectionObj.Dropdown(sectionObj, text, flag, options, callback)
                    FengUI.flags[flag] = options[1] or ""
                    
                    local Dropdown = Instance.new("Frame")
                    Dropdown.Name = "Dropdown"
                    Dropdown.Parent = Content
                    Dropdown.BackgroundTransparency = 1
                    Dropdown.Size = UDim2.new(1, 0, 0, 35)
                    
                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Parent = Dropdown
                    Label.BackgroundTransparency = 1
                    Label.Position = UDim2.new(0, 0, 0, 0)
                    Label.Size = UDim2.new(0, 200, 1, 0)
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = config.PrimaryText
                    Label.TextSize = 13
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    
                    local Selector = Instance.new("TextButton")
                    Selector.Name = "Selector"
                    Selector.Parent = Dropdown
                    Selector.BackgroundColor3 = config.InputBg
                    Selector.BackgroundTransparency = 0.2
                    Selector.Position = UDim2.new(1, -120, 0, 7)
                    Selector.Size = UDim2.new(0, 120, 0, 25)
                    Selector.AutoButtonColor = false
                    Selector.Font = Enum.Font.Gotham
                    Selector.Text = options[1] or "选择"
                    Selector.TextColor3 = config.PrimaryText
                    Selector.TextSize = 12
                    
                    local SelectorCorner = Instance.new("UICorner")
                    SelectorCorner.CornerRadius = UDim.new(0, 6)
                    SelectorCorner.Parent = Selector
                    
                    local SelectorGlow = Instance.new("UIStroke")
                    SelectorGlow.Parent = Selector
                    SelectorGlow.Color = config.AccentColor
                    SelectorGlow.Thickness = 1
                    SelectorGlow.Transparency = 0.6
                    
                    -- 下拉菜单
                    local Menu = Instance.new("Frame")
                    Menu.Name = "Menu"
                    Menu.Parent = Dropdown
                    Menu.BackgroundColor3 = config.CardBg
                    Menu.BackgroundTransparency = 0.1
                    Menu.Position = UDim2.new(1, -120, 0, 35)
                    Menu.Size = UDim2.new(0, 120, 0, 0)
                    Menu.Visible = false
                    Menu.ClipsDescendants = true
                    
                    local MenuCorner = Instance.new("UICorner")
                    MenuCorner.CornerRadius = UDim.new(0, 6)
                    MenuCorner.Parent = Menu
                    
                    local MenuLayout = Instance.new("UIListLayout")
                    MenuLayout.Parent = Menu
                    MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    
                    -- 创建选项
                    for _, option in ipairs(options) do
                        local Option = Instance.new("TextButton")
                        Option.Name = "Option"
                        Option.Parent = Menu
                        Option.BackgroundTransparency = 1
                        Option.Size = UDim2.new(1, 0, 0, 25)
                        Option.Font = Enum.Font.Gotham
                        Option.Text = option
                        Option.TextColor3 = config.PrimaryText
                        Option.TextSize = 12
                        
                        Option.MouseEnter:Connect(function()
                            Option.BackgroundColor3 = config.ButtonBg
                            Option.BackgroundTransparency = 0.5
                        end)
                        
                        Option.MouseLeave:Connect(function()
                            Option.BackgroundTransparency = 1
                        end)
                        
                        Option.MouseButton1Click:Connect(function()
                            Selector.Text = option
                            FengUI.flags[flag] = option
                            Menu.Visible = false
                            
                            createCyberParticleExplosion(
                                UDim2.new(0.5, 0, 0.5, 0),
                                Selector
                            )
                            
                            if callback then
                                pcall(callback, option)
                            end
                        end)
                    end
                    
                    -- 更新菜单高度
                    MenuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        Menu.Size = UDim2.new(0, 120, 0, math.min(MenuLayout.AbsoluteContentSize.Y, 150))
                    end)
                    
                    -- 显示/隐藏菜单
                    Selector.MouseButton1Click:Connect(function()
                        Menu.Visible = not Menu.Visible
                    end)
                    
                    -- 点击外部关闭
                    UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if not isInBounds(Menu, input.Position) and not isInBounds(Selector, input.Position) then
                                Menu.Visible = false
                            end
                        end
                    end)
                    
                    local dropdownObj = {}
                    
                    function dropdownObj.SetOption(self, option)
                        if table.find(options, option) then
                            Selector.Text = option
                            FengUI.flags[flag] = option
                        end
                    end
                    
                    function dropdownObj.GetOption(self)
                        return FengUI.flags[flag]
                    end
                    
                    function dropdownObj.AddOption(self, option)
                        table.insert(options, option)
                        -- 重新创建菜单（简化版本）
                    end
                    
                    return dropdownObj
                end
                
                return sectionObj
            end
            
            return tabObj
        end
        
        return cardObj
    end
    
    return window
end

-- 辅助函数：检查是否在边界内
local function isInBounds(frame, position)
    local absPos = frame.AbsolutePosition
    local absSize = frame.AbsoluteSize
    return position.X >= absPos.X and position.X <= absPos.X + absSize.X and
           position.Y >= absPos.Y and position.Y <= absPos.Y + absSize.Y
end

-- UI控制函数
function FengUI:Destroy()
    if FengYu then
        FengYu:Destroy()
    end
end

function FengUI:Toggle()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playAdvancedEntranceAnimation()
    end
end

function FengUI:SetVisible(visible)
    Main.Visible = visible
    if visible then
        playAdvancedEntranceAnimation()
    end
end

-- 公开API
getgenv().FengUI = FengUI

-- 返回主对象
return FengUI