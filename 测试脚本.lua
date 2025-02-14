local FengY4ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/FengY4/XINXIWANG/refs/heads/main/FengYulibrary.lua"))()
local win = FengY4ui:new("殺脚本")
--
local UITab1 = win:Tab("『用户信息』",'6031097229')

local about = UITab1:section("查看作者信息",true)
about:Label("殺脚本中心")
about:Label("『殺脚本作者』")
about:Button("点击复制作者的QQ号",function()
setclipboard("1926190957")
end)
about:Label("QQ殺脚本主群")
about:Button("点击复制主群",function()
setclipboard("819104139")
end)
about:Label("作者：风御")
about:Label("感谢大家游玩殺脚本")
about:Label("感谢克里姆.exe(sark)发布的脚本")
about:Label("感谢大家支持殺脚本")

local about = UITab1:section("查看玩家信息",true)
about:Label("你的账号年龄:"..player.AccountAge.."天")
about:Label("你的注入器:"..identifyexecutor())
about:Label("你的用户名:"..game.Players.LocalPlayer.Character.Name)
about:Toggle("脚本框架变小一点", "", false, function(state)
        if state then
        game:GetService("CoreGui")["frosty"].Main.Style = "DropShadow"
        else
            game:GetService("CoreGui")["frosty"].Main.Style = "Custom"
        end
    end)
    about:Button("关闭脚本",function()
        game:GetService("CoreGui")["frosty"]:Destroy()
    end)
  
  
local UITab2 = win:Tab("『公告』",'95917771479976')

local about = UITab2:section("『公告』",true)
about:Label("感谢所有支持殺脚本的人")
about:Label("感谢大家游玩殺脚本")
about:Label("主脚本作者『风御 X』")
about:Label("脚本技术支持风御 X")     

local about = UITab2:section("❗️脚本黑名单如下❗️",false)

about:Label("❗️sanic_748❗️")
about:Button("点击复制此黑名单的用户",function()
setclipboard("sanic_748")
end)
about:Label("❗️MYHX57❗️")
about:Button("点击复制福瑞狂的用户名",function()
setclipboard("MYHX57")
end)
about:Label("")
about:Label("")     


local UITab3 = win:Tab("『通用』",'95917771479976')

local about = UITab3:section("『通用』",true)

about:Slider("步行速度!", "WalkSpeed", game.Players.LocalPlayer.Character.Humanoid.WalkSpeed, 16, 400, false, function(Speed)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Speed end end)
end)

about:Slider("跳跃高度!", "JumpPower", game.Players.LocalPlayer.Character.Humanoid.JumpPower, 50, 400, false, function(Jump)
  spawn(function() while task.wait() do game.Players.LocalPlayer.Character.Humanoid.JumpPower = Jump end end)
end)

about:Slider('设置重力', 'Sliderflag', 196.2, 196.2, 1000,false, function(Value)
        game.Workspace.Gravity = Value
end)

about:Toggle("夜视","Toggle",false,function(Value)
if Value then

		    game.Lighting.Ambient = Color3.new(1, 1, 1)

		else

		    game.Lighting.Ambient = Color3.new(0, 0, 0)

		end
end)

about:Toggle("穿墙", "NoClip", false, function(NC)
  local Workspace = game:GetService("Workspace") local Players = game:GetService("Players") if NC then Clipon = true else Clipon = false end Stepped = game:GetService("RunService").Stepped:Connect(function() if not Clipon == false then for a, b in pairs(Workspace:GetChildren()) do if b.Name == Players.LocalPlayer.Name then for i, v in pairs(Workspace[Players.LocalPlayer.Name]:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end end else Stepped:Disconnect() end end)
end)

about:Toggle("人物显示", "RWXS", false, function(RWXS)
    getgenv().enabled = RWXS getgenv().filluseteamcolor = true getgenv().outlineuseteamcolor = true getgenv().fillcolor = Color3.new(1, 0, 0) getgenv().outlinecolor = Color3.new(1, 1, 1) getgenv().filltrans = 0.5 getgenv().outlinetrans = 0.5 loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/RobloxScripts/main/Highlight-ESP.lua"))()
end)

about:Button("旋转",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%97%8B%E8%BD%AC.lua"))()
end)

about:Button("自杀",function()
game.Players.LocalPlayer.Character.Humanoid.Health=0
end)

about:Button("反挂机模式",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/9fFu43FF"))()
end)


local UITab4 = win:Tab("『索尼克灾难』",'95917771479976')

local about = UITab4:section("『灾难脚本』",false)

about:Button("灾难脚本中心",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Biem6ondo/Sonic.exe/refs/heads/main/Encrypted_r1e1m1o1t1e1c1h1e1a1t.txt"))()
end)

local about = UITab4:section("『灾难范围脚本』",false)

about:Button("灾难范围",function()
local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

local secretEnabled = false

local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("AbilityToggles") or Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "AbilityToggles"
screenGui.ResetOnSpawn = false

local secretButton = screenGui:FindFirstChild("SecretButton") or Instance.new("TextButton", screenGui)
secretButton.Name = "SecretButton"
secretButton.Size = UDim2.new(0, 150, 0, 40) -- Smaller size
secretButton.Position = UDim2.new(0, 10, 0, 10)
secretButton.Text = "开启范围(关)"
secretButton.BackgroundColor3 = Color3.new(1, 0, 0)

local sHealButton = screenGui:FindFirstChild("sHealButton") or Instance.new("TextButton", screenGui)
sHealButton.Name = "sHealButton"
sHealButton.Size = UDim2.new(0, 150, 0, 40) -- Smaller size
sHealButton.Position = UDim2.new(0, 10, 0, 60)
sHealButton.Text = "风御翻译"
sHealButton.BackgroundColor3 = Color3.new(1, 1, 0)

spawn(function()
    while true do
        if secretEnabled then
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local args = {
                        [1] = player.Character
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("hitReg"):FireServer(unpack(args))
                end
            end
        end
        wait(0.1)
    end
end)

secretButton.MouseButton1Click:Connect(function()
    secretEnabled = not secretEnabled
    secretButton.Text = "开启范围 (" .. (secretEnabled and "开" or "关") .. ")"
    secretButton.BackgroundColor3 = secretEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

sHealButton.MouseButton1Click:Connect(function()
    local args = {
    [1] = "overheal",
    [2] = workspace:WaitForChild(player.Name)
}

game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("abilities"):FireServer(unpack(args))

end)
end)

about:Button("塔尔斯自瞄",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/FengY4/XINXIWANG/refs/heads/main/Tailsself-aiming.lua"))()
end)

local about = UITab4:section("『无限技能『幸存者』』",false)

about:Button("rouge无限闪光弹",function()
local isTracking = false

local function trackPlayerPositionAndFireTrap()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    while isTracking do
        local position = humanoidRootPart.Position
        local flashbangArgs = {
            [1] = "flashbang",
            [2] = position
        }
        game:GetService("ReplicatedStorage").remotes.abilities:FireServer(unpack(flashbangArgs))

        local drownArgs = {
            [1] = "drown"
        }
        game:GetService("ReplicatedStorage").remotes.actions:FireServer(unpack(drownArgs))

        game:GetService("ReplicatedStorage").remotes.infect:FireServer()

        game:GetService("Players").LocalPlayer.PlayerGui.stats:SetAttribute("isDead", false)

        wait(0.01)
    end
end

local function createToggleButton()
    local player = game.Players.LocalPlayer
    local screenGui = player.PlayerGui:FindFirstChild("ScreenGui")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ScreenGui"
        screenGui.Parent = player.PlayerGui
    end

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 60)
    button.Text = "rouge无限闪光弹"
    button.Parent = screenGui

    button.MouseButton1Click:Connect(function()
        if isTracking then
            isTracking = false
            button.Text = "开启 rouge无限闪光弹"
        else
            isTracking = true
            button.Text = "停止 rouge无限闪光弹"
            trackPlayerPositionAndFireTrap()  -- No username argument needed
        end
    end)
end

createToggleButton()
end)

about:Button("小银无限能量墙",function()
local isTracking = false
local function performActions()
    local player = game.Players.LocalPlayer
    if player then
        local remotes = game.ReplicatedStorage.remotes
        remotes.actions:FireServer("drown")
        remotes.infect:FireServer()
        player.PlayerGui.stats:SetAttribute("isDead", false)
    end
end

local function fireBarriers()
    while isTracking do
        performActions()
        game.ReplicatedStorage.remotes.abilities:FireServer("barrier")
        wait(0.01)
        local player = game.Players.LocalPlayer
        local pos = player.Character.HumanoidRootPart.Position
        game.ReplicatedStorage.remotes.abilities:FireServer("placeBarrier", CFrame.new(pos) * CFrame.Angles(math.pi, 0.4, -math.pi))
        wait(0.01)
        game.ReplicatedStorage.remotes.abilities:FireServer("cancelBarrier")
        wait(0.01)
    end
end

local function createToggleButton()
    local player = game.Players.LocalPlayer
    local screenGui = player.PlayerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", player.PlayerGui)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 60)
    button.Text = "小银无限能量墙"
    button.Parent = screenGui
    button.MouseButton1Click:Connect(function()
        isTracking = not isTracking
        button.Text = isTracking and "停止 小银无限能量墙" or "开启 小银无限能量墙"
        if isTracking then fireBarriers() end
    end)
end

createToggleButton()
end)

local UITab5 = win:Tab("『造船寻宝』",'7734068321')

local about = UITab5:section("『造船寻宝』",true)

about:Button("造船寻宝1",function()
loadstring(game:HttpGet("http://dirtgui.xyz/BuildABoat.lua",true))()
end)

about:Button("造船寻宝2",function()
loadstring(game:HttpGet("https://pastefy.app/hvV1c4nO/raw"))()
end)

about:Button("复制别人的船",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/max2007killer/auto-build-not-limit/main/autobuild.txt"))()
end)

about:Button("刷钱",function()
loadstring(game:HttpGet(('https://raw.githubusercontent.com/urmomjklol69/GoldFarmBabft/main/GoldFarm.lua'),true))()
end)

about:Toggle("自动刷钱", false, function(value)
    getgenv().FengYu = {
    Enabled = value,
    Teleport = 2,
    TimeBetweenRuns = 5
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local autoFarm = function(currentRun)
    local Character = LocalPlayer.Character
    local NormalStages = Workspace.BoatStages.NormalStages

    for i = 1, 10 do
        local Stage = NormalStages["CaveStage" .. i]
        local DarknessPart = Stage:FindFirstChild("DarknessPart")

        if (DarknessPart) then
            
            print("Teleporting to next stage: Stage " .. i)
            Character.HumanoidRootPart.CFrame = DarknessPart.CFrame

            
            local Part = Instance.new("Part", LocalPlayer.Character)
            Part.Anchored = true
            Part.Position = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 6, 0)

            
            wait(getgenv().TreasureAutoFarm.Teleport)
            Part:Destroy()
        end
    end

    print("Teleporting to the end")
    repeat wait()
        Character.HumanoidRootPart.CFrame = NormalStages.TheEnd.GoldenChest.Trigger.CFrame
    until Lighting.ClockTime ~= 14

    
    local Respawned = false
    local Connection
    Connection = LocalPlayer.CharacterAdded:Connect(function()
        Respawned = true
        Connection:Disconnect()
    end)

    repeat wait() until Respawned
    wait(getgenv().TreasureAutoFarm.TimeBetweenRuns)
    print("Auto Farm: Run " .. currentRun .. " finished")
end

local autoFarmRun = 1
while wait() do
    if (getgenv().TreasureAutoFarm.Enabled) then
        print("Initialising Auto Farm: Run " .. autoFarmRun)
        autoFarm(autoFarmRun)
        autoFarmRun = autoFarmRun + 1
    end
end
end)