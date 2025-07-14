-- 主脚本
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/FengYu-ui/refs/heads/main/Fengui.lua"))()

-- 创建 UI
local window = library.new(library, "传送测试", 'dark')
local mainTab = window:Tab("玩家传送", "84830962019412")

-- 添加玩家传送功能部分
local playerSection = mainTab:section("玩家传送", true)

-- 玩家列表变量
local dropdown = {}
local playernamedied = ""

-- 玩家列表下拉框
local Players = playerSection:Dropdown("选择玩家", 'Dropdown', dropdown, function(v)
    playernamedied = v
end)

-- 玩家加入/离开事件处理
game.Players.ChildAdded:Connect(function(player)
    dropdown[player.UserId] = player.Name
    Players:AddOption(player.Name)
end)

game.Players.ChildRemoved:Connect(function(player)
    Players:RemoveOption(player.Name)
    for k, v in pairs(dropdown) do
        if v == player.Name then
            dropdown[k] = nil
        end
    end
end)

-- 传送按钮
playerSection:Button("传送到玩家旁边", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        library.Notify("冷", "已经传送到玩家身边", "rbxassetid://", 5)
    else
        library.Notify("冷", "无法传送 玩家已消失", "rbxassetid://", 5)
    end
end)

playerSection:Button("把玩家传送过来", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        tp_player.Character.HumanoidRootPart.CFrame = HumRoot.CFrame + Vector3.new(0, 3, 0)
        library.Notify("冷", "已传送过来", "rbxassetid://", 5)
    else
        library.Notify("冷", "无法传送 玩家已消失", "rbxassetid://", 5)
    end
end)

-- 查看玩家切换按钮
playerSection:Toggle("查看玩家", 'Toggleflag', false, function(state)
    if state then
        game:GetService('Workspace').CurrentCamera.CameraSubject =
            game:GetService('Players'):FindFirstChild(playernamedied).Character.Humanoid
        library.Notify("冷", "已开启", "rbxassetid://", 5)
    else
        library.Notify("冷", "已关闭", "rbxassetid://", 5)
        local lp = game.Players.LocalPlayer
        game:GetService('Workspace').CurrentCamera.CameraSubject = lp.Character.Humanoid
    end
end)