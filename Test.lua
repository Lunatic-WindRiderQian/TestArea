--[[
    FengYu-Bento (miUI 框架 – 完整版)
    所有控件的视觉框架已替换为 miUI 风格（单行 + 底部线条 + 扁平开关）
    控件尺寸与原文件完全一致
]]
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

local DepthOfFieldEffect = Instance.new("DepthOfFieldEffect")
DepthOfFieldEffect.Name = "FengBlurDOF"
DepthOfFieldEffect.Enabled = false

local function safeDisconnect(conn) if conn then pcall(conn.Disconnect, conn) end end

-- ========== 动画 ==========
local Animation = {}
do
    local _RunService = RunService
    local _state = setmetatable({}, {__mode = "k"})
    function Animation.Apply(theme, root, shineEnabled)
        if not root then return end
        local st = _state[root]
        if st and st.conn then safeDisconnect(st.conn) end
        st = {conn = nil}
        _state[root] = st
        if not theme or not shineEnabled or not theme.ShineEnabled or not theme.Shine then return end
        local cfg = theme.Shine
        local speed = cfg.Speed or 0.5
        local rotSpeed = cfg.RotationSpeed or 25
        local colorSeq = cfg.ColorSequence
        local doStroke = theme.StrokeShine and theme.StrokeDark and theme.Accent
        st.conn = _RunService.RenderStepped:Connect(function(dt)
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("UIGradient") then
                    local t = (obj:GetAttribute("_t") or 0) + dt * speed
                    obj:SetAttribute("_t", t)
                    obj.Rotation = (t * rotSpeed) % 360
                    obj.Offset = Vector2.new(math.sin(t * 0.6) * 0.18, obj.Offset.Y)
                    if colorSeq then obj.Color = colorSeq end
                elseif doStroke and obj:IsA("UIStroke") then
                    local t = (obj:GetAttribute("_t") or 0) + dt * speed
                    obj:SetAttribute("_t", t)
                    local pulse = (math.sin(t) + 1) / 2
                    obj.Thickness = 1.25 + pulse * 1.25
                    obj.Color = theme.StrokeDark:Lerp(theme.Accent, pulse)
                end
            end
        end)
        return st.conn
    end
end

-- ========== 主题 ==========
local Themes = {
    Dark = { Main=Color3.fromRGB(13,13,13), Top=Color3.fromRGB(28,28,30), Text=Color3.fromRGB(240,240,245), Accent=Color3.fromRGB(80,140,255), Stroke=Color3.fromRGB(45,45,48), SubText=Color3.fromRGB(160,160,170), Element=Color3.fromRGB(45,45,50), Hover=Color3.fromRGB(60,60,70), ShineEnabled=true, Shine={Speed=0.4,RotationSpeed=20,ColorSequence=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,40,40)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(105,105,105)),ColorSequenceKeypoint.new(1,Color3.fromRGB(40,40,40))})}, StrokeShine=true, StrokeDark=Color3.fromRGB(40,40,40) },
    ["Charcoal"] = { Main=Color3.fromRGB(20,20,20), Top=Color3.fromRGB(35,35,35), Text=Color3.fromRGB(240,240,240), Accent=Color3.fromRGB(102,102,102), Stroke=Color3.fromRGB(45,45,45), SubText=Color3.fromRGB(170,170,170), Element=Color3.fromRGB(35,35,35), Hover=Color3.fromRGB(90,160,255), ShineEnabled=true, Shine={Speed=0.45,RotationSpeed=25,ColorSequence=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,20,20)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(150,150,150)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,20,20))})}, StrokeShine=true, StrokeDark=Color3.fromRGB(60,60,60) },
    ["AMOLED"] = { Main=Color3.fromRGB(0,0,0), Top=Color3.fromRGB(10,10,10), Text=Color3.fromRGB(255,255,255), Accent=Color3.fromRGB(255,255,255), Stroke=Color3.fromRGB(30,30,30), SubText=Color3.fromRGB(150,150,150), Element=Color3.fromRGB(10,10,10), Hover=Color3.fromRGB(22,22,22), ShineEnabled=false, StrokeShine=false, Shine={Speed=0,RotationSpeed=0,ColorSequence=ColorSequence.new(Color3.fromRGB(0,0,0),Color3.fromRGB(0,0,0))}, StrokeDark=Color3.fromRGB(18,18,18) },
}
local CurrentTheme = Themes.Dark

-- ========== 工具 ==========
local Registry = {}
local ConfigObjects = {}
local ThemeListeners = {}
local function clamp(v, min, max) return math.max(min, math.min(max, v)) end
local function createPulseGlow(obj)
    local running = true
    local conn = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent or not running then safeDisconnect(conn); return end
        local a = 0.5 + math.sin(tick()*3)*0.3
        if obj:IsA("UIStroke") then obj.Transparency = a
        elseif obj:IsA("Frame") or obj:IsA("TextButton") then obj.BackgroundTransparency = a end
    end)
    return { Disconnect = function() running = false; safeDisconnect(conn) end }
end
local function AddToRegistry(obj, prop, key)
    local val = CurrentTheme[key] or Themes.Dark[key] or Color3.new(1,1,1)
    table.insert(Registry, {Object = obj, Property = prop, Type = key})
    obj[prop] = val
end
local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

-- ========== Fenglib API ==========
local Fenglib = {}
function Fenglib:SetTheme(name)
    if Themes[name] then
        CurrentTheme = Themes[name]
        for _, r in pairs(Registry) do if r.Object then Tween(r.Object, {[r.Property] = CurrentTheme[r.Type]}) end end
        for _, fn in pairs(ThemeListeners) do pcall(fn) end
    end
end
function Fenglib:SaveConfig(name, folder)
    local ok, err = pcall(function()
        if not isfolder(folder) then makefolder(folder) end
        local data = {}
        for k, v in pairs(ConfigObjects) do if v and v.Value ~= nil then data[k] = v.Value end end
        writefile(folder.."/"..name..".json", HttpService:JSONEncode(data))
    end)
    if not ok then warn("SaveConfig error:", err) end
    return ok
end
function Fenglib:LoadConfig(path)
    if not pcall(isfile, path) then return false end
    if not isfile(path) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or type(data) ~= "table" then return false end
    Fenglib._loading = true
    for k, v in pairs(data) do if ConfigObjects[k] and ConfigObjects[k].Set then pcall(function() ConfigObjects[k].Set(v) end) end end
    Fenglib._loading = false
    return true
end

-- ========== 媒体管理器 ==========
local MediaManager = {Folder = "FengMediaCache"}
function MediaManager:SetFolder(f) self.Folder = f end
function MediaManager:_init(sub)
    pcall(function()
        if not isfolder(self.Folder) then makefolder(self.Folder) end
        local p = self.Folder.."/"..sub
        if not isfolder(p) then makefolder(p) end
    end)
end
function MediaManager:_rname(ext)
    local s = "abcdefghijklmnopqrstuvwxyz0123456789"
    local n = ""
    for _=1,12 do local i=math.random(1,#s) n=n..s:sub(i,i) end
    return n.."."..ext
end
function MediaManager:Audio(src, noDownload)
    if type(src) ~= "string" or src == "" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if not src:match("^https?://") then return "" end
    local ext = (src:match("%.(%a+)%??[^/]*$") or "mp3"):lower()
    if not ({mp3=1,ogg=1,wav=1,flac=1})[ext] then ext = "mp3" end
    self:_init("audio")
    local dir = self.Folder.."/audio"
    local mapPath = dir.."/_map.json"
    local hs = HttpService
    local map = {}
    pcall(function()
        if isfile(mapPath) then
            local ok, d = pcall(hs.JSONDecode, hs, readfile(mapPath))
            if ok and type(d) == "table" then map = d end
        end
    end)
    local key = tostring(#src).."_"..src:sub(1,40):gsub("[^%w]","")
    if map[key] then
        local cp = dir.."/"..map[key]
        if isfile(cp) then
            local ok, a = pcall(getcustomasset, cp)
            if ok and a and a ~= "" then return a end
        end
        map[key] = nil
    end
    if noDownload then return nil end
    local fname = self:_rname(ext)
    local path = dir.."/"..fname
    local body = nil
    local reqOk = pcall(function()
        local req = (syn and syn.request) or http_request or request
        local r = req({Url=src, Method="GET", Headers={["User-Agent"]="Roblox/WinInet"}})
        if r and r.Body and #r.Body > 128 then
            local peek = r.Body:sub(1,15):lower()
            if peek:find("<!doctype") or peek:find("<html") then return end
            body = r.Body
            writefile(path, body)
        end
    end)
    if reqOk and body and isfile(path) then
        local ok2, a = pcall(getcustomasset, path)
        if ok2 and a and a ~= "" then
            map[key] = fname
            pcall(function() local ok3, enc = pcall(hs.JSONEncode, hs, map); if ok3 then writefile(mapPath, enc) end end)
            return a
        end
    end
    return ""
end
function MediaManager:Video(src)
    if type(src) ~= "string" or src == "" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if not src:match("^https?://") then return "" end
    local ext = (src:match("%.(%a+)%??[^/]*$") or "webm"):lower()
    if not ({webm=1,mp4=1,ogg=1,mov=1})[ext] then ext = "webm" end
    if ext == "mp4" or ext == "mov" then ext = "webm" end
    self:_init("videos")
    local dir = self.Folder.."/videos"
    local mapPath = dir.."/_map.json"
    local hs = HttpService
    local map = {}
    pcall(function()
        if isfile(mapPath) then
            local ok, d = pcall(hs.JSONDecode, hs, readfile(mapPath))
            if ok and type(d) == "table" then map = d end
        end
    end)
    local key = tostring(#src).."_"..src:sub(1,40):gsub("[^%w]","")
    if map[key] then
        local cp = dir.."/"..map[key]
        if isfile(cp) then
            local ok, a = pcall(getcustomasset, cp)
            if ok and a and a ~= "" then return a end
        end
        map[key] = nil
    end
    local fname = self:_rname(ext)
    local path = dir.."/"..fname
    local body = nil
    local reqOk = pcall(function()
        local req = (syn and syn.request) or http_request or request
        local r = req({Url=src, Method="GET", Headers={["User-Agent"]="Roblox/WinInet"}})
        if r and r.Body and #r.Body > 512 then
            local peek = r.Body:sub(1,15):lower()
            if peek:find("<!doctype") or peek:find("<html") then return end
            body = r.Body
            writefile(path, body)
        end
    end)
    if reqOk and body and isfile(path) then
        local ok2, a = pcall(getcustomasset, path)
        if ok2 and a and a ~= "" then
            map[key] = fname
            pcall(function() local ok3, enc = pcall(hs.JSONEncode, hs, map); if ok3 then writefile(mapPath, enc) end end)
            return a
        end
    end
    return ""
end
function MediaManager:Image(src)
    if type(src) ~= "string" or src == "" then return "" end
    if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
    if src:match("^%d+$") then return "rbxassetid://"..src end
    if not src:match("^https?://") then return "" end
    local ext = (src:match("%.(%a+)%??[^/]*$") or "png"):lower()
    if not ({png=1,jpg=1,jpeg=1,webp=1,gif=1})[ext] then ext = "png" end
    self:_init("images")
    local dir = self.Folder.."/images"
    local mapPath = dir.."/_map.json"
    local hs = HttpService
    local map = {}
    pcall(function()
        if isfile(mapPath) then
            local ok, d = pcall(hs.JSONDecode, hs, readfile(mapPath))
            if ok and type(d) == "table" then map = d end
        end
    end)
    local key = tostring(#src).."_"..src:sub(1,40):gsub("[^%w]","")
    if map[key] then
        local cp = dir.."/"..map[key]
        if isfile(cp) then
            local ok, a = pcall(getcustomasset, cp)
            if ok and a and a ~= "" then return a end
        end
        map[key] = nil
    end
    local fname = self:_rname(ext)
    local path = dir.."/"..fname
    local body = nil
    local reqOk = pcall(function()
        local req = (syn and syn.request) or http_request or request
        local r = req({Url=src, Method="GET", Headers={["User-Agent"]="Roblox/WinInet"}})
        if r and r.Body and #r.Body > 128 then
            local peek = r.Body:sub(1,15):lower()
            if peek:find("<!doctype") or peek:find("<html") then return end
            body = r.Body
            writefile(path, body)
        end
    end)
    if reqOk and body and isfile(path) then
        local ok2, a = pcall(getcustomasset, path)
        if ok2 and a and a ~= "" then
            map[key] = fname
            pcall(function() local ok3, enc = pcall(hs.JSONEncode, hs, map); if ok3 then writefile(mapPath, enc) end end)
            return a
        end
    end
    return ""
end

-- ========== 锁覆盖层 ==========
local function createLockOverlay(parent, defaultTitle)
    local cornerRadius = UDim.new(0, 8)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("UICorner") then cornerRadius = child.CornerRadius; break end
    end
    local lockFrame = Instance.new("TextButton")
    lockFrame.Size = UDim2.new(1, 0, 1, 0)
    lockFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    lockFrame.BackgroundTransparency = 0.6
    lockFrame.Text = ""
    lockFrame.AutoButtonColor = false
    lockFrame.Active = true
    lockFrame.Visible = false
    lockFrame.ZIndex = 10
    lockFrame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = cornerRadius
    corner.Parent = lockFrame
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = lockFrame
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container
    local lockIcon = Instance.new("ImageLabel")
    lockIcon.Size = UDim2.new(0, 18, 0, 18)
    lockIcon.BackgroundTransparency = 1
    lockIcon.Image = "rbxassetid://12060512624"
    lockIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    lockIcon.ImageTransparency = 0.1
    lockIcon.Parent = container
    local lockLabel = Instance.new("TextLabel")
    lockLabel.Size = UDim2.new(0, 0, 0, 20)
    lockLabel.BackgroundTransparency = 1
    lockLabel.Font = Enum.Font.GothamBold
    lockLabel.Text = defaultTitle or "Locked"
    lockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockLabel.TextTransparency = 0.2
    lockLabel.TextSize = 14
    lockLabel.AutomaticSize = Enum.AutomaticSize.X
    lockLabel.Parent = container
    return lockFrame, lockLabel
end

-- ========== 完整元素构建器 (miUI 框架 + 原版尺寸) ==========
local function createSectionBuilder(parent, contentContainer, elementWidth, windowCount, window)
    local win = window
    local padding = parent:FindFirstChild("SectionPadding")
    if not padding then
        padding = Instance.new("UIPadding")
        padding.Name = "SectionPadding"
        padding.PaddingLeft = UDim.new(0.04,0)
        padding.Parent = parent
    end

    local child = {}

    local function miRow(parentFrame, height)
        height = height or 42
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, height)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.ClipsDescendants = false
        row.Parent = parentFrame

        local line = Instance.new("Frame")
        line.Name = "RowLine"
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Position = UDim2.new(0, 10, 1, -1)
        line.BackgroundColor3 = CurrentTheme.Stroke
        line.BackgroundTransparency = 0.65
        line.BorderSizePixel = 0
        line.Parent = row
        AddToRegistry(line, "BackgroundColor3", "Stroke")
        return row
    end

    local function miIcon(parentFrame, asset, size, x, y)
        size = size or 18
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, size, 0, size)
        icon.Position = UDim2.new(0, x or 11, 0, y or 0)
        icon.BackgroundTransparency = 1
        icon.BorderSizePixel = 0
        icon.ImageColor3 = CurrentTheme.Text
        icon.ImageTransparency = 0.25
        icon.ScaleType = Enum.ScaleType.Fit
        if type(asset) == "number" then
            icon.Image = "rbxassetid://"..tostring(asset)
        elseif type(asset) == "string" and asset ~= "" then
            if tonumber(asset) then
                icon.Image = "rbxassetid://"..asset
            elseif asset:match("^rbxassetid://") or asset:match("^http") or asset:match("^rbxasset://") then
                icon.Image = asset
            else
                icon.Image = "rbxassetid://"..asset
            end
        end
        icon.Parent = parentFrame
        AddToRegistry(icon, "ImageColor3", "Text")
        return icon
    end

    local function miLabel(parentFrame, text, x, y, w, size)
        local lbl = Instance.new("TextLabel")
        lbl.Text = text or ""
        lbl.Position = UDim2.new(0, x or 11, 0, y or 0)
        lbl.Size = w or UDim2.new(1, -22, 0, 15)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = size or 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = parentFrame
        AddToRegistry(lbl, "TextColor3", "Text")
        return lbl
    end

    -- Button  原尺寸：42px
    child.Button = function(_, config)
        local btnText = config.Name or config.Text or ""
        local callback = config.Callback or function() end
        local parent = config.Parent or contentHolder
        local iconAsset = config.Icon or "chevron-large-left"

        local Tile = miRow(parent, 42)
        local Icon = miIcon(Tile, iconAsset, 15, 11, 13.5)
        local TitleLbl = miLabel(Tile, btnText, 35, 13.5, UDim2.new(1, -50, 0, 15))

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.AutoButtonColor = false
        ClickBtn.Parent = Tile
        ClickBtn.Active = not locked

        local function updateLock(state)
            locked = state
            lockFrame.Visible = state
            ClickBtn.Active = not state
        end

        ClickBtn.MouseEnter:Connect(function()
            if not locked then Tween(Tile, {BackgroundTransparency = 0.92}, 0.18) end
        end)
        ClickBtn.MouseLeave:Connect(function()
            if not locked then Tween(Tile, {BackgroundTransparency = 1}, 0.18) end
        end)
        ClickBtn.MouseButton1Down:Connect(function() if not locked then Tween(Tile, {BackgroundTransparency = 0.82}, 0.1) end end)
        ClickBtn.MouseButton1Up:Connect(function() if not locked then Tween(Tile, {BackgroundTransparency = 0.92}, 0.1) end end)
        ClickBtn.MouseButton1Click:Connect(function() if not locked then callback() end end)

        local self = {}
        function self.UpdateText(t) TitleLbl.Text = t end
        function self.SetIcon(a)
            if tonumber(a) then Icon.Image = "rbxassetid://"..a else Icon.Image = tostring(a) end
        end
        function self.SetVisible(v) Tile.Visible = v end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        return self
    end

    -- Toggle  原尺寸：42px
    child.Toggle = function(_, config)
        local toggleText = config.Name or ""
        local Enabled = config.Value or false
        local callback = config.Callback or function() end
        local controlId = toggleText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder

        local Tile = miRow(parent, 42)
        local TitleLbl = miLabel(Tile, toggleText, 11, 13.5, UDim2.new(1, -60, 0, 15))

        local Switch = Instance.new("Frame")
        Switch.Size = UDim2.new(0, 30, 0, 18)
        Switch.Position = UDim2.new(1, -41, 0.5, -9)
        Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)
        Switch.BorderSizePixel = 0
        Switch.Parent = Tile
        Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

        local SwStroke = Instance.new("UIStroke")
        SwStroke.Thickness = 1
        SwStroke.Transparency = Enabled and 1 or 0.65
        SwStroke.Color = CurrentTheme.Stroke
        SwStroke.Parent = Switch
        table.insert(ThemeListeners, function()
            SwStroke.Color = CurrentTheme.Stroke
            if not Enabled then SwStroke.Transparency = 0.65 end
        end)

        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0, 16, 0, 16)
        Dot.Position = Enabled and UDim2.new(1, -17, 0.5, -8) or UDim2.new(0, 1, 0.5, -8)
        Dot.BackgroundColor3 = Color3.new(1, 1, 1)
        Dot.BorderSizePixel = 0
        Dot.Parent = Switch
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.AutoButtonColor = false
        ClickBtn.Parent = Tile
        ClickBtn.Active = not locked

        local function updateLock(state)
            locked = state
            lockFrame.Visible = state
            ClickBtn.Active = not state
        end

        local function ApplyUI(v)
            Enabled = v
            if Enabled then
                Tween(Switch, {BackgroundColor3 = CurrentTheme.Accent}, 0.18)
                Tween(SwStroke, {Transparency = 1}, 0.18)
                Tween(Dot, {Position = UDim2.new(1, -17, 0.5, -8)}, 0.18)
            else
                Tween(Switch, {BackgroundColor3 = Color3.fromRGB(10, 13, 21)}, 0.18)
                Tween(SwStroke, {Transparency = 0.65}, 0.18)
                Tween(Dot, {Position = UDim2.new(0, 1, 0.5, -8)}, 0.18)
            end
        end

        ConfigObjects[controlId] = {
            Type = "Toggle", Value = Enabled,
            Set = function(v) if not locked then ApplyUI(v); callback(v) end end
        }

        ClickBtn.MouseEnter:Connect(function() if not locked then Tween(Tile, {BackgroundTransparency = 0.92}, 0.18) end end)
        ClickBtn.MouseLeave:Connect(function() if not locked then Tween(Tile, {BackgroundTransparency = 1}, 0.18) end end)
        ClickBtn.MouseButton1Click:Connect(function()
            if locked then return end
            ApplyUI(not Enabled)
            ConfigObjects[controlId].Value = Enabled
            callback(Enabled)
        end)

        local self = {}
        function self.GetValue() return Enabled end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        function self.SetVisible(v) Tile.Visible = v end
        return self
    end

    -- Slider  原尺寸：42px (unlimited) / 60px
    child.Slider = function(_, config)
        local sliderText = config.Name or ""
        local valueTable = config.Value or {}
        local min = valueTable.Min
        local max = valueTable.Max
        local default = valueTable.Default
        local callback = config.Callback or function() end
        local unlimited = (min == nil and max == nil)
        min = tonumber(min); max = tonumber(max)
        local Rounding = config.Rounding or 0
        local Val = tonumber(default) or (min or 0)
        local controlId = sliderText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder

        local tileH = unlimited and 42 or 60
        local Tile = miRow(parent, tileH)

        local TitleLbl = miLabel(Tile, sliderText, 15, unlimited and 11 or 10, UDim2.new(1, -30, 0, 20))

        local numW = unlimited and 72 or 52
        local Num = Instance.new("TextBox")
        Num.Text = tostring(Val)
        Num.Size = UDim2.new(0, numW, 0, 22)
        Num.Position = UDim2.new(1, -(numW + 10), 0, unlimited and 10 or 9)
        Num.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        Num.BackgroundTransparency = 0
        Num.BorderSizePixel = 0
        Num.Font = Enum.Font.GothamBold
        Num.TextSize = 12
        Num.TextColor3 = CurrentTheme.Text
        Num.TextXAlignment = Enum.TextXAlignment.Center
        Num.Parent = Tile
        Num.ClearTextOnFocus = false
        Instance.new("UICorner", Num).CornerRadius = UDim.new(0, 6)
        local NumStroke = Instance.new("UIStroke")
        NumStroke.Thickness = 1
        NumStroke.Transparency = 0.65
        NumStroke.Color = CurrentTheme.Stroke
        NumStroke.Parent = Num
        table.insert(ThemeListeners, function() NumStroke.Color = CurrentTheme.Stroke end)
        Num.Focused:Connect(function() Tween(NumStroke, {Transparency = 0.2}, 0.15) end)

        local Track, Fill, Knob, Bar
        if not unlimited then
            Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -30, 0, 5)
            Track.Position = UDim2.new(0, 15, 0, 44)
            Track.BackgroundColor3 = CurrentTheme.Stroke
            Track.BorderSizePixel = 0
            Track.Parent = Tile
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Track, "BackgroundColor3", "Stroke")

            local initP = (min and max and max ~= min) and ((Val - min) / (max - min)) or 0

            Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(initP, 0, 1, 0)
            Fill.BackgroundColor3 = CurrentTheme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            AddToRegistry(Fill, "BackgroundColor3", "Accent")

            Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new(initP, 0, 0.5, 0)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
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

        local dragging = false
        local function Round(n, decimals)
            local factor = 10^decimals
            return math.floor(n * factor + 0.5) / factor
        end

        local function UpdateSlider(val)
            if unlimited then
                Val = tonumber(val) or Val
                Num.Text = tostring(Val)
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = Val end
                callback(Val)
                return
            end
            val = math.clamp(val, min, max)
            val = Round(val, Rounding)
            local ratio = (val - min) / (max - min)
            TweenService:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Position = UDim2.new(ratio, 0, 0.5, 0)}):Play()
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

        if Bar then
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(GetValueFromInput(input))
                end
            end)
            Bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(GetValueFromInput(input))
                end
            end)
        end

        Num.FocusLost:Connect(function()
            Tween(NumStroke, {Transparency = 0.65}, 0.15)
            local typed = tonumber(Num.Text)
            if typed then UpdateSlider(typed) else Num.Text = tostring(Val) end
        end)

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked
        if Bar then Bar.Active = not locked end
        Num.Active = not locked

        local function updateLock(state)
            locked = state
            lockFrame.Visible = state
            if Bar then Bar.Active = not state end
            Num.Active = not state
        end

        ConfigObjects[controlId] = { Type = "Slider", Value = Val, Set = function(v) if not locked then UpdateSlider(tonumber(v) or Val) end end }
        table.insert(ThemeListeners, function()
            if Fill then Fill.BackgroundColor3 = CurrentTheme.Accent end
            if Track then Track.BackgroundColor3 = CurrentTheme.Stroke end
            Num.TextColor3 = CurrentTheme.Text
        end)
        UpdateSlider(Val)

        local self = {}
        function self.GetValue() return Val end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        function self.SetVisible(v) Tile.Visible = v end
        return self
    end

    -- Dropdown  原尺寸：42px
    child.Dropdown = function(_, config)
        local dropText = config.Name or ""
        local options = config.Values or {}
        local selectedValue = config.Value
        local multi = config.Multi == true
        local callback = config.Callback or function() end
        local controlId = dropText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local selected = multi and {} or nil

        local function initSelected()
            if multi then
                if type(selectedValue) == "table" then
                    selected = {}
                    for _, v in ipairs(selectedValue) do if table.find(options, v) then table.insert(selected, v) end end
                else selected = {} end
            else
                if selectedValue and table.find(options, selectedValue) then selected = selectedValue else selected = options[1] or "" end
            end
        end
        initSelected()

        local Dropped = false
        local Btn = miRow(parent, 42)
        local Lbl = miLabel(Btn, "", 15, 13.5, UDim2.new(1, -50, 0, 15))

        local Icon = Instance.new("ImageLabel")
        Icon.Image = "rbxassetid://18865373378"
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(1, -30, 0.5, -10)
        Icon.BackgroundTransparency = 1
        Icon.Parent = Btn
        AddToRegistry(Icon, "ImageColor3", "Accent")

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.AutoButtonColor = false
        ClickBtn.Parent = Btn

        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.Visible = false
        Container.ClipsDescendants = true
        Container.ZIndex = 10
        Container.BackgroundColor3 = CurrentTheme.Main
        Container.BackgroundTransparency = 0.05
        Container.Parent = parent
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

        local List = Instance.new("UIListLayout")
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Container

        local function updateLabel()
            if multi then
                if #selected == 0 then Lbl.Text = dropText..": (none)"
                else Lbl.Text = dropText..": "..table.concat(selected, ", ") end
            else
                Lbl.Text = dropText..": "..tostring(selected)
            end
        end
        updateLabel()

        local optionButtons = {}
        local function rebuildOptions(optList)
            for _, c in ipairs(Container:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            optionButtons = {}
            for _, opt in ipairs(optList) do
                local O = Instance.new("TextButton")
                O.Size = UDim2.new(1, 0, 0, 34)
                O.Text = ""
                O.BackgroundTransparency = 1
                O.AutoButtonColor = false
                O.Parent = Container

                local check = Instance.new("Frame")
                check.Size = UDim2.new(0, 16, 0, 16)
                check.Position = UDim2.new(0, 10, 0.5, -8)
                check.BackgroundColor3 = CurrentTheme.Accent
                check.BackgroundTransparency = 1
                check.ZIndex = 1
                check.Parent = O
                Instance.new("UICorner", check).CornerRadius = UDim.new(0, 4)

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

                O.MouseEnter:Connect(function() Tween(O, {BackgroundTransparency = 0.1}, 0.15) end)
                O.MouseLeave:Connect(function() Tween(O, {BackgroundTransparency = 1}, 0.15) end)

                local optData = { button = O, label = label, check = check, checkMark = checkMark, value = opt, selected = false }
                table.insert(optionButtons, optData)

                O.MouseButton1Click:Connect(function()
                    if locked then return end
                    if multi then
                        local idx = table.find(selected, opt)
                        if idx then table.remove(selected, idx); optData.selected = false
                        else table.insert(selected, opt); optData.selected = true end
                        optData.check.BackgroundTransparency = optData.selected and 0 or 1
                        optData.checkMark.ImageTransparency = optData.selected and 0 or 1
                        updateLabel()
                        if ConfigObjects[controlId] then ConfigObjects[controlId].Value = selected end
                        callback(selected)
                    else
                        selected = opt
                        for _, d in ipairs(optionButtons) do
                            d.selected = (d.value == opt)
                            d.check.BackgroundTransparency = d.selected and 0 or 1
                            d.checkMark.ImageTransparency = d.selected and 0 or 1
                        end
                        updateLabel()
                        if ConfigObjects[controlId] then ConfigObjects[controlId].Value = selected end
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
                if multi then d.selected = table.find(selected, d.value) ~= nil else d.selected = (d.value == selected) end
                d.check.BackgroundTransparency = d.selected and 0 or 1
                d.checkMark.ImageTransparency = d.selected and 0 or 1
            end
            if Dropped then
                local targetHeight = #optionButtons * 34
                Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
            end
        end
        rebuildOptions(options)

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Btn, lockedTitle)
        lockFrame.Visible = locked
        ClickBtn.Active = not locked

        local function updateLock(state)
            locked = state
            lockFrame.Visible = state
            ClickBtn.Active = not state
            if state then Dropped = false; Container.Visible = false; Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.1) end
        end

        ClickBtn.MouseEnter:Connect(function() if not locked then Tween(Btn, {BackgroundTransparency = 0.92}, 0.18) end end)
        ClickBtn.MouseLeave:Connect(function() if not locked then Tween(Btn, {BackgroundTransparency = 1}, 0.18) end end)
        ClickBtn.MouseButton1Click:Connect(function()
            if locked then return end
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
            local mp = UserInputService:GetMouseLocation()
            local ap, as = frame.AbsolutePosition, frame.AbsoluteSize
            return mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
        end

        local globalClickConn
        globalClickConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Dropped and not locked then
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
            Type = "Dropdown", Value = multi and selected or selected,
            Set = function(val)
                if locked then return end
                if multi then
                    if type(val) == "table" then
                        selected = {}
                        for _, v in ipairs(val) do if table.find(options, v) then table.insert(selected, v) end end
                    else selected = {} end
                else
                    if val and table.find(options, val) then selected = val else selected = options[1] or "" end
                end
                for _, d in ipairs(optionButtons) do
                    if multi then d.selected = table.find(selected, d.value) ~= nil else d.selected = (d.value == selected) end
                    d.check.BackgroundTransparency = d.selected and 0 or 1
                    d.checkMark.ImageTransparency = d.selected and 0 or 1
                end
                updateLabel()
                callback(selected)
            end,
            Refresh = function(newOptions)
                if locked then return end
                options = newOptions or {}
                selected = multi and {} or (options[1] or "")
                rebuildOptions(options)
                updateLabel()
            end
        }

        local self = {}
        function self.GetValue() return selected end
        function self.SetValue(val) if not locked then ConfigObjects[controlId].Set(val) end end
        function self.Refresh(newOptions) if not locked and ConfigObjects[controlId].Refresh then ConfigObjects[controlId].Refresh(newOptions) end end
        function self.SetVisible(state) Btn.Visible = state end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end

        table.insert(WindowCleanup or {}, function() safeDisconnect(globalClickConn) end)
        return self
    end

    -- Keybind  原尺寸：42px
    child.Keybind = function(_, config)
        local keyText = config.Name or ""
        local defaultKey = config.Default or Enum.KeyCode.M
        local mode = config.Mode or "Toggle"
        local callback = config.Callback or function() end
        local controlId = keyText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local state = { Key = defaultKey.Name, Mode = mode, Toggled = false, IsWaiting = false }

        local Tile = miRow(parent, 42)
        local TitleLbl = miLabel(Tile, keyText, 15, 13.5, UDim2.new(0.6, 0, 0, 15))

        local KeyBtn = Instance.new("TextButton")
        KeyBtn.Size = UDim2.new(0, 0, 0, 30)
        KeyBtn.Position = UDim2.new(1, -10, 0.5, 0)
        KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
        KeyBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        KeyBtn.BackgroundTransparency = 0
        KeyBtn.Text = ""
        KeyBtn.AutoButtonColor = false
        KeyBtn.Parent = Tile
        KeyBtn.AutomaticSize = Enum.AutomaticSize.X
        Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 5)
        local keyStroke = Instance.new("UIStroke")
        keyStroke.Thickness = 1
        keyStroke.Transparency = 0.65
        keyStroke.Color = CurrentTheme.Stroke
        keyStroke.Parent = KeyBtn
        table.insert(ThemeListeners, function() keyStroke.Color = CurrentTheme.Stroke end)

        local innerLayout = Instance.new("UIListLayout")
        innerLayout.FillDirection = Enum.FillDirection.Horizontal
        innerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        innerLayout.Padding = UDim.new(0, 4)
        innerLayout.Parent = KeyBtn
        local keyPadding = Instance.new("UIPadding")
        keyPadding.PaddingLeft = UDim.new(0, 7)
        keyPadding.PaddingRight = UDim.new(0, 8)
        keyPadding.Parent = KeyBtn

        local KeyLabel = Instance.new("TextLabel")
        KeyLabel.Text = state.Key
        KeyLabel.Size = UDim2.new(0, 0, 1, 0)
        KeyLabel.BackgroundTransparency = 1
        KeyLabel.Font = Enum.Font.GothamMedium
        KeyLabel.TextSize = 13
        KeyLabel.TextColor3 = CurrentTheme.Text
        KeyLabel.AutomaticSize = Enum.AutomaticSize.X
        KeyLabel.LayoutOrder = 1
        KeyLabel.Parent = KeyBtn
        AddToRegistry(KeyLabel, "TextColor3", "Text")

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked
        KeyBtn.Active = not locked

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
            KeyBtn.Active = not st
        end

        ConfigObjects[controlId] = {
            Type = "Keybind", Value = { Key = state.Key, Mode = state.Mode },
            Set = function(val)
                if locked then return end
                if type(val) == "table" then
                    state.Key = val.Key or state.Key
                    state.Mode = val.Mode or state.Mode
                    KeyLabel.Text = state.Key
                    ConfigObjects[controlId].Value = { Key = state.Key, Mode = state.Mode }
                elseif type(val) == "string" then
                    state.Key = val
                    KeyLabel.Text = val
                    ConfigObjects[controlId].Value = { Key = val, Mode = state.Mode }
                end
            end
        }

        local function updateKeyDisplay(newKey)
            if locked then return end
            state.Key = newKey
            KeyLabel.Text = newKey
            ConfigObjects[controlId].Value = { Key = newKey, Mode = state.Mode }
        end

        KeyBtn.MouseButton1Click:Connect(function()
            if locked or state.IsWaiting then return end
            state.IsWaiting = true
            KeyLabel.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            state.IsWaiting = false
            local newKey = nil
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode.Name ~= "Unknown" then newKey = input.KeyCode.Name end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then newKey = "MouseLeft"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then newKey = "MouseRight" end
            if newKey then updateKeyDisplay(newKey) else KeyLabel.Text = state.Key end
        end)

        local inputConn, inputEndConn
        inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe or locked or state.IsWaiting then return end
            if UserInputService:GetFocusedTextBox() then return end
            local key = state.Key
            if state.Mode == "Toggle" then
                if key == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then state.Toggled = not state.Toggled; pcall(callback, state.Toggled)
                elseif key == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then state.Toggled = not state.Toggled; pcall(callback, state.Toggled)
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then state.Toggled = not state.Toggled; pcall(callback, state.Toggled) end
            elseif state.Mode == "Hold" then
                if key == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then pcall(callback, true)
                elseif key == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(callback, true)
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then pcall(callback, true) end
            end
        end)
        inputEndConn = UserInputService.InputEnded:Connect(function(input, gpe)
            if gpe or locked or state.IsWaiting then return end
            if state.Mode == "Hold" then
                local key = state.Key
                if key == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then pcall(callback, false)
                elseif key == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(callback, false)
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then pcall(callback, false) end
            end
        end)

        local self = {}
        function self.SetValue(val, newMode) if not locked then ConfigObjects[controlId].Set(val, newMode) end end
        function self.GetValue() return { Key = state.Key, Mode = state.Mode } end
        function self.GetState() return state.Toggled end
        function self.SetMode(newMode) if not locked then state.Mode = newMode; ConfigObjects[controlId].Value = { Key = state.Key, Mode = state.Mode } end end
        function self.Destroy() safeDisconnect(inputConn); safeDisconnect(inputEndConn); Tile:Destroy(); ConfigObjects[controlId] = nil end
        function self.SetVisible(vis) Tile.Visible = vis end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        return self
    end

    -- Input  原尺寸：42px
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
        local controlId = inputText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder

        local Tile = miRow(parent, 42)
        local NameLbl = miLabel(Tile, inputText, 15, 13.5, UDim2.new(0.6, 0, 0, 15))

        local BoxContainer = Instance.new("Frame")
        BoxContainer.Size = UDim2.new(0.3, 0, 0, 28)
        BoxContainer.Position = UDim2.new(0.7, -10, 0.5, -14)
        BoxContainer.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        BoxContainer.BackgroundTransparency = 0
        BoxContainer.ClipsDescendants = true
        BoxContainer.BorderSizePixel = 0
        BoxContainer.Parent = Tile
        Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 6)

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 1
        boxStroke.Transparency = 0.65
        boxStroke.Color = CurrentTheme.Stroke
        boxStroke.Parent = BoxContainer
        table.insert(ThemeListeners, function() boxStroke.Color = CurrentTheme.Stroke end)

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
        AddToRegistry(InputBox, "TextColor3", "Text")

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked
        InputBox.Active = not locked

        local function filterText(text)
            if maxLength then text = text:sub(1, maxLength) end
            if numeric then
                local filtered = text:gsub("[^%d%-]", "")
                if filtered:match("^-") then filtered = "-"..filtered:gsub("-", "") else filtered = filtered:gsub("-", "") end
                return filtered
            end
            if type(acceptedChars) == "function" then return acceptedChars(text)
            elseif acceptedChars == "Alphabetic" then return text:gsub("[^a-zA-Z]", "")
            elseif acceptedChars == "AlphaNumeric" then return text:gsub("[^a-zA-Z0-9]", "") end
            return text
        end

        local function updateValue()
            if locked then return end
            local filtered = filterText(InputBox.Text)
            if filtered ~= InputBox.Text then InputBox.Text = filtered end
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = filtered end
            if callback then pcall(callback, filtered) end
            if onChanged then pcall(onChanged, filtered) end
        end

        InputBox.Focused:Connect(function() if not locked then Tween(boxStroke, {Transparency = 0.2}, 0.15) end end)
        InputBox.FocusLost:Connect(function()
            Tween(boxStroke, {Transparency = 0.65}, 0.15)
            if finished then updateValue() end
        end)

        if not finished then
            InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                if locked then return end
                local raw = InputBox.Text
                local filtered = filterText(raw)
                if filtered ~= raw then InputBox.Text = filtered end
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = InputBox.Text end
                if callback then pcall(callback, InputBox.Text) end
                if onChanged then pcall(onChanged, InputBox.Text) end
            end)
        end

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
            InputBox.Active = not st
        end

        ConfigObjects[controlId] = {
            Type = "Input", Value = InputBox.Text,
            Set = function(val)
                if locked then return end
                local str = tostring(val)
                local filtered = filterText(str)
                InputBox.Text = filtered
                ConfigObjects[controlId].Value = filtered
                if callback then pcall(callback, filtered) end
            end
        }

        local self = {}
        function self.UpdateText(newText) if not locked then local f = filterText(tostring(newText)); InputBox.Text = f; ConfigObjects[controlId].Value = f end end
        function self.GetText() return InputBox.Text end
        function self.SetVisible(state) Tile.Visible = state end
        function self.UpdatePlaceholder(p) InputBox.PlaceholderText = p end
        function self.SetValue(val) self.UpdateText(val) end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        return self
    end

    -- Textbox  原尺寸：70px
    child.Textbox = function(_, config)
        local boxText = config.Name or ""
        local placeholder = config.Placeholder or ""
        local callback = config.Callback or function() end
        local controlId = boxText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder

        local Frame = miRow(parent, 70)
        local Lbl = miLabel(Frame, boxText, 15, 10, UDim2.new(1, -30, 0, 20))

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -30, 0, 28)
        Box.Position = UDim2.new(0, 15, 0, 35)
        Box.Text = ""
        Box.PlaceholderText = placeholder
        Box.Font = Enum.Font.GothamMedium
        Box.TextSize = 12
        Box.Parent = Frame
        Box.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        Box.BackgroundTransparency = 0
        Box.BorderSizePixel = 0
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
        AddToRegistry(Box, "TextColor3", "Text")

        local BoxStroke = Instance.new("UIStroke")
        BoxStroke.Thickness = 1
        BoxStroke.Transparency = 0.65
        BoxStroke.Color = CurrentTheme.Stroke
        BoxStroke.Parent = Box
        table.insert(ThemeListeners, function() BoxStroke.Color = CurrentTheme.Stroke end)

        Box.Focused:Connect(function() Tween(BoxStroke, {Transparency = 0.2}, 0.15) end)
        Box.FocusLost:Connect(function()
            if locked then return end
            Tween(BoxStroke, {Transparency = 0.65}, 0.15)
            ConfigObjects[controlId].Value = Box.Text
            callback(Box.Text)
        end)

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Frame, lockedTitle)
        lockFrame.Visible = locked
        Box.Active = not locked

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
            Box.Active = not st
        end

        ConfigObjects[controlId] = { Type = "Textbox", Value = "", Set = function(val) if not locked then Box.Text = val; callback(val) end end }

        local self = {}
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.GetValue() return Box.Text end
        function self.SetVisible(state) Frame.Visible = state end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        return self
    end

    -- Label  原尺寸：42px
    child.Label = function(_, config)
        local labelText = config.Name or ""
        local parent = config.Parent or contentHolder

        local Tile = miRow(parent, 42)
        local TextLabel = miLabel(Tile, labelText, 10, 13.5, UDim2.new(1, -20, 0, 15))

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
        end

        local self = {}
        function self.UpdateText(newText) TextLabel.Text = newText end
        function self.SetVisible(state) Tile.Visible = state end
        function self.Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        return self
    end

    -- Image (AutomaticSize，与原一致)
    child.Image = function(_, config)
        config = config or {}
        local title = config.Name or "Image"
        local subtitle = config.SubName or ""
        local description = config.Description or {}
        if type(description) == "string" then description = { description } end
        local iconAsset = config.Icon or config.ImageLink or ""
        local iconColor = config.IconColor or CurrentTheme.Text
        local callback = config.Callback or function() end
        local parent = config.Parent or contentHolder

        local function formatIcon(asset)
            if type(asset) == "number" then return "rbxassetid://"..tostring(asset)
            elseif type(asset) == "string" then
                if tonumber(asset) then return "rbxassetid://"..asset
                elseif asset:match("^rbxassetid://") then return asset
                elseif asset:match("^http") then return asset
                else return "rbxassetid://"..asset end
            end
            return "rbxassetid://78229538488090"
        end

        local imageFrame = Instance.new("Frame")
        imageFrame.Size = UDim2.new(1, 0, 0, 0)
        imageFrame.AutomaticSize = Enum.AutomaticSize.Y
        imageFrame.BackgroundTransparency = 1
        imageFrame.BorderSizePixel = 0
        imageFrame.Parent = parent

        local horizontal = Instance.new("Frame")
        horizontal.Size = UDim2.new(1, 0, 0, 0)
        horizontal.AutomaticSize = Enum.AutomaticSize.Y
        horizontal.BackgroundTransparency = 1
        horizontal.Parent = imageFrame

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 80, 0, 80)
        iconImg.Position = UDim2.new(0, 12, 0, 12)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = formatIcon(iconAsset)
        iconImg.ImageColor3 = iconColor
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.Parent = horizontal
        Instance.new("UICorner", iconImg).CornerRadius = UDim.new(0, 12)

        local textContainer = Instance.new("Frame")
        textContainer.Size = UDim2.new(1, -104, 0, 0)
        textContainer.Position = UDim2.new(0, 104, 0, 12)
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

        if subtitle ~= "" then
            local subtitleLabel = Instance.new("TextLabel")
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
        end

        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(1, -24, 0, 1)
        Line.Position = UDim2.new(0, 12, 1, -12)
        Line.BackgroundColor3 = CurrentTheme.Stroke
        Line.BackgroundTransparency = 0.65
        Line.BorderSizePixel = 0
        Line.Parent = imageFrame
        AddToRegistry(Line, "BackgroundColor3", "Stroke")

        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, 24)
        padding.Parent = textContainer

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = imageFrame
        clickBtn.MouseButton1Click:Connect(callback)

        local self = {}
        function self.UpdateTitle(newTitle) titleLabel.Text = newTitle end
        function self.SetVisible(state) imageFrame.Visible = state end
        return self
    end

    -- Divider  原尺寸：24 / 12
    child.Divider = function(_, config)
        config = config or {}
        local parent = config.Parent or contentHolder
        local labelText = config.Name or ""
        local hasText = (labelText ~= "")
        local containerHeight = hasText and 24 or 12
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, containerHeight)
        container.BackgroundTransparency = 1
        container.Parent = parent
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -10, 0, 1)
        line.Position = UDim2.new(0, 5, 0.5, 0)
        line.AnchorPoint = Vector2.new(0, 0.5)
        line.BackgroundColor3 = CurrentTheme.Stroke
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = container
        AddToRegistry(line, "BackgroundColor3", "Stroke")
        if hasText then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 0, 0, 16)
            label.AutomaticSize = Enum.AutomaticSize.X
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            label.Position = UDim2.new(0.5, 0, 0.5, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = labelText
            label.TextSize = 12
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.4
            label.Parent = container
            AddToRegistry(label, "TextColor3", "Text")
        end
        local self = {}
        function self.SetVisible(state) container.Visible = state end
        function self.UpdateText(newText)
            local lbl = container:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.Text = newText or "" end
        end
        return self
    end

    -- Space
    child.Space = function(_, config)
        local height = (config and config.Height) or 8
        local parent = config and config.Parent or contentHolder
        local sp = Instance.new("Frame")
        sp.Size = UDim2.new(1, 0, 0, height)
        sp.BackgroundTransparency = 1
        sp.BorderSizePixel = 0
        sp.Parent = parent
        local self = {}
        function self.SetHeight(h) height = h; sp.Size = UDim2.new(1, 0, 0, height) end
        function self.SetVisible(state) sp.Visible = state end
        function self.Destroy() sp:Destroy() end
        return self
    end

    -- Checkbox  原尺寸：42px
    child.Checkbox = function(_, config)
        local title = config.Name or ""
        local default = config.Default or false
        local callback = config.Callback or function() end
        local controlId = title.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder

        local Tile = miRow(parent, 42)
        local TitleLbl = miLabel(Tile, title, 15, 13.5, UDim2.new(1, -60, 0, 15))

        local box = Instance.new("Frame")
        box.Size = UDim2.fromOffset(20, 20)
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, -12, 0.5, 0)
        box.BackgroundColor3 = default and CurrentTheme.Accent or Color3.fromRGB(26, 28, 36)
        box.BorderSizePixel = 0
        box.Parent = Tile
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 1.4
        boxStroke.Transparency = default and 1 or 0.4
        boxStroke.Color = default and CurrentTheme.Accent or CurrentTheme.Stroke
        boxStroke.Parent = box

        local check = Instance.new("ImageLabel")
        check.Size = UDim2.fromOffset(14, 14)
        check.AnchorPoint = Vector2.new(0.5, 0.5)
        check.Position = UDim2.new(0.5, 0, 0.5, 0)
        check.BackgroundTransparency = 1
        check.Image = "rbxassetid://10709790644"
        check.ImageColor3 = Color3.new(1, 1, 1)
        check.ImageTransparency = default and 0 or 1
        check.Parent = box

        local h = { Value = default, Callback = callback, Type = "Checkbox" }
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.AutoButtonColor = false
        ClickBtn.Parent = Tile
        ClickBtn.Active = not locked

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
            ClickBtn.Active = not st
        end

        local function updateColors()
            if h.Value then
                box.BackgroundColor3 = CurrentTheme.Accent
                boxStroke.Color = CurrentTheme.Accent
                boxStroke.Transparency = 1
                check.ImageTransparency = 0
            else
                box.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
                boxStroke.Color = CurrentTheme.Stroke
                boxStroke.Transparency = 0.4
                check.ImageTransparency = 1
            end
        end
        table.insert(ThemeListeners, updateColors)

        function h:SetValue(val)
            if locked then return end
            val = not (not val)
            h.Value = val
            updateColors()
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = val end
            pcall(callback, val)
            pcall(h.Changed, val)
        end
        function h:OnChanged(_, cb) h.Changed = cb; cb(h.Value) end
        function h:GetValue() return h.Value end
        function h:SetVisible(vis) Tile.Visible = vis end
        function h:Destroy() Tile:Destroy(); ConfigObjects[controlId] = nil end
        function h:Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function h:Unlock() updateLock(false) end
        function h:IsLocked() return locked end

        ClickBtn.MouseButton1Click:Connect(function() if not locked then h:SetValue(not h.Value) end end)

        h:SetValue(default)
        ConfigObjects[controlId] = { Type = "Checkbox", Value = h.Value, Set = function(val) h:SetValue(val) end }
        return h
    end

    -- ProgressBar  原尺寸：46 / 26
    child.ProgressBar = function(_, config)
        local name = config.Name or ""
        local valueConfig = config.Value or {}
        local min = valueConfig.Min or 0
        local max = valueConfig.Max or 100
        local default = valueConfig.Default or min
        local showPercent = config.ShowPercent ~= false
        local callback = config.Callback or function() end
        local controlId = name.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder

        local containerHeight = (name ~= "" and 46 or 26)
        local Tile = miRow(parent, containerHeight)
        Tile.BackgroundTransparency = 1

        local TitleLbl = nil
        if name ~= "" then
            TitleLbl = miLabel(Tile, name, 0, 0, UDim2.new(1, -50, 0, 16), 14)
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
            pctLbl.Parent = Tile
            AddToRegistry(pctLbl, "TextColor3", "Text")
        end

        local rail = Instance.new("Frame")
        rail.Size = UDim2.new(1, 0, 0, 8)
        rail.Position = UDim2.new(0, 0, 1, -8)
        rail.BackgroundColor3 = CurrentTheme.Stroke
        rail.BackgroundTransparency = 0.4
        rail.BorderSizePixel = 0
        rail.Parent = Tile
        Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)
        AddToRegistry(rail, "BackgroundColor3", "Stroke")

        local fill = Instance.new("Frame")
        fill.Size = UDim2.fromScale(0, 1)
        fill.BackgroundColor3 = CurrentTheme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = rail
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        AddToRegistry(fill, "BackgroundColor3", "Accent")

        local h = { Value = math.clamp(default, min, max), Min = min, Max = max, Type = "ProgressBar", Frame = Tile }

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(Tile, lockedTitle)
        lockFrame.Visible = locked

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
        end

        function h:SetTitle(s) if TitleLbl then TitleLbl.Text = tostring(s or "") end end
        function h:SetValue(val)
            if locked then return end
            val = math.clamp(tonumber(val) or h.Min, h.Min, h.Max)
            h.Value = val
            local alpha = (h.Max > h.Min) and (val - h.Min) / (h.Max - h.Min) or 0
            Tween(fill, {Size = UDim2.fromScale(alpha, 1)}, 0.2)
            if pctLbl then pctLbl.Text = math.floor(alpha * 100).."%" end
            if callback then pcall(callback, val) end
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = val end
        end
        function h:Destroy() Tile:Destroy(); ConfigObjects[controlId] = nil end
        function h:SetVisible(state) Tile.Visible = state end
        function h:Lock(title) updateLock(true); if title then lockLabel.Text = title; lockedTitle = title end end
        function h:Unlock() updateLock(false) end
        function h:IsLocked() return locked end

        h:SetValue(default)
        ConfigObjects[controlId] = { Type = "ProgressBar", Value = h.Value, Set = function(val) h:SetValue(val) end }
        return h
    end

    -- Video (180px 起始 / 按宽高比)
    child.Video = function(_, config)
        local opts = config or {}
        local parent = opts.Parent or contentHolder
        if not parent then return end
        local src = opts.Video or ""
        local looped = opts.Looped ~= false
        local vol = opts.Volume or 0
        local auto = opts.AutoPlay ~= false
        local aspect = opts.AspectRatio or "16:9"

        local function resolveMedia(s)
            if type(s) ~= "string" or s == "" then return "" end
            if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
            if s:match("^%d+$") then return "rbxassetid://"..s end
            if s:match("^https?://") then return MediaManager:Video(s) end
            return ""
        end
        local function parseRatio(r)
            if type(r) == "number" then return r end
            if type(r) == "string" then local rw, rh = r:match("(%d+):(%d+)") if rw and rh and tonumber(rh) ~= 0 then return tonumber(rw)/tonumber(rh) end end
            return 16/9
        end
        local ratioNum = parseRatio(aspect)

        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, -16, 0, 180)
        wrap.BackgroundColor3 = CurrentTheme.Main
        wrap.BackgroundTransparency = 0.6
        wrap.BorderSizePixel = 0
        wrap.ClipsDescendants = true
        wrap.Parent = parent
        AddToRegistry(wrap, "BackgroundColor3", "Main")
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)

        local function recalcAspect()
            local w = wrap.AbsoluteSize.X
            if w > 0 and ratioNum and ratioNum > 0 then
                wrap.Size = UDim2.new(1, -16, 0, math.floor(w / ratioNum))
            end
        end
        wrap:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcAspect)
        task.defer(recalcAspect)

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
            vid.Video = resolved
            vid.Parent = wrap
            Instance.new("UICorner", vid).CornerRadius = UDim.new(0, 8)
        end

        local placeholder = Instance.new("Frame")
        placeholder.Size = UDim2.fromScale(1, 1)
        placeholder.BackgroundTransparency = 1
        placeholder.Visible = not hasVideo
        placeholder.ZIndex = 2
        placeholder.Parent = wrap

        local phText = Instance.new("TextLabel")
        phText.Size = UDim2.new(1, 0, 0, 16)
        phText.Position = UDim2.new(0, 0, 0.5, -8)
        phText.BackgroundTransparency = 1
        phText.Text = "Video not available"
        phText.TextSize = 11
        phText.Font = Enum.Font.GothamMedium
        phText.TextTransparency = 0.5
        phText.ZIndex = 3
        phText.Parent = placeholder
        AddToRegistry(phText, "TextColor3", "SubText")

        if not hasVideo then
            local mod = { Frame = wrap, Type = "Video", VideoFrame = nil }
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
        gradFr.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        gradFr.BackgroundTransparency = 0
        gradFr.BorderSizePixel = 0
        gradFr.ZIndex = 5
        gradFr.Parent = overlay
        local grad = Instance.new("UIGradient")
        grad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
        grad.Rotation = 90
        grad.Parent = gradFr

        local ctrlRow = Instance.new("Frame")
        ctrlRow.Size = UDim2.new(1, -12, 0, 26)
        ctrlRow.Position = UDim2.new(0, 6, 0, 24)
        ctrlRow.BackgroundTransparency = 1
        ctrlRow.ZIndex = 6
        ctrlRow.Parent = overlay

        local playBtn = Instance.new("TextButton")
        playBtn.Size = UDim2.fromOffset(22, 22)
        playBtn.BackgroundTransparency = 1
        playBtn.Text = ""
        playBtn.ZIndex = 7
        playBtn.AutoButtonColor = false
        playBtn.Parent = ctrlRow
        local playIco = Instance.new("ImageLabel")
        playIco.Size = UDim2.fromOffset(16, 16)
        playIco.Position = UDim2.new(0.5, 0, 0.5, 0)
        playIco.AnchorPoint = Vector2.new(0.5, 0.5)
        playIco.BackgroundTransparency = 1
        playIco.Image = "rbxassetid://10734923549"
        playIco.ZIndex = 8
        playIco.Parent = playBtn
        AddToRegistry(playIco, "ImageColor3", "Text")

        local pauseBtn = Instance.new("TextButton")
        pauseBtn.Size = UDim2.fromOffset(22, 22)
        pauseBtn.BackgroundTransparency = 1
        pauseBtn.Text = ""
        pauseBtn.ZIndex = 7
        pauseBtn.AutoButtonColor = false
        pauseBtn.Parent = ctrlRow
        local pauseIco = Instance.new("ImageLabel")
        pauseIco.Size = UDim2.fromOffset(16, 16)
        pauseIco.Position = UDim2.new(0.5, 0, 0.5, 0)
        pauseIco.AnchorPoint = Vector2.new(0.5, 0.5)
        pauseIco.BackgroundTransparency = 1
        pauseIco.Image = "rbxassetid://10734919336"
        pauseIco.ZIndex = 8
        pauseIco.Parent = pauseBtn
        AddToRegistry(pauseIco, "ImageColor3", "Text")

        local btnLayout = Instance.new("UIListLayout")
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        btnLayout.Padding = UDim.new(0, 2)
        btnLayout.Parent = ctrlRow

        pauseBtn.Visible = auto
        playBtn.Visible = not auto

        playBtn.MouseButton1Click:Connect(function() if vid then pcall(function() vid:Play() end) end; playBtn.Visible = false; pauseBtn.Visible = true end)
        pauseBtn.MouseButton1Click:Connect(function() if vid then pcall(function() vid:Pause() end) end; playBtn.Visible = true; pauseBtn.Visible = false end)

        local vidClickBtn = Instance.new("TextButton")
        vidClickBtn.Size = UDim2.fromScale(1, 1)
        vidClickBtn.BackgroundTransparency = 1
        vidClickBtn.Text = ""
        vidClickBtn.ZIndex = 4
        vidClickBtn.AutoButtonColor = false
        vidClickBtn.Parent = wrap
        vidClickBtn.MouseButton1Click:Connect(function()
            Tween(overlay, {GroupTransparency = overlay.GroupTransparency > 0.5 and 0 or 1}, 0.2)
        end)

        if auto and hasVideo then
            task.spawn(function()
                task.wait(0.08)
                if vid and vid.Parent then pcall(function() vid:Play() end) end
            end)
        end

        local mod = { Frame = wrap, Type = "Video", VideoFrame = vid }
        function mod:Play() if vid then pcall(function() vid:Play() end) end end
        function mod:Pause() if vid then pcall(function() vid:Pause() end) end end
        function mod:Stop() if vid then pcall(function() vid:Stop() end) end end
        function mod:SetVideo(s) if vid then local r = resolveMedia(s); if r ~= "" then vid.Video = r end end end
        function mod:SetVolume(v) if vid then vid.Volume = math.clamp(v, 0, 1) end end
        function mod:SetAspectRatio(r) ratioNum = parseRatio(r); recalcAspect() end
        function mod:Destroy() wrap:Destroy() end
        return mod
    end

    -- Audio (118 / 96)
    child.Audio = function(_, config)
        local opts = config or {}
        local parent = opts.Parent or contentHolder
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
            if type(s) ~= "string" or s == "" then return "" end
            if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
            if s:match("^%d+$") then return "rbxassetid://"..s end
            return ""
        end

        local isHttp = type(src) == "string" and src:match("^https?://")
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
        if hasAudio and not pendingDownload then snd = initSound(resolved) end

        local wrapHeight = (title ~= "" or subtitle ~= "") and 118 or 96
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, -16, 0, wrapHeight)
        wrap.BackgroundColor3 = CurrentTheme.Main
        wrap.BackgroundTransparency = 0.6
        wrap.BorderSizePixel = 0
        wrap.Parent = parent
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)
        AddToRegistry(wrap, "BackgroundColor3", "Main")

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
        audioIcon.Image = "rbxassetid://10747376008"
        audioIcon.ZIndex = 2
        audioIcon.Parent = topRow
        AddToRegistry(audioIcon, "ImageColor3", hasAudio and "Accent" or "SubText")

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Size = UDim2.new(1, -120, 1, 0)
        statusLbl.Position = UDim2.new(0, 28, 0, 0)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = (title ~= "" and title) or (hasAudio and "Audio" or "No audio source")
        statusLbl.TextSize = 12
        statusLbl.Font = Enum.Font.GothamBold
        statusLbl.TextXAlignment = Enum.TextXAlignment.Left
        statusLbl.ZIndex = 2
        statusLbl.Parent = topRow
        AddToRegistry(statusLbl, "TextColor3", "Text")

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
            btn.AutoButtonColor = false
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
            local icons = { play = "rbxassetid://10734923549", pause = "rbxassetid://10734919336", stop = "rbxassetid://10734972621" }
            ic.Image = icons[iconId] or ""
            btn.MouseButton1Click:Connect(function() pcall(cb) end)
            return btn, ic
        end

        local playing = false
        local playBtn, pauseBtn
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
                if snd then _doPlay(); return end
                if pendingDownload then
                    _downloading = true
                    task.spawn(function()
                        local got = resolve(src, false)
                        _downloading = false
                        if got and got ~= "" then
                            pendingDownload = false
                            snd = initSound(got)
                            _doPlay()
                        end
                    end)
                end
            end
            playBtn = ctrlBtn("play", _triggerPlay)
            pauseBtn = ctrlBtn("pause", function()
                if snd then snd:Pause() end
                playing = false
                if playBtn then playBtn.Visible = true end
                if pauseBtn then pauseBtn.Visible = false end
            end)
            pauseBtn.Visible = false
            ctrlBtn("stop", function()
                if snd then pcall(function() snd:Stop(); snd.TimePosition = 0 end) end
                playing = false
                if playBtn then playBtn.Visible = true end
                if pauseBtn then pauseBtn.Visible = false end
            end)
            if auto and snd then _doPlay() end
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
        durLbl.Parent = seekRow
        AddToRegistry(durLbl, "TextColor3", "SubText")

        local rail = Instance.new("Frame")
        rail.Size = UDim2.new(1, -76, 0, 4)
        rail.Position = UDim2.new(0, 38, 0.5, 0)
        rail.AnchorPoint = Vector2.new(0, 0.5)
        rail.BackgroundColor3 = CurrentTheme.Stroke
        rail.BackgroundTransparency = 0.4
        rail.Parent = seekRow
        AddToRegistry(rail, "BackgroundColor3", "Stroke")
        Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = CurrentTheme.Accent
        fill.Parent = rail
        AddToRegistry(fill, "BackgroundColor3", "Accent")
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(12, 12)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.BackgroundColor3 = CurrentTheme.Accent
        knob.Parent = rail
        AddToRegistry(knob, "BackgroundColor3", "Accent")
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function fmtTime(s) s = math.max(0, math.floor(s or 0)); return string.format("%d:%02d", math.floor(s/60), s%60) end

        local dragging = false
        local function seekTo(inputX)
            if not snd then return end
            local railX = rail.AbsolutePosition.X
            local railW = rail.AbsoluteSize.X
            if railW <= 0 then return end
            local pct = math.clamp((inputX - railX) / railW, 0, 1)
            local dur = snd.TimeLength or 0
            if dur > 0 then pcall(function() snd.TimePosition = pct * dur end) end
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

        local mod = { Frame = wrap, Type = "Audio", Sound = snd }
        function mod:Play() if snd then pcall(function() snd:Play() end) end end
        function mod:Pause() if snd then pcall(function() snd:Pause() end) end end
        function mod:Stop() if snd then pcall(function() snd:Stop() end) end end
        function mod:SetVolume(v) if snd then snd.Volume = math.clamp(v, 0, 10) end end
        function mod:Destroy() safeDisconnect(hbConn); if snd then pcall(function() snd:Stop(); snd:Destroy() end) end; wrap:Destroy() end
        return mod
    end

    -- Social  (64px)
    child.Social = function(_, config)
        config = config or {}
        local parent = config.Parent or contentHolder
        if not parent then return end
        local displayName = tostring(config.Name or config.DisplayName or "")
        local subName = tostring(config.SubName or config.Subtitle or "")
        local platform = tostring(config.SmlName or config.Platform or "")
        local avatarSrc = config.Logo or config.Avatar or ""
        local copyText = tostring(config.copy or "")
        local buttonText = tostring(config.Cbn or "复制")
        if displayName == "" then displayName = "用户" end

        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 64)
        wrap.BackgroundTransparency = 1
        wrap.BorderSizePixel = 0
        wrap.Parent = parent

        local avatarBg = Instance.new("Frame")
        avatarBg.Size = UDim2.fromOffset(42, 42)
        avatarBg.Position = UDim2.new(0, 11, 0.5, 0)
        avatarBg.AnchorPoint = Vector2.new(0, 0.5)
        avatarBg.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        avatarBg.BorderSizePixel = 0
        avatarBg.Parent = wrap
        avatarBg.ClipsDescendants = true
        Instance.new("UICorner", avatarBg).CornerRadius = UDim.new(1, 0)

        local avatarImg = Instance.new("ImageLabel")
        avatarImg.Size = UDim2.fromScale(1, 1)
        avatarImg.BackgroundTransparency = 1
        avatarImg.Parent = avatarBg
        Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Text = displayName
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 13
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.BackgroundTransparency = 1
        nameLbl.Size = UDim2.new(1, -140, 0, 16)
        nameLbl.Position = UDim2.new(0, 62, 0, 9)
        nameLbl.Parent = wrap
        AddToRegistry(nameLbl, "TextColor3", "Text")

        if subName ~= "" then
            local subNameLbl = Instance.new("TextLabel")
            subNameLbl.Text = subName
            subNameLbl.Font = Enum.Font.Gotham
            subNameLbl.TextSize = 11
            subNameLbl.TextXAlignment = Enum.TextXAlignment.Left
            subNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            subNameLbl.BackgroundTransparency = 1
            subNameLbl.Size = UDim2.new(1, -140, 0, 13)
            subNameLbl.Position = UDim2.new(0, 62, 0, 27)
            subNameLbl.Parent = wrap
            AddToRegistry(subNameLbl, "TextColor3", "SubText")
        end

        if platform ~= "" then
            local platformLbl = Instance.new("TextLabel")
            platformLbl.Text = platform
            platformLbl.Font = Enum.Font.Gotham
            platformLbl.TextSize = 10
            platformLbl.TextTransparency = 0.3
            platformLbl.TextXAlignment = Enum.TextXAlignment.Left
            platformLbl.BackgroundTransparency = 1
            platformLbl.Size = UDim2.new(1, -140, 0, 12)
            platformLbl.Position = UDim2.new(0, 62, 0, subName ~= "" and 42 or 27)
            platformLbl.Parent = wrap
            AddToRegistry(platformLbl, "TextColor3", "SubText")
        end

        if copyText ~= "" then
            local copyBtn = Instance.new("TextButton")
            copyBtn.Text = buttonText
            copyBtn.Size = UDim2.fromOffset(52, 26)
            copyBtn.Position = UDim2.new(1, -11, 0.5, 0)
            copyBtn.AnchorPoint = Vector2.new(1, 0.5)
            copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyBtn.Font = Enum.Font.GothamMedium
            copyBtn.TextSize = 12
            copyBtn.BackgroundColor3 = Color3.fromRGB(39, 40, 49)
            copyBtn.BorderSizePixel = 0
            copyBtn.Parent = wrap
            Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 8)
            copyBtn.MouseButton1Click:Connect(function()
                pcall(function() toclipboard(copyText) end)
            end)
        end

        task.spawn(function()
            local imgUrl = nil
            if avatarSrc ~= "" then
                if avatarSrc:match("^rbxassetid://") or avatarSrc:match("^rbxasset://") or avatarSrc:match("^http") then
                    imgUrl = avatarSrc
                elseif tonumber(avatarSrc) then
                    imgUrl = "rbxassetid://"..avatarSrc
                end
            end
            if imgUrl and imgUrl ~= "" then
                local ok, asset = pcall(function() return MediaManager:Image(imgUrl) end)
                if ok and asset and asset ~= "" then
                    avatarImg.Image = asset
                end
            end
        end)

        local mod = { Frame = wrap, Type = "Social" }
        function mod:SetName(n) displayName = tostring(n or ""); nameLbl.Text = displayName end
        function mod:Destroy() wrap:Destroy() end
        return mod
    end

    -- Paragraph (AutomaticSize)
    child.Paragraph = function(_, config)
        config = config or {}
        local title = config.Name or ""
        local content = config.Content or ""
        local parent = config.Parent or contentHolder

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 0)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Parent = parent

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 14)
        titleLabel.Position = UDim2.new(0, 10, 0, 13)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.Text = title
        titleLabel.TextSize = 13
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.RichText = true
        titleLabel.Parent = frame
        AddToRegistry(titleLabel, "TextColor3", "Text")

        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1, -20, 0, 0)
        contentLabel.Position = UDim2.new(0, 10, 0, 30)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.Text = content
        contentLabel.TextSize = 12
        contentLabel.TextTransparency = 0.3
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextWrapped = true
        contentLabel.AutomaticSize = Enum.AutomaticSize.Y
        contentLabel.RichText = true
        contentLabel.Parent = frame
        AddToRegistry(contentLabel, "TextColor3", "SubText")

        local bottomPad = Instance.new("Frame")
        bottomPad.Size = UDim2.new(1, 0, 0, 13)
        bottomPad.Position = UDim2.new(0, 0, 1, 0)
        bottomPad.AnchorPoint = Vector2.new(0, 1)
        bottomPad.BackgroundTransparency = 1
        bottomPad.Parent = frame

        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or "Locked"
        local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
        lockFrame.Visible = locked

        local function updateLock(st)
            locked = st
            lockFrame.Visible = st
        end

        local self = {}
        function self.SetName(n) titleLabel.Text = n end
        function self.SetContent(c) contentLabel.Text = c end
        function self.SetVisible(state) frame.Visible = state end
        function self.Destroy() frame:Destroy() end
        function self.Lock(t) updateLock(true); if t then lockLabel.Text = t; lockedTitle = t end end
        function self.Unlock() updateLock(false) end
        function self.IsLocked() return locked end
        return self
    end

    -- Viewport
    child.Viewport = function(_, config)
        local opts = config or {}
        local parent = opts.Parent or contentHolder
        if not parent then return end
        local UIS = UserInputService
        local height = opts.Height or 200
        local focused = (opts.Focused ~= false)
        local interactive = (opts.Interactive ~= false)
        local camera = opts.Camera or Instance.new("Camera")
        local obj = opts.Object
        local aspectRatio = opts.AspectRatio
        local radius = opts.Radius or 8
        assert(obj, "Viewport - Missing Object")

        local function parseRatio(r)
            if type(r) == "number" then return r end
            if type(r) == "string" then
                local w, h = r:match("(%d+):(%d+)")
                if w and h and tonumber(h) ~= 0 then return tonumber(w)/tonumber(h) end
            end
            return nil
        end

        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, -16, 0, height)
        wrap.BackgroundColor3 = CurrentTheme.Main
        wrap.BackgroundTransparency = 0.6
        wrap.BorderSizePixel = 0
        wrap.ClipsDescendants = true
        wrap.Parent = parent
        AddToRegistry(wrap, "BackgroundColor3", "Main")
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, radius)

        local ratioNum = parseRatio(aspectRatio)
        local function recalcAspect()
            if not ratioNum or ratioNum <= 0 then return end
            local w = wrap.AbsoluteSize.X
            if w > 0 then wrap.Size = UDim2.new(1, -16, 0, math.floor(w / ratioNum)) end
        end
        wrap:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcAspect)
        task.defer(recalcAspect)

        local vp = Instance.new("ViewportFrame")
        vp.Size = UDim2.fromScale(1, 1)
        vp.BackgroundTransparency = 1
        vp.CurrentCamera = camera
        vp.Active = interactive
        vp.Parent = wrap
        obj.Parent = vp

        local Dragging = false
        local LastMousePos = nil
        local function focusCamera()
            local mpos = obj:GetPivot().Position
            local size = obj:IsA("BasePart") and obj.Size or select(2, obj:GetBoundingBox(0))
            local ext = math.max(size.X, size.Y, size.Z)
            camera.CFrame = CFrame.new(mpos + Vector3.new(0, ext/2, ext*2), mpos)
        end
        if focused then task.defer(focusCamera) end

        vp.InputBegan:Connect(function(inp)
            if interactive then
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    LastMousePos = inp.Position
                end
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if interactive and Dragging then
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local delta = inp.Position - LastMousePos
                    LastMousePos = inp.Position
                    local pos = obj:GetPivot().Position
                    local ry = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -delta.X * 0.02)
                    camera.CFrame = CFrame.new(pos) * ry * CFrame.new(-pos) * camera.CFrame
                end
            end
        end)
        vp.InputChanged:Connect(function(inp)
            if interactive and inp.UserInputType == Enum.UserInputType.MouseWheel then
                local zoom = inp.Position.Z * 2
                camera.CFrame = camera.CFrame + camera.CFrame.LookVector * zoom
            end
        end)

        local self = {
            Frame = wrap, Type = "Viewport", Object = obj, Camera = camera,
            Interactive = interactive, Height = height, Focused = focused, Value = nil
        }
        function self:SetObject(newObj, clone)
            if clone then newObj = newObj:Clone() end
            if self.Object then self.Object:Destroy() end
            self.Object = newObj
            self.Object.Parent = vp
            if self.Focused then focusCamera() end
        end
        function self:SetHeight(h) self.Height = h; wrap.Size = UDim2.new(1, -16, 0, h) end
        function self:SetAspectRatio(ratio) ratioNum = parseRatio(ratio); if ratioNum then recalcAspect() end end
        function self:Focus() if self.Object then focusCamera() end end
        function self:SetCamera(cam) self.Camera = cam; vp.CurrentCamera = cam end
        function self:SetInteractive(val) self.Interactive = val; vp.Active = val end
        function self:Destroy() wrap:Destroy() end
        return self
    end

    -- Group
    child.Group = function(_, config)
        config = config or {}
        local columns = config.Columns or 2
        local gap = config.Gap or 6
        local parent = config.Parent or contentHolder

        local outerWrap = Instance.new("Frame")
        outerWrap.Size = UDim2.new(1, 0, 0, 0)
        outerWrap.BackgroundTransparency = 1
        outerWrap.AutomaticSize = Enum.AutomaticSize.Y
        outerWrap.Parent = parent

        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 0)
        wrap.BackgroundTransparency = 1
        wrap.AutomaticSize = Enum.AutomaticSize.Y
        wrap.Parent = outerWrap

        local totalGap = gap * (columns - 1)
        local colScale = 1 / columns
        local colOffset = -math.floor(totalGap / columns + 0.5)

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, gap)
        layout.Parent = wrap

        local elements = {}
        local mod = { Frame = outerWrap, Type = "Group", Elements = elements }
        function mod:AddElement()
            local el = Instance.new("Frame")
            el.Size = UDim2.new(colScale, colOffset, 0, 0)
            el.BackgroundTransparency = 1
            el.AutomaticSize = Enum.AutomaticSize.Y
            el.Parent = wrap
            local innerLayout = Instance.new("UIListLayout")
            innerLayout.Padding = UDim.new(0, 5)
            innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            innerLayout.Parent = el
            local colObj = {}
            local function makeColMethod(methodName)
                return function(_, cfg)
                    cfg = cfg or {}
                    cfg.Parent = el
                    return child[methodName](_, cfg)
                end
            end
            local colMethods = {}
            for methodName, fn in pairs(child) do
                if type(fn) == "function" and methodName ~= "Group" and methodName ~= "Section" then
                    colMethods[methodName] = makeColMethod(methodName)
                end
            end
            setmetatable(colObj, {__index = colMethods})
            table.insert(elements, {Frame = el, ColObj = colObj})
            return colObj
        end
        function mod:Destroy() outerWrap:Destroy() end
        return mod
    end

    local functions = {}
    for k, v in pairs(child) do functions[k] = v end

    -- Section
    local function createSection(_, config)
        if type(config) == "string" then
            config = { Name = config }
        elseif type(config) ~= "table" then
            config = {}
        end

        local sectionTitle    = config.Name or config.Title or ""
        local sectionSubtitle = config.SubName or config.Subtitle or ""
        local sectionIcon     = config.Logo or config.Icon or nil
        local collapsible     = config.Collapsible == true
        local collapsed       = collapsible and (config.Collapsed == false)

        local locked      = config.Locked == true
        local lockedTitle = config.TextLocked or config.LockMessage or "Locked"

        local hasTitle    = (sectionTitle ~= "")
        local hasSubtitle = (sectionSubtitle ~= "")
        local hasIcon     = (sectionIcon ~= nil)
        local hasHeader   = hasTitle or hasSubtitle or hasIcon

        local HEADER_LEFT = 12
        local ARROW_W     = collapsible and 26 or 0

        local ICON_SIZE = hasSubtitle and 40 or 32
        local TITLE_SIZE = 15
        local TITLE_H    = 20
        local SUB_SIZE = 12
        local SUB_H    = 16
        local SUB_GAP  = 2

        local HEADER_H
        if hasHeader then HEADER_H = hasSubtitle and 56 or 44 else HEADER_H = 4 end

        local COLLAPSED_H
        if hasSubtitle then COLLAPSED_H = 50
        elseif hasHeader then COLLAPSED_H = 40
        else COLLAPSED_H = collapsible and 40 or 4 end

        local CONTENT_TOP = hasHeader and (HEADER_H + 4) or 4

        local ICON_TOP       = math.floor((COLLAPSED_H - ICON_SIZE) / 2)
        local TEXT_BLOCK_H   = hasSubtitle and (TITLE_H + SUB_GAP + SUB_H) or TITLE_H
        local TEXT_BLOCK_TOP = math.floor((COLLAPSED_H - TEXT_BLOCK_H) / 2)
        local TITLE_TOP      = TEXT_BLOCK_TOP
        local SUB_TOP        = TEXT_BLOCK_TOP + TITLE_H + SUB_GAP
        local ARROW_TOP      = math.floor((COLLAPSED_H - 18) / 2)

        local MIUI_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quart)

        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(0.96, 0, 0, 0)
        sectionFrame.AnchorPoint = Vector2.new(0, 0)
        sectionFrame.Position = UDim2.new(0, 0, 0, 0)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.ClipsDescendants = true
        sectionFrame.Parent = parent

        local contentContainer = Instance.new("Frame")
        contentContainer.Size = UDim2.new(1, -10, 0, 0)
        contentContainer.Position = UDim2.new(0.5, 0, 0, 0)
        contentContainer.AnchorPoint = Vector2.new(0.5, 0)
        contentContainer.BackgroundTransparency = 0.5
        contentContainer.ClipsDescendants = true
        contentContainer.Parent = sectionFrame
        AddToRegistry(contentContainer, "BackgroundColor3", "Main")

        local contentStroke = Instance.new("UIStroke")
        contentStroke.Thickness = 1
        contentStroke.Transparency = 0.65
        contentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        contentStroke.Parent = contentContainer
        AddToRegistry(contentStroke, "Color", "Stroke")

        local contentCorner = Instance.new("UICorner")
        contentCorner.CornerRadius = UDim.new(0, 10)
        contentCorner.Parent = contentContainer

        local iconLabel = nil
        local iconGap = 0
        if hasIcon then
            iconLabel = Instance.new("ImageLabel")
            iconLabel.Name = "SectionLogo"
            iconLabel.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
            iconLabel.Position = UDim2.new(0, HEADER_LEFT, 0, ICON_TOP)
            iconLabel.BackgroundTransparency = 1
            iconLabel.ImageColor3 = Color3.new(1, 1, 1)
            if tonumber(sectionIcon) then
                iconLabel.Image = "rbxassetid://" .. tostring(sectionIcon)
            else
                iconLabel.Image = tostring(sectionIcon)
            end
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = iconLabel
            iconLabel.Parent = contentContainer
            AddToRegistry(iconLabel, "ImageColor3", "Text")
            iconGap = ICON_SIZE + 10
        end

        local titleLabel = nil
        if hasTitle then
            titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "SectionTitle"
            titleLabel.Size = UDim2.new(1, -(HEADER_LEFT * 2 + iconGap + ARROW_W), 0, TITLE_H)
            titleLabel.Position = UDim2.new(0, HEADER_LEFT + iconGap, 0, TITLE_TOP)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = sectionTitle
            titleLabel.TextSize = TITLE_SIZE
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextYAlignment = Enum.TextYAlignment.Center
            titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            titleLabel.TextColor3 = CurrentTheme.Accent
            titleLabel.Parent = contentContainer
            AddToRegistry(titleLabel, "TextColor3", "Accent")
        end

        local subtitleLabel = nil
        if hasSubtitle then
            subtitleLabel = Instance.new("TextLabel")
            subtitleLabel.Name = "SectionSubName"
            subtitleLabel.Size = UDim2.new(1, -(HEADER_LEFT * 2 + iconGap + ARROW_W), 0, SUB_H)
            subtitleLabel.Position = UDim2.new(0, HEADER_LEFT + iconGap, 0, SUB_TOP)
            subtitleLabel.BackgroundTransparency = 1
            subtitleLabel.Font = Enum.Font.Gotham
            subtitleLabel.Text = sectionSubtitle
            subtitleLabel.TextSize = SUB_SIZE
            subtitleLabel.TextTransparency = 0.4
            subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            subtitleLabel.TextYAlignment = Enum.TextYAlignment.Center
            subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            subtitleLabel.Parent = contentContainer
            AddToRegistry(subtitleLabel, "TextColor3", "SubText")
        end

        local collapseArrow = nil
        if collapsible then
            collapseArrow = Instance.new("ImageLabel")
            collapseArrow.Name = "SectionCollapseArrow"
            collapseArrow.Size = UDim2.new(0, 18, 0, 18)
            collapseArrow.AnchorPoint = Vector2.new(1, 0.5)
            collapseArrow.Position = UDim2.new(1, -10, 0, ARROW_TOP + 9)
            collapseArrow.BackgroundTransparency = 1
            collapseArrow.Image = "rbxassetid://122444883127455"
            collapseArrow.ImageColor3 = CurrentTheme.Text
            collapseArrow.ImageTransparency = 0.35
            collapseArrow.ScaleType = Enum.ScaleType.Fit
            collapseArrow.Rotation = collapsed and 180 or 0
            collapseArrow.Parent = contentContainer
            AddToRegistry(collapseArrow, "ImageColor3", "Text")
        end

        local contentHolder = Instance.new("Frame")
        contentHolder.Size = UDim2.new(1, -10, 0, 0)
        contentHolder.Position = UDim2.new(0.5, 0, 0, CONTENT_TOP)
        contentHolder.AnchorPoint = Vector2.new(0.5, 0)
        contentHolder.BackgroundTransparency = 1
        contentHolder.AutomaticSize = Enum.AutomaticSize.None
        contentHolder.ClipsDescendants = false
        contentHolder.Parent = contentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.Parent = contentHolder

        local bottomPadding = Instance.new("Frame")
        bottomPadding.Size = UDim2.new(1, 0, 0, 4)
        bottomPadding.BackgroundTransparency = 1
        bottomPadding.LayoutOrder = 9999
        bottomPadding.Parent = contentHolder

        contentContainer.Visible = true
        contentHolder.Visible = true

        local lockFrame, lockLabel = createLockOverlay(sectionFrame, lockedTitle)
        lockFrame.ZIndex = 200
        lockFrame.Visible = locked

        local collapsedState = collapsed

        local function getContentHeight() return contentLayout.AbsoluteContentSize.Y or 0 end
        local function getTargetHeight()
            if collapsedState then return COLLAPSED_H end
            return getContentHeight() + CONTENT_TOP + 4
        end
        local function updateHeight(instant)
            local targetH = getTargetHeight()
            if instant then
                contentContainer.Size = UDim2.new(1, -10, 0, targetH)
                sectionFrame.Size = UDim2.new(0.96, 0, 0, targetH)
            else
                TweenService:Create(contentContainer, MIUI_TWEEN, {Size = UDim2.new(1, -10, 0, targetH)}):Play()
                TweenService:Create(sectionFrame, MIUI_TWEEN, {Size = UDim2.new(0.96, 0, 0, targetH)}):Play()
            end
        end

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not collapsedState then updateHeight(false) end
        end)
        contentHolder.ChildAdded:Connect(function()
            task.wait(0.05)
            if not collapsedState then updateHeight(false) end
        end)
        contentHolder.ChildRemoved:Connect(function()
            task.wait(0.05)
            if not collapsedState then updateHeight(false) end
        end)

        if collapsedState then contentHolder.Visible = false end
        task.defer(function() updateHeight(true) end)

        local function setCollapsed(state, instant)
            if not collapsible then return end
            state = state == true
            if collapsedState == state then return end
            collapsedState = state
            if collapseArrow then
                TweenService:Create(collapseArrow, MIUI_TWEEN, { Rotation = state and 180 or 0 }):Play()
            end
            contentHolder.Visible = not state
            updateHeight(instant)
        end

        if collapsible then
            local headBtn = Instance.new("TextButton")
            headBtn.Name = "SectionHeaderBtn"
            headBtn.Size = UDim2.new(1, 0, 0, HEADER_H)
            headBtn.Position = UDim2.new(0, 0, 0, 0)
            headBtn.BackgroundTransparency = 1
            headBtn.Text = ""
            headBtn.ZIndex = 5
            headBtn.AutoButtonColor = false
            headBtn.Parent = contentContainer
            headBtn.MouseButton1Click:Connect(function()
                if locked then return end
                setCollapsed(not collapsedState, false)
            end)
        end

        local sectionObj = {}
        for methodName, methodFn in pairs(child) do
            sectionObj[methodName] = function(_, cfg)
                cfg = cfg or {}
                cfg.Parent = contentHolder
                return methodFn(_, cfg)
            end
        end

        sectionObj.SetVisible = function(_, vis) sectionFrame.Visible = vis end
        sectionObj.SetTitle = function(_, text)
            if titleLabel then
                titleLabel.Text = text or ""
                titleLabel.Visible = (text ~= nil and text ~= "")
            end
        end
        sectionObj.SetSubtitle = function(_, text)
            if subtitleLabel then
                subtitleLabel.Text = text or ""
                subtitleLabel.Visible = (text ~= nil and text ~= "")
            end
        end
        sectionObj.SetCollapsed = function(_, state) setCollapsed(state, false); return sectionObj end
        sectionObj.ToggleCollapsed = function(_) setCollapsed(not collapsedState, false); return sectionObj end
        sectionObj.GetCollapsed = function(_) return collapsedState end
        sectionObj.SetCollapsible = function(_, state) collapsible = state == true; return sectionObj end
        sectionObj.IsCollapsible = function(_) return collapsible end
        sectionObj.SetLocked = function(_, state) locked = state == true; lockFrame.Visible = locked; return sectionObj end
        sectionObj.SetTextLocked = function(_, text) lockedTitle = text or "Locked"; lockLabel.Text = lockedTitle; return sectionObj end
        sectionObj.SetMessage = function(_, text) lockedTitle = text or "Locked"; lockLabel.Text = lockedTitle; return sectionObj end
        sectionObj.GetLocked = function(_) return locked end
        sectionObj.Lock = function(_, text)
            if text then lockedTitle = text; lockLabel.Text = lockedTitle end
            locked = true
            lockFrame.Visible = true
            return sectionObj
        end
        sectionObj.Unlock = function(_) locked = false; lockFrame.Visible = false; return sectionObj end

        return sectionObj
    end

    functions.Section = createSection
    return functions
end

-- ========== 窗口创建 ==========
function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Name or "FengYu"
    local Subtitle = Config.SubName
    local Keybind = Config.Keybind
    local IconAsset = Config.Logo
    local SceneId = Config.Scene

    if Config.Theme then
        if type(Config.Theme) == "string" then
            if Themes[Config.Theme] then CurrentTheme = Themes[Config.Theme] end
        elseif type(Config.Theme) == "table" then
            local t = Config.Theme
            local function toC3(v)
                if type(v) == "table" then return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
                elseif type(v) == "userdata" then return v
                else return Color3.new(0,0,0) end
            end
            local customTheme = {}
            for k, v in pairs(CurrentTheme) do customTheme[k] = v end
            if t.Main then customTheme.Main = toC3(t.Main) end
            if t.Top then customTheme.Top = toC3(t.Top) end
            if t.Text then customTheme.Text = toC3(t.Text) end
            if t.Accent then customTheme.Accent = toC3(t.Accent) end
            if t.Stroke then customTheme.Stroke = toC3(t.Stroke) end
            if t.SubText then customTheme.SubText = toC3(t.SubText) end
            if t.Element then customTheme.Element = toC3(t.Element) end
            if t.Hover then customTheme.Hover = toC3(t.Hover) end
            if t.ShineEnabled ~= nil then customTheme.ShineEnabled = t.ShineEnabled end
            if t.Shine then customTheme.Shine = t.Shine end
            if t.StrokeShine ~= nil then customTheme.StrokeShine = t.StrokeShine end
            if t.StrokeDark then customTheme.StrokeDark = toC3(t.StrokeDark) end
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
    local FINAL_HEIGHT = 320

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    local shadowStrokes = {}
    for _, thick in ipairs({6, 5, 4, 3}) do
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = thick
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Transparency = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = MainFrame
        table.insert(shadowStrokes, stroke)
    end

    local function setShadowVisible(visible, instant)
        local targetTrans = visible and 0.9 or 1
        for _, stroke in ipairs(shadowStrokes) do
            if instant then stroke.Transparency = targetTrans
            else Tween(stroke, {Transparency = targetTrans}, 0.3) end
        end
    end

    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "FluentBG"
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ZIndex = 0
    bgImage.Parent = MainFrame
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)
    if SceneId then
        if type(SceneId) == "number" or (type(SceneId) == "string" and tonumber(SceneId)) then
            bgImage.Image = "rbxassetid://"..tostring(SceneId)
        else
            bgImage.Image = tostring(SceneId)
        end
    else
        bgImage.Image = ""
        bgImage.Visible = false
    end

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Name = "FengBgGradient"
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CurrentTheme.Main),
        ColorSequenceKeypoint.new(0.5, CurrentTheme.Top),
        ColorSequenceKeypoint.new(1, CurrentTheme.Main)
    })
    bgGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    bgGradient.Parent = MainFrame

    setShadowVisible(false, true)

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
    local isResizing = false
    local resizeStart = Vector2.new(0, 0)
    local startSize = UDim2.new(0, 0, 0, 0)
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

    local LeftMenuFrame = Instance.new("Frame")
    LeftMenuFrame.Size = UDim2.new(0, 175, 1, 0)
    LeftMenuFrame.BackgroundTransparency = 1
    LeftMenuFrame.Parent = MainFrame

    local HeadFrame = Instance.new("Frame")
    HeadFrame.Size = UDim2.new(1, 0, 0, 50)
    HeadFrame.BackgroundTransparency = 1
    HeadFrame.Parent = LeftMenuFrame

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Size = UDim2.new(0, 35, 0, 35)
    LogoImage.Position = UDim2.new(0, 10, 0.5, -17.5)
    LogoImage.BackgroundTransparency = 1
    LogoImage.Image = IconAsset or "rbxassetid://78229538488090"
    LogoImage.Parent = HeadFrame
    AddToRegistry(LogoImage, "ImageColor3", "Text")
    Instance.new("UICorner", LogoImage).CornerRadius = UDim.new(0, 7)

    local WindowName = Instance.new("TextLabel")
    WindowName.Size = UDim2.new(1, -65, 0, 25)
    WindowName.Position = UDim2.new(0, 55, 0, 4)
    WindowName.BackgroundTransparency = 1
    WindowName.Font = Enum.Font.GothamBold
    WindowName.Text = Title
    WindowName.TextSize = 18
    WindowName.TextXAlignment = Enum.TextXAlignment.Left
    WindowName.Parent = HeadFrame
    AddToRegistry(WindowName, "TextColor3", "Text")

    local WindowContent = Instance.new("TextLabel")
    WindowContent.Size = UDim2.new(1, -65, 0, 15)
    WindowContent.Position = UDim2.new(0, 55, 0, 25)
    WindowContent.BackgroundTransparency = 1
    WindowContent.Font = Enum.Font.GothamMedium
    WindowContent.Text = Subtitle or ""
    WindowContent.TextSize = 9
    WindowContent.TextTransparency = 0.65
    WindowContent.TextXAlignment = Enum.TextXAlignment.Left
    WindowContent.Parent = HeadFrame
    AddToRegistry(WindowContent, "TextColor3", "SubText")

    local LineFrame = Instance.new("Frame")
    LineFrame.Size = UDim2.new(1, -10, 0, 1)
    LineFrame.Position = UDim2.new(0.5, 0, 1, 0)
    LineFrame.AnchorPoint = Vector2.new(0.5, 1)
    LineFrame.BackgroundTransparency = 0.65
    LineFrame.BorderSizePixel = 0
    LineFrame.Parent = HeadFrame
    AddToRegistry(LineFrame, "BackgroundColor3", "Stroke")

    local LeftScrollingFrame = Instance.new("ScrollingFrame")
    LeftScrollingFrame.Size = UDim2.new(1, -10, 1, -100)
    LeftScrollingFrame.Position = UDim2.new(0.5, 0, 0, 50)
    LeftScrollingFrame.AnchorPoint = Vector2.new(0.5, 0)
    LeftScrollingFrame.BackgroundTransparency = 1
    LeftScrollingFrame.ScrollBarThickness = 0
    LeftScrollingFrame.Parent = LeftMenuFrame
    local TabList = Instance.new("UIListLayout")
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 0)
    TabList.Parent = LeftScrollingFrame
    local function updateTabCanvas()
        LeftScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
    end
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
    task.spawn(updateTabCanvas)

    local BottomFrame = Instance.new("Frame")
    BottomFrame.Size = UDim2.new(1, 0, 0, 50)
    BottomFrame.Position = UDim2.new(0, 0, 1, 0)
    BottomFrame.AnchorPoint = Vector2.new(0, 1)
    BottomFrame.BackgroundTransparency = 1
    BottomFrame.Parent = LeftMenuFrame

    local AccountProfile = Instance.new("ImageLabel")
    AccountProfile.Size = UDim2.new(0, 35, 0, 35)
    AccountProfile.Position = UDim2.new(0, 10, 0.5, -17.5)
    AccountProfile.BackgroundTransparency = 1
    AccountProfile.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    AccountProfile.Parent = BottomFrame
    AddToRegistry(AccountProfile, "ImageColor3", "Text")
    Instance.new("UICorner", AccountProfile).CornerRadius = UDim.new(1, 0)

    local AccountName = Instance.new("TextLabel")
    AccountName.Size = UDim2.new(0, 120, 0, 25)
    AccountName.Position = UDim2.new(0, 55, 0, 5)
    AccountName.BackgroundTransparency = 1
    AccountName.Font = Enum.Font.GothamBold
    AccountName.Text = LocalPlayer.DisplayName
    AccountName.TextSize = 14
    AccountName.TextXAlignment = Enum.TextXAlignment.Left
    AccountName.Parent = BottomFrame
    AddToRegistry(AccountName, "TextColor3", "Text")

    local ExpireLabel = Instance.new("TextLabel")
    ExpireLabel.Size = UDim2.new(0, 120, 0, 15)
    ExpireLabel.Position = UDim2.new(0, 55, 0, 25)
    ExpireLabel.BackgroundTransparency = 1
    ExpireLabel.Font = Enum.Font.GothamMedium
    ExpireLabel.Text = "never"
    ExpireLabel.TextSize = 10
    ExpireLabel.TextTransparency = 0.65
    ExpireLabel.TextXAlignment = Enum.TextXAlignment.Left
    ExpireLabel.Parent = BottomFrame
    AddToRegistry(ExpireLabel, "TextColor3", "SubText")

    local UserSettingButton = Instance.new("ImageLabel")
    UserSettingButton.Size = UDim2.new(0, 25, 0, 25)
    UserSettingButton.Position = UDim2.new(1, -7, 0.5, -12.5)
    UserSettingButton.AnchorPoint = Vector2.new(1, 0.5)
    UserSettingButton.BackgroundTransparency = 1
    UserSettingButton.Image = "rbxassetid://134724289526879"
    UserSettingButton.ImageTransparency = 0.5
    UserSettingButton.Parent = BottomFrame
    AddToRegistry(UserSettingButton, "ImageColor3", "Text")

    local RightMenuFrame = Instance.new("Frame")
    RightMenuFrame.Size = UDim2.new(1, -176, 1, 0)
    RightMenuFrame.Position = UDim2.new(0, 176, 0, 0)
    RightMenuFrame.BackgroundTransparency = 0.6
    RightMenuFrame.ClipsDescendants = true
    RightMenuFrame.Parent = MainFrame
    Instance.new("UICorner", RightMenuFrame).CornerRadius = UDim.new(0, 13)
    AddToRegistry(RightMenuFrame, "BackgroundColor3", "Main")

    local RightStroke = Instance.new("UIStroke")
    RightStroke.Thickness = 1
    RightStroke.Transparency = 0.65
    RightStroke.Parent = RightMenuFrame
    AddToRegistry(RightStroke, "Color", "Stroke")

    local RightHeader = Instance.new("Frame")
    RightHeader.Size = UDim2.new(1, 0, 0, 50)
    RightHeader.BackgroundTransparency = 1
    RightHeader.Parent = RightMenuFrame

    local LineFrame_3 = Instance.new("Frame")
    LineFrame_3.Size = UDim2.new(1, -10, 0, 1)
    LineFrame_3.Position = UDim2.new(0.5, 0, 1, 0)
    LineFrame_3.AnchorPoint = Vector2.new(0.5, 1)
    LineFrame_3.BackgroundTransparency = 0.65
    LineFrame_3.BorderSizePixel = 0
    LineFrame_3.Parent = RightHeader
    AddToRegistry(LineFrame_3, "BackgroundColor3", "Stroke")

    local resizerVisible = false
    local ButtonGroup = Instance.new("Frame")
    ButtonGroup.Name = "WindowButtons"
    ButtonGroup.Size = UDim2.new(0, 180, 1, 0)
    ButtonGroup.Position = UDim2.new(1, -190, 0, 0)
    ButtonGroup.BackgroundTransparency = 1
    ButtonGroup.Parent = RightHeader

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
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 0, 0, 0)
        accent.AnchorPoint = Vector2.new(0.5, 0.5)
        accent.Position = UDim2.new(0.5, 0, 0.5, 0)
        accent.BackgroundTransparency = 1
        accent.ZIndex = 2
        accent.BackgroundColor3 = CurrentTheme.Accent
        accent.Parent = btn
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 7)

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
                local p = content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                Tween(content, {[p] = 0}, 0.2)
            end
            Tween(accent, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.2}, 0.2)
            if content then
                local p = content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                Tween(content, {[p] = 0.3}, 0.2)
            end
            Tween(accent, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
        end)
        btn.MouseButton1Click:Connect(callback)
        table.insert(ThemeListeners, function()
            btn.BackgroundColor3 = CurrentTheme.Element or CurrentTheme.Top
            accent.BackgroundColor3 = CurrentTheme.Accent
            if content and content:IsA("ImageLabel") then content.ImageColor3 = CurrentTheme.Text
            elseif content and content:IsA("TextLabel") then content.TextColor3 = CurrentTheme.Text end
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

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 1, -50)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ClipsDescendants = true
    TabContainer.Parent = RightMenuFrame

    local PageContainer = Instance.new("ScrollingFrame")
    PageContainer.Size = UDim2.new(1, 0, 1, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.ScrollBarThickness = 0
    PageContainer.ScrollingEnabled = true
    PageContainer.Parent = TabContainer

    local PageContent = Instance.new("Frame")
    PageContent.Size = UDim2.new(1, 0, 0, 0)
    PageContent.AutomaticSize = Enum.AutomaticSize.Y
    PageContent.BackgroundTransparency = 1
    PageContent.Parent = PageContainer
    local PageList = Instance.new("UIListLayout")
    PageList.Padding = UDim.new(0, 10)
    PageList.SortOrder = Enum.SortOrder.LayoutOrder
    PageList.Parent = PageContent
    local function updatePageCanvas()
        PageContainer.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
    end
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePageCanvas)
    task.spawn(updatePageCanvas)

    local dragToggle = false
    local dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        MainFrame.Position = position
    end
    HeadFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            local input_end
            input_end = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                    input_end:Disconnect()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    local function AnimateWindowIn()
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, FINAL_WIDTH, 0, FINAL_HEIGHT)
        }):Play()
        setShadowVisible(true, false)
    end
    local function onWindowVisibilityChanged()
        if MainFrame.Visible then setShadowVisible(true, false)
        else setShadowVisible(false, false) end
    end
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(onWindowVisibilityChanged)
    task.delay(0.1, AnimateWindowIn)

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
    Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0, 8)
    OpenButton.MouseButton1Click:Connect(function()
        if MainFrame.Visible then
            MainFrame.Visible = false
            OpenButton.Visible = true
        else
            MainFrame.Visible = true
            OpenButton.Visible = false
        end
    end)
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        OpenButton.Visible = not MainFrame.Visible
    end)
    OpenButton.Visible = false
    MainFrame.Visible = true

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    Window._currentCategory = nil
    function Window:Category(config)
        local name = type(config) == "table" and config.Name or config
        local collapsible = type(config) == "table" and config.Collapsible or false
        local opened = true
        if type(config) == "table" and config.Opened ~= nil then opened = config.Opened end
        local categoryFrame = Instance.new("Frame")
        categoryFrame.Size = UDim2.new(1, 0, 0, 0)
        categoryFrame.AutomaticSize = Enum.AutomaticSize.Y
        categoryFrame.BackgroundTransparency = 1
        categoryFrame.Parent = LeftScrollingFrame
        local catLayout = Instance.new("UIListLayout")
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
        content.ClipsDescendants = true
        content.Visible = true
        content.Parent = categoryFrame
        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 4)
        contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentList.Parent = content

        local currentTween = nil
        local function getContentHeight() return contentList.AbsoluteContentSize.Y or 0 end
        local function setContentHeight(targetHeight, animate)
            targetHeight = math.max(0, targetHeight)
            local currentHeight = content.Size.Y.Offset
            if animate and currentHeight ~= targetHeight then
                if currentTween then currentTween:Cancel(); currentTween = nil end
                currentTween = TweenService:Create(content, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)})
                currentTween:Play()
                currentTween.Completed:Connect(function() currentTween = nil; task.spawn(updateTabCanvas) end)
            else
                content.Size = UDim2.new(1, 0, 0, targetHeight)
                task.spawn(updateTabCanvas)
            end
        end
        local function toggleCategory()
            if not collapsible then return end
            opened = not opened
            Tween(arrow, {Rotation = opened and 0 or 180}, 0.25)
            local targetHeight = opened and getContentHeight() or 0
            setContentHeight(targetHeight, true)
        end
        header.MouseButton1Click:Connect(toggleCategory)
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if opened then
                local h = getContentHeight()
                if math.abs(h - content.Size.Y.Offset) > 0.5 then setContentHeight(h, false) end
            end
        end)
        task.spawn(function()
            task.wait()
            local h = getContentHeight()
            local initialHeight = opened and h or 0
            content.Size = UDim2.new(1, 0, 0, initialHeight)
            updateTabCanvas()
        end)
        Window._currentCategory = {frame = categoryFrame, content = content, contentList = contentList, header = header, label = header, arrow = arrow, collapsible = collapsible, opened = opened, toggle = toggleCategory}
        return Window._currentCategory
    end

    Window._activeTab = nil
    Window._tabs = {}
    function Window:Tab(name, icon)
        local parentContainer = LeftScrollingFrame
        local parentList = TabList
        if Window._currentCategory then
            parentContainer = Window._currentCategory.content
            parentList = Window._currentCategory.contentList
        end

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -7, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.BackgroundColor3 = CurrentTheme.Top
        TabBtn.Text = ""
        TabBtn.Parent = parentContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        local glowFrame = Instance.new("Frame")
        glowFrame.Name = "GlowBackground"
        glowFrame.Size = UDim2.new(1, 0, 1, 0)
        glowFrame.BackgroundColor3 = CurrentTheme.Accent
        glowFrame.BackgroundTransparency = 1
        glowFrame.Parent = TabBtn
        Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 10)
        local glowGrad = Instance.new("UIGradient")
        glowGrad.Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent)
        glowGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1)})
        glowGrad.Parent = glowFrame

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn
        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
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
            if tonumber(icon) then TabIcon.Image = "rbxassetid://"..icon else TabIcon.Image = icon end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            Instance.new("UICorner", TabIcon).CornerRadius = UDim.new(0, 8)
        end

        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, -40, 0, 15)
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
        Instance.new("UICorner", Page).CornerRadius = UDim.new(0, 16)
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

        local state = {isActive = false, btn = TabBtn, page = Page, textLabel = TabText, glow = glowFrame}

        TabBtn.MouseButton1Click:Connect(function()
            if Window._activeTab == state then return end
            for _, s in ipairs(Window._tabs) do
                s.btn.BackgroundTransparency = 1
                s.isActive = false
                s.glow.BackgroundTransparency = 1
                if s.textLabel then Tween(s.textLabel, {TextTransparency = 0.3}, 0.2) end
            end
            TabBtn.BackgroundTransparency = 1
            state.isActive = true
            state.glow.BackgroundTransparency = 0
            Tween(TabText, {TextTransparency = 0}, 0.2)
            if Window._activeTab then Window._activeTab.page.Visible = false end
            Page.Visible = true
            Tween(Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
            Window._activeTab = state
        end)

        if not Window._activeTab then
            TabBtn.BackgroundTransparency = 1
            state.isActive = true
            state.glow.BackgroundTransparency = 0
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
                    if grad then grad.Color = ColorSequence.new(CurrentTheme.Accent, CurrentTheme.Accent) end
                end
                s.btn.BackgroundTransparency = 1
            end
        end)

        local builder = createSectionBuilder(PageContent, PageContent, 330, 1, Window)
        return builder
    end

    function Window:TabDivider()
        local parentContainer = LeftScrollingFrame
        if Window._currentCategory then parentContainer = Window._currentCategory.content end
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -20, 0, 1)
        line.Position = UDim2.new(0, 10, 0, 0)
        line.BackgroundColor3 = CurrentTheme.Stroke
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = parentContainer
        AddToRegistry(line, "BackgroundColor3", "Stroke")
    end

    function Window:Dialog(Config)
        Config = Config or {}
        local Dialog = {Closed = false}
        local Overlay = Instance.new("Frame")
        local Panel = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local UIStroke = Instance.new("UIStroke")
        local Title = Instance.new("TextLabel")
        local Content = Instance.new("TextLabel")
        local Divider = Instance.new("Frame")
        local ButtonHolder = Instance.new("Frame")
        local ButtonLayout = Instance.new("UIListLayout")

        Overlay.Name = "DialogOverlay"
        Overlay.Parent = MainFrame
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 1
        Overlay.BorderSizePixel = 0
        Overlay.Size = UDim2.fromScale(1, 1)
        Overlay.ZIndex = 180
        Overlay.Active = true

        Panel.Name = "DialogPanel"
        Panel.Parent = Overlay
        Panel.AnchorPoint = Vector2.new(0.5, 0.5)
        Panel.Position = UDim2.fromScale(0.5, 0.5)
        Panel.BackgroundColor3 = Color3.fromRGB(13, 17, 22)
        Panel.BackgroundTransparency = 1
        Panel.BorderSizePixel = 0
        Panel.ClipsDescendants = true
        Panel.Size = UDim2.new(0, 365, 0, 188)
        Panel.ZIndex = 181
        UICorner.CornerRadius = UDim.new(0, 12)
        UICorner.Parent = Panel
        UIStroke.Transparency = 1
        UIStroke.Color = Color3.fromRGB(45, 48, 58)
        UIStroke.Parent = Panel

        Title.Parent = Panel
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 18, 0, 18)
        Title.Size = UDim2.new(1, -36, 0, 21)
        Title.ZIndex = 183
        Title.Font = Enum.Font.GothamBold
        Title.Text = Config.Title or "Dialog"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        AddToRegistry(Title, "TextColor3", "Text")

        Content.Parent = Panel
        Content.BackgroundTransparency = 1
        Content.Position = UDim2.new(0, 18, 0, 48)
        Content.Size = UDim2.new(1, -36, 0, 76)
        Content.ZIndex = 183
        Content.Font = Enum.Font.GothamMedium
        Content.Text = Config.Content or ""
        Content.TextColor3 = Color3.fromRGB(255, 255, 255)
        Content.TextTransparency = 1
        Content.TextWrapped = true
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.TextYAlignment = Enum.TextYAlignment.Top
        AddToRegistry(Content, "TextColor3", "Text")

        Divider.Parent = Panel
        Divider.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
        Divider.BackgroundTransparency = 1
        Divider.Position = UDim2.new(0, 14, 1, -54)
        Divider.Size = UDim2.new(1, -28, 0, 1)
        Divider.ZIndex = 182
        AddToRegistry(Divider, "BackgroundColor3", "Stroke")

        ButtonHolder.Parent = Panel
        ButtonHolder.AnchorPoint = Vector2.new(1, 1)
        ButtonHolder.BackgroundTransparency = 1
        ButtonHolder.Position = UDim2.new(1, -16, 1, -14)
        ButtonHolder.Size = UDim2.new(1, -32, 0, 32)
        ButtonHolder.ZIndex = 182
        ButtonLayout.Parent = ButtonHolder
        ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ButtonLayout.Padding = UDim.new(0, 8)

        function Dialog:Close(Result)
            if Dialog.Closed then return Result end
            Dialog.Closed = true
            Tween(Overlay, {BackgroundTransparency = 1}, 0.15)
            Tween(Panel, {BackgroundTransparency = 1, Size = UDim2.new(0, 365, 0, 188)}, 0.15)
            task.delay(0.2, function() Overlay:Destroy() end)
            pcall(Config.Callback, Result)
            return Result
        end

        local function AddDialogButton(Text, Primary, Callback)
            local Button = Instance.new("Frame")
            Button.Parent = ButtonHolder
            Button.BackgroundColor3 = Primary and CurrentTheme.Accent or Color3.fromRGB(26, 28, 36)
            Button.BackgroundTransparency = 1
            Button.ClipsDescendants = true
            Button.Size = UDim2.new(0, math.max(78, TextService:GetTextSize(Text, 12, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge)).X + 32), 0, 32)
            Button.ZIndex = 183
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 7)
            local Stroke = Instance.new("UIStroke")
            Stroke.Transparency = 1
            Stroke.Color = Primary and CurrentTheme.Accent or Color3.fromRGB(45, 48, 58)
            Stroke.Parent = Button
            local Label = Instance.new("TextLabel")
            Label.Parent = Button
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.fromScale(1, 1)
            Label.ZIndex = 184
            Label.Font = Primary and Enum.Font.GothamBold or Enum.Font.GothamMedium
            Label.Text = Text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.TextTransparency = 1
            AddToRegistry(Label, "TextColor3", "Text")
            local Input = Instance.new("TextButton")
            Input.Size = UDim2.fromScale(1, 1)
            Input.BackgroundTransparency = 1
            Input.Text = ""
            Input.Parent = Button
            Input.MouseButton1Click:Connect(function()
                local Result = Callback and Callback() or Text
                Dialog:Close(Result)
            end)
            Input.MouseEnter:Connect(function() Tween(Button, {BackgroundTransparency = Primary and 0 or 0.08}, 0.15) end)
            Input.MouseLeave:Connect(function() Tween(Button, {BackgroundTransparency = Primary and 0.1 or 0.25}, 0.15) end)
            Tween(Button, {BackgroundTransparency = Primary and 0.1 or 0.25}, 0.1)
            Tween(Stroke, {Transparency = Primary and 1 or 0.65}, 0.1)
            Tween(Label, {TextTransparency = 0}, 0.1)
        end

        for _, BtnConfig in ipairs(Config.Buttons or {{Text = "OK", Primary = true}}) do
            AddDialogButton(BtnConfig.Text, BtnConfig.Primary, BtnConfig.Callback)
        end

        Tween(Overlay, {BackgroundTransparency = 0.28}, 0.25)
        Tween(Panel, {BackgroundTransparency = 0.025, Size = UDim2.new(0, 392, 0, 200)}, 0.25)
        Tween(UIStroke, {Transparency = 0.65}, 0.25)
        Tween(Title, {TextTransparency = 0}, 0.25)
        Tween(Content, {TextTransparency = 0.25}, 0.25)
        Tween(Divider, {BackgroundTransparency = 0.72}, 0.25)
        return Dialog
    end

    function Window:Notification(titleText, descText, notifType, duration) end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end
    function Window:SetSubtitle(newSubtitle) WindowContent.Text = newSubtitle or "" end

    return Window
end

-- ========== 自定义光标 ==========
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
    cursorRoot.Size = UDim2.new(0, 20, 0, 20)
    cursorRoot.ZIndex = 2147483647
    cursorRoot.Visible = false
    cursorRoot.Parent = cursorScreen

    local img = Instance.new("ImageLabel")
    img.Name = "CursorImage"
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Image = "rbxassetid://132511743665753"
    img.ImageColor3 = Color3.fromRGB(90, 165, 255)
    img.ScaleType = Enum.ScaleType.Fit
    img.Rotation = -90
    img.Parent = cursorRoot

    local cursorConn = RunService.RenderStepped:Connect(function()
        if not cursorRoot.Visible then return end
        local loc = UserInputService:GetMouseLocation()
        cursorRoot.Position = UDim2.new(0, loc.X - 2, 0, loc.Y - 2)
    end)

    Fenglib._cursorObjects = { Screen = cursorScreen, Root = cursorRoot, Image = img, Connection = cursorConn, Enabled = false }

    function Fenglib:SetCustomCursor(enabled)
        enabled = enabled == true
        if Fenglib._cursorObjects then
            Fenglib._cursorObjects.Root.Visible = enabled
            Fenglib._cursorObjects.Screen.Enabled = enabled
            Fenglib._cursorObjects.Enabled = enabled
            pcall(function() UserInputService.MouseIconEnabled = not enabled end)
        end
    end

    function Fenglib:ToggleCustomCursor()
        local current = Fenglib._cursorObjects and Fenglib._cursorObjects.Enabled or false
        Fenglib:SetCustomCursor(not current)
    end

    function Fenglib:CleanupCursor()
        if Fenglib._cursorObjects then
            safeDisconnect(Fenglib._cursorObjects.Connection)
            if Fenglib._cursorObjects.Screen then Fenglib._cursorObjects.Screen:Destroy() end
            Fenglib._cursorObjects = nil
        end
    end
end

return Fenglib