local success, library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/FengYu-X/FengYu-ui/refs/heads/main/UI.lua"))()
end)

if not success then
    return
end

getgenv().vars = getgenv().vars or {
    Enabled = false,
    MaxDistance = 20,
    ESPEnabled = true,
}

getgenv().Main = getgenv().Main or {
    connections = {},
    services = {
        RunService = game:GetService("RunService"),
        Players = game:GetService("Players"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        TweenService = game:GetService("TweenService"),
        HttpService = game:GetService("HttpService"),
        UserInputService = game:GetService("UserInputService"),
        ContextActionService = game:GetService("ContextActionService"),
        PathfindingService = game:GetService("PathfindingService"),
        TeleportService = game:GetService("TeleportService"),
        Lighting = game:GetService("Lighting"),
        Workspace = game:GetService("Workspace"),
        StarterGui = game:GetService("StarterGui"),
        StarterPack = game:GetService("StarterPack"),
        StarterPlayer = game:GetService("StarterPlayer"),
        SoundService = game:GetService("SoundService"),
        CollectionService = game:GetService("CollectionService"),
        Debris = game:GetService("Debris"),
        Stats = game:GetService("Stats"),
        GuiService = game:GetService("GuiService"),
        MarketplaceService = game:GetService("MarketplaceService"),
        InsertService = game:GetService("InsertService"),
        PolicyService = game:GetService("PolicyService"),
        TextService = game:GetService("TextService"),
        VirtualInputManager = game:GetService("VirtualInputManager"),
        ProximityPromptService = game:GetService("ProximityPromptService"),
        Teams = game:GetService("Teams"),
        BadgeService = game:GetService("BadgeService"),
        AnalyticsService = game:GetService("AnalyticsService"),
    }
}

for i, v in next, getgenv().Main.connections do
    v:Disconnect()
end
getgenv().Main.connections = {}

local Services = getgenv().Main.services
local Players = Services.Players
local RunService = Services.RunService
local Teams = Services.Teams

local vars = getgenv().vars
local lp = Players.LocalPlayer

local currentTarget = nil
local currentHighlight = nil

local function clearESP()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
end

local function setTarget(player)
    if player == currentTarget then return end
    currentTarget = player
    clearESP()
    if not vars.ESPEnabled then return end
    if not player or not player.Character then return end

    local char = player.Character
    local highlight = Instance.new("Highlight")
    highlight.Name = "VampireTargetESP"
    highlight.Adornee = char
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = char
    currentHighlight = highlight
end

local function isEnemy(p)
    if p == lp then return false end
    if not p.Character then return false end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end

    if Teams and lp.Team and p.Team and p.Team == lp.Team then
        return false
    end

    return true
end

local function getClosestEnemy(maxDistance)
    local char = lp.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestPlayer = nil
    local closestDist = nil

    for _, plr in next, Players:GetPlayers() do
        if isEnemy(plr) then
            local thrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if thrp then
                local dist = (hrp.Position - thrp.Position).Magnitude
                if dist <= maxDistance and (not closestDist or dist < closestDist) then
                    closestDist = dist
                    closestPlayer = plr
                end
            end
        end
    end

    return closestPlayer
end

local function getVampireRemote()
    local char = lp.Character
    if not char then return nil end
    local vamp = char:FindFirstChild("Vampire")
    if not vamp then return nil end
    local remote = vamp:FindFirstChild("VampireEvent")
    return remote
end

local function VampireInit()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local vamp = char:WaitForChild("Vampire")
    local remote = vamp:WaitForChild("VampireEvent")
    local initArgs = {"Charging", "CancelCharging", "Punch"}
    for _, v in next, initArgs do
        remote:FireServer(v)
    end
end

local Window = library:CreateWindow({
    Name = "殺脚本",
    SubName = "杀戮光环┃风御 X制作",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 93541172717831,
    Theme = "Dark"
})

Window.CurrentConfig = "None"

local FengYu = Window:Tab("杀戮光环", "84830962019412")

local Feng = FengYu:Section({
    Name = "杀戮光环",
    SubName = "主要设置",
    Logo = "84830962019412",
    open = true
})
Feng:Toggle({
    Name = "自动攻击最近敌人",
    Value = vars.Enabled,
    Callback = function(state)
        vars.Enabled = state
        if state then
            task.spawn(function()
                pcall(VampireInit)
            end)
        else
            setTarget(nil)
        end
    end
})

Feng:Slider({
    Name = "最大攻击距离",
    Value = {
        Min = 5,
        Max = 100,
        Default = vars.MaxDistance,
    },
    Rounding = 0,
    Callback = function(value)
        vars.MaxDistance = value
    end
})

Feng:Toggle({
    Name = "显示目标ESP",
    Value = vars.ESPEnabled,
    Callback = function(state)
        vars.ESPEnabled = state
        if not state then
            setTarget(nil)
        elseif currentTarget then
            setTarget(currentTarget)
        end
    end
})

local hbConn = RunService.Heartbeat:Connect(function()
    if not vars.Enabled then
        setTarget(nil)
        return
    end

    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local remote = getVampireRemote()
    if not remote then return end

    local target = getClosestEnemy(vars.MaxDistance or 20)
    setTarget(target)

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local args = {"Charging", "CancelCharging", "Punch"}
        for i, v in next, args do
            remote:FireServer(v)
        end
        remote:FireServer("PunchHit", { hit = target.Character.HumanoidRootPart })
    end
end)

table.insert(getgenv().Main.connections, hbConn)