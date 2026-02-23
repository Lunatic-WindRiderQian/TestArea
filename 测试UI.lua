local MacLib = { 
	Options = {}, 
	Folder = "Maclib", 
	GetService = function(service)
		return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
	end
}

--// Services
local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local HttpService = MacLib.GetService("HttpService")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local Lighting = MacLib.GetService("Lighting")
local Players = MacLib.GetService("Players")
local SoundService = MacLib.GetService("SoundService")      -- 用于新 UI 音效
local TextService = MacLib.GetService("TextService")        -- 用于新 UI 文本测量

--// Variables
local isStudio = RunService:IsStudio()
local LocalPlayer = Players.LocalPlayer

local windowState
local acrylicBlur
local hasGlobalSetting

local tabs = {}
local currentTabInstance = nil
local tabIndex = 0
local unloaded = false

local assets = {
	interFont = "rbxassetid://12187365364",
	userInfoBlurred = "rbxassetid://18824089198",
	toggleBackground = "rbxassetid://18772190202",
	togglerHead = "rbxassetid://18772309008",
	buttonImage = "rbxassetid://10709791437",
	searchIcon = "rbxassetid://86737463322606",
	colorWheel = "rbxassetid://2849458409",
	colorTarget = "rbxassetid://73265255323268",
	grid = "rbxassetid://121484455191370",
	globe = "rbxassetid://108952102602834",
	transform = "rbxassetid://90336395745819",
	dropdown = "rbxassetid://18865373378",
	sliderbar = "rbxassetid://18772615246",
	sliderhead = "rbxassetid://18772834246",
}

-- ==================== 嵌入新 UI 库 (测试UI.lua) ====================
local NewUI = (function()
	-- 将测试UI.lua 的内容直接放在这里，并修改使其返回控制对象、暴露主框架等
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local CoreGui = game:GetService("CoreGui")
	local SoundService = game:GetService("SoundService")
	local Players = game:GetService("Players")
	local HttpService = game:GetService("HttpService") 
	local TextService = game:GetService("TextService")
	local LocalPlayer = Players.LocalPlayer

	local Library = {}
	local RainbowEnabled = false
	local RainbowType = "Animated/Cycling Rainbow" 
	local SFXEnabled = true
	local Registry = {} 
	local ConfigObjects = {} 

	-- SFX
	local Sounds = {
		Hover = "rbxassetid://4510086912",
		Click = "rbxassetid://4510086561",
		ToggleOn = "rbxassetid://4510087425",
		ToggleOff = "rbxassetid://4510087425",
		Slide = "rbxassetid://4510087798",
		Notification = "rbxassetid://4590657391",
		Back = "rbxassetid://4510087236",
		Error = "rbxassetid://4510087545",
		Tab = "rbxassetid://4510087056" 
	}

	-- 使用 maclib 的图片资源
	local ToggleAssets = {
		Bg = assets.toggleBackground,
		Head = assets.togglerHead
	}
	local SliderAssets = {
		Bar = assets.sliderbar,
		Head = assets.sliderhead
	}

	local function PlaySound(id)
		if not SFXEnabled then return end
		task.spawn(function()
			local s = Instance.new("Sound")
			s.SoundId = id
			s.Volume = 1
			s.Parent = SoundService
			s:Play()
			game.Debris:AddItem(s, 2)
		end)
	end

	-- THEMES
	local Themes = {
		Dark   = {Main = Color3.fromRGB(25, 25, 25), Top = Color3.fromRGB(35, 35, 35), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(114, 137, 218), Stroke = Color3.fromRGB(60, 60, 60)},
		White  = {Main = Color3.fromRGB(240, 240, 240), Top = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(25, 25, 25), Accent = Color3.fromRGB(0, 120, 215), Stroke = Color3.fromRGB(200, 200, 200)},
		Purple = {Main = Color3.fromRGB(30, 25, 35), Top = Color3.fromRGB(40, 30, 45), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(170, 0, 255), Stroke = Color3.fromRGB(80, 40, 80)},
		Blue   = {Main = Color3.fromRGB(20, 25, 40), Top = Color3.fromRGB(30, 35, 50), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 100, 255), Stroke = Color3.fromRGB(40, 50, 80)},
		Red    = {Main = Color3.fromRGB(35, 20, 20), Top = Color3.fromRGB(45, 25, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 50, 50), Stroke = Color3.fromRGB(80, 40, 40)},
		Yellow = {Main = Color3.fromRGB(35, 35, 20), Top = Color3.fromRGB(45, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(230, 200, 50), Stroke = Color3.fromRGB(80, 80, 40)},
		Green  = {Main = Color3.fromRGB(20, 35, 20), Top = Color3.fromRGB(25, 45, 25), Text = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(50, 200, 100), Stroke = Color3.fromRGB(40, 80, 40)},
	}
	local CurrentTheme = Themes.Dark

	local function AddToRegistry(obj, prop, themeIndex)
		table.insert(Registry, {Object = obj, Property = prop, Type = themeIndex})
		obj[prop] = CurrentTheme[themeIndex]
	end

	local function Tween(obj, props, time)
		TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
	end

	function Library:SetTheme(themeName)
		if Themes[themeName] then
			CurrentTheme = Themes[themeName]
			for _, reg in pairs(Registry) do
				if reg.Object then
					Tween(reg.Object, {[reg.Property] = CurrentTheme[reg.Type]})
				end
			end
		end
	end

	function Library:ToggleRainbow(bool) RainbowEnabled = bool end
	function Library:SetRainbowType(val) RainbowType = val end
	function Library:SetSFXEnabled(state) SFXEnabled = state end

	function Library:CreateWindow(Config)
		local Window = {}
		local Title = Config.Title or "M0dzn UI"
		local Keybind = Config.Keybind 

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "MacLib_NewUI"
		ScreenGui.Parent = CoreGui
		ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
		if syn and syn.protect_gui then syn.protect_gui(ScreenGui) elseif gethui then ScreenGui.Parent = gethui() end

		local MainFrame = Instance.new("Frame")
		MainFrame.Size = UDim2.new(0, 0, 0, 0) 
		MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		MainFrame.ClipsDescendants = true
		MainFrame.Parent = ScreenGui
		Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
		AddToRegistry(MainFrame, "BackgroundColor3", "Main")

		local Stroke = Instance.new("UIStroke")
		Stroke.Thickness = 2
		Stroke.Parent = MainFrame
		AddToRegistry(Stroke, "Color", "Stroke")

		local Gradient = Instance.new("UIGradient")
		Gradient.Parent = Stroke
		Gradient.Enabled = false

		task.spawn(function()
			local rot = 0
			while ScreenGui.Parent do
				if RainbowEnabled then
					local t = tick()
					if RainbowType == "Linear Gradient (Solid Rainbow)" then
						Gradient.Enabled = true; Gradient.Rotation = 0
						Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))})
						Stroke.Color = Color3.new(1,1,1)
					elseif RainbowType == "Animated/Cycling Rainbow" then
						Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 1, 1)
					elseif RainbowType == "Smooth Fading Gradient" then
						Gradient.Enabled = true; rot = rot + 2; Gradient.Rotation = rot
						Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))}); Stroke.Color = Color3.new(1,1,1)
					elseif RainbowType == "Step/Band Rainbow" then
						Gradient.Enabled = false; local step = math.floor((t % 2) * 4) / 4; Stroke.Color = Color3.fromHSV(step, 1, 1)
					elseif RainbowType == "Rainbow Pulse" then
						Gradient.Enabled = false; local pulse = (math.sin(t * 3) + 1) / 2; Stroke.Color = Color3.fromHSV(t % 5 / 5, pulse, 1)
					elseif RainbowType == "Radial Rainbow" then
						Gradient.Enabled = true; rot = rot + 5; Gradient.Rotation = rot
						Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))}); Stroke.Color = Color3.new(1,1,1)
					elseif RainbowType == "Neon/Glowing Rainbow" then
						Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 2 / 2, 0.8, 1) 
					elseif RainbowType == "Pastel Rainbow" then
						Gradient.Enabled = false; Stroke.Color = Color3.fromHSV(t % 5 / 5, 0.4, 1)
					elseif RainbowType == "Vertical/Horizontal Fade" then
						Gradient.Enabled = true; Gradient.Rotation = 90; local c = Color3.fromHSV(t % 5/5, 1, 1); local c2 = Color3.fromHSV((t+1) % 5/5, 1, 1); Gradient.Color = ColorSequence.new(c, c2); Stroke.Color = Color3.new(1,1,1)
					end
				else
					Gradient.Enabled = false
					Stroke.Color = CurrentTheme.Stroke
				end
				RunService.RenderStepped:Wait()
			end
		end)

		local Topbar = Instance.new("Frame")
		Topbar.Size = UDim2.new(1, 0, 0, 40)
		Topbar.Parent = MainFrame
		Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)
		AddToRegistry(Topbar, "BackgroundColor3", "Top")

		local Fix = Instance.new("Frame")
		Fix.Size = UDim2.new(1, 0, 0, 10)
		Fix.Position = UDim2.new(0, 0, 1, -10)
		Fix.BorderSizePixel = 0
		Fix.Parent = Topbar
		AddToRegistry(Fix, "BackgroundColor3", "Top")

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Text = Title
		TitleLabel.Size = UDim2.new(1, -20, 1, 0)
		TitleLabel.Position = UDim2.new(0, 15, 0, 0)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.TextSize = 16
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Parent = Topbar
		AddToRegistry(TitleLabel, "TextColor3", "Text")

		local Content = Instance.new("Frame")
		Content.Size = UDim2.new(1, -20, 1, -55)
		Content.Position = UDim2.new(0, 10, 0, 45)
		Content.BackgroundTransparency = 1
		Content.Parent = MainFrame

		local TabContainer = Instance.new("ScrollingFrame")
		TabContainer.Size = UDim2.new(0, 140, 0.85, 0)
		TabContainer.BackgroundTransparency = 1
		TabContainer.ScrollBarThickness = 0
		TabContainer.Parent = Content
		local TabList = Instance.new("UIListLayout")
		TabList.Padding = UDim.new(0, 5)
		TabList.SortOrder = Enum.SortOrder.LayoutOrder
		TabList.Parent = TabContainer

		local ProfileFrame = Instance.new("Frame")
		ProfileFrame.Size = UDim2.new(0, 140, 0, 35)
		ProfileFrame.Position = UDim2.new(0, 0, 1, -35)
		ProfileFrame.BackgroundTransparency = 1
		ProfileFrame.Parent = Content

		local Avatar = Instance.new("ImageLabel")
		Avatar.Size = UDim2.new(0, 30, 0, 30)
		Avatar.Position = UDim2.new(0, 0, 0.5, -15)
		Avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
		Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		Avatar.Parent = ProfileFrame
		Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1,0)

		local DispName = Instance.new("TextLabel"); DispName.Text = LocalPlayer.DisplayName; DispName.Size = UDim2.new(1, -35, 0, 15); DispName.Position = UDim2.new(0, 35, 0, 2); DispName.BackgroundTransparency = 1; DispName.Font = Enum.Font.GothamBold; DispName.TextSize = 12; DispName.TextXAlignment = Enum.TextXAlignment.Left; DispName.Parent = ProfileFrame; AddToRegistry(DispName, "TextColor3", "Text")
		local UsrName = Instance.new("TextLabel"); UsrName.Text = "@"..LocalPlayer.Name; UsrName.Size = UDim2.new(1, -35, 0, 15); UsrName.Position = UDim2.new(0, 35, 0, 16); UsrName.BackgroundTransparency = 1; UsrName.Font = Enum.Font.Gotham; UsrName.TextSize = 11; UsrName.TextTransparency = 0.4; UsrName.TextXAlignment = Enum.TextXAlignment.Left; UsrName.Parent = ProfileFrame; AddToRegistry(UsrName, "TextColor3", "Text")

		local Line = Instance.new("Frame")
		Line.Size = UDim2.new(0, 1, 1, 0)
		Line.Position = UDim2.new(0, 145, 0, 0)
		Line.Parent = Content
		AddToRegistry(Line, "BackgroundColor3", "Stroke")

		local PageContainer = Instance.new("Frame")
		PageContainer.Size = UDim2.new(1, -155, 1, 0)
		PageContainer.Position = UDim2.new(0, 155, 0, 0)
		PageContainer.BackgroundTransparency = 1
		PageContainer.Parent = Content

		-- 窗口展开动画
		Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.6)

		local dragging, dragInput, dragStart, startPos
		Topbar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
		Topbar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
		UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
		RunService.RenderStepped:Connect(function()
			if dragging and dragInput then
				local delta = dragInput.Position - dragStart
				local target = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				MainFrame.Position = MainFrame.Position:Lerp(target, 0.2)
			end
		end)
		UserInputService.InputBegan:Connect(function(input, gpe)
			if not gpe and Keybind and input.KeyCode == Keybind then
				MainFrame.Visible = not MainFrame.Visible
				if MainFrame.Visible then 
					MainFrame.Size = UDim2.new(0,0,0,0)
					Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 280)}, 0.4)
				end
			end
		end)

		function Window:Notification(text)
			task.spawn(function()
				PlaySound(Sounds.Notification)
				local Notif = Instance.new("Frame"); Notif.ZIndex = 100; Notif.Size = UDim2.new(0, 250, 0, 45); Notif.Position = UDim2.new(1, 20, 1, -60); Notif.Parent = ScreenGui; AddToRegistry(Notif, "BackgroundColor3", "Top"); Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
				local NStroke = Instance.new("UIStroke"); NStroke.Parent = Notif; AddToRegistry(NStroke, "Color", "Accent")
				local NText = Instance.new("TextLabel"); NText.ZIndex = 101; NText.Text = text; NText.Size = UDim2.new(1,0,1,0); NText.BackgroundTransparency = 1; NText.Parent = Notif; NText.Font = Enum.Font.GothamBold; NText.TextSize = 14; AddToRegistry(NText, "TextColor3", "Text")
				Tween(Notif, {Position = UDim2.new(1, -270, 1, -60)}, 0.5); task.wait(3); Tween(Notif, {Position = UDim2.new(1, 20, 1, -60)}, 0.5); task.wait(0.5); Notif:Destroy()
			end)
		end

		function Window:SetKeybind(key) Keybind = key end
		function Window:Destroy() ScreenGui:Destroy() end

		local firstTab = true
		-- Tab 函数，图标与文字整体居中
		function Window:Tab(name, icon)
			local TabBtn = Instance.new("TextButton")
			TabBtn.Size = UDim2.new(1, 0, 0, 32)
			TabBtn.BackgroundTransparency = 1
			TabBtn.Text = ""
			TabBtn.Parent = TabContainer
			Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

			local ContentFrame = Instance.new("Frame")
			ContentFrame.Size = UDim2.new(1, 0, 1, 0)
			ContentFrame.BackgroundTransparency = 1
			ContentFrame.Parent = TabBtn

			local Layout = Instance.new("UIListLayout")
			Layout.FillDirection = Enum.FillDirection.Horizontal
			Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			Layout.VerticalAlignment = Enum.VerticalAlignment.Center
			Layout.Padding = UDim.new(0, 5)
			Layout.Parent = ContentFrame

			if icon then
				local TabIcon = Instance.new("ImageLabel")
				TabIcon.Size = UDim2.new(0, 20, 0, 20)
				TabIcon.BackgroundTransparency = 1
				if tonumber(icon) then
					TabIcon.Image = "rbxassetid://" .. icon
				else
					TabIcon.Image = icon
				end
				TabIcon.Parent = ContentFrame
				AddToRegistry(TabIcon, "ImageColor3", "Text")
			end

			local TabText = Instance.new("TextLabel")
			local textWidth = TextService:GetTextSize(name, 14, Enum.Font.GothamMedium, Vector2.new(200, 32)).X
			TabText.Size = UDim2.new(0, textWidth, 1, 0)
			TabText.BackgroundTransparency = 1
			TabText.Font = Enum.Font.GothamMedium
			TabText.Text = name
			TabText.TextColor3 = Color3.fromRGB(150, 150, 150)
			TabText.TextSize = 14
			TabText.TextXAlignment = Enum.TextXAlignment.Left
			TabText.Parent = ContentFrame
			AddToRegistry(TabText, "TextColor3", "Text")

			local Page = Instance.new("ScrollingFrame")
			Page.Size = UDim2.new(1, 0, 1, 0)
			Page.BackgroundTransparency = 1
			Page.ScrollBarThickness = 2
			Page.Visible = false
			Page.Parent = PageContainer

			local PageList = Instance.new("UIListLayout")
			PageList.Padding = UDim.new(0, 6)
			PageList.SortOrder = Enum.SortOrder.LayoutOrder
			PageList.Parent = Page
			PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0,0,0, PageList.AbsoluteContentSize.Y + 10) end)

			TabBtn.MouseButton1Click:Connect(function()
				PlaySound(Sounds.Tab) 
				for _, v in pairs(PageContainer:GetChildren()) do v.Visible = false end
				for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then 
					Tween(v, {BackgroundTransparency = 1})
					local content = v:FindFirstChild("ContentFrame")
					if content then
						local textLabel = content:FindFirstChildOfClass("TextLabel")
						if textLabel then
							Tween(textLabel, {TextColor3 = Color3.fromRGB(150,150,150)})
						end
					end
				end end
				Page.Visible = true
				Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent})
				Tween(TabText, {TextColor3 = CurrentTheme.Text})
			end)

			if firstTab then 
				firstTab = false
				Page.Visible = true
				Tween(TabBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = CurrentTheme.Accent})
				Tween(TabText, {TextColor3 = CurrentTheme.Text})
			end

			if name == "Config" then TabBtn.LayoutOrder = 99998 end
			if name == "Settings" then TabBtn.LayoutOrder = 99999 end

			local Elements = {}

			-- Section：可折叠容器，支持自定义图标，保留展开/收缩动画
			function Elements:Section(text, icons, defaultOpen)
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

				local sectionFrame = Instance.new("Frame")
				sectionFrame.Size = UDim2.new(1, 0, 0, 36)
				sectionFrame.BackgroundTransparency = 1
				sectionFrame.Parent = Page
				sectionFrame.ClipsDescendants = true

				local titleBar = Instance.new("Frame")
				titleBar.Size = UDim2.new(1, 0, 0, 36)
				titleBar.BackgroundTransparency = 1
				titleBar.Parent = sectionFrame

				local iconLabel = Instance.new("ImageLabel")
				iconLabel.Size = UDim2.new(0, 24, 0, 24)
				iconLabel.Position = UDim2.new(0, 5, 0.5, -12)
				iconLabel.BackgroundTransparency = 1
				iconLabel.Image = defaultOpen and iconOpen or iconClosed
				iconLabel.Parent = titleBar

				local textLabel = Instance.new("TextLabel")
				textLabel.Text = text
				textLabel.Size = UDim2.new(1, -34, 1, 0)
				textLabel.Position = UDim2.new(0, 34, 0, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextSize = 20
				textLabel.TextXAlignment = Enum.TextXAlignment.Left
				textLabel.Parent = titleBar
				AddToRegistry(textLabel, "TextColor3", "Accent")

				local toggleBtn = Instance.new("TextButton")
				toggleBtn.Size = UDim2.new(1, 0, 1, 0)
				toggleBtn.BackgroundTransparency = 1
				toggleBtn.Text = ""
				toggleBtn.Parent = titleBar

				local contentContainer = Instance.new("Frame")
				contentContainer.Size = UDim2.new(1, 0, 0, 0)
				contentContainer.Position = UDim2.new(0, 0, 0, 36)
				contentContainer.BackgroundTransparency = 1
				contentContainer.ClipsDescendants = true
				contentContainer.Parent = sectionFrame

				local contentLayout = Instance.new("UIListLayout")
				contentLayout.Padding = UDim.new(0, 6)
				contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
				contentLayout.Parent = contentContainer

				local currentContentTween, currentSectionTween
				local open = defaultOpen

				local function updateSectionHeight(instant)
					local targetContentHeight = open and contentLayout.AbsoluteContentSize.Y or 0
					local targetSectionHeight = 36 + targetContentHeight
					if currentContentTween then currentContentTween:Cancel() end
					if currentSectionTween then currentSectionTween:Cancel() end
					local tweenInfo = TweenInfo.new(instant and 0 or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					currentContentTween = TweenService:Create(contentContainer, tweenInfo, {Size = UDim2.new(1, 0, 0, targetContentHeight)})
					currentSectionTween = TweenService:Create(sectionFrame, tweenInfo, {Size = UDim2.new(1, 0, 0, targetSectionHeight)})
					currentContentTween:Play()
					currentSectionTween:Play()
				end

				task.spawn(function()
					task.wait()
					updateSectionHeight(true)
				end)

				local function toggle()
					open = not open
					iconLabel.Image = open and iconOpen or iconClosed
					updateSectionHeight(false)
				end

				toggleBtn.MouseButton1Click:Connect(function()
					PlaySound(Sounds.Click)
					toggle()
				end)

				contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					if open then
						updateSectionHeight(false)
					end
				end)

				local child = {}

				-- Button (maclib 风格)
				child.Button = function(_, btnText, callback)
					local Btn = Instance.new("TextButton")
					Btn.Size = UDim2.new(1, 0, 0, 35)
					Btn.Text = ""
					Btn.Font = Enum.Font.Gotham
					Btn.TextSize = 14
					Btn.Parent = contentContainer
					Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
					AddToRegistry(Btn, "BackgroundColor3", "Top")

					local TextLabel = Instance.new("TextLabel")
					TextLabel.Size = UDim2.new(1, -30, 1, 0)
					TextLabel.Position = UDim2.new(0, 10, 0, 0)
					TextLabel.BackgroundTransparency = 1
					TextLabel.Font = Enum.Font.Gotham
					TextLabel.Text = btnText
					TextLabel.TextSize = 14
					TextLabel.TextXAlignment = Enum.TextXAlignment.Left
					TextLabel.Parent = Btn
					AddToRegistry(TextLabel, "TextColor3", "Text")

					local Icon = Instance.new("ImageLabel")
					Icon.Size = UDim2.new(0, 15, 0, 15)
					Icon.Position = UDim2.new(1, -20, 0.5, -7.5)
					Icon.BackgroundTransparency = 1
					Icon.Image = assets.buttonImage
					Icon.ImageTransparency = 0.5
					Icon.Parent = Btn
					AddToRegistry(Icon, "ImageColor3", "Text")

					local function onHover()
						Tween(Icon, {ImageTransparency = 0}, 0.2)
					end
					local function onLeave()
						Tween(Icon, {ImageTransparency = 0.5}, 0.2)
					end

					Btn.MouseEnter:Connect(onHover)
					Btn.MouseLeave:Connect(onLeave)

					Btn.MouseButton1Click:Connect(function()
						PlaySound(Sounds.Click)
						Tween(Btn, {Size = UDim2.new(0.95, 0, 0, 32)}, 0.1)
						task.wait(0.1)
						Tween(Btn, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
						callback()
					end)

					local self = {}
					function self.UpdateText(newText)
						TextLabel.Text = newText
					end
					function self.SetVisible(state)
						Btn.Visible = state
					end
					return self
				end

				-- Toggle (maclib 风格)
				child.Toggle = function(_, toggleText, default, callback)
					local Enabled = default or false

					local Btn = Instance.new("TextButton")
					Btn.Size = UDim2.new(1, 0, 0, 35)
					Btn.Text = ""
					Btn.Parent = contentContainer
					Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
					AddToRegistry(Btn, "BackgroundColor3", "Top")

					local Title = Instance.new("TextLabel")
					Title.Text = toggleText
					Title.Size = UDim2.new(0.7, 0, 1, 0)
					Title.Position = UDim2.new(0, 10, 0, 0)
					Title.BackgroundTransparency = 1
					Title.Font = Enum.Font.Gotham
					Title.TextSize = 14
					Title.TextXAlignment = Enum.TextXAlignment.Left
					Title.Parent = Btn
					AddToRegistry(Title, "TextColor3", "Text")

					local Switch = Instance.new("ImageLabel")
					Switch.Size = UDim2.new(0, 40, 0, 20)
					Switch.Position = UDim2.new(1, -50, 0.5, -10)
					Switch.BackgroundTransparency = 1
					Switch.Image = ToggleAssets.Bg
					Switch.ImageColor3 = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
					Switch.Parent = Btn

					local Dot = Instance.new("ImageLabel")
					Dot.Size = UDim2.new(0, 16, 0, 16)
					Dot.BackgroundTransparency = 1
					Dot.Image = ToggleAssets.Head
					Dot.ImageColor3 = Color3.new(1, 1, 1)
					Dot.AnchorPoint = Vector2.new(0.5, 0.5)
					Dot.Parent = Switch
					Dot.Position = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)

					local function Update()
						if Enabled then PlaySound(Sounds.ToggleOn) else PlaySound(Sounds.ToggleOff) end
						local targetColor = Enabled and CurrentTheme.Accent or Color3.fromRGB(60, 60, 60)
						Tween(Switch, {ImageColor3 = targetColor}, 0.2)
						local targetPos = Enabled and UDim2.new(1, -8, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
						Tween(Dot, {Position = targetPos}, 0.2)
						callback(Enabled)
					end

					Btn.MouseButton1Click:Connect(function()
						Enabled = not Enabled
						Update()
					end)

					local self = {}
					function self.UpdateName(newText)
						Title.Text = newText
					end
					function self.SetVisible(state)
						Btn.Visible = state
					end
					function self.UpdateState(state)
						Enabled = state
						Update()
					end
					function self.GetState()
						return Enabled
					end
					return self
				end

				-- Slider (maclib 风格)
				child.Slider = function(_, sliderText, min, max, default, callback, options)
					options = options or {}
					local Val = default or min

					local Frame = Instance.new("Frame")
					Frame.Size = UDim2.new(1, 0, 0, 60)
					Frame.Parent = contentContainer
					Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
					AddToRegistry(Frame, "BackgroundColor3", "Top")

					local TopRow = Instance.new("Frame")
					TopRow.Size = UDim2.new(1, -20, 0, 30)
					TopRow.Position = UDim2.new(0, 10, 0, 5)
					TopRow.BackgroundTransparency = 1
					TopRow.Parent = Frame

					local Lbl = Instance.new("TextLabel")
					Lbl.Text = sliderText
					Lbl.Size = UDim2.new(0.5, 0, 1, 0)
					Lbl.BackgroundTransparency = 1
					Lbl.Font = Enum.Font.Gotham
					Lbl.TextSize = 14
					Lbl.TextXAlignment = Enum.TextXAlignment.Left
					Lbl.Parent = TopRow
					AddToRegistry(Lbl, "TextColor3", "Text")

					local NumBox = Instance.new("TextBox")
					NumBox.FontFace = Font.new(assets.interFont)
					NumBox.Text = tostring(Val)
					NumBox.TextColor3 = Color3.fromRGB(255, 255, 255)
					NumBox.TextSize = 12
					NumBox.TextTransparency = 0.1
					NumBox.TextXAlignment = Enum.TextXAlignment.Center
					NumBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					NumBox.BackgroundTransparency = 0.95
					NumBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
					NumBox.BorderSizePixel = 0
					NumBox.Size = UDim2.fromOffset(41, 21)
					NumBox.AnchorPoint = Vector2.new(1, 0.5)
					NumBox.Position = UDim2.new(1, 0, 0.5, 0)
					NumBox.ClipsDescendants = true
					NumBox.Parent = TopRow

					local boxCorner = Instance.new("UICorner")
					boxCorner.CornerRadius = UDim.new(0, 4)
					boxCorner.Parent = NumBox

					local boxStroke = Instance.new("UIStroke")
					boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					boxStroke.Color = Color3.fromRGB(255, 255, 255)
					boxStroke.Transparency = 0.9
					boxStroke.Parent = NumBox

					local boxPadding = Instance.new("UIPadding")
					boxPadding.PaddingLeft = UDim.new(0, 2)
					boxPadding.PaddingRight = UDim.new(0, 2)
					boxPadding.Parent = NumBox

					local SliderBar = Instance.new("ImageLabel")
					SliderBar.Name = "SliderBar"
					SliderBar.Image = SliderAssets.Bar
					SliderBar.ImageColor3 = Color3.fromRGB(87, 86, 86)
					SliderBar.BackgroundTransparency = 1
					SliderBar.Size = UDim2.new(1, -20, 0, 3)
					SliderBar.Position = UDim2.new(0, 10, 0, 40)
					SliderBar.Parent = Frame

					local SliderHead = Instance.new("ImageButton")
					SliderHead.Name = "SliderHead"
					SliderHead.Image = SliderAssets.Head
					SliderHead.AnchorPoint = Vector2.new(0.5, 0.5)
					SliderHead.BackgroundTransparency = 1
					SliderHead.Size = UDim2.fromOffset(16, 16)
					SliderHead.Parent = SliderBar
					local initPosX = (Val - min) / (max - min)
					SliderHead.Position = UDim2.new(initPosX, 0, 0.5, 0)

					local DisplayMethods = {
						Value = function(sliderValue, precision)
							return precision and string.format("%." .. precision .. "f", sliderValue) or tostring(math.round(sliderValue * 100) / 100)
						end,
						Percent = function(sliderValue, precision)
							local percentage = (sliderValue - min) / (max - min) * 100
							return (precision and string.format("%." .. precision .. "f", percentage) or tostring(math.round(percentage))) .. "%"
						end,
					}
					local displayMethod = DisplayMethods[options.DisplayMethod] or DisplayMethods.Value
					local precision = options.Precision

					local function SetValue(input, ignorecallback)
						local posXScale
						if typeof(input) == "Instance" then
							local mouseX = input.Position.X
							local barX = SliderBar.AbsolutePosition.X
							local barWidth = SliderBar.AbsoluteSize.X
							posXScale = math.clamp((mouseX - barX) / barWidth, 0, 1)
						else
							posXScale = (input - min) / (max - min)
						end

						SliderHead.Position = UDim2.new(posXScale, 0, 0.5, 0)
						local newValue = min + posXScale * (max - min)
						Val = newValue

						NumBox.Text = displayMethod(newValue, precision)

						if not ignorecallback then
							task.spawn(function()
								if callback then callback(newValue) end
							end)
						end
					end

					SetValue(Val, true)

					local dragging = false
					SliderHead.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							PlaySound(Sounds.Slide)
							SetValue(input)
						end
					end)
					SliderHead.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = false
						end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							SetValue(input)
						end
					end)

					NumBox.FocusLost:Connect(function(enterPressed)
						local inputText = NumBox.Text
						local value = tonumber(inputText:match("%d+%.?%d*"))
						if value then
							if options.DisplayMethod == "Percent" then
								value = min + (value / 100) * (max - min)
							end
							local newValue = math.clamp(value, min, max)
							SetValue(newValue, false)
						else
							SetValue(Val, true)
						end
					end)

					local self = {}
					function self.UpdateName(newText)
						Lbl.Text = newText
					end
					function self.SetVisible(state)
						Frame.Visible = state
					end
					function self.UpdateValue(val)
						SetValue(tonumber(val), true)
					end
					function self.GetValue()
						return Val
					end
					return self
				end

				-- Textbox (Input)
				child.Textbox = function(_, boxText, placeholder, callback)
					local Frame = Instance.new("Frame")
					Frame.Size = UDim2.new(1,0,0,60)
					Frame.Parent = contentContainer
					Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,6)
					AddToRegistry(Frame, "BackgroundColor3", "Top")

					local Lbl = Instance.new("TextLabel")
					Lbl.Text = boxText
					Lbl.Size = UDim2.new(1,0,0,20)
					Lbl.Position = UDim2.new(0,10,0,5)
					Lbl.BackgroundTransparency = 1
					Lbl.Font = Enum.Font.Gotham
					Lbl.TextSize = 14
					Lbl.TextXAlignment = Enum.TextXAlignment.Left
					Lbl.Parent = Frame
					AddToRegistry(Lbl, "TextColor3", "Text")

					local Box = Instance.new("TextBox")
					Box.Size = UDim2.new(1,-20,0,25)
					Box.Position = UDim2.new(0,10,0,28)
					Box.Text = ""
					Box.PlaceholderText = placeholder
					Box.Font = Enum.Font.Gotham
					Box.TextSize = 13
					Box.BorderSizePixel = 0
					Box.Parent = Frame
					Instance.new("UICorner", Box).CornerRadius = UDim.new(0,4)
					AddToRegistry(Box, "BackgroundColor3", "Main")
					AddToRegistry(Box, "TextColor3", "Text")

					local boxStroke = Instance.new("UIStroke")
					boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					boxStroke.Color = Color3.fromRGB(255, 255, 255)
					boxStroke.Transparency = 0.9
					boxStroke.Parent = Box

					Box.FocusLost:Connect(function()
						callback(Box.Text)
					end)

					local self = {}
					function self.UpdateText(newText)
						Box.Text = newText
					end
					function self.GetText()
						return Box.Text
					end
					function self.SetVisible(state)
						Frame.Visible = state
					end
					function self.UpdatePlaceholder(newPlaceholder)
						Box.PlaceholderText = newPlaceholder
					end
					return self
				end

				-- Dropdown (使用 maclib 的 dropdown 图标)
				child.Dropdown = function(_, dropText, options, callback)
					local Dropped = false
					local Btn = Instance.new("TextButton")
					Btn.Size = UDim2.new(1,0,0,35)
					Btn.Text = ""
					Btn.Parent = contentContainer
					Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)
					AddToRegistry(Btn, "BackgroundColor3", "Top")
					local Lbl = Instance.new("TextLabel")
					Lbl.Text = dropText
					Lbl.Size = UDim2.new(1,-30,1,0)
					Lbl.Position = UDim2.new(0,10,0,0)
					Lbl.BackgroundTransparency = 1
					Lbl.Font = Enum.Font.Gotham
					Lbl.TextSize = 14
					Lbl.TextXAlignment = Enum.TextXAlignment.Left
					Lbl.Parent = Btn
					AddToRegistry(Lbl, "TextColor3", "Text")
					local Icon = Instance.new("ImageLabel")
					Icon.Image = assets.dropdown
					Icon.Size = UDim2.new(0,20,0,20)
					Icon.Position = UDim2.new(1,-30,0.5,-10)
					Icon.BackgroundTransparency = 1
					Icon.Parent = Btn

					local Container = Instance.new("Frame")
					Container.Size = UDim2.new(1,0,0,0)
					Container.Visible = false
					Container.ClipsDescendants = true
					Container.Parent = contentContainer
					Container.ZIndex = 10
					Instance.new("UICorner", Container).CornerRadius = UDim.new(0,6)
					AddToRegistry(Container, "BackgroundColor3", "Top")
					local List = Instance.new("UIListLayout")
					List.SortOrder = Enum.SortOrder.LayoutOrder
					List.Parent = Container

					local function Select(opt)
						Dropped = false
						Lbl.Text = dropText..": "..opt
						callback(opt)
						Tween(Container, {Size = UDim2.new(1,0,0,0)}, 0.2)
						Tween(Icon, {Rotation = 0}, 0.2)
						task.wait(0.2)
						Container.Visible = false
						updateSectionHeight(false)
					end

					local function RefreshOptions(newOpts)
						for _,v in pairs(Container:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
						for _, opt in pairs(newOpts) do
							local O = Instance.new("TextButton")
							O.Size = UDim2.new(1,0,0,30)
							O.Text = opt
							O.TextColor3 = Color3.fromRGB(150,150,150)
							O.Font = Enum.Font.Gotham
							O.TextSize = 13
							O.BackgroundTransparency = 1
							O.Parent = Container
							O.MouseButton1Click:Connect(function() Select(opt) end)
						end
					end
					RefreshOptions(options)

					Btn.MouseButton1Click:Connect(function()
						Dropped = not Dropped
						PlaySound(Sounds.Click)
						if Dropped then
							Container.Visible = true
							local targetHeight = #options * 30
							local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, targetHeight)})
							tweenOpt:Play()
							Tween(Icon, {Rotation = 180}, 0.3)
							tweenOpt.Completed:Connect(function()
								updateSectionHeight(false)
							end)
						else
							local tweenOpt = TweenService:Create(Container, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, 0)})
							tweenOpt:Play()
							Tween(Icon, {Rotation = 0}, 0.2)
							tweenOpt.Completed:Connect(function()
								Container.Visible = false
								updateSectionHeight(false)
							end)
						end
					end)

					local self = {}
					function self.UpdateName(newText)
						Lbl.Text = newText
					end
					function self.SetVisible(state)
						Btn.Visible = state
					end
					function self.UpdateSelection(opt)
						Select(opt)
					end
					function self.InsertOptions(newOpts)
						RefreshOptions(newOpts)
					end
					function self.ClearOptions()
						RefreshOptions({})
					end
					function self.GetOptions()
						local opts = {}
						for _, v in pairs(Container:GetChildren()) do
							if v:IsA("TextButton") then
								table.insert(opts, v.Text)
							end
						end
						return opts
					end
					return self
				end

				-- Keybind (带边框)
				child.Keybind = function(_, keyText, default, callback)
					local Key = default or Enum.KeyCode.M

					local Btn = Instance.new("TextButton")
					Btn.Size = UDim2.new(1, 0, 0, 40)
					Btn.Text = ""
					Btn.Parent = contentContainer
					Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
					AddToRegistry(Btn, "BackgroundColor3", "Top")

					local Title = Instance.new("TextLabel")
					Title.Text = keyText
					Title.Size = UDim2.new(0.6, 0, 1, 0)
					Title.Position = UDim2.new(0, 10, 0, 0)
					Title.BackgroundTransparency = 1
					Title.Font = Enum.Font.Gotham
					Title.TextSize = 14
					Title.TextXAlignment = Enum.TextXAlignment.Left
					Title.Parent = Btn
					AddToRegistry(Title, "TextColor3", "Text")

					local BinderBox = Instance.new("TextBox")
					BinderBox.Name = "BinderBox"
					BinderBox.Font = Enum.Font.GothamBold
					BinderBox.Text = Key.Name
					BinderBox.TextColor3 = Color3.fromRGB(255, 255, 255)
					BinderBox.TextSize = 13
					BinderBox.TextTransparency = 0.1
					BinderBox.PlaceholderText = "..."
					BinderBox.BackgroundTransparency = 0.2
					BinderBox.BorderSizePixel = 0
					BinderBox.Size = UDim2.new(0, 80, 0, 24)
					BinderBox.Position = UDim2.new(1, -90, 0.5, -12)
					BinderBox.Parent = Btn
					Instance.new("UICorner", BinderBox).CornerRadius = UDim.new(0, 5)
					AddToRegistry(BinderBox, "BackgroundColor3", "Main")
					AddToRegistry(BinderBox, "TextColor3", "Accent")

					local boxStroke = Instance.new("UIStroke")
					boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					boxStroke.Color = Color3.fromRGB(255, 255, 255)
					boxStroke.Transparency = 0.9
					boxStroke.Parent = BinderBox

					local isBinding = false
					local focused = false

					Btn.MouseButton1Click:Connect(function()
						PlaySound(Sounds.Click)
						BinderBox:CaptureFocus()
					end)

					BinderBox.Focused:Connect(function()
						focused = true
						isBinding = true
						BinderBox.Text = ""
						BinderBox.PlaceholderText = "..."
					end)

					BinderBox.FocusLost:Connect(function()
						focused = false
						isBinding = false
						BinderBox.Text = Key.Name
						BinderBox.PlaceholderText = ""
					end)

					UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if gameProcessed then return end
						if focused and isBinding then
							local newKey
							if input.UserInputType == Enum.UserInputType.Keyboard then
								newKey = input.KeyCode
							elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
								newKey = input.UserInputType
							end
							if newKey and newKey.Name ~= "Unknown" then
								Key = newKey
								BinderBox.Text = Key.Name
								callback(Key)
							end
							BinderBox:ReleaseFocus()
						end
					end)

					local self = {}
					function self.UpdateName(newText)
						Title.Text = newText
					end
					function self.SetVisible(state)
						Btn.Visible = state
					end
					function self.Bind(newKey)
						Key = newKey
						BinderBox.Text = Key.Name
					end
					function self.Unbind()
						Key = nil
						BinderBox.Text = ""
					end
					function self.GetBind()
						return Key
					end
					return self
				end

				-- Input (maclib 风格)
				child.Input = function(_, inputText, default, callback, options)
					options = options or {}
					local placeholder = options.placeholder or ""
					local acceptedCharacters = options.acceptedCharacters or "All"
					local characterLimit = options.characterLimit
					local onChanged = options.onChanged

					local InputFrame = Instance.new("Frame")
					InputFrame.Size = UDim2.new(1, 0, 0, 35)
					InputFrame.Parent = contentContainer
					Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)
					AddToRegistry(InputFrame, "BackgroundColor3", "Top")

					local NameLbl = Instance.new("TextLabel")
					NameLbl.Text = inputText
					NameLbl.Size = UDim2.new(0.6, 0, 1, 0)
					NameLbl.Position = UDim2.new(0, 10, 0, 0)
					NameLbl.TextXAlignment = Enum.TextXAlignment.Left
					NameLbl.Font = Enum.Font.Gotham
					NameLbl.TextSize = 14
					NameLbl.BackgroundTransparency = 1
					NameLbl.Parent = InputFrame
					AddToRegistry(NameLbl, "TextColor3", "Text")

					local InputBox = Instance.new("TextBox")
					InputBox.Text = tostring(default or "")
					InputBox.PlaceholderText = placeholder
					InputBox.Size = UDim2.new(0.3, 0, 0, 26)
					InputBox.Position = UDim2.new(0.7, -10, 0.5, -13)
					InputBox.Font = Enum.Font.GothamBold
					InputBox.TextSize = 13
					InputBox.TextXAlignment = Enum.TextXAlignment.Center
					InputBox.ClearTextOnFocus = false
					InputBox.Parent = InputFrame

					local boxCorner = Instance.new("UICorner")
					boxCorner.CornerRadius = UDim.new(0, 5)
					boxCorner.Parent = InputBox

					AddToRegistry(InputBox, "BackgroundColor3", "Main")
					AddToRegistry(InputBox, "TextColor3", "Accent")

					local boxStroke = Instance.new("UIStroke")
					boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					boxStroke.Color = Color3.fromRGB(255, 255, 255)
					boxStroke.Transparency = 0.9
					boxStroke.Parent = InputBox

					local function filterText(text)
						if characterLimit then
							text = text:sub(1, characterLimit)
						end
						if type(acceptedCharacters) == "function" then
							return acceptedCharacters(text)
						elseif acceptedCharacters == "Numeric" then
							return text:gsub("[^%d-]", ""):gsub("-(.*)", function(m) return m:gsub("-", "") end)
						elseif acceptedCharacters == "Alphabetic" then
							return text:gsub("[^a-zA-Z]", "")
						elseif acceptedCharacters == "AlphaNumeric" then
							return text:gsub("[^a-zA-Z0-9]", "")
						else
							return text
						end
					end

					InputBox:GetPropertyChangedSignal("Text"):Connect(function()
						local filtered = filterText(InputBox.Text)
						if filtered ~= InputBox.Text then
							InputBox.Text = filtered
						end
						if onChanged then
							onChanged(filtered)
						end
					end)

					InputBox.FocusLost:Connect(function(enterPressed)
						local text = InputBox.Text
						local filtered = filterText(text)
						if filtered ~= text then
							InputBox.Text = filtered
							text = filtered
						end
						if callback then
							callback(text)
						end
					end)

					local self = {}
					function self.UpdateText(newText)
						InputBox.Text = tostring(newText)
					end
					function self.GetText()
						return InputBox.Text
					end
					function self.SetVisible(state)
						InputFrame.Visible = state
					end
					function self.UpdatePlaceholder(newPlaceholder)
						InputBox.PlaceholderText = newPlaceholder
					end
					return self
				end

				return child
			end

			return Elements
		end

		-- 返回的窗口对象包含 MainFrame 和 ScreenGui 以便外部访问
		return {
			MainFrame = MainFrame,
			ScreenGui = ScreenGui,
			Notification = Window.Notification,
			SetKeybind = Window.SetKeybind,
			Destroy = Window.Destroy,
			Tab = Window.Tab,
		}
	end

	return Library
end)()
-- ==================== 嵌入结束 ====================

--// Functions
local function GetGui()
	local newGui = Instance.new("ScreenGui")
	newGui.ScreenInsets = Enum.ScreenInsets.None
	newGui.ResetOnSpawn = false
	newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	newGui.DisplayOrder = 2147483647

	local parent = RunService:IsStudio() 
		and LocalPlayer:FindFirstChild("PlayerGui")
		or (gethui and gethui())
		or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))

	newGui.Parent = parent
	return newGui
end

local function Tween(instance, tweeninfo, propertytable)
	return TweenService:Create(instance, tweeninfo, propertytable)
end

--// Library Functions
function MacLib:Window(Settings)
	local WindowFunctions = {Settings = Settings}
	if Settings.AcrylicBlur ~= nil then
		acrylicBlur = Settings.AcrylicBlur
	else
		acrylicBlur = true
	end

	-- 创建新 UI 窗口
	local newWin = NewUI:CreateWindow({
		Title = Settings.Title,
		Keybind = Settings.Keybind,
	})
	local base = newWin.MainFrame
	local macLib = newWin.ScreenGui

	-- 通知层 (使用 maclib 原有的通知系统，但放置在新 GUI 中)
	local notifications = Instance.new("Frame")
	notifications.Name = "Notifications"
	notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notifications.BackgroundTransparency = 1
	notifications.BorderColor3 = Color3.fromRGB(0, 0, 0)
	notifications.BorderSizePixel = 0
	notifications.Size = UDim2.fromScale(1, 1)
	notifications.Parent = macLib
	notifications.ZIndex = 2

	local notificationsUIListLayout = Instance.new("UIListLayout")
	notificationsUIListLayout.Name = "NotificationsUIListLayout"
	notificationsUIListLayout.Padding = UDim.new(0, 10)
	notificationsUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notificationsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationsUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notificationsUIListLayout.Parent = notifications

	local notificationsUIPadding = Instance.new("UIPadding")
	notificationsUIPadding.Name = "NotificationsUIPadding"
	notificationsUIPadding.PaddingBottom = UDim.new(0, 10)
	notificationsUIPadding.PaddingLeft = UDim.new(0, 10)
	notificationsUIPadding.PaddingRight = UDim.new(0, 10)
	notificationsUIPadding.PaddingTop = UDim.new(0, 10)
	notificationsUIPadding.Parent = notifications

	-- 全局设置面板 (maclib 原有)
	local globalSettings = Instance.new("Frame")
	globalSettings.Name = "GlobalSettings"
	globalSettings.AutomaticSize = Enum.AutomaticSize.XY
	globalSettings.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	globalSettings.BorderColor3 = Color3.fromRGB(0, 0, 0)
	globalSettings.BorderSizePixel = 0
	globalSettings.Position = UDim2.fromScale(0.298, 0.104)

	local globalSettingsUIStroke = Instance.new("UIStroke")
	globalSettingsUIStroke.Name = "GlobalSettingsUIStroke"
	globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
	globalSettingsUIStroke.Transparency = 0.9
	globalSettingsUIStroke.Parent = globalSettings

	local globalSettingsUICorner = Instance.new("UICorner")
	globalSettingsUICorner.Name = "GlobalSettingsUICorner"
	globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
	globalSettingsUICorner.Parent = globalSettings

	local globalSettingsUIPadding = Instance.new("UIPadding")
	globalSettingsUIPadding.Name = "GlobalSettingsUIPadding"
	globalSettingsUIPadding.PaddingBottom = UDim.new(0, 10)
	globalSettingsUIPadding.PaddingTop = UDim.new(0, 10)
	globalSettingsUIPadding.Parent = globalSettings

	local globalSettingsUIListLayout = Instance.new("UIListLayout")
	globalSettingsUIListLayout.Name = "GlobalSettingsUIListLayout"
	globalSettingsUIListLayout.Padding = UDim.new(0, 5)
	globalSettingsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	globalSettingsUIListLayout.Parent = globalSettings

	local globalSettingsUIScale = Instance.new("UIScale")
	globalSettingsUIScale.Name = "GlobalSettingsUIScale"
	globalSettingsUIScale.Scale = 1e-07
	globalSettingsUIScale.Parent = globalSettings
	globalSettings.Parent = base

	-- 全局设置按钮 (在标题栏右侧)
	local globalSettingsButton = Instance.new("ImageButton")
	globalSettingsButton.Name = "GlobalSettingsButton"
	globalSettingsButton.Image = assets.globe
	globalSettingsButton.ImageTransparency = 0.5
	globalSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
	globalSettingsButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	globalSettingsButton.BackgroundTransparency = 1
	globalSettingsButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	globalSettingsButton.BorderSizePixel = 0
	globalSettingsButton.Position = UDim2.fromScale(1, 0.5)
	globalSettingsButton.Size = UDim2.fromOffset(16,16)
	globalSettingsButton.Parent = base.Topbar  -- 将按钮放在新 UI 的标题栏上

	local function ChangeGlobalSettingsButtonState(State)
		if State == "Default" then
			Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				ImageTransparency = 0.5
			}):Play()
		elseif State == "Hover" then
			Tween(globalSettingsButton, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				ImageTransparency = 0.3
			}):Play()
		end
	end

	globalSettingsButton.MouseEnter:Connect(function()
		ChangeGlobalSettingsButtonState("Hover")
	end)
	globalSettingsButton.MouseLeave:Connect(function()
		ChangeGlobalSettingsButtonState("Default")
	end)

	-- 亚克力模糊效果 (基于 base)
	local BlurTarget = base

	local HS = HttpService
	local camera = workspace.CurrentCamera
	local MTREL = "Glass"
	local wedgeguid = HS:GenerateGUID(true)

	local DepthOfField

	for _,v in pairs(Lighting:GetChildren()) do
		if not v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
			DepthOfField = Instance.new('DepthOfFieldEffect')
			DepthOfField.FarIntensity = 0
			DepthOfField.FocusDistance = 51.6
			DepthOfField.InFocusRadius = 50
			DepthOfField.NearIntensity = 1
			DepthOfField.Name = HS:GenerateGUID(true)
			DepthOfField:AddTag(".")
		elseif v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
			DepthOfField = v
		end
	end

	if not DepthOfField then
		DepthOfField = Instance.new('DepthOfFieldEffect')
		DepthOfField.FarIntensity = 0
		DepthOfField.FocusDistance = 51.6
		DepthOfField.InFocusRadius = 50
		DepthOfField.NearIntensity = 1
		DepthOfField.Name = HS:GenerateGUID(true)
		DepthOfField:AddTag(".")
	end

	local frame = Instance.new('Frame')
	frame.Parent = BlurTarget
	frame.Size = UDim2.new(0.97, 0, 0.97, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.Name = HS:GenerateGUID(true)

	do
		local function IsNotNaN(x)
			return x == x
		end
		local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		while not continue do
			RunService.RenderStepped:Wait()
			continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		end
	end

	local DrawQuad; do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		local sz = 0.2

		local function DrawTriangle(v1, v2, v3, p0, p1)
			local s1 = (v1 - v2).magnitude
			local s2 = (v2 - v3).magnitude
			local s3 = (v3 - v1).magnitude
			local smax = max(s1, s2, s3)
			local A, B, C
			if s1 == smax then
				A, B, C = v1, v2, v3
			elseif s2 == smax then
				A, B, C = v2, v3, v1
			elseif s3 == smax then
				A, B, C = v3, v1, v2
			end

			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
			local perp = sqrt((C-A).magnitude^2 - para*para)
			local dif_para = (A - B).magnitude - para

			local st = CFrame.new(B, A)
			local za = CFrame.Angles(pi/2,0,0)

			local cf0 = st

			local Top_Look = (cf0 * za).lookVector
			local Mid_Point = A + CFrame.new(A, B).lookVector * para
			local Needed_Look = CFrame.new(Mid_Point, C).lookVector
			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z

			local ac = CFrame.Angles(0, 0, acos(dot))

			cf0 = cf0 * ac
			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
			end
			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			end
			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

			if not p0 then
				p0 = Instance.new('Part')
				p0.FormFactor = 'Custom'
				p0.TopSurface = 0
				p0.BottomSurface = 0
				p0.Anchored = true
				p0.CanCollide = false
				p0.CastShadow = false
				p0.Material = MTREL
				p0.Size = Vector3.new(sz, sz, sz)
				p0.Name = HS:GenerateGUID(true)
				local mesh = Instance.new('SpecialMesh', p0)
				mesh.MeshType = 2
				mesh.Name = wedgeguid
			end
			p0[wedgeguid].Scale = Vector3.new(0, perp/sz, para/sz)
			p0.CFrame = cf0

			if not p1 then
				p1 = p0:clone()
			end
			p1[wedgeguid].Scale = Vector3.new(0, perp/sz, dif_para/sz)
			p1.CFrame = cf1

			return p0, p1
		end

		function DrawQuad(v1, v2, v3, v4, parts)
			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
		end
	end

	local parts = {}

	local parents = {}
	do
		local function add(child)
			if child:IsA'GuiObject' then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(frame)
	end

	local function IsVisible(instance)
		while instance do
			if instance:IsA("GuiObject") then
				if not instance.Visible then
					return false
				end
			elseif instance:IsA("ScreenGui") then
				if not instance.Enabled then
					return false
				end
				break
			end
			instance = instance.Parent
		end
		return true
	end

	local function UpdateOrientation(fetchProps)
		if not IsVisible(frame) or not acrylicBlur or unloaded then
			for _, pt in pairs(parts) do
				pt.Parent = nil
				DepthOfField.Enabled = false
				DepthOfField.Parent = nil
			end
			return
		end
		if not DepthOfField.Parent then
			DepthOfField.Parent = Lighting
		end
		DepthOfField.Enabled = true
		local properties = {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		}
		local zIndex = 1 - 0.05*frame.ZIndex

		local tl, br = frame.AbsolutePosition, frame.AbsolutePosition + frame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0;
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot%180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				local vec = tl
				tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
				tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
				bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
				br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
			end
		end
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
			parts
		)
		if fetchProps then
			for _, pt in pairs(parts) do
				pt.Parent = camera
			end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do
					pt[propName] = propValue
				end
			end
		end
	end

	UpdateOrientation(true)

	RunService.RenderStepped:Connect(UpdateOrientation)

	-- 全局设置功能
	local hovering
	local toggled = globalSettingsUIScale.Scale == 1 and true or false
	local function toggle()
		if not toggled then
			local intween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = 1
			})
			intween:Play()
			intween.Completed:Wait()
			toggled = true
		elseif toggled then
			local outtween = Tween(globalSettingsUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = 0
			})
			outtween:Play()
			outtween.Completed:Wait()
			toggled = false
		end
	end
	globalSettingsButton.MouseButton1Click:Connect(function()
		if not hasGlobalSetting then return end
		toggle()
	end)
	globalSettings.MouseEnter:Connect(function()
		hovering = true
	end)
	globalSettings.MouseLeave:Connect(function()
		hovering = false
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 and toggled and not hovering then
			toggle()
		end
	end)

	-- 窗口状态
	windowState = true

	-- 返回的 WindowFunctions 需要适配新 UI 的 API
	function WindowFunctions:GlobalSetting(Settings)
		hasGlobalSetting = true
		local GlobalSettingFunctions = {}
		local globalSetting = Instance.new("TextButton")
		globalSetting.Name = "GlobalSetting"
		globalSetting.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
		globalSetting.Text = ""
		globalSetting.TextColor3 = Color3.fromRGB(0, 0, 0)
		globalSetting.TextSize = 14
		globalSetting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		globalSetting.BackgroundTransparency = 1
		globalSetting.BorderColor3 = Color3.fromRGB(0, 0, 0)
		globalSetting.BorderSizePixel = 0
		globalSetting.Size = UDim2.fromOffset(200, 30)

		local globalSettingToggleUIPadding = Instance.new("UIPadding")
		globalSettingToggleUIPadding.Name = "GlobalSettingToggleUIPadding"
		globalSettingToggleUIPadding.PaddingLeft = UDim.new(0, 15)
		globalSettingToggleUIPadding.Parent = globalSetting

		local settingName = Instance.new("TextLabel")
		settingName.Name = "SettingName"
		settingName.FontFace = Font.new(assets.interFont)
		settingName.Text = Settings.Name
		settingName.RichText = true
		settingName.TextColor3 = Color3.fromRGB(255, 255, 255)
		settingName.TextSize = 13
		settingName.TextTransparency = 0.5
		settingName.TextTruncate = Enum.TextTruncate.SplitWord
		settingName.TextXAlignment = Enum.TextXAlignment.Left
		settingName.TextYAlignment = Enum.TextYAlignment.Top
		settingName.AnchorPoint = Vector2.new(0, 0.5)
		settingName.AutomaticSize = Enum.AutomaticSize.Y
		settingName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		settingName.BackgroundTransparency = 1
		settingName.BorderColor3 = Color3.fromRGB(0, 0, 0)
		settingName.BorderSizePixel = 0
		settingName.Position = UDim2.fromScale(1.3e-07, 0.5)
		settingName.Size = UDim2.new(1,-40,0,0)
		settingName.Parent = globalSetting

		local globalSettingToggleUIListLayout = Instance.new("UIListLayout")
		globalSettingToggleUIListLayout.Name = "GlobalSettingToggleUIListLayout"
		globalSettingToggleUIListLayout.Padding = UDim.new(0, 10)
		globalSettingToggleUIListLayout.FillDirection = Enum.FillDirection.Horizontal
		globalSettingToggleUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		globalSettingToggleUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		globalSettingToggleUIListLayout.Parent = globalSetting

		local checkmark = Instance.new("TextLabel")
		checkmark.Name = "Checkmark"
		checkmark.FontFace = Font.new(
			assets.interFont,
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		checkmark.Text = "✓"
		checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
		checkmark.TextSize = 13
		checkmark.TextTransparency = 1
		checkmark.TextXAlignment = Enum.TextXAlignment.Left
		checkmark.TextYAlignment = Enum.TextYAlignment.Top
		checkmark.AnchorPoint = Vector2.new(0, 0.5)
		checkmark.AutomaticSize = Enum.AutomaticSize.Y
		checkmark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		checkmark.BackgroundTransparency = 1
		checkmark.BorderColor3 = Color3.fromRGB(0, 0, 0)
		checkmark.BorderSizePixel = 0
		checkmark.LayoutOrder = -1
		checkmark.Position = UDim2.fromScale(1.3e-07, 0.5)
		checkmark.Size = UDim2.fromOffset(-10, 0)
		checkmark.Parent = globalSetting

		globalSetting.Parent = globalSettings

		local tweensettings = {
			duration = 0.2,
			easingStyle = Enum.EasingStyle.Quint,
			transparencyIn = 0.2,
			transparencyOut = 0.5,
			checkSizeIncrease = 12,
			checkSizeDecrease = -globalSettingToggleUIListLayout.Padding.Offset,
			waitTime = 1
		}

		local tweens = {
			checkIn = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle), {
				Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeIncrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
			}),
			checkOut = Tween(checkmark, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
				Size = UDim2.new(checkmark.Size.X.Scale, tweensettings.checkSizeDecrease, checkmark.Size.Y.Scale, checkmark.Size.Y.Offset)
			}),
			nameIn = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
				TextTransparency = tweensettings.transparencyIn
			}),
			nameOut = Tween(settingName, TweenInfo.new(tweensettings.duration, tweensettings.easingStyle),{
				TextTransparency = tweensettings.transparencyOut
			})
		}

		local function Toggle(State)
			if not State then
				tweens.checkOut:Play()
				tweens.nameOut:Play()
				checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if checkmark.AbsoluteSize.X <= 0 then
						checkmark.TextTransparency = 1
					end
				end)
			else
				tweens.checkIn:Play()
				tweens.nameIn:Play()
				checkmark:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					if checkmark.AbsoluteSize.X > 0 then
						checkmark.TextTransparency = 0
					end
				end)
			end
		end

		local toggled = Settings.Default
		Toggle(toggled)

		globalSetting.MouseButton1Click:Connect(function()
			toggled = not toggled
			Toggle(toggled)

			task.spawn(function()
				if Settings.Callback then
					Settings.Callback(toggled)
				end
			end)
		end)

		function GlobalSettingFunctions:UpdateName(NewName)
			settingName.Text = NewName
		end

		function GlobalSettingFunctions:UpdateState(NewState)
			Toggle(NewState)
			toggled = NewState
		end

		return GlobalSettingFunctions
	end

	function WindowFunctions:TabGroup()
		-- 新 UI 没有 TabGroup，直接返回一个包装，其 Tab 方法调用 newWin:Tab
		local TabGroupWrapper = {}
		function TabGroupWrapper:Tab(Settings)
			local tabName = Settings.Name
			local tabIcon = Settings.Image
			local elements = newWin:Tab(tabName, tabIcon)  -- 返回 Elements 对象

			-- 构造 TabFunctions，包含 Section 方法
			local TabFunctions = {Settings = Settings}
			function TabFunctions:Section(SectionSettings)
				-- SectionSettings 包含 Side (Left/Right)，新 UI 的 Section 不支持左右分栏，我们忽略 Side
				-- 创建 Section，标题使用 SectionSettings.Name 或空
				local sectionChild = elements:Section(SectionSettings.Name or "", nil, true)  -- 默认展开
				-- sectionChild 包含了 Button, Toggle 等方法，我们需要将这些方法包装，使其符合 maclib 的 SectionFunctions
				-- 同时要处理 Flag 和注册到 MacLib.Options
				local SectionFunctions = {}

				-- 辅助函数：包装元素创建，处理 Flag
				local function wrapElement(methodName, elementCreator)
					SectionFunctions[methodName] = function(self, Settings, Flag)
						local ctrl = elementCreator(self, Settings.Name, Settings.Default, Settings.Callback, Settings)
						-- 为控制对象添加通用方法
						if not ctrl.UpdateName then
							ctrl.UpdateName = function(newName)
								-- 可能需要根据元素类型更新文本
							end
						end
						if not ctrl.SetVisible then
							ctrl.SetVisible = function(state) end
						end
						-- 注册到 Options
						if Flag then
							MacLib.Options[Flag] = ctrl
						end
						return ctrl
					end
				end

				-- 映射方法
				wrapElement("Button", function(_, text, _, cb) 
					return sectionChild.Button(text, cb) 
				end)
				wrapElement("Toggle", function(_, text, default, cb)
					return sectionChild.Toggle(text, default, cb)
				end)
				wrapElement("Slider", function(_, text, default, cb, opts)
					return sectionChild.Slider(text, opts.Minimum, opts.Maximum, default, cb, opts)
				end)
				wrapElement("Input", function(_, text, default, cb, opts)
					return sectionChild.Input(text, default, cb, opts)
				end)
				wrapElement("Dropdown", function(_, text, default, cb, opts)
					return sectionChild.Dropdown(text, opts.Options, cb)
				end)
				wrapElement("Keybind", function(_, text, default, cb)
					return sectionChild.Keybind(text, default, cb)
				end)

				-- 其他 maclib 特有元素（Label, Paragraph 等）暂不实现，可以添加简单版本
				SectionFunctions.Label = function(_, Settings, Flag)
					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(1,0,0,20)
					lbl.Text = Settings.Text or Settings.Name
					lbl.TextColor3 = Color3.new(1,1,1)
					lbl.BackgroundTransparency = 1
					lbl.Parent = elements._frame  -- 需要获取 section 的 contentContainer，这里简化
					local self = {UpdateName = function(new) lbl.Text = new end, SetVisible = function(s) lbl.Visible = s end}
					if Flag then MacLib.Options[Flag] = self end
					return self
				end

				SectionFunctions.Divider = function()
					local line = Instance.new("Frame")
					line.Size = UDim2.new(1,0,0,1)
					line.BackgroundColor3 = Color3.fromRGB(255,255,255)
					line.BackgroundTransparency = 0.9
					line.Parent = elements._frame
					return {Remove = function() line:Destroy() end, SetVisibility = function(s) line.Visible = s end}
				end

				return SectionFunctions
			end

			return TabFunctions
		end
		return TabGroupWrapper
	end

	-- 通知、对话框、其他方法保持不变
	function WindowFunctions:Notify(Settings)
		-- 使用新 UI 的通知或保留 maclib 的通知？这里保留 maclib 的
		local NotificationFunctions = {}
		local notification = Instance.new("Frame")
		notification.Name = "Notification"
		notification.AnchorPoint = Vector2.new(0.5, 0.5)
		notification.AutomaticSize = Enum.AutomaticSize.Y
		notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notification.BorderSizePixel = 0
		notification.Position = UDim2.fromScale(0.5, 0.5)
		notification.Size = UDim2.fromOffset(Settings.SizeX or 250, 0)
		notification.Parent = notifications

		local notificationUIStroke = Instance.new("UIStroke")
		notificationUIStroke.Name = "NotificationUIStroke"
		notificationUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		notificationUIStroke.Color = Color3.fromRGB(255, 255, 255)
		notificationUIStroke.Transparency = 0.9
		notificationUIStroke.Parent = notification

		local notificationUICorner = Instance.new("UICorner")
		notificationUICorner.Name = "NotificationUICorner"
		notificationUICorner.CornerRadius = UDim.new(0, 10)
		notificationUICorner.Parent = notification

		local notificationUIScale = Instance.new("UIScale")
		notificationUIScale.Name = "NotificationUIScale"
		notificationUIScale.Parent = notification
		notificationUIScale.Scale = 0

		local notificationInformation = Instance.new("Frame")
		notificationInformation.Name = "NotificationInformation"
		notificationInformation.AutomaticSize = Enum.AutomaticSize.Y
		notificationInformation.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationInformation.BackgroundTransparency = 1
		notificationInformation.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationInformation.BorderSizePixel = 0
		notificationInformation.Size = UDim2.fromScale(1, 1)

		local notificationTitle = Instance.new("TextLabel")
		notificationTitle.Name = "NotificationTitle"
		notificationTitle.FontFace = Font.new(assets.interFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		notificationTitle.RichText = true
		notificationTitle.Text = Settings.Title
		notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationTitle.TextSize = 13
		notificationTitle.TextTransparency = 0.2
		notificationTitle.TextTruncate = Enum.TextTruncate.SplitWord
		notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
		notificationTitle.TextYAlignment = Enum.TextYAlignment.Top
		notificationTitle.AutomaticSize = Enum.AutomaticSize.XY
		notificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationTitle.BackgroundTransparency = 1
		notificationTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationTitle.BorderSizePixel = 0
		notificationTitle.Size = UDim2.new(1, -12, 0, 0)
		notificationTitle.Parent = notificationInformation

		local notificationDescription = Instance.new("TextLabel")
		notificationDescription.Name = "NotificationDescription"
		notificationDescription.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		notificationDescription.Text = Settings.Description
		notificationDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
		notificationDescription.TextSize = 11
		notificationDescription.TextTransparency = 0.5
		notificationDescription.TextWrapped = true
		notificationDescription.RichText = true
		notificationDescription.TextXAlignment = Enum.TextXAlignment.Left
		notificationDescription.TextYAlignment = Enum.TextYAlignment.Top
		notificationDescription.AutomaticSize = Enum.AutomaticSize.XY
		notificationDescription.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationDescription.BackgroundTransparency = 1
		notificationDescription.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationDescription.BorderSizePixel = 0
		notificationDescription.Size = UDim2.new(1, -12, 0, 0)
		notificationDescription.Parent = notificationInformation

		local notificationUIPadding = Instance.new("UIPadding")
		notificationUIPadding.Name = "NotificationUIPadding"
		notificationUIPadding.PaddingBottom = UDim.new(0, 12)
		notificationUIPadding.PaddingLeft = UDim.new(0, 10)
		notificationUIPadding.PaddingRight = UDim.new(0, 10)
		notificationUIPadding.PaddingTop = UDim.new(0, 10)
		notificationUIPadding.Parent = notificationInformation

		notificationInformation.Parent = notification

		local notificationControls = Instance.new("Frame")
		notificationControls.Name = "NotificationControls"
		notificationControls.AutomaticSize = Enum.AutomaticSize.Y
		notificationControls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		notificationControls.BackgroundTransparency = 1
		notificationControls.BorderColor3 = Color3.fromRGB(0, 0, 0)
		notificationControls.BorderSizePixel = 0
		notificationControls.Size = UDim2.fromScale(1, 1)

		local interactable = Instance.new("TextButton")
		interactable.Name = "Interactable"
		interactable.FontFace = Font.new(assets.interFont)
		interactable.Text = "✓"
		interactable.TextColor3 = Color3.fromRGB(255, 255, 255)
		interactable.TextSize = 17
		interactable.TextTransparency = 0.2
		interactable.AnchorPoint = Vector2.new(1, 0.5)
		interactable.AutomaticSize = Enum.AutomaticSize.XY
		interactable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		interactable.BackgroundTransparency = 1
		interactable.BorderColor3 = Color3.fromRGB(0, 0, 0)
		interactable.BorderSizePixel = 0
		interactable.LayoutOrder = 1
		interactable.Position = UDim2.fromScale(1, 0.5)
		interactable.Parent = notificationControls

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0, 6)
		uIPadding.PaddingRight = UDim.new(0, 13)
		uIPadding.PaddingTop = UDim.new(0, 6)
		uIPadding.Parent = notificationControls

		notificationControls.Parent = notification

		local tweens = {
			In = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = Settings.Scale or 1
			}),
			Out = Tween(notificationUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = 0
			}),
		}

		local styles = {
			None = function() interactable:Destroy() end,
			Confirm = function() interactable.Text = "✓" end,
			Cancel = function() interactable.Text = "✗" end
		}
		local style = styles[Settings.Style] or function() interactable:Destroy() end
		style()

		if interactable then
			interactable.MouseButton1Click:Connect(function()
				NotificationFunctions:Cancel()
				if Settings.Callback then
					task.spawn(Settings.Callback)
				end
			end)
		end

		local AnimateNotification = task.spawn(function()
			tweens.In:Play()
			Settings.Lifetime = Settings.Lifetime or 3
			if Settings.Lifetime ~= 0 then
				task.wait(Settings.Lifetime)
				local out = tweens.Out
				out:Play()
				out.Completed:Wait()
				notification:Destroy()
			end
		end)

		function NotificationFunctions:UpdateTitle(New) notificationTitle.Text = New end
		function NotificationFunctions:UpdateDescription(New) notificationDescription.Text = New end
		function NotificationFunctions:Resize(X) notification.Size = UDim2.fromOffset(X or 250, 0) end
		function NotificationFunctions:Cancel()
			task.cancel(AnimateNotification)
			local out = tweens.Out
			out:Play()
			out.Completed:Wait()
			notification:Destroy()
		end
		return NotificationFunctions
	end

	function WindowFunctions:Dialog(Settings)
		-- 复用 maclib 的对话框，但放在新 GUI 中
		local DialogFunctions = {}
		local dialogCanvas = Instance.new("CanvasGroup")
		dialogCanvas.Name = "DialogCanvas"
		dialogCanvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dialogCanvas.BackgroundTransparency = 1
		dialogCanvas.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dialogCanvas.BorderSizePixel = 0
		dialogCanvas.Size = UDim2.fromScale(1, 1)
		dialogCanvas.GroupTransparency = 1
		dialogCanvas.Parent = base

		local dialog = Instance.new("Frame")
		dialog.Name = "Dialog"
		dialog.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		dialog.BackgroundTransparency = 0.5
		dialog.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dialog.BorderSizePixel = 0
		dialog.Size = UDim2.fromScale(1, 1)

		local dialogUICorner = Instance.new("UICorner")
		dialogUICorner.Name = "BaseUICorner"
		dialogUICorner.CornerRadius = UDim.new(0, 10)
		dialogUICorner.Parent = dialog

		local prompt = Instance.new("Frame")
		prompt.Name = "Prompt"
		prompt.AnchorPoint = Vector2.new(0.5, 0.5)
		prompt.AutomaticSize = Enum.AutomaticSize.Y
		prompt.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
		prompt.BorderSizePixel = 0
		prompt.Position = UDim2.fromScale(0.5, 0.5)
		prompt.Size = UDim2.fromOffset(280, 0)

		local promptUIScale = Instance.new("UIScale")
		promptUIScale.Name = "BaseUIScale"
		promptUIScale.Parent = prompt
		promptUIScale.Scale = 0.95

		local globalSettingsUIStroke = Instance.new("UIStroke")
		globalSettingsUIStroke.Name = "GlobalSettingsUIStroke"
		globalSettingsUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		globalSettingsUIStroke.Color = Color3.fromRGB(255, 255, 255)
		globalSettingsUIStroke.Transparency = 0.9
		globalSettingsUIStroke.Parent = prompt

		local globalSettingsUICorner = Instance.new("UICorner")
		globalSettingsUICorner.Name = "GlobalSettingsUICorner"
		globalSettingsUICorner.CornerRadius = UDim.new(0, 10)
		globalSettingsUICorner.Parent = prompt

		local globalSettingsUIPadding = Instance.new("UIPadding")
		globalSettingsUIPadding.Name = "GlobalSettingsUIPadding"
		globalSettingsUIPadding.PaddingBottom = UDim.new(0, 20)
		globalSettingsUIPadding.PaddingLeft = UDim.new(0, 20)
		globalSettingsUIPadding.PaddingRight = UDim.new(0, 20)
		globalSettingsUIPadding.PaddingTop = UDim.new(0, 20)
		globalSettingsUIPadding.Parent = prompt

		local paragraph = Instance.new("Frame")
		paragraph.Name = "Paragraph"
		paragraph.AutomaticSize = Enum.AutomaticSize.Y
		paragraph.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		paragraph.BackgroundTransparency = 1
		paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paragraph.BorderSizePixel = 0
		paragraph.Size = UDim2.new(1, 0, 0, 38)

		local paragraphHeader = Instance.new("TextLabel")
		paragraphHeader.Name = "ParagraphHeader"
		paragraphHeader.FontFace = Font.new(assets.interFont, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		paragraphHeader.RichText = true
		paragraphHeader.Text = Settings.Title
		paragraphHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
		paragraphHeader.TextSize = 18
		paragraphHeader.TextTransparency = 0.4
		paragraphHeader.TextWrapped = true
		paragraphHeader.AutomaticSize = Enum.AutomaticSize.Y
		paragraphHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		paragraphHeader.BackgroundTransparency = 1
		paragraphHeader.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paragraphHeader.BorderSizePixel = 0
		paragraphHeader.Size = UDim2.fromScale(1, 0)
		paragraphHeader.Parent = paragraph

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 15)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = paragraph

		local paragraphBody = Instance.new("TextLabel")
		paragraphBody.Name = "ParagraphBody"
		paragraphBody.FontFace = Font.new(assets.interFont)
		paragraphBody.RichText = true
		paragraphBody.Text = Settings.Description
		paragraphBody.TextColor3 = Color3.fromRGB(255, 255, 255)
		paragraphBody.TextSize = 14
		paragraphBody.TextTransparency = 0.5
		paragraphBody.TextWrapped = true
		paragraphBody.AutomaticSize = Enum.AutomaticSize.Y
		paragraphBody.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		paragraphBody.BackgroundTransparency = 1
		paragraphBody.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paragraphBody.BorderSizePixel = 0
		paragraphBody.LayoutOrder = 1
		paragraphBody.Size = UDim2.fromScale(1, 0)
		paragraphBody.Parent = paragraph

		paragraph.Parent = prompt

		local interactions = Instance.new("Frame")
		interactions.Name = "Interactions"
		interactions.AutomaticSize = Enum.AutomaticSize.Y
		interactions.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		interactions.BackgroundTransparency = 1
		interactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
		interactions.BorderSizePixel = 0
		interactions.LayoutOrder = 1
		interactions.Size = UDim2.fromScale(1, 0)

		local uIListLayout1 = Instance.new("UIListLayout")
		uIListLayout1.Name = "UIListLayout"
		uIListLayout1.Padding = UDim.new(0, 10)
		uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout1.Parent = interactions

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingTop = UDim.new(0, 20)
		uIPadding.Parent = interactions

		interactions.Parent = prompt

		local uIListLayout2 = Instance.new("UIListLayout")
		uIListLayout2.Name = "UIListLayout"
		uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout2.Parent = prompt

		prompt.Parent = dialog
		dialog.Parent = dialogCanvas

		local canvasIn = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 0 })
		local canvasOut = Tween(dialogCanvas, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { GroupTransparency = 1 })
		local scaleIn = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 1 })
		local scaleOut = Tween(promptUIScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine), { Scale = 0.95 })

		local function dialogIn()
			canvasIn:Play()
			scaleIn:Play()
			canvasIn.Completed:Wait()
			dialog.Parent = base
		end

		local function dialogOut()
			if not dialog.Parent then return end
			dialog.Parent = dialogCanvas
			canvasOut:Play()
			scaleOut:Play()
			canvasOut.Completed:Wait()
			dialogCanvas:Destroy()
		end

		for _, v in pairs(Settings.Buttons) do
			local button = Instance.new("TextButton")
			button.Name = "Button"
			button.FontFace = Font.new(assets.interFont)
			button.Text = v.Name
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.TextSize = 15
			button.TextTransparency = 0.5
			button.TextTruncate = Enum.TextTruncate.AtEnd
			button.AutoButtonColor = false
			button.AutomaticSize = Enum.AutomaticSize.Y
			button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			button.BorderColor3 = Color3.fromRGB(0, 0, 0)
			button.BorderSizePixel = 0
			button.Size = UDim2.fromScale(1, 0)

			local uIPadding1 = Instance.new("UIPadding")
			uIPadding1.Name = "UIPadding"
			uIPadding1.PaddingBottom = UDim.new(0, 9)
			uIPadding1.PaddingLeft = UDim.new(0, 10)
			uIPadding1.PaddingRight = UDim.new(0, 10)
			uIPadding1.PaddingTop = UDim.new(0, 9)
			uIPadding1.Parent = button

			local baseUICorner1 = Instance.new("UICorner")
			baseUICorner1.Name = "BaseUICorner"
			baseUICorner1.CornerRadius = UDim.new(0, 10)
			baseUICorner1.Parent = button

			button.Parent = interactions

			local TweenSettings = {
				DefaultTransparency = 0,
				DefaultTransparency2 = 0.5,
				HoverTransparency = 0.3,
				HoverTransparency2 = 0.6,
				EasingStyle = Enum.EasingStyle.Sine
			}

			local function ChangeState(State)
				if State == "Idle" then
					Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
						BackgroundTransparency = TweenSettings.DefaultTransparency,
						TextTransparency = TweenSettings.DefaultTransparency2
					}):Play()
				elseif State == "Hover" then
					Tween(button, TweenInfo.new(0.2, TweenSettings.EasingStyle), {
						BackgroundTransparency = TweenSettings.HoverTransparency,
						TextTransparency = TweenSettings.HoverTransparency2
					}):Play()
				end
			end

			button.MouseButton1Click:Connect(function()
				if dialogCanvas.GroupTransparency ~= 0 then return end
				if v.Callback then
					v.Callback()
				end
				dialogOut()
			end)

			button.MouseEnter:Connect(function() ChangeState("Hover") end)
			button.MouseLeave:Connect(function() ChangeState("Idle") end)
		end

		dialogIn()

		function DialogFunctions:UpdateTitle(New) paragraphHeader.Text = New end
		function DialogFunctions:UpdateDescription(New) paragraphBody.Text = New end
		function DialogFunctions:Cancel() dialogOut() end

		return DialogFunctions
	end

	function WindowFunctions:SetNotificationsState(State) notifications.Visible = State end
	function WindowFunctions:GetNotificationsState() return notifications.Visible end
	function WindowFunctions:SetState(State) base.Visible = State; windowState = State end
	function WindowFunctions:GetState() return windowState end

	local onUnloadCallback
	function WindowFunctions:Unload()
		if onUnloadCallback then onUnloadCallback() end
		macLib:Destroy()
		unloaded = true
	end
	function WindowFunctions.onUnloaded(callback) onUnloadCallback = callback end

	function WindowFunctions:SetKeybind(Keycode)
		newWin:SetKeybind(Keycode)
	end

	function WindowFunctions:SetAcrylicBlurState(State)
		acrylicBlur = State
		base.BackgroundTransparency = State and 0.05 or 0
	end
	function WindowFunctions:GetAcrylicBlurState() return acrylicBlur end

	-- 用户信息显示（新 UI 已内置，但可以添加控制）
	local showUserInfo = Settings.ShowUserInfo ~= nil and Settings.ShowUserInfo or true
	-- 新 UI 的用户信息显示在左下角，无法直接隐藏，这里忽略

	function WindowFunctions:SetUserInfoState(State) end
	function WindowFunctions:GetUserInfoState() return showUserInfo end

	-- 配置系统（保持不变）
	local ClassParser = {
		["Toggle"] = {
			Save = function(Flag, data)
				return {type = "Toggle", flag = Flag, state = data:GetState() or false}
			end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.state then
					MacLib.Options[Flag]:UpdateState(data.state)
				end
			end
		},
		["Slider"] = {
			Save = function(Flag, data)
				return {type = "Slider", flag = Flag, value = data:GetValue() or 0}
			end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.value then
					MacLib.Options[Flag]:UpdateValue(data.value)
				end
			end
		},
		["Input"] = {
			Save = function(Flag, data)
				return {type = "Input", flag = Flag, text = data:GetText() or ""}
			end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.text then
					MacLib.Options[Flag]:UpdateText(data.text)
				end
			end
		},
		["Keybind"] = {
			Save = function(Flag, data)
				local bind = data:GetBind()
				return {type = "Keybind", flag = Flag, bind = bind and bind.Name or nil}
			end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.bind then
					MacLib.Options[Flag]:Bind(Enum.KeyCode[data.bind])
				end
			end
		},
		["Dropdown"] = {
			Save = function(Flag, data)
				return {type = "Dropdown", flag = Flag, value = data.Value}  -- 需要每个元素实现 Value 存储
			end,
			Load = function(Flag, data)
				if MacLib.Options[Flag] and data.value then
					MacLib.Options[Flag]:UpdateSelection(data.value)
				end
			end
		},
		["Colorpicker"] = {
			Save = function(Flag, data)
				local function Color3ToHex(color) return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)) end
				return {type = "Colorpicker", flag = Flag, color = Color3ToHex(data.Color) or nil, alpha = data.Alpha}
			end,
			Load = function(Flag, data)
				local function HexToColor3(hex)
					local r = tonumber(hex:sub(2, 3), 16) / 255
					local g = tonumber(hex:sub(4, 5), 16) / 255
					local b = tonumber(hex:sub(6, 7), 16) / 255
					return Color3.new(r, g, b)
				end
				if MacLib.Options[Flag] and data.color then
					MacLib.Options[Flag]:SetColor(HexToColor3(data.color))
					if data.alpha then MacLib.Options[Flag]:SetAlpha(data.alpha) end
				end
			end
		}
	}

	local function BuildFolderTree()
		if isStudio or not (isfolder and makefolder) then return "Config system unavailable." end
		local paths = {MacLib.Folder, MacLib.Folder .. "/settings"}
		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then makefolder(str) end
		end
	end

	function MacLib:LoadAutoLoadConfig()
		if isStudio or not (isfile and readfile) then return "Config system unavailable." end
		if isfile(MacLib.Folder .. "/settings/autoload.txt") then
			local name = readfile(MacLib.Folder .. "/settings/autoload.txt")
			local suc, err = MacLib:LoadConfig(name)
			if not suc then
				WindowFunctions:Notify({Title = "Interface", Description = "Error loading autoload config: " .. err})
			else
				WindowFunctions:Notify({Title = "Interface", Description = string.format("Autoloaded config: %q", name)})
			end
		end
	end

	function MacLib:SetFolder(Folder) if isStudio then return "Config system unavailable." end; MacLib.Folder = Folder; BuildFolderTree() end

	function MacLib:SaveConfig(Path)
		if isStudio or not writefile then return "Config system unavailable." end
		if not Path then return false, "Please select a config file." end
		local fullPath = MacLib.Folder .. "/settings/" .. Path .. ".json"
		local data = {objects = {}}
		for flag, option in next, MacLib.Options do
			if not ClassParser[option.Class] then continue end
			if option.IgnoreConfig then continue end
			table.insert(data.objects, ClassParser[option.Class].Save(flag, option))
		end
		local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
		if not success then return false, "Unable to encode into JSON data" end
		writefile(fullPath, encoded)
		return true
	end

	function MacLib:LoadConfig(Path)
		if isStudio or not (isfile and readfile) then return "Config system unavailable." end
		if not Path then return false, "Please select a config file." end
		local file = MacLib.Folder .. "/settings/" .. Path .. ".json"
		if not isfile(file) then return false, "Invalid file" end
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
		if not success then return false, "Unable to decode JSON data." end
		for _, option in next, decoded.objects do
			if ClassParser[option.type] then
				task.spawn(function() ClassParser[option.type].Load(option.flag, option) end)
			end
		end
		return true
	end

	function MacLib:RefreshConfigList()
		if isStudio or not (isfolder and listfiles) then return "Config system unavailable." end
		local list = (isfolder(MacLib.Folder) and isfolder(MacLib.Folder .. "/settings")) and listfiles(MacLib.Folder .. "/settings") or {}
		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == ".json" then
				local pos = file:find(".json", 1, true)
				local start = pos
				local char = file:sub(pos, pos)
				while char ~= "/" and char ~= "\\" and char ~= "" do
					pos = pos - 1
					char = file:sub(pos, pos)
				end
				if char == "/" or char == "\\" then
					local name = file:sub(pos + 1, start - 1)
					if name ~= "options" then
						table.insert(out, name)
					end
				end
			end
		end
		return out
	end

	-- 预加载资源
	local assetList = {}
	for _, assetId in pairs(assets) do table.insert(assetList, assetId) end
	ContentProvider:PreloadAsync(assetList)

	base.Visible = true
	windowState = true

	return WindowFunctions
end

function MacLib:Demo()
	local Window = MacLib:Window({
		Title = "Maclib Demo",
		Subtitle = "This is a subtitle.",
		Size = UDim2.fromOffset(868, 650),
		DragStyle = 1,
		DisabledWindowControls = {},
		ShowUserInfo = true,
		Keybind = Enum.KeyCode.RightControl,
		AcrylicBlur = true,
	})

	local globalSettings = {
		UIBlurToggle = Window:GlobalSetting({
			Name = "UI Blur",
			Default = Window:GetAcrylicBlurState(),
			Callback = function(bool)
				Window:SetAcrylicBlurState(bool)
				Window:Notify({Title = Window.Settings.Title, Description = (bool and "Enabled" or "Disabled") .. " UI Blur", Lifetime = 5})
			end,
		}),
		NotificationToggler = Window:GlobalSetting({
			Name = "Notifications",
			Default = Window:GetNotificationsState(),
			Callback = function(bool)
				Window:SetNotificationsState(bool)
				Window:Notify({Title = Window.Settings.Title, Description = (bool and "Enabled" or "Disabled") .. " Notifications", Lifetime = 5})
			end,
		}),
		ShowUserInfo = Window:GlobalSetting({
			Name = "Show User Info",
			Default = Window:GetUserInfoState(),
			Callback = function(bool)
				Window:SetUserInfoState(bool)
				Window:Notify({Title = Window.Settings.Title, Description = (bool and "Showing" or "Redacted") .. " User Info", Lifetime = 5})
			end,
		})
	}

	local tabGroups = { TabGroup1 = Window:TabGroup() }
	local tabs = {
		Main = tabGroups.TabGroup1:Tab({ Name = "Demo", Image = "rbxassetid://18821914323" }),
		Settings = tabGroups.TabGroup1:Tab({ Name = "Settings", Image = "rbxassetid://10734950309" })
	}
	local sections = { MainSection1 = tabs.Main:Section({ Side = "Left" }) }

	sections.MainSection1:Header({ Name = "Header #1" })
	sections.MainSection1:Button({
		Name = "Button",
		Callback = function()
			Window:Dialog({
				Title = Window.Settings.Title,
				Description = "Lorem ipsum odor amet, consectetuer adipiscing elit. Eros vestibulum aliquet mattis, ex platea nunc.",
				Buttons = {
					{ Name = "Confirm", Callback = function() print("Confirmed!") end },
					{ Name = "Cancel" }
				}
			})
		end,
	})
	sections.MainSection1:Input({ Name = "Input", Placeholder = "Input", AcceptedCharacters = "All", Callback = function(input) Window:Notify({Title = Window.Settings.Title, Description = "Successfully set input to " .. input}) end, onChanged = function(input) print("Input is now " .. input) end }, "Input")
	sections.MainSection1:Slider({ Name = "Slider", Default = 50, Minimum = 0, Maximum = 100, DisplayMethod = "Percent", Precision = 0, Callback = function(Value) print("Changed to ".. Value) end }, "Slider")
	sections.MainSection1:Toggle({ Name = "Toggle", Default = false, Callback = function(value) Window:Notify({Title = Window.Settings.Title, Description = (value and "Enabled " or "Disabled ") .. "Toggle"}) end }, "Toggle")
	sections.MainSection1:Keybind({ Name = "Keybind", Blacklist = false, Callback = function(binded) Window:Notify({Title = "Demo Window", Description = "Pressed keybind - "..tostring(binded.Name), Lifetime = 3}) end, onBinded = function(bind) Window:Notify({Title = "Demo Window", Description = "Successfully Binded Keybind to - "..tostring(bind.Name), Lifetime = 3}) end }, "Keybind")
	sections.MainSection1:Colorpicker({ Name = "Colorpicker", Default = Color3.fromRGB(0, 255, 255), Callback = function(color) print("Color: ", color) end }, "Colorpicker")
	local alphaColorPicker = sections.MainSection1:Colorpicker({ Name = "Transparency Colorpicker", Default = Color3.fromRGB(255,0,0), Alpha = 0, Callback = function(color, alpha) print("Color: ", color, " Alpha: ", alpha) end }, "TransparencyColorpicker")
	local rainbowActive, rainbowConnection, hue = false, nil, 0
	sections.MainSection1:Toggle({ Name = "Rainbow", Default = false, Callback = function(value) rainbowActive = value; if rainbowActive then rainbowConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime) hue = (hue + deltaTime * 0.1) % 1; alphaColorPicker:SetColor(Color3.fromHSV(hue, 1, 1)) end) elseif rainbowConnection then rainbowConnection:Disconnect(); rainbowConnection = nil end end }, "RainbowToggle")
	local optionTable = {"Apple","Banana","Orange","Grapes","Pineapple","Mango","Strawberry","Blueberry","Watermelon","Peach"}
	local Dropdown = sections.MainSection1:Dropdown({ Name = "Dropdown", Multi = false, Required = true, Options = optionTable, Default = 1, Callback = function(Value) print("Dropdown changed: ".. Value) end }, "Dropdown")
	local MultiDropdown = sections.MainSection1:Dropdown({ Name = "Multi Dropdown", Search = true, Multi = true, Required = false, Options = optionTable, Default = {"Apple","Orange"}, Callback = function(Value) local Values = {}; for Value, State in next, Value do table.insert(Values, Value) end; print("Mutlidropdown changed:", table.concat(Values, ", ")) end }, "MultiDropdown")
	sections.MainSection1:Button({ Name = "Update Selection", Callback = function() Dropdown:UpdateSelection("Grapes"); MultiDropdown:UpdateSelection({"Banana","Pineapple"}) end })
	sections.MainSection1:Divider()
	sections.MainSection1:Header({ Text = "Header #2" })
	sections.MainSection1:Paragraph({ Header = "Paragraph", Body = "Paragraph body. Lorem ipsum odor amet, consectetuer adipiscing elit. Morbi tempus netus aliquet per velit est gravida." })
	sections.MainSection1:Label({ Text = "Label. Lorem ipsum odor amet, consectetuer adipiscing elit." })
	sections.MainSection1:SubLabel({ Text = "Sub-Label. Lorem ipsum odor amet, consectetuer adipiscing elit." })

	MacLib:SetFolder("Maclib")
	tabs.Settings:InsertConfigSection("Left")
	Window.onUnloaded(function() print("Unloaded!") end)
	tabs.Main:Select()
	MacLib:LoadAutoLoadConfig()
end

return MacLib