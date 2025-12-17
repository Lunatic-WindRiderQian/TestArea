-- 测试UI.lua - 完整高级UI库
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
FengUI.tabContainers = {}

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
    MainColor = Color3.fromRGB(18, 18, 30),
    TabColor = Color3.fromRGB(25, 25, 40),
    Bg_Color = Color3.fromRGB(20, 20, 35),
    Zy_Color = Color3.fromRGB(20, 20, 35),
    Button_Color = Color3.fromRGB(30, 30, 50),
    Textbox_Color = Color3.fromRGB(30, 30, 50),
    Dropdown_Color = Color3.fromRGB(30, 30, 50),
    Keybind_Color = Color3.fromRGB(30, 30, 50),
    Label_Color = Color3.fromRGB(30, 30, 50),
    Slider_Color = Color3.fromRGB(30, 30, 50),
    SliderBar_Color = Color3.fromRGB(0, 200, 255),
    Toggle_Color = Color3.fromRGB(30, 30, 50),
    Toggle_Off = Color3.fromRGB(50, 50, 70),
    Toggle_On = Color3.fromRGB(0, 230, 230),
    AccentColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(240, 245, 255),
    SecondaryTextColor = Color3.fromRGB(180, 190, 210),
    GlowColor = Color3.fromRGB(0, 150, 255),
    
    DeepSpaceColor = Color3.fromRGB(1, 2, 10),
    NebulaColor1 = Color3.fromRGB(0, 40, 80),
    NebulaColor2 = Color3.fromRGB(20, 60, 120),
    AccentGlow = Color3.fromRGB(0, 220, 255),
    ElementColor = Color3.fromRGB(30, 30, 50),
    ElementTransparency = 0.2,
    GlassEffect = Color3.fromRGB(255, 255, 255),
}

-- 全局颜色管理器
FengUI.ColorManager = {
    themes = {
        default = {
            MainColor = Color3.fromRGB(18, 18, 30),
            TabColor = Color3.fromRGB(25, 25, 40),
            Bg_Color = Color3.fromRGB(20, 20, 35),
            AccentColor = Color3.fromRGB(0, 200, 255),
            TextColor = Color3.fromRGB(240, 245, 255),
            SecondaryTextColor = Color3.fromRGB(180, 190, 210),
            Button_Color = Color3.fromRGB(30, 30, 50),
            Toggle_On = Color3.fromRGB(0, 230, 230),
            SliderBar_Color = Color3.fromRGB(0, 200, 255),
        },
        light = {
            MainColor = Color3.fromRGB(240, 240, 245),
            TabColor = Color3.fromRGB(250, 250, 255),
            Bg_Color = Color3.fromRGB(245, 245, 250),
            AccentColor = Color3.fromRGB(0, 150, 255),
            TextColor = Color3.fromRGB(30, 30, 40),
            SecondaryTextColor = Color3.fromRGB(80, 90, 110),
            Button_Color = Color3.fromRGB(220, 220, 230),
            Toggle_On = Color3.fromRGB(0, 180, 255),
            SliderBar_Color = Color3.fromRGB(0, 150, 255),
        },
        neon = {
            MainColor = Color3.fromRGB(10, 10, 20),
            TabColor = Color3.fromRGB(20, 20, 40),
            Bg_Color = Color3.fromRGB(15, 15, 30),
            AccentColor = Color3.fromRGB(0, 255, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
            SecondaryTextColor = Color3.fromRGB(200, 200, 255),
            Button_Color = Color3.fromRGB(40, 40, 80),
            Toggle_On = Color3.fromRGB(0, 255, 255),
            SliderBar_Color = Color3.fromRGB(0, 255, 255),
        },
        ocean = {
            MainColor = Color3.fromRGB(10, 20, 40),
            TabColor = Color3.fromRGB(20, 40, 70),
            Bg_Color = Color3.fromRGB(15, 30, 55),
            AccentColor = Color3.fromRGB(0, 180, 255),
            TextColor = Color3.fromRGB(230, 240, 255),
            SecondaryTextColor = Color3.fromRGB(160, 200, 230),
            Button_Color = Color3.fromRGB(30, 60, 100),
            Toggle_On = Color3.fromRGB(0, 200, 255),
            SliderBar_Color = Color3.fromRGB(0, 180, 255),
        }
    },
    
    components = {},     -- 存储已注册的UI组件
    callbacks = {},      -- 颜色变化回调函数
    currentTheme = "default",
    
    -- 注册UI组件
    RegisterComponent = function(self, componentId, componentType, instance, properties)
        if not self.components[componentId] then
            self.components[componentId] = {}
        end
        
        local comp = {
            type = componentType,
            instance = instance,
            properties = properties or {},  -- 例如: {{property="BackgroundColor3", themeKey="Button_Color"}}
            originalColors = {},
            colorBindings = {}  -- 颜色绑定: {themeKey = property}
        }
        
        -- 保存原始颜色
        for _, prop in ipairs(properties or {}) do
            if instance[prop.property] then
                comp.originalColors[prop.property] = instance[prop.property]
            end
        end
        
        table.insert(self.components[componentId], comp)
        return comp
    end,
    
    -- 绑定颜色到主题键
    BindColor = function(self, componentId, themeKey, property)
        local comps = self.components[componentId]
        if not comps then return end
        
        for _, comp in ipairs(comps) do
            comp.colorBindings[themeKey] = property
            -- 立即应用当前主题颜色
            if self.themes[self.currentTheme][themeKey] then
                comp.instance[property] = self.themes[self.currentTheme][themeKey]
            end
        end
    end,
    
    -- 应用主题
    ApplyTheme = function(self, themeName)
        if not self.themes[themeName] then
            warn("主题不存在: " .. themeName)
            return false
        end
        
        self.currentTheme = themeName
        local theme = self.themes[themeName]
        
        -- 更新全局config
        for key, color in pairs(theme) do
            if config[key] ~= nil then
                config[key] = color
            end
        end
        
        -- 更新所有已注册组件
        for _, compList in pairs(self.components) do
            for _, comp in ipairs(compList) do
                for themeKey, property in pairs(comp.colorBindings) do
                    if theme[themeKey] and comp.instance[property] then
                        services.TweenService:Create(comp.instance, TweenInfo.new(0.3), {
                            [property] = theme[themeKey]
                        }):Play()
                    end
                end
            end
        end
        
        -- 执行回调
        for _, callback in pairs(self.callbacks) do
            pcall(callback, themeName, theme)
        end
        
        return true
    end,
    
    -- 自定义颜色
    SetCustomColor = function(self, themeKey, color)
        if not self.themes[self.currentTheme][themeKey] then
            -- 如果主题中不存在此键，则添加到当前主题
            self.themes[self.currentTheme][themeKey] = color
        else
            self.themes[self.currentTheme][themeKey] = color
        end
        
        -- 更新配置
        config[themeKey] = color
        
        -- 更新绑定此颜色的组件
        for _, compList in pairs(self.components) do
            for _, comp in ipairs(compList) do
                if comp.colorBindings[themeKey] then
                    local property = comp.colorBindings[themeKey]
                    services.TweenService:Create(comp.instance, TweenInfo.new(0.3), {
                        [property] = color
                    }):Play()
                end
            end
        end
        
        return color
    end,
    
    -- 创建新主题
    CreateTheme = function(self, themeName, baseTheme)
        if self.themes[themeName] then
            warn("主题已存在: " .. themeName)
            return false
        end
        
        self.themes[themeName] = {}
        local newTheme = self.themes[themeName]
        local base = self.themes[baseTheme or "default"]
        
        -- 复制基础主题
        for key, color in pairs(base) do
            newTheme[key] = color
        end
        
        return true
    end,
    
    -- 添加颜色变化回调
    AddCallback = function(self, id, callback)
        self.callbacks[id] = callback
    end,
    
    -- 移除回调
    RemoveCallback = function(self, id)
        self.callbacks[id] = nil
    end,
    
    -- 获取当前颜色
    GetColor = function(self, themeKey)
        return self.themes[self.currentTheme][themeKey] or config[themeKey]
    end,
    
    -- 导出主题
    ExportTheme = function(self, themeName)
        if not self.themes[themeName] then return nil end
        
        local export = {}
        for key, color in pairs(self.themes[themeName]) do
            export[key] = {
                R = math.floor(color.R * 255),
                G = math.floor(color.G * 255),
                B = math.floor(color.B * 255)
            }
        end
        
        return export
    end,
    
    -- 导入主题
    ImportTheme = function(self, themeName, themeData)
        self.themes[themeName] = {}
        
        for key, colorData in pairs(themeData) do
            self.themes[themeName][key] = Color3.fromRGB(
                colorData.R or 0,
                colorData.G or 0,
                colorData.B or 0
            )
        end
        
        return true
    end,
    
    -- 获取所有主题
    GetThemes = function(self)
        local themes = {}
        for name, _ in pairs(self.themes) do
            table.insert(themes, name)
        end
        return themes
    end
}

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

local function createSpaceBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "SpaceBackground"
    background.BackgroundColor3 = config.DeepSpaceColor
    background.BackgroundTransparency = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.ZIndex = -100
    
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 10)
    backgroundCorner.Parent = background
    
    background.Parent = parent
    
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
    
    return background
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
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 450, 0, 280)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

createSpaceBackground(Main)

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

local CardsContainer = Instance.new("Frame")
CardsContainer.Name = "CardsContainer"
CardsContainer.Parent = Main
CardsContainer.BackgroundTransparency = 1
CardsContainer.Position = UDim2.new(0, 0, 0, 35)
CardsContainer.Size = UDim2.new(1, 0, 1, -35)
CardsContainer.Visible = true

local CardsLayout = Instance.new("UIGridLayout")
CardsLayout.Parent = CardsContainer
CardsLayout.CellSize = UDim2.new(0, 100, 0, 100)
CardsLayout.CellPadding = UDim2.new(0, 5, 0, 5)
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
CardsLayout.StartCorner = Enum.StartCorner.TopLeft

local MainTabContainer = Instance.new("Frame")
MainTabContainer.Name = "MainTabContainer"
MainTabContainer.Parent = Main
MainTabContainer.BackgroundTransparency = 1
MainTabContainer.Position = UDim2.new(0.2, 0, 0, 37)
MainTabContainer.Size = UDim2.new(0, 360, 0, 243)
MainTabContainer.Visible = false

local MainSideContainer = Instance.new("Frame")
MainSideContainer.Name = "MainSideContainer"
MainSideContainer.Parent = Main
MainSideContainer.BackgroundTransparency = 1
MainSideContainer.Position = UDim2.new(0, 0, 0, 35)
MainSideContainer.Size = UDim2.new(0, 90, 1, -35)
MainSideContainer.Visible = false

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = MainSideContainer

createHologramEffect(MainSideContainer, 0.3)

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
ReturnToCardsButton.Text = "← 返回页面"
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

local function showCards()
    FengUI.showingCards = true
    CardsContainer.Visible = true
    MainSideContainer.Visible = false
    MainTabContainer.Visible = false
    
    if FengUI.currentTab then
        FengUI.currentTab[2].Visible = false
        FengUI.currentTab = nil
    end
    
    services.TweenService:Create(CardsContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(MainSideContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
end

ReturnToCardsButton.MouseButton1Click:Connect(function()
    DigitalParticleExplosion(ReturnToCardsButton)
    showCards()
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
        BackgroundTransparency = 1,
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
        BackgroundTransparency = 1
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
            BackgroundTransparency = 1
        }):Play()
    end
    
    task.wait(0.2)
    
    if not FengUI.showingCards then
        MainTabContainer.Visible = true
        MainSideContainer.Visible = true
    end
    
    DigitalParticleExplosion(Main)
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
    
    function window.card(window, name, description, icon)
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
        CardIcon.Size = UDim2.new(0, 40, 0, 40)
        CardIcon.Image = "rbxassetid://" .. tostring(icon or "84830962019412")
        CardIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        
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
        CardTitle.TextSize = 12
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
        CardDescription.TextSize = 10
        CardDescription.TextScaled = false
        CardDescription.TextWrapped = true
        
        local CardShadow = Instance.new("ImageLabel")
        CardShadow.Name = "CardShadow"
        CardShadow.Parent = Card
        CardShadow.BackgroundTransparency = 1
        CardShadow.Size = UDim2.new(1, 10, 1, 10)
        CardShadow.Position = UDim2.new(0, -5, 0, -5)
        CardShadow.Image = "rbxassetid://5554236805"
        CardShadow.ImageColor3 = Color3.new(0, 0, 0)
        CardShadow.ImageTransparency = 0.8
        CardShadow.ScaleType = Enum.ScaleType.Slice
        CardShadow.SliceCenter = Rect.new(23, 23, 277, 277)
        CardShadow.ZIndex = -1
        
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
        tabBtns.Position = UDim2.new(0, 0, 0, 25)
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
        
        FengUI.tabContainers[name] = {
            tabContainer = tabContainer,
            sideContainer = sideContainer,
            tabBtns = tabBtns
        }
        
        Card.MouseEnter:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.1,
                Size = UDim2.new(0, 105, 0, 105)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 3,
                Transparency = 0.4
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 45, 0, 45),
                Rotation = 5
            }):Play()
            services.TweenService:Create(CardShadow, TweenInfo.new(0.3), {
                ImageTransparency = 0.6,
                Size = UDim2.new(1, 15, 1, 15),
                Position = UDim2.new(0, -7, 0, -7)
            }):Play()
            
            services.TweenService:Create(Card, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, Card.Position.X.Offset, 0, Card.Position.Y.Offset - 3)
            }):Play()
            
            local pulseConnection
            pulseConnection = RunService.Heartbeat:Connect(function()
                if not CardIcon or not CardIcon.Parent then
                    pulseConnection:Disconnect()
                    return
                end
                CardIcon.ImageTransparency = 0.1 + math.sin(tick() * 8) * 0.1
            end)
            
            Card:SetAttribute("PulseConnection", pulseConnection)
        end)
        
        Card.MouseLeave:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.2,
                Size = UDim2.new(0, 100, 0, 100)
            }):Play()
            services.TweenService:Create(CardGlow, TweenInfo.new(0.3), {
                Thickness = 2,
                Transparency = 0.7
            }):Play()
            services.TweenService:Create(CardIcon, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 40, 0, 40),
                Rotation = 0,
                ImageTransparency = 0
            }):Play()
            services.TweenService:Create(CardShadow, TweenInfo.new(0.3), {
                ImageTransparency = 0.8,
                Size = UDim2.new(1, 10, 1, 10),
                Position = UDim2.new(0, -5, 0, -5)
            }):Play()
            
            services.TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            local pulseConnection = Card:GetAttribute("PulseConnection")
            if pulseConnection then
                pulseConnection:Disconnect()
            end
        end)
        
        local function showTabContainer()
            for _, containerData in pairs(FengUI.tabContainers) do
                containerData.tabContainer.Visible = false
                containerData.sideContainer.Visible = false
            end
            
            tabContainer.Visible = true
            sideContainer.Visible = true
            
            FengUI.showingCards = false
            CardsContainer.Visible = false
            MainTabContainer.Visible = true
            MainSideContainer.Visible = true
        end
        
        Card.MouseButton1Click:Connect(function()
            services.TweenService:Create(Card, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 95, 0, 95),
                BackgroundTransparency = 0.3
            }):Play()
            
            services.TweenService:Create(CardIcon, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 35, 0, 35)
            }):Play()
            
            task.wait(0.1)
            
            services.TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 105, 0, 105),
                BackgroundTransparency = 0.1
            }):Play()
            
            services.TweenService:Create(CardIcon, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 45, 0, 45)
            }):Play()
            
            DigitalParticleExplosion(Card)
            showTabContainer()
        end)
        
        local cardObj = {}
        
        function cardObj.Tab(cardObj, tabName, tabIcon)
            local TabIco = Instance.new("ImageLabel")
            TabIco.Name = "TabIco"
            TabIco.Parent = tabBtns
            TabIco.BackgroundTransparency = 1
            TabIco.BorderSizePixel = 0
            TabIco.Size = UDim2.new(0, 22, 0, 22)
            TabIco.Image = "rbxassetid://" .. tostring(tabIcon or "84830962019412")
            TabIco.ImageTransparency = 0.5
            
            startNeonFlowEffect(TabIco, "ImageColor3", 0.005)
            
            local TabText = Instance.new("TextLabel")
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
            
            local TabBtn = Instance.new("TextButton")
            TabBtn.Name = "TabBtn"
            TabBtn.Parent = TabIco
            TabBtn.BackgroundTransparency = 1
            TabBtn.BorderSizePixel = 0
            TabBtn.Size = UDim2.new(0, 90, 0, 22)
            TabBtn.AutoButtonColor = false
            TabBtn.Font = Enum.Font.SourceSans
            TabBtn.Text = ""
            
            local Tab = Instance.new("ScrollingFrame")
            Tab.Name = "Tab_" .. tabName
            Tab.Parent = tabContainer
            Tab.Active = true
            Tab.BackgroundTransparency = 1
            Tab.Size = UDim2.new(1, 0, 1, 0)
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
            
            TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
                
                Tab.ScrollingEnabled = TabL.AbsoluteContentSize.Y > Tab.AbsoluteSize.Y
                Tab.ElasticBehavior = Enum.ElasticBehavior.Never
            end)
            
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
                
                function section.Image(section, imageSource, sizeX, sizeY)
    local ImageModule = Instance.new("Frame")
    local ImageLabel = Instance.new("ImageLabel")
    local ImageCorner = Instance.new("UICorner")
    
    ImageModule.Name = "ImageModule"
    ImageModule.Parent = Objs
    ImageModule.BackgroundTransparency = 1
    ImageModule.BorderSizePixel = 0
    ImageModule.Size = UDim2.new(0, 330, 0, sizeY or 120)
    
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
                
                -- 高级调色板组件
                function section.ColorPicker(section, text, flag, default, callback, options)
                    callback = callback or function() end
                    options = options or {}
                    
                    assert(text, "No text provided")
                    assert(flag, "No flag provided")
                    default = default or config.AccentColor
                    
                    FengUI.flags[flag] = default
                    
                    local ColorPickerModule = Instance.new("Frame")
                    local ColorPickerBtn = Instance.new("TextButton")
                    local ColorPickerBtnC = Instance.new("UICorner")
                    local ColorPreview = Instance.new("Frame")
                    local ColorPreviewC = Instance.new("UICorner")
                    local ColorPreviewStroke = Instance.new("UIStroke")
                    local ColorValue = Instance.new("TextButton")
                    local ColorValueC = Instance.new("UICorner")
                    local ColorPickerL = Instance.new("UIListLayout")
                    local UIPadding = Instance.new("UIPadding")
                    
                    ColorPickerModule.Name = "ColorPickerModule"
                    ColorPickerModule.Parent = Objs
                    ColorPickerModule.BackgroundTransparency = 1
                    ColorPickerModule.BorderSizePixel = 0
                    ColorPickerModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    ColorPickerBtn.Name = "ColorPickerBtn"
                    ColorPickerBtn.Parent = ColorPickerModule
                    ColorPickerBtn.BackgroundColor3 = config.Button_Color
                    ColorPickerBtn.BackgroundTransparency = 0.2
                    ColorPickerBtn.BorderSizePixel = 0
                    ColorPickerBtn.Size = UDim2.new(0, 330, 0, 36)
                    ColorPickerBtn.AutoButtonColor = false
                    ColorPickerBtn.Font = Enum.Font.GothamSemibold
                    ColorPickerBtn.Text = "   " .. text
                    ColorPickerBtn.TextColor3 = config.TextColor
                    ColorPickerBtn.TextSize = 14
                    ColorPickerBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    ColorPickerBtnC.CornerRadius = UDim.new(0, 6)
                    ColorPickerBtnC.Name = "ColorPickerBtnC"
                    ColorPickerBtnC.Parent = ColorPickerBtn
                    
                    ColorPreview.Name = "ColorPreview"
                    ColorPreview.Parent = ColorPickerBtn
                    ColorPreview.BackgroundColor3 = default
                    ColorPreview.BorderSizePixel = 0
                    ColorPreview.Position = UDim2.new(0.72, 0, 0.22, 0)
                    ColorPreview.Size = UDim2.new(0, 70, 0, 22)
                    
                    ColorPreviewC.CornerRadius = UDim.new(0, 6)
                    ColorPreviewC.Name = "ColorPreviewC"
                    ColorPreviewC.Parent = ColorPreview
                    
                    ColorPreviewStroke.Parent = ColorPreview
                    ColorPreviewStroke.Color = config.TextColor
                    ColorPreviewStroke.Thickness = 1
                    ColorPreviewStroke.Transparency = 0.3
                    
                    ColorValue.Name = "ColorValue"
                    ColorValue.Parent = ColorPreview
                    ColorValue.BackgroundTransparency = 1
                    ColorValue.BorderSizePixel = 0
                    ColorValue.Size = UDim2.new(1, 0, 1, 0)
                    ColorValue.AutoButtonColor = false
                    ColorValue.Font = Enum.Font.Gotham
                    ColorValue.Text = string.format("#%02X%02X%02X", 
                        math.floor(default.R * 255),
                        math.floor(default.G * 255),
                        math.floor(default.B * 255)
                    )
                    ColorValue.TextColor3 = Color3.fromRGB(
                        default.R * 255 > 127 and 0 or 255,
                        default.G * 255 > 127 and 0 or 255,
                        default.B * 255 > 127 and 0 or 255
                    )
                    ColorValue.TextSize = 12
                    
                    ColorValueC.CornerRadius = UDim.new(0, 6)
                    ColorValueC.Name = "ColorValueC"
                    ColorValueC.Parent = ColorValue
                    
                    ColorPickerL.Name = "ColorPickerL"
                    ColorPickerL.Parent = ColorPickerBtn
                    ColorPickerL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    ColorPickerL.SortOrder = Enum.SortOrder.LayoutOrder
                    ColorPickerL.VerticalAlignment = Enum.VerticalAlignment.Center
                    
                    UIPadding.Parent = ColorPickerBtn
                    UIPadding.PaddingRight = UDim.new(0, 6)
                    
                    -- 交互效果
                    ColorPickerBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.Button_Color.R * 255 * 1.1),
                                math.floor(config.Button_Color.G * 255 * 1.1),
                                math.floor(config.Button_Color.B * 255 * 1.1)
                            )
                        }):Play()
                        services.TweenService:Create(ColorPreviewStroke, TweenInfo.new(0.2), {
                            Thickness = 2,
                            Transparency = 0
                        }):Play()
                    end)
                    
                    ColorPickerBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                            BackgroundColor3 = config.Button_Color
                        }):Play()
                        services.TweenService:Create(ColorPreviewStroke, TweenInfo.new(0.2), {
                            Thickness = 1,
                            Transparency = 0.3
                        }):Play()
                    end)
                    
                    -- 高级调色板窗口
                    local colorPickerWindow = nil
                    local function createColorPickerWindow()
                        if colorPickerWindow and colorPickerWindow.Parent then
                            colorPickerWindow:Destroy()
                            colorPickerWindow = nil
                            return
                        end
                        
                        -- 创建调色板窗口
                        colorPickerWindow = Instance.new("Frame")
                        colorPickerWindow.Name = "ColorPickerWindow"
                        colorPickerWindow.Parent = ColorPickerBtn
                        colorPickerWindow.BackgroundColor3 = config.MainColor
                        colorPickerWindow.BackgroundTransparency = 0.1
                        colorPickerWindow.BorderSizePixel = 0
                        colorPickerWindow.Position = UDim2.new(0, 0, 1, 5)
                        colorPickerWindow.Size = UDim2.new(0, 250, 0, 320)
                        colorPickerWindow.ZIndex = 100
                        colorPickerWindow.Visible = false
                        
                        local windowCorner = Instance.new("UICorner")
                        windowCorner.CornerRadius = UDim.new(0, 8)
                        windowCorner.Parent = colorPickerWindow
                        
                        local windowStroke = Instance.new("UIStroke")
                        windowStroke.Parent = colorPickerWindow
                        windowStroke.Color = config.AccentColor
                        windowStroke.Thickness = 1
                        windowStroke.Transparency = 0.3
                        
                        -- 颜色预览区域
                        local previewFrame = Instance.new("Frame")
                        previewFrame.Name = "PreviewFrame"
                        previewFrame.Parent = colorPickerWindow
                        previewFrame.BackgroundColor3 = default
                        previewFrame.BackgroundTransparency = 0
                        previewFrame.Position = UDim2.new(0, 10, 0, 10)
                        previewFrame.Size = UDim2.new(1, -20, 0, 40)
                        
                        local previewCorner = Instance.new("UICorner")
                        previewCorner.CornerRadius = UDim.new(0, 6)
                        previewCorner.Parent = previewFrame
                        
                        local previewStroke = Instance.new("UIStroke")
                        previewStroke.Parent = previewFrame
                        previewStroke.Color = Color3.new(0, 0, 0)
                        previewStroke.Thickness = 1
                        
                        -- 颜色区域（色调和饱和度）
                        local colorArea = Instance.new("ImageButton")
                        colorArea.Name = "ColorArea"
                        colorArea.Parent = colorPickerWindow
                        colorArea.BackgroundColor3 = Color3.new(1, 1, 1)
                        colorArea.BorderSizePixel = 0
                        colorArea.Position = UDim2.new(0, 10, 0, 60)
                        colorArea.Size = UDim2.new(1, -20, 0, 120)
                        colorArea.AutoButtonColor = false
                        
                        local colorAreaCorner = Instance.new("UICorner")
                        colorAreaCorner.CornerRadius = UDim.new(0, 6)
                        colorAreaCorner.Parent = colorArea
                        
                        -- 创建颜色渐变
                        local hueGradient = Instance.new("UIGradient")
                        hueGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }
                        hueGradient.Rotation = 0
                        hueGradient.Parent = colorArea
                        
                        -- 色调滑块
                        local hueSlider = Instance.new("Frame")
                        hueSlider.Name = "HueSlider"
                        hueSlider.Parent = colorPickerWindow
                        hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                        hueSlider.BorderSizePixel = 0
                        hueSlider.Position = UDim2.new(0, 10, 0, 190)
                        hueSlider.Size = UDim2.new(1, -20, 0, 20)
                        
                        local hueSliderCorner = Instance.new("UICorner")
                        hueSliderCorner.CornerRadius = UDim.new(0, 4)
                        hueSliderCorner.Parent = hueSlider
                        
                        local hueGradient2 = Instance.new("UIGradient")
                        hueGradient2.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        }
                        hueGradient2.Parent = hueSlider
                        
                        -- RGB输入
                        local rgbFrame = Instance.new("Frame")
                        rgbFrame.Name = "RGBFrame"
                        rgbFrame.Parent = colorPickerWindow
                        rgbFrame.BackgroundTransparency = 1
                        rgbFrame.Position = UDim2.new(0, 10, 0, 220)
                        rgbFrame.Size = UDim2.new(1, -20, 0, 80)
                        
                        local rgbLayout = Instance.new("UIGridLayout")
                        rgbLayout.Parent = rgbFrame
                        rgbLayout.CellSize = UDim2.new(0.32, 0, 0, 30)
                        rgbLayout.CellPadding = UDim2.new(0, 5, 0, 5)
                        
                        local r, g, b = math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)
                        
                        local function createRGBInput(label, value, color)
                            local frame = Instance.new("Frame")
                            frame.BackgroundTransparency = 1
                            frame.Size = UDim2.new(1, 0, 0, 30)
                            
                            local labelText = Instance.new("TextLabel")
                            labelText.Text = label
                            labelText.TextColor3 = config.TextColor
                            labelText.TextSize = 12
                            labelText.BackgroundTransparency = 1
                            labelText.Size = UDim2.new(0, 15, 1, 0)
                            labelText.Parent = frame
                            
                            local textBox = Instance.new("TextBox")
                            textBox.Text = tostring(value)
                            textBox.TextColor3 = config.TextColor
                            textBox.BackgroundColor3 = config.Textbox_Color
                            textBox.BackgroundTransparency = 0.2
                            textBox.Size = UDim2.new(1, -20, 1, 0)
                            textBox.Position = UDim2.new(0, 15, 0, 0)
                            textBox.Parent = frame
                            
                            local corner = Instance.new("UICorner")
                            corner.CornerRadius = UDim.new(0, 4)
                            corner.Parent = textBox
                            
                            textBox.FocusLost:Connect(function()
                                local num = tonumber(textBox.Text)
                                if num then
                                    num = math.clamp(num, 0, 255)
                                    textBox.Text = tostring(num)
                                    -- 更新颜色
                                    local currentColor = previewFrame.BackgroundColor3
                                    if label == "R" then
                                        previewFrame.BackgroundColor3 = Color3.fromRGB(num, currentColor.G * 255, currentColor.B * 255)
                                    elseif label == "G" then
                                        previewFrame.BackgroundColor3 = Color3.fromRGB(currentColor.R * 255, num, currentColor.B * 255)
                                    elseif label == "B" then
                                        previewFrame.BackgroundColor3 = Color3.fromRGB(currentColor.R * 255, currentColor.G * 255, num)
                                    end
                                end
                            end)
                            
                            return frame, textBox
                        end
                        
                        local rFrame, rBox = createRGBInput("R", r, Color3.fromRGB(255, 50, 50))
                        local gFrame, gBox = createRGBInput("G", g, Color3.fromRGB(50, 255, 50))
                        local bFrame, bBox = createRGBInput("B", b, Color3.fromRGB(50, 50, 255))
                        
                        rFrame.Parent = rgbFrame
                        gFrame.Parent = rgbFrame
                        bFrame.Parent = rgbFrame
                        
                        -- 按钮区域
                        local buttonFrame = Instance.new("Frame")
                        buttonFrame.Name = "ButtonFrame"
                        buttonFrame.Parent = colorPickerWindow
                        buttonFrame.BackgroundTransparency = 1
                        buttonFrame.Position = UDim2.new(0, 10, 0, 300)
                        buttonFrame.Size = UDim2.new(1, -20, 0, 30)
                        
                        local applyBtn = Instance.new("TextButton")
                        applyBtn.Name = "ApplyBtn"
                        applyBtn.Parent = buttonFrame
                        applyBtn.BackgroundColor3 = config.Button_Color
                        applyBtn.BackgroundTransparency = 0.2
                        applyBtn.Size = UDim2.new(0.48, 0, 1, 0)
                        applyBtn.Text = "应用"
                        applyBtn.TextColor3 = config.TextColor
                        applyBtn.Font = Enum.Font.GothamSemibold
                        applyBtn.TextSize = 14
                        
                        local applyCorner = Instance.new("UICorner")
                        applyCorner.CornerRadius = UDim.new(0, 6)
                        applyCorner.Parent = applyBtn
                        
                        local cancelBtn = Instance.new("TextButton")
                        cancelBtn.Name = "CancelBtn"
                        cancelBtn.Parent = buttonFrame
                        cancelBtn.BackgroundColor3 = config.Button_Color
                        cancelBtn.BackgroundTransparency = 0.2
                        cancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
                        cancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
                        cancelBtn.Text = "取消"
                        cancelBtn.TextColor3 = config.TextColor
                        cancelBtn.Font = Enum.Font.GothamSemibold
                        cancelBtn.TextSize = 14
                        
                        local cancelCorner = Instance.new("UICorner")
                        cancelCorner.CornerRadius = UDim.new(0, 6)
                        cancelCorner.Parent = cancelBtn
                        
                        -- 按钮交互
                        applyBtn.MouseButton1Click:Connect(function()
                            local color = previewFrame.BackgroundColor3
                            ColorPreview.BackgroundColor3 = color
                            ColorValue.Text = string.format("#%02X%02X%02X", 
                                math.floor(color.R * 255),
                                math.floor(color.G * 255),
                                math.floor(color.B * 255)
                            )
                            ColorValue.TextColor3 = Color3.fromRGB(
                                color.R * 255 > 127 and 0 or 255,
                                color.G * 255 > 127 and 0 or 255,
                                color.B * 255 > 127 and 0 or 255
                            )
                            
                            FengUI.flags[flag] = color
                            callback(color)
                            
                            -- 如果设置了主题键，更新主题
                            if options.themeKey then
                                FengUI.ColorManager:SetCustomColor(options.themeKey, color)
                            end
                            
                            colorPickerWindow:Destroy()
                            colorPickerWindow = nil
                        end)
                        
                        cancelBtn.MouseButton1Click:Connect(function()
                            colorPickerWindow:Destroy()
                            colorPickerWindow = nil
                        end)
                        
                        -- 初始显示
                        colorPickerWindow.Visible = true
                        services.TweenService:Create(colorPickerWindow, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, 250, 0, 320),
                            BackgroundTransparency = 0
                        }):Play()
                    end
                    
                    ColorPickerBtn.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(ColorPickerBtn)
                        createColorPickerWindow()
                    end)
                    
                    -- 返回对象
                    local colorPickerObj = {}
                    
                    function colorPickerObj:SetColor(color)
                        ColorPreview.BackgroundColor3 = color
                        ColorValue.Text = string.format("#%02X%02X%02X", 
                            math.floor(color.R * 255),
                            math.floor(color.G * 255),
                            math.floor(color.B * 255)
                        )
                        ColorValue.TextColor3 = Color3.fromRGB(
                            color.R * 255 > 127 and 0 or 255,
                            color.G * 255 > 127 and 0 or 255,
                            color.B * 255 > 127 and 0 or 255
                        )
                        
                        FengUI.flags[flag] = color
                        callback(color)
                    end
                    
                    function colorPickerObj:GetColor()
                        return FengUI.flags[flag] or default
                    end
                    
                    function colorPickerObj:Destroy()
                        ColorPickerModule:Destroy()
                    end
                    
                    return colorPickerObj
                end
                
                -- 主题切换器组件
                function section.ThemeSwitcher(section, text, includeCustom)
                    local ThemeModule = Instance.new("Frame")
                    local ThemeBtn = Instance.new("TextButton")
                    local ThemeBtnC = Instance.new("UICorner")
                    local ThemeValue = Instance.new("TextButton")
                    local ThemeValueC = Instance.new("UICorner")
                    
                    ThemeModule.Name = "ThemeModule"
                    ThemeModule.Parent = Objs
                    ThemeModule.BackgroundTransparency = 1
                    ThemeModule.BorderSizePixel = 0
                    ThemeModule.Size = UDim2.new(0, 330, 0, 36)
                    
                    ThemeBtn.Name = "ThemeBtn"
                    ThemeBtn.Parent = ThemeModule
                    ThemeBtn.BackgroundColor3 = config.Button_Color
                    ThemeBtn.BackgroundTransparency = 0.2
                    ThemeBtn.BorderSizePixel = 0
                    ThemeBtn.Size = UDim2.new(0, 330, 0, 36)
                    ThemeBtn.AutoButtonColor = false
                    ThemeBtn.Font = Enum.Font.GothamSemibold
                    ThemeBtn.Text = "   " .. text
                    ThemeBtn.TextColor3 = config.TextColor
                    ThemeBtn.TextSize = 14
                    ThemeBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    ThemeBtnC.CornerRadius = UDim.new(0, 6)
                    ThemeBtnC.Name = "ThemeBtnC"
                    ThemeBtnC.Parent = ThemeBtn
                    
                    ThemeValue.Name = "ThemeValue"
                    ThemeValue.Parent = ThemeBtn
                    ThemeValue.BackgroundColor3 = config.Bg_Color
                    ThemeValue.BorderSizePixel = 0
                    ThemeValue.Position = UDim2.new(0.72, 0, 0.22, 0)
                    ThemeValue.Size = UDim2.new(0, 70, 0, 22)
                    ThemeValue.AutoButtonColor = false
                    ThemeValue.Font = Enum.Font.Gotham
                    ThemeValue.Text = FengUI.ColorManager.currentTheme
                    ThemeValue.TextColor3 = config.TextColor
                    ThemeValue.TextSize = 12
                    
                    ThemeValueC.CornerRadius = UDim.new(0, 6)
                    ThemeValueC.Name = "ThemeValueC"
                    ThemeValueC.Parent = ThemeValue
                    
                    -- 主题下拉菜单
                    local themeDropdown = nil
                    local function toggleThemeDropdown()
                        if themeDropdown and themeDropdown.Parent then
                            themeDropdown:Destroy()
                            themeDropdown = nil
                            return
                        end
                        
                        themeDropdown = Instance.new("Frame")
                        themeDropdown.Name = "ThemeDropdown"
                        themeDropdown.Parent = ThemeBtn
                        themeDropdown.BackgroundColor3 = config.MainColor
                        themeDropdown.BackgroundTransparency = 0.1
                        themeDropdown.BorderSizePixel = 0
                        themeDropdown.Position = UDim2.new(0.72, 0, 1, 5)
                        themeDropdown.Size = UDim2.new(0, 120, 0, 30)
                        themeDropdown.ZIndex = 100
                        themeDropdown.ClipsDescendants = true
                        
                        local dropdownCorner = Instance.new("UICorner")
                        dropdownCorner.CornerRadius = UDim.new(0, 6)
                        dropdownCorner.Parent = themeDropdown
                        
                        local dropdownStroke = Instance.new("UIStroke")
                        dropdownStroke.Parent = themeDropdown
                        dropdownStroke.Color = config.AccentColor
                        dropdownStroke.Thickness = 1
                        
                        local themesList = Instance.new("ScrollingFrame")
                        themesList.Name = "ThemesList"
                        themesList.Parent = themeDropdown
                        themesList.BackgroundTransparency = 1
                        themesList.Size = UDim2.new(1, 0, 1, 0)
                        themesList.CanvasSize = UDim2.new(0, 0, 0, 0)
                        themesList.ScrollBarThickness = 2
                        
                        local listLayout = Instance.new("UIListLayout")
                        listLayout.Parent = themesList
                        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        
                        -- 获取所有主题
                        local themes = FengUI.ColorManager:GetThemes()
                        local totalHeight = 0
                        
                        for _, themeName in ipairs(themes) do
                            if includeCustom or themeName ~= "custom" then
                                local themeBtn = Instance.new("TextButton")
                                themeBtn.Name = "Theme_" .. themeName
                                themeBtn.Parent = themesList
                                themeBtn.BackgroundColor3 = config.Button_Color
                                themeBtn.BackgroundTransparency = 0.2
                                themeBtn.Size = UDim2.new(1, -10, 0, 28)
                                themeBtn.Position = UDim2.new(0, 5, 0, totalHeight)
                                themeBtn.Text = themeName
                                themeBtn.TextColor3 = config.TextColor
                                themeBtn.Font = Enum.Font.Gotham
                                themeBtn.TextSize = 12
                                
                                local btnCorner = Instance.new("UICorner")
                                btnCorner.CornerRadius = UDim.new(0, 4)
                                btnCorner.Parent = themeBtn
                                
                                themeBtn.MouseButton1Click:Connect(function()
                                    FengUI.ColorManager:ApplyTheme(themeName)
                                    ThemeValue.Text = themeName
                                    themeDropdown:Destroy()
                                    themeDropdown = nil
                                    DigitalParticleExplosion(themeBtn)
                                end)
                                
                                totalHeight = totalHeight + 30
                            end
                        end
                        
                        themesList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                        themeDropdown.Size = UDim2.new(0, 120, 0, math.min(totalHeight + 10, 150))
                        
                        -- 点击外部关闭
                        local connection
                        connection = services.UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local mousePos = services.UserInputService:GetMouseLocation()
                                local dropdownPos = themeDropdown.AbsolutePosition
                                local dropdownSize = themeDropdown.AbsoluteSize
                                
                                if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                                       mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) then
                                    themeDropdown:Destroy()
                                    themeDropdown = nil
                                    connection:Disconnect()
                                end
                            end
                        end)
                    end
                    
                    ThemeValue.MouseButton1Click:Connect(function()
                        DigitalParticleExplosion(ThemeValue)
                        toggleThemeDropdown()
                    end)
                    
                    -- 监听主题变化
                    FengUI.ColorManager:AddCallback("ThemeSwitcher_" .. text, function(themeName)
                        ThemeValue.Text = themeName
                    end)
                    
                    return {
                        SetTheme = function(self, themeName)
                            FengUI.ColorManager:ApplyTheme(themeName)
                        end,
                        
                        GetCurrentTheme = function(self)
                            return FengUI.ColorManager.currentTheme
                        end,
                        
                        AddTheme = function(self, themeName, baseTheme)
                            return FengUI.ColorManager:CreateTheme(themeName, baseTheme)
                        end,
                        
                        Destroy = function(self)
                            ThemeModule:Destroy()
                            FengUI.ColorManager:RemoveCallback("ThemeSwitcher_" .. text)
                        end
                    }
                end
                
                -- UI组件颜色绑定助手函数
                function section.BindToTheme(section, uiComponent, componentId, themeBindings)
                    -- uiComponent: UI元素实例
                    -- componentId: 组件标识符
                    -- themeBindings: {{property="BackgroundColor3", themeKey="Button_Color"}, ...}
                    
                    local properties = {}
                    for _, binding in ipairs(themeBindings) do
                        table.insert(properties, {
                            property = binding.property,
                            themeKey = binding.themeKey
                        })
                    end
                    
                    -- 注册到颜色管理器
                    local comp = FengUI.ColorManager:RegisterComponent(componentId, "UIElement", uiComponent, properties)
                    
                    -- 绑定颜色
                    for _, binding in ipairs(themeBindings) do
                        FengUI.ColorManager:BindColor(componentId, binding.themeKey, binding.property)
                    end
                    
                    return {
                        UpdateBinding = function(self, newBindings)
                            -- 更新绑定
                            for _, binding in ipairs(newBindings) do
                                FengUI.ColorManager:BindColor(componentId, binding.themeKey, binding.property)
                            end
                        end,
                        
                        RemoveBinding = function(self)
                            -- 移除绑定（简化实现）
                            FengUI.ColorManager.components[componentId] = nil
                        end
                    }
                end
                
                return section
            end
            
            return tabObj
        end
        
        return cardObj
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