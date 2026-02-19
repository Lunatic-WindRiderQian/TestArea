local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local LocalPlayer = Players.LocalPlayer

local Library = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local SFXEnabled = true
local Registry = {} 
local ConfigObjects = {} 

-- SFX
local Sounds = {
    Hover = "rbxassetid://4510086912",
    Click = "rbxassetid://4510086561",
    ToggleOn = "rbxassetid://4510087425",
    ToggleOff = "rbxassetid://4510087425",
    Slide = "rbxassetid://4510087798",
    Notification = "rbxassetid://4590657391",
    Back = "rbxassetid://4510087236",
    Error = "rbxassetid://4510087545",
    Tab = "rbxassetid://4510087056" 
}

local function PlaySound(id)
    if not SFXEnabled then return end
    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = 1
        s.Parent = SoundService
        s:Play()
        game.Debris:AddItem(s, 2)
    end)
end

-- THEMES
local Themes = {
    Dark   = {Main = Color3.fromRGB(25, 25, 25), Top = Color3.fromRGB(35, 35, 35), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(114, 137, 218), Stroke = Color3.fromRGB(60, 60, 60)},
    White  = {Main = Color3.fromRGB(240, 240, 240), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(0, 120, 215), Stroke = Color3.fromRGB(200, 200, 200)},
    Purple = {Main = Color3.fromRGB(30, 25, 35), Top = Color3.fromRGB(40, 30, 45), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(170, 0, 255), Stroke = Color3.fromRGB(80, 40, 80)},
    Blue   = {Main = Color3.fromRGB(20, 25, 40), Top = Color3.fromRGB(30, 35, 50), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 100, 255), Stroke = Color3.fromRGB(40, 50, 80)},
    Red    = {Main = Color3.fromRGB(35, 20, 20), Top = Color3.fromRGB(45, 25, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 50, 50), Stroke = Color3.fromRGB(80, 40, 40)},
    Yellow = {Main = Color3.fromRGB(35, 35, 20), Top = Color3.fromRGB(45, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 200, 50), Stroke = Color3.fromRGB(80, 80, 40)},
    Green  = {Main = Color3.fromRGB(20, 35, 20), Top = Color3.fromRGB(25, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 200, 100), Stroke = Color3.fromRGB(40, 80, 40)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeIndex)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeIndex})
    obj[prop] = CurrentTheme[themeIndex]
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, reg in pairs(Registry) do
            if reg.Object then
                Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]})
            end
        end
    end
end

-- RAINBOW
function Library:ToggleRainbow(bool) RainbowEnabled = bool end
function Library:SetRainbowType(val) RainbowType = val end

-- SFX CONTROL (public method)
function Library:SetSFXEnabled(state)
    SFXEnabled = state
end

function Library:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "M0dzn UI"
    local Keybind = Config.Keybind 
    
    Window.RootFolder = Title 
    Window.ConfigFolder = Title.."/Config"
    -- Window.CurrentConfig = ""   -- 已移除（由 Config 标签页使用）

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "M0dznLib_V1.2"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 0, 0, 0) 
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
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
                local t = tick()
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

    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.Parent = MainFrame
    Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)
    AddToRegistry(Topbar, "BackgroundColor3", "Top")

    local Fix = Instance.new("Frame")
    Fix.Size = UDim2.new(1, 0, 0, 10)
    Fix.Position = UDim2.new(0, 0, 1, -10)
    Fix.BorderSizePixel = 0
    Fix.Parent = Topbar
    AddToRegistry(Fix, "BackgroundColor3", "Top")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar
    AddToRegistry(TitleLabel, "TextColor3", "Text")

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -55)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(0, 140, 0.85, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Content
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 140, 0, 35)
    ProfileFrame.Position = UDim2.new(0, 0, 1, -35)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Content
    
    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 30, 0, 30)
    Avatar.Position = UDim2.new(0, 0, 0.5, -15)
    Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Avatar.Parent = ProfileFrame
    Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)
    
    local DispName = Instance.new("TextLabel"); DispName.Text = LocalPlayer.DisplayName; DispName.Size = UDim2.new(1, -35, 0, 15); DispName.Position = UDim2.new(0, 35, 0, 2); DispName.BackgroundTransparency = 1; DispName.Font = Enum.Font.GothamBold; DispName.TextSize = 12; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.Parent = ProfileFrame; AddToRegistry(DispName, "TextColor3", "Text")
    local UsrName = Instance.new("TextLabel"); UsrName.Text = "@"..LocalPlayer.Name; UsrName.Size = UDim2.new(1, -35, 0, 15); UsrName.Position = UDim2.new(0, 35, 0, 16); UsrName.BackgroundTransparency = 1; UsrName.Font = Enum.Font.Gotham; UsrName.TextSize = 11; UsrName.TextTransparency = 0.4; UsrName.TextXAlignment = Enum.TextXAlignment.Left; UsrName.Parent = ProfileFrame; AddToRegistry(UsrName, "TextColor3", "Text")

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 1, 1, 0)
    Line.Position = UDim2.new(0, 145, 0, 0)
    Line.Parent = Content
    AddToRegistry(Line, "BackgroundColor3", "Stroke")

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -155, 1, 0)
    PageContainer.Position = UDim2.new(0, 155, 0, 0)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Content

    -- 窗口展开动画（尺寸 450×280）
    Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.6)

    local dragging, dragInput, dragStart, startPos
    Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
    Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.2)
        end
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            MainFrame.Visible = not MainFrame.Visible
            if MainFrame.Visible then 
                MainFrame.Size = UDim2.new(0,0,0,0)
                Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.4)
            end
        end
    end)

    function Window:Notification(text)
        task.spawn(function()
            PlaySound(Sounds.Notification)
            local Notif = Instance.new("Frame"); Notif.ZIndex = 100; Notif.Size = UDim2.new(0, 250, 0, 45); Notif.Position = UDim2.new(1, 20, 1, -60); Notif.Parent = ScreenGui; AddToRegistry(Notif, "BackgroundColor3", "Top"); Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
            local NStroke = Instance.new("UIStroke"); NStroke.Parent = Notif; AddToRegistry(NStroke, "Color", "Accent")
            local NText = Instance.new("TextLabel"); NText.ZIndex = 101; NText.Text = text; NText.Size = UDim2.new(1,0,1,0); NText.BackgroundTransparency = 1; NText.Parent = Notif; NText.Font = Enum.Font.GothamBold; NText.TextSize = 14; AddToRegistry(NText, "TextColor3", "Text")
            Tween(Notif, {Position = UDim2.new(1, -270, 1, -60)}, 0.5); task.wait(3); Tween(Notif, {Position = UDim2.new(1, 20, 1, -60)}, 0.5); task.wait(0.5); Notif:Destroy()
        end)
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end

    local firstTab = true
    function Window:Tab(name, icon)
        icon = icon or "rbxassetid://84830962019412" -- 默认图标

        -- 创建标签容器
        local TabContainerItem = Instance.new("Frame")
        TabContainerItem.Size = UDim2.new(1, 0, 0, 32)
        TabContainerItem.BackgroundTransparency = 1
        TabContainerItem.BackgroundColor3 = Color3.new(1,1,1) -- 占位
        TabContainerItem.Parent = TabContainer
        Instance.new("UICorner", TabContainerItem).CornerRadius = UDim.new(0, 6)

        -- 图标
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 5, 0.5, -10)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = icon
        TabIcon.ImageColor3 = Color3.fromRGB(150,150,150) -- 默认灰色
        TabIcon.Parent = TabContainerItem

        -- 文字
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -30, 1, 0)
        TabLabel.Position = UDim2.new(0, 30, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextColor3 = Color3.fromRGB(150,150,150)
        TabLabel.TextSize = 14
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabContainerItem

        -- 点击区域
        local TabHitbox = Instance.new("TextButton")
        TabHitbox.Size = UDim2.new(1, 0, 1, 0)
        TabHitbox.BackgroundTransparency = 1
        TabHitbox.Text = ""
        TabHitbox.Parent = TabContainerItem

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageList = Instance.new("UIListLayout")
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Parent = Page
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 10) end)

        -- 存储页面引用
        TabContainerItem.Page = Page

        TabHitbox.MouseButton1Click:Connect(function()
            PlaySound(Sounds.Tab) 
            -- 隐藏所有页面
            for _, v in pairs(PageContainer:GetChildren()) do
                v.Visible = false
            end
            -- 重置所有标签样式
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("Frame") and v ~= TabContainerItem then
                    Tween(v, {BackgroundTransparency = 1}, 0.3)
                    local iconImg = v:FindFirstChildOfClass("ImageLabel")
                    if iconImg then
                        Tween(iconImg, {ImageColor3 = Color3.fromRGB(150,150,150)}, 0.3)
                    end
                    local textLbl = v:FindFirstChildOfClass("TextLabel")
                    if textLbl then
                        Tween(textLbl, {TextColor3 = Color3.fromRGB(150,150,150)}, 0.3)
                    end
                end
            end
            -- 设置当前标签样式
            Page.Visible = true
            Tween(TabContainerItem, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent}, 0.3)
            Tween(TabIcon, {ImageColor3 = CurrentTheme.Text}, 0.3)
            Tween(TabLabel, {TextColor3 = CurrentTheme.Text}, 0.3)
        end)

        if firstTab then
            firstTab = false
            Page.Visible = true
            TabContainerItem.BackgroundTransparency = 0.9
            TabContainerItem.BackgroundColor3 = CurrentTheme.Accent
            TabIcon.ImageColor3 = CurrentTheme.Text
            TabLabel.TextColor3 = CurrentTheme.Text
        end

        if name == "Config" then TabContainerItem.LayoutOrder = 99998 end
        if name == "Settings" then TabContainerItem.LayoutOrder = 99999 end

        local Elements = {}

        function Elements:Section(text)
            local SectionHeader = Instance.new("Frame")
            SectionHeader.Size = UDim2.new(1, 0, 0, 24)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Parent = Page

            local SectionIcon = Instance.new("ImageLabel")
            SectionIcon.Size = UDim2.new(0, 16, 0, 16)
            SectionIcon.Position = UDim2.new(0, 4, 0.5, -8)
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Image = "rbxassetid://84830962019412"
            SectionIcon.Parent = SectionHeader
            AddToRegistry(SectionIcon, "ImageColor3", "Accent") -- 图标颜色随主题强调色

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -24, 1, 0)
            SectionLabel.Position = UDim2.new(0, 24, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = text
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextSize = 12
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionHeader
            AddToRegistry(SectionLabel, "TextColor3", "Accent") -- 文字颜色也是 Accent
        end

        function Elements:Value(text, default, callback)
            local ValFrame = Instance.new("Frame")
            ValFrame.Size = UDim2.new(1,0,0,35)
            ValFrame.Parent = Page
            Instance.new("UICorner", ValFrame).CornerRadius = UDim.new(0, 6)
            AddToRegistry(ValFrame, "BackgroundColor3", "Top")
            
            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = text
            NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
            NameLbl.Position = UDim2.new(0, 10, 0, 0)
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Font = Enum.Font.Gotham
            NameLbl.TextSize = 14
            NameLbl.BackgroundTransparency = 1
            NameLbl.Parent = ValFrame
            AddToRegistry(NameLbl, "TextColor3", "Text")
            
            local ValBox = Instance.new("TextBox")
            ValBox.Text = tostring(default)
            ValBox.Size = UDim2.new(0.3, 0, 0, 26)
            ValBox.Position = UDim2.new(0.7, -10, 0.5, -13)
            ValBox.Font = Enum.Font.GothamBold
            ValBox.TextSize = 13
            ValBox.TextXAlignment = Enum.TextXAlignment.Center
            ValBox.Parent = ValFrame
            Instance.new("UICorner", ValBox).CornerRadius = UDim.new(0, 5)
            AddToRegistry(ValBox, "BackgroundColor3", "Main")
            AddToRegistry(ValBox, "TextColor3", "Accent")

            ValBox.FocusLost:Connect(function()
                PlaySound(Sounds.Click)
                ConfigObjects[text] = {Type = "Value", Value = ValBox.Text}
                if callback then callback(ValBox.Text) end
                Window:Notification(text..": "..ValBox.Text)
            end)

            ConfigObjects[text] = {Type = "Value", Value = default, Set = function(val) ValBox.Text = val end}
        end

        function Elements:Keybind(text, default, callback)
            local Key = default or Enum.KeyCode.M
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Text = ""; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Title = Instance.new("TextLabel"); Title.Text = text; Title.Size = UDim2.new(0.6, 0, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.Gotham; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Btn; AddToRegistry(Title, "TextColor3", "Text")
            local KeyLabel = Instance.new("TextLabel"); KeyLabel.Text = Key.Name; KeyLabel.Size = UDim2.new(0, 80, 0, 24); KeyLabel.Position = UDim2.new(1, -90, 0.5, -12); KeyLabel.Font = Enum.Font.GothamBold; KeyLabel.TextSize = 13; KeyLabel.Parent = Btn; Instance.new("UICorner", KeyLabel).CornerRadius = UDim.new(0, 5); AddToRegistry(KeyLabel, "BackgroundColor3", "Main"); AddToRegistry(KeyLabel, "TextColor3", "Accent")

            Btn.MouseButton1Click:Connect(function()
                PlaySound(Sounds.Click); KeyLabel.Text = "..."; local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= "Unknown" then 
                    Key = input.KeyCode; 
                    KeyLabel.Text = Key.Name; 
                    ConfigObjects[text] = {Type = "Keybind", Value = Key.Name}; 
                    callback(Key)
                    Window:Notification("Keybind: "..Key.Name)
                else 
                    KeyLabel.Text = Key.Name 
                end
            end)
            ConfigObjects[text] = {Type = "Keybind", Value = Key.Name, Set = function(val) Key = Enum.KeyCode[val] or Key; KeyLabel.Text = Key.Name; callback(Key) end}
        end

        function Elements:Button(text, callback)
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 35); Btn.Text = text; Btn.Font = Enum.Font.Gotham; Btn.TextSize = 14; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6); AddToRegistry(Btn, "BackgroundColor3", "Top"); AddToRegistry(Btn, "TextColor3", "Text")
            Btn.MouseButton1Click:Connect(function() PlaySound(Sounds.Click); Tween(Btn, {Size = UDim2.new(0.95, 0, 0, 32)}, 0.1); task.wait(0.1); Tween(Btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1); callback() end)
        end

        function Elements:Toggle(text, default, callback)
            local Enabled = default or false
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, 0, 0, 35); Btn.Text = ""; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Title = Instance.new("TextLabel"); Title.Text = text; Title.Size = UDim2.new(0.7,0,1,0); Title.Position = UDim2.new(0,10,0,0); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.Gotham; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = Btn; AddToRegistry(Title, "TextColor3", "Text")
            local Switch = Instance.new("Frame"); Switch.Size = UDim2.new(0,40,0,20); Switch.Position = UDim2.new(1,-50,0.5,-10); Switch.Parent = Btn; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0); Switch.BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)
            local Dot = Instance.new("Frame"); Dot.Size = UDim2.new(0,16,0,16); Dot.Position = Enabled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8); Dot.BackgroundColor3 = Color3.new(1,1,1); Dot.Parent = Switch; Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

            local function Update()
                if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end
                Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)})
                Tween(Dot, {Position = Enabled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)})
                ConfigObjects[text].Value = Enabled
                callback(Enabled)
                Window:Notification(text..": "..tostring(Enabled))
            end

            Btn.MouseButton1Click:Connect(function() Enabled = not Enabled; Update() end)
            ConfigObjects[text] = {Type = "Toggle", Value = Enabled, Set = function(val) Enabled = val; Tween(Switch, {BackgroundColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60,60,60)}); Tween(Dot, {Position = Enabled and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}); callback(Enabled) end}
        end

        function Elements:Slider(text, min, max, default, callback)
            local Val = default or min
            local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,0,0,50); Frame.Parent = Page; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6); AddToRegistry(Frame, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,-20,0,20); Lbl.Position = UDim2.new(0,10,0,5); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame; AddToRegistry(Lbl, "TextColor3", "Text")
            local Num = Instance.new("TextLabel"); Num.Text = tostring(Val); Num.Size = UDim2.new(0,40,0,20); Num.Position = UDim2.new(1,-50,0,5); Num.BackgroundTransparency = 1; Num.TextColor3 = Color3.fromRGB(150,150,150); Num.Font = Enum.Font.Gotham; Num.TextSize = 12; Num.Parent = Frame
            local Bar = Instance.new("TextButton"); Bar.Text = ""; Bar.Size = UDim2.new(1,-20,0,6); Bar.Position = UDim2.new(0,10,0,35); Bar.BackgroundColor3 = Color3.fromRGB(60,60,60); Bar.AutoButtonColor = false; Bar.Parent = Frame; Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
            local Fill = Instance.new("Frame"); Fill.Size = UDim2.new((Val-min)/(max-min),0,1,0); Fill.Parent = Bar; Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0); AddToRegistry(Fill, "BackgroundColor3", "Accent")

            local function Update(val_new)
                Val = val_new
                local p = (Val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(p,0,1,0)}, 0.1)
                Num.Text = tostring(Val)
                ConfigObjects[text].Value = Val
                callback(Val)
            end

            local function Drag(input)
                local p = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + ((max - min) * p))
                Update(newVal)
            end

            local sliding
            Bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=true; PlaySound(Sounds.Slide); Drag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
            UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then Drag(i) end end)
            ConfigObjects[text] = {Type = "Slider", Value = Val, Set = function(val) Update(val) end}
        end

        function Elements:Textbox(text, placeholder, callback)
            local Frame = Instance.new("Frame"); Frame.Size = UDim2.new(1,0,0,60); Frame.Parent = Page; Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6); AddToRegistry(Frame, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,0,0,20); Lbl.Position = UDim2.new(0,10,0,5); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Frame; AddToRegistry(Lbl, "TextColor3", "Text")
            local Box = Instance.new("TextBox"); Box.Size = UDim2.new(1,-20,0,25); Box.Position = UDim2.new(0,10,0,28); Box.Text = ""; Box.PlaceholderText = placeholder; Box.Font = Enum.Font.Gotham; Box.TextSize = 13; Box.Parent = Frame; Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4); AddToRegistry(Box, "BackgroundColor3", "Main"); AddToRegistry(Box, "TextColor3", "Text")
            
            Box.FocusLost:Connect(function() 
                ConfigObjects[text].Value = Box.Text
                callback(Box.Text) 
            end)
            ConfigObjects[text] = {Type = "Textbox", Value = "", Set = function(val) Box.Text = val; callback(val) end}
        end

        function Elements:Dropdown(text, options, callback)
            local Dropped = false
            local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,0,35); Btn.Text = ""; Btn.Parent = Page; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6); AddToRegistry(Btn, "BackgroundColor3", "Top")
            local Lbl = Instance.new("TextLabel"); Lbl.Text = text; Lbl.Size = UDim2.new(1,-30,1,0); Lbl.Position = UDim2.new(0,10,0,0); Lbl.BackgroundTransparency = 1; Lbl.Font = Enum.Font.Gotham; Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Parent = Btn; AddToRegistry(Lbl, "TextColor3", "Text")
            local Icon = Instance.new("ImageLabel"); Icon.Image = "rbxassetid://6031091004"; Icon.Size = UDim2.new(0,20,0,20); Icon.Position = UDim2.new(1,-30,0.5,-10); Icon.BackgroundTransparency = 1; Icon.Parent = Btn
            
            local Container = Instance.new("Frame"); Container.Size = UDim2.new(1,0,0,0); Container.Visible = false; Container.ClipsDescendants = true; Container.Parent = Page; Instance.new("UICorner", Container).CornerRadius = UDim.new(0,6); AddToRegistry(Container, "BackgroundColor3", "Top")
            local List = Instance.new("UIListLayout"); List.SortOrder = Enum.SortOrder.LayoutOrder; List.Parent = Container

            local function Select(opt)
                Dropped = false; Lbl.Text = text..": "..opt; 
                ConfigObjects[text].Value = opt
                callback(opt)
                Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2); Tween(Icon, {Rotation = 0}, 0.2); task.wait(0.2); Container.Visible = false
            end
            
            local function RefreshOptions(newOpts)
                for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(newOpts) do
                    local O = Instance.new("TextButton"); O.Size = UDim2.new(1,0,0,30); O.Text = opt; O.TextColor3 = Color3.fromRGB(150,150,150); O.Font = Enum.Font.Gotham; O.TextSize = 13; O.BackgroundTransparency = 1; O.Parent = Container
                    O.MouseButton1Click:Connect(function() Select(opt) end)
                end
            end
            RefreshOptions(options)

            Btn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                PlaySound(Sounds.Click)
                if Dropped then Container.Visible = true; Tween(Container, {Size = UDim2.new(1,0,0, #Container:GetChildren()*30)}, 0.3); Tween(Icon, {Rotation = 180}, 0.3)
                else Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2); Tween(Icon, {Rotation = 0}, 0.2); task.wait(0.2); Container.Visible = false end
            end)

            ConfigObjects[text] = {Type = "Dropdown", Value = options[1], Set = function(val) Select(val) end, Refresh = RefreshOptions}
            return {Refresh = RefreshOptions} 
        end
        return Elements
    end

    -- ！！！注意：此处已移除内置的 Config 与 Settings 标签页 ！！！
    -- 如果你需要配置管理或个性化设置功能，请参考文件末尾的示例代码手动添加。

    return Window
end

-- 公开方法：控制音效开关
function Library:SetSFXEnabled(state)
    SFXEnabled = state
end

return Library