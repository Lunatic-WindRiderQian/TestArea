--[[
    FengYu-Bento (miUI 框架 – 完整版)
    ...
    所有 Section 内控件已换成 miUI 风格（Row 布局：左 Label + 右控件）
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
local function AddToRegistry(obj, prop, key)
    local val = CurrentTheme[key] or Themes.Dark[key] or Color3.new(1,1,1)
    table.insert(Registry, {Object = obj, Property = prop, Type = key})
    obj[prop] = val
end
local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end
local function startNeonFlowEffect(obj, prop, speed)
    speed = speed or 0.008
    local hue = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then safeDisconnect(conn); return end
        hue = (hue + speed) % 1
        obj[prop] = Color3.new(math.sin(hue*3+0)*0.3+0.7, math.sin(hue*3+2)*0.1, math.sin(hue*3+4)*0.1)
    end)
    return conn
end
local function createPulseGlow(obj)
    local running = true
    local conn = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent or not running then safeDisconnect(conn); return end
        local a = 0.5 + math.sin(tick()*3)*0.3
        if obj:IsA("UIStroke") then obj.Transparency = a
        elseif obj:IsA("Frame") or obj:IsA("TextButton") then obj.BackgroundTransparency = a end
    end)
    return { Disconnect = function() running=false; safeDisconnect(conn) end }
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
    if not ok or type(data)~="table" then return false end
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
            pcall(function() local ok3,enc = pcall(hs.JSONEncode, hs, map); if ok3 then writefile(mapPath, enc) end end)
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
    if ext=="mp4" or ext=="mov" then ext="webm" end
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
    local path = dir.."/"..fname
    local body = nil
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
            pcall(function() local ok3,enc = pcall(hs.JSONEncode, hs, map); if ok3 then writefile(mapPath, enc) end end)
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
            pcall(function() local ok3,enc = pcall(hs.JSONEncode, hs, map); if ok3 then writefile(mapPath, enc) end end)
            return a
        end
    end
    return ""
end

-- ========== 锁覆盖层（TextButton 拦截所有点击） ==========
local function createLockOverlay(parent, defaultTitle)
    local cornerRadius = UDim.new(0, 6)
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
    lockIcon.Size = UDim2.new(0, 16, 0, 16)
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
    lockLabel.TextSize = 13
    lockLabel.AutomaticSize = Enum.AutomaticSize.X
    lockLabel.Parent = container
    return lockFrame, lockLabel
end

-- ========== 完整元素构建器（miUI 风格） ==========
local function createSectionBuilder(parent, contentContainer, elementWidth, windowCount, window)
    local win = window
    local padding = parent:FindFirstChild("SectionPadding")
    if not padding then
        padding = Instance.new("UIPadding")
        padding.Name = "SectionPadding"
        padding.PaddingLeft = UDim.new(0.04,0)
        padding.Parent = parent
    end

    -- ========== miUI 风格辅助函数 ==========
    local ROW_H = 30
    local PAD_LEFT = 11
    local CTRL_RIGHT = -11

    local function makeRow(parent, height, locked)
        local row = Instance.new("Frame")
        row.Name = "Row"
        row.Size = UDim2.new(1, 0, 0, height or ROW_H)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.ClipsDescendants = false
        row.Parent = parent
        local lockFrame, lockLabel = createLockOverlay(row, "Locked")
        lockFrame.Visible = locked == true
        return row, lockFrame, lockLabel
    end

    local function makeRowLabel(row, text, rightOffset)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -(rightOffset or 30) - 20, 0, 15)
        lbl.Position = UDim2.new(0, PAD_LEFT, 0, 7)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Text = text or ""
        lbl.Parent = row
        AddToRegistry(lbl, "TextColor3", "Text")
        return lbl
    end

    local function makeCtrlBacking(row, width, height, posX)
        local ctrl = Instance.new("Frame")
        ctrl.Size = UDim2.new(0, width, 0, height)
        ctrl.Position = UDim2.new(1, posX, 0.5, -height/2)
        ctrl.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        ctrl.BorderSizePixel = 0
        ctrl.Parent = row
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = ctrl
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(45, 48, 58)
        stroke.Transparency = 0.65
        stroke.Parent = ctrl
        AddToRegistry(ctrl, "BackgroundColor3", "Main")
        AddToRegistry(stroke, "Color", "Stroke")
        return ctrl, corner, stroke
    end

    local child = {}

    -- ========== Button（miUI 风格：整行点击） ==========
    child.Button = function(_, config)
        local btnText = config.Name or config.Text or ""
        local callback = config.Callback or function() end
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, 30, locked)
        lockLabel.Text = lockedTitle

        local bg = Instance.new("Frame")
        bg.Name = "BG"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel = 0
        bg.Parent = row
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 8)
        bgCorner.Parent = bg

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.Position = UDim2.new(0, PAD_LEFT, 0.5, -8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://10709791437"
        icon.ImageColor3 = CurrentTheme.Accent
        icon.ImageTransparency = 0.35
        icon.Parent = row
        AddToRegistry(icon, "ImageColor3", "Accent")

        local lbl = Instance.new("TextLabel")
        lbl.Text = btnText
        lbl.Size = UDim2.new(1, -34, 1, 0)
        lbl.Position = UDim2.new(0, 34, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row
        AddToRegistry(lbl, "TextColor3", "Text")

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = row

        clickBtn.MouseEnter:Connect(function()
            if locked then return end
            Tween(bg, {BackgroundTransparency = 0.45}, 0.15)
        end)
        clickBtn.MouseLeave:Connect(function()
            Tween(bg, {BackgroundTransparency = 1}, 0.15)
        end)
        clickBtn.MouseButton1Click:Connect(function()
            if locked then return end
            callback()
        end)

        local self = {}
        function self.UpdateText(t) lbl.Text = t end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Toggle（miUI 小开关） ==========
    child.Toggle = function(_, config)
        local toggleText = config.Name or ""
        local Enabled = config.Value or false
        local callback = config.Callback or function() end
        local controlId = toggleText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle
        local lbl = makeRowLabel(row, toggleText, 56)

        local switch = Instance.new("Frame")
        switch.Name = "Switch"
        switch.Size = UDim2.new(0, 30, 0, 18)
        switch.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)
        switch.BorderSizePixel = 0
        switch.Parent = row
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
        local swStroke = Instance.new("UIStroke")
        swStroke.Thickness = 1
        swStroke.Color = Color3.fromRGB(45, 48, 58)
        swStroke.Transparency = Enabled and 1 or 0.65
        swStroke.Parent = switch

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = Enabled and UDim2.new(1, -17, 0.5, -8) or UDim2.new(0, 1, 0.5, -8)
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.BackgroundTransparency = Enabled and 0 or 0.5
        dot.Parent = switch
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function updateUI(animate)
            if animate then
                Tween(switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)}, 0.15)
                Tween(swStroke, {Transparency = Enabled and 1 or 0.65}, 0.15)
                Tween(dot, {Position = Enabled and UDim2.new(1, -17, 0.5, -8) or UDim2.new(0, 1, 0.5, -8), BackgroundTransparency = Enabled and 0 or 0.5}, 0.15)
            else
                switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)
                swStroke.Transparency = Enabled and 1 or 0.65
                dot.Position = Enabled and UDim2.new(1, -17, 0.5, -8) or UDim2.new(0, 1, 0.5, -8)
                dot.BackgroundTransparency = Enabled and 0 or 0.5
            end
        end

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = row
        clickBtn.MouseButton1Click:Connect(function()
            if locked then return end
            Enabled = not Enabled
            updateUI(true)
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = Enabled end
            pcall(callback, Enabled)
        end)

        ConfigObjects[controlId] = {Type="Toggle", Value=Enabled, Set=function(v)
            Enabled = not (not v)
            updateUI(true)
            callback(Enabled)
        end}

        local self = {}
        function self.GetValue() return Enabled end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Checkbox（miUI 小方块） ==========
    child.Checkbox = function(_, config)
        local title = config.Name or ""
        local default = config.Default or false
        local callback = config.Callback or function() end
        local controlId = title.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle
        local lbl = makeRowLabel(row, title, 30)

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 18, 0, 18)
        box.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        box.BackgroundColor3 = default and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)
        box.BorderSizePixel = 0
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 1
        boxStroke.Color = default and CurrentTheme.Accent or Color3.fromRGB(45, 48, 58)
        boxStroke.Transparency = default and 1 or 0.65
        boxStroke.Parent = box

        local check = Instance.new("ImageLabel")
        check.Size = UDim2.new(0, 12, 0, 12)
        check.Position = UDim2.new(0.5, -6, 0.5, -6)
        check.BackgroundTransparency = 1
        check.Image = "rbxassetid://10709790644"
        check.ImageColor3 = Color3.new(1, 1, 1)
        check.ImageTransparency = default and 0 or 1
        check.Parent = box

        local State = default

        local function updateUI(animate)
            if animate then
                Tween(box, {BackgroundColor3 = State and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)}, 0.15)
                Tween(boxStroke, {Transparency = State and 1 or 0.65}, 0.15)
                Tween(check, {ImageTransparency = State and 0 or 1}, 0.15)
            else
                box.BackgroundColor3 = State and CurrentTheme.Accent or Color3.fromRGB(10, 13, 21)
                boxStroke.Transparency = State and 1 or 0.65
                check.ImageTransparency = State and 0 or 1
            end
        end

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = row
        clickBtn.MouseButton1Click:Connect(function()
            if locked then return end
            State = not State
            updateUI(true)
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = State end
            pcall(callback, State)
        end)

        ConfigObjects[controlId] = {Type="Checkbox", Value=State, Set=function(v)
            State = not (not v)
            updateUI(true)
            callback(State)
        end}

        local self = {}
        function self.GetValue() return State end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Slider（miUI 紧凑） ==========
    child.Slider = function(_, config)
        local sliderText = config.Name or ""
        local valueTable = config.Value or {}
        local min = tonumber(valueTable.Min) or 0
        local max = tonumber(valueTable.Max) or 100
        local default = tonumber(valueTable.Default) or min
        local callback = config.Callback or function() end
        local Rounding = config.Rounding or 0
        local Val = math.clamp(default, min, max)
        local controlId = sliderText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle
        local lbl = makeRowLabel(row, sliderText, 160)

        -- 数值输入框
        local numBox = Instance.new("TextBox")
        numBox.Size = UDim2.new(0, 52, 0, 18)
        numBox.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        numBox.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        numBox.BackgroundTransparency = 0.1
        numBox.Font = Enum.Font.GothamMedium
        numBox.TextSize = 11
        numBox.TextXAlignment = Enum.TextXAlignment.Center
        numBox.ClearTextOnFocus = false
        numBox.Text = tostring(Val)
        numBox.Parent = row
        Instance.new("UICorner", numBox).CornerRadius = UDim.new(0, 4)
        local numStroke = Instance.new("UIStroke")
        numStroke.Thickness = 1
        numStroke.Color = Color3.fromRGB(45, 48, 58)
        numStroke.Transparency = 0.65
        numStroke.Parent = numBox
        AddToRegistry(numBox, "TextColor3", "Text")

        -- 滑动条（容器）
        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 120, 0, 18)
        track.Position = UDim2.new(1, -(52 + 4 + 120 + 11), 0.5, -9)
        track.BackgroundTransparency = 1
        track.Parent = row

        local rail = Instance.new("Frame")
        rail.Size = UDim2.new(1, 0, 0, 4)
        rail.Position = UDim2.new(0, 0, 0.5, -2)
        rail.BackgroundColor3 = Color3.fromRGB(30, 29, 36)
        rail.BorderSizePixel = 0
        rail.Parent = track
        Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)

        local initP = (max > min) and (Val - min) / (max - min) or 0
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(initP, 0, 1, 0)
        fill.BackgroundColor3 = CurrentTheme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = rail
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        AddToRegistry(fill, "BackgroundColor3", "Accent")

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(initP, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.Parent = rail
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local bar = Instance.new("TextButton")
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.BackgroundTransparency = 1
        bar.Text = ""
        bar.Parent = track

        local function roundTo(n, dec)
            local f = 10^dec
            return math.floor(n*f + 0.5)/f
        end

        local function updateVal(v)
            v = math.clamp(v, min, max)
            v = roundTo(v, Rounding)
            Val = v
            local p = (max > min) and (v - min) / (max - min) or 0
            Tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
            Tween(knob, {Position = UDim2.new(p, 0, 0.5, 0)}, 0.1)
            numBox.Text = tostring(v)
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = v end
            callback(v)
        end

        local dragging = false
        local function getValFromInput(input)
            local absX = track.AbsolutePosition.X
            local absW = track.AbsoluteSize.X
            local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
            return ratio * (max - min) + min
        end

        bar.InputBegan:Connect(function(input)
            if locked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateVal(getValFromInput(input))
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and not locked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateVal(getValFromInput(input))
            end
        end)
        numBox.FocusLost:Connect(function()
            if locked then return end
            local n = tonumber(numBox.Text)
            if n then updateVal(n) else numBox.Text = tostring(Val) end
        end)

        ConfigObjects[controlId] = {Type="Slider", Value=Val, Set=function(v)
            if not locked then updateVal(tonumber(v) or Val) end
        end}

        local self = {}
        function self.GetValue() return Val end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Dropdown（miUI 小按钮 + 浮层） ==========
    child.Dropdown = function(_, config)
        local dropText = config.Name or ""
        local options = config.Values or {}
        local selectedValue = config.Value
        local multi = config.Multi == true
        local callback = config.Callback or function() end
        local controlId = dropText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local selected = multi and {} or nil
        if multi then
            if type(selectedValue) == "table" then
                selected = {}
                for _, v in ipairs(selectedValue) do
                    if table.find(options, v) then table.insert(selected, v) end
                end
            end
        else
            selected = (selectedValue and table.find(options, selectedValue)) and selectedValue or (options[1] or "")
        end

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle
        local lbl = makeRowLabel(row, dropText, 110)

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 100, 0, 18)
        button.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        button.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        button.Parent = row
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Thickness = 1
        btnStroke.Color = Color3.fromRGB(45, 48, 58)
        btnStroke.Transparency = 0.65
        btnStroke.Parent = button

        local btnLabel = Instance.new("TextLabel")
        btnLabel.Size = UDim2.new(1, -24, 1, 0)
        btnLabel.Position = UDim2.new(0, 6, 0, 0)
        btnLabel.BackgroundTransparency = 1
        btnLabel.Font = Enum.Font.GothamMedium
        btnLabel.TextSize = 11
        btnLabel.TextXAlignment = Enum.TextXAlignment.Left
        btnLabel.TextTruncate = Enum.TextTruncate.AtEnd
        btnLabel.Parent = button
        AddToRegistry(btnLabel, "TextColor3", "Text")

        local arrowIcon = Instance.new("ImageLabel")
        arrowIcon.Size = UDim2.new(0, 12, 0, 12)
        arrowIcon.Position = UDim2.new(1, -16, 0.5, -6)
        arrowIcon.BackgroundTransparency = 1
        arrowIcon.Image = "rbxassetid://134243273101015"
        arrowIcon.ImageColor3 = CurrentTheme.Text
        arrowIcon.ImageTransparency = 0.35
        arrowIcon.Parent = button
        AddToRegistry(arrowIcon, "ImageColor3", "Text")

        local function updateLabel()
            if multi then
                if #selected == 0 then btnLabel.Text = "None" else btnLabel.Text = table.concat(selected, ", ") end
            else
                btnLabel.Text = tostring(selected or "None")
            end
        end
        updateLabel()

        -- 下拉浮层
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 100, 0, 0)
        popup.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
        popup.BorderSizePixel = 0
        popup.ClipsDescendants = true
        popup.Visible = false
        popup.ZIndex = 50
        popup.Parent = parent
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 6)
        local popupStroke = Instance.new("UIStroke")
        popupStroke.Thickness = 1
        popupStroke.Color = Color3.fromRGB(45, 48, 58)
        popupStroke.Transparency = 0.5
        popupStroke.Parent = popup

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = popup

        local optButtons = {}
        local dropped = false

        local function positionPopup()
            popup.Position = UDim2.new(0, button.AbsolutePosition.X, 0, button.AbsolutePosition.Y + button.AbsoluteSize.Y + 2)
            popup.Size = UDim2.new(0, 120, 0, 0)
        end

        local function rebuild()
            for _, c in ipairs(popup:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            optButtons = {}
            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, 0, 0, 22)
                ob.BackgroundTransparency = 1
                ob.Text = ""
                ob.AutoButtonColor = false
                ob.Parent = popup
                ob.ZIndex = 51

                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0, 10, 0, 10)
                dot.Position = UDim2.new(0, 8, 0.5, -5)
                dot.BackgroundColor3 = CurrentTheme.Accent
                dot.BackgroundTransparency = 1
                dot.Parent = ob
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

                local oLbl = Instance.new("TextLabel")
                oLbl.Size = UDim2.new(1, -26, 1, 0)
                oLbl.Position = UDim2.new(0, 22, 0, 0)
                oLbl.BackgroundTransparency = 1
                oLbl.Font = Enum.Font.GothamMedium
                oLbl.TextSize = 11
                oLbl.TextXAlignment = Enum.TextXAlignment.Left
                oLbl.TextTruncate = Enum.TextTruncate.AtEnd
                oLbl.Text = tostring(opt)
                oLbl.Parent = ob
                AddToRegistry(oLbl, "TextColor3", "Text")

                local isSel = multi and table.find(selected, opt) ~= nil or (not multi and selected == opt)
                dot.BackgroundTransparency = isSel and 0 or 1

                ob.MouseEnter:Connect(function()
                    Tween(ob, {BackgroundTransparency = 0.7}, 0.12)
                end)
                ob.MouseLeave:Connect(function()
                    Tween(ob, {BackgroundTransparency = 1}, 0.12)
                end)
                ob.MouseButton1Click:Connect(function()
                    if locked then return end
                    if multi then
                        local idx = table.find(selected, opt)
                        if idx then table.remove(selected, idx) else table.insert(selected, opt) end
                        dot.BackgroundTransparency = table.find(selected, opt) and 0 or 1
                        updateLabel()
                        if ConfigObjects[controlId] then ConfigObjects[controlId].Value = selected end
                        callback(selected)
                    else
                        selected = opt
                        for i, d in ipairs(optButtons) do
                            d.dot.BackgroundTransparency = d.value == opt and 0 or 1
                        end
                        updateLabel()
                        if ConfigObjects[controlId] then ConfigObjects[controlId].Value = selected end
                        callback(selected)
                        dropped = false
                        Tween(popup, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
                        task.wait(0.22)
                        popup.Visible = false
                    end
                end)

                table.insert(optButtons, {button = ob, dot = dot, value = opt})
            end
            if dropped then
                popup.Size = UDim2.new(0, 120, 0, #optButtons * 22)
            end
        end
        rebuild()

        button.MouseButton1Click:Connect(function()
            if locked then return end
            dropped = not dropped
            if dropped then
                positionPopup()
                popup.Visible = true
                Tween(popup, {Size = UDim2.new(0, 120, 0, #optButtons * 22)}, 0.25)
            else
                Tween(popup, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
                task.wait(0.22)
                popup.Visible = false
            end
        end)

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dropped and not locked then
                local mp = UserInputService:GetMouseLocation()
                local bp = button.AbsolutePosition
                local bs = button.AbsoluteSize
                local pp = popup.AbsolutePosition
                local ps = popup.AbsoluteSize
                local overBtn = mp.X >= bp.X and mp.X <= bp.X + bs.X and mp.Y >= bp.Y and mp.Y <= bp.Y + bs.Y
                local overPopup = mp.X >= pp.X and mp.X <= pp.X + ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y
                if not overBtn and not overPopup then
                    dropped = false
                    Tween(popup, {Size = UDim2.new(0, 120, 0, 0)}, 0.2)
                    task.wait(0.22)
                    popup.Visible = false
                end
            end
        end)

        ConfigObjects[controlId] = {
            Type = "Dropdown", Value = selected,
            Set = function(v)
                if locked then return end
                if multi then
                    if type(v) == "table" then
                        selected = {}
                        for _, x in ipairs(v) do if table.find(options, x) then table.insert(selected, x) end end
                    else selected = {} end
                else
                    selected = (v and table.find(options, v)) and v or (options[1] or "")
                end
                for _, d in ipairs(optButtons) do
                    local isSel = multi and table.find(selected, d.value) ~= nil or (not multi and selected == d.value)
                    d.dot.BackgroundTransparency = isSel and 0 or 1
                end
                updateLabel()
                callback(selected)
            end,
            Refresh = function(newOpts)
                if locked then return end
                options = newOpts or {}
                selected = multi and {} or (options[1] or "")
                rebuild()
                updateLabel()
            end
        }

        local self = {}
        function self.GetValue() return selected end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.Refresh(o) if not locked then ConfigObjects[controlId].Refresh(o) end end
        function self.SetVisible(v) row.Visible = v; if not v then popup.Visible = false end end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Keybind（miUI 小按钮） ==========
    child.Keybind = function(_, config)
        local keyText = config.Name or ""
        local defaultKey = config.Default or Enum.KeyCode.M
        local mode = config.Mode or "Toggle"
        local callback = config.Callback or function() end
        local controlId = keyText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"
        local state = {Key = defaultKey.Name, Mode = mode, Toggled = false, Waiting = false}

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle
        local lbl = makeRowLabel(row, keyText, 60)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 18)
        btn.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        btn.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        btn.BorderSizePixel = 0
        btn.Text = state.Key
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextTransparency = 0.4
        btn.AutoButtonColor = false
        btn.Parent = row
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Thickness = 1
        btnStroke.Color = Color3.fromRGB(45, 48, 58)
        btnStroke.Transparency = 0.65
        btnStroke.Parent = btn
        AddToRegistry(btn, "TextColor3", "Text")

        btn.MouseButton1Click:Connect(function()
            if locked then return end
            if state.Waiting then return end
            state.Waiting = true
            btn.Text = "..."
            local input = UserInputService.InputBegan:Wait()
            state.Waiting = false
            local nk = nil
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode.Name ~= "Unknown" then nk = input.KeyCode.Name end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then nk = "MouseLeft"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then nk = "MouseRight" end
            if nk then
                state.Key = nk
                btn.Text = nk
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = {Key = nk, Mode = state.Mode} end
            else
                btn.Text = state.Key
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe or locked or state.Waiting then return end
            if UserInputService:GetFocusedTextBox() then return end
            local k = state.Key
            if state.Mode == "Toggle" then
                if k == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    state.Toggled = not state.Toggled
                    pcall(callback, state.Toggled)
                elseif k == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then
                    state.Toggled = not state.Toggled
                    pcall(callback, state.Toggled)
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == k then
                    state.Toggled = not state.Toggled
                    pcall(callback, state.Toggled)
                end
            elseif state.Mode == "Hold" then
                if k == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then pcall(callback, true)
                elseif k == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(callback, true)
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == k then pcall(callback, true) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if locked or state.Waiting then return end
            if state.Mode == "Hold" then
                local k = state.Key
                if k == "MouseLeft" and input.UserInputType == Enum.UserInputType.MouseButton1 then pcall(callback, false)
                elseif k == "MouseRight" and input.UserInputType == Enum.UserInputType.MouseButton2 then pcall(callback, false)
                elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == k then pcall(callback, false) end
            end
        end)

        ConfigObjects[controlId] = {
            Type = "Keybind",
            Value = {Key = state.Key, Mode = state.Mode},
            Set = function(v)
                if locked then return end
                if type(v) == "table" then
                    state.Key = v.Key or state.Key
                    state.Mode = v.Mode or state.Mode
                elseif type(v) == "string" then
                    state.Key = v
                end
                btn.Text = state.Key
            end
        }

        local self = {}
        function self.GetValue() return {Key = state.Key, Mode = state.Mode} end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Input（miUI 输入框） ==========
    child.Input = function(_, config)
        local inputText = config.Name or ""
        local default = config.Value or ""
        local callback = config.Callback or function() end
        local opts = config or {}
        local placeholder = opts.Placeholder or ""
        local numeric = opts.Numeric == true
        local controlId = inputText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle
        local lbl = makeRowLabel(row, inputText, 130)

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 120, 0, 18)
        box.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        box.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        box.BackgroundTransparency = 0.1
        box.BorderSizePixel = 0
        box.Font = Enum.Font.GothamMedium
        box.TextSize = 11
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.ClearTextOnFocus = false
        box.Text = tostring(default)
        box.PlaceholderText = placeholder
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 1
        boxStroke.Color = Color3.fromRGB(45, 48, 58)
        boxStroke.Transparency = 0.65
        boxStroke.Parent = box
        AddToRegistry(box, "TextColor3", "Text")

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.Parent = box

        if numeric then
            box:GetPropertyChangedSignal("Text"):Connect(function()
                local t = box.Text:gsub("[^%d%-%.]", "")
                if t ~= box.Text then
                    box.Text = t
                    box.CursorPosition = #t + 1
                end
            end)
        end

        box.FocusLost:Connect(function()
            if locked then return end
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = box.Text end
            callback(box.Text)
        end)
        box:GetPropertyChangedSignal("Text"):Connect(function()
            if locked then return end
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = box.Text end
        end)

        ConfigObjects[controlId] = {Type = "Input", Value = box.Text, Set = function(v)
            if not locked then box.Text = tostring(v or ""); callback(box.Text) end
        end}

        local self = {}
        function self.GetText() return box.Text end
        function self.GetValue() return box.Text end
        function self.UpdateText(t) if not locked then box.Text = tostring(t or "") end end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.UpdatePlaceholder(p) box.PlaceholderText = p end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Textbox（多行，miUI 风格） ==========
    child.Textbox = function(_, config)
        local boxText = config.Name or ""
        local placeholder = config.Placeholder or ""
        local callback = config.Callback or function() end
        local controlId = boxText.."_"..tostring(#Registry)
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, 62, locked)
        lockLabel.Text = lockedTitle

        local lbl = Instance.new("TextLabel")
        lbl.Text = boxText
        lbl.Size = UDim2.new(1, -22, 0, 15)
        lbl.Position = UDim2.new(0, PAD_LEFT, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        AddToRegistry(lbl, "TextColor3", "Text")

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -22, 0, 36)
        box.Position = UDim2.new(0, PAD_LEFT, 0, 20)
        box.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        box.BackgroundTransparency = 0.1
        box.BorderSizePixel = 0
        box.Font = Enum.Font.GothamMedium
        box.TextSize = 11
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.TextWrapped = true
        box.MultiLine = true
        box.ClearTextOnFocus = false
        box.Text = ""
        box.PlaceholderText = placeholder
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 1
        boxStroke.Color = Color3.fromRGB(45, 48, 58)
        boxStroke.Transparency = 0.65
        boxStroke.Parent = box
        AddToRegistry(box, "TextColor3", "Text")

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.PaddingTop = UDim.new(0, 4)
        pad.Parent = box

        box.FocusLost:Connect(function()
            if locked then return end
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = box.Text end
            callback(box.Text)
        end)

        ConfigObjects[controlId] = {Type = "Textbox", Value = "", Set = function(v)
            if not locked then box.Text = tostring(v or ""); callback(box.Text) end
        end}

        local self = {}
        function self.GetValue() return box.Text end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Label（miUI 文本行） ==========
    child.Label = function(_, config)
        local labelText = config.Name or ""
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, 24, locked)
        lockLabel.Text = lockedTitle

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -22, 1, 0)
        lbl.Position = UDim2.new(0, PAD_LEFT, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.Text = labelText
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.Parent = row
        AddToRegistry(lbl, "TextColor3", "Text")

        local self = {}
        function self.UpdateText(t) lbl.Text = t end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Paragraph（miUI 标题 + 内容） ==========
    child.Paragraph = function(_, config)
        config = config or {}
        local title = config.Name or ""
        local content = config.Content or ""
        local parent = config.Parent or contentHolder
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, 24, locked)
        lockLabel.Text = lockedTitle

        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -22, 0, 0)
        holder.Position = UDim2.new(0, PAD_LEFT, 0, 4)
        holder.BackgroundTransparency = 1
        holder.AutomaticSize = Enum.AutomaticSize.Y
        holder.Parent = row

        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 2)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Parent = holder

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, 0, 0, 14)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Text = title
        titleLbl.Parent = holder
        AddToRegistry(titleLbl, "TextColor3", "Text")

        local contentLbl = Instance.new("TextLabel")
        contentLbl.Size = UDim2.new(1, 0, 0, 14)
        contentLbl.BackgroundTransparency = 1
        contentLbl.Font = Enum.Font.Gotham
        contentLbl.TextSize = 12
        contentLbl.TextTransparency = 0.4
        contentLbl.TextXAlignment = Enum.TextXAlignment.Left
        contentLbl.TextWrapped = true
        contentLbl.AutomaticSize = Enum.AutomaticSize.Y
        contentLbl.Text = content
        contentLbl.Parent = holder
        AddToRegistry(contentLbl, "TextColor3", "SubText")

        task.defer(function()
            task.wait(0.05)
            row.Size = UDim2.new(1, 0, 0, math.max(24, holder.AbsoluteSize.Y + 8))
        end)
        holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            row.Size = UDim2.new(1, 0, 0, math.max(24, holder.AbsoluteSize.Y + 8))
        end)

        local self = {}
        function self.SetName(t) titleLbl.Text = t end
        function self.SetContent(t) contentLbl.Text = t end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Divider ==========
    child.Divider = function(_, config)
        config = config or {}
        local parent = config.Parent or contentHolder
        local labelText = config.Name or ""
        local hasText = (labelText ~= "")
        local h = hasText and 22 or 10

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, h)
        container.BackgroundTransparency = 1
        container.Parent = parent

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, -22, 0, 1)
        line.Position = UDim2.new(0, PAD_LEFT, 0.5, 0)
        line.AnchorPoint = Vector2.new(0, 0.5)
        line.BackgroundColor3 = Color3.fromRGB(45, 48, 58)
        line.BackgroundTransparency = 0.5
        line.BorderSizePixel = 0
        line.Parent = container
        AddToRegistry(line, "BackgroundColor3", "Stroke")

        if hasText then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 0, 0, 14)
            lbl.AutomaticSize = Enum.AutomaticSize.X
            lbl.AnchorPoint = Vector2.new(0.5, 0.5)
            lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 11
            lbl.TextTransparency = 0.4
            lbl.Text = labelText
            lbl.Parent = container
            AddToRegistry(lbl, "TextColor3", "SubText")
        end

        local self = {}
        function self.SetVisible(v) container.Visible = v end
        function self.UpdateText(t)
            local l = container:FindFirstChildOfClass("TextLabel")
            if l then l.Text = t or "" end
        end
        return self
    end

    -- ========== Space ==========
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
        function self.SetVisible(v) sp.Visible = v end
        function self.Destroy() sp:Destroy() end
        return self
    end

    -- ========== ProgressBar（miUI 紧凑） ==========
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
        local locked = config.Locked == true
        local lockedTitle = config.LockedTitle or config.TextLocked or "Locked"

        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, locked)
        lockLabel.Text = lockedTitle

        local lbl = makeRowLabel(row, name, 90)

        local pctLbl = Instance.new("TextLabel")
        pctLbl.Size = UDim2.new(0, 40, 0, 14)
        pctLbl.Position = UDim2.new(1, CTRL_RIGHT - 40, 0.5, -7)
        pctLbl.BackgroundTransparency = 1
        pctLbl.Font = Enum.Font.GothamMedium
        pctLbl.TextSize = 11
        pctLbl.TextXAlignment = Enum.TextXAlignment.Right
        pctLbl.Text = "0%"
        pctLbl.Parent = row
        AddToRegistry(pctLbl, "TextColor3", "Text")

        local rail = Instance.new("Frame")
        rail.Size = UDim2.new(0, 100, 0, 5)
        rail.Position = UDim2.new(1, CTRL_RIGHT - 40 - 6 - 100, 0.5, -2.5)
        rail.BackgroundColor3 = Color3.fromRGB(30, 29, 36)
        rail.BorderSizePixel = 0
        rail.Parent = row
        Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = CurrentTheme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = rail
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        AddToRegistry(fill, "BackgroundColor3", "Accent")

        local Val = math.clamp(default, min, max)

        local function setVal(v)
            v = math.clamp(tonumber(v) or Val, min, max)
            Val = v
            local a = (max > min) and (v - min) / (max - min) or 0
            Tween(fill, {Size = UDim2.fromScale(a, 1)}, 0.2)
            pctLbl.Text = math.floor(a * 100) .. "%"
            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = v end
            callback(v)
        end
        setVal(default)

        ConfigObjects[controlId] = {Type = "ProgressBar", Value = Val, Set = function(v)
            if not locked then setVal(v) end
        end}

        local self = {}
        function self.GetValue() return Val end
        function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
        function self.SetTitle(t) lbl.Text = t end
        function self.SetVisible(v) row.Visible = v end
        function self.Lock(t) locked = true; lockFrame.Visible = true; if t then lockLabel.Text = t end end
        function self.Unlock() locked = false; lockFrame.Visible = false end
        function self.IsLocked() return locked end
        return self
    end

    -- ========== Image（保留原样但用 Row 包装） ==========
    child.Image = function(_, config)
        config = config or {}
        local title = config.Name or "Image"
        local subtitle = config.SubName or ""
        local description = config.Description or {}
        if type(description) == "string" then description = {description} end
        local iconAsset = config.Icon or config.ImageLink or ""
        local iconColor = config.IconColor or CurrentTheme.Text
        local callback = config.Callback or function() end
        local parent = config.Parent or contentHolder

        local function formatIcon(asset)
            if type(asset) == "number" then return "rbxassetid://" .. tostring(asset)
            elseif type(asset) == "string" then
                if tonumber(asset) then return "rbxassetid://" .. asset
                elseif asset:match("^rbxassetid://") then return asset
                elseif asset:match("^http") then return asset
                else return "rbxassetid://" .. asset end
            end
            return "rbxassetid://78229538488090"
        end

        local row, lockFrame, lockLabel = makeRow(parent, 80, false)

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 60, 0, 60)
        iconImg.Position = UDim2.new(0, PAD_LEFT, 0.5, -30)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = formatIcon(iconAsset)
        iconImg.ImageColor3 = iconColor
        iconImg.Parent = row
        Instance.new("UICorner", iconImg).CornerRadius = UDim.new(0, 8)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -100, 0, 16)
        titleLbl.Position = UDim2.new(0, 76, 0, 15)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Text = title
        titleLbl.Parent = row
        AddToRegistry(titleLbl, "TextColor3", "Text")

        if subtitle ~= "" then
            local subLbl = Instance.new("TextLabel")
            subLbl.Size = UDim2.new(1, -100, 0, 14)
            subLbl.Position = UDim2.new(0, 76, 0, 33)
            subLbl.BackgroundTransparency = 1
            subLbl.Font = Enum.Font.Gotham
            subLbl.TextSize = 11
            subLbl.TextTransparency = 0.4
            subLbl.TextXAlignment = Enum.TextXAlignment.Left
            subLbl.Text = subtitle
            subLbl.Parent = row
            AddToRegistry(subLbl, "TextColor3", "SubText")
        end

        local clickBtn = Instance.new("TextButton")
        clickBtn.Size = UDim2.new(1, 0, 1, 0)
        clickBtn.BackgroundTransparency = 1
        clickBtn.Text = ""
        clickBtn.Parent = row
        clickBtn.MouseButton1Click:Connect(callback)

        local self = {}
        function self.UpdateTitle(t) titleLbl.Text = t end
        function self.SetVisible(v) row.Visible = v end
        function self.SetIcon(i, c) iconImg.Image = formatIcon(i); if c then iconImg.ImageColor3 = c end end
        return self
    end

    -- ========== 以下保留原样 ==========
    -- Video / Audio / Social / Viewport / Group 保持和原来一致

    child.Video = function(_, config)
        local opts = config or {}
        local parent = opts.Parent or contentHolder
        if not parent then return end
        local radius = opts.Radius or 8
        local src = opts.Video or ""
        local looped = opts.Looped ~= false
        local vol = opts.Volume or 0
        local auto = opts.AutoPlay ~= false
        local aspect = opts.AspectRatio or "16:9"
        local function resolveMedia(s)
            if type(s) ~= "string" or s == "" then return "" end
            if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
            if s:match("^%d+$") then return "rbxassetid://" .. s end
            if s:match("^https?://") then return MediaManager:Video(s) end
            return ""
        end
        local function applyIcon(imgLabel, iconName)
            if not imgLabel then return end
            local m = {play = "rbxassetid://10734923549", pause = "rbxassetid://10734919336", stop = "rbxassetid://10734972621", volume = "rbxassetid://10747376008"}
            imgLabel.Image = m[iconName] or ""
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
        wrap.BackgroundTransparency = 0.92
        wrap.BorderSizePixel = 0
        wrap.ClipsDescendants = true
        wrap.Parent = parent
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, radius)
        AddToRegistry(wrap, "BackgroundColor3", "Main")
        local wStroke = Instance.new("UIStroke")
        wStroke.Thickness = 1
        wStroke.Color = CurrentTheme.Stroke
        wStroke.Transparency = 0.6
        wStroke.Parent = wrap
        AddToRegistry(wStroke, "Color", "Stroke")
        local resolved = resolveMedia(src)
        local hasVideo = (resolved ~= "")
        local vid = nil
        if hasVideo then
            vid = Instance.new("VideoFrame")
            vid.Size = UDim2.fromScale(1, 1)
            vid.BackgroundTransparency = 1
            vid.Looped = looped
            vid.Volume = vol
            vid.Video = resolved
            vid.Parent = wrap
        else
            local ph = Instance.new("ImageLabel")
            ph.Size = UDim2.fromOffset(32, 32)
            ph.Position = UDim2.new(0.5, 0, 0.5, -16)
            ph.AnchorPoint = Vector2.new(0.5, 0.5)
            ph.BackgroundTransparency = 1
            ph.Image = "rbxassetid://10734923549"
            ph.ImageTransparency = 0.5
            ph.Parent = wrap
        end
        local mod = {Frame = wrap, Type = "Video", VideoFrame = vid}
        function mod:Play() if vid then pcall(function() vid:Play() end) end end
        function mod:Pause() if vid then pcall(function() vid:Pause() end) end end
        function mod:Stop() if vid then pcall(function() vid:Stop() end) end end
        function mod:SetVolume(v) if vid then vid.Volume = math.clamp(v, 0, 1) end end
        function mod:Destroy() wrap:Destroy() end
        return mod
    end

    child.Audio = function(_, config)
        local opts = config or {}
        local parent = opts.Parent or contentHolder
        if not parent then return end
        local title = opts.Name or opts.Title or "Audio"
        local src = opts.Audio or opts.Sound or ""
        local vol = (opts.Volume ~= nil) and math.clamp(opts.Volume, 0, 10) or 0.5
        local looped = opts.Looped ~= false
        local function resolve(s)
            if type(s) ~= "string" or s == "" then return "" end
            if s:match("^rbxassetid://") or s:match("^rbxasset://") then return s end
            if s:match("^%d+$") then return "rbxassetid://" .. s end
            if s:match("^https?://") then return MediaManager:Audio(s) end
            return ""
        end
        local resolved = resolve(src)
        local hasAudio = resolved ~= ""
        local snd = nil
        if hasAudio then
            snd = Instance.new("Sound")
            pcall(function() snd.SoundId = resolved end)
            snd.Volume = vol
            snd.Looped = looped
            snd.Parent = workspace
        end
        local row, lockFrame, lockLabel = makeRow(parent, ROW_H, false)
        local lbl = makeRowLabel(row, title, 90)
        local playBtn = Instance.new("TextButton")
        playBtn.Size = UDim2.new(0, 60, 0, 18)
        playBtn.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
        playBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
        playBtn.BorderSizePixel = 0
        playBtn.Text = "Play"
        playBtn.Font = Enum.Font.GothamMedium
        playBtn.TextSize = 11
        playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        playBtn.Parent = row
        Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 4)
        AddToRegistry(playBtn, "TextColor3", "Text")
        local isPlaying = false
        playBtn.MouseButton1Click:Connect(function()
            if not snd then return end
            if isPlaying then snd:Pause(); playBtn.Text = "Play" else snd:Play(); playBtn.Text = "Pause" end
            isPlaying = not isPlaying
        end)
        local mod = {Frame = row, Type = "Audio", Sound = snd}
        function mod:Play() if snd then snd:Play(); playBtn.Text = "Pause"; isPlaying = true end end
        function mod:Pause() if snd then snd:Pause(); playBtn.Text = "Play"; isPlaying = false end end
        function mod:Stop() if snd then snd:Stop(); playBtn.Text = "Play"; isPlaying = false end end
        function mod:SetVolume(v) if snd then snd.Volume = math.clamp(v, 0, 10) end end
        function mod:Destroy() if snd then pcall(function() snd:Stop(); snd:Destroy() end) end; row:Destroy() end
        return mod
    end

    child.Social = function(_, config)
        config = config or {}
        local parent = config.Parent or contentHolder
        if not parent then return end
        local displayName = tostring(config.Name or config.DisplayName or "User")
        local subName = tostring(config.SubName or "")
        local avatarSrc = config.Logo or config.Avatar or ""
        local copyText = tostring(config.copy or "")
        local row, lockFrame, lockLabel = makeRow(parent, 42, false)
        local av = Instance.new("ImageLabel")
        av.Size = UDim2.new(0, 32, 0, 32)
        av.Position = UDim2.new(0, PAD_LEFT, 0.5, -16)
        av.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        av.Parent = row
        Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
        if avatarSrc ~= "" then
            local url = avatarSrc
            if tonumber(avatarSrc) then url = "rbxassetid://" .. avatarSrc end
            task.spawn(function()
                local ok, asset = pcall(function() return MediaManager:Image(url) end)
                if ok and asset and asset ~= "" then av.Image = asset end
            end)
        end
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -90, 0, 14)
        nameLbl.Position = UDim2.new(0, 52, 0, 7)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamMedium
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Text = displayName
        nameLbl.Parent = row
        AddToRegistry(nameLbl, "TextColor3", "Text")
        if subName ~= "" then
            local sl = Instance.new("TextLabel")
            sl.Size = UDim2.new(1, -90, 0, 12)
            sl.Position = UDim2.new(0, 52, 0, 22)
            sl.BackgroundTransparency = 1
            sl.Font = Enum.Font.Gotham
            sl.TextSize = 10
            sl.TextTransparency = 0.4
            sl.TextXAlignment = Enum.TextXAlignment.Left
            sl.Text = subName
            sl.Parent = row
            AddToRegistry(sl, "TextColor3", "SubText")
        end
        if copyText ~= "" then
            local cb = Instance.new("TextButton")
            cb.Size = UDim2.new(0, 44, 0, 18)
            cb.Position = UDim2.new(1, CTRL_RIGHT, 0.5, -9)
            cb.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
            cb.BorderSizePixel = 0
            cb.Text = config.Cbn or "Copy"
            cb.Font = Enum.Font.GothamMedium
            cb.TextSize = 10
            cb.TextColor3 = Color3.fromRGB(255, 255, 255)
            cb.Parent = row
            Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
            AddToRegistry(cb, "TextColor3", "Text")
            cb.MouseButton1Click:Connect(function() pcall(function() toclipboard(copyText) end) end)
        end
        local mod = {Frame = row, Type = "Social"}
        function mod:SetName(n) nameLbl.Text = n end
        function mod:Destroy() row:Destroy() end
        return mod
    end

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
        assert(obj, "Viewport - Missing Object")
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, -16, 0, height)
        wrap.BackgroundTransparency = 0.92
        wrap.BackgroundColor3 = CurrentTheme.Main
        wrap.BorderSizePixel = 0
        wrap.ClipsDescendants = true
        wrap.Parent = parent
        Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)
        AddToRegistry(wrap, "BackgroundColor3", "Main")
        local wS = Instance.new("UIStroke")
        wS.Thickness = 1
        wS.Color = CurrentTheme.Stroke
        wS.Transparency = 0.6
        wS.Parent = wrap
        AddToRegistry(wS, "Color", "Stroke")
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
            camera.CFrame = CFrame.new(mpos + Vector3.new(0, ext / 2, ext * 2), mpos)
        end
        if focused then task.defer(focusCamera) end
        vp.InputBegan:Connect(function(inp)
            if interactive and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
                Dragging = true
                LastMousePos = inp.Position
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
        local self = {Frame = wrap, Type = "Viewport", Object = obj, Camera = camera}
        function self:SetObject(newObj, clone)
            if clone then newObj = newObj:Clone() end
            if self.Object then self.Object:Destroy() end
            self.Object = newObj
            self.Object.Parent = vp
        end
        function self:SetHeight(h) wrap.Size = UDim2.new(1, -16, 0, h) end
        function self:Destroy() wrap:Destroy() end
        return self
    end

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
        local mod = {Frame = outerWrap, Type = "Group", Elements = elements}
        function mod:SetSection(s) self._section = s end
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
            for mn, fn in pairs(child) do
                if type(fn) == "function" and mn ~= "Group" and mn ~= "Section" then
                    colMethods[mn] = makeColMethod(mn)
                end
            end
            setmetatable(colObj, {__index = colMethods})
            table.insert(elements, {Frame = el, ColObj = colObj})
            return colObj
        end
        function mod:Destroy() outerWrap:Destroy() end
        return mod
    end

    -- ========== 返回构建器 ==========
    local functions = {}
    for k, v in pairs(child) do functions[k] = v end

    -- ========== 创建 Section ==========
    local function createSection(_, config)
        if type(config) == "string" then
            config = { Name = config }
        elseif type(config) ~= "table" then
            config = {}
        end

        local sectionTitle = config.Name or config.Title or ""
        local sectionSubtitle = config.SubName or config.Subtitle or ""
        local sectionIcon = config.Logo or config.Icon or nil
        local collapsible = config.Collapsible == true
        local collapsed = collapsible and (config.Collapsed == false)
        local locked = config.Locked == true
        local lockedTitle = config.TextLocked or config.LockMessage or "Locked"

        local hasTitle = (sectionTitle ~= "")
        local hasSubtitle = (sectionSubtitle ~= "")
        local hasIcon = (sectionIcon ~= nil)
        local hasHeader = hasTitle or hasSubtitle or hasIcon

        local HEADER_LEFT = 12
        local ARROW_W = collapsible and 26 or 0
        local ICON_SIZE = hasSubtitle and 40 or 32
        local TITLE_SIZE = 15
        local TITLE_H = 20
        local SUB_SIZE = 12
        local SUB_H = 16
        local SUB_GAP = 2

        local HEADER_H = hasHeader and (hasSubtitle and 56 or 44) or 4
        local COLLAPSED_H = hasSubtitle and 50 or (hasHeader and 40 or (collapsible and 40 or 4))
        local CONTENT_TOP = hasHeader and (HEADER_H + 4) or 4

        local ICON_TOP = math.floor((COLLAPSED_H - ICON_SIZE) / 2)
        local TEXT_BLOCK_H = hasSubtitle and (TITLE_H + SUB_GAP + SUB_H) or TITLE_H
        local TEXT_BLOCK_TOP = math.floor((COLLAPSED_H - TEXT_BLOCK_H) / 2)
        local TITLE_TOP = TEXT_BLOCK_TOP
        local SUB_TOP = TEXT_BLOCK_TOP + TITLE_H + SUB_GAP
        local ARROW_TOP = math.floor((COLLAPSED_H - 18) / 2)

        local MIUI_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quart)

        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(0.96, 0, 0, 0)
        sectionFrame.AnchorPoint = Vector2.new(0, 0)
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

        -- 图标
        local iconLabel = nil
        local iconGap = 0
        if hasIcon then
            iconLabel = Instance.new("ImageLabel")
            iconLabel.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
            iconLabel.Position = UDim2.new(0, HEADER_LEFT, 0, ICON_TOP)
            iconLabel.BackgroundTransparency = 1
            iconLabel.ImageColor3 = Color3.new(1, 1, 1)
            iconLabel.Image = tonumber(sectionIcon) and ("rbxassetid://" .. tostring(sectionIcon)) or tostring(sectionIcon)
            Instance.new("UICorner", iconLabel).CornerRadius = UDim.new(0, 8)
            iconLabel.Parent = contentContainer
            AddToRegistry(iconLabel, "ImageColor3", "Text")
            iconGap = ICON_SIZE + 10
        end

        -- 标题
        local titleLabel = nil
        if hasTitle then
            titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -(HEADER_LEFT * 2 + iconGap + ARROW_W), 0, TITLE_H)
            titleLabel.Position = UDim2.new(0, HEADER_LEFT + iconGap, 0, TITLE_TOP)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = sectionTitle
            titleLabel.TextSize = TITLE_SIZE
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextYAlignment = Enum.TextYAlignment.Center
            titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            titleLabel.Parent = contentContainer
            AddToRegistry(titleLabel, "TextColor3", "Accent")
        end

        -- 副标题
        local subtitleLabel = nil
        if hasSubtitle then
            subtitleLabel = Instance.new("TextLabel")
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

        -- 折叠箭头
        local collapseArrow = nil
        if collapsible then
            collapseArrow = Instance.new("ImageLabel")
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

        -- 内容持有者
        local contentHolder = Instance.new("Frame")
        contentHolder.Size = UDim2.new(1, -10, 0, 0)
        contentHolder.Position = UDim2.new(0.5, 0, 0, CONTENT_TOP)
        contentHolder.AnchorPoint = Vector2.new(0.5, 0)
        contentHolder.BackgroundTransparency = 1
        contentHolder.ClipsDescendants = false
        contentHolder.Parent = contentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 4)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.Parent = contentHolder

        local bottomPadding = Instance.new("Frame")
        bottomPadding.Size = UDim2.new(1, 0, 0, 6)
        bottomPadding.BackgroundTransparency = 1
        bottomPadding.LayoutOrder = 9999
        bottomPadding.Parent = contentHolder

        -- Locked 覆盖层
        local lockFrame, lockLabel = createLockOverlay(sectionFrame, lockedTitle)
        lockFrame.ZIndex = 200
        lockFrame.Visible = locked

        local collapsedState = collapsed

        local function getContentHeight()
            return contentLayout.AbsoluteContentSize.Y or 0
        end
        local function getTargetHeight()
            if collapsedState then return COLLAPSED_H end
            return getContentHeight() + CONTENT_TOP + 6
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

        if collapsedState then
            contentHolder.Visible = false
        end
        task.defer(function() updateHeight(true) end)

        local function setCollapsed(state, instant)
            if not collapsible then return end
            state = state == true
            if collapsedState == state then return end
            collapsedState = state
            if collapseArrow then
                TweenService:Create(collapseArrow, MIUI_TWEEN, {Rotation = state and 180 or 0}):Play()
            end
            contentHolder.Visible = not state
            updateHeight(instant)
        end

        if collapsible then
            local headBtn = Instance.new("TextButton")
            headBtn.Size = UDim2.new(1, 0, 0, HEADER_H)
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
        for mn, mf in pairs(child) do
            sectionObj[mn] = function(_, cfg)
                cfg = cfg or {}
                cfg.Parent = contentHolder
                return mf(_, cfg)
            end
        end

        sectionObj.SetVisible = function(_, v) sectionFrame.Visible = v end
        sectionObj.SetTitle = function(_, t) if titleLabel then titleLabel.Text = t or ""; titleLabel.Visible = (t ~= nil and t ~= "") end end
        sectionObj.SetSubtitle = function(_, t) if subtitleLabel then subtitleLabel.Text = t or ""; subtitleLabel.Visible = (t ~= nil and t ~= "") end end
        sectionObj.SetCollapsed = function(_, s) setCollapsed(s, false); return sectionObj end
        sectionObj.ToggleCollapsed = function(_) setCollapsed(not collapsedState, false); return sectionObj end
        sectionObj.GetCollapsed = function(_) return collapsedState end
        sectionObj.SetCollapsible = function(_, s) collapsible = s == true; return sectionObj end
        sectionObj.IsCollapsible = function(_) return collapsible end
        sectionObj.SetLocked = function(_, s) locked = s == true; lockFrame.Visible = locked; return sectionObj end
        sectionObj.SetTextLocked = function(_, t) lockedTitle = t or "Locked"; lockLabel.Text = lockedTitle; return sectionObj end
        sectionObj.SetMessage = function(_, t) lockedTitle = t or "Locked"; lockLabel.Text = lockedTitle; return sectionObj end
        sectionObj.GetLocked = function(_) return locked end
        sectionObj.Lock = function(_, t) if t then lockedTitle = t; lockLabel.Text = lockedTitle end; locked = true; lockFrame.Visible = true; return sectionObj end
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
                else return Color3.new(0, 0, 0) end
            end
            local ct = {}
            for k, v in pairs(CurrentTheme) do ct[k] = v end
            if t.Main then ct.Main = toC3(t.Main) end
            if t.Top then ct.Top = toC3(t.Top) end
            if t.Text then ct.Text = toC3(t.Text) end
            if t.Accent then ct.Accent = toC3(t.Accent) end
            if t.Stroke then ct.Stroke = toC3(t.Stroke) end
            if t.SubText then ct.SubText = toC3(t.SubText) end
            if t.Element then ct.Element = toC3(t.Element) end
            if t.Hover then ct.Hover = toC3(t.Hover) end
            if t.ShineEnabled ~= nil then ct.ShineEnabled = t.ShineEnabled end
            if t.Shine then ct.Shine = t.Shine end
            if t.StrokeShine ~= nil then ct.StrokeShine = t.StrokeShine end
            if t.StrokeDark then ct.StrokeDark = toC3(t.StrokeDark) end
            local cn = t.Name or "Custom"
            Themes[cn] = ct
            CurrentTheme = ct
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FengYu-Bento"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Size = UDim2.new(0, 300, 0, 0)
    NotificationHolder.AutomaticSize = Enum.AutomaticSize.Y
    NotificationHolder.Position = UDim2.new(1, -20, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 100
    local HL = Instance.new("UIListLayout")
    HL.HorizontalAlignment = Enum.HorizontalAlignment.Right
    HL.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HL.SortOrder = Enum.SortOrder.LayoutOrder
    HL.Padding = UDim.new(0, 5)
    HL.Parent = NotificationHolder

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
        local s = Instance.new("UIStroke")
        s.Thickness = thick
        s.Color = Color3.new(0, 0, 0)
        s.Transparency = 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = MainFrame
        table.insert(shadowStrokes, s)
    end
    local function setShadow(v, inst)
        for _, s in ipairs(shadowStrokes) do
            if inst then s.Transparency = v and 0.9 or 1 else Tween(s, {Transparency = v and 0.9 or 1}, 0.3) end
        end
    end

    local bgImage = Instance.new("ImageLabel")
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ZIndex = 0
    bgImage.Parent = MainFrame
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0, 12)
    if SceneId then
        if type(SceneId) == "number" or (type(SceneId) == "string" and tonumber(SceneId)) then
            bgImage.Image = "rbxassetid://" .. tostring(SceneId)
        else bgImage.Image = tostring(SceneId) end
    else bgImage.Image = ""; bgImage.Visible = false end

    local bgGradient = Instance.new("UIGradient")
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

    setShadow(false, true)

    -- Resizer
    local Resizer = Instance.new("TextButton")
    Resizer.Parent = MainFrame
    Resizer.BackgroundTransparency = 0.8
    Resizer.BackgroundColor3 = Color3.new(1, 1, 1)
    Resizer.Position = UDim2.new(1, 5, 1, 5)
    Resizer.Size = UDim2.new(0, 24, 0, 24)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.Text = ""
    Resizer.ZIndex = 30
    Resizer.Visible = false
    Instance.new("UICorner", Resizer).CornerRadius = UDim.new(0, 6)
    local isResizing = false
    local rs, ss = Vector2.new(0, 0), UDim2.new(0, 0, 0, 0)
    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true; rs = input.Position; ss = MainFrame.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - rs
            MainFrame.Size = UDim2.new(0, math.max(400, ss.X.Offset + d.X), 0, math.max(250, ss.Y.Offset + d.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isResizing = false end
    end)

    -- Blur
    local function CreateBlurModule()
        if not MainFrame or not MainFrame.Parent then return end
        local Part = Instance.new("Part")
        Part.Anchored = true; Part.CanCollide = false; Part.CanTouch = false; Part.CastShadow = false
        Part.Material = Enum.Material.Glass; Part.Transparency = 0.97; Part.Reflectance = 0.8
        Part.Size = Vector3.new(1, 1, 1) * 0.01
        Part.Parent = workspace
        local DOF = DepthOfFieldEffect
        DOF.Enabled = true; DOF.FarIntensity = 0; DOF.FocusDistance = 0; DOF.InFocusRadius = 1000; DOF.NearIntensity = 1
        DOF.Parent = Lighting
        local function UpdateBlur()
            if not MainFrame.Visible then Part.Transparency = 1; DOF.NearIntensity = 0; return end
            local cam = Camera
            if not cam then return end
            local pos = MainFrame.AbsolutePosition
            local size = MainFrame.AbsoluteSize
            local ray0 = cam:ScreenPointToRay(pos.X, pos.Y, 1)
            local ray1 = cam:ScreenPointToRay(pos.X + size.X, pos.Y + size.Y, 1)
            local po = cam.CFrame.Position + cam.CFrame.LookVector * 0.05
            local pn = cam.CFrame.LookVector
            local function getP(origin, dir)
                local num = pn:Dot(po - origin)
                local den = pn:Dot(dir)
                if math.abs(den) < 1e-8 then return origin end
                return origin + dir * (num / den)
            end
            local p0 = getP(ray0.Origin, ray0.Direction)
            local p1 = getP(ray1.Origin, ray1.Direction)
            local center = (p0 + p1) / 2
            local sv = p1 - p0
            Part.CFrame = cam.CFrame
            Part.Size = Vector3.new(1, 1, 1) * 0.01
            local mesh = Part:FindFirstChildOfClass("BlockMesh")
            if not mesh then mesh = Instance.new("BlockMesh"); mesh.Parent = Part end
            mesh.Offset = cam.CFrame:PointToObjectSpace(center)
            mesh.Scale = sv / 0.0101
            Part.Transparency = 0.97
            DOF.NearIntensity = 1
        end
        local c1 = RunService.RenderStepped:Connect(UpdateBlur)
        MainFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateBlur)
        MainFrame:GetPropertyChangedSignal("Size"):Connect(UpdateBlur)
        MainFrame:GetPropertyChangedSignal("Position"):Connect(UpdateBlur)
        MainFrame.AncestryChanged:Connect(function(_, p)
            if not p then c1:Disconnect(); pcall(function() Part:Destroy() end); DOF.Enabled = false end
        end)
    end
    task.delay(0.3, function() if MainFrame and MainFrame.Parent then pcall(CreateBlurModule) end end)

    -- 左侧
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
    TabList.Parent = LeftScrollingFrame
    local function updateTabCanvas()
        LeftScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
    end
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
    task.spawn(updateTabCanvas)

    -- 底部
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
    local LineFrame_2 = Instance.new("Frame")
    LineFrame_2.Size = UDim2.new(1, -10, 0, 1)
    LineFrame_2.Position = UDim2.new(0.5, 0, 0, 0)
    LineFrame_2.AnchorPoint = Vector2.new(0.5, 0)
    LineFrame_2.BackgroundTransparency = 0.65
    LineFrame_2.Parent = BottomFrame
    AddToRegistry(LineFrame_2, "BackgroundColor3", "Stroke")

    -- 右侧
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

    -- 三按钮
    local resizerVisible = false
    local ButtonGroup = Instance.new("Frame")
    ButtonGroup.Size = UDim2.new(0, 180, 1, 0)
    ButtonGroup.Position = UDim2.new(1, -190, 0, 0)
    ButtonGroup.BackgroundTransparency = 1
    ButtonGroup.Parent = RightHeader
    local BLayout = Instance.new("UIListLayout")
    BLayout.FillDirection = Enum.FillDirection.Horizontal
    BLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BLayout.Padding = UDim.new(0, 5)
    BLayout.Parent = ButtonGroup
    local BPadding = Instance.new("UIPadding")
    BPadding.PaddingRight = UDim.new(0, 10)
    BPadding.Parent = ButtonGroup

    local function createControlButton(iconAsset, fallbackText, cb)
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
            if content then Tween(content, {[content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"] = 0}, 0.2) end
            Tween(accent, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundTransparency = 0.2}, 0.2)
            if content then Tween(content, {[content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"] = 0.3}, 0.2) end
            Tween(accent, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
        end)
        btn.MouseButton1Click:Connect(cb)
        table.insert(ThemeListeners, function()
            btn.BackgroundColor3 = CurrentTheme.Element or CurrentTheme.Top
            accent.BackgroundColor3 = CurrentTheme.Accent
            if content and content:IsA("ImageLabel") then content.ImageColor3 = CurrentTheme.Text
            elseif content and content:IsA("TextLabel") then content.TextColor3 = CurrentTheme.Text end
        end)
        return btn
    end

    createControlButton(nil, "−", function() MainFrame.Visible = false end)
    createControlButton("rbxassetid://6031090998", nil, function()
        resizerVisible = not resizerVisible; Resizer.Visible = resizerVisible
    end)
    createControlButton("rbxassetid://130510492706892", nil, function() ScreenGui:Destroy() end)

    -- TabContainer / Page
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
    PageContainer.Parent = TabContainer

    local dragToggle = false
    local dragStart, startPos
    HeadFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            local c
            c = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false; c:Disconnect() end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local function AnimateWindowIn()
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, FINAL_WIDTH, 0, FINAL_HEIGHT)
        }):Play()
        setShadow(true, false)
    end
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if MainFrame.Visible then setShadow(true, false) else setShadow(false, false) end
    end)
    task.delay(0.1, AnimateWindowIn)

    -- 浮动按钮
    local OpenButton = Instance.new("ImageButton")
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
    local oS = Instance.new("UIStroke")
    oS.Parent = OpenButton
    oS.Color = Color3.fromRGB(180, 180, 180)
    oS.Thickness = 1.2
    oS.Transparency = 0.4
    OpenButton.MouseButton1Click:Connect(function()
        if MainFrame.Visible then MainFrame.Visible = false; OpenButton.Visible = true
        else MainFrame.Visible = true; OpenButton.Visible = false end
    end)
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function() OpenButton.Visible = not MainFrame.Visible end)
    OpenButton.Visible = false
    MainFrame.Visible = true

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- Category
    Window._currentCategory = nil
    function Window:Category(config)
        local name = type(config) == "table" and config.Name or config
        local collapsible = type(config) == "table" and config.Collapsible or false
        local opened = true
        if type(config) == "table" and config.Opened ~= nil then opened = config.Opened end
        local cFrame = Instance.new("Frame")
        cFrame.Size = UDim2.new(1, 0, 0, 0)
        cFrame.AutomaticSize = Enum.AutomaticSize.Y
        cFrame.BackgroundTransparency = 1
        cFrame.Parent = LeftScrollingFrame
        local cL = Instance.new("UIListLayout")
        cL.FillDirection = Enum.FillDirection.Vertical
        cL.SortOrder = Enum.SortOrder.LayoutOrder
        cL.Parent = cFrame
        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundTransparency = 1
        header.Text = name
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Font = Enum.Font.GothamBold
        header.TextSize = 13
        header.TextTransparency = 0.5
        header.Parent = cFrame
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.Parent = header
        AddToRegistry(header, "TextColor3", "Text")
        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0, 12, 0, 12)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://8240930340"
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
        content.Parent = cFrame
        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 4)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentList.Parent = content
        local ct
        local function getContentHeight() return contentList.AbsoluteContentSize.Y or 0 end
        local function setContentHeight(th, animate)
            th = math.max(0, th)
            if animate then
                if ct then ct:Cancel() end
                ct = TweenService:Create(content, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, th)})
                ct:Play()
                ct.Completed:Connect(function() ct = nil; task.spawn(updateTabCanvas) end)
            else
                content.Size = UDim2.new(1, 0, 0, th)
                task.spawn(updateTabCanvas)
            end
        end
        local function toggle()
            if not collapsible then return end
            opened = not opened
            Tween(arrow, {Rotation = opened and 0 or 180}, 0.25)
            setContentHeight(opened and getContentHeight() or 0, true)
        end
        header.MouseButton1Click:Connect(toggle)
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if opened then
                local h = getContentHeight()
                if math.abs(h - content.Size.Y.Offset) > 0.5 then setContentHeight(h, false) end
            end
        end)
        task.spawn(function()
            task.wait()
            content.Size = UDim2.new(1, 0, 0, opened and getContentHeight() or 0)
            updateTabCanvas()
        end)
        Window._currentCategory = {content = content, contentList = contentList, header = header, arrow = arrow, collapsible = collapsible, opened = opened, toggle = toggle}
        table.insert(ThemeListeners, function() header.TextColor3 = CurrentTheme.Text; arrow.ImageColor3 = CurrentTheme.Text end)
        return Window._currentCategory
    end

    -- Tab
    Window._activeTab = nil
    Window._tabs = {}
    function Window:Tab(name, icon)
        local parentContainer = LeftScrollingFrame
        if Window._currentCategory then parentContainer = Window._currentCategory.content end
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -7, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = parentContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 10)

        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(1, 0, 1, 0)
        glow.BackgroundColor3 = CurrentTheme.Accent
        glow.BackgroundTransparency = 1
        glow.Parent = TabBtn
        Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 10)

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = TabBtn
        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 5)
        Layout.Parent = ContentFrame
        local P = Instance.new("UIPadding")
        P.PaddingLeft = UDim.new(0, 10)
        P.Parent = ContentFrame

        if icon then
            local I = Instance.new("ImageLabel")
            I.Size = UDim2.new(0, 20, 0, 20)
            I.BackgroundTransparency = 1
            I.Image = tonumber(icon) and ("rbxassetid://" .. icon) or icon
            I.Parent = ContentFrame
            AddToRegistry(I, "ImageColor3", "Text")
        end

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, -30, 0, 15)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamMedium
        T.Text = name
        T.TextTransparency = 0.3
        T.TextSize = 13
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = ContentFrame
        AddToRegistry(T, "TextColor3", "Text")

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.Parent = PageContainer

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

        local state = {btn = TabBtn, page = Page, textLabel = T, glow = glow}
        TabBtn.MouseButton1Click:Connect(function()
            if Window._activeTab == state then return end
            for _, s in ipairs(Window._tabs) do
                s.glow.BackgroundTransparency = 1
                Tween(s.textLabel, {TextTransparency = 0.3}, 0.2)
            end
            state.glow.BackgroundTransparency = 0
            Tween(T, {TextTransparency = 0}, 0.2)
            if Window._activeTab then Window._activeTab.page.Visible = false end
            Page.Visible = true
            Window._activeTab = state
        end)
        if not Window._activeTab then
            state.glow.BackgroundTransparency = 0
            T.TextTransparency = 0
            Page.Visible = true
            Window._activeTab = state
        end
        table.insert(Window._tabs, state)
        table.insert(ThemeListeners, function()
            for _, s in ipairs(Window._tabs) do s.glow.BackgroundColor3 = CurrentTheme.Accent end
        end)

        return createSectionBuilder(PageContent, PageContent, 330, 1, Window)
    end

    function Window:TabDivider()
        local pc = LeftScrollingFrame
        if Window._currentCategory then pc = Window._currentCategory.content end
        local l = Instance.new("Frame")
        l.Size = UDim2.new(1, -20, 0, 1)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundColor3 = CurrentTheme.Stroke
        l.BackgroundTransparency = 0.5
        l.Parent = pc
        AddToRegistry(l, "BackgroundColor3", "Stroke")
    end

    function Window:Dialog(Config)
        Config = Config or {}
        local Dialog = {Closed = false}
        local Overlay = Instance.new("Frame")
        Overlay.Parent = MainFrame
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 1
        Overlay.Size = UDim2.fromScale(1, 1)
        Overlay.ZIndex = 180
        Overlay.Active = true

        local Panel = Instance.new("Frame")
        Panel.Parent = Overlay
        Panel.AnchorPoint = Vector2.new(0.5, 0.5)
        Panel.Position = UDim2.fromScale(0.5, 0.5)
        Panel.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
        Panel.BackgroundTransparency = 1
        Panel.Size = UDim2.new(0, 340, 0, 160)
        Panel.ZIndex = 181
        Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)
        local PStroke = Instance.new("UIStroke")
        PStroke.Transparency = 1
        PStroke.Color = Color3.fromRGB(45, 48, 58)
        PStroke.Parent = Panel

        local Title = Instance.new("TextLabel")
        Title.Parent = Panel
        Title.Position = UDim2.new(0, 18, 0, 18)
        Title.Size = UDim2.new(1, -36, 0, 20)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 15
        Title.Text = Config.Title or "Dialog"
        Title.TextTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        AddToRegistry(Title, "TextColor3", "Text")

        local Content = Instance.new("TextLabel")
        Content.Parent = Panel
        Content.Position = UDim2.new(0, 18, 0, 44)
        Content.Size = UDim2.new(1, -36, 0, 64)
        Content.BackgroundTransparency = 1
        Content.Font = Enum.Font.GothamMedium
        Content.TextSize = 12
        Content.Text = Config.Content or ""
        Content.TextTransparency = 1
        Content.TextWrapped = true
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.TextYAlignment = Enum.TextYAlignment.Top
        AddToRegistry(Content, "TextColor3", "SubText")

        local BHolder = Instance.new("Frame")
        BHolder.Parent = Panel
        BHolder.AnchorPoint = Vector2.new(1, 1)
        BHolder.Position = UDim2.new(1, -14, 1, -14)
        BHolder.Size = UDim2.new(1, -28, 0, 30)
        BHolder.BackgroundTransparency = 1
        local BLayout = Instance.new("UIListLayout")
        BLayout.FillDirection = Enum.FillDirection.Horizontal
        BLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        BLayout.Padding = UDim.new(0, 8)
        BLayout.Parent = BHolder

        function Dialog:Close(Result)
            if Dialog.Closed then return Result end
            Dialog.Closed = true
            Tween(Overlay, {BackgroundTransparency = 1}, 0.15)
            Tween(Panel, {BackgroundTransparency = 1}, 0.15)
            task.delay(0.2, function() Overlay:Destroy() end)
            pcall(Config.Callback, Result)
            return Result
        end

        for _, B in ipairs(Config.Buttons or {{Text = "OK", Primary = true}}) do
            local Btn = Instance.new("Frame")
            Btn.Parent = BHolder
            Btn.BackgroundColor3 = B.Primary and CurrentTheme.Accent or Color3.fromRGB(26, 28, 36)
            Btn.BackgroundTransparency = 1
            Btn.Size = UDim2.new(0, 70, 0, 28)
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            local BL = Instance.new("TextLabel")
            BL.Size = UDim2.fromScale(1, 1)
            BL.BackgroundTransparency = 1
            BL.Font = Enum.Font.GothamMedium
            BL.TextSize = 12
            BL.Text = B.Text or "OK"
            BL.TextTransparency = 1
            BL.Parent = Btn
            AddToRegistry(BL, "TextColor3", "Text")
            local Inp = Instance.new("TextButton")
            Inp.Size = UDim2.fromScale(1, 1)
            Inp.BackgroundTransparency = 1
            Inp.Text = ""
            Inp.Parent = Btn
            Inp.MouseButton1Click:Connect(function() Dialog:Close(B.Callback and B.Callback() or B.Text) end)
            Tween(Btn, {BackgroundTransparency = B.Primary and 0.1 or 0.25}, 0.15)
            Tween(BL, {TextTransparency = 0}, 0.15)
        end

        Tween(Overlay, {BackgroundTransparency = 0.35}, 0.25)
        Tween(Panel, {BackgroundTransparency = 0.05}, 0.25)
        Tween(PStroke, {Transparency = 0.65}, 0.25)
        Tween(Title, {TextTransparency = 0}, 0.25)
        Tween(Content, {TextTransparency = 0.25}, 0.25)
        return Dialog
    end

    function Window:Notification() end
    function Window:SetKeybind(k) Keybind = k end
    function Window:Destroy() ScreenGui:Destroy() end
    function Window:SetSubtitle(s) WindowContent.Text = s or "" end

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
    cursorRoot.BackgroundTransparency = 1
    cursorRoot.Size = UDim2.new(0, 20, 0, 20)
    cursorRoot.ZIndex = 2147483647
    cursorRoot.Visible = false
    cursorRoot.Parent = cursorScreen

    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1, 0, 1, 0)
    img.Image = "rbxassetid://132511743665753"
    img.ImageColor3 = Color3.fromRGB(90, 165, 255)
    img.ScaleType = Enum.ScaleType.Fit
    img.Rotation = -90
    img.Parent = cursorRoot

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not cursorRoot.Visible then return end
        local loc = UserInputService:GetMouseLocation()
        cursorRoot.Position = UDim2.new(0, loc.X - 2, 0, loc.Y - 2)
    end)

    Fenglib._cursorObjects = {Screen = cursorScreen, Root = cursorRoot, Connection = conn, Enabled = false}

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
        local c = Fenglib._cursorObjects and Fenglib._cursorObjects.Enabled or false
        Fenglib:SetCustomCursor(not c)
    end
end

return Fenglib