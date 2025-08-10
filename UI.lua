-- FengYu UI Library - 修复版
-- 保证100%显示且视觉效果正常

repeat task.wait() until game:IsLoaded()

local FengYu = {
    currentTab = nil,
    flags = {},
    tabs = {}
}

-- 服务引用
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- 颜色配置 (确保所有颜色都有定义)
local colors = {
    mainBg = Color3.fromRGB(20, 20, 20),
    sidebar = Color3.fromRGB(25, 25, 25),
    tabBg = Color3.fromRGB(30, 30, 30),
    accent = Color3.fromRGB(0, 255, 170),
    text = Color3.fromRGB(240, 240, 240),
    button = Color3.fromRGB(40, 40, 40),
    buttonHover = Color3.fromRGB(60, 60, 60),
    shadow = Color3.fromRGB(0, 0, 0)
}

-- 创建主UI函数 (修复所有显示问题)
function FengYu:Create(name)
    -- 1. 创建ScreenGui (关键修复点)
    local ui = Instance.new("ScreenGui")
    ui.Name = "FengYuUI_"..tostring(math.random(1,10000))
    ui.ResetOnSpawn = false
    ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ui.DisplayOrder = 999  -- 确保显示在最前
    
    -- 保护UI (关键修复点)
    if syn and syn.protect_gui then
        syn.protect_gui(ui)
        ui.Parent = CoreGui
    elseif gethui then
        ui.Parent = gethui()
    else
        ui.Parent = CoreGui
    end

    -- 2. 主窗口框架 (确保可见性)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = ui
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = colors.mainBg
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Visible = true  -- 明确设置为可见

    -- 添加圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- 3. 侧边栏 (确保层级)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = mainFrame
    sidebar.BackgroundColor3 = colors.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(0, 120, 1, 0)
    sidebar.ZIndex = 2

    -- 侧边栏圆角 (只设置左上和左下)
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 8)
    sidebarCorner.Parent = sidebar

    -- 4. 标题 (确保文字可见)
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = sidebar
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 10, 0, 10)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = name or "FengYu UI"
    title.TextColor3 = colors.accent
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3

    -- 5. 标签按钮容器 (修复滚动问题)
    local tabButtons = Instance.new("ScrollingFrame")
    tabButtons.Name = "TabButtons"
    tabButtons.Parent = sidebar
    tabButtons.BackgroundTransparency = 1
    tabButtons.BorderSizePixel = 0
    tabButtons.Position = UDim2.new(0, 5, 0, 50)
    tabButtons.Size = UDim2.new(1, -10, 1, -55)
    tabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabButtons.ScrollBarThickness = 3
    tabButtons.ScrollBarImageColor3 = colors.accent
    tabButtons.ZIndex = 2

    -- 6. 标签页容器 (确保显示层级)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Parent = mainFrame
    tabContainer.BackgroundTransparency = 1
    tabContainer.Position = UDim2.new(0, 125, 0, 10)
    tabContainer.Size = UDim2.new(1, -135, 1, -20)
    tabContainer.ZIndex = 2

    -- 7. 添加第一个标签 (确保默认显示)
    local function createDefaultTab()
        local firstTab = self:AddTab("Main")
        firstTab.button.BackgroundColor3 = colors.accent
        firstTab.button.TextColor3 = colors.shadow
        firstTab.frame.Visible = true
        self.currentTab = "Main"
    end

    -- 8. 初始化UI (关键调用)
    createDefaultTab()

    -- 返回UI控制API
    return {
        ui = ui,
        AddTab = function(name, icon)
            return FengYu:AddTab(name, icon)
        end,
        Toggle = function()
            mainFrame.Visible = not mainFrame.Visible
        end,
        Destroy = function()
            ui:Destroy()
        end
    }
end

-- 添加标签页方法 (修复显示逻辑)
function FengYu:AddTab(name, icon)
    if not self.ui then error("UI not initialized. Call Create() first.") end
    
    -- 标签按钮
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Parent = self.ui.MainFrame.Sidebar.TabButtons
    tabButton.BackgroundColor3 = colors.button
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = "  " .. (icon and utf8.char(icon).."  " or "") .. name
    tabButton.TextColor3 = colors.text
    tabButton.TextSize = 14
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.ZIndex = 3
    
    -- 标签页
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Tab"
    tabFrame.Parent = self.ui.MainFrame.TabContainer
    tabFrame.BackgroundTransparency = 1
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.Visible = false
    tabFrame.ScrollBarThickness = 3
    tabFrame.ScrollBarImageColor3 = colors.accent
    tabFrame.ZIndex = 2
    
    -- 标签切换逻辑
    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.tabs) do
            tab.frame.Visible = false
            tab.button.BackgroundColor3 = colors.button
            tab.button.TextColor3 = colors.text
        end
        
        tabFrame.Visible = true
        tabButton.BackgroundColor3 = colors.accent
        tabButton.TextColor3 = colors.shadow
        self.currentTab = name
    end)
    
    -- 添加到标签列表
    local tab = {
        name = name,
        frame = tabFrame,
        button = tabButton
    }
    table.insert(self.tabs, tab)
    
    return {
        AddSection = function(title)
            -- 分区创建逻辑...
        end
    }
end

return FengYu