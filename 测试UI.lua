repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().VoidwareUI = {}

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

local VoidwareUI = {}
local ToggleUI = true
VoidwareUI.currentTab = nil
VoidwareUI.flags = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

local config = {
    -- 主色调 - 深色科技感
    MainColor = Color3.fromRGB(12, 12, 20),
    TabColor = Color3.fromRGB(18, 18, 28),
    Bg_Color = Color3.fromRGB(15, 15, 25),
    Sidebar_Color = Color3.fromRGB(20, 20, 32),
    
    -- 强调色 - 霓虹蓝和粉色
    PrimaryAccent = Color3.fromRGB(0, 200, 255),   -- 霓虹蓝
    SecondaryAccent = Color3.fromRGB(255, 50, 150), -- 霓虹粉
    
    -- 控件颜色
    Button_Color = Color3.fromRGB(25, 25, 40),
    Textbox_Color = Color3.fromRGB(25, 25, 40),
    Dropdown_Color = Color3.fromRGB(25, 25, 40),
    Keybind_Color = Color3.fromRGB(25, 25, 40),
    Label_Color = Color3.fromRGB(25, 25, 40),
    Slider_Color = Color3.fromRGB(25, 25, 40),
    SliderBar_Color = Color3.fromRGB(0, 200, 255),
    Toggle_Color = Color3.fromRGB(25, 25, 40),
    Toggle_Off = Color3.fromRGB(40, 40, 60),
    Toggle_On = Color3.fromRGB(0, 200, 255),
    
    -- 文本颜色
    TextColor = Color3.fromRGB(240, 240, 255),
    SecondaryTextColor = Color3.fromRGB(180, 180, 200),
    WarningColor = Color3.fromRGB(255, 100, 100),
    SuccessColor = Color3.fromRGB(100, 255, 150),
    
    -- 发光效果
    GlowColor = Color3.fromRGB(0, 200, 255),
    PinkGlow = Color3.fromRGB(255, 50, 150),
    
    -- 边框
    BorderColor = Color3.fromRGB(50, 50, 70),
}

local function createGlowEffect(object, color, thickness)
    local glow = Instance.new("UIStroke")
    glow.Parent = object
    glow.Color = color or config.GlowColor
    glow.Thickness = thickness or 2
    glow.Transparency = 0.7
    glow.LineJoinMode = Enum.LineJoinMode.Round
    
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            pulseConnection:Disconnect()
            return
        end
        
        local alpha = 0.6 + math.sin(tick() * 3) * 0.3
        glow.Transparency = alpha
    end)
    
    return glow
end

local function createNeonEffect(object, property)
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + 0.02) % 1
        local r = math.sin(hue * 6 + 0) * 0.5 + 0.5
        local g = math.sin(hue * 6 + 2) * 0.5 + 0.5
        local b = math.sin(hue * 6 + 4) * 0.5 + 0.5
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createScanlines(frame)
    local scanlines = Instance.new("Frame")
    scanlines.Name = "Scanlines"
    scanlines.BackgroundTransparency = 1
    scanlines.Size = UDim2.new(1, 0, 1, 0)
    scanlines.ZIndex = 2
    scanlines.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(0.1, 0.85),
        NumberSequenceKeypoint.new(0.2, 0.95),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    gradient.Parent = scanlines
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if scanlines and scanlines.Parent then
            gradient.Offset = Vector2.new(0, (tick() * 0.5) % 1)
        else
            connection:Disconnect()
        end
    end)
    
    return scanlines
end

local function createButtonEffect(button)
    button.MouseEnter:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(button.BackgroundColor3.R * 255 * 1.2),
                math.floor(button.BackgroundColor3.G * 255 * 1.2),
                math.floor(button.BackgroundColor3.B * 255 * 1.2)
            )
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = config.Button_Color
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(button.BackgroundColor3.R * 255 * 0.8),
                math.floor(button.BackgroundColor3.G * 255 * 0.8),
                math.floor(button.BackgroundColor3.B * 255 * 0.8)
            )
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        services.TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = config.Button_Color
        }):Play()
    end)
end

local function createRoundedCorners(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "VoidwareUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local MainUI = Instance.new("ScreenGui")
MainUI.Name = "VoidwareUI"
protectGUI(MainUI)
MainUI.Parent = services.CoreGui

local MainContainer = Instance.new("Frame")
MainContainer.Name = "MainContainer"
MainContainer.Parent = MainUI
MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
MainContainer.BackgroundColor3 = config.MainColor
MainContainer.BackgroundTransparency = 0.1
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
MainContainer.Size = UDim2.new(0, 800, 0, 500)
MainContainer.ZIndex = 1
MainContainer.Active = true
MainContainer.Draggable = true

createRoundedCorners(MainContainer, 12)

local mainGlow = createGlowEffect(MainContainer, config.PrimaryAccent, 3)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainContainer
Header.BackgroundColor3 = config.Sidebar_Color
Header.BackgroundTransparency = 0.1
Header.Size = UDim2.new(1, 0, 0, 50)

createRoundedCorners(Header, 12)

local HeaderGlow = createGlowEffect(Header, config.PrimaryAccent, 2)

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "VOIDWARE"
Title.TextColor3 = config.PrimaryAccent
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left

createNeonEffect(Title, "TextColor3")

local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Parent = Header
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0.02, 0, 0.6, 0)
Subtitle.Size = UDim2.new(0, 200, 0, 20)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Advanced Script Hub"
Subtitle.TextColor3 = config.SecondaryTextColor
Subtitle.TextSize = 14
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = Header
CloseButton.BackgroundColor3 = config.WarningColor
CloseButton.BackgroundTransparency = 0.8
CloseButton.Position = UDim2.new(0.95, 0, 0.2, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.ZIndex = 3

createRoundedCorners(CloseButton, 6)
createGlowEffect(CloseButton, config.WarningColor, 2)

CloseButton.MouseButton1Click:Connect(function()
    services.TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(mainGlow, TweenInfo.new(0.3), {
        Thickness = 0,
        Transparency = 1
    }):Play()
    
    task.wait(0.3)
    MainUI:Destroy()
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainContainer
Sidebar.BackgroundColor3 = config.Sidebar_Color
Sidebar.BackgroundTransparency = 0.1
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.Size = UDim2.new(0, 200, 0, 450)

local sidebarGlow = createGlowEffect(Sidebar, config.SecondaryAccent, 2)

local TabButtons = Instance.new("ScrollingFrame")
TabButtons.Name = "TabButtons"
TabButtons.Parent = Sidebar
TabButtons.BackgroundTransparency = 1
TabButtons.BorderSizePixel = 0
TabButtons.Position = UDim2.new(0, 10, 0, 20)
TabButtons.Size = UDim2.new(1, -20, 1, -40)
TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
TabButtons.ScrollBarThickness = 0

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabButtons
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 10)

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = MainContainer
ContentArea.BackgroundColor3 = config.Bg_Color
ContentArea.BackgroundTransparency = 0.1
ContentArea.Position = UDim2.new(0, 210, 0, 60)
ContentArea.Size = UDim2.new(0, 580, 0, 430)

createRoundedCorners(ContentArea, 10)
createGlowEffect(ContentArea, config.PrimaryAccent, 1)

createScanlines(ContentArea)

local ContentScrolling = Instance.new("ScrollingFrame")
ContentScrolling.Name = "ContentScrolling"
ContentScrolling.Parent = ContentArea
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.Position = UDim2.new(0, 10, 0, 10)
ContentScrolling.Size = UDim2.new(1, -20, 1, -20)
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.ScrollBarThickness = 3
ContentScrolling.ScrollBarImageColor3 = config.PrimaryAccent

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentScrolling
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 15)

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)

local function createTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Parent = TabButtons
    TabButton.BackgroundColor3 = config.TabColor
    TabButton.BackgroundTransparency = 0.2
    TabButton.Size = UDim2.new(1, 0, 0, 45)
    TabButton.AutoButtonColor = false
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = config.SecondaryTextColor
    TabButton.TextSize = 16
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    
    createRoundedCorners(TabButton, 8)
    createGlowEffect(TabButton, config.SecondaryAccent, 1)
    
    local TabContent = Instance.new("Frame")
    TabContent.Name = name .. "Content"
    TabContent.Parent = ContentScrolling
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.Visible = false
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Parent = TabContent
    TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabContentLayout.Padding = UDim.new(0, 15)
    
    TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.Size = UDim2.new(1, 0, 0, TabContentLayout.AbsoluteContentSize.Y)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        for _, btn in ipairs(TabButtons:GetChildren()) do
            if btn:IsA("TextButton") then
                services.TweenService:Create(btn, TweenInfo.new(0.3), {
                    BackgroundColor3 = config.TabColor,
                    TextColor3 = config.SecondaryTextColor
                }):Play()
            end
        end
        
        for _, content in ipairs(ContentScrolling:GetChildren()) do
            if content:IsA("Frame") and content.Name:match("Content$") then
                content.Visible = false
            end
        end
        
        services.TweenService:Create(TabButton, TweenInfo.new(0.3), {
            BackgroundColor3 = config.PrimaryAccent,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        TabContent.Visible = true
        VoidwareUI.currentTab = name
    end)
    
    local tab = {}
    
    function tab:CreateSection(title)
        local Section = Instance.new("Frame")
        Section.Name = "Section"
        Section.Parent = TabContent
        Section.BackgroundColor3 = config.TabColor
        Section.BackgroundTransparency = 0.2
        Section.Size = UDim2.new(1, 0, 0, 40)
        
        createRoundedCorners(Section, 8)
        createGlowEffect(Section, config.PrimaryAccent, 1)
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Parent = Section
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Position = UDim2.new(0, 15, 0, 0)
        SectionTitle.Size = UDim2.new(1, -30, 1, 0)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.Text = title
        SectionTitle.TextColor3 = config.TextColor
        SectionTitle.TextSize = 18
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local SectionContent = Instance.new("Frame")
        SectionContent.Name = "SectionContent"
        SectionContent.Parent = Section
        SectionContent.BackgroundTransparency = 1
        SectionContent.Position = UDim2.new(0, 0, 0, 45)
        SectionContent.Size = UDim2.new(1, 0, 0, 0)
        
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.Parent = SectionContent
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SectionLayout.Padding = UDim.new(0, 10)
        
        SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            SectionContent.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y)
            Section.Size = UDim2.new(1, 0, 0, 45 + SectionLayout.AbsoluteContentSize.Y + 15)
        end)
        
        local section = {}
        
        function section:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Name = text .. "Button"
            Button.Parent = SectionContent
            Button.BackgroundColor3 = config.Button_Color
            Button.BackgroundTransparency = 0.2
            Button.Size = UDim2.new(1, 0, 0, 40)
            Button.AutoButtonColor = false
            Button.Font = Enum.Font.GothamSemibold
            Button.Text = text
            Button.TextColor3 = config.TextColor
            Button.TextSize = 16
            
            createRoundedCorners(Button, 6)
            createGlowEffect(Button, config.PrimaryAccent, 1)
            createButtonEffect(Button)
            
            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            return Button
        end
        
        function section:CreateToggle(text, flag, default, callback)
            default = default or false
            VoidwareUI.flags[flag] = default
            
            local Toggle = Instance.new("Frame")
            Toggle.Name = text .. "Toggle"
            Toggle.Parent = SectionContent
            Toggle.BackgroundTransparency = 1
            Toggle.Size = UDim2.new(1, 0, 0, 40)
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Parent = Toggle
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
            ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleLabel.Font = Enum.Font.GothamSemibold
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = config.TextColor
            ToggleLabel.TextSize = 16
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Parent = Toggle
            ToggleButton.BackgroundColor3 = default and config.PrimaryAccent or config.Toggle_Off
            ToggleButton.BackgroundTransparency = 0.2
            ToggleButton.Position = UDim2.new(0.85, 0, 0.25, 0)
            ToggleButton.Size = UDim2.new(0, 50, 0, 20)
            ToggleButton.AutoButtonColor = false
            ToggleButton.Text = ""
            
            createRoundedCorners(ToggleButton, 10)
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "ToggleCircle"
            ToggleCircle.Parent = ToggleButton
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
            ToggleCircle.Position = UDim2.new(0, default and 30 or 4, 0, 2)
            
            createRoundedCorners(ToggleCircle, 8)
            
            ToggleButton.MouseButton1Click:Connect(function()
                local newState = not VoidwareUI.flags[flag]
                VoidwareUI.flags[flag] = newState
                
                services.TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
                    BackgroundColor3 = newState and config.PrimaryAccent or config.Toggle_Off
                }):Play()
                
                services.TweenService:Create(ToggleCircle, TweenInfo.new(0.3), {
                    Position = UDim2.new(0, newState and 30 or 4, 0, 2)
                }):Play()
                
                if callback then
                    callback(newState)
                end
            end)
            
            return Toggle
        end
        
        function section:CreateSlider(text, flag, min, max, default, callback)
            default = default or min
            VoidwareUI.flags[flag] = default
            
            local Slider = Instance.new("Frame")
            Slider.Name = text .. "Slider"
            Slider.Parent = SectionContent
            Slider.BackgroundTransparency = 1
            Slider.Size = UDim2.new(1, 0, 0, 60)
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Parent = Slider
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Position = UDim2.new(0, 0, 0, 0)
            SliderLabel.Size = UDim2.new(1, 0, 0, 20)
            SliderLabel.Font = Enum.Font.GothamSemibold
            SliderLabel.Text = text .. ": " .. default
            SliderLabel.TextColor3 = config.TextColor
            SliderLabel.TextSize = 16
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = "SliderTrack"
            SliderTrack.Parent = Slider
            SliderTrack.BackgroundColor3 = config.Slider_Color
            SliderTrack.BackgroundTransparency = 0.2
            SliderTrack.Position = UDim2.new(0, 0, 0, 30)
            SliderTrack.Size = UDim2.new(1, 0, 0, 10)
            
            createRoundedCorners(SliderTrack, 5)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = SliderTrack
            SliderFill.BackgroundColor3 = config.SliderBar_Color
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            
            createRoundedCorners(SliderFill, 5)
            createGlowEffect(SliderFill, config.SliderBar_Color, 2)
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Name = "SliderButton"
            SliderButton.Parent = SliderTrack
            SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderButton.BackgroundTransparency = 0
            SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -3)
            SliderButton.Size = UDim2.new(0, 16, 0, 16)
            SliderButton.Text = ""
            
            createRoundedCorners(SliderButton, 8)
            createGlowEffect(SliderButton, Color3.fromRGB(255, 255, 255), 2)
            
            local dragging = false
            
            local function updateSlider(value)
                value = math.clamp(value, min, max)
                local percent = (value - min) / (max - min)
                
                services.TweenService:Create(SliderFill, TweenInfo.new(0.1), {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()
                
                services.TweenService:Create(SliderButton, TweenInfo.new(0.1), {
                    Position = UDim2.new(percent, -8, 0, -3)
                }):Play()
                
                SliderLabel.Text = text .. ": " .. math.floor(value)
                VoidwareUI.flags[flag] = value
                
                if callback then
                    callback(value)
                end
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            services.UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            services.UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = services.UserInputService:GetMouseLocation()
                    local trackPos = SliderTrack.AbsolutePosition.X
                    local trackSize = SliderTrack.AbsoluteSize.X
                    local relativeX = (mousePos.X - trackPos) / trackSize
                    local value = min + (max - min) * math.clamp(relativeX, 0, 1)
                    updateSlider(value)
                end
            end)
            
            SliderTrack.MouseButton1Down:Connect(function()
                local mousePos = services.UserInputService:GetMouseLocation()
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local relativeX = (mousePos.X - trackPos) / trackSize
                local value = min + (max - min) * math.clamp(relativeX, 0, 1)
                updateSlider(value)
            end)
            
            return Slider
        end
        
        function section:CreateLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Name = text .. "Label"
            Label.Parent = SectionContent
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 0, 30)
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = config.SecondaryTextColor
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            return Label
        end
        
        function section:CreateDropdown(text, flag, options, callback)
            VoidwareUI.flags[flag] = options[1] or ""
            
            local Dropdown = Instance.new("Frame")
            Dropdown.Name = text .. "Dropdown"
            Dropdown.Parent = SectionContent
            Dropdown.BackgroundTransparency = 1
            Dropdown.Size = UDim2.new(1, 0, 0, 40)
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "DropdownLabel"
            DropdownLabel.Parent = Dropdown
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Position = UDim2.new(0, 0, 0, 0)
            DropdownLabel.Size = UDim2.new(0.7, 0, 1, 0)
            DropdownLabel.Font = Enum.Font.GothamSemibold
            DropdownLabel.Text = text
            DropdownLabel.TextColor3 = config.TextColor
            DropdownLabel.TextSize = 16
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = Dropdown
            DropdownButton.BackgroundColor3 = config.Dropdown_Color
            DropdownButton.BackgroundTransparency = 0.2
            DropdownButton.Position = UDim2.new(0.7, 0, 0.25, 0)
            DropdownButton.Size = UDim2.new(0.3, 0, 0, 30)
            DropdownButton.AutoButtonColor = false
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.Text = options[1] or "Select"
            DropdownButton.TextColor3 = config.TextColor
            DropdownButton.TextSize = 14
            
            createRoundedCorners(DropdownButton, 6)
            createGlowEffect(DropdownButton, config.PrimaryAccent, 1)
            
            local DropdownList = Instance.new("Frame")
            DropdownList.Name = "DropdownList"
            DropdownList.Parent = Dropdown
            DropdownList.BackgroundColor3 = config.Dropdown_Color
            DropdownList.BackgroundTransparency = 0.1
            DropdownList.Position = UDim2.new(0.7, 0, 0.25, 30)
            DropdownList.Size = UDim2.new(0.3, 0, 0, 0)
            DropdownList.Visible = false
            DropdownList.ClipsDescendants = true
            
            createRoundedCorners(DropdownList, 6)
            createGlowEffect(DropdownList, config.SecondaryAccent, 1)
            
            local DropdownLayout = Instance.new("UIListLayout")
            DropdownLayout.Parent = DropdownList
            DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local function toggleDropdown()
                DropdownList.Visible = not DropdownList.Visible
                services.TweenService:Create(DropdownList, TweenInfo.new(0.3), {
                    Size = UDim2.new(0.3, 0, 0, DropdownList.Visible and (math.min(#options * 35, 150)) or 0)
                }):Play()
            end
            
            DropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            for _, option in ipairs(options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = option .. "Option"
                OptionButton.Parent = DropdownList
                OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                OptionButton.BackgroundTransparency = 0.2
                OptionButton.Size = UDim2.new(1, -10, 0, 30)
                OptionButton.Position = UDim2.new(0, 5, 0, 0)
                OptionButton.AutoButtonColor = false
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Text = option
                OptionButton.TextColor3 = config.TextColor
                OptionButton.TextSize = 14
                
                createRoundedCorners(OptionButton, 4)
                
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = option
                    VoidwareUI.flags[flag] = option
                    toggleDropdown()
                    
                    if callback then
                        callback(option)
                    end
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    services.TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.PrimaryAccent
                    }):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    services.TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                    }):Play()
                end)
            end
            
            DropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownLayout.AbsoluteContentSize.Y)
            end)
            
            return Dropdown
        end
        
        return section
    end
    
    return tab
end

-- 创建示例选项卡
local mainTab = createTab("MAIN")
local espTab = createTab("ESP")
local miscTab = createTab("MISC")
local settingsTab = createTab("SETTINGS")

-- 主选项卡内容
local mainSection = mainTab:CreateSection("SNT HUB")
mainSection:CreateToggle("Persistent", "Persistent", true)
mainSection:CreateLabel("INFO")
mainSection:CreateToggle("SOCIALS", "Socials", true)
mainSection:CreateLabel("CHARACTER")

local sampleSection = mainTab:CreateSection("SAMPLE")
sampleSection:CreateToggle("ESP", "ESP", false)
sampleSection:CreateToggle("AMABOT", "Amabot", true)
sampleSection:CreateLabel("Dinoydaah109")

local roundSection = mainTab:CreateSection("Round ends in:")
roundSection:CreateToggle("Show Rayfield", "ShowRayfield", false)
roundSection:CreateLabel("OFF")
roundSection:CreateLabel("generator to get them up &")

-- ESP选项卡内容
local espFeatures = espTab:CreateSection("ESP Features")
espFeatures:CreateToggle("Player ESP", "PlayerESP", true)
espFeatures:CreateToggle("Item ESP", "ItemESP", false)
espFeatures:CreateToggle("Distance Check", "DistanceCheck", true)
espFeatures:CreateSlider("Max Distance", "MaxDistance", 0, 500, 100)

local espColors = espTab:CreateSection("ESP Colors")
espColors:CreateDropdown("Team Color", "TeamColor", {"Red", "Blue", "Green", "Yellow"})

-- 杂项选项卡内容
local staminaSection = miscTab:CreateSection("Infinite Stamina")
staminaSection:CreateLabel("Never get tired while sprinting")
staminaSection:CreateToggle("Infinite Stamina", "InfiniteStamina", true)

local antiSection = miscTab:CreateSection("Anti Features")
antiSection:CreateToggle("Anti Stun", "AntiStun", true)
antiSection:CreateLabel("Never get stunned")
antiSection:CreateToggle("Anti Slow", "AntiSlow", false)
antiSection:CreateLabel("Never get slowed")

-- 设置选项卡内容
local uiSettings = settingsTab:CreateSection("UI Settings")
uiSettings:CreateDropdown("Theme", "Theme", {"Dark", "Light", "Blue", "Pink"})
uiSettings:CreateSlider("UI Transparency", "UITransparency", 0, 100, 20)
uiSettings:CreateToggle("Show Watermark", "ShowWatermark", true)
uiSettings:CreateToggle("Notifications", "Notifications", true)

local keybinds = settingsTab:CreateSection("Keybinds")
keybinds:CreateButton("Toggle UI - LeftControl", function()
    MainContainer.Visible = not MainContainer.Visible
end)
keybinds:CreateButton("Destroy UI", function()
    MainUI:Destroy()
end)

-- 默认选择第一个选项卡
if TabButtons:FindFirstChild("MAINTab") then
    TabButtons.MAINTab:Fire("MouseButton1Click")
end

-- 添加UI拖拽功能
local dragStart, startPos
MainContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = MainContainer.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragStart = nil
            end
        end)
    end
end)

MainContainer.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 创建迷你按钮
local MiniButton = Instance.new("TextButton")
MiniButton.Name = "MiniButton"
MiniButton.Parent = MainUI
MiniButton.BackgroundColor3 = config.PrimaryAccent
MiniButton.BackgroundTransparency = 0.8
MiniButton.Position = UDim2.new(0, 20, 0, 20)
MiniButton.Size = UDim2.new(0, 50, 0, 50)
MiniButton.Font = Enum.Font.GothamBold
MiniButton.Text = "V"
MiniButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniButton.TextSize = 24

createRoundedCorners(MiniButton, 8)
createGlowEffect(MiniButton, config.PrimaryAccent, 2)

MiniButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
end)

-- 全局UI切换快捷键
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.LeftControl then
            MainContainer.Visible = not MainContainer.Visible
        elseif input.KeyCode == Enum.KeyCode.RightControl then
            MainUI:Destroy()
        end
    end
end)

-- 初始化动画
MainContainer.Size = UDim2.new(0, 0, 0, 0)
MainContainer.BackgroundTransparency = 1
mainGlow.Transparency = 1

services.TweenService:Create(MainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 800, 0, 500),
    BackgroundTransparency = 0.1
}):Play()

services.TweenService:Create(mainGlow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Transparency = 0.7
}):Play()

-- 创建波纹效果
local function createRippleEffect(button)
    button.MouseButton1Click:Connect(function()
        local Ripple = Instance.new("Frame")
        Ripple.Name = "Ripple"
        Ripple.Parent = button
        Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.BackgroundTransparency = 0.7
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        
        createRoundedCorners(Ripple, 100)
        
        services.TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.5)
        Ripple:Destroy()
    end)
end

-- 为所有按钮添加波纹效果
for _, button in ipairs(MainContainer:GetDescendants()) do
    if button:IsA("TextButton") and button.Name ~= "CloseButton" then
        createRippleEffect(button)
    end
end

-- 公开API
function VoidwareUI:Destroy()
    MainUI:Destroy()
end

function VoidwareUI:Toggle()
    MainContainer.Visible = not MainContainer.Visible
end

function VoidwareUI:GetFlag(flag)
    return VoidwareUI.flags[flag]
end

function VoidwareUI:SetFlag(flag, value)
    VoidwareUI.flags[flag] = value
end

getgenv().VoidwareUI = VoidwareUI

return VoidwareUI