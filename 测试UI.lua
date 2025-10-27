repeat
    task.wait()
until game:IsLoaded()

settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

local isSynapse = syn and syn.protect_gui ~= nil
local isScriptWare = secure_load ~= nil
local isKrnl = krnl and krnl.protect_gui ~= nil
local isFluxus = fluxus and fluxus.protect_gui ~= nil
local isElectron = is_sirhurt_closure ~= nil
local isComet = comet and comet.protect_gui ~= nil
local isOxygen = getexecutorname and getexecutorname():lower():find("oxygen") ~= nil
local isAlus = alus and alus.protect_gui ~= nil
local isXeno = xeno and xeno.protect_gui ~= nil

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
    elseif isXeno then
        xeno.protect_gui(gui)
    end
    
    local success, err = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("RobloxGui", gui)
    end
end

local FengY3 = {}
local ToggleUI = true
FengY3.currentTab = nil
FengY3.flaFengYu = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

-- WindUI 风格配色方案
local config = {
    MainColor = Color3.fromRGB(13, 17, 23),
    TabColor = Color3.fromRGB(22, 27, 34),
    Bg_Color = Color3.fromRGB(13, 17, 23),
    Zy_Color = Color3.fromRGB(13, 17, 23), 
    Button_Color = Color3.fromRGB(33, 38, 45),
    Textbox_Color = Color3.fromRGB(33, 38, 45),
    Dropdown_Color = Color3.fromRGB(33, 38, 45),
    Keybind_Color = Color3.fromRGB(33, 38, 45),
    Label_Color = Color3.fromRGB(33, 38, 45),
    Slider_Color = Color3.fromRGB(33, 38, 45),
    SliderBar_Color = Color3.fromRGB(47, 129, 247),
    Toggle_Color = Color3.fromRGB(33, 38, 45),
    Toggle_Off = Color3.fromRGB(48, 54, 61),
    Toggle_On = Color3.fromRGB(47, 129, 247),
    AccentColor = Color3.fromRGB(47, 129, 247),
    TextColor = Color3.fromRGB(248, 250, 252),
    SecondaryTextColor = Color3.fromRGB(139, 148, 158),
    GlowColor = Color3.fromRGB(47, 129, 247),
    BorderColor = Color3.fromRGB(48, 54, 61),
    HoverColor = Color3.fromRGB(40, 46, 53)
}

local function startRainbowEffect(object, property, speed)
    speed = speed or 0.005
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + speed) % 1
        object[property] = Color3.fromHSV(hue, 0.8, 1)
    end)
    return connection
end

local function createAuroraEffect(frame, intensity)
    intensity = intensity or 1
    
    local aurora = Instance.new("Frame")
    aurora.Name = "AuroraEffect"
    aurora.BackgroundTransparency = 1
    aurora.Size = UDim2.new(1, 0, 1, 0)
    aurora.ZIndex = frame.ZIndex - 1
    aurora.Parent = frame
    aurora.ClipsDescendants = true
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.2 * intensity),
        NumberSequenceKeypoint.new(1, 0)
    })
    gradient.Parent = aurora
    
    local colors = {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(47, 129, 247)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(56, 139, 253)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(65, 149, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(74, 159, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(83, 169, 255))
    }
    
    gradient.Color = ColorSequence.new(colors)
    
    local sizeConnection
    sizeConnection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        aurora.Size = UDim2.new(2, 0, 2, 0)
    end)
    
    local xOffset = 0
    local yOffset = 0
    local xDir = 1
    local yDir = 1
    local xSpeed = 0.5
    local ySpeed = 0.3
    
    local heartbeatConnection
    heartbeatConnection = RunService.Heartbeat:Connect(function(delta)
        if not aurora or not aurora.Parent then
            heartbeatConnection:Disconnect()
            sizeConnection:Disconnect()
            return
        end
        
        xOffset = (xOffset + xSpeed * delta * xDir) % 1
        yOffset = (yOffset + ySpeed * delta * yDir) % 1
        
        if xOffset >= 0.9 or xOffset <= 0.1 then xDir = xDir * -1 end
        if yOffset >= 0.9 or yOffset <= 0.1 then yDir = yDir * -1 end
        
        aurora.Position = UDim2.new(-0.5 + xOffset, 0, -0.5 + yOffset, 0)
        
        for i, keypoint in ipairs(colors) do
            local time = tick() * 0.1 + i * 0.2
            local h = (time % 1) * 360
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV((h/360) % 1, 0.8, 1)
            )
        end
        gradient.Color = ColorSequence.new(colors)
    end)
    
    return aurora
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
        Ripple.ImageTransparency = 0.6
        Ripple.ScaleType = Enum.ScaleType.Fit
        
        local hue = tick() % 5 / 5
        Ripple.ImageColor3 = Color3.fromHSV(hue, 0.8, 1)
        
        local x = (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X
        local y = (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y
        Ripple.Position = UDim2.new(x, 0, y, 0)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.8, 0, -0.8, 0),
            Size = UDim2.new(2.6, 0, 2.6, 0)
        }):Play()
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageTransparency = 1
        }):Play()
        
        task.wait(0.8)
        Ripple:Destroy()
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
    
    local old = FengY3.currentTab
    if old == nil then
        new[2].Visible = true
        FengY3.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { ImageTransparency = 0 }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengY3.currentTab = new
    
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

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

-- WindUI 风格主窗口
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.Bg_Color
Main.BackgroundTransparency = 0.1
Main.Position = UDim2.new(0.5, 0, 0.4, 0)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = config.BorderColor
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3

-- WindUI 风格标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.ZIndex = 2

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "WindUI"
TitleText.TextColor3 = config.TextColor
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0.5, -10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = config.SecondaryTextColor
CloseButton.TextSize = 18
CloseButton.ZIndex = 10

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = Color3.fromRGB(248, 81, 109),
        BackgroundTransparency = 0.9,
        BackgroundColor3 = Color3.fromRGB(248, 81, 109)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        TextColor3 = config.SecondaryTextColor,
        BackgroundTransparency = 1
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    Ripple(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        BackgroundTransparency = 0.8
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
Open.Size = UDim2.new(0, 45, 0, 45)
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
OpenStroke.Color = config.AccentColor
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0.4

startRainbowEffect(Open, "BackgroundColor3", 0.012)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 40)
TabMain.Size = UDim2.new(0, 400, 0, 275)

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.1
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 35)
Side.Size = UDim2.new(0, 100, 0, 285)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = Side

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0.05, 0)
TabBtns.Size = UDim2.new(0, 100, 0, 265)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = config.BorderColor
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y)
    
    TabBtns.ScrollingEnabled = TabBtnsL.AbsoluteContentSize.Y > TabBtns.AbsoluteSize.Y
    TabBtns.ElasticBehavior = Enum.ElasticBehavior.Never
end)

function FengY3.new(FengY3, name, theme)
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

    TitleText.Text = name or "WindUI"
    
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
        Tab.ScrollBarImageColor3 = config.BorderColor
        Tab.ScrollBarImageTransparency = 0.5
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundColor3 = config.Button_Color
        TabIco.BackgroundTransparency = 0.8
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 80, 0, 32)
        TabIco.Image = "rbxassetid://84830962019412"
        TabIco.ImageTransparency = 0.5
        
        local TabIcoCorner = Instance.new("UICorner")
        TabIcoCorner.CornerRadius = UDim.new(0, 6)
        TabIcoCorner.Parent = TabIco
        
        startRainbowEffect(TabIco, "ImageColor3", 0.005)
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Size = UDim2.new(1, 0, 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 13
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(1, 0, 1, 0)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 6)
        
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({ TabIco, Tab })
        end)
        
        if FengY3.currentTab == nil then
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
            Section.BackgroundTransparency = 0.1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.95, 0, 0, 40)
            
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.088, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 320, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 14
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, -26, 0, 9)
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
            Objs.Position = UDim2.new(0, 6, 0, 40)
            Objs.Size = UDim2.new(0.98, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 6)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 6 or 40)
                SectionOpened.ImageTransparency = open and 0 or 1
                SectionOpen.ImageTransparency = open and 1 or 0
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.2), {
                    Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 6 or 40)
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
                Section.Size = UDim2.new(0.95, 0, 0, 40 + ObjsL.AbsoluteContentSize.Y + 6)
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
                BtnModule.Size = UDim2.new(0, 380, 0, 36)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.1
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, 380, 0, 36)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 14
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                local btnStroke = Instance.new("UIStroke")
                btnStroke.Parent = Btn
                btnStroke.Color = config.BorderColor
                btnStroke.Thickness = 1
                btnStroke.Transparency = 0.5
                
                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.HoverColor,
                        BackgroundTransparency = 0.05
                    }):Play()
                    services.TweenService:Create(btnStroke, TweenInfo.new(0.2), {
                        Color = config.AccentColor,
                        Transparency = 0.3
                    }):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                    services.TweenService:Create(btnStroke, TweenInfo.new(0.2), {
                        Color = config.BorderColor,
                        Transparency = 0.5
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    callback()
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = config.AccentColor,
                        BackgroundTransparency = 0.3
                    }):Play()
                    services.TweenService:Create(btnStroke, TweenInfo.new(0.1), {
                        Color = config.AccentColor,
                        Thickness = 2,
                        Transparency = 0.2
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                    services.TweenService:Create(btnStroke, TweenInfo.new(0.2), {
                        Color = config.BorderColor,
                        Thickness = 1,
                        Transparency = 0.5
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
                ImageModule.Size = UDim2.new(0, 380, 0, sizeY or 120)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundColor3 = config.Bg_Color
                ImageLabel.BackgroundTransparency = 0.1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, 370), 0, sizeY or 120)
                ImageLabel.Image = "rbxassetid://" .. tostring(imageId)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 6)
                ImageCorner.Parent = ImageLabel
                
                local imageStroke = Instance.new("UIStroke")
                imageStroke.Parent = ImageLabel
                imageStroke.Color = config.BorderColor
                imageStroke.Thickness = 1
                imageStroke.Transparency = 0.5
                
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
                LabelModule.Size = UDim2.new(0, 380, 0, 28)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.1
                TextLabel.Size = UDim2.new(0, 380, 0, 28)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 13
                
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
                local labelStroke = Instance.new("UIStroke")
                labelStroke.Parent = TextLabel
                labelStroke.Color = config.BorderColor
                labelStroke.Thickness = 1
                labelStroke.Transparency = 0.5
                
                return TextLabel
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengY3.flaFengYu[flag] = enabled

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
                ToggleModule.Size = UDim2.new(0, 380, 0, 36)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.1
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, 380, 0, 36)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 14
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                local toggleStroke = Instance.new("UIStroke")
                toggleStroke.Parent = ToggleBtn
                toggleStroke.Color = config.BorderColor
                toggleStroke.Thickness = 1
                toggleStroke.Transparency = 0.5
                
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
                    createAuroraEffect(ToggleSwitch, 0.8)
                end
                
                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.HoverColor,
                        BackgroundTransparency = 0.05
                    }):Play()
                    services.TweenService:Create(toggleStroke, TweenInfo.new(0.2), {
                        Color = config.AccentColor,
                        Transparency = 0.3
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Toggle_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                    services.TweenService:Create(toggleStroke, TweenInfo.new(0.2), {
                        Color = config.BorderColor,
                        Transparency = 0.5
                    }):Play()
                end)
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengY3.flaFengYu[flag]
                        end
                        if FengY3.flaFengYu[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, state and 14 or 0, 0, 0),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        if state then
                            createAuroraEffect(ToggleSwitch, 0.8)
                        else
                            local aurora = ToggleSwitch:FindFirstChild("AuroraEffect")
                            if aurora then
                                aurora:Destroy()
                            end
                        end
                        
                        FengY3.flaFengYu[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Ripple(ToggleBtn)
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
                KeybindModule.Size = UDim2.new(0, 380, 0, 36)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.1
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, 380, 0, 36)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 14
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                local keybindStroke = Instance.new("UIStroke")
                keybindStroke.Parent = KeybindBtn
                keybindStroke.Color = config.BorderColor
                keybindStroke.Thickness = 1
                keybindStroke.Transparency = 0.5
                
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
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.HoverColor,
                        BackgroundTransparency = 0.05
                    }):Play()
                    services.TweenService:Create(keybindStroke, TweenInfo.new(0.2), {
                        Color = config.AccentColor,
                        Transparency = 0.3
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Keybind_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                    services.TweenService:Create(keybindStroke, TweenInfo.new(0.2), {
                        Color = config.BorderColor,
                        Transparency = 0.5
                    }):Play()
                end)
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                KeybindValue.MouseButton1Click:Connect(function()
                    Ripple(KeybindValue)
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
                
                FengY3.flaFengYu[flag] = default
                
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
                TextboxModule.Size = UDim2.new(0, 380, 0, 36)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.1
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, 380, 0, 36)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 14
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                local textboxStroke = Instance.new("UIStroke")
                textboxStroke.Parent = TextboxBack
                textboxStroke.Color = config.BorderColor
                textboxStroke.Thickness = 1
                textboxStroke.Transparency = 0.5
                
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
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.HoverColor,
                        BackgroundTransparency = 0.05
                    }):Play()
                    services.TweenService:Create(textboxStroke, TweenInfo.new(0.2), {
                        Color = config.AccentColor,
                        Transparency = 0.3
                    }):Play()
                end)
                
                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Textbox_Color,
                        BackgroundTransparency = 0.1
                    }):Play()
                    services.TweenService:Create(textboxStroke, TweenInfo.new(0.2), {
                        Color = config.BorderColor,
                        Transparency = 0.5
                    }):Play()
                end)
                
                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    FengY3.flaFengYu[flag] = TextBox.Text
                    callback(TextBox.Text)
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
                
                FengY3.flaFengYu[flag] = default

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
                SliderModule.Size = UDim2.new(0, 380, 0, 36)
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.1
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(0, 380, 0, 36)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderBack.TextSize = 14.000
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                local sliderStroke = Instance.new("UIStroke")
                sliderStroke.Parent = SliderBack
                sliderStroke.Color = config.BorderColor
                sliderStroke.Thickness = 1
                sliderStroke.Transparency = 0.5
                
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
                        FengY3.flaFengYu[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        
                        services.TweenService:Create(SliderPart, TweenInfo.new(0.1), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        callback(tonumber(value))
                    end,
                    
                    GetValue = function(self)
                        return FengY3.flaFengYu[flag]
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
                    Ripple(MinSlider)
                    local currentValue = FengY3.flaFengYu[flag]
                    currentValue = math.clamp(currentValue - 1, min, max)
                    funcs:SetValue(currentValue)
                end)
                
                AddSlider.MouseButton1Click:Connect(function()
                    Ripple(AddSlider)
                    local currentValue = FengY3.flaFengYu[flag]
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
                FengY3.flaFengYu[flag] = nil
                
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
                DropdownModule.Size = UDim2.new(0, 380, 0, 36)
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0.1
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(0, 380, 0, 36)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = config.TextColor
                DropdownTop.TextSize = 14.000
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop
                
                local dropdownStroke = Instance.new("UIStroke")
                dropdownStroke.Parent = DropdownTop
                dropdownStroke.Color = config.BorderColor
                dropdownStroke.Thickness = 1
                dropdownStroke.Transparency = 0.5
                
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
                
                createAuroraEffect(DropdownOpenFrame, 0.8)
                
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
                    DropdownModule.Size = UDim2.new(0, 380, 0, (open and math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150) or 36))
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
                    DropdownModule.Size = UDim2.new(0, 380, 0, math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150))
                end)
                
                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    local OptionC = Instance.new("UICorner")
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownModule
                    Option.BackgroundColor3 = config.TabColor
                    Option.BackgroundTransparency = 0.1
                    Option.BorderSizePixel = 0
                    Option.Position = UDim2.new(0, 0, 0.328125, 0)
                    Option.Size = UDim2.new(0, 360, 0, 24)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 13.000
                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    local optionStroke = Instance.new("UIStroke")
                    optionStroke.Parent = Option
                    optionStroke.Color = config.BorderColor
                    optionStroke.Thickness = 1
                    optionStroke.Transparency = 0.5
                    
                    Option.MouseButton1Click:Connect(function()
                        Ripple(Option)
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        FengY3.flaFengYu[flag] = Option.Text
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

return FengY3