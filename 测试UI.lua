local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Fenglib = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local RainbowSpeed = 1.0
local Registry = {} 
local ConfigObjects = {} 
local ThemeListeners = {}

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
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
        local r = math.sin(hue * 3 + 0) * 0.3 + 0.7
        local g = math.sin(hue * 3 + 2) * 0.1
        local b = math.sin(hue * 3 + 4) * 0.1
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createPulseGlow(object)
    local connection
    local isRunning = true
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent or not isRunning then
            if connection then
                connection:Disconnect()
            end
            return
        end
        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return {
        Disconnect = function()
            isRunning = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        IsRunning = function()
            return isRunning and object and object.Parent
        end
    }
end

local Themes = {
    Dark   = {Main = Color3.fromRGB(13, 13, 13), Top = Color3.fromRGB(28, 28, 30), Text = Color3.fromRGB(240, 240, 245), Accent = Color3.fromRGB(80, 140, 255), Stroke = Color3.fromRGB(45, 45, 48)},
    White  = {Main = Color3.fromRGB(243, 243, 243), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(20, 20, 20), Accent = Color3.fromRGB(0, 100, 210), Stroke = Color3.fromRGB(220, 220, 225)},
    Purple = {Main = Color3.fromRGB(18, 15, 22), Top = Color3.fromRGB(30, 25, 35), Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255), Stroke = Color3.fromRGB(50, 45, 60)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28), Top = Color3.fromRGB(25, 32, 45), Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255), Stroke = Color3.fromRGB(45, 55, 75)},
    Red    = {Main = Color3.fromRGB(22, 12, 12), Top = Color3.fromRGB(35, 20, 20), Text = Color3.fromRGB(255, 240, 240), Accent = Color3.fromRGB(255, 80, 80), Stroke = Color3.fromRGB(60, 40, 40)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12), Top = Color3.fromRGB(35, 35, 20), Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80), Stroke = Color3.fromRGB(60, 60, 40)},
    Green  = {Main = Color3.fromRGB(12, 22, 15), Top = Color3.fromRGB(20, 35, 25), Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130), Stroke = Color3.fromRGB(40, 60, 50)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeKey)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeKey})
    obj[prop] = CurrentTheme[themeKey]
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function Fenglib:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, r in pairs(Registry) do
            if r.Object then
                Tween(r.Object, {[r.Property] = CurrentTheme[r.Type]})
            end
        end
        for _, fn in pairs(ThemeListeners) do
            pcall(fn)
        end
    end
end

function Fenglib:ToggleRainbow(bool) RainbowEnabled = bool end
function Fenglib:SetRainbowType(val) RainbowType = val end
function Fenglib:SetRainbowSpeed(val) RainbowSpeed = clamp(tonumber(val) or 1, 0.1, 10) end

function Fenglib:SaveConfig(configName, configFolder)
    local ok, err = pcall(function()
        if not isfolder(configFolder) then makefolder(configFolder) end
        local data = {}
        for flag, obj in pairs(ConfigObjects) do
            if obj and obj.Value ~= nil then
                data[flag] = obj.Value
            end
        end
        local json = HttpService:JSONEncode(data)
        writefile(configFolder .. "/" .. configName .. ".json", json)
    end)
    if not ok then
        warn("SaveConfig error:", err)
    end
    return ok
end

function Fenglib:LoadConfig(path)
    if not pcall(isfile, path) then return false end
    local exists = false
    pcall(function() exists = isfile(path) end)
    if not exists then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    Fenglib._loading = true
    for flag, val in pairs(data) do
        if ConfigObjects[flag] and ConfigObjects[flag].Set then
            pcall(function() ConfigObjects[flag].Set(val) end)
        end
    end
    Fenglib._loading = false

    return true
end

function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "FengY3"
    local Subtitle = Config.Subtitle
    local Keybind = Config.Keybind 
    local IconAsset = Config.Icon  
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"
    Window.CurrentConfig = ""

    if Config.Theme then
        if type(Config.Theme) == "string" then
            if Themes[Config.Theme] then
                CurrentTheme = Themes[Config.Theme]
            end
        elseif type(Config.Theme) == "table" then
            local t = Config.Theme
            local function toC3(v)
                if type(v) == "table" then return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
                elseif type(v) == "userdata" then return v
                else return Color3.new(0,0,0) end
            end
            local customTheme = {
                Main   = t.Main   and toC3(t.Main)   or CurrentTheme.Main,
                Top    = t.Top    and toC3(t.Top)    or CurrentTheme.Top,
                Text   = t.Text   and toC3(t.Text)   or CurrentTheme.Text,
                Accent = t.Accent and toC3(t.Accent) or CurrentTheme.Accent,
                Stroke = t.Stroke and toC3(t.Stroke) or CurrentTheme.Stroke,
            }
            local customName = t.Name or "Custom"
            Themes[customName] = customTheme
            CurrentTheme = customTheme
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FengYu-Bento"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 300, 0, 0)
    NotificationHolder.AutomaticSize = Enum.AutomaticSize.Y
    NotificationHolder.Position = UDim2.new(1, -20, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.BorderSizePixel = 0
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 100

    local HolderList = Instance.new("UIListLayout")
    HolderList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    HolderList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HolderList.SortOrder = Enum.SortOrder.LayoutOrder
    HolderList.Padding = UDim.new(0, 5)
    HolderList.Parent = NotificationHolder

    local HolderPadding = Instance.new("UIPadding")
    HolderPadding.PaddingRight = UDim.new(0, 5)
    HolderPadding.PaddingBottom = UDim.new(0, 5)
    HolderPadding.Parent = NotificationHolder

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0) 
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = false
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Stroke")

    local Gradient = Instance.new("UIGradient")
    Gradient.Parent = Stroke
    Gradient.Enabled = false

    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick() * RainbowSpeed
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Gradient.Enabled = true; Gradient.Rotation = 0
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})
                    Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Animated/Cycling Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Gradient.Enabled = true; rot = rot + 2; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Step/Band Rainbow" then
                    Gradient.Enabled = false; local step = math.floor((t % 2) * 4) / 4; Stroke.Color = Color3.fromHSV(step, 1, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    Gradient.Enabled = false; local pulse = (math.sin(t * 3) + 1) / 2; Stroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
                elseif RainbowType == "Radial Rainbow" then
                    Gradient.Enabled = true; rot = rot + 5; Gradient.Rotation = rot
                    Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))}); Stroke.Color = Color3.new(1,1,1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.8, 1) 
                elseif RainbowType == "Pastel Rainbow" then
                    Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.4, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                    Gradient.Enabled = true; Gradient.Rotation = 90; local c = Color3.fromHSV(t % 5/5, 1, 1); local c2 = Color3.fromHSV((t+1) % 5/5, 1, 1); Gradient.Color = ColorSequence.new(c, c2); Stroke.Color = Color3.new(1,1,1)
                end
            else
                Gradient.Enabled = false
                Stroke.Color = CurrentTheme.Stroke
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local topbarHeight = Subtitle and 45 or 40

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, topbarHeight)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    if IconAsset then
        if tonumber(IconAsset) then
            IconAsset = "rbxassetid://" .. IconAsset
        end
    else
        IconAsset = "rbxassetid://78229538488090"  
    end

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "WindowIcon"
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 10, 0.5, -16)  
    Icon.BackgroundTransparency = 1
    Icon.Image = IconAsset
    Icon.Parent = Topbar
    AddToRegistry(Icon, "ImageColor3", "Text")

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 8)
    iconCorner.Parent = Icon

    local ButtonGroup = Instance.new("Frame")
    ButtonGroup.Name = "WindowButtons"
    ButtonGroup.Size = UDim2.new(0, 180, 1, 0)
    ButtonGroup.Position = UDim2.new(1, -190, 0, 0)
    ButtonGroup.BackgroundTransparency = 1
    ButtonGroup.Parent = Topbar

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 5)
    ButtonLayout.Parent = ButtonGroup

    local ButtonPadding = Instance.new("UIPadding")
    ButtonPadding.PaddingRight = UDim.new(0, 10)
    ButtonPadding.Parent = ButtonGroup

    local function NewRoundFrame(radius, imageType, properties, children)
        local frame = Instance.new("ImageLabel")
        frame.BackgroundTransparency = 1
        frame.Image = imageType == "Squircle" and "rbxassetid://80999662900595" or
                      imageType == "SquircleOutline" and "rbxassetid://117788349049947" or
                      imageType == "SquircleOutline2" and "rbxassetid://117817408534198" or
                      "rbxassetid://80999662900595"
        frame.ScaleType = Enum.ScaleType.Slice
        frame.SliceCenter = Rect.new(256, 256, 256, 256)
        frame.SliceScale = radius / 256
        for prop, val in pairs(properties or {}) do
            frame[prop] = val
        end
        for _, child in ipairs(children or {}) do
            child.Parent = frame
        end
        return frame
    end

    local function createTextButton(textSymbol, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 36, 0, 36)
        btn.Text = textSymbol
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.BackgroundTransparency = 1
        btn.Parent = ButtonGroup

        local bg = NewRoundFrame(9, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.95,
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = btn
        })

        local outline = NewRoundFrame(9, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = btn
        })
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 45
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255))
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.1),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1.0, 0.1)
        })
        gradient.Parent = outline

        local function onHover()
            Tween(bg, {ImageTransparency = 0.8}, 0.2)
            Tween(outline, {ImageTransparency = 0.75}, 0.2)
        end
        local function onLeave()
            Tween(bg, {ImageTransparency = 0.95}, 0.2)
            Tween(outline, {ImageTransparency = 1}, 0.2)
        end

        btn.MouseEnter:Connect(onHover)
        btn.MouseLeave:Connect(onLeave)
        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    local function createIconButton(iconAsset, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 36, 0, 36)
        btn.Text = ""
        btn.BackgroundTransparency = 1
        btn.Parent = ButtonGroup

        local bg = NewRoundFrame(9, "Squircle", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 0.95,
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = btn
        })

        local outline = NewRoundFrame(9, "SquircleOutline", {
            Size = UDim2.new(1, 0, 1, 0),
            ImageTransparency = 1,
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = btn
        })
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 45
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255))
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.1),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1.0, 0.1)
        })
        gradient.Parent = outline

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = iconAsset
        icon.ImageColor3 = Color3.new(1, 1, 1)
        icon.Parent = btn

        local function onHover()
            Tween(bg, {ImageTransparency = 0.8}, 0.2)
            Tween(outline, {ImageTransparency = 0.75}, 0.2)
        end
        local function onLeave()
            Tween(bg, {ImageTransparency = 0.95}, 0.2)
            Tween(outline, {ImageTransparency = 1}, 0.2)
        end

        btn.MouseEnter:Connect(onHover)
        btn.MouseLeave:Connect(onLeave)
        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    if Subtitle then
        TitleLabel.Size = UDim2.new(1, -180, 0, 20)   
        TitleLabel.Position = UDim2.new(0, 50, 0, 5)

        local SubtitleLabel = Instance.new("TextLabel")
        SubtitleLabel.Text = Subtitle
        SubtitleLabel.Size = UDim2.new(1, -180, 0, 15)
        SubtitleLabel.Position = UDim2.new(0, 50, 0, 25)
        SubtitleLabel.BackgroundTransparency = 1
        SubtitleLabel.Font = Enum.Font.GothamMedium
        SubtitleLabel.TextSize = 12
        SubtitleLabel.TextTransparency = 0.4
        SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubtitleLabel.Parent = Topbar
        AddToRegistry(SubtitleLabel, "TextColor3", "Text")
    else
        TitleLabel.Size = UDim2.new(1, -180, 1, 0)
        TitleLabel.Position = UDim2.new(0, 50, 0, 0)
    end

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -(topbarHeight + 15))
    Content.Position = UDim2.new(0, 10, 0, topbarHeight + 5)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 0.85, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 140, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -40)
    ProfileFrame.BackgroundTransparency = 0.05
    ProfileFrame.Parent = Content
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 10)
    AddToRegistry(ProfileFrame, "BackgroundColor3", "Top")
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 26, 0, 26)
    Avatar.Position = UDim2.new(0, 8, 0.5, -13)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
    
    local DispName = Instance.new("TextLabel")
    DispName.Text = LocalPlayer.DisplayName
    DispName.Size = UDim2.new(1, -45, 0, 15)
    DispName.Position = UDim2.new(0, 40, 0, 5)
    DispName.BackgroundTransparency = 1
    DispName.Font = Enum.Font.GothamMedium
    DispName.TextSize = 11
    DispName.TextXAlignment = Enum.TextXAlignment.Left
    DispName.Parent = ProfileFrame
    AddToRegistry(DispName, "TextColor3", "Text")

    local UsrName = Instance.new("TextLabel")
    UsrName.Text = "@"..LocalPlayer.Name
    UsrName.Size = UDim2.new(1, -45, 0, 15)
    UsrName.Position = UDim2.new(0, 40, 0, 19)
    UsrName.BackgroundTransparency = 1
    UsrName.Font = Enum.Font.Gotham
    UsrName.TextSize = 10
    UsrName.TextTransparency = 0.5
    UsrName.TextXAlignment = Enum.TextXAlignment.Left
    UsrName.Parent = ProfileFrame
    AddToRegistry(UsrName, "TextColor3", "Text")

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 1, 1, 0)
    Line.Position = UDim2.new(0, 150, 0, 0)
    Line.BackgroundTransparency = 0.8
    Line.Parent = Content
    AddToRegistry(Line, "BackgroundColor3", "Stroke")

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -165, 1, 0)
    PageContainer.Position = UDim2.new(0, 160, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    MainFrame.ClipsDescendants = false

    local Resizer = Instance.new("TextButton")
    Resizer.Name = "WindowResizer"
    Resizer.Parent = MainFrame
    Resizer.BackgroundTransparency = 0.8
    Resizer.BackgroundColor3 = Color3.new(1, 1, 1)
    Resizer.Position = UDim2.new(1, 5, 1, 5)
    Resizer.Size = UDim2.new(0, 24, 0, 24)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.Text = ""
    Resizer.ZIndex = 30
    Resizer.Visible = false

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 4
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Transparency = 0
    stroke.Parent = Resizer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = Resizer

    local isResizing = false
    local resizeStart = Vector2.new(0,0)
    local startSize = UDim2.new(0,0,0,0)

    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStart = input.Position
            startSize = MainFrame.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.max(400, startSize.X.Offset + delta.X)
            local newHeight = math.max(250, startSize.Y.Offset + delta.Y)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = false
        end
    end)

    Window._ProjectorModeEnabled = false
    Window._ProjectorObjects = nil
    Window._ProjectorSettings = {
        distance = 8,
        width = 12,
        height = 8,
        transparency = 0.3,
        autoSize = true
    }

    local function addPressEffect(button)
        local originalSize = button.Size
        local originalPos = button.Position
        button.MouseButton1Down:Connect(function()
            Tween(button, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.95, originalSize.Y.Scale, originalSize.Y.Offset * 0.95), Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 2, originalPos.Y.Scale, originalPos.Y.Offset + 2)}, 0.05)
        end)
        button.MouseButton1Up:Connect(function()
            Tween(button, {Size = originalSize, Position = originalPos}, 0.1)
        end)
        button.MouseLeave:Connect(function()
            Tween(button, {Size = originalSize, Position = originalPos}, 0.1)
        end)
    end

    local function addPressEffectToAll(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                addPressEffect(child)
            end
            addPressEffectToAll(child)
        end
    end

    function Window:UpdateProjectorSizeFromUI()
        if not Window._ProjectorModeEnabled or not Window._ProjectorObjects then return end
        local mainFrame = Window._ProjectorObjects.SurfaceGui:FindFirstChild("FengYu-Bento")
        if not mainFrame then return end
        local absSize = mainFrame.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then return end
        local aspect = absSize.X / absSize.Y
        local targetHeight = Window._ProjectorSettings.height
        local targetWidth = targetHeight * aspect
        targetWidth = clamp(targetWidth, 4, 24)
        targetHeight = clamp(targetHeight, 3, 16)
        Window._ProjectorObjects.Screen.Size = Vector3.new(targetWidth, targetHeight, 0.1)
        Window._ProjectorSettings.width = targetWidth
        Window._ProjectorSettings.height = targetHeight
    end

    local function SwitchToProjectorMode(distance, width, height, transparency)
        if Window._ProjectorModeEnabled then return end
        
        distance = distance or Window._ProjectorSettings.distance
        width = width or Window._ProjectorSettings.width
        height = height or Window._ProjectorSettings.height
        transparency = transparency or Window._ProjectorSettings.transparency
        
        local projectorScreen = Instance.new("Part")
        projectorScreen.Name = "FengYu_ProjectorScreen"
        projectorScreen.Anchored = true
        projectorScreen.CanCollide = false
        projectorScreen.Locked = true
        projectorScreen.Transparency = transparency
        projectorScreen.Size = Vector3.new(width, height, 0.1)
        projectorScreen.BrickColor = BrickColor.new("White")
        projectorScreen.Material = Enum.Material.SmoothPlastic
        projectorScreen.TopSurface = Enum.SurfaceType.Smooth
        projectorScreen.BottomSurface = Enum.SurfaceType.Smooth
        
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Adornee = projectorScreen
        selectionBox.Color3 = CurrentTheme.Accent
        selectionBox.LineThickness = 0.08
        selectionBox.Transparency = 0.4
        selectionBox.Parent = projectorScreen
        
        if syn and syn.protect_gui then syn.protect_gui(projectorScreen) end
        projectorScreen.Parent = workspace
        
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Name = "ProjectorUI"
        surfaceGui.ResetOnSpawn = false
        surfaceGui.Face = Enum.NormalId.Front
        surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surfaceGui.CanvasSize = Vector2.new(1600, 1200)
        surfaceGui.ClipsDescendants = true
        surfaceGui.AlwaysOnTop = true
        surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        surfaceGui.Adornee = projectorScreen
        surfaceGui.Parent = projectorScreen
        
        local originalChildren = {}
        for _, child in ipairs(ScreenGui:GetChildren()) do
            if child ~= OpenButton and child ~= NotificationHolder then
                originalChildren[#originalChildren + 1] = child
            end
        end
        
        for _, child in ipairs(originalChildren) do
            child.Parent = surfaceGui
        end
        
        Window._savedMainFrameSize = MainFrame.Size
        Window._savedMainFramePos = MainFrame.Position
        
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        addPressEffectToAll(surfaceGui)
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 2.5
        pointLight.Range = 20
        pointLight.Color = CurrentTheme.Accent
        pointLight.Parent = projectorScreen
        
        local function updateScreenPosition()
            local character = LocalPlayer.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local forward = rootPart.CFrame.LookVector
            forward = Vector3.new(forward.X, 0, forward.Z).Unit
            local targetPos = rootPart.Position + forward * distance
            targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z)
            
            local lookAtPoint = Vector3.new(rootPart.Position.X, targetPos.Y, rootPart.Position.Z)
            local screenCF = CFrame.lookAt(targetPos, lookAtPoint, Vector3.new(0, 1, 0))
            
            projectorScreen.CFrame = screenCF
        end
        
        updateScreenPosition()
        
        local updateConnection
        updateConnection = RunService.RenderStepped:Connect(function()
            if not projectorScreen.Parent then
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            updateScreenPosition()
        end)
        
        local sizeConnection
        sizeConnection = MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
            if Window._ProjectorSettings.autoSize then
                Window:UpdateProjectorSizeFromUI()
            end
        end)
        task.wait(0.1)
        Window:UpdateProjectorSizeFromUI()
        
        Window._ProjectorModeEnabled = true
        Window._ProjectorObjects = {
            Screen = projectorScreen,
            SurfaceGui = surfaceGui,
            UpdateConnection = updateConnection,
            SizeConnection = sizeConnection,
            Light = pointLight,
            SelectionBox = selectionBox
        }
        
        return true
    end
    
    local function SwitchTo2DMode()
        if not Window._ProjectorModeEnabled then return end
        
        if Window._ProjectorObjects then
            if Window._ProjectorObjects.UpdateConnection then
                Window._ProjectorObjects.UpdateConnection:Disconnect()
            end
            if Window._ProjectorObjects.SizeConnection then
                Window._ProjectorObjects.SizeConnection:Disconnect()
            end
            if Window._ProjectorObjects.SurfaceGui then
                local surfaceGui = Window._ProjectorObjects.SurfaceGui
                for _, child in ipairs(surfaceGui:GetChildren()) do
                    child.Parent = ScreenGui
                end
            end
            if Window._ProjectorObjects.Screen then
                Window._ProjectorObjects.Screen:Destroy()
            end
        end
        
        if Window._savedMainFrameSize then
            MainFrame.Size = Window._savedMainFrameSize
            MainFrame.Position = Window._savedMainFramePos
        else
            MainFrame.Size = UDim2.new(0, 500, 0, 299)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
        
        Window._ProjectorModeEnabled = false
        Window._ProjectorObjects = nil

        dragging = false
        dragStartPos = nil
        dragStartWindowPos = nil
        
        return true
    end
    
    local function ToggleProjectorMode()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
        else
            SwitchToProjectorMode()
        end
    end
    
    local Toggle3DBtn = createIconButton("rbxassetid://12684119225", function()
        ToggleProjectorMode()
    end)
    
    local MinimizeBtn = createTextButton("-", function()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
        else
            MainFrame.Visible = false
        end
    end)
    
    local resizerVisible = false
    Resizer.Visible = resizerVisible
    
    local MaximizeBtn = createIconButton("rbxassetid://6031090998", function()
        resizerVisible = not resizerVisible
        Resizer.Visible = resizerVisible
    end)
    
    local CloseBtn = createTextButton("X", function()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
        end
        ScreenGui:Destroy()
    end)

    Tween(MainFrame, {Size = UDim2.new(0, 500, 0, 299)}, 0.6)

    local dragging = false
    local dragStartPos = nil
    local dragStartWindowPos = nil
    
    local function getInputPosition(input)
        local pos = input.Position
        if typeof(pos) == "Vector3" then
            return Vector2.new(pos.X, pos.Y)
        end
        return pos
    end
    
    local function startDrag(input)
        if Window._ProjectorModeEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = getInputPosition(input)
            dragStartWindowPos = MainFrame.Position
            pcall(function() input:StopPropagation() end)
        end
    end
    
    local function onDragMove(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local currentPos = getInputPosition(input)
            local delta = currentPos - dragStartPos
            
            local newPos = UDim2.new(
                dragStartWindowPos.X.Scale,
                dragStartWindowPos.X.Offset + delta.X,
                dragStartWindowPos.Y.Scale,
                dragStartWindowPos.Y.Offset + delta.Y
            )
            MainFrame.Position = newPos
        end
    end
    
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            dragStartPos = nil
            dragStartWindowPos = nil
        end
    end
    
    Topbar.InputBegan:Connect(startDrag)
    UserInputService.InputChanged:Connect(onDragMove)
    UserInputService.InputEnded:Connect(endDrag)

    local function toggleMainFrame()
        if MainFrame.Visible then
            MainFrame.Visible = false
        else
            local targetSize = MainFrame.Size
            MainFrame.Size = UDim2.new(0,0,0,0)
            MainFrame.Visible = true
            Tween(MainFrame, {Size = targetSize}, 0.5)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            toggleMainFrame()
        end
    end)

    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingOpenButton"
    OpenButton.Parent = ScreenGui
    OpenButton.BackgroundColor3 = CurrentTheme.Accent
    OpenButton.BackgroundTransparency = 0.85
    OpenButton.Position = UDim2.new(0.92, 0, 0.01, 0)  
    OpenButton.Size = UDim2.new(0, 40, 0, 40)
    OpenButton.Active = true
    OpenButton.Draggable = true  
    OpenButton.Image = "rbxassetid://84830962019412"  
    OpenButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    OpenButton.ImageTransparency = 0.15
    OpenButton.ZIndex = 10  

    OpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pcall(function() input:StopPropagation() end)
        end
    end)

    local openCorner = Instance.new("UICorner")
    openCorner.CornerRadius = UDim.new(0, 8)
    openCorner.Parent = OpenButton

    local openStroke = Instance.new("UIStroke")
    openStroke.Parent = OpenButton
    openStroke.Color = Color3.fromRGB(180, 180, 180)
    openStroke.Thickness = 1.2
    openStroke.Transparency = 0.4

    startNeonFlowEffect(OpenButton, "BackgroundColor3", 0.012)
    createPulseGlow(openStroke)

    OpenButton.MouseButton1Click:Connect(function()
        toggleMainFrame()
    end)

    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        OpenButton.Visible = not MainFrame.Visible
    end)

    OpenButton.Visible = false

    function Window:Notification(titleText, descText, notifType, duration)
        notifType = notifType or "Info"
        duration = duration or 3
        local config = {
            Title = titleText,
            Description = descText,
            Duration = duration,
            Type = notifType
        }

        local title = config.Title or "Notification"
        local description = config.Description or ""
        local totalTime = config.Duration or 3
        local notifType = config.Type or "Info"

        local typeColors = {
            Success = Color3.fromRGB(60, 179, 113),
            Error   = Color3.fromRGB(229, 51, 51),
            Info    = Color3.fromRGB(77, 163, 255)
        }
        local typeIcons = {
            Success = "rbxassetid://120659272678891",
            Error   = "rbxassetid://89180847534855",
            Info    = "rbxassetid://75441143875602"
        }
        local closeIcon = "rbxassetid://103624613466093"

        local accentColor = typeColors[notifType] or typeColors.Info

        local root = Instance.new("Frame")
        root.Name = "NotificationRoot"
        root.Size = UDim2.new(0, 0, 0, 0)
        root.BackgroundTransparency = 1
        root.BorderSizePixel = 0
        root.ClipsDescendants = true
        root.Parent = NotificationHolder

        local main = Instance.new("Frame")
        main.Name = "Main"
        main.Size = UDim2.new(0, 250, 0, 0)
        main.AutomaticSize = Enum.AutomaticSize.Y
        main.BackgroundColor3 = CurrentTheme.Top
        main.BackgroundTransparency = 0.05
        main.BorderSizePixel = 0
        main.Parent = root

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 20)
        corner.Parent = main

        local closeImg = Instance.new("ImageLabel")
        closeImg.Name = "CloseIcon"
        closeImg.Image = closeIcon
        closeImg.Size = UDim2.new(0, 8, 0, 8)
        closeImg.Position = UDim2.new(1, -15, 0, 15)
        closeImg.AnchorPoint = Vector2.new(1, 0)
        closeImg.BackgroundTransparency = 1
        closeImg.BorderSizePixel = 0
        closeImg.ImageColor3 = CurrentTheme.Text
        closeImg.Parent = main

        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseButton"
        closeBtn.Size = UDim2.new(1, 0, 1, 0)
        closeBtn.BackgroundTransparency = 1
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = ""
        closeBtn.Parent = main

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -65, 1, 0)
        content.Position = UDim2.new(0, 35, 0, 0)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = main

        local icon = Instance.new("ImageLabel")
        icon.Name = "TypeIcon"
        icon.Image = typeIcons[notifType]
        icon.Size = UDim2.new(0, 15, 0, 15)
        icon.Position = UDim2.new(0, -15, 0.5, 0)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.ImageColor3 = accentColor
        icon.Parent = content

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Name = "Title"
        titleLbl.Text = title
        titleLbl.Size = UDim2.new(1, 0, 0, 10)
        titleLbl.AutomaticSize = Enum.AutomaticSize.Y
        titleLbl.BackgroundTransparency = 1
        titleLbl.BorderSizePixel = 0
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.TextColor3 = CurrentTheme.Text
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.RichText = true
        titleLbl.Parent = content

        icon.Parent = titleLbl

        local descLbl = Instance.new("TextLabel")
        descLbl.Name = "Description"
        descLbl.Text = description
        descLbl.Size = UDim2.new(1, 0, 0, 5)
        descLbl.AutomaticSize = Enum.AutomaticSize.Y
        descLbl.BackgroundTransparency = 1
        descLbl.BorderSizePixel = 0
        descLbl.Font = Enum.Font.Gotham
        descLbl.TextSize = 12
        descLbl.TextColor3 = CurrentTheme.Text
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.RichText = true
        descLbl.Parent = content

        local line = Instance.new("Frame")
        line.Name = "Line"
        line.Size = UDim2.new(0, 3, 1, 3)
        line.Position = UDim2.new(0, -15, 0.5, 0)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = accentColor
        line.BackgroundTransparency = 0.7
        line.BorderSizePixel = 0
        line.Parent = descLbl

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 0)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = content

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 14)
        padding.PaddingBottom = UDim.new(0, 16)
        padding.Parent = content

        RunService.Heartbeat:Wait()
        local mainSize = main.AbsoluteSize

        Tween(root, {Size = UDim2.new(0, mainSize.X, 0, mainSize.Y)}, 0.3)

        local function updateTheme()
            main.BackgroundColor3 = CurrentTheme.Top
            titleLbl.TextColor3 = CurrentTheme.Text
            descLbl.TextColor3 = CurrentTheme.Text
            closeImg.ImageColor3 = CurrentTheme.Text
        end

        table.insert(ThemeListeners, updateTheme)

        local isDestroying = false

        local function destroy()
            if isDestroying then return end
            isDestroying = true

            for i, fn in ipairs(ThemeListeners) do
                if fn == updateTheme then
                    table.remove(ThemeListeners, i)
                    break
                end
            end

            local shrink = TweenService:Create(root, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)})
            shrink.Completed:Connect(function()
                if root and root.Parent then
                    root:Destroy()
                end
            end)
            shrink:Play()
        end

        closeBtn.MouseButton1Click:Connect(destroy)

        local showTime = math.max(0, totalTime - 0.3 - 0.25)

        if showTime > 0 then
            task.delay(showTime, destroy)
        else
            task.delay(0.3, destroy)
        end
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end
    function Window:SetSubtitle(newSubtitle)
        for _, child in ipairs(Topbar:GetChildren()) do
            if child:IsA("TextLabel") and child ~= TitleLabel then
                child.Text = newSubtitle
                break
            end
        end
    end

    function Window:SetProjectorDistance(distance)
        distance = clamp(distance, 3, 20)
        Window._ProjectorSettings.distance = distance
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local forward = rootPart.CFrame.LookVector
                forward = Vector3.new(forward.X, 0, forward.Z).Unit
                local targetPos = rootPart.Position + forward * distance
                targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z)
                local lookAtPoint = Vector3.new(rootPart.Position.X, targetPos.Y, rootPart.Position.Z)
                local screenCF = CFrame.lookAt(targetPos, lookAtPoint, Vector3.new(0, 1, 0))
                Window._ProjectorObjects.Screen.CFrame = screenCF
            end
        end
    end
    
    function Window:SetProjectorSize(width, height)
        width = clamp(width, 4, 24)
        height = clamp(height, 3, 16)
        Window._ProjectorSettings.width = width
        Window._ProjectorSettings.height = height
        Window._ProjectorSettings.autoSize = false
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            Window._ProjectorObjects.Screen.Size = Vector3.new(width, height, 0.1)
        end
    end
    
    function Window:SetProjectorTransparency(transparency)
        transparency = clamp(transparency, 0, 0.8)
        Window._ProjectorSettings.transparency = transparency
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            Window._ProjectorObjects.Screen.Transparency = transparency
        end
    end
    
    function Window:EnableProjectorMode(distance, width, height, transparency)
        return SwitchToProjectorMode(distance, width, height, transparency)
    end
    
    function Window:DisableProjectorMode()
        return SwitchTo2DMode()
    end
    
    function Window:ToggleProjectorMode()
        return ToggleProjectorMode()
    end
    
    function Window:IsProjectorMode()
        return Window._ProjectorModeEnabled
    end

    local firstTab = true
    local controlCounter = 0

    local function createSection(parent, text, icons, defaultOpen)
        if defaultOpen == nil then defaultOpen = true end

        local function formatAssetId(id)
            if type(id) == "number" then
                return "rbxassetid://" .. tostring(id)
            elseif type(id) == "string" then
                if tonumber(id) then
                    return "rbxassetid://" .. id
                else
                    return id
                end
            else
                return nil
            end
        end

        local iconOpen, iconClosed
        if type(icons) == "table" then
            iconOpen = formatAssetId(icons.Y or icons.open) or "rbxassetid://6031091004"
            iconClosed = formatAssetId(icons.F or icons.closed) or iconOpen
        else
            local defaultIcon = formatAssetId(icons) or "rbxassetid://6031091004"
            iconOpen = defaultIcon
            iconClosed = defaultIcon
        end

        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(1, 0, 0, 36)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.Parent = parent
        sectionFrame.ClipsDescendants = true

        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 36)
        titleBar.BackgroundTransparency = 1
        titleBar.Parent = sectionFrame

        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, 28, 0, 28)
        iconLabel.Position = UDim2.new(0, 5, 0.5, -14)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = defaultOpen and iconOpen or iconClosed
        iconLabel.Parent = titleBar
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 8)
        iconCorner.Parent = iconLabel
        AddToRegistry(iconLabel, "ImageColor3", "Text")

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = text
        textLabel.Size = UDim2.new(1, -38, 1, 0)
        textLabel.Position = UDim2.new(0, 38, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.Parent = titleBar
        AddToRegistry(textLabel, "TextColor3", "Accent")

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(1, 0, 1, 0)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.Parent = titleBar

        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, 0, 0, 0)
        contentContainer.Position = UDim2.new(0, 0, 0, 36)
        contentContainer.BackgroundTransparency = 1
        contentContainer.ClipsDescendants = true
        contentContainer.Parent = sectionFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentContainer

        local currentContentTween, currentSectionTween
        local open = defaultOpen

        local function updateSectionHeight(instant)
            local targetContentHeight = open and contentLayout.AbsoluteContentSize.Y or 0
            local targetSectionHeight = 36 + targetContentHeight
            if currentContentTween then currentContentTween:Cancel() end
            if currentSectionTween then currentSectionTween:Cancel() end
            local tweenInfo = TweenInfo.new(instant and 0 or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            currentContentTween = TweenService:Create(contentContainer, tweenInfo, {Size = UDim2.new(1, 0, 0, targetContentHeight)})
            currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, targetSectionHeight)})
            currentContentTween:Play()
            currentSectionTween:Play()
        end

        task.spawn(function()
            task.wait()
            updateSectionHeight(true)
        end)

        local function toggle()
            open = not open
            iconLabel.Image = open and iconOpen or iconClosed
            updateSectionHeight(false)
        end

        toggleBtn.MouseButton1Click:Connect(toggle)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if open then
                updateSectionHeight(false)
            end
        end)

        local child = {}

        child.Button = function(_, btnText, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 42)
            Btn.Text = ""
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Btn.Parent = contentContainer
            Btn.BackgroundTransparency = 0.05
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -30, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.Text = btnText
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = Btn
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 15, 0, 15)
            Icon.Position = UDim2.new(1, -25, 0.5, -7.5)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://10709791437"
            Icon.ImageTransparency = 0.5
            Icon.Parent = Btn
            AddToRegistry(Icon, "ImageColor3", "Text")

            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundTransparency = 0.00}, 0.18)
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundTransparency = 0.05}, 0.18)
            end)

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, {Size = UDim2.new(0.97, 0, 0, 38)}, 0.1)
                task.wait(0.1)
                Tween(Btn, {Size = UDim2.new(1, 0, 0, 42)}, 0.15)
                callback()
            end)

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) Btn.Visible = state end
            return self
        end

        child.Toggle = function(_, toggleText, default, callback)
            local Enabled = default or false
            controlCounter = controlCounter + 1
            local controlId = toggleText .. "_" .. tostring(controlCounter)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 42)
            Tile.Parent = contentContainer
            Tile.BackgroundTransparency = 0.05
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = toggleText
            TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 15, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.Position = UDim2.new(1, -56, 0.5, -11)
            Switch.Parent = Tile
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
            Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke

            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1
            SwStroke.Transparency = 0.6
            SwStroke.Parent = Switch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Dot.Parent = Switch
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            ConfigObjects[controlId] = {Type = "Toggle", Value = Enabled, Set = function(val)
                Enabled = val
                Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke
                Dot.Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                callback(Enabled)
            end}

            local function Update()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
                Tween(Dot, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                ConfigObjects[controlId].Value = Enabled
                callback(Enabled)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                Update()
            end)

            table.insert(ThemeListeners, function()
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or CurrentTheme.Stroke})
            end)
        end

        child.Slider = function(_, sliderText, min, max, default, callback, options)
            options = options or {}
            local unlimited = (min == nil and max == nil)
            min = tonumber(min)
            max = tonumber(max)
            local Val = tonumber(default) or (min or 0)
            controlCounter = controlCounter + 1
            local controlId = sliderText .. "_" .. tostring(controlCounter)

            local tileH = unlimited and 42 or 60
            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, tileH)
            Tile.Parent = contentContainer
            Tile.BackgroundTransparency = 0.05
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = sliderText
            TitleLbl.Size = UDim2.new(1, -30, 0, 20)
            TitleLbl.Position = UDim2.new(0, 15, 0, unlimited and 11 or 10)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local numW = unlimited and 72 or 52
            local Num = Instance.new("TextBox")
            Num.Text = tostring(Val)
            Num.Size = UDim2.new(0, numW, 0, 22)
            Num.Position = UDim2.new(1, -(numW + 10), 0, unlimited and 10 or 9)
            Num.BackgroundTransparency = 0.08
            Num.Font = Enum.Font.GothamBold
            Num.TextSize = 12
            Num.TextXAlignment = Enum.TextXAlignment.Center
            Num.Parent = Tile
            Num.ClearTextOnFocus = false
            Instance.new("UICorner", Num).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Num, "BackgroundColor3", "Main")
            AddToRegistry(Num, "TextColor3", "Accent")
            local NumStroke = Instance.new("UIStroke")
            NumStroke.Thickness = 1
            NumStroke.Transparency = 0.75
            NumStroke.Parent = Num
            AddToRegistry(NumStroke, "Color", "Stroke")
            Num.Focused:Connect(function() Tween(NumStroke, {Transparency = 0.2}, 0.15) end)

            if unlimited then
                local HintLbl = Instance.new("TextLabel")
                HintLbl.Text = "∞"
                HintLbl.Size = UDim2.new(0, 14, 0, 14)
                HintLbl.Position = UDim2.new(1, -(numW + 10) - 16, 0, 18)
                HintLbl.BackgroundTransparency = 1
                HintLbl.Font = Enum.Font.GothamBold
                HintLbl.TextSize = 11
                HintLbl.TextTransparency = 0.4
                HintLbl.Parent = Tile
                AddToRegistry(HintLbl, "TextColor3", "Accent")
            end

            local Track, Fill, Knob, Bar
            if not unlimited then
                Track = Instance.new("Frame")
                Track.Size = UDim2.new(1, -30, 0, 5)
                Track.Position = UDim2.new(0, 15, 0, 44)
                Track.BorderSizePixel = 0
                Track.Parent = Tile
                Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
                AddToRegistry(Track, "BackgroundColor3", "Stroke")

                local initP = (min and max and max ~= min) and ((Val - min) / (max - min)) or 0
                Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(initP, 0, 1, 0)
                Fill.Parent = Track
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
                AddToRegistry(Fill, "BackgroundColor3", "Accent")

                Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob.Position = UDim2.new(initP, 0, 0.5, 0)
                Knob.BackgroundColor3 = Color3.new(1, 1, 1)
                Knob.ZIndex = 2
                Knob.Parent = Track
                Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

                Bar = Instance.new("TextButton")
                Bar.Size = UDim2.new(1, 0, 0, 18)
                Bar.Position = UDim2.new(0, 0, 0.5, -9)
                Bar.BackgroundTransparency = 1
                Bar.Text = ""
                Bar.ZIndex = 3
                Bar.Parent = Track
            end

            local function Update(newVal)
                if min ~= nil and max ~= nil then
                    newVal = clamp(newVal, min, max)
                elseif min ~= nil then
                    newVal = math.max(newVal, min)
                elseif max ~= nil then
                    newVal = math.min(newVal, max)
                else
                    newVal = newVal
                end
                Val = newVal
                Num.Text = tostring(Val)
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Value = Val
                end
                if Track and Fill and Knob and min ~= nil and max ~= nil and max ~= min then
                    local p = (Val - min) / (max - min)
                    Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.16)
                    Tween(Knob, {Position = UDim2.new(p, 0, 0.5, 0)}, 0.16)
                end
                callback(Val)
            end

            ConfigObjects[controlId] = {Type = "Slider", Value = Val, Set = function(val) Update(tonumber(val) or Val) end}

            local function Drag(input)
                if not Track or min == nil or max == nil or max == min then return end
                local p = clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                Update(min + (max - min) * p)
            end

            Num.FocusLost:Connect(function()
                Tween(NumStroke, {Transparency = 0.75}, 0.15)
                local typed = tonumber(Num.Text)
                if typed then
                    Update(typed)
                else
                    Num.Text = tostring(Val)
                end
            end)

            if Bar then
                local sliding = false
                Bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        Drag(i)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        Drag(i)
                    end
                end)
            end

            table.insert(ThemeListeners, function()
                if Fill then Fill.BackgroundColor3 = CurrentTheme.Accent end
                if Track then Track.BackgroundColor3 = CurrentTheme.Stroke end
                Num.TextColor3 = CurrentTheme.Accent
            end)
        end

        child.Dropdown = function(_, dropText, options, callback)
            local Dropped = false
            local Selected = options[1] or ""
            controlCounter = controlCounter + 1
            local controlId = dropText .. "_" .. tostring(controlCounter)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 42)
            Btn.Text = ""
            Btn.BackgroundTransparency = 0.05
            Btn.Parent = contentContainer
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = dropText
            Lbl.Size = UDim2.new(1, -40, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Btn
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Image = "rbxassetid://18865373378"
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(1, -30, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.Parent = Btn
            AddToRegistry(Icon, "ImageColor3", "Accent")

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.Visible = false
            Container.ClipsDescendants = true
            Container.ZIndex = 10
            Container.Parent = contentContainer
            Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Container, "BackgroundColor3", "Top")

            local CSt = Instance.new("UIStroke")
            CSt.Thickness = 1
            CSt.Transparency = 0.65
            CSt.Parent = Container
            AddToRegistry(CSt, "Color", "Accent")

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container

            local function Select(opt)
                Dropped = false
                Selected = opt
                Lbl.Text = dropText .. ": " .. opt
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Value = opt
                end
                callback(opt)

                Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                Tween(Icon, {Rotation = 0}, 0.28)
                task.wait(0.3)
                Container.Visible = false
                updateSectionHeight(false)
            end

            local function RefreshOptions(newOpts)
                for _, v in pairs(Container:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end

                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton")
                    O.Size = UDim2.new(1, 0, 0, 34)
                    O.Text = "   " .. opt
                    O.TextXAlignment = Enum.TextXAlignment.Left
                    O.Font = Enum.Font.GothamMedium
                    O.TextSize = 12
                    O.BackgroundTransparency = 1
                    O.Parent = Container
                    O.TextColor3 = CurrentTheme.Text

                    O.MouseEnter:Connect(function()
                        Tween(O, {TextColor3 = CurrentTheme.Accent}, 0.15)
                    end)
                    O.MouseLeave:Connect(function()
                        Tween(O, {TextColor3 = CurrentTheme.Text}, 0.15)
                    end)

                    O.MouseButton1Click:Connect(function() Select(opt) end)
                end

                if Dropped then
                    local targetHeight = #newOpts * 34
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                end
            end
            RefreshOptions(options)

            local function ResetDropdown()
                if #options > 0 then
                    Select(options[1])
                else
                    Dropped = false
                    Lbl.Text = dropText
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(Icon, {Rotation = 0}, 0.2)
                    task.delay(0.22, function() Container.Visible = false end)
                    updateSectionHeight(false)
                end
            end

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                if Dropped then
                    Container.Visible = true
                    local buttonCount = 0
                    for _, child in pairs(Container:GetChildren()) do
                        if child:IsA("TextButton") then
                            buttonCount = buttonCount + 1
                        end
                    end
                    local targetHeight = buttonCount * 34
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.32)
                    Tween(Icon, {Rotation = 180}, 0.32)
                else
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    Tween(Icon, {Rotation = 0}, 0.28)
                    task.wait(0.3)
                    Container.Visible = false
                end
                updateSectionHeight(false)
            end)

            ConfigObjects[controlId] = {
                Type = "Dropdown",
                Value = Selected,
                Set = function(val) Select(val) end,
                Refresh = RefreshOptions,
                Reset = ResetDropdown
            }

            table.insert(ThemeListeners, function()
                for _, O in pairs(Container:GetChildren()) do
                    if O:IsA("TextButton") then
                        O.TextColor3 = CurrentTheme.Text
                    end
                end
            end)

            return {Refresh = RefreshOptions, Reset = ResetDropdown}
        end

        child.Keybind = function(_, keyText, default, callback)
            local Key = default or Enum.KeyCode.M
            controlCounter = controlCounter + 1
            local controlId = keyText .. "_" .. tostring(controlCounter)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 42)
            Tile.Parent = contentContainer
            Tile.BackgroundTransparency = 0.05
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = keyText
            TitleLbl.Size = UDim2.new(0.6, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 15, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Text = Key.Name
            KeyLabel.Size = UDim2.new(0, 86, 0, 28)
            KeyLabel.Position = UDim2.new(1, -100, 0.5, -14)
            KeyLabel.Font = Enum.Font.GothamMedium
            KeyLabel.TextSize = 11
            KeyLabel.Parent = Tile
            KeyLabel.BackgroundTransparency = 0.1
            Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 8)
            AddToRegistry(KeyLabel, "BackgroundColor3", "Main")
            AddToRegistry(KeyLabel, "TextColor3", "Accent")

            ConfigObjects[controlId] = {Type = "Keybind", Value = Key.Name, Set = function(val)
                Key = Enum.KeyCode[val] or Key
                KeyLabel.Text = Key.Name
                callback(Key)
            end}

            ClickBtn.MouseButton1Click:Connect(function()
                KeyLabel.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then
                    Key = input.KeyCode
                    KeyLabel.Text = Key.Name
                    ConfigObjects[controlId].Value = Key.Name
                    callback(Key)
                else
                    KeyLabel.Text = Key.Name
                end
            end)
        end

        child.Textbox = function(_, boxText, placeholder, callback)
            controlCounter = controlCounter + 1
            local controlId = boxText .. "_" .. tostring(controlCounter)

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 70)
            Frame.Parent = contentContainer
            Frame.BackgroundTransparency = 0.05
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Frame, "BackgroundColor3", "Top")

            local Lbl = Instance.new("TextLabel")
            Lbl.Text = boxText
            Lbl.Size = UDim2.new(1, 0, 0, 20)
            Lbl.Position = UDim2.new(0, 15, 0, 10)
            Lbl.BackgroundTransparency = 1
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            Lbl.Parent = Frame
            AddToRegistry(Lbl, "TextColor3", "Text")

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -30, 0, 28)
            Box.Position = UDim2.new(0, 15, 0, 35)
            Box.Text = ""
            Box.PlaceholderText = placeholder
            Box.Font = Enum.Font.GothamMedium
            Box.TextSize = 12
            Box.Parent = Frame
            Box.BackgroundTransparency = 0.1
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
            AddToRegistry(Box, "BackgroundColor3", "Main")
            AddToRegistry(Box, "TextColor3", "Text")

            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Thickness = 1
            BoxStroke.Transparency = 0.75
            BoxStroke.Parent = Box
            AddToRegistry(BoxStroke, "Color", "Stroke")

            Box.Focused:Connect(function()
                Tween(BoxStroke, {Transparency = 0.2}, 0.15)
            end)
            Box.FocusLost:Connect(function()
                Tween(BoxStroke, {Transparency = 0.75}, 0.15)
                ConfigObjects[controlId].Value = Box.Text
                callback(Box.Text)
            end)

            ConfigObjects[controlId] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; callback(val) end}
        end

        child.Input = function(_, inputText, default, callback, options)
            options = options or {}
            local placeholder = options.placeholder or ""; local acceptedCharacters = options.acceptedCharacters or "All"; local characterLimit = options.characterLimit; local onChanged = options.onChanged
            controlCounter = controlCounter + 1
            local controlId = inputText .. "_" .. tostring(controlCounter)

            local InputFrame = Instance.new("Frame"); InputFrame.Size = UDim2.new(1, 0, 0, 42); InputFrame.Parent = contentContainer; InputFrame.BackgroundTransparency = 0.05; Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 12); AddToRegistry(InputFrame, "BackgroundColor3", "Top")
            local NameLbl = Instance.new("TextLabel"); NameLbl.Text = inputText; NameLbl.Size = UDim2.new(0.6,0,1,0); NameLbl.Position = UDim2.new(0,15,0,0); NameLbl.TextXAlignment = Enum.TextXAlignment.Left; NameLbl.Font = Enum.Font.GothamMedium; NameLbl.TextSize = 13; NameLbl.BackgroundTransparency = 1; NameLbl.Parent = InputFrame; AddToRegistry(NameLbl, "TextColor3", "Text")
            local InputBox = Instance.new("TextBox"); InputBox.Text = tostring(default or ""); InputBox.PlaceholderText = placeholder; InputBox.Size = UDim2.new(0.3,0,0,28); InputBox.Position = UDim2.new(0.7,-10,0.5,-14); InputBox.Font = Enum.Font.GothamBold; InputBox.TextSize = 13; InputBox.TextXAlignment = Enum.TextXAlignment.Center; InputBox.ClearTextOnFocus = false; InputBox.Parent = InputFrame
            local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0,6); boxCorner.Parent = InputBox
            AddToRegistry(InputBox, "BackgroundColor3", "Main"); AddToRegistry(InputBox, "TextColor3", "Accent")
            local boxStroke = Instance.new("UIStroke"); boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; boxStroke.Color = CurrentTheme.Stroke; boxStroke.Transparency = 0.6; boxStroke.Parent = InputBox
            local function filterText(text)
                if characterLimit then text = text:sub(1,characterLimit) end
                if type(acceptedCharacters)=="function" then return acceptedCharacters(text)
                elseif acceptedCharacters=="Numeric" then return text:gsub("[^%d-]",""):gsub("-(.*)",function(m) return m:gsub("-","") end)
                elseif acceptedCharacters=="Alphabetic" then return text:gsub("[^a-zA-Z]","")
                elseif acceptedCharacters=="AlphaNumeric" then return text:gsub("[^a-zA-Z0-9]","")
                else return text end
            end
            InputBox:GetPropertyChangedSignal("Text"):Connect(function() local filtered = filterText(InputBox.Text); if filtered~=InputBox.Text then InputBox.Text=filtered end; if onChanged then onChanged(filtered) end end)
            InputBox.FocusLost:Connect(function()
                local text = InputBox.Text
                local filtered = filterText(text)
                if filtered~=text then
                    InputBox.Text = filtered
                    text = filtered
                end
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Value = text
                end
                if callback then callback(text) end
            end)
            ConfigObjects[controlId] = {Type = "Input", Value = InputBox.Text, Set = function(val) InputBox.Text = tostring(val) end}
            local self = {}; function self.UpdateText(newText) InputBox.Text = tostring(newText); ConfigObjects[controlId].Value = InputBox.Text end; function self.GetText() return InputBox.Text end; function self.SetVisible(state) InputFrame.Visible = state end; function self.UpdatePlaceholder(newPlaceholder) InputBox.PlaceholderText = newPlaceholder end; return self
        end

        child.Label = function(_, labelText)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 42)
            LabelFrame.Parent = contentContainer
            LabelFrame.BackgroundTransparency = 0.05
            Instance.new("UICorner", LabelFrame).CornerRadius = UDim.new(0, 12)
            AddToRegistry(LabelFrame, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -20, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.GothamMedium
            TextLabel.Text = labelText
            TextLabel.TextSize = 13
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TextLabel.Parent = LabelFrame
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) LabelFrame.Visible = state end
            return self
        end

        child.SubLabel = function(_, subLabelText)
            local SubLabelFrame = Instance.new("Frame")
            SubLabelFrame.Size = UDim2.new(1, 0, 0, 42)
            SubLabelFrame.Parent = contentContainer
            SubLabelFrame.BackgroundTransparency = 0.05
            Instance.new("UICorner", SubLabelFrame).CornerRadius = UDim.new(0, 12)
            AddToRegistry(SubLabelFrame, "BackgroundColor3", "Top")

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -20, 1, 0)
            TextLabel.Position = UDim2.new(0, 10, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.Gotham
            TextLabel.Text = subLabelText
            TextLabel.TextSize = 12
            TextLabel.TextTransparency = 0.5
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
            TextLabel.Parent = SubLabelFrame
            AddToRegistry(TextLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateText(newText) TextLabel.Text = newText end
            function self.SetVisible(state) SubLabelFrame.Visible = state end
            return self
        end

        child.Paragraph = function(_, headerText, bodyText)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.Parent = contentContainer
            ParaFrame.BackgroundTransparency = 0.05
            Instance.new("UICorner", ParaFrame).CornerRadius = UDim.new(0, 12)
            AddToRegistry(ParaFrame, "BackgroundColor3", "Top")

            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 12)
            Padding.PaddingRight = UDim.new(0, 12)
            Padding.PaddingTop = UDim.new(0, 12)
            Padding.PaddingBottom = UDim.new(0, 12)
            Padding.Parent = ParaFrame

            local Layout = Instance.new("UIListLayout")
            Layout.Padding = UDim.new(0, 5)
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Parent = ParaFrame

            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Size = UDim2.new(1, 0, 0, 0)
            HeaderLabel.AutomaticSize = Enum.AutomaticSize.Y
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.Text = headerText
            HeaderLabel.TextSize = 14
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.TextWrapped = true
            HeaderLabel.Parent = ParaFrame
            AddToRegistry(HeaderLabel, "TextColor3", "Accent")

            local BodyLabel = Instance.new("TextLabel")
            BodyLabel.Size = UDim2.new(1, 0, 0, 0)
            BodyLabel.AutomaticSize = Enum.AutomaticSize.Y
            BodyLabel.BackgroundTransparency = 1
            BodyLabel.Font = Enum.Font.Gotham
            BodyLabel.Text = bodyText
            BodyLabel.TextSize = 13
            BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
            BodyLabel.TextWrapped = true
            BodyLabel.Parent = ParaFrame
            AddToRegistry(BodyLabel, "TextColor3", "Text")

            local self = {}
            function self.UpdateHeader(newHeader) HeaderLabel.Text = newHeader end
            function self.UpdateBody(newBody) BodyLabel.Text = newBody end
            function self.SetVisible(state) ParaFrame.Visible = state end
            return self
        end

        child.ColorPicker = function(_, pickerText, default, callback)
            local Color = default or Color3.fromRGB(255, 255, 255)
            local h, s, v = Color3.toHSV(Color)
            controlCounter = controlCounter + 1
            local controlId = pickerText .. "_" .. tostring(controlCounter)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 44)
            Tile.Parent = contentContainer
            Tile.BackgroundTransparency = 0.05
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = pickerText
            TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 15, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Swatch = Instance.new("Frame")
            Swatch.Size = UDim2.new(0, 32, 0, 22)
            Swatch.Position = UDim2.new(1, -46, 0.5, -11)
            Swatch.BackgroundColor3 = Color
            Swatch.Parent = Tile
            Instance.new("UICorner", Swatch).CornerRadius = UDim.new(0, 6)
            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1
            SwStroke.Transparency = 0.6
            SwStroke.Parent = Swatch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Panel = Instance.new("Frame")
            Panel.Size = UDim2.new(1, 0, 0, 0)
            Panel.Visible = false
            Panel.ClipsDescendants = true
            Panel.Parent = contentContainer
            Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)
            AddToRegistry(Panel, "BackgroundColor3", "Top")

            local PSt = Instance.new("UIStroke")
            PSt.Thickness = 1
            PSt.Transparency = 0.65
            PSt.Parent = Panel
            AddToRegistry(PSt, "Color", "Accent")

            local SVBox = Instance.new("ImageLabel")
            SVBox.Size = UDim2.new(1, -52, 0, 110)
            SVBox.Position = UDim2.new(0, 10, 0, 10)
            SVBox.Image = "rbxassetid://4155801252"
            SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVBox.Parent = Panel
            Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 6)

            local SVDot = Instance.new("Frame")
            SVDot.Size = UDim2.new(0, 10, 0, 10)
            SVDot.AnchorPoint = Vector2.new(0.5, 0.5)
            SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
            SVDot.BackgroundColor3 = Color3.new(1, 1, 1)
            SVDot.ZIndex = 2
            SVDot.Parent = SVBox
            Instance.new("UICorner", SVDot).CornerRadius = UDim.new(1, 0)
            local DotStroke = Instance.new("UIStroke")
            DotStroke.Thickness = 1.5
            DotStroke.Color = Color3.fromRGB(80, 80, 80)
            DotStroke.Parent = SVDot

            local HueBar = Instance.new("Frame")
            HueBar.Size = UDim2.new(0, 16, 0, 110)
            HueBar.Position = UDim2.new(1, -30, 0, 10)
            HueBar.BackgroundColor3 = Color3.new(1, 1, 1)
            HueBar.BorderSizePixel = 0
            HueBar.Parent = Panel
            Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 6)

            local HueGradient = Instance.new("UIGradient")
            HueGradient.Rotation = 90
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 0,   0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,   255, 0)),
                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,   255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   0,   255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0,   255)),
                ColorSequenceKeypoint.new(1,    Color3.fromRGB(255, 0,   0)),
            })
            HueGradient.Parent = HueBar

            local HueDot = Instance.new("Frame")
            HueDot.Size = UDim2.new(1, 6, 0, 4)
            HueDot.AnchorPoint = Vector2.new(0.5, 0.5)
            HueDot.Position = UDim2.new(0.5, 0, h, 0)
            HueDot.BackgroundColor3 = Color3.new(1, 1, 1)
            HueDot.ZIndex = 2
            HueDot.Parent = HueBar
            Instance.new("UICorner", HueDot).CornerRadius = UDim.new(1, 0)

            local RGBRow = Instance.new("Frame")
            RGBRow.Size = UDim2.new(1, -20, 0, 28)
            RGBRow.Position = UDim2.new(0, 10, 0, 128)
            RGBRow.BackgroundTransparency = 1
            RGBRow.Parent = Panel

            local function MakeRGBBox(label, xPos)
                local Holder = Instance.new("Frame")
                Holder.Size = UDim2.new(0.33, -4, 1, 0)
                Holder.Position = UDim2.new(xPos, 2, 0, 0)
                Holder.BackgroundTransparency = 0.08
                Holder.Parent = RGBRow
                Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 6)
                AddToRegistry(Holder, "BackgroundColor3", "Main")

                local HolderStroke = Instance.new("UIStroke")
                HolderStroke.Thickness = 1
                HolderStroke.Transparency = 0.75
                HolderStroke.Parent = Holder
                AddToRegistry(HolderStroke, "Color", "Stroke")

                local Prefix = Instance.new("TextLabel")
                Prefix.Text = label .. ":"
                Prefix.Size = UDim2.new(0, 20, 1, 0)
                Prefix.Position = UDim2.new(0, 4, 0, 0)
                Prefix.BackgroundTransparency = 1
                Prefix.Font = Enum.Font.GothamBold
                Prefix.TextSize = 10
                Prefix.TextXAlignment = Enum.TextXAlignment.Left
                Prefix.Parent = Holder
                AddToRegistry(Prefix, "TextColor3", "Accent")

                local Box = Instance.new("TextBox")
                Box.Size = UDim2.new(1, -26, 1, 0)
                Box.Position = UDim2.new(0, 22, 0, 0)
                Box.Text = "0"
                Box.BackgroundTransparency = 1
                Box.Font = Enum.Font.GothamMedium
                Box.TextSize = 11
                Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.Parent = Holder
                AddToRegistry(Box, "TextColor3", "Text")

                Box.Focused:Connect(function()
                    Tween(HolderStroke, {Transparency = 0.15}, 0.15)
                end)
                Box.FocusLost:Connect(function()
                    Tween(HolderStroke, {Transparency = 0.75}, 0.15)
                end)

                return Box
            end

            local RBox = MakeRGBBox("R", 0)
            local GBox = MakeRGBBox("G", 0.33)
            local BBox = MakeRGBBox("B", 0.66)

            local function ApplyColor()
                Color = Color3.fromHSV(h, s, v)
                Swatch.BackgroundColor3 = Color
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                RBox.Text = tostring(math.floor(Color.R * 255))
                GBox.Text = tostring(math.floor(Color.G * 255))
                BBox.Text = tostring(math.floor(Color.B * 255))
                ConfigObjects[controlId].Value = {R = Color.R, G = Color.G, B = Color.B}
                callback(Color)
            end

            local function OnRGBInput()
                local r = math.clamp(tonumber(RBox.Text) or 0, 0, 255)
                local g = math.clamp(tonumber(GBox.Text) or 0, 0, 255)
                local b = math.clamp(tonumber(BBox.Text) or 0, 0, 255)
                Color = Color3.fromRGB(r, g, b)
                h, s, v = Color3.toHSV(Color)
                SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                HueDot.Position = UDim2.new(0.5, 0, h, 0)
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                Swatch.BackgroundColor3 = Color
                ConfigObjects[controlId].Value = {R = Color.R, G = Color.G, B = Color.B}
                callback(Color)
            end

            RBox.FocusLost:Connect(OnRGBInput)
            GBox.FocusLost:Connect(OnRGBInput)
            BBox.FocusLost:Connect(OnRGBInput)

            local svDragging = false
            local SVBtn = Instance.new("TextButton")
            SVBtn.Size = UDim2.new(1, 0, 1, 0)
            SVBtn.BackgroundTransparency = 1
            SVBtn.Text = ""
            SVBtn.ZIndex = 3
            SVBtn.Parent = SVBox
            SVBtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if svDragging then
                        svDragging = false
                        local r = math.floor(Color.R * 255)
                        local g = math.floor(Color.G * 255)
                        local b = math.floor(Color.B * 255)
                        Window:Notification(pickerText, r .. ", " .. g .. ", " .. b, "Info", 1.5)
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if svDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    s = clamp((i.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                    v = 1 - clamp((i.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                    SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                    ApplyColor()
                end
            end)

            local hueDragging = false
            local HueBtn = Instance.new("TextButton")
            HueBtn.Size = UDim2.new(1, 0, 1, 0)
            HueBtn.BackgroundTransparency = 1
            HueBtn.Text = ""
            HueBtn.ZIndex = 3
            HueBtn.Parent = HueBar
            HueBtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if hueDragging then
                        hueDragging = false
                        local r = math.floor(Color.R * 255)
                        local g = math.floor(Color.G * 255)
                        local b = math.floor(Color.B * 255)
                        Window:Notification(pickerText, r .. ", " .. g .. ", " .. b, "Info", 1.5)
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    h = clamp((i.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    HueDot.Position = UDim2.new(0.5, 0, h, 0)
                    ApplyColor()
                end
            end)

            local pickerOpen = false
            ClickBtn.MouseButton1Click:Connect(function()
                pickerOpen = not pickerOpen
                if pickerOpen then
                    Panel.Visible = true
                    Tween(Panel, {Size = UDim2.new(1, 0, 0, 166)}, 0.32)
                else
                    Tween(Panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    task.wait(0.3)
                    Panel.Visible = false
                end
                updateSectionHeight(false)
            end)

            ConfigObjects[controlId] = {
                Type = "ColorPicker",
                Value = {R = Color.R, G = Color.G, B = Color.B},
                Set = function(val)
                    if type(val) == "table" then
                        Color = Color3.new(val.R, val.G, val.B)
                        h, s, v = Color3.toHSV(Color)
                        SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                        HueDot.Position = UDim2.new(0.5, 0, h, 0)
                        RBox.Text = tostring(math.floor(Color.R * 255))
                        GBox.Text = tostring(math.floor(Color.G * 255))
                        BBox.Text = tostring(math.floor(Color.B * 255))
                        ApplyColor()
                    elseif type(val) == "userdata" and val.ClassName == "Color3" then
                        Color = val
                        h, s, v = Color3.toHSV(Color)
                        SVDot.Position = UDim2.new(s, 0, 1 - v, 0)
                        HueDot.Position = UDim2.new(0.5, 0, h, 0)
                        RBox.Text = tostring(math.floor(Color.R * 255))
                        GBox.Text = tostring(math.floor(Color.G * 255))
                        BBox.Text = tostring(math.floor(Color.B * 255))
                        ApplyColor()
                    end
                end
            }

            table.insert(ThemeListeners, function()
                SwStroke.Color = CurrentTheme.Stroke
            end)
        end

        child.Image = function(_, config)
            config = config or {}
            local title = config.Title or "Image"
            local subtitle = config.Subtitle or ""
            local description = config.Description or {}
            if type(description) == "string" then
                description = {description}
            end
            local iconAsset = config.Icon or config.ImageLink or ""
            local iconColor = config.IconColor or CurrentTheme.Text
            local callback = config.Callback or function() end
            local strokeColor = config.StrokeColor or CurrentTheme.Stroke

            local function formatIcon(asset)
                if type(asset) == "number" then
                    return "rbxassetid://" .. tostring(asset)
                elseif type(asset) == "string" then
                    if tonumber(asset) then
                        return "rbxassetid://" .. asset
                    elseif asset:match("^rbxassetid://") then
                        return asset
                    elseif asset:match("^http") then
                        return asset
                    else
                        return "rbxassetid://" .. asset
                    end
                end
                return "rbxassetid://78229538488090"
            end

            local imageFrame = Instance.new("Frame")
            imageFrame.Size = UDim2.new(1, 0, 0, 0)
            imageFrame.AutomaticSize = Enum.AutomaticSize.Y
            imageFrame.Parent = contentContainer
            imageFrame.BackgroundTransparency = 0.05
            Instance.new("UICorner", imageFrame).CornerRadius = UDim.new(0, 12)
            AddToRegistry(imageFrame, "BackgroundColor3", "Top")

            local imgStroke = Instance.new("UIStroke")
            imgStroke.Thickness = 1
            imgStroke.Transparency = 0.6
            imgStroke.Color = strokeColor
            imgStroke.Parent = imageFrame
            AddToRegistry(imgStroke, "Color", "Stroke")

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 12)
            padding.PaddingRight = UDim.new(0, 12)
            padding.PaddingTop = UDim.new(0, 12)
            padding.PaddingBottom = UDim.new(0, 12)
            padding.Parent = imageFrame

            local horizontal = Instance.new("Frame")
            horizontal.Size = UDim2.new(1, 0, 1, 0)
            horizontal.BackgroundTransparency = 1
            horizontal.Parent = imageFrame

            local iconImg = Instance.new("ImageLabel")
            iconImg.Size = UDim2.new(0, 80, 0, 80)
            iconImg.Position = UDim2.new(0, 0, 0, 0)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = formatIcon(iconAsset)
            iconImg.ImageColor3 = iconColor
            iconImg.Parent = horizontal
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 12)
            iconCorner.Parent = iconImg

            local textContainer = Instance.new("Frame")
            textContainer.Size = UDim2.new(1, -92, 1, 0)
            textContainer.Position = UDim2.new(0, 92, 0, 0)
            textContainer.BackgroundTransparency = 1
            textContainer.AutomaticSize = Enum.AutomaticSize.Y
            textContainer.Parent = horizontal

            local textLayout = Instance.new("UIListLayout")
            textLayout.Padding = UDim.new(0, 6)
            textLayout.SortOrder = Enum.SortOrder.LayoutOrder
            textLayout.Parent = textContainer

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.AutomaticSize = Enum.AutomaticSize.Y
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = title
            titleLabel.TextSize = 15
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextWrapped = true
            titleLabel.Parent = textContainer
            AddToRegistry(titleLabel, "TextColor3", "Text")

            local subtitleLabel = nil
            if subtitle ~= "" then
                subtitleLabel = Instance.new("TextLabel")
                subtitleLabel.Size = UDim2.new(1, 0, 0, 0)
                subtitleLabel.AutomaticSize = Enum.AutomaticSize.Y
                subtitleLabel.BackgroundTransparency = 1
                subtitleLabel.Font = Enum.Font.Gotham
                subtitleLabel.Text = subtitle
                subtitleLabel.TextSize = 12
                subtitleLabel.TextTransparency = 0.5
                subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                subtitleLabel.TextWrapped = true
                subtitleLabel.Parent = textContainer
                AddToRegistry(subtitleLabel, "TextColor3", "Text")
            end

            local descLabels = {}
            for _, line in ipairs(description) do
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, 0, 0, 0)
                descLabel.AutomaticSize = Enum.AutomaticSize.Y
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.Gotham
                descLabel.Text = line
                descLabel.TextSize = 12
                descLabel.TextTransparency = 0.3
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextWrapped = true
                descLabel.Parent = textContainer
                AddToRegistry(descLabel, "TextColor3", "Text")
                table.insert(descLabels, descLabel)
            end

            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = imageFrame
            clickBtn.MouseButton1Click:Connect(callback)

            local function onEnter()
                Tween(imageFrame, {BackgroundTransparency = 0.00}, 0.18)
            end
            local function onLeave()
                Tween(imageFrame, {BackgroundTransparency = 0.05}, 0.18)
            end
            clickBtn.MouseEnter:Connect(onEnter)
            clickBtn.MouseLeave:Connect(onLeave)

            local self = {}
            function self.UpdateTitle(newTitle)
                titleLabel.Text = newTitle
            end
            function self.UpdateSubtitle(newSubtitle)
                if subtitleLabel then
                    subtitleLabel.Text = newSubtitle
                elseif newSubtitle ~= "" then
                    subtitleLabel = Instance.new("TextLabel")
                    subtitleLabel.Size = UDim2.new(1, 0, 0, 0)
                    subtitleLabel.AutomaticSize = Enum.AutomaticSize.Y
                    subtitleLabel.BackgroundTransparency = 1
                    subtitleLabel.Font = Enum.Font.Gotham
                    subtitleLabel.Text = newSubtitle
                    subtitleLabel.TextSize = 12
                    subtitleLabel.TextTransparency = 0.5
                    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    subtitleLabel.TextWrapped = true
                    subtitleLabel.Parent = textContainer
                    AddToRegistry(subtitleLabel, "TextColor3", "Text")
                    textLayout:Arrange()
                end
            end
            function self.UpdateDescription(newDesc)
                for _, lbl in ipairs(descLabels) do
                    lbl:Destroy()
                end
                descLabels = {}
                if type(newDesc) == "string" then newDesc = {newDesc} end
                for _, line in ipairs(newDesc) do
                    local descLabel = Instance.new("TextLabel")
                    descLabel.Size = UDim2.new(1, 0, 0, 0)
                    descLabel.AutomaticSize = Enum.AutomaticSize.Y
                    descLabel.BackgroundTransparency = 1
                    descLabel.Font = Enum.Font.Gotham
                    descLabel.Text = line
                    descLabel.TextSize = 12
                    descLabel.TextTransparency = 0.3
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextWrapped = true
                    descLabel.Parent = textContainer
                    AddToRegistry(descLabel, "TextColor3", "Text")
                    table.insert(descLabels, descLabel)
                end
                textLayout:Arrange()
            end
            function self.SetIcon(newIcon, newColor)
                iconImg.Image = formatIcon(newIcon)
                if newColor then
                    iconImg.ImageColor3 = newColor
                end
            end
            function self.SetVisible(state)
                imageFrame.Visible = state
            end

            return self
        end

        return child
    end

    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        TabBtn.Selected = false

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 3, 0.65, 0)
        TabBar.Position = UDim2.new(0, 0, 0.175, 0)
        TabBar.BackgroundTransparency = 1
        TabBar.BorderSizePixel = 0
        TabBar.Parent = TabBtn
        Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
        AddToRegistry(TabBar, "BackgroundColor3", "Accent")

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.Parent = ContentFrame

        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 28, 0, 28)
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then
                TabIcon.Image = "rbxassetid://" .. icon
            else
                TabIcon.Image = icon
            end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
        end

        local TabText = Instance.new("TextLabel")
        local textWidth = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(200, 32)).X
        TabText.Size = UDim2.new(0, textWidth, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 158)
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = ContentFrame

        TabBtn.MouseEnter:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(180, 180, 188)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(150, 150, 158)}, 0.15)
            end
        end)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(80,80,85)
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        Page.Visible = false
        Page.Parent = PageContainer

        local ContentHolder = Instance.new("Frame")
        ContentHolder.Name = "Content"
        ContentHolder.Size = UDim2.new(1, 0, 0, 0)
        ContentHolder.AutomaticSize = Enum.AutomaticSize.Y
        ContentHolder.BackgroundTransparency = 1
        ContentHolder.Parent = Page

        local HolderPadding = Instance.new("UIPadding")
        HolderPadding.PaddingRight = UDim.new(0, 2)
        HolderPadding.Parent = ContentHolder

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 10)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = ContentHolder

        local function updateCanvas()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.spawn(function() task.wait(); updateCanvas() end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    v.Selected = false
                    Tween(v, {BackgroundTransparency = 1, BackgroundColor3 = CurrentTheme.Top})
                    local content = v:FindFirstChild("ContentFrame")
                    if content then
                        local textLabel = content:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            Tween(textLabel, {TextColor3 = Color3.fromRGB(150, 150, 158)})
                        end
                    end
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then
                        Tween(bar, {BackgroundTransparency = 1})
                    end
                end
            end
            Page.Visible = true
            TabBtn.Selected = true
            Tween(TabBtn, {BackgroundTransparency = 0.05, BackgroundColor3 = CurrentTheme.Top})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
            Tween(TabBar, {BackgroundTransparency = 0})
        end)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabBtn.Selected = true
            TabBtn.BackgroundTransparency = 0.05
            TabBtn.BackgroundColor3 = CurrentTheme.Top
            TabText.TextColor3 = CurrentTheme.Text
            TabBar.BackgroundTransparency = 0
        end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local Elements = {}
        function Elements:Section(text, icons, defaultOpen)
            return createSection(ContentHolder, text, icons, defaultOpen)
        end

        Elements.ColorPicker = function(_, pickerText, default, callback)
            local section = createSection(ContentHolder, pickerText, nil, true)
            return section.ColorPicker(pickerText, default, callback)
        end

        return Elements
    end

    function Window:DualTab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        TabBtn.Selected = false

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 3, 0.65, 0)
        TabBar.Position = UDim2.new(0, 0, 0.175, 0)
        TabBar.BackgroundTransparency = 1
        TabBar.BorderSizePixel = 0
        TabBar.Parent = TabBtn
        Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
        AddToRegistry(TabBar, "BackgroundColor3", "Accent")

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame

        local Padding = Instance.new("UIPadding")
        Padding.PaddingLeft = UDim.new(0, 10)
        Padding.Parent = ContentFrame

        if icon then
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 28, 0, 28)
            TabIcon.BackgroundTransparency = 1
            if tonumber(icon) then
                TabIcon.Image = "rbxassetid://" .. icon
            else
                TabIcon.Image = icon
            end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
        end

        local TabText = Instance.new("TextLabel")
        local textWidth = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(200, 32)).X
        TabText.Size = UDim2.new(0, textWidth, 1, 0)
        TabText.BackgroundTransparency = 1
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = Color3.fromRGB(150, 150, 158)
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = ContentFrame

        TabBtn.MouseEnter:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(180, 180, 188)}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not TabBtn.Selected then
                Tween(TabText, {TextColor3 = Color3.fromRGB(150, 150, 158)}, 0.15)
            end
        end)

        local PageFrame = Instance.new("Frame")
        PageFrame.Size = UDim2.new(1, 0, 1, 0)
        PageFrame.BackgroundTransparency = 1
        PageFrame.Visible = false
        PageFrame.Parent = PageContainer

        local Columns = Instance.new("Frame")
        Columns.Size = UDim2.new(1, 0, 1, 0)
        Columns.BackgroundTransparency = 1
        Columns.Parent = PageFrame

        local ColumnsLayout = Instance.new("UIListLayout")
        ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
        ColumnsLayout.Padding = UDim.new(0, 10)
        ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ColumnsLayout.Parent = Columns

        local ColumnsPadding = Instance.new("UIPadding")
        ColumnsPadding.PaddingLeft = UDim.new(0, 5)
        ColumnsPadding.PaddingRight = UDim.new(0, 5)
        ColumnsPadding.Parent = Columns

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Name = "LeftColumn"
        LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollingDirection = Enum.ScrollingDirection.Y
        LeftColumn.ScrollBarThickness = 2
        LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(80,80,85)
        LeftColumn.BottomImage = ""
        LeftColumn.TopImage = ""
        LeftColumn.Parent = Columns

        local LeftHolder = Instance.new("Frame")
        LeftHolder.Name = "Content"
        LeftHolder.Size = UDim2.new(1, 0, 0, 0)
        LeftHolder.AutomaticSize = Enum.AutomaticSize.Y
        LeftHolder.BackgroundTransparency = 1
        LeftHolder.Parent = LeftColumn

        local LeftHolderPadding = Instance.new("UIPadding")
        LeftHolderPadding.PaddingRight = UDim.new(0, 2)
        LeftHolderPadding.Parent = LeftHolder

        local LeftList = Instance.new("UIListLayout")
        LeftList.Padding = UDim.new(0, 10)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Parent = LeftHolder

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Name = "RightColumn"
        RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollingDirection = Enum.ScrollingDirection.Y
        RightColumn.ScrollBarThickness = 2
        RightColumn.ScrollBarImageColor3 = Color3.fromRGB(80,80,85)
        RightColumn.BottomImage = ""
        RightColumn.TopImage = ""
        RightColumn.Parent = Columns

        local RightHolder = Instance.new("Frame")
        RightHolder.Name = "Content"
        RightHolder.Size = UDim2.new(1, 0, 0, 0)
        RightHolder.AutomaticSize = Enum.AutomaticSize.Y
        RightHolder.BackgroundTransparency = 1
        RightHolder.Parent = RightColumn

        local RightHolderPadding = Instance.new("UIPadding")
        RightHolderPadding.PaddingRight = UDim.new(0, 2)
        RightHolderPadding.Parent = RightHolder

        local RightList = Instance.new("UIListLayout")
        RightList.Padding = UDim.new(0, 10)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Parent = RightHolder

        local function updateLeftCanvas()
            LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftList.AbsoluteContentSize.Y + 10)
        end
        local function updateRightCanvas()
            RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightList.AbsoluteContentSize.Y + 10)
        end
        LeftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftCanvas)
        RightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightCanvas)
        task.spawn(function() task.wait(); updateLeftCanvas(); updateRightCanvas() end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(PageContainer:GetChildren()) do
                v.Visible = false
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    v.Selected = false
                    Tween(v, {BackgroundTransparency = 1, BackgroundColor3 = CurrentTheme.Top})
                    local content = v:FindFirstChild("ContentFrame")
                    if content then
                        local textLabel = content:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            Tween(textLabel, {TextColor3 = Color3.fromRGB(150, 150, 158)})
                        end
                    end
                    local bar = v:FindFirstChildOfClass("Frame")
                    if bar then
                        Tween(bar, {BackgroundTransparency = 1})
                    end
                end
            end
            PageFrame.Visible = true
            TabBtn.Selected = true
            Tween(TabBtn, {BackgroundTransparency = 0.05, BackgroundColor3 = CurrentTheme.Top})
            Tween(TabText, {TextColor3 = CurrentTheme.Text})
            Tween(TabBar, {BackgroundTransparency = 0})
        end)

        if firstTab then
            firstTab = false
            PageFrame.Visible = true
            TabBtn.Selected = true
            TabBtn.BackgroundTransparency = 0.05
            TabBtn.BackgroundColor3 = CurrentTheme.Top
            TabText.TextColor3 = CurrentTheme.Text
            TabBar.BackgroundTransparency = 0
        end

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        local DualElements = {}
        function DualElements:section(side, text, icons, defaultOpen)
            local holder = side == "Left" and LeftHolder or RightHolder
            return createSection(holder, text, icons, defaultOpen)
        end

        return DualElements
    end

    return Window
end

return Fenglib