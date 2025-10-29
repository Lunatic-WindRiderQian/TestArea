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

local WindUI = {}
local ToggleUI = true
WindUI.currentTab = nil
WindUI.flags = {}

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
    MainColor = Color3.fromRGB(25, 25, 30),
    TabColor = Color3.fromRGB(30, 30, 35),
    Bg_Color = Color3.fromRGB(28, 28, 33),
    Button_Color = Color3.fromRGB(35, 35, 40),
    Textbox_Color = Color3.fromRGB(35, 35, 40),
    Dropdown_Color = Color3.fromRGB(35, 35, 40),
    Keybind_Color = Color3.fromRGB(35, 35, 40),
    Label_Color = Color3.fromRGB(35, 35, 40),
    Slider_Color = Color3.fromRGB(35, 35, 40),
    SliderBar_Color = Color3.fromRGB(0, 150, 255),
    Toggle_Color = Color3.fromRGB(35, 35, 40),
    Toggle_Off = Color3.fromRGB(45, 45, 50),
    Toggle_On = Color3.fromRGB(0, 150, 255),
    AccentColor = Color3.fromRGB(0, 150, 255),
    TextColor = Color3.fromRGB(240, 240, 240),
    SecondaryTextColor = Color3.fromRGB(180, 180, 180),
    BorderColor = Color3.fromRGB(60, 60, 70)
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
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(80, 80, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 150)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 0))
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

local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = WindUI.currentTab
    if old == nil then
        new[2].Visible = true
        WindUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.2), { BackgroundColor3 = config.AccentColor }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    WindUI.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { BackgroundColor3 = config.TabColor }):Play()
    services.TweenService:Create(new[1], tweenInfo, { BackgroundColor3 = config.AccentColor }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { TextColor3 = config.SecondaryTextColor }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.2)
    switchingTabs = false
end

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "WindUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local WindUIGui = Instance.new("ScreenGui")
WindUIGui.Name = "WindUI"
protectGUI(WindUIGui)
WindUIGui.Parent = services.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = WindUIGui
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = config.MainColor
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
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.ZIndex = 2

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "WindUI"
TitleText.TextColor3 = config.TextColor
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.ZIndex = 3

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    Ripple(CloseButton)
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    }):Play()
    task.wait(0.1)
    WindUIGui:Destroy()
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -50, 0, 5)
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.ZIndex = 3

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

MinimizeButton.MouseEnter:Connect(function()
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    }):Play()
end)

MinimizeButton.MouseLeave:Connect(function()
    services.TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 180, 60)
    }):Play()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    Ripple(MinimizeButton)
    Main.Visible = not Main.Visible
end)

local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = WindUIGui
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.8
Open.Position = UDim2.new(0.95, 0, 0.02, 0)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.2

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = config.BorderColor
OpenStroke.Thickness = 1.5
OpenStroke.Transparency = 0.3

startRainbowEffect(Open, "BackgroundColor3", 0.01)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
        services.TweenService:Create(Open, TweenInfo.new(0.2), {Rotation = Open.Rotation + 180}):Play()
    end
end)

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Parent = Main
TabContainer.BackgroundTransparency = 1
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.Size = UDim2.new(1, 0, 0, 285)

local SideTabs = Instance.new("Frame")
SideTabs.Name = "SideTabs"
SideTabs.Parent = TabContainer
SideTabs.BackgroundColor3 = config.TabColor
SideTabs.BorderSizePixel = 0
SideTabs.Size = UDim2.new(0, 120, 1, 0)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = SideTabs

local TabButtons = Instance.new("ScrollingFrame")
TabButtons.Name = "TabButtons"
TabButtons.Parent = SideTabs
TabButtons.Active = true
TabButtons.BackgroundTransparency = 1
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 5, 0, 5)
TabButtons.Size = UDim2.new(1, -10, 1, -10)
TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
TabButtons.ScrollBarThickness = 3
TabButtons.ScrollBarImageColor3 = config.BorderColor
TabButtons.ScrollBarImageTransparency = 0.5

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Name = "TabListLayout"
TabListLayout.Parent = TabButtons
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabButtons.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    TabButtons.ScrollingEnabled = TabListLayout.AbsoluteContentSize.Y > TabButtons.AbsoluteSize.Y
end)

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = TabContainer
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 125, 0, 0)
ContentArea.Size = UDim2.new(0, 370, 1, 0)

function WindUI.new(Window, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "WindUI" then
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
        local TabFrame = Instance.new("ScrollingFrame")
        local TabButton = Instance.new("TextButton")
        local TabText = Instance.new("TextLabel")
        local TabContentLayout = Instance.new("UIListLayout")
        
        TabFrame.Name = "TabFrame"
        TabFrame.Parent = ContentArea
        TabFrame.Active = true
        TabFrame.BackgroundTransparency = 1
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.ScrollBarThickness = 2
        TabFrame.ScrollBarImageTransparency = 0.5
        TabFrame.Visible = false
        TabFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        
        TabButton.Name = "TabButton"
        TabButton.Parent = TabButtons
        TabButton.BackgroundColor3 = config.TabColor
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.AutoButtonColor = false
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Text = ""
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = TabButton
        
        TabText.Name = "TabText"
        TabText.Parent = TabButton
        TabText.BackgroundTransparency = 1
        TabText.Size = UDim2.new(1, 0, 1, 0)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.SecondaryTextColor
        TabText.TextSize = 13
        
        TabContentLayout.Name = "TabContentLayout"
        TabContentLayout.Parent = TabFrame
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Padding = UDim.new(0, 8)
        
        TabButton.MouseButton1Click:Connect(function()
            Ripple(TabButton)
            switchTab({ TabButton, TabFrame })
        end)
        
        if WindUI.currentTab == nil then
            switchTab({ TabButton, TabFrame })
        end
        
        TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 10)
            TabFrame.ScrollingEnabled = TabContentLayout.AbsoluteContentSize.Y > TabFrame.AbsoluteSize.Y
        end)
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            local Section = Instance.new("Frame")
            local SectionCorner = Instance.new("UICorner")
            local SectionHeader = Instance.new("Frame")
            local SectionTitle = Instance.new("TextLabel")
            local SectionToggle = Instance.new("ImageButton")
            local SectionContent = Instance.new("Frame")
            local SectionLayout = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = TabFrame
            Section.BackgroundColor3 = config.Bg_Color
            Section.BackgroundTransparency = 0.1
            Section.Size = UDim2.new(1, 0, 0, 40)
            
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = Section
            
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = Section
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Size = UDim2.new(1, 0, 0, 40)
            
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionHeader
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.Size = UDim2.new(1, -40, 1, 0)
            SectionTitle.Font = Enum.Font.GothamSemibold
            SectionTitle.Text = name
            SectionTitle.TextColor3 = config.TextColor
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionHeader
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.Position = UDim2.new(1, -30, 0, 10)
            SectionToggle.Size = UDim2.new(0, 20, 0, 20)
            SectionToggle.Image = "rbxassetid://3926305904"
            SectionToggle.ImageRectOffset = Vector2.new(284, 4)
            SectionToggle.ImageRectSize = Vector2.new(24, 24)
            SectionToggle.ImageColor3 = config.SecondaryTextColor
            
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = Section
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 0, 0, 40)
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            
            SectionLayout.Name = "SectionLayout"
            SectionLayout.Parent = SectionContent
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 6)
            
            local open = TabVal ~= false
            if TabVal ~= false then
                Section.Size = UDim2.new(1, 0, 0, open and 40 + SectionLayout.AbsoluteContentSize.Y + 10 or 40)
                SectionToggle.Rotation = open and 180 or 0
            end
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, open and 40 + SectionLayout.AbsoluteContentSize.Y + 10 or 40)
                }):Play()
                
                services.TweenService:Create(SectionToggle, TweenInfo.new(0.2), {
                    Rotation = open and 180 or 0
                }):Play()
            end)
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then return end
                Section.Size = UDim2.new(1, 0, 0, 40 + SectionLayout.AbsoluteContentSize.Y + 10)
            end)
            
            local section = {}
            
            function section.Button(section, text, callback)
                callback = callback or function() end
                
                local Button = Instance.new("TextButton")
                local ButtonCorner = Instance.new("UICorner")
                
                Button.Name = "Button"
                Button.Parent = SectionContent
                Button.BackgroundColor3 = config.Button_Color
                Button.BackgroundTransparency = 0.1
                Button.Size = UDim2.new(1, 0, 0, 35)
                Button.AutoButtonColor = false
                Button.Font = Enum.Font.GothamSemibold
                Button.Text = text
                Button.TextColor3 = config.TextColor
                Button.TextSize = 13
                
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                local ButtonStroke = Instance.new("UIStroke")
                ButtonStroke.Parent = Button
                ButtonStroke.Color = config.AccentColor
                ButtonStroke.Thickness = 1
                ButtonStroke.Transparency = 0.7
                
                Button.MouseEnter:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.1),
                            math.floor(config.Button_Color.G * 255 * 1.1),
                            math.floor(config.Button_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    services.TweenService:Create(Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                end)
                
                Button.MouseButton1Click:Connect(function()
                    Ripple(Button)
                    callback()
                end)
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                WindUI.flags[flag] = enabled

                local Toggle = Instance.new("TextButton")
                local ToggleCorner = Instance.new("UICorner")
                local ToggleIndicator = Instance.new("Frame")
                local ToggleDot = Instance.new("Frame")
                local ToggleText = Instance.new("TextLabel")
                
                Toggle.Name = "Toggle"
                Toggle.Parent = SectionContent
                Toggle.BackgroundColor3 = config.Toggle_Color
                Toggle.BackgroundTransparency = 0.1
                Toggle.Size = UDim2.new(1, 0, 0, 35)
                Toggle.AutoButtonColor = false
                Toggle.Font = Enum.Font.SourceSans
                Toggle.Text = ""
                
                ToggleCorner.CornerRadius = UDim.new(0, 6)
                ToggleCorner.Parent = Toggle
                
                ToggleText.Name = "ToggleText"
                ToggleText.Parent = Toggle
                ToggleText.BackgroundTransparency = 1
                ToggleText.Position = UDim2.new(0, 10, 0, 0)
                ToggleText.Size = UDim2.new(0, 200, 1, 0)
                ToggleText.Font = Enum.Font.GothamSemibold
                ToggleText.Text = text
                ToggleText.TextColor3 = config.TextColor
                ToggleText.TextSize = 13
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleIndicator.Name = "ToggleIndicator"
                ToggleIndicator.Parent = Toggle
                ToggleIndicator.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleIndicator.Position = UDim2.new(1, -50, 0, 10)
                ToggleIndicator.Size = UDim2.new(0, 40, 0, 15)
                
                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(1, 0)
                IndicatorCorner.Parent = ToggleIndicator
                
                ToggleDot.Name = "ToggleDot"
                ToggleDot.Parent = ToggleIndicator
                ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleDot.Size = UDim2.new(0, 15, 0, 15)
                ToggleDot.Position = UDim2.new(0, enabled and 25 or 0, 0, 0)
                
                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(1, 0)
                DotCorner.Parent = ToggleDot
                
                if enabled then
                    createAuroraEffect(ToggleIndicator, 0.8)
                end
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not WindUI.flags[flag]
                        end
                        if WindUI.flags[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, state and 25 or 0, 0, 0)
                        }):Play()
                        
                        services.TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        if state then
                            createAuroraEffect(ToggleIndicator, 0.8)
                        else
                            local aurora = ToggleIndicator:FindFirstChild("AuroraEffect")
                            if aurora then
                                aurora:Destroy()
                            end
                        end
                        
                        WindUI.flags[flag] = state
                        callback(state)
                    end
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                Toggle.MouseButton1Click:Connect(function()
                    Ripple(Toggle)
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
                
                local Keybind = Instance.new("TextButton")
                local KeybindCorner = Instance.new("UICorner")
                local KeybindText = Instance.new("TextLabel")
                local KeybindValue = Instance.new("TextButton")
                local ValueCorner = Instance.new("UICorner")
                
                Keybind.Name = "Keybind"
                Keybind.Parent = SectionContent
                Keybind.BackgroundColor3 = config.Keybind_Color
                Keybind.BackgroundTransparency = 0.1
                Keybind.Size = UDim2.new(1, 0, 0, 35)
                Keybind.AutoButtonColor = false
                Keybind.Font = Enum.Font.SourceSans
                Keybind.Text = ""
                
                KeybindCorner.CornerRadius = UDim.new(0, 6)
                KeybindCorner.Parent = Keybind
                
                KeybindText.Name = "KeybindText"
                KeybindText.Parent = Keybind
                KeybindText.BackgroundTransparency = 1
                KeybindText.Position = UDim2.new(0, 10, 0, 0)
                KeybindText.Size = UDim2.new(0, 200, 1, 0)
                KeybindText.Font = Enum.Font.GothamSemibold
                KeybindText.Text = text
                KeybindText.TextColor3 = config.TextColor
                KeybindText.TextSize = 13
                KeybindText.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = Keybind
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.Position = UDim2.new(1, -80, 0, 7)
                KeybindValue.Size = UDim2.new(0, 70, 0, 21)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 12
                
                ValueCorner.CornerRadius = UDim.new(0, 4)
                ValueCorner.Parent = KeybindValue
                
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
            end
            
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                
                WindUI.flags[flag] = default
                
                local Textbox = Instance.new("TextButton")
                local TextboxCorner = Instance.new("UICorner")
                local TextboxText = Instance.new("TextLabel")
                local InputBox = Instance.new("TextBox")
                local InputCorner = Instance.new("UICorner")
                
                Textbox.Name = "Textbox"
                Textbox.Parent = SectionContent
                Textbox.BackgroundColor3 = config.Textbox_Color
                Textbox.BackgroundTransparency = 0.1
                Textbox.Size = UDim2.new(1, 0, 0, 35)
                Textbox.AutoButtonColor = false
                Textbox.Font = Enum.Font.SourceSans
                Textbox.Text = ""
                
                TextboxCorner.CornerRadius = UDim.new(0, 6)
                TextboxCorner.Parent = Textbox
                
                TextboxText.Name = "TextboxText"
                TextboxText.Parent = Textbox
                TextboxText.BackgroundTransparency = 1
                TextboxText.Position = UDim2.new(0, 10, 0, 0)
                TextboxText.Size = UDim2.new(0, 150, 1, 0)
                TextboxText.Font = Enum.Font.GothamSemibold
                TextboxText.Text = text
                TextboxText.TextColor3 = config.TextColor
                TextboxText.TextSize = 13
                TextboxText.TextXAlignment = Enum.TextXAlignment.Left
                
                InputBox.Parent = Textbox
                InputBox.BackgroundColor3 = config.Bg_Color
                InputBox.Position = UDim2.new(1, -160, 0, 7)
                InputBox.Size = UDim2.new(0, 150, 0, 21)
                InputBox.Font = Enum.Font.Gotham
                InputBox.Text = default
                InputBox.TextColor3 = config.TextColor
                InputBox.TextSize = 12
                InputBox.PlaceholderColor3 = config.SecondaryTextColor
                
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = InputBox
                
                InputBox.FocusLost:Connect(function()
                    if InputBox.Text == "" then
                        InputBox.Text = default
                    end
                    WindUI.flags[flag] = InputBox.Text
                    callback(InputBox.Text)
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
                
                WindUI.flags[flag] = default

                local Slider = Instance.new("TextButton")
                local SliderCorner = Instance.new("UICorner")
                local SliderText = Instance.new("TextLabel")
                local SliderBar = Instance.new("Frame")
                local BarCorner = Instance.new("UICorner")
                local SliderFill = Instance.new("Frame")
                local FillCorner = Instance.new("UICorner")
                local SliderValue = Instance.new("TextLabel")
                
                Slider.Name = "Slider"
                Slider.Parent = SectionContent
                Slider.BackgroundColor3 = config.Slider_Color
                Slider.BackgroundTransparency = 0.1
                Slider.Size = UDim2.new(1, 0, 0, 50)
                Slider.AutoButtonColor = false
                Slider.Font = Enum.Font.SourceSans
                Slider.Text = ""
                
                SliderCorner.CornerRadius = UDim.new(0, 6)
                SliderCorner.Parent = Slider
                
                SliderText.Name = "SliderText"
                SliderText.Parent = Slider
                SliderText.BackgroundTransparency = 1
                SliderText.Position = UDim2.new(0, 10, 0, 5)
                SliderText.Size = UDim2.new(0, 200, 0, 20)
                SliderText.Font = Enum.Font.GothamSemibold
                SliderText.Text = text
                SliderText.TextColor3 = config.TextColor
                SliderText.TextSize = 13
                SliderText.TextXAlignment = Enum.TextXAlignment.Left
                
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = Slider
                SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                SliderBar.Position = UDim2.new(0, 10, 0, 30)
                SliderBar.Size = UDim2.new(1, -20, 0, 8)
                
                BarCorner.CornerRadius = UDim.new(1, 0)
                BarCorner.Parent = SliderBar
                
                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderBar
                SliderFill.BackgroundColor3 = config.SliderBar_Color
                SliderFill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
                
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = Slider
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(1, -60, 0, 5)
                SliderValue.Size = UDim2.new(0, 50, 0, 20)
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
                        WindUI.flags[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        
                        services.TweenService:Create(SliderFill, TweenInfo.new(0.1), {
                            Size = UDim2.new(percent, 0, 1, 0)
                        }):Play()
                        
                        callback(tonumber(value))
                    end,
                    
                    GetValue = function(self)
                        return WindUI.flags[flag]
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
                WindUI.flags[flag] = nil
                
                local Dropdown = Instance.new("TextButton")
                local DropdownCorner = Instance.new("UICorner")
                local DropdownText = Instance.new("TextLabel")
                local DropdownValue = Instance.new("TextLabel")
                local DropdownArrow = Instance.new("ImageLabel")
                local DropdownOptions = Instance.new("Frame")
                local OptionsLayout = Instance.new("UIListLayout")
                
                Dropdown.Name = "Dropdown"
                Dropdown.Parent = SectionContent
                Dropdown.BackgroundColor3 = config.Dropdown_Color
                Dropdown.BackgroundTransparency = 0.1
                Dropdown.Size = UDim2.new(1, 0, 0, 35)
                Dropdown.AutoButtonColor = false
                Dropdown.Font = Enum.Font.SourceSans
                Dropdown.Text = ""
                
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = Dropdown
                
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = Dropdown
                DropdownText.BackgroundTransparency = 1
                DropdownText.Position = UDim2.new(0, 10, 0, 0)
                DropdownText.Size = UDim2.new(0, 200, 1, 0)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.Text = text
                DropdownText.TextColor3 = config.TextColor
                DropdownText.TextSize = 13
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                
                DropdownValue.Name = "DropdownValue"
                DropdownValue.Parent = Dropdown
                DropdownValue.BackgroundTransparency = 1
                DropdownValue.Position = UDim2.new(0, 150, 0, 0)
                DropdownValue.Size = UDim2.new(1, -40, 1, 0)
                DropdownValue.Font = Enum.Font.Gotham
                DropdownValue.Text = "Select..."
                DropdownValue.TextColor3 = config.SecondaryTextColor
                DropdownValue.TextSize = 12
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
                
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Parent = Dropdown
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Position = UDim2.new(1, -20, 0, 10)
                DropdownArrow.Size = UDim2.new(0, 15, 0, 15)
                DropdownArrow.Image = "rbxassetid://3926305904"
                DropdownArrow.ImageRectOffset = Vector2.new(284, 4)
                DropdownArrow.ImageRectSize = Vector2.new(24, 24)
                DropdownArrow.ImageColor3 = config.SecondaryTextColor
                
                DropdownOptions.Name = "DropdownOptions"
                DropdownOptions.Parent = Dropdown
                DropdownOptions.BackgroundColor3 = config.Bg_Color
                DropdownOptions.Position = UDim2.new(0, 0, 1, 5)
                DropdownOptions.Size = UDim2.new(1, 0, 0, 0)
                DropdownOptions.Visible = false
                
                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 6)
                OptionsCorner.Parent = DropdownOptions
                
                OptionsLayout.Name = "OptionsLayout"
                OptionsLayout.Parent = DropdownOptions
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownOptions
                    Option.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(1, 0, 0, 25)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = config.TextColor
                    Option.TextSize = 12
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = Option
                    
                    Option.MouseButton1Click:Connect(function()
                        Ripple(Option)
                        DropdownValue.Text = option
                        DropdownOptions.Visible = false
                        DropdownArrow.Rotation = 0
                        callback(option)
                        WindUI.flags[flag] = option
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
                
                local open = false
                Dropdown.MouseButton1Click:Connect(function()
                    Ripple(Dropdown)
                    open = not open
                    DropdownOptions.Visible = open
                    services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                        Rotation = open and 180 or 0
                    }):Play()
                    
                    if open then
                        DropdownOptions.Size = UDim2.new(1, 0, 0, math.min(#options * 25 + 5, 100))
                    end
                end)
                
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
    if WindUIGui then
        WindUIGui:Destroy()
    end
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    WindUIGui.Enabled = ToggleUI
    Main.Visible = not ToggleUI
end

return WindUI
