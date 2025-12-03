-- UI.lua
-- FengUI v2.0 现代化UI库 - 完整组件版

repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

-- 性能优化
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

-- 主UI对象
local FengUI = {}
local ToggleUI = true
FengUI.currentTab = nil
FengUI.flags = {}

-- 服务引用
local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    HttpService = game:GetService("HttpService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    TextChatService = game:GetService("TextChatService"),
    TeleportService = game:GetService("TeleportService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

-- 现代化配色方案
local config = {
    -- 基础颜色
    PrimaryColor = Color3.fromRGB(16, 16, 24),     -- 主色调
    SecondaryColor = Color3.fromRGB(22, 22, 30),   -- 次要色调
    TertiaryColor = Color3.fromRGB(28, 28, 36),    -- 第三色调
    
    -- 功能颜色
    Bg_Color = Color3.fromRGB(16, 16, 24),
    TabColor = Color3.fromRGB(22, 22, 30),
    Button_Color = Color3.fromRGB(28, 28, 36),
    Textbox_Color = Color3.fromRGB(28, 28, 36),
    Dropdown_Color = Color3.fromRGB(28, 28, 36),
    Keybind_Color = Color3.fromRGB(28, 28, 36),
    Label_Color = Color3.fromRGB(28, 28, 36),
    Slider_Color = Color3.fromRGB(28, 28, 36),
    Toggle_Color = Color3.fromRGB(28, 28, 36),
    ColorPicker_Color = Color3.fromRGB(28, 28, 36),
    
    -- 强调色
    AccentColor = Color3.fromRGB(0, 180, 255),     -- 主强调色 (青蓝色)
    AccentSecondary = Color3.fromRGB(255, 105, 180), -- 次要强调色 (粉色)
    AccentTertiary = Color3.fromRGB(120, 220, 120),  -- 第三强调色 (绿色)
    
    -- 交互状态
    Toggle_Off = Color3.fromRGB(45, 45, 55),
    Toggle_On = Color3.fromRGB(0, 180, 255),
    SliderBar_Color = Color3.fromRGB(0, 180, 255),
    
    -- 文字颜色
    TextColor = Color3.fromRGB(245, 245, 245),
    SecondaryTextColor = Color3.fromRGB(180, 180, 200),
    DisabledTextColor = Color3.fromRGB(120, 120, 140),
    
    -- 透明度设置
    NormalTransparency = 0.1,
    HoverTransparency = 0,
    ActiveTransparency = 0.2,
}

-- 全局动画效果
local function createRippleEffect(button, position)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Parent = button
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.8
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = position
    ripple.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    services.TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    }):Play()
    
    delay(0.6, function()
        ripple:Destroy()
    end)
end

local function createNeonGlow(element)
    local glow = Instance.new("UIStroke")
    glow.Name = "NeonGlow"
    glow.Parent = element
    glow.Color = config.AccentColor
    glow.Thickness = 2
    glow.Transparency = 0.8
    
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        if not element or not element.Parent then
            pulseConnection:Disconnect()
            return
        end
        local alpha = 0.7 + math.sin(tick() * 3) * 0.2
        glow.Transparency = alpha
    end)
    
    return glow
end

-- 清除旧UI
for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "FengUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

-- 创建主UI框架
local FengYu = Instance.new("ScreenGui")
FengYu.Name = "FengUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- 主窗口
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.Bg_Color
Main.BackgroundTransparency = config.NormalTransparency
Main.Position = UDim2.new(0.5, 0, 0.4, 0)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = config.NormalTransparency
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 2

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 12)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "FengUI v2.0"
TitleText.TextColor3 = config.AccentColor
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundTransparency = config.NormalTransparency
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.ZIndex = 10

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    createRippleEffect(CloseButton, UDim2.new(0.5, 0, 0.5, 0))
    
    services.TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    task.wait(0.5)
    FengYu:Destroy()
end)

-- 侧边栏
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Parent = Main
SideBar.BackgroundColor3 = config.TabColor
SideBar.BackgroundTransparency = config.NormalTransparency
SideBar.ClipsDescendants = true
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.Size = UDim2.new(0, 100, 0, 310)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = SideBar

-- 标签按钮容器
local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = SideBar
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.Position = UDim2.new(0, 0, 0, 10)
TabBtns.Size = UDim2.new(0, 100, 0, 290)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 2
TabBtns.ScrollBarImageColor3 = config.AccentColor
TabBtns.ScrollBarImageTransparency = 0.6
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.Visible = false

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)

-- 标签页区域
local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 45)
TabMain.Size = UDim2.new(0, 400, 0, 305)
TabMain.Visible = false

-- 标签页切换系统
local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
            ImageTransparency = 0,
            Size = UDim2.new(0, 26, 0, 26)
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
        Size = UDim2.new(0, 26, 0, 26)
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.5,
        TextColor3 = config.TextColor
    }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { 
        TextTransparency = 0,
        TextColor3 = config.AccentColor
    }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.3)
    switchingTabs = false
end

-- 入口动画
local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    CloseButton.BackgroundTransparency = 1
    SideBar.BackgroundTransparency = 1
    
    TabMain.Visible = false
    TabBtns.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = config.NormalTransparency,
        Size = UDim2.new(0, 500, 0, 350)
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = config.NormalTransparency
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0,
        BackgroundTransparency = config.NormalTransparency
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(SideBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = config.NormalTransparency
    }):Play()
    
    task.wait(0.2)
    
    TabMain.Visible = true
    TabBtns.Visible = true
end

-- 自动播放入口动画
task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

-- 主UI创建函数
function FengUI.new(name, theme)
    -- 应用自定义主题
    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end

    TitleText.Text = name or "FengUI v2.0"
    
    local window = {}
    
    -- 创建标签页
    function window.Tab(name, icon)
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
        Tab.ScrollBarImageColor3 = config.AccentColor
        Tab.ScrollBarImageTransparency = 0.6
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.Size = UDim2.new(0, 22, 0, 22)
        TabIco.Image = "rbxassetid://" .. (icon or "84830962019412")
        TabIco.ImageTransparency = 0.5
        TabIco.ImageColor3 = config.TextColor
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.2, 0, 0, 0)
        TabText.Size = UDim2.new(0, 70, 0, 22)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(0, 100, 0, 22)
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 6)
        
        TabBtn.MouseButton1Click:Connect(function()
            createRippleEffect(TabBtn, UDim2.new(0.5, 0, 0.5, 0))
            switchTab({ TabIco, Tab })
        end)
        
        if FengUI.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 10)
            Tab.ScrollingEnabled = TabL.AbsoluteContentSize.Y > Tab.AbsoluteSize.Y
        end)
        
        local tab = {}
        
        -- 创建分区
        function tab.section(name, TabVal)
            local Section = Instance.new("Frame")
            local SectionC = Instance.new("UICorner")
            local SectionText = Instance.new("TextLabel")
            local SectionIcon = Instance.new("ImageLabel")
            local SectionToggle = Instance.new("ImageButton")
            local Objs = Instance.new("Frame")
            local ObjsL = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = config.NormalTransparency
            Section.Size = UDim2.new(0.95, 0, 0, 40)
            
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.1, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 320, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionIcon.Name = "SectionIcon"
            SectionIcon.Parent = SectionText
            SectionIcon.BackgroundTransparency = 1
            SectionIcon.Position = UDim2.new(0, -30, 0, 9)
            SectionIcon.Size = UDim2.new(0, 22, 0, 22)
            SectionIcon.Image = "rbxassetid://84830962019412"
            SectionIcon.ImageColor3 = config.AccentColor
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionIcon
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            SectionToggle.Image = ""
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.Position = UDim2.new(0, 8, 0, 40)
            Objs.Size = UDim2.new(0.98, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 8 or 40)
                services.TweenService:Create(SectionIcon, TweenInfo.new(0.3), {
                    Rotation = open and 90 or 0
                }):Play()
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                createRippleEffect(SectionToggle, UDim2.new(0.5, 0, 0.5, 0))
                
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 8 or 40)
                }):Play()
                
                services.TweenService:Create(SectionIcon, TweenInfo.new(0.3), {
                    Rotation = open and 90 or 0
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(0.95, 0, 0, 40 + ObjsL.AbsoluteContentSize.Y + 8)
            end)
            
            local section = {}
            
            -- ==================== 按钮组件 ====================
            function section.Button(text, callback)
                local BtnModule = Instance.new("Frame")
                local Btn = Instance.new("TextButton")
                local BtnC = Instance.new("UICorner")
                local BtnIcon = Instance.new("ImageLabel")
                
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.Size = UDim2.new(0, 380, 0, 40)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = config.NormalTransparency
                Btn.Size = UDim2.new(0, 380, 0, 40)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 14
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                
                BtnC.CornerRadius = UDim.new(0, 8)
                BtnC.Parent = Btn
                
                BtnIcon.Name = "BtnIcon"
                BtnIcon.Parent = Btn
                BtnIcon.BackgroundTransparency = 1
                BtnIcon.Position = UDim2.new(0.9, 0, 0.25, 0)
                BtnIcon.Size = UDim2.new(0, 20, 0, 20)
                BtnIcon.Image = "rbxassetid://84830962019412"
                BtnIcon.ImageColor3 = config.AccentColor
                
                createNeonGlow(Btn)
                
                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundTransparency = config.HoverTransparency
                    }):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundTransparency = config.NormalTransparency
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    createRippleEffect(Btn, UDim2.new(0.5, 0, 0.5, 0))
                    callback()
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = config.ActiveTransparency
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundTransparency = config.NormalTransparency
                    }):Play()
                end)
            end
            
            -- ==================== 开关组件 ====================
            function section.Toggle(text, flag, enabled, callback)
                FengUI.flags[flag] = enabled or false

                local ToggleModule = Instance.new("Frame")
                local ToggleBtn = Instance.new("TextButton")
                local ToggleBtnC = Instance.new("UICorner")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchC = Instance.new("UICorner")
                
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.Size = UDim2.new(0, 380, 0, 40)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = config.NormalTransparency
                ToggleBtn.Size = UDim2.new(0, 380, 0, 40)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 14
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 8)
                ToggleBtnC.Parent = ToggleBtn
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleBtn
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Position = UDim2.new(0.85, 0, 0.25, 0)
                ToggleSwitch.Size = UDim2.new(0, 50, 0, 20)
                
                ToggleSwitchC.CornerRadius = UDim.new(1, 0)
                ToggleSwitchC.Parent = ToggleSwitch
                
                local toggleKnob = Instance.new("Frame")
                toggleKnob.Name = "ToggleKnob"
                toggleKnob.Parent = ToggleSwitch
                toggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                toggleKnob.Position = UDim2.new(0, enabled and 30 or 0, 0, 0)
                toggleKnob.Size = UDim2.new(0, 20, 0, 20)
                
                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = toggleKnob
                
                createNeonGlow(ToggleSwitch)
                
                local funcs = {}
                funcs.SetState = function(state)
                    if state == nil then
                        state = not FengUI.flags[flag]
                    end
                    if FengUI.flags[flag] == state then
                        return
                    end
                    
                    services.TweenService:Create(toggleKnob, TweenInfo.new(0.3), {
                        Position = UDim2.new(0, state and 30 or 0, 0, 0)
                    }):Play()
                    
                    services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.3), {
                        BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                    }):Play()
                    
                    FengUI.flags[flag] = state
                    if callback then callback(state) end
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    createRippleEffect(ToggleBtn, UDim2.new(0.5, 0, 0.5, 0))
                    funcs.SetState()
                end)
                
                return funcs
            end
            
            -- ==================== 滑块组件 ====================
            function section.Slider(text, flag, default, min, max, callback)
                FengUI.flags[flag] = default or min

                local SliderModule = Instance.new("Frame")
                local SliderBack = Instance.new("TextButton")
                local SliderBackC = Instance.new("UICorner")
                local SliderBar = Instance.new("Frame")
                local SliderBarC = Instance.new("UICorner")
                local SliderFill = Instance.new("Frame")
                local SliderFillC = Instance.new("UICorner")
                local SliderKnob = Instance.new("Frame")
                local SliderKnobC = Instance.new("UICorner")
                local SliderValue = Instance.new("TextLabel")
                
                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundTransparency = 1
                SliderModule.Size = UDim2.new(0, 380, 0, 60)
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = config.NormalTransparency
                SliderBack.Size = UDim2.new(0, 380, 0, 60)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = config.TextColor
                SliderBack.TextSize = 14
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBackC.CornerRadius = UDim.new(0, 8)
                SliderBackC.Parent = SliderBack
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                SliderBar.Position = UDim2.new(0.05, 0, 0.65, 0)
                SliderBar.Size = UDim2.new(0.9, 0, 0, 6)
                
                SliderBarC.CornerRadius = UDim.new(1, 0)
                SliderBarC.Parent = SliderBar
                
                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderBar
                SliderFill.BackgroundColor3 = config.SliderBar_Color
                SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                SliderFillC.CornerRadius = UDim.new(1, 0)
                SliderFillC.Parent = SliderFill
                
                SliderKnob.Name = "SliderKnob"
                SliderKnob.Parent = SliderBar
                SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                SliderKnob.Position = UDim2.new((default - min)/(max - min), -8, 0, -7)
                SliderKnob.Size = UDim2.new(0, 20, 0, 20)
                
                SliderKnobC.CornerRadius = UDim.new(1, 0)
                SliderKnobC.Parent = SliderKnob
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderBack
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(0.8, 0, 0.15, 0)
                SliderValue.Size = UDim2.new(0, 50, 0, 20)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.AccentColor
                SliderValue.TextSize = 14
                
                createNeonGlow(SliderKnob)
                
                local funcs = {}
                funcs.SetValue = function(value)
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
                    
                    value = math.clamp(value, min, max)
                    percent = (value - min)/(max - min)
                    FengUI.flags[flag] = value
                    SliderValue.Text = string.format("%.1f", value)
                    
                    services.TweenService:Create(SliderFill, TweenInfo.new(0.2), {
                        Size = UDim2.new(percent, 0, 1, 0)
                    }):Play()
                    
                    services.TweenService:Create(SliderKnob, TweenInfo.new(0.2), {
                        Position = UDim2.new(percent, -8, 0, -7)
                    }):Play()
                    
                    if callback then callback(value) end
                end
                
                funcs.GetValue = function()
                    return FengUI.flags[flag]
                end
                
                funcs.SetValue(default)
                
                local dragging = false
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        funcs.SetValue()
                    end
                end)
                
                SliderKnob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        funcs.SetValue()
                    end
                end)
                
                return funcs
            end
            
            -- ==================== 文本框组件 ====================
            function section.Textbox(text, flag, placeholder, default, callback)
                FengUI.flags[flag] = default or ""

                local TextboxModule = Instance.new("Frame")
                local TextboxBack = Instance.new("TextButton")
                local TextboxBackC = Instance.new("UICorner")
                local TextBox = Instance.new("TextBox")
                local TextBoxC = Instance.new("UICorner")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.Size = UDim2.new(0, 380, 0, 50)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = config.NormalTransparency
                TextboxBack.Size = UDim2.new(0, 380, 0, 50)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 14
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 8)
                TextboxBackC.Parent = TextboxBack
                
                TextBox.Parent = TextboxBack
                TextBox.BackgroundColor3 = config.Bg_Color
                TextBox.Position = UDim2.new(0.6, 0, 0.2, 0)
                TextBox.Size = UDim2.new(0, 120, 0, 30)
                TextBox.Font = Enum.Font.Gotham
                TextBox.PlaceholderText = placeholder or "输入文本..."
                TextBox.Text = default or ""
                TextBox.TextColor3 = config.TextColor
                TextBox.TextSize = 12
                TextBox.ClearTextOnFocus = false
                
                TextBoxC.CornerRadius = UDim.new(0, 6)
                TextBoxC.Parent = TextBox
                
                createNeonGlow(TextBox)
                
                TextBox.FocusLost:Connect(function(enterPressed)
                    if TextBox.Text == "" then
                        TextBox.Text = default or ""
                    end
                    FengUI.flags[flag] = TextBox.Text
                    if callback then callback(TextBox.Text, enterPressed) end
                end)
                
                local funcs = {}
                funcs.SetText = function(newText)
                    TextBox.Text = newText
                    FengUI.flags[flag] = newText
                    if callback then callback(newText) end
                end
                
                funcs.GetText = function()
                    return FengUI.flags[flag]
                end
                
                return funcs
            end
            
            -- ==================== 下拉框组件 ====================
            function section.Dropdown(text, flag, options, callback)
                FengUI.flags[flag] = options[1] or ""

                local DropdownModule = Instance.new("Frame")
                local DropdownBack = Instance.new("TextButton")
                local DropdownBackC = Instance.new("UICorner")
                local DropdownText = Instance.new("TextLabel")
                local DropdownArrow = Instance.new("ImageLabel")
                local DropdownList = Instance.new("ScrollingFrame")
                local DropdownListLayout = Instance.new("UIListLayout")
                
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(0, 380, 0, 40)
                
                DropdownBack.Name = "DropdownBack"
                DropdownBack.Parent = DropdownModule
                DropdownBack.BackgroundColor3 = config.Dropdown_Color
                DropdownBack.BackgroundTransparency = config.NormalTransparency
                DropdownBack.Size = UDim2.new(0, 380, 0, 40)
                DropdownBack.AutoButtonColor = false
                DropdownBack.Font = Enum.Font.GothamSemibold
                DropdownBack.Text = "   " .. text
                DropdownBack.TextColor3 = config.TextColor
                DropdownBack.TextSize = 14
                DropdownBack.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownBackC.CornerRadius = UDim.new(0, 8)
                DropdownBackC.Parent = DropdownBack
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownBack
                DropdownText.BackgroundTransparency = 1
                DropdownText.Position = UDim2.new(0.6, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 120, 0, 40)
                DropdownText.Font = Enum.Font.Gotham
                DropdownText.Text = options[1] or "选择..."
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = 12
                DropdownText.TextXAlignment = Enum.TextXAlignment.Center
                
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Parent = DropdownBack
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position = UDim2.new(0.9, 0, 0.25, 0)
                DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                DropdownArrow.Image = "rbxassetid://6031091004"
                DropdownArrow.ImageColor3 = config.AccentColor
                
                DropdownList.Name = "DropdownList"
                DropdownList.Parent = DropdownModule
                DropdownList.BackgroundColor3 = config.Dropdown_Color
                DropdownList.BackgroundTransparency = 0.1
                DropdownList.Position = UDim2.new(0, 0, 1, 0)
                DropdownList.Size = UDim2.new(0, 380, 0, 0)
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
                DropdownList.ScrollBarThickness = 2
                DropdownList.ScrollBarImageColor3 = config.AccentColor
                DropdownList.Visible = false
                
                DropdownListLayout.Name = "DropdownListLayout"
                DropdownListLayout.Parent = DropdownList
                DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownListLayout.Padding = UDim.new(0, 2)
                
                local isOpen = false
                
                local function createOption(optionText)
                    local optionBtn = Instance.new("TextButton")
                    optionBtn.Name = "Option_" .. optionText
                    optionBtn.Parent = DropdownList
                    optionBtn.BackgroundColor3 = config.TabColor
                    optionBtn.BackgroundTransparency = 0.2
                    optionBtn.Size = UDim2.new(0, 370, 0, 30)
                    optionBtn.AutoButtonColor = false
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.Text = optionText
                    optionBtn.TextColor3 = config.TextColor
                    optionBtn.TextSize = 12
                    
                    local optionCorner = Instance.new("UICorner")
                    optionCorner.CornerRadius = UDim.new(0, 6)
                    optionCorner.Parent = optionBtn
                    
                    optionBtn.MouseEnter:Connect(function()
                        services.TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0
                        }):Play()
                    end)
                    
                    optionBtn.MouseLeave:Connect(function()
                        services.TweenService:Create(optionBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2
                        }):Play()
                    end)
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        DropdownText.Text = optionText
                        FengUI.flags[flag] = optionText
                        isOpen = false
                        
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, 380, 0, 0)
                        }):Play()
                        
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.3), {
                            Rotation = 0
                        }):Play()
                        
                        task.wait(0.3)
                        DropdownList.Visible = false
                        
                        if callback then callback(optionText) end
                    end)
                    
                    return optionBtn
                end
                
                for _, option in ipairs(options) do
                    createOption(option)
                end
                
                DropdownListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownListLayout.AbsoluteContentSize.Y)
                end)
                
                DropdownBack.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    
                    if isOpen then
                        DropdownList.Visible = true
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, 380, 0, math.min(DropdownListLayout.AbsoluteContentSize.Y, 150))
                        }):Play()
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.3), {
                            Rotation = 180
                        }):Play()
                    else
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, 380, 0, 0)
                        }):Play()
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.3), {
                            Rotation = 0
                        }):Play()
                        task.wait(0.3)
                        DropdownList.Visible = false
                    end
                end)
                
                local funcs = {}
                funcs.AddOption = function(optionText)
                    createOption(optionText)
                    table.insert(options, optionText)
                end
                
                funcs.RemoveOption = function(optionText)
                    local option = DropdownList:FindFirstChild("Option_" .. optionText)
                    if option then
                        option:Destroy()
                        for i, v in ipairs(options) do
                            if v == optionText then
                                table.remove(options, i)
                                break
                            end
                        end
                    end
                end
                
                funcs.SetOptions = function(newOptions)
                    for _, child in ipairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    options = newOptions
                    for _, option in ipairs(options) do
                        createOption(option)
                    end
                end
                
                funcs.GetSelected = function()
                    return FengUI.flags[flag]
                end
                
                return funcs
            end
            
            -- ==================== 键位绑定组件 ====================
            function section.Keybind(text, flag, defaultKey, callback)
                local currentKey = defaultKey or Enum.KeyCode.F
                FengUI.flags[flag] = currentKey.Name

                local KeybindModule = Instance.new("Frame")
                local KeybindBack = Instance.new("TextButton")
                local KeybindBackC = Instance.new("UICorner")
                local KeybindText = Instance.new("TextLabel")
                local KeybindBtn = Instance.new("TextButton")
                local KeybindBtnC = Instance.new("UICorner")
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.Size = UDim2.new(0, 380, 0, 40)
                
                KeybindBack.Name = "KeybindBack"
                KeybindBack.Parent = KeybindModule
                KeybindBack.BackgroundColor3 = config.Keybind_Color
                KeybindBack.BackgroundTransparency = config.NormalTransparency
                KeybindBack.Size = UDim2.new(0, 380, 0, 40)
                KeybindBack.AutoButtonColor = false
                KeybindBack.Font = Enum.Font.GothamSemibold
                KeybindBack.Text = "   " .. text
                KeybindBack.TextColor3 = config.TextColor
                KeybindBack.TextSize = 14
                KeybindBack.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBackC.CornerRadius = UDim.new(0, 8)
                KeybindBackC.Parent = KeybindBack
                
                KeybindText.Name = "KeybindText"
                KeybindText.Parent = KeybindBack
                KeybindText.BackgroundTransparency = 1
                KeybindText.Position = UDim2.new(0.6, 0, 0, 0)
                KeybindText.Size = UDim2.new(0, 80, 0, 40)
                KeybindText.Font = Enum.Font.Gotham
                KeybindText.Text = currentKey.Name
                KeybindText.TextColor3 = config.TextColor
                KeybindText.TextSize = 12
                KeybindText.TextXAlignment = Enum.TextXAlignment.Center
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindBack
                KeybindBtn.BackgroundColor3 = config.Bg_Color
                KeybindBtn.BackgroundTransparency = 0.2
                KeybindBtn.Position = UDim2.new(0.8, 0, 0.25, 0)
                KeybindBtn.Size = UDim2.new(0, 50, 0, 20)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.Gotham
                KeybindBtn.Text = "绑定"
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 10
                
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Parent = KeybindBtn
                
                createNeonGlow(KeybindBtn)
                
                local listening = false
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if input.KeyCode == currentKey then
                        if callback then callback(currentKey.Name) end
                    end
                end)
                
                KeybindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindBtn.Text = "监听中..."
                    KeybindBtn.BackgroundColor3 = config.AccentColor
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            FengUI.flags[flag] = currentKey.Name
                            KeybindText.Text = currentKey.Name
                            listening = false
                            KeybindBtn.Text = "绑定"
                            KeybindBtn.BackgroundColor3 = config.Bg_Color
                            connection:Disconnect()
                        end
                    end)
                    
                    task.spawn(function()
                        task.wait(5)
                        if listening then
                            listening = false
                            KeybindBtn.Text = "绑定"
                            KeybindBtn.BackgroundColor3 = config.Bg_Color
                            connection:Disconnect()
                        end
                    end)
                end)
                
                local funcs = {}
                funcs.SetKey = function(keyCode)
                    currentKey = keyCode
                    FengUI.flags[flag] = currentKey.Name
                    KeybindText.Text = currentKey.Name
                end
                
                funcs.GetKey = function()
                    return currentKey
                end
                
                return funcs
            end
            
            -- ==================== 标签组件 ====================
            function section.Label(text, color)
                local LabelModule = Instance.new("Frame")
                local LabelBack = Instance.new("TextLabel")
                local LabelBackC = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.Size = UDim2.new(0, 380, 0, 30)
                
                LabelBack.Name = "LabelBack"
                LabelBack.Parent = LabelModule
                LabelBack.BackgroundColor3 = color or config.Label_Color
                LabelBack.BackgroundTransparency = config.NormalTransparency
                LabelBack.Size = UDim2.new(0, 380, 0, 30)
                LabelBack.Font = Enum.Font.GothamSemibold
                LabelBack.Text = text
                LabelBack.TextColor3 = config.TextColor
                LabelBack.TextSize = 14
                LabelBack.TextXAlignment = Enum.TextXAlignment.Center
                
                LabelBackC.CornerRadius = UDim.new(0, 8)
                LabelBackC.Parent = LabelBack
                
                createNeonGlow(LabelBack)
                
                local funcs = {}
                funcs.SetText = function(newText)
                    LabelBack.Text = newText
                end
                
                funcs.SetColor = function(newColor)
                    LabelBack.BackgroundColor3 = newColor
                end
                
                return funcs
            end
            
            -- ==================== 图片组件 ====================
            function section.Image(imageId, width, height)
                local ImageModule = Instance.new("Frame")
                local ImageContainer = Instance.new("ImageLabel")
                local ImageContainerC = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.Size = UDim2.new(0, 380, 0, height or 120)
                
                ImageContainer.Name = "ImageContainer"
                ImageContainer.Parent = ImageModule
                ImageContainer.BackgroundColor3 = config.Bg_Color
                ImageContainer.BackgroundTransparency = 0.1
                ImageContainer.AnchorPoint = Vector2.new(0.5, 0)
                ImageContainer.Position = UDim2.new(0.5, 0, 0, 0)
                ImageContainer.Size = UDim2.new(0, width or 200, 0, height or 120)
                ImageContainer.Image = "rbxassetid://" .. tostring(imageId)
                ImageContainer.ScaleType = Enum.ScaleType.Crop
                
                ImageContainerC.CornerRadius = UDim.new(0, 8)
                ImageContainerC.Parent = ImageContainer
                
                createNeonGlow(ImageContainer)
                
                local funcs = {}
                funcs.SetImage = function(newImageId)
                    ImageContainer.Image = "rbxassetid://" .. tostring(newImageId)
                end
                
                funcs.SetSize = function(newWidth, newHeight)
                    ImageContainer.Size = UDim2.new(0, newWidth, 0, newHeight)
                    ImageModule.Size = UDim2.new(0, 380, 0, newHeight)
                end
                
                return funcs
            end
            
            -- ==================== 颜色选择器组件 ====================
            function section.ColorPicker(text, flag, defaultColor, callback)
                FengUI.flags[flag] = defaultColor or config.AccentColor

                local ColorModule = Instance.new("Frame")
                local ColorBack = Instance.new("TextButton")
                local ColorBackC = Instance.new("UICorner")
                local ColorPreview = Instance.new("Frame")
                local ColorPreviewC = Instance.new("UICorner")
                local ColorBtn = Instance.new("TextButton")
                local ColorBtnC = Instance.new("UICorner")
                
                ColorModule.Name = "ColorModule"
                ColorModule.Parent = Objs
                ColorModule.BackgroundTransparency = 1
                ColorModule.Size = UDim2.new(0, 380, 0, 40)
                
                ColorBack.Name = "ColorBack"
                ColorBack.Parent = ColorModule
                ColorBack.BackgroundColor3 = config.ColorPicker_Color
                ColorBack.BackgroundTransparency = config.NormalTransparency
                ColorBack.Size = UDim2.new(0, 380, 0, 40)
                ColorBack.AutoButtonColor = false
                ColorBack.Font = Enum.Font.GothamSemibold
                ColorBack.Text = "   " .. text
                ColorBack.TextColor3 = config.TextColor
                ColorBack.TextSize = 14
                ColorBack.TextXAlignment = Enum.TextXAlignment.Left
                
                ColorBackC.CornerRadius = UDim.new(0, 8)
                ColorBackC.Parent = ColorBack
                
                ColorPreview.Name = "ColorPreview"
                ColorPreview.Parent = ColorBack
                ColorPreview.BackgroundColor3 = defaultColor or config.AccentColor
                ColorPreview.Position = UDim2.new(0.6, 0, 0.25, 0)
                ColorPreview.Size = UDim2.new(0, 40, 0, 20)
                
                ColorPreviewC.CornerRadius = UDim.new(0, 6)
                ColorPreviewC.Parent = ColorPreview
                
                ColorBtn.Name = "ColorBtn"
                ColorBtn.Parent = ColorBack
                ColorBtn.BackgroundColor3 = config.Bg_Color
                ColorBtn.BackgroundTransparency = 0.2
                ColorBtn.Position = UDim2.new(0.8, 0, 0.25, 0)
                ColorBtn.Size = UDim2.new(0, 50, 0, 20)
                ColorBtn.AutoButtonColor = false
                ColorBtn.Font = Enum.Font.Gotham
                ColorBtn.Text = "选择"
                ColorBtn.TextColor3 = config.TextColor
                ColorBtn.TextSize = 10
                
                ColorBtnC.CornerRadius = UDim.new(0, 6)
                ColorBtnC.Parent = ColorBtn
                
                createNeonGlow(ColorPreview)
                createNeonGlow(ColorBtn)
                
                local colorPickerOpen = false
                local colorPickerFrame = nil
                
                local function openColorPicker()
                    if colorPickerOpen then return end
                    colorPickerOpen = true
                    
                    colorPickerFrame = Instance.new("Frame")
                    colorPickerFrame.Name = "ColorPickerFrame"
                    colorPickerFrame.Parent = ColorModule
                    colorPickerFrame.BackgroundColor3 = config.TabColor
                    colorPickerFrame.BackgroundTransparency = 0.1
                    colorPickerFrame.Position = UDim2.new(0, 0, 1, 0)
                    colorPickerFrame.Size = UDim2.new(0, 380, 0, 0)
                    colorPickerFrame.ClipsDescendants = true
                    
                    local colorPickerCorner = Instance.new("UICorner")
                    colorPickerCorner.CornerRadius = UDim.new(0, 8)
                    colorPickerCorner.Parent = colorPickerFrame
                    
                    local hueSlider = Instance.new("Frame")
                    hueSlider.Name = "HueSlider"
                    hueSlider.Parent = colorPickerFrame
                    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
                    hueSlider.Position = UDim2.new(0.05, 0, 0.1, 0)
                    hueSlider.Size = UDim2.new(0.9, 0, 0, 20)
                    
                    local hueGradient = Instance.new("UIGradient")
                    hueGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    })
                    hueGradient.Rotation = 0
                    hueGradient.Parent = hueSlider
                    
                    local hueCorner = Instance.new("UICorner")
                    hueCorner.CornerRadius = UDim.new(0, 6)
                    hueCorner.Parent = hueSlider
                    
                    local hueMarker = Instance.new("Frame")
                    hueMarker.Name = "HueMarker"
                    hueMarker.Parent = hueSlider
                    hueMarker.BackgroundColor3 = Color3.new(1, 1, 1)
                    hueMarker.Size = UDim2.new(0, 4, 1, 4)
                    hueMarker.Position = UDim2.new(0.5, -2, 0, -2)
                    
                    local hueMarkerCorner = Instance.new("UICorner")
                    hueMarkerCorner.CornerRadius = UDim.new(0, 2)
                    hueMarkerCorner.Parent = hueMarker
                    
                    local saturationValue = Instance.new("Frame")
                    saturationValue.Name = "SaturationValue"
                    saturationValue.Parent = colorPickerFrame
                    saturationValue.BackgroundColor3 = Color3.new(1, 1, 1)
                    saturationValue.Position = UDim2.new(0.05, 0, 0.4, 0)
                    saturationValue.Size = UDim2.new(0, 200, 0, 150)
                    
                    local svCorner = Instance.new("UICorner")
                    svCorner.CornerRadius = UDim.new(0, 6)
                    svCorner.Parent = saturationValue
                    
                    local svMarker = Instance.new("Frame")
                    svMarker.Name = "SVMarker"
                    svMarker.Parent = saturationValue
                    svMarker.BackgroundColor3 = Color3.new(1, 1, 1)
                    svMarker.Size = UDim2.new(0, 8, 0, 8)
                    svMarker.Position = UDim2.new(0.5, -4, 0.5, -4)
                    
                    local svMarkerCorner = Instance.new("UICorner")
                    svMarkerCorner.CornerRadius = UDim.new(1, 0)
                    svMarkerCorner.Parent = svMarker
                    
                    local rgbInputs = Instance.new("Frame")
                    rgbInputs.Name = "RGBInputs"
                    rgbInputs.Parent = colorPickerFrame
                    rgbInputs.BackgroundTransparency = 1
                    rgbInputs.Position = UDim2.new(0.55, 0, 0.4, 0)
                    rgbInputs.Size = UDim2.new(0, 150, 0, 150)
                    
                    local function createRGBInput(label, defaultValue, yPos)
                        local inputFrame = Instance.new("Frame")
                        inputFrame.Parent = rgbInputs
                        inputFrame.BackgroundTransparency = 1
                        inputFrame.Position = UDim2.new(0, 0, yPos, 0)
                        inputFrame.Size = UDim2.new(1, 0, 0, 40)
                        
                        local labelText = Instance.new("TextLabel")
                        labelText.Parent = inputFrame
                        labelText.BackgroundTransparency = 1
                        labelText.Position = UDim2.new(0, 0, 0, 0)
                        labelText.Size = UDim2.new(0.4, 0, 1, 0)
                        labelText.Font = Enum.Font.Gotham
                        labelText.Text = label
                        labelText.TextColor3 = config.TextColor
                        labelText.TextSize = 12
                        labelText.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local textBox = Instance.new("TextBox")
                        textBox.Parent = inputFrame
                        textBox.BackgroundColor3 = config.Bg_Color
                        textBox.BackgroundTransparency = 0.2
                        textBox.Position = UDim2.new(0.4, 0, 0.25, 0)
                        textBox.Size = UDim2.new(0.6, 0, 0.5, 0)
                        textBox.Font = Enum.Font.Gotham
                        textBox.Text = tostring(defaultValue)
                        textBox.TextColor3 = config.TextColor
                        textBox.TextSize = 12
                        textBox.ClearTextOnFocus = false
                        
                        local textBoxCorner = Instance.new("UICorner")
                        textBoxCorner.CornerRadius = UDim.new(0, 4)
                        textBoxCorner.Parent = textBox
                        
                        return textBox
                    end
                    
                    local rInput = createRGBInput("R:", 255, 0)
                    local gInput = createRGBInput("G:", 180, 0.2)
                    local bInput = createRGBInput("B:", 255, 0.4)
                    
                    local currentColor = defaultColor or config.AccentColor
                    local h, s, v = currentColor:ToHSV()
                    
                    services.TweenService:Create(colorPickerFrame, TweenInfo.new(0.3), {
                        Size = UDim2.new(0, 380, 0, 220)
                    }):Play()
                    
                    local function updateColor(newH, newS, newV)
                        if newH then h = newH end
                        if newS then s = newS end
                        if newV then v = newV end
                        
                        currentColor = Color3.fromHSV(h, s, v)
                        ColorPreview.BackgroundColor3 = currentColor
                        FengUI.flags[flag] = currentColor
                        
                        if callback then callback(currentColor) end
                    end
                    
                    hueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local dragging = true
                            local connection
                            connection = services.UserInputService.InputChanged:Connect(function(input)
                                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                    local mouseX = services.Players.LocalPlayer:GetMouse().X
                                    local sliderPos = hueSlider.AbsolutePosition.X
                                    local sliderWidth = hueSlider.AbsoluteSize.X
                                    local percent = math.clamp((mouseX - sliderPos) / sliderWidth, 0, 1)
                                    h = percent
                                    hueMarker.Position = UDim2.new(percent, -2, 0, -2)
                                    updateColor(h, nil, nil)
                                end
                            end)
                            
                            services.UserInputService.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    dragging = false
                                    connection:Disconnect()
                                end
                            end)
                        end
                    end)
                    
                    ColorBtn.MouseButton1Click:Connect(function()
                        if colorPickerOpen then
                            services.TweenService:Create(colorPickerFrame, TweenInfo.new(0.3), {
                                Size = UDim2.new(0, 380, 0, 0)
                            }):Play()
                            task.wait(0.3)
                            colorPickerFrame:Destroy()
                            colorPickerOpen = false
                        else
                            openColorPicker()
                        end
                    end)
                end
                
                ColorBtn.MouseButton1Click:Connect(openColorPicker)
                
                local funcs = {}
                funcs.SetColor = function(color)
                    ColorPreview.BackgroundColor3 = color
                    FengUI.flags[flag] = color
                    if callback then callback(color) end
                end
                
                funcs.GetColor = function()
                    return FengUI.flags[flag]
                end
                
                return funcs
            end
            
            return section
        end

        return tab
    end

    return window
end

-- UI控制函数
function FengUI:Destroy()
    if FengYu then
        FengYu:Destroy()
    end
end

function FengUI:Toggle()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    Main.Visible = ToggleUI
end

function FengUI:GetFlag(flag)
    return FengUI.flags[flag]
end

function FengUI:SetFlag(flag, value)
    FengUI.flags[flag] = value
end

-- 全局导出
getgenv().FengUI = FengUI
return FengUI