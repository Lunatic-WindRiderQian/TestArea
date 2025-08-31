repeat
    task.wait()
until game:IsLoaded()

local isSynapse = syn and syn.protect_gui ~= nil
local isScriptWare = secure_load ~= nil
local isKrnl = krnl and krnl.protect_gui ~= nil
local isFluxus = fluxus and fluxus.protect_gui ~= nil
local isElectron = is_sirhurt_closure ~= nil
local isComet = comet and comet.protect_gui ~= nil
local isOxygen = getexecutorname and getexecutorname():lower():find("oxygen") ~= nil
local isAlus = alus and alus.protect_gui ~= nil

local function protectGUI(gui)
    if isSynapse then
        syn.protect_gui(gui)
    elseif isScriptWare then
        secure_load(gui)
    elseif isKrnl then
        krnl.protect_gui(gui)
    elseif isFluxus then
        fluxus.protect_gui(gui)
    elseif isElectron then
        protect_gui(gui)
    elseif isComet then
        comet.protect_gui(gui)
    elseif isOxygen then
        protect_gui(gui)
    elseif isAlus then
        alus.protect_gui(gui)
    end
    
    local success, err = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("RobloxGui", gui)
    end
end

local library = {}
local ToggleUI = true
library.currentTab = nil
library.flaFengYu = {}

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

function drag(frame, hold)
    if not hold then hold = frame end
    
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Ripple(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundTransparency = 1
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://84830962019412"
        Ripple.ImageTransparency = 0.8
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = config.AccentColor
        
        local x = (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        Ripple.Position = UDim2.new(x, 0, y, 0)
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.5, 0, -0.5, 0),
            Size = UDim2.new(2, 0, 2, 0)
        }):Play()
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 1
        }):Play()
        
        task.wait(0.4)
        Ripple:Destroy()
    end)
end

local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = library.currentTab
    if old == nil then
        new[2].Visible = true
        library.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { ImageTransparency = 0 }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    library.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { ImageTransparency = 0.5 }):Play()
    services.TweenService:Create(new[1], tweenInfo, { ImageTransparency = 0 }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { TextTransparency = 0.5 }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { TextTransparency = 0 }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.2)
    switchingTabs = false
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
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 600, 0, 380)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

-- 添加圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

-- 添加边框
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5

local Open = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")

Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 1
Open.Position = UDim2.new(0.008, 0, 0.131, 0)
Open.Size = UDim2.new(0, 50, 0, 50)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = config.AccentColor

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
end)

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Open

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
    end
end)

-- 创建超级美观的背景
local MainBackground = Instance.new("Frame")
MainBackground.Name = "MainBackground"
MainBackground.Parent = Main
MainBackground.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainBackground.Size = UDim2.new(1, 0, 1, 0)
MainBackground.ZIndex = 0

-- 添加圆角
local MainBgCorner = Instance.new("UICorner")
MainBgCorner.CornerRadius = UDim.new(0, 12)
MainBgCorner.Parent = MainBackground

-- 创建渐变背景效果
local BackgroundGradient = Instance.new("UIGradient")
BackgroundGradient.Parent = MainBackground
BackgroundGradient.Rotation = 120
BackgroundGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 20, 40)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(15, 15, 25))
})

-- 添加装饰性几何图案
local DecorPattern = Instance.new("ImageLabel")
DecorPattern.Name = "DecorPattern"
DecorPattern.Parent = MainBackground
DecorPattern.BackgroundTransparency = 1
DecorPattern.Size = UDim2.new(1, 0, 1, 0)
DecorPattern.Image = "rbxassetid://8992233754" -- 简约几何图案
DecorPattern.ImageColor3 = Color3.fromRGB(30, 30, 45)
DecorPattern.ImageTransparency = 0.9
DecorPattern.ScaleType = Enum.ScaleType.Tile
DecorPattern.TileSize = UDim2.new(0, 100, 0, 100)
DecorPattern.ZIndex = 1

-- 添加简约装饰元素
local DecorCircle1 = Instance.new("Frame")
DecorCircle1.Parent = MainBackground
DecorCircle1.BackgroundColor3 = Color3.fromRGB(37, 254, 152)
DecorCircle1.BackgroundTransparency = 0.9
DecorCircle1.Size = UDim2.new(0, 120, 0, 120)
DecorCircle1.Position = UDim2.new(0.8, 0, -0.1, 0)
DecorCircle1.ZIndex = 1

local DecorCircle1Corner = Instance.new("UICorner")
DecorCircle1Corner.CornerRadius = UDim.new(1, 0)
DecorCircle1Corner.Parent = DecorCircle1

local DecorCircle2 = Instance.new("Frame")
DecorCircle2.Parent = MainBackground
DecorCircle2.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
DecorCircle2.BackgroundTransparency = 0.9
DecorCircle2.Size = UDim2.new(0, 80, 0, 80)
DecorCircle2.Position = UDim2.new(-0.05, 0, 0.7, 0)
DecorCircle2.ZIndex = 1

local DecorCircle2Corner = Instance.new("UICorner")
DecorCircle2Corner.CornerRadius = UDim.new(1, 0)
DecorCircle2Corner.Parent = DecorCircle2

-- 添加简约边框效果
local InnerStroke = Instance.new("UIStroke")
InnerStroke.Parent = MainBackground
InnerStroke.Color = Color3.fromRGB(60, 60, 80)
InnerStroke.Thickness = 2
InnerStroke.Transparency = 0.8

-- 添加左右渐变遮罩效果
local LeftGradientMask = Instance.new("Frame")
LeftGradientMask.Name = "LeftGradientMask"
LeftGradientMask.Parent = MainBackground
LeftGradientMask.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LeftGradientMask.BackgroundTransparency = 0.5
LeftGradientMask.Size = UDim2.new(0.2, 0, 1, 0)
LeftGradientMask.ZIndex = 2

local LeftGradient = Instance.new("UIGradient")
LeftGradient.Parent = LeftGradientMask
LeftGradient.Rotation = 0
LeftGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 0, 0))
})
LeftGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.0),
    NumberSequenceKeypoint.new(1.0, 1.0)
})

local RightGradientMask = Instance.new("Frame")
RightGradientMask.Name = "RightGradientMask"
RightGradientMask.Parent = MainBackground
RightGradientMask.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightGradientMask.BackgroundTransparency = 0.5
RightGradientMask.Position = UDim2.new(0.8, 0, 0, 0)
RightGradientMask.Size = UDim2.new(0.2, 0, 1, 0)
RightGradientMask.ZIndex = 2

local RightGradient = Instance.new("UIGradient")
RightGradient.Parent = RightGradientMask
RightGradient.Rotation = 180
RightGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(0, 0, 0))
})
RightGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0.0),
    NumberSequenceKeypoint.new(1.0, 1.0)
})

-- 添加动态粒子效果
local ParticleEmitter = Instance.new("Frame")
ParticleEmitter.Name = "ParticleEmitter"
ParticleEmitter.Parent = MainBackground
ParticleEmitter.BackgroundTransparency = 1
ParticleEmitter.Size = UDim2.new(1, 0, 1, 0)
ParticleEmitter.ZIndex = 1

-- 创建粒子效果
local function createParticle()
    local particle = Instance.new("Frame")
    particle.Parent = ParticleEmitter
    particle.BackgroundColor3 = config.AccentColor
    particle.Size = UDim2.new(0, 2, 0, 2)
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.ZIndex = 1
    
    local particleCorner = Instance.new("UICorner")
    particleCorner.CornerRadius = UDim.new(1, 0)
    particleCorner.Parent = particle
    
    services.TweenService:Create(particle, TweenInfo.new(math.random(2, 5), Enum.EasingStyle.Linear), {
        Position = UDim2.new(math.random(), 0, math.random(), 0),
        BackgroundTransparency = 1
    }):Play()
    
    delay(5, function()
        particle:Destroy()
    end)
end

-- 定期生成粒子
spawn(function()
    while wait(0.1) do
        if #ParticleEmitter:GetChildren() < 20 then
            createParticle()
        end
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.217, 0, 0, 3)
TabMain.Size = UDim2.new(0, 468, 0, 374)
TabMain.ZIndex = 10

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 0)
Side.Size = UDim2.new(0, 120, 0, 380)

-- 添加圆角
local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Side

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0.097, 0)
TabBtns.Size = UDim2.new(0, 120, 0, 340)
TabBtns.CanvasSize = UDim2.new(0, 0, 1, 0)
TabBtns.ScrollBarThickness = 0

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 12)

-- 修改脚本标题为彩色渐变效果
local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.009, 0)
ScriptTitle.Size = UDim2.new(0, 110, 0, 20)
ScriptTitle.Font = Enum.Font.GothamSemibold
ScriptTitle.Text = "彩虹UI"
ScriptTitle.TextSize = 16
ScriptTitle.TextScaled = true
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

-- 添加彩色渐变效果到标题
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Parent = ScriptTitle
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 165, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(128, 0, 128))
})

-- 添加标题动画
spawn(function()
    while wait(0.05) do
        TitleGradient.Offset = Vector2.new((TitleGradient.Offset.X + 0.01) % 1, 0)
    end
end)

function library.new(library, name, theme)
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

    -- 设置彩色标题
    ScriptTitle.Text = name or "彩虹UI"
    
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
        Tab.Visible = false
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = "rbxassetid://84830962019412"
        TabIco.ImageTransparency = 0.5
        TabIco.ImageColor3 = config.AccentColor
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.416, 0, 0, 0)
        TabText.Size = UDim2.new(0, 86, 0, 24)
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
        TabBtn.Size = UDim2.new(0, 120, 0, 24)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({ TabIco, Tab })
        end)
        
        if library.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
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
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.981, 0, 0, 36)
            
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.088, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 401, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, -33, 0, 5)
            SectionOpen.Size = UDim2.new(0, 26, 0, 26)
            SectionOpen.Image = "rbxassetid://84830962019412"
            SectionOpen.ImageColor3 = config.SecondaryTextColor
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(0, 26, 0, 26)
            SectionOpened.Image = "rbxassetid://84830962019412"
            SectionOpened.ImageColor3 = config.AccentColor
            SectionOpened.ImageTransparency = 1
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(0, 26, 0, 26)
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 6, 0, 36)
            Objs.Size = UDim2.new(0.986, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = open and 0 or 1
                SectionOpen.ImageTransparency = open and 1 or 0
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.2), {
                    Size = UDim2.new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                }):Play()
                
                services.TweenService:Create(SectionOpened, TweenInfo.new(0.2), {
                    ImageTransparency = open and 0 or 1
                }):Play()
                
                services.TweenService:Create(SectionOpen, TweenInfo.new(0.2), {
                    ImageTransparency = open and 1 or 0
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(0.981, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
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
                BtnModule.Size = UDim2.new(0, 448, 0, 38)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, 448, 0, 38)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 16
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.1),
                            math.floor(config.Button_Color.G * 255 * 1.1),
                            math.floor(config.Button_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenService.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    callback()
                end)
            end
            
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                local TextLabel = Instance.new("TextLabel")
                local LabelC = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, 448, 0, 19)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.Size = UDim2.new(0, 448, 0, 22)
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
                library.flaFengYu[flag] = enabled

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
                ToggleModule.Size = UDim2.new(0, 448, 0, 38)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, 448, 0, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 16
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = config.Bg_Color
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.901, 0, 0.208, 0)
                ToggleDisable.Size = UDim2.new(0, 36, 0, 22)
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)
                ToggleSwitch.Position = UDim2.new(0, enabled and 12 or 0, 0, 0)
                
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(0, 6)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Toggle_Color.R * 255 * 1.1),
                            math.floor(config.Toggle_Color.G * 255 * 1.1),
                            math.floor(config.Toggle_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Toggle_Color
                    }):Play()
                end)
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Ripple(ToggleBtn)
                    library.flaFengYu[flag] = not library.flaFengYu[flag]
                    enabled = library.flaFengYu[flag]
                    
                    services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, enabled and 12 or 0, 0, 0),
                        BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                    }):Play()
                    
                    callback(enabled)
                end)
                
                return {
                    Set = function(self, value)
                        library.flaFengYu[flag] = value
                        enabled = value
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, enabled and 12 or 0, 0, 0),
                            BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        callback(enabled)
                    end,
                    Get = function(self)
                        return library.flaFengYu[flag]
                    end
                }
            end
            
            function section.Slider(section, text, flag, min, max, step, value, callback)
                callback = callback or function() end
                value = value or min
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flaFengYu[flag] = value

                local SliderModule = Instance.new("Frame")
                local SliderBtn = Instance.new("TextButton")
                local SliderBtnC = Instance.new("UICorner")
                local SliderBar = Instance.new("Frame")
                local SliderBarC = Instance.new("UICorner")
                local SliderVal = Instance.new("TextLabel")
                local SliderBarMain = Instance.new("Frame")
                local SliderBarMainC = Instance.new("UICorner")
                
                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundTransparency = 1
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(0, 448, 0, 38)
                
                SliderBtn.Name = "SliderBtn"
                SliderBtn.Parent = SliderModule
                SliderBtn.BackgroundColor3 = config.Slider_Color
                SliderBtn.BorderSizePixel = 0
                SliderBtn.Size = UDim2.new(0, 448, 0, 38)
                SliderBtn.AutoButtonColor = false
                SliderBtn.Font = Enum.Font.GothamSemibold
                SliderBtn.Text = "   " .. text
                SliderBtn.TextColor3 = config.TextColor
                SliderBtn.TextSize = 16
                SliderBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBtnC.CornerRadius = UDim.new(0, 6)
                SliderBtnC.Name = "SliderBtnC"
                SliderBtnC.Parent = SliderBtn
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBtn
                SliderBar.BackgroundColor3 = config.Bg_Color
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.032, 0, 0.632, 0)
                SliderBar.Size = UDim2.new(0, 420, 0, 8)
                
                SliderBarC.CornerRadius = UDim.new(0, 4)
                SliderBarC.Name = "SliderBarC"
                SliderBarC.Parent = SliderBar
                
                SliderVal.Name = "SliderVal"
                SliderVal.Parent = SliderBtn
                SliderVal.BackgroundTransparency = 1
                SliderVal.Position = UDim2.new(0.8, 0, 0, 0)
                SliderVal.Size = UDim2.new(0, 80, 0, 38)
                SliderVal.Font = Enum.Font.GothamSemibold
                SliderVal.Text = tostring(value)
                SliderVal.TextColor3 = config.SecondaryTextColor
                SliderVal.TextSize = 16
                SliderVal.TextXAlignment = Enum.TextXAlignment.Right
                
                SliderBarMain.Name = "SliderBarMain"
                SliderBarMain.Parent = SliderBar
                SliderBarMain.BackgroundColor3 = config.SliderBar_Color
                SliderBarMain.BorderSizePixel = 0
                SliderBarMain.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                
                SliderBarMainC.CornerRadius = UDim.new(0, 4)
                SliderBarMainC.Name = "SliderBarMainC"
                SliderBarMainC.Parent = SliderBarMain
                
                SliderBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(SliderBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Slider_Color.R * 255 * 1.1),
                            math.floor(config.Slider_Color.G * 255 * 1.1),
                            math.floor(config.Slider_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                SliderBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(SliderBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Slider_Color
                    }):Play()
                end)
                
                local dragging = false
                
                local function update(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
                    local value = math.floor((min + (max - min) * pos.X.Scale) / step + 0.5) * step
                    value = math.clamp(value, min, max)
                    
                    SliderBarMain.Size = pos
                    SliderVal.Text = tostring(value)
                    library.flaFengYu[flag] = value
                    callback(value)
                end
                
                SliderBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)
                
                SliderBtn.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                
                return {
                    Set = function(self, value)
                        value = math.clamp(value, min, max)
                        SliderBarMain.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        SliderVal.Text = tostring(value)
                        library.flaFengYu[flag] = value
                        callback(value)
                    end,
                    Get = function(self)
                        return library.flaFengYu[flag]
                    end
                }
            end
            
            function section.Textbox(section, text, flag, placeholder, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flaFengYu[flag] = ""

                local TextboxModule = Instance.new("Frame")
                local TextboxBtn = Instance.new("TextButton")
                local TextboxBtnC = Instance.new("UICorner")
                local TextboxBox = Instance.new("TextBox")
                local TextboxBoxC = Instance.new("UICorner")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, 448, 0, 38)
                
                TextboxBtn.Name = "TextboxBtn"
                TextboxBtn.Parent = TextboxModule
                TextboxBtn.BackgroundColor3 = config.Textbox_Color
                TextboxBtn.BorderSizePixel = 0
                TextboxBtn.Size = UDim2.new(0, 448, 0, 38)
                TextboxBtn.AutoButtonColor = false
                TextboxBtn.Font = Enum.Font.GothamSemibold
                TextboxBtn.Text = "   " .. text
                TextboxBtn.TextColor3 = config.TextColor
                TextboxBtn.TextSize = 16
                TextboxBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBtnC.CornerRadius = UDim.new(0, 6)
                TextboxBtnC.Name = "TextboxBtnC"
                TextboxBtnC.Parent = TextboxBtn
                
                TextboxBox.Name = "TextboxBox"
                TextboxBox.Parent = TextboxBtn
                TextboxBox.BackgroundColor3 = config.Bg_Color
                TextboxBox.BorderSizePixel = 0
                TextboxBox.Position = UDim2.new(0.7, 0, 0.184, 0)
                TextboxBox.Size = UDim2.new(0, 120, 0, 22)
                TextboxBox.Font = Enum.Font.GothamSemibold
                TextboxBox.PlaceholderText = placeholder or ""
                TextboxBox.Text = ""
                TextboxBox.TextColor3 = config.TextColor
                TextboxBox.TextSize = 14
                TextboxBox.ClearTextOnFocus = false
                
                TextboxBoxC.CornerRadius = UDim.new(0, 4)
                TextboxBoxC.Name = "TextboxBoxC"
                TextboxBoxC.Parent = TextboxBox
                
                TextboxBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(TextboxBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Textbox_Color.R * 255 * 1.1),
                            math.floor(config.Textbox_Color.G * 255 * 1.1),
                            math.floor(config.Textbox_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                TextboxBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Textbox_Color
                    }):Play()
                end)
                
                TextboxBox.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        library.flaFengYu[flag] = TextboxBox.Text
                        callback(TextboxBox.Text)
                    end
                end)
                
                return {
                    Set = function(self, value)
                        TextboxBox.Text = tostring(value)
                        library.flaFengYu[flag] = tostring(value)
                        callback(tostring(value))
                    end,
                    Get = function(self)
                        return library.flaFengYu[flag]
                    end
                }
            end
            
            function section.Dropdown(section, text, flag, list, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flaFengYu[flag] = nil

                local DropdownModule = Instance.new("Frame")
                local DropdownBtn = Instance.new("TextButton")
                local DropdownBtnC = Instance.new("UICorner")
                local DropdownVal = Instance.new("TextLabel")
                local DropdownArrow = Instance.new("ImageLabel")
                local DropdownList = Instance.new("ScrollingFrame")
                local DropdownListL = Instance.new("UIListLayout")
                local DropdownListC = Instance.new("UICorner")
                
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.Size = UDim2.new(0, 448, 0, 38)
                
                DropdownBtn.Name = "DropdownBtn"
                DropdownBtn.Parent = DropdownModule
                DropdownBtn.BackgroundColor3 = config.Dropdown_Color
                DropdownBtn.BorderSizePixel = 0
                DropdownBtn.Size = UDim2.new(0, 448, 0, 38)
                DropdownBtn.AutoButtonColor = false
                DropdownBtn.Font = Enum.Font.GothamSemibold
                DropdownBtn.Text = "   " .. text
                DropdownBtn.TextColor3 = config.TextColor
                DropdownBtn.TextSize = 16
                DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownBtnC.CornerRadius = UDim.new(0, 6)
                DropdownBtnC.Name = "DropdownBtnC"
                DropdownBtnC.Parent = DropdownBtn
                
                DropdownVal.Name = "DropdownVal"
                DropdownVal.Parent = DropdownBtn
                DropdownVal.BackgroundTransparency = 1
                DropdownVal.Position = UDim2.new(0.7, 0, 0, 0)
                DropdownVal.Size = UDim2.new(0, 100, 0, 38)
                DropdownVal.Font = Enum.Font.GothamSemibold
                DropdownVal.Text = "None"
                DropdownVal.TextColor3 = config.SecondaryTextColor
                DropdownVal.TextSize = 16
                DropdownVal.TextXAlignment = Enum.TextXAlignment.Right
                
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Parent = DropdownVal
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position = UDim2.new(1.1, 0, 0.237, 0)
                DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                DropdownArrow.Image = "rbxassetid://84830962019412"
                DropdownArrow.ImageColor3 = config.SecondaryTextColor
                DropdownArrow.Rotation = 0
                
                DropdownList.Name = "DropdownList"
                DropdownList.Parent = DropdownBtn
                DropdownList.Active = true
                DropdownList.BackgroundColor3 = config.Dropdown_Color
                DropdownList.BorderSizePixel = 0
                DropdownList.Position = UDim2.new(0, 0, 1, 4)
                DropdownList.Size = UDim2.new(0, 448, 0, 0)
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
                DropdownList.ScrollBarThickness = 2
                DropdownList.Visible = false
                
                DropdownListL.Name = "DropdownListL"
                DropdownListL.Parent = DropdownList
                DropdownListL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownListL.Padding = UDim.new(0, 4)
                
                DropdownListC.CornerRadius = UDim.new(0, 6)
                DropdownListC.Name = "DropdownListC"
                DropdownListC.Parent = DropdownList
                
                DropdownBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(DropdownBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Dropdown_Color.R * 255 * 1.1),
                            math.floor(config.Dropdown_Color.G * 255 * 1.1),
                            math.floor(config.Dropdown_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                DropdownBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(DropdownBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Dropdown_Color
                    }):Play()
                end)
                
                local open = false
                local selected = nil
                
                local function updateList()
                    for _, v in next, DropdownList:GetChildren() do
                        if v:IsA("TextButton") then
                            v:Destroy()
                        end
                    end
                    
                    for _, v in next, list do
                        local Option = Instance.new("TextButton")
                        Option.Name = "Option"
                        Option.Parent = DropdownList
                        Option.BackgroundColor3 = config.Bg_Color
                        Option.BorderSizePixel = 0
                        Option.Size = UDim2.new(0, 448, 0, 30)
                        Option.AutoButtonColor = false
                        Option.Font = Enum.Font.GothamSemibold
                        Option.Text = "   " .. tostring(v)
                        Option.TextColor3 = config.TextColor
                        Option.TextSize = 14
                        Option.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local OptionC = Instance.new("UICorner")
                        OptionC.CornerRadius = UDim.new(0, 6)
                        OptionC.Name = "OptionC"
                        OptionC.Parent = Option
                        
                        Option.MouseEnter:Connect(function()
                            services.TweenService:Create(Option, TweenInfo.new(0.2), {
                                BackgroundColor3 = Color3.fromRGB(
                                    math.floor(config.Bg_Color.R * 255 * 1.1),
                                    math.floor(config.Bg_Color.G * 255 * 1.1),
                                    math.floor(config.Bg_Color.B * 255 * 1.1)
                                )
                            }):Play()
                        end)
                        
                        Option.MouseLeave:Connect(function()
                            services.TweenService:Create(Option, TweenInfo.new(0.2), {
                                BackgroundColor3 = config.Bg_Color
                            }):Play()
                        end)
                        
                        Option.MouseButton1Click:Connect(function()
                            Ripple(Option)
                            selected = v
                            DropdownVal.Text = tostring(v)
                            library.flaFengYu[flag] = v
                            callback(v)
                            
                            services.TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                                Size = UDim2.new(0, 448, 0, 0)
                            }):Play()
                            
                            services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                                Rotation = 0
                            }):Play()
                            
                            task.wait(0.2)
                            DropdownList.Visible = false
                            open = false
                        end)
                    end
                    
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownListL.AbsoluteContentSize.Y)
                end
                
                updateList()
                
                DropdownBtn.MouseButton1Click:Connect(function()
                    Ripple(DropdownBtn)
                    open = not open
                    
                    if open then
                        DropdownList.Visible = true
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, 448, 0, math.clamp(DropdownListL.AbsoluteContentSize.Y, 0, 150))
                        }):Play()
                        
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                            Rotation = 180
                        }):Play()
                    else
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, 448, 0, 0)
                        }):Play()
                        
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                            Rotation = 0
                        }):Play()
                        
                        task.wait(0.2)
                        DropdownList.Visible = false
                    end
                end)
                
                DropdownListL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, 448, 0, math.clamp(DropdownListL.AbsoluteContentSize.Y, 0, 150))
                        }):Play()
                    end
                    
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownListL.AbsoluteContentSize.Y)
                end)
                
                return {
                    Set = function(self, value)
                        if table.find(list, value) then
                            selected = value
                            DropdownVal.Text = tostring(value)
                            library.flaFengYu[flag] = value
                            callback(value)
                        end
                    end,
                    Get = function(self)
                        return library.flaFengYu[flag]
                    end,
                    Refresh = function(self, newList)
                        list = newList
                        updateList()
                    end
                }
            end
            
            function section.Keybind(section, text, flag, default, callback)
                callback = callback or function() end
                default = default or Enum.KeyCode.Unknown
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flaFengYu[flag] = default

                local KeybindModule = Instance.new("Frame")
                local KeybindBtn = Instance.new("TextButton")
                local KeybindBtnC = Instance.new("UICorner")
                local KeybindVal = Instance.new("TextButton")
                local KeybindValC = Instance.new("UICorner")
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(0, 448, 0, 38)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, 448, 0, 38)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 16
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                KeybindVal.Name = "KeybindVal"
                KeybindVal.Parent = KeybindBtn
                KeybindVal.BackgroundColor3 = config.Bg_Color
                KeybindVal.BorderSizePixel = 0
                KeybindVal.Position = UDim2.new(0.8, 0, 0.184, 0)
                KeybindVal.Size = UDim2.new(0, 80, 0, 22)
                KeybindVal.AutoButtonColor = false
                KeybindVal.Font = Enum.Font.GothamSemibold
                KeybindVal.Text = tostring(default.Name)
                KeybindVal.TextColor3 = config.TextColor
                KeybindVal.TextSize = 14
                
                KeybindValC.CornerRadius = UDim.new(0, 4)
                KeybindValC.Name = "KeybindValC"
                KeybindValC.Parent = KeybindVal
                
                KeybindBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Keybind_Color.R * 255 * 1.1),
                            math.floor(config.Keybind_Color.G * 255 * 1.1),
                            math.floor(config.Keybind_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Keybind_Color
                    }):Play()
                end)
                
                local listening = false
                
                KeybindVal.MouseButton1Click:Connect(function()
                    Ripple(KeybindVal)
                    listening = true
                    KeybindVal.Text = "..."
                    KeybindVal.BackgroundColor3 = config.AccentColor
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            library.flaFengYu[flag] = input.KeyCode
                            KeybindVal.Text = tostring(input.KeyCode.Name)
                            KeybindVal.BackgroundColor3 = config.Bg_Color
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            listening = false
                            library.flaFengYu[flag] = Enum.KeyCode.Unknown
                            KeybindVal.Text = "Mouse1"
                            KeybindVal.BackgroundColor3 = config.Bg_Color
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            listening = false
                            library.flaFengYu[flag] = Enum.KeyCode.Unknown
                            KeybindVal.Text = "Mouse2"
                            KeybindVal.BackgroundColor3 = config.Bg_Color
                        end
                    else
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == library.flaFengYu[flag] then
                            callback()
                        end
                    end
                end)
                
                return {
                    Set = function(self, value)
                        library.flaFengYu[flag] = value
                        KeybindVal.Text = tostring(value.Name)
                    end,
                    Get = function(self)
                        return library.flaFengYu[flag]
                    end
                }
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

return library