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
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

-- iOS Style Configuration
local config = {
    -- iOS 15+ 主色调
    MainColor = Color3.fromRGB(242, 242, 247), -- iOS系统背景色
    TabColor = Color3.fromRGB(255, 255, 255), -- 白色背景
    Bg_Color = Color3.fromRGB(255, 255, 255), -- 纯白背景
    Zy_Color = Color3.fromRGB(248, 248, 248), -- 次要背景色
    Button_Color = Color3.fromRGB(0, 122, 255), -- iOS蓝色
    Textbox_Color = Color3.fromRGB(248, 248, 248), -- 浅灰色
    Dropdown_Color = Color3.fromRGB(248, 248, 248), -- 浅灰色
    Keybind_Color = Color3.fromRGB(248, 248, 248), -- 浅灰色
    Label_Color = Color3.fromRGB(248, 248, 248), -- 浅灰色
    Slider_Color = Color3.fromRGB(248, 248, 248), -- 浅灰色
    SliderBar_Color = Color3.fromRGB(0, 122, 255), -- iOS蓝色
    Toggle_Color = Color3.fromRGB(248, 248, 248), -- 浅灰色
    Toggle_Off = Color3.fromRGB(229, 229, 234), -- iOS关闭状态灰色
    Toggle_On = Color3.fromRGB(0, 122, 255), -- iOS蓝色
    AccentColor = Color3.fromRGB(0, 122, 255), -- iOS蓝色
    TextColor = Color3.fromRGB(0, 0, 0), -- 黑色文字
    SecondaryTextColor = Color3.fromRGB(142, 142, 147), -- iOS次要文字颜色
    GlowColor = Color3.fromRGB(0, 122, 255), -- iOS蓝色
    
    -- iOS毛玻璃效果颜色
    DeepSpaceColor = Color3.fromRGB(242, 242, 247),
    NebulaColor1 = Color3.fromRGB(255, 255, 255),
    NebulaColor2 = Color3.fromRGB(248, 248, 248),
    AccentGlow = Color3.fromRGB(0, 122, 255),
    ElementColor = Color3.fromRGB(255, 255, 255),
    ElementTransparency = 0.1,
    GlassEffect = Color3.fromRGB(255, 255, 255),
    
    -- iOS特定颜色
    iOS_Blue = Color3.fromRGB(0, 122, 255),
    iOS_Green = Color3.fromRGB(52, 199, 89),
    iOS_Red = Color3.fromRGB(255, 59, 48),
    iOS_Orange = Color3.fromRGB(255, 149, 0),
    iOS_Purple = Color3.fromRGB(175, 82, 222),
    iOS_Yellow = Color3.fromRGB(255, 204, 0),
    iOS_Gray1 = Color3.fromRGB(142, 142, 147),
    iOS_Gray2 = Color3.fromRGB(174, 174, 178),
    iOS_Gray3 = Color3.fromRGB(199, 199, 204),
    iOS_Gray4 = Color3.fromRGB(209, 209, 214),
    iOS_Gray5 = Color3.fromRGB(229, 229, 234),
    iOS_Gray6 = Color3.fromRGB(242, 242, 247),
}

-- 移除霓虹效果，替换为iOS简约效果
local function createiOSHoverEffect(object, property, isText)
    local originalColor = object[property]
    local hoverConnection
    
    hoverConnection = object.MouseEnter:Connect(function()
        services.TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            [property] = isText and config.iOS_Blue or Color3.fromRGB(
                math.clamp(originalColor.R * 255 * 0.9, 0, 255),
                math.clamp(originalColor.G * 255 * 0.9, 0, 255),
                math.clamp(originalColor.B * 255 * 0.9, 0, 255)
            )
        }):Play()
    end)
    
    object.MouseLeave:Connect(function()
        services.TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            [property] = originalColor
        }):Play()
    end)
    
    return hoverConnection
end

-- iOS简约动画效果
local function createiOSPulse(object, scale)
    scale = scale or 0.95
    services.TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(object.Size.X.Scale * scale, object.Size.X.Offset * scale, object.Size.Y.Scale * scale, object.Size.Y.Offset * scale)
    }):Play()
    
    task.wait(0.1)
    
    services.TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = object.Size
    }):Play()
end

-- iOS毛玻璃背景效果
local function createiOSBlurBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "iOSBackground"
    background.BackgroundColor3 = config.MainColor
    background.BackgroundTransparency = 0.1
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.ZIndex = -100
    
    -- iOS大圆角
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 16)
    backgroundCorner.Parent = background
    
    -- iOS阴影效果
    local shadow = Instance.new("UIStroke")
    shadow.Parent = background
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Thickness = 0.5
    shadow.Transparency = 0.8
    
    background.Parent = parent
    
    return background
end

-- iOS简约图标动画
local function createiOSIconAnimation(icon, duration)
    duration = duration or 0.3
    
    services.TweenService:Create(icon, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = 180,
        Size = UDim2.new(0, icon.Size.X.Offset * 1.1, 0, icon.Size.Y.Offset * 1.1)
    }):Play()
    
    task.wait(duration/2)
    
    services.TweenService:Create(icon, TweenInfo.new(duration/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = 360,
        Size = icon.Size
    }):Play()
    
    task.wait(duration/2)
    
    icon.Rotation = 0
end

-- iOS简约切换效果
local function createiOSToggleAnimation(object, toggled)
    if toggled then
        services.TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = config.iOS_Blue
        }):Play()
    else
        services.TweenService:Create(object, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = config.Toggle_Off
        }):Play()
    end
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
    
    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { 
            ImageTransparency = 0,
            Size = UDim2.new(0, 25, 0, 25)
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
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { 
        ImageTransparency = 0.5,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
    services.TweenService:Create(new[1], tweenInfo, { 
        ImageTransparency = 0,
        Size = UDim2.new(0, 25, 0, 25)
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.5,
        TextColor3 = config.SecondaryTextColor
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

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local FengYu = Instance.new("ScreenGui")
FengYu.Name = "iOSUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 450, 0, 280)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

-- iOS毛玻璃背景
createiOSBlurBackground(Main)

-- iOS大圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

-- iOS边框
local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(230, 230, 230)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.3

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = 0.1
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.ZIndex = 2

-- iOS标题栏圆角
local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 20, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.SourceSansSemibold
TitleText.Text = "iOS UI"
TitleText.TextColor3 = config.TextColor
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 0

local TagContainer = Instance.new("Frame")
TagContainer.Name = "TagContainer"
TagContainer.Parent = TitleBar
TagContainer.BackgroundTransparency = 1
TagContainer.Position = UDim2.new(0, 0, 0, 8)
TagContainer.Size = UDim2.new(0, 0, 1, -16)
TagContainer.ZIndex = 5

local TagLayout = Instance.new("UIListLayout")
TagLayout.Parent = TagContainer
TagLayout.FillDirection = Enum.FillDirection.Horizontal
TagLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TagLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TagLayout.SortOrder = Enum.SortOrder.LayoutOrder
TagLayout.Padding = UDim.new(0, 5)

local function UpdateTagContainerPosition()
    local textSize = game:GetService("TextService"):GetTextSize(
        TitleText.Text, 
        18,
        TitleText.Font, 
        Vector2.new(10000, TitleText.AbsoluteSize.Y)
    )
    
    TagContainer.Position = UDim2.new(0, textSize.X + 25, 0, 8)
end

TitleText:GetPropertyChangedSignal("Text"):Connect(function()
    UpdateTagContainerPosition()
end)

UpdateTagContainerPosition()

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.SourceSansSemibold
CloseButton.Text = "×"
CloseButton.TextColor3 = config.SecondaryTextColor
CloseButton.TextSize = 20
CloseButton.ZIndex = 10
CloseButton.TextTransparency = 0

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

createiOSHoverEffect(CloseButton, "TextColor3", true)

CloseButton.MouseButton1Click:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = config.iOS_Red
    }):Play()
    
    services.TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.3), {
        TextTransparency = 1
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.3), {
        TextTransparency = 1
    }):Play()
    
    task.wait(0.3)
    FengYu:Destroy()
end)

local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.iOS_Blue
Open.BackgroundTransparency = 0.1
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 50, 0, 50)
Open.Active = true
Open.Draggable = true
Open.Image = ""
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 1

-- iOS圆形按钮
local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = Open

local OpenLabel = Instance.new("TextLabel")
OpenLabel.Name = "OpenLabel"
OpenLabel.Parent = Open
OpenLabel.BackgroundTransparency = 1
OpenLabel.Size = UDim2.new(1, 0, 1, 0)
OpenLabel.Font = Enum.Font.SourceSansSemibold
OpenLabel.Text = "≡"
OpenLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenLabel.TextSize = 24

createiOSHoverEffect(Open, "BackgroundTransparency", false)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playEntranceAnimation()
    end
    createiOSIconAnimation(Open, 0.3)
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
        createiOSIconAnimation(Open, 0.3)
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 50)
TabMain.Size = UDim2.new(0, 360, 0, 230)
TabMain.Visible = false

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 0.1
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 45)
Side.Size = UDim2.new(0, 90, 0, 235)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 16)
SideCorner.Parent = Side

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 5)
TabBtns.Size = UDim2.new(0, 90, 0, 225)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None
TabBtns.Visible = false

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

local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    Side.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    
    TabMain.Visible = false
    TabBtns.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 450, 0, 280)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.3
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(Side, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
    
    task.wait(0.2)
    
    TabMain.Visible = true
    TabBtns.Visible = true
end

task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

task.spawn(function()
    local matrixEffect = Instance.new("UIGradient")
    matrixEffect.Rotation = 90
    matrixEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    matrixEffect.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.iOS_Blue),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 170, 255))
    })
    matrixEffect.Parent = TitleText
    
    while TitleText and TitleText.Parent do
        task.wait(0.1)
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

    local scriptName = name or "iOS UI"
    TitleText.Text = scriptName
    
    local window = {
    tags = {},
    tagObjects = {},
    tagCount = 0,
    maxTags = 3,
    }
    
    function window:AddTag(text, bgColor, textColor, useiOSEffect)
    if self.tagCount >= self.maxTags then
        return nil
    end
    
    bgColor = bgColor or config.iOS_Gray5
    textColor = textColor or config.TextColor
    useiOSEffect = useiOSEffect or false
    
    local Tag = Instance.new("TextLabel")
    Tag.Name = "Tag_" .. text
    Tag.Parent = TagContainer
    Tag.BackgroundColor3 = bgColor
    Tag.BackgroundTransparency = 0.1
    Tag.Text = text
    Tag.Font = Enum.Font.SourceSansSemibold
    Tag.TextColor3 = textColor
    Tag.TextSize = 11
    Tag.TextWrapped = true
    Tag.Size = UDim2.new(0, 50, 0, 22)
    Tag.ZIndex = 6
    
    local TagCorner = Instance.new("UICorner")
    TagCorner.CornerRadius = UDim.new(0, 10)
    TagCorner.Parent = Tag
    
    local textSize = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.SourceSansSemibold, Vector2.new(200, 22))
    Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 22)
    
    local tagObj = {
        Instance = Tag,
        Text = text,
        Color = bgColor,
        TextColor = textColor,
        UseiOSEffect = false,
        
        Destroy = function()
            Tag:Destroy()
        end,
        
        Update = function(newText, newBgColor, newTextColor, newUseiOSEffect)
            if newText then
                Tag.Text = newText
                tagObj.Text = newText
                local textSize = game:GetService("TextService"):GetTextSize(newText, 11, Enum.Font.SourceSansSemibold, Vector2.new(200, 22))
                Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 22)
            end
            
            if newBgColor then
                tagObj.Color = newBgColor
                if not tagObj.UseiOSEffect then
                    Tag.BackgroundColor3 = newBgColor
                end
            end
            
            if newTextColor then
                Tag.TextColor3 = newTextColor
                tagObj.TextColor = newTextColor
            end
            
            if newUseiOSEffect ~= nil then
                tagObj:SetiOSEffect(newUseiOSEffect)
            end
            
            UpdateTagContainerPosition()
        end,
        
        SetiOSEffect = function(selfObj, enabled)
            selfObj.UseiOSEffect = enabled
            
            if enabled then
                Tag.BackgroundColor3 = config.iOS_Blue
                Tag.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                Tag.BackgroundColor3 = selfObj.Color
                Tag.TextColor3 = selfObj.TextColor
            end
        end,
        
        SetColor = function(selfObj, newColor)
            selfObj.Color = newColor
            
            if not selfObj.UseiOSEffect then
                Tag.BackgroundColor3 = newColor
            else
            end
        end
    }
    
    if useiOSEffect then
        tagObj:SetiOSEffect(true)
    else
        Tag.BackgroundColor3 = tagObj.Color
    end
    
    table.insert(self.tags, Tag)
    table.insert(self.tagObjects, tagObj)
    self.tagCount = self.tagCount + 1
    
    UpdateTagContainerPosition()
    
    return tagObj
end

function window:UpdateTag(index, text, bgColor, textColor, useiOSEffect)
    if index < 1 or index > #self.tagObjects then return end
    
    local tagObj = self.tagObjects[index]
    if not tagObj or not tagObj.Instance or not tagObj.Instance.Parent then return end
    
    local Tag = tagObj.Instance
    
    if text then
        Tag.Text = text
        tagObj.Text = text
        local textSize = game:GetService("TextService"):GetTextSize(text, 11, Enum.Font.SourceSansSemibold, Vector2.new(200, 22))
        Tag.Size = UDim2.new(0, math.clamp(textSize.X + 15, 40, 80), 0, 22)
    end
    
    if bgColor then
        tagObj.Color = bgColor
        if not tagObj.UseiOSEffect then
            Tag.BackgroundColor3 = bgColor
        end
    end
    
    if textColor then
        Tag.TextColor3 = textColor
        tagObj.TextColor = textColor
    end
    
    if useiOSEffect ~= nil then
        tagObj:SetiOSEffect(useiOSEffect)
    end
    
    UpdateTagContainerPosition()
end
    
    function window:ClearTags()
    for i = #self.tagObjects, 1, -1 do
        self:RemoveTag(i)
    end
    
        self.tagCount = 0
    end
    
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1
        
        local Tab = Instance.new("ScrollingFrame")
        local TabIco = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabBtn = Instance.new("TextButton")
        local TabL = Instance.new("UIListLayout")
        local TabContainer = Instance.new("Frame")
        
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 0
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabContainer.Name = "TabContainer"
        TabContainer.Parent = Tab
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        
        if windowCount == 2 then
            TabContainer.Size = UDim2.new(1, 0, 1, 0)
            
            local LeftContainer = Instance.new("ScrollingFrame")
            LeftContainer.Name = "LeftContainer"
            LeftContainer.Parent = TabContainer
            LeftContainer.BackgroundTransparency = 1
            LeftContainer.Size = UDim2.new(0.48, -2, 1, 0)
            LeftContainer.Position = UDim2.new(0, 2, 0, 0)
            LeftContainer.ScrollBarThickness = 0
            LeftContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            LeftContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            LeftContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local LeftLayout = Instance.new("UIListLayout")
            LeftLayout.Name = "LeftLayout"
            LeftLayout.Parent = LeftContainer
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 4)
            
            local RightContainer = Instance.new("ScrollingFrame")
            RightContainer.Name = "RightContainer"
            RightContainer.Parent = TabContainer
            RightContainer.BackgroundTransparency = 1
            RightContainer.Size = UDim2.new(0.50, -2, 1, 0)
            RightContainer.Position = UDim2.new(0.48, 0, 0, 0)
            RightContainer.ScrollBarThickness = 0
            RightContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            RightContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            RightContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Name = "RightLayout"
            RightLayout.Parent = RightContainer
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 4)
            
            local function updateLeftScrolling()
                LeftContainer.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
                LeftContainer.ScrollingEnabled = LeftLayout.AbsoluteContentSize.Y > LeftContainer.AbsoluteSize.Y
            end
            
            local function updateRightScrolling()
                RightContainer.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
                RightContainer.ScrollingEnabled = RightLayout.AbsoluteContentSize.Y > RightContainer.AbsoluteSize.Y
            end
            
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftScrolling)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightScrolling)
            
            task.spawn(function()
                task.wait(0.1)
                updateLeftScrolling()
                updateRightScrolling()
            end)
        end
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 22, 0, 22)
        
        if icon and type(icon) == "string" and icon:match("^%d+$") then
            TabIco.Image = "rbxassetid://" .. icon
        elseif icon and type(icon) == "string" then
            TabIco.Image = icon
        else
            TabIco.Image = ""
        end
        
        TabIco.ImageTransparency = 0.5
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.2, 0, 0, 0)
        TabText.Size = UDim2.new(0, 65, 0, 22)
        TabText.Font = Enum.Font.SourceSansSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 90, 0, 22)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = TabContainer
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
        if windowCount == 2 then
            TabL:Destroy()
            Tab.ScrollingEnabled = false
            Tab.CanvasSize = UDim2.new(0, 0, 1, 0)
            Tab.ScrollBarThickness = 0
        else
            Tab.ScrollBarThickness = 0
            setupSmoothScrolling(Tab, TabL)
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            switchTab({ TabIco, Tab })
        end)
        
        if FengUI.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        local tab = {}
        
        function tab.section(tab, name, windowPosition, TabVal)
            if type(windowPosition) == "boolean" then
                TabVal = windowPosition
                windowPosition = "Left"
            elseif not windowPosition or type(windowPosition) ~= "string" then
                windowPosition = "Left"
            end
            
            local TargetContainer
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    TargetContainer = TabContainer:FindFirstChild("LeftContainer")
                else
                    TargetContainer = TabContainer:FindFirstChild("RightContainer")
                end
            else
                TargetContainer = TabContainer
            end
            
            if not TargetContainer then
                TargetContainer = TabContainer
            end
            
            local Section = Instance.new("Frame")
            local SectionText = Instance.new("TextLabel")
            local SectionOpen = Instance.new("ImageLabel")
            local SectionOpened = Instance.new("ImageLabel")
            local SectionToggle = Instance.new("ImageButton")
            local Objs = Instance.new("Frame")
            local ObjsL = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = TargetContainer
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            
            local elementWidth = 330
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    elementWidth = 160
                else
                    elementWidth = 168
                end
            end
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0, 15, 0, 0)
            SectionText.Size = UDim2.new(1, -15, 0, 40)
            SectionText.Font = Enum.Font.SourceSansSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.TextColor
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = Section
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, 0, 0, 10)
            SectionOpen.Size = UDim2.new(0, 0, 0, 0)
            SectionOpen.Image = ""
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(1, 0, 1, 0)
            SectionOpened.Image = ""
            SectionOpened.ImageTransparency = 1
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 0, 0, 40)
            Objs.Size = UDim2.new(1, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = true
            if TabVal ~= nil then
                if type(TabVal) == "boolean" then
                    open = TabVal
                elseif TabVal == "false" or TabVal == "0" then
                    open = false
                elseif TabVal == "true" or TabVal == "1" then
                    open = true
                end
            end
            
            local function updateSectionHeight()
                Section.Size = UDim2.new(1, 0, 0, open and (40 + ObjsL.AbsoluteContentSize.Y + 8) or 40)
            end
            
            updateSectionHeight()
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and (40 + ObjsL.AbsoluteContentSize.Y + 8) or 40)
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
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
                BtnModule.Size = UDim2.new(0, elementWidth, 0, 40)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.1
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, elementWidth, 0, 40)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.SourceSansSemibold
                Btn.Text = text
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.TextSize = 15
                Btn.TextXAlignment = Enum.TextXAlignment.Center
                
                BtnC.CornerRadius = UDim.new(0, 10)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.05
                    }):Play()
                    createiOSPulse(Btn, 0.98)
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    callback()
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.2
                    }):Play()
                    createiOSPulse(Btn, 0.95)
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
            end
            
            function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, elementWidth, 0, sizeY or 120)
                
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or elementWidth - 20, elementWidth), 0, sizeY or 120)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 12)
                ImageCorner.Parent = ImageLabel
                
                local function setImage(source)
                    if type(source) == "table" then
                        if source.Type == "Player" then
                            local userId = source.UserId
                            if userId then
                                task.spawn(function()
                                    local success, result = pcall(function()
                                        return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                                    end)
                                    
                                    if success and result then
                                        ImageLabel.Image = result
                                    else
                                        ImageLabel.Image = "rbxassetid://0"
                                    end
                                end)
                            end
                        elseif source.Type == "Game" then
                            local placeId = source.PlaceId
                            if placeId then
                                task.spawn(function()
                                    local success1, gameInfo = pcall(function()
                                        local MarketplaceService = game:GetService("MarketplaceService")
                                        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
                                    end)
                                    
                                    if success1 and gameInfo and gameInfo.IconImageAssetId then
                                        ImageLabel.Image = "rbxassetid://" .. gameInfo.IconImageAssetId
                                        return
                                    end
                                    
                                    local success2, thumbnailUrl = pcall(function()
                                        local ThumbnailService = game:GetService("ThumbnailService")
                                        return ThumbnailService:GetGameThumbnailAsync(placeId)
                                    end)
                                    
                                    if success2 and thumbnailUrl then
                                        ImageLabel.Image = thumbnailUrl
                                        return
                                    end
                                    
                                    ImageLabel.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. placeId
                                end)
                            end
                        end
                    else
                        local imageId = tostring(source)
                        if imageId:match("^%d+$") then
                            ImageLabel.Image = "rbxassetid://" .. imageId
                        else
                            ImageLabel.Image = imageId
                        end
                    end
                end
                
                if imageSource then
                    setImage(imageSource)
                end
                
                local imageController = {}
                
                function imageController:SetImage(newSource)
                    setImage(newSource)
                end
                
                function imageController:SetPlayerAvatar(userId)
                    setImage({Type = "Player", UserId = userId})
                end
                
                function imageController:SetGameIcon(placeId)
                    setImage({Type = "Game", PlaceId = placeId})
                end
                
                function imageController:SetLocalPlayerAvatar()
                    local localPlayer = game.Players.LocalPlayer
                    if localPlayer then
                        setImage({Type = "Player", UserId = localPlayer.UserId})
                    end
                end
                
                function imageController:Destroy()
                    ImageModule:Destroy()
                end
                
                imageController.Instance = ImageLabel
                imageController.Module = ImageModule
                
                return imageController
            end
            
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                local TextLabel = Instance.new("TextLabel")
                local LabelC = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, elementWidth, 0, 30)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.1
                TextLabel.Size = UDim2.new(0, elementWidth, 0, 30)
                TextLabel.Font = Enum.Font.SourceSansSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.TextColor
                TextLabel.TextSize = 14
                
                LabelC.CornerRadius = UDim.new(0, 8)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
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
                ToggleModule.Size = UDim2.new(0, elementWidth, 0, 40)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.1
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, elementWidth, 0, 40)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.SourceSansSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 15
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 10)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                local togglePosition = 0.85
                if windowCount == 2 then
                    togglePosition = 0.78
                end
                
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = config.Toggle_Off
                ToggleDisable.BackgroundTransparency = 0.1
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(togglePosition, 0, 0.25, 0)
                ToggleDisable.Size = UDim2.new(0, 50, 0, 28)
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 255, 255)
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 24)
                ToggleSwitch.Position = UDim2.new(0, enabled and 22 or 2, 0, 2)
                
                ToggleSwitchC.CornerRadius = UDim.new(1, 0)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(1, 0)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.05,
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1,
                    }):Play()
                end)
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengUI.flags[flag]
                        end
                        if FengUI.flags[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, state and 22 or 2, 0, 2),
                        }):Play()
                        
                        services.TweenService:Create(ToggleDisable, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = state and config.iOS_Green or config.Toggle_Off
                        }):Play()
                        
                        FengUI.flags[flag] = state
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
                KeybindModule.Size = UDim2.new(0, elementWidth, 0, 40)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.1
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, elementWidth, 0, 40)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.SourceSansSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 15
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBtnC.CornerRadius = UDim.new(0, 10)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                local keybindPosition = 0.72
                if windowCount == 2 then
                    keybindPosition = 0.64
                end
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(keybindPosition, 0, 0.2, 0)
                KeybindValue.Size = UDim2.new(0, 70, 0, 24)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.SourceSans
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 13
                
                KeybindValueC.CornerRadius = UDim.new(0, 8)
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
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.05
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
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
                    
                    createiOSPulse(KeybindValue, 0.95)
                end)
                
                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 24)
                end)
                
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 24)
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
                local TextboxBackL = Instance.new("UIListLayout")
                local TextboxBackP = Instance.new("UIPadding")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, elementWidth, 0, 40)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.1
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, elementWidth, 0, 40)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.SourceSansSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 15
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 10)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                local textboxPosition = 0.45
                if windowCount == 2 then
                    textboxPosition = 0.36
                end
                
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(textboxPosition, 0, 0.2, 0)
                BoxBG.Size = UDim2.new(0, 90, 0, 24)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.SourceSans
                BoxBG.Text = ""
                
                BoxBGC.CornerRadius = UDim.new(0, 8)
                BoxBGC.Name = "BoxBGC"
                BoxBGC.Parent = BoxBG
                
                TextBox.Parent = BoxBG
                TextBox.BackgroundTransparency = 1
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Font = Enum.Font.SourceSans
                TextBox.Text = default
                TextBox.TextColor3 = config.TextColor
                TextBox.TextSize = 13
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
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.05
                    }):Play()
                end)
                
                TextboxBack.MouseLeave:Connect(function()
                    services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    FengUI.flags[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)
                
                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 24)
                end)
                
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 24)
            end

            function section.ColorPicker(section, text, flag, defaultColor, callback)
                callback = callback or function() end
                defaultColor = defaultColor or Color3.fromRGB(0, 122, 255)
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                FengUI.flags[flag] = defaultColor
                
                local elementWidth = 330
                if windowCount == 2 then
                    elementWidth = 160
                end
                
                local ColorPickerModule = Instance.new("Frame")
                local ColorPickerBtn = Instance.new("TextButton")
                local ColorPickerBtnC = Instance.new("UICorner")
                local ColorPreview = Instance.new("Frame")
                local ColorPreviewC = Instance.new("UICorner")
                local ColorPickerL = Instance.new("UIListLayout")
                local ColorPickerP = Instance.new("UIPadding")
                
                ColorPickerModule.Name = "ColorPickerModule"
                ColorPickerModule.Parent = Objs
                ColorPickerModule.BackgroundTransparency = 1
                ColorPickerModule.BorderSizePixel = 0
                ColorPickerModule.Size = UDim2.new(0, elementWidth, 0, 40)
                
                ColorPickerBtn.Name = "ColorPickerBtn"
                ColorPickerBtn.Parent = ColorPickerModule
                ColorPickerBtn.BackgroundColor3 = config.Button_Color
                ColorPickerBtn.BackgroundTransparency = 0.1
                ColorPickerBtn.BorderSizePixel = 0
                ColorPickerBtn.Size = UDim2.new(0, elementWidth, 0, 40)
                ColorPickerBtn.AutoButtonColor = false
                ColorPickerBtn.Font = Enum.Font.SourceSansSemibold
                ColorPickerBtn.Text = "   " .. text
                ColorPickerBtn.TextColor3 = config.TextColor
                ColorPickerBtn.TextSize = 15
                ColorPickerBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ColorPickerBtnC.CornerRadius = UDim.new(0, 10)
                ColorPickerBtnC.Name = "ColorPickerBtnC"
                ColorPickerBtnC.Parent = ColorPickerBtn
                
                local colorPickerPosition = 0.65
                if windowCount == 2 then
                    colorPickerPosition = 0.56
                end
                
                ColorPreview.Name = "ColorPreview"
                ColorPreview.Parent = ColorPickerBtn
                ColorPreview.BackgroundColor3 = defaultColor
                ColorPreview.BorderSizePixel = 0
                ColorPreview.Position = UDim2.new(colorPickerPosition, 0, 0.2, 0)
                ColorPreview.Size = UDim2.new(0, 40, 0, 24)
                
                ColorPreviewC.CornerRadius = UDim.new(0, 8)
                ColorPreviewC.Name = "ColorPreviewC"
                ColorPreviewC.Parent = ColorPreview
                
                ColorPickerL.Name = "ColorPickerL"
                ColorPickerL.Parent = ColorPickerBtn
                ColorPickerL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                ColorPickerL.SortOrder = Enum.SortOrder.LayoutOrder
                ColorPickerL.VerticalAlignment = Enum.VerticalAlignment.Center
                
                ColorPickerP.Name = "ColorPickerP"
                ColorPickerP.Parent = ColorPickerBtn
                ColorPickerP.PaddingRight = UDim.new(0, 8)
                
                local ColorPickerPopup = Instance.new("Frame")
                ColorPickerPopup.Name = "ColorPickerPopup"
                ColorPickerPopup.Parent = Main
                ColorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
                ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ColorPickerPopup.BackgroundTransparency = 0.1
                ColorPickerPopup.BorderSizePixel = 0
                ColorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                ColorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
                ColorPickerPopup.Visible = false
                ColorPickerPopup.ZIndex = 1000
                ColorPickerPopup.Active = false
                ColorPickerPopup.Draggable = false
                
                local PopupCorner = Instance.new("UICorner")
                PopupCorner.CornerRadius = UDim.new(0, 16)
                PopupCorner.Parent = ColorPickerPopup
                
                local PopupStroke = Instance.new("UIStroke")
                PopupStroke.Parent = ColorPickerPopup
                PopupStroke.Color = Color3.fromRGB(230, 230, 230)
                PopupStroke.Thickness = 1
                PopupStroke.Transparency = 0.3
                
                local PopupTitle = Instance.new("TextLabel")
                PopupTitle.Name = "PopupTitle"
                PopupTitle.Parent = ColorPickerPopup
                PopupTitle.BackgroundTransparency = 1
                PopupTitle.Position = UDim2.new(0, 10, 0, 8)
                PopupTitle.Size = UDim2.new(1, -20, 0, 24)
                PopupTitle.Font = Enum.Font.SourceSansSemibold
                PopupTitle.Text = text
                PopupTitle.TextColor3 = config.TextColor
                PopupTitle.TextSize = 16
                PopupTitle.TextXAlignment = Enum.TextXAlignment.Center
                PopupTitle.ZIndex = 1001
                
                local SatVibMap = Instance.new("ImageLabel")
                SatVibMap.Name = "SatVibMap"
                SatVibMap.Parent = ColorPickerPopup
                SatVibMap.Size = UDim2.fromOffset(150, 140)
                SatVibMap.Position = UDim2.fromOffset(15, 40)
                SatVibMap.Image = "rbxassetid://4155801252"
                SatVibMap.BackgroundColor3 = defaultColor
                SatVibMap.BackgroundTransparency = 0
                SatVibMap.ZIndex = 1001
                
                local SatVibCorner = Instance.new("UICorner")
                SatVibCorner.CornerRadius = UDim.new(0, 8)
                SatVibCorner.Parent = SatVibMap
                
                local SatCursor = Instance.new("ImageLabel")
                SatCursor.Name = "SatCursor"
                SatCursor.Size = UDim2.new(0, 16, 0, 16)
                SatCursor.ScaleType = Enum.ScaleType.Fit
                SatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SatCursor.BackgroundTransparency = 1
                SatCursor.Image = "http://www.roblox.com/asset/?id=4805639000"
                SatCursor.ZIndex = 1002
                SatCursor.Parent = SatVibMap
                
                local HueSlider = Instance.new("Frame")
                HueSlider.Name = "HueSlider"
                HueSlider.Parent = ColorPickerPopup
                HueSlider.Size = UDim2.fromOffset(14, 140)
                HueSlider.Position = UDim2.fromOffset(175, 40)
                HueSlider.ZIndex = 1001
                
                local HueSliderCorner = Instance.new("UICorner")
                HueSliderCorner.CornerRadius = UDim.new(1, 0)
                HueSliderCorner.Parent = HueSlider
                
                local SequenceTable = {}
                for Color = 0, 1, 0.1 do
                    table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
                end
                
                local HueSliderGradient = Instance.new("UIGradient")
                HueSliderGradient.Color = ColorSequence.new(SequenceTable)
                HueSliderGradient.Rotation = 90
                HueSliderGradient.Parent = HueSlider
                
                local HueDragHolder = Instance.new("Frame")
                HueDragHolder.Name = "HueDragHolder"
                HueDragHolder.Size = UDim2.new(1, 0, 1, -10)
                HueDragHolder.Position = UDim2.fromOffset(0, 5)
                HueDragHolder.BackgroundTransparency = 1
                HueDragHolder.Parent = HueSlider
                HueDragHolder.ZIndex = 1002
                
                local HueDrag = Instance.new("ImageLabel")
                HueDrag.Name = "HueDrag"
                HueDrag.Size = UDim2.fromOffset(14, 14)
                HueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
                HueDrag.Parent = HueDragHolder
                HueDrag.ImageColor3 = Color3.new(1, 1, 1)
                HueDrag.ZIndex = 1003
                
                local RGBInputs = Instance.new("Frame")
                RGBInputs.Name = "RGBInputs"
                RGBInputs.Parent = ColorPickerPopup
                RGBInputs.BackgroundTransparency = 1
                RGBInputs.Position = UDim2.new(0, 200, 0, 40)
                RGBInputs.Size = UDim2.new(0, 110, 0, 140)
                RGBInputs.ZIndex = 1001
                
                local function createRGBInput(label, position, defaultValue)
                    local InputFrame = Instance.new("Frame")
                    InputFrame.Name = label .. "Input"
                    InputFrame.Parent = RGBInputs
                    InputFrame.BackgroundTransparency = 1
                    InputFrame.Position = position
                    InputFrame.Size = UDim2.new(1, 0, 0, 28)
                    InputFrame.ZIndex = 1002
                    
                    local InputLabel = Instance.new("TextLabel")
                    InputLabel.Name = "Label"
                    InputLabel.Parent = InputFrame
                    InputLabel.BackgroundTransparency = 1
                    InputLabel.Position = UDim2.new(0, 0, 0, 0)
                    InputLabel.Size = UDim2.new(0, 25, 1, 0)
                    InputLabel.Font = Enum.Font.SourceSansSemibold
                    InputLabel.Text = label .. ":"
                    InputLabel.TextColor3 = config.TextColor
                    InputLabel.TextSize = 13
                    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                    InputLabel.ZIndex = 1002
                    
                    local InputBox = Instance.new("TextBox")
                    InputBox.Name = "InputBox"
                    InputBox.Parent = InputFrame
                    InputBox.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
                    InputBox.BackgroundTransparency = 0.1
                    InputBox.BorderSizePixel = 0
                    InputBox.Position = UDim2.new(0, 30, 0, 0)
                    InputBox.Size = UDim2.new(0, 75, 0, 28)
                    InputBox.Font = Enum.Font.SourceSans
                    InputBox.Text = tostring(defaultValue)
                    InputBox.TextColor3 = config.TextColor
                    InputBox.TextSize = 13
                    InputBox.PlaceholderColor3 = config.SecondaryTextColor
                    InputBox.ZIndex = 1002
                    
                    local InputCorner = Instance.new("UICorner")
                    InputCorner.CornerRadius = UDim.new(0, 8)
                    InputCorner.Parent = InputBox
                    
                    return InputBox
                end
                
                local RInput = createRGBInput("R", UDim2.new(0, 0, 0, 0), math.floor(defaultColor.R * 255))
                local GInput = createRGBInput("G", UDim2.new(0, 0, 0, 32), math.floor(defaultColor.G * 255))
                local BInput = createRGBInput("B", UDim2.new(0, 0, 0, 64), math.floor(defaultColor.B * 255))
                local HexInput = createRGBInput("Hex", UDim2.new(0, 0, 0, 96), "#" .. defaultColor:ToHex())
                
                local PreviewContainer = Instance.new("Frame")
                PreviewContainer.Name = "PreviewContainer"
                PreviewContainer.Parent = ColorPickerPopup
                PreviewContainer.BackgroundTransparency = 1
                PreviewContainer.Position = UDim2.new(0, 15, 0, 190)
                PreviewContainer.Size = UDim2.new(1, -30, 0, 30)
                PreviewContainer.ZIndex = 1001
                
                local OldColorFrame = Instance.new("Frame")
                OldColorFrame.Name = "OldColorFrame"
                OldColorFrame.Parent = PreviewContainer
                OldColorFrame.BackgroundColor3 = defaultColor
                OldColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
                OldColorFrame.Position = UDim2.new(0, 0, 0, 0)
                OldColorFrame.BackgroundTransparency = 0
                OldColorFrame.ZIndex = 1002
                
                local OldColorFrameCorner = Instance.new("UICorner")
                OldColorFrameCorner.CornerRadius = UDim.new(0, 8)
                OldColorFrameCorner.Parent = OldColorFrame
                
                local OldColorLabel = Instance.new("TextLabel")
                OldColorLabel.Name = "OldColorLabel"
                OldColorLabel.Parent = OldColorFrame
                OldColorLabel.BackgroundTransparency = 1
                OldColorLabel.Size = UDim2.new(1, 0, 1, 0)
                OldColorLabel.Font = Enum.Font.SourceSans
                OldColorLabel.Text = "原色"
                OldColorLabel.TextColor3 = Color3.new(1, 1, 1)
                OldColorLabel.TextSize = 12
                OldColorLabel.TextXAlignment = Enum.TextXAlignment.Center
                OldColorLabel.ZIndex = 1003
                
                local CurrentColorFrame = Instance.new("Frame")
                CurrentColorFrame.Name = "CurrentColorFrame"
                CurrentColorFrame.Parent = PreviewContainer
                CurrentColorFrame.BackgroundColor3 = defaultColor
                CurrentColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
                CurrentColorFrame.Position = UDim2.new(0.52, 0, 0, 0)
                CurrentColorFrame.BackgroundTransparency = 0
                CurrentColorFrame.ZIndex = 1002
                
                local CurrentColorFrameCorner = Instance.new("UICorner")
                CurrentColorFrameCorner.CornerRadius = UDim.new(0, 8)
                CurrentColorFrameCorner.Parent = CurrentColorFrame
                
                local CurrentColorLabel = Instance.new("TextLabel")
                CurrentColorLabel.Name = "CurrentColorLabel"
                CurrentColorLabel.Parent = CurrentColorFrame
                CurrentColorLabel.BackgroundTransparency = 1
                CurrentColorLabel.Size = UDim2.new(1, 0, 1, 0)
                CurrentColorLabel.Font = Enum.Font.SourceSans
                CurrentColorLabel.Text = "新色"
                CurrentColorLabel.TextColor3 = Color3.new(1, 1, 1)
                CurrentColorLabel.TextSize = 12
                CurrentColorLabel.TextXAlignment = Enum.TextXAlignment.Center
                CurrentColorLabel.ZIndex = 1003
                
                local ButtonContainer = Instance.new("Frame")
                ButtonContainer.Name = "ButtonContainer"
                ButtonContainer.Parent = ColorPickerPopup
                ButtonContainer.BackgroundTransparency = 1
                ButtonContainer.Position = UDim2.new(0, 15, 1, -40)
                ButtonContainer.Size = UDim2.new(1, -30, 0, 30)
                ButtonContainer.ZIndex = 1001
                
                local ConfirmBtn = Instance.new("TextButton")
                ConfirmBtn.Name = "ConfirmBtn"
                ConfirmBtn.Parent = ButtonContainer
                ConfirmBtn.BackgroundColor3 = config.iOS_Blue
                ConfirmBtn.BackgroundTransparency = 0.1
                ConfirmBtn.BorderSizePixel = 0
                ConfirmBtn.Position = UDim2.new(0, 0, 0, 0)
                ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
                ConfirmBtn.Font = Enum.Font.SourceSansSemibold
                ConfirmBtn.Text = "确认"
                ConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
                ConfirmBtn.TextSize = 14
                ConfirmBtn.AutoButtonColor = true
                ConfirmBtn.ZIndex = 1002
                ConfirmBtn.Modal = true
                
                local ConfirmCorner = Instance.new("UICorner")
                ConfirmCorner.CornerRadius = UDim.new(0, 10)
                ConfirmCorner.Parent = ConfirmBtn
                
                local CancelBtn = Instance.new("TextButton")
                CancelBtn.Name = "CancelBtn"
                CancelBtn.Parent = ButtonContainer
                CancelBtn.BackgroundColor3 = config.iOS_Gray5
                CancelBtn.BackgroundTransparency = 0.1
                CancelBtn.BorderSizePixel = 0
                CancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
                CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
                CancelBtn.Font = Enum.Font.SourceSansSemibold
                CancelBtn.Text = "取消"
                CancelBtn.TextColor3 = config.TextColor
                CancelBtn.TextSize = 14
                CancelBtn.AutoButtonColor = true
                CancelBtn.ZIndex = 1002
                CancelBtn.Modal = true
                
                local CancelCorner = Instance.new("UICorner")
                CancelCorner.CornerRadius = UDim.new(0, 10)
                CancelCorner.Parent = CancelBtn
                
                local CloseClickArea = Instance.new("TextButton")
                CloseClickArea.Name = "CloseClickArea"
                CloseClickArea.Parent = FengYu
                CloseClickArea.BackgroundTransparency = 1
                CloseClickArea.BorderSizePixel = 0
                CloseClickArea.Size = UDim2.new(1, 0, 1, 0)
                CloseClickArea.Text = ""
                CloseClickArea.Visible = false
                CloseClickArea.ZIndex = 99
                CloseClickArea.Modal = true
                
                local currentColor = defaultColor
                local currentHue, currentSat, currentVib = Color3.toHSV(defaultColor)
                
                local function updateDisplay()
                    SatVibMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                    
                    SatCursor.Position = UDim2.new(currentSat, 0, 1 - currentVib, 0)
                    HueDrag.Position = UDim2.new(0, 0, currentHue, -7)
                    
                    currentColor = Color3.fromHSV(currentHue, currentSat, currentVib)
                    CurrentColorFrame.BackgroundColor3 = currentColor
                    ColorPreview.BackgroundColor3 = currentColor
                    
                    local oldBrightness = (OldColorFrame.BackgroundColor3.R * 0.299 + OldColorFrame.BackgroundColor3.G * 0.587 + OldColorFrame.BackgroundColor3.B * 0.114)
                    OldColorLabel.TextColor3 = oldBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                    
                    local currentBrightness = (currentColor.R * 0.299 + currentColor.G * 0.587 + currentColor.B * 0.114)
                    CurrentColorLabel.TextColor3 = currentBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                    
                    local rgb = {
                        R = math.floor(currentColor.R * 255),
                        G = math.floor(currentColor.G * 255),
                        B = math.floor(currentColor.B * 255)
                    }
                    
                    HexInput.Text = "#" .. currentColor:ToHex()
                    RInput.Text = tostring(rgb.R)
                    GInput.Text = tostring(rgb.G)
                    BInput.Text = tostring(rgb.B)
                end
                
                local function setupInteraction()
                    local satVibDragging = false
                    
                    local function updateSatVib(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            satVibDragging = true
                            
                            local connection
                            connection = services.RunService.RenderStepped:Connect(function()
                                if not satVibDragging then
                                    connection:Disconnect()
                                    return
                                end
                                
                                local mouse = services.Players.LocalPlayer:GetMouse()
                                local minX = SatVibMap.AbsolutePosition.X
                                local maxX = minX + SatVibMap.AbsoluteSize.X
                                local mouseX = math.clamp(mouse.X, minX, maxX)
                                
                                local minY = SatVibMap.AbsolutePosition.Y
                                local maxY = minY + SatVibMap.AbsoluteSize.Y
                                local mouseY = math.clamp(mouse.Y, minY, maxY)
                                
                                currentSat = (mouseX - minX) / (maxX - minX)
                                currentVib = 1 - ((mouseY - minY) / (maxY - minY))
                                
                                updateDisplay()
                            end)
                            
                            services.UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                    satVibDragging = false
                                end
                            end)
                        end
                    end
                    
                    SatVibMap.InputBegan:Connect(updateSatVib)
                    SatCursor.InputBegan:Connect(updateSatVib)
                    
                    local hueDragging = false
                    
                    local function updateHue(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = true
                            
                            local connection
                            connection = services.RunService.RenderStepped:Connect(function()
                                if not hueDragging then
                                    connection:Disconnect()
                                    return
                                end
                                
                                local mouse = services.Players.LocalPlayer:GetMouse()
                                local minY = HueSlider.AbsolutePosition.Y
                                local maxY = minY + HueSlider.AbsoluteSize.Y
                                local mouseY = math.clamp(mouse.Y, minY, maxY)
                                
                                currentHue = ((mouseY - minY) / (maxY - minY))
                                
                                updateDisplay()
                            end)
                            
                            services.UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                    hueDragging = false
                                end
                            end)
                        end
                    end
                    
                    HueSlider.InputBegan:Connect(updateHue)
                    HueDragHolder.InputBegan:Connect(updateHue)
                    HueDrag.InputBegan:Connect(updateHue)
                end
                
                local function setupRGBInputs()
                    local function validateRGBInput(inputBox, maxValue)
                        inputBox.FocusLost:Connect(function(enterPressed)
                            local text = inputBox.Text
                            
                            if inputBox == HexInput then
                                local hex = text:gsub("#", "")
                                if hex:match("^[0-9A-Fa-f]+$") and #hex == 6 then
                                    local success, color = pcall(Color3.fromHex, hex)
                                    if success then
                                        currentHue, currentSat, currentVib = Color3.toHSV(color)
                                        updateDisplay()
                                        return
                                    end
                                end
                                inputBox.Text = "#" .. currentColor:ToHex()
                            else
                                local num = tonumber(text)
                                
                                if num then
                                    num = math.clamp(num, 0, maxValue)
                                    inputBox.Text = tostring(num)
                                    
                                    local r = tonumber(RInput.Text) or 255
                                    local g = tonumber(GInput.Text) or 255
                                    local b = tonumber(BInput.Text) or 255
                                    local color = Color3.fromRGB(r, g, b)
                                    currentHue, currentSat, currentVib = Color3.toHSV(color)
                                    updateDisplay()
                                else
                                    if inputBox == RInput then
                                        inputBox.Text = tostring(math.floor(currentColor.R * 255))
                                    elseif inputBox == GInput then
                                        inputBox.Text = tostring(math.floor(currentColor.G * 255))
                                    elseif inputBox == BInput then
                                        inputBox.Text = tostring(math.floor(currentColor.B * 255))
                                    end
                                end
                            end
                        end)
                    end
                
                    validateRGBInput(HexInput, 255)
                    validateRGBInput(RInput, 255)
                    validateRGBInput(GInput, 255)
                    validateRGBInput(BInput, 255)
                end
                
                ColorPickerBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.05
                    }):Play()
                end)
                
                ColorPickerBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ColorPickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                ConfirmBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ConfirmBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.05,
                        Size = UDim2.new(0.48, 2, 1.1, 0)
                    }):Play()
                end)
                
                ConfirmBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ConfirmBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1,
                        Size = UDim2.new(0.48, 0, 1, 0)
                    }):Play()
                end)
                
                CancelBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(CancelBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.05,
                        Size = UDim2.new(0.48, 2, 1.1, 0)
                    }):Play()
                end)
                
                CancelBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(CancelBtn, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1,
                        Size = UDim2.new(0.48, 0, 1, 0)
                    }):Play()
                end)
                
                updateDisplay()
                setupInteraction()
                setupRGBInputs()
                
                ColorPickerBtn.MouseButton1Click:Connect(function()
                    OldColorFrame.BackgroundColor3 = FengUI.flags[flag] or defaultColor
                    
                    ColorPickerPopup.Visible = true
                    CloseClickArea.Visible = true
                    
                    ColorPickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
                    ColorPickerPopup.BackgroundTransparency = 0.8
                    
                    services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                
                ConfirmBtn.MouseButton1Click:Connect(function()
                    FengUI.flags[flag] = currentColor
                    callback(currentColor)
                    
                    services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.8
                    }):Play()
                    
                    task.wait(0.2)
                    ColorPickerPopup.Visible = false
                    CloseClickArea.Visible = false
                end)
                
                CancelBtn.MouseButton1Click:Connect(function()
                    local originalColor = FengUI.flags[flag] or defaultColor
                    currentHue, currentSat, currentVib = Color3.toHSV(originalColor)
                    currentColor = originalColor
                    updateDisplay()
                    
                    services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.8
                    }):Play()
                    
                    task.wait(0.2)
                    ColorPickerPopup.Visible = false
                    CloseClickArea.Visible = false
                end)
                
                CloseClickArea.MouseButton1Click:Connect(function()
                    CancelBtn.MouseButton1Click:Fire()
                end)
                
                local funcs = {
                    SetColor = function(self, color)
                        if typeof(color) == "Color3" then
                            currentHue, currentSat, currentVib = Color3.toHSV(color)
                            currentColor = color
                            updateDisplay()
                            FengUI.flags[flag] = color
                            callback(color)
                        end
                    end,
                    
                    GetColor = function(self)
                        return FengUI.flags[flag] or defaultColor
                    end,
                    
                    Module = ColorPickerModule
                }
                
                return funcs
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
                SliderModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderModule.BackgroundTransparency = 1.000
                SliderModule.BorderSizePixel = 0
                SliderModule.Position = UDim2.new(0, 0, 0, 0)
                
                if windowCount == 2 then
                    SliderModule.Size = UDim2.new(0, elementWidth, 0, 56)
                else
                    SliderModule.Size = UDim2.new(0, elementWidth, 0, 40)
                end
                
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BackgroundTransparency = 0.1
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(1, 0, 1, 0)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.SourceSansSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = Color3.fromRGB(0, 0, 0)
                SliderBack.TextSize = 15.000
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                if windowCount == 2 then
                    SliderBack.TextYAlignment = Enum.TextYAlignment.Top
                    local padding = Instance.new("UIPadding")
                    padding.Parent = SliderBack
                    padding.PaddingTop = UDim.new(0, 4)
                end
                
                SliderBackC.CornerRadius = UDim.new(0, 10)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                if windowCount == 2 then
                    SliderBar.Name = "SliderBar"
                    SliderBar.Parent = SliderBack
                    SliderBar.AnchorPoint = Vector2.new(0, 0)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
                    SliderBar.BorderSizePixel = 0
                    SliderBar.Position = UDim2.new(0.03, 0, 0.45, 0)
                    SliderBar.Size = UDim2.new(0.65, 0, 0, 6)
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
                    
                    SliderValBG.Name = "SliderValBG"
                    SliderValBG.Parent = SliderBack
                    SliderValBG.BackgroundColor3 = config.Bg_Color
                    SliderValBG.BorderSizePixel = 0
                    SliderValBG.Position = UDim2.new(0.72, 0, 0.42, 0)
                    SliderValBG.Size = UDim2.new(0, 36, 0, 24)
                    SliderValBG.AutoButtonColor = false
                    SliderValBG.Font = Enum.Font.SourceSans
                    SliderValBG.Text = ""
                    SliderValBG.TextColor3 = Color3.fromRGB(0, 0, 0)
                    SliderValBG.TextSize = 14.000
                    
                    SliderValBGC.CornerRadius = UDim.new(0, 8)
                    SliderValBGC.Name = "SliderValBGC"
                    SliderValBGC.Parent = SliderValBG
                    
                    SliderBack.Text = "   " .. text
                else
                    local sliderBarPosition = 0.35
                    local sliderBarWidth = 120
                    local sliderValuePosition = 0.82
                    local minSliderPosition = 0.28
                    local addSliderPosition = 0.75
                    
                    SliderBar.Name = "SliderBar"
                    SliderBar.Parent = SliderBack
                    SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
                    SliderBar.BorderSizePixel = 0
                    SliderBar.Position = UDim2.new(sliderBarPosition, 0, 0.5, 0)
                    SliderBar.Size = UDim2.new(0, sliderBarWidth, 0, 6)
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
                    
                    SliderValBG.Name = "SliderValBG"
                    SliderValBG.Parent = SliderBack
                    SliderValBG.BackgroundColor3 = config.Bg_Color
                    SliderValBG.BorderSizePixel = 0
                    SliderValBG.Position = UDim2.new(sliderValuePosition, 0, 0.2, 0)
                    SliderValBG.Size = UDim2.new(0, 36, 0, 24)
                    SliderValBG.AutoButtonColor = false
                    SliderValBG.Font = Enum.Font.SourceSans
                    SliderValBG.Text = ""
                    SliderValBG.TextColor3 = Color3.fromRGB(0, 0, 0)
                    SliderValBG.TextSize = 14.000
                    
                    SliderValBGC.CornerRadius = UDim.new(0, 8)
                    SliderValBGC.Name = "SliderValBGC"
                    SliderValBGC.Parent = SliderValBG
                    
                    local MinSlider = Instance.new("TextButton")
                    MinSlider.Name = "MinSlider"
                    MinSlider.Parent = SliderBack
                    MinSlider.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
                    MinSlider.BackgroundTransparency = 0
                    MinSlider.BorderSizePixel = 0
                    MinSlider.Position = UDim2.new(minSliderPosition, 0, 0.25, 0)
                    MinSlider.Size = UDim2.new(0, 20, 0, 20)
                    MinSlider.Font = Enum.Font.SourceSans
                    MinSlider.Text = "-"
                    MinSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
                    MinSlider.TextSize = 16.000
                    MinSlider.TextWrapped = true
                    MinSlider.ZIndex = 2
                    
                    local MinSliderC = Instance.new("UICorner")
                    MinSliderC.CornerRadius = UDim.new(1, 0)
                    MinSliderC.Parent = MinSlider
                    
                    local AddSlider = Instance.new("TextButton")
                    AddSlider.Name = "AddSlider"
                    AddSlider.Parent = SliderBack
                    AddSlider.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
                    AddSlider.BackgroundTransparency = 0
                    AddSlider.BorderSizePixel = 0
                    AddSlider.Position = UDim2.new(addSliderPosition, 0, 0.25, 0)
                    AddSlider.Size = UDim2.new(0, 20, 0, 20)
                    AddSlider.Font = Enum.Font.SourceSans
                    AddSlider.Text = "+"
                    AddSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
                    AddSlider.TextSize = 16.000
                    AddSlider.TextWrapped = true
                    AddSlider.ZIndex = 2
                    
                    local AddSliderC = Instance.new("UICorner")
                    AddSliderC.CornerRadius = UDim.new(1, 0)
                    AddSliderC.Parent = AddSlider
                    
                    MinSlider.MouseButton1Click:Connect(function()
                        local currentValue = FengUI.flags[flag]
                        currentValue = math.clamp(currentValue - 1, min, max)
                        funcs:SetValue(currentValue)
                    end)
                    
                    AddSlider.MouseButton1Click:Connect(function()
                        local currentValue = FengUI.flags[flag]
                        currentValue = math.clamp(currentValue + 1, min, max)
                        funcs:SetValue(currentValue)
                    end)
                end
                
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderValue.BackgroundTransparency = 1.000
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.SourceSans
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = Color3.fromRGB(0, 0, 0)
                SliderValue.TextSize = 12.000
                
                if windowCount == 2 then
                    SliderValue.TextSize = 13
                    SliderValue.Font = Enum.Font.SourceSans
                end
                
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
                        
                        services.TweenService:Create(SliderPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
    FengUI.flags[flag] = nil
    
    local DropdownModule = Instance.new("Frame")
    local DropdownTop = Instance.new("TextButton")
    local DropdownTopC = Instance.new("UICorner")
    local DropdownOpenFrame = Instance.new("Frame")
    local DropdownOpenFrameC = Instance.new("UICorner")
    local DropdownOpen = Instance.new("TextButton")
    local DropdownText = Instance.new("TextBox")
    
    DropdownModule.Name = "DropdownModule"
    DropdownModule.Parent = Objs
    DropdownModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownModule.BackgroundTransparency = 1.000
    DropdownModule.BorderSizePixel = 0
    DropdownModule.ClipsDescendants = true
    DropdownModule.Position = UDim2.new(0, 0, 0, 0)
    DropdownModule.Size = UDim2.new(0, elementWidth, 0, 40)
    
    DropdownTop.Name = "DropdownTop"
    DropdownTop.Parent = DropdownModule
    DropdownTop.BackgroundColor3 = config.Dropdown_Color
    DropdownTop.BackgroundTransparency = 0.1
    DropdownTop.BorderSizePixel = 0
    DropdownTop.Size = UDim2.new(1, 0, 0, 40)
    DropdownTop.AutoButtonColor = false
    DropdownTop.Font = Enum.Font.SourceSansSemibold
    DropdownTop.Text = ""
    DropdownTop.TextColor3 = config.TextColor
    DropdownTop.TextSize = 15.000
    DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
    
    DropdownTopC.CornerRadius = UDim.new(0, 10)
    DropdownTopC.Name = "DropdownTopC"
    DropdownTopC.Parent = DropdownTop
    
    local BackgroundFill = Instance.new("Frame")
    BackgroundFill.Name = "BackgroundFill"
    BackgroundFill.Parent = DropdownTop
    BackgroundFill.BackgroundColor3 = config.Dropdown_Color
    BackgroundFill.BorderSizePixel = 0
    BackgroundFill.Position = UDim2.new(0.75, 0, 0, 0)
    BackgroundFill.Size = UDim2.new(0.25, 0, 1, 0)
    BackgroundFill.ZIndex = 0
    
    local dropdownFramePosition = 0.80
    local separatorPosition = 0.74
    if windowCount == 2 then
        dropdownFramePosition = 0.71
        separatorPosition = 0.65
    end
    
    DropdownOpenFrame.Name = "DropdownOpenFrame"
    DropdownOpenFrame.Parent = DropdownTop
    DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
    DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
    DropdownOpenFrame.BorderSizePixel = 0
    DropdownOpenFrame.Position = UDim2.new(dropdownFramePosition, 0, 0.5, 0)
    DropdownOpenFrame.Size = UDim2.new(0, 40, 0, 24)
    DropdownOpenFrame.ZIndex = 2
    
    DropdownOpenFrameC.CornerRadius = UDim.new(0, 8)
    DropdownOpenFrameC.Name = "DropdownOpenFrameC"
    DropdownOpenFrameC.Parent = DropdownOpenFrame
    
    DropdownOpen.Name = "DropdownOpen"
    DropdownOpen.Parent = DropdownOpenFrame
    DropdownOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownOpen.BackgroundTransparency = 1.000
    DropdownOpen.BorderSizePixel = 0
    DropdownOpen.Size = UDim2.new(1, 0, 1, 0)
    DropdownOpen.Font = Enum.Font.SourceSansSemibold
    DropdownOpen.Text = "选择"
    DropdownOpen.TextColor3 = config.TextColor
    DropdownOpen.TextSize = 12.000
    DropdownOpen.TextWrapped = true
    DropdownOpen.ZIndex = 3
    
    DropdownText.Name = "DropdownText"
    DropdownText.Parent = DropdownTop
    DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.BackgroundTransparency = 1.000
    DropdownText.BorderSizePixel = 0
    DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
    DropdownText.Size = UDim2.new(0, 230, 1, 0)
    DropdownText.Font = Enum.Font.SourceSansSemibold
    DropdownText.PlaceholderColor3 = config.SecondaryTextColor
    DropdownText.PlaceholderText = text
    DropdownText.Text = ""
    DropdownText.TextColor3 = config.TextColor
    DropdownText.TextSize = 15.000
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.ZIndex = 2
    
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Parent = DropdownTop
    Separator.BackgroundColor3 = Color3.fromRGB(229, 229, 234)
    Separator.BorderSizePixel = 0
    Separator.Position = UDim2.new(separatorPosition, 0, 0.2, 0)
    Separator.Size = UDim2.new(0, 1, 0, 24)
    Separator.ZIndex = 1
    
    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Name = "OptionsContainer"
    OptionsContainer.Parent = DropdownModule
    OptionsContainer.BackgroundTransparency = 1
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.Position = UDim2.new(0, 0, 0, 44)
    OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
    OptionsContainer.ClipsDescendants = true
    OptionsContainer.Visible = false
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Name = "OptionsLayout"
    OptionsLayout.Parent = OptionsContainer
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Padding = UDim.new(0, 4)
    
    local allOptions = {}
    local open = false
    
    local function updateDropdownHeight()
        if not open then 
            OptionsContainer.Visible = false
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 40)
            return 
        end
        
        OptionsContainer.Visible = true
        
        local visibleCount = 0
        for _, option in pairs(allOptions) do
            if option and option.Parent and option.Visible then
                visibleCount = visibleCount + 1
            end
        end
        
        if visibleCount == 0 then
            OptionsContainer.Size = UDim2.new(1, 0, 0, 30)
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 40 + 30)
        else
            local optionHeight = 28
            local padding = 4
            local totalOptionsHeight = (optionHeight + padding) * visibleCount
            OptionsContainer.Size = UDim2.new(1, 0, 0, totalOptionsHeight)
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 40 + totalOptionsHeight + 8)
        end
    end
    
    local function setAllVisible()
        for _, option in pairs(allOptions) do
            if option then
                option.Visible = true
            end
        end
        updateDropdownHeight()
    end
    
    local function searchDropdown(text)
        local visibleCount = 0
        
        for _, option in pairs(allOptions) do
            if option then
                if text == "" then
                    option.Visible = true
                else
                    option.Visible = option.Text:lower():match(text:lower()) ~= nil
                end
                
                if option.Visible then
                    visibleCount = visibleCount + 1
                end
            end
        end
        
        updateDropdownHeight()
    end
    
    local function toggleDropdown()
        open = not open
        DropdownOpen.Text = open and "取消" or "选择"
        
        if open then
            setAllVisible()
            DropdownText:CaptureFocus()
        end
        
        updateDropdownHeight()
        createiOSPulse(DropdownOpenFrame, 0.95)
    end
    
    DropdownOpen.MouseButton1Click:Connect(toggleDropdown)
    
    DropdownText.Focused:Connect(function()
        if not open then
            toggleDropdown()
        end
    end)
    
    DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
        if open then
            searchDropdown(DropdownText.Text)
        end
    end)
    
    OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if open then
            updateDropdownHeight()
        end
    end)
    
    local funcs = {}
    
    funcs.AddOption = function(self, optionText)
        local Option = Instance.new("TextButton")
        local OptionC = Instance.new("UICorner")
        
        Option.Name = "Option_" .. optionText
        Option.Parent = OptionsContainer
        Option.BackgroundColor3 = config.TabColor
        Option.BackgroundTransparency = 0.1
        Option.BorderSizePixel = 0
        Option.Size = UDim2.new(1, 0, 0, 28)
        Option.AutoButtonColor = false
        Option.Font = Enum.Font.SourceSans
        Option.Text = optionText
        Option.TextColor3 = config.TextColor
        Option.TextSize = 14.000
        Option.Visible = true
        Option.LayoutOrder = #allOptions + 1
        
        OptionC.CornerRadius = UDim.new(0, 8)
        OptionC.Name = "OptionC"
        OptionC.Parent = Option
        
        Option.MouseEnter:Connect(function()
            services.TweenService:Create(Option, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.05
            }):Play()
        end)
        
        Option.MouseLeave:Connect(function()
            services.TweenService:Create(Option, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        Option.MouseButton1Click:Connect(function()
            toggleDropdown()
            callback(Option.Text)
            DropdownText.Text = Option.Text
            FengUI.flags[flag] = Option.Text
            createiOSPulse(Option, 0.95)
        end)
        
        table.insert(allOptions, Option)
        
        if open then
            updateDropdownHeight()
        end
        
        return Option
    end
    
    funcs.RemoveOption = function(self, optionText)
        for i, option in pairs(allOptions) do
            if option and option.Text == optionText then
                option:Destroy()
                table.remove(allOptions, i)
                break
            end
        end
        if open then
            updateDropdownHeight()
        end
    end
    
    funcs.SetOptions = function(self, newOptions)
        for _, option in pairs(allOptions) do
            if option then
                option:Destroy()
            end
        end
        allOptions = {}
        
        for _, optionText in pairs(newOptions) do
            funcs:AddOption(optionText)
        end
        
        if open then
            updateDropdownHeight()
        end
    end
    
    funcs.GetSelected = function(self)
        return FengUI.flags[flag]
    end
    
    funcs.SetSelected = function(self, value)
        if value then
            for _, option in pairs(allOptions) do
                if option and option.Text == value then
                    DropdownText.Text = value
                    FengUI.flags[flag] = value
                    break
                end
            end
        else
            DropdownText.Text = ""
            FengUI.flags[flag] = nil
        end
    end
    
    funcs.Clear = function(self)
        for _, option in pairs(allOptions) do
            if option then
                option:Destroy()
            end
        end
        allOptions = {}
        DropdownText.Text = ""
        FengUI.flags[flag] = nil
        if open then
            updateDropdownHeight()
        end
    end
    
    funcs.Open = function(self)
        if not open then
            toggleDropdown()
        end
    end
    
    funcs.Close = function(self)
        if open then
            toggleDropdown()
        end
    end
    
    funcs:SetOptions(options)
    
    return funcs
end

            return section
        end

        return tab
    end
    
    function window:DualTab(name, icon)
        if type(icon) == "number" then
            icon = tostring(icon)
        end
        
        return window:Tab(name, icon, 2)
    end

    return window
end

FengUI.ColorPickers = {}

function FengUI:CreateColorPicker(options)
    local config = {
        title = options.title or "选择颜色",
        defaultColor = options.defaultColor or Color3.fromRGB(0, 122, 255),
        callback = options.callback or function(color) end,
        position = options.position or UDim2.new(0.5, 0, 0.5, 0),
        parent = options.parent or FengYu
    }
    
    local ColorPickerPopup = Instance.new("Frame")
    ColorPickerPopup.Name = "ColorPickerPopup"
    ColorPickerPopup.Parent = config.parent
    ColorPickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
    ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ColorPickerPopup.BackgroundTransparency = 0.1
    ColorPickerPopup.BorderSizePixel = 0
    ColorPickerPopup.Position = config.position
    ColorPickerPopup.Size = UDim2.new(0, 320, 0, 260)
    ColorPickerPopup.Visible = true
    ColorPickerPopup.ZIndex = 1000
    ColorPickerPopup.Active = true
    ColorPickerPopup.Draggable = true
    
    local PopupCorner = Instance.new("UICorner")
    PopupCorner.CornerRadius = UDim.new(0, 16)
    PopupCorner.Parent = ColorPickerPopup
    
    local PopupStroke = Instance.new("UIStroke")
    PopupStroke.Parent = ColorPickerPopup
    PopupStroke.Color = Color3.fromRGB(230, 230, 230)
    PopupStroke.Thickness = 1
    PopupStroke.Transparency = 0.3
    
    local PopupTitle = Instance.new("TextLabel")
    PopupTitle.Name = "PopupTitle"
    PopupTitle.Parent = ColorPickerPopup
    PopupTitle.BackgroundTransparency = 1
    PopupTitle.Position = UDim2.new(0, 10, 0, 8)
    PopupTitle.Size = UDim2.new(1, -20, 0, 24)
    PopupTitle.Font = Enum.Font.SourceSansSemibold
    PopupTitle.Text = config.title
    PopupTitle.TextColor3 = config.TextColor
    PopupTitle.TextSize = 16
    PopupTitle.TextXAlignment = Enum.TextXAlignment.Center
    PopupTitle.ZIndex = 1001
    
    local SatVibMap = Instance.new("ImageLabel")
    SatVibMap.Name = "SatVibMap"
    SatVibMap.Parent = ColorPickerPopup
    SatVibMap.Size = UDim2.fromOffset(150, 140)
    SatVibMap.Position = UDim2.fromOffset(15, 40)
    SatVibMap.Image = "rbxassetid://4155801252"
    SatVibMap.BackgroundColor3 = config.defaultColor
    SatVibMap.BackgroundTransparency = 0
    SatVibMap.ZIndex = 1001
    
    local SatVibCorner = Instance.new("UICorner")
    SatVibCorner.CornerRadius = UDim.new(0, 8)
    SatVibCorner.Parent = SatVibMap
    
    local SatCursor = Instance.new("ImageLabel")
    SatCursor.Name = "SatCursor"
    SatCursor.Size = UDim2.new(0, 16, 0, 16)
    SatCursor.ScaleType = Enum.ScaleType.Fit
    SatCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    SatCursor.BackgroundTransparency = 1
    SatCursor.Image = "http://www.roblox.com/asset/?id=4805639000"
    SatCursor.ZIndex = 1002
    SatCursor.Parent = SatVibMap
    
    local HueSlider = Instance.new("Frame")
    HueSlider.Name = "HueSlider"
    HueSlider.Parent = ColorPickerPopup
    HueSlider.Size = UDim2.fromOffset(14, 140)
    HueSlider.Position = UDim2.fromOffset(175, 40)
    HueSlider.ZIndex = 1001
    
    local HueSliderCorner = Instance.new("UICorner")
    HueSliderCorner.CornerRadius = UDim.new(1, 0)
    HueSliderCorner.Parent = HueSlider
    
    local SequenceTable = {}
    for Color = 0, 1, 0.1 do
        table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
    end
    
    local HueSliderGradient = Instance.new("UIGradient")
    HueSliderGradient.Color = ColorSequence.new(SequenceTable)
    HueSliderGradient.Rotation = 90
    HueSliderGradient.Parent = HueSlider
    
    local HueDragHolder = Instance.new("Frame")
    HueDragHolder.Name = "HueDragHolder"
    HueDragHolder.Size = UDim2.new(1, 0, 1, -10)
    HueDragHolder.Position = UDim2.fromOffset(0, 5)
    HueDragHolder.BackgroundTransparency = 1
    HueDragHolder.Parent = HueSlider
    HueDragHolder.ZIndex = 1002
    
    local HueDrag = Instance.new("ImageLabel")
    HueDrag.Name = "HueDrag"
    HueDrag.Size = UDim2.fromOffset(14, 14)
    HueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
    HueDrag.Parent = HueDragHolder
    HueDrag.ImageColor3 = Color3.new(1, 1, 1)
    HueDrag.ZIndex = 1003
    
    local RGBInputs = Instance.new("Frame")
    RGBInputs.Name = "RGBInputs"
    RGBInputs.Parent = ColorPickerPopup
    RGBInputs.BackgroundTransparency = 1
    RGBInputs.Position = UDim2.new(0, 200, 0, 40)
    RGBInputs.Size = UDim2.new(0, 110, 0, 140)
    RGBInputs.ZIndex = 1001
    
    local function createRGBInput(label, position, defaultValue)
        local InputFrame = Instance.new("Frame")
        InputFrame.Name = label .. "Input"
        InputFrame.Parent = RGBInputs
        InputFrame.BackgroundTransparency = 1
        InputFrame.Position = position
        InputFrame.Size = UDim2.new(1, 0, 0, 28)
        InputFrame.ZIndex = 1002
        
        local InputLabel = Instance.new("TextLabel")
        InputLabel.Name = "Label"
        InputLabel.Parent = InputFrame
        InputLabel.BackgroundTransparency = 1
        InputLabel.Position = UDim2.new(0, 0, 0, 0)
        InputLabel.Size = UDim2.new(0, 25, 1, 0)
        InputLabel.Font = Enum.Font.SourceSansSemibold
        InputLabel.Text = label .. ":"
        InputLabel.TextColor3 = config.TextColor
        InputLabel.TextSize = 13
        InputLabel.TextXAlignment = Enum.TextXAlignment.Left
        InputLabel.ZIndex = 1002
        
        local InputBox = Instance.new("TextBox")
        InputBox.Name = "InputBox"
        InputBox.Parent = InputFrame
        InputBox.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
        InputBox.BackgroundTransparency = 0.1
        InputBox.BorderSizePixel = 0
        InputBox.Position = UDim2.new(0, 30, 0, 0)
        InputBox.Size = UDim2.new(0, 75, 0, 28)
        InputBox.Font = Enum.Font.SourceSans
        InputBox.Text = tostring(defaultValue)
        InputBox.TextColor3 = config.TextColor
        InputBox.TextSize = 13
        InputBox.PlaceholderColor3 = config.SecondaryTextColor
        InputBox.ZIndex = 1002
        
        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 8)
        InputCorner.Parent = InputBox
        
        return InputBox
    end
    
    local RInput = createRGBInput("R", UDim2.new(0, 0, 0, 0), math.floor(config.defaultColor.R * 255))
    local GInput = createRGBInput("G", UDim2.new(0, 0, 0, 32), math.floor(config.defaultColor.G * 255))
    local BInput = createRGBInput("B", UDim2.new(0, 0, 0, 64), math.floor(config.defaultColor.B * 255))
    local HexInput = createRGBInput("Hex", UDim2.new(0, 0, 0, 96), "#" .. config.defaultColor:ToHex())
    
    local PreviewContainer = Instance.new("Frame")
    PreviewContainer.Name = "PreviewContainer"
    PreviewContainer.Parent = ColorPickerPopup
    PreviewContainer.BackgroundTransparency = 1
    PreviewContainer.Position = UDim2.new(0, 15, 0, 190)
    PreviewContainer.Size = UDim2.new(1, -30, 0, 30)
    PreviewContainer.ZIndex = 1001
    
    local OldColorFrame = Instance.new("Frame")
    OldColorFrame.Name = "OldColorFrame"
    OldColorFrame.Parent = PreviewContainer
    OldColorFrame.BackgroundColor3 = config.defaultColor
    OldColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
    OldColorFrame.Position = UDim2.new(0, 0, 0, 0)
    OldColorFrame.BackgroundTransparency = 0
    OldColorFrame.ZIndex = 1002
    
    local OldColorFrameCorner = Instance.new("UICorner")
    OldColorFrameCorner.CornerRadius = UDim.new(0, 8)
    OldColorFrameCorner.Parent = OldColorFrame
    
    local OldColorLabel = Instance.new("TextLabel")
    OldColorLabel.Name = "OldColorLabel"
    OldColorLabel.Parent = OldColorFrame
    OldColorLabel.BackgroundTransparency = 1
    OldColorLabel.Size = UDim2.new(1, 0, 1, 0)
    OldColorLabel.Font = Enum.Font.SourceSans
    OldColorLabel.Text = "原色"
    OldColorLabel.TextColor3 = Color3.new(1, 1, 1)
    OldColorLabel.TextSize = 12
    OldColorLabel.TextXAlignment = Enum.TextXAlignment.Center
    OldColorLabel.ZIndex = 1003
    
    local CurrentColorFrame = Instance.new("Frame")
    CurrentColorFrame.Name = "CurrentColorFrame"
    CurrentColorFrame.Parent = PreviewContainer
    CurrentColorFrame.BackgroundColor3 = config.defaultColor
    CurrentColorFrame.Size = UDim2.new(0.48, 0, 1, 0)
    CurrentColorFrame.Position = UDim2.new(0.52, 0, 0, 0)
    CurrentColorFrame.BackgroundTransparency = 0
    CurrentColorFrame.ZIndex = 1002
                
                local CurrentColorFrameCorner = Instance.new("UICorner")
                CurrentColorFrameCorner.CornerRadius = UDim.new(0, 8)
                CurrentColorFrameCorner.Parent = CurrentColorFrame
                
                local CurrentColorLabel = Instance.new("TextLabel")
                CurrentColorLabel.Name = "CurrentColorLabel"
                CurrentColorLabel.Parent = CurrentColorFrame
                CurrentColorLabel.BackgroundTransparency = 1
                CurrentColorLabel.Size = UDim2.new(1, 0, 1, 0)
                CurrentColorLabel.Font = Enum.Font.SourceSans
                CurrentColorLabel.Text = "新色"
                CurrentColorLabel.TextColor3 = Color3.new(1, 1, 1)
                CurrentColorLabel.TextSize = 12
                CurrentColorLabel.TextXAlignment = Enum.TextXAlignment.Center
                CurrentColorLabel.ZIndex = 1003
                
                local ButtonContainer = Instance.new("Frame")
                ButtonContainer.Name = "ButtonContainer"
                ButtonContainer.Parent = ColorPickerPopup
                ButtonContainer.BackgroundTransparency = 1
                ButtonContainer.Position = UDim2.new(0, 15, 1, -40)
                ButtonContainer.Size = UDim2.new(1, -30, 0, 30)
                ButtonContainer.ZIndex = 1001
                
                local ConfirmBtn = Instance.new("TextButton")
                ConfirmBtn.Name = "ConfirmBtn"
                ConfirmBtn.Parent = ButtonContainer
                ConfirmBtn.BackgroundColor3 = config.iOS_Blue
                ConfirmBtn.BackgroundTransparency = 0.1
                ConfirmBtn.BorderSizePixel = 0
                ConfirmBtn.Position = UDim2.new(0, 0, 0, 0)
                ConfirmBtn.Size = UDim2.new(0.48, 0, 1, 0)
                ConfirmBtn.Font = Enum.Font.SourceSansSemibold
                ConfirmBtn.Text = "确认"
                ConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
                ConfirmBtn.TextSize = 14
                ConfirmBtn.AutoButtonColor = true
                ConfirmBtn.ZIndex = 1002
                ConfirmBtn.Modal = true
                
                local ConfirmCorner = Instance.new("UICorner")
                ConfirmCorner.CornerRadius = UDim.new(0, 10)
                ConfirmCorner.Parent = ConfirmBtn
                
                local CancelBtn = Instance.new("TextButton")
                CancelBtn.Name = "CancelBtn"
                CancelBtn.Parent = ButtonContainer
                CancelBtn.BackgroundColor3 = config.iOS_Gray5
                CancelBtn.BackgroundTransparency = 0.1
                CancelBtn.BorderSizePixel = 0
                CancelBtn.Position = UDim2.new(0.52, 0, 0, 0)
                CancelBtn.Size = UDim2.new(0.48, 0, 1, 0)
                CancelBtn.Font = Enum.Font.SourceSansSemibold
                CancelBtn.Text = "取消"
                CancelBtn.TextColor3 = config.TextColor
                CancelBtn.TextSize = 14
                CancelBtn.AutoButtonColor = true
                CancelBtn.ZIndex = 1002
                CancelBtn.Modal = true
                
                local CancelCorner = Instance.new("UICorner")
                CancelCorner.CornerRadius = UDim.new(0, 10)
                CancelCorner.Parent = CancelBtn
                
                local currentColor = config.defaultColor
                local currentHue, currentSat, currentVib = Color3.toHSV(config.defaultColor)
                
                local function updateDisplay()
                    SatVibMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
                    
                    local cursorX = currentSat
                    local cursorY = 1 - currentVib
                    SatCursor.Position = UDim2.new(cursorX, -8, cursorY, -8)
                    
                    HueDrag.Position = UDim2.new(0, 0, currentHue, -7)
                    
                    currentColor = Color3.fromHSV(currentHue, currentSat, currentVib)
                    CurrentColorFrame.BackgroundColor3 = currentColor
                    
                    local oldBrightness = (OldColorFrame.BackgroundColor3.R * 0.299 + OldColorFrame.BackgroundColor3.G * 0.587 + OldColorFrame.BackgroundColor3.B * 0.114)
                    OldColorLabel.TextColor3 = oldBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                    
                    local currentBrightness = (currentColor.R * 0.299 + currentColor.G * 0.587 + currentColor.B * 0.114)
                    CurrentColorLabel.TextColor3 = currentBrightness > 0.5 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
                    
                    local rgb = {
                        R = math.floor(currentColor.R * 255),
                        G = math.floor(currentColor.G * 255),
                        B = math.floor(currentColor.B * 255)
                    }
                    
                    HexInput.Text = "#" .. currentColor:ToHex()
                    RInput.Text = tostring(rgb.R)
                    GInput.Text = tostring(rgb.G)
                    BInput.Text = tostring(rgb.B)
                end
                
                local function setupInteraction()
                    local satVibDragging = false
                    
                    local function updateSatVib(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            satVibDragging = true
                            
                            local connection
                            connection = services.RunService.RenderStepped:Connect(function()
                                if not satVibDragging then
                                    connection:Disconnect()
                                    return
                                end
                                
                                local mouse = services.Players.LocalPlayer:GetMouse()
                                local minX = SatVibMap.AbsolutePosition.X
                                local maxX = minX + SatVibMap.AbsoluteSize.X
                                local mouseX = math.clamp(mouse.X, minX, maxX)
                                
                                local minY = SatVibMap.AbsolutePosition.Y
                                local maxY = minY + SatVibMap.AbsoluteSize.Y
                                local mouseY = math.clamp(mouse.Y, minY, maxY)
                                
                                currentSat = (mouseX - minX) / (maxX - minX)
                                currentVib = 1 - ((mouseY - minY) / (maxY - minY))
                                
                                updateDisplay()
                            end)
                            
                            services.UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                    satVibDragging = false
                                end
                            end)
                        end
                    end
                    
                    SatVibMap.InputBegan:Connect(updateSatVib)
                    SatCursor.InputBegan:Connect(updateSatVib)
                    
                    local hueDragging = false
                    
                    local function updateHue(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            hueDragging = true
                            
                            local connection
                            connection = services.RunService.RenderStepped:Connect(function()
                                if not hueDragging then
                                    connection:Disconnect()
                                    return
                                end
                                
                                local mouse = services.Players.LocalPlayer:GetMouse()
                                local minY = HueSlider.AbsolutePosition.Y
                                local maxY = minY + HueSlider.AbsoluteSize.Y
                                local mouseY = math.clamp(mouse.Y, minY, maxY)
                                
                                currentHue = ((mouseY - minY) / (maxY - minY))
                                
                                updateDisplay()
                            end)
                            
                            services.UserInputService.InputEnded:Connect(function(endInput)
                                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                                    hueDragging = false
                                end
                            end)
                        end
                    end
                    
                    HueSlider.InputBegan:Connect(updateHue)
                    HueDragHolder.InputBegan:Connect(updateHue)
                    HueDrag.InputBegan:Connect(updateHue)
                end
                
                local function setupRGBInputs()
                    local function validateRGBInput(inputBox, maxValue)
                        inputBox.FocusLost:Connect(function(enterPressed)
                            local text = inputBox.Text
                            
                            if inputBox == HexInput then
                                local hex = text:gsub("#", "")
                                if hex:match("^[0-9A-Fa-f]+$") and #hex == 6 then
                                    local success, color = pcall(Color3.fromHex, hex)
                                    if success then
                                        currentHue, currentSat, currentVib = Color3.toHSV(color)
                                        updateDisplay()
                                        return
                                    end
                                end
                                inputBox.Text = "#" .. currentColor:ToHex()
                            else
                                local num = tonumber(text)
                                
                                if num then
                                    num = math.clamp(num, 0, maxValue)
                                    inputBox.Text = tostring(num)
                                    
                                    local r = tonumber(RInput.Text) or 255
                                    local g = tonumber(GInput.Text) or 255
                                    local b = tonumber(BInput.Text) or 255
                                    local color = Color3.fromRGB(r, g, b)
                                    currentHue, currentSat, currentVib = Color3.toHSV(color)
                                    updateDisplay()
                                else
                                    if inputBox == RInput then
                                        inputBox.Text = tostring(math.floor(currentColor.R * 255))
                                    elseif inputBox == GInput then
                                        inputBox.Text = tostring(math.floor(currentColor.G * 255))
                                    elseif inputBox == BInput then
                                        inputBox.Text = tostring(math.floor(currentColor.B * 255))
                                    end
                                end
                            end
                        end)
                    end
                
                    validateRGBInput(HexInput, 255)
                    validateRGBInput(RInput, 255)
                    validateRGBInput(GInput, 255)
                    validateRGBInput(BInput, 255)
                end
                
                updateDisplay()
                setupInteraction()
                setupRGBInputs()
                
                local colorPickerObj = {
                    Instance = ColorPickerPopup,
                    CurrentColor = currentColor,
                    Closed = false
                }
                
                local pickerId = #FengUI.ColorPickers + 1
                FengUI.ColorPickers[pickerId] = colorPickerObj
                
                local function closePicker(saveColor)
                    if colorPickerObj.Closed then return end
                    
                    colorPickerObj.Closed = true
                    
                    services.TweenService:Create(ColorPickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.8,
                        Size = UDim2.new(0, 10, 0, 10)
                    }):Play()
                    
                    task.wait(0.2)
                    
                    if saveColor then
                        config.callback(currentColor)
                    end
                    
                    ColorPickerPopup:Destroy()
                    FengUI.ColorPickers[pickerId] = nil
                end
                
                ConfirmBtn.MouseButton1Click:Connect(function()
                    closePicker(true)
                end)
                
                CancelBtn.MouseButton1Click:Connect(function()
                    closePicker(false)
                end)
                
                local ClosePickerBtn = Instance.new("TextButton")
                ClosePickerBtn.Name = "ClosePickerBtn"
                ClosePickerBtn.Parent = ColorPickerPopup
                ClosePickerBtn.BackgroundTransparency = 1
                ClosePickerBtn.BorderSizePixel = 0
                ClosePickerBtn.Position = UDim2.new(1, -40, 0, 5)
                ClosePickerBtn.Size = UDim2.new(0, 30, 0, 30)
                ClosePickerBtn.Font = Enum.Font.SourceSansSemibold
                ClosePickerBtn.Text = "×"
                ClosePickerBtn.TextColor3 = config.SecondaryTextColor
                ClosePickerBtn.TextSize = 20
                ClosePickerBtn.ZIndex = 1002
                
                ClosePickerBtn.MouseButton1Click:Connect(function()
                    closePicker(false)
                end)
                
                return colorPickerObj
            end

            function FengUI:ColorPicker(options)
                return self:CreateColorPicker(options)
            end

            function FengUI:PickColor(title, defaultColor)
                defaultColor = defaultColor or Color3.fromRGB(0, 122, 255)
                
                local colorSelected = false
                local selectedColor = defaultColor
                
                local picker = self:CreateColorPicker({
                    title = title or "选择颜色",
                    defaultColor = defaultColor,
                    callback = function(color)
                        selectedColor = color
                        colorSelected = true
                    end,
                    position = UDim2.new(0.5, 0, 0.4, 0)
                })
                
                while not picker.Closed do
                    task.wait()
                end
                
                return selectedColor
            end

            function FengUI:BindColorPicker(button, options)
                local currentColor = options.defaultColor or Color3.fromRGB(0, 122, 255)
                
                local previewFrame = Instance.new("Frame")
                previewFrame.Name = "ColorPreview"
                previewFrame.Parent = button
                previewFrame.BackgroundColor3 = currentColor
                previewFrame.BorderSizePixel = 0
                previewFrame.Position = UDim2.new(0.8, 0, 0.2, 0)
                previewFrame.Size = UDim2.new(0, 40, 0, 24)
                
                local previewCorner = Instance.new("UICorner")
                previewCorner.CornerRadius = UDim.new(0, 8)
                previewCorner.Parent = previewFrame
                
                button.MouseButton1Click:Connect(function()
                    local picker = FengUI:CreateColorPicker({
                        title = options.title or "选择颜色",
                        defaultColor = currentColor,
                        callback = function(color)
                            currentColor = color
                            previewFrame.BackgroundColor3 = color
                            if options.callback then
                                options.callback(color)
                            end
                        end,
                        position = UDim2.new(0.5, 0, 0.5, 0)
                    })
                end)
                
                return {
                    GetColor = function()
                        return currentColor
                    end,
                    SetColor = function(color)
                        currentColor = color
                        previewFrame.BackgroundColor3 = color
                        if options.callback then
                            options.callback(color)
                        end
                    end
                }
            end

            function FengUI:CloseAllColorPickers()
                for _, picker in pairs(FengUI.ColorPickers) do
                    if picker.Instance and picker.Instance.Parent then
                        picker.Instance:Destroy()
                    end
                end
                FengUI.ColorPickers = {}
            end

            function UiDestroy()
                if FengYu then
                    FengYu:Destroy()
                end
                FengUI:CloseAllColorPickers()
            end

            function ToggleUILib()
                ToggleUI = not ToggleUI
                FengYu.Enabled = ToggleUI
                Main.Visible = not ToggleUI
            end

            if not getgenv then getgenv = function() return _G end end
            getgenv().FengUI = FengUI

            return FengUI