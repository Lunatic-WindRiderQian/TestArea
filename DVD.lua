local IMAGE_ID = "rbxassetid://73542239032835"
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