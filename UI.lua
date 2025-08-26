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

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.009, 0)
ScriptTitle.Size = UDim2.new(0, 110, 0, 20)
ScriptTitle.Font = Enum.Font.GothamSemibold
ScriptTitle.Text = "Delta"
ScriptTitle.TextColor3 = config.AccentColor
ScriptTitle.TextSize = 16
ScriptTitle.TextScaled = true
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

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

    ScriptTitle.Text = name or "Delta"

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
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not library.flaFengYu[flag]
                        end
                        if library.flaFengYu[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, state and 12 or 0, 0, 0),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        library.flaFengYu[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
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
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.763, 0, 0.289, 0)
                KeybindValue.Size = UDim2.new(0, 100, 0, 28)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 14
                
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
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                KeybindValue.MouseButton1Click:Connect(function()
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
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
                end)
                
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end
            
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                
                library.flaFengYu[flag] = default
                
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
                TextboxModule.Size = UDim2.new(0, 448, 0, 38)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, 448, 0, 38)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 16
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.763, 0, 0.289, 0)
                BoxBG.Size = UDim2.new(0, 100, 0, 28)
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
                TextBox.TextSize = 14
                TextBox.PlaceholderColor3 = config.SecondaryTextColor
                
                TextboxBackL.Name = "TextboxBackL"
                TextboxBackL.Parent = TextboxBack
                TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
                TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center
                
                TextboxBackP.Name = "TextboxBackP"
                TextboxBackP.Parent = TextboxBack
                TextboxBackP.PaddingRight = UDim.new(0, 6)
                
                TextboxBack.MouseEnter:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Textbox_Color.R * 255 * 1.1),
                            math.floor(config.Textbox_Color.G * 255 * 1.1),
                            math.floor(config.Textbox_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Textbox_Color
                    }):Play()
                end)
                
                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    library.flaFengYu[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)
                
                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
                end)
                
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
            end
            
            -- 修复后的滑块功能 - 现在可以正常滑动
            function section.Slider(section, text, flag, default, min, max, precise, callback)
    callback = callback or function() end
    min = min or 1
    max = max or 10
    default = default or min
    precise = precise or false
    
    assert(text, "No text provided")
    assert(flag, "No flag provided")
    assert(default, "No default value provided")
    
    library.flaFengYu[flag] = default

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
    local MinSlider = Instance.new("TextButton")
    local AddSlider = Instance.new("TextButton")
    local SliderText = Instance.new("TextLabel")
    
    SliderModule.Name = "SliderModule"
    SliderModule.Parent = Objs
    SliderModule.BackgroundTransparency = 1
    SliderModule.BorderSizePixel = 0
    SliderModule.Size = UDim2.new(0, 448, 0, 38)
    
    SliderBack.Name = "SliderBack"
    SliderBack.Parent = SliderModule
    SliderBack.BackgroundColor3 = config.Slider_Color
    SliderBack.BorderSizePixel = 0
    SliderBack.Size = UDim2.new(0, 448, 0, 38)
    SliderBack.AutoButtonColor = false
    SliderBack.Font = Enum.Font.GothamSemibold
    SliderBack.Text = ""
    SliderBack.TextColor3 = config.TextColor
    SliderBack.TextSize = 16
    SliderBack.TextXAlignment = Enum.TextXAlignment.Left
    
    SliderBackC.CornerRadius = UDim.new(0, 6)
    SliderBackC.Name = "SliderBackC"
    SliderBackC.Parent = SliderBack
    
    -- 滑块文本标签
    SliderText.Name = "SliderText"
    SliderText.Parent = SliderBack
    SliderText.BackgroundTransparency = 1
    SliderText.Position = UDim2.new(0.03, 0, 0, 0)
    SliderText.Size = UDim2.new(0, 150, 1, 0)
    SliderText.Font = Enum.Font.GothamSemibold
    SliderText.Text = text
    SliderText.TextColor3 = config.TextColor
    SliderText.TextSize = 14
    SliderText.TextXAlignment = Enum.TextXAlignment.Left
    
    SliderBar.Name = "SliderBar"
    SliderBar.Parent = SliderBack
    SliderBar.AnchorPoint = Vector2.new(0, 0.5)
    SliderBar.BackgroundColor3 = config.Bg_Color
    SliderBar.BorderSizePixel = 0
    SliderBar.Position = UDim2.new(0.4, 0, 0.5, 0)
    SliderBar.Size = UDim2.new(0.35, 0, 0, 8)
    
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
    SliderValBG.Position = UDim2.new(0.8, 0, 0.2, 0)
    SliderValBG.Size = UDim2.new(0, 60, 0, 24)
    SliderValBG.AutoButtonColor = false
    SliderValBG.Font = Enum.Font.Gotham
    SliderValBG.Text = ""
    
    SliderValBGC.CornerRadius = UDim.new(0, 4)
    SliderValBGC.Name = "SliderValBGC"
    SliderValBGC.Parent = SliderValBG
    
    SliderValue.Name = "SliderValue"
    SliderValue.Parent = SliderValBG
    SliderValue.BackgroundTransparency = 1
    SliderValue.BorderSizePixel = 0
    SliderValue.Size = UDim2.new(1, 0, 1, 0)
    SliderValue.Font = Enum.Font.Gotham
    SliderValue.Text = tostring(default)
    SliderValue.TextColor3 = config.TextColor
    SliderValue.TextSize = 14
    SliderValue.TextXAlignment = Enum.TextXAlignment.Center
    
    MinSlider.Name = "MinSlider"
    MinSlider.Parent = SliderBack
    MinSlider.BackgroundTransparency = 1
    MinSlider.BorderSizePixel = 0
    MinSlider.Position = UDim2.new(0.76, 0, 0.2, 0)
    MinSlider.Size = UDim2.new(0, 20, 0, 24)
    MinSlider.Font = Enum.Font.GothamBold
    MinSlider.Text = "-"
    MinSlider.TextColor3 = config.TextColor
    MinSlider.TextSize = 18
    MinSlider.TextWrapped = true
    
    AddSlider.Name = "AddSlider"
    AddSlider.Parent = SliderBack
    AddSlider.BackgroundTransparency = 1
    AddSlider.BorderSizePixel = 0
    AddSlider.Position = UDim2.new(0.93, 0, 0.2, 0)
    AddSlider.Size = UDim2.new(0, 20, 0, 24)
    AddSlider.Font = Enum.Font.GothamBold
    AddSlider.Text = "+"
    AddSlider.TextColor3 = config.TextColor
    AddSlider.TextSize = 18
    AddSlider.TextWrapped = true
    
    SliderBack.MouseEnter:Connect(function()
        services.TweenService:Create(SliderBack, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(config.Slider_Color.R * 255 * 1.1),
                math.floor(config.Slider_Color.G * 255 * 1.1),
                math.floor(config.Slider_Color.B * 255 * 1.1)
            )
        }):Play()
    end)
    
    SliderBack.MouseLeave:Connect(function()
        services.TweenService:Create(SliderBack, TweenInfo.new(0.2), {
            BackgroundColor3 = config.Slider_Color
        }):Play()
    end)
    
    local funcs = {
        SetValue = function(self, value)
            local percent
            
            if value then
                percent = (value - min)/(max - min)
            else
                local mouse = services.Players.LocalPlayer:GetMouse()
                percent = (mouse.X - SliderBar.AbsolutePosition.X)/SliderBar.AbsoluteSize.X
            end
            
            percent = math.clamp(percent, 0, 1)
            
            if precise then
                value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent)))
            else
                value = value or math.floor(min + (max - min) * percent)
            end
            
            value = math.clamp(value, min, max)
            library.flaFengYu[flag] = tonumber(value)
            SliderValue.Text = tostring(value)
            
            services.TweenService:Create(SliderPart, TweenInfo.new(0.1), {
                Size = UDim2.new(percent, 0, 1, 0)
            }):Play()
            
            callback(tonumber(value))
        end,
        
        GetValue = function(self)
            return library.flaFengYu[flag]
        end
    }
    
    MinSlider.MouseButton1Click:Connect(function()
        local currentValue = library.flaFengYu[flag]
        currentValue = math.clamp(currentValue - 1, min, max)
        funcs:SetValue(currentValue)
    end)
    
    AddSlider.MouseButton1Click:Connect(function()
        local currentValue = library.flaFengYu[flag]
        currentValue = math.clamp(currentValue + 1, min, max)
        funcs:SetValue(currentValue)
    end)
    
    funcs:SetValue(default)
    
    local dragging = false
    
    -- 修复滑块拖动功能
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            funcs:SetValue()
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            funcs:SetValue()
        end
    end)
    
    -- 文本框输入功能
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
        if not boxFocused then return end
        
        -- 只允许数字输入
        local text = SliderValue.Text
        local filtered = text:gsub("%D+", "")
        
        if text ~= filtered then
            SliderValue.Text = filtered
        end
        
        local numValue = tonumber(filtered)
        if numValue and not allowed[filtered] then
            if numValue > max then
                SliderValue.Text = tostring(max)
            end
        end
    end)
    
    return funcs
end
            
            function section.Dropdown(section, text, flag, options, callback)
                callback = callback or function() end
                options = options or {}
                
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                library.flaFengYu[flag] = nil
                
                local DropdownModule = Instance.new("Frame")
                local DropdownTop = Instance.new("TextButton")
                local DropdownTopC = Instance.new("UICorner")
                local DropdownOpen = Instance.new("TextButton")
                local DropdownText = Instance.new("TextBox")
                local DropdownModuleL = Instance.new("UIListLayout")
                
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(0, 448, 0, 38)
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(0, 448, 0, 38)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = config.TextColor
                DropdownTop.TextSize = 16
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop
                
                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownTop
                DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpen.BackgroundTransparency = 1
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Position = UDim2.new(0.918, 0, 0.5, 0)
                DropdownOpen.Size = UDim2.new(0, 20, 0, 20)
                DropdownOpen.Font = Enum.Font.Gotham
                DropdownOpen.Text = "+"
                DropdownOpen.TextColor3 = config.TextColor
                DropdownOpen.TextSize = 24
                DropdownOpen.TextWrapped = true
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundTransparency = 1
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 184, 0, 38)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.PlaceholderColor3 = config.SecondaryTextColor
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = 16
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownModuleL.Name = "DropdownModuleL"
                DropdownModuleL.Parent = DropdownModule
                DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownModuleL.Padding = UDim.new(0, 4)
                
                DropdownTop.MouseEnter:Connect(function()
                    services.TweenService:Create(DropdownTop, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Dropdown_Color.R * 255 * 1.1),
                            math.floor(config.Dropdown_Color.G * 255 * 1.1),
                            math.floor(config.Dropdown_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                DropdownTop.MouseLeave:Connect(function()
                    services.TweenService:Create(DropdownTop, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Dropdown_Color
                    }):Play()
                end)
                
                local setAllVisible = function()
                    for _, option in next, DropdownModule:GetChildren() do
                        if option:IsA("TextButton") and option.Name:match("Option_") then
                            option.Visible = true
                        end
                    end
                end
                
                local searchDropdown = function(text)
                    for _, option in next, DropdownModule:GetChildren() do
                        if option:IsA("TextButton") and option.Name:match("Option_") then
                            if text == "" then
                                option.Visible = true
                            else
                                option.Visible = option.Text:lower():match(text:lower()) ~= nil
                            end
                        end
                    end
                end
                
                local open = false
                local ToggleDropVis = function()
                    open = not open
                    if open then setAllVisible() end
                    DropdownOpen.Text = open and "-" or "+"
                    
                    services.TweenService:Create(DropdownModule, TweenInfo.new(0.2), {
                        Size = UDim2.new(0, 448, 0, open and DropdownModuleL.AbsoluteContentSize.Y + 4 or 38)
                    }):Play()
                end
                
                DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)
                
                DropdownText.Focused:Connect(function()
                    if not open then ToggleDropVis() end
                end)
                
                DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                    if open then searchDropdown(DropdownText.Text) end
                end)
                
                DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then
                        DropdownModule.Size = UDim2.new(0, 448, 0, DropdownModuleL.AbsoluteContentSize.Y + 4)
                    end
                end)
                
                local funcs = {}
                
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    local OptionC = Instance.new("UICorner")
                    
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownModule
                    Option.BackgroundColor3 = config.TabColor
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(0, 448, 0, 26)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 14
                    
                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    Option.MouseEnter:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.TabColor.R * 255 * 1.1),
                                math.floor(config.TabColor.G * 255 * 1.1),
                                math.floor(config.TabColor.B * 255 * 1.1)
                            )
                        }):Play()
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = config.TabColor
                        }):Play()
                    end)
                    
                    Option.MouseButton1Click:Connect(function()
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        library.flaFengYu[flag] = Option.Text
                    end)
                end
                
                funcs.RemoveOption = function(self, option)
                    local option = DropdownModule:FindFirstChild("Option_" .. option)
                    if option then option:Destroy() end
                end
                
                funcs.SetOptions = function(self, options)
                    for _, v in next, DropdownModule:GetChildren() do
                        if v.Name:match("Option_") then v:Destroy() end
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

return library