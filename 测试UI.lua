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
    RunService = game:GetService("RunService")
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

local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer

function MusicPlayer.new(parentSection)
    local self = setmetatable({}, MusicPlayer)
    
    self.parentSection = parentSection
    self.isPlaying = false
    self.currentTrack = nil
    self.currentTime = 0
    self.totalTime = 0
    self.volume = 0.5
    self.playlist = {}
    self.currentIndex = 1
    self.loopMode = "none" -- none, single, all
    self.audioEffects = {}
    
    self:CreateUI()
    self:SetupConnections()
    
    return self
end

function MusicPlayer:CreateUI()
    -- 音乐播放器主容器
    self.container = Instance.new("Frame")
    self.container.Name = "MusicPlayer"
    self.container.Parent = self.parentSection.Objs
    self.container.BackgroundTransparency = 1
    self.container.Size = UDim2.new(1, 0, 0, 180)
    self.container.LayoutOrder = 999
    
    -- 专辑封面
    self.albumArt = Instance.new("ImageLabel")
    self.albumArt.Name = "AlbumArt"
    self.albumArt.Parent = self.container
    self.albumArt.BackgroundColor3 = config.Bg_Color
    self.albumArt.BackgroundTransparency = 0.2
    self.albumArt.BorderSizePixel = 0
    self.albumArt.Position = UDim2.new(0, 0, 0, 0)
    self.albumArt.Size = UDim2.new(0, 80, 0, 80)
    self.albumArt.Image = "rbxassetid://0"
    
    local albumCorner = Instance.new("UICorner")
    albumCorner.CornerRadius = UDim.new(0, 8)
    albumCorner.Parent = self.albumArt
    
    local albumGlow = Instance.new("UIStroke")
    albumGlow.Parent = self.albumArt
    albumGlow.Color = config.AccentColor
    albumGlow.Thickness = 1
    albumGlow.Transparency = 0.8
    
    -- 歌曲信息
    self.trackInfo = Instance.new("Frame")
    self.trackInfo.Name = "TrackInfo"
    self.trackInfo.Parent = self.container
    self.trackInfo.BackgroundTransparency = 1
    self.trackInfo.Position = UDim2.new(0, 90, 0, 0)
    self.trackInfo.Size = UDim2.new(1, -90, 0, 40)
    
    self.trackTitle = Instance.new("TextLabel")
    self.trackTitle.Name = "TrackTitle"
    self.trackTitle.Parent = self.trackInfo
    self.trackTitle.BackgroundTransparency = 1
    self.trackTitle.Size = UDim2.new(1, 0, 0.5, 0)
    self.trackTitle.Font = Enum.Font.GothamBold
    self.trackTitle.Text = "未选择歌曲"
    self.trackTitle.TextColor3 = config.TextColor
    self.trackTitle.TextSize = 14
    self.trackTitle.TextXAlignment = Enum.TextXAlignment.Left
    self.trackTitle.TextTruncate = Enum.TextTruncate.AtEnd
    
    self.trackArtist = Instance.new("TextLabel")
    self.trackArtist.Name = "TrackArtist"
    self.trackArtist.Parent = self.trackInfo
    self.trackArtist.BackgroundTransparency = 1
    self.trackArtist.Position = UDim2.new(0, 0, 0.5, 0)
    self.trackArtist.Size = UDim2.new(1, 0, 0.5, 0)
    self.trackArtist.Font = Enum.Font.Gotham
    self.trackArtist.Text = "未知艺术家"
    self.trackArtist.TextColor3 = config.SecondaryTextColor
    self.trackArtist.TextSize = 12
    self.trackArtist.TextXAlignment = Enum.TextXAlignment.Left
    self.trackArtist.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- 进度条
    self.progressContainer = Instance.new("Frame")
    self.progressContainer.Name = "ProgressContainer"
    self.progressContainer.Parent = self.container
    self.progressContainer.BackgroundTransparency = 1
    self.progressContainer.Position = UDim2.new(0, 90, 0, 45)
    self.progressContainer.Size = UDim2.new(1, -90, 0, 20)
    
    self.progressBar = Instance.new("Frame")
    self.progressBar.Name = "ProgressBar"
    self.progressBar.Parent = self.progressContainer
    self.progressBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.progressBar.BorderSizePixel = 0
    self.progressBar.Size = UDim2.new(1, 0, 0, 6)
    self.progressBar.Position = UDim2.new(0, 0, 0.5, -3)
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = self.progressBar
    
    self.progressFill = Instance.new("Frame")
    self.progressFill.Name = "ProgressFill"
    self.progressFill.Parent = self.progressBar
    self.progressFill.BackgroundColor3 = config.AccentColor
    self.progressFill.BorderSizePixel = 0
    self.progressFill.Size = UDim2.new(0, 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = self.progressFill
    
    self.progressHandle = Instance.new("Frame")
    self.progressHandle.Name = "ProgressHandle"
    self.progressHandle.Parent = self.progressFill
    self.progressHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.progressHandle.BorderSizePixel = 0
    self.progressHandle.Position = UDim2.new(1, -4, 0.5, -4)
    self.progressHandle.Size = UDim2.new(0, 8, 0, 8)
    self.progressHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = self.progressHandle
    
    self.timeDisplay = Instance.new("TextLabel")
    self.timeDisplay.Name = "TimeDisplay"
    self.timeDisplay.Parent = self.progressContainer
    self.timeDisplay.BackgroundTransparency = 1
    self.timeDisplay.Position = UDim2.new(0, 0, 1, 2)
    self.timeDisplay.Size = UDim2.new(1, 0, 0, 12)
    self.timeDisplay.Font = Enum.Font.Gotham
    self.timeDisplay.Text = "0:00 / 0:00"
    self.timeDisplay.TextColor3 = config.SecondaryTextColor
    self.timeDisplay.TextSize = 10
    self.timeDisplay.TextXAlignment = Enum.TextXAlignment.Center
    
    -- 控制按钮
    self.controlsContainer = Instance.new("Frame")
    self.controlsContainer.Name = "ControlsContainer"
    self.controlsContainer.Parent = self.container
    self.controlsContainer.BackgroundTransparency = 1
    self.controlsContainer.Position = UDim2.new(0, 90, 0, 70)
    self.controlsContainer.Size = UDim2.new(1, -90, 0, 40)
    
    -- 上一首按钮
    self.prevButton = self:CreateControlButton("◀◀", UDim2.new(0, 30, 0, 30), UDim2.new(0.2, -40, 0.5, -15))
    self.prevButton.Parent = self.controlsContainer
    
    -- 播放/暂停按钮
    self.playButton = self:CreateControlButton("▶", UDim2.new(0, 40, 0, 40), UDim2.new(0.5, -20, 0.5, -20))
    self.playButton.Parent = self.controlsContainer
    
    -- 下一首按钮
    self.nextButton = self:CreateControlButton("▶▶", UDim2.new(0, 30, 0, 30), UDim2.new(0.8, 10, 0.5, -15))
    self.nextButton.Parent = self.controlsContainer
    
    -- 循环模式按钮
    self.loopButton = self:CreateControlButton("↻", UDim2.new(0, 25, 0, 25), UDim2.new(0.95, -25, 0.5, -12.5))
    self.loopButton.Parent = self.controlsContainer
    self.loopButton.TextColor3 = config.SecondaryTextColor
    
    -- 音量控制
    self.volumeContainer = Instance.new("Frame")
    self.volumeContainer.Name = "VolumeContainer"
    self.volumeContainer.Parent = self.container
    self.volumeContainer.BackgroundTransparency = 1
    self.volumeContainer.Position = UDim2.new(0, 90, 0, 115)
    self.volumeContainer.Size = UDim2.new(1, -90, 0, 20)
    
    local volumeIcon = Instance.new("TextLabel")
    volumeIcon.Name = "VolumeIcon"
    volumeIcon.Parent = self.volumeContainer
    volumeIcon.BackgroundTransparency = 1
    volumeIcon.Size = UDim2.new(0, 20, 1, 0)
    volumeIcon.Font = Enum.Font.Gotham
    volumeIcon.Text = "🔊"
    volumeIcon.TextColor3 = config.SecondaryTextColor
    volumeIcon.TextSize = 12
    
    self.volumeBar = Instance.new("Frame")
    self.volumeBar.Name = "VolumeBar"
    self.volumeBar.Parent = self.volumeContainer
    self.volumeBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.volumeBar.BorderSizePixel = 0
    self.volumeBar.Position = UDim2.new(0, 25, 0.5, -3)
    self.volumeBar.Size = UDim2.new(1, -30, 0, 6)
    
    local volumeCorner = Instance.new("UICorner")
    volumeCorner.CornerRadius = UDim.new(1, 0)
    volumeCorner.Parent = self.volumeBar
    
    self.volumeFill = Instance.new("Frame")
    self.volumeFill.Name = "VolumeFill"
    self.volumeFill.Parent = self.volumeBar
    self.volumeFill.BackgroundColor3 = config.AccentColor
    self.volumeFill.BorderSizePixel = 0
    self.volumeFill.Size = UDim2.new(self.volume, 0, 1, 0)
    
    local volumeFillCorner = Instance.new("UICorner")
    volumeFillCorner.CornerRadius = UDim.new(1, 0)
    volumeFillCorner.Parent = self.volumeFill
    
    self.volumeHandle = Instance.new("Frame")
    self.volumeHandle.Name = "VolumeHandle"
    self.volumeHandle.Parent = self.volumeFill
    self.volumeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.volumeHandle.BorderSizePixel = 0
    self.volumeHandle.Position = UDim2.new(1, -4, 0.5, -4)
    self.volumeHandle.Size = UDim2.new(0, 8, 0, 8)
    self.volumeHandle.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local volumeHandleCorner = Instance.new("UICorner")
    volumeHandleCorner.CornerRadius = UDim.new(1, 0)
    volumeHandleCorner.Parent = self.volumeHandle
    
    self.volumeText = Instance.new("TextLabel")
    self.volumeText.Name = "VolumeText"
    self.volumeText.Parent = self.volumeContainer
    self.volumeText.BackgroundTransparency = 1
    self.volumeText.Position = UDim2.new(1, -25, 0, 0)
    self.volumeText.Size = UDim2.new(0, 25, 1, 0)
    self.volumeText.Font = Enum.Font.Gotham
    self.volumeText.Text = "50%"
    self.volumeText.TextColor3 = config.SecondaryTextColor
    self.volumeText.TextSize = 10
    
    -- 播放列表和效果区域
    self.extrasContainer = Instance.new("Frame")
    self.extrasContainer.Name = "ExtrasContainer"
    self.extrasContainer.Parent = self.container
    self.extrasContainer.BackgroundTransparency = 1
    self.extrasContainer.Position = UDim2.new(0, 0, 0, 140)
    self.extrasContainer.Size = UDim2.new(1, 0, 0, 40)
    
    -- 可视化效果
    self.visualizer = Instance.new("Frame")
    self.visualizer.Name = "Visualizer"
    self.visualizer.Parent = self.extrasContainer
    self.visualizer.BackgroundTransparency = 1
    self.visualizer.Size = UDim2.new(0.7, 0, 1, 0)
    
    -- 创建频谱条
    self.bars = {}
    for i = 1, 16 do
        local bar = Instance.new("Frame")
        bar.Name = "Bar_" .. i
        bar.Parent = self.visualizer
        bar.BackgroundColor3 = config.AccentColor
        bar.BorderSizePixel = 0
        bar.Size = UDim2.new(0.05, 0, 0.2, 0)
        bar.Position = UDim2.new((i-1) * 0.06, 0, 0.8, 0)
        bar.AnchorPoint = Vector2.new(0, 1)
        
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 2)
        barCorner.Parent = bar
        
        table.insert(self.bars, bar)
    end
    
    -- 添加歌曲按钮
    self.addTrackButton = self:CreateControlButton("+", UDim2.new(0, 30, 0, 30), UDim2.new(0.85, 0, 0.5, -15))
    self.addTrackButton.Parent = self.extrasContainer
    self.addTrackButton.TextColor3 = config.AccentColor
    
    -- 当前播放列表显示
    self.playlistInfo = Instance.new("TextLabel")
    self.playlistInfo.Name = "PlaylistInfo"
    self.playlistInfo.Parent = self.extrasContainer
    self.playlistInfo.BackgroundTransparency = 1
    self.playlistInfo.Position = UDim2.new(0.7, 5, 0, 0)
    self.playlistInfo.Size = UDim2.new(0.3, -35, 1, 0)
    self.playlistInfo.Font = Enum.Font.Gotham
    self.playlistInfo.Text = "0 首歌曲"
    self.playlistInfo.TextColor3 = config.SecondaryTextColor
    self.playlistInfo.TextSize = 10
    self.playlistInfo.TextXAlignment = Enum.TextXAlignment.Right
end

function MusicPlayer:CreateControlButton(text, size, position)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = config.Button_Color
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Size = size
    button.Position = position
    button.AnchorPoint = Vector2.new(0, 0.5)
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = config.TextColor
    button.TextSize = 12
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local glow = Instance.new("UIStroke")
    glow.Parent = button
    glow.Color = config.AccentColor
    glow.Thickness = 1
    glow.Transparency = 0.8
    
    -- 按钮交互效果
    button.MouseEnter:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        }):Play()
        services.TweenService:Create(glow, TweenInfo.new(0.2), {
            Transparency = 0.5
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
        services.TweenService:Create(glow, TweenInfo.new(0.2), {
            Transparency = 0.8
        }):Play()
    end)
    
    return button
end

function MusicPlayer:SetupConnections()
    -- 播放/暂停按钮
    self.playButton.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(self.playButton)
        self:TogglePlayPause()
    end)
    
    -- 上一首/下一首
    self.prevButton.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(self.prevButton)
        self:PreviousTrack()
    end)
    
    self.nextButton.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(self.nextButton)
        self:NextTrack()
    end)
    
    -- 循环模式
    self.loopButton.MouseButton1Click:Connect(function()
        self:CycleLoopMode()
    end)
    
    -- 进度条拖动
    self:SetupProgressDrag()
    
    -- 音量控制
    self:SetupVolumeDrag()
    
    -- 添加歌曲按钮
    self.addTrackButton.MouseButton1Click:Connect(function()
        self:ShowAddTrackDialog()
    end)
    
    -- 可视化效果更新
    self.visualizerConnection = RunService.Heartbeat:Connect(function()
        self:UpdateVisualizer()
    end)
end

function MusicPlayer:SetupProgressDrag()
    local dragging = false
    
    self.progressBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            self:SetProgressFromMouse(input.Position.X)
        end
    end)
    
    self.progressBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:SetProgressFromMouse(input.Position.X)
        end
    end)
end

function MusicPlayer:SetupVolumeDrag()
    local dragging = false
    
    self.volumeBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            self:SetVolumeFromMouse(input.Position.X)
        end
    end)
    
    self.volumeBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:SetVolumeFromMouse(input.Position.X)
        end
    end)
end

function MusicPlayer:SetProgressFromMouse(mouseX)
    if not self.currentTrack then return end
    
    local barAbsolutePos = self.progressBar.AbsolutePosition.X
    local barAbsoluteSize = self.progressBar.AbsoluteSize.X
    local relativeX = math.clamp(mouseX - barAbsolutePos, 0, barAbsoluteSize)
    local progress = relativeX / barAbsoluteSize
    
    self.currentTime = self.totalTime * progress
    self:UpdateProgressDisplay()
    
    if self.currentSound then
        self.currentSound.TimePosition = self.currentTime
    end
end

function MusicPlayer:SetVolumeFromMouse(mouseX)
    local barAbsolutePos = self.volumeBar.AbsolutePosition.X
    local barAbsoluteSize = self.volumeBar.AbsoluteSize.X
    local relativeX = math.clamp(mouseX - barAbsolutePos, 0, barAbsoluteSize)
    local volume = relativeX / barAbsoluteSize
    
    self:SetVolume(volume)
end

function MusicPlayer:SetVolume(volume)
    self.volume = math.clamp(volume, 0, 1)
    self.volumeFill.Size = UDim2.new(self.volume, 0, 1, 0)
    self.volumeText.Text = math.floor(self.volume * 100) .. "%"
    
    if self.currentSound then
        self.currentSound.Volume = self.volume
    end
end

function MusicPlayer:TogglePlayPause()
    if not self.currentTrack then
        if #self.playlist > 0 then
            self:PlayTrack(1)
        else
            warn("播放列表为空")
        end
        return
    end
    
    if self.isPlaying then
        self:Pause()
    else
        self:Play()
    end
end

function MusicPlayer:Play()
    if not self.currentSound then return end
    
    self.isPlaying = true
    self.currentSound:Play()
    self.playButton.Text = "⏸"
    
    -- 开始更新进度
    self:StartProgressUpdate()
end

function MusicPlayer:Pause()
    if not self.currentSound then return end
    
    self.isPlaying = false
    self.currentSound:Pause()
    self.playButton.Text = "▶"
    
    -- 停止进度更新
    if self.progressConnection then
        self.progressConnection:Disconnect()
    end
end

function MusicPlayer:PlayTrack(index)
    if index < 1 or index > #self.playlist then return end
    
    -- 停止当前播放
    if self.currentSound then
        self.currentSound:Stop()
        self.currentSound:Destroy()
    end
    
    self.currentIndex = index
    self.currentTrack = self.playlist[index]
    
    -- 创建新的Sound实例
    self.currentSound = Instance.new("Sound")
    self.currentSound.SoundId = "rbxassetid://" .. self.currentTrack.id
    self.currentSound.Volume = self.volume
    self.currentSound.Parent = services.SoundService
    
    -- 等待加载
    self.currentSound.Loaded:Connect(function()
        self.totalTime = self.currentSound.TimeLength
        self.currentTime = 0
        self:UpdateTrackInfo()
        self:UpdateProgressDisplay()
        self:Play()
    end)
    
    self.currentSound.Ended:Connect(function()
        self:HandleTrackEnd()
    end)
end

function MusicPlayer:PreviousTrack()
    if #self.playlist == 0 then return end
    
    local newIndex = self.currentIndex - 1
    if newIndex < 1 then
        newIndex = #self.playlist
    end
    
    self:PlayTrack(newIndex)
end

function MusicPlayer:NextTrack()
    if #self.playlist == 0 then return end
    
    local newIndex = self.currentIndex + 1
    if newIndex > #self.playlist then
        newIndex = 1
    end
    
    self:PlayTrack(newIndex)
end

function MusicPlayer:CycleLoopMode()
    local modes = {"none", "single", "all"}
    local currentIndex = table.find(modes, self.loopMode) or 1
    local newIndex = (currentIndex % #modes) + 1
    self.loopMode = modes[newIndex]
    
    -- 更新按钮显示
    local displayTexts = {"↻", "🔂", "🔁"}
    local colors = {config.SecondaryTextColor, config.AccentColor, config.AccentColor}
    
    self.loopButton.Text = displayTexts[newIndex]
    self.loopButton.TextColor3 = colors[newIndex]
end

function MusicPlayer:HandleTrackEnd()
    if self.loopMode == "single" then
        self:PlayTrack(self.currentIndex)
    elseif self.loopMode == "all" then
        self:NextTrack()
    else
        self.isPlaying = false
        self.playButton.Text = "▶"
        self.currentTime = 0
        self:UpdateProgressDisplay()
    end
end

function MusicPlayer:StartProgressUpdate()
    if self.progressConnection then
        self.progressConnection:Disconnect()
    end
    
    self.progressConnection = RunService.Heartbeat:Connect(function()
        if self.currentSound and self.isPlaying then
            self.currentTime = self.currentSound.TimePosition
            self:UpdateProgressDisplay()
            
            -- 检查是否到达结尾
            if self.currentTime >= self.totalTime - 0.1 then
                self:HandleTrackEnd()
            end
        end
    end)
end

function MusicPlayer:UpdateProgressDisplay()
    local progress = self.totalTime > 0 and (self.currentTime / self.totalTime) or 0
    self.progressFill.Size = UDim2.new(progress, 0, 1, 0)
    
    -- 格式化时间显示
    local currentTimeFormatted = self:FormatTime(self.currentTime)
    local totalTimeFormatted = self:FormatTime(self.totalTime)
    self.timeDisplay.Text = currentTimeFormatted .. " / " .. totalTimeFormatted
end

function MusicPlayer:UpdateTrackInfo()
    if not self.currentTrack then return end
    
    self.trackTitle.Text = self.currentTrack.title or "未知标题"
    self.trackArtist.Text = self.currentTrack.artist or "未知艺术家"
    
    -- 设置专辑封面
    if self.currentTrack.albumArt then
        self.albumArt.Image = "rbxassetid://" .. self.currentTrack.albumArt
    else
        self.albumArt.Image = "rbxassetid://0"
    end
end

function MusicPlayer:UpdateVisualizer()
    if not self.isPlaying or not self.bars then return end
    
    for i, bar in ipairs(self.bars) do
        local height = 0.2 + (math.noise(tick() * 2 + i * 0.3) + 1) * 0.4
        services.TweenService:Create(bar, TweenInfo.new(0.1), {
            Size = UDim2.new(bar.Size.X.Scale, 0, height, 0)
        }):Play()
    end
end

function MusicPlayer:FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%d:%02d", minutes, secs)
end

function MusicPlayer:AddTrack(trackData)
    table.insert(self.playlist, trackData)
    self:UpdatePlaylistInfo()
    
    -- 如果是第一首歌曲，自动设置为当前曲目
    if #self.playlist == 1 then
        self.currentTrack = trackData
        self:UpdateTrackInfo()
    end
end

function MusicPlayer:RemoveTrack(index)
    if index < 1 or index > #self.playlist then return end
    
    table.remove(self.playlist, index)
    self:UpdatePlaylistInfo()
    
    -- 如果删除的是当前曲目
    if index == self.currentIndex then
        if #self.playlist > 0 then
            self:PlayTrack(math.min(index, #self.playlist))
        else
            self.currentTrack = nil
            self:UpdateTrackInfo()
            self:Pause()
        end
    end
end

function MusicPlayer:UpdatePlaylistInfo()
    self.playlistInfo.Text = #self.playlist .. " 首歌曲"
end

function MusicPlayer:ShowAddTrackDialog()
    -- 创建添加歌曲的对话框
    local dialog = Instance.new("Frame")
    dialog.Name = "AddTrackDialog"
    dialog.Parent = self.container
    dialog.BackgroundColor3 = config.Bg_Color
    dialog.BackgroundTransparency = 0.1
    dialog.BorderSizePixel = 0
    dialog.Position = UDim2.new(0, 0, 1, 5)
    dialog.Size = UDim2.new(1, 0, 0, 120)
    dialog.ZIndex = 10
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 8)
    dialogCorner.Parent = dialog
    
    local dialogStroke = Instance.new("UIStroke")
    dialogStroke.Parent = dialog
    dialogStroke.Color = config.AccentColor
    dialogStroke.Thickness = 1
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Parent = dialog
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Font = Enum.Font.GothamBold
    title.Text = "添加歌曲"
    title.TextColor3 = config.TextColor
    title.TextSize = 12
    
    -- 音频ID输入
    local idInput = Instance.new("TextBox")
    idInput.Parent = dialog
    idInput.BackgroundColor3 = config.Textbox_Color
    idInput.BackgroundTransparency = 0.2
    idInput.BorderSizePixel = 0
    idInput.Position = UDim2.new(0, 5, 0, 25)
    idInput.Size = UDim2.new(1, -10, 0, 25)
    idInput.Font = Enum.Font.Gotham
    idInput.PlaceholderText = "音频ID"
    idInput.TextColor3 = config.TextColor
    idInput.TextSize = 12
    
    local idInputCorner = Instance.new("UICorner")
    idInputCorner.CornerRadius = UDim.new(0, 4)
    idInputCorner.Parent = idInput
    
    -- 歌曲标题输入
    local titleInput = Instance.new("TextBox")
    titleInput.Parent = dialog
    titleInput.BackgroundColor3 = config.Textbox_Color
    titleInput.BackgroundTransparency = 0.2
    titleInput.BorderSizePixel = 0
    titleInput.Position = UDim2.new(0, 5, 0, 55)
    titleInput.Size = UDim2.new(0.6, -5, 0, 25)
    titleInput.Font = Enum.Font.Gotham
    titleInput.PlaceholderText = "歌曲标题"
    titleInput.TextColor3 = config.TextColor
    titleInput.TextSize = 12
    
    local titleInputCorner = Instance.new("UICorner")
    titleInputCorner.CornerRadius = UDim.new(0, 4)
    titleInputCorner.Parent = titleInput
    
    -- 艺术家输入
    local artistInput = Instance.new("TextBox")
    artistInput.Parent = dialog
    artistInput.BackgroundColor3 = config.Textbox_Color
    artistInput.BackgroundTransparency = 0.2
    artistInput.BorderSizePixel = 0
    artistInput.Position = UDim2.new(0.6, 5, 0, 55)
    artistInput.Size = UDim2.new(0.4, -10, 0, 25)
    artistInput.Font = Enum.Font.Gotham
    artistInput.PlaceholderText = "艺术家"
    artistInput.TextColor3 = config.TextColor
    artistInput.TextSize = 12
    
    local artistInputCorner = Instance.new("UICorner")
    artistInputCorner.CornerRadius = UDim.new(0, 4)
    artistInputCorner.Parent = artistInput
    
    -- 按钮容器
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Parent = dialog
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Position = UDim2.new(0, 0, 0, 85)
    buttonContainer.Size = UDim2.new(1, 0, 0, 30)
    
    -- 添加按钮
    local addButton = Instance.new("TextButton")
    addButton.Parent = buttonContainer
    addButton.BackgroundColor3 = config.AccentColor
    addButton.BorderSizePixel = 0
    addButton.Position = UDim2.new(0.5, 5, 0, 0)
    addButton.Size = UDim2.new(0.5, -10, 1, 0)
    addButton.Font = Enum.Font.GothamBold
    addButton.Text = "添加"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 12
    
    local addButtonCorner = Instance.new("UICorner")
    addButtonCorner.CornerRadius = UDim.new(0, 4)
    addButtonCorner.Parent = addButton
    
    -- 取消按钮
    local cancelButton = Instance.new("TextButton")
    cancelButton.Parent = buttonContainer
    cancelButton.BackgroundColor3 = config.Button_Color
    cancelButton.BorderSizePixel = 0
    cancelButton.Size = UDim2.new(0.5, -5, 1, 0)
    cancelButton.Font = Enum.Font.Gotham
    cancelButton.Text = "取消"
    cancelButton.TextColor3 = config.TextColor
    cancelButton.TextSize = 12
    
    local cancelButtonCorner = Instance.new("UICorner")
    cancelButtonCorner.CornerRadius = UDim.new(0, 4)
    cancelButtonCorner.Parent = cancelButton
    
    -- 按钮事件
    addButton.MouseButton1Click:Connect(function()
        local trackId = tonumber(idInput.Text)
        if trackId then
            local trackData = {
                id = trackId,
                title = titleInput.Text ~= "" and titleInput.Text or "未知标题",
                artist = artistInput.Text ~= "" and artistInput.Text or "未知艺术家"
            }
            self:AddTrack(trackData)
        end
        dialog:Destroy()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
    
    -- 点击外部关闭
    local function closeDialog(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local dialogPos = dialog.AbsolutePosition
            local dialogSize = dialog.AbsoluteSize
            
            if mousePos.X < dialogPos.X or mousePos.X > dialogPos.X + dialogSize.X or
               mousePos.Y < dialogPos.Y or mousePos.Y > dialogPos.Y + dialogSize.Y then
                dialog:Destroy()
            end
        end
    end
    
    services.UserInputService.InputBegan:Connect(closeDialog)
end

function MusicPlayer:Destroy()
    if self.currentSound then
        self.currentSound:Stop()
        self.currentSound:Destroy()
    end
    
    if self.progressConnection then
        self.progressConnection:Disconnect()
    end
    
    if self.visualizerConnection then
        self.visualizerConnection:Disconnect()
    end
    
    if self.container then
        self.container:Destroy()
    end
end

-- 新的数字粒子爆炸效果
function DigitalParticleExplosion(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        
        -- 获取点击位置（固定位置，不跟随）
        local x = (mouse.X - obj.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - obj.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        
        -- 创建爆炸中心
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
        
        -- 中心发光效果
        local centerGlow = Instance.new("UIStroke")
        centerGlow.Parent = explosionCenter
        centerGlow.Color = Color3.fromRGB(0, 255, 255)
        centerGlow.Thickness = 3
        centerGlow.Transparency = 0.2
        
        -- 创建数字粒子
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
        
        -- 中心爆炸动画
        services.TweenService:Create(explosionCenter, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 40, 0, 40),
            BackgroundTransparency = 1
        }):Play()
        
        services.TweenService:Create(centerGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Thickness = 8,
            Transparency = 1
        }):Play()
        
        -- 粒子飞散动画
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
                
                -- 旋转和透明度变化
                particleData.instance.Rotation = particleData.rotation * progress
                particleData.instance.TextTransparency = progress
                
                -- 数字闪烁效果
                if math.random(1, 3) == 1 then
                    particleData.instance.Text = tostring(math.random(0, 1))
                end
            end
            
            -- 中心缩放效果
            explosionCenter.Size = UDim2.new(0, 40 + progress * 20, 0, 40 + progress * 20)
        end)
        
        -- 创建冲击波环
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

-- 新的霓虹流光效果
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
        -- 创建霓虹色系循环
        local r = math.sin(hue * 6 + 0) * 0.5 + 0.5
        local g = math.sin(hue * 6 + 2) * 0.5 + 0.5
        local b = math.sin(hue * 6 + 4) * 0.5 + 0.5
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

-- 新的全息投影效果
local function createHologramEffect(frame, intensity)
    intensity = intensity or 1
    
    local hologram = Instance.new("Frame")
    hologram.Name = "HologramEffect"
    hologram.BackgroundTransparency = 1
    hologram.Size = UDim2.new(1, 0, 1, 0)
    hologram.ZIndex = frame.ZIndex - 1
    hologram.Parent = frame
    hologram.ClipsDescendants = true
    
    -- 创建扫描线效果
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
    
    -- 创建光晕效果
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
    
    -- 扫描线动画
    local scanConnection
    scanConnection = RunService.Heartbeat:Connect(function(delta)
        if not scanLines or not scanLines.Parent then
            scanConnection:Disconnect()
            return
        end
        linePattern.Offset = Vector2.new(0, (tick() * 0.5) % 1)
    end)
    
    -- 颜色循环动画
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

-- 新的脉冲发光效果
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

-- 新的3D翻转动画
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

-- 新的粒子轨迹效果
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
        -- 新的标签切换动画：缩放 + 透明度
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
    
    -- 新的切换动画：弹性缩放
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
    
    -- 创建切换粒子效果
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
Main.BackgroundTransparency = 0.2
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

-- 添加脉冲发光效果
createPulseGlow(neonStroke)

-- 添加标题栏和分割线
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)
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

-- 添加标题栏下方的分割线
local Line = Instance.new("Frame")
Line.Name = "Line"
Line.Parent = TitleBar
Line.BackgroundColor3 = config.AccentColor
Line.BorderSizePixel = 0
Line.Position = UDim2.new(0, 0, 1, 0)
Line.Size = UDim2.new(1, 0, 0, 1)
Line.ZIndex = 2

-- 调整关闭按钮位置到标题栏内
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 5)
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
        Position = UDim2.new(1, -26, 0, 4)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 16,
        Position = UDim2.new(1, -25, 0, 5)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 14,
        Position = UDim2.new(1, -24, 0, 6)
    }):Play()
    task.wait(0.1)
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
    -- 新的3D翻转动画
    create3DFlipAnimation(Open, 0.5)
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        create3DFlipAnimation(Open, 0.5)
    end
end)

-- 调整主内容区域位置
local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 32) -- 调整位置，在标题栏下方
TabMain.Size = UDim2.new(0, 360, 0, 248) -- 调整高度

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.2
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 30) -- 调整位置，在标题栏下方
Side.Size = UDim2.new(0, 90, 0, 250) -- 调整高度

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Side

-- 添加全息投影效果到侧边栏
createHologramEffect(Side, 0.3)

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 5) -- 调整位置
TabBtns.Size = UDim2.new(0, 90, 0, 240) -- 调整高度
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

-- 移除原来的ScriptTitle，因为现在有标题栏了
local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.009, 0)
ScriptTitle.Size = UDim2.new(0, 90, 0, 20)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.Text = "FengUI"
ScriptTitle.TextColor3 = config.AccentColor
ScriptTitle.TextSize = 16
ScriptTitle.TextScaled = false
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Center
ScriptTitle.Visible = false -- 隐藏原来的标题

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
        
        -- 创建数字矩阵效果
        TitleText.TextColor3 = Color3.fromHSV(hue, 1, 1)
        
        matrixEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV((hue + 0.2) % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue - 0.2) % 1, 1, 1))
        })
        
        -- 新的文字动画：弹性跳动
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

    -- 修复：确保脚本名称正确显示
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
                -- 新的弹性展开动画
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0.95, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 6 or 36)
                }):Play()
                
                services.TweenService:Create(SectionOpened, TweenInfo.new(0.3), {
                    ImageTransparency = open and 0 or 1
                }):Play()
                
                services.TweenService:Create(SectionOpen, TweenInfo.new(0.3), {
                    ImageTransparency = open and 1 or 0
                }):Play()
                
                -- 添加点击效果
                DigitalParticleExplosion(SectionToggle)
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(0.95, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 6)
            end)
            
            local section = {}
            
function section.MusicPlayer(section, name)
    local MusicPlayerModule = Instance.new("Frame")
    MusicPlayerModule.Name = "MusicPlayerModule"
    MusicPlayerModule.Parent = Objs
    MusicPlayerModule.BackgroundTransparency = 1
    MusicPlayerModule.BorderSizePixel = 0
    MusicPlayerModule.Size = UDim2.new(0, 330, 0, 36)
    
    local MusicPlayerBtn = Instance.new("TextButton")
    MusicPlayerBtn.Name = "MusicPlayerBtn"
    MusicPlayerBtn.Parent = MusicPlayerModule
    MusicPlayerBtn.BackgroundColor3 = config.Button_Color
    MusicPlayerBtn.BackgroundTransparency = 0.2
    MusicPlayerBtn.BorderSizePixel = 0
    MusicPlayerBtn.Size = UDim2.new(0, 330, 0, 36)
    MusicPlayerBtn.AutoButtonColor = false
    MusicPlayerBtn.Font = Enum.Font.GothamSemibold
    MusicPlayerBtn.Text = "   " .. (name or "音乐播放器")
    MusicPlayerBtn.TextColor3 = config.TextColor
    MusicPlayerBtn.TextSize = 14
    MusicPlayerBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local MusicPlayerBtnC = Instance.new("UICorner")
    MusicPlayerBtnC.CornerRadius = UDim.new(0, 6)
    MusicPlayerBtnC.Name = "MusicPlayerBtnC"
    MusicPlayerBtnC.Parent = MusicPlayerBtn
    
    local btnGlow = Instance.new("UIStroke")
    btnGlow.Parent = MusicPlayerBtn
    btnGlow.Color = config.AccentColor
    btnGlow.Thickness = 1
    btnGlow.Transparency = 0.8
    
    startNeonFlowEffect(btnGlow, "Color", 0.01)
    createPulseGlow(btnGlow)
    
    local player = nil
    local isExpanded = false
    
    MusicPlayerBtn.MouseButton1Click:Connect(function()
        DigitalParticleExplosion(MusicPlayerBtn)
        
        if not player then
            -- 创建音乐播放器
            player = MusicPlayer.new(section)
            
            -- 添加一些示例歌曲
            local sampleTracks = {
                {id = 27697743, title = "Roblox 经典", artist = "Roblox"},
                {id = 137226237, title = "电子音乐", artist = "未知艺术家"},
                {id = 27697248, title = "放松音乐", artist = "Roblox"}
            }
            
            for _, track in ipairs(sampleTracks) do
                player:AddTrack(track)
            end
            
            -- 调整容器大小
            MusicPlayerModule.Size = UDim2.new(0, 330, 0, 180)
            MusicPlayerBtn.Text = "   " .. (name or "音乐播放器") .. " (已加载)"
        else
            -- 切换展开/收起
            isExpanded = not isExpanded
            if isExpanded then
                player.container.Visible = true
                MusicPlayerModule.Size = UDim2.new(0, 330, 0, 180)
            else
                player.container.Visible = false
                MusicPlayerModule.Size = UDim2.new(0, 330, 0, 36)
            end
        end
    end)
    
    MusicPlayerBtn.MouseEnter:Connect(function()
        services.TweenService:Create(MusicPlayerBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    MusicPlayerBtn.MouseLeave:Connect(function()
        services.TweenService:Create(MusicPlayerBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    local funcs = {}
    
    funcs.AddTrack = function(self, trackData)
        if player then
            player:AddTrack(trackData)
        end
    end
    
    funcs.Play = function(self)
        if player then
            player:Play()
        end
    end
    
    funcs.Pause = function(self)
        if player then
            player:Pause()
        end
    end
    
    funcs.SetVolume = function(self, volume)
        if player then
            player:SetVolume(volume)
        end
    end
    
    funcs.Destroy = function(self)
        if player then
            player:Destroy()
            player = nil
        end
        MusicPlayerModule:Destroy()
    end
    
    return funcs
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
                    
                    -- 添加确认动画
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
                    
                    -- 添加输入完成动画
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
                        
                        -- 添加数值变化粒子效果
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
                    
                    -- 添加展开/收起动画
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