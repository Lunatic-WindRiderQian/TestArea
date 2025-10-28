--[[
    FengY3 UI Library v2.0
    A modern, lightweight UI library for Roblox
    Features:
    - Clean and modern design
    - Full theming support
    - Smooth animations
    - Comprehensive documentation
    - Easy to use
]]

repeat
    task.wait()
until game:IsLoaded()

-- Performance optimization
settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

-- Executor detection
local executor = {
    Synapse = syn and syn.protect_gui ~= nil,
    ScriptWare = secure_load ~= nil,
    Krnl = krnl and krnl.protect_gui ~= nil,
    Fluxus = fluxus and fluxus.protect_gui ~= nil,
    Electron = is_sirhurt_closure ~= nil,
    Comet = comet and comet.protect_gui ~= nil,
    Oxygen = getexecutorname and getexecutorname():lower():find("oxygen") ~= nil,
    Alus = alus and alus.protect_gui ~= nil,
    Xeno = xeno and xeno.protect_gui ~= nil
}

-- GUI protection function
local function protectGUI(gui)
    if executor.Synapse then
        syn.protect_gui(gui)
    elseif executor.ScriptWare then
        secure_load(gui)
    elseif executor.Krnl then
        krnl.protect_gui(gui)
    elseif executor.Fluxus then
        fluxus.protect_gui(gui)
    elseif executor.Electron then
        protect_gui(gui)
    elseif executor.Comet then
        comet.protect_gui(gui)
    elseif executor.Oxygen then
        protect_gui(gui)
    elseif executor.Alus then
        alus.protect_gui(gui)
    elseif executor.Xeno then
        xeno.protect_gui(gui)
    end
    
    local success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        game:GetService("StarterGui"):SetCore("RobloxGui", gui)
    end
end

-- Main UI Library
local FengY3 = {
    currentTab = nil,
    flags = {},
    themes = {},
    connections = {}
}

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService")
}

-- Default configuration
local Config = {
    -- Colors
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
    Error = Color3.fromRGB(244, 67, 54),
    
    -- Sizes
    WindowWidth = 500,
    WindowHeight = 350,
    TabWidth = 80,
    BorderRadius = 8,
    
    -- Animations
    TweenDuration = 0.2,
    TweenStyle = Enum.EasingStyle.Quad,
    
    -- Fonts
    TitleFont = Enum.Font.GothamBold,
    HeaderFont = Enum.Font.GothamSemibold,
    BodyFont = Enum.Font.Gotham,
    
    -- Text Sizes
    TitleSize = 18,
    HeaderSize = 16,
    BodySize = 14,
    SmallSize = 12
}

-- Predefined themes
FengY3.themes = {
    Dark = {
        Primary = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(240, 240, 240)
    },
    Light = {
        Primary = Color3.fromRGB(245, 245, 245),
        Secondary = Color3.fromRGB(225, 225, 235),
        Accent = Color3.fromRGB(0, 100, 200),
        Text = Color3.fromRGB(30, 30, 30)
    },
    Purple = {
        Primary = Color3.fromRGB(30, 25, 45),
        Secondary = Color3.fromRGB(45, 35, 65),
        Accent = Color3.fromRGB(147, 112, 219),
        Text = Color3.fromRGB(240, 240, 240)
    },
    Green = {
        Primary = Color3.fromRGB(25, 35, 25),
        Secondary = Color3.fromRGB(35, 45, 35),
        Accent = Color3.fromRGB(76, 175, 80),
        Text = Color3.fromRGB(240, 240, 240)
    }
}

-- Utility functions
local function CreateRoundedFrame(parent, size, position)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Config.Primary
    frame.Size = size or UDim2.new(1, 0, 1, 0)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Config.BorderRadius)
    corner.Parent = frame
    
    return frame
end

local function CreateStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.Accent
    stroke.Thickness = thickness or 1
    stroke.Parent = object
    return stroke
end

local function CreateLabel(parent, text, font, textSize, textColor)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = font or Config.BodyFont
    label.TextSize = textSize or Config.BodySize
    label.TextColor3 = textColor or Config.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

-- Ripple effect
function FengY3:Ripple(button)
    if not button then return end
    
    task.spawn(function()
        button.ClipsDescendants = true
        
        local ripple = Instance.new("ImageLabel")
        ripple.Name = "Ripple"
        ripple.Parent = button
        ripple.BackgroundTransparency = 1
        ripple.ZIndex = 8
        ripple.Image = "rbxassetid://8572677762"
        ripple.ImageTransparency = 0.6
        ripple.ScaleType = Enum.ScaleType.Fit
        ripple.ImageColor3 = Config.Accent
        
        local mouse = Services.Players.LocalPlayer:GetMouse()
        local x = (mouse.X - ripple.AbsolutePosition.X) / button.AbsoluteSize.X
        local y = (mouse.Y - ripple.AbsolutePosition.Y) / button.AbsoluteSize.Y
        
        ripple.Position = UDim2.new(x, 0, y, 0)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        
        Services.TweenService:Create(ripple, TweenInfo.new(0.6), {
            Position = UDim2.new(-0.8, 0, -0.8, 0),
            Size = UDim2.new(2.6, 0, 2.6, 0)
        }):Play()
        
        Services.TweenService:Create(ripple, TweenInfo.new(0.8), {
            ImageTransparency = 1
        }):Play()
        
        task.wait(0.8)
        ripple:Destroy()
    end)
end

-- Tab management
function FengY3:SwitchTab(newTab)
    if self.currentTab == newTab then return end
    
    local oldTab = self.currentTab
    self.currentTab = newTab
    
    if oldTab then
        Services.TweenService:Create(oldTab.Button, TweenInfo.new(Config.TweenDuration), {
            BackgroundTransparency = 0.8
        }):Play()
        Services.TweenService:Create(oldTab.Button.TabText, TweenInfo.new(Config.TweenDuration), {
            TextTransparency = 0.5
        }):Play()
        oldTab.Content.Visible = false
    end
    
    Services.TweenService:Create(newTab.Button, TweenInfo.new(Config.TweenDuration), {
        BackgroundTransparency = 0.2
    }):Play()
    Services.TweenService:Create(newTab.Button.TabText, TweenInfo.new(Config.TweenDuration), {
        TextTransparency = 0
    }):Play()
    newTab.Content.Visible = true
end

-- Main UI creation
function FengY3:CreateUI(title, theme)
    -- Cleanup existing UI
    for _, gui in ipairs(Services.CoreGui:GetChildren()) do
        if gui.Name == "FengY3UI" and gui:IsA("ScreenGui") then
            gui:Destroy()
        end
    end
    
    -- Apply theme
    if theme and self.themes[theme] then
        for key, value in pairs(self.themes[theme]) do
            if Config[key] ~= nil then
                Config[key] = value
            end
        end
    end
    
    -- Create main screen GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FengY3UI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    protectGUI(ScreenGui)
    
    -- Main container
    local Main = CreateRoundedFrame(ScreenGui, 
        UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight),
        UDim2.new(0.5, -Config.WindowWidth/2, 0.5, -Config.WindowHeight/2)
    )
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Config.Primary
    CreateStroke(Main, Config.Accent, 2)
    Main.Active = true
    Main.Draggable = true
    
    -- Header
    local Header = CreateRoundedFrame(Main,
        UDim2.new(1, 0, 0, 40)
    )
    Header.BackgroundColor3 = Config.Secondary
    
    local Title = CreateLabel(Header, title or "FengY3 UI", Config.TitleFont, Config.TitleSize)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Config.Error
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Config.Text
    CloseButton.TextSize = 20
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, Config.BorderRadius)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        self:Ripple(CloseButton)
        Services.TweenService:Create(Main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Tab container
    local TabContainer = CreateRoundedFrame(Main,
        UDim2.new(0, Config.TabWidth, 1, -40),
        UDim2.new(0, 0, 0, 40)
    )
    TabContainer.BackgroundColor3 = Config.Secondary
    
    local TabContent = CreateRoundedFrame(Main,
        UDim2.new(1, -Config.TabWidth - 10, 1, -50),
        UDim2.new(0, Config.TabWidth + 5, 0, 45)
    )
    TabContent.BackgroundColor3 = Config.Primary
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 3
    TabList.ScrollBarImageColor3 = Config.Accent
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabList
    
    local ContentScrolling = Instance.new("ScrollingFrame")
    ContentScrolling.Size = UDim2.new(1, 0, 1, 0)
    ContentScrolling.BackgroundTransparency = 1
    ContentScrolling.ScrollBarThickness = 3
    ContentScrolling.ScrollBarImageColor3 = Config.Accent
    ContentScrolling.Parent = TabContent
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = ContentScrolling
    
    -- Auto-resize scrolling frames
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    end)
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Toggle button
    local ToggleButton = CreateRoundedFrame(ScreenGui,
        UDim2.new(0, 50, 0, 50),
        UDim2.new(1, -60, 0, 10)
    )
    ToggleButton.BackgroundColor3 = Config.Accent
    
    local ToggleIcon = CreateLabel(ToggleButton, "☰", Config.TitleFont, 20)
    ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
    ToggleIcon.TextColor3 = Config.Text
    ToggleIcon.TextXAlignment = Enum.TextXAlignment.Center
    
    ToggleButton.MouseButton1Click:Connect(function()
        self:Ripple(ToggleButton)
        Main.Visible = not Main.Visible
    end)
    
    -- Keyboard toggle (Ctrl + T)
    Services.UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.T and Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            Main.Visible = not Main.Visible
        end
    end)
    
    ScreenGui.Parent = Services.CoreGui
    
    -- Window object
    local Window = {
        GUI = ScreenGui,
        Main = Main,
        Tabs = {}
    }
    
    function Window:Tab(name, icon)
        local TabButton = CreateRoundedFrame(TabList,
            UDim2.new(1, -10, 0, 40)
        )
        TabButton.BackgroundColor3 = Config.Secondary
        TabButton.BackgroundTransparency = 0.8
        
        local TabText = CreateLabel(TabButton, name, Config.HeaderFont, Config.BodySize)
        TabText.Size = UDim2.new(1, 0, 1, 0)
        TabText.TextColor3 = Config.Text
        TabText.TextTransparency = 0.5
        TabText.TextXAlignment = Enum.TextXAlignment.Center
        
        local TabContentFrame = CreateRoundedFrame(ContentScrolling,
            UDim2.new(1, 0, 0, 0)
        )
        TabContentFrame.BackgroundTransparency = 1
        TabContentFrame.Visible = false
        
        local Tab = {
            Button = TabButton,
            Content = TabContentFrame,
            Sections = {}
        }
        
        TabButton.MouseButton1Click:Connect(function()
            self:Ripple(TabButton)
            FengY3:SwitchTab(Tab)
        end)
        
        table.insert(Window.Tabs, Tab)
        
        if not FengY3.currentTab then
            FengY3:SwitchTab(Tab)
        end
        
        local TabObject = {}
        
        function TabObject:Section(title)
            local Section = CreateRoundedFrame(TabContentFrame,
                UDim2.new(1, 0, 0, 40)
            )
            Section.BackgroundColor3 = Config.Secondary
            
            local SectionTitle = CreateLabel(Section, title, Config.HeaderFont, Config.HeaderSize)
            SectionTitle.Size = UDim2.new(1, -20, 1, 0)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            
            local SectionContent = CreateRoundedFrame(TabContentFrame,
                UDim2.new(1, 0, 0, 0)
            )
            SectionContent.BackgroundTransparency = 1
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 5)
            SectionLayout.Parent = SectionContent
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y)
            end)
            
            local SectionObject = {}
            
            function SectionObject:Button(text, callback)
                local Button = CreateRoundedFrame(SectionContent,
                    UDim2.new(1, 0, 0, 35)
                )
                Button.BackgroundColor3 = Config.Secondary
                
                local ButtonLabel = CreateLabel(Button, text, Config.BodyFont, Config.BodySize)
                ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
                ButtonLabel.TextXAlignment = Enum.TextXAlignment.Center
                
                Button.MouseButton1Click:Connect(function()
                    self:Ripple(Button)
                    if callback then
                        callback()
                    end
                end)
                
                return Button
            end
            
            function SectionObject:Toggle(text, flag, default, callback)
                default = default or false
                FengY3.flags[flag] = default
                
                local Toggle = CreateRoundedFrame(SectionContent,
                    UDim2.new(1, 0, 0, 35)
                )
                Toggle.BackgroundColor3 = Config.Secondary
                
                local ToggleLabel = CreateLabel(Toggle, text, Config.BodyFont, Config.BodySize)
                ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                
                local ToggleButton = CreateRoundedFrame(Toggle,
                    UDim2.new(0, 50, 0, 25),
                    UDim2.new(1, -60, 0.5, -12.5)
                )
                ToggleButton.BackgroundColor3 = default and Config.Success or Config.Error
                
                local ToggleKnob = CreateRoundedFrame(ToggleButton,
                    UDim2.new(0, 20, 0, 20),
                    UDim2.new(0, default and 25 or 5, 0.5, -10)
                )
                ToggleKnob.BackgroundColor3 = Config.Text
                
                local function UpdateToggle(state)
                    FengY3.flags[flag] = state
                    Services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = state and Config.Success or Config.Error
                    }):Play()
                    Services.TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, state and 25 or 5, 0.5, -10)
                    }):Play()
                    if callback then
                        callback(state)
                    end
                end
                
                Toggle.MouseButton1Click:Connect(function()
                    self:Ripple(Toggle)
                    UpdateToggle(not FengY3.flags[flag])
                end)
                
                UpdateToggle(default)
                
                return {
                    SetState = function(_, state)
                        UpdateToggle(state)
                    end,
                    GetState = function()
                        return FengY3.flags[flag]
                    end
                }
            end
            
            function SectionObject:Slider(text, flag, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = default or min
                FengY3.flags[flag] = default
                
                local Slider = CreateRoundedFrame(SectionContent,
                    UDim2.new(1, 0, 0, 50)
                )
                Slider.BackgroundColor3 = Config.Secondary
                
                local SliderLabel = CreateLabel(Slider, text, Config.BodyFont, Config.BodySize)
                SliderLabel.Size = UDim2.new(1, -20, 0, 20)
                SliderLabel.Position = UDim2.new(0, 10, 0, 5)
                
                local SliderValue = CreateLabel(Slider, tostring(default), Config.BodyFont, Config.SmallSize)
                SliderValue.Size = UDim2.new(0, 40, 0, 20)
                SliderValue.Position = UDim2.new(1, -50, 0, 5)
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                
                local SliderTrack = CreateRoundedFrame(Slider,
                    UDim2.new(1, -20, 0, 6),
                    UDim2.new(0, 10, 1, -15)
                )
                SliderTrack.BackgroundColor3 = Config.Primary
                
                local SliderFill = CreateRoundedFrame(SliderTrack,
                    UDim2.new((default - min) / (max - min), 0, 1, 0)
                )
                SliderFill.BackgroundColor3 = Config.Accent
                
                local SliderKnob = CreateRoundedFrame(SliderTrack,
                    UDim2.new(0, 12, 0, 12),
                    UDim2.new((default - min) / (max - min), -6, 0.5, -6)
                )
                SliderKnob.BackgroundColor3 = Config.Text
                CreateStroke(SliderKnob, Config.Accent, 2)
                
                local function UpdateSlider(value)
                    value = math.clamp(value, min, max)
                    FengY3.flags[flag] = value
                    local percent = (value - min) / (max - min)
                    
                    SliderValue.Text = tostring(math.floor(value))
                    Services.TweenService:Create(SliderFill, TweenInfo.new(0.1), {
                        Size = UDim2.new(percent, 0, 1, 0)
                    }):Play()
                    Services.TweenService:Create(SliderKnob, TweenInfo.new(0.1), {
                        Position = UDim2.new(percent, -6, 0.5, -6)
                    }):Play()
                    
                    if callback then
                        callback(value)
                    end
                end
                
                local dragging = false
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local percent = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                        UpdateSlider(min + (max - min) * percent)
                    end
                end)
                
                Services.UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                Services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                        UpdateSlider(min + (max - min) * math.clamp(percent, 0, 1))
                    end
                end)
                
                UpdateSlider(default)
                
                return {
                    SetValue = function(_, value)
                        UpdateSlider(value)
                    end,
                    GetValue = function()
                        return FengY3.flags[flag]
                    end
                }
            end
            
            function SectionObject:Dropdown(text, flag, options, callback)
                options = options or {}
                FengY3.flags[flag] = options[1]
                
                local Dropdown = CreateRoundedFrame(SectionContent,
                    UDim2.new(1, 0, 0, 35)
                )
                Dropdown.BackgroundColor3 = Config.Secondary
                
                local DropdownLabel = CreateLabel(Dropdown, text, Config.BodyFont, Config.BodySize)
                DropdownLabel.Size = UDim2.new(0.7, 0, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                
                local DropdownButton = CreateRoundedFrame(Dropdown,
                    UDim2.new(0, 100, 0, 25),
                    UDim2.new(1, -110, 0.5, -12.5)
                )
                DropdownButton.BackgroundColor3 = Config.Primary
                
                local DropdownText = CreateLabel(DropdownButton, options[1] or "Select", Config.BodyFont, Config.SmallSize)
                DropdownText.Size = UDim2.new(1, -25, 1, 0)
                DropdownText.Position = UDim2.new(0, 5, 0, 0)
                
                local DropdownArrow = CreateLabel(DropdownButton, "▼", Config.BodyFont, Config.SmallSize)
                DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
                DropdownArrow.TextXAlignment = Enum.TextXAlignment.Center
                
                local DropdownList = CreateRoundedFrame(SectionContent,
                    UDim2.new(1, 0, 0, 0)
                )
                DropdownList.BackgroundColor3 = Config.Primary
                DropdownList.Visible = false
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropdownList
                
                local function UpdateDropdown(value)
                    FengY3.flags[flag] = value
                    DropdownText.Text = value
                    DropdownList.Visible = false
                    Services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                        Rotation = 0
                    }):Play()
                    if callback then
                        callback(value)
                    end
                end
                
                local function ToggleDropdown()
                    local visible = not DropdownList.Visible
                    DropdownList.Visible = visible
                    Services.TweenService:Create(DropdownArrow, TweenInfo.new(0.2), {
                        Rotation = visible and 180 or 0
                    }):Play()
                    
                    if visible then
                        for _, option in pairs(options) do
                            local OptionButton = CreateRoundedFrame(DropdownList,
                                UDim2.new(1, 0, 0, 25)
                            )
                            OptionButton.BackgroundColor3 = Config.Secondary
                            
                            local OptionText = CreateLabel(OptionButton, option, Config.BodyFont, Config.SmallSize)
                            OptionText.Size = UDim2.new(1, -10, 1, 0)
                            OptionText.Position = UDim2.new(0, 5, 0, 0)
                            
                            OptionButton.MouseButton1Click:Connect(function()
                                self:Ripple(OptionButton)
                                UpdateDropdown(option)
                            end)
                        end
                        
                        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            DropdownList.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
                        end)
                    end
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    self:Ripple(DropdownButton)
                    ToggleDropdown()
                end)
                
                return {
                    SetOptions = function(_, newOptions)
                        options = newOptions
                        UpdateDropdown(options[1] or "Select")
                    end,
                    GetValue = function()
                        return FengY3.flags[flag]
                    end
                }
            end
            
            function SectionObject:Label(text)
                local Label = CreateRoundedFrame(SectionContent,
                    UDim2.new(1, 0, 0, 25)
                )
                Label.BackgroundColor3 = Config.Secondary
                
                local LabelText = CreateLabel(Label, text, Config.BodyFont, Config.BodySize)
                LabelText.Size = UDim2.new(1, -10, 1, 0)
                LabelText.Position = UDim2.new(0, 5, 0, 0)
                LabelText.TextXAlignment = Enum.TextXAlignment.Center
                
                return Label
            end
            
            table.insert(Tab.Sections, SectionObject)
            return SectionObject
        end
        
        return TabObject
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    function Window:Toggle()
        Main.Visible = not Main.Visible
    end
    
    return Window
end

-- Documentation and examples
FengY3.Documentation = {
    Introduction = [[
FengY3 UI Library v2.0
A modern, lightweight UI library for Roblox

Features:
• Clean and modern design
• Full theming support
• Smooth animations
• Easy to use API
• Comprehensive documentation
    ]],
    
    QuickStart = [[
-- Basic usage example
local FengY3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/FengY3/main/UI.lua"))()

local Window = FengY3:CreateUI("My Script", "Dark")

local MainTab = Window:Tab("Main")
local MainSection = MainTab:Section("Features")

MainSection:Button("Click Me", function()
    print("Button clicked!")
end)

local Toggle = MainSection:Toggle("Enable Feature", "feature_enabled", false, function(state)
    print("Feature enabled:", state)
end)

local Slider = MainSection:Slider("Volume", "volume", 0, 100, 50, function(value)
    print("Volume set to:", value)
end)

local Dropdown = MainSection:Dropdown("Options", "selected_option", {"Option 1", "Option 2", "Option 3"}, function(option)
    print("Selected:", option)
end)
    ]],
    
    Themes = [[
Available themes:
• Dark (default)
• Light
• Purple
• Green

Usage:
FengY3:CreateUI("My Script", "Purple")
    ]],
    
    API = [[
Window Methods:
• Window:Tab(name) - Create a new tab
• Window:Destroy() - Destroy the UI
• Window:Toggle() - Toggle UI visibility

Tab Methods:
• Tab:Section(title) - Create a section

Section Methods:
• Section:Button(text, callback) - Create a button
• Section:Toggle(text, flag, default, callback) - Create a toggle
• Section:Slider(text, flag, min, max, default, callback) - Create a slider
• Section:Dropdown(text, flag, options, callback) - Create a dropdown
• Section:Label(text) - Create a label
    ]]
}

-- Export public API
FengY3.CreateWindow = FengY3.CreateUI
FengY3.GetConfig = function() return Config end
FengY3.GetFlags = function() return FengY3.flags end
FengY3.GetThemes = function() return FengY3.themes end

return FengY3