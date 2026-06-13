local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") 
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local Fenglib = {}
local RainbowEnabled = false
local RainbowType = "Animated/Cycling Rainbow" 
local RainbowSpeed = 1.0
local Registry = {} 
local ConfigObjects = {} 
local ThemeListeners = {}

local function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function startNeonFlowEffect(object, property, speed)
    speed = speed or 0.008
    local hue = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect()
            return
        end
        hue = (hue + speed) % 1
        local r = math.sin(hue * 3 + 0) * 0.3 + 0.7
        local g = math.sin(hue * 3 + 2) * 0.1
        local b = math.sin(hue * 3 + 4) * 0.1
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createPulseGlow(object)
    local connection
    local isRunning = true
    connection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent or not isRunning then
            if connection then
                connection:Disconnect()
            end
            return
        end
        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return {
        Disconnect = function()
            isRunning = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        IsRunning = function()
            return isRunning and object and object.Parent
        end
    }
end

local Themes = {
    Dark   = {Main = Color3.fromRGB(13, 13, 13), Top = Color3.fromRGB(28, 28, 30), Text = Color3.fromRGB(240, 240, 245), Accent = Color3.fromRGB(80, 140, 255), Stroke = Color3.fromRGB(45, 45, 48)},
    White  = {Main = Color3.fromRGB(243, 243, 243), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(20, 20, 20), Accent = Color3.fromRGB(0, 100, 210), Stroke = Color3.fromRGB(220, 220, 225)},
    Purple = {Main = Color3.fromRGB(18, 15, 22), Top = Color3.fromRGB(30, 25, 35), Text = Color3.fromRGB(245, 240, 255), Accent = Color3.fromRGB(160, 90, 255), Stroke = Color3.fromRGB(50, 45, 60)},
    Blue   = {Main = Color3.fromRGB(12, 18, 28), Top = Color3.fromRGB(25, 32, 45), Text = Color3.fromRGB(240, 245, 255), Accent = Color3.fromRGB(70, 130, 255), Stroke = Color3.fromRGB(45, 55, 75)},
    Red    = {Main = Color3.fromRGB(22, 12, 12), Top = Color3.fromRGB(35, 20, 20), Text = Color3.fromRGB(255, 240, 240), Accent = Color3.fromRGB(255, 80, 80), Stroke = Color3.fromRGB(60, 40, 40)},
    Yellow = {Main = Color3.fromRGB(22, 22, 12), Top = Color3.fromRGB(35, 35, 20), Text = Color3.fromRGB(255, 255, 240), Accent = Color3.fromRGB(255, 200, 80), Stroke = Color3.fromRGB(60, 60, 40)},
    Green  = {Main = Color3.fromRGB(12, 22, 15), Top = Color3.fromRGB(20, 35, 25), Text = Color3.fromRGB(240, 255, 245), Accent = Color3.fromRGB(60, 220, 130), Stroke = Color3.fromRGB(40, 60, 50)},
}
local CurrentTheme = Themes.Dark

local function AddToRegistry(obj, prop, themeKey)
    table.insert(Registry, {Object = obj, Property = prop, Type = themeKey})
    obj[prop] = CurrentTheme[themeKey]
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

function Fenglib:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, r in pairs(Registry) do
            if r.Object then
                Tween(r.Object, {[r.Property] = CurrentTheme[r.Type]})
            end
        end
        for _, fn in pairs(ThemeListeners) do
            pcall(fn)
        end
    end
end

function Fenglib:ToggleRainbow(bool) RainbowEnabled = bool end
function Fenglib:SetRainbowType(val) RainbowType = val end
function Fenglib:SetRainbowSpeed(val) RainbowSpeed = clamp(tonumber(val) or 1, 0.1, 10) end

function Fenglib:SaveConfig(configName, configFolder)
    local ok, err = pcall(function()
        if not isfolder(configFolder) then makefolder(configFolder) end
        local data = {}
        for flag, obj in pairs(ConfigObjects) do
            if obj and obj.Value ~= nil then
                data[flag] = obj.Value
            end
        end
        local json = HttpService:JSONEncode(data)
        writefile(configFolder .. "/" .. configName .. ".json", json)
    end)
    if not ok then
        warn("SaveConfig error:", err)
    end
    return ok
end

function Fenglib:LoadConfig(path)
    if not pcall(isfile, path) then return false end
    local exists = false
    pcall(function() exists = isfile(path) end)
    if not exists then return false end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then return false end

    Fenglib._loading = true
    for flag, val in pairs(data) do
        if ConfigObjects[flag] and ConfigObjects[flag].Set then
            pcall(function() ConfigObjects[flag].Set(val) end)
        end
    end
    Fenglib._loading = false

    return true
end

-- ======================= METUI INTEGRATION START =======================
local Library = do
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local RunService = game:GetService("RunService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new
    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local UDim2FromOffset = UDim2.fromOffset
    local Vector2New = Vector2.new
    local Vector3New = Vector3.new

    local MathClamp = math.clamp
    local MathMax = math.max
    local MathFloor = math.floor
    local MathAbs = math.abs
    local MathSin = math.sin

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableClone = table.clone
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub
    local StringLower = string.lower
    local StringLen = string.len

    local InstanceNew = Instance.new

    local RectNew = Rect.new

    local IsMobile = UserInputService.TouchEnabled or false

    Library = {
        Theme =  { },

        MenuKeybind = tostring(Enum.KeyCode.RightControl), 

        Flags = { },

        Tween = {
            Time = 0.3,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },

        FadeSpeed = 0.2,

        Folders = {
            Directory = "FengLib",
            Configs = "FengLib/Configs",
            Assets = "FengLib/Assets",
        },

        Pages = { },
        Sections = { },

        Connections = { },
        Threads = { },

        ThemeMap = { },
        ThemeItems = { },

        OpenFrames = { },

        SetFlags = { },

        BlurInstances = {},
        KeybindRows = {},
        KeybindFlagListeners = {},

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        UnusedHolder = nil,

        Font = nil
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    local Themes = {
        ["Preset"] = {
            ["Background 2"] = FromRGB(10, 10, 12),
            ["Background"] = FromRGB(12, 12, 14),
            ["Text"] = FromRGB(235, 235, 235),
            ["Outline"] = FromRGB(25, 25, 28),
            ["Section Top"] = FromRGB(28, 27, 31),
            ["Section Background"] = FromRGB(10, 10, 12),
            ["Section Background 2"] = FromRGB(14, 14, 16),
            ["Accent"] = CurrentTheme.Accent,
            ["AccentGradient"] = CurrentTheme.Accent,
            ["Element"] = FromRGB(16, 16, 18)
        }
    }

    Library.Theme = TableClone(Themes["Preset"])

    for Index, Value in Library.Folders do 
        if not isfolder(Value) then
            makefolder(Value)
        end
    end

    local Tween = { } do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            if not Item then return setmetatable({}, Tween) end
            local ok, inst = pcall(function() return IsRawItem and Item or Item.Instance end)
            if not ok or not inst then return setmetatable({}, Tween) end
            Item = inst

            if not Library then return setmetatable({}, Tween) end
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local tweenObj
            local ok2 = pcall(function()
                tweenObj = TweenService:Create(Item, Info, Goal)
            end)
            if not ok2 or not tweenObj then return setmetatable({}, Tween) end

            local NewTween = {
                Tween = tweenObj,
                Info = Info,
                Goal = Goal,
                Item = Item
            }

            NewTween.Tween:Play()

            setmetatable(NewTween, Tween)

            return NewTween
        end

        Tween.GetProperty = function(self, Item)
            Item = Item or self.Item 

            if Item:IsA("Frame") then
                return { "BackgroundTransparency" }
            elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
                return { "BackgroundTransparency", "ImageTransparency" }
            elseif Item:IsA("ScrollingFrame") then
                return { "BackgroundTransparency", "ScrollBarImageTransparency" }
            elseif Item:IsA("TextBox") then
                return { "TextTransparency", "BackgroundTransparency" }
            elseif Item:IsA("UIStroke") then 
                return { "Transparency" }
            end
        end

        Tween.FadeItem = function(self, Item, Property, Visibility, Speed)
            local Item = Item or self.Item 

            local OldTransparency = Item[Property]
            Item[Property] = Visibility and 1 or OldTransparency

            local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
                [Property] = Visibility and OldTransparency or 1
            }, true)

            Library:Connect(NewTween.Tween.Completed, function()
                if not Visibility then 
                    task.wait()
                    Item[Property] = OldTransparency
                end
            end)

            return NewTween
        end

        Tween.Get = function(self)
            if not self.Tween then 
                return
            end

            return self.Tween, self.Info, self.Goal
        end

        Tween.Pause = function(self)
            if not self.Tween then 
                return
            end

            self.Tween:Pause()
        end

        Tween.Play = function(self)
            if not self.Tween then 
                return
            end

            self.Tween:Play()
        end

        Tween.Clean = function(self)
            if not self.Tween then 
                return
            end

            Tween:Pause()
            self = nil
        end
    end

    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end

            return NewItem
        end

        Instances.FadeItem = function(self, Visibility, Speed)
            local Item = self.Instance

            if Visibility == true then 
                Item.Visible = true
            end

            local Descendants = Item:GetDescendants()
            TableInsert(Descendants, Item)

            local NewTween

            for Index, Value in Descendants do 
                local TransparencyProperty = Tween:GetProperty(Value)

                if not TransparencyProperty then 
                    continue
                end

                if type(TransparencyProperty) == "table" then 
                    for _, Property in TransparencyProperty do 
                        NewTween = Tween:FadeItem(Value, Property, not Visibility, Speed)
                    end
                else
                    NewTween = Tween:FadeItem(Value, TransparencyProperty, not Visibility, Speed)
                end
            end
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then 
                return
            end

            Library:AddToTheme(self, Properties)
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then 
                return
            end

            Library:ChangeItemTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then 
                return
            end

            if not self.Instance[Event] then 
                return
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then 
                return
            end

            return Tween:Create(self, Info, Goal)
        end

        Instances.Disconnect = function(self, Name)
            if not self.Instance then 
                return
            end

            return Library:Disconnect(Name)
        end

        Instances.Clean = function(self)
            if not self.Instance then 
                return
            end

            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then 
                return
            end
        
            local Gui = self.Instance
            local Dragging = false 
            local GrabScreenOffset = nil

            local function setPositionFromAbsolute(targetAbsX, targetAbsY)
                local parent = Gui.Parent
                if not parent then return end
                local pap = parent.AbsolutePosition
                local psz = parent.AbsoluteSize
                local gs = Gui.AbsoluteSize
                local ap = Gui.AnchorPoint
                local nx = MathClamp(targetAbsX, pap.X, pap.X + MathMax(0, psz.X - gs.X))
                local ny = MathClamp(targetAbsY, pap.Y, pap.Y + MathMax(0, psz.Y - gs.Y))
                Gui.Position = UDim2FromOffset(nx - pap.X + ap.X * gs.X, ny - pap.Y + ap.Y * gs.Y)
            end
        
            local InputChanged
        
            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    local mouse = UserInputService:GetMouseLocation()
                    local ap = Gui.AbsolutePosition
                    GrabScreenOffset = Vector2.new(mouse.X - ap.X, mouse.Y - ap.Y)

                    if InputChanged then 
                        return
                    end
        
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            GrabScreenOffset = nil
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)
        
            Library:Connect(UserInputService.InputChanged, function(Input)
                if not Dragging or not GrabScreenOffset then return end
                if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end
                local mouse = UserInputService:GetMouseLocation()
                setPositionFromAbsolute(mouse.X - GrabScreenOffset.X, mouse.Y - GrabScreenOffset.Y)
            end)
        
            return Dragging
        end

        Instances.MakeDraggableLerp = function(self, lerpK)
            if not self.Instance then
                return
            end
            lerpK = lerpK or 0.22
            local Gui = self.Instance
            local Dragging = false
            local GrabScreenOffset = nil
            local InputChanged

            local function setPositionFromAbsolute(targetAbsX, targetAbsY)
                local parent = Gui.Parent
                if not parent then return end
                local pap = parent.AbsolutePosition
                local psz = parent.AbsoluteSize
                local gs = Gui.AbsoluteSize
                local ap = Gui.AnchorPoint
                local nx = MathClamp(targetAbsX, pap.X, pap.X + MathMax(0, psz.X - gs.X))
                local ny = MathClamp(targetAbsY, pap.Y, pap.Y + MathMax(0, psz.Y - gs.Y))
                Gui.Position = UDim2FromOffset(nx - pap.X + ap.X * gs.X, ny - pap.Y + ap.Y * gs.Y)
            end

            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    local mouse = UserInputService:GetMouseLocation()
                    local gAp = Gui.AbsolutePosition
                    GrabScreenOffset = Vector2.new(mouse.X - gAp.X, mouse.Y - gAp.Y)
                    if InputChanged then
                        return
                    end
                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Dragging = false
                            GrabScreenOffset = nil
                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(RunService.RenderStepped, function(dt)
                if not Dragging or not GrabScreenOffset then
                    return
                end
                local mouse = UserInputService:GetMouseLocation()
                local wantX = mouse.X - GrabScreenOffset.X
                local wantY = mouse.Y - GrabScreenOffset.Y
                local parent = Gui.Parent
                if not parent then return end
                local pap = parent.AbsolutePosition
                local psz = parent.AbsoluteSize
                local gs = Gui.AbsoluteSize
                local ap = Gui.AnchorPoint
                local nx = MathClamp(wantX, pap.X, pap.X + MathMax(0, psz.X - gs.X))
                local ny = MathClamp(wantY, pap.Y, pap.Y + MathMax(0, psz.Y - gs.Y))
                local tx = nx - pap.X + ap.X * gs.X
                local ty = ny - pap.Y + ap.Y * gs.Y
                local cur = Gui.Position
                local cx, cy = cur.X.Offset, cur.Y.Offset
                local a = MathClamp(lerpK * (1 / math.max(dt, 1 / 240)), 0.02, 0.22)
                Gui.Position = UDim2FromOffset(cx + (tx - cx) * a, cy + (ty - cy) * a)
            end)
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum, Window)
            if not self.Instance then 
                return
            end

            local Gui = self.Instance

            local Resizing = false 
            local CurrentSide = nil

            local StartMouse = nil 
            local StartPosition = nil 
            local StartSize = nil
            
            local EdgeThickness = 2

            local MakeEdge = function(Name, Position, Size)
                local Button = Instances:Create("TextButton", {
                    Name = "\0",
                    Size = Size,
                    Position = Position,
                    BackgroundColor3 = FromRGB(166, 147, 243),
                    BackgroundTransparency = 1,
                    Text = "",
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Parent = Gui,
                    ZIndex = 99999,
                })  Button:AddToTheme({BackgroundColor3 = "Accent"})

                return Button
            end

            local Edges = {
                {Button = MakeEdge(
                    "Left", 
                    UDim2New(0, 0, 0, 0), 
                    UDim2New(0, EdgeThickness, 1, 0)), 
                    Side = "L"
                },

                {Button = MakeEdge(
                    "Right", 
                    UDim2New(1, -EdgeThickness, 0, 0), 
                    UDim2New(0, EdgeThickness, 1, 0)), 
                    Side = "R"
                },

                {Button = MakeEdge(
                    "Top", UDim2New(0, 0, 0, 0), 
                    UDim2New(1, 0, 0, EdgeThickness)), 
                    Side = "T"
                },

                {Button = MakeEdge(
                    "Bottom", 
                    UDim2New(0, 0, 1, -EdgeThickness), 
                    UDim2New(1, 0, 0, EdgeThickness)), 
                    Side = "B"
                },
            }

            local BeginResizing = function(Side)
                Resizing = true 
                CurrentSide = Side 

                StartMouse = UserInputService:GetMouseLocation()

                StartPosition = Vector2New(Gui.Position.X.Offset, Gui.Position.Y.Offset)
                StartSize = Vector2New(Gui.Size.X.Offset, Gui.Size.Y.Offset)
                
                for Index, Value in Edges do 
                    Value.Button:Tween(nil, {BackgroundTransparency = (Value.Side == Side) and 0 or 1})
                end
            end

            local EndResizing = function()
                Resizing = false 
                CurrentSide = nil

                for Index, Value in Edges do 
                    Value.Button.Instance.BackgroundTransparency = 1
                end
            end

            for Index, Value in Edges do 
                Value.Button:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        BeginResizing(Value.Side)
                    end
                end)
            end

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Resizing then
                        EndResizing()
                    end
                end
            end)

            Library:Connect(RunService.RenderStepped, function()
                if not Resizing or not CurrentSide then 
                    return 
                end

                local MouseLocation = UserInputService:GetMouseLocation()
                local dx = MouseLocation.X - StartMouse.X
                local dy = MouseLocation.Y - StartMouse.Y
            
                local x, y = StartPosition.X, StartPosition.Y
                local w, h = StartSize.X, StartSize.Y

                if CurrentSide == "L" then
                    x = StartPosition.X + dx
                    w = StartSize.X - dx

                    if Window then
                        Window.Left.Y = h
                    end
                elseif CurrentSide == "R" then
                    w = StartSize.X + dx

                    if Window then
                        Window.Right.Y = h
                    end
                elseif CurrentSide == "T" then
                    y = StartPosition.Y + dy
                    h = StartSize.Y - dy

                    if Window then
                        Window.Top.X = w
                    end
                elseif CurrentSide == "B" then
                    h = StartSize.Y + dy

                    if Window then
                        Window.Bottom.X = w
                    end
                end
            
                if w < Minimum.X then
                    if CurrentSide == "L" then
                        x = x - (Minimum.X - w)
                    end
                    w = Minimum.X
                end
                if h < Minimum.Y then
                    if CurrentSide == "T" then
                        y = y - (Minimum.Y - h)
                    end
                    h = Minimum.Y
                end
            
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2FromOffset(x, y)})
                self:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2FromOffset(w, h)})
            end)
        end

        Instances.OnHover = function(self, Function)
            if not self.Instance then 
                return
            end
            
            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then 
                return
            end
            
            return Library:Connect(self.Instance.MouseLeave, Function)
        end
    end

    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if not isfile(Data.Id) then 
                writefile(Data.Id, game:HttpGet(Data.Url))
            end

            local Data = {
                name = Name,
                faces = {
                    {
                        name = Name,
                        weight = Weight,
                        style = Style,
                        assetId = getcustomasset(Data.Id)
                    }
                }
            }

            writefile(`{Library.Folders.Assets}/{Name}.font`, HttpService:JSONEncode(Data))
            return getcustomasset(`{Library.Folders.Assets}/{Name}.font`)
        end

        local FontId = "rbxassetid://12187365364"
        local Thin = Font.new(FontId, Enum.FontWeight.Thin, Enum.FontStyle.Normal)
        local ExtraLight = Font.new(FontId, Enum.FontWeight.ExtraLight, Enum.FontStyle.Normal)
        local SemiBold = Font.new(FontId, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        local Medium = Font.new(FontId, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        local Regular = Font.new(FontId, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        local Light = Font.new(FontId, Enum.FontWeight.Light, Enum.FontStyle.Normal)
        local Bold = Font.new(FontId, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        local ExtraBold = Font.new(FontId, Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)

        Library.Fonts = {
            ["ExtraBold"] = ExtraBold,
            ["Bold"] = Bold,
            ["SemiBold"] = SemiBold,
            ["Medium"] = Medium,
            ["Regular"] = Regular,
            ["Light"] = Light,
            ["ExtraLight"] = ExtraLight,
            ["Thin"] = Thin,
        }

        Library.Font = Light
    end

    do
        local FetchedIcons, IconModule = pcall(function()
            return loadstring(
                game:HttpGet("https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua")
            )()
        end)

        Library.GetIcon = function(self, IconName)
            if not FetchedIcons or not IconModule then return nil end
            local ok, icon = pcall(IconModule.GetAsset, IconName)
            if ok and icon then return icon end
            return nil
        end

        Library.ResolveIcon = function(self, Icon)
            if not Icon then return nil, nil, nil end

            if type(Icon) == "table" then
                return Icon.Url, Icon.ImageRectOffset or Vector2New(0, 0), Icon.ImageRectSize or Vector2New(0, 0)
            end

            if tonumber(Icon) then
                return "rbxassetid://" .. tostring(Icon), Vector2New(0, 0), Vector2New(0, 0)
            end

            if type(Icon) == "string" then
                if StringFind(Icon, "rbxassetid://") or StringFind(Icon, "http") then
                    return Icon, Vector2New(0, 0), Vector2New(0, 0)
                end

                local iconData = Library:GetIcon(Icon)
                if not iconData then
                    local stripped = Icon:gsub("%-2$", "")
                    if stripped ~= Icon then
                        iconData = Library:GetIcon(stripped)
                    end
                end
                if not iconData and Icon:find("bar%-chart") then
                    iconData = Library:GetIcon("bar-chart")
                end
                if iconData then
                    return iconData.Url, iconData.ImageRectOffset or Vector2New(0, 0), iconData.ImageRectSize or Vector2New(0, 0)
                end

                if tonumber(Icon) then
                    return "rbxassetid://" .. Icon, Vector2New(0, 0), Vector2New(0, 0)
                end

                return nil, nil, nil
            end

            return nil, nil, nil
        end

        Library.SetIcon = function(self, ImageLabel, Icon)
            local url, offset, size = Library:ResolveIcon(Icon)
            if url then
                ImageLabel.Image = url
                if offset then ImageLabel.ImageRectOffset = offset end
                if size and size.X > 0 then
                    ImageLabel.ImageRectSize = size
                else
                    ImageLabel.ImageRectOffset = Vector2New(0, 0)
                    ImageLabel.ImageRectSize = Vector2New(0, 0)
                end
            end
        end
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 80,
        ResetOnSpawn = false
    })

    Library.UnusedHolder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        Enabled = false,
        ResetOnSpawn = false
    })

    Library.NotifHolder  = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Name = "\0",
        BackgroundTransparency = 1,
        Size = UDim2New(0, 0, 1, 0),
        BorderColor3 = FromRGB(0, 0, 0),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })
    
    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        Padding = UDimNew(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    Instances:Create("UIPadding", {
        Parent = Library.NotifHolder.Instance,
        Name = "\0",
        PaddingTop = UDimNew(0, 12),
        PaddingBottom = UDimNew(0, 12),
        PaddingRight = UDimNew(0, 12),
        PaddingLeft = UDimNew(0, 12)
    })    

    Library.Unload = function(self)
        for Index, Value in self.Connections do 
            Value.Connection:Disconnect()
        end

        for Index, Value in self.Threads do 
            coroutine.close(Value)
        end

        pcall(function() UserInputService.MouseIconEnabled = true end)
        if Library.CursorConn then pcall(function() Library.CursorConn:Disconnect() end) end

        if Library.BlurInstances then
            for _, blur in ipairs(Library.BlurInstances) do
                pcall(function()
                    if typeof(blur) == "Instance" then blur:Destroy() end
                end)
            end
            table.clear(Library.BlurInstances)
        end

        for _, inst in ipairs(Lighting:GetChildren()) do
            if inst:IsA("DepthOfFieldEffect") then
                pcall(function() inst:Destroy() end)
            elseif inst:IsA("BlurEffect") then
                pcall(function() inst:Destroy() end)
            end
        end

        if self.Holder then 
            self.Holder:Clean()
        end

        if Library.CursorScreenGui then pcall(function() Library.CursorScreenGui:Destroy() end) end
        if Library.CursorGui then pcall(function() Library.CursorGui:Destroy() end) end
        if Library.TooltipGui then Library.TooltipGui:Clean() end
        if Library.KeybindRows then table.clear(Library.KeybindRows) end
        if Library.KeybindFlagListeners then table.clear(Library.KeybindFlagListeners) end

        Library = nil 
        getgenv().Library = nil
    end

    Library._NotifyKeybindFlagListeners = function(flag)
        if not flag or not Library.KeybindFlagListeners then
            return
        end
        local t = Library.KeybindFlagListeners[flag]
        if not t then
            return
        end
        for _, fn in ipairs(t) do
            pcall(fn)
        end
    end

    Library.SetKeybindRowsVisible = function(self, visible)
        Library.Flags.ShowKeybindRows = visible
        if not Library.KeybindRows then return end
        for _, row in ipairs(Library.KeybindRows) do
            if row and typeof(row) == "Instance" then
                pcall(function() row.Visible = visible end)
            end
        end
    end

    Library.GetImage = function(self, Image)
        local ImageData = self.Images[Image]

        if not ImageData then 
            return
        end

        return getcustomasset(self.Folders.Assets .. "/" .. ImageData[1])
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)
        
        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()

        TableInsert(self.Threads, NewThread)
        return NewThread
    end
    
    Library.SafeCall = function(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))

        if not Success then
            warn(Result)
            return false
        end

        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        Library:Thread(function()
            NewConnection.Connection = Event:Connect(Callback)
        end)

        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in self.Connections do 
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("flag_number_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item 

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            else
                Item[Property] = Value()
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.ToRich = function(self, Text, Color)
        return `<font color="rgb({MathFloor(Color.R * 255)}, {MathFloor(Color.G * 255)}, {MathFloor(Color.B * 255)})">{Text}</font>`
    end

    Library.GetConfig = function(self)
        local Config = { } 

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Library.Flags do 
                if type(Value) == "table" and Value.Key then
                    Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                else
                    Config[Index] = Value
                end
            end
        end)

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do 
                local SetFunction = Library.SetFlags[Index]

                if not SetFunction then
                    continue
                end

                if type(Value) == "table" and Value.Key then 
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)

        return Success, Result
    end

    Library.ConfigDisplayToFile = function(self, name)
        if not name or name == "" then return nil end
        name = tostring(name):gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then return nil end
        if StringLower(name:sub(-5)) == ".json" then
            return name
        end
        return name .. ".json"
    end

    Library.DeleteConfig = function(self, Config)
        local fn = Library:ConfigDisplayToFile(Config)
        if not fn then return end
        local p = Library.Folders.Configs .. "/" .. fn
        if isfile(p) then
            delfile(p)
        end
    end

    Library.RefreshConfigsList = function(self, Element)
        if not Element or not Element.Refresh then return end
        local List = {}
        if not isfolder(Library.Folders.Configs) then
            pcall(function() makefolder(Library.Folders.Configs) end)
        end
        local ok, files = pcall(function()
            return listfiles(Library.Folders.Configs)
        end)
        if ok and files then
            for _, path in ipairs(files) do
                local base = string.match(path, "([^/\\]+)$")
                if base and StringLower(base:sub(-5)) == ".json" then
                    local disp = base:sub(1, -6)
                    if disp ~= "" then
                        TableInsert(List, disp)
                    end
                end
            end
        end
        table.sort(List)
        Element:Refresh(List)
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        if not self.ThemeMap[Item] then 
            return
        end

        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color

        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                elseif type(Value) == "function" then
                    Item.Item[Property] = Value()
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance

        local MousePosition = Vector2New(Mouse.X, Mouse.Y)

        return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X 
        and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
    end

    do
        local TooltipPadX = 10
        local TooltipVisible = false

        local TooltipGui = Instances:Create("ScreenGui", {
            Parent = gethui(),
            Name = "\0",
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
            DisplayOrder = 9998,
            ResetOnSpawn = false,
            IgnoreGuiInset = true
        })
        Library.TooltipGui = TooltipGui

        local TooltipFrame = Instances:Create("Frame", {
            Parent = TooltipGui.Instance,
            Name = "\0",
            BackgroundColor3 = FromRGB(20, 19, 23),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2New(0, 0, 0, 26),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 9999,
            Visible = false
        })

        Instances:Create("UICorner", {
            Parent = TooltipFrame.Instance,
            Name = "\0",
            CornerRadius = UDimNew(0, 5)
        })

        Instances:Create("UIStroke", {
            Parent = TooltipFrame.Instance,
            Name = "\0",
            Color = FromRGB(40, 38, 46),
            Thickness = 1
        })

        Instances:Create("UIPadding", {
            Parent = TooltipFrame.Instance,
            Name = "\0",
            PaddingLeft = UDimNew(0, TooltipPadX),
            PaddingRight = UDimNew(0, TooltipPadX),
        })

        local TooltipLabel = Instances:Create("TextLabel", {
            Parent = TooltipFrame.Instance,
            Name = "\0",
            FontFace = Library.Fonts.Light,
            TextColor3 = FromRGB(190, 188, 210),
            TextTransparency = 1,
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2New(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            AnchorPoint = Vector2New(0, 0.5),
            Position = UDim2New(0, 0, 0.5, 0),
            TextSize = 13,
            ZIndex = 10000
        })

        Library:Connect(RunService.RenderStepped, function()
            if not TooltipVisible then return end
            local mx, my
            local ok, pos = pcall(UserInputService.GetMouseLocation, UserInputService)
            if ok and pos then
                mx, my = pos.X, pos.Y
            else
                mx, my = Mouse.X, Mouse.Y + 36
            end
            local ScreenSize = Camera.ViewportSize
            local TFSize = TooltipFrame.Instance.AbsoluteSize
            local X = mx + 14
            local Y = my + 20
            if ScreenSize.X > 100 and X + TFSize.X > ScreenSize.X - 4 then
                X = mx - TFSize.X - 6
            end
            if ScreenSize.Y > 100 and Y + TFSize.Y > ScreenSize.Y - 4 then
                Y = my - TFSize.Y - 6
            end
            TooltipFrame.Instance.Position = UDim2New(0, X, 0, Y)
        end)

        Library.ShowTooltip = function(self, Text)
            TooltipLabel.Instance.Text = Text
            TooltipFrame.Instance.Visible = true
            TooltipVisible = true
            Tween:Create(TooltipFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.08})
            Tween:Create(TooltipLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0})
        end

        Library.HideTooltip = function(self)
            TooltipVisible = false
            Tween:Create(TooltipFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
            Tween:Create(TooltipLabel, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 1})
            task.delay(0.12, function()
                if not TooltipVisible then
                    TooltipFrame.Instance.Visible = false
                end
            end)
        end

        Library.AttachTooltip = function(self, GuiObj, Text)
            if not Text or Text == "" then return end
            local inst = (type(GuiObj) == "table" and GuiObj.Instance) or GuiObj
            if not inst then return end
            local ok1 = pcall(function()
                Library:Connect(inst.MouseEnter, function()
                    Library:ShowTooltip(Text)
                end)
            end)
            local ok2 = pcall(function()
                Library:Connect(inst.MouseLeave, function()
                    Library:HideTooltip()
                end)
            end)
        end
    end

    Library.Lerp = function(self, Start, Finish, Time)
        return Start + (Finish - Start) * Time
    end

    Library.CompareVectors = function(self, PointA, PointB)
        return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
    end

    Library.IsClipped = function(self, Object, Column)
        local Parent = Column
        
        local BoundryTop = Parent.AbsolutePosition
        local BoundryBottom = BoundryTop + Parent.AbsoluteSize

        local Top = Object.AbsolutePosition
        local Bottom = Top + Object.AbsoluteSize 

        return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
    end

    Library.GetCalculatedRayPosition = function(self, Position, Normal, Origin, Direction)
        local N = Normal
        local D = Direction
        local V = Origin - Position

        local Number = (N.x * V.x) + (N.y * V.y) + (N.z * V.z)
        local Den = (N.x * D.x) + (N.y * D.y) + (N.z * D.z)
        local A = -Number / Den

        return Origin + (A * Direction)
    end

    Library.UpdateText = function(self)
        for Index, Value in self.UnusedHolder.Instance:GetDescendants() do 
            if Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
                Value.FontFace = Library.Font
            end
        end

        for Index, Value in self.Holder.Instance:GetDescendants() do 
            if Value:IsA("TextLabel") or Value:IsA("TextButton") or Value:IsA("TextBox") then
                Value.FontFace = Library.Font
            end
        end
    end

    Library.MakeBlurred = function(self, Item, Window)
        Item = Item.Instance
        local BlurItem = Item

        local Part = Instances:Create("Part", {
            Material = Enum.Material.Glass,
            Transparency = 1,
            Reflectance = 1,
            CastShadow = false,
            Anchored = true,
            CanCollide = false,
            CanQuery = false,
            CollisionGroup = " ",
            Size = Vector3New(1, 1, 1) * 0.01,
            Color = FromRGB(0,0,0),
            Parent = Camera
        })
            
        local BlockMesh = Instances:Create("BlockMesh", {Parent = Part.Instance})

        local DepthOfField = Instances:Create("DepthOfFieldEffect", {
            Parent = Lighting,
            Enabled = true,
            FarIntensity = 0,
            FocusDistance = 0,
            InFocusRadius = 1000,
            NearIntensity = 1,
            Name = ""
        })

        Library:Connect(RunService.RenderStepped, function()
            if Window.IsOpen then
                if Item.Visible then
                    DepthOfField:Tween(nil, {NearIntensity = 1})

                    Part:Tween(nil, {Transparency = 0.97})
                    Part:Tween(nil, {Size = Vector3New(1, 1, 1) * 0.01})

                    local Corner0 = BlurItem.AbsolutePosition;
                    local Corner1 = Corner0 + BlurItem.AbsoluteSize;
                        
                    local Ray0 = Camera.ScreenPointToRay(Camera, Corner0.X, Corner0.Y, 1);
                    local Ray1 = Camera.ScreenPointToRay(Camera, Corner1.X, Corner1.Y, 1);

                    local Origin = Camera.CFrame.Position + Camera.CFrame.LookVector * (0.05 - Camera.NearPlaneZ);

                    local Normal = Camera.CFrame.LookVector;

                    local Position0 = Library:GetCalculatedRayPosition(Origin, Normal, Ray0.Origin, Ray0.Direction)
                    local Position1 = Library:GetCalculatedRayPosition(Origin, Normal, Ray1.Origin, Ray1.Direction)

                    Position0 = Camera.CFrame:PointToObjectSpace(Position0)
                    Position1 = Camera.CFrame:PointToObjectSpace(Position1)

                    local Size = Position1 - Position0
                    local Center = (Position0 + Position1) / 2

                    BlockMesh.Instance.Offset = Center
                    BlockMesh.Instance.Scale  = Size / 0.0101

                    Part.Instance.CFrame = Camera.CFrame
                else
                    DepthOfField:Tween(nil, {NearIntensity = 0})

                    BlockMesh.Instance.Offset = Vector3New(0, 0, 0)
                    BlockMesh.Instance.Scale  = Vector3New(0, 0, 0)
                end
            else
                DepthOfField:Tween(nil, {NearIntensity = 0})

                BlockMesh.Instance.Offset = Vector3New(0, 0, 0)
                BlockMesh.Instance.Scale  = Vector3New(0, 0, 0)
            end
        end)

        TableInsert(Library.BlurInstances, Part.Instance)
        TableInsert(Library.BlurInstances, DepthOfField.Instance)
    end

    Library.EscapePattern = function(self, String)
        local ShouldEscape = false 

        if string.match(String, "[%(%)%.%%%+%-%*%?%[%]%^%$]") then
            ShouldEscape = true
        end

        if ShouldEscape then
            return StringGSub(String, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
        end

        return String
    end

    do 
        Library.CreateColorpicker = function(self, Data)
            local Colorpicker = {
                Flag = Data.Flag,

                Hue = 0,
                Saturation = 0,
                Value = 0,

                Alpha = 0,

                Color = FromRGB(0, 0, 0),
                HexValue = "#000000",

                SavedColors = { },

                IsOpen = false 
            }

            local Items = { } do
                Items["ColorpickerButton"] = Instances:Create("TextButton", {
                    Parent = Data.Parent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2New(0, 100, 0, 20),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                if not Data.Parent2.Instance:FindFirstChild("nig") then
                    Items["PaletteIcon"] = Instances:Create("ImageLabel", {
                        Parent = Data.Parent2.Instance,
                        ImageColor3 = FromRGB(141, 141, 150),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(0, 16, 0, 16),
                        AnchorPoint = Vector2New(0.5, 1),
                        Image = "rbxassetid://92464809279921",
                        Name = "nig",
                        BackgroundTransparency = 1,
                        Position = UDim2New(1, -16, 1, -6),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })                

                    Items["PaletteIcon"]:OnHover(function()
                        Items["PaletteIcon"]:Tween(nil, {ImageColor3 = Library.Theme.Accent})
                    end)
                    
                    Items["PaletteIcon"]:OnHoverLeave(function()
                        Items["PaletteIcon"]:Tween(nil, {ImageColor3 = FromRGB(141, 141, 150)})
                    end)
                end
                
                Items["Color"] = Instances:Create("Frame", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 15, 0, 15),
                    Position = UDim2New(0, 0, 0, 2),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Color"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["ColorpickerButton"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "#7842ff",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 25, 0, 2),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                    Parent = Library.UnusedHolder.Instance,
                    AutoButtonColor = false,
                    Text = "",
                    Name = "\0",
                    Visible = false,
                    Position = UDim2New(0.01075268816202879, 0, 0.0336427167057991, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 235, 0, 270),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 25)
                })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Palette"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Position = UDim2New(0, 15, 0, 10),
                    Size = UDim2New(1, -31, 1, -159),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })
                
                Items["Saturation"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 1, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Saturation"].Instance,
                    Name = "\0",
                    Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Saturation"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Value"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 1, 1, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(0, 0, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Value"].Instance,
                    Name = "\0",
                    Rotation = 90,
                    Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Value"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["PaletteDragger"] = Instances:Create("Frame", {
                    Parent = Items["Palette"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 15, 0, 15),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 10),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIStroke", {
                    Parent = Items["PaletteDragger"].Instance,
                    Name = "\0",
                    Color = FromRGB(255, 255, 255),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["PaletteDragger"].Instance,
                    Name = "\0"
                })
                
                Items["Hue"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 15, 1, -131),
                    Size = UDim2New(1, -31, 0, 6),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["HueInline"] = Instances:Create("TextButton", {
                    Parent = Items["Hue"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 0, 0)), RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)), RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)), RGBSequenceKeypoint(0.5, FromRGB(0, 255, 255)), RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)), RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)), RGBSequenceKeypoint(1, FromRGB(255, 0, 0))}
                })
                
                Items["HueDragger"] = Instances:Create("Frame", {
                    Parent = Items["HueInline"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 15, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["HueDragger"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Alpha"] = Instances:Create("TextButton", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 15, 1, -107),
                    Size = UDim2New(1, -31, 0, 6),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(0, 0, 0)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                })
                
                Items["AlphaDragger"] = Instances:Create("Frame", {
                    Parent = Items["Alpha"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 15, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["AlphaDragger"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["SavedColors"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    AnchorPoint = Vector2New(0, 1),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    ScrollBarImageColor3 = FromRGB(124, 163, 255),
                    MidImage = "rbxassetid://86870199131153",
                    BorderColor3 = FromRGB(0, 0, 0),
                    ScrollBarThickness = 0,
                    Size = UDim2New(1, -20, 0, 69),
                    Selectable = false,
                    TopImage = "rbxassetid://86870199131153",
                    Position = UDim2New(0, 10, 1, -30),
                    BottomImage = "rbxassetid://86870199131153",
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                }) 
                
                Instances:Create("UIGridLayout", {
                    Parent = Items["SavedColors"].Instance,
                    Name = "\0",
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    CellPadding = UDim2New(0, 10, 0, 10),
                    CellSize = UDim2New(0, 25, 0, 25)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["SavedColors"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 5),
                    PaddingTop = UDimNew(0, 5),
                    PaddingRight = UDimNew(0, -125),
                    PaddingBottom = UDimNew(0, 5)
                })

                Items["HEXInput"] = Instances:Create("TextBox", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ClearTextOnFocus = false,
                    Text = "#7ca3ff",
                    AnchorPoint = Vector2New(1, 1),
                    Size = UDim2New(0, 140, 0, 20),
                    TextTransparency = 0.5,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    Position = UDim2New(1, -8, 1, -8),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(30, 29, 31)
                })  Items["HEXInput"]:AddToTheme({BackgroundColor3 = "Outline"})

                Instances:Create("UIPadding", {
                    Parent = Items["HEXInput"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 5),
                })
                
                Items["HexLabel"] = Instances:Create("TextLabel", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "Custom:",
                    TextTransparency = 0.5,
                    AnchorPoint = Vector2New(0, 1),
                    Size = UDim2New(0, 40, 0, 20),
                    Position = UDim2New(0, 10, 1, -8),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(30, 29, 31)
                })  Items["HexLabel"]:AddToTheme({TextColor3 = "Text"})
                
                Instances:Create("UICorner", {
                    Parent = Items["HEXInput"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })                
            end

            function Colorpicker:Get()
                return Colorpicker.Color, Colorpicker.Alpha
            end

            function Colorpicker:Update(IsFromAlpha)
                local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
                Colorpicker.Color = FromHSV(Hue, Saturation, Value)
                Colorpicker.HexValue = Colorpicker.Color:ToHex()

                Library.Flags[Colorpicker.Flag] = {
                    Alpha = Colorpicker.Alpha,
                    Color = Colorpicker.Color,
                    HexValue = Colorpicker.HexValue,
                    Transparency = 1 - Colorpicker.Alpha
                }

                Items["Color"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                Items["Palette"]:Tween(nil, {BackgroundColor3 = FromHSV(Hue, 1, 1)})
                Items["Text"].Instance.Text = ("#"..Colorpicker.HexValue):upper()
                Items["HEXInput"].Instance.Text = "#"..Colorpicker.HexValue

                if not IsFromAlpha then 
                    Items["Alpha"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
                end

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Colorpicker.Color, Colorpicker.Alpha)
                end
            end

            local SlidingPalette = false
            local PaletteChanged
            
            function Colorpicker:SlidePalette(Input)
                if not Input or not SlidingPalette then
                    return
                end

                local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
                local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)

                Colorpicker.Saturation = ValueX
                Colorpicker.Value = ValueY

                local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.955)
                local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.955)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, SlideY, 0)})
                Colorpicker:Update()
            end
            
            local SlidingHue = false
            local HueChanged

            function Colorpicker:SlideHue(Input)
                if not Input or not SlidingHue then
                    return
                end
                
                local ValueX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 1)

                Colorpicker.Hue = ValueX

                local SlideX = MathClamp((Input.Position.X - Items["Hue"].Instance.AbsolutePosition.X) / Items["Hue"].Instance.AbsoluteSize.X, 0, 0.955)

                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, 0.5, 0)})
                Colorpicker:Update()
            end

            local SlidingAlpha = false 
            local AlphaChanged

            function Colorpicker:SlideAlpha(Input)
                if not Input or not SlidingAlpha then
                    return
                end

                local ValueX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)

                Colorpicker.Alpha = ValueX

                local SlideX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.955)

                Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, 0.5, 0)})
                Colorpicker:Update(true)
            end

            local Debounce = false
            local RenderStepped  

            function Colorpicker:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Colorpicker.IsOpen = Bool

                Debounce = true 

                if Colorpicker.IsOpen then 
                    Items["ColorpickerWindow"].Instance.Visible = true
                    Items["ColorpickerWindow"].Instance.Parent = Library.Holder.Instance
                    
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["ColorpickerWindow"].Instance.Position = UDim2New(
                            0, 
                            Items["ColorpickerButton"].Instance.AbsolutePosition.X, 
                            0, 
                            Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5
                        )
                    end)

                    if Data.Section.IsSettings ~= true then
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Colorpicker then
                                Value:SetOpen(false)
                            end
                        end
                    end

                    Library.OpenFrames[Colorpicker] = Colorpicker 
                else
                    if not Data.Section.IsSettings then
                        if Library.OpenFrames[Colorpicker] then 
                            Library.OpenFrames[Colorpicker] = nil
                        end
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end
                end

                local Descendants = Items["ColorpickerWindow"].Instance:GetDescendants()
                TableInsert(Descendants, Items["ColorpickerWindow"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if not Value.ClassName:find("UI") then 
                        Value.ZIndex = (Colorpicker.IsOpen and Data.Section.IsSettings and 9) or (Colorpicker.IsOpen and not Data.Section.IsSettings and 3) or 1
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["ColorpickerWindow"].Instance.Visible = Colorpicker.IsOpen
                    task.wait(0.2)
                    Items["ColorpickerWindow"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Colorpicker:Set(Color, Alpha)
                if type(Color) == "table" then
                    Color = FromRGB(Color[1], Color[2], Color[3])
                    Alpha = Color[4]
                elseif type(Color) == "string" then
                    Color = FromHex(Color)
                end 

                Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
                Colorpicker.Alpha = Alpha or 0  

                local PaletteValueX = MathClamp(1 - Colorpicker.Saturation, 0, 0.955)
                local PaletteValueY = MathClamp(1 - Colorpicker.Value, 0, 0.955)

                local AlphaPositionX = MathClamp(Colorpicker.Alpha, 0, 0.955)
                    
                local HuePositionX = MathClamp(Colorpicker.Hue, 0, 0.955)

                Items["PaletteDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PaletteValueX, 0, PaletteValueY, 0)})
                Items["HueDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(HuePositionX, 0, 0.5, 0)})
                Items["AlphaDragger"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(AlphaPositionX, 0, 0.5, 0)})
                Colorpicker:Update()
            end

            Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
                Colorpicker:SetOpen(not Colorpicker.IsOpen)
            end)

            Items["Palette"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingPalette = true 

                    Colorpicker:SlidePalette(Input)

                    if PaletteChanged then
                        return
                    end

                    PaletteChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingPalette = false

                            PaletteChanged:Disconnect()
                            PaletteChanged = nil
                        end
                    end)
                end
            end)

            Items["HueInline"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingHue = true 

                    Colorpicker:SlideHue(Input)

                    if HueChanged then
                        return
                    end

                    HueChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingHue = false

                            HueChanged:Disconnect()
                            HueChanged = nil
                        end
                    end)
                end
            end)

            Items["Alpha"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    SlidingAlpha = true 

                    Colorpicker:SlideAlpha(Input)

                    if AlphaChanged then
                        return
                    end

                    AlphaChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            SlidingAlpha = false

                            AlphaChanged:Disconnect()
                            AlphaChanged = nil
                        end
                    end)
                end
            end)

            function AddColor(Color)
                local SaveIndex = #Colorpicker.SavedColors + 1

                local SavedColor = Instances:Create("TextButton", {
                    Parent = Items["SavedColors"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2New(0, 200, 0, 50),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    BackgroundColor3 = Color
                })
                
                Instances:Create("UICorner", {
                    Parent = SavedColor.Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6),
                })                

                local UIStroke = Instances:Create("UIStroke", {
                    Parent = SavedColor.Instance,
                    Name = "\0",
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = FromRGB(255, 255, 255),
                    Thickness = 1.5,
                    Transparency = 1
                })

                SavedColor:OnHover(function()
                    UIStroke:Tween(nil, {Transparency = 0})
                end)

                SavedColor:OnHoverLeave(function()
                    UIStroke:Tween(nil, {Transparency = 1})
                end)

                Colorpicker.SavedColors[SaveIndex] = {
                    Color = Color,
                    Alpha = Colorpicker.Alpha,
                }

                SavedColor:Connect("MouseButton1Down", function()
                    local NewColorData = Colorpicker.SavedColors[SaveIndex]
                    Colorpicker:Set(NewColorData.Color, NewColorData.Alpha)
                end)

                SavedColor:Tween(nil, {BackgroundTransparency = 0})
            end

            local Colors = {
                ["Orange"] = FromRGB(245, 114, 66),
                ["Pink"] = FromRGB(245, 66, 191),
                ["Purple"] = FromRGB(124, 54, 245),
                ["Pink 2"] = FromRGB(202, 110, 255),
                ["Pink 3"] = FromRGB(250, 142, 239),
                ["Yellow"] = FromRGB(214, 206, 92),
                ["Orange 2"] = FromRGB(255, 93, 48),
                ["Orange 3"] = FromRGB(255, 169, 56),   
                ["Green"] = FromRGB(0, 171, 0),
                ["Blue"] = FromRGB(0, 116, 224),
                ["Maroon"] = FromRGB(120, 0, 76),
                ["Whiteish Pink"] = FromRGB(255, 194, 245),         
                ["White"] = FromRGB(255, 255, 255),
                ["Red"] = FromRGB(255, 0, 0),
                ["Sky Blue"] = FromRGB(171, 209, 255),
            }

            AddColor(Colors["Orange"])
            AddColor(Colors["Pink"])
            AddColor(Colors["Purple"])
            AddColor(Colors["Pink 2"])
            AddColor(Colors["Pink 3"])
            AddColor(Colors["Yellow"])
            AddColor(Colors["Orange 2"])
            AddColor(Colors["Orange 3"])
            AddColor(Colors["Green"])
            AddColor(Colors["Blue"])
            AddColor(Colors["Maroon"])
            AddColor(Colors["Whiteish Pink"])
            AddColor(Colors["White"])
            AddColor(Colors["Red"])
            AddColor(Colors["Sky Blue"])

            Items["HEXInput"]:Connect("FocusLost", function()
                Colorpicker:Set(tostring(Items["HEXInput"].Instance.Text), Colorpicker.Alpha)
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if SlidingPalette then 
                        Colorpicker:SlidePalette(Input)
                    end

                    if SlidingHue then
                        Colorpicker:SlideHue(Input)
                    end

                    if SlidingAlpha then
                        Colorpicker:SlideAlpha(Input)
                    end
                end
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if not Colorpicker.IsOpen then
                        return
                    end

                    if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) or Library:IsMouseOverFrame(Items["PaletteIcon"]) and not Data.Section.IsSettings then
                        return
                    end

                    Colorpicker:SetOpen(false)
                end
            end)

            if Data.Default then
                Colorpicker:Set(Data.Default, Data.Alpha)
            end

            Library.SetFlags[Colorpicker.Flag] = function(Value, Alpha)
                Colorpicker:Set(Value, Alpha)
            end

            return Colorpicker, Items 
        end

        Library.KeybindList = function(self, Title)
            local KeybindList = { }
            Library.KeyList = KeybindList

            local Items = { } do 
                Items["KeybindsList"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0),
                    BackgroundTransparency = 0.30000001192092896,
                    Position = UDim2New(0, 20, 0, 72),
                    Size = UDim2New(0, 100, 0, 30),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["KeybindsList"]:AddToTheme({BackgroundColor3 = "Section Background"})

                Items["KeybindsList"]:MakeDraggableLerp(0.05)
                
                Instances:Create("UICorner", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0"
                })
                
                Items["Top"] = Instances:Create("Frame", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 12, 0, 40),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                })  Items["Top"]:AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 21, 0, 20),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "rbxassetid://81598136527047",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 15, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIGradient", {
                    Parent = Items["Icon"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(248, 248, 248),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Title,
                    AutomaticSize = Enum.AutomaticSize.X,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 45, 0.5, -1),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 15,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Top"].Instance,
                    Name = "\0"
                })
                
                Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 1),
                    Position = UDim2New(0, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                }):AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 1),
                    Position = UDim2New(1, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 10, 0, 5),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                }):AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 40),
                    Size = UDim2New(1, 12, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 8),
                    PaddingLeft = UDimNew(0, 8)
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["KeybindsList"].Instance,
                    Name = "\0",
                    PaddingRight = UDimNew(0, 12)
                })                
            end

            function KeybindList:SetVisibility(Bool)
                Items["KeybindsList"].Instance.Visible = Bool
            end

            function KeybindList:Add(Name, Key)
                local NewKey = Instances:Create("TextButton", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                local NewKeyAccent = Instances:Create("Frame", {
                    Parent = NewKey.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIGradient",{
                    Parent = NewKeyAccent.Instance,
                    Name = "\0",
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Instances:Create("UICorner", {
                    Parent = NewKeyAccent.Instance,
                    Name = "\0"
                })
                
                local NewKeyText = Instances:Create("TextLabel", {
                    Parent = NewKey.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.30000001192092896,
                    Text = Name .. " ["..Key.."]",
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  NewKeyText:AddToTheme({TextColor3 = "Text"})

                function NewKey:Set(Name, Key)
                    NewKeyText.Instance.Text = Name .. " ["..Key.."]"
                end

                function NewKey:SetStatus(Bool)
                    if Bool then 
                        NewKeyText:Tween(nil, {Position = UDim2New(0, 15, 0.5, 0), TextTransparency = 0})
                        NewKeyAccent:Tween(nil, {BackgroundTransparency = 0})
                    else
                        NewKeyText:Tween(nil, {Position = UDim2New(0, 0, 0.5, 0), TextTransparency = 0.3})
                        NewKeyAccent:Tween(nil, {BackgroundTransparency = 1})
                    end
                end

                return NewKey
            end

            return KeybindList
        end

        Library.Notification = function(self, Data)
            local Items = { } do 
                Items["Notification"] = Instances:Create("Frame", {
                    Parent = Library.NotifHolder.Instance,
                    Name = "\0",
                    BackgroundTransparency = 0.3499999940395355,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2New(0, 280, 0, 0),
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })

                Instances:Create("UICorner", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 10),
                    PaddingBottom = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 10)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Top
                })

                Items["HeaderRow"] = Instances:Create("Frame", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 18),
                    BorderSizePixel = 0,
                    LayoutOrder = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["HeaderRow"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Data.Title,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, -22, 0, 15),
                    BorderSizePixel = 0,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

                local iconId = Data.Icon or "97594400820219"
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["HeaderRow"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 0),
                    Image = "rbxassetid://"..tostring(iconId),
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                if not Data.IconColor then
                    Instances:Create("UIGradient", {
                        Parent = Items["Icon"].Instance,
                        Name = "\0",
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})
                else
                    Instances:Create("UIGradient", {
                        Parent = Items["Icon"].Instance,
                        Name = "\0",
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, Data.IconColor.Start), RGBSequenceKeypoint(1, Data.IconColor.End)}
                    })
                end

                Items["Description"] = Instances:Create("TextLabel", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.30000001192092896,
                    Text = Data.Description,
                    Size = UDim2New(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Description"]:AddToTheme({TextColor3 = "Text"})

                Items["AccentHolder"] = Instances:Create("Frame", {
                    Parent = Items["Notification"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 4),
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    LayoutOrder = 3,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["AccentHolder"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
            end

            local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            Items["Title"].Instance.TextTransparency = 1
            Items["Description"].Instance.TextTransparency = 1
            Items["Icon"].Instance.ImageTransparency = 1
            Items["Notification"].Instance.BackgroundTransparency = 1
            Items["Accent"].Instance.BackgroundTransparency = 1
            Items["Accent"].Instance.Size = UDim2New(0, 0, 1, 0)

            task.spawn(function()
                task.wait(0.05)
                Items["Title"]:Tween(fadeInfo, {TextTransparency = 0})
                Items["Description"]:Tween(fadeInfo, {TextTransparency = 0.3})
                Items["Icon"]:Tween(fadeInfo, {ImageTransparency = 0})
                Items["Notification"]:Tween(fadeInfo, {BackgroundTransparency = 0.35})
                Items["Accent"]:Tween(fadeInfo, {BackgroundTransparency = 0})

                local hold = math.clamp(tonumber(Data.Duration) or tonumber(Data.Time) or 3, 0.5, 120)
                task.wait(0.14)
                Items["Accent"].Instance.Size = UDim2New(1, 0, 1, 0)
                Items["Accent"]:Tween(TweenInfo.new(hold, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Size = UDim2New(0, 0, 1, 0)})

                task.wait(hold + 0.05)

                Items["Title"]:Tween(fadeInfo, {TextTransparency = 1})
                Items["Description"]:Tween(fadeInfo, {TextTransparency = 1})
                Items["Icon"]:Tween(fadeInfo, {ImageTransparency = 1})
                Items["Notification"]:Tween(fadeInfo, {BackgroundTransparency = 1})
                Items["Accent"]:Tween(fadeInfo, {BackgroundTransparency = 1})

                task.wait(0.5)
                if Items["Notification"] and Items["Notification"].Instance then
                    Items["Notification"]:Clean()
                end
            end)
        end

        Library.Window = function(self, Data)
            Data = Data or { }

            local Window = {
                Name = Data.Name or Data.name or "Window",
                SubName = Data.SubName or Data.subname or "Fine-tuning for sure wins",
                Logo = Data.Logo or Data.logo or "1l20959262762131",

                Pages = { },
                Items = { },
                IsOpen = false,
                CurrentAlignment = "LeftTabs",
                TabSwitchCooldownSec = 0.5,
                _tabCooldownUntil = 0
            }

            local Items = { } do
                local WINDOW_CORNER_RADIUS = 14

                Items["MainFrame"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    BorderColor3 = Library.Theme.Background,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 0.12,
                    Position = UDim2New(0.5519999861717224, 0, 0.5, 0),
                    Size = Data.Size or (IsMobile and UDim2New(0, 520, 0, 420) or UDim2New(0, 940, 0, 730)),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Background"})

                Instances:Create("UICorner", {
                    Parent = Items["MainFrame"].Instance,
                    CornerRadius = UDimNew(0, WINDOW_CORNER_RADIUS)
                })

                if IsMobile then 
                    Items["MobileUIScale"] = Instances:Create("UIScale", {
                        Parent = Items["MainFrame"].Instance,
                        Name = "\0",
                        Scale = (Data.MobileScale or 0.74) * 0.88
                    })
                else
                    Items["IntroScale"] = Instance.new("UIScale")
                    Items["IntroScale"].Scale = 0.94
                    Items["IntroScale"].Parent = Items["MainFrame"].Instance
                end

                Library.MainFrame = Items["MainFrame"]
                Items["MainFrame"]:MakeResizeable(Vector2New(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y), Vector2New(9999, 9999), OriginalSizes)
                Library:MakeBlurred(Items["MainFrame"], Window)

                do
                    Items["ResizeCorner"] = Instances:Create("TextButton", {
                        Parent = Library.Holder.Instance,
                        Name = "\0",
                        AutoButtonColor = false,
                        Text = "",
                        AnchorPoint = Vector2New(1, 1),
                        Position = UDim2FromOffset(0, 0),
                        Size = UDim2FromOffset(18, 18),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 250,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    local ResizeIcon = Instances:Create("ImageLabel", {
                        Parent = Items["ResizeCorner"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        Size = UDim2New(0, 14, 0, 14),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 9999,
                        ImageTransparency = 0.5,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  ResizeIcon:AddToTheme({ImageColor3 = "Text"})

                    Library:SetIcon(ResizeIcon.Instance, "move-diagonal-2")

                    local CornerResizing = false
                    local CornerStartMouse = nil
                    local CornerStartSize = nil
                    local CornerStartPos = nil

                    Items["ResizeCorner"]:OnHover(function()
                        ResizeIcon:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = 0})
                    end)
                    Items["ResizeCorner"]:OnHoverLeave(function()
                        if not CornerResizing then
                            ResizeIcon:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = 0.5})
                        end
                    end)

                    Items["ResizeCorner"]:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            CornerResizing = true
                            CornerStartMouse = UserInputService:GetMouseLocation()
                            CornerStartSize = Vector2New(Items["MainFrame"].Instance.AbsoluteSize.X, Items["MainFrame"].Instance.AbsoluteSize.Y)
                            CornerStartPos = Vector2New(Items["MainFrame"].Instance.Position.X.Offset, Items["MainFrame"].Instance.Position.Y.Offset)
                        end
                    end)

                    Library:Connect(UserInputService.InputEnded, function(Input)
                        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and CornerResizing then
                            CornerResizing = false
                            ResizeIcon:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageTransparency = 0.5})
                        end
                    end)

                    Library:Connect(RunService.RenderStepped, function()
                        local mf = Items["MainFrame"].Instance
                        local rc = Items["ResizeCorner"].Instance
                        if mf.Parent and rc.Parent then
                            local mPos = mf.AbsolutePosition
                            local mSz = mf.AbsoluteSize
                            local pap = rc.Parent.AbsolutePosition
                            rc.Position = UDim2FromOffset(mPos.X + mSz.X - 2 - pap.X, mPos.Y + mSz.Y - 2 - pap.Y)
                        end
                        if not CornerResizing then
                            return
                        end
                        local MousePos = UserInputService:GetMouseLocation()
                        local dx = MousePos.X - CornerStartMouse.X
                        local dy = MousePos.Y - CornerStartMouse.Y
                        local newW = MathClamp(CornerStartSize.X + dx, 400, 9999)
                        local newH = MathClamp(CornerStartSize.Y + dy, 300, 9999)
                        Items["MainFrame"].Instance.Size = UDim2FromOffset(newW, newH)
                    end)
                end
                
                Items["LeftTabs"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    Visible = true,
                    BorderColor3 = Library.Theme.Background,
                    AnchorPoint = Vector2New(0, 0),
                    Position = UDim2New(0, 0, 0, 55),
                    BackgroundTransparency = 0.12,
                    Size = UDim2New(0, 225, 1, -55),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["LeftTabs"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Background"})

                Instances:Create("UICorner", {
                    Parent = Items["LeftTabs"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, WINDOW_CORNER_RADIUS),
                })

                Items["LeftTabsScroll"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["LeftTabs"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2New(1, -2, 1, -2),
                    Position = UDim2New(0, 1, 0, 1),
                    AnchorPoint = Vector2New(0, 0),
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    ScrollBarThickness = 5,
                    ScrollBarImageColor3 = FromRGB(90, 165, 255),
                    ScrollingEnabled = true,
                    Active = true,
                    ClipsDescendants = true,
                    ZIndex = 3,
                })

                local Gui = Items["MainFrame"].Instance

                local Dragging = false 
                local DragStart
                local StartPosition 
    
                local Set = function(Input)
                    local DragDelta = Input.Position - DragStart
                    Items["MainFrame"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)})
                end
    
                Items["MainFrame"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
    
                        DragStart = Input.Position
                        StartPosition = Gui.Position
    
                        Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Dragging = false
                            end
                        end)
                    end
                end)

                Items["LeftTabs"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
    
                        DragStart = Input.Position
                        StartPosition = Gui.Position
    
                        Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Dragging = false
                            end
                        end)
                    end
                end)
    
                Library:Connect(UserInputService.InputChanged, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Dragging then
                            Set(Input)
                        end
                    end
                end)

                do
                    Items["FloatingButton"] = Instances:Create("TextButton", {
                        Parent = Library.Holder.Instance,
                        Text = "",
                        AutoButtonColor = false,
                        Name = "\0",
                        Position = UDim2New(0.5, 0, 0, 20),
                        AnchorPoint = Vector2New(0.5, 0),
                        Visible = true,
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(0, 54, 0, 54),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 0.14,
                        ZIndex = 127,
                        BackgroundColor3 = Library.Theme.Background
                    })  Items["FloatingButton"]:AddToTheme({BackgroundColor3 = "Background"})

                    Instances:Create("UIStroke", {
                        Parent = Items["FloatingButton"].Instance,
                        Name = "\0",
                        Thickness = 1.25,
                        Transparency = 0.28,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Color = FromRGB(90, 165, 255)
                    }):AddToTheme({Color = "Accent"})

                    Items["FloatingLogo"] = Instances:Create("ImageLabel", {
                        Parent = Items["FloatingButton"].Instance,
                        BorderColor3 = FromRGB(0, 0, 0),
                        Name = "\0",
                        Image = "rbxassetid://" .. Window.Logo,
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        ZIndex = 128,
                        Size = UDim2New(1, -22, 1, -22),
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
        
                    Instances:Create("UICorner", {
                        Parent = Items["FloatingButton"].Instance,
                        CornerRadius = UDimNew(1, 0)
                    }) 

                    local FloatGrad = Instances:Create("UIGradient", {
                        Parent = Items["FloatingLogo"].Instance,
                        Name = "\0",
                        Enabled = false,
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                    })
                    FloatGrad:AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})

                    Library.FloatingButtonWidget = Items["FloatingButton"]

                    local floatDragging = false
                    local floatPressStart = nil
                    local floatGrabOffset = nil
                    local floatMoved = false
                    local FLOAT_DRAG_PX = 8
                    local FLOAT_LERP = 0.15

                    Items["FloatingButton"]:Connect("InputBegan", function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            floatDragging = true
                            floatMoved = false
                            local inst = Items["FloatingButton"].Instance
                            floatPressStart = UserInputService:GetMouseLocation()
                            local ap = inst.AbsolutePosition
                            floatGrabOffset = Vector2.new(floatPressStart.X - ap.X, floatPressStart.Y - ap.Y)
                        end
                    end)

                    Library:Connect(UserInputService.InputEnded, function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            if floatDragging then
                                if not floatMoved then
                                    Window:SetOpen(not Window.IsOpen)
                                end
                            end
                            floatDragging = false
                            floatPressStart = nil
                            floatGrabOffset = nil
                            floatMoved = false
                        end
                    end)

                    Library:Connect(RunService.RenderStepped, function(dt)
                        if not floatDragging or not floatGrabOffset then
                            return
                        end
                        local inst = Items["FloatingButton"].Instance
                        local parent = inst.Parent
                        if not parent then return end
                        local now = UserInputService:GetMouseLocation()
                        local totalDx = now.X - floatPressStart.X
                        local totalDy = now.Y - floatPressStart.Y
                        if (Vector2New(totalDx, totalDy)).Magnitude >= FLOAT_DRAG_PX then
                            floatMoved = true
                        end
                        if not floatMoved then
                            return
                        end
                        local psz = parent.AbsoluteSize
                        local sz = inst.AbsoluteSize
                        local p0 = parent.AbsolutePosition
                        local anch = inst.AnchorPoint
                        local wantTLX = now.X - floatGrabOffset.X
                        local wantTLY = now.Y - floatGrabOffset.Y
                        wantTLX = MathClamp(wantTLX, p0.X, p0.X + MathMax(0, psz.X - sz.X))
                        wantTLY = MathClamp(wantTLY, p0.Y, p0.Y + MathMax(0, psz.Y - sz.Y))
                        local tx = wantTLX - p0.X + anch.X * sz.X
                        local ty = wantTLY - p0.Y + anch.Y * sz.Y
                        local cur = inst.Position
                        local cx = cur.X.Offset
                        local cy = cur.Y.Offset
                        local a = math.clamp(FLOAT_LERP * (1 / math.max(dt, 1 / 240)), 0.06, 0.32)
                        inst.Position = UDim2FromOffset(cx + (tx - cx) * a, cy + (ty - cy) * a)
                    end)
                end

                Items["PagePlaceholder"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    Visible = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0),
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["LeftTabsScroll"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 12),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["LeftTabsScroll"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 15),
                    PaddingBottom = UDimNew(0, 15),
                    PaddingRight = UDimNew(0, 12),
                    PaddingLeft = UDimNew(0, 12)
                })

                Items["Logo"] = Instances:Create("ImageLabel", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    ScaleType = Enum.ScaleType.Fit,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 35, 0, 35),
                    Image = "rbxassetid://"..Window.Logo,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 12),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                }) 

                Instances:Create("UIGradient", {
                    Parent = Items["Logo"].Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Window.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 52, 0, 13),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 16,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Items["SubTitle"] = Instances:Create("TextLabel", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.4000000059604645,
                    Text = Window.SubName,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 52, 0, 30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})

                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    BorderColor3 = Library.Theme.Background,
                    BackgroundTransparency = 0.75,
                    Position = UDim2New(0, 225, 0, 55),
                    Size = UDim2New(1, -225, 1, -55),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["Content"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Background"})

                Instances:Create("UICorner", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, WINDOW_CORNER_RADIUS)
                })

                Items["CloseButton"] = Instances:Create("TextButton", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0.20000000298023224,
                    Position = UDim2New(1, -14, 0, 11),
                    Size = UDim2New(0, 32, 0, 32),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["CloseButton"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })
                
                Items["CloseIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(240, 240, 240),
                    ImageTransparency = 0.30000001192092896,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 11, 0, 11),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://130510492706892",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["CloseIcon"]:AddToTheme({ImageColor3 = "Text"})        
                
                Items["CloseButton"]:Connect("MouseButton1Down", function()
                    Library:Unload()
                end)

                Items["CloseIconAccent"] = Instances:Create("Frame", {
                    Parent = Items["CloseButton"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderSizePixel = 0,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    ZIndex = 2,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Items["CloseIconAccent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })

                function Window:SetTransparency()
                    Items["MainFrame"].Instance.BackgroundTransparency = Library.Flags["BackgroundTransparency"] 
                    Items["LeftTabs"].Instance.BackgroundTransparency = Library.Flags["BackgroundTransparency"]  
                    if Items["FloatingButton"] then
                        local showFloat = Library.Flags["FloatingButtonVisible"] ~= false
                        Items["FloatingButton"].Instance.Visible = showFloat
                        if showFloat then
                            Items["FloatingButton"].Instance.BackgroundTransparency = Library.Flags["BackgroundTransparency"]
                        end
                    end
                end

                Instances:Create("UIGradient", {
                    Parent = Items["CloseIconAccent"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))},
                    Rotation = -115
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["MinimizeButton"] = Instances:Create("TextButton", {
                    Parent = Items["MainFrame"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 0.20000000298023224,
                    Position = UDim2New(1, -56, 0, 11),
                    Size = UDim2New(0, 32, 0, 32),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["MinimizeButton"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["MinimizeButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })

                Items["MinimizeIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["MinimizeButton"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(240, 240, 240),
                    ImageTransparency = 0.30000001192092896,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 14, 0, 14),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["MinimizeIcon"]:AddToTheme({ImageColor3 = "Text"})
                Library:SetIcon(Items["MinimizeIcon"].Instance, "minus")

                Items["MinimizeIconAccent"] = Instances:Create("Frame", {
                    Parent = Items["MinimizeButton"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderSizePixel = 0,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    ZIndex = 2,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Items["MinimizeIconAccent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 7)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["MinimizeIconAccent"].Instance,
                    Name = "\0",
                    Rotation = -115
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["MinimizeButton"]:Connect("MouseButton1Down", function()
                    Window:SetOpen(false)
                end)

                Items["MinimizeButton"]:OnHover(function()
                    Items["MinimizeIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(1, 0, 1, 0),
                        BackgroundTransparency = 0
                    })
                end)

                Items["MinimizeButton"]:OnHoverLeave(function()
                    Items["MinimizeIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                end)

                Items["CloseButton"]:OnHover(function()
                    Items["CloseIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(1, 0, 1, 0),
                        BackgroundTransparency = 0
                    })
                end)

                Items["CloseButton"]:OnHoverLeave(function()
                    Items["CloseIconAccent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Size = UDim2New(0, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                end)
                
                Window.Items = Items
            end
            
            local Debounce = false

            function Window:SetCenter()
                local CenterPosition = Items["MainFrame"].Instance.AbsolutePosition
                task.wait()
                Items["MainFrame"].Instance.AnchorPoint = Vector2New(0, 0)

                Items["MainFrame"].Instance.Position = UDim2New(0, CenterPosition.X, 0, CenterPosition.Y)
            end

            function Window:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Window.IsOpen = Bool

                Debounce = true 

                if Window.IsOpen then 
                    Items["MainFrame"].Instance.Visible = true 
                end

                local Descendants = Items["MainFrame"].Instance:GetDescendants()
                TableInsert(Descendants, Items["MainFrame"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["MainFrame"].Instance.Visible = Window.IsOpen
                end)
            end

            function Window:Toggle()
                Window:SetOpen(not Window.IsOpen)
            end

            function Window:Init()
                task.spawn(function()
                    if Items["IntroScale"] then
                        TweenService:Create(Items["IntroScale"], TweenInfo.new(0.48, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
                    elseif Items["MobileUIScale"] and Items["MobileUIScale"].Instance then
                        local target = Data.MobileScale or 0.74
                        TweenService:Create(Items["MobileUIScale"].Instance, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = target}):Play()
                    end
                    local firstPage = Window.Pages and Window.Pages[1]
                    if firstPage and not firstPage.Active then
                        firstPage:Turn(true)
                    end
                    for __, Value in Window.Pages do 
                        if Value.Active then 
                            for _, Value2 in Value.Sections do 
                                task.spawn(function()
                                    Value2:TweenElements(true)
                                end)
                            end
                        end
                    end
                end)
            end

            Window:SetCenter()
            task.wait()
            Window:SetOpen(true)
            return setmetatable(Window, Library)
        end

        Library.Category = function(self, Name)
            local Items = { } do 
                Items["Category"] = Instances:Create("TextLabel", {
                    Parent = self.Items["LeftTabsScroll"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.4000000059604645,
                    Text = Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(1, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Category"]:AddToTheme({TextColor3 = "Text"})
            end                
        end

        Library.TabDivider = function(self)
            local Win = self
            Instances:Create("Frame", {
                Parent = Win.Items["LeftTabsScroll"].Instance,
                Name = "\0",
                BackgroundColor3 = FromRGB(38, 36, 46),
                Size = UDim2New(1, -24, 0, 1),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.42,
                ZIndex = 2
            }):AddToTheme({BackgroundColor3 = "Element"})
        end

        Library.Page = function(self, Data)
            Data = Data or { }

            local Page = {
                Window = self,

                Name = Data.Name or Data.name or "Page",
                Icon = Data.Icon or Data.icon or "100050851789190",
                Columns = Data.Columns or Data.columns or 2,
                TabLayoutOrder = Data.LayoutOrder or Data.layoutOrder or Data.TabLayoutOrder or 0,

                Items = { },
                ColumnsData = { },
                Sections = { },
                Active = false
            }

            local Items = { } do
                Items["Inactive"] = Instances:Create("TextButton", {
                    Parent = Page.Window.Items["LeftTabsScroll"].Instance,
                    Name = "\0",
                    LayoutOrder = Page.TabLayoutOrder,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2New(0, 200, 0, 40),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Accent"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items.Gradient = Instances:Create("UIGradient", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    Transparency = NumSequence{NumSequenceKeypoint(0, 0.41874998807907104), NumSequenceKeypoint(0.445, 0.78125), NumSequenceKeypoint(0.751, 0.9375), NumSequenceKeypoint(1, 1)}
                })

                Items["TabIndicator"] = Instances:Create("Frame", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 6, 0.5, 0),
                    Size = UDim2New(0, 3, 0, 22),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["TabIndicator"]:AddToTheme({BackgroundColor3 = "Accent"})
                
                Instances:Create("UICorner", {
                    Parent = Items["TabIndicator"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 18, 0, 18),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 18, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Library:SetIcon(Items["Icon"].Instance, Page.Icon)

                Instances:Create("UIGradient", {
                    Parent = Items["Icon"].Instance,
                    Name = "\0",
                    Rotation = -115
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Page.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 44, 0.5, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})      
                
                Items["Page"] = Instances:Create("CanvasGroup", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    GroupTransparency = 1,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    Position = UDim2New(0, 0, 0, 60),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDimNew(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 10),
                    PaddingBottom = UDimNew(0, 10),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 10)
                })                

                for Index = 1, Page.Columns do 
                    local NewColumn = Instances:Create("ScrollingFrame", {
                        Parent = Items["Page"].Instance,
                        Name = "\0",
                        ScrollBarImageColor3 = FromRGB(0, 0, 0),
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 0,
                        BorderColor3 = FromRGB(0, 0, 0),
                        BackgroundTransparency = 1,
                        Size = UDim2New(0, 100, 0, 100),
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        CanvasSize = UDim2New(0, 0, 0, 0)
                    })
                    
                    Instances:Create("UIListLayout", {
                        Parent = NewColumn.Instance,
                        Name = "\0",
                        Padding = UDimNew(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Page.ColumnsData[Index] = NewColumn
                end

                Page.Items = Items
            end

            local Debounce = false

            function Page:InstantDeactivate()
                Items["Inactive"].Instance.BackgroundTransparency = 1
                Items["TabIndicator"].Instance.BackgroundTransparency = 1
                Items["Page"].Instance.Visible = false
                Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
                Items["Page"].Instance.GroupTransparency = 1
                Page.Active = false
                Debounce = false
                for _, Sec in Page.Sections do
                    task.spawn(function()
                        Sec:TweenElements(false, true)
                    end)
                end
            end

            function Page:Turn(Bool)
                if Debounce then 
                    return 
                end

                Page.Active = Bool 
                Debounce = true

                local tabFade = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                if Page.Active then
                    Items["Page"].Instance.Visible = true
                    Items["Page"].Instance.Parent = Page.Window.Items["Content"].Instance
                    Items["Page"].Instance.GroupTransparency = 1
                    Items["Page"].Instance.Position = UDim2New(0, 0, 0, 28)

                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0.88})
                    Items["TabIndicator"]:Tween(nil, {BackgroundTransparency = 0})

                    for _, Sec in Page.Sections do
                        task.spawn(function()
                            Sec:TweenElements(false, true)
                        end)
                    end

                    local NewTween = Tween:Create(Items["Page"].Instance, tabFade, {GroupTransparency = 0, Position = UDim2New(0, 0, 0, 0)}, true)
                    if NewTween and NewTween.Tween then
                        Library:Connect(NewTween.Tween.Completed, function()
                            Library:Thread(function()
                                for _, Value in Page.Sections do
                                    task.spawn(function()
                                        Value:TweenElements(true)
                                    end)
                                    task.wait(0.055)
                                end
                                Debounce = false
                            end)
                        end)
                    else
                        Debounce = false
                    end
                else
                    Items["Inactive"]:Tween(nil, {BackgroundTransparency = 1})
                    Items["TabIndicator"]:Tween(nil, {BackgroundTransparency = 1})

                    local NewTween = Tween:Create(Items["Page"].Instance, tabFade, {GroupTransparency = 1, Position = UDim2New(0, 0, 0, 36)}, true)
                    if NewTween and NewTween.Tween then
                        Library:Connect(NewTween.Tween.Completed, function()
                            Items["Page"].Instance.Visible = false
                            Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
                            for Index, Value in Page.Sections do 
                                task.spawn(function()
                                    Value:TweenElements(false, true)
                                end)   
                            end
                            Debounce = false
                        end)
                    else
                        Items["Page"].Instance.Visible = false
                        Items["Page"].Instance.Parent = Library.UnusedHolder.Instance
                        Debounce = false
                    end
                end
            end

            Items["Inactive"]:Connect("MouseButton1Down", function()
                local W = Page.Window
                local now = tick()
                if now < (W._tabCooldownUntil or 0) then
                    return
                end
                for _, Value in Page.Window.Pages do 
                    if Value == Page and Page.Active then
                        return
                    end
                end
                for _, Value in Page.Window.Pages do 
                    if Value ~= Page and Value.InstantDeactivate then
                        Value:InstantDeactivate()
                    end
                end
                Page:Turn(true)
                W._tabCooldownUntil = now + (W.TabSwitchCooldownSec or 0.5)
            end)

            if #Page.Window.Pages == 0 then 
                Page:Turn(true)
            end
            
            TableInsert(Page.Window.Pages, Page)
            return setmetatable(Page, Library.Pages)
        end

        Library.DashboardPage = function(self, Data)
            Data = Data or {}

            local Window = self

            local DashPage = {
                Window = Window,
                Name = Data.Name or "Dashboard",
                Icon = Data.Icon or "100050851789190",
                Active = false,
                Pages = {},
                Sections = {},
                ColumnsData = {},
                Items = {},
                IsDashboard = true,
                WelcomeText = Data.WelcomeText or "WELCOME TO",
                HubName = Data.HubName,
                StatusText = Data.StatusText,
                Badge = Data.Badge or "PLAYER",
                Links = Data.Links or {},
                GameName = Data.GameName or "MY HUB",
                GameDescription = Data.GameDescription or "Welcome to my hub!",
                QuickAccess = Data.QuickAccess or {},
                Stats = Data.Stats or {},
                Credits = Data.Credits or {}
            }

            local AddQuickCard
            local DashItems = {} do
                DashItems["Inactive"] = Instances:Create("TextButton", {
                    Parent = Window.Items["LeftTabsScroll"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2New(0, 200, 0, 40),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })  DashItems["Inactive"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = DashItems["Inactive"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })

                DashItems.Gradient = Instances:Create("UIGradient", {
                    Parent = DashItems["Inactive"].Instance,
                    Name = "\0",
                    Transparency = NumSequence{NumSequenceKeypoint(0, 0.41874998807907104), NumSequenceKeypoint(0.445, 0.78125), NumSequenceKeypoint(0.751, 0.9375), NumSequenceKeypoint(1, 1)}
                })

                DashItems["TabIndicator"] = Instances:Create("Frame", {
                    Parent = DashItems["Inactive"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0, 0.5),
                    Position = UDim2New(0, 6, 0.5, 0),
                    Size = UDim2New(0, 3, 0, 22),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  DashItems["TabIndicator"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = DashItems["TabIndicator"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })

                DashItems["Icon"] = Instances:Create("ImageLabel", {
                    Parent = DashItems["Inactive"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 18, 0, 18),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 18, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Library:SetIcon(DashItems["Icon"].Instance, DashPage.Icon)

                Instances:Create("UIGradient", {
                    Parent = DashItems["Icon"].Instance,
                    Name = "\0",
                    Rotation = -115
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                DashItems["Text"] = Instances:Create("TextLabel", {
                    Parent = DashItems["Inactive"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = DashPage.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 44, 0.5, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  DashItems["Text"]:AddToTheme({TextColor3 = "Text"})

                DashItems["Page"] = Instances:Create("CanvasGroup", {
                    Parent = Library.UnusedHolder.Instance,
                    Name = "\0",
                    Visible = false,
                    GroupTransparency = 1,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    Position = UDim2New(0, 0, 0, 60),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIPadding", {
                    Parent = DashItems["Page"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 16),
                    PaddingBottom = UDimNew(0, 16),
                    PaddingRight = UDimNew(0, 16),
                    PaddingLeft = UDimNew(0, 16)
                })

                local AvatarImage = ""
                pcall(function()
                    AvatarImage = game.Players:GetUserThumbnailAsync(
                        LocalPlayer.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size420x420
                    )
                end)

                DashItems["HeroRow"] = Instances:Create("Frame", {
                    Parent = DashItems["Page"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 190),
                    Position = UDim2New(0, 0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                local LeftCol = Instances:Create("Frame", {
                    Parent = DashItems["HeroRow"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 0),
                    Size = UDim2New(0.57, -8, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                DashItems["WelcomeLabel"] = Instances:Create("TextLabel", {
                    Parent = LeftCol.Instance,
                    Name = "\0",
                    FontFace = Library.Fonts.Light,
                    TextColor3 = FromRGB(160, 158, 180),
                    Text = DashPage.WelcomeText,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                DashItems["HubName"] = Instances:Create("TextLabel", {
                    Parent = LeftCol.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    Text = DashPage.HubName or Window.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 38),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 30,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIGradient", {
                    Parent = DashItems["HubName"].Instance,
                    Name = "\0",
                    Rotation = -90
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                DashItems["StatusText"] = Instances:Create("TextLabel", {
                    Parent = LeftCol.Instance,
                    Name = "\0",
                    FontFace = Library.Fonts.Light,
                    TextColor3 = FromRGB(120, 118, 145),
                    Text = DashPage.StatusText or Window.SubName,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 62),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 13,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                DashItems["LinksRow"] = Instances:Create("Frame", {
                    Parent = LeftCol.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 86),
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = DashItems["LinksRow"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                for _, link in DashPage.Links do
                    local linkBtn = Instances:Create("TextButton", {
                        Parent = DashItems["LinksRow"].Instance,
                        Name = "\0",
                        AutoButtonColor = false,
                        Text = "",
                        BorderSizePixel = 0,
                        Size = UDim2New(0, 30, 0, 30),
                        ZIndex = 3,
                        BackgroundTransparency = 0.1,
                        BackgroundColor3 = FromRGB(30, 28, 38)
                    })  linkBtn:AddToTheme({BackgroundColor3 = "Element"})

                    local linkHoverRing = Instances:Create("Frame", {
                        Parent = linkBtn.Instance,
                        Name = "\0",
                        Active = false,
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        Size = UDim2New(1, 8, 1, 8),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 1,
                        BackgroundColor3 = FromRGB(100, 149, 255)
                    })
                    linkHoverRing:AddToTheme({BackgroundColor3 = "Accent"})
                    Instances:Create("UICorner", {
                        Parent = linkHoverRing.Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(1, 0)
                    })

                    Instances:Create("UICorner", {
                        Parent = linkBtn.Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(1, 0)
                    })

                    local linkStroke = Instances:Create("UIStroke", {
                        Parent = linkBtn.Instance,
                        Name = "\0",
                        Thickness = 2.25,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Transparency = 1,
                    }):AddToTheme({Color = "Accent"})

                    local linkIcon = Instances:Create("ImageLabel", {
                        Parent = linkBtn.Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        Size = UDim2New(0, 16, 0, 16),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 4,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    Library:SetIcon(linkIcon.Instance, link.Icon or "link")
                    Instances:Create("UIGradient", {
                        Parent = linkIcon.Instance,
                        Name = "\0",
                        Rotation = -115
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})

                    linkBtn:Connect("MouseButton1Down", function()
                        if link.Callback then Library:SafeCall(link.Callback) end
                    end)
                    linkBtn:OnHover(function()
                        linkBtn:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 0})
                        linkHoverRing:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.35})
                        if linkStroke and linkStroke.Instance then
                            TweenService:Create(linkStroke.Instance, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Transparency = 0.06}):Play()
                        end
                    end)
                    linkBtn:OnHoverLeave(function()
                        linkBtn:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 0.1})
                        linkHoverRing:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
                        if linkStroke and linkStroke.Instance then
                            TweenService:Create(linkStroke.Instance, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
                        end
                    end)
                    linkBtn:Connect("InputBegan", function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch and linkStroke and linkStroke.Instance then
                            TweenService:Create(linkStroke.Instance, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {Transparency = 0.06}):Play()
                        end
                    end)
                    linkBtn:Connect("InputEnded", function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch and linkStroke and linkStroke.Instance then
                            TweenService:Create(linkStroke.Instance, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {Transparency = 1}):Play()
                        end
                    end)
                    if link.Tooltip then
                        Library:AttachTooltip(linkBtn.Instance, link.Tooltip)
                    end
                end

                do
                    local d1 = Instances:Create("Frame", {
                        Parent = LeftCol.Instance,
                        Name = "\0",
                        BackgroundColor3 = FromRGB(38, 36, 44),
                        Position = UDim2New(0, 0, 0, 119),
                        Size = UDim2New(1, 0, 0, 1),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundTransparency = 0,
                    })
                    d1:AddToTheme({BackgroundColor3 = "Outline"})
                end

                DashItems["GameName"] = Instances:Create("TextLabel", {
                    Parent = LeftCol.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(245, 244, 255),
                    Text = DashPage.GameName,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 126),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 22,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  DashItems["GameName"]:AddToTheme({TextColor3 = "Text"})

                DashItems["GameDesc"] = Instances:Create("TextLabel", {
                    Parent = LeftCol.Instance,
                    Name = "\0",
                    FontFace = Library.Fonts.Light,
                    TextColor3 = FromRGB(120, 118, 148),
                    Text = DashPage.GameDescription,
                    Size = UDim2New(1, 0, 0, 40),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 156),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                do
                    local d2 = Instances:Create("Frame", {
                        Parent = LeftCol.Instance,
                        Name = "\0",
                        BackgroundColor3 = FromRGB(38, 36, 44),
                        Position = UDim2New(0, 0, 0, 197),
                        Size = UDim2New(1, 0, 0, 1),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundTransparency = 0,
                    })
                    d2:AddToTheme({BackgroundColor3 = "Outline"})
                end

                local RightCol = Instances:Create("Frame", {
                    Parent = DashItems["HeroRow"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.59, 0, 0, 0),
                    Size = UDim2New(0.41, 0, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                DashItems["AvatarRing"] = Instances:Create("Frame", {
                    Parent = RightCol.Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 58, 0, 58),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(40, 38, 48)
                })  DashItems["AvatarRing"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = DashItems["AvatarRing"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })

                Instances:Create("UIStroke", {
                    Parent = DashItems["AvatarRing"].Instance,
                    Name = "\0",
                    Thickness = 2
                }):AddToTheme({Color = "Accent"})

                DashItems["Avatar"] = Instances:Create("ImageLabel", {
                    Parent = DashItems["AvatarRing"].Instance,
                    Name = "\0",
                    Image = AvatarImage,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(1, -4, 1, -4),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = DashItems["Avatar"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })

                DashItems["PlayerName"] = Instances:Create("TextLabel", {
                    Parent = RightCol.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(225, 223, 240),
                    Text = LocalPlayer.DisplayName,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 18),
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 64),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  DashItems["PlayerName"]:AddToTheme({TextColor3 = "Text"})

                DashItems["Badge"] = Instances:Create("TextLabel", {
                    Parent = RightCol.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    Text = " " .. (DashPage.Badge or "PLAYER") .. " ",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 20),
                    BackgroundTransparency = 0,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 86),
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BorderSizePixel = 0,
                    ZIndex = 3,
                    TextSize = 11,
                    BackgroundColor3 = FromRGB(100, 140, 255)
                })  DashItems["Badge"]:AddToTheme({BackgroundColor3 = "Accent"})

                Instances:Create("UICorner", {
                    Parent = DashItems["Badge"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })

                DashItems["StatsContainer"] = Instances:Create("Frame", {
                    Parent = RightCol.Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 114),
                    Size = UDim2New(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = DashItems["StatsContainer"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                DashItems["StatItems"] = {}

                local function AddStat(Name, GetValue, Icon)
                    local statFrame = Instances:Create("Frame", {
                        Parent = DashItems["StatsContainer"].Instance,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        Size = UDim2New(1, 0, 0, 18),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    local statIcon = Instances:Create("ImageLabel", {
                        Parent = statFrame.Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0, 0.5),
                        Position = UDim2New(0, 0, 0.5, 0),
                        Size = UDim2New(0, 13, 0, 13),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 3,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    Library:SetIcon(statIcon.Instance, Icon or "activity")
                    Instances:Create("UIGradient", {
                        Parent = statIcon.Instance,
                        Name = "\0",
                        Rotation = -115
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})

                    Instances:Create("TextLabel", {
                        Parent = statFrame.Instance,
                        Name = "\0",
                        FontFace = Library.Fonts.Light,
                        TextColor3 = FromRGB(100, 98, 125),
                        Text = StringLower(Name),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2New(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, 18, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        TextSize = 12,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    local statVal = Instances:Create("TextLabel", {
                        Parent = statFrame.Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(215, 215, 235),
                        Text = "—",
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2New(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2New(1, 0),
                        Position = UDim2New(1, 0, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        TextSize = 12,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  statVal:AddToTheme({TextColor3 = "Text"})

                    DashItems["StatItems"][Name] = {
                        Frame = statFrame,
                        Value = statVal,
                        GetValue = GetValue
                    }
                end

                for _, StatData in DashPage.Stats do
                    AddStat(StatData.Name or "Stat", StatData.GetValue, StatData.Icon)
                end

                if #DashPage.Stats > 0 then
                    Library:Connect(RunService.Heartbeat, function()
                        for _, StatInfo in DashItems["StatItems"] do
                            if StatInfo.GetValue then
                                local ok, val = pcall(StatInfo.GetValue)
                                if ok and val ~= nil then
                                    StatInfo.Value.Instance.Text = tostring(val)
                                end
                            end
                        end
                    end)
                end

                DashItems["Sep1"] = Instances:Create("Frame", {
                    Parent = DashItems["Page"].Instance,
                    Name = "\0",
                    BackgroundColor3 = FromRGB(38, 36, 46),
                    Position = UDim2New(0, 0, 0, 196),
                    Size = UDim2New(0.59, -12, 0, 1),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundTransparency = 0
                })  DashItems["Sep1"]:AddToTheme({BackgroundColor3 = "Element"})

                DashItems["QASep"] = Instances:Create("TextLabel", {
                    Parent = DashItems["Page"].Instance,
                    Name = "\0",
                    FontFace = Library.Fonts.Light,
                    TextColor3 = FromRGB(80, 78, 102),
                    Text = "QUICK ACCESS",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 206),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 11,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                DashItems["QARow"] = Instances:Create("Frame", {
                    Parent = DashItems["Page"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 228),
                    Size = UDim2New(1, 0, 1, -228),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = DashItems["QARow"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                DashItems["QACards"] = {}

                AddQuickCard = function(CardData, Index)
                    local numCards = #DashPage.QuickAccess
                    local card = Instances:Create("TextButton", {
                        Parent = DashItems["QARow"].Instance,
                        Name = "\0",
                        AutoButtonColor = false,
                        Text = "",
                        BackgroundColor3 = FromRGB(22, 21, 26),
                        BorderSizePixel = 0,
                        Size = UDim2New(1 / numCards, Index < numCards and -8 or 0, 1, 0),
                        ZIndex = 2,
                        BackgroundTransparency = 0
                    })  card:AddToTheme({BackgroundColor3 = "Section Background 2"})

                    Instances:Create("UICorner", {
                        Parent = card.Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 6)
                    })

                    local cardStroke = Instances:Create("UIStroke", {
                        Parent = card.Instance,
                        Name = "\0",
                        Color = FromRGB(38, 36, 46),
                        Thickness = 1,
                        Transparency = 0
                    })

                    local cardIcon = Instances:Create("ImageLabel", {
                        Parent = card.Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0.5, 0),
                        Position = UDim2New(0.5, 0, 0, 22),
                        Size = UDim2New(0, 28, 0, 28),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 3,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                    Library:SetIcon(cardIcon.Instance, CardData.Icon or "layout-grid")
                    Instances:Create("UIGradient", {
                        Parent = cardIcon.Instance,
                        Name = "\0",
                        Rotation = -115
                    }):AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})

                    Instances:Create("TextLabel", {
                        Parent = card.Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(225, 224, 240),
                        Text = CardData.Name or "Tab",
                        Size = UDim2New(1, -20, 0, 18),
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2New(0.5, 0),
                        Position = UDim2New(0.5, 0, 0, 56),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        TextSize = 14,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    Instances:Create("TextLabel", {
                        Parent = card.Instance,
                        Name = "\0",
                        FontFace = Library.Fonts.Light,
                        TextColor3 = FromRGB(100, 98, 130),
                        Text = CardData.Description or "",
                        Size = UDim2New(1, -20, 0, 32),
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2New(0.5, 0),
                        Position = UDim2New(0.5, 0, 0, 78),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextWrapped = true,
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        TextSize = 12,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })

                    card:OnHover(function()
                        card:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = FromRGB(30, 28, 36)})
                        Tween:Create(cardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Color = Library.Theme.Accent, Transparency = 0}, true)
                    end)
                    card:OnHoverLeave(function()
                        card:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart), {BackgroundColor3 = Library.Theme["Section Background 2"]})
                        Tween:Create(cardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Color = FromRGB(38, 36, 46), Transparency = 0}, true)
                    end)

                    card:Connect("MouseButton1Down", function()
                        if type(CardData.Tab) == "table" and CardData.Tab.Turn then
                            local W = DashPage.Window
                            local now = tick()
                            if now < (W._tabCooldownUntil or 0) then return end
                            local target = CardData.Tab
                            for _, P in DashPage.Window.Pages do
                                if P == target and target.Active then return end
                            end
                            for _, P in DashPage.Window.Pages do
                                if P ~= target and P.InstantDeactivate then
                                    P:InstantDeactivate()
                                end
                            end
                            target:Turn(true)
                            W._tabCooldownUntil = now + (W.TabSwitchCooldownSec or 0.5)
                        elseif type(CardData.Callback) == "function" then
                            Library:SafeCall(CardData.Callback)
                        end
                    end)

                    DashItems["QACards"][Index] = card
                end

                for i, CardData in DashPage.QuickAccess do
                    AddQuickCard(CardData, i)
                end

                DashPage.Items = DashItems
            end

            local DashDebounce = false

            function DashPage:InstantDeactivate()
                DashItems["Inactive"].Instance.BackgroundTransparency = 1
                DashItems["TabIndicator"].Instance.BackgroundTransparency = 1
                DashItems["Page"].Instance.Visible = false
                DashItems["Page"].Instance.Parent = Library.UnusedHolder.Instance
                DashItems["Page"].Instance.GroupTransparency = 1
                DashPage.Active = false
                DashDebounce = false
            end

            function DashPage:Turn(Bool)
                if DashDebounce then return end
                DashPage.Active = Bool
                DashDebounce = true

                local dti = TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                if Bool then
                    DashItems["Page"].Instance.Visible = true
                    DashItems["Page"].Instance.Parent = DashPage.Window.Items["Content"].Instance
                    DashItems["Page"].Instance.GroupTransparency = 1
                    DashItems["Page"].Instance.Position = UDim2New(0, 0, 0, 28)

                    DashItems["Inactive"]:Tween(nil, {BackgroundTransparency = 0.88})
                    DashItems["TabIndicator"]:Tween(nil, {BackgroundTransparency = 0})

                    local NewTween = Tween:Create(DashItems["Page"].Instance, dti, {GroupTransparency = 0, Position = UDim2New(0, 0, 0, 0)}, true)
                    if NewTween and NewTween.Tween then
                        Library:Connect(NewTween.Tween.Completed, function()
                            DashDebounce = false
                        end)
                    else
                        DashDebounce = false
                    end
                else
                    DashItems["Inactive"]:Tween(nil, {BackgroundTransparency = 1})
                    DashItems["TabIndicator"]:Tween(nil, {BackgroundTransparency = 1})

                    local NewTween = Tween:Create(DashItems["Page"].Instance, dti, {GroupTransparency = 1, Position = UDim2New(0, 0, 0, 36)}, true)
                    if NewTween and NewTween.Tween then
                        Library:Connect(NewTween.Tween.Completed, function()
                            DashItems["Page"].Instance.Visible = false
                            DashItems["Page"].Instance.Parent = Library.UnusedHolder.Instance
                            DashDebounce = false
                        end)
                    else
                        DashItems["Page"].Instance.Visible = false
                        DashItems["Page"].Instance.Parent = Library.UnusedHolder.Instance
                        DashDebounce = false
                    end
                end
            end

            function DashPage:SetGameName(Name)
                DashItems["GameName"].Instance.Text = tostring(Name)
            end

            function DashPage:SetGameDescription(Desc)
                DashItems["GameDesc"].Instance.Text = tostring(Desc)
            end

            function DashPage:SetStat(Name, Value)
                if DashItems["StatItems"] and DashItems["StatItems"][Name] then
                    DashItems["StatItems"][Name].Value.Instance.Text = tostring(Value)
                end
            end

            function DashPage:AddCard(CardData)
                local idx = #DashItems["QACards"] + 1
                TableInsert(DashPage.QuickAccess, CardData)
                AddQuickCard(CardData, idx)
                local numCards = #DashPage.QuickAccess
                for i, card in DashItems["QACards"] do
                    card.Instance.Size = UDim2New(1 / numCards, i < numCards and -8 or 0, 1, 0)
                end
            end

            DashItems["Inactive"]:Connect("MouseButton1Down", function()
                local W = DashPage.Window
                local now = tick()
                if now < (W._tabCooldownUntil or 0) then return end
                for _, Value in DashPage.Window.Pages do
                    if Value == DashPage and DashPage.Active then return end
                end
                for _, Value in DashPage.Window.Pages do
                    if Value ~= DashPage and Value.InstantDeactivate then
                        Value:InstantDeactivate()
                    end
                end
                DashPage:Turn(true)
                W._tabCooldownUntil = now + (W.TabSwitchCooldownSec or 0.5)
            end)

            if #DashPage.Window.Pages == 0 then
                DashPage:Turn(true)
            end

            TableInsert(DashPage.Window.Pages, DashPage)
            return DashPage
        end

        Library.Pages.GlobalChat = function(self, Side)
            local GlobalChat = { }
            Library.GlobalChatt = GlobalChat

            local Items = { } do 
                Items["GlobalChat"] = Instances:Create("Frame", {
                    Parent = self.ColumnsData[Side].Instance,
                    Name = "\0",
                    BackgroundTransparency = 0.30000001192092896,
                    Position = UDim2New(0,0,0,0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["GlobalChat"]:AddToTheme({BackgroundColor3 = "Section Background 2"})

                Items["GlobalChat"]:MakeDraggable()
                
                Instances:Create("UICorner", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "GLOBAL CHAT",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 13),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 16,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Items["SubTitle"] = Instances:Create("TextLabel", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.4000000059604645,
                    Text = "Chat with other users here.",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 14, 0, 30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["SubTitle"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Message"] = Instances:Create("Frame", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 1),
                    Selectable = true,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 1, -12),
                    Size = UDim2New(1, -66, 0, 32),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Message"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Message"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Message"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    Selectable = true,
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    ZIndex = 2,
                    Size = UDim2New(1, -20, 0, 15),
                    Position = UDim2New(0, 10, 0, 8),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    PlaceholderText = "Message...",
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Input"]:AddToTheme({TextColor3 = "Text"})
                
                Items["SendButton"] = Instances:Create("TextButton", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 1),
                    Position = UDim2New(1, -12, 1, -12),
                    Size = UDim2New(0, 32, 0, 32),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["SendButton"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["SendButton"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["SendIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["SendButton"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ImageTransparency = 0.2,
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://101636617799068",
                    BackgroundTransparency = 1,
                    ZIndex = 3,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 22, 0, 22),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["SendButton"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0)
                })

                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["SendButton"]:OnHover(function()
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time+0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 0})
                end)

                Items["SendButton"]:OnHoverLeave(function()
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time+0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 0, 0, 0), BackgroundTransparency = 1})
                end)
                
                Items["Messages"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    ScrollBarImageColor3 = FromRGB(124, 163, 255),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    Size = UDim2New(1, -24, 1, -115),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 60),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  Items["Messages"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Messages"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                Instances:Create("UIPadding", {
                    Parent = Items["Messages"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 0),
                    PaddingBottom = UDimNew(0, 0),
                    PaddingRight = UDimNew(0, 10),
                    PaddingLeft = UDimNew(0, 0)
                })

                Items["Status"] = Instances:Create("Frame", {
                    Parent = Items["GlobalChat"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -12, 0, 10),
                    Size = UDim2New(0, 100, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["StatusCircle"] = Instances:Create("Frame", {
                    Parent = Items["Status"].Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 12, 0, 12),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 210, 62)
                })

                Items["Glow"] = Instances:Create("ImageLabel", {
                    Parent = Items["StatusCircle"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 210, 62),
                    ScaleType = Enum.ScaleType.Slice,
                    ImageTransparency = 0.30000001192092896,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    Size = UDim2New(1, 8, 1, 8),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "http://www.roblox.com/asset/?id=18245826428",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    SliceCenter = RectNew(Vector2New(21, 21), Vector2New(79, 79))
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["StatusCircle"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(1, 0)
                })
                
                Items["StatusText"] = Instances:Create("TextLabel", {
                    Parent = Items["Status"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 210, 62),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "67 Active | Connected",
                    AnchorPoint = Vector2New(1, 0.5),
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -20, 0.5, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })                
            end

            function GlobalChat:SetVisibility(Bool)
                Items["GlobalChat"].Instance.Visible = Bool
                Items["GlobalChat"].Instance.Parent = Bool and Data.MainFrame.Instance or Library.UnusedHolder
            end

            function GlobalChat:SetStatus(Text, Color)
                Items["StatusText"].Instance.Text = Text
                Items["StatusText"].Instance.TextColor3 = Color
                Items["StatusCircle"].Instance.BackgroundColor3 = Color
            end

            function GlobalChat:SetStatusText(Text)
                if not Done then
                    Items["StatusText"].Instance.TextColor3 = FromRGB(62, 255, 91)
                    Items["Glow"].Instance.ImageColor3 = FromRGB(62, 255, 91)
                    Items["StatusCircle"].Instance.BackgroundColor3 = FromRGB(62, 255, 91)
                    Done = true
                end
                Items["StatusText"].Instance.Text = Text
            end

            local OnMessagePressed            

            function GlobalChat:OnMessageSendPressed(Func)
                OnMessagePressed = Func
            end

            function GlobalChat:GetTypedMessage()
                return Items["Input"].Instance.Text
            end

            function GlobalChat:ClearText()
                Items["Input"].Instance.Text = ""
            end

            function GlobalChat:SendMessage(Avatar, Username, Message, IsLocalPlayer)
                local SubItems = { } do
                    if not IsLocalPlayer then
                        SubItems["Message1"] = Instances:Create("Frame", {
                            Parent = Items["Messages"].Instance,
                            Name = "\0",
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 45),
                            ZIndex = 2,
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        SubItems["PlayerName"] = Instances:Create("TextLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Username,
                            Size = UDim2New(0, 0, 0, 15),
                            BackgroundTransparency = 1,
                            RichText = true,
                            Position = UDim2New(0, 38, 0, 0),
                            TextTransparency = 0.3,
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 14,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["PlayerName"]:AddToTheme({TextColor3 = "Text"})

                        SubItems["RealMessage"] = Instances:Create("Frame", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            Position = UDim2New(0, 38, 0, 20),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundColor3 = FromRGB(27, 25, 29)
                        })  SubItems["RealMessage"]:AddToTheme({BackgroundColor3 = "Background"})

                        Instances:Create("UISizeConstraint", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            MaxSize = Vector2New(370, 70)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })

                        SubItems["MessageText"] = Instances:Create("TextLabel", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Message,
                            BackgroundTransparency = 1,
                            TextWrapped = true,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            TextSize = 14,
                            ZIndex = 2,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["MessageText"]:AddToTheme({TextColor3 = "Text"})

                        Instances:Create("UIPadding", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            PaddingTop = UDimNew(0, 10),
                            PaddingBottom = UDimNew(0, 10),
                            PaddingRight = UDimNew(0, 10),
                            PaddingLeft = UDimNew(0, 10)
                        })

                        SubItems["Avatar"] = Instances:Create("ImageLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            BorderColor3 = FromRGB(0, 0, 0),
                            AnchorPoint = Vector2New(0, 0.5),
                            Image = Avatar,
                            BackgroundTransparency = 1,
                            Position = UDim2New(0, 0, 0.5, 0),
                            Size = UDim2New(0, 30, 0, 30),
                            ZIndex = 2,
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["Avatar"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })
                    else
                        SubItems["Message1"] = Instances:Create("Frame", {
                            Parent = Items["Messages"].Instance,
                            Name = "\0",
                            BackgroundTransparency = 1,
                            Size = UDim2New(1, 0, 0, 45),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        SubItems["PlayerName"] = Instances:Create("TextLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Username,
                            RichText = true,
                            AnchorPoint = Vector2New(1, 0),
                            Size = UDim2New(0, 0, 0, 15),
                            ZIndex = 2,
                            TextTransparency = 0.3,
                            BackgroundTransparency = 1,
                            Position = UDim2New(1, -38, 0, 0),
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.X,
                            TextSize = 14,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["PlayerName"]:AddToTheme({TextColor3 = "Text"})

                        SubItems["RealMessage"] = Instances:Create("Frame", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            AnchorPoint = Vector2New(1, 0),
                            Position = UDim2New(1, -38, 0, 20),
                            BorderColor3 = FromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            BackgroundColor3 = FromRGB(27, 25, 29)
                        })  SubItems["RealMessage"]:AddToTheme({BackgroundColor3 = "Background"})

                        Instances:Create("UISizeConstraint", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            MaxSize = Vector2New(370, 75)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })

                        SubItems["MessageText"] = Instances:Create("TextLabel", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            FontFace = Library.Font,
                            TextColor3 = FromRGB(240, 240, 240),
                            BorderColor3 = FromRGB(0, 0, 0),
                            Text = Message,
                            BackgroundTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BorderSizePixel = 0,
                            AutomaticSize = Enum.AutomaticSize.XY,
                            ZIndex = 2,
                            TextWrapped = true,
                            TextSize = 14,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })  SubItems["MessageText"]:AddToTheme({TextColor3 = "Text"})

                        Instances:Create("UIPadding", {
                            Parent = SubItems["RealMessage"].Instance,
                            Name = "\0",
                            PaddingTop = UDimNew(0, 10),
                            PaddingBottom = UDimNew(0, 10),
                            PaddingRight = UDimNew(0, 10),
                            PaddingLeft = UDimNew(0, 10)
                        })

                        SubItems["Avatar"] = Instances:Create("ImageLabel", {
                            Parent = SubItems["Message1"].Instance,
                            Name = "\0",
                            BorderColor3 = FromRGB(0, 0, 0),
                            AnchorPoint = Vector2New(1, 0.5),
                            Image = Avatar,
                            ZIndex = 2,
                            BackgroundTransparency = 1,
                            Position = UDim2New(1, 0, 0.5, 0),
                            Size = UDim2New(0, 30, 0, 30),
                            BorderSizePixel = 0,
                            BackgroundColor3 = FromRGB(255, 255, 255)
                        })

                        Instances:Create("UICorner", {
                            Parent = SubItems["Avatar"].Instance,
                            Name = "\0",
                            CornerRadius = UDimNew(0, 4)
                        })
                    end
                end
            end

            Items["SendButton"]:Connect("MouseButton1Down", function()
                if GlobalChat:GetTypedMessage() == "" then
                    return
                end
                
                OnMessagePressed()
            end)

            Items["Messages"]:Connect("ChildAdded", function()
                task.wait()
                Items["Messages"]:Tween(nil, {CanvasPosition = Vector2New(0, Items["Messages"].Instance.AbsoluteCanvasSize.Y - Items["Messages"].Instance.AbsoluteSize.Y)})
            end)

            for Index, Value in Items["GlobalChat"].Instance:GetDescendants() do 
                if Value.ClassName:find("UI") then 
                    continue 
                end

                Value.ZIndex = 2
            end

            Items["GlobalChat"].Instance.ZIndex = 2
            Items["SendIcon"].Instance.ZIndex = 3

            return GlobalChat 
        end

        Library.Pages.Section = function(self, Data)
            Data = Data or { }

            local Section = {
                Window = self.Window,
                Page = self,

                Name = Data.Name or Data.name or "Section",
                Description = Data.Description or Data.Description or "",
                Icon = Data.Icon or Data.icon or "123944728972740",
                Side = Data.Side or Data.side or 1,

                Items = { },
                IsActive = true,
                Elements = { }
            }

            local Items = { } do
                Items["Section"] = Instances:Create("Frame", {
                    Parent = Section.Page.ColumnsData[Section.Side].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                    Size = UDim2New(1, 0, 0, 45),
                    ZIndex = 2,
                    LayoutOrder = Data.LayoutOrder or Data.layoutOrder or 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(29, 28, 32)
                })  Items["Section"]:AddToTheme({BackgroundColor3 = "Section Background 2"})
                
                Items["Top"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 0.6499999761581421,
                    Size = UDim2New(1, 0, 0, 55),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(31, 31, 36)
                })  Items["Top"]:AddToTheme({BackgroundColor3 = "Outline"})
                
                Items["TopBackground"] = Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(0, 1, 0, 1),
                    Size = UDim2New(1, -2, 1, -2),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["TopBackground"]:AddToTheme({BackgroundColor3 = "Section Top"})
                
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["TopBackground"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 21, 0, 20),
                    AnchorPoint = Vector2New(0, 0.5),
                    Image = "",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 15, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Library:SetIcon(Items["Icon"].Instance, Section.Icon)
                
                Instances:Create("UIGradient", {
                    Parent = Items["Icon"].Instance,
                    Name = "\0",
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Items["Description"] = Instances:Create("TextLabel", {
                    Parent = Items["TopBackground"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(183, 183, 183),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Section.Description,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 50, 0, 28),
                    BorderSizePixel = 0,
                    TextTransparency = 0.4,
                    ZIndex = 2,
                    TextSize = 15,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Description"]:AddToTheme({TextColor3 = "Text"})
                
                Instances:Create("UICorner", {
                    Parent = Items["TopBackground"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Title"] = Instances:Create("TextLabel", {
                    Parent = Items["TopBackground"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(248, 248, 248),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Section.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 50, 0, 10),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 15,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Title"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    Active = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0.5),
                    Selectable = false,
                    Position = UDim2New(1, -15, 0.5, 0),
                    Size = UDim2New(0, 26, 0, 16),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Circle"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0.5),
                    Position = UDim2New(1, -4, 0.5, 0),
                    Size = UDim2New(0, 8, 0, 8),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Circle"]:AddToTheme({BackgroundColor3 = "Text"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Circle"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 99999)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 9)
                })
                
                Items["Gradient"] = Instances:Create("UIGradient", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                })  Items["Gradient"]:AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Instances:Create("UICorner", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Fill"] = Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 1, 1, -4),
                    Size = UDim2New(1, -2, 0, 4),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Fill"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Fill"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["TopFills"] = Instances:Create("Frame", {
                    Parent = Items["Top"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 1),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 3),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  
                
                Items["Right1"] = Instances:Create("Frame", {
                    Parent = Items["TopFills"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(1, -1, 0, 0),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Right1"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Items["Right2"] = Instances:Create("Frame", {
                    Parent = Items["TopFills"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(1, -1, 0, 1),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Right2"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Items["Right3"] = Instances:Create("Frame", {
                    Parent = Items["TopFills"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(1, -2, 0, 1),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Right3"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Items["Left1"] = Instances:Create("Frame", {
                    Parent = Items["TopFills"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(0, 2, 0, 0),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Left1"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Items["Left2"] = Instances:Create("Frame", {
                    Parent = Items["TopFills"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(0, 2, 0, 1),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Left2"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Items["Left3"] = Instances:Create("Frame", {
                    Parent = Items["TopFills"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(0, 3, 0, 1),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(26, 26, 30)
                })  Items["Left3"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Section"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Section"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 0.6499999761581421,
                    Position = UDim2New(0, 1, 0, 55),
                    Size = UDim2New(1, -2, 1, -56),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(24, 22, 25)
                })  Items["Background"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Items["Content"] = Instances:Create("Frame", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 12, 0, 15),
                    Size = UDim2New(1, -24, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })                

                Items["Fade"] = Instances:Create("TextButton", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 0, 10, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutoButtonColor = false,
                    Visible = false,
                    Text = "",
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(24, 22, 25)
                })  Items["Fade"]:AddToTheme({BackgroundColor3 = "Section Background"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Fade"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })                

                Instances:Create("UIPadding", {
                    Parent = Items["Content"].Instance,
                    Name = "\0",
                    PaddingBottom = UDimNew(0, 10)
                })

                Section.Items = Items
            end

            function Section:ToggleBackground()
                Section.IsActive = not Section.IsActive

                if not Section.IsActive then 
                    Items["Fade"].Instance.Visible = true
                    Items["Fade"]:Tween(nil, {BackgroundTransparency = 0.3})
    
                    Items["Gradient"].Instance.Enabled = false
                    Items["Toggle"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                    Items["Toggle"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                    Items["Circle"]:Tween(nil, {AnchorPoint = Vector2New(0, 0.5), Position = UDim2New(0, 4, 0.5, 0), BackgroundColor3 = Library.Theme.Text, BackgroundTransparency = 0.6})
                else
                    Items["Fade"]:Tween(nil, {BackgroundTransparency = 1})
                    task.spawn(function() 
                        task.wait(Library.Tween.Time)
                        Items["Fade"].Instance.Visible = false
                    end)

                    Items["Gradient"].Instance.Enabled = true
                    Items["Toggle"]:ChangeItemTheme({BackgroundColor3 = "Text"})
                    Items["Toggle"]:Tween(nil, {BackgroundColor3 = Library.Theme.Text})
                    Items["Circle"]:Tween(nil, {AnchorPoint = Vector2New(1, 0.5), Position = UDim2New(1, -4, 0.5, 0), BackgroundColor3 = Library.Theme.Text, BackgroundTransparency = 0})
                end
            end

            Library:Connect(Items["Content"].Instance.Changed, function(Property)
                if Property == "AbsoluteSize" then
                    Items["Fade"].Instance.Size = UDim2New(1, 0, 0, Items["Content"].Instance.AbsoluteSize.Y + 10)
                end
            end)

            function Section:TweenElements(Bool, Debounce)
                for Index, Value in Section.Elements do
                    Value:RefreshPosition(Bool)
                end
            end

            Items["Toggle"]:Connect("MouseButton1Down", function()
                Section:ToggleBackground()
            end)

            Section.Page.Sections[Section.Name] = Section

            return setmetatable(Section, Library.Sections)
        end

        Library.Sections.Toggle = function(self, Data)
            Data = Data or { }
            
            local Toggle = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Toggle",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or false,
                Callback = Data.Callback or Data.callback or function() end,

                Value = false
            }

            local Items = { } do 
                Items["Toggle"] = Instances:Create("TextButton", {
                    Parent = Toggle.Section.Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2New(1, 0, 0, 18),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Indicator"] = Instances:Create("Frame", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 18, 0, 18),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(124, 163, 255)
                })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 3)
                })
                
                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["Indicator"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0)
                })

                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 3)
                })

                Items["CheckImage"] = Instances:Create("ImageLabel", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 0, 0, 0),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://121760666525660",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    ImageTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["CheckImage"]:AddToTheme({ImageColor3 = "Text"})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Toggle"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = Toggle.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    Position = UDim2New(0, 24, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["Gradient"] = Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                })  Items["Gradient"]:AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["Toggle"]:OnHover(function()
                    Items["Indicator"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 21, 0, 21), Position = UDim2New(0, -3, 0, -3)})
                end)

                Items["Toggle"]:OnHoverLeave(function()
                    Items["Indicator"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 18, 0, 18), Position = UDim2New(0, 0, 0, 0)})
                end)
            end

            Items["Indicator"].Instance.Position = UDim2New(0, 60, 0, 0)
            Items["Text"].Instance.Position = UDim2New(0, 84, 0, 0)

            function Toggle:Get()
                return Toggle.Value 
            end

            function Toggle:Set(Value, SkipCallback)
                Toggle.Value = Value 
                Library.Flags[Toggle.Flag] = Value 

                if Toggle.Value then 
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Size = UDim2New(1, 0, 1, 0)})
                    Items["CheckImage"]:Tween(nil, {ImageTransparency = 0, Size = UDim2New(0, 10, 0, 9)})
                else
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 0)})
                    Items["CheckImage"]:Tween(nil, {ImageTransparency = 1, Size = UDim2New(0, 0, 0, 0)})
                end

                if Toggle.Callback and not SkipCallback then 
                    Library:SafeCall(Toggle.Callback, Toggle.Value)
                end

                Library._NotifyKeybindFlagListeners(Toggle.Flag)
            end

            local SettingsItem = { }

            function Toggle:Settings(Size)
                local Settings = {
                    IsOpen = false,
                    Name = "",
                    Items = { },
                    IsSettings = true,
                    Elements = { } 
                }
                Toggle.Settings = Settings

                SettingsItem = { } do 
                    SettingsItem["Settings"] = Instances:Create("Frame", {
                        Parent = Library.UnusedHolder.Instance,
                        Name = "\0",
                        Visible = false,
                        BorderColor3 = FromRGB(0, 0, 0),
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BorderSizePixel = 0,
                        Position = UDim2New(0.8949604630470276, 0, 0.2945185601711273, 0),
                        Size = UDim2New(0, 245, 0, 159),
                        ZIndex = 2,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundColor3 = FromRGB(21, 21, 24)
                    })  SettingsItem["Settings"]:AddToTheme({BackgroundColor3 = "Background"})

                    Instances:Create("UICorner", {
                        Parent = SettingsItem["Settings"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 6)
                    })                    

                    SettingsItem["SettingsIcon"] = Instances:Create("ImageLabel", {
                        Parent = Items["Text"].Instance,
                        Name = "\0",
                        ImageColor3 = FromRGB(141, 141, 150),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(0, 14, 0, 14),
                        AnchorPoint = Vector2New(0, 0.5),
                        Image = "rbxassetid://101500482366184",
                        BackgroundTransparency = 1,
                        Position = UDim2New(1, 6, 0.5, 1),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["SettingsIcon"] = SettingsItem["SettingsIcon"]

                    SettingsItem["Content"] = Instances:Create("ScrollingFrame", {
                        Parent = SettingsItem["Settings"].Instance,
                        Name = "\0",
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        Selectable = false,
                        Size = UDim2New(1, -8, 1, -46),
                        Position = UDim2New(0, 4, 0, 4),
                        ScrollBarThickness = 2,
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        BorderColor3 = FromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        CanvasSize = UDim2New(0, 0, 0, 0)
                    })  SettingsItem["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                    
                    Instances:Create("UIListLayout", {
                        Parent = SettingsItem["Content"].Instance,
                        Name = "\0",
                        Padding = UDimNew(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })
                    
                    Instances:Create("UIPadding", {
                        Parent = SettingsItem["Content"].Instance,
                        Name = "\0",
                        PaddingTop = UDimNew(0, 4),
                        PaddingBottom = UDimNew(0, 4),
                        PaddingRight = UDimNew(0, 4),
                        PaddingLeft = UDimNew(0, 4)
                    })

                    SettingsItem["Button"] = Instances:Create("TextButton", {
                        Parent = SettingsItem["Settings"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(0, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        Text = "",
                        AutoButtonColor = false,
                        BorderSizePixel = 0,
                        Size = UDim2New(1, -16, 0, 32),
                        ZIndex = 2,
                        AnchorPoint = Vector2New(0, 1),
                        Position = UDim2New(0, 8, 1, -8),
                        TextSize = 14,
                        BackgroundColor3 = FromRGB(27, 26, 29)
                    })  SettingsItem["Button"]:AddToTheme({BackgroundColor3 = "Element"})
    
                    SettingsItem["Accent"] = Instances:Create("Frame", {
                        Parent = SettingsItem["Button"].Instance,
                        Name = "\0",
                        Size = UDim2New(0, 0, 0, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0)
                    })  
    
                    SettingsItem["Gradient"] = Instances:Create("UIGradient", {
                        Parent = SettingsItem["Accent"].Instance,
                        Name = "\0",
                        Enabled = true,
                        Rotation = -115,
                        Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                    })  SettingsItem["Gradient"]:AddToTheme({Color = function()
                        return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                    end})
    
                    Instances:Create("UICorner", {
                        Parent = SettingsItem["Accent"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 4)
                    })
                    
                    Instances:Create("UICorner", {
                        Parent = SettingsItem["Button"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 4)
                    })
                    
                    SettingsItem["Text"] = Instances:Create("TextLabel", {
                        Parent = SettingsItem["Button"].Instance,
                        Name = "\0",
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(240, 240, 240),
                        TextTransparency = 0.30000001192092896,
                        Text = "Close",
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2New(0, 0, 0, 15),
                        AnchorPoint = Vector2New(0.5, 0.5),
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        TextSize = 14,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  SettingsItem["Text"]:AddToTheme({TextColor3 = "Text"})   

                    SettingsItem["Button"]:OnHover(function()
                        SettingsItem["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 0})
                    end)
    
                    SettingsItem["Button"]:OnHoverLeave(function()
                        SettingsItem["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 0, 0, 0), BackgroundTransparency = 1})
                    end)
                end

                local RenderStepped 
                local Debounce = false

                function Settings:SetOpen(Bool)
                    if Debounce then 
                        return
                    end
    
                    Settings.IsOpen = Bool
    
                    Debounce = true 
    
                    if Settings.IsOpen then 
                        task.spawn(function()
                            for Index, Value in Settings.Elements do
                                Value:RefreshPosition(true)
                                task.wait(0.03)
                            end
                        end)

                        SettingsItem["Settings"].Instance.Visible = true
                        SettingsItem["Settings"].Instance.Parent = Library.Holder.Instance
                        
                        RenderStepped = RunService.RenderStepped:Connect(function()
                            SettingsItem["Settings"].Instance.Position = UDim2New(
                                0, Items["Toggle"].Instance.AbsolutePosition.X + Items["Toggle"].Instance.AbsoluteSize.X / 1.9 + 15, 
                                0, Items["Toggle"].Instance.AbsolutePosition.Y + Items["Toggle"].Instance.AbsoluteSize.Y + Size / 1.9)
                            SettingsItem["Settings"].Instance.Size = UDim2New(0, 245, 0, Size)
                        end)
    
                        for Index, Value in Library.OpenFrames do 
                            if Value ~= Settings then 
                                Value:SetOpen(false)
                            end
                        end
    
                        Library.OpenFrames[Settings] = Settings 
                    else
                        for Index, Value in Settings.Elements do
                            Value:RefreshPosition(false)
                        end

                        if Library.OpenFrames[Settings] then 
                            Library.OpenFrames[Settings] = nil
                        end
    
                        if RenderStepped then 
                            RenderStepped:Disconnect()
                            RenderStepped = nil
                        end
                    end
    
                    local Descendants = SettingsItem["Settings"].Instance:GetDescendants()
                    TableInsert(Descendants, SettingsItem["Settings"].Instance)
    
                    local NewTween
    
                    for Index, Value in Descendants do 
                        local TransparencyProperty = Tween:GetProperty(Value)
    
                        if not TransparencyProperty then
                            continue 
                        end
    
                        if not Value.ClassName:find("UI") then 
                            Value.ZIndex = Settings.IsOpen and 7 or 1
                        end
    
                        if type(TransparencyProperty) == "table" then 
                            for _, Property in TransparencyProperty do 
                                NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                            end
                        else
                            NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                        end
                    end
                    
                    NewTween.Tween.Completed:Connect(function()
                        Debounce = false 
                        SettingsItem["Settings"].Instance.Visible = Settings.IsOpen
                        task.wait(0.2)
                        SettingsItem["Settings"].Instance.Parent = not Settings.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                    end)
                end

                SettingsItem["Button"]:Connect("MouseButton1Down", function()
                    Settings:SetOpen(false)
                end)

                SettingsItem["SettingsIcon"]:Connect("InputBegan", function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        Settings:SetOpen(not Settings.IsOpen)
                    end
                end)

                Library:Connect(UserInputService.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        if Library:IsMouseOverFrame(SettingsItem["Settings"]) then
                            return 
                        end

                        Settings:SetOpen(false)
                    end
                end)

                Settings.Items = SettingsItem
                Settings.Window = Toggle.Window
                Settings.Page = Toggle.Page

                setmetatable(Settings, Library.Sections)
                return Settings
            end

            function Toggle:SetVisibility(Bool)
                Items["Toggle"].Instance.Visible = Bool 
            end

            function Toggle:Colorpicker(Data)
                Data = Data or { }

                local Colorpicker = {
                    Window = Toggle.Window,
                    Page = Toggle.Page,
                    Section = Toggle.Section,

                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or false
                }

                if not Items["SubElements"] then
                    Items["SubElements"] = Instances:Create("Frame", {
                        Parent = Toggle.Section.Items["Content"].Instance,
                        Name = "\0",
                        Size = UDim2New(1, 0, 0, 26),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                    })
                end

                local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                    Parent = Items["SubElements"],
                    Parent2 = Items["Toggle"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Alpha = Colorpicker.Alpha
                })

                return NewColorpicker
            end

            function Toggle:Keybind(Data)
                Data = Data or { }

                local Keybind = {
                    Window = Toggle.Window,
                    Page = Toggle.Page,
                    Section = Toggle.Section,

                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Enum.KeyCode.E,
                    Callback = Data.Callback or Data.callback or function() end,
                    Mode = Data.Mode or Data.mode or "Toggle"
                }

                if not Items["SubElements"] then
                    Items["SubElements"] = Instances:Create("Frame", {
                        Parent = Toggle.Section.Items["Content"].Instance,
                        Name = "\0",
                        Size = UDim2New(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                    })
                end

                local NewKeybind = Library:CreateKeybind({
                    Parent = Items["SubElements"],
                    Window = Keybind.Window,
                    Page = Keybind.Page,
                    Flag = Keybind.Flag,
                    Default = Keybind.Default,
                    Mode = Keybind.Mode,
                    Callback = Keybind.Callback,
                    syncFlag = Toggle.Flag,
                })

                return NewKeybind
            end

            function Toggle:RefreshPosition(Bool)
                if Bool then 
                    Items["Indicator"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 0)})
                    Items["Text"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 24, 0, 0)})
                else
                    Items["Indicator"].Instance.Position = UDim2New(0, 60, 0, 0)
                    Items["Text"].Instance.Position = UDim2New(0, 84, 0, 0)
                end 
            end

            Items["Toggle"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                    if Items["SettingsIcon"] and Library:IsMouseOverFrame(Items["SettingsIcon"]) then
                        return 
                    end
                    
                    Toggle:Set(not Toggle.Value)
                end
            end)

            Toggle:Set(Toggle.Default, true)

            Library.SetFlags[Toggle.Flag] = function(Value)
                Toggle:Set(Value)
            end

            if Data.Tooltip or Data.tooltip then
                Library:AttachTooltip(Items["Toggle"].Instance, Data.Tooltip or Data.tooltip)
            end

            Toggle.Section.Elements[#Toggle.Section.Elements+1] = Toggle

            return Toggle 
        end

        Library.Sections.Button = function(self, Data)
            Data = Data or { }

            local Button = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Button",
                Icon = Data.Icon or Data.icon or nil,
                Callback = Data.Callback or Data.callback or function() end
            }

            local Items = { } do 
                Items["Button"] = Instances:Create("TextButton", {
                    Parent = Button.Section.Items["Content"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                    Size = UDim2New(1, 0, 0, 32),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element"})

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    Size = UDim2New(0, 0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0.5, 0, 0.5, 0)
                })

                Items["Gradient"] = Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                })  Items["Gradient"]:AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Instances:Create("UICorner", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Button"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = Button.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})          
                
                if Button.Icon then 
                    Items["Icon"] = Instances:Create("ImageLabel", {
                        Parent = Items["Text"].Instance,
                        Name = "\0",
                        ImageColor3 = FromRGB(240, 240, 240),
                        ImageTransparency = 0.30000001192092896,
                        BorderColor3 = FromRGB(0, 0, 0),
                        Size = UDim2New(0, 18, 0, 18),
                        AnchorPoint = Vector2New(1, 0.5),
                        Image = "rbxassetid://"..Button.Icon,
                        BackgroundTransparency = 1,
                        Position = UDim2New(0, -8, 0.5, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})
                end                    

                Items["Button"]:OnHover(function()
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 1, 0), BackgroundTransparency = 0})
                end)

                Items["Button"]:OnHoverLeave(function()
                    Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time + 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 0, 0, 0), BackgroundTransparency = 1})
                end)
            end 

            function Button:SetVisibility(Bool)
                Items["Button"].Instance.Visible = Bool
            end

            function Button:Press()
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Accent"})
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})

                Items["Text"]:Tween(nil, {TextColor3 = FromRGB(0, 0, 0), TextTransparency = 0})

                if Button.Icon then 
                    Items["Icon"]:Tween(nil, {ImageColor3 = FromRGB(0, 0, 0), ImageTransparency = 0})
                end

                task.wait(0.2)

                Library:SafeCall(Button.Callback)
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element"})
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})

                Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.3})

                if Button.Icon then 
                    Items["Icon"]:Tween(nil, {ImageColor3 = Library.Theme.Text, ImageTransparency = 0.3})
                end
            end

            Items["Button"]:Connect("MouseButton1Down", function()
                Button:Press()
            end)

            if Data.Tooltip or Data.tooltip then
                Library:AttachTooltip(Items["Button"].Instance, Data.Tooltip or Data.tooltip)
            end

            return Button
        end

        Library.Sections.Slider = function(self, Data)
            Data = Data or { }

            local Slider = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Slider",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Min = Data.Min or Data.min or 0,
                Default = Data.Default or Data.default or 0,
                Max = Data.Max or Data.max or 100,
                Suffix = Data.Suffix or Data.suffix or "",
                Decimals = Data.Decimals or Data.decimals or 1,
                Callback = Data.Callback or Data.callback or function() end,

                Value = 0,
                Sliding = false
            }

            local Items = { } do 
                Items["Slider"] = Instances:Create("Frame", {
                    Parent = Slider.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, IsMobile and 50 or 35),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
 
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = Slider.Name,
                    TextWrapped = true,
                    Size = UDim2New(IsMobile and 1 or 0, IsMobile and -90 or 0, 0, 0),
                    AutomaticSize = IsMobile and Enum.AutomaticSize.Y or Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

                Items["RealSlider"] = Instances:Create("TextButton", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 1),
                    BorderSizePixel = 0,
                    Position = UDim2New(0, 20, 1, -3),
                    Size = UDim2New(1, -40, 0, 7),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0"
                })

                Items["Accent"] = Instances:Create("Frame", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    Size = UDim2New(0.5, 0, 1, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0"
                })

                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 16, 0, 12),
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://117786983271442",
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 5, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIGradient", {
                    Parent = Items["Accent"].Instance,
                    Name = "\0",
                    Rotation = -102,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(166, 166, 166))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["Plus"] = Instances:Create("TextButton", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = "+",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(0, 0.5),
                    Size = UDim2New(0, 20, 0, 20),
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0.5, -3),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Plus"]:AddToTheme({TextColor3 = "Text"})

                Items["Minus"] = Instances:Create("TextButton", {
                    Parent = Items["RealSlider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = "-",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0.5),
                    Size = UDim2New(0, 20, 0, 20),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, -2, 0.5, -2),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Minus"]:AddToTheme({TextColor3 = "Text"})

                Items["Value"] = Instances:Create("TextBox", {
                    Parent = Items["Slider"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = "50%",
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 52, 0, 15),
                    AnchorPoint = Vector2New(1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, 0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    ClearTextOnFocus = false,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

                Items["RealSlider"]:OnHover(function()
                    Items["Icon"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 18, 0, 14)})
                end)

                Items["RealSlider"]:OnHoverLeave(function()
                    Items["Icon"]:Tween(TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2New(0, 16, 0, 12)})
                end)
            end

            if IsMobile then
                Items["RealSlider"].Instance.Position = UDim2New(0, 20, 1, -6)
                Items["Text"].Instance.Position = UDim2New(0, 0, 0, 0)
            else
                Items["RealSlider"].Instance.Position = UDim2New(0, 80, 1, -3)
                Items["Text"].Instance.Position = UDim2New(0, 80, 0, 0)
            end

            function Slider:Get()
                return Slider.Value 
            end

            function Slider:SetVisibility(Bool)
                Items["Slider"].Instance.Visible = Bool
            end

            function Slider:RefreshPosition(Bool)
                if IsMobile then
                    Items["RealSlider"].Instance.Position = UDim2New(0, 20, 1, -6)
                    Items["Text"].Instance.Position = UDim2New(0, 0, 0, 0)
                    return
                end
                if Bool then 
                    Items["RealSlider"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 20, 1, -3)})
                    Items["Text"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 0)})
                else
                    Items["RealSlider"].Instance.Position = UDim2New(0, 80, 1, -3)
                    Items["Text"].Instance.Position = UDim2New(0, 80, 0, 0)
                end
            end

            function Slider:Set(Value, SkipCallback)
                Slider.Value = Library:Round(MathClamp(Value, Slider.Min, Slider.Max), Slider.Decimals)
                Library.Flags[Slider.Flag] = Slider.Value

                Items["Accent"]:Tween(TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New((Slider.Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1, 0)})
                Items["Value"].Instance.Text = StringFormat("%s%s", Slider.Value, Slider.Suffix)

                if Slider.Value >= Slider.Max then 
                    Items["Icon"].Instance.Position = UDim2New(1, -5, 0.5, 0)
                else
                    Items["Icon"].Instance.Position = UDim2New(1, 5, 0.5, 0)
                end

                if Slider.Callback and not SkipCallback then 
                    Library:SafeCall(Slider.Callback, Slider.Value)
                end
            end

            Items["Plus"]:Connect("MouseButton1Down", function()
                Slider:Set(Slider.Value + Slider.Decimals)
            end)

            Items["Minus"]:Connect("MouseButton1Down", function()
                Slider:Set(Slider.Value - Slider.Decimals)
            end)

            Items["Value"]:Connect("FocusLost", function()
                local raw = Items["Value"].Instance.Text
                local n = tonumber((raw:gsub("[^%d%.%-]", "")))
                if n then
                    Slider:Set(n)
                else
                    Items["Value"].Instance.Text = StringFormat("%s%s", Slider.Value, Slider.Suffix)
                end
            end)

            local InputChanged 
            
            Items["RealSlider"]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Slider.Sliding = true

                    local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                    local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min

                    Slider:Set(Value)

                    if InputChanged then
                        return
                    end

                    InputChanged = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Slider.Sliding = false

                            InputChanged:Disconnect()
                            InputChanged = nil
                        end
                    end)
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Slider.Sliding then
                        local SizeX = (Input.Position.X - Items["RealSlider"].Instance.AbsolutePosition.X) / Items["RealSlider"].Instance.AbsoluteSize.X
                        local Value = ((Slider.Max - Slider.Min) * SizeX) + Slider.Min

                        Slider:Set(Value)
                    end
                end
            end)

            if Slider.Default then
                Slider:Set(Slider.Default, true)
            end

            Library.SetFlags[Slider.Flag] = function(Value)
                Slider:Set(Value)
            end

            if Data.Tooltip or Data.tooltip then
                Library:AttachTooltip(Items["Slider"].Instance, Data.Tooltip or Data.tooltip)
            end

            Slider.Section.Elements[#Slider.Section.Elements+1] = Slider
            return Slider 
        end

        Library.Sections.Dropdown = function(self, Data)
            Data = Data or { }

            local Dropdown = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Dropdown",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Items = Data.Items or Data.items or { "One", "Two", "Three" },
                Default = Data.Default or Data.default or nil,
                Callback = Data.Callback or Data.callback or function() end,
                Size = Data.Size or Data.size or 125,
                OptionHolderSize = Data.OptionHolderSize or Data.optionholder or 125,
                Multi = Data.Multi or Data.multi or false,

                Value = { },
                Options = { },
                OptionsWithIndexes = { },
                IsOpen = false,
                SearchEnabled = Data.Search == true or Data.search == true,
                FilterRows = { }
            }

            local Items = { } do 
                Items["Dropdown"] = Instances:Create("Frame", {
                    Parent = Dropdown.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 25),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Dropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = Dropdown.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})
                
                Items["RealDropdown"] = Instances:Create("TextButton", {
                    Parent = Items["Dropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    Size = UDim2New(0, Dropdown.Size or 125, 0, 25),
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Items["Value"] = Instances:Create("TextLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = "-",
                    Size = UDim2New(1, -40, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 10, 0.5, -1),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Value"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Liner"] = Instances:Create("Frame", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, -25, 0, 0),
                    Size = UDim2New(0, 2, 1, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(34, 32, 36)
                })  Items["Liner"]:AddToTheme({BackgroundColor3 = "Outline"})
                
                Items["ArrowIcon"] = Instances:Create("ImageLabel", {
                    Parent = Items["RealDropdown"].Instance,
                    Name = "\0",
                    ImageColor3 = FromRGB(141, 141, 150),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 16, 0, 8),
                    AnchorPoint = Vector2New(1, 0.5),
                    Image = "rbxassetid://123317177279443",
                    BackgroundTransparency = 1,
                    Position = UDim2New(1, -5, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Items["Gradient"] = Instances:Create("UIGradient", {
                    Parent = Items["ArrowIcon"].Instance,
                    Name = "\0",
                    Enabled = false,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(131, 131, 131)), RGBSequenceKeypoint(1, FromRGB(255, 255, 255))}
                })  Items["Gradient"]:AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})

                Items["OptionHolder"] = Instances:Create("TextButton", {
                    Parent = Library.UnusedHolder.Instance,
                    Text = "",
                    AutoButtonColor = false,
                    Name = "\0",
                    Visible = false,
                    Position = UDim2New(0, 897, 0, 101),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(0, 159, 0, 87),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 25, 29)
                })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Background"})
                 
                Instances:Create("UIStroke", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    Color = FromRGB(35, 33, 38),
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                }):AddToTheme({Color = "Outline"})
                
                Instances:Create("UICorner", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })
                
                Items["Holder"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["OptionHolder"].Instance,
                    Name = "\0",
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    Size = UDim2New(1, -16, 1, -16),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 8, 0, 8),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  Items["Holder"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Holder"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                if Dropdown.SearchEnabled then
                    Items["SearchField"] = Instances:Create("TextBox", {
                        Parent = Items["OptionHolder"].Instance,
                        Name = "\0",
                        FontFace = Library.Fonts.Light,
                        TextColor3 = FromRGB(220, 220, 230),
                        PlaceholderText = "Search..",
                        PlaceholderColor3 = FromRGB(120, 118, 130),
                        Text = "",
                        Size = UDim2New(1, -16, 0, 26),
                        Position = UDim2New(0, 8, 0, 8),
                        BackgroundTransparency = 0.25,
                        ZIndex = 6,
                        TextSize = 13,
                        ClearTextOnFocus = false,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(22, 21, 26)
                    })
                    Instances:Create("UICorner", {
                        Parent = Items["SearchField"].Instance,
                        CornerRadius = UDimNew(0, 5)
                    })
                    Items["SearchField"]:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})
                    Items["Holder"].Instance.Position = UDim2New(0, 8, 0, 40)
                    Items["Holder"].Instance.Size = UDim2New(1, -16, 1, -48)
                end
            end

            Items["Text"].Instance.Position = UDim2New(0, 30, 0.5, 0)
            Items["RealDropdown"].Instance.Position = UDim2New(1, 30, 0, 0)

            function Dropdown:Get()
                return Dropdown.Value
            end

            function Dropdown:SetVisibility(Bool)
                Items["Dropdown"].Instance.Visible = Bool
            end

            function Dropdown:RefreshPosition(Bool)
                if Bool then
                    Items["Text"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0.5, 0)})
                    Items["RealDropdown"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(1, 0, 0, 0)})
                else
                    Items["Text"].Instance.Position = UDim2New(0, 30, 0.5, 0)
                    Items["RealDropdown"].Instance.Position = UDim2New(1, 30, 0, 0)
                end
            end

            Items["RealDropdown"]:OnHover(function()
                if Dropdown.IsOpen then
                    return 
                end

                Items["ArrowIcon"]:Tween(nil, {ImageColor3 = FromRGB(255, 255, 255)})
                Items["Gradient"].Instance.Enabled = true
            end)

            Items["RealDropdown"]:OnHoverLeave(function()
                if Dropdown.IsOpen then
                    return 
                end

                Items["ArrowIcon"]:Tween(nil, {ImageColor3 = FromRGB(141, 141, 150)})
                Items["Gradient"].Instance.Enabled = false
            end)

            local RenderStepped 

            function Dropdown:SetOpen(Bool)
                if Debounce then 
                    return
                end

                Dropdown.IsOpen = Bool

                Debounce = true 

                if Dropdown.IsOpen then 
                    Items["OptionHolder"].Instance.Visible = true
                    Items["OptionHolder"].Instance.Parent = Library.Holder.Instance

                    Items["ArrowIcon"]:Tween(nil, {Rotation = 180, ImageColor3 = FromRGB(255, 255, 255)})
                    Items["Gradient"].Instance.Enabled = true
                    
                    Library:Thread(function()
                        for Index, Value in Dropdown.OptionsWithIndexes do 
                            task.spawn(function()
                                Value:RefreshPosition(true)
                            end)
                            task.wait(0.05)
                        end
                    end)
                    
                    local searchPad = Dropdown.SearchEnabled and 32 or 0
                    RenderStepped = RunService.RenderStepped:Connect(function()
                        Items["OptionHolder"].Instance.Position = UDim2New(0, Items["RealDropdown"].Instance.AbsolutePosition.X, 0, Items["RealDropdown"].Instance.AbsolutePosition.Y + Items["RealDropdown"].Instance.AbsoluteSize.Y + 5)
                        Items["OptionHolder"].Instance.Size = UDim2New(0, Items["RealDropdown"].Instance.AbsoluteSize.X, 0, Dropdown.OptionHolderSize + searchPad)
                    end)

                    for Index, Value in Library.OpenFrames do 
                        if Value ~= Dropdown and not Dropdown.Section.IsSettings then 
                            Value:SetOpen(false)
                        end
                    end

                    Library.OpenFrames[Dropdown] = Dropdown 
                else
                    if not Dropdown.IsOpen then
                        for Index, Value in Dropdown.OptionsWithIndexes do 
                            task.spawn(function()
                                Value:RefreshPosition(false)
                            end)
                        end
                    end

                    if Library.OpenFrames[Dropdown] then 
                        Library.OpenFrames[Dropdown] = nil
                    end

                    if RenderStepped then 
                        RenderStepped:Disconnect()
                        RenderStepped = nil
                    end

                    Items["ArrowIcon"]:Tween(nil, {Rotation = 0, ImageColor3 = FromRGB(141, 141, 150)})
                    Items["Gradient"].Instance.Enabled = false
                end

                local Descendants = Items["OptionHolder"].Instance:GetDescendants()
                TableInsert(Descendants, Items["OptionHolder"].Instance)

                local NewTween

                for Index, Value in Descendants do 
                    local TransparencyProperty = Tween:GetProperty(Value)

                    if not TransparencyProperty then
                        continue 
                    end

                    if not Value.ClassName:find("UI") then 
                        Value.ZIndex = (Dropdown.IsOpen and Dropdown.Section.IsSettings and 8) or (Dropdown.IsOpen and 3) or 1
                    end

                    if type(TransparencyProperty) == "table" then 
                        for _, Property in TransparencyProperty do 
                            NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                        end
                    else
                        NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
                    end
                end
                
                NewTween.Tween.Completed:Connect(function()
                    Debounce = false 
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                    task.wait(0.2)
                    Items["OptionHolder"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
                end)
            end

            function Dropdown:Set(Option, SkipCallback)
                if Dropdown.Multi then 
                    if type(Option) ~= "table" then 
                        return
                    end
 
                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Option do
                        local OptionData = Dropdown.Options[Value]
                         
                        if not OptionData then
                            continue
                        end

                        OptionData.Selected = true 
                        OptionData:Toggle("Active")
                    end

                    Items["Value"].Instance.Text = TableConcat(Option, ", ")
                else
                    if not Dropdown.Options[Option] then
                        return
                    end

                    local OptionData = Dropdown.Options[Option]

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.Selected = false 
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true 
                            Value:Toggle("Active")
                        end
                    end

                    Items["Value"].Instance.Text = Option
                end

                if Dropdown.Callback and not SkipCallback then   
                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["Holder"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                local OptionAccent = Instances:Create("Frame", {
                    Parent = OptionButton.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIGradient", {
                    Parent = OptionAccent.Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Instances:Create("UICorner", {
                    Parent = OptionAccent.Instance,
                    Name = "\0"
                })
                
                local OptionText = Instances:Create("TextLabel", {
                    Parent = OptionAccent.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.30000001192092896,
                    Text = Option,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 30, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  OptionText:AddToTheme({TextColor3 = "Text"})
                
                local OptionData = {
                    Button = OptionButton,
                    Name = Option,
                    OptionText = OptionText,
                    OptionAccent = OptionAccent,
                    Selected = false
                }
                
                function OptionData:Toggle(Value)
                    if Value == "Active" then
                        OptionText:Tween(nil, {TextTransparency = 0, Position = UDim2New(0, 15, 0.5, 0)})
                        OptionAccent:Tween(nil, {BackgroundTransparency = 0})
                    else
                        OptionText:Tween(nil, {TextTransparency = 0.3, Position = UDim2New(0, 0, 0.5, 0)})
                        OptionAccent:Tween(nil, {BackgroundTransparency = 1})
                    end
                end

                function OptionData:RefreshPosition(Bool)
                    if Bool then 
                        if OptionData.Selected then
                            OptionAccent:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0.5, 0)})
                            OptionText:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 15, 0.5, 0)})
                        else
                            OptionText:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0.5, 0)})
                        end
                    else
                        if OptionData.Selected then
                            OptionAccent.Instance.Position = UDim2New(0, 30, 0.5, 0)
                            OptionText.Instance.Position = UDim2New(0, 45, 0.5, 0)
                        else
                            OptionText.Instance.Position = UDim2New(0, 30, 0.5, 0)
                        end
                    end
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected

                    if Dropdown.Multi then 
                        local Index = TableFind(Dropdown.Value, OptionData.Name)

                        if Index then 
                            TableRemove(Dropdown.Value, Index)
                        else
                            TableInsert(Dropdown.Value, OptionData.Name)
                        end

                        OptionData:Toggle(Index and "Inactive" or "Active")

                        Library.Flags[Dropdown.Flag] = Dropdown.Value

                        local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "..."
                        Items["Value"].Instance.Text = TextFormat
                    else
                        if OptionData.Selected then 
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name

                            OptionData.Selected = true
                            OptionData:Toggle("Active")

                            for Index, Value in Dropdown.Options do 
                                if Value ~= OptionData then
                                    Value.Selected = false 
                                    Value:Toggle("Inactive")
                                end
                            end

                            Items["Value"].Instance.Text = OptionData.Name
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil

                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")

                            Items["Value"].Instance.Text = "..."
                        end
                    end

                    if Dropdown.Callback then
                        Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                    end
                end

                OptionData.Button:Connect("MouseButton1Down", function()
                    OptionData:Set()
                end)

                Dropdown.Options[OptionData.Name] = OptionData
                Dropdown.OptionsWithIndexes[#Dropdown.OptionsWithIndexes+1] = OptionData
                Dropdown.FilterRows[Option] = OptionButton
                OptionData:RefreshPosition(false)

                return OptionData
            end

            function Dropdown:Remove(Option)
                if Dropdown.Options[Option] then
                    Dropdown.Options[Option].Button:Clean()
                    Dropdown.Options[Option] = nil
                end
                if Dropdown.FilterRows then
                    Dropdown.FilterRows[Option] = nil
                end
            end

            function Dropdown:Refresh(List)
                for _, opt in pairs(Dropdown.Options) do 
                    Dropdown:Remove(opt.Name)
                end

                List = List or {}
                for _, Value in ipairs(List) do 
                    Dropdown:Add(Value)
                end
            end

            Items["RealDropdown"]:Connect("MouseButton1Down", function()
                Dropdown:SetOpen(not Dropdown.IsOpen)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dropdown.IsOpen then
                        if Library:IsMouseOverFrame(Items["OptionHolder"]) then
                            return
                        end

                        Dropdown:SetOpen(false)
                    end
                end
            end)

            Items["RealDropdown"]:Connect("Changed", function(Property)
                if Property == "AbsolutePosition" and Dropdown.IsOpen then
                    Dropdown.IsOpen = not Library:IsClipped(Items["OptionHolder"].Instance, Dropdown.Section.Items["Section"].Instance.Parent)
                    Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                end
            end)

            for Index, Value in Dropdown.Items do 
                Dropdown:Add(Value)
            end

            if Dropdown.SearchEnabled and Items["SearchField"] then
                Items["SearchField"]:Connect("Changed", function()
                    local q = StringLower(Items["SearchField"].Instance.Text)
                    for name, row in Dropdown.FilterRows do
                        if row and row.Instance then
                            local nm = StringLower(tostring(name))
                            row.Instance.Visible = q == "" or string.find(nm, q, 1, true) ~= nil
                        end
                    end
                end)
            end

            if Dropdown.Default then 
                Dropdown:Set(Dropdown.Default, true)
            end

            Library.SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end

            if Data.Tooltip or Data.tooltip then
                Library:AttachTooltip(Items["Dropdown"].Instance, Data.Tooltip or Data.tooltip)
            end

            Dropdown.Section.Elements[#Dropdown.Section.Elements+1] = Dropdown
            return Dropdown
        end

        Library.Sections.Label = function(self, Name)
            local Label = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Name or "Label"
            }

            local Items = { } do 
                Items["Label"] = Instances:Create("Frame", {
                    Parent = Label.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = Label.Name,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2New(1, -36, 0, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 30, 0, 5),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})          
            end

            function Label:SetText(Text)
                Text = tostring(Text)
                Items["Text"].Instance.Text = Text
            end

            function Label:SetVisibility(Bool)
                Items["Label"].Instance.Visible = Bool
            end

            function Label:RefreshPosition(Bool)
                if Bool then 
                    Items["Text"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 5)})

                    if Items["SubElements"] then
                        Items["SubElements"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 30)})
                        Tween:Create(Items["Label"].Instance:FindFirstChild("nig"), TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(1, -16, 1, -6)}, true)
                    end
                else 
                    Items["Text"].Instance.Position = UDim2New(0, 30, 0, 5)

                    if Items["SubElements"] then
                        Items["SubElements"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 30, 0, 30)})
                        Tween:Create(Items["Label"].Instance:FindFirstChild("nig"), TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(1, 30, 1, -6)}, true)
                    end
                end
            end

            function Label:Colorpicker(Data)
                Data = Data or { }

                local Colorpicker = {
                    Window = Label.Window,
                    Page = Label.Page,
                    Section = Label.Section,

                    Flag = Data.Flag or Data.flag or Library:NextFlag(),
                    Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                    Callback = Data.Callback or Data.callback or function() end,
                    Alpha = Data.Alpha or Data.alpha or false
                }

                if not Items["SubElements"] then
                    Items["SubElements"] = Instances:Create("Frame", {
                        Parent = Items["Label"].Instance,
                        Name = "\0",
                        Size = UDim2New(1, 0, 0, 30),
                        Position = UDim2New(0, 0, 0, 30),
                        BorderColor3 = FromRGB(0, 0, 0),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(27, 26, 29)
                    })  Items["SubElements"]:AddToTheme({BackgroundColor3 = "Element"})
                    
                    Instances:Create("UICorner", {
                        Parent = Items["SubElements"].Instance,
                        Name = "\0",
                        CornerRadius = UDimNew(0, 5)
                    })
                    
                    Instances:Create("UIListLayout", {
                        Parent = Items["SubElements"].Instance,
                        Name = "\0",
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDimNew(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Instances:Create("UIPadding", {
                        Parent = Items["SubElements"].Instance,
                        Name = "\0",
                        PaddingLeft = UDimNew(0, 6)
                    })                
                end

                local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
                    Parent = Items["SubElements"],
                    Page = Colorpicker.Page,
                    Section = Colorpicker.Section,
                    Flag = Colorpicker.Flag,
                    Default = Colorpicker.Default,
                    Callback = Colorpicker.Callback,
                    Parent2 = Items["Label"],
                    Alpha = Colorpicker.Alpha
                })

                return NewColorpicker
            end

            Label.Section.Elements[#Label.Section.Elements+1] = Label
            return Label
        end

        function Library:CreateKeybind(Data)
            Data = Data or {}
            local p = Data.Parent
            local inst = (typeof(p) == "table" and p.Instance) or p
            local fakeSection = {
                Window = Data.Window or (Data.Page and Data.Page.Window),
                Page = Data.Page,
                Items = { Content = { Instance = inst } },
                Elements = {},
            }
            return Library.Sections.Keybind(fakeSection, Data)
        end

        Library.Sections.Keybind = function(self, Data)
            Data = Data or { }

            local modeDefault = Data.Mode or Data.mode
            if typeof(modeDefault) ~= "string" or not TableFind({ "Toggle", "Hold", "Always" }, modeDefault) then
                modeDefault = "Toggle"
            end

            local syncFlag = Data.syncFlag or Data.SyncFlag
            if syncFlag == "" then
                syncFlag = nil
            end

            local Keybind = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Name = Data.Name or Data.name or "Keybind",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Enum.KeyCode.RightShift,
                Callback = Data.Callback or Data.callback or function() end,
                Mode = modeDefault,
                syncFlag = syncFlag,

                Value = "",
                ModeSelected = "",
                Toggled = false,
                Picking = false,
                CodeName = nil,
                _modeMenuConn = nil,
            }

            local Items = { } do
                Items["Label"] = Instances:Create("Frame", {
                    Parent = Keybind.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["SubElements"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, 0, 0, 30),
                    Position = UDim2New(0, 0, 0, 30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["SubElements"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    FillDirection = Enum.FillDirection.Horizontal,
                    Padding = UDimNew(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    PaddingLeft = UDimNew(0, 6)
                })
                
                Items["KeyButton"] = Instances:Create("TextButton", {
                    Parent = Items["SubElements"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = "MouseButton2",
                    AutoButtonColor = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    SelectionOrder = 2,
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["KeyButton"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Text"] = Instances:Create("TextLabel", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.30000001192092896,
                    Text = Keybind.Name,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2New(0, 0, 0, 15),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, 5),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Text"]:AddToTheme({TextColor3 = "Text"})
                
                Items["Modes"] = Instances:Create("Frame", {
                    Parent = Items["Label"].Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    Position = UDim2New(1, 0, 0, 0),
                    Size = UDim2New(0, 118, 0, 25),
                    ZIndex = 4,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Modes"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["Modes"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })

                Instances:Create("UIStroke", {
                    Parent = Items["Modes"].Instance,
                    Name = "\0",
                    Thickness = 1,
                    Transparency = 0.5,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    Color = FromRGB(60, 90, 160)
                }):AddToTheme({Color = "Accent"})

                Items["ModeSelect"] = Instances:Create("TextButton", {
                    Parent = Items["Modes"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    TextTransparency = 0.15,
                    Text = "Toggle  ▾",
                    AutoButtonColor = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    TextSize = 13,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["ModeSelect"]:AddToTheme({TextColor3 = "Text"})

                Items["ModeList"] = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Name = "\0",
                    Visible = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundColor3 = FromRGB(22, 22, 26),
                    BorderSizePixel = 0,
                    Size = UDim2New(0, 116, 0, 66),
                    ZIndex = 200,
                })  Items["ModeList"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("UICorner", {
                    Parent = Items["ModeList"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 5)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["ModeList"].Instance,
                    Name = "\0",
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDimNew(0, 0),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                local function positionModeList()
                    local m = Items["Modes"].Instance
                    local abs = m.AbsolutePosition
                    local sz = m.AbsoluteSize
                    Items["ModeList"].Instance.Position = UDim2FromOffset(abs.X, abs.Y + sz.Y + 2)
                end
                local function closeModeMenu()
                    Items["ModeList"].Instance.Visible = false
                    if Keybind._modeMenuConn then
                        Keybind._modeMenuConn:Disconnect()
                        Keybind._modeMenuConn = nil
                    end
                end

                local function makeModeOption(label, order)
                    local B = Instances:Create("TextButton", {
                        Parent = Items["ModeList"].Instance,
                        Name = "\0",
                        LayoutOrder = order,
                        FontFace = Library.Font,
                        TextColor3 = FromRGB(240, 240, 240),
                        TextTransparency = 0.2,
                        Text = label,
                        AutoButtonColor = false,
                        Size = UDim2New(1, 0, 0, 22),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ZIndex = 201,
                        TextSize = 13,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })  B:AddToTheme({TextColor3 = "Text"})
                    B:Connect("MouseButton1Click", function()
                        closeModeMenu()
                        Keybind:SetMode(label, false)
                    end)
                    return B
                end

                makeModeOption("Toggle", 1)
                makeModeOption("Hold", 2)
                makeModeOption("Always", 3)

                Items["ModeSelect"]:Connect("MouseButton1Click", function()
                    if Items["ModeList"].Instance.Visible then
                        closeModeMenu()
                        return
                    end
                    positionModeList()
                    Items["ModeList"].Instance.Size = UDim2New(0, Items["Modes"].Instance.AbsoluteSize.X, 0, 66)
                    Items["ModeList"].Instance.Visible = true
                    if Keybind._modeMenuConn then
                        Keybind._modeMenuConn:Disconnect()
                    end
                    Keybind._modeMenuConn = UserInputService.InputBegan:Connect(function(Input)
                        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end
                        if Library:IsMouseOverFrame(Items["ModeList"]) or Library:IsMouseOverFrame(Items["Modes"]) then
                            return
                        end
                        closeModeMenu()
                    end)
                end)
            end

            local KeyListItem 

            if Library.KeyList then 
                KeyListItem = Library.KeyList:Add("", "")
            end

            local function keyListStatusOn()
                if Keybind.syncFlag then
                    return Library.Flags[Keybind.syncFlag] == true
                end
                return Keybind.Toggled
            end

            local Update = function()
                if KeyListItem then
                    KeyListItem:Set(Data.Name, Keybind.Value)
                    KeyListItem:SetStatus(keyListStatusOn())
                end
            end

            function Keybind:RefreshPosition(Bool)
                if Bool then 
                    Items["Text"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 5)})
                    Items["SubElements"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 30)})
                    Items["Modes"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(1, 0, 0, 0)})
                else
                    Items["Text"].Instance.Position = UDim2New(0, 30, 0, 5)
                    Items["SubElements"].Instance.Position = UDim2New(0, 30, 0, 30)
                    Items["Modes"].Instance.Position = UDim2New(1, 30, 0, 0)
                end
            end

            function Keybind:SetMode(Mode, SkipCallback)
                Keybind.ModeSelected = Mode
                if Items["ModeSelect"] then
                    Items["ModeSelect"].Instance.Text = Mode .. "  ▾"
                end

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.ModeSelected,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback and not SkipCallback then
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
            end

            function Keybind:Press(Bool)
                if Keybind.ModeSelected == "Toggle" then 
                    Keybind.Toggled = not Keybind.Toggled
                elseif Keybind.ModeSelected == "Hold" then 
                    Keybind.Toggled = Bool
                elseif Keybind.ModeSelected == "Always" then 
                    Keybind.Toggled = true
                end

                Library.Flags[Keybind.Flag] = {
                    Mode = Keybind.ModeSelected,
                    Key = Keybind.Key,
                    Toggled = Keybind.Toggled
                }

                if Data.Callback then 
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end

                Update()
            end

            function Keybind:Get()
                return Keybind.Key, Keybind.ModeSelected, Keybind.Toggled
            end

            function Keybind:Set(Key, SkipCallback)
                if typeof(Key) == "EnumItem" then
                    Keybind.Key = tostring(Key)
                    if Key.EnumType == Enum.KeyCode then
                        local kn = Key.Name == "Backspace" and "None" or Key.Name
                        Keybind.CodeName = (kn == "None") and nil or kn
                        local disp = Keys[kn] or kn
                        Keybind.Value = disp
                        Items["KeyButton"].Instance.Text = disp
                    else
                        Keybind.CodeName = nil
                        Keybind.Value = Key.Name or tostring(Key)
                        Items["KeyButton"].Instance.Text = Keybind.Value
                    end

                    Library.Flags[Keybind.Flag] = {
                        Mode = Keybind.ModeSelected,
                        Key = Keybind.Key,
                        Toggled = Keybind.Toggled
                    }

                    if Data.Callback and not SkipCallback then
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                elseif type(Key) == "table" then
                    local rk = Key.Key
                    if typeof(rk) == "EnumItem" then
                        Keybind.Key = tostring(rk)
                        if rk.EnumType == Enum.KeyCode then
                            local kn = rk.Name == "Backspace" and "None" or rk.Name
                            Keybind.CodeName = (kn == "None") and nil or kn
                            local disp = Keys[kn] or kn
                            Keybind.Value = disp
                            Items["KeyButton"].Instance.Text = disp
                        else
                            Keybind.CodeName = nil
                            Keybind.Value = rk.Name or tostring(rk)
                            Items["KeyButton"].Instance.Text = Keybind.Value
                        end
                    else
                        Keybind.Key = tostring(rk)
                        Keybind.CodeName = nil
                        Keybind.Value = tostring(rk)
                        Items["KeyButton"].Instance.Text = Keybind.Value
                    end

                    if Key.Mode then
                        Keybind:SetMode(Key.Mode, SkipCallback)
                    else
                        Keybind:SetMode("Toggle", SkipCallback)
                    end

                    if Data.Callback and not SkipCallback then
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                elseif TableFind({ "Toggle", "Hold", "Always" }, Key) then
                    Keybind:SetMode(Key, SkipCallback)

                    if Data.Callback and not SkipCallback then
                        Library:SafeCall(Data.Callback, Keybind.Toggled)
                    end

                    Update()
                end

                Keybind.Picking = false
            end

            Items["KeyButton"]:Connect("MouseButton1Click", function()
                Keybind.Picking = true 

                Items["KeyButton"].Instance.Text = "."
                Library:Thread(function()
                    local Count = 1

                    while true do 
                        if not Keybind.Picking then 
                            break
                        end

                        if Count == 4 then
                            Count = 1
                        end

                        Items["KeyButton"].Instance.Text = Count == 1 and "." or Count == 2 and ".." or Count == 3 and "..."
                        Count += 1
                        task.wait(0.35)
                    end
                end)

                local InputBegan
                InputBegan = UserInputService.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Keyboard then 
                        Keybind:Set(Input.KeyCode)
                    else
                        Keybind:Set(Input.UserInputType)
                    end

                    InputBegan:Disconnect()
                    InputBegan = nil
                end)
            end)

            Library:Connect(UserInputService.InputBegan, function(Input)
                if Keybind.Picking then
                    return
                end
                if UserInputService:GetFocusedTextBox() ~= nil then
                    return
                end
                if Keybind.Value == "None" or Keybind.Value == nil or Keybind.Value == "" then
                    return
                end

                local matched = false
                if Keybind.CodeName then
                    matched = Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Keybind.CodeName
                elseif Keybind.Key then
                    matched = tostring(Input.UserInputType) == Keybind.Key
                end

                if matched then
                    local now = tick()
                    if Keybind._lastInputAt and (now - Keybind._lastInputAt) < 0.08 then
                        return
                    end
                    Keybind._lastInputAt = now
                    if Keybind.ModeSelected == "Toggle" then
                        Keybind:Press()
                    elseif Keybind.ModeSelected == "Hold" then
                        Keybind:Press(true)
                    elseif Keybind.ModeSelected == "Always" then
                        Keybind:Press(true)
                    end
                end

                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not Keybind.IsOpen then
                        return
                    end

                    if (Items["KeybindWindow"] and Library:IsMouseOverFrame(Items["KeybindWindow"]))
                        or (Items["OptionHolder"] and Library:IsMouseOverFrame(Items["OptionHolder"])) then
                        return
                    end

                    Keybind:SetOpen(false)
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(Input)
                if Keybind.Picking then
                    return
                end
                if UserInputService:GetFocusedTextBox() ~= nil then
                    return
                end
                if Keybind.Value == "None" or Keybind.Value == nil or Keybind.Value == "" then
                    return
                end

                local matched = false
                if Keybind.CodeName then
                    matched = Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Keybind.CodeName
                elseif Keybind.Key then
                    matched = tostring(Input.UserInputType) == Keybind.Key
                end

                if matched then
                    local now = tick()
                    if Keybind._lastInputEndAt and (now - Keybind._lastInputEndAt) < 0.06 then
                        return
                    end
                    Keybind._lastInputEndAt = now
                    if Keybind.ModeSelected == "Hold" then
                        Keybind:Press(false)
                    elseif Keybind.ModeSelected == "Always" then
                        Keybind:Press(true)
                    end
                end
            end)

            if Keybind.Default then 
                Keybind:Set({
                    Mode = Keybind.Mode or "Toggle",
                    Key = Keybind.Default,
                }, true)
            end

            Library.SetFlags[Keybind.Flag] = function(Value)
                Keybind:Set(Value, true)
            end

            if Keybind.syncFlag then
                Library.KeybindFlagListeners[Keybind.syncFlag] = Library.KeybindFlagListeners[Keybind.syncFlag] or {}
                TableInsert(Library.KeybindFlagListeners[Keybind.syncFlag], Update)
            end

            if Data.Tooltip or Data.tooltip then
                Library:AttachTooltip(Items["Label"].Instance, Data.Tooltip or Data.tooltip)
            end

            TableInsert(Library.KeybindRows, Items["Label"].Instance)
            local showRows = Library.Flags.ShowKeybindRows
            if showRows == nil then
                showRows = not IsMobile
            end
            Items["Label"].Instance.Visible = showRows ~= false

            Keybind.Section.Elements[#Keybind.Section.Elements+1] = Keybind
            return Keybind 
        end

        Library.Sections.Textbox = function(self, Data)
            Data = Data or { }

            local Textbox = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "",
                Callback = Data.Callback or Data.callback or function() end,
                Placeholder = Data.Placeholder or Data.placeholder or "Placeholder",
                Numeric = Data.Numeric or Data.numeric or false,
                Finished = Data.Finished or Data.finished or false,

                Value = ""
            }

            local Items = { } do 
                Items["Textbox"] = Instances:Create("Frame", {
                    Parent = Textbox.Section.Items["Content"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    Selectable = true,
                    Size = UDim2New(1, 0, 0, 32),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                }) 
                
                Instances:Create("UICorner", {
                    Parent = Items["Textbox"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Textbox"].Instance,
                    Name = "\0",
                    Active = true,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    Selectable = true,
                    ZIndex = 2,
                    ClipsDescendants = true,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 4)
                })
                
                Items["Input"] = Instances:Create("TextBox", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    ZIndex = 2,
                    Size = UDim2New(1, -20, 0, 15),
                    Position = UDim2New(0, 10, 0, 8),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    PlaceholderText = Textbox.Placeholder,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Input"]:AddToTheme({TextColor3 = "Text"})               
            end
            
            function Textbox:Get()
                return Textbox.Value
            end

            function Textbox:SetVisibility(Bool)
                Items["Textbox"].Instance.Visible = Bool
            end

            function Textbox:RefreshPosition(Bool)
                if Bool then
                    Items["Background"]:Tween(TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 0)})
                else
                    Items["Background"].Instance.Position = UDim2New(0, 30, 0, 0)
                end
            end

            function Textbox:Set(Value)
                if Textbox.Numeric then
                    if (not tonumber(Value)) and StringLen(tostring(Value)) > 0 then
                        Value = Textbox.Value
                    end
                end

                Textbox.Value = Value
                Items["Input"].Instance.Text = Value
                Library.Flags[Textbox.Flag] = Value

                if Textbox.Callback then
                    Library:SafeCall(Textbox.Callback, Value)
                end
            end

            if Textbox.Finished then 
                Items["Input"]:Connect("FocusLost", function(PressedEnterQuestionMark)
                    if PressedEnterQuestionMark then
                        Textbox:Set(Items["Input"].Instance.Text)
                    end
                end)
            else
                Library:Connect(Items["Input"].Instance:GetPropertyChangedSignal("Text"), function()
                    Textbox:Set(Items["Input"].Instance.Text)
                end)
            end

            if Textbox.Default then
                Textbox:Set(Textbox.Default)
            end

            Library.SetFlags[Textbox.Flag] = function(Value)
                Textbox:Set(Value)
            end

            if Data.Tooltip or Data.tooltip then
                Library:AttachTooltip(Items["Textbox"].Instance, Data.Tooltip or Data.tooltip)
            end

            Textbox.Section.Elements[#Textbox.Section.Elements+1] = Textbox
            return Textbox
        end

        Library.Sections.Listbox = function(self, Data)
            Data = Data or { }

            local Dropdown = {
                Window = self.Window,
                Page = self.Page,
                Section = self,

                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Items = Data.Items or Data.items or { "One", "Two", "Three" },
                Default = Data.Default or Data.default or nil,
                Callback = Data.Callback or Data.callback or function() end,
                Size = Data.Size or Data.size or 125,
                Multi = Data.Multi or Data.multi or false,

                Value = { },
                Options = { },
                IsOpen = false
            }

            local Items = { } do 
                Items["Listbox"] = Instances:Create("Frame", {
                    Parent = Dropdown.Section.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, Dropdown.Size),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Items["Search"] = Instances:Create("TextBox", {
                    Parent = Items["Listbox"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    CursorPosition = -1,
                    TextColor3 = FromRGB(240, 240, 240),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    ZIndex = 2,
                    Size = UDim2New(1, 0, 0, 30),
                    BorderSizePixel = 0,
                    PlaceholderColor3 = FromRGB(185, 185, 185),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    PlaceholderText = "Search..",
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["Search"]:AddToTheme({TextColor3 = "Text", BackgroundColor3 = "Element"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Search"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 4),
                    PaddingLeft = UDimNew(0, 8)
                })

                Items["Background"] = Instances:Create("Frame", {
                    Parent = Items["Listbox"].Instance,
                    Name = "\0",
                    Active = true,
                    Size = UDim2New(1, 0, 1, -30),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Position = UDim2New(0, 0, 0, 30),
                    BackgroundColor3 = FromRGB(27, 26, 29),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element"})
                
                Items["Holder"] = Instances:Create("ScrollingFrame", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    ScrollBarImageColor3 = FromRGB(0, 0, 0),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    Size = UDim2New(1, -4, 1, -8),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Position = UDim2New(0, 0, 0, 4),
                    BackgroundColor3 = FromRGB(27, 26, 29),
                    ZIndex = 2,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  Items["Holder"]:AddToTheme({ScrollBarImageColor3 = "Accent"})
                
                Instances:Create("UICorner", {
                    Parent = Items["Background"].Instance,
                    Name = "\0",
                    CornerRadius = UDimNew(0, 6)
                })
                
                Instances:Create("UIListLayout", {
                    Parent = Items["Holder"].Instance,
                    Name = "\0",
                    Padding = UDimNew(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                Instances:Create("UIPadding", {
                    Parent = Items["Holder"].Instance,
                    Name = "\0",
                    PaddingTop = UDimNew(0, 8),
                    PaddingBottom = UDimNew(0, 8),
                    PaddingRight = UDimNew(0, 12),
                    PaddingLeft = UDimNew(0, 8)
                })      
                
                Items["_"] = Instances:Create("Frame", {
                    Parent = Items["Listbox"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, 0, 0, 10),
                    Position = UDim2New(0, 0, 0, 25),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29)
                })  Items["_"]:AddToTheme({BackgroundColor3 = "Element"})

                Instances:Create("Frame", {
                    Parent = Items["_"].Instance,
                    Name = "\0",
                    Size = UDim2New(1, 0, 0, 1),
                    Position = UDim2New(0, 0, 1, -3),
                    AnchorPoint = Vector2New(0, 1),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 26, 29),
                }):AddToTheme({BackgroundColor3 = "Outline"})
            end

            function Dropdown:Get()
                return Dropdown.Value
            end

            function Dropdown:SetVisibility(Bool)
                Items["Listbox"].Instance.Visible = Bool
            end

            function Dropdown:RefreshPosition(Bool)
                if Bool then
                    Items["Background"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 30)})
                    Items["Search"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 0)})
                    Items["_"]:Tween(TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, 0, 25)})
                else
                    Items["Background"].Instance.Position = UDim2New(0, 30, 0, 30)
                    Items["Search"].Instance.Position = UDim2New(0, 30, 0, 0)
                    Items["_"].Instance.Position = UDim2New(0, 30, 0, 25)
                end
            end

            function Dropdown:Set(Option)
                if Dropdown.Multi then 
                    if type(Option) ~= "table" then 
                        return
                    end

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Option do
                        local OptionData = Dropdown.Options[Value]
                         
                        if not OptionData then
                            continue
                        end

                        OptionData.Selected = true 
                        OptionData:Toggle("Active")
                    end
                else
                    if not Dropdown.Options[Option] then
                        return
                    end

                    local OptionData = Dropdown.Options[Option]

                    Dropdown.Value = Option
                    Library.Flags[Dropdown.Flag] = Option

                    for Index, Value in Dropdown.Options do
                        if Value ~= OptionData then
                            Value.Selected = false 
                            Value:Toggle("Inactive")
                        else
                            Value.Selected = true 
                            Value:Toggle("Active")
                        end
                    end
                end

                if Dropdown.Callback then   
                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end
            end

            function Dropdown:Add(Option)
                local OptionButton = Instances:Create("TextButton", {
                    Parent = Items["Holder"].Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                local OptionAccent = Instances:Create("Frame", {
                    Parent = OptionButton.Instance,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 0.5),
                    BackgroundTransparency = 1,
                    ZIndex = 2,
                    Position = UDim2New(0, 0, 0.5, 0),
                    Size = UDim2New(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
                
                Instances:Create("UIGradient", {
                    Parent = OptionAccent.Instance,
                    Name = "\0",
                    Enabled = true,
                    Rotation = -115,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(143, 143, 143))}
                }):AddToTheme({Color = function()
                    return RGBSequence{RGBSequenceKeypoint(0, Library.Theme.Accent), RGBSequenceKeypoint(1, Library.Theme.AccentGradient)}
                end})
                
                Instances:Create("UICorner", {
                    Parent = OptionAccent.Instance,
                    Name = "\0"
                })
                
                local OptionText = Instances:Create("TextLabel", {
                    Parent = OptionButton.Instance,
                    Name = "\0",
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(255, 255, 255),
                    TextTransparency = 0.30000001192092896,
                    Text = Option,
                    Size = UDim2New(0, 0, 0, 15),
                    AnchorPoint = Vector2New(0, 0.5),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0.5, 0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  OptionText:AddToTheme({TextColor3 = "Text"})
                
                local OptionData = {
                    Button = OptionButton,
                    Name = Option,
                    OptionText = OptionText,
                    IsSearching = false,
                    OptionAccent = OptionAccent,
                    Selected = false
                }
                
                function OptionData:Toggle(Value)
                    if Value == "Active" then
                        OptionText:Tween(nil, {TextTransparency = 0, Position = UDim2New(0, 15, 0.5, 0)})
                        OptionAccent:Tween(nil, {BackgroundTransparency = 0})
                    else
                        OptionText:Tween(nil, {TextTransparency = 0.3, Position = UDim2New(0, 0, 0.5, 0)})
                        OptionAccent:Tween(nil, {BackgroundTransparency = 1})
                    end
                end

                function OptionData:Search(Bool)
                    Library:Thread(function()
                        if Bool then 
                            OptionData.IsSearching = true
                            OptionText:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 1})
                            task.wait(0.08)
                            OptionButton:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 0, 0)})
                            
                            if OptionData.Selected then 
                                OptionAccent:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                            end
                        else
                            OptionData.IsSearching = false
                            OptionText:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = OptionData.Selected and 0 or 0.3})
                            task.wait(0.08)
                            OptionButton:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2New(1, 0, 0, 20)})
                            
                            if OptionData.Selected then 
                                OptionAccent:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
                            end
                        end
                    end)
                end

                function OptionData:Set()
                    OptionData.Selected = not OptionData.Selected

                    if Dropdown.Multi then 
                        local Index = TableFind(Dropdown.Value, OptionData.Name)

                        if Index then 
                            TableRemove(Dropdown.Value, Index)
                        else
                            TableInsert(Dropdown.Value, OptionData.Name)
                        end

                        OptionData:Toggle(Index and "Inactive" or "Active")

                        Library.Flags[Dropdown.Flag] = Dropdown.Value
                    else
                        if OptionData.Selected then 
                            Dropdown.Value = OptionData.Name
                            Library.Flags[Dropdown.Flag] = OptionData.Name

                            OptionData.Selected = true
                            OptionData:Toggle("Active")

                            for Index, Value in Dropdown.Options do 
                                if Value ~= OptionData and not Value.IsSearching then
                                    Value.Selected = false 
                                    Value:Toggle("Inactive")
                                end
                            end
                        else
                            Dropdown.Value = nil
                            Library.Flags[Dropdown.Flag] = nil

                            OptionData.Selected = false
                            OptionData:Toggle("Inactive")
                        end
                    end

                    if Dropdown.Callback then
                        Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                    end
                end

                OptionData.Button:Connect("MouseButton1Down", function()
                    OptionData:Set()
                end)

                Dropdown.Options[OptionData.Name] = OptionData
                return OptionData
            end

            function Dropdown:Remove(Option)
                if Dropdown.Options[Option] then
                    Dropdown.Options[Option].Button:Clean()
                    Dropdown.Options[Option] = nil
                end
            end

            function Dropdown:Refresh(List)
                for _, opt in pairs(Dropdown.Options) do 
                    Dropdown:Remove(opt.Name)
                end

                List = List or {}
                for _, Value in ipairs(List) do 
                    Dropdown:Add(Value)
                end
            end

            Library:Connect(Items["Search"].Instance:GetPropertyChangedSignal("Text"), function()
                Library:Thread(function()
                    for Index, Value in Dropdown.Options do
                        local InputText = Items["Search"].Instance.Text
                        if InputText ~= "" then
                            if StringFind(StringLower(Value.Name), Library:EscapePattern(StringLower(InputText))) then
                                Value.Button.Instance.Visible = true
                                Value:Search(false)
                            else
                                Value:Search(true)
                                Value.Button.Instance.Visible = false
                            end
                        else
                            Value:Search(false)
                            Value.Button.Instance.Visible = true
                        end
                    end
                end)
            end)

            for Index, Value in Dropdown.Items do 
                Dropdown:Add(Value)
            end

            if Dropdown.Default then 
                Dropdown:Set(Dropdown.Default)
            end

            Library.SetFlags[Dropdown.Flag] = function(Value)
                Dropdown:Set(Value)
            end

            Dropdown.Section.Elements[#Dropdown.Section.Elements+1] = Dropdown
            return Dropdown
        end
    end

        Library.Sections.Divider = function(self, Label)
            local Items = {} do
                Items["Container"] = Instances:Create("Frame", {
                    Parent = self.Items["Content"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, 0, 0, Label and 22 or 12),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                if Label and Label ~= "" then
                    Items["LineLeft"] = Instances:Create("Frame", {
                        Parent = Items["Container"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0, 0.5),
                        Position = UDim2New(0, 0, 0.5, 0),
                        Size = UDim2New(0.35, -6, 0, 1),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundColor3 = FromRGB(38, 36, 44)
                    })

                    Items["LineRight"] = Instances:Create("Frame", {
                        Parent = Items["Container"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(1, 0.5),
                        Position = UDim2New(1, 0, 0.5, 0),
                        Size = UDim2New(0.35, -6, 0, 1),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundColor3 = FromRGB(38, 36, 44)
                    })

                    Items["Label"] = Instances:Create("TextLabel", {
                        Parent = Items["Container"].Instance,
                        Name = "\0",
                        FontFace = Library.Fonts.Light,
                        TextColor3 = FromRGB(110, 108, 130),
                        Text = Label,
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2New(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2New(0.5, 0.5),
                        Position = UDim2New(0.5, 0, 0.5, 0),
                        TextSize = 12,
                        ZIndex = 3,
                        BorderSizePixel = 0,
                        BackgroundColor3 = FromRGB(255, 255, 255)
                    })
                else
                    Items["Line"] = Instances:Create("Frame", {
                        Parent = Items["Container"].Instance,
                        Name = "\0",
                        AnchorPoint = Vector2New(0, 0.5),
                        Position = UDim2New(0, 0, 0.5, 0),
                        Size = UDim2New(1, 0, 0, 1),
                        BorderSizePixel = 0,
                        ZIndex = 2,
                        BackgroundColor3 = FromRGB(38, 36, 44)
                    })
                end
            end

            local Divider = {
                Window = self.Window,
                Page = self.Page,
                Section = self,
                Items = Items
            }

            function Divider:SetVisibility(Bool)
                Items["Container"].Instance.Visible = Bool
            end

            function Divider:RefreshPosition(Bool)
            end

            self.Elements[#self.Elements + 1] = Divider
            return Divider
        end

    Library.CreateSettingsPage = function(self, Window, KeybindList, Options)
        Options = Options or {}
        local pageInfo = { Name = "UI Settings", Icon = "settings" }
        local Page = Window:Page(pageInfo)

        local UISection = Page:Section({Name = "Appearance", Icon = "palette", Side = 1}) do
            UISection:Label("Accent color"):Colorpicker({
                Flag = "AccentColor",
                Default = Library.Theme.Accent,
                Callback = function(Color)
                    Library.Theme.Accent = Color
                    Library:ChangeTheme("Accent", Color)
                end
            })

            UISection:Label("Accent gradient"):Colorpicker({
                Flag = "AccentGradientColor",
                Default = Library.Theme.AccentGradient,
                Callback = function(Color)
                    Library.Theme.AccentGradient = Color
                    Library:ChangeTheme("AccentGradient", Color)
                end
            })

            UISection:Dropdown({
                Name = "Font weight",
                Flag = "FontStyle",
                Default = "Light",
                Items = { "Thin", "ExtraLight", "Light", "Regular", "Medium", "SemiBold", "Bold", "ExtraBold" },
                Callback = function(Value)
                    local FontData = Library.Fonts[Value]
                    if FontData then
                        Library.Font = FontData
                        Library:UpdateText()
                    end
                end
            })

            UISection:Slider({
                Name = "Background Transparency",
                Default = 0.12,
                Decimals = 0.01,
                Max = 1,
                Min = 0,
                Suffix = "%",
                Flag = "BackgroundTransparency",
                Callback = function(Value)
                    Window:SetTransparency(Value)
                end
            })

            UISection:Slider({
                Name = "DPI Scale",
                Flag = "DPIScale",
                Min = 50,
                Max = 200,
                Default = 100,
                Suffix = "%",
                Callback = function(Value)
                    Library:SetDPIScale(Value)
                end
            })

            task.defer(function()
                pcall(function()
                    Library:SetDPIScale(Library.Flags.DPIScale or 100)
                end)
            end)

            UISection:Divider()

            UISection:Toggle({
                Name = "Show Floating Toggle Button",
                Flag = "FloatingButtonVisible",
                Default = true,
                Tooltip = "Shows the round logo button used to open or close the UI.",
                Callback = function(v)
                    if Library.FloatingButtonWidget and Library.FloatingButtonWidget.Instance then
                        Library.FloatingButtonWidget.Instance.Visible = v
                    end
                end
            })

            UISection:Toggle({
                Name = "Custom Cursor",
                Flag = "CustomCursorEnabled",
                Default = false,
                Tooltip = "Replaces the default cursor with a themed blue cursor.",
                Callback = function(v)
                    Library:SetCustomCursor(v)
                end
            })

            UISection:Toggle({
                Name = "Show keybind rows",
                Flag = "ShowKeybindRows",
                Default = not IsMobile,
                Tooltip = "Shows per-feature keybind rows. Off by default on touch devices.",
                Callback = function(v)
                    Library:SetKeybindRowsVisible(v)
                end
            })

            task.defer(function()
                pcall(function()
                    if Library.Flags.CustomCursorEnabled then
                        Library:SetCustomCursor(true)
                    end
                    if Library.FloatingButtonWidget and Library.FloatingButtonWidget.Instance then
                        Library.FloatingButtonWidget.Instance.Visible = Library.Flags.FloatingButtonVisible ~= false
                    end
                    Library:SetKeybindRowsVisible(Library.Flags.ShowKeybindRows ~= false)
                end)
            end)
        end

        if not IsMobile then
            local KeybindSection = Page:Section({Name = "Keybinds", Icon = "keyboard", Side = 1}) do
                if KeybindList and KeybindList.SetVisibility then
                    KeybindSection:Toggle({
                        Name = "Show Keybinds List",
                        Flag = "KeybindListVisible",
                        Default = true,
                        Tooltip = "Shows or hides the draggable keybind list window.",
                        Callback = function(v)
                            KeybindList:SetVisibility(v)
                        end
                    })
                end
                KeybindSection:Toggle({
                    Name = "Enable Menu Keybind",
                    Flag = "MenuKeybindEnabled",
                    Default = true,
                    Tooltip = "When off, the Toggle UI keybind will not work.",
                    Callback = function(v) end
                })
                KeybindSection:Keybind({
                    Name = "Toggle UI",
                    Flag = "MenuBind",
                    Default = Enum.KeyCode.RightControl,
                    Callback = function()
                        if Library.Flags.MenuKeybindEnabled == false then
                            return
                        end
                        local now = tick()
                        if Library._lastMenuToggleAt and (now - Library._lastMenuToggleAt) < 0.2 then
                            return
                        end
                        Library._lastMenuToggleAt = now
                        Window:SetOpen(not Window.IsOpen)
                    end
                })
            end
        end

        local ConfigsSection = Page:Section({Name = "Configs", Side = 2, LayoutOrder = 5}) do
            local ConfigName
            local ConfigSelected

            local ConfigsDropdown = ConfigsSection:Listbox({
                Flag = "ConfigsList",
                Items = {},
                Multi = false,
                Callback = function(Value)
                    ConfigSelected = Value
                end
            })

            ConfigsSection:Textbox({
                Flag = "ConfigsName",
                Placeholder = "Config name...",
                Numeric = false,
                Finished = true,
                Callback = function(Value)
                    ConfigName = Value
                end
            })

            ConfigsSection:Button({
                Name = "Create",
                Callback = function()
                    local raw = ConfigName or (Library.Flags and Library.Flags.ConfigsName)
                    local fn = Library:ConfigDisplayToFile(raw)
                    if fn and not isfile(Library.Folders.Configs .. "/" .. fn) then
                        writefile(Library.Folders.Configs .. "/" .. fn, Library:GetConfig())
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Delete",
                Callback = function()
                    if ConfigSelected then
                        Library:DeleteConfig(ConfigSelected)
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Load",
                Callback = function()
                    if not ConfigSelected then return end
                    local fn = Library:ConfigDisplayToFile(ConfigSelected)
                    if fn and isfile(Library.Folders.Configs .. "/" .. fn) then
                        Library:LoadConfig(readfile(Library.Folders.Configs .. "/" .. fn))
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Save",
                Callback = function()
                    if not ConfigSelected then return end
                    local fn = Library:ConfigDisplayToFile(ConfigSelected)
                    if fn then
                        writefile(Library.Folders.Configs .. "/" .. fn, Library:GetConfig())
                        Library:RefreshConfigsList(ConfigsDropdown)
                    end
                end
            })

            ConfigsSection:Button({
                Name = "Refresh",
                Callback = function()
                    Library:RefreshConfigsList(ConfigsDropdown)
                end
            })

            task.defer(function()
                Library:RefreshConfigsList(ConfigsDropdown)
            end)
        end

        return Page
    end

    Library.SetDPIScale = function(self, Scale)
        local factor = math.clamp((Scale or 100) / 100, 0.5, 2)
        pcall(function()
            local mainFrame = Library.MainFrame and Library.MainFrame.Instance
            if not mainFrame then return end
            local ap = mainFrame.AbsolutePosition
            local as = mainFrame.AbsoluteSize
            local cx = ap.X + as.X * 0.5
            local cy = ap.Y + as.Y * 0.5
            local s = mainFrame:FindFirstChildOfClass("UIScale")
            if not s then
                s = Instance.new("UIScale")
                s.Parent = mainFrame
            end
            s.Scale = factor
            task.defer(function()
                if not mainFrame.Parent then return end
                local nas = mainFrame.AbsoluteSize
                mainFrame.Position = UDim2FromOffset(cx - nas.X * 0.5, cy - nas.Y * 0.5)
            end)
        end)
    end

    do
        local cursorScreen = Instance.new("ScreenGui")
        cursorScreen.Name = "\0MentalityCursor"
        cursorScreen.IgnoreGuiInset = true
        cursorScreen.DisplayOrder = 2147483647
        cursorScreen.ZIndexBehavior = Enum.ZIndexBehavior.Global
        cursorScreen.ResetOnSpawn = false
        cursorScreen.Enabled = false
        cursorScreen.Parent = gethui()
        Library.CursorScreenGui = cursorScreen

        local cursorRoot = Instance.new("Frame")
        cursorRoot.Name = "\0"
        cursorRoot.BackgroundTransparency = 1
        cursorRoot.BorderSizePixel = 0
        cursorRoot.Size = UDim2New(0, 20, 0, 20)
        cursorRoot.ZIndex = 2147483647
        cursorRoot.Visible = false
        cursorRoot.Parent = cursorScreen

        local img = Instance.new("ImageLabel")
        img.Name = "\0"
        img.BackgroundTransparency = 1
        img.Size = UDim2New(1, 0, 1, 0)
        img.BorderSizePixel = 0
        img.Image = "rbxassetid://132511743665753"
        img.ImageColor3 = FromRGB(90, 165, 255)
        img.ScaleType = Enum.ScaleType.Fit
        img.Rotation = -90
        img.AnchorPoint = Vector2New(0, 0)
        img.Position = UDim2New(0, 0, 0, 0)
        img.Parent = cursorRoot

        local CursorConn = RunService.RenderStepped:Connect(function()
            if not cursorRoot.Visible then return end
            local loc = UserInputService:GetMouseLocation()
            local ox, oy = 2, 2
            cursorRoot.Position = UDim2New(0, loc.X - ox, 0, loc.Y - oy)
        end)

        Library.CursorGui = cursorRoot
        Library.CursorConn = CursorConn

        Library.SetCustomCursor = function(self, enabled)
            local on = enabled == true
            cursorRoot.Visible = on
            cursorScreen.Enabled = on
            pcall(function()
                UserInputService.MouseIconEnabled = not on
            end)
        end
    end

    return Library
end

-- ======================= METUI INTEGRATION END =======================

-- Fenglib API wrapper

local function buildSectionBuilder(page, contentContainer, elementWidth, windowCount)
    local function createSection(text, icons, defaultOpen)
        if defaultOpen == nil then defaultOpen = true end

        local function formatAssetId(id)
            if type(id) == "number" then
                return "rbxassetid://" .. tostring(id)
            elseif type(id) == "string" then
                if tonumber(id) then
                    return "rbxassetid://" .. id
                else
                    return id
                end
            else
                return nil
            end
        end

        local iconOpen, iconClosed
        if type(icons) == "table" then
            iconOpen = formatAssetId(icons.Y or icons.open) or "rbxassetid://6031091004"
            iconClosed = formatAssetId(icons.F or icons.closed) or iconOpen
        else
            local defaultIcon = formatAssetId(icons) or "rbxassetid://6031091004"
            iconOpen = defaultIcon
            iconClosed = defaultIcon
        end

        local sectionFrame = page:Section({
            Name = text,
            Icon = iconOpen,
            Description = "",
            Side = 1,
            LayoutOrder = 0
        })
        -- sectionFrame is a metUI section object. It has Items.Content as a frame that holds elements.
        -- We need to return a builder that adds elements into that content frame.

        local contentLayout = sectionFrame.Items.Content
        local currentContentTween, currentSectionTween
        local open = defaultOpen

        local function updateSectionHeight(instant)
            -- handled by metUI internally
        end

        task.spawn(function()
            task.wait()
            updateSectionHeight(true)
        end)

        -- Override toggle behavior to match original
        local origToggle = sectionFrame.ToggleBackground
        sectionFrame.ToggleBackground = function(self)
            origToggle(self)
            open = not open
            -- no icon change needed as metUI uses its own indicator
        end
        if not defaultOpen then
            sectionFrame:ToggleBackground()
            open = false
        end

        local child = {}

        child.Button = function(_, btnText, callback)
            local btn = sectionFrame:Button({
                Name = btnText,
                Callback = callback
            })
            return {
                UpdateText = function(newText)
                    local lbl = btn.Items.Text
                    if lbl and lbl.Instance then
                        lbl.Instance.Text = newText
                    end
                end,
                SetVisible = function(state) btn:SetVisibility(state) end
            }
        end

        child.Toggle = function(_, toggleText, defaultVal, callback)
            local tg = sectionFrame:Toggle({
                Name = toggleText,
                Default = defaultVal,
                Callback = callback
            })
            return tg
        end

        child.Slider = function(_, sliderText, minVal, maxVal, defaultVal, callback, options)
            options = options or {}
            local unlimited = (minVal == nil and maxVal == nil)
            if unlimited then
                -- Fallback: use a regular slider with large range
                minVal = 0
                maxVal = 100
            end
            local sl = sectionFrame:Slider({
                Name = sliderText,
                Min = tonumber(minVal) or 0,
                Max = tonumber(maxVal) or 100,
                Default = tonumber(defaultVal) or 0,
                Suffix = options.suffix or "",
                Decimals = options.decimals or 1,
                Callback = callback
            })
            return sl
        end

        child.Dropdown = function(_, dropText, optionsList, callback)
            local dd = sectionFrame:Dropdown({
                Name = dropText,
                Items = optionsList,
                Default = optionsList[1],
                Callback = callback,
                Multi = false
            })
            return {
                Refresh = function(newOpts) dd:Refresh(newOpts) end,
                Reset = function() 
                    if #optionsList > 0 then
                        dd:Set(optionsList[1])
                    end
                end
            }
        end

        child.Keybind = function(_, keyText, defaultKey, callback)
            local kb = sectionFrame:Keybind({
                Name = keyText,
                Default = defaultKey,
                Mode = "Toggle",
                Callback = callback
            })
            return kb
        end

        child.Textbox = function(_, boxText, placeholder, callback)
            local tb = sectionFrame:Textbox({
                Name = boxText,
                Placeholder = placeholder,
                Finished = true,
                Callback = callback
            })
            return tb
        end

        child.Input = function(_, inputText, defaultVal, callback, options)
            options = options or {}
            local tb = sectionFrame:Textbox({
                Name = inputText,
                Placeholder = options.placeholder or "",
                Default = tostring(defaultVal or ""),
                Callback = callback,
                Numeric = options.acceptedCharacters == "Numeric"
            })
            return {
                UpdateText = function(newText) tb:Set(tostring(newText)) end,
                GetText = function() return tb:Get() end,
                SetVisible = function(state) tb:SetVisibility(state) end,
                UpdatePlaceholder = function(newPlaceholder) end -- not supported
            }
        end

        child.Label = function(_, labelText)
            local lbl = sectionFrame:Label(labelText)
            return {
                UpdateText = function(newText) lbl:SetText(newText) end,
                SetVisible = function(state) lbl:SetVisibility(state) end
            }
        end

        child.SubLabel = function(_, subLabelText)
            -- metUI doesn't have SubLabel, use Label with smaller text
            local lbl = sectionFrame:Label(subLabelText)
            if lbl.Items and lbl.Items.Text and lbl.Items.Text.Instance then
                lbl.Items.Text.Instance.TextSize = 12
                lbl.Items.Text.Instance.TextTransparency = 0.5
            end
            return {
                UpdateText = function(newText) lbl:SetText(newText) end,
                SetVisible = function(state) lbl:SetVisibility(state) end
            }
        end

        child.Paragraph = function(_, headerText, bodyText)
            local lblHeader = sectionFrame:Label(headerText)
            if lblHeader.Items and lblHeader.Items.Text and lblHeader.Items.Text.Instance then
                lblHeader.Items.Text.Instance.Font = Enum.Font.GothamBold
                lblHeader.Items.Text.Instance.TextSize = 14
            end
            local lblBody = sectionFrame:Label(bodyText)
            if lblBody.Items and lblBody.Items.Text and lblBody.Items.Text.Instance then
                lblBody.Items.Text.Instance.TextSize = 13
                lblBody.Items.Text.Instance.TextTransparency = 0.3
            end
            return {
                UpdateHeader = function(newText) lblHeader:SetText(newText) end,
                UpdateBody = function(newText) lblBody:SetText(newText) end,
                SetVisible = function(state) 
                    lblHeader:SetVisibility(state)
                    lblBody:SetVisibility(state)
                end
            }
        end

        child.ColorPicker = function(_, pickerText, defaultColor, callback)
            local cp = sectionFrame:Label(pickerText):Colorpicker({
                Default = defaultColor,
                Callback = callback
            })
            return cp
        end

        child.Image = function(_, config)
            config = config or {}
            local title = config.Title or "Image"
            local subtitle = config.Subtitle or ""
            local description = config.Description or {}
            if type(description) == "string" then
                description = {description}
            end
            local iconAsset = config.Icon or config.ImageLink or ""
            local callback = config.Callback or function() end

            -- Create a frame inside the section to hold the image content
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.BackgroundTransparency = 0.05
            container.Parent = contentLayout
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = container
            AddToRegistry(container, "BackgroundColor3", "Top")
            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Transparency = 0.6
            stroke.Parent = container
            AddToRegistry(stroke, "Color", "Stroke")

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 12)
            padding.PaddingRight = UDim.new(0, 12)
            padding.PaddingTop = UDim.new(0, 12)
            padding.PaddingBottom = UDim.new(0, 12)
            padding.Parent = container

            local horizontal = Instance.new("Frame")
            horizontal.Size = UDim2.new(1, 0, 1, 0)
            horizontal.BackgroundTransparency = 1
            horizontal.Parent = container

            local iconImg = Instance.new("ImageLabel")
            iconImg.Size = UDim2.new(0, 80, 0, 80)
            iconImg.Position = UDim2.new(0, 0, 0, 0)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = iconAsset
            iconImg.ImageColor3 = CurrentTheme.Text
            iconImg.Parent = horizontal
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 12)
            iconCorner.Parent = iconImg
            AddToRegistry(iconImg, "ImageColor3", "Text")

            local textContainer = Instance.new("Frame")
            textContainer.Size = UDim2.new(1, -92, 1, 0)
            textContainer.Position = UDim2.new(0, 92, 0, 0)
            textContainer.BackgroundTransparency = 1
            textContainer.AutomaticSize = Enum.AutomaticSize.Y
            textContainer.Parent = horizontal

            local textLayout = Instance.new("UIListLayout")
            textLayout.Padding = UDim.new(0, 6)
            textLayout.SortOrder = Enum.SortOrder.LayoutOrder
            textLayout.Parent = textContainer

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 0)
            titleLabel.AutomaticSize = Enum.AutomaticSize.Y
            titleLabel.BackgroundTransparency = 1
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.Text = title
            titleLabel.TextSize = 15
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.TextWrapped = true
            titleLabel.Parent = textContainer
            AddToRegistry(titleLabel, "TextColor3", "Text")

            local subtitleLabel = nil
            if subtitle ~= "" then
                subtitleLabel = Instance.new("TextLabel")
                subtitleLabel.Size = UDim2.new(1, 0, 0, 0)
                subtitleLabel.AutomaticSize = Enum.AutomaticSize.Y
                subtitleLabel.BackgroundTransparency = 1
                subtitleLabel.Font = Enum.Font.Gotham
                subtitleLabel.Text = subtitle
                subtitleLabel.TextSize = 12
                subtitleLabel.TextTransparency = 0.5
                subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                subtitleLabel.TextWrapped = true
                subtitleLabel.Parent = textContainer
                AddToRegistry(subtitleLabel, "TextColor3", "Text")
            end

            local descLabels = {}
            for _, line in ipairs(description) do
                local descLabel = Instance.new("TextLabel")
                descLabel.Size = UDim2.new(1, 0, 0, 0)
                descLabel.AutomaticSize = Enum.AutomaticSize.Y
                descLabel.BackgroundTransparency = 1
                descLabel.Font = Enum.Font.Gotham
                descLabel.Text = line
                descLabel.TextSize = 12
                descLabel.TextTransparency = 0.3
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextWrapped = true
                descLabel.Parent = textContainer
                AddToRegistry(descLabel, "TextColor3", "Text")
                table.insert(descLabels, descLabel)
            end

            local clickBtn = Instance.new("TextButton")
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Text = ""
            clickBtn.Parent = container
            clickBtn.MouseButton1Click:Connect(callback)

            local function onEnter()
                Tween(container, {BackgroundTransparency = 0.00}, 0.18)
            end
            local function onLeave()
                Tween(container, {BackgroundTransparency = 0.05}, 0.18)
            end
            clickBtn.MouseEnter:Connect(onEnter)
            clickBtn.MouseLeave:Connect(onLeave)

            local self = {}
            function self.UpdateTitle(newTitle) titleLabel.Text = newTitle end
            function self.UpdateSubtitle(newSubtitle)
                if subtitleLabel then
                    subtitleLabel.Text = newSubtitle
                elseif newSubtitle ~= "" then
                    subtitleLabel = Instance.new("TextLabel")
                    subtitleLabel.Size = UDim2.new(1, 0, 0, 0)
                    subtitleLabel.AutomaticSize = Enum.AutomaticSize.Y
                    subtitleLabel.BackgroundTransparency = 1
                    subtitleLabel.Font = Enum.Font.Gotham
                    subtitleLabel.Text = newSubtitle
                    subtitleLabel.TextSize = 12
                    subtitleLabel.TextTransparency = 0.5
                    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    subtitleLabel.TextWrapped = true
                    subtitleLabel.Parent = textContainer
                    AddToRegistry(subtitleLabel, "TextColor3", "Text")
                    textLayout:Arrange()
                end
            end
            function self.UpdateDescription(newDesc)
                for _, lbl in ipairs(descLabels) do
                    lbl:Destroy()
                end
                descLabels = {}
                if type(newDesc) == "string" then newDesc = {newDesc} end
                for _, line in ipairs(newDesc) do
                    local descLabel = Instance.new("TextLabel")
                    descLabel.Size = UDim2.new(1, 0, 0, 0)
                    descLabel.AutomaticSize = Enum.AutomaticSize.Y
                    descLabel.BackgroundTransparency = 1
                    descLabel.Font = Enum.Font.Gotham
                    descLabel.Text = line
                    descLabel.TextSize = 12
                    descLabel.TextTransparency = 0.3
                    descLabel.TextXAlignment = Enum.TextXAlignment.Left
                    descLabel.TextWrapped = true
                    descLabel.Parent = textContainer
                    AddToRegistry(descLabel, "TextColor3", "Text")
                    table.insert(descLabels, descLabel)
                end
                textLayout:Arrange()
            end
            function self.SetIcon(newIcon, newColor)
                iconImg.Image = newIcon
                if newColor then
                    iconImg.ImageColor3 = newColor
                end
            end
            function self.SetVisible(state)
                container.Visible = state
            end
            return self
        end

        return child
    end
    return createSection
end

function Fenglib:CreateWindow(Config)
    local Window = {}
    local Title = Config.Title or "FengY3"
    local Subtitle = Config.Subtitle
    local Keybind = Config.Keybind 
    local IconAsset = Config.Icon  
    local isCardMode = Config.Card == true

    if Config.Theme then
        if type(Config.Theme) == "string" then
            if Themes[Config.Theme] then
                CurrentTheme = Themes[Config.Theme]
                Library.Theme.Accent = CurrentTheme.Accent
                Library.Theme.AccentGradient = CurrentTheme.Accent
                Library.Theme["Background"] = CurrentTheme.Main
                Library.Theme["Background 2"] = CurrentTheme.Main
                Library.Theme["Section Top"] = CurrentTheme.Top
                Library.Theme["Section Background"] = CurrentTheme.Main
                Library.Theme["Section Background 2"] = CurrentTheme.Top
                Library.Theme["Text"] = CurrentTheme.Text
                Library.Theme["Outline"] = CurrentTheme.Stroke
                Library.Theme["Element"] = CurrentTheme.Top
                for _, item in Library.ThemeItems do
                    pcall(function() Library:ChangeItemTheme(item.Item, item.Properties) end)
                end
            end
        elseif type(Config.Theme) == "table" then
            local t = Config.Theme
            local function toC3(v)
                if type(v) == "table" then return Color3.fromRGB(v[1] or 0, v[2] or 0, v[3] or 0)
                elseif type(v) == "userdata" then return v
                else return Color3.new(0,0,0) end
            end
            CurrentTheme = {
                Main   = t.Main   and toC3(t.Main)   or CurrentTheme.Main,
                Top    = t.Top    and toC3(t.Top)    or CurrentTheme.Top,
                Text   = t.Text   and toC3(t.Text)   or CurrentTheme.Text,
                Accent = t.Accent and toC3(t.Accent) or CurrentTheme.Accent,
                Stroke = t.Stroke and toC3(t.Stroke) or CurrentTheme.Stroke,
            }
            Library.Theme.Accent = CurrentTheme.Accent
            Library.Theme.AccentGradient = CurrentTheme.Accent
            Library.Theme["Background"] = CurrentTheme.Main
            Library.Theme["Background 2"] = CurrentTheme.Main
            Library.Theme["Section Top"] = CurrentTheme.Top
            Library.Theme["Section Background"] = CurrentTheme.Main
            Library.Theme["Section Background 2"] = CurrentTheme.Top
            Library.Theme["Text"] = CurrentTheme.Text
            Library.Theme["Outline"] = CurrentTheme.Stroke
            Library.Theme["Element"] = CurrentTheme.Top
            for _, item in Library.ThemeItems do
                pcall(function() Library:ChangeItemTheme(item.Item, item.Properties) end)
            end
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FengYu-Bento"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ScreenInsets = Enum.ScreenInsets.None
    if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 300, 0, 0)
    NotificationHolder.AutomaticSize = Enum.AutomaticSize.Y
    NotificationHolder.Position = UDim2.new(1, -20, 1, -20)
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.BorderSizePixel = 0
    NotificationHolder.Parent = ScreenGui
    NotificationHolder.ZIndex = 100

    local HolderList = Instance.new("UIListLayout")
    HolderList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    HolderList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    HolderList.SortOrder = Enum.SortOrder.LayoutOrder
    HolderList.Padding = UDim.new(0, 5)
    HolderList.Parent = NotificationHolder

    local HolderPadding = Instance.new("UIPadding")
    HolderPadding.PaddingRight = UDim.new(0, 5)
    HolderPadding.PaddingBottom = UDim.new(0, 5)
    HolderPadding.Parent = NotificationHolder

    -- Create metUI window
    local metWindow = Library:Window({
        Name = Title,
        SubName = Subtitle or "",
        Logo = IconAsset or "1l20959262762131",
        Size = UDim2.new(0, 940, 0, 730)
    })
    local MainFrame = metWindow.Items.MainFrame.Instance
    MainFrame.Parent = ScreenGui

    -- Remove original title/logo etc to match Fenglib style? Actually metUI already has its own top bar, but we need to adapt.
    -- We'll hide the original metUI top bar elements and use our own? But we are required to keep API same, so we need to provide .Tab method.
    -- metWindow already has .Page method. We'll map .Tab to .Page and return a builder that returns section creator.

    local function getTabBuilder(page)
        return function()
            local elements = {}
            local createSection = buildSectionBuilder(page, nil, 330, 1)
            elements.Section = function(_, text, icons, defaultOpen) return createSection(text, icons, defaultOpen) end
            elements.Button   = function(_, btnText, callback) return createSection("", nil, true).Button(btnText, callback) end
            elements.Toggle   = function(_, toggleText, defaultVal, callback) return createSection("", nil, true).Toggle(toggleText, defaultVal, callback) end
            elements.Slider   = function(_, sliderText, minVal, maxVal, defaultVal, callback, opts) return createSection("", nil, true).Slider(sliderText, minVal, maxVal, defaultVal, callback, opts) end
            elements.Dropdown = function(_, dropText, options, callback) return createSection("", nil, true).Dropdown(dropText, options, callback) end
            elements.Keybind  = function(_, keyText, defaultKey, callback) return createSection("", nil, true).Keybind(keyText, defaultKey, callback) end
            elements.Textbox  = function(_, boxText, placeholder, callback) return createSection("", nil, true).Textbox(boxText, placeholder, callback) end
            elements.Input    = function(_, inputText, defaultVal, callback, opts) return createSection("", nil, true).Input(inputText, defaultVal, callback, opts) end
            elements.Label    = function(_, labelText) return createSection("", nil, true).Label(labelText) end
            elements.SubLabel = function(_, subLabelText) return createSection("", nil, true).SubLabel(subLabelText) end
            elements.Paragraph= function(_, headerText, bodyText) return createSection("", nil, true).Paragraph(headerText, bodyText) end
            elements.ColorPicker= function(_, pickerText, defaultColor, callback) return createSection("", nil, true).ColorPicker(pickerText, defaultColor, callback) end
            elements.Image    = function(_, config) return createSection("", nil, true).Image(config) end
            return elements
        end
    end

    function Window:Tab(name, icon)
        local page = metWindow:Page({ Name = name, Icon = icon or "layout-grid" })
        return getTabBuilder(page)
    end

    -- Card mode (preserve original card mode from old UI.lua)
    if isCardMode then
        -- We will re-implement card mode on top of metUI or fallback to original card mode implementation?
        -- For compatibility, we can replicate the card mode using metUI's dashboard page or custom scrolling frame.
        -- Given complexity, we'll keep a simplified card mode that mimics old behavior.
        warn("Card mode not fully reimplemented in metUI integration; falling back to normal tab mode.")
    end

    -- Projector mode (original logic, adapted to new main frame)
    Window._ProjectorModeEnabled = false
    Window._ProjectorObjects = nil
    Window._ProjectorSettings = {
        distance = 8,
        width = 12,
        height = 8,
        transparency = 0.3,
        autoSize = true
    }

    local function SwitchToProjectorMode(distance, width, height, transparency)
        if Window._ProjectorModeEnabled then return end
        distance = distance or Window._ProjectorSettings.distance
        width = width or Window._ProjectorSettings.width
        height = height or Window._ProjectorSettings.height
        transparency = transparency or Window._ProjectorSettings.transparency
        
        local projectorScreen = Instance.new("Part")
        projectorScreen.Name = "FengYu_ProjectorScreen"
        projectorScreen.Anchored = true
        projectorScreen.CanCollide = false
        projectorScreen.Locked = true
        projectorScreen.Transparency = transparency
        projectorScreen.Size = Vector3.new(width, height, 0.1)
        projectorScreen.BrickColor = BrickColor.new("White")
        projectorScreen.Material = Enum.Material.SmoothPlastic
        projectorScreen.TopSurface = Enum.SurfaceType.Smooth
        projectorScreen.BottomSurface = Enum.SurfaceType.Smooth
        projectorScreen.Parent = workspace
        
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Name = "ProjectorUI"
        surfaceGui.ResetOnSpawn = false
        surfaceGui.Face = Enum.NormalId.Front
        surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surfaceGui.CanvasSize = Vector2.new(1600, 1200)
        surfaceGui.ClipsDescendants = true
        surfaceGui.AlwaysOnTop = true
        surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        surfaceGui.Adornee = projectorScreen
        surfaceGui.Parent = projectorScreen
        
        local originalChildren = {}
        for _, child in ipairs(ScreenGui:GetChildren()) do
            if child ~= OpenButton and child ~= NotificationHolder then
                originalChildren[#originalChildren + 1] = child
            end
        end
        
        for _, child in ipairs(originalChildren) do
            child.Parent = surfaceGui
        end
        
        Window._savedMainFrameSize = MainFrame.Size
        Window._savedMainFramePos = MainFrame.Position
        
        MainFrame.Size = UDim2.new(0, 600, 0, 400)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 2.5
        pointLight.Range = 20
        pointLight.Color = CurrentTheme.Accent
        pointLight.Parent = projectorScreen
        
        local function updateScreenPosition()
            local character = LocalPlayer.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local forward = rootPart.CFrame.LookVector
            forward = Vector3.new(forward.X, 0, forward.Z).Unit
            local targetPos = rootPart.Position + forward * distance
            targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z)
            
            local lookAtPoint = Vector3.new(rootPart.Position.X, targetPos.Y, rootPart.Position.Z)
            local screenCF = CFrame.lookAt(targetPos, lookAtPoint, Vector3.new(0, 1, 0))
            
            projectorScreen.CFrame = screenCF
        end
        
        updateScreenPosition()
        
        local updateConnection
        updateConnection = RunService.RenderStepped:Connect(function()
            if not projectorScreen.Parent then
                if updateConnection then updateConnection:Disconnect() end
                return
            end
            updateScreenPosition()
        end)
        
        local sizeConnection
        sizeConnection = MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
            if Window._ProjectorSettings.autoSize then
                if Window._ProjectorObjects and Window._ProjectorObjects.SurfaceGui then
                    local mainFrame = Window._ProjectorObjects.SurfaceGui:FindFirstChild("FengYu-Bento")
                    if mainFrame then
                        local absSize = mainFrame.AbsoluteSize
                        if absSize.X > 0 and absSize.Y > 0 then
                            local aspect = absSize.X / absSize.Y
                            local targetHeight = Window._ProjectorSettings.height
                            local targetWidth = targetHeight * aspect
                            targetWidth = clamp(targetWidth, 4, 24)
                            targetHeight = clamp(targetHeight, 3, 16)
                            projectorScreen.Size = Vector3.new(targetWidth, targetHeight, 0.1)
                            Window._ProjectorSettings.width = targetWidth
                            Window._ProjectorSettings.height = targetHeight
                        end
                    end
                end
            end
        end)
        task.wait(0.1)
        
        Window._ProjectorModeEnabled = true
        Window._ProjectorObjects = {
            Screen = projectorScreen,
            SurfaceGui = surfaceGui,
            UpdateConnection = updateConnection,
            SizeConnection = sizeConnection,
            Light = pointLight
        }
        
        return true
    end
    
    local function SwitchTo2DMode()
        if not Window._ProjectorModeEnabled then return end
        
        if Window._ProjectorObjects then
            if Window._ProjectorObjects.UpdateConnection then
                Window._ProjectorObjects.UpdateConnection:Disconnect()
            end
            if Window._ProjectorObjects.SizeConnection then
                Window._ProjectorObjects.SizeConnection:Disconnect()
            end
            if Window._ProjectorObjects.SurfaceGui then
                local surfaceGui = Window._ProjectorObjects.SurfaceGui
                for _, child in ipairs(surfaceGui:GetChildren()) do
                    child.Parent = ScreenGui
                end
            end
            if Window._ProjectorObjects.Screen then
                Window._ProjectorObjects.Screen:Destroy()
            end
        end
        
        if Window._savedMainFrameSize then
            MainFrame.Size = Window._savedMainFrameSize
            MainFrame.Position = Window._savedMainFramePos
        else
            MainFrame.Size = UDim2.new(0, 500, 0, 299)
            MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
        
        Window._ProjectorModeEnabled = false
        Window._ProjectorObjects = nil
        
        return true
    end
    
    local function ToggleProjectorMode()
        if Window._ProjectorModeEnabled then
            SwitchTo2DMode()
        else
            SwitchToProjectorMode()
        end
    end
    
    function Window:SetProjectorDistance(distance)
        distance = clamp(distance, 3, 20)
        Window._ProjectorSettings.distance = distance
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local forward = rootPart.CFrame.LookVector
                forward = Vector3.new(forward.X, 0, forward.Z).Unit
                local targetPos = rootPart.Position + forward * distance
                targetPos = Vector3.new(targetPos.X, targetPos.Y + 1.2, targetPos.Z)
                local lookAtPoint = Vector3.new(rootPart.Position.X, targetPos.Y, rootPart.Position.Z)
                local screenCF = CFrame.lookAt(targetPos, lookAtPoint, Vector3.new(0, 1, 0))
                Window._ProjectorObjects.Screen.CFrame = screenCF
            end
        end
    end
    
    function Window:SetProjectorSize(width, height)
        width = clamp(width, 4, 24)
        height = clamp(height, 3, 16)
        Window._ProjectorSettings.width = width
        Window._ProjectorSettings.height = height
        Window._ProjectorSettings.autoSize = false
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            Window._ProjectorObjects.Screen.Size = Vector3.new(width, height, 0.1)
        end
    end
    
    function Window:SetProjectorTransparency(transparency)
        transparency = clamp(transparency, 0, 0.8)
        Window._ProjectorSettings.transparency = transparency
        if Window._ProjectorModeEnabled and Window._ProjectorObjects and Window._ProjectorObjects.Screen then
            Window._ProjectorObjects.Screen.Transparency = transparency
        end
    end
    
    function Window:EnableProjectorMode(distance, width, height, transparency)
        return SwitchToProjectorMode(distance, width, height, transparency)
    end
    
    function Window:DisableProjectorMode()
        return SwitchTo2DMode()
    end
    
    function Window:ToggleProjectorMode()
        return ToggleProjectorMode()
    end
    
    function Window:IsProjectorMode()
        return Window._ProjectorModeEnabled
    end

    function Window:Notification(titleText, descText, notifType, duration)
        notifType = notifType or "Info"
        duration = duration or 3
        Library:Notification({
            Title = titleText,
            Description = descText,
            Duration = duration,
            Icon = notifType == "Success" and "120659272678891" or (notifType == "Error" and "89180847534855" or "75441143875602"),
            IconColor = notifType == "Success" and {Start = Color3.fromRGB(60,179,113), End = Color3.fromRGB(60,179,113)} or
                        (notifType == "Error" and {Start = Color3.fromRGB(229,51,51), End = Color3.fromRGB(229,51,51)} or nil)
        })
    end

    function Window:SetKeybind(key) Keybind = key end
    function Window:Destroy() ScreenGui:Destroy() end
    function Window:SetSubtitle(newSubtitle) Subtitle = newSubtitle end

    -- Floating button (reuse metUI's floating button)
    local OpenButton = metWindow.Items.FloatingButton.Instance
    OpenButton.Parent = ScreenGui
    OpenButton.Visible = false
    OpenButton.MouseButton1Click:Connect(function()
        if MainFrame.Visible then
            MainFrame.Visible = false
        else
            MainFrame.Visible = true
        end
    end)
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        OpenButton.Visible = not MainFrame.Visible
    end)

    -- Keybind handling
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and Keybind and input.KeyCode == Keybind then
            if MainFrame.Visible then
                MainFrame.Visible = false
            else
                MainFrame.Visible = true
            end
        end
    end)

    return Window
end

return Fenglib