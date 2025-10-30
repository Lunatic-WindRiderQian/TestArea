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

local config = {
    MainColor = Color3.fromRGB(20, 20, 25),
    TabColor = Color3.fromRGB(25, 25, 30),
    Bg_Color = Color3.fromRGB(18, 18, 24),
    Zy_Color = Color3.fromRGB(18, 18, 24), 
    Button_Color = Color3.fromRGB(30, 30, 38),
    Textbox_Color = Color3.fromRGB(30, 30, 38),
    Dropdown_Color = Color3.fromRGB(30, 30, 38),
    Keybind_Color = Color3.fromRGB(30, 30, 38),
    Label_Color = Color3.fromRGB(30, 30, 38),
    Slider_Color = Color3.fromRGB(30, 30, 38),
    SliderBar_Color = Color3.fromRGB(80, 160, 255),
    Toggle_Color = Color3.fromRGB(30, 30, 38),
    Toggle_Off = Color3.fromRGB(45, 45, 55),
    Toggle_On = Color3.fromRGB(80, 160, 255),
    AccentColor = Color3.fromRGB(80, 160, 255),
    TextColor = Color3.fromRGB(240, 240, 245),
    SecondaryTextColor = Color3.fromRGB(160, 160, 170),
    GlowColor = Color3.fromRGB(80, 160, 255),
}

local function createRippleEffect(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = config.AccentColor
    ripple.BackgroundTransparency = 0.7
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = 10
    ripple.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    services.TweenService:Create(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    }):Play()
    
    delay(0.6, function()
        ripple:Destroy()
    end)
end

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
        object[property] = Color3.fromHSV(hue, 0.7, 0.9)
    end)
    return connection
end

local function createGlowEffect(frame)
    local glow = Instance.new("UIStroke")
    glow.Color = config.AccentColor
    glow.Thickness = 1
    glow.Transparency = 0.8
    glow.Parent = frame
    
    startRainbowEffect(glow, "Color", 0.003)
    return glow
end

local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = FengY3.currentTab
    if old == nil then
        new[2].Visible = true
        FengY3.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { BackgroundColor3 = config.AccentColor }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { TextColor3 = Color3.new(1,1,1) }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengY3.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { BackgroundColor3 = config.TabColor }):Play()
    services.TweenService:Create(new[1], tweenInfo, { BackgroundColor3 = config.AccentColor }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { TextColor3 = config.SecondaryTextColor }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { TextColor3 = Color3.new(1,1,1) }):Play()
    
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

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.MainColor
Main.BackgroundTransparency = 0.05
Main.Position = UDim2.new(0.5, 0, 0.4, 0)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.3

createGlowEffect(Main)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Main
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
CloseButton.BackgroundTransparency = 0
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -28, 0, 8)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.TextSize = 16
CloseButton.ZIndex = 10

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(240, 90, 90),
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -29, 0, 7)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(220, 70, 70),
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -28, 0, 8)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    createRippleEffect(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -27, 0, 9)
    }):Play()
    task.wait(0.1)
    FengYu:Destroy()
end)

local Open = Instance.new("TextButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0
Open.Position = UDim2.new(0.95, 0, 0.02, 0)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.AutoButtonColor = false
Open.Active = true
Open.Draggable = true
Open.Font = Enum.Font.GothamBold
Open.Text = "☰"
Open.TextColor3 = Color3.new(1,1,1)
Open.TextSize = 18

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(100, 150, 255)
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0.3

Open.MouseEnter:Connect(function()
    services.TweenService:Create(Open, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(100, 170, 255),
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0.95, -1.5, 0.02, -1.5)
    }):Play()
end)

Open.MouseLeave:Connect(function()
    services.TweenService:Create(Open, TweenInfo.new(0.2), {
        BackgroundColor3 = config.AccentColor,
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0.95, 0, 0.02, 0)
    }):Play()
end)

Open.MouseButton1Click:Connect(function()
    createRippleEffect(Open)
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.22, 0, 0.05, 0)
TabMain.Size = UDim2.new(0, 385, 0, 300)

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.05
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 0)
Side.Size = UDim2.new(0, 110, 0, 320)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Side

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0.12, 0)
TabBtns.Size = UDim2.new(0, 110, 0, 275)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = config.AccentColor
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 8)

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y)
    TabBtns.ScrollingEnabled = TabBtnsL.AbsoluteContentSize.Y > TabBtns.AbsoluteSize.Y
end)

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.02, 0)
ScriptTitle.Size = UDim2.new(0, 110, 0, 25)
ScriptTitle.Font = Enum.Font.GothamBold
ScriptTitle.Text = "FengY3"
ScriptTitle.TextColor3 = config.AccentColor
ScriptTitle.TextSize = 18
ScriptTitle.TextScaled = false
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Center

task.spawn(function()
    while ScriptTitle and ScriptTitle.Parent do
        services.TweenService:Create(ScriptTitle, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = Color3.fromRGB(100, 180, 255)
        }):Play()
        task.wait(2)
        services.TweenService:Create(ScriptTitle, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextColor3 = config.AccentColor
        }):Play()
        task.wait(2)
    end
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

    ScriptTitle.Text = name or "FengY3"
    
    local window = {}
    
    function window.Tab(window, name, icon)
        local Tab = Instance.new("ScrollingFrame")
        local TabBtn = Instance.new("TextButton")
        local TabText = Instance.new("TextLabel")
        local TabL = Instance.new("UIListLayout")
        
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.ScrollBarImageColor3 = config.AccentColor
        Tab.ScrollBarImageTransparency = 0.5
        Tab.Visible = false
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabBtns
        TabBtn.BackgroundColor3 = config.TabColor
        TabBtn.BackgroundTransparency = 0
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 90, 0, 32)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn
        
        TabText.Name = "TabText"
        TabText.Parent = TabBtn
        TabText.BackgroundTransparency = 1
        TabText.Size = UDim2.new(1, 0, 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.SecondaryTextColor
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Center
        
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 6)
        
        TabBtn.MouseButton1Click:Connect(function()
            createRippleEffect(TabBtn)
            switchTab({ TabBtn, Tab })
        end)
        
        if FengY3.currentTab == nil then
            switchTab({ TabBtn, Tab })
        end
        
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 10)
            Tab.ScrollingEnabled = TabL.AbsoluteContentSize.Y > Tab.AbsoluteSize.Y
        end)
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            local Section = Instance.new("Frame")
            local SectionC = Instance.new("UICorner")
            local SectionText = Instance.new("TextLabel")
            local SectionToggle = Instance.new("TextButton")
            local Objs = Instance.new("Frame")
            local ObjsL = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = 0.05
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.95, 0, 0, 40)
            
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.05, 0, 0, 0)
            SectionText.Size = UDim2.new(0.7, 0, 0, 40)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 15
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = Section
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Position = UDim2.new(0.85, 0, 0, 0)
            SectionToggle.Size = UDim2.new(0, 40, 0, 40)
            SectionToggle.Font = Enum.Font.GothamBold
            SectionToggle.Text = "+"
            SectionToggle.TextColor3 = config.SecondaryTextColor
            SectionToggle.TextSize = 18
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 8, 0, 40)
            Objs.Size = UDim2.new(0.96, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 6)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 6 or 40)
                SectionToggle.Text = open and "−" or "+"
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.2), {
                    Size = UDim2.new(0.95, 0, 0, open and 40 + ObjsL.AbsoluteContentSize.Y + 6 or 40)
                }):Play()
                
                services.TweenService:Create(SectionToggle, TweenInfo.new(0.2), {
                    Text = open and "−" or "+"
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
                BtnModule.Size = UDim2.new(0, 365, 0, 36)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, 365, 0, 36)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 14
                
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
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    createRippleEffect(Btn)
                    callback()
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 0.8),
                            math.floor(config.Button_Color.G * 255 * 0.8),
                            math.floor(config.Button_Color.B * 255 * 0.8)
                        )
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
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
                ImageModule.Size = UDim2.new(0, 365, 0, sizeY or 120)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundColor3 = config.Bg_Color
                ImageLabel.BackgroundTransparency = 0
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or 140, 355), 0, sizeY or 120)
                ImageLabel.Image = "rbxassetid://" .. tostring(imageId)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 6)
                ImageCorner.Parent = ImageLabel
                
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
                LabelModule.Size = UDim2.new(0, 365, 0, 28)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0
                TextLabel.Size = UDim2.new(0, 365, 0, 28)
                TextLabel.Font = Enum.Font.Gotham
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 13
                
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
                FengY3.flaFengYu[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                local ToggleBtn = Instance.new("TextButton")
                local ToggleBtnC = Instance.new("UICorner")
                local ToggleText = Instance.new("TextLabel")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchC = Instance.new("UICorner")
                
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(0, 365, 0, 36)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, 365, 0, 36)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.SourceSans
                ToggleBtn.Text = ""
                
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                ToggleText.Name = "ToggleText"
                ToggleText.Parent = ToggleBtn
                ToggleText.BackgroundTransparency = 1
                ToggleText.Position = UDim2.new(0.03, 0, 0, 0)
                ToggleText.Size = UDim2.new(0.7, 0, 1, 0)
                ToggleText.Font = Enum.Font.GothamSemibold
                ToggleText.Text = text
                ToggleText.TextColor3 = config.TextColor
                ToggleText.TextSize = 14
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleBtn
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.BorderSizePixel = 0
                ToggleSwitch.Position = UDim2.new(0.85, 0, 0.22, 0)
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 24)
                
                ToggleSwitchC.CornerRadius = UDim.new(1, 0)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                if enabled then
                    createGlowEffect(ToggleSwitch)
                end
                
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
                            state = not FengY3.flaFengYu[flag]
                        end
                        if FengY3.flaFengYu[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        if state then
                            createGlowEffect(ToggleSwitch)
                        else
                            local glow = ToggleSwitch:FindFirstChildOfClass("UIStroke")
                            if glow then
                                glow:Destroy()
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
                    createRippleEffect(ToggleBtn)
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
                    RightControl = "R-Ctrl", LeftControl = "L-Ctrl",
                    LeftShift = "L-Shift", RightShift = "R-Shift",
                    RightAlt = "R-Alt", LeftAlt = "L-Alt"
                }
                
                local bindKey = default
                local keyTxt = default and (shortNames[default.Name] or default.Name) or "None"
                
                local KeybindModule = Instance.new("Frame")
                local KeybindBtn = Instance.new("TextButton")
                local KeybindBtnC = Instance.new("UICorner")
                local KeybindText = Instance.new("TextLabel")
                local KeybindValue = Instance.new("TextButton")
                local KeybindValueC = Instance.new("UICorner")
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(0, 365, 0, 36)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, 365, 0, 36)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.SourceSans
                KeybindBtn.Text = ""
                
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                KeybindText.Name = "KeybindText"
                KeybindText.Parent = KeybindBtn
                KeybindText.BackgroundTransparency = 1
                KeybindText.Position = UDim2.new(0.03, 0, 0, 0)
                KeybindText.Size = UDim2.new(0.6, 0, 1, 0)
                KeybindText.Font = Enum.Font.GothamSemibold
                KeybindText.Text = text
                KeybindText.TextColor3 = config.TextColor
                KeybindText.TextSize = 14
                KeybindText.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.75, 0, 0.22, 0)
                KeybindValue.Size = UDim2.new(0, 60, 0, 22)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 12
                
                KeybindValueC.CornerRadius = UDim.new(0, 4)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue
                
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
                    createRippleEffect(KeybindValue)
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
                    keyTxt = shortNames[keyName] or keyName
                    KeybindValue.Text = keyTxt
                end)
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
                local TextboxText = Instance.new("TextLabel")
                local TextBox = Instance.new("TextBox")
                local TextBoxC = Instance.new("UICorner")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, 365, 0, 36)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, 365, 0, 36)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.SourceSans
                TextboxBack.Text = ""
                
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                TextboxText.Name = "TextboxText"
                TextboxText.Parent = TextboxBack
                TextboxText.BackgroundTransparency = 1
                TextboxText.Position = UDim2.new(0.03, 0, 0, 0)
                TextboxText.Size = UDim2.new(0.4, 0, 1, 0)
                TextboxText.Font = Enum.Font.GothamSemibold
                TextboxText.Text = text
                TextboxText.TextColor3 = config.TextColor
                TextboxText.TextSize = 14
                TextboxText.TextXAlignment = Enum.TextXAlignment.Left
                
                TextBox.Parent = TextboxBack
                TextBox.BackgroundColor3 = config.Bg_Color
                TextBox.BorderSizePixel = 0
                TextBox.Position = UDim2.new(0.5, 0, 0.22, 0)
                TextBox.Size = UDim2.new(0.45, 0, 0, 22)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = config.TextColor
                TextBox.TextSize = 12
                TextBox.PlaceholderColor3 = config.SecondaryTextColor
                
                TextBoxC.CornerRadius = UDim.new(0, 4)
                TextBoxC.Name = "TextBoxC"
                TextBoxC.Parent = TextBox
                
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
                    FengY3.flaFengYu[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)
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
                local SliderText = Instance.new("TextLabel")
                local SliderBar = Instance.new("Frame")
                local SliderBarC = Instance.new("UICorner")
                local SliderPart = Instance.new("Frame")
                local SliderPartC = Instance.new("UICorner")
                local SliderValue = Instance.new("TextLabel")
                
                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundTransparency = 1
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(0, 365, 0, 50)
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(0, 365, 0, 50)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.SourceSans
                SliderBack.Text = ""
                
                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                SliderText.Name = "SliderText"
                SliderText.Parent = SliderBack
                SliderText.BackgroundTransparency = 1
                SliderText.Position = UDim2.new(0.03, 0, 0, 5)
                SliderText.Size = UDim2.new(0.7, 0, 0, 20)
                SliderText.Font = Enum.Font.GothamSemibold
                SliderText.Text = text
                SliderText.TextColor3 = config.TextColor
                SliderText.TextSize = 14
                SliderText.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.03, 0, 0.6, 0)
                SliderBar.Size = UDim2.new(0.94, 0, 0, 6)
                SliderBarC.CornerRadius = UDim.new(1, 0)
                SliderBarC.Name = "SliderBarC"
                SliderBarC.Parent = SliderBar
                
                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = config.SliderBar_Color
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                SliderPartC.CornerRadius = UDim.new(1, 0)
                SliderPartC.Name = "SliderPartC"
                SliderPartC.Parent = SliderPart
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderBack
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(0.8, 0, 0.1, 0)
                SliderValue.Size = UDim2.new(0.15, 0, 0, 20)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.SecondaryTextColor
                SliderValue.TextSize = 12
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                
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
                local DropdownText = Instance.new("TextLabel")
                local DropdownArrow = Instance.new("TextLabel")
                local DropdownOptions = Instance.new("Frame")
                local DropdownOptionsL = Instance.new("UIListLayout")
                local DropdownOptionsC = Instance.new("UICorner")
                
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(0, 365, 0, 36)
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(0, 365, 0, 36)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.SourceSans
                DropdownTop.Text = ""
                
                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundTransparency = 1
                DropdownText.Position = UDim2.new(0.03, 0, 0, 0)
                DropdownText.Size = UDim2.new(0.8, 0, 1, 0)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.Text = text
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = 14
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Parent = DropdownTop
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position = UDim2.new(0.9, 0, 0, 0)
                DropdownArrow.Size = UDim2.new(0.1, 0, 1, 0)
                DropdownArrow.Font = Enum.Font.GothamBold
                DropdownArrow.Text = "▼"
                DropdownArrow.TextColor3 = config.SecondaryTextColor
                DropdownArrow.TextSize = 12
                
                DropdownOptions.Name = "DropdownOptions"
                DropdownOptions.Parent = DropdownModule
                DropdownOptions.BackgroundColor3 = config.TabColor
                DropdownOptions.BorderSizePixel = 0
                DropdownOptions.Position = UDim2.new(0, 0, 1, 4)
                DropdownOptions.Size = UDim2.new(0, 365, 0, 0)
                DropdownOptions.Visible = false
                
                DropdownOptionsC.CornerRadius = UDim.new(0, 6)
                DropdownOptionsC.Name = "DropdownOptionsC"
                DropdownOptionsC.Parent = DropdownOptions
                
                DropdownOptionsL.Name = "DropdownOptionsL"
                DropdownOptionsL.Parent = DropdownOptions
                DropdownOptionsL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownOptionsL.Padding = UDim.new(0, 2)
                
                local open = false
                local ToggleDropVis = function()
                    open = not open
                    DropdownOptions.Visible = open
                    DropdownArrow.Text = open and "▲" or "▼"
                    
                    if open then
                        DropdownOptions.Size = UDim2.new(0, 365, 0, math.min(DropdownOptionsL.AbsoluteContentSize.Y + 8, 120))
                    else
                        DropdownOptions.Size = UDim2.new(0, 365, 0, 0)
                    end
                end
                
                DropdownTop.MouseButton1Click:Connect(function()
                    createRippleEffect(DropdownTop)
                    ToggleDropVis()
                end)
                
                DropdownOptionsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then
                        DropdownOptions.Size = UDim2.new(0, 365, 0, math.min(DropdownOptionsL.AbsoluteContentSize.Y + 8, 120))
                    end
                end)
                
                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    local OptionC = Instance.new("UICorner")
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownOptions
                    Option.BackgroundColor3 = config.Button_Color
                    Option.BackgroundTransparency = 0
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(0, 355, 0, 28)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 13
                    
                    OptionC.CornerRadius = UDim.new(0, 4)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    Option.MouseEnter:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(
                                math.floor(config.Button_Color.R * 255 * 1.1),
                                math.floor(config.Button_Color.G * 255 * 1.1),
                                math.floor(config.Button_Color.B * 255 * 1.1)
                            )
                        }):Play()
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        services.TweenService:Create(Option, TweenInfo.new(0.2), {
                            BackgroundColor3 = config.Button_Color
                        }):Play()
                    end)
                    
                    Option.MouseButton1Click:Connect(function()
                        createRippleEffect(Option)
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = option
                        FengY3.flaFengYu[flag] = Option.Text
                    end)
                end
                
                funcs.RemoveOption = function(self, option)
                    local option = DropdownOptions:FindFirstChild("Option_" .. option)
                    if option then
                        option:Destroy()
                    end
                end
                
                funcs.SetOptions = function(self, options)
                    for _, v in next, DropdownOptions:GetChildren() do
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