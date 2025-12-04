repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().AetherUI = {}

-- 性能优化
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

-- AetherUI主对象
local AetherUI = {}
local ToggleUI = true
AetherUI.currentTab = nil
AetherUI.flags = {}

-- 服务引用
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

-- 新色彩配置 - 赛博朋克风格
local config = {
    MainColor = Color3.fromRGB(10, 10, 20),
    TabColor = Color3.fromRGB(15, 15, 25),
    Bg_Color = Color3.fromRGB(8, 8, 18),
    Button_Color = Color3.fromRGB(20, 20, 35),
    Textbox_Color = Color3.fromRGB(20, 20, 35),
    Dropdown_Color = Color3.fromRGB(20, 20, 35),
    Keybind_Color = Color3.fromRGB(20, 20, 35),
    Label_Color = Color3.fromRGB(20, 20, 35),
    Slider_Color = Color3.fromRGB(20, 20, 35),
    SliderBar_Color = Color3.fromRGB(0, 255, 255),
    Toggle_Color = Color3.fromRGB(20, 20, 35),
    Toggle_Off = Color3.fromRGB(40, 40, 60),
    Toggle_On = Color3.fromRGB(0, 255, 255),
    AccentColor = Color3.fromRGB(0, 255, 255),
    AccentColor2 = Color3.fromRGB(255, 0, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryTextColor = Color3.fromRGB(180, 180, 220),
    GlowColor = Color3.fromRGB(0, 200, 255),
    NeonBlue = Color3.fromRGB(0, 200, 255),
    NeonPink = Color3.fromRGB(255, 0, 255),
    NeonGreen = Color3.fromRGB(0, 255, 128)
}

-- 音乐播放器（简化版）
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

function MusicPlayer:AddToPlaylist(trackId, title, artist, imageId)
    table.insert(self.playlist, {
        id = trackId,
        title = title or "Unknown Title",
        artist = artist or "Unknown Artist",
        imageId = imageId or "84830962019412"
    })
end

function MusicPlayer:GetCurrentTrack()
    if #self.playlist == 0 then return nil end
    return self.playlist[self.currentTrackIndex]
end

-- 高级视觉效果
local function createCyberGrid(parent, speed)
    speed = speed or 0.5
    local grid = Instance.new("Frame")
    grid.Name = "CyberGrid"
    grid.BackgroundTransparency = 1
    grid.Size = UDim2.new(1, 0, 1, 0)
    grid.Parent = parent
    grid.ZIndex = -1
    
    local gridSize = 40
    local lines = {}
    
    for i = 1, math.floor(parent.AbsoluteSize.X/gridSize) do
        local line = Instance.new("Frame")
        line.Name = "GridLineV"
        line.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        line.BackgroundTransparency = 0.95
        line.BorderSizePixel = 0
        line.Size = UDim2.new(0, 1, 1, 0)
        line.Position = UDim2.new(0, i * gridSize, 0, 0)
        line.Parent = grid
        table.insert(lines, line)
    end
    
    for i = 1, math.floor(parent.AbsoluteSize.Y/gridSize) do
        local line = Instance.new("Frame")
        line.Name = "GridLineH"
        line.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        line.BackgroundTransparency = 0.95
        line.BorderSizePixel = 0
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0, i * gridSize)
        line.Parent = grid
        table.insert(lines, line)
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not grid.Parent then
            connection:Disconnect()
            return
        end
        
        local time = tick() * speed
        for _, line in ipairs(lines) do
            local alpha = 0.8 + math.sin(time + line.AbsolutePosition.X * 0.01 + line.AbsolutePosition.Y * 0.01) * 0.2
            line.BackgroundTransparency = 1 - alpha * 0.05
        end
    end)
    
    return grid
end

local function createDataStream(parent)
    local stream = Instance.new("Frame")
    stream.Name = "DataStream"
    stream.BackgroundTransparency = 1
    stream.Size = UDim2.new(1, 0, 1, 0)
    stream.Parent = parent
    stream.ClipsDescendants = true
    
    local chars = {"0", "1", "▮", "▯", "■", "□", "▣", "▢", "◈", "◉", "◊", "○"}
    local particles = {}
    
    for i = 1, 30 do
        local particle = Instance.new("TextLabel")
        particle.Name = "DataParticle"
        particle.BackgroundTransparency = 1
        particle.Text = chars[math.random(1, #chars)]
        particle.TextColor3 = Color3.fromRGB(0, math.random(150, 255), math.random(200, 255))
        particle.TextSize = math.random(12, 18)
        particle.Font = Enum.Font.Code
        particle.Size = UDim2.new(0, 20, 0, 20)
        particle.Position = UDim2.new(0, math.random(0, parent.AbsoluteSize.X), 0, -20)
        particle.Parent = stream
        particle.ZIndex = -1
        
        local speed = math.random(2, 5)
        local life = math.random(2, 4)
        
        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < life and particle.Parent do
                particle.Position = particle.Position + UDim2.new(0, 0, 0, speed)
                particle.TextTransparency = (tick() - startTime) / life
                
                if math.random(1, 10) == 1 then
                    particle.Text = chars[math.random(1, #chars)]
                end
                
                if particle.Position.Y.Offset > parent.AbsoluteSize.Y then
                    particle.Position = UDim2.new(0, math.random(0, parent.AbsoluteSize.X), 0, -20)
                end
                
                task.wait(0.03)
            end
            particle:Destroy()
        end)
    end
    
    return stream
end

local function createHologramGlow(frame)
    local glow = Instance.new("UIGradient")
    glow.Rotation = 45
    glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.NeonBlue),
        ColorSequenceKeypoint.new(0.5, config.NeonPink),
        ColorSequenceKeypoint.new(1, config.NeonBlue)
    })
    glow.Parent = frame
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not glow.Parent then
            connection:Disconnect()
            return
        end
        
        local time = tick()
        glow.Rotation = glow.Rotation + 1
        if glow.Rotation >= 360 then
            glow.Rotation = 0
        end
    end)
    
    return glow
end

local function createPulseEffect(object, property)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        
        local alpha = 0.5 + math.sin(tick() * 2) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif property == "BackgroundTransparency" then
            object.BackgroundTransparency = alpha
        elseif property == "ImageTransparency" then
            object.ImageTransparency = alpha
        end
    end)
    return connection
end

-- 清除旧GUI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "AetherUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建主GUI
local AetherGui = Instance.new("ScreenGui")
AetherGui.Name = "AetherUI"
protectGUI(AetherGui)
AetherGui.Parent = services.CoreGui

-- 主窗口
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = AetherGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.MainColor
Main.BackgroundTransparency = 0.1
Main.Position = UDim2.new(0.5, 0, 0.4, 0)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- 边框效果
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = config.NeonBlue
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

local InnerStroke = Instance.new("UIStroke")
InnerStroke.Parent = Main
InnerStroke.Color = config.NeonPink
InnerStroke.Thickness = 1
InnerStroke.Transparency = 0.5

-- 背景网格
createCyberGrid(Main, 0.3)
createDataStream(Main)

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

-- 标题文字
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0.03, 0, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "AETHER UI"
TitleText.TextColor3 = config.AccentColor
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 0

-- 标题霓虹效果
createPulseEffect(TitleText, "TextTransparency")

-- 关闭按钮
local CloseButton = Instance.new("ImageButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BackgroundTransparency = 0.8
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Image = "rbxassetid://7733765391"
CloseButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.ZIndex = 10

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.6,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 20, 0, 20)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    task.wait(0.4)
    AetherGui:Destroy()
end)

-- 侧边栏
local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.2
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 40)
Side.Size = UDim2.new(0, 100, 0, 280)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Side

createHologramGlow(Side)

-- 标签按钮容器
local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 10, 0, 10)
TabBtns.Size = UDim2.new(0, 80, 0, 260)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = config.NeonBlue
TabBtns.ScrollBarImageTransparency = 0.5

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)

-- 主要内容区域
local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0, 110, 0, 50)
TabMain.Size = UDim2.new(0, 380, 0, 260)

-- 切换标签函数
local switchingTabs = false
function switchTab(newTab)
    if switchingTabs then return end
    
    local oldTab = AetherUI.currentTab
    if oldTab then
        oldTab.container.Visible = false
        services.TweenService:Create(oldTab.button, TweenInfo.new(0.3), {
            BackgroundColor3 = config.Button_Color,
            Size = UDim2.new(0, 70, 0, 30)
        }):Play()
    end
    
    AetherUI.currentTab = newTab
    newTab.container.Visible = true
    
    services.TweenService:Create(newTab.button, TweenInfo.new(0.3), {
        BackgroundColor3 = config.AccentColor,
        Size = UDim2.new(0, 75, 0, 32)
    }):Play()
    
    createDataStream(newTab.container)
end

-- 入口动画
local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.3, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 500, 0, 320)
    }):Play()
    
    task.wait(0.3)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4), {
        BackgroundTransparency = 0.1
    }):Play()
    
    services.TweenService:Create(Side, TweenInfo.new(0.4), {
        BackgroundTransparency = 0.2
    }):Play()
end

-- 延迟播放动画
task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

-- 主UI创建函数
function AetherUI.new(name, theme)
    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end
    
    local scriptName = name or "AETHER UI"
    TitleText.Text = scriptName
    
    local window = {}
    
    function window.Tab(name, icon)
        -- 创建标签容器
        local TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Name = "Tab_" .. name
        TabContainer.Parent = TabMain
        TabContainer.Active = true
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.ScrollBarThickness = 3
        TabContainer.ScrollBarImageColor3 = config.NeonBlue
        TabContainer.ScrollBarImageTransparency = 0.5
        TabContainer.Visible = false
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Name = "TabLayout"
        TabLayout.Parent = TabContainer
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 8)
        
        -- 创建标签按钮
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabBtn_" .. name
        TabButton.Parent = TabBtns
        TabButton.BackgroundColor3 = config.Button_Color
        TabButton.BackgroundTransparency = 0.2
        TabButton.Size = UDim2.new(0, 70, 0, 30)
        TabButton.AutoButtonColor = false
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = name
        TabButton.TextColor3 = config.TextColor
        TabButton.TextSize = 13
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton
        
        -- 添加按钮效果
        TabButton.MouseEnter:Connect(function()
            services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        TabButton.MouseLeave:Connect(function()
            if AetherUI.currentTab and AetherUI.currentTab.button ~= TabButton then
                services.TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            switchTab({button = TabButton, container = TabContainer})
        end)
        
        -- 设置初始标签
        if not AetherUI.currentTab then
            switchTab({button = TabButton, container = TabContainer})
        end
        
        local tab = {}
        
        function tab.Section(title)
            local Section = Instance.new("Frame")
            Section.Name = "Section_" .. title
            Section.Parent = TabContainer
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = 0.2
            Section.Size = UDim2.new(1, 0, 0, 40)
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = Section
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = Section
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0.05, 0, 0, 0)
            SectionTitle.Size = UDim2.new(0.9, 0, 1, 0)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = "  " .. title
            SectionTitle.TextColor3 = config.AccentColor
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = Section
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 10, 0, 40)
            SectionContent.Size = UDim2.new(1, -20, 0, 0)
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.Name = "SectionLayout"
            SectionLayout.Parent = SectionContent
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 6)
            
            local section = {}
            
            function section.Button(text, callback)
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn_" .. text
                Btn.Parent = SectionContent
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.2
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 13
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 6)
                BtnCorner.Parent = Btn
                
                -- 霓虹边框
                local BtnGlow = Instance.new("UIStroke")
                BtnGlow.Parent = Btn
                BtnGlow.Color = config.NeonBlue
                BtnGlow.Thickness = 1
                BtnGlow.Transparency = 0.7
                
                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                    services.TweenService:Create(BtnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.4
                    }):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.2
                    }):Play()
                    services.TweenService:Create(BtnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.7
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    if callback then
                        callback()
                    end
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = config.AccentColor
                    }):Play()
                    task.wait(0.1)
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                end)
                
                return Btn
            end
            
            function section.Toggle(text, flag, default, callback)
                local Toggle = Instance.new("TextButton")
                Toggle.Name = "Toggle_" .. text
                Toggle.Parent = SectionContent
                Toggle.BackgroundColor3 = config.Toggle_Color
                Toggle.BackgroundTransparency = 0.2
                Toggle.Size = UDim2.new(1, 0, 0, 32)
                Toggle.AutoButtonColor = false
                Toggle.Font = Enum.Font.GothamSemibold
                Toggle.Text = "  " .. text
                Toggle.TextColor3 = config.TextColor
                Toggle.TextSize = 13
                Toggle.TextXAlignment = Enum.TextXAlignment.Left
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 6)
                ToggleCorner.Parent = Toggle
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "ToggleIndicator"
                ToggleIndicator.Parent = Toggle
                ToggleIndicator.BackgroundColor3 = default and config.Toggle_On or config.Toggle_Off
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Position = UDim2.new(0.85, 0, 0.15, 0)
                ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
                
                local ToggleIndicatorCorner = Instance.new("UICorner")
                ToggleIndicatorCorner.CornerRadius = UDim.new(0, 4)
                ToggleIndicatorCorner.Parent = ToggleIndicator
                
                if default then
                    createHologramGlow(ToggleIndicator)
                end
                
                local state = default or false
                AetherUI.flags[flag] = state
                
                Toggle.MouseButton1Click:Connect(function()
                    state = not state
                    AetherUI.flags[flag] = state
                    
                    services.TweenService:Create(ToggleIndicator, TweenInfo.new(0.3), {
                        BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                    }):Play()
                    
                    if state then
                        createHologramGlow(ToggleIndicator)
                    else
                        local glow = ToggleIndicator:FindFirstChildOfClass("UIGradient")
                        if glow then
                            glow:Destroy()
                        end
                    end
                    
                    if callback then
                        callback(state)
                    end
                end)
                
                local toggleFuncs = {}
                
                function toggleFuncs:SetState(newState)
                    state = newState
                    AetherUI.flags[flag] = state
                    ToggleIndicator.BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                    
                    if callback then
                        callback(state)
                    end
                end
                
                function toggleFuncs:GetState()
                    return state
                end
                
                return toggleFuncs
            end
            
            function section.Slider(text, flag, min, max, default, callback)
                local Slider = Instance.new("TextButton")
                Slider.Name = "Slider_" .. text
                Slider.Parent = SectionContent
                Slider.BackgroundColor3 = config.Slider_Color
                Slider.BackgroundTransparency = 0.2
                Slider.Size = UDim2.new(1, 0, 0, 40)
                Slider.AutoButtonColor = false
                Slider.Font = Enum.Font.GothamSemibold
                Slider.Text = "  " .. text
                Slider.TextColor3 = config.TextColor
                Slider.TextSize = 13
                Slider.TextXAlignment = Enum.TextXAlignment.Left
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 6)
                SliderCorner.Parent = Slider
                
                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = Slider
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
                SliderBar.Size = UDim2.new(0.9, 0, 0, 6)
                
                local SliderBarCorner = Instance.new("UICorner")
                SliderBarCorner.CornerRadius = UDim.new(1, 0)
                SliderBarCorner.Parent = SliderBar
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderBar
                SliderFill.BackgroundColor3 = config.SliderBar_Color
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = Slider
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(0.8, 0, 0.1, 0)
                SliderValue.Size = UDim2.new(0.15, 0, 0, 15)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.SecondaryTextColor
                SliderValue.TextSize = 11
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                
                AetherUI.flags[flag] = default
                
                local dragging = false
                
                local function updateValue(value)
                    value = math.clamp(value, min, max)
                    AetherUI.flags[flag] = value
                    SliderValue.Text = tostring(math.floor(value))
                    SliderFill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local mouse = services.Players.LocalPlayer:GetMouse()
                        local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        updateValue(min + (max - min) * percent)
                    end
                end)
                
                services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mouse = services.Players.LocalPlayer:GetMouse()
                        local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        updateValue(min + (max - min) * percent)
                    end
                end)
                
                local sliderFuncs = {}
                
                function sliderFuncs:SetValue(value)
                    updateValue(value)
                end
                
                function sliderFuncs:GetValue()
                    return AetherUI.flags[flag]
                end
                
                return sliderFuncs
            end
            
            function section.Label(text)
                local Label = Instance.new("TextLabel")
                Label.Name = "Label_" .. text
                Label.Parent = SectionContent
                Label.BackgroundColor3 = config.Label_Color
                Label.BackgroundTransparency = 0.2
                Label.Size = UDim2.new(1, 0, 0, 28)
                Label.Font = Enum.Font.Gotham
                Label.Text = text
                Label.TextColor3 = config.SecondaryTextColor
                Label.TextSize = 12
                Label.TextWrapped = true
                
                local LabelCorner = Instance.new("UICorner")
                LabelCorner.CornerRadius = UDim.new(0, 6)
                LabelCorner.Parent = Label
                
                return Label
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

-- UI控制函数
function UiDestroy()
    if AetherGui then
        AetherGui:Destroy()
    end
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    AetherGui.Enabled = ToggleUI
end

-- 全局导出
getgenv().AetherUI = AetherUI

-- 添加快捷键打开/关闭UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        ToggleUILib()
        Main.Visible = ToggleUI
    end
end)

return AetherUI