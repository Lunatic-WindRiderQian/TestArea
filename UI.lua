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

-- 创建简约高性能背景
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

-- 创建简约渐变背景效果
local BackgroundGradient = Instance.new("UIGradient")
BackgroundGradient.Parent = MainBackground
BackgroundGradient.Rotation = 120
BackgroundGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(15, 15, 25)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 20, 40)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(15, 15, 25))
})

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
                
                local listening = false
                local function setKey(key)
                    if key then
                        if banned[key.Name] then
                            key = default
                            keyTxt = default and (shortNames[default.Name] or default.Name) or "None"
                        else
                            keyTxt = shortNames[key.Name] or key.Name
                            bindKey = key
                        end
                    else
                        keyTxt = "None"
                        bindKey = nil
                    end
                    
                    KeybindValue.Text = keyTxt
                    listening = false
                end
                
                KeybindValue.MouseButton1Click:Connect(function()
                    if listening then
                        setKey()
                        return
                    end
                    
                    listening = true
                    KeybindValue.Text = "..."
                end)
                
                local keyConnection
                keyConnection = UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            setKey(input.KeyCode)
                        end
                    elseif bindKey and input.KeyCode == bindKey then
                        callback()
                    end
                end)
                
                local funcs = {
                    SetKey = function(self, key)
                        setKey(key)
                    end,
                    Module = KeybindModule
                }
                
                return funcs
            end
            
            function section.Slider(section, text, min, max, start, callback, flag)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(min, "No min value provided")
                assert(max, "No max value provided")
                start = start or min
                
                if flag then
                    library.flaFengYu[flag] = start
                end
                
                local SliderModule = Instance.new("Frame")
                local SliderBtn = Instance.new("TextButton")
                local SliderBtnC = Instance.new("UICorner")
                local SliderBar = Instance.new("Frame")
                local SliderBarC = Instance.new("UICorner")
                local SliderValue = Instance.new("TextLabel")
                local SliderBarInner = Instance.new("Frame")
                local SliderBarInnerC = Instance.new("UICorner")
                
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
                SliderBar.Position = UDim2.new(0.763, 0, 0.289, 0)
                SliderBar.Size = UDim2.new(0, 100, 0, 28)
                
                SliderBarC.CornerRadius = UDim.new(0, 6)
                SliderBarC.Name = "SliderBarC"
                SliderBarC.Parent = SliderBar
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderBar
                SliderValue.BackgroundTransparency = 1
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(start)
                SliderValue.TextColor3 = config.TextColor
                SliderValue.TextSize = 14
                
                SliderBarInner.Name = "SliderBarInner"
                SliderBarInner.Parent = SliderBar
                SliderBarInner.BackgroundColor3 = config.SliderBar_Color
                SliderBarInner.BorderSizePixel = 0
                SliderBarInner.Size = UDim2.new((start - min) / (max - min), 0, 1, 0)
                
                SliderBarInnerC.CornerRadius = UDim.new(0, 6)
                SliderBarInnerC.Name = "SliderBarInnerC"
                SliderBarInnerC.Parent = SliderBarInner
                
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
                
                local sliding = false
                local function slide(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
                    local value = math.floor(((pos.X.Scale * max) / max) * (max - min) + min)
                    
                    SliderBarInner.Size = pos
                    SliderValue.Text = tostring(value)
                    
                    if flag then
                        library.flaFengYu[flag] = value
                    end
                    
                    callback(value)
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        slide(input)
                    end
                end)
                
                SliderBar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then
                        slide(input)
                    end
                end)
                
                local funcs = {
                    SetValue = function(self, value)
                        value = math.clamp(value, min, max)
                        SliderBarInner.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        SliderValue.Text = tostring(value)
                        
                        if flag then
                            library.flaFengYu[flag] = value
                        end
                        
                        callback(value)
                    end,
                    Module = SliderModule
                }
                
                return funcs
            end
            
            function section.Textbox(section, text, placeholder, callback, flag)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(placeholder, "No placeholder provided")
                
                if flag then
                    library.flaFengYu[flag] = ""
                end
                
                local TextboxModule = Instance.new("Frame")
                local TextboxBtn = Instance.new("TextButton")
                local TextboxBtnC = Instance.new("UICorner")
                local TextboxValue = Instance.new("TextBox")
                local TextboxValueC = Instance.new("UICorner")
                
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
                
                TextboxValue.Name = "TextboxValue"
                TextboxValue.Parent = TextboxBtn
                TextboxValue.BackgroundColor3 = config.Bg_Color
                TextboxValue.BorderSizePixel = 0
                TextboxValue.Position = UDim2.new(0.763, 0, 0.289, 0)
                TextboxValue.Size = UDim2.new(0, 100, 0, 28)
                TextboxValue.Font = Enum.Font.Gotham
                TextboxValue.PlaceholderText = placeholder
                TextboxValue.Text = ""
                TextboxValue.TextColor3 = config.TextColor
                TextboxValue.TextSize = 14
                
                TextboxValueC.CornerRadius = UDim.new(0, 6)
                TextboxValueC.Name = "TextboxValueC"
                TextboxValueC.Parent = TextboxValue
                
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
                
                TextboxValue.FocusLost:Connect(function()
                    if flag then
                        library.flaFengYu[flag] = TextboxValue.Text
                    end
                    
                    callback(TextboxValue.Text)
                end)
                
                local funcs = {
                    SetText = function(self, value)
                        TextboxValue.Text = value
                        
                        if flag then
                            library.flaFengYu[flag] = value
                        end
                        
                        callback(value)
                    end,
                    Module = TextboxModule
                }
                
                return funcs
            end
            
            function section.Dropdown(section, text, list, callback, flag)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(list, "No list provided")
                
                if flag then
                    library.flaFengYu[flag] = nil
                end
                
                local DropdownModule = Instance.new("Frame")
                local DropdownBtn = Instance.new("TextButton")
                local DropdownBtnC = Instance.new("UICorner")
                local DropdownValue = Instance.new("TextButton")
                local DropdownValueC = Instance.new("UICorner")
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
                
                DropdownValue.Name = "DropdownValue"
                DropdownValue.Parent = DropdownBtn
                DropdownValue.BackgroundColor3 = config.Bg_Color
                DropdownValue.BorderSizePixel = 0
                DropdownValue.Position = UDim2.new(0.763, 0, 0.289, 0)
                DropdownValue.Size = UDim2.new(0, 100, 0, 28)
                DropdownValue.AutoButtonColor = false
                DropdownValue.Font = Enum.Font.Gotham
                DropdownValue.Text = "None"
                DropdownValue.TextColor3 = config.TextColor
                DropdownValue.TextSize = 14
                
                DropdownValueC.CornerRadius = UDim.new(0, 6)
                DropdownValueC.Name = "DropdownValueC"
                DropdownValueC.Parent = DropdownValue
                
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Parent = DropdownValue
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.BorderSizePixel = 0
                DropdownArrow.Position = UDim2.new(0.8, 0, 0.143, 0)
                DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                DropdownArrow.Image = "rbxassetid://84830962019412"
                DropdownArrow.ImageColor3 = config.TextColor
                
                DropdownList.Name = "DropdownList"
                DropdownList.Parent = DropdownBtn
                DropdownList.Active = true
                DropdownList.BackgroundColor3 = config.Bg_Color
                DropdownList.BorderSizePixel = 0
                DropdownList.Position = UDim2.new(0.763, 0, 1.1, 0)
                DropdownList.Size = UDim2.new(0, 100, 0, 0)
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
                DropdownList.ScrollBarThickness = 2
                DropdownList.Visible = false
                
                DropdownListL.Name = "DropdownListL"
                DropdownListL.Parent = DropdownList
                DropdownListL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownListL.Padding = UDim.new(0, 2)
                
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
                
                local opened = false
                local function toggle()
                    opened = not opened
                    
                    if opened then
                        DropdownList.Visible = true
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, 100, 0, math.clamp(#list * 28, 0, 140))
                        }):Play()
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                            Rotation = 180
                        }):Play()
                    else
                        services.TweenService:Create(DropdownList, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, 100, 0, 0)
                        }):Play()
                        services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                            Rotation = 0
                        }):Play()
                        task.wait(0.2)
                        DropdownList.Visible = false
                    end
                end
                
                DropdownValue.MouseButton1Click:Connect(toggle)
                DropdownBtn.MouseButton1Click:Connect(toggle)
                
                DropdownListL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownListL.AbsoluteContentSize.Y)
                end)
                
                local selected = nil
                local function select(item)
                    selected = item
                    DropdownValue.Text = item
                    
                    if flag then
                        library.flaFengYu[flag] = item
                    end
                    
                    callback(item)
                    toggle()
                end
                
                for _, item in pairs(list) do
                    local Option = Instance.new("TextButton")
                    local OptionC = Instance.new("UICorner")
                    
                    Option.Name = "Option"
                    Option.Parent = DropdownList
                    Option.BackgroundColor3 = config.Dropdown_Color
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(0, 96, 0, 24)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = item
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 14
                    
                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    Option.MouseEnter:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.Dropdown_Color.R * 255 * 1.1),
                                math.floor(config.Dropdown_Color.G * 255 * 1.1),
                                math.floor(config.Dropdown_Color.B * 255 * 1.1)
                            )
                        }):Play()
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = config.Dropdown_Color
                        }):Play()
                    end)
                    
                    Option.MouseButton1Click:Connect(function()
                        select(item)
                    end)
                end
                
                local funcs = {
                    SetValue = function(self, value)
                        if table.find(list, value) then
                            select(value)
                        end
                    end,
                    AddValue = function(self, value)
                        table.insert(list, value)
                        
                        local Option = Instance.new("TextButton")
                        local OptionC = Instance.new("UICorner")
                        
                        Option.Name = "Option"
                        Option.Parent = DropdownList
                        Option.BackgroundColor3 = config.Dropdown_Color
                        Option.BorderSizePixel = 0
                        Option.Size = UDim2.new(0, 96, 0, 24)
                        Option.AutoButtonColor = false
                        Option.Font = Enum.Font.Gotham
                        Option.Text = value
                        Option.TextColor3 = config.TextColor
                        Option.TextSize = 14
                        
                        OptionC.CornerRadius = UDim.new(0, 6)
                        OptionC.Name = "OptionC"
                        OptionC.Parent = Option
                        
                        Option.MouseEnter:Connect(function()
                            services.TweenService:Create(Option, TweenInfo.new(0.2), {
                                BackgroundColor3 = Color3.fromRGB(
                                    math.floor(config.Dropdown_Color.R * 255 * 1.1),
                                    math.floor(config.Dropdown_Color.G * 255 * 1.1),
                                    math.floor(config.Dropdown_Color.B * 255 * 1.1)
                                )
                            }):Play()
                        end)
                        
                        Option.MouseLeave:Connect(function()
                            services.TweenService:Create(Option, TweenInfo.new(0.2), {
                                BackgroundColor3 = config.Dropdown_Color
                            }):Play()
                        end)
                        
                        Option.MouseButton1Click:Connect(function()
                            select(value)
                        end)
                    end,
                    RemoveValue = function(self, value)
                        local index = table.find(list, value)
                        if index then
                            table.remove(list, index)
                            
                            for _, child in pairs(DropdownList:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == value then
                                    child:Destroy()
                                    break
                                end
                            end
                        end
                    end,
                    Module = DropdownModule
                }
                
                return funcs
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

return library