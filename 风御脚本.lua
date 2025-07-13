if getgenv().ED_AntiKick then
	return
end

getgenv().ED_AntiKick = {
	Enabled = true, -- Set to false if you want to disable the Anti-Kick.
	SendNotifications = true, -- Set to true if you want to get notified for every event
	CheckCaller = true -- Set to true if you want to disable kicking by other executed scripts
}
                warn("Anti afk running")
game:GetService("Players").LocalPlayer.Idled:connect(function()
warn("Anti afk ran")
game:GetService("VirtualUser"):CaptureController()
game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)
local drop
local function dealerships()
local tables = {"Dealerships"}
for i,v in pairs(workspace.Etc.Dealership:GetChildren()) do
    if v.ClassName == "Model" then
    table.insert(tables,v.Name)
end
end
return tables
end
getfenv().grav = workspace.Gravity
local bai = {
    axedupe = false,
    soltnumber = "1",
    waterwalk = false,
    awaysday = false,
    awaysdnight = false,
    nofog = false,
    axeflying = false,
    playernamedied = "",
    tptree = "",
    moneyaoumt = 1,
    moneytoplayername = "",
    donationRecipient = tostring(game.Players.LocalPlayer),
    autodropae = false,
    farAxeEquip = nil,
    cuttreeselect = "Generic",
    autofarm = false,
    PlankToBlueprint = nil,
    plankModel = nil,
    blueprintModel = nil,
    saymege = "",
    autosay = false,
    saymount = 1,
    sayfast = false,
    autofarm1 = false,
    bringamount = 1,
    bringtree = false,
    dxmz = "",
    color = 0,
    0,
    0,
    zlwjia = "",
    mtwjia = nil,
    zix = 1,
    zlz = 3,
    axeFling = nil,
    itemtoopen = "",
    openItem = nil,
    car = nil,
    load = false,
    autobuyamount = 1,
    autopick = false,
    loaddupeaxewaittime = 3.1,
    walkspeed = 16,
    JumpPower = 50,
    pickupaxeamount = 1,
    whthmose = false,
    itemset = nil,
    LoneCaveAxeDetection = nil,
    cuttree = false,
    LoneCaveCharacterAddedDetection = nil,
    LoneCaveDeathDetection = nil,
    lovecavecutcframe = nil,
    lovecavepast = nil,
    zlmt = nil,
    shuzhe = false,
    modwood = false,
    tchonmt = nil,
    cskais = false,
    dledetree = false,
    delereeset = nil,
    treecutset = nil,
    autobuyset = nil,
    wood = 7,
    cswjia = nil,
    boxOpenConnection = nil,
    autobuystop = flase,
    dropdown = {},
    autocsdx = nil,
    kuangxiu = nil,
    xzemuban = false,
    daiwp = false,
    stopcar = false
}
 
local dropdown = {}
local playernamedied = ""

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

getgenv().SheriffAim = false;
getgenv().GunAccuracy = 25;

local GunHook
GunHook = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }
        if not checkcaller() then
                if typeof(self) == "Instance" then
                        if self.Name == "ShootGun" and method == "InvokeServer" then
                                if getgenv().SheriffAim and getgenv().GunAccuracy then
                                        if Murderer then
                                                local Root = Players[tostring(Murder)].Character.PrimaryPart;
                                                local Veloc = Root.AssemblyLinearVelocity;
                                                local Pos = Root.Position + (Veloc * Vector3.new(getgenv().GunAccuracy / 200, 0, getgenv().GunAccuracy/ 200));
                                                args[2] = Pos;
                                        end;
                                end;
                        end;
                end;
        end;
        return GunHook(self, unpack(args));
end);
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-3/FengYu-ui/refs/heads/main/Fengui.lua", true))()
----------------------------------------------------------------------------------------------------------------------------------------
local window = library:new("殺脚本(测试版)")--V1
----------------------------------------------------------------------------------------------------------------------------------------

local creds = window:Tab("关于", "6031097229")
    local bin = creds:section("信息", true)
    
    bin:Label("欢迎大家使用殺脚本")
    bin:Label("我自己用手搓出来的脚本")
    bin:Label("此脚本更偏向于通用")
    bin:Label("不好用的话也别吐槽")
    bin:Label("我只是不想让大家偏向于恶俗")
    bin:Label("禁止倒卖")
    bin:Label("感谢支持")
    
    bin:Button("脚本主群", function()
    setclipboard("819104139")
end)
    
    bin:Label("作者：风御")    
    bin:Label("原创：单殺『现已退游』")

    bin:Label("脚本代理：星河入梦")    
    
    bin:Button("QQ号", function()
    setclipboard("192564182")
end)
    

    local credits = creds:section("Ul设置", true)

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

local creds = window:Tab("通用",'6031097229')

local credits = creds:section("其他",true)
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
    
    credits:Slider('修改跳跃', 'JumpPowerSlider', 50, 50, 99999,false, function(Value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
end)
    
    credits:Slider('修改重力', 'GravitySlider', 198, 198, 99999,false,function(Value)
    game.Workspace.Gravity = Value
end)
    
credits:Textbox("重力设置", "Gravity", "输入", function(Gravity)
  spawn(function() while task.wait() do game.Workspace.Gravity = Gravity end end)
end)
    
    credits:Slider('修改高度', 'Slider', 1, 1, 9999,false, function(Value)
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
 
local credits = creds:section("通用脚本",true)
    
    credits:Toggle("Circle ESP", "ESP", false, function(state)
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if state then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.Adornee = player.Character

                    local billboard = Instance.new("BillboardGui")
                    billboard.Parent = player.Character
                    billboard.Adornee = player.Character
                    billboard.Size = UDim2.new(0, 100, 0, 100)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Parent = billboard
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = player.Name
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.TextStrokeTransparency = 0.5
                    nameLabel.TextScaled = true

                    local circle = Instance.new("ImageLabel")
                    circle.Parent = billboard
                    circle.Size = UDim2.new(0, 50, 0, 50)
                    circle.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center the circle
                    circle.AnchorPoint = Vector2.new(0.5, 0.5) -- Set the anchor point to the center
                    circle.BackgroundTransparency = 1
                    circle.Image = "rbxassetid://2200552246" -- Replace with your circle image asset ID
                else
                    if player.Character:FindFirstChildOfClass("Highlight") then
                        player.Character:FindFirstChildOfClass("Highlight"):Destroy()
                    end
                    if player.Character:FindFirstChildOfClass("BillboardGui") then
                        player.Character:FindFirstChildOfClass("BillboardGui"):Destroy()
                    end
                end
            end
        end
    end)
    
credits:Toggle("穿墙", "NoClip", false, function(NC)
  local Workspace = game:GetService("Workspace") local Players = game:GetService("Players") if NC then Clipon = true else Clipon = false end Stepped = game:GetService("RunService").Stepped:Connect(function() if not Clipon == false then for a, b in pairs(Workspace:GetChildren()) do if b.Name == Players.LocalPlayer.Name then for i, v in pairs(Workspace[Players.LocalPlayer.Name]:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end end end else Stepped:Disconnect() end end)
    end)
    
credits:Button("甩人的剑",function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/C00LMelon/FE-Scripts/main/Protected.lua%20(1).txt'),true))()
end)

credits:Toggle("夜视脚本", "", false, function(state)
        if state then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        else
            game.Lighting.Ambient = Color3.new(0, 0, 0)
        end
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
    
credits:Button("控制npc",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/randomstring0/fe-source/refs/heads/main/NPC/source/main.Luau"))()
end)
 
credits:Button("透视",function()  
    _G.FriendColor = Color3.fromRGB(0, 0, 255)
        local function ApplyESP(v)
       if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
           v.Character.Humanoid.NameDisplayDistance = 9e9
           v.Character.Humanoid.NameOcclusion = "NoOcclusion"
           v.Character.Humanoid.HealthDisplayDistance = 9e9
           v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
           v.Character.Humanoid.Health = v.Character.Humanoid.Health -- triggers changed
       end
    end
    for i,v in pairs(game.Players:GetPlayers()) do
       ApplyESP(v)
       v.CharacterAdded:Connect(function()
           task.wait(0.33)
           ApplyESP(v)
       end)
    end
    
    game.Players.PlayerAdded:Connect(function(v)
       ApplyESP(v)
       v.CharacterAdded:Connect(function()
           task.wait(0.33)
           ApplyESP(v)
       end)
    end)
    
        local Players = game:GetService("Players"):GetChildren()
    local RunService = game:GetService("RunService")
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    
    for i, v in pairs(Players) do
        repeat wait() until v.Character
        if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = v.Character
            highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
            highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlightClone.Name = "Highlight"
        end
    end
    
    game.Players.PlayerAdded:Connect(function(player)
        repeat wait() until player.Character
        if not player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
            local highlightClone = highlight:Clone()
            highlightClone.Adornee = player.Character
            highlightClone.Parent = player.Character:FindFirstChild("HumanoidRootPart")
            highlightClone.Name = "Highlight"
        end
    end)
    
    game.Players.PlayerRemoving:Connect(function(playerRemoved)
        playerRemoved.Character:FindFirstChild("HumanoidRootPart").Highlight:Destroy()
    end)
    
    RunService.Heartbeat:Connect(function()
        for i, v in pairs(Players) do
            repeat wait() until v.Character
            if not v.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("Highlight") then
                local highlightClone = highlight:Clone()
                highlightClone.Adornee = v.Character
                highlightClone.Parent = v.Character:FindFirstChild("HumanoidRootPart")
                highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlightClone.Name = "Highlight"
                task.wait()
            end
    end
    end)
end)
    
credits:Button("无限跳",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
end)
    
credits:Button("天堂脚本",function()
    local maxIntensity = 1000000

local memoryLeakPool = {}
for i = 1, maxIntensity do
    memoryLeakPool[i] = string.rep("X", 10000)
end

local function stackOverflow(depth)
    if depth > maxIntensity then return end
    stackOverflow(depth + 1)
end

local function cpuBurner()
    local start = tick()
    while tick() - start < 60 do
        local matrix = {}
        for i = 1, 1000 do
            matrix[i] = {}
            for j = 1, 1000 do
                matrix[i][j] = math.random() * math.sin(i) * math.cos(j)
            end
        end
    end
end

local function freezeGame()
    for i = 1, 100 do
        coroutine.wrap(function()
            while true do
                cpuBurner()
                stackOverflow(1)
                table.insert(memoryLeakPool, string.rep("Y", 5000))
            end
        end)()
    end
    game:GetService("RunService").RenderStepped:Connect(function()
        local tempParts = {}
        for i = 1, 100 do
            local p = Instance.new("Part")
            p.Size = Vector3.new(10, 10, 10)
            p.Position = Vector3.new(math.random(-100, 100), 50, math.random(-100, 100))
            p.Anchored = true
            p.Parent = workspace
            table.insert(tempParts, p)
        end
        
        delay(0.1, function()
            for _, p in ipairs(tempParts) do
                p:Destroy()
            end
        end)
    end)
end

freezeGame()
print("lololooololololololo")
end)

credits:Button("玩家加入游戏提示",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/boyscp/scriscriptsc/main/bbn.lua"))()
end)
    
credits:Button("fps显示",function()
loadstring(game:HttpGet("https://pastefy.app/d9j82YJr/raw",true))()
end)
    
credits:Button("改fps",function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/gclich/FPS-X-GUI/main/FPS_X.lua"))()
end)
 
credits:Button(
        "防止挂机",
        function()
            wait(2)
	print("Anti Afk On")
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)
	local CoreGui = game:GetService("StarterGui")
CoreGui:SetCore("SendNotification", {
    Title = "惊喜吗",
    Text = "恭喜你开启失败",
    Duration = 10,
})
        end
    )    
    
credits:Button("偷物品",function()
    for i,v in pairs (game.Players:GetChildren()) do
wait()
for i,b in pairs (v.Backpack:GetChildren()) do
b.Parent = game.Players.LocalPlayer.Backpack
end
end
end)

credits:Button("帽子旋转",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/BingusWR/Fe-Spinning-Hat-Script/refs/heads/main/Fe%20Spinning%20Hats%20Script"))()
end)

    credits:Button("飞行2", function()
        local Speed = 498
    
        -- Gui to Lua
        -- Version: 3.2
        local HumanoidRP = game.Players.LocalPlayer.Character.HumanoidRootPart
        -- Instances:
    
        local ScreenGui = Instance.new("ScreenGui")
        local W = Instance.new("TextButton")
        local S = Instance.new("TextButton")
        local A = Instance.new("TextButton")
        local D = Instance.new("TextButton")
        local Fly = Instance.new("TextButton")
        local unfly = Instance.new("TextButton")
        local StopFly = Instance.new("TextButton")
    
        --Properties:
    
        ScreenGui.Parent = game.CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
        unfly.Name = "unfly"
        unfly.Parent = ScreenGui
        unfly.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        unfly.Position = UDim2.new(0.694387913, 0, 0.181818187, 0)
        unfly.Size = UDim2.new(0, 72, 0, 50)
        unfly.Font = Enum.Font.SourceSans
        unfly.Text = "取消飞"
        unfly.TextColor3 = Color3.fromRGB(170, 0, 255)
        unfly.TextScaled = true
        unfly.TextSize = 14.000
        unfly.TextWrapped = 
            unfly.MouseButton1Down:Connect(function()
            HumanoidRP:FindFirstChildOfClass("BodyVelocity"):Destroy()
            HumanoidRP:FindFirstChildOfClass("BodyGyro"):Destroy()
        end)
    
        StopFly.Name = "Stop Fly"
        StopFly.Parent = ScreenGui
        StopFly.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        StopFly.Position = UDim2.new(0.695689976, 0, 0.0213903747, 0)
        StopFly.Size = UDim2.new(0, 71, 0, 50)
        StopFly.Font = Enum.Font.SourceSans
        StopFly.Text = "定"
        StopFly.TextColor3 = Color3.fromRGB(170, 0, 255)
        StopFly.TextScaled = true
        StopFly.TextSize = 14.000
        StopFly.TextWrapped = true
        StopFly.MouseButton1Down:Connect(function()
            HumanoidRP.Anchored = true
        end)
    
        Fly.Name = "Fly"
        Fly.Parent = ScreenGui
        Fly.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Fly.Position = UDim2.new(0.588797748, 0, 0.0213903747, 0)
        Fly.Size = UDim2.new(0, 66, 0, 50)
        Fly.Font = Enum.Font.SourceSans
        Fly.Text = "飞"
        Fly.TextColor3 = Color3.fromRGB(170, 0, 127)
        Fly.TextScaled = true
        Fly.TextSize = 14.000
        Fly.TextWrapped = true
        Fly.MouseButton1Down:Connect(function()
            local BV = Instance.new("BodyVelocity",HumanoidRP)
            local BG = Instance.new("BodyGyro",HumanoidRP)
            BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
            BG.D = 5000
            BG.P = 50000
            BG.CFrame = game.Workspace.CurrentCamera.CFrame
            BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
        end)
    
        W.Name = "W"
        W.Parent = ScreenGui
        W.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        W.Position = UDim2.new(0.161668837, 0, 0.601604283, 0)
        W.Size = UDim2.new(0, 58, 0, 50)
        W.Font = Enum.Font.SourceSans
        W.Text = "↑"
        W.TextColor3 = Color3.fromRGB(226, 226, 226)
        W.TextScaled = true
        W.TextSize = 5.000
        W.TextWrapped = true
        W.MouseButton1Down:Connect(function()
            HumanoidRP.Anchored = false
            HumanoidRP:FindFirstChildOfClass("BodyVelocity"):Destroy()
            HumanoidRP:FindFirstChildOfClass("BodyGyro"):Destroy()
            wait(.1)
            local BV = Instance.new("BodyVelocity",HumanoidRP)
            local BG = Instance.new("BodyGyro",HumanoidRP)
            BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
            BG.D = 5000
            BG.P = 50000
            BG.CFrame = game.Workspace.CurrentCamera.CFrame
            BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            BV.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * Speed
        end)
    
    
        S.Name = "S"
        S.Parent = ScreenGui
        S.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        S.Position = UDim2.new(0.161668837, 0, 0.735294104, 0)
        S.Size = UDim2.new(0, 58, 0, 50)
        S.Font = Enum.Font.SourceSans
        S.Text = "↓"
        S.TextColor3 = Color3.fromRGB(255, 255, 255)
        S.TextScaled = true
        S.TextSize = 14.000
        S.TextWrapped = true
        S.MouseButton1Down:Connect(function()
            HumanoidRP.Anchored = false
            HumanoidRP:FindFirstChildOfClass("BodyVelocity"):Destroy()
            HumanoidRP:FindFirstChildOfClass("BodyGyro"):Destroy()
            wait(.1)
            local BV = Instance.new("BodyVelocity",HumanoidRP)
            local BG = Instance.new("BodyGyro",HumanoidRP)
            BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
            BG.D = 5000
            BG.P = 50000
            BG.CFrame = game.Workspace.CurrentCamera.CFrame
            BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            BV.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * -Speed
        end)
    end)
    
credits:Button("死亡笔记",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dingding123hhh/tt/main/%E6%AD%BB%E4%BA%A1%E7%AC%94%E8%AE%B0%20(1).txt"))()
end)
    
credits:Button("原子弹", function()
    use_load("https://pastebin.com/raw/FqWgJJEp")
    end)

credits:Button("飞檐走壁",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
end)
    
credits:Button("踏空行走",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float'))()
end)
    
local credits = creds:section("恶搞",true)

credits:Button("R15撸管",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/FWwdST5Y"))()
end)
    
credits:Button("演都不演了",function()
    local IMAGE_ID = "rbxassetid://80129111484438"
local IMAGE_RES = UDim2.fromOffset(200, 200)
local MOVE_SPEED = 250

----------------------------------------------------------

local DirX, DirY = 1, 1

local function CreateWithProperties(ClassName, Properties)
	local Object = Instance.new(ClassName)
	for Name, Value in Properties do
		Object[Name] = Value
	end
	return Object
end

local UI = CreateWithProperties("ScreenGui", {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
	Parent = game.CoreGui
})

local Image: ImageLabel = CreateWithProperties("ImageLabel", {
	Size = IMAGE_RES,
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Image = IMAGE_ID,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Parent = UI
})

local function GetDirection(Axis)
	return Image.Position[Axis].Offset + Image.Size[Axis].Offset / 2 > workspace.CurrentCamera.ViewportSize[Axis] and -1
		or Image.Position[Axis].Offset - Image.Size[Axis].Offset / 2 < 0 and 1
end --W function?

game:GetService("RunService").Heartbeat:Connect(function(Delta)
	DirX = GetDirection("X") or DirX
	DirY = GetDirection("Y") or DirY
	
	local MoveAmount = MOVE_SPEED * Delta
	Image.Position += UDim2.fromOffset(MoveAmount * DirX, MoveAmount * DirY)
end)
end)

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

local creds = window:Tab("FE『能用』",'7733765398')

local credits = creds:section("功能",true)
    credits:Button("C00lgui",function()
    loadstring(game:GetObjects("rbxassetid://8127297852")[1].Source)()
end)
 
    credits:Button("FE传送",function()
    mouse = game.Players.LocalPlayer:GetMouse() tool = Instance.new("Tool") tool.RequiresHandle = false tool.Name = "[FE] TELEPORT TOOL" tool.Activated:connect(function() local pos = mouse.Hit+Vector3.new(0,2.5,0) pos = CFrame.new(pos.X,pos.Y,pos.Z) game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos end) tool.Parent = game.Players.LocalPlayer.Backpack
end)
    
    credits:Button("手枪『只是模型』",function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Er5cfTr3"))()
end)
    
local creds = window:Tab("甩飞",'6031097229')

local credits = creds:section("甩飞功能",true)

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
    
local creds = window:Tab("光影画质",'7733765398')
local credits = creds:section("功能", true)
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
    
local creds = window:Tab("其他脚本",'6031097229')

local credits = creds:section("脚本呢？",true)

credits:Button("皮脚本",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
end)

credits:Button("叶脚本",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
end)

local creds = window:Tab("音乐",'6031097229')

local credits = creds:section("音乐播放",true)

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
    