--[[
    FengYu-Bento (miUI 框架 – 完整版)
    三按钮功能与原文件完全一致：最小化/最大化(Resizer)/关闭(确认框)
    所有 UI 元素均已完整展开
    ================================================
    [MOD] 移植 miUI 的透明度增强：
      - 背景模糊（DepthOfField + 动态 Part，已修复 PointToObjectSpace）
      - 窗口背景渐变（UIGradient）
      - 主窗口边框替换为 miUI 式多层阴影（移除硬边描边）
      - 阴影颜色为黑色（与第三个文件的边框颜色一致）
      - 窗口大小固定为 500×320
      - 背景图默认为空（不显示任何图片）
      - 主题仅保留 Dark、Charcoal、AMOLED
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

-- [MOD] 新增 DepthOfField 和 Blur 相关引用
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

-- ========== 主题（仅保留 Dark, Charcoal, AMOLED） ==========
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
    if not ok or type(data)~="table" then return false end
    Fenglib._loading = true
    for k, v in pairs(data) do if ConfigObjects[k] and ConfigObjects[k].Set then pcall(function() ConfigObjects[k].Set(v) end) end end
    Fenglib._loading = false
    return true
end

-- ========== 媒体管理器（完整） ==========
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

-- ========== 锁覆盖层 ==========
local function createLockOverlay(parent, defaultTitle)
    local cornerRadius = UDim.new(0, 8)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("UICorner") then cornerRadius = child.CornerRadius; break end
    end
    local lockFrame = Instance.new("Frame")
    lockFrame.Size = UDim2.new(1, 0, 1, 0)
    lockFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    lockFrame.BackgroundTransparency = 0.6
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

-- ================================================================
-- 新增：miUI 风格 Section 构建器（完全替换原 createSectionBuilder）
-- ================================================================
local function createSectionBuilder(parent, contentContainer, elementWidth, windowCount, window)
    local win = window
    local padding = parent:FindFirstChild("SectionPadding")
    if not padding then
        padding = Instance.new("UIPadding")
        padding.Name = "SectionPadding"
        padding.PaddingLeft = UDim.new(0.04, 0)
        padding.Parent = parent
    end

    -- ---------- 辅助函数 ----------
    local function getIconId(icon)
        if not icon or icon == "" then return "" end
        if tonumber(icon) then return "rbxassetid://" .. icon end
        if icon:match("^rbxassetid://") or icon:match("^rbxasset://") then return icon end
        if icon:match("^https?://") then return icon end
        -- 内置名称（如 "gear"）直接作为 rbxassetid（需确保存在）
        return "rbxassetid://" .. icon
    end

    -- ---------- 创建 miUI 风格的 Section ----------
    local function createSection(config)
        local titleText = ""
        local subtitleText = nil
        local iconAsset = nil
        local defaultOpen = true

        if type(config) == "table" then
            titleText = config.Name or ""
            subtitleText = config.SubName
            iconAsset = config.Logo
            if config.open ~= nil then defaultOpen = config.open end
        else
            titleText = config or ""
            if type(iconAsset) == "table" then
                subtitleText = iconAsset.subtitle
                iconAsset = iconAsset.icon
            elseif type(iconAsset) == "string" then
                subtitleText = iconAsset
            end
        end

        -- 1. Section 根容器
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(0.96, 0, 0, 0)
        sectionFrame.AnchorPoint = Vector2.new(0, 0)
        sectionFrame.Position = UDim2.new(0, 0, 0, 0)
        sectionFrame.BackgroundTransparency = 1
        sectionFrame.ClipsDescendants = true
        sectionFrame.Parent = parent

        -- 2. 标题栏（miUI 风格）
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 30)
        header.BackgroundColor3 = Color3.fromRGB(25, 27, 33)
        header.BackgroundTransparency = 0.25
        header.ClipsDescendants = true
        header.Parent = sectionFrame
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = CurrentTheme.Stroke
        stroke.Transparency = 0.7
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = header
        table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

        -- 标题图标（可选）
        local iconLabel = nil
        if iconAsset then
            iconLabel = Instance.new("ImageLabel")
            iconLabel.Size = UDim2.fromOffset(16, 16)
            iconLabel.Position = UDim2.new(0, 11, 0.5, 0)
            iconLabel.AnchorPoint = Vector2.new(0, 0.5)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Image = getIconId(iconAsset)
            iconLabel.ImageColor3 = CurrentTheme.Text
            iconLabel.ImageTransparency = 0.5
            iconLabel.Parent = header
            AddToRegistry(iconLabel, "ImageColor3", "Text")
        end

        -- 标题文字
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -46, 1, 0)
        titleLabel.Position = UDim2.new(0, iconLabel and 32 or 11, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.Text = titleText
        titleLabel.TextColor3 = CurrentTheme.Text
        titleLabel.TextTransparency = 0.2
        titleLabel.TextSize = 13
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = header
        AddToRegistry(titleLabel, "TextColor3", "Text")

        -- 折叠箭头（默认隐藏，由 Collapsible 控制）
        local collapsible = config.Collapsible == true
        local collapsed = config.Collapsed == true
        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.fromOffset(16, 16)
        arrow.Position = UDim2.new(1, -10, 0.5, 0)
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://8240930340"   -- 向下箭头
        arrow.ImageColor3 = CurrentTheme.Text
        arrow.ImageTransparency = 0.5
        arrow.Rotation = collapsed and -90 or 0
        arrow.Visible = collapsible
        arrow.Parent = header
        AddToRegistry(arrow, "ImageColor3", "Text")

        -- 3. 内容容器（用于放置控件）
        local contentHolder = Instance.new("Frame")
        contentHolder.Size = UDim2.new(1, -10, 0, 0)
        contentHolder.Position = UDim2.new(0, 5, 0, 30)
        contentHolder.BackgroundTransparency = 1
        contentHolder.ClipsDescendants = true
        contentHolder.Parent = sectionFrame

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = contentHolder

        -- 底部留白
        local bottomPad = Instance.new("Frame")
        bottomPad.Size = UDim2.new(1, 0, 0, 4)
        bottomPad.BackgroundTransparency = 1
        bottomPad.Parent = contentHolder

        -- 4. 折叠逻辑
        local function updateHeight(instant)
            local contentHeight = contentLayout.AbsoluteContentSize.Y
            local target = (collapsed or not collapsible) and 0 or contentHeight + 8
            local totalHeight = 30 + target
            if instant then
                contentHolder.Size = UDim2.new(1, -10, 0, target)
                sectionFrame.Size = UDim2.new(0.96, 0, 0, totalHeight)
            else
                TweenService:Create(contentHolder, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -10, 0, target)
                }):Play()
                TweenService:Create(sectionFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0.96, 0, 0, totalHeight)
                }):Play()
                TweenService:Create(arrow, TweenInfo.new(0.25), { Rotation = collapsed and -90 or 0 }):Play()
            end
        end

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not collapsed or not collapsible then updateHeight(false) end
        end)

        -- 标题点击切换折叠
        if collapsible then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = header
            btn.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                updateHeight(false)
            end)
            header.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    collapsed = not collapsed
                    updateHeight(false)
                end
            end)
        end

        -- 初始高度
        task.defer(function() updateHeight(true) end)

        -- ========== 控件生成器 ==========
        local child = {}

        -- ---------- Button ----------
        child.Button = function(_, config)
            local btnText = config.Name or config.Text or ""
            local callback = config.Callback or function() end
            local icon = config.Icon
            local parent = config.Parent or contentHolder

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local strokeBtn = Instance.new("UIStroke")
            strokeBtn.Thickness = 1
            strokeBtn.Color = CurrentTheme.Stroke
            strokeBtn.Transparency = 0.6
            strokeBtn.Parent = frame
            table.insert(ThemeListeners, function() strokeBtn.Color = CurrentTheme.Stroke end)

            local iconLabel = nil
            if icon then
                iconLabel = Instance.new("ImageLabel")
                iconLabel.Size = UDim2.fromOffset(18, 18)
                iconLabel.Position = UDim2.new(0, 11, 0.5, 0)
                iconLabel.AnchorPoint = Vector2.new(0, 0.5)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Image = getIconId(icon)
                iconLabel.ImageColor3 = CurrentTheme.Text
                iconLabel.ImageTransparency = 0.25
                iconLabel.Parent = frame
                AddToRegistry(iconLabel, "ImageColor3", "Text")
            end

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, icon and -46 or -20, 1, 0)
            label.Position = UDim2.new(0, icon and 35 or 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = btnText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local click = Instance.new("TextButton")
            click.Size = UDim2.fromScale(1, 1)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.Parent = frame

            click.MouseButton1Click:Connect(callback)
            click.MouseEnter:Connect(function()
                Tween(frame, { BackgroundTransparency = 0.35 }, 0.15)
            end)
            click.MouseLeave:Connect(function()
                Tween(frame, { BackgroundTransparency = 1 }, 0.15)
            end)

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            click.Active = not locked

            local self = {}
            function self.UpdateText(t) label.Text = t end
            function self.SetVisible(v) frame.Visible = v end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            return self
        end

        -- ---------- Toggle ----------
        child.Toggle = function(_, config)
            local toggleText = config.Name or ""
            local Enabled = config.Value or false
            local callback = config.Callback or function() end
            local parent = config.Parent or contentHolder

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = toggleText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            -- Switch
            local switch = Instance.new("Frame")
            switch.Size = UDim2.fromOffset(36, 18)
            switch.Position = UDim2.new(1, -46, 0.5, 0)
            switch.AnchorPoint = Vector2.new(1, 0.5)
            switch.BackgroundTransparency = 0
            switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(40, 40, 45)
            switch.Parent = frame
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

            local dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(14, 14)
            dot.Position = Enabled and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            dot.AnchorPoint = Vector2.new(0, 0.5)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
            dot.BackgroundTransparency = 0
            dot.Parent = switch
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local click = Instance.new("TextButton")
            click.Size = UDim2.fromScale(1, 1)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.Parent = frame

            local function updateSwitch(val)
                Enabled = val
                Tween(switch, { BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(40,40,45) }, 0.15)
                Tween(dot, { Position = Enabled and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.15)
                callback(Enabled)
            end

            click.MouseButton1Click:Connect(function() updateSwitch(not Enabled) end)

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            click.Active = not locked

            local self = {}
            function self.GetValue() return Enabled end
            function self.SetValue(v) if not locked then updateSwitch(v) end end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            function self.SetVisible(v) frame.Visible = v end
            return self
        end

        -- ---------- Slider ----------
        child.Slider = function(_, config)
            local sliderText = config.Name or ""
            local valueTable = config.Value or {}
            local min = valueTable.Min or 0
            local max = valueTable.Max or 100
            local default = valueTable.Default or min
            local callback = config.Callback or function() end
            local rounding = config.Rounding or 0
            local parent = config.Parent or contentHolder

            local val = tonumber(default) or min
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 44)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -80, 0, 18)
            label.Position = UDim2.new(0, 15, 0, 4)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = sliderText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local numBox = Instance.new("TextBox")
            numBox.Size = UDim2.fromOffset(50, 20)
            numBox.Position = UDim2.new(1, -60, 0, 3)
            numBox.AnchorPoint = Vector2.new(1, 0)
            numBox.BackgroundTransparency = 0.1
            numBox.BackgroundColor3 = CurrentTheme.Main
            numBox.Font = Enum.Font.GothamBold
            numBox.TextSize = 12
            numBox.Text = tostring(val)
            numBox.TextColor3 = CurrentTheme.Accent
            numBox.TextXAlignment = Enum.TextXAlignment.Center
            numBox.ClearTextOnFocus = false
            numBox.Parent = frame
            Instance.new("UICorner", numBox).CornerRadius = UDim.new(0, 4)
            AddToRegistry(numBox, "BackgroundColor3", "Main")
            AddToRegistry(numBox, "TextColor3", "Accent")

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -30, 0, 5)
            track.Position = UDim2.new(0, 15, 0, 32)
            track.BackgroundColor3 = CurrentTheme.Stroke
            track.BackgroundTransparency = 0.5
            track.BorderSizePixel = 0
            track.Parent = frame
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = CurrentTheme.Accent
            fill.BorderSizePixel = 0
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(12, 12)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((val-min)/(max-min), 0, 0.5, 0)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.Parent = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateSlider(newVal)
                newVal = math.clamp(newVal, min, max)
                local factor = 10^rounding
                newVal = math.floor(newVal * factor + 0.5) / factor
                val = newVal
                local ratio = (val - min) / (max - min)
                Tween(fill, { Size = UDim2.new(ratio, 0, 1, 0) }, 0.1)
                Tween(knob, { Position = UDim2.new(ratio, 0, 0.5, 0) }, 0.1)
                numBox.Text = tostring(val)
                callback(val)
            end

            local function getValueFromInput(input)
                local absX = track.AbsolutePosition.X
                local absW = track.AbsoluteSize.X
                local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
                return ratio * (max - min) + min
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(getValueFromInput(input))
                end
            end)
            track.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(getValueFromInput(input))
                end
            end)

            numBox.FocusLost:Connect(function()
                local typed = tonumber(numBox.Text)
                if typed then updateSlider(typed) else numBox.Text = tostring(val) end
            end)

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked

            local self = {}
            function self.GetValue() return val end
            function self.SetValue(v) if not locked then updateSlider(v) end end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            function self.SetVisible(v) frame.Visible = v end
            return self
        end

        -- ---------- Dropdown ----------
        child.Dropdown = function(_, config)
            local dropText = config.Name or ""
            local options = config.Values or {}
            local selectedValue = config.Value
            local multi = config.Multi == true
            local callback = config.Callback or function() end
            local parent = config.Parent or contentHolder

            local selected = multi and {} or nil
            local function initSelected()
                if multi then
                    if type(selectedValue)=="table" then
                        selected={}
                        for _,v in ipairs(selectedValue) do if table.find(options, v) then table.insert(selected, v) end end
                    else selected={} end
                else
                    if selectedValue and table.find(options, selectedValue) then selected=selectedValue else selected=options[1] or "" end
                end
            end
            initSelected()

            local Dropped = false
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = dropText..": "..tostring(selected)
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local arrowIcon = Instance.new("ImageLabel")
            arrowIcon.Size = UDim2.fromOffset(16, 16)
            arrowIcon.Position = UDim2.new(1, -10, 0.5, 0)
            arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
            arrowIcon.BackgroundTransparency = 1
            arrowIcon.Image = "rbxassetid://8240930340"
            arrowIcon.ImageColor3 = CurrentTheme.Text
            arrowIcon.ImageTransparency = 0.3
            arrowIcon.Parent = frame
            AddToRegistry(arrowIcon, "ImageColor3", "Text")

            -- 下拉列表容器
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.Visible = false
            container.ClipsDescendants = true
            container.ZIndex = 10
            container.Parent = parent
            local containerStroke = Instance.new("UIStroke")
            containerStroke.Thickness = 1
            containerStroke.Color = CurrentTheme.Stroke
            containerStroke.Transparency = 0.6
            containerStroke.Parent = container
            table.insert(ThemeListeners, function() containerStroke.Color = CurrentTheme.Stroke end)
            container.BackgroundColor3 = CurrentTheme.Main
            container.BackgroundTransparency = 0.92
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
            AddToRegistry(container, "BackgroundColor3", "Main")

            local list = Instance.new("UIListLayout")
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Parent = container

            local optionButtons = {}

            local function updateLabel()
                if multi then
                    if #selected==0 then label.Text=dropText..":  (none)" else label.Text=dropText..": "..table.concat(selected,", ") end
                else
                    label.Text=dropText..": "..tostring(selected)
                end
            end

            local function rebuildOptions(optList)
                for _, child in ipairs(container:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                optionButtons = {}
                for _, opt in ipairs(optList) do
                    local O = Instance.new("TextButton")
                    O.Size = UDim2.new(1, 0, 0, 30)
                    O.Text = ""
                    O.BackgroundTransparency = 1
                    O.AutoButtonColor = false
                    O.BackgroundColor3 = CurrentTheme.Top
                    O.Parent = container
                    O.TextColor3 = CurrentTheme.Text

                    local check = Instance.new("Frame")
                    check.Size = UDim2.fromOffset(14, 14)
                    check.Position = UDim2.new(0, 10, 0.5, 0)
                    check.AnchorPoint = Vector2.new(0,0.5)
                    check.BackgroundColor3 = CurrentTheme.Accent
                    check.BackgroundTransparency = 1
                    check.Parent = O
                    Instance.new("UICorner", check).CornerRadius = UDim.new(0, 3)
                    local checkStroke = Instance.new("UIStroke")
                    checkStroke.Thickness = 1.5
                    checkStroke.Color = CurrentTheme.Accent
                    checkStroke.Transparency = 0.7
                    checkStroke.Parent = check
                    local checkMark = Instance.new("ImageLabel")
                    checkMark.Size = UDim2.fromOffset(10, 10)
                    checkMark.Position = UDim2.new(0.5, 0, 0.5, 0)
                    checkMark.AnchorPoint = Vector2.new(0.5, 0.5)
                    checkMark.BackgroundTransparency = 1
                    checkMark.Image = "rbxassetid://16633109272"
                    checkMark.ImageTransparency = 1
                    checkMark.Parent = check
                    AddToRegistry(checkMark, "ImageColor3", "Accent")

                    local labelOpt = Instance.new("TextLabel")
                    labelOpt.Size = UDim2.new(1, -30, 1, 0)
                    labelOpt.Position = UDim2.new(0, 30, 0, 0)
                    labelOpt.BackgroundTransparency = 1
                    labelOpt.Font = Enum.Font.GothamMedium
                    labelOpt.Text = opt
                    labelOpt.TextSize = 12
                    labelOpt.TextXAlignment = Enum.TextXAlignment.Left
                    labelOpt.Parent = O
                    AddToRegistry(labelOpt, "TextColor3", "Text")

                    O.MouseEnter:Connect(function()
                        Tween(O, { BackgroundTransparency = 0.1 }, 0.15)
                    end)
                    O.MouseLeave:Connect(function()
                        Tween(O, { BackgroundTransparency = 1 }, 0.15)
                    end)

                    local optData = {button=O,label=labelOpt,check=check,checkMark=checkMark,value=opt,selected=false}
                    table.insert(optionButtons, optData)

                    O.MouseButton1Click:Connect(function()
                        if locked then return end
                        if multi then
                            local idx = table.find(selected, opt)
                            if idx then table.remove(selected, idx); optData.selected=false
                            else table.insert(selected, opt); optData.selected=true end
                            optData.check.BackgroundTransparency = optData.selected and 0 or 1
                            optData.checkMark.ImageTransparency = optData.selected and 0 or 1
                            updateLabel()
                            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = selected end
                            callback(selected)
                        else
                            selected = opt
                            for _, d in ipairs(optionButtons) do
                                d.selected = (d.value==opt)
                                d.check.BackgroundTransparency = d.selected and 0 or 1
                                d.checkMark.ImageTransparency = d.selected and 0 or 1
                            end
                            updateLabel()
                            if ConfigObjects[controlId] then ConfigObjects[controlId].Value = selected end
                            callback(selected)
                            Dropped = false
                            Tween(container, { Size = UDim2.new(1, 0, 0, 0) }, 0.25)
                            Tween(arrowIcon, { Rotation = 0 }, 0.25)
                            task.wait(0.25)
                            container.Visible = false
                        end
                    end)
                end

                for _, d in ipairs(optionButtons) do
                    if multi then d.selected = table.find(selected, d.value)~=nil else d.selected = (d.value==selected) end
                    d.check.BackgroundTransparency = d.selected and 0 or 1
                    d.checkMark.ImageTransparency = d.selected and 0 or 1
                end
                if Dropped then
                    local targetHeight = #optionButtons*30
                    Tween(container, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.2)
                end
            end
            rebuildOptions(options)

            local click = Instance.new("TextButton")
            click.Size = UDim2.fromScale(1, 1)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.Parent = frame

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            click.Active = not locked

            local controlId = dropText.."_"..tostring(#Registry)
            ConfigObjects[controlId] = {
                Type="Dropdown", Value=multi and selected or selected,
                Set=function(val)
                    if locked then return end
                    if multi then
                        if type(val)=="table" then
                            selected={}
                            for _,v in ipairs(val) do if table.find(options, v) then table.insert(selected, v) end end
                        else selected={} end
                    else
                        if val and table.find(options, val) then selected=val else selected=options[1] or "" end
                    end
                    for _, d in ipairs(optionButtons) do
                        if multi then d.selected = table.find(selected, d.value)~=nil else d.selected = (d.value==selected) end
                        d.check.BackgroundTransparency = d.selected and 0 or 1
                        d.checkMark.ImageTransparency = d.selected and 0 or 1
                    end
                    updateLabel()
                    callback(selected)
                end,
                Refresh=function(newOptions)
                    if locked then return end
                    options = newOptions or {}
                    selected = multi and {} or (options[1] or "")
                    rebuildOptions(options)
                    updateLabel()
                end
            }

            click.MouseButton1Click:Connect(function()
                if locked then return end
                Dropped = not Dropped
                if Dropped then
                    container.Visible = true
                    local targetHeight = #optionButtons*30
                    Tween(container, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.3)
                    Tween(arrowIcon, { Rotation = 180 }, 0.3)
                else
                    Tween(container, { Size = UDim2.new(1, 0, 0, 0) }, 0.25)
                    Tween(arrowIcon, { Rotation = 0 }, 0.25)
                    task.wait(0.25)
                    container.Visible = false
                end
            end)

            local function isMouseOver(frame)
                if not frame then return false end
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = frame.AbsolutePosition
                local absSize = frame.AbsoluteSize
                return mousePos.X>=absPos.X and mousePos.X<=absPos.X+absSize.X and mousePos.Y>=absPos.Y and mousePos.Y<=absPos.Y+absSize.Y
            end
            local globalClickConn
            globalClickConn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if Dropped and not locked then
                        if not isMouseOver(container) and not isMouseOver(frame) then
                            Dropped = false
                            Tween(container, { Size = UDim2.new(1, 0, 0, 0) }, 0.25)
                            Tween(arrowIcon, { Rotation = 0 }, 0.25)
                            task.wait(0.25)
                            container.Visible = false
                        end
                    end
                end
            end)

            local self = {}
            function self.GetValue() return selected end
            function self.SetValue(val) if not locked then ConfigObjects[controlId].Set(val) end end
            function self.Refresh(newOptions) if not locked and ConfigObjects[controlId].Refresh then ConfigObjects[controlId].Refresh(newOptions) end end
            function self.SetVisible(state) frame.Visible = state end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            table.insert(WindowCleanup or {}, function() safeDisconnect(globalClickConn) end)
            return self
        end

        -- ---------- Keybind ----------
        child.Keybind = function(_, config)
            local keyText = config.Name or ""
            local defaultKey = config.Default or Enum.KeyCode.M
            local mode = config.Mode or "Toggle"
            local callback = config.Callback or function() end
            local parent = config.Parent or contentHolder
            local state = {Key=defaultKey.Name, Mode=mode, Toggled=false, IsWaiting=false}
            local controlId = keyText.."_"..tostring(#Registry)

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.6, 0, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = keyText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.fromOffset(0, 24)
            keyBtn.Position = UDim2.new(1, -10, 0.5, 0)
            keyBtn.AnchorPoint = Vector2.new(1, 0.5)
            keyBtn.BackgroundTransparency = 0.1
            keyBtn.Text = ""
            keyBtn.AutoButtonColor = false
            keyBtn.Parent = frame
            keyBtn.AutomaticSize = Enum.AutomaticSize.X
            AddToRegistry(keyBtn, "BackgroundColor3", "Main")
            Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 4)

            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(0, 0, 0, 14)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Font = Enum.Font.GothamMedium
            keyLabel.Text = state.Key
            keyLabel.TextColor3 = CurrentTheme.Text
            keyLabel.TextSize = 13
            keyLabel.AutomaticSize = Enum.AutomaticSize.X
            keyLabel.Parent = keyBtn
            AddToRegistry(keyLabel, "TextColor3", "Text")

            -- UIPadding for keyBtn
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 6)
            pad.PaddingRight = UDim.new(0, 6)
            pad.Parent = keyBtn

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            keyBtn.Active = not locked

            ConfigObjects[controlId] = {
                Type="Keybind", Value={Key=state.Key, Mode=state.Mode},
                Set=function(val)
                    if locked then return end
                    if type(val)=="table" then
                        local newKey = val.Key or state.Key
                        local newMode = val.Mode or state.Mode
                        state.Key = newKey; state.Mode = newMode
                        keyLabel.Text = newKey
                        ConfigObjects[controlId].Value = {Key=newKey, Mode=newMode}
                    elseif type(val)=="string" then
                        state.Key = val; keyLabel.Text = val
                        ConfigObjects[controlId].Value = {Key=val, Mode=state.Mode}
                    end
                end
            }

            keyBtn.MouseButton1Click:Connect(function()
                if locked then return end
                if state.IsWaiting then return end
                state.IsWaiting = true
                keyLabel.Text = "..."
                local input = UserInputService.InputBegan:Wait()
                state.IsWaiting = false
                local newKey = nil
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode.Name ~= "Unknown" then newKey = input.KeyCode.Name end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then newKey = "MouseLeft"
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then newKey = "MouseRight" end
                if newKey then
                    state.Key = newKey
                    keyLabel.Text = newKey
                    ConfigObjects[controlId].Value = {Key=newKey, Mode=state.Mode}
                else
                    keyLabel.Text = state.Key
                end
            end)

            local function doToggle()
                if locked then return end
                if state.Mode == "Toggle" then state.Toggled = not state.Toggled; pcall(callback, state.Toggled) end
            end
            local function doPress()
                if locked then return end
                if state.Mode == "Hold" then pcall(callback, true) end
            end
            local function doRelease()
                if locked then return end
                if state.Mode == "Hold" then pcall(callback, false) end
            end

            local inputConn, inputEndConn
            inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or locked or state.IsWaiting or UserInputService:GetFocusedTextBox() then return end
                local key = state.Key
                if state.Mode == "Toggle" then
                    if key=="MouseLeft" and input.UserInputType==Enum.UserInputType.MouseButton1 then doToggle()
                    elseif key=="MouseRight" and input.UserInputType==Enum.UserInputType.MouseButton2 then doToggle()
                    elseif input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode.Name==key then doToggle() end
                elseif state.Mode == "Hold" then
                    if key=="MouseLeft" and input.UserInputType==Enum.UserInputType.MouseButton1 then doPress()
                    elseif key=="MouseRight" and input.UserInputType==Enum.UserInputType.MouseButton2 then doPress()
                    elseif input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode.Name==key then doPress() end
                end
            end)
            inputEndConn = UserInputService.InputEnded:Connect(function(input, gpe)
                if gpe or locked or state.IsWaiting then return end
                if state.Mode == "Hold" then
                    local key = state.Key
                    if key=="MouseLeft" and input.UserInputType==Enum.UserInputType.MouseButton1 then doRelease()
                    elseif key=="MouseRight" and input.UserInputType==Enum.UserInputType.MouseButton2 then doRelease()
                    elseif input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode.Name==key then doRelease() end
                end
            end)

            local self = {}
            function self.SetValue(val) if not locked then ConfigObjects[controlId].Set(val) end end
            function self.GetValue() return {Key=state.Key, Mode=state.Mode} end
            function self.GetState() return state.Toggled end
            function self.SetMode(newMode) if not locked then state.Mode = newMode; ConfigObjects[controlId].Value = {Key=state.Key, Mode=state.Mode} end end
            function self.SetVisible(vis) frame.Visible = vis end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            return self
        end

        -- ---------- Textbox ----------
        child.Textbox = function(_, config)
            local boxText = config.Name or ""
            local placeholder = config.Placeholder or ""
            local callback = config.Callback or function() end
            local parent = config.Parent or contentHolder
            local controlId = boxText.."_"..tostring(#Registry)

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 70)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Position = UDim2.new(0, 15, 0, 6)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = boxText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -30, 0, 28)
            box.Position = UDim2.new(0, 15, 0, 30)
            box.Text = ""
            box.PlaceholderText = placeholder
            box.Font = Enum.Font.GothamMedium
            box.TextSize = 12
            box.Parent = frame
            box.BackgroundTransparency = 0.1
            box.BackgroundColor3 = CurrentTheme.Main
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            AddToRegistry(box, "BackgroundColor3", "Main")
            AddToRegistry(box, "TextColor3", "Text")

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Thickness = 1
            boxStroke.Transparency = 0.75
            boxStroke.Color = CurrentTheme.Stroke
            boxStroke.Parent = box
            AddToRegistry(boxStroke, "Color", "Stroke")

            box.Focused:Connect(function() Tween(boxStroke, { Transparency = 0.2 }, 0.15) end)
            box.FocusLost:Connect(function()
                if locked then return end
                Tween(boxStroke, { Transparency = 0.75 }, 0.15)
                ConfigObjects[controlId].Value = box.Text
                callback(box.Text)
            end)

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            box.Active = not locked

            ConfigObjects[controlId] = {Type="Textbox", Value="", Set=function(val) if not locked then box.Text=val; callback(val) end end}

            local self = {}
            function self.SetValue(v) if not locked then ConfigObjects[controlId].Set(v) end end
            function self.GetValue() return box.Text end
            function self.SetVisible(state) frame.Visible = state end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            return self
        end

        -- ---------- Input ----------
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
            local parent = config.Parent or contentHolder
            local controlId = inputText.."_"..tostring(#Registry)

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = inputText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local boxContainer = Instance.new("Frame")
            boxContainer.Size = UDim2.new(0.4, 0, 0, 24)
            boxContainer.Position = UDim2.new(0.6, -10, 0.5, 0)
            boxContainer.AnchorPoint = Vector2.new(1, 0.5)
            boxContainer.BackgroundTransparency = 0.1
            boxContainer.BackgroundColor3 = CurrentTheme.Main
            boxContainer.Parent = frame
            Instance.new("UICorner", boxContainer).CornerRadius = UDim.new(0, 4)
            AddToRegistry(boxContainer, "BackgroundColor3", "Main")

            local box = Instance.new("TextBox")
            box.Text = tostring(default)
            box.PlaceholderText = placeholder
            box.Size = UDim2.new(1, -10, 1, 0)
            box.Position = UDim2.new(0, 10, 0, 0)
            box.Font = Enum.Font.GothamBold
            box.TextSize = 12
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = false
            box.BackgroundTransparency = 1
            box.Parent = boxContainer
            AddToRegistry(box, "TextColor3", "Accent")

            local indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(1, -4, 0, 1)
            indicator.Position = UDim2.new(0, 2, 1, 0)
            indicator.AnchorPoint = Vector2.new(0, 1)
            indicator.BackgroundTransparency = 0.5
            indicator.BorderSizePixel = 0
            indicator.BackgroundColor3 = CurrentTheme.Stroke
            indicator.Parent = boxContainer

            local function filterText(text)
                if maxLength then text = text:sub(1,maxLength) end
                if numeric then
                    local filtered = text:gsub("[^%d-]","")
                    if filtered:match("^-") then filtered = "-"..filtered:gsub("-","") else filtered = filtered:gsub("-","") end
                    return filtered
                end
                if type(acceptedChars)=="function" then return acceptedChars(text)
                elseif acceptedChars=="Alphabetic" then return text:gsub("[^a-zA-Z]","")
                elseif acceptedChars=="AlphaNumeric" then return text:gsub("[^a-zA-Z0-9]","") end
                return text
            end

            local function updateValue()
                if locked then return end
                local filtered = filterText(box.Text)
                if filtered ~= box.Text then box.Text = filtered end
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = filtered end
                if callback then pcall(callback, filtered) end
                if onChanged then pcall(onChanged, filtered) end
            end

            box.Focused:Connect(function()
                if locked then return end
                Tween(indicator, { Size = UDim2.new(1, -2, 0, 2), Position = UDim2.new(0,1,1,0), BackgroundTransparency = 0 }, 0.15)
                Tween(boxContainer, { BackgroundTransparency = 0.05 }, 0.15)
                indicator.BackgroundColor3 = CurrentTheme.Accent
            end)
            box.FocusLost:Connect(function()
                if locked then return end
                Tween(indicator, { Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0,2,1,0), BackgroundTransparency = 0.5 }, 0.15)
                Tween(boxContainer, { BackgroundTransparency = 0.1 }, 0.15)
                indicator.BackgroundColor3 = CurrentTheme.Stroke
                if finished then updateValue() end
            end)

            if not finished then
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if locked then return end
                    local raw = box.Text
                    local filtered = filterText(raw)
                    if filtered ~= raw then
                        local cursor = box.CursorPosition
                        box.Text = filtered
                        pcall(function() box.CursorPosition = math.min(cursor, #filtered) end)
                    end
                    if ConfigObjects[controlId] then ConfigObjects[controlId].Value = box.Text end
                    if callback then pcall(callback, box.Text) end
                    if onChanged then pcall(onChanged, box.Text) end
                end)
            end

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            box.Active = not locked

            ConfigObjects[controlId] = {
                Type="Input", Value=box.Text,
                Set=function(val)
                    if locked then return end
                    local str=tostring(val); local filtered=filterText(str); box.Text=filtered; ConfigObjects[controlId].Value=filtered; if callback then pcall(callback, filtered) end
                end
            }

            local self = {}
            function self.UpdateText(newText) if not locked then local filtered=filterText(tostring(newText)); box.Text=filtered; ConfigObjects[controlId].Value=filtered end end
            function self.GetText() return box.Text end
            function self.SetVisible(state) frame.Visible = state end
            function self.UpdatePlaceholder(newPlaceholder) box.PlaceholderText = newPlaceholder end
            function self.SetValue(val) self.UpdateText(val) end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            return self
        end

        -- ---------- Label ----------
        child.Label = function(_, config)
            local labelText = config.Name or ""
            local parent = config.Parent or contentHolder

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = labelText
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked

            local self = {}
            function self.UpdateText(newText) label.Text = newText end
            function self.SetVisible(state) frame.Visible = state end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            return self
        end

        -- ---------- Image ----------
        child.Image = function(_, config)
            config = config or {}
            local title = config.Name or "Image"
            local subtitle = config.SubName or ""
            local description = config.Description or {}
            if type(description)=="string" then description={description} end
            local iconAsset = config.Icon or config.ImageLink or ""
            local iconColor = config.IconColor or CurrentTheme.Text
            local callback = config.Callback or function() end
            local strokeColor = config.StrokeColor or CurrentTheme.Stroke
            local parent = config.Parent or contentHolder

            local function formatIcon(asset)
                if type(asset)=="number" then return "rbxassetid://"..tostring(asset)
                elseif type(asset)=="string" then
                    if tonumber(asset) then return "rbxassetid://"..asset
                    elseif asset:match("^rbxassetid://") then return asset
                    elseif asset:match("^http") then return asset
                    else return "rbxassetid://"..asset end
                end
                return "rbxassetid://78229538488090"
            end

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = strokeColor
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 12)
            padding.PaddingRight = UDim.new(0, 12)
            padding.PaddingTop = UDim.new(0, 8)
            padding.PaddingBottom = UDim.new(0, 8)
            padding.Parent = frame

            local horizontal = Instance.new("Frame")
            horizontal.Size = UDim2.new(1, 0, 1, 0)
            horizontal.BackgroundTransparency = 1
            horizontal.Parent = frame

            local iconImg = Instance.new("ImageLabel")
            iconImg.Size = UDim2.fromOffset(64, 64)
            iconImg.Position = UDim2.new(0, 0, 0.5, 0)
            iconImg.AnchorPoint = Vector2.new(0, 0.5)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = formatIcon(iconAsset)
            iconImg.ImageColor3 = iconColor
            iconImg.Parent = horizontal
            Instance.new("UICorner", iconImg).CornerRadius = UDim.new(0, 8)

            local textContainer = Instance.new("Frame")
            textContainer.Size = UDim2.new(1, -76, 1, 0)
            textContainer.Position = UDim2.new(0, 76, 0, 0)
            textContainer.BackgroundTransparency = 1
            textContainer.AutomaticSize = Enum.AutomaticSize.Y
            textContainer.Parent = horizontal

            local textLayout = Instance.new("UIListLayout")
            textLayout.Padding = UDim.new(0, 4)
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
            if subtitle~="" then
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

            local click = Instance.new("TextButton")
            click.Size = UDim2.new(1, 0, 1, 0)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.Parent = frame
            click.MouseButton1Click:Connect(callback)
            click.MouseEnter:Connect(function() Tween(frame, { BackgroundTransparency = 0.05 }, 0.18) end)
            click.MouseLeave:Connect(function() Tween(frame, { BackgroundTransparency = 1 }, 0.18) end)

            local self = {}
            function self.UpdateTitle(newTitle) titleLabel.Text = newTitle end
            function self.UpdateSubtitle(newSubtitle)
                if subtitleLabel then subtitleLabel.Text = newSubtitle
                elseif newSubtitle~="" then
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
                for _, lbl in ipairs(descLabels) do lbl:Destroy() end
                descLabels = {}
                if type(newDesc)=="string" then newDesc={newDesc} end
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
                if newColor then iconImg.ImageColor3 = newColor end
            end
            function self.SetVisible(state) frame.Visible = state end
            return self
        end

        -- ---------- Divider ----------
        child.Divider = function(_, config)
            config = config or {}
            local parent = config.Parent or contentHolder
            local labelText = config.Name or ""
            local hasText = (labelText ~= "")
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, hasText and 24 or 12)
            container.BackgroundTransparency = 1
            container.Parent = parent

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -10, 0, 1)
            line.Position = UDim2.new(0, 5, 0.5, 0)
            line.AnchorPoint = Vector2.new(0, 0.5)
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

        -- ---------- Space ----------
        child.Space = function(_, config)
            local height = (config and config.Height) or 8
            local parent = config and config.Parent or contentHolder
            local sp = Instance.new("Frame")
            sp.Size = UDim2.new(1, 0, 0, height)
            sp.BackgroundTransparency = 1
            sp.BorderSizePixel = 0
            sp.Parent = parent
            local self = {}
            function self.SetHeight(h) height=h; sp.Size=UDim2.new(1,0,0,height) end
            function self.SetVisible(state) sp.Visible = state end
            return self
        end

        -- ---------- Checkbox ----------
        child.Checkbox = function(_, config)
            local title = config.Name or ""
            local default = config.Default or false
            local callback = config.Callback or function() end
            local parent = config.Parent or contentHolder
            local controlId = title.."_"..tostring(#Registry)

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.Text = title
            label.TextColor3 = CurrentTheme.Text
            label.TextTransparency = 0.2
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            AddToRegistry(label, "TextColor3", "Text")

            local box = Instance.new("Frame")
            box.Size = UDim2.fromOffset(18, 18)
            box.Position = UDim2.new(1, -28, 0.5, 0)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.BackgroundTransparency = 0
            box.BackgroundColor3 = default and CurrentTheme.Accent or CurrentTheme.Stroke
            box.Parent = frame
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

            local check = Instance.new("ImageLabel")
            check.Size = UDim2.fromOffset(14, 14)
            check.Position = UDim2.new(0.5, 0, 0.5, 0)
            check.AnchorPoint = Vector2.new(0.5, 0.5)
            check.BackgroundTransparency = 1
            check.Image = "rbxassetid://10709790644"
            check.ImageTransparency = default and 0 or 1
            check.ImageColor3 = Color3.new(1, 1, 1)
            check.Parent = box

            local click = Instance.new("TextButton")
            click.Size = UDim2.fromScale(1, 1)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.Parent = frame

            local h = {Value=default, Callback=callback}
            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked
            click.Active = not locked

            function h:SetValue(val)
                if locked then return end
                val = not (not val)
                h.Value = val
                box.BackgroundColor3 = val and CurrentTheme.Accent or CurrentTheme.Stroke
                check.ImageTransparency = val and 0 or 1
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = val end
                pcall(callback, val)
                pcall(h.Changed, val)
            end
            function h:OnChanged(_, cb) h.Changed = cb; cb(h.Value) end
            function h:GetValue() return h.Value end
            function h:SetVisible(state) frame.Visible = state end
            function h:Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function h:Unlock() locked = false; lockFrame.Visible = false end
            function h:IsLocked() return locked end

            click.MouseButton1Click:Connect(function() if not locked then h:SetValue(not h.Value) end end)
            h:SetValue(default)
            ConfigObjects[controlId] = {Type="Checkbox", Value=h.Value, Set=function(val) h:SetValue(val) end}
            return h
        end

        -- ---------- ProgressBar ----------
        child.ProgressBar = function(_, config)
            local name = config.Name or ""
            local valueConfig = config.Value or {}
            local min = valueConfig.Min or 0
            local max = valueConfig.Max or 100
            local default = valueConfig.Default or min
            local showPercent = config.ShowPercent ~= false
            local callback = config.Callback or function() end
            local parent = config.Parent or contentHolder
            local controlId = name.."_"..tostring(#Registry)

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, name~="" and 46 or 26)
            container.BackgroundTransparency = 1
            container.Parent = parent

            local titleLbl = nil
            if name~="" then
                titleLbl = Instance.new("TextLabel")
                titleLbl.Size = UDim2.new(1, -50, 0, 16)
                titleLbl.Position = UDim2.new(0, 0, 0, 0)
                titleLbl.BackgroundTransparency = 1
                titleLbl.Font = Enum.Font.GothamMedium
                titleLbl.Text = name
                titleLbl.TextSize = 14
                titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                titleLbl.Parent = container
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
                pctLbl.Parent = container
                AddToRegistry(pctLbl, "TextColor3", "Text")
            end

            local rail = Instance.new("Frame")
            rail.Size = UDim2.new(1, 0, 0, 6)
            rail.Position = UDim2.new(0, 0, 1, -6)
            rail.BackgroundTransparency = 0.4
            rail.BackgroundColor3 = CurrentTheme.Stroke
            rail.BorderSizePixel = 0
            rail.Parent = container
            Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)
            AddToRegistry(rail, "BackgroundColor3", "Stroke")

            local fill = Instance.new("Frame")
            fill.Size = UDim2.fromScale(0, 1)
            fill.BackgroundColor3 = CurrentTheme.Accent
            fill.BorderSizePixel = 0
            fill.Parent = rail
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local h = {Value=math.clamp(default,min,max), Min=min, Max=max}
            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(container, lockedTitle)
            lockFrame.Visible = locked

            function h:SetTitle(s) if titleLbl then titleLbl.Text = tostring(s or "") end end
            function h:SetValue(val)
                if locked then return end
                val = math.clamp(tonumber(val) or h.Min, h.Min, h.Max)
                h.Value = val
                local alpha = (h.Max > h.Min) and (val - h.Min)/(h.Max - h.Min) or 0
                Tween(fill, { Size = UDim2.fromScale(alpha, 1) }, 0.2)
                if pctLbl then pctLbl.Text = math.floor(alpha*100).."%" end
                if callback then pcall(callback, val) end
                if ConfigObjects[controlId] then ConfigObjects[controlId].Value = val end
            end
            function h:SetVisible(state) container.Visible = state end
            function h:Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function h:Unlock() locked = false; lockFrame.Visible = false end
            function h:IsLocked() return locked end
            h:SetValue(default)
            ConfigObjects[controlId] = {Type="ProgressBar", Value=h.Value, Set=function(val) h:SetValue(val) end}
            return h
        end

        -- ---------- Video ----------
        child.Video = function(_, config)
            local opts = config or {}
            local parent = opts.Parent or contentHolder
            if not parent then return end
            local radius = opts.Radius or 8
            local src = opts.Video or ""
            local looped = opts.Looped ~= false
            local vol = opts.Volume or 0
            local auto = opts.AutoPlay ~= false
            local title = opts.Name or "Video"
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
                if s:match("^https?://") then return MediaManager:Video(s) end
                return ""
            end
            local function applyIcon(imgLabel, iconName)
                if not imgLabel then return end
                local imageMap = {play="rbxassetid://10734923549", pause="rbxassetid://10734919336", stop="rbxassetid://10734972621", volume="rbxassetid://10747376008", external="rbxassetid://10747366266"}
                imgLabel.Image = imageMap[iconName] or ""
            end
            local function parseRatio(r)
                if type(r)=="number" then return r end
                if type(r)=="string" then local rw, rh = r:match("(%d+):(%d+)") if rw and rh and tonumber(rh)~=0 then return tonumber(rw)/tonumber(rh) end end
                return 16/9
            end
            local ratioNum = parseRatio(aspect)

            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, -16, 0, 180)
            wrap.BackgroundColor3 = CurrentTheme.Main
            wrap.BackgroundTransparency = 0.92
            wrap.BorderSizePixel = 0
            wrap.ClipsDescendants = true
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Main")
            local wrapStroke = Instance.new("UIStroke")
            wrapStroke.Thickness = 1
            wrapStroke.Color = CurrentTheme.Stroke
            wrapStroke.Transparency = 0.6
            wrapStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            wrapStroke.Parent = wrap
            table.insert(ThemeListeners, function() wrapStroke.Color = CurrentTheme.Stroke end)

            local function recalcAspect() local w = wrap.AbsoluteSize.X if w>0 and ratioNum and ratioNum>0 then wrap.Size = UDim2.new(1,-16,0,math.floor(w/ratioNum)) end end
            wrap:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcAspect)
            task.defer(recalcAspect)

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, radius)
            corner.Parent = wrap

            local resolved = resolveMedia(src)
            local hasVideo = (resolved~="")
            local vid = nil
            if hasVideo then
                vid = Instance.new("VideoFrame")
                vid.Size = UDim2.fromScale(1,1)
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
            placeholder.Size = UDim2.fromScale(1,1)
            placeholder.BackgroundTransparency = 1
            placeholder.Visible = not hasVideo
            placeholder.ZIndex = 2
            placeholder.Parent = wrap
            local phImg = Instance.new("ImageLabel")
            phImg.Size = UDim2.fromOffset(32,32)
            phImg.Position = UDim2.new(0.5,0,0.5,-14)
            phImg.AnchorPoint = Vector2.new(0.5,0.5)
            phImg.BackgroundTransparency = 1
            phImg.ImageTransparency = 0.4
            phImg.ZIndex = 3
            phImg.Parent = placeholder
            AddToRegistry(phImg, "ImageColor3", "SubText")
            applyIcon(phImg, "play")
            local phText = Instance.new("TextLabel")
            phText.Size = UDim2.new(1,0,0,16)
            phText.Position = UDim2.new(0,0,0.5,20)
            phText.AnchorPoint = Vector2.new(0,0)
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

            -- 控制栏（保留原实现）
            local overlay = Instance.new("CanvasGroup")
            overlay.Size = UDim2.new(1,0,0,54)
            overlay.Position = UDim2.new(0,0,1,0)
            overlay.AnchorPoint = Vector2.new(0,1)
            overlay.BackgroundTransparency = 1
            overlay.GroupTransparency = 1
            overlay.ZIndex = 5
            overlay.Parent = wrap
            local gradFr = Instance.new("Frame")
            gradFr.Size = UDim2.fromScale(1,1)
            gradFr.BackgroundColor3 = Color3.fromRGB(0,0,0)
            gradFr.BackgroundTransparency = 0
            gradFr.BorderSizePixel = 0
            gradFr.ZIndex = 5
            gradFr.Parent = overlay
            local grad = Instance.new("UIGradient")
            grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.3), NumberSequenceKeypoint.new(1,1)})
            grad.Rotation = 90
            grad.Parent = gradFr

            local seekRow = Instance.new("Frame")
            seekRow.Size = UDim2.new(1,-12,0,16)
            seekRow.Position = UDim2.new(0,6,0,4)
            seekRow.BackgroundTransparency = 1
            seekRow.ZIndex = 6
            seekRow.Parent = overlay
            local timeCur = Instance.new("TextLabel")
            timeCur.Size = UDim2.fromOffset(36,16)
            timeCur.BackgroundTransparency = 1
            timeCur.Text = "0:00"
            timeCur.TextSize = 10
            timeCur.Font = Enum.Font.GothamMedium
            timeCur.TextColor3 = Color3.fromRGB(220,220,220)
            timeCur.ZIndex = 7
            timeCur.Parent = seekRow
            local seekContainer = Instance.new("Frame")
            seekContainer.Size = UDim2.new(1,-84,0,16)
            seekContainer.Position = UDim2.fromOffset(40,0)
            seekContainer.BackgroundTransparency = 1
            seekContainer.ZIndex = 6
            seekContainer.Parent = seekRow
            local seekRail = Instance.new("TextButton")
            seekRail.Size = UDim2.new(1,0,0,5)
            seekRail.Position = UDim2.new(0,0,0.5,-2)
            seekRail.BackgroundColor3 = Color3.fromRGB(80,80,90)
            seekRail.BorderSizePixel = 0
            seekRail.ZIndex = 7
            seekRail.Text = ""
            seekRail.AutoButtonColor = false
            seekRail.Parent = seekContainer
            Instance.new("UICorner", seekRail).CornerRadius = UDim.new(1,0)
            local seekFill = Instance.new("Frame")
            seekFill.Size = UDim2.new(0,0,1,0)
            seekFill.BackgroundColor3 = CurrentTheme.Accent
            seekFill.BorderSizePixel = 0
            seekFill.ZIndex = 8
            seekFill.Parent = seekRail
            Instance.new("UICorner", seekFill).CornerRadius = UDim.new(1,0)
            local seekKnob = Instance.new("Frame")
            seekKnob.Size = UDim2.fromOffset(12,12)
            seekKnob.Position = UDim2.new(0,0,0.5,0)
            seekKnob.AnchorPoint = Vector2.new(0.5,0.5)
            seekKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
            seekKnob.BorderSizePixel = 0
            seekKnob.ZIndex = 9
            seekKnob.Parent = seekRail
            Instance.new("UICorner", seekKnob).CornerRadius = UDim.new(1,0)
            local timeDur = Instance.new("TextLabel")
            timeDur.Size = UDim2.fromOffset(36,16)
            timeDur.Position = UDim2.new(1,-36,0,0)
            timeDur.BackgroundTransparency = 1
            timeDur.Text = "0:00"
            timeDur.TextSize = 10
            timeDur.Font = Enum.Font.GothamMedium
            timeDur.TextColor3 = Color3.fromRGB(160,160,170)
            timeDur.ZIndex = 7
            timeDur.Parent = seekRow

            local ctrlRow = Instance.new("Frame")
            ctrlRow.Size = UDim2.new(1,-12,0,26)
            ctrlRow.Position = UDim2.new(0,6,0,24)
            ctrlRow.BackgroundTransparency = 1
            ctrlRow.ZIndex = 6
            ctrlRow.Parent = overlay
            local function ctrlBtn(iconName, cb)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.fromOffset(22,22)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = 7
                btn.AutoButtonColor = false
                btn.Parent = ctrlRow
                local ic = Instance.new("ImageLabel")
                ic.Size = UDim2.fromOffset(16,16)
                ic.Position = UDim2.new(0.5,0,0.5,0)
                ic.AnchorPoint = Vector2.new(0.5,0.5)
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
            volIco.Size = UDim2.fromOffset(14,14)
            volIco.Position = UDim2.fromOffset(68,4)
            volIco.BackgroundTransparency = 1
            volIco.ZIndex = 7
            volIco.Parent = ctrlRow
            AddToRegistry(volIco, "ImageColor3", "SubText")
            applyIcon(volIco, "volume")
            local volLbl = Instance.new("TextLabel")
            volLbl.Size = UDim2.fromOffset(32,22)
            volLbl.Position = UDim2.fromOffset(84,0)
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
            btnLayout.Padding = UDim.new(0,2)
            btnLayout.Parent = ctrlRow

            local ctrlVisible = false
            local fadeTimer = 0
            local fadingOut = false
            local function showOverlay()
                ctrlVisible = true; fadingOut = false; fadeTimer = 3
                Tween(overlay, {GroupTransparency=0}, 0.18)
            end
            local function hideOverlay()
                ctrlVisible = false; fadingOut = true
                Tween(overlay, {GroupTransparency=1}, 0.3)
            end
            local vidClickBtn = Instance.new("TextButton")
            vidClickBtn.Size = UDim2.fromScale(1,1)
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
                playing = true; playBtn.Visible = false; pauseBtn.Visible = true; resetFade()
            end)
            pauseBtn.MouseButton1Click:Connect(function()
                if vid then pcall(function() vid:Pause() end) end
                playing = false; playBtn.Visible = true; pauseBtn.Visible = false; resetFade()
            end)
            stopBtn.MouseButton1Click:Connect(function()
                if vid then pcall(function() vid:Stop() end) end
                playing = false; playBtn.Visible = true; pauseBtn.Visible = false; resetFade()
            end)
            pauseBtn.Visible = auto; playBtn.Visible = not auto

            local seeking = false
            local function vidSeek(posX)
                resetFade()
                local rx = seekRail.AbsolutePosition.X
                local rw = seekRail.AbsoluteSize.X
                local pct = math.clamp((posX-rx)/rw,0,1)
                seekFill.Size = UDim2.new(pct,0,1,0)
                seekKnob.Position = UDim2.new(pct,0,0.5,0)
                if vid and vid.TimeLength and vid.TimeLength>0 then
                    pcall(function() vid.TimePosition = vid.TimeLength * pct end)
                end
            end
            seekRail.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    seeking = true
                    vidSeek(inp.Position.X)
                    resetFade()
                    inp.Changed:Connect(function()
                        if inp.UserInputState==Enum.UserInputState.End then seeking = false end
                    end)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if seeking and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                    vidSeek(inp.Position.X)
                end
            end)

            local function fmtTime(s) s = math.max(0, math.floor(s or 0)); return string.format("%d:%02d", math.floor(s/60), s%60) end
            local hbConn = RunService.Heartbeat:Connect(function(dt)
                if not wrap.Parent then return end
                if ctrlVisible then
                    fadeTimer = fadeTimer - dt
                    if fadeTimer <= 0 and not seeking then hideOverlay() end
                end
                if not vid then return end
                local dur = vid.TimeLength or 0
                local pos = 0; pcall(function() pos = vid.TimePosition end)
                if dur > 0 and not seeking then
                    local pct = math.clamp(pos/dur,0,1)
                    seekFill.Size = UDim2.new(pct,0,1,0)
                    seekKnob.Position = UDim2.new(pct,0,0.5,0)
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
            function mod:Play() if vid then pcall(function() vid:Play() end); playing=true; playBtn.Visible=false; pauseBtn.Visible=true end end
            function mod:Pause() if vid then pcall(function() vid:Pause() end); playing=false; playBtn.Visible=true; pauseBtn.Visible=false end end
            function mod:Stop() if vid then pcall(function() vid:Stop() end); playing=false; playBtn.Visible=true; pauseBtn.Visible=false end end
            function mod:SetVideo(s) if vid then local r=resolveMedia(s); if r~="" then vid.Video=r; placeholder.Visible=false else placeholder.Visible=true end end end
            function mod:SetVolume(v) if vid then vid.Volume=math.clamp(v,0,1) end; volLbl.Text=tostring(math.floor(math.clamp(v,0,1)*100)).."%" end
            function mod:SetAspectRatio(r) ratioNum=parseRatio(r); recalcAspect() end
            function mod:Destroy() safeDisconnect(hbConn); wrap:Destroy() end
            return mod
        end

        -- ---------- Audio ----------
        child.Audio = function(_, config)
            local opts = config or {}
            local parent = opts.Parent or contentHolder
            if not parent then return end
            local title = opts.Name or opts.Title or "Audio"
            local subtitle = opts.SubName or opts.SubTitle or ""
            local src = opts.Audio or opts.Sound or ""
            local vol = (opts.Volume~=nil) and math.clamp(opts.Volume,0,10) or 0.5
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
            local function fmtTime(s) s = math.max(0, math.floor(s or 0)); return string.format("%d:%02d", math.floor(s/60), s%60) end

            local isHttp = type(src)=="string" and src:match("^https?://")
            local resolved = isHttp and resolve(src, true) or resolve(src, false)
            local pendingDownload = isHttp and (not resolved or resolved=="")
            local hasAudio = (resolved~=nil and resolved~="") or pendingDownload
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

            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, -16, 0, 118)
            wrap.BackgroundTransparency = 0.92
            wrap.BackgroundColor3 = CurrentTheme.Top
            wrap.BorderSizePixel = 0
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Top")
            local wrapStroke = Instance.new("UIStroke")
            wrapStroke.Thickness = 1
            wrapStroke.Color = CurrentTheme.Stroke
            wrapStroke.Transparency = 0.6
            wrapStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            wrapStroke.Parent = wrap
            table.insert(ThemeListeners, function() wrapStroke.Color = CurrentTheme.Stroke end)
            local wrapCorner = Instance.new("UICorner")
            wrapCorner.CornerRadius = UDim.new(0, 8)
            wrapCorner.Parent = wrap

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 10)
            padding.PaddingRight = UDim.new(0, 10)
            padding.PaddingTop = UDim.new(0, 10)
            padding.PaddingBottom = UDim.new(0, 10)
            padding.Parent = wrap

            local topRow = Instance.new("Frame")
            topRow.Size = UDim2.new(1,0,0,38)
            topRow.BackgroundTransparency = 1
            topRow.Parent = wrap

            local audioIcon = Instance.new("ImageLabel")
            audioIcon.Size = UDim2.fromOffset(20,20)
            audioIcon.Position = UDim2.new(0,0,0.5,0)
            audioIcon.AnchorPoint = Vector2.new(0,0.5)
            audioIcon.BackgroundTransparency = 1
            audioIcon.ZIndex = 2
            audioIcon.Parent = topRow
            AddToRegistry(audioIcon, "ImageColor3", hasAudio and "Accent" or "SubText")
            audioIcon.Image = "rbxassetid://10747376008"

            local titleHolder = Instance.new("Frame")
            titleHolder.Size = UDim2.new(1,-110,1,0)
            titleHolder.Position = UDim2.new(0,28,0,0)
            titleHolder.BackgroundTransparency = 1
            titleHolder.ZIndex = 2
            titleHolder.Parent = topRow

            local statusLbl = Instance.new("TextLabel")
            statusLbl.Size = UDim2.new(1,0,0,16)
            statusLbl.Position = UDim2.new(0,0,0,2)
            statusLbl.AnchorPoint = Vector2.new(0,0)
            statusLbl.BackgroundTransparency = 1
            statusLbl.Text = (title~="" and title) or (hasAudio and "Audio" or "No audio source")
            statusLbl.TextSize = 12
            statusLbl.Font = Enum.Font.GothamBold
            statusLbl.TextXAlignment = Enum.TextXAlignment.Left
            statusLbl.TextTruncate = Enum.TextTruncate.AtEnd
            statusLbl.ZIndex = 2
            statusLbl.Parent = titleHolder
            AddToRegistry(statusLbl, "TextColor3", hasAudio and "Text" or "SubText")

            local subtitleLbl = nil
            if subtitle~="" then
                subtitleLbl = Instance.new("TextLabel")
                subtitleLbl.Size = UDim2.new(1,0,0,13)
                subtitleLbl.Position = UDim2.new(0,0,0,20)
                subtitleLbl.AnchorPoint = Vector2.new(0,0)
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
            controls.Size = UDim2.new(0,116,1,0)
            controls.Position = UDim2.new(1,0,0,0)
            controls.AnchorPoint = Vector2.new(1,0)
            controls.BackgroundTransparency = 1
            controls.Visible = hasAudio
            controls.Parent = topRow
            local ctrlLayout = Instance.new("UIListLayout")
            ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
            ctrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            ctrlLayout.Padding = UDim.new(0,4)
            ctrlLayout.Parent = controls

            local function ctrlBtn(iconId, cb)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.fromOffset(24,24)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = 3
                btn.Parent = controls
                local ic = Instance.new("ImageLabel")
                ic.Size = UDim2.fromOffset(16,16)
                ic.Position = UDim2.new(0.5,0,0.5,0)
                ic.AnchorPoint = Vector2.new(0.5,0.5)
                ic.BackgroundTransparency = 1
                ic.ZIndex = 4
                ic.Parent = btn
                AddToRegistry(ic, "ImageColor3", "Text")
                local icons = {play="rbxassetid://10734923549", pause="rbxassetid://10734919336", stop="rbxassetid://10734972621", external="rbxassetid://10747366266", import="rbxassetid://10747366266"}
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
                    if snd then _doPlay(); return end
                    if pendingDownload then
                        _downloading = true
                        if win then win:Notification("Audio", "Downloading audio, please wait...", "Info", 4) end
                        task.spawn(function()
                            local got = resolve(src, false)
                            _downloading = false
                            if got and got~="" then
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
                    if snd then pcall(function() snd:Stop(); snd.TimePosition=0 end) end
                    playing = false
                    if playBtn then playBtn.Visible = true end
                    if pauseBtn then pauseBtn.Visible = false end
                end)
                local function toggleOutside()
                    playOutside = not playOutside
                    local iconName = playOutside and "external" or "import"
                    if outsideIco then outsideIco.Image = icons[iconName] or "rbxassetid://10747366266" end
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
                if outsideIco then outsideIco.Image = playOutside and "rbxassetid://10747366266" or "rbxassetid://10747366266" end
                if auto and snd then _doPlay() end
            end

            local seekRow = Instance.new("Frame")
            seekRow.Size = UDim2.new(1,0,0,24)
            seekRow.Position = UDim2.new(0,0,0,56)
            seekRow.BackgroundTransparency = 1
            seekRow.Visible = hasAudio
            seekRow.Parent = wrap

            local curLbl = Instance.new("TextLabel")
            curLbl.Size = UDim2.fromOffset(34,20)
            curLbl.Position = UDim2.new(0,0,0.5,0)
            curLbl.AnchorPoint = Vector2.new(0,0.5)
            curLbl.BackgroundTransparency = 1
            curLbl.Text = "0:00"
            curLbl.TextSize = 10
            curLbl.Font = Enum.Font.Gotham
            curLbl.TextXAlignment = Enum.TextXAlignment.Left
            curLbl.ZIndex = 3
            curLbl.Parent = seekRow
            AddToRegistry(curLbl, "TextColor3", "SubText")

            local durLbl = Instance.new("TextLabel")
            durLbl.Size = UDim2.fromOffset(34,20)
            durLbl.Position = UDim2.new(1,0,0.5,0)
            durLbl.AnchorPoint = Vector2.new(1,0.5)
            durLbl.BackgroundTransparency = 1
            durLbl.Text = "0:00"
            durLbl.TextSize = 10
            durLbl.Font = Enum.Font.Gotham
            durLbl.TextXAlignment = Enum.TextXAlignment.Right
            durLbl.ZIndex = 3
            durLbl.Parent = seekRow
            AddToRegistry(durLbl, "TextColor3", "SubText")

            local rail = Instance.new("Frame")
            rail.Size = UDim2.new(1,-76,0,4)
            rail.Position = UDim2.new(0,38,0.5,0)
            rail.AnchorPoint = Vector2.new(0,0.5)
            rail.BackgroundTransparency = 0.65
            rail.ZIndex = 2
            rail.Parent = seekRow
            AddToRegistry(rail, "BackgroundColor3", "SubText")
            Instance.new("UICorner", rail).CornerRadius = UDim.new(1,0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0,0,1,0)
            fill.BackgroundTransparency = 0
            fill.ZIndex = 3
            fill.Parent = rail
            AddToRegistry(fill, "BackgroundColor3", "Accent")
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(12,12)
            knob.Position = UDim2.new(0,0,0.5,0)
            knob.AnchorPoint = Vector2.new(0.5,0.5)
            knob.ZIndex = 4
            knob.Parent = rail
            AddToRegistry(knob, "BackgroundColor3", "Accent")
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

            local dragging = false
            local function seekTo(inputX)
                if not snd then return end
                local railX = rail.AbsolutePosition.X
                local railW = rail.AbsoluteSize.X
                if railW <= 0 then return end
                local pct = math.clamp((inputX - railX)/railW,0,1)
                local dur = snd.TimeLength or 0
                if dur > 0 then pcall(function() snd.TimePosition = pct * dur end) end
            end
            rail.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragging = true
                    seekTo(inp.Position.X)
                end
            end)
            rail.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
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
                local pct = dur > 0 and (pos/dur) or 0
                fill.Size = UDim2.new(pct,0,1,0)
                knob.Position = UDim2.new(pct,0,0.5,0)
            end)

            local mod = {Frame=wrap, Type="Audio", Sound=snd}
            function mod:Play() if snd then pcall(function() snd:Play() end) end end
            function mod:Pause() if snd then pcall(function() snd:Pause() end) end end
            function mod:Stop() if snd then pcall(function() snd:Stop() end) end end
            function mod:SetVolume(v) if snd then snd.Volume = math.clamp(v,0,10) end end
            function mod:SetAudio(src) local r=resolve(src); if snd then pcall(function() snd:Stop(); snd.SoundId = r end) else snd=initSound(r) end; hasAudio = r~=""; controls.Visible = hasAudio; seekRow.Visible = hasAudio; statusLbl.Text = hasAudio and (title or "Audio") or "No audio source"; if playBtn then playBtn.Visible = hasAudio end; if pauseBtn then pauseBtn.Visible = false end end
            function mod:SetAudioTitle(title, subtitle) statusLbl.Text = title or (hasAudio and "Audio" or "No audio source"); if subtitleLbl then subtitleLbl.Text = subtitle or ""; subtitleLbl.Visible = subtitle and subtitle~="" end end
            function mod:SetPlayOutside(enabled) playOutside = enabled; if snd then local wasPlaying=playing; pcall(function() snd:Stop() end); if enabled then snd.Parent=game:GetService("SoundService") else snd.Parent=workspace end; if wasPlaying then pcall(function() snd:Play() end) end end end
            function mod:Destroy() safeDisconnect(hbConn); if snd then pcall(function() snd:Stop(); snd:Destroy() end) end; wrap:Destroy() end
            return mod
        end

        -- ---------- Social ----------
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
            wrap.Parent = parent
            local wrapStroke = Instance.new("UIStroke")
            wrapStroke.Thickness = 1
            wrapStroke.Color = CurrentTheme.Stroke
            wrapStroke.Transparency = 0.6
            wrapStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            wrapStroke.Parent = wrap
            table.insert(ThemeListeners, function() wrapStroke.Color = CurrentTheme.Stroke end)
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = wrap

            local avatarBg = Instance.new("Frame")
            avatarBg.Size = UDim2.fromOffset(42,42)
            avatarBg.Position = UDim2.new(0, 11, 0.5, 0)
            avatarBg.AnchorPoint = Vector2.new(0,0.5)
            avatarBg.BackgroundColor3 = Color3.fromRGB(90,90,90)
            avatarBg.Parent = wrap
            avatarBg.ClipsDescendants = true
            local avatarCorner = Instance.new("UICorner")
            avatarCorner.CornerRadius = UDim.new(0, 8)
            avatarCorner.Parent = avatarBg

            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Size = UDim2.fromScale(1,1)
            avatarImg.BackgroundTransparency = 1
            avatarImg.Parent = avatarBg
            local avatarImgCorner = Instance.new("UICorner")
            avatarImgCorner.CornerRadius = UDim.new(0, 8)
            avatarImgCorner.Parent = avatarImg
            if avatarSrc ~= "" then
                avatarCorner.CornerRadius = UDim.new(1,0)
                avatarImgCorner.CornerRadius = UDim.new(1,0)
            end

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Text = displayName
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.BackgroundTransparency = 1
            nameLbl.Size = UDim2.new(1,-140,0,16)
            nameLbl.Position = UDim2.new(0,62,0,9)
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
                subNameLbl.Size = UDim2.new(1,-140,0,13)
                subNameLbl.Position = UDim2.new(0,62,0,27)
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
                platformLbl.Size = UDim2.new(1,-140,0,12)
                platformLbl.Position = UDim2.new(0,62,0, subName~="" and 42 or 27)
                platformLbl.Parent = wrap
                AddToRegistry(platformLbl, "TextColor3", "SubText")
            end

            if copyText ~= "" then
                local copyBtn = Instance.new("TextButton")
                copyBtn.Text = buttonText
                copyBtn.Size = UDim2.fromOffset(52,26)
                copyBtn.Position = UDim2.new(1,-11,0.5,0)
                copyBtn.AnchorPoint = Vector2.new(1,0.5)
                copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
                copyBtn.Font = Enum.Font.GothamBold
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
                if imgUrl and imgUrl~="" then
                    local ok, asset = pcall(function() return MediaManager:Image(imgUrl) end)
                    if ok and asset and asset~="" then
                        avatarImg.Image = asset
                        avatarCorner.CornerRadius = UDim.new(1,0)
                        avatarImgCorner.CornerRadius = UDim.new(1,0)
                    end
                end
            end)

            local mod = {Frame=wrap, Type="Social"}
            function mod:SetName(newName) displayName=tostring(newName or ""); local lbl=wrap:FindFirstChild("DisplayName"); if lbl then lbl.Text=displayName end end
            function mod:SetSubName(newSubName) subName=tostring(newSubName or ""); local existing=wrap:FindFirstChild("SubName"); if existing then existing:Destroy() end; if subName~="" then local newLbl=Instance.new("TextLabel"); newLbl.Name="SubName"; newLbl.Text=subName; newLbl.Font=Enum.Font.Gotham; newLbl.TextSize=11; newLbl.TextXAlignment=Enum.TextXAlignment.Left; newLbl.TextTruncate=Enum.TextTruncate.AtEnd; newLbl.BackgroundTransparency=1; newLbl.Size=UDim2.new(1,-140,0,13); newLbl.Position=UDim2.new(0,62,0,27); newLbl.Parent=wrap; AddToRegistry(newLbl, "TextColor3", "SubText") end end
            function mod:SetSmlName(newPlatform) platform=tostring(newPlatform or ""); local existing=wrap:FindFirstChild("PlatformLabel"); if existing then existing:Destroy() end; if platform~="" then local newLbl=Instance.new("TextLabel"); newLbl.Name="PlatformLabel"; newLbl.Text=platform; newLbl.Font=Enum.Font.Gotham; newLbl.TextSize=10; newLbl.TextTransparency=0.3; newLbl.TextXAlignment=Enum.TextXAlignment.Left; newLbl.BackgroundTransparency=1; newLbl.Size=UDim2.new(1,-140,0,12); newLbl.Position=UDim2.new(0,62,0, subName~="" and 42 or 27); newLbl.Parent=wrap; AddToRegistry(newLbl, "TextColor3", "SubText") end end
            function mod:SetLogo(newLogo) avatarSrc=tostring(newLogo or ""); if avatarSrc~="" then local imgUrl; if avatarSrc:match("^rbxassetid://") or avatarSrc:match("^rbxasset://") or avatarSrc:match("^http") then imgUrl=avatarSrc elseif tonumber(avatarSrc) then imgUrl="rbxassetid://"..avatarSrc end; if imgUrl then local ok, asset = pcall(function() return MediaManager:Image(imgUrl) end); if ok and asset and asset~="" then avatarImg.Image = asset end end end end
            function mod:SetCopy(newText) copyText=tostring(newText or ""); local existing=wrap:FindFirstChild("CopyButton"); if existing then existing:Destroy() end; if copyText~="" then local newBtn=Instance.new("TextButton"); newBtn.Name="CopyButton"; newBtn.Text=buttonText; newBtn.Size=UDim2.fromOffset(52,26); newBtn.Position=UDim2.new(1,-11,0.5,0); newBtn.AnchorPoint=Vector2.new(1,0.5); newBtn.TextColor3=Color3.fromRGB(255,255,255); newBtn.Font=Enum.Font.GothamBold; newBtn.TextSize=12; newBtn.Parent=wrap; AddToRegistry(newBtn, "BackgroundColor3", "Element"); local newCorner=Instance.new("UICorner"); newCorner.CornerRadius=UDim.new(0,8); newCorner.Parent=newBtn; local newStroke=Instance.new("UIStroke"); newStroke.Transparency=0.4; newStroke.Thickness=1; newStroke.Parent=newBtn; AddToRegistry(newStroke, "Color", "Stroke"); newBtn.MouseButton1Click:Connect(function() pcall(function() toclipboard(copyText) end) end) end end
            function mod:SetCbn(newText) buttonText=tostring(newText or "复制"); local btn=wrap:FindFirstChild("CopyButton"); if btn then btn.Text=buttonText end end
            function mod:Destroy() wrap:Destroy() end
            return mod
        end

        -- ---------- Paragraph ----------
        child.Paragraph = function(_, config)
            config = config or {}
            local title = config.Name or ""
            local content = config.Content or ""
            local parent = config.Parent or contentHolder

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 0)
            frame.AutomaticSize = Enum.AutomaticSize.Y
            frame.BackgroundTransparency = 1
            frame.Parent = parent

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = frame
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = CurrentTheme.Stroke
            stroke.Transparency = 0.6
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Parent = frame
            table.insert(ThemeListeners, function() stroke.Color = CurrentTheme.Stroke end)

            local labelHolder = Instance.new("Frame")
            labelHolder.Size = UDim2.new(1, -20, 0, 0)
            labelHolder.Position = UDim2.new(0, 10, 0, 0)
            labelHolder.BackgroundTransparency = 1
            labelHolder.AutomaticSize = Enum.AutomaticSize.Y
            labelHolder.Parent = frame

            local holderLayout = Instance.new("UIListLayout")
            holderLayout.Padding = UDim.new(0, 0)
            holderLayout.SortOrder = Enum.SortOrder.LayoutOrder
            holderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            holderLayout.Parent = labelHolder

            local padding = Instance.new("UIPadding")
            padding.PaddingTop = UDim.new(0, 8)
            padding.PaddingBottom = UDim.new(0, 8)
            padding.Parent = labelHolder

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 14)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamMedium
            titleLabel.Text = title
            titleLabel.TextSize = 13
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
            titleLabel.RichText = true
            titleLabel.Parent = labelHolder
            AddToRegistry(titleLabel, "TextColor3", "Text")

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, 0, 0, 14)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Font = Enum.Font.Gotham
            contentLabel.Text = content
            contentLabel.TextSize = 12
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.TextWrapped = true
            contentLabel.AutomaticSize = Enum.AutomaticSize.Y
            contentLabel.RichText = true
            contentLabel.Parent = labelHolder
            AddToRegistry(contentLabel, "TextColor3", "SubText")

            local locked = config.Locked == true
            local lockedTitle = config.LockedTitle or "Locked"
            local lockFrame, lockLabel = createLockOverlay(frame, lockedTitle)
            lockFrame.Visible = locked

            local self = {}
            function self.SetName(newTitle) titleLabel.Text = newTitle end
            function self.SetContent(newContent) contentLabel.Text = newContent end
            function self.SetVisible(state) frame.Visible = state end
            function self.Destroy() frame:Destroy() end
            function self.Lock(title) locked = true; lockFrame.Visible = true; if title then lockLabel.Text = title end end
            function self.Unlock() locked = false; lockFrame.Visible = false end
            function self.IsLocked() return locked end
            return self
        end

        -- ---------- Viewport ----------
        child.Viewport = function(_, config)
            local opts = config or {}
            local parent = opts.Parent or contentHolder
            if not parent then return end
            local height = opts.Height or 200
            local focused = (opts.Focused ~= false)
            local interactive = (opts.Interactive ~= false)
            local camera = opts.Camera or Instance.new("Camera")
            local obj = opts.Object
            local aspectRatio = opts.AspectRatio
            local radius = opts.Radius or 8
            assert(obj, "Viewport - Missing Object")

            local function parseRatio(r)
                if type(r)=="number" then return r end
                if type(r)=="string" then
                    local w,h = r:match("(%d+):(%d+)")
                    if w and h and tonumber(h)~=0 then return tonumber(w)/tonumber(h) end
                end
                return nil
            end

            local wrap = Instance.new("Frame")
            wrap.Size = UDim2.new(1, -16, 0, height)
            wrap.BackgroundTransparency = 0.92
            wrap.BackgroundColor3 = CurrentTheme.Main
            wrap.BorderSizePixel = 0
            wrap.ClipsDescendants = true
            wrap.Parent = parent
            AddToRegistry(wrap, "BackgroundColor3", "Main")
            local wrapStroke = Instance.new("UIStroke")
            wrapStroke.Thickness = 1
            wrapStroke.Color = CurrentTheme.Stroke
            wrapStroke.Transparency = 0.6
            wrapStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            wrapStroke.Parent = wrap
            table.insert(ThemeListeners, function() wrapStroke.Color = CurrentTheme.Stroke end)
            local wrapCorner = Instance.new("UICorner")
            wrapCorner.CornerRadius = UDim.new(0, radius)
            wrapCorner.Parent = wrap

            local ratioNum = parseRatio(aspectRatio)
            local function recalcAspect()
                if not ratioNum or ratioNum<=0 then return end
                local w = wrap.AbsoluteSize.X
                if w>0 then wrap.Size = UDim2.new(1, -16, 0, math.floor(w/ratioNum)) end
            end
            wrap:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcAspect)
            task.defer(recalcAspect)

            local bg = Instance.new("ImageLabel")
            bg.Size = UDim2.fromScale(1,1)
            bg.BackgroundTransparency = 0.1
            bg.BorderSizePixel = 0
            bg.Image = ""
            bg.BackgroundColor3 = Color3.fromRGB(15,15,20)
            bg.Parent = wrap
            local bgCorner = Instance.new("UICorner")
            bgCorner.CornerRadius = UDim.new(0, radius)
            bgCorner.Parent = bg
            AddToRegistry(bg, "BackgroundColor3", "Main")

            local vp = Instance.new("ViewportFrame")
            vp.Size = UDim2.fromScale(1,1)
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
                    if inst:IsA("ScrollingFrame") then return inst end
                    inst = inst.Parent
                end
                return nil
            end
            ScrollFrameRef = findScrollFrame(wrap)

            local function isMouseInViewport(pos)
                local ap = vp.AbsolutePosition
                local as = vp.AbsoluteSize
                return pos.X>=ap.X and pos.X<=ap.X+as.X and pos.Y>=ap.Y and pos.Y<=ap.Y+as.Y
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
            if focused then task.defer(focusCamera) end

            vp.MouseEnter:Connect(function()
                if interactive and ScrollFrameRef then ScrollFrameRef.ScrollingEnabled = false end
            end)
            vp.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                    if ScrollFrameRef then ScrollFrameRef.ScrollingEnabled = true end
                end
            end)
            vp.InputBegan:Connect(function(inp)
                if interactive then
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or (inp.UserInputType==Enum.UserInputType.Touch and not Pinching) then
                        Dragging = true
                        LastMousePos = inp.Position
                    end
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if interactive then
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if interactive and Dragging and not Pinching then
                    if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                        local delta = inp.Position - LastMousePos
                        LastMousePos = inp.Position
                        local pos = obj:GetPivot().Position
                        local ry = CFrame.fromAxisAngle(Vector3.new(0,1,0), -delta.X*0.02)
                        camera.CFrame = CFrame.new(pos) * ry * CFrame.new(-pos) * camera.CFrame
                        local rx = CFrame.fromAxisAngle(camera.CFrame.RightVector, -delta.Y*0.02)
                        local pitched = CFrame.new(pos) * rx * CFrame.new(-pos) * camera.CFrame
                        if pitched.UpVector.Y > 0.1 then camera.CFrame = pitched end
                        updateZoomValue()
                    end
                end
            end)
            vp.InputChanged:Connect(function(inp)
                if interactive then
                    if inp.UserInputType==Enum.UserInputType.MouseWheel then
                        if not isMouseInViewport(UserInputService:GetMouseLocation()) then return end
                        local zoom = inp.Position.Z * 2
                        camera.CFrame = camera.CFrame + camera.CFrame.LookVector * zoom
                        updateZoomValue()
                    end
                end
            end)
            UserInputService.TouchPinch:Connect(function(touches, scale, vel, state)
                if interactive then
                    if state==Enum.UserInputState.Begin then
                        local mid = (touches[1]+touches[2])/2
                        if not isMouseInViewport(mid) then return end
                        Pinching = true; Dragging = false
                        LastPinchDist = (touches[1]-touches[2]).Magnitude
                    elseif state==Enum.UserInputState.Change then
                        if not Pinching then return end
                        local cur = (touches[1]-touches[2]).Magnitude
                        local d = (cur - LastPinchDist) * 0.03
                        LastPinchDist = cur
                        camera.CFrame = camera.CFrame + camera.CFrame.LookVector * d
                        updateZoomValue()
                    elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then
                        Pinching = false
                    end
                end
            end)

            local self = {
                Frame=wrap, Type="Viewport", Object=obj, Camera=camera,
                Interactive=interactive, Height=height, Focused=focused, Value=nil
            }
            function self:SetObject(newObj, clone)
                if clone then newObj = newObj:Clone() end
                if self.Object then self.Object:Destroy() end
                self.Object = newObj
                self.Object.Parent = vp
                if self.Focused then focusCamera() end
            end
            function self:SetHeight(h) self.Height = h; wrap.Size = UDim2.new(1, -16, 0, h) end
            function self:SetAspectRatio(ratio) ratioNum = parseRatio(ratio); if ratioNum then recalcAspect() else wrap.Size = UDim2.new(1, -16, 0, self.Height) end end
            function self:Focus() if self.Object then focusCamera() end end
            function self:SetCamera(cam) self.Camera = cam; vp.CurrentCamera = cam end
            function self:SetInteractive(val) self.Interactive = val; vp.Active = val end
            function self:SetValue(dist) local ok, mpos = pcall(function() return self.Object:GetPivot().Position end); if not ok then return end; local dir = (self.Camera.CFrame.Position - mpos); if dir.Magnitude < 1e-4 then dir = Vector3.new(0,0,1) end; dir = dir.Unit; self.Camera.CFrame = CFrame.new(mpos + dir * dist, mpos); self.Value = dist end
            function self:Destroy() wrap:Destroy() end
            return self
        end

        -- ---------- Group ----------
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
            local mod = {Frame=outerWrap, Type="Group", Elements=elements}

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
                    if type(fn)=="function" and methodName~="Group" and methodName~="Section" then
                        colMethods[methodName] = makeColMethod(methodName)
                    end
                end
                setmetatable(colObj, {__index = colMethods})
                table.insert(elements, {Frame=el, ColObj=colObj})
                return colObj
            end

            function mod:Destroy() outerWrap:Destroy() end
            return mod
        end

        -- ========== 返回控件生成器 ==========
        return child
    end

    -- ========== 对外返回 ==========
    return createSection
end
-- ================================================================
-- 以上为新的 miUI 风格 Section 构建器，原 createSectionBuilder 已被完全替换。

-- ========== 窗口创建 ==========
function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Name or "FengYu"
    local Subtitle = Config.SubName
    local Keybind = Config.Keybind
    local IconAsset = Config.Logo
    local SceneId = Config.Scene  -- 默认为 nil，背景图空

    if Config.Theme then
        if type(Config.Theme)=="string" then
            if Themes[Config.Theme] then CurrentTheme = Themes[Config.Theme] end
        elseif type(Config.Theme)=="table" then
            local t = Config.Theme
            local function toC3(v)
                if type(v)=="table" then return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
                elseif type(v)=="userdata" then return v
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

    -- 通知容器
    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0,300,0,0)
    NotificationHolder.AutomaticSize = Enum.AutomaticSize.Y
    NotificationHolder.Position = UDim2.new(1,-20,1,-20)
    NotificationHolder.AnchorPoint = Vector2.new(1,1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.BorderSizePixel = 0
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 100
    local HolderList = Instance.new("UIListLayout")
    HolderList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    HolderList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HolderList.SortOrder = Enum.SortOrder.LayoutOrder
    HolderList.Padding = UDim.new(0,5)
    HolderList.Parent = NotificationHolder
    local HolderPadding = Instance.new("UIPadding")
    HolderPadding.PaddingRight = UDim.new(0,5)
    HolderPadding.PaddingBottom = UDim.new(0,5)
    HolderPadding.Parent = NotificationHolder

    -- 窗口大小固定为 500×320
    local FINAL_WIDTH = 500
    local FINAL_HEIGHT = 320

    -- 主窗口
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,0,0,0)
    MainFrame.Position = UDim2.new(0.5,0,0.5,0)
    MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    AddToRegistry(MainFrame, "BackgroundColor3", "Main")

    -- ===== [MOD] 移除原有的描边（UIStroke），替换为 miUI 风格的多层阴影，颜色改为黑色 =====
    local shadowStrokes = {}
    local thicknesses = {6, 5, 4, 3}
    for _, thick in ipairs(thicknesses) do
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = thick
        stroke.Color = Color3.new(0, 0, 0)  -- 黑色
        stroke.Transparency = 1
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = MainFrame
        table.insert(shadowStrokes, stroke)
    end

    local function setShadowVisible(visible, instant)
        local targetTrans = visible and 0.9 or 1
        for _, stroke in ipairs(shadowStrokes) do
            if instant then
                stroke.Transparency = targetTrans
            else
                Tween(stroke, {Transparency = targetTrans}, 0.3)
            end
        end
    end

    -- 背景图（默认为空）
    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "FluentBG"
    bgImage.Size = UDim2.new(1,0,1,0)
    bgImage.BackgroundTransparency = 1
    bgImage.ZIndex = 0
    bgImage.Parent = MainFrame
    Instance.new("UICorner", bgImage).CornerRadius = UDim.new(0,12)
    if SceneId then
        if type(SceneId)=="number" or (type(SceneId)=="string" and tonumber(SceneId)) then
            bgImage.Image = "rbxassetid://"..tostring(SceneId)
        else
            bgImage.Image = tostring(SceneId)
        end
    else
        bgImage.Image = ""
        bgImage.Visible = false
        bgImage.BackgroundTransparency = 1
    end

    -- 背景渐变
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

    -- Resizer (保留)
    local Resizer = Instance.new("TextButton")
    Resizer.Name = "WindowResizer"
    Resizer.Parent = MainFrame
    Resizer.BackgroundTransparency = 0.8
    Resizer.BackgroundColor3 = Color3.new(1,1,1)
    Resizer.Position = UDim2.new(1, 5, 1, 5)
    Resizer.Size = UDim2.new(0, 24, 0, 24)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.Text = ""
    Resizer.ZIndex = 30
    Resizer.Visible = false
    local resizerStroke = Instance.new("UIStroke")
    resizerStroke.Thickness = 4
    resizerStroke.Color = Color3.new(1,1,1)
    resizerStroke.Transparency = 0
    resizerStroke.Parent = Resizer
    local resizerCorner = Instance.new("UICorner")
    resizerCorner.CornerRadius = UDim.new(0, 6)
    resizerCorner.Parent = Resizer
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

    -- 背景模糊模块
    local function CreateBlurModule()
        if not MainFrame or not MainFrame.Parent then return end
        local Part = Instance.new("Part")
        Part.Name = "FengBlurPart"
        Part.Anchored = true
        Part.CanCollide = false
        Part.CanTouch = false
        Part.CastShadow = false
        Part.Material = Enum.Material.Glass
        Part.Transparency = 0.97
        Part.Reflectance = 0.8
        Part.Size = Vector3.new(1,1,1) * 0.01
        Part.Parent = workspace

        local DOF = DepthOfFieldEffect
        DOF.Enabled = true
        DOF.FarIntensity = 0
        DOF.FocusDistance = 0
        DOF.InFocusRadius = 1000
        DOF.NearIntensity = 1
        DOF.Parent = Lighting

        local function UpdateBlur()
            if not MainFrame.Visible then
                Part.Transparency = 1
                DOF.NearIntensity = 0
                return
            end
            local cam = Camera
            if not cam then return end
            local pos = MainFrame.AbsolutePosition
            local size = MainFrame.AbsoluteSize
            local corner0 = pos
            local corner1 = pos + size
            local ray0 = cam:ScreenPointToRay(corner0.X, corner0.Y, 1)
            local ray1 = cam:ScreenPointToRay(corner1.X, corner1.Y, 1)
            local planeOrigin = cam.CFrame.Position + cam.CFrame.LookVector * 0.05
            local planeNormal = cam.CFrame.LookVector

            local function getPos(origin, dir)
                local num = planeNormal:Dot(planeOrigin - origin)
                local den = planeNormal:Dot(dir)
                if math.abs(den) < 1e-8 then return origin end
                local t = num / den
                return origin + dir * t
            end

            local p0 = getPos(ray0.Origin, ray0.Direction)
            local p1 = getPos(ray1.Origin, ray1.Direction)
            local center = (p0 + p1) / 2
            local sizeVec = p1 - p0
            Part.CFrame = cam.CFrame
            local scale = sizeVec / 0.0101
            Part.Size = Vector3.new(1,1,1) * 0.01
            local mesh = Part:FindFirstChildOfClass("BlockMesh")
            if not mesh then
                mesh = Instance.new("BlockMesh")
                mesh.Parent = Part
            end
            mesh.Offset = cam.CFrame:PointToObjectSpace(center)
            mesh.Scale = scale
            Part.Transparency = 0.97
            DOF.NearIntensity = 1
        end

        local updateConn = RunService.RenderStepped:Connect(UpdateBlur)
        MainFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateBlur)
        local resizeConn = MainFrame:GetPropertyChangedSignal("Size"):Connect(UpdateBlur)
        local changeConn = MainFrame:GetPropertyChangedSignal("Position"):Connect(UpdateBlur)

        MainFrame.AncestryChanged:Connect(function(_, newParent)
            if not newParent then
                updateConn:Disconnect()
                resizeConn:Disconnect()
                changeConn:Disconnect()
                pcall(function() Part:Destroy() end)
                DOF.Enabled = false
            end
        end)
    end
    task.delay(0.3, function()
        if MainFrame and MainFrame.Parent then
            pcall(CreateBlurModule)
        end
    end)

    -- 左侧菜单（完整）
    local LeftMenuFrame = Instance.new("Frame")
    LeftMenuFrame.Size = UDim2.new(0, 175, 1, 0)
    LeftMenuFrame.BackgroundTransparency = 1
    LeftMenuFrame.BorderSizePixel = 0
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

    -- [MOD] 左侧滚动列表：位置紧贴分割线，高度精确填充
    local LeftScrollingFrame = Instance.new("ScrollingFrame")
    LeftScrollingFrame.Size = UDim2.new(1, -10, 1, -100)   -- 修改：减去头部50和底部50
    LeftScrollingFrame.Position = UDim2.new(0.5, 0, 0, 50) -- 修改：从50开始
    LeftScrollingFrame.AnchorPoint = Vector2.new(0.5, 0)
    LeftScrollingFrame.BackgroundTransparency = 1
    LeftScrollingFrame.ScrollBarThickness = 0
    LeftScrollingFrame.Parent = LeftMenuFrame
    local TabList = Instance.new("UIListLayout")
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 0)   -- 移除顶部边距
    TabList.Parent = LeftScrollingFrame
    local function updateTabCanvas()
        LeftScrollingFrame.CanvasSize = UDim2.new(0,0,0, TabList.AbsoluteContentSize.Y + 10)
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
    Instance.new("UICorner", AccountProfile).CornerRadius = UDim.new(1,0)
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
    local LineFrame_2 = Instance.new("Frame")
    LineFrame_2.Size = UDim2.new(1, -10, 0, 1)
    LineFrame_2.Position = UDim2.new(0.5, 0, 0, 0)
    LineFrame_2.AnchorPoint = Vector2.new(0.5, 0)
    LineFrame_2.BackgroundTransparency = 0.65
    LineFrame_2.BorderSizePixel = 0
    LineFrame_2.Parent = BottomFrame
    AddToRegistry(LineFrame_2, "BackgroundColor3", "Stroke")

    -- 右侧内容区
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

    -- 三按钮（与原来完全一致）
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
        accentGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, CurrentTheme.Accent), ColorSequenceKeypoint.new(1, CurrentTheme.Accent) })
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
            Tween(btn, { BackgroundTransparency = 0 }, 0.2)
            if content then
                local transProp = content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                Tween(content, { [transProp] = 0 }, 0.2)
            end
            Tween(accent, { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 }, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.2 }, 0.2)
            if content then
                local transProp = content:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
                Tween(content, { [transProp] = 0.3 }, 0.2)
            end
            Tween(accent, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.2)
        end)
        btn.MouseButton1Click:Connect(callback)
        table.insert(ThemeListeners, function()
            btn.BackgroundColor3 = CurrentTheme.Element or CurrentTheme.Top
            accent.BackgroundColor3 = CurrentTheme.Accent
            accentGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, CurrentTheme.Accent), ColorSequenceKeypoint.new(1, CurrentTheme.Accent) })
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

    -- 内容容器
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
        PageContainer.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 10)
    end
    PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePageCanvas)
    task.spawn(updatePageCanvas)

    -- 拖动
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

    -- 窗口动画与阴影联动
    local function AnimateWindowIn()
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, FINAL_WIDTH, 0, FINAL_HEIGHT)
        }):Play()
        setShadowVisible(true, false)
    end
    local function onWindowVisibilityChanged()
        if MainFrame.Visible then
            setShadowVisible(true, false)
        else
            setShadowVisible(false, false)
        end
    end
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(onWindowVisibilityChanged)
    task.delay(0.1, AnimateWindowIn)

    -- 浮动打开按钮
    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingOpenButton"
    OpenButton.Parent = ScreenGui
    OpenButton.BackgroundColor3 = CurrentTheme.Accent
    OpenButton.BackgroundTransparency = 0.85
    OpenButton.Position = UDim2.new(0.92,0,0.01,0)
    OpenButton.Size = UDim2.new(0,40,0,40)
    OpenButton.Active = true
    OpenButton.Draggable = true
    OpenButton.Image = "rbxassetid://84830962019412"
    OpenButton.ImageColor3 = Color3.fromRGB(255,255,255)
    OpenButton.ImageTransparency = 0.15
    OpenButton.ZIndex = 10
    Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(0,8)
    local openStroke = Instance.new("UIStroke")
    openStroke.Parent = OpenButton
    openStroke.Color = Color3.fromRGB(180,180,180)
    openStroke.Thickness = 1.2
    openStroke.Transparency = 0.4
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

    -- 键盘绑定
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- ===== Window:Category =====
    Window._currentCategory = nil
    function Window:Category(config)
        local name = type(config)=="table" and config.Name or config
        local collapsible = type(config)=="table" and config.Collapsible or false
        local opened = true
        if type(config)=="table" and config.Opened ~= nil then opened = config.Opened end
        local categoryFrame = Instance.new("Frame")
        categoryFrame.Size = UDim2.new(1,0,0,0)
        categoryFrame.AutomaticSize = Enum.AutomaticSize.Y
        categoryFrame.BackgroundTransparency = 1
        categoryFrame.Parent = LeftScrollingFrame
        local catLayout = Instance.new("UIListLayout")
        catLayout.FillDirection = Enum.FillDirection.Vertical
        catLayout.SortOrder = Enum.SortOrder.LayoutOrder
        catLayout.Padding = UDim.new(0,0)
        catLayout.Parent = categoryFrame
        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1,0,0,28)
        header.BackgroundTransparency = 1
        header.Text = name
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Font = Enum.Font.GothamBold
        header.TextSize = 13
        header.TextColor3 = CurrentTheme.Text
        header.TextTransparency = 0.5
        header.Parent = categoryFrame
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0,10)
        pad.Parent = header
        AddToRegistry(header, "TextColor3", "Text")
        local arrow = Instance.new("ImageLabel")
        arrow.Size = UDim2.new(0,12,0,12)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://8240930340"
        arrow.ImageColor3 = CurrentTheme.Text
        arrow.ImageTransparency = 0.3
        arrow.Visible = collapsible
        arrow.Rotation = opened and 0 or 180
        arrow.Parent = header
        arrow.AnchorPoint = Vector2.new(1,0.5)
        arrow.Position = UDim2.new(1,-10,0.5,0)
        AddToRegistry(arrow, "ImageColor3", "Text")
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1,0,0,0)
        content.BackgroundTransparency = 1
        content.AutomaticSize = Enum.AutomaticSize.None
        content.ClipsDescendants = true
        content.Visible = true
        content.Parent = categoryFrame
        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0,4)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentList.Parent = content
        local currentTween = nil
        local function getContentHeight() return contentList.AbsoluteContentSize.Y or 0 end
        local function setContentHeight(targetHeight, animate)
            targetHeight = math.max(0, targetHeight)
            local currentHeight = content.Size.Y.Offset
            if animate and currentHeight ~= targetHeight then
                if currentTween then currentTween:Cancel(); currentTween=nil end
                currentTween = TweenService:Create(content, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,targetHeight)})
                currentTween:Play()
                currentTween.Completed:Connect(function() currentTween=nil; task.spawn(updateTabCanvas) end)
            else
                content.Size = UDim2.new(1,0,0,targetHeight)
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
            content.Size = UDim2.new(1,0,0,initialHeight)
            updateTabCanvas()
        end)
        Window._currentCategory = {frame=categoryFrame, content=content, contentList=contentList, header=header, label=header, arrow=arrow, collapsible=collapsible, opened=opened, toggle=toggleCategory}
        table.insert(ThemeListeners, function() header.TextColor3=CurrentTheme.Text; arrow.ImageColor3=CurrentTheme.Text end)
        return Window._currentCategory
    end

    -- ===== Window:Tab (已移除指示标) =====
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

        -- 移除 TabBar 指示条

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
        glowGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1)})
        glowGrad.Parent = glowFrame

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
            if tonumber(icon) then TabIcon.Image = "rbxassetid://"..icon else TabIcon.Image = icon end
            TabIcon.Parent = ContentFrame
            AddToRegistry(TabIcon, "ImageColor3", "Text")
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 8)
            iconCorner.Parent = TabIcon
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

        local state = {isActive = false, btn = TabBtn, page = Page, textLabel = TabText, glow = glowFrame}  -- 移除 bar

        TabBtn.MouseButton1Click:Connect(function()
            if Window._activeTab and Window._activeTab == state then return end
            for _, s in ipairs(Window._tabs) do
                s.btn.BackgroundTransparency = 1
                s.isActive = false
                s.glow.BackgroundTransparency = 1
                local txt = s.textLabel
                if txt then Tween(txt, {TextTransparency = 0.3}, 0.2) end
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

        local function getElements()
            local elements = {}
            local createSection = createSectionBuilder(PageContent, PageContent, 330, 1, Window)
            elements.Section     = function(_, config) return createSection(config) end
            elements.Button      = function(_, config) return createSection("", nil, true).Button(config) end
            elements.Toggle      = function(_, config) return createSection("", nil, true).Toggle(config) end
            elements.Slider      = function(_, config) return createSection("", nil, true).Slider(config) end
            elements.Dropdown    = function(_, config) return createSection("", nil, true).Dropdown(config) end
            elements.Keybind     = function(_, config) return createSection("", nil, true).Keybind(config) end
            elements.Textbox     = function(_, config) return createSection("", nil, true).Textbox(config) end
            elements.Input       = function(_, config) return createSection("", nil, true).Input(config) end
            elements.Label       = function(_, config) return createSection("", nil, true).Label(config) end
            elements.Image       = function(_, config) return createSection("", nil, true).Image(config) end
            elements.Divider     = function(_, config) return createSection("", nil, true).Divider(config) end
            elements.Space       = function(_, config) return createSection("", nil, true).Space(config) end
            elements.Checkbox    = function(_, config) return createSection("", nil, true).Checkbox(config) end
            elements.ProgressBar = function(_, config) return createSection("", nil, true).ProgressBar(config) end
            elements.Video       = function(_, config) return createSection("", nil, true).Video(config) end
            elements.Audio       = function(_, config) return createSection("", nil, true).Audio(config) end
            elements.Viewport    = function(_, config) return createSection("", nil, true).Viewport(config) end
            elements.Social      = function(_, config) return createSection("", nil, true).Social(config) end
            elements.Paragraph   = function(_, config) return createSection("", nil, true).Paragraph(config) end
            elements.Group       = function(_, config) return createSection("", nil, true).Group(config) end
            return elements
        end
        return getElements()
    end

    -- ===== TabDivider =====
    function Window:TabDivider()
        local parentContainer = LeftScrollingFrame
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
        table.insert(ThemeListeners, function() line.BackgroundColor3 = CurrentTheme.Stroke end)
    end

    -- ===== Dialog =====
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
        Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
        Overlay.BackgroundTransparency = 1
        Overlay.BorderSizePixel = 0
        Overlay.Size = UDim2.fromScale(1,1)
        Overlay.ZIndex = 180
        Overlay.Active = true
        Panel.Name = "DialogPanel"
        Panel.Parent = Overlay
        Panel.AnchorPoint = Vector2.new(0.5,0.5)
        Panel.Position = UDim2.fromScale(0.5,0.5)
        Panel.BackgroundColor3 = Color3.fromRGB(13,17,22)
        Panel.BackgroundTransparency = 1
        Panel.BorderSizePixel = 0
        Panel.ClipsDescendants = true
        Panel.Size = UDim2.new(0, 365, 0, 188)
        Panel.ZIndex = 181
        UICorner.CornerRadius = UDim.new(0,12)
        UICorner.Parent = Panel
        UIStroke.Transparency = 1
        UIStroke.Color = Color3.fromRGB(45,48,58)
        UIStroke.Parent = Panel
        Title.Name = "DialogTitle"
        Title.Parent = Panel
        Title.BackgroundTransparency = 1
        Title.BorderSizePixel = 0
        Title.Position = UDim2.new(0, 18, 0, 18)
        Title.Size = UDim2.new(1, -36, 0, 21)
        Title.ZIndex = 183
        Title.Font = Enum.Font.GothamBold
        Title.Text = Config.Title or "Dialog"
        Title.TextColor3 = Color3.fromRGB(255,255,255)
        Title.TextTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        AddToRegistry(Title, "TextColor3", "Text")
        Content.Name = "DialogContent"
        Content.Parent = Panel
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.Position = UDim2.new(0, 18, 0, 48)
        Content.Size = UDim2.new(1, -36, 0, 76)
        Content.ZIndex = 183
        Content.Font = Enum.Font.GothamMedium
        Content.Text = Config.Content or ""
        Content.TextColor3 = Color3.fromRGB(255,255,255)
        Content.TextTransparency = 1
        Content.TextWrapped = true
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.TextYAlignment = Enum.TextYAlignment.Top
        AddToRegistry(Content, "TextColor3", "Text")
        Divider.Name = "DialogDivider"
        Divider.Parent = Panel
        Divider.BackgroundColor3 = Color3.fromRGB(45,48,58)
        Divider.BackgroundTransparency = 1
        Divider.BorderSizePixel = 0
        Divider.Position = UDim2.new(0, 14, 1, -54)
        Divider.Size = UDim2.new(1, -28, 0, 1)
        Divider.ZIndex = 182
        AddToRegistry(Divider, "BackgroundColor3", "Stroke")
        ButtonHolder.Name = "DialogButtonHolder"
        ButtonHolder.Parent = Panel
        ButtonHolder.AnchorPoint = Vector2.new(1,1)
        ButtonHolder.BackgroundTransparency = 1
        ButtonHolder.BorderSizePixel = 0
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
            Tween(Overlay, {BackgroundTransparency=1}, 0.15)
            Tween(Panel, {BackgroundTransparency=1, Size=UDim2.new(0,365,0,188)}, 0.15)
            task.delay(0.2, function() Overlay:Destroy() end)
            pcall(Config.Callback, Result)
            return Result
        end

        local function AddDialogButton(Text, Primary, Callback)
            local Button = Instance.new("Frame")
            Button.Parent = ButtonHolder
            Button.BackgroundColor3 = Primary and CurrentTheme.Accent or Color3.fromRGB(26,28,36)
            Button.BackgroundTransparency = 1
            Button.BorderSizePixel = 0
            Button.ClipsDescendants = true
            Button.Size = UDim2.new(0, math.max(78, TextService:GetTextSize(Text, 12, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge)).X + 32), 0, 32)
            Button.ZIndex = 183
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0,7)
            Corner.Parent = Button
            local Stroke = Instance.new("UIStroke")
            Stroke.Transparency = 1
            Stroke.Color = Primary and CurrentTheme.Accent or Color3.fromRGB(45,48,58)
            Stroke.Parent = Button
            local Label = Instance.new("TextLabel")
            Label.Parent = Button
            Label.BackgroundTransparency = 1
            Label.BorderSizePixel = 0
            Label.Size = UDim2.fromScale(1,1)
            Label.ZIndex = 184
            Label.Font = Primary and Enum.Font.GothamBold or Enum.Font.GothamMedium
            Label.Text = Text
            Label.TextColor3 = Color3.fromRGB(255,255,255)
            Label.TextSize = 12
            Label.TextTransparency = 1
            AddToRegistry(Label, "TextColor3", "Text")
            local Input = Instance.new("TextButton")
            Input.Size = UDim2.fromScale(1,1)
            Input.BackgroundTransparency = 1
            Input.Text = ""
            Input.Parent = Button
            Input.MouseButton1Click:Connect(function()
                local Result = Callback and Callback() or Text
                Dialog:Close(Result)
            end)
            Input.MouseEnter:Connect(function()
                Tween(Button, {BackgroundTransparency = Primary and 0 or 0.080}, 0.15)
            end)
            Input.MouseLeave:Connect(function()
                Tween(Button, {BackgroundTransparency = Primary and 0.100 or 0.250}, 0.15)
            end)
            Tween(Button, {BackgroundTransparency = Primary and 0.100 or 0.250}, 0.1)
            Tween(Stroke, {Transparency = Primary and 1 or 0.650}, 0.1)
            Tween(Label, {TextTransparency = 0}, 0.1)
            table.insert(ThemeListeners, function()
                Button.BackgroundColor3 = Primary and CurrentTheme.Accent or Color3.fromRGB(26,28,36)
                Stroke.Color = Primary and CurrentTheme.Accent or Color3.fromRGB(45,48,58)
            end)
        end

        local Buttons = Config.Buttons or {{Text="OK", Primary=true}}
        for _, BtnConfig in ipairs(Buttons) do
            AddDialogButton(BtnConfig.Text, BtnConfig.Primary, BtnConfig.Callback)
        end

        Tween(Overlay, {BackgroundTransparency=0.280}, 0.25)
        Tween(Panel, {BackgroundTransparency=0.025, Size=UDim2.new(0, 392, 0, 200)}, 0.25)
        Tween(UIStroke, {Transparency=0.650}, 0.25)
        Tween(Title, {TextTransparency=0}, 0.25)
        Tween(Content, {TextTransparency=0.250}, 0.25)
        Tween(Divider, {BackgroundTransparency=0.720}, 0.25)
        return Dialog
    end

    -- ===== Notification =====
    function Window:Notification(titleText, descText, notifType, duration)
        -- 保持原有实现（此处略，可按需要添加）
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    function Window:SetSubtitle(newSubtitle)
        WindowContent.Text = newSubtitle or ""
    end

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
    cursorRoot.BorderSizePixel = 0
    cursorRoot.Size = UDim2.new(0,20,0,20)
    cursorRoot.ZIndex = 2147483647
    cursorRoot.Visible = false
    cursorRoot.Parent = cursorScreen

    local img = Instance.new("ImageLabel")
    img.Name = "CursorImage"
    img.BackgroundTransparency = 1
    img.Size = UDim2.new(1,0,1,0)
    img.BorderSizePixel = 0
    img.Image = "rbxassetid://132511743665753"
    img.ImageColor3 = Color3.fromRGB(90,165,255)
    img.ScaleType = Enum.ScaleType.Fit
    img.Rotation = -90
    img.AnchorPoint = Vector2.new(0,0)
    img.Position = UDim2.new(0,0,0,0)
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