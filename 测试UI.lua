-- 等待游戏加载完成
repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

-- 优化渲染设置
settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

-- GUI保护函数
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

-- 主UI表
local FengUI = {}
FengUI.flags = {}
FengUI.currentFeature = nil
FengUI.featurePanels = {}
FengUI.featureCards = {}

-- 服务引用
local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService")
}

-- 配置
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
    PrimaryColor = Color3.fromRGB(25, 25, 35),
    SecondaryColor = Color3.fromRGB(35, 35, 45),
    SuccessColor = Color3.fromRGB(0, 200, 150),
    WarningColor = Color3.fromRGB(255, 150, 0),
    DangerColor = Color3.fromRGB(255, 80, 80),
    CardColor = Color3.fromRGB(30, 30, 40),
    PanelColor = Color3.fromRGB(20, 20, 30)
}

-- 音乐播放器系统
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

-- 特效函数
local function DigitalParticleExplosion(obj)
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

-- 清理旧UI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "ModernFengUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建主UI
local ModernUI = Instance.new("ScreenGui")
ModernUI.Name = "ModernFengUI"
protectGUI(ModernUI)
ModernUI.Parent = services.CoreGui

-- 创建主容器
local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = ModernUI
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.BackgroundColor3 = config.PrimaryColor
MainContainer.BackgroundTransparency = 0.1
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.Size = UDim2.new(0, 500, 0, 400)
MainContainer.Visible = false

-- 主容器圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainContainer

-- 主容器描边
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainContainer
MainStroke.Color = config.AccentColor
MainStroke.Thickness = 2
MainStroke.Transparency = 0.8

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainContainer
TitleBar.BackgroundColor3 = config.SecondaryColor
TitleBar.BackgroundTransparency = 0.1
TitleBar.Size = UDim2.new(1, 0, 0, 50)

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 20, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "高级功能面板"
TitleText.TextColor3 = config.TextColor
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = config.DangerColor
CloseButton.BackgroundTransparency = 0.8
CloseButton.Position = UDim2.new(1, -35, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.TextStrokeTransparency = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- 功能面板容器
local FeaturesContainer = Instance.new("ScrollingFrame")
FeaturesContainer.Name = "FeaturesContainer"
FeaturesContainer.Parent = MainContainer
FeaturesContainer.BackgroundTransparency = 1
FeaturesContainer.Position = UDim2.new(0, 15, 0, 60)
FeaturesContainer.Size = UDim2.new(1, -30, 1, -75)
FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
FeaturesContainer.ScrollBarThickness = 4
FeaturesContainer.ScrollBarImageColor3 = config.AccentColor
FeaturesContainer.ScrollBarImageTransparency = 0.5

-- 功能卡片布局
local FeaturesLayout = Instance.new("UIGridLayout")
FeaturesLayout.Parent = FeaturesContainer
FeaturesLayout.CellPadding = UDim2.new(0, 10, 0, 10)
FeaturesLayout.CellSize = UDim2.new(0, 140, 0, 120)
FeaturesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
FeaturesLayout.SortOrder = Enum.SortOrder.LayoutOrder
FeaturesLayout.StartCorner = Enum.StartCorner.TopLeft

-- 详情面板
local DetailPanel = Instance.new("Frame")
DetailPanel.Name = "DetailPanel"
DetailPanel.Parent = MainContainer
DetailPanel.BackgroundColor3 = config.PanelColor
DetailPanel.BackgroundTransparency = 0.1
DetailPanel.Position = UDim2.new(1, 10, 0, 0)
DetailPanel.Size = UDim2.new(0, 300, 1, 0)
DetailPanel.Visible = false

local DetailCorner = Instance.new("UICorner")
DetailCorner.CornerRadius = UDim.new(0, 12)
DetailCorner.Parent = DetailPanel

local DetailStroke = Instance.new("UIStroke")
DetailStroke.Parent = DetailPanel
DetailStroke.Color = config.AccentColor
DetailStroke.Thickness = 2
DetailStroke.Transparency = 0.8

local DetailTitle = Instance.new("TextLabel")
DetailTitle.Name = "DetailTitle"
DetailTitle.Parent = DetailPanel
DetailTitle.BackgroundTransparency = 1
DetailTitle.Position = UDim2.new(0, 15, 0, 15)
DetailTitle.Size = UDim2.new(1, -30, 0, 30)
DetailTitle.Font = Enum.Font.GothamBold
DetailTitle.Text = "功能详情"
DetailTitle.TextColor3 = config.TextColor
DetailTitle.TextSize = 16
DetailTitle.TextXAlignment = Enum.TextXAlignment.Left

local DetailContent = Instance.new("ScrollingFrame")
DetailContent.Name = "DetailContent"
DetailContent.Parent = DetailPanel
DetailContent.BackgroundTransparency = 1
DetailContent.Position = UDim2.new(0, 15, 0, 60)
DetailContent.Size = UDim2.new(1, -30, 1, -75)
DetailContent.CanvasSize = UDim2.new(0, 0, 0, 0)
DetailContent.ScrollBarThickness = 3

local DetailLayout = Instance.new("UIListLayout")
DetailLayout.Parent = DetailContent
DetailLayout.SortOrder = Enum.SortOrder.LayoutOrder
DetailLayout.Padding = UDim.new(0, 8)

-- 打开按钮
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ModernUI
OpenButton.BackgroundColor3 = config.AccentColor
OpenButton.BackgroundTransparency = 0.2
OpenButton.Position = UDim2.new(0, 20, 0, 20)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Image = "rbxassetid://3926305904"
OpenButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.ImageRectOffset = Vector2.new(964, 324)
OpenButton.ImageRectSize = Vector2.new(36, 36)

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = OpenButton
OpenStroke.Color = config.AccentColor
OpenStroke.Thickness = 2

-- 动画函数
local function createParticleEffect(parent, position)
    local particle = Instance.new("Frame")
    particle.Parent = parent
    particle.BackgroundColor3 = config.AccentColor
    particle.BackgroundTransparency = 0.5
    particle.Size = UDim2.new(0, 0, 0, 0)
    particle.Position = position
    particle.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    services.TweenService:Create(particle, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 40, 0, 40),
        BackgroundTransparency = 1
    }):Play()
    
    delay(0.3, function()
        particle:Destroy()
    end)
end

local function slideInPanel(panel)
    panel.Visible = true
    services.TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -310, 0, 0)
    }):Play()
end

local function slideOutPanel(panel)
    services.TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 10, 0, 0)
    }):Play()
    delay(0.3, function()
        panel.Visible = false
    end)
end

-- 打开按钮点击事件
OpenButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
    if MainContainer.Visible then
        services.TweenService:Create(MainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 400)
        }):Play()
        createParticleEffect(ModernUI, UDim2.new(0, OpenButton.AbsolutePosition.X + 25, 0, OpenButton.AbsolutePosition.Y + 25))
    else
        if DetailPanel.Visible then
            slideOutPanel(DetailPanel)
            FengUI.currentFeature = nil
        end
    end
end)

-- 关闭按钮事件
CloseButton.MouseButton1Click:Connect(function()
    if DetailPanel.Visible then
        slideOutPanel(DetailPanel)
        FengUI.currentFeature = nil
    else
        services.TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        delay(0.3, function()
            MainContainer.Visible = false
        end)
    end
end)

-- 功能卡片点击事件
local function onFeatureCardClick(featureName, card)
    DigitalParticleExplosion(card)
    
    if FengUI.currentFeature == featureName then
        slideOutPanel(DetailPanel)
        FengUI.currentFeature = nil
    else
        if FengUI.currentFeature then
            slideOutPanel(DetailPanel)
            wait(0.3)
        end
        FengUI.currentFeature = featureName
        local featurePanel = FengUI.featurePanels[featureName]
        if featurePanel then
            DetailContent:ClearAllChildren()
            featurePanel:Build(DetailContent)
            DetailTitle.Text = featureName
            slideInPanel(DetailPanel)
        end
    end
end

-- 创建功能卡片
function FengUI:CreateFeatureCard(name, description, icon)
    local FeatureCard = Instance.new("TextButton")
    FeatureCard.Name = name .. "Card"
    FeatureCard.Parent = FeaturesContainer
    FeatureCard.BackgroundColor3 = config.CardColor
    FeatureCard.BackgroundTransparency = 0.1
    FeatureCard.AutoButtonColor = false
    FeatureCard.Text = ""
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = FeatureCard
    
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Parent = FeatureCard
    CardStroke.Color = config.AccentColor
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.7
    
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = FeatureCard
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.5, -20, 0.3, -20)
    Icon.Size = UDim2.new(0, 40, 0, 40)
    Icon.Image = icon or "rbxassetid://3926305904"
    Icon.ImageColor3 = config.AccentColor
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = FeatureCard
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0.7, -10)
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = name
    Title.TextColor3 = config.TextColor
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Center
    
    local Desc = Instance.new("TextLabel")
    Desc.Name = "Description"
    Desc.Parent = FeatureCard
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 10, 0.85, -10)
    Desc.Size = UDim2.new(1, -20, 0, 15)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = description
    Desc.TextColor3 = config.SecondaryTextColor
    Desc.TextSize = 11
    Desc.TextXAlignment = Enum.TextXAlignment.Center
    
    -- 悬停效果
    FeatureCard.MouseEnter:Connect(function()
        services.TweenService:Create(FeatureCard, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.05,
            BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        }):Play()
        services.TweenService:Create(CardStroke, TweenInfo.new(0.2), {
            Transparency = 0.3
        }):Play()
    end)
    
    FeatureCard.MouseLeave:Connect(function()
        services.TweenService:Create(FeatureCard, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            BackgroundColor3 = config.CardColor
        }):Play()
        services.TweenService:Create(CardStroke, TweenInfo.new(0.2), {
            Transparency = 0.7
        }):Play()
    end)
    
    FengUI.featureCards[name] = FeatureCard
    return FeatureCard
end

-- 创建功能面板
function FengUI:CreateFeaturePanel(name)
    local panel = {}
    panel.Name = name
    panel.Elements = {}
    
    function panel:Button(text, callback)
        local BtnModule = Instance.new("Frame")
        local Btn = Instance.new("TextButton")
        local BtnC = Instance.new("UICorner")
        
        BtnModule.Name = "BtnModule"
        BtnModule.BackgroundTransparency = 1
        BtnModule.BorderSizePixel = 0
        BtnModule.Size = UDim2.new(1, 0, 0, 36)
        
        Btn.Name = "Btn"
        Btn.Parent = BtnModule
        Btn.BackgroundColor3 = config.Button_Color
        Btn.BackgroundTransparency = 0.2
        Btn.BorderSizePixel = 0
        Btn.Size = UDim2.new(1, 0, 0, 36)
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
            if callback then callback() end
            
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
        
        table.insert(self.Elements, BtnModule)
        return BtnModule
    end
    
    function panel:Toggle(text, flag, default, callback)
        FengUI.flags[flag] = default or false
        
        local ToggleModule = Instance.new("Frame")
        local ToggleBtn = Instance.new("TextButton")
        local ToggleBtnC = Instance.new("UICorner")
        local ToggleDisable = Instance.new("Frame")
        local ToggleSwitch = Instance.new("Frame")
        local ToggleSwitchC = Instance.new("UICorner")
        local ToggleDisableC = Instance.new("UICorner")
        
        ToggleModule.Name = "ToggleModule"
        ToggleModule.BackgroundTransparency = 1
        ToggleModule.BorderSizePixel = 0
        ToggleModule.Size = UDim2.new(1, 0, 0, 36)
        
        ToggleBtn.Name = "ToggleBtn"
        ToggleBtn.Parent = ToggleModule
        ToggleBtn.BackgroundColor3 = config.Toggle_Color
        ToggleBtn.BackgroundTransparency = 0.2
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
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
        ToggleSwitch.BackgroundColor3 = default and config.Toggle_On or config.Toggle_Off
        ToggleSwitch.Size = UDim2.new(0, 20, 0, 18)
        ToggleSwitch.Position = UDim2.new(0, default and 14 or 0, 0, 0)
        
        ToggleSwitchC.CornerRadius = UDim.new(0, 6)
        ToggleSwitchC.Name = "ToggleSwitchC"
        ToggleSwitchC.Parent = ToggleSwitch
        
        ToggleDisableC.CornerRadius = UDim.new(0, 6)
        ToggleDisableC.Name = "ToggleDisableC"
        ToggleDisableC.Parent = ToggleDisable
        
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
                if callback then callback(state) end
            end,
            Module = ToggleModule
        }
        
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
        
        ToggleBtn.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(ToggleBtn)
            funcs:SetState()
        end)
        
        table.insert(self.Elements, ToggleModule)
        return funcs
    end
    
    function panel:Slider(text, flag, min, max, default, precise, callback)
        FengUI.flags[flag] = default or min
        
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
        SliderModule.BackgroundTransparency = 1
        SliderModule.BorderSizePixel = 0
        SliderModule.Size = UDim2.new(1, 0, 0, 36)
        
        SliderBack.Name = "SliderBack"
        SliderBack.Parent = SliderModule
        SliderBack.BackgroundColor3 = config.Slider_Color
        SliderBack.BackgroundTransparency = 0.2
        SliderBack.BorderSizePixel = 0
        SliderBack.Size = UDim2.new(1, 0, 0, 36)
        SliderBack.AutoButtonColor = false
        SliderBack.Font = Enum.Font.GothamSemibold
        SliderBack.Text = "   " .. text
        SliderBack.TextColor3 = config.TextColor
        SliderBack.TextSize = 14
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
        
        SliderValBGC.CornerRadius = UDim.new(0, 6)
        SliderValBGC.Name = "SliderValBGC"
        SliderValBGC.Parent = SliderValBG
        
        SliderValue.Name = "SliderValue"
        SliderValue.Parent = SliderValBG
        SliderValue.BackgroundTransparency = 1
        SliderValue.BorderSizePixel = 0
        SliderValue.Size = UDim2.new(1, 0, 1, 0)
        SliderValue.Font = Enum.Font.Gotham
        SliderValue.Text = tostring(default)
        SliderValue.TextColor3 = config.TextColor
        SliderValue.TextSize = 11
        
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
                
                if callback then callback(tonumber(value)) end
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
        
        table.insert(self.Elements, SliderModule)
        return funcs
    end
    
    function panel:Dropdown(text, flag, options, callback)
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
        DropdownModule.BackgroundTransparency = 1
        DropdownModule.BorderSizePixel = 0
        DropdownModule.ClipsDescendants = true
        DropdownModule.Size = UDim2.new(1, 0, 0, 36)
        
        DropdownTop.Name = "DropdownTop"
        DropdownTop.Parent = DropdownModule
        DropdownTop.BackgroundColor3 = config.Dropdown_Color
        DropdownTop.BackgroundTransparency = 0.2
        DropdownTop.BorderSizePixel = 0
        DropdownTop.Size = UDim2.new(1, 0, 0, 36)
        DropdownTop.AutoButtonColor = false
        DropdownTop.Font = Enum.Font.GothamSemibold
        DropdownTop.Text = ""
        DropdownTop.TextColor3 = config.TextColor
        DropdownTop.TextSize = 14
        DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
        
        DropdownTopC.CornerRadius = UDim.new(0, 6)
        DropdownTopC.Name = "DropdownTopC"
        DropdownTopC.Parent = DropdownTop
        
        DropdownOpenFrame.Name = "DropdownOpenFrame"
        DropdownOpenFrame.Parent = DropdownTop
        DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
        DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
        DropdownOpenFrame.BorderSizePixel = 0
        DropdownOpenFrame.Position = UDim2.new(0.80, 0, 0.5, 0)
        DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)
        
        DropdownOpenFrameC.CornerRadius = UDim.new(0, 4)
        DropdownOpenFrameC.Name = "DropdownOpenFrameC"
        DropdownOpenFrameC.Parent = DropdownOpenFrame
        
        DropdownOpen.Name = "DropdownOpen"
        DropdownOpen.Parent = DropdownOpenFrame
        DropdownOpen.BackgroundTransparency = 1
        DropdownOpen.BorderSizePixel = 0
        DropdownOpen.Size = UDim2.new(1, 0, 1, 0)
        DropdownOpen.Font = Enum.Font.GothamSemibold
        DropdownOpen.Text = "选择"
        DropdownOpen.TextColor3 = config.TextColor
        DropdownOpen.TextSize = 11
        DropdownOpen.TextWrapped = true
        
        DropdownText.Name = "DropdownText"
        DropdownText.Parent = DropdownTop
        DropdownText.BackgroundTransparency = 1
        DropdownText.BorderSizePixel = 0
        DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
        DropdownText.Size = UDim2.new(0, 230, 0, 36)
        DropdownText.Font = Enum.Font.GothamSemibold
        DropdownText.PlaceholderColor3 = config.SecondaryTextColor
        DropdownText.PlaceholderText = text
        DropdownText.Text = ""
        DropdownText.TextColor3 = config.TextColor
        DropdownText.TextSize = 14
        DropdownText.TextXAlignment = Enum.TextXAlignment.Left
        
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
            
            DropdownModule.Size = UDim2.new(1, 0, 0, open and (36 + DropdownModuleL.AbsoluteContentSize.Y + 4) or 36)
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
                DropdownModule.Size = UDim2.new(1, 0, 0, 36 + DropdownModuleL.AbsoluteContentSize.Y + 4)
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
            Option.Size = UDim2.new(1, 0, 0, 24)
            Option.AutoButtonColor = false
            Option.Font = Enum.Font.Gotham
            Option.Text = option
            Option.TextColor3 = config.TextColor
            Option.TextSize = 13
            OptionC.CornerRadius = UDim.new(0, 6)
            OptionC.Name = "OptionC"
            OptionC.Parent = Option
            
            Option.MouseButton1Click:Connect(function()
                DigitalParticleExplosion(Option)
                ToggleDropVis()
                if callback then callback(Option.Text) end
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
        table.insert(self.Elements, DropdownModule)
        return funcs
    end
    
    function panel:Textbox(text, flag, default, callback)
        FengUI.flags[flag] = default
        
        local TextboxModule = Instance.new("Frame")
        local TextboxBack = Instance.new("TextButton")
        local TextboxBackC = Instance.new("UICorner")
        local BoxBG = Instance.new("TextButton")
        local BoxBGC = Instance.new("UICorner")
        local TextBox = Instance.new("TextBox")
        
        TextboxModule.Name = "TextboxModule"
        TextboxModule.BackgroundTransparency = 1
        TextboxModule.BorderSizePixel = 0
        TextboxModule.Size = UDim2.new(1, 0, 0, 36)
        
        TextboxBack.Name = "TextboxBack"
        TextboxBack.Parent = TextboxModule
        TextboxBack.BackgroundColor3 = config.Textbox_Color
        TextboxBack.BackgroundTransparency = 0.2
        TextboxBack.BorderSizePixel = 0
        TextboxBack.Size = UDim2.new(1, 0, 0, 36)
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
            if callback then callback(TextBox.Text) end
            DigitalParticleExplosion(BoxBG)
        end)
        
        TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
            BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
        end)
        
        BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
        table.insert(self.Elements, TextboxModule)
        return TextboxModule
    end
    
    function panel:Keybind(text, default, callback)
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
        
        KeybindModule.Name = "KeybindModule"
        KeybindModule.BackgroundTransparency = 1
        KeybindModule.BorderSizePixel = 0
        KeybindModule.Size = UDim2.new(1, 0, 0, 36)
        
        KeybindBtn.Name = "KeybindBtn"
        KeybindBtn.Parent = KeybindModule
        KeybindBtn.BackgroundColor3 = config.Keybind_Color
        KeybindBtn.BackgroundTransparency = 0.2
        KeybindBtn.BorderSizePixel = 0
        KeybindBtn.Size = UDim2.new(1, 0, 0, 36)
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
        
        services.UserInputService.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if inp.KeyCode ~= bindKey then return end
            if callback then callback(bindKey.Name) end
        end)
        
        KeybindValue.MouseButton1Click:Connect(function()
            DigitalParticleExplosion(KeybindValue)
            KeybindValue.Text = "..."
            task.wait()
            
            local key = services.UserInputService.InputEnded:Wait()
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
            keyTxt = KeybindValue.Text
            
            create3DFlipAnimation(KeybindValue, 0.3)
        end)
        
        KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
            KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
        end)
        
        KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
        table.insert(self.Elements, KeybindModule)
        return KeybindModule
    end
    
    function panel:Label(text)
        local LabelModule = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local LabelC = Instance.new("UICorner")
        
        LabelModule.Name = "LabelModule"
        LabelModule.BackgroundTransparency = 1
        LabelModule.BorderSizePixel = 0
        LabelModule.Size = UDim2.new(1, 0, 0, 24)
        
        TextLabel.Parent = LabelModule
        TextLabel.BackgroundColor3 = config.Label_Color
        TextLabel.BackgroundTransparency = 0.2
        TextLabel.Size = UDim2.new(1, 0, 0, 28)
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.Text = text
        TextLabel.TextColor3 = config.SecondaryTextColor
        TextLabel.TextSize = 14
        
        LabelC.CornerRadius = UDim.new(0, 6)
        LabelC.Name = "LabelC"
        LabelC.Parent = TextLabel
        
        table.insert(self.Elements, LabelModule)
        return TextLabel
    end
    
    function panel:Image(imageId, sizeX, sizeY)
        local ImageModule = Instance.new("Frame")
        local ImageLabel = Instance.new("ImageLabel")
        local ImageCorner = Instance.new("UICorner")
        
        ImageModule.Name = "ImageModule"
        ImageModule.BackgroundTransparency = 1
        ImageModule.BorderSizePixel = 0
        ImageModule.Size = UDim2.new(1, 0, 0, sizeY or 120)
        
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
        
        table.insert(self.Elements, ImageModule)
        return ImageLabel
    end
    
    function panel:MusicPlayer(title, defaultPlaylist)
        local MusicPlayerModule = Instance.new("Frame")
        MusicPlayerModule.Name = "MusicPlayerModule"
        MusicPlayerModule.BackgroundTransparency = 1
        MusicPlayerModule.BorderSizePixel = 0
        MusicPlayerModule.Size = UDim2.new(1, 0, 0, 160)
        
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
        
        table.insert(self.Elements, MusicPlayerModule)
        return musicPlayerFuncs
    end
    
    function panel:Build(parent)
        for _, element in ipairs(self.Elements) do
            element.Parent = parent
        end
        DetailLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            DetailContent.CanvasSize = UDim2.new(0, 0, 0, DetailLayout.AbsoluteContentSize.Y)
        end)
    end
    
    FengUI.featurePanels[name] = panel
    return panel
end

-- 注册功能模块（在脚本中使用）
function FengUI:RegisterFeature(name, description, icon, panelBuilder)
    -- 创建功能卡片
    local card = self:CreateFeatureCard(name, description, icon)
    
    -- 创建功能面板
    local panel = self:CreateFeaturePanel(name)
    
    -- 使用外部提供的面板构建器
    if panelBuilder and type(panelBuilder) == "function" then
        panelBuilder(panel)
    end
    
    -- 绑定点击事件
    card.MouseButton1Click:Connect(function()
        onFeatureCardClick(name, card)
    end)
    
    return {
        Card = card,
        Panel = panel
    }
end

-- 自动调整容器大小
FeaturesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FeaturesContainer.CanvasSize = UDim2.new(0, 0, 0, FeaturesLayout.AbsoluteContentSize.Y)
end)

-- 全局函数
function FengUI:Toggle()
    OpenButton.MouseButton1Click:Fire()
end

function FengUI:Destroy()
    if ModernUI then
        ModernUI:Destroy()
    end
end

-- 返回UI对象
getgenv().FengUI = FengUI
return FengUI