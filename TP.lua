game:GetService("Players").LocalPlayer.Idled:connect(function()
game:GetService("VirtualUser"):CaptureController()
game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
 
local dropdown = {}
local playernamedied = ""

for i, player in pairs(game.Players:GetPlayers()) do
    dropdown[i] = player.Name
end
local LS = {
    playernamedied = "",
    dropdown = {},
    sayCount = 1,
    sayFast = false,
    autoSay = false,
}

--传送与甩飞玩家
function shuaxinlb(zji)
    LS.dropdown = {}
    if zji == true then
        for _, player in pairs(game.Players:GetPlayers()) do
            table.insert(LS.dropdown, player.Name)
        end
    else
        local lp = game.Players.LocalPlayer
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= lp then
                table.insert(LS.dropdown, player.Name)
            end
        end
    end
end
shuaxinlb(true)

function Notify(top, text, ico, dur)
  game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = top,
    Text = text,
    Icon = ico,
    Duration = dur,
  })
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/66YEUIUI.txt", true))()
----------------------------------------------------------------------------------------------------------------------------------------
local window = library:new("殺脚本(测试版)")--V8
----------------------------------------------------------------------------------------------------------------------------------------

 local xiaoye = window:Tab("传送与甩飞玩家",'18930406865')

local Select = xiaoye:section("传送与甩飞玩家",true)
local dropdown = {}
local playernamedied = ""
local teleportConnection
local behindTeleportDistance = 3 
local headTeleportHeight = 4 


for i, player in pairs(game.Players:GetPlayers()) do
    dropdown[i] = player.Name
end


function Notify(top, text, ico, dur)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = top,
        Text = text,
        Icon = ico,
        Duration = dur,
    })
end

local Players = Select:Dropdown("选择玩家的名称", 'Dropdown', LS.dropdown, function(v)
    LS.playernamedied = v
end)

Select:Button("刷新玩家名称", function()
    shuaxinlb(true)
    Players:SetOptions(LS.dropdown)
end)

Select:Button("传送到玩家旁边", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(LS.playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Notify("脚本", "已传送到玩家旁边", "rbxassetid://", 5)
    else
        Notify("脚本", "无法传送 玩家已消失", "rbxassetid://", 5)
    end
end)

Select:Toggle("锁定传送", "Loop", false, function(state)
    if state then
        LS.LoopTeleport = true
        Notify("脚本", "已开启循环传送", "rbxassetid://", 5)
        while LS.LoopTeleport do
            local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
            local tp_player = game.Players:FindFirstChild(LS.playernamedied)
            if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
                HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
            wait()
        end
    else
        LS.LoopTeleport = false
        Notify("脚本", "已关闭循环传送", "rbxassetid://", 5)
    end
end)

Select:Button("把玩家传送过来", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(LS.playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        tp_player.Character.HumanoidRootPart.CFrame = HumRoot.CFrame + Vector3.new(0, 3, 0)
        Notify("脚本", "已将玩家传送过来", "rbxassetid://", 5)
    else
        Notify("脚本", "无法传送 玩家已消失", "rbxassetid://", 5)
    end
end)

Select:Toggle("循环传送玩家过来", "Loop", false, function(state)
    if state then
        LS.LoopTeleport = true
        Notify("脚本", "已开启循环传送玩家过来", "rbxassetid://", 5)
        while LS.LoopTeleport do
            local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
            local tp_player = game.Players:FindFirstChild(LS.playernamedied)
            if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
                tp_player.Character.HumanoidRootPart.CFrame = HumRoot.CFrame + Vector3.new(0, 3, 0)
            end
            wait()
        end
    else
        LS.LoopTeleport = false
        Notify("脚本", "已关闭循环传送玩家过来", "rbxassetid://", 5)
    end
end)

Select:Toggle("查看玩家", "look player", false, function(state)
    if state then
        game:GetService('Workspace').CurrentCamera.CameraSubject =
            game:GetService('Players'):FindFirstChild(LS.playernamedied).Character.Humanoid
        Notify("脚本", "已开启查看玩家", "rbxassetid://", 5)
    else
        local lp = game.Players.LocalPlayer
        game:GetService('Workspace').CurrentCamera.CameraSubject = lp.Character.Humanoid
        Notify("脚本", "已关闭查看玩家", "rbxassetid://", 5)
    end
end)   