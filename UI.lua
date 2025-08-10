-- 修复版 FengYu UI Library
-- 保证显示悬浮窗且视觉效果正常

repeat task.wait() until game:IsLoaded()

local library = {
    currentTab = nil,
    flags = {},
    tabs = {}
}

-- 服务引用
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- 增强的颜色配置
local colors = {
    mainBg = Color3.fromRGB(20, 20, 20),
    sidebar = Color3.fromRGB(25, 25, 25),
    tabBg = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(0, 255, 170),  -- 霓虹青色
    text = Color3.fromRGB(240, 240, 240),
    button = Color3.fromRGB(40, 40, 40),
    buttonHover = Color3.fromRGB(50, 50, 50)
}

-- 创建主UI函数
function library:Create(name)
    -- 清理旧UI
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v.Name == "FengYuUI" then
            v:Destroy()
        end
    end

    -- 创建主ScreenGui
    local ui = Instance.new("ScreenGui")
    ui.Name = "FengYuUI"
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- 保护UI
    if syn and syn.protect_gui then
        syn.protect_gui(ui)
    elseif gethui then
        ui.Parent = gethui()
    else
        ui.Parent = CoreGui
    end

    -- 主窗口容器
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = ui
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = colors.mainBg
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Active = true
    mainFrame.Visible = true  -- 确保可见

    -- 添加圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- 添加阴影
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = mainFrame
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = -1

    -- 侧边栏
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = mainFrame
    sidebar.BackgroundColor3 = colors.sidebar
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.ZIndex = 2

    -- 侧边栏圆角
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 8)
    sidebarCorner.Parent = sidebar

    -- 标题
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = sidebar
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = name or "FengYu UI"
    title.TextColor3 = colors.accent
    title.TextSize = 18
    title.ZIndex = 3

    -- 标签按钮容器
    local tabButtons = Instance.new("ScrollingFrame")
    tabButtons.Name = "TabButtons"
    tabButtons.Parent = sidebar
    tabButtons.BackgroundTransparency = 1
    tabButtons.Position = UDim2.new(0, 0, 0, 50)
    tabButtons.Size = UDim2.new(1, 0, 1, -50)
    tabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabButtons.ScrollBarThickness = 3
    tabButtons.ZIndex = 2

    -- 标签页容器
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Parent = mainFrame
    tabContainer.BackgroundTransparency = 1
    tabContainer.Position = UDim2.new(0, 125, 0, 10)
    tabContainer.Size = UDim2.new(1, -135, 1, -20)
    tabContainer.ZIndex = 2

    -- 拖拽功能
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- 创建标签函数
    function library:AddTab(name, icon)
        -- 创建标签按钮
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name .. "TabButton"
        tabButton.Parent = tabButtons
        tabButton.BackgroundColor3 = colors.button
        tabButton.Size = UDim2.new(0.9, 0, 0, 40)
        tabButton.Position = UDim2.new(0.05, 0, 0, #self.tabs * 45)
        tabButton.Font = Enum.Font.Gotham
        tabButton.Text = "  " .. name
        tabButton.TextColor3 = colors.text
        tabButton.TextSize = 14
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.ZIndex = 3
        
        -- 按钮圆角
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        -- 悬停效果
        tabButton.MouseEnter:Connect(function()
            tabButton.BackgroundColor3 = colors.buttonHover
        end)
        
        tabButton.MouseLeave:Connect(function()
            if library.currentTab ~= name then
                tabButton.BackgroundColor3 = colors.button
            end
        end)

        -- 创建标签页
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Name = name .. "Tab"
        tabFrame.Parent = tabContainer
        tabFrame.BackgroundTransparency = 1
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.Visible = false
        tabFrame.ScrollBarThickness = 3
        tabFrame.ZIndex = 2
        
        -- 标签内容布局
        local layout = Instance.new("UIListLayout")
        layout.Parent = tabFrame
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        
        -- 标签按钮点击事件
        tabButton.MouseButton1Click:Connect(function()
            -- 隐藏所有标签页
            for _, tab in pairs(self.tabs) do
                tab.frame.Visible = false
                tab.button.BackgroundColor3 = colors.button
            end
            
            -- 显示当前标签页
            tabFrame.Visible = true
            tabButton.BackgroundColor3 = colors.accent
            tabButton.TextColor3 = Color3.new(0, 0, 0)
            
            library.currentTab = name
        end)
        
        -- 如果是第一个标签，默认显示
        if #self.tabs == 0 then
            tabFrame.Visible = true
            tabButton.BackgroundColor3 = colors.accent
            tabButton.TextColor3 = Color3.new(0, 0, 0)
            library.currentTab = name
        end
        
        -- 更新CanvasSize
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
        
        -- 更新按钮位置
        tabButtons.CanvasSize = UDim2.new(0, 0, 0, #self.tabs * 45 + 50)
        
        -- 标签功能表
        local tab = {
            name = name,
            frame = tabFrame,
            button = tabButton
        }
        
        table.insert(self.tabs, tab)
        
        -- 添加分区函数
        function tab:AddSection(title)
            local section = Instance.new("Frame")
            section.Name = title .. "Section"
            section.Parent = tabFrame
            section.BackgroundColor3 = colors.tabBg
            section.Size = UDim2.new(1, 0, 0, 40)
            section.ZIndex = 3
            
            -- 圆角
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = section
            
            -- 标题
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Parent = section
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Position = UDim2.new(0, 15, 0, 0)
            sectionTitle.Size = UDim2.new(1, -15, 1, 0)
            sectionTitle.Font = Enum.Font.GothamSemibold
            sectionTitle.Text = title
            sectionTitle.TextColor3 = colors.text
            sectionTitle.TextSize = 16
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.ZIndex = 4
            
            -- 内容容器
            local content = Instance.new("Frame")
            content.Name = "Content"
            content.Parent = section
            content.BackgroundTransparency = 1
            content.Position = UDim2.new(0, 0, 0, 40)
            content.Size = UDim2.new(1, 0, 0, 0)
            content.ClipsDescendants = true
            content.ZIndex = 3
            
            -- 内容布局
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Parent = content
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Padding = UDim.new(0, 5)
            
            -- 切换按钮
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleButton"
            toggleButton.Parent = section
            toggleButton.BackgroundTransparency = 1
            toggleButton.Size = UDim2.new(1, 0, 1, 0)
            toggleButton.Text = ""
            toggleButton.ZIndex = 5
            
            local isExpanded = false
            toggleButton.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                
                if isExpanded then
                    section.Size = UDim2.new(1, 0, 0, 40 + contentLayout.AbsoluteContentSize.Y)
                else
                    section.Size = UDim2.new(1, 0, 0, 40)
                end
            end)
            
            -- 更新内容大小
            contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if isExpanded then
                    section.Size = UDim2.new(1, 0, 0, 40 + contentLayout.AbsoluteContentSize.Y)
                end
            end)
            
            -- 分区功能
            local sectionApi = {}
            
            function sectionApi:AddButton(text, callback)
                local button = Instance.new("TextButton")
                button.Name = text .. "Button"
                button.Parent = content
                button.BackgroundColor3 = colors.button
                button.Size = UDim2.new(1, -10, 0, 35)
                button.Position = UDim2.new(0, 5, 0, 0)
                button.Font = Enum.Font.Gotham
                button.Text = "  " .. text
                button.TextColor3 = colors.text
                button.TextSize = 14
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.ZIndex = 4
                
                -- 圆角
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = button
                
                -- 悬停效果
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = colors.buttonHover
                end)
                
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = colors.button
                end)
                
                -- 点击事件
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                
                return button
            end
            
            return sectionApi
        end
        
        return tab
    end
    
    -- 返回UI控制API
    local api = {
        ui = ui,
        mainFrame = mainFrame,
        AddTab = function(name, icon)
            return library:AddTab(name, icon)
        end,
        Toggle = function()
            mainFrame.Visible = not mainFrame.Visible
        end,
        Destroy = function()
            ui:Destroy()
        end
    }
    
    return api
end

return library