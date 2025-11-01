repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

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

local FengUI = {}
local ToggleUI = true
FengUI.currentTab = nil
FengUI.flags = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

-- 宝蓝色主题配置
local config = {
    MainColor = Color3.fromRGB(8, 18, 36),
    TabColor = Color3.fromRGB(12, 25, 48),
    Bg_Color = Color3.fromRGB(10, 22, 42),
    Zy_Color = Color3.fromRGB(10, 22, 42), 
    Button_Color = Color3.fromRGB(15, 30, 58),
    Textbox_Color = Color3.fromRGB(15, 30, 58),
    Dropdown_Color = Color3.fromRGB(15, 30, 58),
    Keybind_Color = Color3.fromRGB(15, 30, 58),
    Label_Color = Color3.fromRGB(15, 30, 58),
    Slider_Color = Color3.fromRGB(15, 30, 58),
    SliderBar_Color = Color3.fromRGB(0, 112, 255),
    Toggle_Color = Color3.fromRGB(15, 30, 58),
    Toggle_Off = Color3.fromRGB(25, 40, 68),
    Toggle_On = Color3.fromRGB(0, 112, 255),
    AccentColor = Color3.fromRGB(0, 112, 255),
    TextColor = Color3.fromRGB(240, 245, 255),
    SecondaryTextColor = Color3.fromRGB(180, 195, 230),
    GlowColor = Color3.fromRGB(0, 150, 255),
}

-- 现代化霓虹效果
local function createNeonEffect(object, intensity)
    intensity = intensity or 0.3
    
    local glow = Instance.new("UIStroke")
    glow.Parent = object
    glow.Color = config.AccentColor
    glow.Thickness = 2
    glow.Transparency = 0.7
    
    -- 脉动效果
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        local pulse = math.sin(tick() * 4) * 0.3 + 0.7
        glow.Transparency = 0.8 - (pulse * 0.2)
    end)
    
    return glow
end

-- 现代化悬浮效果
local function setupHoverEffect(button, baseColor)
    button.MouseEnter:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(baseColor.R * 255 * 1.15),
                math.floor(baseColor.G * 255 * 1.15),
                math.floor(baseColor.B * 255 * 1.15)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = baseColor
        }):Play()
    end)
end

-- 现代化波纹效果
function Ripple(obj)
    if not obj or not obj.Parent then return end
    
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        
        local mouse = services.Players.LocalPlayer:GetMouse()
        local Ripple = Instance.new("Frame")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundColor3 = config.AccentColor
        Ripple.BackgroundTransparency = 0.7
        Ripple.ZIndex = 8
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        Ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = Ripple
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(2, 0, 2, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.6)
        Ripple:Destroy()
    end)
end

-- 现代化滑动效果
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
    
    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { BackgroundTransparency = 0.1 }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { TextColor3 = config.AccentColor }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengUI.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { BackgroundTransparency = 0.8 }):Play()
    services.TweenService:Create(new[1], tweenInfo, { BackgroundTransparency = 0.1 }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { TextColor3 = config.SecondaryTextColor }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { TextColor3 = config.AccentColor }):Play()
    
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
Main.BackgroundColor3 = config.Bg_Color
Main.BackgroundTransparency = 0.1
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
MainStroke.Color = Color3.fromRGB(30, 60, 100)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3

-- 添加现代化阴影
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Parent = Main
shadow.BackgroundTransparency = 1
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.ZIndex = 0
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)

createNeonEffect(Main, 0.4)

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Main
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BackgroundTransparency = 0.8
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -30, 0, 8)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.ZIndex = 10

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

setupHoverEffect(CloseButton, Color3.fromRGB(255, 60, 60))

CloseButton.MouseButton1Click:Connect(function()
    Ripple(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -28, 0, 10)
    }):Play()
    task.wait(0.1)
    FengYu:Destroy()
end)

local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.2
Open.Position = UDim2.new(0.95, 0, 0.02, 0)
Open.Size = UDim2.new(0, 50, 0, 50)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://7072725342"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.1

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0.3, 0)
OpenCorner.Parent = Open

createNeonEffect(Open, 0.5)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = Open.Rotation + 180,
        Size = UDim2.new(0, 45, 0, 45)
    }):Play()
    task.wait(0.15)
    services.TweenService:Create(Open, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        services.TweenService:Create(Open, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Rotation = Open.Rotation + 180,
            Size = UDim2.new(0, 45, 0, 45)
        }):Play()
        task.wait(0.15)
        services.TweenService:Create(Open, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 50)
        }):Play()
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.22, 0, 0, 8)
TabMain.Size = UDim2.new(0, 385, 0, 304)

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.1
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
TabBtns.ScrollBarImageTransparency = 0.7
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

local ScriptTitle = Instance.new("TextLabel")
ScriptTitle.Name = "ScriptTitle"
ScriptTitle.Parent = Side
ScriptTitle.BackgroundTransparency = 1
ScriptTitle.Position = UDim2.new(0, 0, 0.02, 0)
ScriptTitle.Size = UDim2.new(0, 110, 0, 25)
ScriptTitle.Font = Enum.Font.GothamBlack
ScriptTitle.Text = "FengUI"
ScriptTitle.TextColor3 = config.AccentColor
ScriptTitle.TextSize = 18
ScriptTitle.TextScaled = false
ScriptTitle.TextXAlignment = Enum.TextXAlignment.Center

-- 现代化标题效果
task.spawn(function()
    while ScriptTitle and ScriptTitle.Parent do
        services.TweenService:Create(ScriptTitle, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            TextTransparency = 0.2
        }):Play()
        task.wait(1)
        services.TweenService:Create(ScriptTitle, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            TextTransparency = 0
        }):Play()
        task.wait(1)
    end
end)

function FengUI.new(FengUI, name, theme)
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

    ScriptTitle.Text = name or "FengUI"
    
    local window = {}
    
    function window.Tab(window, name, icon)
        local Tab = Instance.new("ScrollingFrame")
        local TabIco = Instance.new("Frame")
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
        Tab.ScrollBarImageTransparency = 0.7
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundColor3 = config.TabColor
        TabIco.BackgroundTransparency = 0.8
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0.8, 0, 0, 35)
        TabIco.Position = UDim2.new(0.1, 0, 0, 0)
        
        local TabIcoCorner = Instance.new("UICorner")
        TabIcoCorner.CornerRadius = UDim.new(0, 8)
        TabIcoCorner.Parent = TabIco
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Size = UDim2.new(1, 0, 1, 0)
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = name
        TabText.TextColor3 = config.SecondaryTextColor
        TabText.TextSize = 13
        TabText.TextTransparency = 0.3
        
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
        
        setupHoverEffect(TabIco, config.TabColor)
        
        if FengUI.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 12)
            
            Tab.ScrollingEnabled = TabL.AbsoluteContentSize.Y > Tab.AbsoluteSize.Y
            Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        end)
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            local Section = Instance.new("Frame")
            local SectionC = Instance.new("UICorner")
            local SectionText = Instance.new("TextLabel")
            local SectionToggle = Instance.new("ImageButton")
            local Objs = Instance.new("Frame")
            local ObjsL = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = 0.1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.98, 0, 0, 42)
            
            createNeonEffect(Section, 0.3)
            
            SectionC.CornerRadius = UDim.new(0, 8)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.05, 0, 0, 0)
            SectionText.Size = UDim2.new(0.8, 0, 1, 0)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 14
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = Section
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Position = UDim2.new(0.9, 0, 0.2, 0)
            SectionToggle.Size = UDim2.new(0, 25, 0, 25)
            SectionToggle.Image = "rbxassetid://7072725678"
            SectionToggle.ImageColor3 = config.AccentColor
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 8, 0, 42)
            Objs.Size = UDim2.new(0.98, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(0.98, 0, 0, open and 42 + ObjsL.AbsoluteContentSize.Y + 8 or 42)
                SectionToggle.Rotation = open and 180 or 0
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.3), {
                    Size = UDim2.new(0.98, 0, 0, open and 42 + ObjsL.AbsoluteContentSize.Y + 8 or 42)
                }):Play()
                
                services.TweenService:Create(SectionToggle, TweenInfo.new(0.3), {
                    Rotation = open and 180 or 0
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(0.98, 0, 0, 42 + ObjsL.AbsoluteContentSize.Y + 8)
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
                BtnModule.Size = UDim2.new(1, 0, 0, 40)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.1
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(1, 0, 0, 40)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamMedium
                Btn.Text = text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 13
                Btn.TextXAlignment = Enum.TextXAlignment.Center
                
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                createNeonEffect(Btn, 0.4)
                setupHoverEffect(Btn, config.Button_Color)
                
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    callback()
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3,
                        Size = UDim2.new(0.98, 0, 0, 38)
                    }):Play()
                    task.wait(0.1)
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.1,
                        Size = UDim2.new(1, 0, 0, 40)
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
                ImageModule.Size = UDim2.new(1, 0, 0, sizeY or 140)
                
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundColor3 = config.Bg_Color
                ImageLabel.BackgroundTransparency = 0.1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0.95, 0, 0, sizeY or 140)
                ImageLabel.Image = "rbxassetid://" .. tostring(imageId)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 8)
                ImageCorner.Parent = ImageLabel
                
                createNeonEffect(ImageLabel, 0.3)
                
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
                LabelModule.Size = UDim2.new(1, 0, 0, 30)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.1
                TextLabel.Size = UDim2.new(1, 0, 0, 30)
                TextLabel.Font = Enum.Font.Gotham
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 12
                
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
                createNeonEffect(TextLabel, 0.2)
                
                return TextLabel
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = enabled

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
                ToggleModule.Size = UDim2.new(1, 0, 0, 40)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.1
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamMedium
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 13
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                createNeonEffect(ToggleBtn, 0.3)
                setupHoverEffect(ToggleBtn, config.Toggle_Color)
                
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = config.Bg_Color
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.8, 0, 0.25, 0)
                ToggleDisable.Size = UDim2.new(0, 45, 0, 20)
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 20, 0, 20)
                ToggleSwitch.Position = UDim2.new(0, enabled and 25 or 0, 0, 0)
                
                ToggleSwitchC.CornerRadius = UDim.new(1, 0)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(1, 0)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                if enabled then
                    createNeonEffect(ToggleSwitch, 0.5)
                end
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengUI.flags[flag]
                        end
                        if FengUI.flags[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, state and 25 or 0, 0, 0),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        if state then
                            createNeonEffect(ToggleSwitch, 0.5)
                        else
                            local glow = ToggleSwitch:FindFirstChildOfClass("UIStroke")
                            if glow then
                                glow:Destroy()
                            end
                        end
                        
                        FengUI.flags[flag] = state
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
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(1, 0, 0, 40)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.1
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(1, 0, 0, 40)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamMedium
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 13
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                createNeonEffect(KeybindBtn, 0.3)
                setupHoverEffect(KeybindBtn, config.Keybind_Color)
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.75, 0, 0.25, 0)
                KeybindValue.Size = UDim2.new(0, 70, 0, 20)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 11
                
                KeybindValueC.CornerRadius = UDim.new(0, 4)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue
                
                createNeonEffect(KeybindValue, 0.4)
                
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
                    keyTxt = shortNames[keyName] or keyName
                    KeybindValue.Text = keyTxt
                end)
                
                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 20)
                end)
                
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 20)
            end
            
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                
                FengUI.flags[flag] = default
                
                local TextboxModule = Instance.new("Frame")
                local TextboxBack = Instance.new("TextButton")
                local TextboxBackC = Instance.new("UICorner")
                local BoxBG = Instance.new("TextButton")
                local BoxBGC = Instance.new("UICorner")
                local TextBox = Instance.new("TextBox")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(1, 0, 0, 40)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.1
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(1, 0, 0, 40)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamMedium
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 13
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                createNeonEffect(TextboxBack, 0.3)
                setupHoverEffect(TextboxBack, config.Textbox_Color)
                
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.7, 0, 0.25, 0)
                BoxBG.Size = UDim2.new(0, 80, 0, 20)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.Gotham
                BoxBG.Text = ""
                
                BoxBGC.CornerRadius = UDim.new(0, 4)
                BoxBGC.Name = "BoxBGC"
                BoxBGC.Parent = BoxBG
                
                createNeonEffect(BoxBG, 0.4)
                
                TextBox.Parent = BoxBG
                TextBox.BackgroundTransparency = 1
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = config.TextColor
                TextBox.TextSize = 11
                TextBox.PlaceholderColor3 = config.SecondaryTextColor
                
                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    FengUI.flags[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)
                
                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 20)
                end)
                
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 20)
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
                
                FengUI.flags[flag] = default

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
                SliderModule.BackgroundTransparency = 1
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(1, 0, 0, 50)
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.1
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(1, 0, 0, 50)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamMedium
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = config.TextColor
                SliderBack.TextSize = 13
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                createNeonEffect(SliderBack, 0.3)
                setupHoverEffect(SliderBack, config.Slider_Color)
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.05, 0, 0.7, 0)
                SliderBar.Size = UDim2.new(0.6, 0, 0, 8)
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
                
                createNeonEffect(SliderPart, 0.5)
                
                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBack
                SliderValBG.BackgroundColor3 = config.Bg_Color
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.75, 0, 0.3, 0)
                SliderValBG.Size = UDim2.new(0, 50, 0, 20)
                SliderValBG.AutoButtonColor = false
                SliderValBG.Font = Enum.Font.Gotham
                SliderValBG.Text = ""
                
                SliderValBGC.CornerRadius = UDim.new(0, 4)
                SliderValBGC.Name = "SliderValBGC"
                SliderValBGC.Parent = SliderValBG
                
                createNeonEffect(SliderValBG, 0.4)
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundTransparency = 1
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = config.TextColor
                SliderValue.TextSize = 11
                
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
                        FengUI.flags[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        
                        services.TweenService:Create(SliderPart, TweenInfo.new(0.1), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        callback(tonumber(value))
                    end,
                    
                    GetValue = function(self)
                        return FengUI.flags[flag]
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
                
                local boxFocused = false
                
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
                
                return funcs
            end
            
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = nil
                
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
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(1, 0, 0, 40)
                
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BackgroundTransparency = 0.1
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(1, 0, 0, 40)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamMedium
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = config.TextColor
                DropdownTop.TextSize = 13
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop
                
                createNeonEffect(DropdownTop, 0.3)
                setupHoverEffect(DropdownTop, config.Dropdown_Color)
                
                DropdownOpenFrame.Name = "DropdownOpenFrame"
                DropdownOpenFrame.Parent = DropdownTop
                DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
                DropdownOpenFrame.BorderSizePixel = 0
                DropdownOpenFrame.Position = UDim2.new(0.8, 0, 0.5, 0)
                DropdownOpenFrame.Size = UDim2.new(0, 50, 0, 25)
                
                createNeonEffect(DropdownOpenFrame, 0.4)
                
                DropdownOpenFrameC.CornerRadius = UDim.new(0, 4)
                DropdownOpenFrameC.Name = "DropdownOpenFrameC"
                DropdownOpenFrameC.Parent = DropdownOpenFrame
                
                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownOpenFrame
                DropdownOpen.BackgroundTransparency = 1
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Size = UDim2.new(1, 0, 1, 0)
                DropdownOpen.Font = Enum.Font.GothamMedium
                DropdownOpen.Text = "选择"
                DropdownOpen.TextColor3 = config.TextColor
                DropdownOpen.TextSize = 11
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundTransparency = 1
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.05, 0, 0, 0)
                DropdownText.Size = UDim2.new(0.7, 0, 1, 0)
                DropdownText.Font = Enum.Font.GothamMedium
                DropdownText.PlaceholderColor3 = config.SecondaryTextColor
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = 13
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                
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
                    DropdownModule.Size = UDim2.new(1, 0, 0, (open and math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150) or 40))
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
                    DropdownModule.Size = UDim2.new(1, 0, 0, math.min(DropdownModuleL.AbsoluteContentSize.Y + 4, 150))
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
                    Option.Size = UDim2.new(0.95, 0, 0, 25)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 12
                    OptionC.CornerRadius = UDim.new(0, 4)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    createNeonEffect(Option, 0.2)
                    setupHoverEffect(Option, config.TabColor)
                    
                    Option.MouseButton1Click:Connect(function()
                        Ripple(Option)
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        FengUI.flags[flag] = Option.Text
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

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI