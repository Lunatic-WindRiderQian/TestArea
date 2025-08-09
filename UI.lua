repeat
	task.wait()
until game:IsLoaded()
local library = {}
function library.new(name)
local ToggleUI = false
library.currentTab = nil
library.flags = {}
    local services = {
        TweenService = game:GetService("TweenService"),
        UserInputService = game:GetService("UserInputService"),
        CoreGui = game:GetService("CoreGui"),
        Players = game:GetService("Players"),
    }
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        -- 处理输入
    end
end)

-- 新增颜色配置
local colorConfig = {
    primary = Color3.fromRGB(37, 254, 152),  -- 主色调
    secondary = Color3.fromRGB(22, 22, 22),  -- 次级色调
    background = Color3.fromRGB(16, 16, 16), -- 背景色
    text = Color3.fromRGB(240, 240, 240),    -- 文本色
    accent = Color3.fromRGB(255, 50, 50),    -- 强调色
    disabled = Color3.fromRGB(100, 100, 100) -- 禁用状态色
}

local function safeCreate(instanceType, properties)
    local success, instance = pcall(function()
        return Instance.new(instanceType)
    end)
    if success then
        for prop, value in pairs(properties) do
            pcall(function()
                instance[prop] = value
            end)
        end
        return instance
    end
    return nil
end

local mouse = services.Players.LocalPlayer:GetMouse()

-- 优化的Tween函数
function Tween(obj, t, data)
    services.TweenService
        :Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data)
        :Play()
    return true
end

-- 优化的Ripple效果
function Ripple(obj)
    spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundColor3 = colorConfig.accent
        Ripple.BackgroundTransparency = 1.000
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://84830962019412"
        Ripple.ImageTransparency = 0.800
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = colorConfig.accent
        Ripple.Position = UDim2.new(
            (mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X,
            0,
            (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y,
            0
        )
        Tween(
            Ripple,
            { 0.3, "Linear", "InOut" },
            { Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0) }
        )
        wait(0.15)
        Tween(Ripple, { 0.3, "Linear", "InOut" }, { ImageTransparency = 1 })
        wait(0.3)
        Ripple:Destroy()
    end)
end

local toggled = false
local switchingTabs = false

-- 优化的切换标签页函数
function switchTab(new)
    if switchingTabs then
        return
    end
    local old = library.currentTab
    if old == nil then
        new[2].Visible = true
        library.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.1), { ImageTransparency = 0 }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0 }):Play()
        return
    end
    if old[1] == new[1] then
        return
    end
    switchingTabs = true
    library.currentTab = new
    services.TweenService:Create(old[1], TweenInfo.new(0.1), { ImageTransparency = 0.2 }):Play()
    services.TweenService:Create(new[1], TweenInfo.new(0.1), { ImageTransparency = 0 }):Play()
    services.TweenService:Create(old[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0.2 }):Play()
    services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), { TextTransparency = 0 }):Play()
    old[2].Visible = false
    new[2].Visible = true
    task.wait(0.1)
    switchingTabs = false
end

-- 优化的拖拽函数
function drag(frame, hold)
    if not hold then
        hold = frame
    end
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position =
            UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    
    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function library.new(library, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "REN" then
            v:Destroy()
        end
    end

    local config = {
        MainColor = colorConfig.background,
        TabColor = colorConfig.secondary,
        Bg_Color = colorConfig.background,
        Zy_Color = colorConfig.background, 

        Button_Color = colorConfig.secondary,
        Textbox_Color = colorConfig.secondary,
        Dropdown_Color = colorConfig.secondary,
        Keybind_Color = colorConfig.secondary,
        Label_Color = colorConfig.secondary,

        Slider_Color = colorConfig.secondary,
        SliderBar_Color = colorConfig.primary,

        Toggle_Color = colorConfig.secondary,
        Toggle_Off = Color3.fromRGB(34, 34, 34),
        Toggle_On = colorConfig.primary,
    }

    -- 创建主UI
    local FengYu = Instance.new("ScreenGui")
    FengYu.Name = "UniversalUI"
    FengYu.ResetOnSpawn = false
    FengYu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- 保护UI
    if syn and syn.protect_gui then
        syn.protect_gui(FengYu)
    elseif protect_gui then
        protect_gui(FengYu)
    end
    
    local function protectUI(gui)
        if pcall(function() gui.Parent = services.CoreGui end) then
            return true
        end
        return false
    end
    protectUI(FengYu)
    
    FengYu.Name = "REN"
    FengYu.Parent = services.CoreGui
    
    -- 主窗口框架
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = FengYu
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = config.Bg_Color
    Main.BorderColor3 = config.MainColor
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 572, 0, 353)
    Main.ZIndex = 1
    Main.Active = true
    
    -- 添加阴影效果
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = Main
    shadow.BackgroundTransparency = 1
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 0
    
    -- 圆角
    local UICornerMain = Instance.new("UICorner")
    UICornerMain.CornerRadius = UDim.new(0, 8)
    UICornerMain.Parent = Main
    
    -- 拖动功能
    drag(Main)
    
    -- 控制键显示/隐藏
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            Main.Visible = not Main.Visible
        end
    end)

    -- 打开/关闭按钮
    local Open = Instance.new("ImageButton")
    Open.Name = "Open"
    Open.Parent = FengYu
    Open.BackgroundColor3 = colorConfig.primary
    Open.BackgroundTransparency = 0.8
    Open.Position = UDim2.new(0.008, 0, 0.131, 0)
    Open.Size = UDim2.new(0, 40, 0, 40)
    Open.AutoButtonColor = false
    Open.Image = "rbxassetid://84830962019412"
    Open.ImageColor3 = colorConfig.primary
    
    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0, 12)
    OpenCorner.Parent = Open
    
    Open.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    -- 悬停效果
    Open.MouseEnter:Connect(function()
        Tween(Open, {0.2, "Linear", "Out"}, {BackgroundTransparency = 0.6})
    end)
    
    Open.MouseLeave:Connect(function()
        Tween(Open, {0.2, "Linear", "Out"}, {BackgroundTransparency = 0.8})
    end)

    -- 标签页主框架
    local TabMain = Instance.new("Frame")
    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabMain.BackgroundTransparency = 1.000
    TabMain.Position = UDim2.new(0.217, 0, 0, 3)
    TabMain.Size = UDim2.new(0, 448, 0, 350)
    
    -- 侧边栏
    local Side = Instance.new("Frame")
    Side.Name = "Side"
    Side.Parent = Main
    Side.BackgroundColor3 = config.Zy_Color
    Side.BorderSizePixel = 0
    Side.Position = UDim2.new(0, 0, 0, 0)
    Side.Size = UDim2.new(0, 110, 0, 353)
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
    SideCorner.Parent = Side
    
    -- 脚本标题
    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Position = UDim2.new(0, 10, 0.01, 0)
    ScriptTitle.Size = UDim2.new(0, 90, 0, 20)
    ScriptTitle.Font = Enum.Font.GothamSemibold
    ScriptTitle.Text = name
    ScriptTitle.TextColor3 = colorConfig.primary
    ScriptTitle.TextSize = 16
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 标签按钮容器
    local TabBtns = Instance.new("ScrollingFrame")
    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundTransparency = 1
    TabBtns.BorderSizePixel = 0
    TabBtns.Position = UDim2.new(0, 0, 0.097, 0)
    TabBtns.Size = UDim2.new(0, 110, 0, 318)
    TabBtns.CanvasSize = UDim2.new(0, 0, 1, 0)
    TabBtns.ScrollBarThickness = 0
    
    local TabBtnsL = Instance.new("UIListLayout")
    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)
    
    TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 18)
    end)

    -- 窗口功能
    local window = {}
    
    function window.Tab(window, name, icon)
        -- 标签页内容框架
        local Tab = Instance.new("ScrollingFrame")
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.Visible = false
        
        local TabL = Instance.new("UIListLayout")
        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
        end)
        
        -- 标签按钮
        local TabIco = Instance.new("ImageLabel")
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 24, 0, 24)
        TabIco.Image = ("rbxassetid://84830962019412"):format((icon or 4370341699))
        TabIco.ImageTransparency = 0.2
        TabIco.ImageColor3 = colorConfig.primary
        
        local TabText = Instance.new("TextLabel")
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.416, 0, 0, 0)
        TabText.Size = UDim2.new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = colorConfig.primary
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.2
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 110, 0, 24)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        -- 点击切换标签页
        TabBtn.MouseButton1Click:Connect(function()
            spawn(function()
                Ripple(TabBtn)
            end)
            switchTab({ TabIco, Tab })
        end)
        
        -- 默认选中第一个标签页
        if library.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        local tab = {}
        
        function tab.section(tab, name, TabVal)
            -- 创建分区
            local Section = Instance.new("Frame")
            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = config.TabColor
            Section.BackgroundTransparency = 0.1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2.new(0.981, 0, 0, 36)
            
            local SectionC = Instance.new("UICorner")
            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section
            
            -- 分区标题
            local SectionText = Instance.new("TextLabel")
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0.088, 0, 0, 0)
            SectionText.Size = UDim2.new(0, 401, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = colorConfig.text
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 折叠/展开图标
            local SectionOpen = Instance.new("ImageLabel")
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, -33, 0, 5)
            SectionOpen.Size = UDim2.new(0, 26, 0, 26)
            SectionOpen.Image = "http://www.roblox.com/asset/?id=6031302934"
            SectionOpen.ImageColor3 = colorConfig.text
            
            local SectionOpened = Instance.new("ImageLabel")
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(0, 26, 0, 26)
            SectionOpened.Image = "http://www.roblox.com/asset/?id=6031302932"
            SectionOpened.ImageTransparency = 1
            SectionOpened.ImageColor3 = colorConfig.text
            
            local SectionToggle = Instance.new("ImageButton")
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(0, 26, 0, 26)
            
            -- 内容容器
            local Objs = Instance.new("Frame")
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 6, 0, 36)
            Objs.Size = UDim2.new(0.986, 0, 0, 0)
            
            local ObjsL = Instance.new("UIListLayout")
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = TabVal
            
            -- 初始状态
            if TabVal ~= false then
                Section.Size = UDim2.new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = (open and 0 or 1)
                SectionOpen.ImageTransparency = (open and 1 or 0)
            end
            
            -- 切换折叠/展开
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                Section.Size = UDim2.new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = (open and 0 or 1)
                SectionOpen.ImageTransparency = (open and 1 or 0)
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then
                    return
                end
                Section.Size = UDim2.new(0.981, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
            end)
            
            local section = {}
            
            -- 按钮控件
            function section.Button(section, text, callback)
                local callback = callback or function() end
                
                local BtnModule = Instance.new("Frame")
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.BorderSizePixel = 0
                BtnModule.Size = UDim2.new(0, 428, 0, 38)
                
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, 428, 0, 38)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = colorConfig.text
                Btn.TextSize = 16
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                
                local BtnC = Instance.new("UICorner")
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                -- 悬停效果
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {0.2, "Linear", "Out"}, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)})
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {0.2, "Linear", "Out"}, {BackgroundColor3 = config.Button_Color})
                end)
                
                -- 点击事件
                Btn.MouseButton1Click:Connect(function()
                    spawn(function()
                        Ripple(Btn)
                    end)
                    spawn(callback)
                end)
            end
            
            -- 标签控件
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, 428, 0, 19)
                
                local TextLabel = Instance.new("TextLabel")
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.Size = UDim2.new(0, 428, 0, 22)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = colorConfig.text
                TextLabel.TextSize = 14
                
                local LabelC = Instance.new("UICorner")
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
                return TextLabel
            end
            
            -- 开关控件
            function section.Toggle(section, text, flag, enabled, callback)
                local callback = callback or function() end
                local enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flags[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(0, 428, 0, 38)
                
                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, 428, 0, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = colorConfig.text
                ToggleBtn.TextSize = 16
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                local ToggleBtnC = Instance.new("UICorner")
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                local ToggleDisable = Instance.new("Frame")
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = config.Bg_Color
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(0.901, 0, 0.208, 0)
                ToggleDisable.Size = UDim2.new(0, 36, 0, 22)
                
                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 24, 0, 22)
                
                local ToggleSwitchC = Instance.new("UICorner")
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                local ToggleDisableC = Instance.new("UICorner")
                ToggleDisableC.CornerRadius = UDim.new(0, 6)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not library.flags[flag]
                        end
                        if library.flags[flag] == state then
                            return
                        end
                        services.TweenService
                            :Create(ToggleSwitch, TweenInfo.new(0.2), {
                                Position = UDim2.new(0, (state and ToggleSwitch.Size.X.Offset / 2 or 0), 0, 0),
                                BackgroundColor3 = (state and config.Toggle_On or config.Toggle_Off),
                            })
                            :Play()
                        library.flags[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule,
                }
                
                if enabled ~= false then
                    funcs:SetState(flag, true)
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                
                return funcs
            end
            
            -- 键位绑定控件
            function section.Keybind(section, text, default, callback)
                local callback = callback or function() end
                assert(text, "No text provided")
                assert(default, "No default key provided")
                local default = (typeof(default) == "string" and Enum.KeyCode[default] or default)
                local banned = {
                    Return = true,
                    Space = true,
                    Tab = true,
                    Backquote = true,
                    CapsLock = true,
                    Escape = true,
                    Unknown = true,
                }
                local shortNames = {
                    RightControl = "Right Ctrl",
                    LeftControl = "Left Ctrl",
                    LeftShift = "Left Shift",
                    RightShift = "Right Shift",
                    Semicolon = ";",
                    Quote = '"',
                    LeftBracket = "[",
                    RightBracket = "]",
                    Equals = "=",
                    Minus = "-",
                    RightAlt = "Right Alt",
                    LeftAlt = "Left Alt",
                }
                
                local bindKey = default
                local keyTxt = (default and (shortNames[default.Name] or default.Name) or "None")
                
                local KeybindModule = Instance.new("Frame")
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(0, 428, 0, 38)
                
                local KeybindBtn = Instance.new("TextButton")
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, 428, 0, 38)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = colorConfig.text
                KeybindBtn.TextSize = 16
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                local KeybindBtnC = Instance.new("UICorner")
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                local KeybindValue = Instance.new("TextButton")
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(0.763, 0, 0.289, 0)
                KeybindValue.Size = UDim2.new(0, 100, 0, 28)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = colorConfig.text
                KeybindValue.TextSize = 14
                
                local KeybindValueC = Instance.new("UICorner")
                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue
                
                -- 监听按键
                services.UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then
                        return
                    end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end
                    if inp.KeyCode ~= bindKey then
                        return
                    end
                    callback(bindKey.Name)
                end)
                
                -- 更改键位
                KeybindValue.MouseButton1Click:Connect(function()
                    KeybindValue.Text = "..."
                    wait()
                    local key, _ = services.UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    if banned[keyName] then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    wait()
                    bindKey = Enum.KeyCode[keyName]
                    KeybindValue.Text = shortNames[keyName] or keyName
                end)
                
                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
                end)
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end
            
            -- 文本框控件
            function section.Textbox(section, text, flag, default, callback)
                local callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                library.flags[flag] = default
                
                local TextboxModule = Instance.new("Frame")
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, 428, 0, 38)
                
                local TextboxBack = Instance.new("TextButton")
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, 428, 0, 38)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = colorConfig.text
                TextboxBack.TextSize = 16
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                local TextboxBackC = Instance.new("UICorner")
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                local BoxBG = Instance.new("TextButton")
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(0.763, 0, 0.289, 0)
                BoxBG.Size = UDim2.new(0, 100, 0, 28)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.Gotham
                BoxBG.Text = ""
                
                local BoxBGC = Instance.new("UICorner")
                BoxBGC.CornerRadius = UDim.new(0, 6)
                BoxBGC.Name = "BoxBGC"
                BoxBGC.Parent = BoxBG
                
                local TextBox = Instance.new("TextBox")
                TextBox.Parent = BoxBG
                TextBox.BackgroundTransparency = 1
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2.new(1, 0, 1, 0)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = colorConfig.text
                TextBox.TextSize = 14
                TextBox.PlaceholderColor3 = colorConfig.disabled
                
                -- 失去焦点时处理
                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    library.flags[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)
                
                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
                end)
                BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 30, 0, 28)
            end
            
            -- 滑块控件
            function section.Slider(section, text, flag, default, min, max, precise, callback)
                local callback = callback or function() end
                local min = min or 1
                local max = max or 10
                local default = default or min
                local precise = precise or false
                library.flags[flag] = default
                
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default value provided")
                
                local SliderModule = Instance.new("Frame")
                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundTransparency = 1
                SliderModule.BorderSizePixel = 0
                SliderModule.Size = UDim2.new(0, 428, 0, 38)
                
                local SliderBack = Instance.new("TextButton")
                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = config.Slider_Color
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2.new(0, 428, 0, 38)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = colorConfig.text
                SliderBack.TextSize = 16
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left
                
                local SliderBackC = Instance.new("UICorner")
                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack
                
                local SliderBar = Instance.new("Frame")
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                SliderBar.BackgroundColor3 = config.Bg_Color
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2.new(0.369, 40, 0.5, 0)
                SliderBar.Size = UDim2.new(0, 140, 0, 12)
                
                local SliderBarC = Instance.new("UICorner")
                SliderBarC.CornerRadius = UDim.new(0, 4)
                SliderBarC.Name = "SliderBarC"
                SliderBarC.Parent = SliderBar
                
                local SliderPart = Instance.new("Frame")
                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = config.SliderBar_Color
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2.new(0, 54, 0, 13)
                
                local SliderPartC = Instance.new("UICorner")
                SliderPartC.CornerRadius = UDim.new(0, 4)
                SliderPartC.Name = "SliderPartC"
                SliderPartC.Parent = SliderPart
                
                local SliderValBG = Instance.new("TextButton")
                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBack
                SliderValBG.BackgroundColor3 = config.Bg_Color
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2.new(0.883, 0, 0.131, 0)
                SliderValBG.Size = UDim2.new(0, 44, 0, 28)
                SliderValBG.AutoButtonColor = false
                SliderValBG.Font = Enum.Font.Gotham
                SliderValBG.Text = ""
                
                local SliderValBGC = Instance.new("UICorner")
                SliderValBGC.CornerRadius = UDim.new(0, 6)
                SliderValBGC.Name = "SliderValBGC"
                SliderValBGC.Parent = SliderValBG
                
                local SliderValue = Instance.new("TextBox")
                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundTransparency = 1
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2.new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = "1000"
                SliderValue.TextColor3 = colorConfig.text
                SliderValue.TextSize = 14
                
                local MinSlider = Instance.new("TextButton")
                MinSlider.Name = "MinSlider"
                MinSlider.Parent = SliderModule
                MinSlider.BackgroundTransparency = 1
                MinSlider.BorderSizePixel = 0
                MinSlider.Position = UDim2.new(0.296, 40, 0.236, 0)
                MinSlider.Size = UDim2.new(0, 20, 0, 20)
                MinSlider.Font = Enum.Font.Gotham
                MinSlider.Text = "-"
                MinSlider.TextColor3 = colorConfig.text
                MinSlider.TextSize = 24
                MinSlider.TextWrapped = true
                
                local AddSlider = Instance.new("TextButton")
                AddSlider.Name = "AddSlider"
                AddSlider.Parent = SliderModule
                AddSlider.AnchorPoint = Vector2.new(0, 0.5)
                AddSlider.BackgroundTransparency = 1
                AddSlider.BorderSizePixel = 0
                AddSlider.Position = UDim2.new(0.810, 0, 0.5, 0)
                AddSlider.Size = UDim2.new(0, 20, 0, 20)
                AddSlider.Font = Enum.Font.Gotham
                AddSlider.Text = "+"
                AddSlider.TextColor3 = colorConfig.text
                AddSlider.TextSize = 24
                AddSlider.TextWrapped = true
                
                local funcs = {
                    SetValue = function(self, value)
                        local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        if value then
                            percent = (value - min) / (max - min)
                        end
                        percent = math.clamp(percent, 0, 1)
                        if precise then
                            value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent))
                        else
                            value = value or math.floor(min + (max - min) * percent)
                        end
                        library.flags[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        SliderPart.Size = UDim2.new(percent, 0, 1, 0)
                        callback(tonumber(value))
                    end,
                }
                
                -- 减少值
                MinSlider.MouseButton1Click:Connect(function()
                    local currentValue = library.flags[flag]
                    currentValue = math.clamp(currentValue - 1, min, max)
                    funcs:SetValue(currentValue)
                end)
                
                -- 增加值
                AddSlider.MouseButton1Click:Connect(function()
                    local currentValue = library.flags[flag]
                    currentValue = math.clamp(currentValue + 1, min, max)
                    funcs:SetValue(currentValue)
                end)
                
                -- 初始值
                funcs:SetValue(default)
                
                local dragging, boxFocused, allowed = false, false, { [""] = true, ["-"] = true }
                
                -- 滑块拖动
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        funcs:SetValue()
                        dragging = true
                    end
                end)
                
                services.UserInputService.InputEnded:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        funcs:SetValue()
                    end
                end)
                
                -- 文本框输入
                SliderValue.Focused:Connect(function()
                    boxFocused = true
                end)
                
                SliderValue.FocusLost:Connect(function()
                    boxFocused = false
                    if SliderValue.Text == "" then
                        funcs:SetValue(default)
                    end
                end)
                
                SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
                    if not boxFocused then
                        return
                    end
                    SliderValue.Text = SliderValue.Text:gsub("%D+", "")
                    local text = SliderValue.Text
                    if not tonumber(text) then
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
            
            -- 下拉菜单控件
            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function() end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                library.flags[flag] = nil
                
                local DropdownModule = Instance.new("Frame")
                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundTransparency = 1
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Size = UDim2.new(0, 428, 0, 38)
                
                local DropdownTop = Instance.new("TextButton")
                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = config.Dropdown_Color
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2.new(0, 428, 0, 38)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = colorConfig.text
                DropdownTop.TextSize = 16
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
                
                local DropdownTopC = Instance.new("UICorner")
                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop
                
                local DropdownOpen = Instance.new("TextButton")
                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownTop
                DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpen.BackgroundTransparency = 1
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Position = UDim2.new(0.918, 0, 0.5, 0)
                DropdownOpen.Size = UDim2.new(0, 20, 0, 20)
                DropdownOpen.Font = Enum.Font.Gotham
                DropdownOpen.Text = "+"
                DropdownOpen.TextColor3 = colorConfig.text
                DropdownOpen.TextSize = 24
                DropdownOpen.TextWrapped = true
                
                local DropdownText = Instance.new("TextBox")
                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundTransparency = 1
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
                DropdownText.Size = UDim2.new(0, 184, 0, 38)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.PlaceholderColor3 = colorConfig.disabled
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = colorConfig.text
                DropdownText.TextSize = 16
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                
                local DropdownModuleL = Instance.new("UIListLayout")
                DropdownModuleL.Name = "DropdownModuleL"
                DropdownModuleL.Parent = DropdownModule
                DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownModuleL.Padding = UDim.new(0, 4)
                
                -- 设置所有选项可见
                local setAllVisible = function()
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if option:IsA("TextButton") and option.Name:match("Option_") then
                            option.Visible = true
                        end
                    end
                end
                
                -- 搜索功能
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
                
                -- 切换下拉菜单可见性
                local ToggleDropVis = function()
                    open = not open
                    if open then
                        setAllVisible()
                    end
                    DropdownOpen.Text = (open and "-" or "+")
                    DropdownModule.Size =
                        UDim2.new(0, 428, 0, (open and DropdownModuleL.AbsoluteContentSize.Y + 4 or 38))
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
                    DropdownModule.Size = UDim2.new(0, 428, 0, (DropdownModuleL.AbsoluteContentSize.Y + 4))
                end)
                
                local funcs = {}
                
                -- 添加选项
                funcs.AddOption = function(self, option)
                    local Option = Instance.new("TextButton")
                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownModule
                    Option.BackgroundColor3 = config.TabColor
                    Option.BorderSizePixel = 0
                    Option.Size = UDim2.new(0, 428, 0, 26)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = colorConfig.text
                    Option.TextSize = 14
                    
                    local OptionC = Instance.new("UICorner")
                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option
                    
                    -- 悬停效果
                    Option.MouseEnter:Connect(function()
                        Tween(Option, {0.2, "Linear", "Out"}, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)})
                    end)
                    
                    Option.MouseLeave:Connect(function()
                        Tween(Option, {0.2, "Linear", "Out"}, {BackgroundColor3 = config.TabColor})
                    end)
                    
                    -- 选择选项
                    Option.MouseButton1Click:Connect(function()
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        library.flags[flag] = Option.Text
                    end)
                end
                
                -- 移除选项
                funcs.RemoveOption = function(self, option)
                    local option = DropdownModule:FindFirstChild("Option_" .. option)
                    if option then
                        option:Destroy()
                    end
                end
                
                -- 设置选项
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
                
                -- 初始化选项
                funcs:SetOptions(options)
                
                return funcs
            end
            
            return section
        end
        
        return tab
    end
    
    return window
end

-- UI销毁函数
function UiDestroy()
    FengYu:Destroy()
end

-- UI切换显示函数
function ToggleUILib()
    if not ToggleUI then
        FengYu.Enabled = false
        ToggleUI = true
    else
        ToggleUI = false
        FengYu.Enabled = true
    end
end

return library