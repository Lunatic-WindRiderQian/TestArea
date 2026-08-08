local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Fenglib = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local RainbowSpeed = 1.0
local Registry = {} 
local ConfigObjects = {} 
local ThemeListeners = {}
local WindowCleanup = {}

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
    Dark   = {Main = Color3.fromRGB(13, 13, 13), Top = Color3.fromRGB(28, 28, 30), Text = Color3.fromRGB(240, 240, 245), Accent = Color3.fromRGB(80, 140, 255), Stroke = Color3.fromRGB(45, 45, 48), SubText = Color3.fromRGB(160, 160, 170), Element = Color3.fromRGB(45, 45, 50), Hover = Color3.fromRGB(60, 60, 70)},
    White  = {Main = Color3.fromRGB(243, 243, 243), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(20, 20, 20), Accent = Color3.fromRGB(0, 100, 210), Stroke = Color3.fromRGB(220, 220, 225), SubText = Color3.fromRGB(100, 100, 110), Element = Color3.fromRGB(235, 235, 240), Hover = Color3.fromRGB(210, 210, 220)},
    Purple = {Main = Color3.fromRGB(18, 15, 22), Top = Color3.fromRGB(30, 25, 35), Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255), Stroke = Color3.fromRGB(50, 45, 60), SubText = Color3.fromRGB(180, 170, 200), Element = Color3.fromRGB(50, 45, 60), Hover = Color3.fromRGB(70, 60, 85)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28), Top = Color3.fromRGB(25, 32, 45), Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255), Stroke = Color3.fromRGB(45, 55, 75), SubText = Color3.fromRGB(150, 170, 200), Element = Color3.fromRGB(45, 55, 75), Hover = Color3.fromRGB(65, 80, 105)},
    Red    = {Main = Color3.fromRGB(22, 12, 12), Top = Color3.fromRGB(35, 20, 20), Text = Color3.fromRGB(255, 240, 240), Accent = Color3.fromRGB(255, 80, 80), Stroke = Color3.fromRGB(60, 40, 40), SubText = Color3.fromRGB(200, 160, 160), Element = Color3.fromRGB(60, 40, 40), Hover = Color3.fromRGB(85, 55, 55)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12), Top = Color3.fromRGB(35, 35, 20), Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80), Stroke = Color3.fromRGB(60, 60, 40), SubText = Color3.fromRGB(200, 190, 160), Element = Color3.fromRGB(60, 60, 40), Hover = Color3.fromRGB(85, 85, 55)},
    Green  = {Main = Color3.fromRGB(12, 22, 15), Top = Color3.fromRGB(20, 35, 25), Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130), Stroke = Color3.fromRGB(40, 60, 50), SubText = Color3.fromRGB(160, 200, 180), Element = Color3.fromRGB(40, 60, 50), Hover = Color3.fromRGB(55, 85, 70)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeKey)
    local val = CurrentTheme[themeKey]
    if val == nil then
        val = Themes.Dark[themeKey]
        if val == nil then
            warn("Theme key '" .. tostring(themeKey) .. "' not found, using fallback white.")
            val = Color3.new(1, 1, 1)
        end
    end
    table.insert(Registry, {Object = obj, Property = prop, Type = themeKey})
    obj[prop] = val
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

-- ===== MediaManager =====
local MediaManager = {}
MediaManager.Folder = "FengMediaCache"

function MediaManager:SetFolder(f)
    self.Folder = f
end

function MediaManager:_init(sub)
    pcall(function()
        if not isfolder(self.Folder) then makefolder(self.Folder) end
        local p = self.Folder .. "/" .. sub
        if not isfolder(p) then makefolder(p) end
    end)
end

function MediaManager:_rname(ext)
    local s = "abcdefghijklmnopqrstuvwxyz0123456789"
    local n = ""
    for _=1,12 do local i=math.random(1,#s); n=n..s:sub(i,i) end
    return n.."."..ext
end

function MediaManager:Audio(src, noDownload)
    if type(src)~="string" or src=="" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if not src:match("^https?://") then return "" end
    local ext = (src:match("%.(%a+)%??[^/]*$") or "mp3"):lower()
    if not ({mp3=1,ogg=1,wav=1,flac=1})[ext] then ext="mp3" end
    self:_init("audio")
    local dir = self.Folder.."/audio"
    local mapPath = dir.."/_map.json"
    local hs = HttpService
    local map = {}
    pcall(function()
        if isfile(mapPath) then
            local ok,d = pcall(hs.JSONDecode, hs, readfile(mapPath))
            if ok and type(d)=="table" then map=d end
        end
    end)
    local key = tostring(#src).."_"..src:sub(1,40):gsub("[^%w]","")
    if map[key] then
        local cp = dir.."/"..map[key]
        if isfile(cp) then
            local ok,a = pcall(getcustomasset, cp)
            if ok and a and a~="" then return a end
        end
        map[key] = nil
    end
    if noDownload then return nil end
    local fname = self:_rname(ext)
    local path  = dir.."/"..fname
    local body  = nil
    local reqOk = pcall(function()
        local req = (syn and syn.request) or http_request or request
        local r = req({Url=src,Method="GET",Headers={["User-Agent"]="Roblox/WinInet"}})
        if r and r.Body and #r.Body > 128 then
            local peek = r.Body:sub(1,15):lower()
            if peek:find("<!doctype") or peek:find("<html") then return end
            body = r.Body
            writefile(path, body)
        end
    end)
    if reqOk and body and isfile(path) then
        local ok2,a = pcall(getcustomasset, path)
        if ok2 and a and a~="" then
            map[key] = fname
            pcall(function()
                local ok3,enc = pcall(hs.JSONEncode, hs, map)
                if ok3 then writefile(mapPath, enc) end
            end)
            return a
        end
    end
    return ""
end

function MediaManager:Video(src)
    if type(src)~="string" or src=="" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if not src:match("^https?://") then return "" end
    local ext = (src:match("%.(%a+)%??[^/]*$") or "webm"):lower()
    if not ({webm=1,mp4=1,ogg=1,mov=1})[ext] then ext="webm" end
    if ext == "mp4" or ext == "mov" then ext = "webm" end
    self:_init("videos")
    local dir = self.Folder.."/videos"
    local mapPath = dir.."/_map.json"
    local hs = HttpService
    local map = {}
    pcall(function()
        if isfile(mapPath) then
            local ok,d = pcall(hs.JSONDecode, hs, readfile(mapPath))
            if ok and type(d)=="table" then map=d end
        end
    end)
    local key = tostring(#src).."_"..src:sub(1,40):gsub("[^%w]","")
    if map[key] then
        local cp = dir.."/"..map[key]
        if isfile(cp) then
            local ok,a = pcall(getcustomasset, cp)
            if ok and a and a~="" then return a end
        end
        map[key] = nil
    end
    local fname = self:_rname(ext)
    local path  = dir.."/"..fname
    local body  = nil
    local reqOk = pcall(function()
        local req = (syn and syn.request) or http_request or request
        local r = req({Url=src,Method="GET",Headers={["User-Agent"]="Roblox/WinInet"}})
        if r and r.Body and #r.Body > 512 then
            local peek = r.Body:sub(1,15):lower()
            if peek:find("<!doctype") or peek:find("<html") then return end
            body = r.Body
            writefile(path, body)
        end
    end)
    if reqOk and body and isfile(path) then
        local ok2,a = pcall(getcustomasset, path)
        if ok2 and a and a~="" then
            map[key] = fname
            pcall(function()
                local ok3,enc = pcall(hs.JSONEncode, hs, map)
                if ok3 then writefile(mapPath, enc) end
            end)
            return a
        end
    end
    return ""
end

function MediaManager:Image(src)
    if type(src)~="string" or src=="" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if not src:match("^https?://") then return "" end
    local ext = (src:match("%.(%a+)%??[^/]*$") or "png"):lower()
    if not ({png=1,jpg=1,jpeg=1,webp=1,gif=1})[ext] then ext="png" end
    self:_init("images")
    local dir = self.Folder.."/images"
    local mapPath = dir.."/_map.json"
    local hs = HttpService
    local map = {}
    pcall(function()
        if isfile(mapPath) then
            local ok,d = pcall(hs.JSONDecode, hs, readfile(mapPath))
            if ok and type(d)=="table" then map=d end
        end
    end)
    local key = tostring(#src).."_"..src:sub(1,40):gsub("[^%w]","")
    if map[key] then
        local cp = dir.."/"..map[key]
        if isfile(cp) then
            local ok,a = pcall(getcustomasset, cp)
            if ok and a and a~="" then return a end
        end
        map[key] = nil
    end
    local fname = self:_rname(ext)
    local path = dir.."/"..fname
    local body = nil
    local reqOk = pcall(function()
        local req = (syn and syn.request) or http_request or request
        local r = req({Url=src,Method="GET",Headers={["User-Agent"]="Roblox/WinInet"}})
        if r and r.Body and #r.Body > 128 then
            local peek = r.Body:sub(1,15):lower()
            if peek:find("<!doctype") or peek:find("<html") then return end
            body = r.Body
            writefile(path, body)
        end
    end)
    if reqOk and body and isfile(path) then
        local ok2,a = pcall(getcustomasset, path)
        if ok2 and a and a~="" then
            map[key] = fname
            pcall(function()
                local ok3,enc = pcall(hs.JSONEncode, hs, map)
                if ok3 then writefile(mapPath, enc) end
            end)
            return a
        end
    end
    return ""
end
-- ===== 结束 MediaManager =====

local function createSectionBuilder(parent, contentContainer, elementWidth, windowCount, window)
    local win = window
    local padding = parent:FindFirstChild("SectionPadding")
    if not padding then
        padding = Instance.new("UIPadding")
        padding.Name = "SectionPadding"
        padding.PaddingLeft = UDim.new(0.04, 0)
        padding.Parent = parent
    end

    local function styleContainer(frame)
        frame.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1.5
        stroke.Color = CurrentTheme.Stroke
        stroke.Parent = frame
        table.insert(ThemeListeners, function()
            stroke.Color = CurrentTheme.Stroke
        end)
    end

    local function createSection(text, icons, defaultOpen)
        local titleText = ""
        local subtitleText = nil
        local iconAsset = nil
        if defaultOpen == nil then defaultOpen = true end

        if type(text) == "table" then
            local config = text
            titleText = config.Name or ""
            subtitleText = config.SubName
            iconAsset = config.Logo
            if config.open ~= nil then defaultOpen = config.open end
        else
            titleText = text or ""
            if type(icons) == "table" then
                subtitleText = icons.subtitle
                iconAsset = icons.icon
            elseif type(icons) == "string" then
                subtitleText = icons
            end
        end

        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(0.96, 0, 0, 46)
        sectionFrame.AnchorPoint = Vector2.new(0, 0)
        sectionFrame.Position = UDim2.new(0, 0, 0, 0)
        sectionFrame.BackgroundTransparency = 0.65
        sectionFrame.ClipsDescendants = true
        sectionFrame.Parent = parent
        local mainCorner = Instance.new("UICorner", sectionFrame)
        mainCorner.CornerRadius = UDim.new(0, 4)
        AddToRegistry(sectionFrame, "BackgroundColor3", "Main")

        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 46)
        titleBar.BackgroundTransparency = 0.65
        titleBar.ClipsDescendants = true
        titleBar.Parent = sectionFrame
        local titleBarCorner = Instance.new("UICorner", titleBar)
        titleBarCorner.CornerRadius = UDim.new(0, 4)
        AddToRegistry(titleBar, "BackgroundColor3", "Stroke")

        local topBg = Instance.new("Frame")
        topBg.Size = UDim2.new(1, -2, 1, -2)
        topBg.Position = UDim2.new(0, 1, 0, 1)
        topBg.BackgroundTransparency = 0.65
        topBg.ClipsDescendants = true
        topBg.Parent = titleBar
        local topBgCorner = Instance.new("UICorner", topBg)
        topBgCorner.CornerRadius = UDim.new(0, 4)
        AddToRegistry(topBg, "BackgroundColor3", "Top")

        local leftOffset = 16
        if iconAsset then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 32, 0, 32)
            icon.Position = UDim2.new(0, 10, 0.5, -16)
            icon.BackgroundTransparency = 1
            if tonumber(iconAsset) then
                icon.Image = "rbxassetid://" .. iconAsset
            else
                icon.Image = iconAsset
            end
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = icon
            icon.Parent = topBg
            AddToRegistry(icon, "ImageColor3", "Text")
            leftOffset = 50
        end

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -80, 0, 19)
        if subtitleText then
            titleLabel.Position = UDim2.new(0, leftOffset, 0, 4)
        else
            titleLabel.Position = UDim2.new(0, leftOffset, 0, 14)
        end
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = titleText
        titleLabel.TextSize = 15
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = topBg
        AddToRegistry(titleLabel, "TextColor3", "Text")

        if subtitleText then
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(1, -80, 0, 17)
            subLabel.Position = UDim2.new(0, leftOffset, 0, 25)
            subLabel.BackgroundTransparency = 1
            subLabel.Font = Enum.Font.Gotham
            subLabel.Text = subtitleText
            subLabel.TextSize = 12
            subLabel.TextTransparency = 0.5
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.Parent = topBg
            AddToRegistry(subLabel, "TextColor3", "Text")
        end

        local open = defaultOpen
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 42, 0, 22)
        toggleBtn.Position = UDim2.new(1, -52, 0.5, -11)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Text = ""
        toggleBtn.Parent = topBg
        toggleBtn.ZIndex = 3

        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(1, 0, 1, 0)
        switchBg.BackgroundColor3 = open and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        switchBg.Parent = toggleBtn
        Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

        local swStroke = Instance.new("UIStroke")
        swStroke.Thickness = 1
        swStroke.Transparency = 0.6
        swStroke.Parent = switchBg
        AddToRegistry(swStroke, "Color", "Stroke")

        local leftLabel = Instance.new("TextLabel")
        leftLabel.Size = UDim2.new(0.5, 0, 1, 0)
        leftLabel.Position = UDim2.new(0, 4, 0, 0)
        leftLabel.BackgroundTransparency = 1
        leftLabel.Font = Enum.Font.GothamBold
        leftLabel.Text = "I"
        leftLabel.TextSize = 12
        leftLabel.TextColor3 = open and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
        leftLabel.TextTransparency = open and 0 or 0.6
        leftLabel.TextXAlignment = Enum.TextXAlignment.Left
        leftLabel.TextYAlignment = Enum.TextYAlignment.Center
        leftLabel.Parent = switchBg

        local rightLabel = Instance.new("TextLabel")
        rightLabel.Size = UDim2.new(0.5, 0, 1, 0)
        rightLabel.Position = UDim2.new(0.5, -4, 0, 0)
        rightLabel.BackgroundTransparency = 1
        rightLabel.Font = Enum.Font.GothamBold
        rightLabel.Text = "O"
        rightLabel.TextSize = 12
        rightLabel.TextColor3 = open and Color3.fromRGB(150, 150, 150) or Color3.new(1, 1, 1)
        rightLabel.TextTransparency = open and 0.6 or 0
        rightLabel.TextXAlignment = Enum.TextXAlignment.Right
        rightLabel.TextYAlignment = Enum.TextYAlignment.Center
        rightLabel.Parent = switchBg

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = open and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.Parent = switchBg
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function updateSwitch(animate)
            local targetBg = open and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            local dotTarget = open and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            local leftColor = open and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
            local rightColor = open and Color3.fromRGB(150, 150, 150) or Color3.new(1, 1, 1)
            local leftTrans = open and 0 or 0.6
            local rightTrans = open and 0.6 or 0

            if animate then
                Tween(switchBg, { BackgroundColor3 = targetBg })
                Tween(dot, { Position = dotTarget })
                Tween(leftLabel, { TextColor3 = leftColor, TextTransparency = leftTrans })
                Tween(rightLabel, { TextColor3 = rightColor, TextTransparency = rightTrans })
            else
                switchBg.BackgroundColor3 = targetBg
                dot.Position = dotTarget
                leftLabel.TextColor3 = leftColor
                leftLabel.TextTransparency = leftTrans
                rightLabel.TextColor3 = rightColor
                rightLabel.TextTransparency = rightTrans
            end
        end

        updateSwitch(false)

        local contentContainerSection = Instance.new("Frame")
        contentContainerSection.Size = UDim2.new(1, -2, 0, 0)
        contentContainerSection.Position = UDim2.new(0, 1, 0, 46)
        contentContainerSection.BackgroundTransparency = 0.65
        contentContainerSection.ClipsDescendants = false
        contentContainerSection.Parent = sectionFrame
        AddToRegistry(contentContainerSection, "BackgroundColor3", "Main")
        
        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 4)
        contentCorner.Parent = contentContainerSection
        
        local contentStroke = Instance.new("UIStroke")
        contentStroke.Thickness = 1
        contentStroke.Transparency = 0.5
        contentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        contentStroke.Parent = contentContainerSection
        AddToRegistry(contentStroke, "Color", "Stroke")

        local contentHolder = Instance.new("Frame")
        contentHolder.Size = UDim2.new(1, -20, 0, 0)
        contentHolder.Position = UDim2.new(0, 10, 0, 4)
        contentHolder.BackgroundTransparency = 1
        contentHolder.AutomaticSize = Enum.AutomaticSize.None
        contentHolder.ClipsDescendants = false
        contentHolder.Parent = contentContainerSection

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentHolder

        local bottomPadding = Instance.new("Frame")
        bottomPadding.Size = UDim2.new(1, 0, 0, 4)
        bottomPadding.BackgroundTransparency = 1
        bottomPadding.Parent = contentHolder

        local currentContentTween, currentSectionTween, currentHolderTween, currentBgTween

        local function getContentHeight()
            return contentLayout.AbsoluteContentSize.Y
        end

        local function updateSectionHeight(instant)
            local actualContentHeight = getContentHeight()
            local targetContentHeight = open and math.max(0, actualContentHeight) or 0
            local targetContainerHeight = targetContentHeight + 16
            local targetSectionHeight = 46 + targetContainerHeight

            if currentContentTween then currentContentTween:Cancel() end
            if currentSectionTween then currentSectionTween:Cancel() end
            if currentHolderTween then currentHolderTween:Cancel() end
            if currentBgTween then currentBgTween:Cancel() end

            local tweenInfo = TweenInfo.new(instant and 0 or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            if open then
                contentContainerSection.Visible = true
                contentHolder.Visible = true
                
                currentBgTween = TweenService:Create(contentContainerSection, tweenInfo, {
                    BackgroundTransparency = 0.65
                })
                currentContentTween = TweenService:Create(contentContainerSection, tweenInfo, {
                    Size = UDim2.new(1, -2, 0, targetContainerHeight)
                })
                currentHolderTween = TweenService:Create(contentHolder, tweenInfo, {
                    Size = UDim2.new(1, -20, 0, math.max(0, targetContentHeight))
                })
                currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {
                    Size = UDim2.new(0.96, 0, 0, targetSectionHeight)
                })
            else
                currentBgTween = TweenService:Create(contentContainerSection, tweenInfo, {
                    BackgroundTransparency = 1
                })
                currentContentTween = TweenService:Create(contentContainerSection, tweenInfo, {
                    Size = UDim2.new(1, -2, 0, 0)
                })
                currentHolderTween = TweenService:Create(contentHolder, tweenInfo, {
                    Size = UDim2.new(1, -20, 0, 0)
                })
                currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {
                    Size = UDim2.new(0.96, 0, 0, 46)
                })
                
                task.delay((instant and 0 or 0.3) + 0.05, function()
                    if not open and contentContainerSection then
                        contentContainerSection.Visible = false
                        contentHolder.Visible = false
                    end
                end)
            end

            currentBgTween:Play()
            currentContentTween:Play()
            currentHolderTween:Play()
            currentSectionTween:Play()
        end

        task.spawn(function()
            task.wait()
            updateSectionHeight(true)
        end)

        local function toggleSection()
            open = not open
            updateSwitch(true)
            updateSectionHeight(false)
        end

        toggleBtn.MouseButton1Click:Connect(toggleSection)
        topBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggleSection()
            end
        end)

        table.insert(ThemeListeners, function()
            swStroke.Color = CurrentTheme.Stroke
        end)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if open then
                updateSectionHeight(false)
            end
        end)

        contentHolder.ChildAdded:Connect(function()
            task.wait(0.05)
            if open then
                updateSectionHeight(false)
            end
        end)

        local child = {}

        child.Button = function(_, config)
            local btnText = config.Name or config.Text or ""
            local callback = config.Callback or function() end

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 42)
            Tile.Parent = contentHolder
            styleContainer(Tile)
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 4)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = btnText
            TitleLbl.Size = UDim2.new(1, -30, 1, 0)
            TitleLbl.Position = UDim2.new(0, 15, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 15, 0, 15)
            Icon.Position = UDim2.new(1, -25, 0.5, -7.5)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://10709791437"
            Icon.ImageTransparency = 0.5
            Icon.Parent = Tile
            AddToRegistry(Icon, "ImageColor3", "Text")

            ClickBtn.MouseEnter:Connect(function()
                Tween(Tile, {BackgroundTransparency = 0.05}, 0.18)
            end)
            ClickBtn.MouseLeave:Connect(function()
                Tween(Tile, {BackgroundTransparency = 1}, 0.18)
            end)
            ClickBtn.MouseButton1Down:Connect(function()
                Tween(Tile, {BackgroundTransparency = 0.2}, 0.1)
            end)
            ClickBtn.MouseButton1Up:Connect(function()
                Tween(Tile, {BackgroundTransparency = 0.05}, 0.1)
            end)
            ClickBtn.MouseButton1Click:Connect(function()
                callback()
            end)

            local self = {}
            function self.UpdateText(newText) TitleLbl.Text = newText end
            function self.SetVisible(state) Tile.Visible = state end
            return self
        end

        child.Toggle = function(_, config)
            local toggleText = config.Name or ""
            local Enabled = config.Value or false
            local callback = config.Callback or function() end
            local controlId = toggleText .. "_" .. tostring(#Registry)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 42)
            Tile.Parent = contentHolder
            styleContainer(Tile)
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 4)
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
            Switch.BackgroundTransparency = 1
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local SwStroke = Instance.new("UIStroke")
            SwStroke.Thickness = 1
            SwStroke.Transparency = 0.6
            SwStroke.Parent = Switch
            AddToRegistry(SwStroke, "Color", "Stroke")

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Dot.Parent = Switch
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Dot, "BackgroundColor3", "Accent")

            ConfigObjects[controlId] = {
                Type = "Toggle",
                Value = Enabled,
                Set = function(val)
                    Enabled = val
                    Dot.Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                    callback(Enabled)
                end
            }

            local function Update()
                Tween(Dot, {Position = Enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
                ConfigObjects[controlId].Value = Enabled
                callback(Enabled)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                Update()
            end)
        end

        child.Slider = function(_, config)
            local sliderText = config.Name or ""
            local valueTable = config.Value or {}
            local min = valueTable.Min
            local max = valueTable.Max
            local default = valueTable.Default
            local callback = config.Callback or function() end
            local options = config.Options or {}
            local unlimited = (min == nil and max == nil)
            min = tonumber(min)
            max = tonumber(max)
            local Rounding = config.Rounding or 0
            local Val = tonumber(default) or (min or 0)
            local controlId = sliderText .. "_" .. tostring(#Registry)

            local tileH = unlimited and 42 or 60
            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, tileH)
            Tile.Parent = contentHolder
            styleContainer(Tile)
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 4)
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

            local white = Color3.new(1, 1, 1)
            local dragging = false

            local function Round(n, decimals)
                local factor = 10 ^ decimals
                return math.floor(n * factor + 0.5) / factor
            end

            local function UpdateSlider(val)
                if unlimited then
                    Val = val
                    Num.Text = tostring(Val)
                    if ConfigObjects[controlId] then ConfigObjects[controlId].Value = Val end
                    callback(Val)
                    return
                end
                val = math.clamp(val, min, max)
                val = Round(val, Rounding)
                local ratio = (val - min) / (max - min)
                TweenService:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = UDim2.new(ratio, 0, 0.5, 0)}):Play()
                Num.Text = tostring(val)
                Val = val
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = val end
                callback(val)
                return val
            end

            local function GetValueFromInput(input)
                if unlimited or not Track then return Val end
                local absX = Track.AbsolutePosition.X
                local absW = Track.AbsoluteSize.X
                local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
                return ratio * (max - min) + min
            end

            local function SetDragging(state)
                dragging = state
                if state then
                    TweenService:Create(Num, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 15}):Play()
                    TweenService:Create(Num, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = CurrentTheme.Accent}):Play()
                    TweenService:Create(TitleLbl, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = CurrentTheme.Accent}):Play()
                else
                    TweenService:Create(Num, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 12}):Play()
                    TweenService:Create(Num, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = white}):Play()
                    TweenService:Create(TitleLbl, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = white}):Play()
                end
            end

            local function SetFocused(state)
                if state then
                    TweenService:Create(Num, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = CurrentTheme.Accent}):Play()
                    TweenService:Create(TitleLbl, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = CurrentTheme.Accent}):Play()
                else
                    TweenService:Create(Num, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = white}):Play()
                    TweenService:Create(TitleLbl, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = white}):Play()
                end
            end

            if Bar then
                Bar.InputBegan:Connect(function(input)
                    if unlimited then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        SetDragging(true)
                        UpdateSlider(GetValueFromInput(input))
                    end
                end)

                Bar.InputEnded:Connect(function(input)
                    if unlimited then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        SetDragging(false)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if unlimited then return end
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(GetValueFromInput(input))
                    end
                end)
            end

            Num.FocusLost:Connect(function()
                Tween(NumStroke, {Transparency = 0.75}, 0.15)
                SetFocused(false)
                local typed = tonumber(Num.Text)
                if typed then
                    UpdateSlider(typed)
                else
                    Num.Text = tostring(Val)
                end
            end)

            Num.Focused:Connect(function()
                SetFocused(true)
            end)

            ConfigObjects[controlId] = {Type = "Slider", Value = Val, Set = function(val) UpdateSlider(tonumber(val) or Val) end}

            table.insert(ThemeListeners, function()
                if Fill then Fill.BackgroundColor3 = CurrentTheme.Accent end
                if Track then Track.BackgroundColor3 = CurrentTheme.Stroke end
                Num.TextColor3 = CurrentTheme.Accent
            end)

            UpdateSlider(Val)
        end

        child.Dropdown = function(_, config)
            local dropText = config.Name or ""
            local options = config.Values or {}
            local selectedValue = config.Value
            local multi = config.Multi == true
            local callback = config.Callback or function() end
            local controlId = dropText .. "_" .. tostring(#Registry)

            local selected = multi and {} or nil
            local function initSelected()
                if multi then
                    if type(selectedValue) == "table" then
                        selected = {}
                        for _, v in ipairs(selectedValue) do
                            if table.find(options, v) then
                                table.insert(selected, v)
                            end
                        end
                    else
                        selected = {}
                    end
                else
                    if selectedValue and table.find(options, selectedValue) then
                        selected = selectedValue
                    else
                        selected = options[1] or ""
                    end
                end
            end
            initSelected()

            local Dropped = false

            local Btn = Instance.new("Frame")
            Btn.Size = UDim2.new(1, 0, 0, 42)
            Btn.Parent = contentHolder
            styleContainer(Btn)
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
            AddToRegistry(Btn, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Btn

            local Lbl = Instance.new("TextLabel")
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
            Container.Parent = contentHolder
            styleContainer(Container)
            Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 4)
            AddToRegistry(Container, "BackgroundColor3", "Top")

            local List = Instance.new("UIListLayout")
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container

            local function updateLabel()
                if multi then
                    if #selected == 0 then
                        Lbl.Text = dropText .. ":  (none)"
                    else
                        Lbl.Text = dropText .. ": " .. table.concat(selected, ", ")
                    end
                else
                    Lbl.Text = dropText .. ": " .. tostring(selected)
                end
            end
            updateLabel()

            local optionButtons = {}
            local function rebuildOptions(optList)
                for _, child in ipairs(Container:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                optionButtons = {}

                for _, opt in ipairs(optList) do
                    local O = Instance.new("TextButton")
                    O.Size = UDim2.new(1, 0, 0, 34)
                    O.Text = ""
                    O.BackgroundTransparency = 1
                    O.AutoButtonColor = false
                    O.BackgroundColor3 = CurrentTheme.Top
                    O.Parent = Container
                    O.TextColor3 = CurrentTheme.Text

                    local check = Instance.new("Frame")
                    check.Size = UDim2.new(0, 16, 0, 16)
                    check.Position = UDim2.new(0, 10, 0.5, -8)
                    check.BackgroundColor3 = CurrentTheme.Accent
                    check.BackgroundTransparency = 1
                    check.ZIndex = 1
                    check.Parent = O
                    local checkCorner = Instance.new("UICorner")
                    checkCorner.CornerRadius = UDim.new(0, 4)
                    checkCorner.Parent = check
                    local checkStroke = Instance.new("UIStroke")
                    checkStroke.Thickness = 1.5
                    checkStroke.Color = CurrentTheme.Accent
                    checkStroke.Transparency = 0.7
                    checkStroke.Parent = check

                    local checkGrad = Instance.new("UIGradient")
                    checkGrad.Rotation = 0
                    checkGrad.Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent)
                    checkGrad.Transparency = NumberSequence.new(1)
                    checkGrad.Parent = check

                    local checkMark = Instance.new("ImageLabel")
                    checkMark.Size = UDim2.new(0, 12, 0, 12)
                    checkMark.Position = UDim2.new(0.5, 0, 0.5, 0)
                    checkMark.AnchorPoint = Vector2.new(0.5, 0.5)
                    checkMark.BackgroundTransparency = 1
                    checkMark.Image = "rbxassetid://16633109272"
                    checkMark.ImageTransparency = 1
                    checkMark.Parent = check
                    AddToRegistry(checkMark, "ImageColor3", "Accent")

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, -40, 1, 0)
                    label.Position = UDim2.new(0, 36, 0, 0)
                    label.BackgroundTransparency = 1
                    label.Font = Enum.Font.GothamMedium
                    label.Text = opt
                    label.TextSize = 12
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Parent = O
                    AddToRegistry(label, "TextColor3", "Text")

                    O.MouseEnter:Connect(function()
                        Tween(O, {BackgroundTransparency = 0.1}, 0.15)
                    end)
                    O.MouseLeave:Connect(function()
                        Tween(O, {BackgroundTransparency = 1}, 0.15)
                    end)

                    local optData = {
                        button = O,
                        label = label,
                        check = check,
                        checkGrad = checkGrad,
                        checkStroke = checkStroke,
                        checkMark = checkMark,
                        value = opt,
                        selected = false
                    }
                    table.insert(optionButtons, optData)

                    O.MouseButton1Click:Connect(function()
                        if multi then
                            local idx = table.find(selected, opt)
                            if idx then
                                table.remove(selected, idx)
                                optData.selected = false
                            else
                                table.insert(selected, opt)
                                optData.selected = true
                            end
                            optData.check.BackgroundTransparency = optData.selected and 0 or 1
                            optData.checkGrad.Transparency = optData.selected and NumberSequence.new(0, 0, 1, 0.7) or NumberSequence.new(1)
                            optData.checkMark.ImageTransparency = optData.selected and 0 or 1
                            updateLabel()
                            if ConfigObjects[controlId] then
                                ConfigObjects[controlId].Value = selected
                            end
                            callback(selected)
                        else
                            selected = opt
                            for _, d in ipairs(optionButtons) do
                                d.selected = (d.value == opt)
                                d.check.BackgroundTransparency = d.selected and 0 or 1
                                d.checkGrad.Transparency = d.selected and NumberSequence.new(0, 0, 1, 0.7) or NumberSequence.new(1)
                                d.checkMark.ImageTransparency = d.selected and 0 or 1
                            end
                            updateLabel()
                            if ConfigObjects[controlId] then
                                ConfigObjects[controlId].Value = selected
                            end
                            callback(selected)
                            Dropped = false
                            Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                            Tween(Icon, {Rotation = 0}, 0.28)
                            task.wait(0.3)
                            Container.Visible = false
                        end
                    end)
                end

                for _, d in ipairs(optionButtons) do
                    if multi then
                        d.selected = table.find(selected, d.value) ~= nil
                    else
                        d.selected = (d.value == selected)
                    end
                    d.check.BackgroundTransparency = d.selected and 0 or 1
                    d.checkGrad.Transparency = d.selected and NumberSequence.new(0, 0, 1, 0.7) or NumberSequence.new(1)
                    d.checkMark.ImageTransparency = d.selected and 0 or 1
                end

                if Dropped then
                    local targetHeight = #optionButtons * 34
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                end
            end

            rebuildOptions(options)

            ClickBtn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                if Dropped then
                    Container.Visible = true
                    local targetHeight = #optionButtons * 34
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.32)
                    Tween(Icon, {Rotation = 180}, 0.32)
                else
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    Tween(Icon, {Rotation = 0}, 0.28)
                    task.wait(0.3)
                    Container.Visible = false
                end
            end)

            local function isMouseOver(frame)
                if not frame then return false end
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = frame.AbsolutePosition
                local absSize = frame.AbsoluteSize
                return mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                       mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
            end

            local globalClickConn
            globalClickConn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Dropped then
                        if not isMouseOver(Container) and not isMouseOver(Btn) then
                            Dropped = false
                            Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                            Tween(Icon, {Rotation = 0}, 0.28)
                            task.wait(0.3)
                            Container.Visible = false
                        end
                    end
                end
            end)

            ConfigObjects[controlId] = {
                Type = "Dropdown",
                Value = multi and selected or selected,
                Set = function(val)
                    if multi then
                        if type(val) == "table" then
                            selected = {}
                            for _, v in ipairs(val) do
                                if table.find(options, v) then
                                    table.insert(selected, v)
                                end
                            end
                        else
                            selected = {}
                        end
                    else
                        if val and table.find(options, val) then
                            selected = val
                        else
                            selected = options[1] or ""
                        end
                    end
                    for _, d in ipairs(optionButtons) do
                        if multi then
                            d.selected = table.find(selected, d.value) ~= nil
                        else
                            d.selected = (d.value == selected)
                        end
                        d.check.BackgroundTransparency = d.selected and 0 or 1
                        d.checkGrad.Transparency = d.selected and NumberSequence.new(0, 0, 1, 0.7) or NumberSequence.new(1)
                        d.checkMark.ImageTransparency = d.selected and 0 or 1
                    end
                    updateLabel()
                    callback(selected)
                end,
                Refresh = function(newOptions)
                    options = newOptions or {}
                    selected = multi and {} or (options[1] or "")
                    rebuildOptions(options)
                    updateLabel()
                end
            }

            local self = {}
            function self.GetValue()
                return selected
            end
            function self.SetValue(val)
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Set(val)
                end
            end
            function self.Refresh(newOptions)
                if ConfigObjects[controlId] and ConfigObjects[controlId].Refresh then
                    ConfigObjects[controlId].Refresh(newOptions)
                end
            end
            function self.SetVisible(state)
                Btn.Visible = state
            end

            table.insert(ThemeListeners, function()
                for _, d in ipairs(optionButtons) do
                    if d.checkStroke then d.checkStroke.Color = CurrentTheme.Accent end
                    if d.check then
                        d.check.BackgroundColor3 = CurrentTheme.Accent
                    end
                    if d.checkGrad then
                        d.checkGrad.Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent)
                    end
                    if d.button then
                        d.button.BackgroundColor3 = CurrentTheme.Top
                    end
                end
            end)

            table.insert(WindowCleanup or {}, function()
                if globalClickConn then globalClickConn:Disconnect() end
            end)

            return self
        end

        child.Keybind = function(_, config)
            local keyText = config.Name or ""
            local defaultKey = config.Default or Enum.KeyCode.M
            local mode = config.Mode or "Toggle"
            local callback = config.Callback or function() end
            local controlId = keyText .. "_" .. tostring(#Registry)

            local state = {
                Key = defaultKey.Name,
                Mode = mode,
                Toggled = false,
                IsWaiting = false,
            }

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 42)
            Tile.Parent = contentHolder
            styleContainer(Tile)
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 4)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

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

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 0, 0, 30)
            KeyBtn.Position = UDim2.new(1, -10, 0.5, 0)
            KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
            KeyBtn.BackgroundTransparency = 0.1
            KeyBtn.Text = ""
            KeyBtn.AutoButtonColor = false
            KeyBtn.Parent = Tile
            KeyBtn.AutomaticSize = Enum.AutomaticSize.X
            AddToRegistry(KeyBtn, "BackgroundColor3", "Main")

            local keyCorner = Instance.new("UICorner")
            keyCorner.CornerRadius = UDim.new(0, 5)
            keyCorner.Parent = KeyBtn

            local keyStroke = Instance.new("UIStroke")
            keyStroke.Thickness = 1
            keyStroke.Transparency = 0.5
            keyStroke.Parent = KeyBtn
            AddToRegistry(keyStroke, "Color", "Stroke")

            local innerLayout = Instance.new("UIListLayout")
            innerLayout.FillDirection = Enum.FillDirection.Horizontal
            innerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            innerLayout.Padding = UDim.new(0, 4)
            innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            innerLayout.Parent = KeyBtn

            local keyPadding = Instance.new("UIPadding")
            keyPadding.PaddingLeft = UDim.new(0, 7)
            keyPadding.PaddingRight = UDim.new(0, 8)
            keyPadding.Parent = KeyBtn

            local mouseIco = Instance.new("ImageLabel")
            mouseIco.Size = UDim2.fromOffset(13, 13)
            mouseIco.BackgroundTransparency = 1
            mouseIco.Image = "rbxassetid://10734898592"
            mouseIco.ImageTransparency = 0.35
            mouseIco.LayoutOrder = 1
            mouseIco.Parent = KeyBtn
            AddToRegistry(mouseIco, "ImageColor3", "Text")

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Text = state.Key
            KeyLabel.Size = UDim2.new(0, 0, 0, 14)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Font = Enum.Font.GothamMedium
            KeyLabel.TextSize = 13
            KeyLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            KeyLabel.AutomaticSize = Enum.AutomaticSize.X
            KeyLabel.LayoutOrder = 2
            KeyLabel.Parent = KeyBtn
            AddToRegistry(KeyLabel, "TextColor3", "Text")

            ConfigObjects[controlId] = {
                Type = "Keybind",
                Value = { Key = state.Key, Mode = state.Mode },
                Set = function(val)
                    if type(val) == "table" then
                        local newKey = val.Key or state.Key
                        local newMode = val.Mode or state.Mode
                        state.Key = newKey
                        state.Mode = newMode
                        KeyLabel.Text = newKey
                        ConfigObjects[controlId].Value = { Key = newKey, Mode = newMode }
                    elseif type(val) == "string" then
                        state.Key = val
                        KeyLabel.Text = val
                        ConfigObjects[controlId].Value = { Key = val, Mode = state.Mode }
                    end
                end
            }

            local function updateKeyDisplay(newKey)
                state.Key = newKey
                KeyLabel.Text = newKey
                ConfigObjects[controlId].Value = { Key = newKey, Mode = state.Mode }
            end

            KeyBtn.MouseButton1Click:Connect(function()
                if state.IsWaiting then return end
                state.IsWaiting = true
                KeyLabel.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                state.IsWaiting = false
                local newKey = nil
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode.Name ~= "Unknown" then
                        newKey = input.KeyCode.Name
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                    newKey = "MouseLeft"
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    newKey = "MouseRight"
                end
                if newKey then
                    updateKeyDisplay(newKey)
                else
                    KeyLabel.Text = state.Key
                end
            end)

            local function doToggle()
                if state.Mode == "Toggle" then
                    state.Toggled = not state.Toggled
                    pcall(callback, state.Toggled)
                end
            end

            local function doPress()
                if state.Mode == "Hold" then
                    pcall(callback, true)
                end
            end

            local function doRelease()
                if state.Mode == "Hold" then
                    pcall(callback, false)
                end
            end

            local inputConn
            inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if state.IsWaiting then return end
                if UserInputService:GetFocusedTextBox() then return end

                local key = state.Key
                if state.Mode == "Toggle" then
                    if key == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        doToggle()
                    elseif key == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then
                        doToggle()
                    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                        doToggle()
                    end
                elseif state.Mode == "Hold" then
                    if key == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        doPress()
                    elseif key == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then
                        doPress()
                    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                        doPress()
                    end
                end
            end)

            local inputEndConn
            inputEndConn = UserInputService.InputEnded:Connect(function(input, gpe)
                if gpe then return end
                if state.IsWaiting then return end
                if state.Mode == "Hold" then
                    local key = state.Key
                    if key == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        doRelease()
                    elseif key == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then
                        doRelease()
                    elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                        doRelease()
                    end
                end
            end)

            local function cleanup()
                if inputConn then inputConn:Disconnect() end
                if inputEndConn then inputEndConn:Disconnect() end
            end

            local self = {}
            function self.SetValue(val, newMode)
                if type(val) == "table" then
                    ConfigObjects[controlId].Set(val)
                else
                    ConfigObjects[controlId].Set({ Key = tostring(val), Mode = newMode or state.Mode })
                end
            end
            function self.GetValue()
                return { Key = state.Key, Mode = state.Mode }
            end
            function self.GetState()
                return state.Toggled
            end
            function self.SetMode(newMode)
                state.Mode = newMode
                ConfigObjects[controlId].Value = { Key = state.Key, Mode = state.Mode }
            end
            function self.Destroy()
                cleanup()
                Tile:Destroy()
                ConfigObjects[controlId] = nil
            end
            function self.SetVisible(vis)
                Tile.Visible = vis
            end

            return self
        end

        child.ColorPicker = function(_, config)
            local pickerText = config.Name or ""
            local Color = config.Default or Color3.fromRGB(255, 255, 255)
            local callback = config.Callback or function() end
            local controlId = pickerText .. "_" .. tostring(#Registry)
            
            local hue, sat, val = Color3.toHSV(Color)
            local alpha = 1.0
            local hexValue = "#" .. Color:ToHex()
            local isOpen = false
            
            local savedColors = {}
            local function addPresetColors()
                local presets = {
                    Color3.fromRGB(245,114,66), Color3.fromRGB(245,66,191),
                    Color3.fromRGB(124,54,245), Color3.fromRGB(202,110,255),
                    Color3.fromRGB(250,142,239), Color3.fromRGB(214,206,92),
                    Color3.fromRGB(255,93,48), Color3.fromRGB(255,169,56),
                    Color3.fromRGB(0,171,0), Color3.fromRGB(0,116,224),
                    Color3.fromRGB(120,0,76), Color3.fromRGB(255,194,245),
                    Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0),
                    Color3.fromRGB(171,209,255)
                }
                for _, c in ipairs(presets) do
                    table.insert(savedColors, {Color = c, Alpha = 1})
                end
            end
            addPresetColors()
            
            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 44)
            Tile.Parent = contentHolder
            styleContainer(Tile)
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 4)
            AddToRegistry(Tile, "BackgroundColor3", "Top")
            
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile
            
            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = pickerText
            TitleLbl.Size = UDim2.new(0.6, 0, 1, 0)
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
            Panel.Parent = contentHolder
            styleContainer(Panel)
            Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 4)
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
            SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            SVBox.Parent = Panel
            Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 6)
            
            local SVDot = Instance.new("Frame")
            SVDot.Size = UDim2.new(0, 10, 0, 10)
            SVDot.AnchorPoint = Vector2.new(0.5, 0.5)
            SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
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
            HueDot.Position = UDim2.new(0.5, 0, hue, 0)
            HueDot.BackgroundColor3 = Color3.new(1, 1, 1)
            HueDot.ZIndex = 2
            HueDot.Parent = HueBar
            Instance.new("UICorner", HueDot).CornerRadius = UDim.new(1, 0)
            
            local AlphaBar = Instance.new("Frame")
            AlphaBar.Size = UDim2.new(1, -52, 0, 6)
            AlphaBar.Position = UDim2.new(0, 10, 0, 128)
            AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            AlphaBar.Parent = Panel
            Instance.new("UICorner", AlphaBar).CornerRadius = UDim.new(1, 0)
            local AlphaGrad = Instance.new("UIGradient")
            AlphaGrad.Rotation = 0
            AlphaGrad.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(1,1,1))
            AlphaGrad.Parent = AlphaBar
            
            local AlphaDot = Instance.new("Frame")
            AlphaDot.Size = UDim2.new(0, 12, 0, 12)
            AlphaDot.AnchorPoint = Vector2.new(0.5, 0.5)
            AlphaDot.Position = UDim2.new(alpha, 0, 0.5, 0)
            AlphaDot.BackgroundColor3 = Color3.new(1, 1, 1)
            AlphaDot.ZIndex = 2
            AlphaDot.Parent = AlphaBar
            Instance.new("UICorner", AlphaDot).CornerRadius = UDim.new(1, 0)
            
            local HexBox = Instance.new("TextBox")
            HexBox.Size = UDim2.new(0.5, -20, 0, 24)
            HexBox.Position = UDim2.new(0, 10, 0, 142)
            HexBox.Text = "#" .. Color:ToHex()
            HexBox.Font = Enum.Font.GothamBold
            HexBox.TextSize = 12
            HexBox.TextColor3 = CurrentTheme.Text
            HexBox.BackgroundTransparency = 0.1
            HexBox.Parent = Panel
            Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0, 6)
            AddToRegistry(HexBox, "BackgroundColor3", "Main")
            AddToRegistry(HexBox, "TextColor3", "Text")
            local HexStroke = Instance.new("UIStroke")
            HexStroke.Thickness = 1
            HexStroke.Transparency = 0.75
            HexStroke.Parent = HexBox
            AddToRegistry(HexStroke, "Color", "Stroke")
            
            local PresetContainer = Instance.new("ScrollingFrame")
            PresetContainer.Size = UDim2.new(0.5, -10, 0, 70)
            PresetContainer.Position = UDim2.new(0.5, 10, 0, 140)
            PresetContainer.BackgroundTransparency = 1
            PresetContainer.ScrollBarThickness = 0
            PresetContainer.Parent = Panel
            local Grid = Instance.new("UIGridLayout")
            Grid.CellSize = UDim2.new(0, 20, 0, 20)
            Grid.CellPadding = UDim2.new(0, 4, 0, 4)
            Grid.FillDirection = Enum.FillDirection.Horizontal
            Grid.SortOrder = Enum.SortOrder.LayoutOrder
            Grid.Parent = PresetContainer
            
            for _, data in ipairs(savedColors) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundColor3 = data.Color
                btn.BackgroundTransparency = 0
                btn.AutoButtonColor = false
                btn.Text = ""
                btn.Parent = PresetContainer
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 1.5
                stroke.Color = Color3.new(1,1,1)
                stroke.Transparency = 1
                stroke.Parent = btn
                btn.MouseEnter:Connect(function()
                    Tween(stroke, {Transparency = 0}, 0.15)
                end)
                btn.MouseLeave:Connect(function()
                    Tween(stroke, {Transparency = 1}, 0.15)
                end)
                btn.MouseButton1Click:Connect(function()
                    Color = data.Color
                    hue, sat, val = Color3.toHSV(Color)
                    SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                    HueDot.Position = UDim2.new(0.5, 0, hue, 0)
                    AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    Swatch.BackgroundColor3 = Color
                    HexBox.Text = "#" .. Color:ToHex()
                    ApplyColor()
                end)
            end
            
            local function ApplyColor()
                Color = Color3.fromHSV(hue, sat, val)
                Swatch.BackgroundColor3 = Color
                SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                HexBox.Text = "#" .. Color:ToHex()
                ConfigObjects[controlId].Value = {R = Color.R, G = Color.G, B = Color.B, A = alpha}
                callback(Color, alpha)
            end
            
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
                    local x = (i.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X
                    local y = (i.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y
                    sat = math.clamp(x, 0, 1)
                    val = 1 - math.clamp(y, 0, 1)
                    SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                    ApplyColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if svDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local x = (i.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X
                    local y = (i.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y
                    sat = math.clamp(x, 0, 1)
                    val = 1 - math.clamp(y, 0, 1)
                    SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                    ApplyColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
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
                    local y = (i.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y
                    hue = math.clamp(y, 0, 1)
                    HueDot.Position = UDim2.new(0.5, 0, hue, 0)
                    SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    ApplyColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hueDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local y = (i.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y
                    hue = math.clamp(y, 0, 1)
                    HueDot.Position = UDim2.new(0.5, 0, hue, 0)
                    SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    ApplyColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                end
            end)
            
            local alphaDragging = false
            local AlphaBtn = Instance.new("TextButton")
            AlphaBtn.Size = UDim2.new(1, 0, 1, 0)
            AlphaBtn.BackgroundTransparency = 1
            AlphaBtn.Text = ""
            AlphaBtn.ZIndex = 3
            AlphaBtn.Parent = AlphaBar
            AlphaBtn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    alphaDragging = true
                    local x = (i.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X
                    alpha = math.clamp(x, 0, 1)
                    AlphaDot.Position = UDim2.new(alpha, 0, 0.5, 0)
                    ApplyColor()
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if alphaDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local x = (i.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X
                    alpha = math.clamp(x, 0, 1)
                    AlphaDot.Position = UDim2.new(alpha, 0, 0.5, 0)
                    ApplyColor()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    alphaDragging = false
                end
            end)
            
            HexBox.FocusLost:Connect(function()
                local txt = HexBox.Text:gsub("#", "")
                if #txt == 6 or #txt == 3 then
                    local success, c = pcall(Color3.fromHex, "#" .. txt)
                    if success then
                        Color = c
                        hue, sat, val = Color3.toHSV(Color)
                        SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                        HueDot.Position = UDim2.new(0.5, 0, hue, 0)
                        SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        Swatch.BackgroundColor3 = Color
                        ApplyColor()
                    end
                end
            end)
            
            local function togglePanel()
                isOpen = not isOpen
                if isOpen then
                    Panel.Visible = true
                    Tween(Panel, {Size = UDim2.new(1, 0, 0, 190)}, 0.32)
                else
                    Tween(Panel, {Size = UDim2.new(1, 0, 0, 0)}, 0.28)
                    task.wait(0.3)
                    Panel.Visible = false
                end
            end
            
            ClickBtn.MouseButton1Click:Connect(togglePanel)
            
            ConfigObjects[controlId] = {
                Type = "ColorPicker",
                Value = {R = Color.R, G = Color.G, B = Color.B, A = alpha},
                Set = function(val)
                    if type(val) == "table" then
                        Color = Color3.new(val.R or 0, val.G or 0, val.B or 0)
                        alpha = val.A or 1
                        hue, sat, val = Color3.toHSV(Color)
                        SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                        HueDot.Position = UDim2.new(0.5, 0, hue, 0)
                        AlphaDot.Position = UDim2.new(alpha, 0, 0.5, 0)
                        SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        Swatch.BackgroundColor3 = Color
                        HexBox.Text = "#" .. Color:ToHex()
                        ApplyColor()
                    elseif type(val) == "userdata" and val.ClassName == "Color3" then
                        Color = val
                        hue, sat, val = Color3.toHSV(Color)
                        SVDot.Position = UDim2.new(sat, 0, 1 - val, 0)
                        HueDot.Position = UDim2.new(0.5, 0, hue, 0)
                        SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        AlphaBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        Swatch.BackgroundColor3 = Color
                        HexBox.Text = "#" .. Color:ToHex()
                        ApplyColor()
                    end
                end
            }
            
            table.insert(ThemeListeners, function()
                SwStroke.Color = CurrentTheme.Stroke
                PSt.Color = CurrentTheme.Accent
                HexStroke.Color = CurrentTheme.Stroke
                HexBox.TextColor3 = CurrentTheme.Text
            end)
            
            local self = {}
            function self.SetValue(val)
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Set(val)
                end
            end
            function self.GetValue()
                return ConfigObjects[controlId].Value
            end
            function self.SetVisible(state)
                Tile.Visible = state
            end
            return self
        end

        child.Input = function(_, config)
            local inputText = config.Name or ""
            local default = config.Value or ""
            local callback = config.Callback or function() end
            local options = config or {}
            local placeholder = options.Placeholder or ""
            local finished = options.Finished == true
            local numeric = options.Numeric == true
            local maxLength = options.MaxLength or options.CharacterLimit
            local acceptedChars = options.AcceptedCharacters
            local onChanged = options.OnChanged
            local controlId = inputText .. "_" .. tostring(#Registry)

            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, 42)
            InputFrame.Parent = contentHolder
            styleContainer(InputFrame)
            Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)
            AddToRegistry(InputFrame, "BackgroundColor3", "Top")

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = inputText
            NameLbl.Size = UDim2.new(0.6,0,1,0)
            NameLbl.Position = UDim2.new(0,15,0,0)
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Font = Enum.Font.GothamMedium
            NameLbl.TextSize = 13
            NameLbl.BackgroundTransparency = 1
            NameLbl.Parent = InputFrame
            AddToRegistry(NameLbl, "TextColor3", "Text")

            local BoxContainer = Instance.new("Frame")
            BoxContainer.Size = UDim2.new(0.3,0,0,28)
            BoxContainer.Position = UDim2.new(0.7,-10,0.5,-14)
            BoxContainer.BackgroundTransparency = 0.1
            BoxContainer.ClipsDescendants = true
            BoxContainer.Parent = InputFrame
            AddToRegistry(BoxContainer, "BackgroundColor3", "Main")
            Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 6)

            local InputBox = Instance.new("TextBox")
            InputBox.Text = tostring(default)
            InputBox.PlaceholderText = placeholder
            InputBox.Size = UDim2.new(1, -10, 1, 0)
            InputBox.Position = UDim2.new(0, 10, 0, 0)
            InputBox.Font = Enum.Font.GothamBold
            InputBox.TextSize = 13
            InputBox.TextXAlignment = Enum.TextXAlignment.Left
            InputBox.ClearTextOnFocus = false
            InputBox.BackgroundTransparency = 1
            InputBox.Parent = BoxContainer
            AddToRegistry(InputBox, "TextColor3", "Accent")

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(1, -4, 0, 1)
            Indicator.Position = UDim2.new(0, 2, 1, 0)
            Indicator.AnchorPoint = Vector2.new(0, 1)
            Indicator.BackgroundTransparency = 0.5
            Indicator.BorderSizePixel = 0
            Indicator.Parent = BoxContainer
            Indicator.BackgroundColor3 = CurrentTheme.Stroke

            local function filterText(text)
                if maxLength then
                    text = text:sub(1, maxLength)
                end
                if numeric then
                    local filtered = text:gsub("[^%d-]", "")
                    if filtered:match("^-") then
                        filtered = "-" .. filtered:gsub("-", "")
                    else
                        filtered = filtered:gsub("-", "")
                    end
                    return filtered
                end
                if type(acceptedChars) == "function" then
                    return acceptedChars(text)
                elseif acceptedChars == "Alphabetic" then
                    return text:gsub("[^a-zA-Z]", "")
                elseif acceptedChars == "AlphaNumeric" then
                    return text:gsub("[^a-zA-Z0-9]", "")
                end
                return text
            end

            local function updateValue()
                local filtered = filterText(InputBox.Text)
                if filtered ~= InputBox.Text then
                    InputBox.Text = filtered
                end
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Value = filtered
                end
                if callback then
                    pcall(callback, filtered)
                end
                if onChanged then
                    pcall(onChanged, filtered)
                end
            end

            local function onFocus()
                Tween(Indicator, {
                    Size = UDim2.new(1, -2, 0, 2),
                    Position = UDim2.new(0, 1, 1, 0),
                    BackgroundTransparency = 0
                }, 0.15)
                Tween(BoxContainer, { BackgroundTransparency = 0.05 }, 0.15)
                Indicator.BackgroundColor3 = CurrentTheme.Accent
            end

            local function onFocusLost()
                Tween(Indicator, {
                    Size = UDim2.new(1, -4, 0, 1),
                    Position = UDim2.new(0, 2, 1, 0),
                    BackgroundTransparency = 0.5
                }, 0.15)
                Tween(BoxContainer, { BackgroundTransparency = 0.1 }, 0.15)
                Indicator.BackgroundColor3 = CurrentTheme.Stroke
                if finished then
                    updateValue()
                end
            end

            InputBox.Focused:Connect(onFocus)
            InputBox.FocusLost:Connect(onFocusLost)

            table.insert(ThemeListeners, function()
                if InputBox:IsFocused() then
                    Indicator.BackgroundColor3 = CurrentTheme.Accent
                else
                    Indicator.BackgroundColor3 = CurrentTheme.Stroke
                end
            end)

            if not finished then
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local raw = InputBox.Text
                    local filtered = filterText(raw)
                    if filtered ~= raw then
                        local cursor = InputBox.CursorPosition
                        InputBox.Text = filtered
                        pcall(function()
                            InputBox.CursorPosition = math.min(cursor, #filtered)
                        end)
                    end
                    if ConfigObjects[controlId] then
                        ConfigObjects[controlId].Value = InputBox.Text
                    end
                    if callback then
                        pcall(callback, InputBox.Text)
                    end
                    if onChanged then
                        pcall(onChanged, InputBox.Text)
                    end
                end)
            end

            ConfigObjects[controlId] = {
                Type = "Input",
                Value = InputBox.Text,
                Set = function(val)
                    local str = tostring(val)
                    local filtered = filterText(str)
                    InputBox.Text = filtered
                    ConfigObjects[controlId].Value = filtered
                    if callback then pcall(callback, filtered) end
                end
            }

            local self = {}
            function self.UpdateText(newText)
                local filtered = filterText(tostring(newText))
                InputBox.Text = filtered
                ConfigObjects[controlId].Value = filtered
            end
            function self.GetText()
                return InputBox.Text
            end
            function self.SetVisible(state)
                InputFrame.Visible = state
            end
            function self.UpdatePlaceholder(newPlaceholder)
                InputBox.PlaceholderText = newPlaceholder
            end
            function self.SetValue(val)
                self.UpdateText(val)
            end
            return self
        end

        child.Textbox = function(_, config)
            local boxText = config.Name or ""
            local placeholder = config.Placeholder or ""
            local callback = config.Callback or function() end
            local controlId = boxText .. "_" .. tostring(#Registry)

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 70)
            Frame.Parent = contentHolder
            styleContainer(Frame)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
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

        child.Label = function(_, config)
            local labelText = config.Name or ""
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 42)
            LabelFrame.Parent = contentHolder
            styleContainer(LabelFrame)
            Instance.new("UICorner", LabelFrame).CornerRadius = UDim.new(0, 4)
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

        child.Image = function(_, config)
            config = config or {}
            local title = config.Name or "Image"
            local subtitle = config.SubName or ""
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
            imageFrame.Parent = contentHolder
            styleContainer(imageFrame)
            Instance.new("UICorner", imageFrame).CornerRadius = UDim.new(0, 4)
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

            clickBtn.MouseEnter:Connect(function()
                Tween(imageFrame, {BackgroundTransparency = 0.05}, 0.18)
            end)
            clickBtn.MouseLeave:Connect(function()
                Tween(imageFrame, {BackgroundTransparency = 1}, 0.18)
            end)
            clickBtn.MouseButton1Down:Connect(function()
                Tween(imageFrame, {BackgroundTransparency = 0.2}, 0.1)
            end)
            clickBtn.MouseButton1Up:Connect(function()
                Tween(imageFrame, {BackgroundTransparency = 0.05}, 0.1)
            end)

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

        child.Divider = function(_, config)
            local labelText = config and config.Name or config or ""

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, (labelText ~= "" and 22 or 12))
            container.BackgroundTransparency = 1
            container.Parent = contentHolder

            if labelText ~= "" then
                local leftLine = Instance.new("Frame")
                leftLine.Size = UDim2.new(0.35, -6, 0, 1)
                leftLine.Position = UDim2.new(0, 0, 0.5, 0)
                leftLine.AnchorPoint = Vector2.new(0, 0.5)
                leftLine.BackgroundColor3 = CurrentTheme.Stroke
                leftLine.Parent = container
                AddToRegistry(leftLine, "BackgroundColor3", "Stroke")

                local rightLine = Instance.new("Frame")
                rightLine.Size = UDim2.new(0.35, -6, 0, 1)
                rightLine.Position = UDim2.new(1, 0, 0.5, 0)
                rightLine.AnchorPoint = Vector2.new(1, 0.5)
                rightLine.BackgroundColor3 = CurrentTheme.Stroke
                rightLine.Parent = container
                AddToRegistry(rightLine, "BackgroundColor3", "Stroke")

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0, 0, 1, 0)
                label.AutomaticSize = Enum.AutomaticSize.X
                label.Position = UDim2.new(0.5, 0, 0.5, 0)
                label.AnchorPoint = Vector2.new(0.5, 0.5)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.Text = labelText
                label.TextSize = 12
                label.TextColor3 = CurrentTheme.Text
                label.TextTransparency = 0.4
                label.Parent = container
                AddToRegistry(label, "TextColor3", "Text")
            else
                local line = Instance.new("Frame")
                line.Size = UDim2.new(1, 0, 0, 1)
                line.Position = UDim2.new(0, 0, 0.5, 0)
                line.AnchorPoint = Vector2.new(0, 0.5)
                line.BackgroundColor3 = CurrentTheme.Stroke
                line.Parent = container
                AddToRegistry(line, "BackgroundColor3", "Stroke")
            end

            local self = {}
            function self.SetVisible(state)
                container.Visible = state
            end
            function self.UpdateText(newText)
                local label = container:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = newText
                end
            end
            return self
        end

        child.Checkbox = function(_, config)
            local title = config.Name or ""
            local default = config.Default or false
            local callback = config.Callback or function() end
            local controlId = title .. "_" .. tostring(#Registry)

            local Tile = Instance.new("Frame")
            Tile.Size = UDim2.new(1, 0, 0, 42)
            Tile.Parent = contentHolder
            styleContainer(Tile)
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 4)
            AddToRegistry(Tile, "BackgroundColor3", "Top")

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Tile

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Text = title
            TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
            TitleLbl.Position = UDim2.new(0, 15, 0, 0)
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Font = Enum.Font.GothamMedium
            TitleLbl.TextSize = 13
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.Parent = Tile
            AddToRegistry(TitleLbl, "TextColor3", "Text")

            local box = Instance.new("Frame")
            box.Size = UDim2.fromOffset(20, 20)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.Position = UDim2.new(1, -12, 0.5, 0)
            box.BackgroundTransparency = 0
            box.Parent = Tile
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Thickness = 1.4
            boxStroke.Transparency = 0.4
            boxStroke.Parent = box

            local check = Instance.new("ImageLabel")
            check.Size = UDim2.fromOffset(14, 14)
            check.AnchorPoint = Vector2.new(0.5, 0.5)
            check.Position = UDim2.new(0.5, 0, 0.5, 0)
            check.BackgroundTransparency = 1
            check.Image = "rbxassetid://10709790644"
            check.ImageTransparency = 1
            check.Parent = box

            local h = {
                Value = default,
                Callback = callback,
                Type = "Checkbox",
            }

            local function updateColors()
                if h.Value then
                    box.BackgroundColor3 = CurrentTheme.Accent
                    boxStroke.Color = CurrentTheme.Accent
                    check.ImageTransparency = 0
                else
                    box.BackgroundColor3 = CurrentTheme.Stroke
                    boxStroke.Color = CurrentTheme.Stroke
                    check.ImageTransparency = 1
                end
            end

            table.insert(ThemeListeners, updateColors)

            function h:SetValue(val)
                val = not (not val)
                h.Value = val
                updateColors()
                if ConfigObjects[controlId] then
                    ConfigObjects[controlId].Value = val
                end
                pcall(callback, val)
                pcall(h.Changed, val)
            end

            function h:OnChanged(_, cb)
                h.Changed = cb
                cb(h.Value)
            end

            function h:GetValue()
                return h.Value
            end

            function h:SetVisible(vis)
                Tile.Visible = vis
            end

            function h:Destroy()
                Tile:Destroy()
                ConfigObjects[controlId] = nil
            end

            ClickBtn.MouseButton1Click:Connect(function()
                h:SetValue(not h.Value)
            end)

            h:SetValue(default)

            ConfigObjects[controlId] = {
                Type = "Checkbox",
                Value = h.Value,
                Set = function(val)
                    h:SetValue(val)
                end
            }

            return h
        end

        child.ProgressBar = function(_, config)
            local name = config.Name or ""
            local valueConfig = config.Value or {}
            local min = valueConfig.Min or 0
            local max = valueConfig.Max or 100
            local default = valueConfig.Default or min
            local showPercent = config.ShowPercent ~= false
            local callback = config.Callback or function() end
            local controlId = name .. "_" .. tostring(#Registry)

            local containerHeight = (name ~= "" and 46 or 26)
            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, 0, 0, containerHeight)
            wrap.BackgroundTransparency = 1
            wrap.Parent = contentHolder

            local titleLbl = nil
            if name ~= "" then
                titleLbl = Instance.new("TextLabel")
                titleLbl.Size = UDim2.new(1, -50, 0, 16)
                titleLbl.Position = UDim2.new(0, 0, 0, 0)
                titleLbl.BackgroundTransparency = 1
                titleLbl.Font = Enum.Font.GothamMedium
                titleLbl.Text = name
                titleLbl.TextSize = 14
                titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                titleLbl.Parent = wrap
                AddToRegistry(titleLbl, "TextColor3", "Text")
            end

            local pctLbl = nil
            if showPercent then
                pctLbl = Instance.new("TextLabel")
                pctLbl.Size = UDim2.new(0, 50, 0, 16)
                pctLbl.Position = UDim2.new(1, -50, 0, 0)
                pctLbl.BackgroundTransparency = 1
                pctLbl.Font = Enum.Font.Gotham
                pctLbl.Text = "0%"
                pctLbl.TextSize = 13
                pctLbl.TextXAlignment = Enum.TextXAlignment.Right
                pctLbl.TextTransparency = 0.5
                pctLbl.Parent = wrap
                AddToRegistry(pctLbl, "TextColor3", "Text")
            end

            local rail = Instance.new("Frame")
            rail.Size = UDim2.new(1, 0, 0, 8)
            rail.Position = UDim2.new(0, 0, 1, -8)
            rail.BackgroundTransparency = 0.4
            rail.BorderSizePixel = 0
            rail.Parent = wrap
            Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)
            AddToRegistry(rail, "BackgroundColor3", "Stroke")

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale(0, 1)
            fill.BackgroundTransparency = 0
            fill.BorderSizePixel = 0
            fill.Parent = rail
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            AddToRegistry(fill, "BackgroundColor3", "Accent")

            local h = {
                Value = math.clamp(default, min, max),
                Min = min,
                Max = max,
                Type = "ProgressBar",
                Frame = wrap,
            }

            function h:SetTitle(s)
                if titleLbl then
                    titleLbl.Text = tostring(s or "")
                end
            end

            function h:SetValue(val)
                val = math.clamp(tonumber(val) or h.Min, h.Min, h.Max)
                h.Value = val
                local alpha = (h.Max > h.Min) and (val - h.Min) / (h.Max - h.Min) or 0
                Tween(fill, { Size = UDim2.fromScale(alpha, 1) }, 0.2)
                if pctLbl then
                    pctLbl.Text = math.floor(alpha * 100) .. "%"
                end
                if callback then pcall(callback, val) end
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = val end
            end

            function h:Destroy()
                wrap:Destroy()
                ConfigObjects[controlId] = nil
            end

            function h:SetVisible(state)
                wrap.Visible = state
            end

            h:SetValue(default)

            ConfigObjects[controlId] = {
                Type = "ProgressBar",
                Value = h.Value,
                Set = function(val) h:SetValue(val) end
            }

            return h
        end

        child.Video = function(_, config)
            local opts   = config or {}
            local parent = contentHolder
            if not parent then return end

            local radius = opts.Radius or 8
            local src    = opts.Video or ""
            local looped = opts.Looped ~= false
            local vol    = opts.Volume or 0
            local auto   = opts.AutoPlay ~= false
            local title  = opts.Name or "Video"
            local aspect = opts.AspectRatio or "16:9"

            local function resolveSync(s)
                if type(s)~="string" or s=="" then return "" end
                if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
                if s:match("^%d+$") then return "rbxassetid://"..s end
                return ""
            end

            local function resolveMedia(s)
                if type(s)~="string" or s=="" then return "" end
                if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
                if s:match("^%d+$") then return "rbxassetid://"..s end
                if s:match("^https?://") then
                    return MediaManager:Video(s)
                end
                return ""
            end

            local function applyIcon(imgLabel, iconName)
                if not imgLabel then return end
                local imageMap = {
                    ["play"]    = "rbxassetid://10734923549",
                    ["pause"]   = "rbxassetid://10734919336",
                    ["stop"]    = "rbxassetid://10734972621",
                    ["volume"]  = "rbxassetid://10747376008",
                    ["external"]= "rbxassetid://10747366266",
                }
                imgLabel.Image = imageMap[iconName] or ""
            end

            local function parseRatio(r)
                if type(r) == "number" then return r end
                if type(r) == "string" then
                    local rw, rh = r:match("(%d+):(%d+)")
                    if rw and rh and tonumber(rh) ~= 0 then return tonumber(rw) / tonumber(rh) end
                end
                return 16 / 9
            end

            local ratioNum = parseRatio(aspect)

            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, -16, 0, 180)
            wrap.BackgroundColor3 = CurrentTheme.Main
            wrap.BackgroundTransparency = 0.9
            wrap.BorderSizePixel = 0
            wrap.ClipsDescendants = true
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Main")

            local function recalcAspect()
                local w = wrap.AbsoluteSize.X
                if w > 0 and ratioNum and ratioNum > 0 then
                    wrap.Size = UDim2.new(1, -16, 0, math.floor(w / ratioNum))
                end
            end
            wrap:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcAspect)
            task.defer(recalcAspect)

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, radius)
            corner.Parent = wrap

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Transparency = 0.6
            stroke.Parent = wrap
            AddToRegistry(stroke, "Color", "Stroke")

            local resolved = resolveMedia(src)
            local hasVideo = (resolved ~= "")

            local vid = nil
            if hasVideo then
                vid = Instance.new("VideoFrame")
                vid.Size = UDim2.fromScale(1, 1)
                vid.BackgroundTransparency = 1
                vid.Looped = looped
                vid.Volume = vol
                vid.ZIndex = 1
                vid:SetAttribute("BFVolume", vol)
                vid:SetAttribute("BFAutoPlay", auto)
                vid.Video = resolved
                vid.Parent = wrap
                local vidCorner = Instance.new("UICorner")
                vidCorner.CornerRadius = UDim.new(0, radius)
                vidCorner.Parent = vid
            end

            local placeholder = Instance.new("Frame")
            placeholder.Size = UDim2.fromScale(1, 1)
            placeholder.BackgroundTransparency = 1
            placeholder.Visible = not hasVideo
            placeholder.ZIndex = 2
            placeholder.Parent = wrap

            local phImg = Instance.new("ImageLabel")
            phImg.Size = UDim2.fromOffset(32, 32)
            phImg.Position = UDim2.new(0.5, 0, 0.5, -14)
            phImg.AnchorPoint = Vector2.new(0.5, 0.5)
            phImg.BackgroundTransparency = 1
            phImg.ImageTransparency = 0.4
            phImg.ZIndex = 3
            phImg.Parent = placeholder
            AddToRegistry(phImg, "ImageColor3", "SubText")
            applyIcon(phImg, "play")

            local phText = Instance.new("TextLabel")
            phText.Size = UDim2.new(1, 0, 0, 16)
            phText.Position = UDim2.new(0, 0, 0.5, 20)
            phText.AnchorPoint = Vector2.new(0, 0)
            phText.BackgroundTransparency = 1
            phText.Text = "Video not available"
            phText.TextSize = 11
            phText.Font = Enum.Font.GothamMedium
            phText.TextTransparency = 0.5
            phText.ZIndex = 3
            phText.Parent = placeholder
            AddToRegistry(phText, "TextColor3", "SubText")

            if not hasVideo then
                local mod = {Frame=wrap, Type="Video", VideoFrame=nil}
                function mod:Destroy() wrap:Destroy() end
                function mod:SetVideo(s) end
                function mod:SetVolume(v) end
                function mod:Play() end
                function mod:Pause() end
                function mod:Stop() end
                function mod:SetAspectRatio(r) end
                return mod
            end

            local overlay = Instance.new("CanvasGroup")
            overlay.Size = UDim2.new(1, 0, 0, 54)
            overlay.Position = UDim2.new(0, 0, 1, 0)
            overlay.AnchorPoint = Vector2.new(0, 1)
            overlay.BackgroundTransparency = 1
            overlay.GroupTransparency = 1
            overlay.ZIndex = 5
            overlay.Parent = wrap

            local gradFr = Instance.new("Frame")
            gradFr.Size = UDim2.fromScale(1, 1)
            gradFr.BackgroundColor3 = Color3.fromRGB(0,0,0)
            gradFr.BackgroundTransparency = 0
            gradFr.BorderSizePixel = 0
            gradFr.ZIndex = 5
            gradFr.Parent = overlay
            local grad = Instance.new("UIGradient")
            grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 1)
            })
            grad.Rotation = 90
            grad.Parent = gradFr

            local seekRow = Instance.new("Frame")
            seekRow.Size = UDim2.new(1, -12, 0, 16)
            seekRow.Position = UDim2.new(0, 6, 0, 4)
            seekRow.BackgroundTransparency = 1
            seekRow.ZIndex = 6
            seekRow.Parent = overlay

            local timeCur = Instance.new("TextLabel")
            timeCur.Size = UDim2.fromOffset(36, 16)
            timeCur.BackgroundTransparency = 1
            timeCur.Text = "0:00"
            timeCur.TextSize = 10
            timeCur.Font = Enum.Font.GothamMedium
            timeCur.TextColor3 = Color3.fromRGB(220,220,220)
            timeCur.ZIndex = 7
            timeCur.Parent = seekRow

            local seekContainer = Instance.new("Frame")
            seekContainer.Size = UDim2.new(1, -84, 0, 16)
            seekContainer.Position = UDim2.fromOffset(40, 0)
            seekContainer.BackgroundTransparency = 1
            seekContainer.ZIndex = 6
            seekContainer.Parent = seekRow

            local seekRail = Instance.new("TextButton")
            seekRail.Size = UDim2.new(1, 0, 0, 5)
            seekRail.Position = UDim2.new(0, 0, 0.5, -2)
            seekRail.BackgroundColor3 = Color3.fromRGB(80,80,90)
            seekRail.BorderSizePixel = 0
            seekRail.ZIndex = 7
            seekRail.Text = ""
            seekRail.AutoButtonColor = false
            seekRail.Parent = seekContainer
            Instance.new("UICorner", seekRail).CornerRadius = UDim.new(1, 0)

            local seekFill = Instance.new("Frame")
            seekFill.Size = UDim2.new(0, 0, 1, 0)
            seekFill.BackgroundColor3 = CurrentTheme.Accent
            seekFill.BorderSizePixel = 0
            seekFill.ZIndex = 8
            seekFill.Parent = seekRail
            Instance.new("UICorner", seekFill).CornerRadius = UDim.new(1, 0)

            local seekKnob = Instance.new("Frame")
            seekKnob.Size = UDim2.fromOffset(12, 12)
            seekKnob.Position = UDim2.new(0, 0, 0.5, 0)
            seekKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            seekKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
            seekKnob.BorderSizePixel = 0
            seekKnob.ZIndex = 9
            seekKnob.Parent = seekRail
            Instance.new("UICorner", seekKnob).CornerRadius = UDim.new(1, 0)

            local timeDur = Instance.new("TextLabel")
            timeDur.Size = UDim2.fromOffset(36, 16)
            timeDur.Position = UDim2.new(1, -36, 0, 0)
            timeDur.BackgroundTransparency = 1
            timeDur.Text = "0:00"
            timeDur.TextSize = 10
            timeDur.Font = Enum.Font.GothamMedium
            timeDur.TextColor3 = Color3.fromRGB(160,160,170)
            timeDur.ZIndex = 7
            timeDur.Parent = seekRow

            local ctrlRow = Instance.new("Frame")
            ctrlRow.Size = UDim2.new(1, -12, 0, 26)
            ctrlRow.Position = UDim2.new(0, 6, 0, 24)
            ctrlRow.BackgroundTransparency = 1
            ctrlRow.ZIndex = 6
            ctrlRow.Parent = overlay

            local function ctrlBtn(iconName, cb)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.fromOffset(22, 22)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = 7
                btn.AutoButtonColor = false
                btn.Parent = ctrlRow
                local ic = Instance.new("ImageLabel")
                ic.Size = UDim2.fromOffset(16, 16)
                ic.Position = UDim2.new(0.5, 0, 0.5, 0)
                ic.AnchorPoint = Vector2.new(0.5, 0.5)
                ic.BackgroundTransparency = 1
                ic.ZIndex = 8
                ic.Parent = btn
                AddToRegistry(ic, "ImageColor3", "Text")
                applyIcon(ic, iconName)
                btn.MouseButton1Click:Connect(function() pcall(cb) end)
                return btn, ic
            end

            local playing = auto
            local playBtn, playIco = ctrlBtn("play", function() end)
            local pauseBtn, pauseIco = ctrlBtn("pause", function() end)
            local stopBtn, stopIco = ctrlBtn("stop", function() end)
            local volIco = Instance.new("ImageLabel")
            volIco.Size = UDim2.fromOffset(14, 14)
            volIco.Position = UDim2.fromOffset(68, 4)
            volIco.BackgroundTransparency = 1
            volIco.ZIndex = 7
            volIco.Parent = ctrlRow
            AddToRegistry(volIco, "ImageColor3", "SubText")
            applyIcon(volIco, "volume")
            local volLbl = Instance.new("TextLabel")
            volLbl.Size = UDim2.fromOffset(32, 22)
            volLbl.Position = UDim2.fromOffset(84, 0)
            volLbl.BackgroundTransparency = 1
            volLbl.Text = tostring(math.floor(vol*100)).."%"
            volLbl.TextSize = 10
            volLbl.Font = Enum.Font.Gotham
            volLbl.ZIndex = 7
            volLbl.Parent = ctrlRow
            AddToRegistry(volLbl, "TextColor3", "SubText")

            local btnLayout = Instance.new("UIListLayout")
            btnLayout.FillDirection = Enum.FillDirection.Horizontal
            btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            btnLayout.Padding = UDim.new(0, 2)
            btnLayout.Parent = ctrlRow

            local ctrlVisible = false
            local fadeTimer = 0
            local fadingOut = false

            local function showOverlay()
                ctrlVisible = true
                fadingOut = false
                fadeTimer = 3
                Tween(overlay, {GroupTransparency = 0}, 0.18)
            end

            local function hideOverlay()
                ctrlVisible = false
                fadingOut = true
                Tween(overlay, {GroupTransparency = 1}, 0.3)
            end

            local vidClickBtn = Instance.new("TextButton")
            vidClickBtn.Size = UDim2.fromScale(1, 1)
            vidClickBtn.BackgroundTransparency = 1
            vidClickBtn.Text = ""
            vidClickBtn.ZIndex = 4
            vidClickBtn.AutoButtonColor = false
            vidClickBtn.Parent = wrap
            vidClickBtn.MouseButton1Click:Connect(function()
                if ctrlVisible then fadeTimer = 3 else showOverlay() end
            end)

            local function resetFade() fadeTimer = 3; fadingOut = false end

            playBtn.MouseButton1Click:Connect(function()
                if vid then pcall(function() vid:Play() end) end
                playing = true
                playBtn.Visible = false
                pauseBtn.Visible = true
                resetFade()
            end)

            pauseBtn.MouseButton1Click:Connect(function()
                if vid then pcall(function() vid:Pause() end) end
                playing = false
                playBtn.Visible = true
                pauseBtn.Visible = false
                resetFade()
            end)

            stopBtn.MouseButton1Click:Connect(function()
                if vid then pcall(function() vid:Stop() end) end
                playing = false
                playBtn.Visible = true
                pauseBtn.Visible = false
                resetFade()
            end)

            pauseBtn.Visible = auto
            playBtn.Visible = not auto

            local seeking = false
            local function vidSeek(posX)
                resetFade()
                local rx = seekRail.AbsolutePosition.X
                local rw = seekRail.AbsoluteSize.X
                local pct = math.clamp((posX - rx) / rw, 0, 1)
                seekFill.Size = UDim2.new(pct, 0, 1, 0)
                seekKnob.Position = UDim2.new(pct, 0, 0.5, 0)
                if vid and vid.TimeLength and vid.TimeLength > 0 then
                    pcall(function() vid.TimePosition = vid.TimeLength * pct end)
                end
            end

            seekRail.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    seeking = true
                    vidSeek(inp.Position.X)
                    resetFade()
                    inp.Changed:Connect(function()
                        if inp.UserInputState == Enum.UserInputState.End then seeking = false end
                    end)
                end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if seeking and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    vidSeek(inp.Position.X)
                end
            end)

            local function fmtTime(s)
                s = math.max(0, math.floor(s or 0))
                return string.format("%d:%02d", math.floor(s/60), s%60)
            end

            local hbConn = RunService.Heartbeat:Connect(function(dt)
                if not wrap.Parent then return end
                if ctrlVisible then
                    fadeTimer = fadeTimer - dt
                    if fadeTimer <= 0 and not seeking then
                        hideOverlay()
                    end
                end
                if not vid then return end
                local dur = vid.TimeLength or 0
                local pos = 0
                pcall(function() pos = vid.TimePosition end)
                if dur > 0 and not seeking then
                    local pct = math.clamp(pos / dur, 0, 1)
                    seekFill.Size = UDim2.new(pct, 0, 1, 0)
                    seekKnob.Position = UDim2.new(pct, 0, 0.5, 0)
                end
                timeCur.Text = fmtTime(pos)
                timeDur.Text = fmtTime(dur)
            end)

            if auto and hasVideo then
                task.spawn(function()
                    task.wait(0.08)
                    if vid and vid.Parent then
                        pcall(function() vid:Play() end)
                        playing = true
                        pauseBtn.Visible = true
                        playBtn.Visible = false
                    end
                end)
            end

            local mod = {Frame=wrap, Type="Video", VideoFrame=vid}
            function mod:Play()
                if vid then pcall(function() vid:Play() end); playing=true; playBtn.Visible=false; pauseBtn.Visible=true end
            end
            function mod:Pause()
                if vid then pcall(function() vid:Pause() end); playing=false; playBtn.Visible=true; pauseBtn.Visible=false end
            end
            function mod:Stop()
                if vid then pcall(function() vid:Stop() end); playing=false; playBtn.Visible=true; pauseBtn.Visible=false end
            end
            function mod:SetVideo(s)
                if not vid then return end
                local r = resolveMedia(s)
                if r ~= "" then
                    vid.Video = r
                    placeholder.Visible = false
                else
                    placeholder.Visible = true
                end
            end
            function mod:SetVolume(v)
                if vid then vid.Volume = math.clamp(v, 0, 1) end
                volLbl.Text = tostring(math.floor(math.clamp(v, 0, 1)*100)).."%"
            end
            function mod:SetAspectRatio(r)
                ratioNum = parseRatio(r)
                recalcAspect()
            end
            function mod:Destroy()
                pcall(function() hbConn:Disconnect() end)
                wrap:Destroy()
            end
            return mod
        end

        child.Audio = function(_, config)
            local opts = config or {}
            local parent = contentHolder
            if not parent then return end

            local title = opts.Name or opts.Title or "Audio"
            local subtitle = opts.SubName or opts.SubTitle or ""
            local src = opts.Audio or opts.Sound or ""
            local vol = (opts.Volume ~= nil) and math.clamp(opts.Volume, 0, 10) or 0.5
            local looped = opts.Looped ~= false
            local auto = opts.AutoPlay ~= false
            local playOutside = opts.PlayOutsideWindow == true

            local function resolve(s, noDownload)
                local mm = MediaManager
                if mm then return mm:Audio(s, noDownload) end
                if type(s)~="string" or s=="" then return "" end
                if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
                if s:match("^%d+$") then return "rbxassetid://"..s end
                return ""
            end

            local function fmtTime(s)
                s = math.max(0, math.floor(s or 0))
                return string.format("%d:%02d", math.floor(s/60), s%60)
            end

            local isHttp = type(src)=="string" and src:match("^https?://")
            local resolved = isHttp and resolve(src, true) or resolve(src, false)
            local pendingDownload = isHttp and (not resolved or resolved == "")
            local hasAudio = (resolved ~= nil and resolved ~= "") or pendingDownload

            local snd = nil
            local function initSound(resolvedId)
                local s2 = Instance.new("Sound")
                s2.Name = "FengAudio"
                pcall(function() s2.SoundId = resolvedId end)
                s2.Volume = vol
                s2.Looped = looped
                if playOutside then
                    s2.RollOffMaxDistance = 10000
                    s2.Parent = game:GetService("SoundService")
                else
                    s2.Parent = workspace
                end
                return s2
            end

            if hasAudio and not pendingDownload then
                snd = initSound(resolved)
            end

            local wrapHeight = (title ~= "" or subtitle ~= "") and 118 or 96
            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, -16, 0, wrapHeight)
            wrap.BackgroundTransparency = 0.9
            wrap.BorderSizePixel = 0
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Top")
            local wrapCorner = Instance.new("UICorner")
            wrapCorner.CornerRadius = UDim.new(0, 8)
            wrapCorner.Parent = wrap
            local wrapStroke = Instance.new("UIStroke")
            wrapStroke.Thickness = 1
            wrapStroke.Transparency = 0.6
            wrapStroke.Parent = wrap
            AddToRegistry(wrapStroke, "Color", "Stroke")

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 10)
            padding.PaddingRight = UDim.new(0, 10)
            padding.PaddingTop = UDim.new(0, 10)
            padding.PaddingBottom = UDim.new(0, 10)
            padding.Parent = wrap

            local topRow = Instance.new("Frame")
            topRow.Size = UDim2.new(1, 0, 0, (title ~= "" or subtitle ~= "") and 38 or 28)
            topRow.BackgroundTransparency = 1
            topRow.Parent = wrap

            local audioIcon = Instance.new("ImageLabel")
            audioIcon.Size = UDim2.fromOffset(20, 20)
            audioIcon.Position = UDim2.new(0, 0, 0.5, 0)
            audioIcon.AnchorPoint = Vector2.new(0, 0.5)
            audioIcon.BackgroundTransparency = 1
            audioIcon.ZIndex = 2
            audioIcon.Parent = topRow
            AddToRegistry(audioIcon, "ImageColor3", hasAudio and "Accent" or "SubText")
            audioIcon.Image = "rbxassetid://10747376008"

            local titleHolder = Instance.new("Frame")
            titleHolder.Size = UDim2.new(1, -110, 1, 0)
            titleHolder.Position = UDim2.new(0, 28, 0, 0)
            titleHolder.BackgroundTransparency = 1
            titleHolder.ZIndex = 2
            titleHolder.Parent = topRow

            local statusLbl = Instance.new("TextLabel")
            statusLbl.Size = UDim2.new(1, 0, 0, 16)
            statusLbl.Position = UDim2.new(0, 0, 0, (title ~= "" or subtitle ~= "") and 2 or 0)
            statusLbl.AnchorPoint = Vector2.new(0, 0)
            statusLbl.BackgroundTransparency = 1
            statusLbl.Text = (title ~= "" and title) or (hasAudio and "Audio" or "No audio source")
            statusLbl.TextSize = (title ~= "" or subtitle ~= "") and 12 or 11
            statusLbl.Font = (title ~= "" or subtitle ~= "") and Enum.Font.GothamBold or Enum.Font.Gotham
            statusLbl.TextXAlignment = Enum.TextXAlignment.Left
            statusLbl.TextTruncate = Enum.TextTruncate.AtEnd
            statusLbl.ZIndex = 2
            statusLbl.Parent = titleHolder
            AddToRegistry(statusLbl, "TextColor3", hasAudio and "Text" or "SubText")

            local subtitleLbl = nil
            if subtitle ~= "" then
                subtitleLbl = Instance.new("TextLabel")
                subtitleLbl.Size = UDim2.new(1, 0, 0, 13)
                subtitleLbl.Position = UDim2.new(0, 0, 0, 20)
                subtitleLbl.AnchorPoint = Vector2.new(0, 0)
                subtitleLbl.BackgroundTransparency = 1
                subtitleLbl.Text = subtitle
                subtitleLbl.TextSize = 10
                subtitleLbl.Font = Enum.Font.Gotham
                subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                subtitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
                subtitleLbl.Visible = true
                subtitleLbl.ZIndex = 2
                subtitleLbl.Parent = titleHolder
                AddToRegistry(subtitleLbl, "TextColor3", "SubText")
            end

            local controls = Instance.new("Frame")
            controls.Size = UDim2.new(0, 116, 1, 0)
            controls.Position = UDim2.new(1, 0, 0, 0)
            controls.AnchorPoint = Vector2.new(1, 0)
            controls.BackgroundTransparency = 1
            controls.Visible = hasAudio
            controls.Parent = topRow

            local ctrlLayout = Instance.new("UIListLayout")
            ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
            ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            ctrlLayout.Padding = UDim.new(0, 4)
            ctrlLayout.Parent = controls

            local function ctrlBtn(iconId, cb)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.fromOffset(24, 24)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = 3
                btn.Parent = controls
                local ic = Instance.new("ImageLabel")
                ic.Size = UDim2.fromOffset(16, 16)
                ic.Position = UDim2.new(0.5, 0, 0.5, 0)
                ic.AnchorPoint = Vector2.new(0.5, 0.5)
                ic.BackgroundTransparency = 1
                ic.ZIndex = 4
                ic.Parent = btn
                AddToRegistry(ic, "ImageColor3", "Text")
                local icons = {
                    play = "rbxassetid://10734923549",
                    pause = "rbxassetid://10734919336",
                    stop = "rbxassetid://10734972621",
                    external = "rbxassetid://10747366266",
                    import = "rbxassetid://10747366266",
                }
                ic.Image = icons[iconId] or "rbxassetid://10734923549"
                btn.MouseButton1Click:Connect(function() pcall(cb) end)
                return btn, ic
            end

            local playing = false
            local playBtn, playIco
            local pauseBtn, pauseIco
            local outsideBtn, outsideIco

            if hasAudio then
                local _downloading = false
                local function _doPlay()
                    if not snd then return end
                    pcall(function() snd:Play() end)
                    playing = true
                    if playBtn then playBtn.Visible = false end
                    if pauseBtn then pauseBtn.Visible = true end
                end
                local function _triggerPlay()
                    if _downloading then return end
                    if snd then
                        _doPlay()
                        return
                    end
                    if pendingDownload then
                        _downloading = true
                        if win then win:Notification("Audio", "Downloading audio, please wait...", "Info", 4) end
                        task.spawn(function()
                            local got = resolve(src, false)
                            _downloading = false
                            if got and got ~= "" then
                                pendingDownload = false
                                snd = initSound(got)
                                _doPlay()
                                if win then win:Notification("Audio", "Audio ready — playing now", "Success", 2) end
                            else
                                if win then win:Notification("Audio", "Failed to download audio", "Error", 3) end
                            end
                        end)
                    end
                end
                playBtn, playIco = ctrlBtn("play", _triggerPlay)
                pauseBtn, pauseIco = ctrlBtn("pause", function()
                    if snd then snd:Pause() end
                    playing = false
                    if playBtn then playBtn.Visible = true end
                    if pauseBtn then pauseBtn.Visible = false end
                end)
                pauseBtn.Visible = false

                local stopBtn, stopIco = ctrlBtn("stop", function()
                    if snd then pcall(function() snd:Stop(); snd.TimePosition = 0 end) end
                    playing = false
                    if playBtn then playBtn.Visible = true end
                    if pauseBtn then pauseBtn.Visible = false end
                end)

                local function toggleOutside()
                    playOutside = not playOutside
                    local iconName = playOutside and "external" or "import"
                    if outsideIco then
                        outsideIco.Image = icons[iconName] or "rbxassetid://10747366266"
                    end
                    if snd then
                        local wasPlaying = playing
                        pcall(function() if wasPlaying then snd:Stop() end end)
                        if playOutside then
                            snd.RollOffMaxDistance = 10000
                            snd.Parent = game:GetService("SoundService")
                        else
                            snd.Parent = workspace
                        end
                        if wasPlaying then pcall(function() snd:Play() end) end
                    end
                    if win then win:Notification("Audio", playOutside and "Play Outside Window: ON" or "Play Outside Window: OFF", "Info", 2) end
                end
                outsideBtn, outsideIco = ctrlBtn("external", toggleOutside)
                if outsideIco then
                    outsideIco.Image = playOutside and "rbxassetid://10747366266" or "rbxassetid://10747366266"
                end

                if auto and snd then
                    _doPlay()
                end
            end

            local seekRowOffset = (title ~= "" or subtitle ~= "") and 56 or 36
            local seekRow = Instance.new("Frame")
            seekRow.Size = UDim2.new(1, 0, 0, 24)
            seekRow.Position = UDim2.new(0, 0, 0, seekRowOffset)
            seekRow.BackgroundTransparency = 1
            seekRow.Visible = hasAudio
            seekRow.Parent = wrap

            local curLbl = Instance.new("TextLabel")
            curLbl.Size = UDim2.fromOffset(34, 20)
            curLbl.Position = UDim2.new(0, 0, 0.5, 0)
            curLbl.AnchorPoint = Vector2.new(0, 0.5)
            curLbl.BackgroundTransparency = 1
            curLbl.Text = "0:00"
            curLbl.TextSize = 10
            curLbl.Font = Enum.Font.Gotham
            curLbl.TextXAlignment = Enum.TextXAlignment.Left
            curLbl.ZIndex = 3
            curLbl.Parent = seekRow
            AddToRegistry(curLbl, "TextColor3", "SubText")

            local durLbl = Instance.new("TextLabel")
            durLbl.Size = UDim2.fromOffset(34, 20)
            durLbl.Position = UDim2.new(1, 0, 0.5, 0)
            durLbl.AnchorPoint = Vector2.new(1, 0.5)
            durLbl.BackgroundTransparency = 1
            durLbl.Text = "0:00"
            durLbl.TextSize = 10
            durLbl.Font = Enum.Font.Gotham
            durLbl.TextXAlignment = Enum.TextXAlignment.Right
            durLbl.ZIndex = 3
            durLbl.Parent = seekRow
            AddToRegistry(durLbl, "TextColor3", "SubText")

            local rail = Instance.new("Frame")
            rail.Size = UDim2.new(1, -76, 0, 4)
            rail.Position = UDim2.new(0, 38, 0.5, 0)
            rail.AnchorPoint = Vector2.new(0, 0.5)
            rail.BackgroundTransparency = 0.65
            rail.ZIndex = 2
            rail.Parent = seekRow
            AddToRegistry(rail, "BackgroundColor3", "SubText")
            Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundTransparency = 0
            fill.ZIndex = 3
            fill.Parent = rail
            AddToRegistry(fill, "BackgroundColor3", "Accent")
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(12, 12)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.ZIndex = 4
            knob.Parent = rail
            AddToRegistry(knob, "BackgroundColor3", "Accent")
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function seekTo(inputX)
                if not snd then return end
                local railX = rail.AbsolutePosition.X
                local railW = rail.AbsoluteSize.X
                if railW <= 0 then return end
                local pct = math.clamp((inputX - railX) / railW, 0, 1)
                local dur = snd.TimeLength or 0
                if dur > 0 then
                    pcall(function() snd.TimePosition = pct * dur end)
                end
            end

            rail.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    seekTo(inp.Position.X)
                end
            end)
            rail.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    seekTo(inp.Position.X)
                end
            end)

            local hbConn = RunService.Heartbeat:Connect(function()
                if not wrap.Parent then return end
                if not snd then return end
                local dur = snd.TimeLength or 0
                local pos = snd.TimePosition or 0
                curLbl.Text = fmtTime(pos)
                durLbl.Text = fmtTime(dur)
                local pct = dur > 0 and (pos / dur) or 0
                fill.Size = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, 0, 0.5, 0)
            end)

            local mod = {Frame=wrap, Type="Audio", Sound=snd}
            function mod:Play() if snd then pcall(function() snd:Play() end) end end
            function mod:Pause() if snd then pcall(function() snd:Pause() end) end end
            function mod:Stop() if snd then pcall(function() snd:Stop() end) end end
            function mod:SetVolume(v)
                if snd then snd.Volume = math.clamp(v, 0, 10) end
            end
            function mod:SetAudio(src)
                local r = resolve(src)
                if snd then
                    pcall(function() snd:Stop() end)
                    pcall(function() snd.SoundId = r end)
                else
                    snd = initSound(r)
                end
                hasAudio = r ~= ""
                controls.Visible = hasAudio
                seekRow.Visible = hasAudio
                statusLbl.Text = hasAudio and (title or "Audio") or "No audio source"
                if playBtn then playBtn.Visible = hasAudio end
                if pauseBtn then pauseBtn.Visible = false end
            end
            function mod:SetAudioTitle(title, subtitle)
                statusLbl.Text = title or (hasAudio and "Audio" or "No audio source")
                if subtitleLbl then
                    subtitleLbl.Text = subtitle or ""
                    subtitleLbl.Visible = subtitle and subtitle ~= ""
                end
            end
            function mod:SetPlayOutside(enabled)
                playOutside = enabled
                if snd then
                    local wasPlaying = playing
                    pcall(function() snd:Stop() end)
                    if enabled then
                        snd.Parent = game:GetService("SoundService")
                    else
                        snd.Parent = workspace
                    end
                    if wasPlaying then pcall(function() snd:Play() end) end
                end
            end
            function mod:Destroy()
                if hbConn then hbConn:Disconnect() end
                if snd then pcall(function() snd:Stop(); snd:Destroy() end) end
                wrap:Destroy()
            end

            return mod
        end

        child.Viewport = function(_, config)
            local opts = config or {}
            local parent = contentHolder
            if not parent then return end

            local UIS = UserInputService
            local RS  = RunService
            local TS  = TweenService

            local height     = opts.Height or 200
            local focused    = (opts.Focused ~= false)
            local interactive= (opts.Interactive ~= false)
            local camera     = opts.Camera or Instance.new("Camera")
            local obj        = opts.Object
            local aspectRatio= opts.AspectRatio
            local radius     = opts.Radius or 8

            assert(obj, "Viewport - Missing Object")

            local function parseRatio(r)
                if type(r) == "number" then return r end
                if type(r) == "string" then
                    local w, h = r:match("(%d+):(%d+)")
                    if w and h and tonumber(h) ~= 0 then return tonumber(w) / tonumber(h) end
                end
                return nil
            end

            local wrap = Instance.new("Frame")
            wrap.Name = "ViewportHolder"
            wrap.Size = UDim2.new(1, -16, 0, height)
            wrap.BackgroundTransparency = 0.9
            wrap.BorderSizePixel = 0
            wrap.ClipsDescendants = true
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Main")

            local wrapCorner = Instance.new("UICorner")
            wrapCorner.CornerRadius = UDim.new(0, radius)
            wrapCorner.Parent = wrap

            local wrapStroke = Instance.new("UIStroke")
            wrapStroke.Thickness = 1
            wrapStroke.Transparency = 0.6
            wrapStroke.Parent = wrap
            AddToRegistry(wrapStroke, "Color", "Stroke")

            local ratioNum = parseRatio(aspectRatio)
            local function recalcAspect()
                if not ratioNum or ratioNum <= 0 then return end
                local w = wrap.AbsoluteSize.X
                if w > 0 then
                    wrap.Size = UDim2.new(1, -16, 0, math.floor(w / ratioNum))
                end
            end
            wrap:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcAspect)
            task.defer(recalcAspect)

            local bg = Instance.new("ImageLabel")
            bg.Size = UDim2.fromScale(1, 1)
            bg.BackgroundTransparency = 0.1
            bg.BorderSizePixel = 0
            bg.Image = ""
            bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            bg.Parent = wrap
            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, radius)
            bgCorner.Parent = bg
            AddToRegistry(bg, "BackgroundColor3", "Main")

            local vp = Instance.new("ViewportFrame")
            vp.Name = "Viewport"
            vp.Size = UDim2.fromScale(1, 1)
            vp.BackgroundTransparency = 1
            vp.CurrentCamera = camera
            vp.Active = interactive
            vp.Parent = wrap

            obj.Parent = vp

            local Dragging = false
            local Pinching = false
            local LastMousePos = nil
            local LastPinchDist = 0
            local ScrollFrameRef = nil

            local function findScrollFrame(inst)
                while inst do
                    if inst:IsA("ScrollingFrame") then
                        return inst
                    end
                    inst = inst.Parent
                end
                return nil
            end
            ScrollFrameRef = findScrollFrame(wrap)

            local function isMouseInViewport(pos)
                local ap = vp.AbsolutePosition
                local as = vp.AbsoluteSize
                return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
            end

            local function updateZoomValue()
                local ok, mpos = pcall(function() return obj:GetPivot().Position end)
                if ok and camera then
                    local dist = (camera.CFrame.Position - mpos).Magnitude
                    if self then self.Value = dist end
                end
            end

            local function focusCamera()
                local mpos = obj:GetPivot().Position
                local size = obj:IsA("BasePart") and obj.Size or select(2, obj:GetBoundingBox(0))
                local ext = math.max(size.X, size.Y, size.Z)
                camera.CFrame = CFrame.new(mpos + Vector3.new(0, ext/2, ext*2), mpos)
                updateZoomValue()
            end

            if focused then
                task.defer(focusCamera)
            end

            vp.MouseEnter:Connect(function()
                if interactive and ScrollFrameRef then
                    ScrollFrameRef.ScrollingEnabled = false
                end
            end)

            vp.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    if ScrollFrameRef then
                        ScrollFrameRef.ScrollingEnabled = true
                    end
                end
            end)

            vp.InputBegan:Connect(function(inp)
                if interactive then
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or (inp.UserInputType == Enum.UserInputType.Touch and not Pinching) then
                        Dragging = true
                        LastMousePos = inp.Position
                    end
                end
            end)

            UIS.InputEnded:Connect(function(inp)
                if interactive then
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end
            end)

            UIS.InputChanged:Connect(function(inp)
                if interactive and Dragging and not Pinching then
                    if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                        local delta = inp.Position - LastMousePos
                        LastMousePos = inp.Position
                        local pos = obj:GetPivot().Position
                        local ry = CFrame.fromAxisAngle(Vector3.new(0,1,0), -delta.X * 0.02)
                        camera.CFrame = CFrame.new(pos) * ry * CFrame.new(-pos) * camera.CFrame
                        local rx = CFrame.fromAxisAngle(camera.CFrame.RightVector, -delta.Y * 0.02)
                        local pitched = CFrame.new(pos) * rx * CFrame.new(-pos) * camera.CFrame
                        if pitched.UpVector.Y > 0.1 then
                            camera.CFrame = pitched
                        end
                        updateZoomValue()
                    end
                end
            end)

            vp.InputChanged:Connect(function(inp)
                if interactive then
                    if inp.UserInputType == Enum.UserInputType.MouseWheel then
                        if not isMouseInViewport(UIS:GetMouseLocation()) then return end
                        local zoom = inp.Position.Z * 2
                        camera.CFrame = camera.CFrame + camera.CFrame.LookVector * zoom
                        updateZoomValue()
                    end
                end
            end)

            UIS.TouchPinch:Connect(function(touches, scale, vel, state)
                if interactive then
                    if state == Enum.UserInputState.Begin then
                        local mid = (touches[1] + touches[2]) / 2
                        if not isMouseInViewport(mid) then return end
                        Pinching = true
                        Dragging = false
                        LastPinchDist = (touches[1] - touches[2]).Magnitude
                    elseif state == Enum.UserInputState.Change then
                        if not Pinching then return end
                        local cur = (touches[1] - touches[2]).Magnitude
                        local d = (cur - LastPinchDist) * 0.03
                        LastPinchDist = cur
                        camera.CFrame = camera.CFrame + camera.CFrame.LookVector * d
                        updateZoomValue()
                    elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                        Pinching = false
                    end
                end
            end)

            local self = {
                Frame = wrap,
                Type = "Viewport",
                Object = obj,
                Camera = camera,
                Interactive = interactive,
                Height = height,
                Focused = focused,
                Value = nil,
            }

            function self:SetObject(newObj, clone)
                if clone then newObj = newObj:Clone() end
                if self.Object then self.Object:Destroy() end
                self.Object = newObj
                self.Object.Parent = vp
                if self.Focused then focusCamera() end
            end

            function self:SetHeight(h)
                self.Height = h
                wrap.Size = UDim2.new(1, -16, 0, h)
            end

            function self:SetAspectRatio(ratio)
                ratioNum = parseRatio(ratio)
                if ratioNum then recalcAspect() else wrap.Size = UDim2.new(1, -16, 0, self.Height) end
            end

            function self:Focus()
                if self.Object then focusCamera() end
            end

            function self:SetCamera(cam)
                self.Camera = cam
                vp.CurrentCamera = cam
            end

            function self:SetInteractive(val)
                self.Interactive = val
                vp.Active = val
            end

            function self:SetValue(dist)
                if type(dist) ~= "number" then return end
                local ok, mpos = pcall(function() return self.Object:GetPivot().Position end)
                if not ok then return end
                local dir = (self.Camera.CFrame.Position - mpos)
                if dir.Magnitude < 1e-4 then dir = Vector3.new(0, 0, 1) end
                dir = dir.Unit
                self.Camera.CFrame = CFrame.new(mpos + dir * dist, mpos)
                self.Value = dist
            end

            function self:Destroy()
                wrap:Destroy()
            end

            updateZoomValue()

            return self
        end

        -- ===== Social（支持 Name / SubName / SmlName / Logo / copy / Cbn）=====
        child.Social = function(_, config)
            config = config or {}
            local parent = contentHolder
            if not parent then return end

            local displayName = tostring(config.Name or config.DisplayName or "")
            local subName = tostring(config.SubName or config.Subtitle or "")
            local platform = tostring(config.SmlName or config.Platform or "")
            local avatarSrc = config.Logo or config.Avatar or ""
            local copyText = tostring(config.copy or "")
            local buttonText = tostring(config.Cbn or "复制")

            if displayName == "" then
                displayName = "用户"
            end

            -- 主卡片
            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, 0, 0, 64)
            wrap.BackgroundTransparency = 0.82
            wrap.BorderSizePixel = 0
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Top")

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = wrap

            local stroke = Instance.new("UIStroke")
            stroke.Transparency = 0.45
            stroke.Thickness = 1.5
            stroke.Parent = wrap
            AddToRegistry(stroke, "Color", "Stroke")

            -- 头像
            local avatarBg = Instance.new("Frame")
            avatarBg.Name = "AvatarBg"
            avatarBg.Size = UDim2.fromOffset(42, 42)
            avatarBg.Position = UDim2.new(0, 11, 0.5, 0)
            avatarBg.AnchorPoint = Vector2.new(0, 0.5)
            avatarBg.BackgroundColor3 = Color3.fromRGB(90,90,90)
            avatarBg.Parent = wrap
            avatarBg.ClipsDescendants = true

            local avatarCorner = Instance.new("UICorner")
            avatarCorner.CornerRadius = UDim.new(0, 8)
            avatarCorner.Parent = avatarBg

            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size = UDim2.fromScale(1, 1)
            avatarImg.BackgroundTransparency = 1
            avatarImg.Parent = avatarBg

            local avatarImgCorner = Instance.new("UICorner")
            avatarImgCorner.CornerRadius = UDim.new(0, 8)
            avatarImgCorner.Parent = avatarImg

            if avatarSrc ~= "" then
                avatarCorner.CornerRadius = UDim.new(1, 0)
                avatarImgCorner.CornerRadius = UDim.new(1, 0)
            end

            -- 显示名
            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "DisplayName"
            nameLbl.Text = displayName
            nameLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
            nameLbl.TextSize = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.BackgroundTransparency = 1
            nameLbl.Size = UDim2.new(1, -140, 0, 16)
            nameLbl.Position = UDim2.new(0, 62, 0, 9)
            nameLbl.Parent = wrap
            AddToRegistry(nameLbl, "TextColor3", "Text")

            -- 副标题
            if subName ~= "" then
                local subNameLbl = Instance.new("TextLabel")
                subNameLbl.Name = "SubName"
                subNameLbl.Text = subName
                subNameLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
                subNameLbl.TextSize = 11
                subNameLbl.TextXAlignment = Enum.TextXAlignment.Left
                subNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                subNameLbl.BackgroundTransparency = 1
                subNameLbl.Size = UDim2.new(1, -140, 0, 13)
                subNameLbl.Position = UDim2.new(0, 62, 0, 27)
                subNameLbl.Parent = wrap
                AddToRegistry(subNameLbl, "TextColor3", "SubText")
            end

            -- 平台标签
            if platform ~= "" then
                local platformLbl = Instance.new("TextLabel")
                platformLbl.Name = "PlatformLabel"
                platformLbl.Text = platform
                platformLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
                platformLbl.TextSize = 10
                platformLbl.TextTransparency = 0.3
                platformLbl.TextXAlignment = Enum.TextXAlignment.Left
                platformLbl.BackgroundTransparency = 1
                platformLbl.Size = UDim2.new(1, -140, 0, 12)
                platformLbl.Position = UDim2.new(0, 62, 0, subName ~= "" and 42 or 27)
                platformLbl.Parent = wrap
                AddToRegistry(platformLbl, "TextColor3", "SubText")
            end

            -- 复制按钮（点击复制 copy 字段内容，按钮文字使用 Cbn）
            if copyText ~= "" then
                local copyBtn = Instance.new("TextButton")
                copyBtn.Name = "CopyButton"
                copyBtn.Text = buttonText
                copyBtn.Size = UDim2.fromOffset(52, 26)
                copyBtn.Position = UDim2.new(1, -11, 0.5, 0)
                copyBtn.AnchorPoint = Vector2.new(1, 0.5)
                copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                copyBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                copyBtn.TextSize = 12
                copyBtn.Parent = wrap
                AddToRegistry(copyBtn, "BackgroundColor3", "Element")

                local copyCorner = Instance.new("UICorner")
                copyCorner.CornerRadius = UDim.new(0, 8)
                copyCorner.Parent = copyBtn

                local copyStroke = Instance.new("UIStroke")
                copyStroke.Transparency = 0.4
                copyStroke.Thickness = 1
                copyStroke.Parent = copyBtn
                AddToRegistry(copyStroke, "Color", "Stroke")

                -- 点击复制 copy 内容
                copyBtn.MouseButton1Click:Connect(function()
                    pcall(function() toclipboard(copyText) end)
                    if win then win:Notification("", "已复制到剪贴板", "Success", 2) end
                end)
            end

            -- 头像加载
            task.spawn(function()
                local imgUrl = nil
                if avatarSrc ~= "" then
                    if avatarSrc:match("^rbxassetid://") or avatarSrc:match("^rbxasset://") or avatarSrc:match("^http") then
                        imgUrl = avatarSrc
                    elseif tonumber(avatarSrc) then
                        imgUrl = "rbxassetid://" .. avatarSrc
                    end
                end

                if imgUrl and imgUrl ~= "" then
                    local ok, asset = pcall(function()
                        return MediaManager:Image(imgUrl)
                    end)
                    if ok and asset and asset ~= "" then
                        avatarImg.Image = asset
                        avatarCorner.CornerRadius = UDim.new(1, 0)
                        avatarImgCorner.CornerRadius = UDim.new(1, 0)
                    end
                end
            end)

            local mod = {Frame=wrap, Type="Social"}
            function mod:SetName(newName)
                displayName = tostring(newName or "")
                local lbl = wrap:FindFirstChild("DisplayName")
                if lbl then lbl.Text = displayName end
            end
            function mod:SetSubName(newSubName)
                subName = tostring(newSubName or "")
                local existing = wrap:FindFirstChild("SubName")
                if existing then existing:Destroy() end
                if subName ~= "" then
                    local newLbl = Instance.new("TextLabel")
                    newLbl.Name = "SubName"
                    newLbl.Text = subName
                    newLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
                    newLbl.TextSize = 11
                    newLbl.TextXAlignment = Enum.TextXAlignment.Left
                    newLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    newLbl.BackgroundTransparency = 1
                    newLbl.Size = UDim2.new(1, -140, 0, 13)
                    newLbl.Position = UDim2.new(0, 62, 0, 27)
                    newLbl.Parent = wrap
                    AddToRegistry(newLbl, "TextColor3", "SubText")
                end
            end
            function mod:SetSmlName(newPlatform)
                platform = tostring(newPlatform or "")
                local existing = wrap:FindFirstChild("PlatformLabel")
                if existing then existing:Destroy() end
                if platform ~= "" then
                    local newLbl = Instance.new("TextLabel")
                    newLbl.Name = "PlatformLabel"
                    newLbl.Text = platform
                    newLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
                    newLbl.TextSize = 10
                    newLbl.TextTransparency = 0.3
                    newLbl.TextXAlignment = Enum.TextXAlignment.Left
                    newLbl.BackgroundTransparency = 1
                    newLbl.Size = UDim2.new(1, -140, 0, 12)
                    newLbl.Position = UDim2.new(0, 62, 0, subName ~= "" and 42 or 27)
                    newLbl.Parent = wrap
                    AddToRegistry(newLbl, "TextColor3", "SubText")
                end
            end
            function mod:SetLogo(newLogo)
                avatarSrc = tostring(newLogo or "")
                if avatarSrc ~= "" then
                    local imgUrl
                    if avatarSrc:match("^rbxassetid://") or avatarSrc:match("^rbxasset://") or avatarSrc:match("^http") then
                        imgUrl = avatarSrc
                    elseif tonumber(avatarSrc) then
                        imgUrl = "rbxassetid://" .. avatarSrc
                    end
                    if imgUrl then
                        local ok, asset = pcall(function()
                            return MediaManager:Image(imgUrl)
                        end)
                        if ok and asset and asset ~= "" then
                            avatarImg.Image = asset
                        end
                    end
                end
            end
            function mod:SetCopy(newText)
                copyText = tostring(newText or "")
                local existing = wrap:FindFirstChild("CopyButton")
                if existing then existing:Destroy() end
                if copyText ~= "" then
                    local newBtn = Instance.new("TextButton")
                    newBtn.Name = "CopyButton"
                    newBtn.Text = buttonText
                    newBtn.Size = UDim2.fromOffset(52, 26)
                    newBtn.Position = UDim2.new(1, -11, 0.5, 0)
                    newBtn.AnchorPoint = Vector2.new(1, 0.5)
                    newBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    newBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
                    newBtn.TextSize = 12
                    newBtn.Parent = wrap
                    AddToRegistry(newBtn, "BackgroundColor3", "Element")
                    local newCorner = Instance.new("UICorner")
                    newCorner.CornerRadius = UDim.new(0, 8)
                    newCorner.Parent = newBtn
                    local newStroke = Instance.new("UIStroke")
                    newStroke.Transparency = 0.4
                    newStroke.Thickness = 1
                    newStroke.Parent = newBtn
                    AddToRegistry(newStroke, "Color", "Stroke")
                    newBtn.MouseButton1Click:Connect(function()
                        pcall(function() toclipboard(copyText) end)
                        if win then win:Notification("", "已复制到剪贴板", "Success", 2) end
                    end)
                end
            end
            function mod:SetCbn(newText)
                buttonText = tostring(newText or "复制")
                local btn = wrap:FindFirstChild("CopyButton")
                if btn then btn.Text = buttonText end
            end
            function mod:Destroy()
                wrap:Destroy()
            end
            return mod
        end

        return child
    end
    return createSection
end

function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Name or "FengY3"
    local Subtitle = Config.SubName
    local Keybind = Config.Keybind 
    local IconAsset = Config.Logo
    local SceneId = Config.Scene or 102597607447167

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
            local customTheme = {}
            for k, v in pairs(CurrentTheme) do
                customTheme[k] = v
            end
            if t.Main   then customTheme.Main   = toC3(t.Main) end
            if t.Top    then customTheme.Top    = toC3(t.Top) end
            if t.Text   then customTheme.Text   = toC3(t.Text) end
            if t.Accent then customTheme.Accent = toC3(t.Accent) end
            if t.Stroke then customTheme.Stroke = toC3(t.Stroke) end
            if t.SubText then customTheme.SubText = toC3(t.SubText) end
            if t.Element then customTheme.Element = toC3(t.Element) end
            if t.Hover then customTheme.Hover = toC3(t.Hover) end

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

    local FINAL_WIDTH = 500
    local FINAL_HEIGHT = 299

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    AddToRegistry(Stroke, "Color", "Stroke")

    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "FluentBG"
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    if type(SceneId) == "number" or (type(SceneId) == "string" and tonumber(SceneId)) then
        bgImage.Image = "rbxassetid://" .. tostring(SceneId)
    else
        bgImage.Image = tostring(SceneId)
    end
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ZIndex = 0
    bgImage.Parent = MainFrame

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 16)
    bgCorner.Parent = bgImage

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Rotation = 0
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 10, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 10, 20))
    })
    bgGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.6),
        NumberSequenceKeypoint.new(0.5, 0.0),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    bgGradient.Parent = bgImage

    local shineConn
    local function startShine()
        local rot = 0
        shineConn = RunService.RenderStepped:Connect(function(dt)
            rot = (rot + dt * 20) % 360
            bgGradient.Rotation = rot
        end)
    end
    startShine()

    table.insert(WindowCleanup, function()
        if shineConn then shineConn:Disconnect() end
    end)

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

    local resizerStroke = Instance.new("UIStroke")
    resizerStroke.Thickness = 4
    resizerStroke.Color = Color3.new(1, 1, 1)
    resizerStroke.Transparency = 0
    resizerStroke.Parent = Resizer

    local resizerCorner = Instance.new("UICorner")
    resizerCorner.CornerRadius = UDim.new(0, 6)
    resizerCorner.Parent = Resizer

    local resizerVisible = false
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

    task.spawn(function()
        local rot = 0
        while ScreenGui.Parent do
            if RainbowEnabled then
                local t = tick() * RainbowSpeed
                if RainbowType == "Linear Gradient (Solid Rainbow)" then
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Animated/Cycling Rainbow" then
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Smooth Fading Gradient" then
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Step/Band Rainbow" then
                    local step = math.floor((t % 2) * 4) / 4
                    Stroke.Color = Color3.fromHSV(step, 1, 1)
                elseif RainbowType == "Rainbow Pulse" then
                    local pulse = (math.sin(t * 3) + 1) / 2
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
                elseif RainbowType == "Radial Rainbow" then
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
                elseif RainbowType == "Neon/Glowing Rainbow" then
                    Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.8, 1)
                elseif RainbowType == "Pastel Rainbow" then
                    Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.4, 1)
                elseif RainbowType == "Vertical/Horizontal Fade" then
                    Stroke.Color = Color3.fromHSV(t % 5/5, 1, 1)
                end
            else
                Stroke.Color = CurrentTheme.Stroke
            end
            RunService.RenderStepped:Wait()
        end
    end)

    local IntroHolder = Instance.new("Frame")
    IntroHolder.Size = UDim2.new(1, 999999, 1, 999999)
    IntroHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    IntroHolder.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
    IntroHolder.BackgroundTransparency = 1
    IntroHolder.ZIndex = 50
    IntroHolder.Parent = ScreenGui

    local function formatIcon(asset)
        if tonumber(asset) then
            return "rbxassetid://" .. asset
        elseif type(asset) == "string" and asset:match("^rbxassetid://") then
            return asset
        elseif type(asset) == "string" and asset:match("^http") then
            return asset
        elseif type(asset) == "string" then
            return "rbxassetid://" .. asset
        end
        return "rbxassetid://78229538488090"
    end

    local IntroLogo = Instance.new("ImageLabel")
    IntroLogo.Size = UDim2.new(0, 0, 0, 0)
    IntroLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroLogo.Position = UDim2.new(0.5, 0, 0.5, -16)
    IntroLogo.BackgroundTransparency = 1
    IntroLogo.Image = formatIcon(IconAsset or "78229538488090")
    IntroLogo.ZIndex = 51
    IntroLogo.Parent = IntroHolder
    Instance.new("UICorner", IntroLogo).CornerRadius = UDim.new(1, 0)

    local IntroTitle = Instance.new("TextLabel")
    IntroTitle.Size = UDim2.new(0, 0, 0, 20)
    IntroTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroTitle.Position = UDim2.new(0.5, 0, 0.5, 40)
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.Text = Title
    IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntroTitle.TextTransparency = 1
    IntroTitle.TextSize = 20
    IntroTitle.ZIndex = 51
    IntroTitle.Parent = IntroHolder

    local IntroSub = Instance.new("TextLabel")
    IntroSub.Size = UDim2.new(0, 0, 0, 16)
    IntroSub.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroSub.Position = UDim2.new(0.5, 0, 0.5, 62)
    IntroSub.BackgroundTransparency = 1
    IntroSub.Font = Enum.Font.Gotham
    IntroSub.Text = Subtitle or ""
    IntroSub.TextColor3 = Color3.fromRGB(200, 200, 200)
    IntroSub.TextTransparency = 1
    IntroSub.TextSize = 16
    IntroSub.ZIndex = 51
    IntroSub.Parent = IntroHolder

    TweenService:Create(IntroHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.85
    }):Play()
    TweenService:Create(IntroLogo, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 82, 0, 82)
    }):Play()
    TweenService:Create(IntroTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    TweenService:Create(IntroSub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()

    task.wait(1.3)

    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, FINAL_WIDTH, 0, FINAL_HEIGHT)
    }):Play()

    TweenService:Create(IntroHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(IntroTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(IntroSub, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    }):Play()
    TweenService:Create(IntroLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.wait(0.35)
    IntroHolder:Destroy()

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

    local function createControlButton(iconAsset, fallbackText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.BackgroundTransparency = 0.2
        btn.BackgroundColor3 = CurrentTheme.Element or CurrentTheme.Top
        btn.Parent = ButtonGroup

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = btn

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 0, 0, 0)
        accent.AnchorPoint = Vector2.new(0.5, 0.5)
        accent.Position = UDim2.new(0.5, 0, 0.5, 0)
        accent.BackgroundTransparency = 1
        accent.ZIndex = 2
        accent.BackgroundColor3 = CurrentTheme.Accent
        accent.Parent = btn

        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(0, 7)
        accentCorner.Parent = accent

        local accentGrad = Instance.new("UIGradient")
        accentGrad.Rotation = -115
        accentGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
            ColorSequenceKeypoint.new(1, CurrentTheme.Accent)
        })
        accentGrad.Parent = accent

        local content
        if iconAsset then
            content = Instance.new("ImageLabel")
            content.Size = UDim2.new(0, 14, 0, 14)
            content.AnchorPoint = Vector2.new(0.5, 0.5)
            content.Position = UDim2.new(0.5, 0, 0.5, 0)
            content.BackgroundTransparency = 1
            content.Image = iconAsset
            content.ImageColor3 = CurrentTheme.Text
            content.ImageTransparency = 0.3
            content.ZIndex = 3
            content.Parent = btn
        else
            content = Instance.new("TextLabel")
            content.Size = UDim2.new(1, 0, 1, 0)
            content.BackgroundTransparency = 1
            content.Font = Enum.Font.GothamBold
            content.Text = fallbackText or ""
            content.TextSize = 18
            content.TextColor3 = CurrentTheme.Text
            content.TextTransparency = 0.3
            content.ZIndex = 3
            content.Parent = btn
        end

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundTransparency = 0}, 0.2)
            if content then
                local transProp = content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                Tween(content, {[transProp] = 0}, 0.2)
            end
            Tween(accent, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}, 0.2)
        end)

        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.2}, 0.2)
            if content then
                local transProp = content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                Tween(content, {[transProp] = 0.3}, 0.2)
            end
            Tween(accent, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
        end)

        btn.MouseButton1Click:Connect(callback)

        table.insert(ThemeListeners, function()
            btn.BackgroundColor3 = CurrentTheme.Element or CurrentTheme.Top
            accent.BackgroundColor3 = CurrentTheme.Accent
            accentGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
                ColorSequenceKeypoint.new(1, CurrentTheme.Accent)
            })
            if content and content:IsA("ImageLabel") then
                content.ImageColor3 = CurrentTheme.Text
            elseif content and content:IsA("TextLabel") then
                content.TextColor3 = CurrentTheme.Text
            end
        end)

        return btn
    end

    local MinimizeBtn = createControlButton(nil, "−", function()
        MainFrame.Visible = false
    end)

    local MaximizeBtn = createControlButton("rbxassetid://6031090998", nil, function()
        resizerVisible = not resizerVisible
        Resizer.Visible = resizerVisible
    end)

    local CloseBtn = createControlButton("rbxassetid://130510492706892", nil, function()
        ScreenGui:Destroy()
    end)

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

    local leftWidth = 160

    local LeftContainer = Instance.new("Frame")
    LeftContainer.Size = UDim2.new(0, leftWidth, 1, -topbarHeight)
    LeftContainer.Position = UDim2.new(0, 0, 0, topbarHeight)
    LeftContainer.BackgroundTransparency = 0.3
    LeftContainer.BackgroundColor3 = CurrentTheme.Main
    LeftContainer.ClipsDescendants = true
    LeftContainer.Parent = MainFrame

    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 16)
    leftCorner.Parent = LeftContainer

    local function createCorner(pos, anchor)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 16, 0, 16)
        container.Position = pos
        container.AnchorPoint = anchor
        container.BackgroundTransparency = 1
        container.BorderSizePixel = 0
        container.ZIndex = 0
        container.ClipsDescendants = true
        container.Parent = LeftContainer

        local arc = Instance.new("Frame")
        arc.Size = UDim2.new(0, 32, 0, 32)
        local offsetX, offsetY = 0, 0
        if anchor.X == 0 and anchor.Y == 0 then
            offsetX, offsetY = -16, -16
        elseif anchor.X == 1 and anchor.Y == 0 then
            offsetX, offsetY = 0, -16
        elseif anchor.X == 1 and anchor.Y == 1 then
            offsetX, offsetY = 0, 0
        end
        arc.Position = UDim2.new(0, offsetX, 0, offsetY)
        arc.BackgroundColor3 = CurrentTheme.Main
        arc.BackgroundTransparency = 0.2
        arc.BorderSizePixel = 0
        arc.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = arc

        table.insert(ThemeListeners, function()
            arc.BackgroundColor3 = CurrentTheme.Main
        end)

        return container
    end

    createCorner(UDim2.new(0, 0, 0, 0), Vector2.new(0, 0))
    createCorner(UDim2.new(1, 0, 0, 0), Vector2.new(1, 0))
    createCorner(UDim2.new(1, 0, 1, 0), Vector2.new(1, 1))

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -55)
    TabScroll.Position = UDim2.new(0, 0, 0, 0)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    TabScroll.Parent = LeftContainer

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 4)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = TabScroll

    local function updateTabCanvas()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 20)
    end
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
    task.spawn(updateTabCanvas)

    Window._currentCategory = nil

    function Window:Category(config)
        local name = type(config) == "table" and config.Name or config
        local collapsible = type(config) == "table" and config.Collapsible or false
        local opened = true
        if type(config) == "table" and config.Opened ~= nil then
            opened = config.Opened
        end

        local categoryFrame = Instance.new("Frame")
        categoryFrame.Size = UDim2.new(1, 0, 0, 0)
        categoryFrame.AutomaticSize = Enum.AutomaticSize.Y
        categoryFrame.BackgroundTransparency = 1
        categoryFrame.Parent = TabScroll

        local catLayout = Instance.new("UIListLayout")
        catLayout.FillDirection = Enum.FillDirection.Vertical
        catLayout.SortOrder = Enum.SortOrder.LayoutOrder
        catLayout.Padding = UDim.new(0, 0)
        catLayout.Parent = categoryFrame

        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundTransparency = 1
        header.Text = name
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Font = Enum.Font.GothamBold
        header.TextSize = 13
        header.TextColor3 = CurrentTheme.Text
        header.TextTransparency = 0.5
        header.Parent = categoryFrame
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.Parent = header
        AddToRegistry(header, "TextColor3", "Text")

        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0, 12, 0, 12)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://8240930340"
        arrow.ImageColor3 = CurrentTheme.Text
        arrow.ImageTransparency = 0.3
        arrow.Visible = collapsible
        arrow.Rotation = opened and 0 or 180
        arrow.Parent = header
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -10, 0.5, 0)
        AddToRegistry(arrow, "ImageColor3", "Text")

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 0, 0)
        content.BackgroundTransparency = 1
        content.AutomaticSize = Enum.AutomaticSize.None
        content.ClipsDescendants = true
        content.Visible = true
        content.Parent = categoryFrame

        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 4)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentList.Parent = content

        local currentTween = nil

        local function getContentHeight()
            return contentList.AbsoluteContentSize.Y or 0
        end

        local function setContentHeight(targetHeight, animate)
            targetHeight = math.max(0, targetHeight)
            local currentHeight = content.Size.Y.Offset
            if animate and currentHeight ~= targetHeight then
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                currentTween = TweenService:Create(
                    content,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { Size = UDim2.new(1, 0, 0, targetHeight) }
                )
                currentTween:Play()
                currentTween.Completed:Connect(function()
                    currentTween = nil
                    task.spawn(updateTabCanvas)
                end)
            else
                content.Size = UDim2.new(1, 0, 0, targetHeight)
                task.spawn(updateTabCanvas)
            end
        end

        local function toggleCategory()
            if not collapsible then return end
            opened = not opened
            Tween(arrow, { Rotation = opened and 0 or 180 }, 0.25)
            local targetHeight = opened and getContentHeight() or 0
            setContentHeight(targetHeight, true)
        end

        header.MouseButton1Click:Connect(toggleCategory)

        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if opened then
                local h = getContentHeight()
                if math.abs(h - content.Size.Y.Offset) > 0.5 then
                    setContentHeight(h, false)
                end
            end
        end)

        task.spawn(function()
            task.wait()
            local h = getContentHeight()
            local initialHeight = opened and h or 0
            content.Size = UDim2.new(1, 0, 0, initialHeight)
            updateTabCanvas()
        end)

        Window._currentCategory = {
            frame = categoryFrame,
            content = content,
            contentList = contentList,
            header = header,
            label = header,
            arrow = arrow,
            collapsible = collapsible,
            opened = opened,
            toggle = toggleCategory
        }

        table.insert(ThemeListeners, function()
            header.TextColor3 = CurrentTheme.Text
            arrow.ImageColor3 = CurrentTheme.Text
        end)

        return Window._currentCategory
    end

    function Window:TabDivider()
        local parentContainer = TabScroll
        if Window._currentCategory then
            parentContainer = Window._currentCategory.content
        end
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Position = UDim2.new(0, 10, 0, 0)
        line.BackgroundColor3 = CurrentTheme.Stroke
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = parentContainer
        AddToRegistry(line, "BackgroundColor3", "Stroke")
        table.insert(ThemeListeners, function()
            line.BackgroundColor3 = CurrentTheme.Stroke
        end)
    end

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 140, 0, 40)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -10)
    ProfileFrame.AnchorPoint = Vector2.new(0, 1)
    ProfileFrame.BackgroundTransparency = 0.05
    ProfileFrame.Parent = LeftContainer
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 10)
    AddToRegistry(ProfileFrame, "BackgroundColor3", "Top")

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 26, 0, 26)
    Avatar.Position = UDim2.new(0, 8, 0.5, -13)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)

    local realDisplayName = LocalPlayer.DisplayName
    local realUsername = "@" .. LocalPlayer.Name

    local DispName = Instance.new("TextLabel")
    DispName.Text = realDisplayName
    DispName.Size = UDim2.new(1, -45, 0, 15)
    DispName.Position = UDim2.new(0, 40, 0, 5)
    DispName.BackgroundTransparency = 1
    DispName.Font = Enum.Font.GothamMedium
    DispName.TextSize = 11
    DispName.TextXAlignment = Enum.TextXAlignment.Left
    DispName.Parent = ProfileFrame
    AddToRegistry(DispName, "TextColor3", "Text")

    local UsrName = Instance.new("TextLabel")
    UsrName.Text = realUsername
    UsrName.Size = UDim2.new(1, -45, 0, 15)
    UsrName.Position = UDim2.new(0, 40, 0, 19)
    UsrName.BackgroundTransparency = 1
    UsrName.Font = Enum.Font.Gotham
    UsrName.TextSize = 10
    UsrName.TextTransparency = 0.5
    UsrName.TextXAlignment = Enum.TextXAlignment.Left
    UsrName.Parent = ProfileFrame
    AddToRegistry(UsrName, "TextColor3", "Text")

    local AnonBtn = Instance.new("TextButton")
    AnonBtn.Size = UDim2.new(0, 18, 0, 18)
    AnonBtn.Position = UDim2.new(1, -6, 0.5, 0)
    AnonBtn.AnchorPoint = Vector2.new(1, 0.5)
    AnonBtn.BackgroundTransparency = 0.7
    AnonBtn.Text = ""
    AnonBtn.Parent = ProfileFrame
    Instance.new("UICorner", AnonBtn).CornerRadius = UDim.new(1, 0)
    AddToRegistry(AnonBtn, "BackgroundColor3", "Top")

    local EyeIcon = Instance.new("ImageLabel")
    EyeIcon.Size = UDim2.new(1, 0, 1, 0)
    EyeIcon.BackgroundTransparency = 1
    EyeIcon.Image = "rbxassetid://10723346959"
    EyeIcon.ImageColor3 = CurrentTheme.Text
    EyeIcon.ImageTransparency = 0.3
    EyeIcon.Parent = AnonBtn
    AddToRegistry(EyeIcon, "ImageColor3", "Text")

    local anonActive = false
    local function setAnon(active)
        anonActive = active
        if active then
            DispName.Text = "脚本杀手"
            UsrName.Text = "@•••••••"
            EyeIcon.Image = "rbxassetid://10723346871"
        else
            DispName.Text = realDisplayName
            UsrName.Text = realUsername
            EyeIcon.Image = "rbxassetid://10723346959"
        end
    end

    AnonBtn.MouseButton1Click:Connect(function()
        setAnon(not anonActive)
    end)

    table.insert(ThemeListeners, function()
        AnonBtn.BackgroundColor3 = CurrentTheme.Top
        EyeIcon.ImageColor3 = CurrentTheme.Text
    end)

    local RightContainer = Instance.new("Frame")
    RightContainer.Size = UDim2.new(1, -leftWidth, 1, -topbarHeight)
    RightContainer.Position = UDim2.new(0, leftWidth, 0, topbarHeight)
    RightContainer.BackgroundColor3 = CurrentTheme.Main
    RightContainer.BackgroundTransparency = 0.75
    RightContainer.ClipsDescendants = true
    RightContainer.Parent = MainFrame

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 16)
    rightCorner.Parent = RightContainer

    table.insert(ThemeListeners, function()
        RightContainer.BackgroundColor3 = CurrentTheme.Main
    end)

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, 0, 1, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = RightContainer

    MainFrame.ClipsDescendants = false

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
    function Window:Destroy() 
        for _, fn in ipairs(WindowCleanup) do pcall(fn) end
        ScreenGui:Destroy() 
    end
    function Window:SetSubtitle(newSubtitle)
        for _, child in ipairs(Topbar:GetChildren()) do
            if child:IsA("TextLabel") and child ~= TitleLabel then
                child.Text = newSubtitle
                break
            end
        end
    end

    RightContainer.ClipsDescendants = true

    Window._activeTab = nil
    Window._tabs = {}

    function Window:Tab(name, icon)
        local parentContainer = TabScroll
        local parentList = TabList

        if Window._currentCategory then
            parentContainer = Window._currentCategory.content
            parentList = Window._currentCategory.contentList
        end

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 140, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.BackgroundColor3 = CurrentTheme.Top
        TabBtn.Text = ""
        TabBtn.Parent = parentContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)
        AddToRegistry(TabBtn, "BackgroundColor3", "Top")

        local glowFrame = Instance.new("Frame")
        glowFrame.Name = "GlowBackground"
        glowFrame.Size = UDim2.new(1, 0, 1, 0)
        glowFrame.BackgroundColor3 = CurrentTheme.Accent
        glowFrame.BackgroundTransparency = 1
        glowFrame.Parent = TabBtn
        local glowCorner = Instance.new("UICorner")
        glowCorner.CornerRadius = UDim.new(0, 10)
        glowCorner.Parent = glowFrame
        local glowGrad = Instance.new("UIGradient")
        glowGrad.Rotation = 0
        glowGrad.Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent)
        glowGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(1, 1)
        })
        glowGrad.Parent = glowFrame

        local TabBar = Instance.new("Frame")
        TabBar.Size = UDim2.new(0, 3, 0, 0)
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
        TabText.TextColor3 = CurrentTheme.Text
        TabText.TextTransparency = 0.3
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = ContentFrame
        AddToRegistry(TabText, "TextColor3", "Text")

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.ScrollingEnabled = true
        Page.Visible = false
        Page.Position = UDim2.new(0, 0, 0, 60)
        Page.Parent = PageContainer

        local pageCorner = Instance.new("UICorner")
        pageCorner.CornerRadius = UDim.new(0, 16)
        pageCorner.Parent = Page
        Page.ClipsDescendants = true

        local PageContent = Instance.new("Frame")
        PageContent.Size = UDim2.new(1, 0, 0, 0)
        PageContent.AutomaticSize = Enum.AutomaticSize.Y
        PageContent.BackgroundTransparency = 1
        PageContent.Parent = Page

        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 10)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = PageContent

        local function updatePageCanvas()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePageCanvas)
        task.spawn(updatePageCanvas)

        local state = {
            isActive = false,
            btn = TabBtn,
            page = Page,
            textLabel = TabText,
            bar = TabBar,
            glow = glowFrame
        }

        TabBtn.MouseButton1Click:Connect(function()
            if Window._activeTab and Window._activeTab == state then
                return
            end

            for _, s in ipairs(Window._tabs) do
                s.btn.BackgroundTransparency = 1
                s.isActive = false
                s.glow.BackgroundTransparency = 1
                local bar = s.bar
                if bar then
                    Tween(bar, {BackgroundTransparency = 1, Size = UDim2.new(0,3,0,0)}, 0.2)
                end
                local txt = s.textLabel
                if txt then
                    Tween(txt, {TextTransparency = 0.3}, 0.2)
                end
            end

            TabBtn.BackgroundTransparency = 1
            state.isActive = true
            state.glow.BackgroundTransparency = 0

            if TabBar then
                Tween(TabBar, {BackgroundTransparency = 0, Size = UDim2.new(0,3,0.65,0)}, 0.2)
            end
            Tween(TabText, {TextTransparency = 0}, 0.2)

            if Window._activeTab then
                Window._activeTab.page.Visible = false
            end
            Page.Visible = true
            Tween(Page, { Position = UDim2.new(0, 0, 0, 0) }, 0.5)

            Window._activeTab = state
        end)

        if not Window._activeTab then
            TabBtn.BackgroundTransparency = 1
            state.isActive = true
            state.glow.BackgroundTransparency = 0
            TabBar.BackgroundTransparency = 0
            TabBar.Size = UDim2.new(0,3,0.65,0)
            TabText.TextTransparency = 0
            Page.Visible = true
            Page.Position = UDim2.new(0, 0, 0, 0)
            Window._activeTab = state
        end

        table.insert(Window._tabs, state)

        if name == "Config" then TabBtn.LayoutOrder = 99998 end
        if name == "Settings" then TabBtn.LayoutOrder = 99999 end

        table.insert(ThemeListeners, function()
            for _, s in ipairs(Window._tabs) do
                local glow = s.glow
                if glow then
                    glow.BackgroundColor3 = CurrentTheme.Accent
                    local grad = glow:FindFirstChildOfClass("UIGradient")
                    if grad then
                        grad.Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent)
                    end
                end
                if s.isActive then
                    s.btn.BackgroundTransparency = 1
                else
                    s.btn.BackgroundTransparency = 1
                end
            end
        end)

        local getElements = function()
            local elements = {}
            local createSection = createSectionBuilder(PageContent, PageContent, 330, 1, Window)
            elements.Section = function(_, config) return createSection(config) end
            elements.Button   = function(_, config) return createSection("", nil, true).Button(config) end
            elements.Toggle   = function(_, config) return createSection("", nil, true).Toggle(config) end
            elements.Slider   = function(_, config) return createSection("", nil, true).Slider(config) end
            elements.Dropdown = function(_, config) return createSection("", nil, true).Dropdown(config) end
            elements.Keybind  = function(_, config) return createSection("", nil, true).Keybind(config) end
            elements.Textbox  = function(_, config) return createSection("", nil, true).Textbox(config) end
            elements.Input    = function(_, config) return createSection("", nil, true).Input(config) end
            elements.Label    = function(_, config) return createSection("", nil, true).Label(config) end
            elements.ColorPicker= function(_, config) return createSection("", nil, true).ColorPicker(config) end
            elements.Image    = function(_, config) return createSection("", nil, true).Image(config) end
            elements.Divider  = function(_, config) return createSection("", nil, true).Divider(config) end
            elements.Checkbox = function(_, config) return createSection("", nil, true).Checkbox(config) end
            elements.ProgressBar = function(_, config) return createSection("", nil, true).ProgressBar(config) end
            elements.Video    = function(_, config) return createSection("", nil, true).Video(config) end
            elements.Audio    = function(_, config) return createSection("", nil, true).Audio(config) end
            elements.Viewport = function(_, config) return createSection("", nil, true).Viewport(config) end
            elements.Social   = function(_, config) return createSection("", nil, true).Social(config) end
            return elements
        end

        return getElements()
    end

    return Window
end

do
    local cursorScreen = Instance.new("ScreenGui")
    cursorScreen.Name = "FengCustomCursor"
    cursorScreen.IgnoreGuiInset = true
    cursorScreen.DisplayOrder = 2147483647
    cursorScreen.ZIndexBehavior = Enum.ZIndexBehavior.Global
    cursorScreen.ResetOnSpawn = false
    cursorScreen.Enabled = false
    cursorScreen.Parent = CoreGui

    local cursorRoot = Instance.new("Frame")
    cursorRoot.Name = "CursorRoot"
    cursorRoot.BackgroundTransparency = 1
    cursorRoot.BorderSizePixel = 0
    cursorRoot.Size = UDim2.new(0, 20, 0, 20)
    cursorRoot.ZIndex = 2147483647
    cursorRoot.Visible = false
    cursorRoot.Parent = cursorScreen

    local img = Instance.new("ImageLabel")
    img.Name = "CursorImage"
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BorderSizePixel = 0
    img.Image = "rbxassetid://132511743665753"
    img.ImageColor3 = Color3.fromRGB(90, 165, 255)
    img.ScaleType = Enum.ScaleType.Fit
    img.Rotation = -90
    img.AnchorPoint = Vector2.new(0, 0)
    img.Position = UDim2.new(0, 0, 0, 0)
    img.Parent = cursorRoot

    local cursorConn
    local function updateCursor()
        if not cursorRoot.Visible then return end
        local loc = UserInputService:GetMouseLocation()
        local ox, oy = 2, 2
        cursorRoot.Position = UDim2.new(0, loc.X - ox, 0, loc.Y - oy)
    end
    cursorConn = RunService.RenderStepped:Connect(updateCursor)

    Fenglib._cursorObjects = {
        Screen = cursorScreen,
        Root = cursorRoot,
        Image = img,
        Connection = cursorConn,
        Enabled = false
    }

    function Fenglib:SetCustomCursor(enabled)
        enabled = enabled == true
        if Fenglib._cursorObjects then
            Fenglib._cursorObjects.Root.Visible = enabled
            Fenglib._cursorObjects.Screen.Enabled = enabled
            Fenglib._cursorObjects.Enabled = enabled
            pcall(function()
                UserInputService.MouseIconEnabled = not enabled
            end)
        end
    end

    function Fenglib:ToggleCustomCursor()
        local current = Fenglib._cursorObjects and Fenglib._cursorObjects.Enabled or false
        Fenglib:SetCustomCursor(not current)
    end

    function Fenglib:CleanupCursor()
        if Fenglib._cursorObjects then
            if Fenglib._cursorObjects.Connection then
                Fenglib._cursorObjects.Connection:Disconnect()
            end
            if Fenglib._cursorObjects.Screen then
                Fenglib._cursorObjects.Screen:Destroy()
            end
            Fenglib._cursorObjects = nil
        end
    end
end

return Fenglib