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

if isfunctionhooked(game.HttpGet) or isfunctionhooked(request) or isfunctionhooked(game.HttpPost) then
    while true do end
end
                 
local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
bb:CaptureController()
bb:ClickButton2(Vector2.new())
end)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
wait(1)
vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local Ghost = {
  ["透视颜色"] = Color3.fromRGB(255, 255, 255),
  ["透视名字"] = false,
  ["透视血量"] = false,
  ["透视开关"] = false,
  ["圆圈颜色"] = Color3.fromRGB(255, 255, 255),
  ["自瞄距离"] = 200,
  ["自瞄开关"] = false,
}
local Colors = {
  ["红"] = Color3.fromRGB(255, 0, 0),
  ["橙"] = Color3.fromRGB(255, 150, 0),
  ["黄"] = Color3.fromRGB(255, 255, 15),
  ["绿"] = Color3.fromRGB(0, 255, 0),
  ["青"] = Color3.fromRGB(0, 255, 219),
  ["蓝"] = Color3.fromRGB(0, 0, 255),
  ["紫"] = Color3.fromRGB(183, 0, 255),
  ["彩色"] = nil
}
local P = game:GetService("Players")
local L = P.LocalPlayer
local C = workspace.CurrentCamera
local Circle = Drawing.new("Circle")
Circle.Filled = false
Circle.Position = C.ViewportSize / 2
Circle.Radius = 100
Circle.Thickness = 1
Circle.Visible = false

local function AddESP(part, color, text, enabled)
  local hl = part:FindFirstChild("Highlight")
  local bg = part:FindFirstChild("BillboardGui")
  if not hl then
    local HL = Instance.new("Highlight", part)
    HL.FillColor = color
    HL.FillTransparency = 0.5
    HL.Enabled = enabled
   else
    local HL = hl
    HL.FillColor = color
    HL.Enabled = enabled
  end
  if not bg then
    local BG = Instance.new("BillboardGui", workspace)
    BG.AlwaysOnTop = true
    BG.Size = UDim2.new(0, 100, 0, 50)
    BG.StudsOffset = Vector3.new(0, 4, 0)
    BG.Enabled = enabled
    local TL = Instance.new("TextLabel", BG)
    TL.BackgroundTransparency = 1
    TL.Size = UDim2.new(0, 100, 0, 50)
    TL.Text = text
    TL.TextSize = 10
    TL.TextColor3 = color
    TL.Parent = BG
    BG.Parent = part
   else
    local BG = bg
    local TL = BG:FindFirstChild("TextLabel")
    TL.Text = text
    TL.TextColor3 = color
    BG.Enabled = enabled
  end
end

function lookAt(a, b)
  C.CFrame = CFrame.new(a, b)
end

function getClosestPlayerToCursor(trg_part)
  local nearest = nil
  for i,v in pairs(P:GetPlayers()) do
    if v ~= L and L and v.Character and v.Character:FindFirstChild(trg_part) then
      if L.Character:FindFirstChild(trg_part) then
        local ePos, vissss = C:WorldToViewportPoint(v.Character[trg_part].Position)
        local AccPos = Vector2.new(ePos.x, ePos.y)
        local mousePos = Vector2.new(C.ViewportSize.x / 2, C.ViewportSize.y / 2)
        local distance = (AccPos - mousePos).magnitude
        if vissss and distance < Circle.Radius then
          nearest = v
        end
      end
    end
  end
  return nearest
end

game:GetService("RunService").Heartbeat:Connect(function()
  if not L.Character then return end
  local h = (tick() % 5) / 5
  local t = ""
  for a, b in next, P:GetPlayers() do
    AddESP(b.Character, (Ghost["透视颜色"] or Color3.fromHSV(h, 1, 1)), (Ghost["透视名字"] and ("名字" .. b.Name) or "") .. (Ghost["透视血量"] and ("\n血量:" .. math.round(b.Character.Humanoid.Health)) or ""), Ghost["透视开关"])
  end
  Circle.Color = Ghost["圆圈颜色"] or Color3.fromHSV(h, 1, 1)
  local closest = getClosestPlayerToCursor("Head")
  if Ghost["自瞄开关"] and closest and closest.Character:FindFirstChild("Head") and (L.Character.HumanoidRootPart.Position - closest.Character.HumanoidRootPart.Position).Magnitude <= Ghost["自瞄距离"] then
    lookAt(C.CFrame.p, closest.Character:FindFirstChild("Head").Position)
  end
end)

local function scripts()	

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/FengYu-ui/refs/heads/main/Fengui.lua", true))()
----------------------------------------------------------------------------------------------------------------------------------------
local window = library:new("殺脚本")--测试版本
----------------------------------------------------------------------------------------------------------------------------------------

local creds = window:Tab("『关于』", "6031097229")
    local bin = creds:section("『作者信息』", true)
    
    bin:Label("作者：风御 X")    

    bin:Button("脚本主群", function()
    setclipboard("819104139")
end)
    

    local credits = creds:section("『UI设置』", true)

credits:Toggle("脚本框架变小一点", "", false, function(state)
        if state then
        game:GetService("CoreGui")["frosty"].Main.Style = "DropShadow"
        else
            game:GetService("CoreGui")["frosty"].Main.Style = "Custom"
        end
    end)
    
        credits:Button("扔出去",function()
            game:GetService("CoreGui")["frosty"]:Destroy()
    end)

local creds = window:Tab("『通用区』",'6031097229')

local credits = creds:section("『修改区』",false)
    credits:Textbox("快速跑步(推荐调2)", "tpwalking", "输入", function(king)
local tspeed = king
local hb = game:GetService("RunService").Heartbeat
local tpwalking = true
local player = game:GetService("Players")
local lplr = player.LocalPlayer
local chr = lplr.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
while tpwalking and hb:Wait() and chr and hum and hum.Parent do
  if hum.MoveDirection.Magnitude > 0 then
    if tspeed then
      chr:TranslateBy(hum.MoveDirection * tonumber(tspeed))
    else
      chr:TranslateBy(hum.MoveDirection)
    end
  end
end
end)
    
credits:Slider('修改速度', 'WalkspeedSlider', 16, 16, 99999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end)

    credits:Slider('修改跳跃', 'JumpPowerSlider', 50, 50, 99999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)
    
    credits:Slider('修改重力', 'GravitySlider', 198, 198, 99999,false,function(Value)
    game.Workspace.Gravity = Value
end)
    
credits:Textbox("重力设置", "Gravity", "输入", function(Gravity)
  spawn(function() while task.wait() do game.Workspace.Gravity = Gravity end end)
end)
    
    credits:Slider('修改高度', 'Slider', 0, 0, 9999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.HipHeight = Value
end)
    
    credits:Slider('相机焦距上限', 'ZOOOOOM OUT!',  128, 128, 200000,false, function(Value)
    game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = Value
end)
    
    credits:Slider('相机焦距【正常为70】', 'Sliderflag', 70, 0.1, 250, false, function(v)
        game.Workspace.CurrentCamera.FieldOfView = v
end)
    
    credits:Slider('健康值上限', 'Sliderflag',  120, 120, 999999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.MaxHealth = Value
end)
    
    credits:Slider('玩家健康值', 'Sliderflag',  120, 120, 999999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.Health = Value
end)
 
local credits = creds:section("『通用区』",false)
    
credits:Toggle("穿墙", "NoClip", false, function(NC)
  local Workspace = game:GetService("Workspace") local Players = game:GetService("Players") if NC then Clipon = true else Clipon = false end Stepped = game:GetService("RunService").Stepped:Connect(function() if not Clipon == false then for a, b in pairs(Workspace:GetChildren()) do if b.Name == Players.LocalPlayer.Name then for i, v in pairs(Workspace[Players.LocalPlayer.Name]:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end end else Stepped:Disconnect() end end)
    end)
    
credits:Toggle("自动互动", "Auto Interact", false, function(state)
        if state then
            autoInteract = true
            while autoInteract do
                for _, descendant in pairs(workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        fireproximityprompt(descendant)
                    end
                end
                task.wait(0.25) -- Adjust the wait time as needed
            end
        else
            autoInteract = false
        end
    end)
    
credits:Toggle("夜视脚本", "", false, function(state)
        if state then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        else
            game.Lighting.Ambient = Color3.new(0, 0, 0)
        end
    end)
    
credits:Button("控制npc",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/fe-source/refs/heads/main/NPC/source/main.Luau"))()
end)
 
    credits:Button(
        "自杀脚本",
        function()
            game.Players.LocalPlayer.Character.Humanoid.Health=0
HumanDied = true
        end
    )    
    
credits:Button("翻跟斗",function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-super-awesome-backflip-31143"))()
end)
    
credits:Button("殺飞行",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengY4/FengY4/refs/heads/main/%E6%AE%BA%E9%A3%9E%E8%A1%8C.lua"))()
end)
    
credits:Button("聊天画画",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ocfi/_/refs/heads/main/a"))()
end)
    
credits:Button("无限跳",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
end)
    
credits:Button(
        "指令脚本",
        function()
            loadstring(game:HttpGet(('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'),true))()
        end
    )
    
credits:Button("玩家加入游戏提示",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/boyscp/scriscriptsc/main/bbn.lua"))()
end)
    
credits:Button("显示FPS", function()
local ScreenGui = Instance.new("ScreenGui")
local FpsLabel = Instance.new("TextLabel")

ScreenGui.Name = "FPSGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

FpsLabel.Name = "FPSLabel"
FpsLabel.Size = UDim2.new(0, 100, 0, 50)
FpsLabel.Position = UDim2.new(0.75,20,0.075,20)--位置
FpsLabel.BackgroundTransparency = 1
FpsLabel.Font = Enum.Font.SourceSansBold
FpsLabel.Text = "FPS: 0"
FpsLabel.TextSize = 30
FpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255) --颜色
FpsLabel.Parent = ScreenGui

local frameCounter = 0

function updateFpsLabel()
    frameCounter = frameCounter + 1
    if frameCounter >= 20 then -- 20帧
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        FpsLabel.Text = "FPS: " .. fps
        frameCounter = 0
    end
end

game:GetService("RunService").RenderStepped:Connect(updateFpsLabel)

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end)
  
credits:Button("偷物品",function()
    for i,v in pairs (game.Players:GetChildren()) do
wait()
for i,b in pairs (v.Backpack:GetChildren()) do
b.Parent = game.Players.LocalPlayer.Backpack
end
end
end)
  
credits:Button("飞檐走壁",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)
    
credits:Button("踏空行走",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float'))()
end)
    
local credits = creds:section("『传送区』",false)
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

local Players = credits:Dropdown("选择玩家的名称", 'Dropdown', LS.dropdown, function(v)
    LS.playernamedied = v
end)

credits:Button("刷新玩家名称", function()
    shuaxinlb(true)
    Players:SetOptions(LS.dropdown)
end)

credits:Button("传送到玩家旁边", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(LS.playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        HumRoot.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        Notify("殺脚本", "已传送到玩家旁边", "rbxassetid://84830962019412", 5)
    else
        Notify("殺脚本", "无法传送 玩家已消失", "rbxassetid://84830962019412", 5)
    end
end)

credits:Toggle("锁定传送", "Loop", false, function(state)
    if state then
        LS.LoopTeleport = true
        Notify("殺脚本", "已开启循环传送", "rbxassetid://84830962019412", 5)
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
        Notify("殺脚本", "已关闭循环传送", "rbxassetid://84830962019412", 5)
    end
end)

credits:Button("把玩家传送过来", function()
    local HumRoot = game.Players.LocalPlayer.Character.HumanoidRootPart
    local tp_player = game.Players:FindFirstChild(LS.playernamedied)
    if tp_player and tp_player.Character and tp_player.Character.HumanoidRootPart then
        tp_player.Character.HumanoidRootPart.CFrame = HumRoot.CFrame + Vector3.new(0, 3, 0)
        Notify("殺脚本", "已将玩家传送过来", "rbxassetid://84830962019412", 5)
    else
        Notify("殺脚本", "无法传送 玩家已消失", "rbxassetid://84830962019412", 5)
    end
end)

credits:Toggle("循环传送玩家过来", "Loop", false, function(state)
    if state then
        LS.LoopTeleport = true
        Notify("殺脚本", "已开启循环传送玩家过来", "rbxassetid://84830962019412", 5)
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
        Notify("殺脚本", "已关闭循环传送玩家过来", "rbxassetid://84830962019412", 5)
    end
end)

credits:Toggle("查看玩家", "look player", false, function(state)
    if state then
        game:GetService('Workspace').CurrentCamera.CameraSubject =
            game:GetService('Players'):FindFirstChild(LS.playernamedied).Character.Humanoid
        Notify("殺脚本", "已开启查看玩家", "rbxassetid://84830962019412", 5)
    else
        local lp = game.Players.LocalPlayer
        game:GetService('Workspace').CurrentCamera.CameraSubject = lp.Character.Humanoid
        Notify("殺脚本", "已关闭查看玩家", "rbxassetid://84830962019412", 5)
    end
end)   
 
local credits = creds:section("透视区",false)

credits:Toggle("开启透视", "e5", false, function(a)
  Ghost["透视开关"] = a
end)

credits:Dropdown("选择透视颜色", "e1", {"红", "橙", "黄", "绿", "青", "蓝", "紫", "彩色"}, function(a)
  Ghost["透视颜色"] = Colors[a]
end)

credits:Toggle("透视名字", "e2", false, function(a)
  Ghost["透视名字"] = a
end)

credits:Toggle("透视血量", "e3", false, function(a)
  Ghost["透视血量"] = a
end)
  
local credits = creds:section("自瞄区",false)

credits:Toggle("自瞄开关", "a6", false, function(a)
  Ghost["自瞄开关"] = a
end)

credits:Toggle("圆圈开关", "a4", false, function(a)
  Circle.Visible = a
end)

credits:Dropdown("圆圈颜色", "a2", {"红", "橙", "黄", "绿", "青", "蓝", "紫", "彩色"}, function(a)
  Ghost["圆圈颜色"] = Colors[a]
end)

credits:Slider("圆圈大小", "a1", 100, 0, 150, false, function(a)
  Circle.Radius = a
end)

credits:Slider("圆圈厚度", "a3", 1, 0, 15, false, function(a)
  Circle.Thickness = a
end)

credits:Slider("自瞄距离", "a5", 200, 0, 800, false, function(a)
  Ghost["自瞄距离"] = a
end)
  
local credits = creds:section("旋转区",false)

credits:Label("只有两个其他没加")
credits:Textbox("旋转速度", "SpinSpeed", "输入", function(Value)
    local speed = tonumber(Value)
    local plr = game:GetService("Players").LocalPlayer
    repeat task.wait() until plr.Character
    local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    local humanoid = plr.Character:WaitForChild("Humanoid")
    humanoid.AutoRotate = false

    if not spinVelocity then
        spinVelocity = Instance.new("AngularVelocity")
        spinVelocity.Attachment0 = humRoot:WaitForChild("RootAttachment")
        spinVelocity.MaxTorque = math.huge
        spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
        spinVelocity.Parent = humRoot
        spinVelocity.Name = "Spinbot"
    else
        spinVelocity.AngularVelocity = Vector3.new(0, speed, 0)
    end
end)

credits:Button("停止旋转", function()
    local plr = game:GetService("Players").LocalPlayer
    repeat task.wait() until plr.Character
    local humRoot = plr.Character:WaitForChild("HumanoidRootPart")
    local humanoid = plr.Character:WaitForChild("Humanoid")

    local spinbot = humRoot:FindFirstChild("Spinbot")
    if spinbot then
        spinbot:Destroy()
        spinVelocity = nil
    end
    humanoid.AutoRotate = true 
end)
  
local credits = creds:section("『甩飞区』",false)

credits:Button("旋转甩飞",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%97%8B%E8%BD%AC.lua"))()
end)
    
credits:Button("碰到就飞",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/0Ben1/fe./main/Fling%20GUI"))()
end)
    
credits:Button("甩飞所有人",function()
loadstring(game:HttpGet("https://pastebin.com/raw/zqyDSUWX"))()
end)
   
credits:Button("铁拳",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_rf6iQURzu1fqrytcnLBAvW34C9N55kS9g9G3CKz086rC47M6632sEd4ZZYB0AYgV.lua.txt'))()
end)
    
credits:Button("输入名字起飞",function()
loadstring(game:HttpGet(('https://pastefy.app/9SmQXduA/raw'),true))()
end)
    
local credits = creds:section("『恶搞区』",false)
   
    credits:Button(
        "直升机",
        function()
            if game.Players.LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://27432686"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=165113352"
hi.Volume = 2
hi.Looped = true
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()

local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)

end)
else
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://507776043"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=165113352"
hi.Volume = 2
hi.Looped = true
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()

local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)


end)    
end
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local u = game.Players.LocalPlayer
local urchar = u.Character

task.spawn(function()


qUp = Mouse.KeyUp:Connect(function(KEY)
if KEY == 'q' then
urchar.Humanoid.HipHeight = urchar.Humanoid.HipHeight - 3
end
end)
eUp = Mouse.KeyUp:Connect(function(KEY)
if KEY == 'e' then
urchar.Humanoid.HipHeight = urchar.Humanoid.HipHeight + 3
end
end)


end)
        end
    )    
    
  credits:Button("人物螺旋上天",function()
    if game.Players.LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://27432686"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=8114290584"
hi.Volume = 2
hi.Looped = false
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()
wait(1.5)
local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
wait(3.5)
while speaker.Character.Humanoid.Health > 0 do
   wait(0.1)
speaker.Character.Humanoid.HipHeight = speaker.Character.Humanoid.HipHeight + 1
end
end)
else
spawn(function()
local speaker = game.Players.LocalPlayer
local Anim = Instance.new("Animation")
     Anim.AnimationId = "rbxassetid://507776043"
     local bruh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
bruh:Play()
bruh:AdjustSpeed(0)
speaker.Character.Animate.Disabled = true
local hi = Instance.new("Sound")
hi.Name = "Sound"
hi.SoundId = "http://www.roblox.com/asset/?id=8114290584"
hi.Volume = 2
hi.Looped = false
hi.archivable = false
hi.Parent = game.Workspace
hi:Play()
wait(1.5)
local spinSpeed = 40
local Spin = Instance.new("BodyAngularVelocity")
Spin.Name = "Spinning"
Spin.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
Spin.MaxTorque = Vector3.new(0, math.huge, 0)
Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
wait(3.5)
while speaker.Character.Humanoid.Health > 0 do
   wait(0.1)
speaker.Character.Humanoid.HipHeight = speaker.Character.Humanoid.HipHeight + 1
end
end)    
end
end)
  
credits:Button("撸管r6",function()
    loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
end)
    
credits:Button("撸管r15",function()
    loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
end)
    
credits:Button("演都不演了",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengY4/FengY4/refs/heads/main/DVD.lua"))()
end)
 
local creds = window:Tab("『FE(能用)』",'7733765398')

local credits = creds:section("功能",false)
    credits:Button("C00lgui",function()
    loadstring(game:GetObjects("rbxassetid://8127297852")[1].Source)()
end)
 
credits:Button("好玩的FE脚本",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sypcerr/FECollection/refs/heads/main/script.lua",true))()
end)

credits:Button("VR视角",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty45.lua"))()
end)

credits:Button("获取念力工具",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/dbcy7SHF"))()
end)
  
credits:Button("FE抓取",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty1.lua"))()
end)
 
    credits:Button("FE传送",function()
    mouse = game.Players.LocalPlayer:GetMouse() tool = Instance.new("Tool") tool.RequiresHandle = false tool.Name = "[FE] TELEPORT TOOL" tool.Activated:connect(function() local pos = mouse.Hit+Vector3.new(0,2.5,0) pos = CFrame.new(pos.X,pos.Y,pos.Z) game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos end) tool.Parent = game.Players.LocalPlayer.Backpack
end)
    
credits:Button("FE一把剑",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FengY4/FengY4/refs/heads/main/%E4%B8%80%E6%8A%8A%E5%89%91%20FE.lua"))()
end)
 
    credits:Button("手枪『只是模型』",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Er5cfTr3"))()
end)
   
credits:Button("变天使",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/RaXbiByH"))()
end)
 
local creds = window:Tab("『光影画质』",'7733765398')
local credits = creds:section("『功能』", true)
credits:Button(
        "光影1",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
        end
    )
   
   credits:Button(
        "光影2",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
        end
    )
    
credits:Button(
        "光影3",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
        end
    )

credits:Button(
        "画质光影",
        function()
            loadstring(game:HttpGet("https://pastebin.com/raw/jHBfJYmS"))()
        end
    )   
   
   credits:Button(
        "普通光影",
        function()
            loadstring(game:HttpGet("https://pastebin.com/raw/jHBfJYmS"))()
        end
    )
    
   credits:Button(
        "深色光影",
        function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml"))()
        end
    )
    
local creds = window:Tab("『其他脚本』",'6031097229')

local credits = creds:section("『推荐脚本』",true)

credits:Button("叶脚本",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
end)

local creds = window:Tab("『音乐』",'6031097229')

local credits = creds:section("『音乐播放』",true)

credits:Button("防空警报", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://792323017"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    
credits:Button("义勇军进行曲", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1845918434"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    
    credits:Button("雨中流浪", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://1683110839393"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    credits:Button("米老鼠", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://8491769438"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    
    credits:Button("骨灰给你扬了", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://7691078503"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    
    credits:Button("齐天大圣", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://8195914641"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    
    credits:Button("卡车鸣笛", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3900067524"
    sound.Parent = game.Workspace
    sound:Play()
    end)
    
    credits:Button("算命先生", function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6086894326"
    sound.Parent = game.Workspace
    sound:Play()
    end)
