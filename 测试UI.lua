repeat
    task.wait()
until game:IsLoaded()

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = {}

settings().Rendering.QualityLevel = 1
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
settings().Rendering.EagerBulkExecution = true

local function protectGUI(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif get_hidden_gui then
        get_hidden_gui(gui)
    end
    
    local success, err = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        local starterGui = game:GetService("StarterGui")
        starterGui:SetCore("RobloxGui", gui)
    end
end

local FengUI = {}
local ToggleUI = true
FengUI.currentTab = nil
FengUI.flags = {}

local services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService")
}

local UserInputService = services.UserInputService
local RunService = services.RunService

local config = {
    MainColor = Color3.fromRGB(18, 18, 30),
    TabColor = Color3.fromRGB(25, 25, 40),
    Bg_Color = Color3.fromRGB(20, 20, 35),
    Zy_Color = Color3.fromRGB(20, 20, 35),
    Button_Color = Color3.fromRGB(30, 30, 50),
    Textbox_Color = Color3.fromRGB(30, 30, 50),
    Dropdown_Color = Color3.fromRGB(30, 30, 50),
    Keybind_Color = Color3.fromRGB(30, 30, 50),
    Label_Color = Color3.fromRGB(30, 30, 50),
    Slider_Color = Color3.fromRGB(30, 30, 50),
    SliderBar_Color = Color3.fromRGB(0, 200, 255),
    Toggle_Color = Color3.fromRGB(30, 30, 50),
    Toggle_Off = Color3.fromRGB(50, 50, 70),
    Toggle_On = Color3.fromRGB(0, 230, 230),
    AccentColor = Color3.fromRGB(0, 200, 255),
    TextColor = Color3.fromRGB(240, 245, 255),
    SecondaryTextColor = Color3.fromRGB(180, 190, 210),
    GlowColor = Color3.fromRGB(0, 150, 255),
    
    DeepSpaceColor = Color3.fromRGB(1, 2, 10),
    NebulaColor1 = Color3.fromRGB(0, 40, 80),
    NebulaColor2 = Color3.fromRGB(20, 60, 120),
    AccentGlow = Color3.fromRGB(0, 220, 255),
    ElementColor = Color3.fromRGB(30, 30, 50),
    ElementTransparency = 0.2,
    GlassEffect = Color3.fromRGB(255, 255, 255),
}

-- 加载原始颜色选择器模块
local function loadOriginalColorpicker()
    -- 创建模拟环境以运行原始颜色选择器
    local mockEnv = {
        game = game,
        Color3 = Color3,
        UDim2 = UDim2,
        Vector2 = Vector2,
        Enum = Enum,
        require = require,
        pcall = pcall,
        math = math,
        tonumber = tonumber,
        typeof = typeof,
        table = table,
        string = string,
        type = type,
        assert = assert,
        tostring = tostring
    }
    
    -- 创建模拟的Creator模块
    mockEnv.Creator = {
        New = function(className, properties, children)
            local instance = Instance.new(className)
            
            if properties then
                for key, value in pairs(properties) do
                    if key == "Parent" then
                        instance.Parent = value
                    else
                        instance[key] = value
                    end
                end
            end
            
            if children then
                for _, child in pairs(children) do
                    child.Parent = instance
                end
            end
            
            return instance
        end,
        
        AddSignal = function(connection, callback)
            if connection and callback then
                connection:Connect(callback)
            end
        end
    }
    
    -- 创建模拟的Components模块
    mockEnv.Components = {
        Element = function(title, description, container, hasButton)
            local element = {
                Frame = Instance.new("Frame"),
                SetTitle = function(self, newTitle) end,
                SetDesc = function(self, newDesc) end,
                Destroy = function(self) self.Frame:Destroy() end
            }
            
            element.Frame.BackgroundTransparency = 1
            element.Frame.Size = UDim2.new(1, 0, 0, 30)
            
            return element
        end,
        
        Dialog = {
            Create = function()
                local dialog = {
                    Root = Instance.new("Frame"),
                    Title = Instance.new("TextLabel"),
                    Button = function(self, text, callback) end,
                    Open = function(self) end
                }
                
                dialog.Root.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                dialog.Root.BackgroundTransparency = 0.1
                dialog.Root.Size = UDim2.fromOffset(400, 300)
                
                dialog.Title.Text = "Color Picker"
                dialog.Title.Parent = dialog.Root
                
                return dialog
            end
        },
        
        Textbox = function()
            return {
                Frame = Instance.new("Frame"),
                Input = Instance.new("TextBox")
            }
        end
    }
    
    -- 设置环境并执行原始颜色选择器代码
    local originalCode = [[
local UserInputService = game:GetService("UserInputService")
local TouchInputService = game:GetService("TouchInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RenderStepped = RunService.RenderStepped
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Colorpicker - Missing Title")
	assert(Config.Default, "AddColorPicker: Missing default value.")

	local Colorpicker = {
		Value = Config.Default,
		Transparency = Config.Transparency or 0,
		Type = "Colorpicker",
		Title = type(Config.Title) == "string" and Config.Title or "Colorpicker",
		Callback = Config.Callback or function(Color) end,
	}

	function Colorpicker:SetHSVFromRGB(Color)
		local H, S, V = Color3.toHSV(Color)
		Colorpicker.Hue = H
		Colorpicker.Sat = S
		Colorpicker.Vib = V
	end

	Colorpicker:SetHSVFromRGB(Colorpicker.Value)

	local ColorpickerFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, true)

	Colorpicker.SetTitle = ColorpickerFrame.SetTitle
	Colorpicker.SetDesc = ColorpickerFrame.SetDesc

	local DisplayFrameColor = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Colorpicker.Value,
		Parent = ColorpickerFrame.Frame,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})

	local DisplayFrame = New("ImageLabel", {
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Parent = ColorpickerFrame.Frame,
		Image = "http://www.roblox.com/asset/?id=14204231522",
		ImageTransparency = 0.45,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(40, 40),
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		DisplayFrameColor,
	})

	local function CreateColorDialog()
		local Dialog = require(Components.Dialog):Create()
		Dialog.Title.Text = Colorpicker.Title
		Dialog.Root.Size = UDim2.fromOffset(430, 330)

		local Hue, Sat, Vib = Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib
		local Transparency = Colorpicker.Transparency

		local function CreateInput()
			local Box = require(Components.Textbox)()
			Box.Frame.Parent = Dialog.Root
			Box.Frame.Size = UDim2.new(0, 90, 0, 32)

			return Box
		end

		local function CreateInputLabel(Text, Pos)
			return New("TextLabel", {
				FontFace = Font.new(
					"rbxasset://fonts/families/GothamSSm.json",
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				),
				Text = Text,
				TextColor3 = Color3.fromRGB(240, 240, 240),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 32),
				Position = Pos,
				BackgroundTransparency = 1,
				Parent = Dialog.Root,
				ThemeTag = {
					TextColor3 = "Text",
				},
			})
		end

		local function GetRGB()
			local Value = Color3.fromHSV(Hue, Sat, Vib)
			return { R = math.floor(Value.r * 255), G = math.floor(Value.g * 255), B = math.floor(Value.b * 255) }
		end

		local SatCursor = New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=4805639000",
		})

		local SatVibMap = New("ImageLabel", {
			Size = UDim2.fromOffset(180, 160),
			Position = UDim2.fromOffset(20, 55),
			Image = "rbxassetid://4155801252",
			BackgroundColor3 = Colorpicker.Value,
			BackgroundTransparency = 0,
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			SatCursor,
		})

		local OldColorFrame = New("Frame", {
			BackgroundColor3 = Colorpicker.Value,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = Colorpicker.Transparency,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})

		local OldColorFrameChecker = New("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=14204231522",
			ImageTransparency = 0.45,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(40, 40),
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(112, 220),
			Size = UDim2.fromOffset(88, 24),
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIStroke", {
				Thickness = 2,
				Transparency = 0.75,
			}),
			OldColorFrame,
		})

		local DialogDisplayFrame = New("Frame", {
			BackgroundColor3 = Colorpicker.Value,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		})

		local DialogDisplayFrameChecker = New("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=14204231522",
			ImageTransparency = 0.45,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(40, 40),
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(20, 220),
			Size = UDim2.fromOffset(88, 24),
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			New("UIStroke", {
				Thickness = 2,
				Transparency = 0.75,
			}),
			DialogDisplayFrame,
		})

		local SequenceTable = {}

		for Color = 0, 1, 0.1 do
			table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
		end

		local HueSliderGradient = New("UIGradient", {
			Color = ColorSequence.new(SequenceTable),
			Rotation = 90,
		})

		local HueDragHolder = New("Frame", {
			Size = UDim2.new(1, 0, 1, -10),
			Position = UDim2.fromOffset(0, 5),
			BackgroundTransparency = 1,
		})

		local HueDrag = New("ImageLabel", {
			Size = UDim2.fromOffset(14, 14),
			Image = "http://www.roblox.com/asset/?id=12266946128",
			Parent = HueDragHolder,
			ThemeTag = {
				ImageColor3 = "DialogInput",
			},
		})

		local HueSlider = New("Frame", {
			Size = UDim2.fromOffset(12, 190),
			Position = UDim2.fromOffset(210, 55),
			Parent = Dialog.Root,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			HueSliderGradient,
			HueDragHolder,
		})

		local HexInput = CreateInput()
		HexInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 55)
		CreateInputLabel("Hex", UDim2.fromOffset(Config.Transparency and 360 or 340, 55))

		local RedInput = CreateInput()
		RedInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 95)
		CreateInputLabel("Red", UDim2.fromOffset(Config.Transparency and 360 or 340, 95))

		local GreenInput = CreateInput()
		GreenInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 135)
		CreateInputLabel("Green", UDim2.fromOffset(Config.Transparency and 360 or 340, 135))

		local BlueInput = CreateInput()
		BlueInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 175)
		CreateInputLabel("Blue", UDim2.fromOffset(Config.Transparency and 360 or 340, 175))

		local AlphaInput
		if Config.Transparency then
			AlphaInput = CreateInput()
			AlphaInput.Frame.Position = UDim2.fromOffset(260, 215)
			CreateInputLabel("Alpha", UDim2.fromOffset(360, 215))
		end

		local TransparencySlider, TransparencyDrag, TransparencyColor
		if Config.Transparency then
			local TransparencyDragHolder = New("Frame", {
				Size = UDim2.new(1, 0, 1, -10),
				Position = UDim2.fromOffset(0, 5),
				BackgroundTransparency = 1,
			})

			TransparencyDrag = New("ImageLabel", {
				Size = UDim2.fromOffset(14, 14),
				Image = "http://www.roblox.com/asset/?id=12266946128",
				Parent = TransparencyDragHolder,
				ThemeTag = {
					ImageColor3 = "DialogInput",
				},
			})

			TransparencyColor = New("Frame", {
				Size = UDim2.fromScale(1, 1),
			}, {
				New("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
					Rotation = 270,
				}),
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			})

			TransparencySlider = New("Frame", {
				Size = UDim2.fromOffset(12, 190),
				Position = UDim2.fromOffset(230, 55),
				Parent = Dialog.Root,
				BackgroundTransparency = 1,
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				New("ImageLabel", {
					Image = "http://www.roblox.com/asset/?id=14204231522",
					ImageTransparency = 0.45,
					ScaleType = Enum.ScaleType.Tile,
					TileSize = UDim2.fromOffset(40, 40),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Parent = Dialog.Root,
				}, {
					New("UICorner", {
						CornerRadius = UDim.new(1, 0),
					}),
				}),
				TransparencyColor,
				TransparencyDragHolder,
			})
		end

		local function Display()
			SatVibMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			HueDrag.Position = UDim2.new(0, -1, Hue, -6)
			SatCursor.Position = UDim2.new(Sat, 0, 1 - Vib, 0)
			DialogDisplayFrame.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)

			HexInput.Input.Text = "#" .. Color3.fromHSV(Hue, Sat, Vib):ToHex()
			RedInput.Input.Text = GetRGB()["R"]
			GreenInput.Input.Text = GetRGB()["G"]
			BlueInput.Input.Text = GetRGB()["B"]

			if Config.Transparency then
				TransparencyColor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
				DialogDisplayFrame.BackgroundTransparency = Transparency
				TransparencyDrag.Position = UDim2.new(0, -1, 1 - Transparency, -6)
				AlphaInput.Input.Text = require(Root):Round((1 - Transparency) * 100, 0) .. "%"
			end
		end

		Creator.AddSignal(HexInput.Input.FocusLost, function(Enter)
			if Enter then
				local Success, Result = pcall(Color3.fromHex, HexInput.Input.Text)
				if Success and typeof(Result) == "Color3" then
					Hue, Sat, Vib = Color3.toHSV(Result)
				end
			end
			Display()
		end)

		Creator.AddSignal(RedInput.Input.FocusLost, function(Enter)
			if Enter then
				local CurrentColor = GetRGB()
				local Success, Result = pcall(Color3.fromRGB, RedInput.Input.Text, CurrentColor["G"], CurrentColor["B"])
				if Success and typeof(Result) == "Color3" then
					if tonumber(RedInput.Input.Text) <= 255 then
						Hue, Sat, Vib = Color3.toHSV(Result)
					end
				end
			end
			Display()
		end)

		Creator.AddSignal(GreenInput.Input.FocusLost, function(Enter)
			if Enter then
				local CurrentColor = GetRGB()
				local Success, Result =
					pcall(Color3.fromRGB, CurrentColor["R"], GreenInput.Input.Text, CurrentColor["B"])
				if Success and typeof(Result) == "Color3" then
					if tonumber(GreenInput.Input.Text) <= 255 then
						Hue, Sat, Vib = Color3.toHSV(Result)
					end
				end
			end
			Display()
		end)

		Creator.AddSignal(BlueInput.Input.FocusLost, function(Enter)
			if Enter then
				local CurrentColor = GetRGB()
				local Success, Result =
					pcall(Color3.fromRGB, CurrentColor["R"], CurrentColor["G"], BlueInput.Input.Text)
				if Success and typeof(Result) == "Color3" then
					if tonumber(BlueInput.Input.Text) <= 255 then
						Hue, Sat, Vib = Color3.toHSV(Result)
					end
				end
			end
			Display()
		end)

		if Config.Transparency then
			Creator.AddSignal(AlphaInput.Input.FocusLost, function(Enter)
				if Enter then
					pcall(function()
						local Value = tonumber(AlphaInput.Input.Text)
						if Value >= 0 and Value <= 100 then
							Transparency = 1 - Value * 0.01
						end
					end)
				end
				Display()
			end)
		end

		Creator.AddSignal(SatVibMap.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinX = SatVibMap.AbsolutePosition.X
					local MaxX = MinX + SatVibMap.AbsoluteSize.X
					local MouseX = math.clamp(Mouse.X, MinX, MaxX)

					local MinY = SatVibMap.AbsolutePosition.Y
					local MaxY = MinY + SatVibMap.AbsoluteSize.Y
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

					Sat = (MouseX - MinX) / (MaxX - MinX)
					Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))
					Display()

					RenderStepped:Wait()
				end
			end
		end)

		Creator.AddSignal(HueSlider.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
					local MinY = HueSlider.AbsolutePosition.Y
					local MaxY = MinY + HueSlider.AbsoluteSize.Y
					local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

					Hue = ((MouseY - MinY) / (MaxY - MinY))
					Display()

					RenderStepped:Wait()
				end
			end
		end)

		if Config.Transparency then
			Creator.AddSignal(TransparencySlider.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						local MinY = TransparencySlider.AbsolutePosition.Y
						local MaxY = MinY + TransparencySlider.AbsoluteSize.Y
						local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

						Transparency = 1 - ((MouseY - MinY) / (MaxY - MinY))
						Display()

						RenderStepped:Wait()
					end
				end
			end)
		end

		Display()

		Dialog:Button("Done", function()
			Colorpicker:SetValue({ Hue, Sat, Vib }, Transparency)
		end)
		Dialog:Button("Cancel")
		Dialog:Open()
	end

	function Colorpicker:Display()
		Colorpicker.Value = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)

		DisplayFrameColor.BackgroundColor3 = Colorpicker.Value
		DisplayFrameColor.BackgroundTransparency = Colorpicker.Transparency

		Element.Library:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
		Element.Library:SafeCallback(Colorpicker.Changed, Colorpicker.Value)
	end

	function Colorpicker:SetValue(HSV, Transparency)
		local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

		Colorpicker.Transparency = Transparency or 0
		Colorpicker:SetHSVFromRGB(Color)
		Colorpicker:Display()
	end

	function Colorpicker:SetValueRGB(Color, Transparency)
		Colorpicker.Transparency = Transparency or 0
		Colorpicker:SetHSVFromRGB(Color)
		Colorpicker:Display()
	end

	function Colorpicker:OnChanged(Func)
		Colorpicker.Changed = Func
		Func(Colorpicker.Value)
	end

	function Colorpicker:Destroy()
		ColorpickerFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(ColorpickerFrame.Frame.MouseButton1Click, function()
		CreateColorDialog()
	end)

	Colorpicker:Display()

	Library.Options[Idx] = Colorpicker
	return Colorpicker
end

return Element
]]

    -- 在模拟环境中执行代码
    local func, err = loadstring(originalCode)
    if not func then
        warn("Failed to load colorpicker:", err)
        return nil
    end
    
    setfenv(func, mockEnv)
    local success, element = pcall(func)
    
    if success and element then
        return element
    else
        warn("Failed to initialize colorpicker:", element)
        return nil
    end
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
        local r = math.sin(hue * 6 + 0) * 0.5 + 0.5
        local g = math.sin(hue * 6 + 2) * 0.5 + 0.5
        local b = math.sin(hue * 6 + 4) * 0.5 + 0.5
        object[property] = Color3.new(r, g, b)
    end)
    return connection
end

local function createSpaceBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "SpaceBackground"
    background.BackgroundColor3 = config.DeepSpaceColor
    background.BackgroundTransparency = 0
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.ZIndex = -100
    
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 10)
    backgroundCorner.Parent = background
    
    background.Parent = parent
    
    local gradient1 = Instance.new("UIGradient")
    gradient1.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.DeepSpaceColor),
        ColorSequenceKeypoint.new(0.3, config.NebulaColor1),
        ColorSequenceKeypoint.new(0.7, config.NebulaColor2),
        ColorSequenceKeypoint.new(1, config.DeepSpaceColor)
    })
    gradient1.Rotation = 45
    gradient1.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    gradient1.Parent = background
    
    local gradient2 = Instance.new("UIGradient")
    gradient2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 50, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 80, 150))
    })
    gradient2.Rotation = 135
    gradient2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    gradient2.Parent = background
    
    return background
end

local function createPulseGlow(object)
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        if not object or not object.Parent then
            pulseConnection:Disconnect()
            return
        end
        
        local alpha = 0.5 + math.sin(tick() * 3) * 0.3
        if object:IsA("UIStroke") then
            object.Transparency = alpha
        elseif object:IsA("Frame") or object:IsA("TextButton") then
            object.BackgroundTransparency = alpha
        end
    end)
    return pulseConnection
end

local function createHologramEffect(frame, intensity)
    intensity = intensity or 1
    
    local hologram = Instance.new("Frame")
    hologram.Name = "HologramEffect"
    hologram.BackgroundTransparency = 1
    hologram.Size = UDim2.new(1, 0, 1, 0)
    hologram.ZIndex = frame.ZIndex - 1
    hologram.Parent = frame
    hologram.ClipsDescendants = true
    
    local scanLines = Instance.new("Frame")
    scanLines.Name = "ScanLines"
    scanLines.BackgroundTransparency = 1
    scanLines.Size = UDim2.new(1, 0, 1, 0)
    scanLines.Parent = hologram
    
    local linePattern = Instance.new("UIGradient")
    linePattern.Rotation = 0
    linePattern.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.1, 0.7),
        NumberSequenceKeypoint.new(0.2, 0.9),
        NumberSequenceKeypoint.new(1, 0.9)
    })
    linePattern.Parent = scanLines
    
    local glow = Instance.new("UIGradient")
    glow.Rotation = 45
    glow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.3, 0.3 * intensity),
        NumberSequenceKeypoint.new(0.7, 0.3 * intensity),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    
    local colors = {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
    }
    glow.Color = ColorSequence.new(colors)
    glow.Parent = hologram
    
    local scanConnection
    scanConnection = RunService.Heartbeat:Connect(function(delta)
        if not scanLines or not scanLines.Parent then
            scanConnection:Disconnect()
            return
        end
        linePattern.Offset = Vector2.new(0, (tick() * 0.5) % 1)
    end)
    
    local colorConnection
    colorConnection = RunService.Heartbeat:Connect(function(delta)
        if not hologram or not hologram.Parent then
            colorConnection:Disconnect()
            return
        end
        
        local time = tick()
        for i, keypoint in ipairs(colors) do
            local hue = (time * 0.2 + i * 0.3) % 1
            colors[i] = ColorSequenceKeypoint.new(
                keypoint.Time,
                Color3.fromHSV(hue, 0.8, 1)
            )
        end
        glow.Color = ColorSequence.new(colors)
    end)
    
    return hologram
end

local function create3DFlipAnimation(object, duration)
    duration = duration or 0.5
    
    services.TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = 15
    }):Play()
    
    task.wait(duration/2)
    
    services.TweenService:Create(object, TweenInfo.new(duration/2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Rotation = 0
    }):Play()
end

local function createParticleTrail(startPos, endPos, parent)
    local trail = Instance.new("Frame")
    trail.Name = "ParticleTrail"
    trail.BackgroundColor3 = Color3.new(1, 1, 1)
    trail.BackgroundTransparency = 0.3
    trail.Size = UDim2.new(0, 4, 0, 4)
    trail.Position = startPos
    trail.Parent = parent
    trail.ZIndex = 10
    
    local trailCorner = Instance.new("UICorner")
    trailCorner.CornerRadius = UDim.new(1, 0)
    trailCorner.Parent = trail
    
    services.TweenService:Create(trail, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 2, 0, 2)
    }):Play()
    
    delay(0.3, function()
        trail:Destroy()
    end)
end

local function setupSmoothScrolling(scrollingFrame, layout)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        
        if layout.AbsoluteContentSize.Y <= scrollingFrame.AbsoluteSize.Y then
            scrollingFrame.ScrollingEnabled = false
        else
            scrollingFrame.ScrollingEnabled = true
        end
    end)
    
    scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
end

local switchingTabs = false
function switchTab(new)
    if switchingTabs then return end
    
    local old = FengUI.currentTab
    if old == nil then
        new[2].Visible = true
        FengUI.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { 
            ImageTransparency = 0,
            Size = UDim2.new(0, 25, 0, 25)
        }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.3), { 
            TextTransparency = 0,
            TextColor3 = config.AccentColor
        }):Play()
        return
    end
    
    if old[1] == new[1] then return end
    
    switchingTabs = true
    FengUI.currentTab = new
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    services.TweenService:Create(old[1], tweenInfo, { 
        ImageTransparency = 0.5,
        Size = UDim2.new(0, 22, 0, 22)
    }):Play()
    services.TweenService:Create(new[1], tweenInfo, { 
        ImageTransparency = 0,
        Size = UDim2.new(0, 25, 0, 25)
    }):Play()
    services.TweenService:Create(old[1].TabText, tweenInfo, { 
        TextTransparency = 0.5,
        TextColor3 = config.TextColor
    }):Play()
    services.TweenService:Create(new[1].TabText, tweenInfo, { 
        TextTransparency = 0,
        TextColor3 = config.AccentColor
        }):Play()
    
    old[2].Visible = false
    new[2].Visible = true
    
    task.wait(0.3)
    switchingTabs = false
end

for _, gui in ipairs(services.CoreGui:GetChildren()) do
    if gui.Name == "UniversalUI" and gui:IsA("ScreenGui") then
        gui:Destroy()
    end
end

local FengYu = Instance.new("ScreenGui")
FengYu.Name = "UniversalUI"
protectGUI(FengYu)
FengYu.Parent = services.CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = FengYu
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundTransparency = 1
Main.Position = UDim2.new(0.5, 0, 0.35, 0)
Main.Size = UDim2.new(0, 450, 0, 280)
Main.ZIndex = 1
Main.Active = true
Main.Draggable = true

createSpaceBackground(Main)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1
MainStroke.Transparency = 1

local neonStroke = Instance.new("UIStroke")
neonStroke.Parent = Main
neonStroke.Thickness = 2
neonStroke.Transparency = 1
neonStroke.LineJoinMode = Enum.LineJoinMode.Round
startNeonFlowEffect(neonStroke, "Color", 0.01)

createPulseGlow(neonStroke)

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = Main
TitleBar.BackgroundColor3 = config.TabColor
TitleBar.BackgroundTransparency = 1
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.ZIndex = 2

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 10)
TitleBarCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.BackgroundTransparency = 1
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Font = Enum.Font.GothamBold
TitleText.Text = "FengUI"
TitleText.TextColor3 = config.AccentColor
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.TextTransparency = 1

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -25, 0, 7)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.TextSize = 16
CloseButton.ZIndex = 10
CloseButton.TextTransparency = 1

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 18,
        Position = UDim2.new(1, -26, 0, 6)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        TextColor3 = Color3.fromRGB(255, 60, 60),
        TextSize = 16,
        Position = UDim2.new(1, -25, 0, 7)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    services.TweenService:Create(CloseButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(255, 30, 30),
        TextSize = 14,
        Position = UDim2.new(1, -24, 0, 8)
    }):Play()
    
    services.TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, 0, 0.3, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 10, 0, 10)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.4), {
        Transparency = 1
    }):Play()
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4), {
        TextTransparency = 1
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4), {
        TextTransparency = 1
    }):Play()
    
    task.wait(0.4)
    FengYu:Destroy()
end)

local Open = Instance.new("ImageButton")
Open.Name = "Open"
Open.Parent = FengYu
Open.BackgroundColor3 = config.AccentColor
Open.BackgroundTransparency = 0.85
Open.Position = UDim2.new(0.92, 0, 0.01, 0)
Open.Size = UDim2.new(0, 40, 0, 40)
Open.Active = true
Open.Draggable = true
Open.Image = "rbxassetid://84830962019412"
Open.ImageColor3 = Color3.fromRGB(255, 255, 255)
Open.ImageTransparency = 0.15

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 8)
OpenCorner.Parent = Open

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Parent = Open
OpenStroke.Color = Color3.fromRGB(180, 180, 180)
OpenStroke.Thickness = 1.2
OpenStroke.Transparency = 0.4

startNeonFlowEffect(Open, "BackgroundColor3", 0.012)
createPulseGlow(OpenStroke)

Open.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        playEntranceAnimation()
    end
    create3DFlipAnimation(Open, 0.5)
end)

services.UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
        if Main.Visible then
            playEntranceAnimation()
        end
        create3DFlipAnimation(Open, 0.5)
    end
end)

local TabMain = Instance.new("Frame")
TabMain.Name = "TabMain"
TabMain.Parent = Main
TabMain.BackgroundTransparency = 1
TabMain.Position = UDim2.new(0.2, 0, 0, 37)
TabMain.Size = UDim2.new(0, 360, 0, 243)
TabMain.Visible = false

local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Parent = Main
Side.BackgroundColor3 = config.TabColor
Side.BackgroundTransparency = 1
Side.BorderSizePixel = 0
Side.ClipsDescendants = true
Side.Position = UDim2.new(0, 0, 0, 35)
Side.Size = UDim2.new(0, 90, 0, 245)

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Side

local TabBtns = Instance.new("ScrollingFrame")
TabBtns.Name = "TabBtns"
TabBtns.Parent = Side
TabBtns.Active = true
TabBtns.BackgroundTransparency = 1
TabBtns.BorderSizePixel = 0
TabBtns.Position = UDim2.new(0, 0, 0, 5)
TabBtns.Size = UDim2.new(0, 90, 0, 235)
TabBtns.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBtns.ScrollBarThickness = 3
TabBtns.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
TabBtns.ScrollBarImageTransparency = 0.5
TabBtns.VerticalScrollBarInset = Enum.ScrollBarInset.Always
TabBtns.ScrollingDirection = Enum.ScrollingDirection.Y
TabBtns.HorizontalScrollBarInset = Enum.ScrollBarInset.None
TabBtns.Visible = false

local TabBtnsL = Instance.new("UIListLayout")
TabBtnsL.Name = "TabBtnsL"
TabBtnsL.Parent = TabBtns
TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
TabBtnsL.Padding = UDim.new(0, 6)

TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabBtns.CanvasSize = UDim2.new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y)
    
    TabBtns.ScrollingEnabled = TabBtnsL.AbsoluteContentSize.Y > TabBtns.AbsoluteSize.Y
    TabBtns.ElasticBehavior = Enum.ElasticBehavior.Never
end)

local function playEntranceAnimation()
    Main.Position = UDim2.new(0.5, 0, 0.35, 0)
    Main.BackgroundTransparency = 1
    Main.Size = UDim2.new(0, 10, 0, 10)
    
    TitleBar.BackgroundTransparency = 1
    TitleText.TextTransparency = 1
    CloseButton.TextTransparency = 1
    Side.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    neonStroke.Transparency = 1
    
    TabMain.Visible = false
    TabBtns.Visible = false
    
    services.TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.4, 0),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 450, 0, 280)
    }):Play()
    
    services.TweenService:Create(MainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.5
    }):Play()
    
    services.TweenService:Create(neonStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.7
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(TitleBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    services.TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    services.TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()
    
    task.wait(0.2)
    
    services.TweenService:Create(Side, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.2)
    
    TabMain.Visible = true
    TabBtns.Visible = true
end

task.spawn(function()
    task.wait(0.5)
    playEntranceAnimation()
end)

task.spawn(function()
    local hue = 0
    local matrixEffect = Instance.new("UIGradient")
    matrixEffect.Rotation = 90
    matrixEffect.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })
    matrixEffect.Parent = TitleText
    
    while TitleText and TitleText.Parent do
        hue = (hue + 0.03) % 1
        
        TitleText.TextColor3 = Color3.fromHSV(hue, 1, 1)
        
        matrixEffect.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV((hue + 0.2) % 1, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue - 0.2) % 1, 1, 1))
        })
        
        services.TweenService:Create(TitleText, TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 15 + math.sin(tick() * 3) * 2
        }):Play()
        
        task.wait(0.05)
    end
end)

function FengUI.new(FengUI, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "REN" then
            v:Destroy()
        end
    end

    if theme then
        for k, v in pairs(theme) do
            if config[k] ~= nil then
                config[k] = v
            end
        end
    end

    local scriptName = name or "FengUI"
    TitleText.Text = scriptName
    
    local window = {}
    
    function window.Tab(window, name, icon, windowCount)
        local windowCount = windowCount or 1
        
        local Tab = Instance.new("ScrollingFrame")
        local TabIco = Instance.new("ImageLabel")
        local TabText = Instance.new("TextLabel")
        local TabBtn = Instance.new("TextButton")
        local TabL = Instance.new("UIListLayout")
        local TabContainer = Instance.new("Frame")
        
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundTransparency = 1
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 0  -- 移除主Tab滚动条
        Tab.Visible = false
        Tab.ElasticBehavior = Enum.ElasticBehavior.Never
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y
        Tab.HorizontalScrollBarInset = Enum.ScrollBarInset.None
        
        TabContainer.Name = "TabContainer"
        TabContainer.Parent = Tab
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        
        if windowCount == 2 then
            TabContainer.Size = UDim2.new(1, 0, 1, 0)
            
            local LeftContainer = Instance.new("ScrollingFrame")
            LeftContainer.Name = "LeftContainer"
            LeftContainer.Parent = TabContainer
            LeftContainer.BackgroundTransparency = 1
            LeftContainer.Size = UDim2.new(0.48, -2, 1, 0)
            LeftContainer.Position = UDim2.new(0, 2, 0, 0)
            LeftContainer.ScrollBarThickness = 0  -- 移除左容器滚动条
            LeftContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            LeftContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            LeftContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local LeftLayout = Instance.new("UIListLayout")
            LeftLayout.Name = "LeftLayout"
            LeftLayout.Parent = LeftContainer
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 4)
            
            local RightContainer = Instance.new("ScrollingFrame")
            RightContainer.Name = "RightContainer"
            RightContainer.Parent = TabContainer
            RightContainer.BackgroundTransparency = 1
            RightContainer.Size = UDim2.new(0.50, -2, 1, 0)
            RightContainer.Position = UDim2.new(0.48, 0, 0, 0)
            RightContainer.ScrollBarThickness = 0  -- 移除右容器滚动条
            RightContainer.ElasticBehavior = Enum.ElasticBehavior.Never
            RightContainer.ScrollingDirection = Enum.ScrollingDirection.Y
            RightContainer.HorizontalScrollBarInset = Enum.ScrollBarInset.None
            
            local RightLayout = Instance.new("UIListLayout")
            RightLayout.Name = "RightLayout"
            RightLayout.Parent = RightContainer
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 4)
            
            -- 修复双窗口滚动问题
            local function updateLeftScrolling()
                LeftContainer.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 10)
                LeftContainer.ScrollingEnabled = LeftLayout.AbsoluteContentSize.Y > LeftContainer.AbsoluteSize.Y
            end
            
            local function updateRightScrolling()
                RightContainer.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 10)
                RightContainer.ScrollingEnabled = RightLayout.AbsoluteContentSize.Y > RightContainer.AbsoluteSize.Y
            end
            
            LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftScrolling)
            RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightScrolling)
            
            -- 初始化滚动设置
            task.spawn(function()
                task.wait(0.1)
                updateLeftScrolling()
                updateRightScrolling()
            end)
        end
        
        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2.new(0, 22, 0, 22)
        TabIco.Image = "rbxassetid://84830962019412"
        TabIco.ImageTransparency = 0.5
        
        startNeonFlowEffect(TabIco, "ImageColor3", 0.005)
        
        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(1.2, 0, 0, 0)
        TabText.Size = UDim2.new(0, 65, 0, 22)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = config.TextColor
        TabText.TextSize = 14
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.5
        
        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 90, 0, 22)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        
        TabL.Name = "TabL"
        TabL.Parent = TabContainer
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)
        
        if windowCount == 2 then
            TabL:Destroy()
            Tab.ScrollingEnabled = false
            Tab.CanvasSize = UDim2.new(0, 0, 1, 0)
            Tab.ScrollBarThickness = 0  -- 确保主Tab也没有滚动条
        else
            Tab.ScrollBarThickness = 0  -- 单窗口模式也移除滚动条
            setupSmoothScrolling(Tab, TabL)
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            switchTab({ TabIco, Tab })
        end)
        
        if FengUI.currentTab == nil then
            switchTab({ TabIco, Tab })
        end
        
        local tab = {}
        
        function tab.section(tab, name, windowPosition, TabVal)
            if type(windowPosition) == "boolean" then
                TabVal = windowPosition
                windowPosition = "Left"
            elseif not windowPosition or type(windowPosition) ~= "string" then
                windowPosition = "Left"
            end
            
            local TargetContainer
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    TargetContainer = TabContainer:FindFirstChild("LeftContainer")
                else
                    TargetContainer = TabContainer:FindFirstChild("RightContainer")
                end
            else
                TargetContainer = TabContainer
            end
            
            if not TargetContainer then
                TargetContainer = TabContainer
            end
            
            local Section = Instance.new("Frame")
            local SectionText = Instance.new("TextLabel")
            local SectionOpen = Instance.new("ImageLabel")
            local SectionOpened = Instance.new("ImageLabel")
            local SectionToggle = Instance.new("ImageButton")
            local Objs = Instance.new("Frame")
            local ObjsL = Instance.new("UIListLayout")
            
            Section.Name = "Section"
            Section.Parent = TargetContainer
            Section.BackgroundTransparency = 1
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            
            local elementWidth = 330
            if windowCount == 2 then
                if windowPosition:lower() == "left" then
                    elementWidth = 160
                else
                    elementWidth = 168
                end
            end
            
            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundTransparency = 1
            SectionText.Position = UDim2.new(0, 35, 0, 0)
            SectionText.Size = UDim2.new(1, -35, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = config.AccentColor
            SectionText.TextSize = 16
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            
            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = Section
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2.new(0, 5, 0, 5)
            SectionOpen.Size = UDim2.new(0, 22, 0, 22)
            SectionOpen.Image = "rbxassetid://84830962019412"
            SectionOpen.ImageColor3 = config.SecondaryTextColor
            
            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2.new(1, 0, 1, 0)
            SectionOpened.Image = "rbxassetid://84830962019412"
            SectionOpened.ImageColor3 = config.AccentColor
            SectionOpened.ImageTransparency = 1
            
            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2.new(1, 0, 1, 0)
            
            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2.new(0, 0, 0, 36)
            Objs.Size = UDim2.new(1, 0, 0, 0)
            
            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)
            
            local open = true
            if TabVal ~= nil then
                if type(TabVal) == "boolean" then
                    open = TabVal
                elseif TabVal == "false" or TabVal == "0" then
                    open = false
                elseif TabVal == "true" or TabVal == "1" then
                    open = true
                end
            end
            
            local function updateSectionHeight()
                Section.Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
            end
            
            updateSectionHeight()
            SectionOpened.ImageTransparency = open and 0 or 1
            SectionOpen.ImageTransparency = open and 1 or 0
            
            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                services.TweenService:Create(Section, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, open and (36 + ObjsL.AbsoluteContentSize.Y + 8) or 36)
                }):Play()
                
                services.TweenService:Create(SectionOpened, TweenInfo.new(0.3), {
                    ImageTransparency = open and 0 or 1
                }):Play()
                
                services.TweenService:Create(SectionOpen, TweenInfo.new(0.3), {
                    ImageTransparency = open and 1 or 0
                }):Play()
            end)
            
            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    updateSectionHeight()
                end
            end)
            
            local section = {}
            
            function section.Button(section, text, callback)
                callback = callback or function() end
                
                local BtnModule = Instance.new("Frame")
                local Btn = Instance.new("TextButton")
                local BtnC = Instance.new("UICorner")
                
                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1
                BtnModule.BorderSizePixel = 0
                BtnModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = config.Button_Color
                Btn.BackgroundTransparency = 0.2
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2.new(0, elementWidth, 0, 36)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = config.TextColor
                Btn.TextSize = 14
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                
                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn
                
                local btnGlow = Instance.new("UIStroke")
                btnGlow.Parent = Btn
                btnGlow.Color = config.AccentColor
                btnGlow.Thickness = 1
                btnGlow.Transparency = 0.8
                
                startNeonFlowEffect(btnGlow, "Color", 0.01)
                createPulseGlow(btnGlow)
                
                Btn.MouseEnter:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 1.1),
                            math.floor(config.Button_Color.G * 255 * 1.1),
                            math.floor(config.Button_Color.B * 255 * 1.1)
                        )
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.5
                    }):Play()
                end)
                
                Btn.MouseLeave:Connect(function()
                    services.TweenService:Create(Btn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    callback()
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Button_Color.R * 255 * 0.8),
                            math.floor(config.Button_Color.G * 255 * 0.8),
                            math.floor(config.Button_Color.B * 255 * 0.8)
                        )
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.1), {
                        Thickness = 3,
                        Transparency = 0.3
                    }):Play()
                    
                    task.wait(0.1)
                    
                    services.TweenService:Create(Btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = config.Button_Color
                    }):Play()
                    services.TweenService:Create(btnGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)
            end
            
                                    function section.Image(section, imageSource, sizeX, sizeY)
                local ImageModule = Instance.new("Frame")
                local ImageLabel = Instance.new("ImageLabel")
                local ImageCorner = Instance.new("UICorner")
                
                ImageModule.Name = "ImageModule"
                ImageModule.Parent = Objs
                ImageModule.BackgroundTransparency = 1
                ImageModule.BorderSizePixel = 0
                ImageModule.Size = UDim2.new(0, elementWidth, 0, sizeY or 120)
                
                ImageLabel.Name = "ImageLabel"
                ImageLabel.Parent = ImageModule
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.BorderSizePixel = 0
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0)
                ImageLabel.Position = UDim2.new(0.5, 0, 0, 0)
                ImageLabel.Size = UDim2.new(0, math.min(sizeX or elementWidth - 20, elementWidth), 0, sizeY or 120)
                ImageLabel.ScaleType = Enum.ScaleType.Crop
                
                ImageCorner.CornerRadius = UDim.new(0, 6)
                ImageCorner.Parent = ImageLabel
                
                local imageGlow = Instance.new("UIStroke")
                imageGlow.Parent = ImageLabel
                imageGlow.Color = config.AccentColor
                imageGlow.Thickness = 1
                imageGlow.Transparency = 0.8
                
                local function setImage(source)
                    if type(source) == "table" then
                        if source.Type == "Player" then
                            local userId = source.UserId
                            if userId then
                                task.spawn(function()
                                    local success, result = pcall(function()
                                        return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                                    end)
                                    
                                    if success and result then
                                        ImageLabel.Image = result
                                    else
                                        ImageLabel.Image = "rbxassetid://0"
                                    end
                                end)
                            end
                        elseif source.Type == "Game" then
                            local placeId = source.PlaceId
                            if placeId then
                                task.spawn(function()
                                    local success1, gameInfo = pcall(function()
                                        local MarketplaceService = game:GetService("MarketplaceService")
                                        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
                                    end)
                                    
                                    if success1 and gameInfo and gameInfo.IconImageAssetId then
                                        ImageLabel.Image = "rbxassetid://" .. gameInfo.IconImageAssetId
                                        return
                                    end
                                    
                                    local success2, thumbnailUrl = pcall(function()
                                        local ThumbnailService = game:GetService("ThumbnailService")
                                        return ThumbnailService:GetGameThumbnailAsync(placeId)
                                    end)
                                    
                                    if success2 and thumbnailUrl then
                                        ImageLabel.Image = thumbnailUrl
                                        return
                                    end
                                    
                                    ImageLabel.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. placeId
                                end)
                            end
                        end
                    else
                        local imageId = tostring(source)
                        if imageId:match("^%d+$") then
                            ImageLabel.Image = "rbxassetid://" .. imageId
                        else
                            ImageLabel.Image = imageId
                        end
                    end
                end
                
                if imageSource then
                    setImage(imageSource)
                end
                
                local imageController = {}
                
                function imageController:SetImage(newSource)
                    setImage(newSource)
                end
                
                function imageController:SetPlayerAvatar(userId)
                    setImage({Type = "Player", UserId = userId})
                end
                
                function imageController:SetGameIcon(placeId)
                    setImage({Type = "Game", PlaceId = placeId})
                end
                
                function imageController:SetLocalPlayerAvatar()
                    local localPlayer = game.Players.LocalPlayer
                    if localPlayer then
                        setImage({Type = "Player", UserId = localPlayer.UserId})
                    end
                end
                
                function imageController:Destroy()
                    ImageModule:Destroy()
                end
                
                imageController.Instance = ImageLabel
                imageController.Module = ImageModule
                
                return imageController
            end
            
            function section:Label(text)
                local LabelModule = Instance.new("Frame")
                local TextLabel = Instance.new("TextLabel")
                local LabelC = Instance.new("UICorner")
                
                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundTransparency = 1
                LabelModule.BorderSizePixel = 0
                LabelModule.Size = UDim2.new(0, elementWidth, 0, 24)
                
                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = config.Label_Color
                TextLabel.BackgroundTransparency = 0.2
                TextLabel.Size = UDim2.new(0, elementWidth, 0, 28)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = config.SecondaryTextColor
                TextLabel.TextSize = 14
                
                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                
                return TextLabel
            end

            -- 颜色选择器组件
            function section.Colorpicker(section, text, flag, default, options, callback)
                callback = callback or function() end
                default = default or Color3.fromRGB(255, 255, 255)
                options = options or {}
                
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                FengUI.flags[flag] = default
                
                -- 加载原始颜色选择器
                local OriginalColorpicker = loadOriginalColorpicker()
                if not OriginalColorpicker then
                    -- 如果加载失败，使用简单的颜色选择器作为后备
                    return section:SimpleColorpicker(text, flag, default, callback)
                end
                
                local ColorpickerModule = Instance.new("Frame")
                local ColorpickerBtn = Instance.new("TextButton")
                local ColorpickerBtnC = Instance.new("UICorner")
                
                ColorpickerModule.Name = "ColorpickerModule"
                ColorpickerModule.Parent = Objs
                ColorpickerModule.BackgroundTransparency = 1
                ColorpickerModule.BorderSizePixel = 0
                ColorpickerModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                ColorpickerBtn.Name = "ColorpickerBtn"
                ColorpickerBtn.Parent = ColorpickerModule
                ColorpickerBtn.BackgroundColor3 = config.ElementColor
                ColorpickerBtn.BackgroundTransparency = 0.2
                ColorpickerBtn.BorderSizePixel = 0
                ColorpickerBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                ColorpickerBtn.AutoButtonColor = false
                ColorpickerBtn.Font = Enum.Font.GothamSemibold
                ColorpickerBtn.Text = "   " .. text
                ColorpickerBtn.TextColor3 = config.TextColor
                ColorpickerBtn.TextSize = 14
                ColorpickerBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ColorpickerBtnC.CornerRadius = UDim.new(0, 6)
                ColorpickerBtnC.Name = "ColorpickerBtnC"
                ColorpickerBtnC.Parent = ColorpickerBtn
                
                local colorpickerPosition = 0.85
                if windowCount == 2 then
                    colorpickerPosition = 0.78
                end
                
                -- 创建颜色显示区域（保持原样）
                local DisplayFrameChecker = Instance.new("ImageLabel")
                DisplayFrameChecker.Name = "DisplayFrameChecker"
                DisplayFrameChecker.Parent = ColorpickerBtn
                DisplayFrameChecker.Image = "http://www.roblox.com/asset/?id=14204231522"
                DisplayFrameChecker.ImageTransparency = 0.45
                DisplayFrameChecker.ScaleType = Enum.ScaleType.Tile
                DisplayFrameChecker.TileSize = UDim2.fromOffset(40, 40)
                DisplayFrameChecker.BackgroundTransparency = 1
                DisplayFrameChecker.Position = UDim2.new(colorpickerPosition, 0, 0.22, 0)
                DisplayFrameChecker.Size = UDim2.new(0, 34, 0, 18)
                
                local DisplayFrameCheckerC = Instance.new("UICorner")
                DisplayFrameCheckerC.CornerRadius = UDim.new(0, 6)
                DisplayFrameCheckerC.Name = "DisplayFrameCheckerC"
                DisplayFrameCheckerC.Parent = DisplayFrameChecker
                
                local DisplayFrameColor = Instance.new("Frame")
                DisplayFrameColor.Name = "DisplayFrameColor"
                DisplayFrameColor.Parent = DisplayFrameChecker
                DisplayFrameColor.BackgroundColor3 = default
                DisplayFrameColor.Size = UDim2.fromScale(1, 1)
                DisplayFrameColor.BackgroundTransparency = options.Transparency or 0
                
                local DisplayFrameColorC = Instance.new("UICorner")
                DisplayFrameColorC.CornerRadius = UDim.new(0, 6)
                DisplayFrameColorC.Name = "DisplayFrameColorC"
                DisplayFrameColorC.Parent = DisplayFrameColor
                
                -- 添加FengUI风格的发光效果
                local colorGlow = Instance.new("UIStroke")
                colorGlow.Parent = DisplayFrameChecker
                colorGlow.Color = config.AccentColor
                colorGlow.Thickness = 1
                colorGlow.Transparency = 0.8
                
                startNeonFlowEffect(colorGlow, "Color", 0.01)
                createPulseGlow(colorGlow)
                
                -- FengUI风格的鼠标悬停效果
                ColorpickerBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ColorpickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.ElementColor.R * 255 * 1.1),
                            math.floor(config.ElementColor.G * 255 * 1.1),
                            math.floor(config.ElementColor.B * 255 * 1.1)
                        )
                    }):Play()
                    services.TweenService:Create(colorGlow, TweenInfo.new(0.2), {
                        Thickness = 2,
                        Transparency = 0.5
                    }):Play()
                end)
                
                ColorpickerBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ColorpickerBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.ElementColor
                    }):Play()
                    services.TweenService:Create(colorGlow, TweenInfo.new(0.2), {
                        Thickness = 1,
                        Transparency = 0.8
                    }):Play()
                end)
                
                -- 初始化原始颜色选择器
                local colorpickerInstance = nil
                
                local function initializeOriginalColorpicker()
                    if not OriginalColorpicker then return end
                    
                    -- 创建适配器配置
                    local config = {
                        Title = text,
                        Default = default,
                        Callback = function(color)
                            FengUI.flags[flag] = color
                            DisplayFrameColor.BackgroundColor3 = color
                            callback(color)
                        end,
                        Transparency = options.Transparency,
                        Description = options.Description
                    }
                    
                    -- 创建模拟的Library和Container
                    local mockLibrary = {
                        Options = {},
                        SafeCallback = function(self, func, ...)
                            if func then
                                pcall(func, ...)
                            end
                        end
                    }
                    
                    local mockContainer = ColorpickerModule
                    
                    -- 创建颜色选择器实例
                    local mockElement = {
                        Library = mockLibrary,
                        Container = mockContainer
                    }
                    
                    setmetatable(mockElement, OriginalColorpicker)
                    
                    colorpickerInstance = OriginalColorpicker.New(mockElement, 1, config)
                    
                    if colorpickerInstance then
                        -- 重写显示函数以更新FengUI的显示
                        local originalDisplay = colorpickerInstance.Display
                        colorpickerInstance.Display = function(self)
                            if originalDisplay then
                                originalDisplay(self)
                            end
                            DisplayFrameColor.BackgroundColor3 = self.Value
                            DisplayFrameColor.BackgroundTransparency = self.Transparency or 0
                        end
                        
                        -- 应用初始颜色
                        colorpickerInstance:SetValueRGB(default, options.Transparency)
                    end
                end
                
                -- 点击打开颜色选择器
                local function openColorPicker()
                    if colorpickerInstance then
                        -- 调用原始颜色选择器的打开方法
                        pcall(function()
                            -- 查找并点击颜色选择器框架
                            for _, child in pairs(ColorpickerModule:GetDescendants()) do
                                if child:IsA("Frame") and child.Name == "Frame" then
                                    child:Fire("MouseButton1Click")
                                    break
                                end
                            end
                        end)
                    else
                        -- 初始化并打开
                        initializeOriginalColorpicker()
                        openColorPicker()
                    end
                end
                
                ColorpickerBtn.MouseButton1Click:Connect(openColorPicker)
                DisplayFrameChecker.MouseButton1Click:Connect(openColorPicker)
                
                -- 添加3D翻转动画
                DisplayFrameChecker.MouseButton1Click:Connect(function()
                    create3DFlipAnimation(DisplayFrameChecker, 0.3)
                end)
                
                local funcs = {}
                
                function funcs:SetColor(color, transparency)
                    if typeof(color) == "Color3" then
                        FengUI.flags[flag] = color
                        DisplayFrameColor.BackgroundColor3 = color
                        
                        if transparency then
                            DisplayFrameColor.BackgroundTransparency = transparency
                            options.Transparency = transparency
                        end
                        
                        if colorpickerInstance then
                            if transparency then
                                colorpickerInstance:SetValueRGB(color, transparency)
                            else
                                colorpickerInstance:SetValueRGB(color)
                            end
                        end
                        
                        callback(color, transparency)
                    end
                end
                
                function funcs:GetColor()
                    return FengUI.flags[flag]
                end
                
                function funcs:GetTransparency()
                    return options.Transparency or 0
                end
                
                function funcs:SetTransparency(transparency)
                    if transparency and transparency >= 0 and transparency <= 1 then
                        options.Transparency = transparency
                        DisplayFrameColor.BackgroundTransparency = transparency
                        
                        if colorpickerInstance then
                            colorpickerInstance.Transparency = transparency
                            colorpickerInstance:Display()
                        end
                    end
                end
                
                function funcs:SetHSV(h, s, v, transparency)
                    if h and s and v then
                        local color = Color3.fromHSV(h, s, v)
                        self:SetColor(color, transparency)
                    end
                end
                
                function funcs:GetHSV()
                    local color = FengUI.flags[flag]
                    if color and typeof(color) == "Color3" then
                        return Color3.toHSV(color)
                    end
                    return 0, 0, 1
                end
                
                function funcs:Destroy()
                    if colorpickerInstance then
                        colorpickerInstance:Destroy()
                    end
                    ColorpickerModule:Destroy()
                end
                
                -- 初始化颜色选择器（延迟初始化）
                task.spawn(function()
                    task.wait(0.5)
                    initializeOriginalColorpicker()
                end)
                
                return funcs
            end
            
            -- 简单的后备颜色选择器（如果原始加载失败）
            function section.SimpleColorpicker(section, text, flag, default, callback)
                callback = callback or function() end
                default = default or Color3.fromRGB(255, 255, 255)
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                
                FengUI.flags[flag] = default
                
                local ColorpickerModule = Instance.new("Frame")
                local ColorpickerBtn = Instance.new("TextButton")
                local ColorpickerBtnC = Instance.new("UICorner")
                
                ColorpickerModule.Name = "ColorpickerModule"
                ColorpickerModule.Parent = Objs
                ColorpickerModule.BackgroundTransparency = 1
                ColorpickerModule.BorderSizePixel = 0
                ColorpickerModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                ColorpickerBtn.Name = "ColorpickerBtn"
                ColorpickerBtn.Parent = ColorpickerModule
                ColorpickerBtn.BackgroundColor3 = config.ElementColor
                ColorpickerBtn.BackgroundTransparency = 0.2
                ColorpickerBtn.BorderSizePixel = 0
                ColorpickerBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                ColorpickerBtn.AutoButtonColor = false
                ColorpickerBtn.Font = Enum.Font.GothamSemibold
                ColorpickerBtn.Text = "   " .. text
                ColorpickerBtn.TextColor3 = config.TextColor
                ColorpickerBtn.TextSize = 14
                ColorpickerBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ColorpickerBtnC.CornerRadius = UDim.new(0, 6)
                ColorpickerBtnC.Name = "ColorpickerBtnC"
                ColorpickerBtnC.Parent = ColorpickerBtn
                
                local colorpickerPosition = 0.85
                if windowCount == 2 then
                    colorpickerPosition = 0.78
                end
                
                local ColorDisplay = Instance.new("Frame")
                ColorDisplay.Name = "ColorDisplay"
                ColorDisplay.Parent = ColorpickerBtn
                ColorDisplay.BackgroundColor3 = default
                ColorDisplay.BorderSizePixel = 0
                ColorDisplay.Position = UDim2.new(colorpickerPosition, 0, 0.22, 0)
                ColorDisplay.Size = UDim2.new(0, 34, 0, 18)
                
                local ColorDisplayC = Instance.new("UICorner")
                ColorDisplayC.CornerRadius = UDim.new(0, 6)
                ColorDisplayC.Parent = ColorDisplay
                
                local colorGlow = Instance.new("UIStroke")
                colorGlow.Parent = ColorDisplay
                colorGlow.Color = config.AccentColor
                colorGlow.Thickness = 1
                colorGlow.Transparency = 0.8
                
                startNeonFlowEffect(colorGlow, "Color", 0.01)
                createPulseGlow(colorGlow)
                
                -- 简单的颜色选择对话框
                local function openSimpleColorDialog()
                    local Dialog = Instance.new("Frame")
                    Dialog.Name = "ColorDialog"
                    Dialog.BackgroundColor3 = config.MainColor
                    Dialog.BackgroundTransparency = 0.1
                    Dialog.BorderSizePixel = 0
                    Dialog.Size = UDim2.new(0, 250, 0, 150)
                    Dialog.Position = UDim2.new(0.5, -125, 0.5, -75)
                    Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
                    Dialog.Parent = FengYu
                    Dialog.ZIndex = 100
                    
                    local DialogCorner = Instance.new("UICorner")
                    DialogCorner.CornerRadius = UDim.new(0, 12)
                    DialogCorner.Parent = Dialog
                    
                    local DialogStroke = Instance.new("UIStroke")
                    DialogStroke.Parent = Dialog
                    DialogStroke.Color = config.AccentColor
                    DialogStroke.Thickness = 2
                    DialogStroke.Transparency = 0.7
                    
                    local Title = Instance.new("TextLabel")
                    Title.Name = "Title"
                    Title.Parent = Dialog
                    Title.BackgroundTransparency = 1
                    Title.Size = UDim2.new(1, 0, 0, 30)
                    Title.Font = Enum.Font.GothamBold
                    Title.Text = "选择颜色"
                    Title.TextColor3 = config.AccentColor
                    Title.TextSize = 16
                    
                    local ColorPreview = Instance.new("Frame")
                    ColorPreview.Name = "ColorPreview"
                    ColorPreview.Parent = Dialog
                    ColorPreview.BackgroundColor3 = FengUI.flags[flag]
                    ColorPreview.Position = UDim2.new(0.5, -40, 0, 40)
                    ColorPreview.Size = UDim2.new(0, 80, 0, 40)
                    
                    local ColorPreviewCorner = Instance.new("UICorner")
                    ColorPreviewCorner.CornerRadius = UDim.new(0, 8)
                    ColorPreviewCorner.Parent = ColorPreview
                    
                    local HexInput = Instance.new("TextBox")
                    HexInput.Name = "HexInput"
                    HexInput.Parent = Dialog
                    HexInput.Position = UDim2.new(0.5, -80, 0, 90)
                    HexInput.Size = UDim2.new(0, 160, 0, 30)
                    HexInput.BackgroundColor3 = config.ElementColor
                    HexInput.BackgroundTransparency = 0.2
                    HexInput.TextColor3 = config.TextColor
                    HexInput.Text = "#" .. FengUI.flags[flag]:ToHex()
                    HexInput.Font = Enum.Font.Gotham
                    HexInput.TextSize = 14
                    HexInput.PlaceholderText = "输入Hex颜色"
                    
                    local HexInputCorner = Instance.new("UICorner")
                    HexInputCorner.CornerRadius = UDim.new(0, 6)
                    HexInputCorner.Parent = HexInput
                    
                    local ApplyButton = Instance.new("TextButton")
                    ApplyButton.Name = "ApplyButton"
                    ApplyButton.Parent = Dialog
                    ApplyButton.Position = UDim2.new(0.5, -50, 0, 130)
                    ApplyButton.Size = UDim2.new(0, 100, 0, 30)
                    ApplyButton.BackgroundColor3 = config.AccentColor
                    ApplyButton.BackgroundTransparency = 0.2
                    ApplyButton.Font = Enum.Font.GothamBold
                    ApplyButton.Text = "应用"
                    ApplyButton.TextColor3 = config.TextColor
                    ApplyButton.TextSize = 14
                    
                    local ApplyCorner = Instance.new("UICorner")
                    ApplyCorner.CornerRadius = UDim.new(0, 6)
                    ApplyCorner.Parent = ApplyButton
                    
                    HexInput.FocusLost:Connect(function()
                        local hexText = HexInput.Text:gsub("#", "")
                        local success, color = pcall(function()
                            return Color3.fromHex(hexText)
                        end)
                        
                        if success and color then
                            ColorPreview.BackgroundColor3 = color
                        end
                    end)
                    
                    ApplyButton.MouseButton1Click:Connect(function()
                        local hexText = HexInput.Text:gsub("#", "")
                        local success, color = pcall(function()
                            return Color3.fromHex(hexText)
                        end)
                        
                        if success and color then
                            FengUI.flags[flag] = color
                            ColorDisplay.BackgroundColor3 = color
                            callback(color)
                        end
                        
                        Dialog:Destroy()
                    end)
                    
                    -- 点击外部关闭
                    local BackgroundOverlay = Instance.new("TextButton")
                    BackgroundOverlay.Name = "BackgroundOverlay"
                    BackgroundOverlay.Parent = FengYu
                    BackgroundOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    BackgroundOverlay.BackgroundTransparency = 0.5
                    BackgroundOverlay.Size = UDim2.new(1, 0, 1, 0)
                    BackgroundOverlay.Text = ""
                    BackgroundOverlay.ZIndex = 99
                    
                    BackgroundOverlay.MouseButton1Click:Connect(function()
                        Dialog:Destroy()
                        BackgroundOverlay:Destroy()
                    end)
                    
                    Dialog.ZIndex = 100
                end
                
                ColorpickerBtn.MouseButton1Click:Connect(openSimpleColorDialog)
                ColorDisplay.MouseButton1Click:Connect(openSimpleColorDialog)
                
                local funcs = {}
                
                function funcs:SetColor(color)
                    if typeof(color) == "Color3" then
                        FengUI.flags[flag] = color
                        ColorDisplay.BackgroundColor3 = color
                        callback(color)
                    end
                end
                
                function funcs:GetColor()
                    return FengUI.flags[flag]
                end
                
                return funcs
            end
            
            function section.Toggle(section, text, flag, enabled, callback)
                callback = callback or function() end
                enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                FengUI.flags[flag] = enabled

                local ToggleModule = Instance.new("Frame")
                local ToggleBtn = Instance.new("TextButton")
                local ToggleBtnC = Instance.new("UICorner")
                local ToggleDisable = Instance.new("Frame")
                local ToggleSwitch = Instance.new("Frame")
                local ToggleSwitchC = Instance.new("UICorner")
                local ToggleDisableC = Instance.new("UICorner")
                
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = config.Toggle_Color
                ToggleBtn.BackgroundTransparency = 0.2
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = config.TextColor
                ToggleBtn.TextSize = 14
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn
                
                local togglePosition = 0.85
                if windowCount == 2 then
                    togglePosition = 0.78
                end
                
                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
                ToggleDisable.BackgroundTransparency = 0.8
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2.new(togglePosition, 0, 0.22, 0)
                ToggleDisable.Size = UDim2.new(0, 34, 0, 18)
                
                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = enabled and config.Toggle_On or config.Toggle_Off
                ToggleSwitch.Size = UDim2.new(0, 20, 0, 18)
                ToggleSwitch.Position = UDim2.new(0, enabled and 14 or 0, 0, 0)
                
                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch
                
                ToggleDisableC.CornerRadius = UDim.new(0, 9)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable
                
                ToggleBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.1,
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Toggle_Color.R * 255 * 1.1),
                            math.floor(config.Toggle_Color.G * 255 * 1.1),
                            math.floor(config.Toggle_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                ToggleBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundTransparency = 0.2,
                        BackgroundColor3 = config.Toggle_Color
                    }):Play()
                end)
                
                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not FengUI.flags[flag]
                        end
                        if FengUI.flags[flag] == state then
                            return
                        end
                        
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                            Position = UDim2.new(0, state and 14 or 0, 0, 0),
                            BackgroundColor3 = state and config.Toggle_On or config.Toggle_Off
                        }):Play()
                        
                        FengUI.flags[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule
                }
                
                if enabled ~= false then
                    funcs:SetState(true)
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                
                return funcs
            end
            
            function section.Keybind(section, text, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(default, "No default key provided")
                
                local default = typeof(default) == "string" and Enum.KeyCode[default] or default
                local banned = {
                    Return = true, Space = true, Tab = true,
                    Backquote = true, CapsLock = true, Escape = true,
                    Unknown = true
                }
                
                local shortNames = {
                    RightControl = "Right Ctrl", LeftControl = "Left Ctrl",
                    LeftShift = "Left Shift", RightShift = "Right Shift",
                    Semicolon = ";", Quote = '"', LeftBracket = "[",
                    RightBracket = "]", Equals = "=", Minus = "-",
                    RightAlt = "Right Alt", LeftAlt = "Left Alt"
                }
                
                local bindKey = default
                local keyTxt = default and (shortNames[default.Name] or default.Name) or "None"
                
                local KeybindModule = Instance.new("Frame")
                local KeybindBtn = Instance.new("TextButton")
                local KeybindBtnC = Instance.new("UICorner")
                local KeybindValue = Instance.new("TextButton")
                local KeybindValueC = Instance.new("UICorner")
                local KeybindL = Instance.new("UIListLayout")
                local UIPadding = Instance.new("UIPadding")
                
                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = config.Keybind_Color
                KeybindBtn.BackgroundTransparency = 0.2
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2.new(0, elementWidth, 0, 36)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = config.TextColor
                KeybindBtn.TextSize = 14
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                
                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn
                
                local keybindPosition = 0.72
                if windowCount == 2 then
                    keybindPosition = 0.64
                end
                
                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = config.Bg_Color
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2.new(keybindPosition, 0, 0.22, 0)
                KeybindValue.Size = UDim2.new(0, 70, 0, 22)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = config.TextColor
                KeybindValue.TextSize = 12
                
                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue
                
                KeybindL.Name = "KeybindL"
                KeybindL.Parent = KeybindBtn
                KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
                KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center
                
                UIPadding.Parent = KeybindBtn
                UIPadding.PaddingRight = UDim.new(0, 6)
                
                KeybindBtn.MouseEnter:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        BackgroundColor3 = Color3.fromRGB(
                            math.floor(config.Keybind_Color.R * 255 * 1.1),
                            math.floor(config.Keybind_Color.G * 255 * 1.1),
                            math.floor(config.Keybind_Color.B * 255 * 1.1)
                        )
                    }):Play()
                end)
                
                KeybindBtn.MouseLeave:Connect(function()
                    services.TweenService:Create(KeybindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        BackgroundColor3 = config.Keybind_Color
                    }):Play()
                end)
                
                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then return end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if inp.KeyCode ~= bindKey then return end
                    callback(bindKey.Name)
                end)
                
                KeybindValue.MouseButton1Click:Connect(function()
                    KeybindValue.Text = "..."
                    task.wait()
                    
                    local key = UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    
                    if banned[keyName] then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    
                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    KeybindValue.Text = shortNames[keyName] or keyName
                    
                    create3DFlipAnimation(KeybindValue, 0.3)
                end)
                
                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
                end)
                
                KeybindValue.Size = UDim2.new(0, KeybindValue.TextBounds.X + 20, 0, 22)
            end
            
            function section.Textbox(section, text, flag, default, callback)
                callback = callback or function() end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")
                
                FengUI.flags[flag] = default
                
                local TextboxModule = Instance.new("Frame")
                local TextboxBack = Instance.new("TextButton")
                local TextboxBackC = Instance.new("UICorner")
                local BoxBG = Instance.new("TextButton")
                local BoxBGC = Instance.new("UICorner")
                local TextBox = Instance.new("TextBox")
                local TextboxBackL = Instance.new("UIListLayout")
                local TextboxBackP = Instance.new("UIPadding")
                
                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundTransparency = 1
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Size = UDim2.new(0, elementWidth, 0, 36)
                
                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = config.Textbox_Color
                TextboxBack.BackgroundTransparency = 0.2
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2.new(0, elementWidth, 0, 36)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = config.TextColor
                TextboxBack.TextSize = 14
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left
                
                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack
                
                local textboxPosition = 0.45
                if windowCount == 2 then
                    textboxPosition = 0.36
                end
                
                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = config.Bg_Color
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2.new(textboxPosition, 0, 0.22, 0)
                BoxBG.Size = UDim2.new(0, 80, 0, 22)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.Gotham
                BoxBG.Text = ""
                
                BoxBGC.CornerRadius = UDim.new(0, 6)
    BoxBGC.Name = "BoxBGC"
    BoxBGC.Parent = BoxBG
    
    TextBox.Parent = BoxBG
    TextBox.BackgroundTransparency = 1
    TextBox.BorderSizePixel = 0
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.Font = Enum.Font.Gotham
    TextBox.Text = default
    TextBox.TextColor3 = config.TextColor
    TextBox.TextSize = 12
    TextBox.PlaceholderColor3 = config.SecondaryTextColor
    
    TextboxBackL.Name = "TextboxBackL"
    TextboxBackL.Parent = TextboxBack
    TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
    TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
    TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center
    
    TextboxBackP.Name = "TextboxBackP"
    TextboxBackP.Parent = TextboxBack
    TextboxBackP.PaddingRight = UDim.new(0, 12)
    
    TextboxBack.MouseEnter:Connect(function()
        services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(config.Textbox_Color.R * 255 * 1.1),
                math.floor(config.Textbox_Color.G * 255 * 1.1),
                math.floor(config.Textbox_Color.B * 255 * 1.1)
            )
        }):Play()
    end)
    
    TextboxBack.MouseLeave:Connect(function()
        services.TweenService:Create(TextboxBack, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            BackgroundColor3 = config.Textbox_Color
        }):Play()
    end)
    
    TextBox.FocusLost:Connect(function()
        if TextBox.Text == "" then
            TextBox.Text = default
        end
        FengUI.flags[flag] = TextBox.Text
        callback(TextBox.Text)
    end)
    
    TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
        BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
    end)
    
    BoxBG.Size = UDim2.new(0, TextBox.TextBounds.X + 20, 0, 22)
end

function section.Slider(section, text, flag, default, min, max, precise, callback)
    callback = callback or function() end
    min = min or 0
    max = max or 10
    default = default or min
    precise = precise or false
    
    assert(text, "No text provided")
    assert(flag, "No flag provided")
    assert(default, "No default value provided")
    
    FengUI.flags[flag] = default

    local SliderModule = Instance.new("Frame")
    local SliderBack = Instance.new("TextButton")
    local SliderBackC = Instance.new("UICorner")
    local SliderBar = Instance.new("Frame")
    local SliderBarC = Instance.new("UICorner")
    local SliderPart = Instance.new("Frame")
    local SliderPartC = Instance.new("UICorner")
    local SliderValBG = Instance.new("TextButton")
    local SliderValBGC = Instance.new("UICorner")
    local SliderValue = Instance.new("TextBox")
    
    SliderModule.Name = "SliderModule"
    SliderModule.Parent = Objs
    SliderModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderModule.BackgroundTransparency = 1.000
    SliderModule.BorderSizePixel = 0
    SliderModule.Position = UDim2.new(0, 0, 0, 0)
    
    if windowCount == 2 then
        SliderModule.Size = UDim2.new(0, elementWidth, 0, 52)
    else
        SliderModule.Size = UDim2.new(0, elementWidth, 0, 36)
    end
    
    SliderBack.Name = "SliderBack"
    SliderBack.Parent = SliderModule
    SliderBack.BackgroundColor3 = config.Slider_Color
    SliderBack.BackgroundTransparency = 0.2
    SliderBack.BorderSizePixel = 0
    SliderBack.Size = UDim2.new(1, 0, 1, 0)
    SliderBack.AutoButtonColor = false
    SliderBack.Font = Enum.Font.GothamSemibold
    SliderBack.Text = "   " .. text
    SliderBack.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderBack.TextSize = 14.000
    SliderBack.TextXAlignment = Enum.TextXAlignment.Left
    
    if windowCount == 2 then
        SliderBack.TextYAlignment = Enum.TextYAlignment.Top
        local padding = Instance.new("UIPadding")
        padding.Parent = SliderBack
        padding.PaddingTop = UDim.new(0, 4)
    end
    
    SliderBackC.CornerRadius = UDim.new(0, 6)
    SliderBackC.Name = "SliderBackC"
    SliderBackC.Parent = SliderBack
    
    if windowCount == 2 then
        SliderBar.Name = "SliderBar"
        SliderBar.Parent = SliderBack
        SliderBar.AnchorPoint = Vector2.new(0, 0)
        SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(0.03, 0, 0.45, 0)
        SliderBar.Size = UDim2.new(0.65, 0, 0, 14)
        SliderBarC.CornerRadius = UDim.new(0, 4)
        SliderBarC.Name = "SliderBarC"
        SliderBarC.Parent = SliderBar
        
        SliderPart.Name = "SliderPart"
        SliderPart.Parent = SliderBar
        SliderPart.BackgroundColor3 = config.SliderBar_Color
        SliderPart.BorderSizePixel = 0
        SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        SliderPartC.CornerRadius = UDim.new(0, 4)
        SliderPartC.Name = "SliderPartC"
        SliderPartC.Parent = SliderPart
        
        SliderValBG.Name = "SliderValBG"
        SliderValBG.Parent = SliderBack
        SliderValBG.BackgroundColor3 = config.Bg_Color
        SliderValBG.BorderSizePixel = 0
        SliderValBG.Position = UDim2.new(0.72, 0, 0.42, 0)
        SliderValBG.Size = UDim2.new(0, 36, 0, 22)
        SliderValBG.AutoButtonColor = false
        SliderValBG.Font = Enum.Font.Gotham
        SliderValBG.Text = ""
        SliderValBG.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderValBG.TextSize = 14.000
        
        SliderValBGC.CornerRadius = UDim.new(0, 6)
        SliderValBGC.Name = "SliderValBGC"
        SliderValBGC.Parent = SliderValBG
        
        SliderBack.Text = "   " .. text
    else
        local sliderBarPosition = 0.35
        local sliderBarWidth = 120
        local sliderValuePosition = 0.82
        local minSliderPosition = 0.28
        local addSliderPosition = 0.75
        
        SliderBar.Name = "SliderBar"
        SliderBar.Parent = SliderBack
        SliderBar.AnchorPoint = Vector2.new(0, 0.5)
        SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(sliderBarPosition, 0, 0.5, 0)
        SliderBar.Size = UDim2.new(0, sliderBarWidth, 0, 14)
        SliderBarC.CornerRadius = UDim.new(0, 4)
        SliderBarC.Name = "SliderBarC"
        SliderBarC.Parent = SliderBar
        
        SliderPart.Name = "SliderPart"
        SliderPart.Parent = SliderBar
        SliderPart.BackgroundColor3 = config.SliderBar_Color
        SliderPart.BorderSizePixel = 0
        SliderPart.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        SliderPartC.CornerRadius = UDim.new(0, 4)
        SliderPartC.Name = "SliderPartC"
        SliderPartC.Parent = SliderPart
        
        SliderValBG.Name = "SliderValBG"
        SliderValBG.Parent = SliderBack
        SliderValBG.BackgroundColor3 = config.Bg_Color
        SliderValBG.BorderSizePixel = 0
        SliderValBG.Position = UDim2.new(sliderValuePosition, 0, 0.22, 0)
        SliderValBG.Size = UDim2.new(0, 36, 0, 22)
        SliderValBG.AutoButtonColor = false
        SliderValBG.Font = Enum.Font.Gotham
        SliderValBG.Text = ""
        SliderValBG.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderValBG.TextSize = 14.000
        
        SliderValBGC.CornerRadius = UDim.new(0, 6)
        SliderValBGC.Name = "SliderValBGC"
        SliderValBGC.Parent = SliderValBG
        
        local MinSlider = Instance.new("TextButton")
        MinSlider.Name = "MinSlider"
        MinSlider.Parent = SliderBack
        MinSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        MinSlider.BackgroundTransparency = 0
        MinSlider.BorderSizePixel = 0
        MinSlider.Position = UDim2.new(minSliderPosition, 0, 0.25, 0)
        MinSlider.Size = UDim2.new(0, 18, 0, 18)
        MinSlider.Font = Enum.Font.Gotham
        MinSlider.Text = "减"
        MinSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinSlider.TextSize = 13.000
        MinSlider.TextWrapped = true
        MinSlider.ZIndex = 2
        
        local MinSliderC = Instance.new("UICorner")
        MinSliderC.CornerRadius = UDim.new(0, 4)
        MinSliderC.Parent = MinSlider
        
        local AddSlider = Instance.new("TextButton")
        AddSlider.Name = "AddSlider"
        AddSlider.Parent = SliderBack
        AddSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        AddSlider.BackgroundTransparency = 0
        AddSlider.BorderSizePixel = 0
        AddSlider.Position = UDim2.new(addSliderPosition, 0, 0.25, 0)
        AddSlider.Size = UDim2.new(0, 18, 0, 18)
        AddSlider.Font = Enum.Font.Gotham
        AddSlider.Text = "加"
        AddSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
        AddSlider.TextSize = 13.000
        AddSlider.TextWrapped = true
        AddSlider.ZIndex = 2
        
        local AddSliderC = Instance.new("UICorner")
        AddSliderC.CornerRadius = UDim.new(0, 4)
        AddSliderC.Parent = AddSlider
        
        MinSlider.MouseButton1Click:Connect(function()
            local currentValue = FengUI.flags[flag]
            currentValue = math.clamp(currentValue - 1, min, max)
            funcs:SetValue(currentValue)
        end)
        
        AddSlider.MouseButton1Click:Connect(function()
            local currentValue = FengUI.flags[flag]
            currentValue = math.clamp(currentValue + 1, min, max)
            funcs:SetValue(currentValue)
        end)
    end
    
    SliderValue.Name = "SliderValue"
    SliderValue.Parent = SliderValBG
    SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderValue.BackgroundTransparency = 1.000
    SliderValue.BorderSizePixel = 0
    SliderValue.Size = UDim2.new(1, 0, 1, 0)
    SliderValue.Font = Enum.Font.Gotham
    SliderValue.Text = tostring(default)
    SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderValue.TextSize = 11.000
    
    if windowCount == 2 then
        SliderValue.TextSize = 12
        SliderValue.Font = Enum.Font.Gotham
    end
    
    local funcs = {
        SetValue = function(self, value)
            local percent
            
            if value then
                percent = (value - min)/(max - min)
            else
                local mouse = services.Players.LocalPlayer:GetMouse()
                local barPos = SliderBar.AbsolutePosition.X
                local barSize = SliderBar.AbsoluteSize.X
                local mouseX = math.clamp(mouse.X, barPos, barPos + barSize)
                percent = (mouseX - barPos) / barSize
                value = min + (max - min) * percent
            end
            
            if precise then
                value = tonumber(string.format("%.2f", value))
            else
                value = math.floor(value + 0.5)
            end
            
            value = math.clamp(value, min, max)
            percent = (value - min)/(max - min)
            FengUI.flags[flag] = tonumber(value)
            SliderValue.Text = tostring(value)
            
            services.TweenService:Create(SliderPart, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                Size = UDim2.new(percent, 0, 1, 0)
            }):Play()
            
            callback(tonumber(value))
        end,
        
        GetValue = function(self)
            return FengUI.flags[flag]
        end
    }
    
    funcs:SetValue(default)
    
    local dragging = false
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            funcs:SetValue()
        end
    end)
    
    SliderPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            funcs:SetValue()
        end
    end)
    
    services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            funcs:SetValue()
        end
    end)
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            funcs:SetValue()
        end
    end)
    
    services.UserInputService.InputEnded:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            funcs:SetValue()
        end
    end)
    
    local boxFocused = false
    local allowed = { [""] = true, ["-"] = true }
    
    SliderValue.Focused:Connect(function()
        boxFocused = true
    end)
    
    SliderValue.FocusLost:Connect(function()
        boxFocused = false
        if SliderValue.Text == "" then
            funcs:SetValue(default)
            return
        end
        
        local numValue = tonumber(SliderValue.Text)
        if numValue then
            numValue = math.clamp(numValue, min, max)
            funcs:SetValue(numValue)
        else
            funcs:SetValue(default)
        end
    end)
    
    SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
        if not boxFocused then
            return
        end
        
        local text = SliderValue.Text
        local newText = ""
        
        for i = 1, #text do
            local char = text:sub(i, i)
            if char:match("%d") or (char == "." and precise) then
                newText = newText .. char
            end
        end
        
        local dotCount = 0
        local finalText = ""
        for i = 1, #newText do
            local char = newText:sub(i, i)
            if char == "." then
                dotCount = dotCount + 1
                if dotCount <= 1 then
                    finalText = finalText .. char
                end
            else
                finalText = finalText .. char
            end
        end
        
        SliderValue.Text = finalText
        
        local text = SliderValue.Text
        if not tonumber(text) and not allowed[text] then
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
            
function section.Dropdown(section, text, flag, options, callback)
    local callback = callback or function() end
    local options = options or {}
    assert(text, "No text provided")
    assert(flag, "No flag provided")
    FengUI.flags[flag] = nil
    
    local DropdownModule = Instance.new("Frame")
    local DropdownTop = Instance.new("TextButton")
    local DropdownTopC = Instance.new("UICorner")
    local DropdownOpenFrame = Instance.new("Frame")
    local DropdownOpenFrameC = Instance.new("UICorner")
    local DropdownOpen = Instance.new("TextButton")
    local DropdownText = Instance.new("TextBox")
    local DropdownModuleL = Instance.new("UIListLayout")
    
    DropdownModule.Name = "DropdownModule"
    DropdownModule.Parent = Objs
    DropdownModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownModule.BackgroundTransparency = 1.000
    DropdownModule.BorderSizePixel = 0
    DropdownModule.ClipsDescendants = true
    DropdownModule.Position = UDim2.new(0, 0, 0, 0)
    DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36)
    
    DropdownTop.Name = "DropdownTop"
    DropdownTop.Parent = DropdownModule
    DropdownTop.BackgroundColor3 = config.Dropdown_Color
    DropdownTop.BackgroundTransparency = 0.2
    DropdownTop.BorderSizePixel = 0
    DropdownTop.Size = UDim2.new(0, elementWidth, 0, 36)
    DropdownTop.AutoButtonColor = false
    DropdownTop.Font = Enum.Font.GothamSemibold
    DropdownTop.Text = ""
    DropdownTop.TextColor3 = config.TextColor
    DropdownTop.TextSize = 14.000
    DropdownTop.TextXAlignment = Enum.TextXAlignment.Left
    
    DropdownTopC.CornerRadius = UDim.new(0, 6)
    DropdownTopC.Name = "DropdownTopC"
    DropdownTopC.Parent = DropdownTop
    
    local BackgroundFill = Instance.new("Frame")
    BackgroundFill.Name = "BackgroundFill"
    BackgroundFill.Parent = DropdownTop
    BackgroundFill.BackgroundColor3 = config.Dropdown_Color
    BackgroundFill.BorderSizePixel = 0
    BackgroundFill.Position = UDim2.new(0.75, 0, 0, 0)
    BackgroundFill.Size = UDim2.new(0.25, 0, 1, 0)
    BackgroundFill.ZIndex = 0
    
    local dropdownFramePosition = 0.80
    local separatorPosition = 0.74
    if windowCount == 2 then
        dropdownFramePosition = 0.71
        separatorPosition = 0.65
    end
    
    DropdownOpenFrame.Name = "DropdownOpenFrame"
    DropdownOpenFrame.Parent = DropdownTop
    DropdownOpenFrame.AnchorPoint = Vector2.new(0, 0.5)
    DropdownOpenFrame.BackgroundColor3 = config.Bg_Color
    DropdownOpenFrame.BorderSizePixel = 0
    DropdownOpenFrame.Position = UDim2.new(dropdownFramePosition, 0, 0.5, 0)
    DropdownOpenFrame.Size = UDim2.new(0, 35, 0, 22)
    DropdownOpenFrame.ZIndex = 2
    
    DropdownOpenFrameC.CornerRadius = UDim.new(0, 4)
    DropdownOpenFrameC.Name = "DropdownOpenFrameC"
    DropdownOpenFrameC.Parent = DropdownOpenFrame
    
    DropdownOpen.Name = "DropdownOpen"
    DropdownOpen.Parent = DropdownOpenFrame
    DropdownOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownOpen.BackgroundTransparency = 1.000
    DropdownOpen.BorderSizePixel = 0
    DropdownOpen.Size = UDim2.new(1, 0, 1, 0)
    DropdownOpen.Font = Enum.Font.GothamSemibold
    DropdownOpen.Text = "选择"
    DropdownOpen.TextColor3 = config.TextColor
    DropdownOpen.TextSize = 11.000
    DropdownOpen.TextWrapped = true
    DropdownOpen.ZIndex = 3
    
    DropdownText.Name = "DropdownText"
    DropdownText.Parent = DropdownTop
    DropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownText.BackgroundTransparency = 1.000
    DropdownText.BorderSizePixel = 0
    DropdownText.Position = UDim2.new(0.037, 0, 0, 0)
    DropdownText.Size = UDim2.new(0, 230, 0, 36)
    DropdownText.Font = Enum.Font.GothamSemibold
    DropdownText.PlaceholderColor3 = config.SecondaryTextColor
    DropdownText.PlaceholderText = text
    DropdownText.Text = ""
    DropdownText.TextColor3 = config.TextColor
    DropdownText.TextSize = 14.000
    DropdownText.TextXAlignment = Enum.TextXAlignment.Left
    DropdownText.ZIndex = 2
    
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Parent = DropdownTop
    Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Separator.BorderSizePixel = 0
    Separator.Position = UDim2.new(separatorPosition, 0, 0.2, 0)
    Separator.Size = UDim2.new(0, 1, 0, 22)
    Separator.ZIndex = 1
    
    DropdownModuleL.Name = "DropdownModuleL"
    DropdownModuleL.Parent = DropdownModule
    DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
    DropdownModuleL.Padding = UDim.new(0, 4)
    
    -- 存储所有选项的表
    local allOptions = {}
    
    local function updateDropdownHeight()
        if not open then return end
        
        local visibleCount = 0
        for _, option in pairs(allOptions) do
            if option and option.Parent and option.Visible then
                visibleCount = visibleCount + 1
            end
        end
        
        if visibleCount == 0 then
            -- 如果没有可见选项，显示一个提示选项
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36 + 28)
        else
            -- 计算总高度：顶部36 + 每个选项28 + 最后一个选项的额外边距4
            local totalHeight = 36 + (visibleCount * 28) + 4
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, totalHeight)
        end
    end
    
    local function setAllVisible()
        for _, option in pairs(allOptions) do
            if option then
                option.Visible = true
            end
        end
        updateDropdownHeight()
    end
    
    local function searchDropdown(text)
        local visibleCount = 0
        
        for _, option in pairs(allOptions) do
            if option then
                if text == "" then
                    option.Visible = true
                else
                    option.Visible = option.Text:lower():match(text:lower()) ~= nil
                end
                
                if option.Visible then
                    visibleCount = visibleCount + 1
                end
            end
        end
        
        -- 如果没有可见选项，显示提示
        if visibleCount == 0 and text ~= "" then
            -- 可以在这里添加"无结果"提示
        end
        
        updateDropdownHeight()
    end
    
    local open = false
    local function toggleDropdown()
        open = not open
        DropdownOpen.Text = open and "取消" or "选择"
        
        if open then
            setAllVisible()
            updateDropdownHeight()
        else
            DropdownModule.Size = UDim2.new(0, elementWidth, 0, 36)
        end
        
        create3DFlipAnimation(DropdownOpenFrame, 0.3)
    end
    
    DropdownOpen.MouseButton1Click:Connect(toggleDropdown)
    
    DropdownText.Focused:Connect(function()
        if not open then
            toggleDropdown()
        end
    end)
    
    DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
        if open then
            searchDropdown(DropdownText.Text)
        end
    end)
    
    DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateDropdownHeight()
    end)
    
    local funcs = {}
    
    funcs.AddOption = function(self, optionText)
        local Option = Instance.new("TextButton")
        local OptionC = Instance.new("UICorner")
        
        Option.Name = "Option_" .. optionText
        Option.Parent = DropdownModule
        Option.BackgroundColor3 = config.TabColor
        Option.BackgroundTransparency = 0.2
        Option.BorderSizePixel = 0
        Option.Position = UDim2.new(0, 0, 0.328125, 0)
        Option.Size = UDim2.new(0, elementWidth - 20, 0, 24)
        Option.AutoButtonColor = false
        Option.Font = Enum.Font.Gotham
        Option.Text = optionText
        Option.TextColor3 = config.TextColor
        Option.TextSize = 13.000
        Option.Visible = open  -- 根据下拉状态设置初始可见性
        
        OptionC.CornerRadius = UDim.new(0, 6)
        OptionC.Name = "OptionC"
        OptionC.Parent = Option
        
        -- 存储到所有选项表
        table.insert(allOptions, Option)
        
        Option.MouseButton1Click:Connect(function()
            toggleDropdown()
            callback(Option.Text)
            DropdownText.Text = Option.Text
            FengUI.flags[flag] = Option.Text
        end)
        
        updateDropdownHeight()
    end
    
    funcs.RemoveOption = function(self, optionText)
        for i, option in pairs(allOptions) do
            if option and option.Text == optionText then
                option:Destroy()
                table.remove(allOptions, i)
                break
            end
        end
        updateDropdownHeight()
    end
    
    funcs.SetOptions = function(self, newOptions)
        -- 清除现有选项
        for _, option in pairs(allOptions) do
            if option then
                option:Destroy()
            end
        end
        allOptions = {}
        
        -- 添加新选项
        for _, optionText in pairs(newOptions) do
            funcs:AddOption(optionText)
        end
        
        updateDropdownHeight()
    end
    
    funcs:SetOptions(options)
    
    return funcs
end

            return section
        end

        return tab
    end
    
    function window:DualTab(name, icon)
        return window:Tab(name, icon, 2)
    end

    return window
end

function UiDestroy()
    if FengYu then
        FengYu:Destroy()
    end
end

function ToggleUILib()
    ToggleUI = not ToggleUI
    FengYu.Enabled = ToggleUI
    Main.Visible = not ToggleUI
end

if not getgenv then getgenv = function() return _G end end
getgenv().FengUI = FengUI

return FengUI