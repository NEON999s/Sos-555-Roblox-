local UserInputService = game:GetService("UserInputService")
local dragging = false
local startMousePosition, startSize

local Config_Gui = {
	["Theme"] = "Dark",
	["Background Transparency"] = 0.2;
	["Top Transparency"] = 0.5
}

local GUI = game:GetService("CoreGui"):FindFirstChild("LUX2ICANTLUX") 
if GUI then 
	GUI:Destroy() 
end

local function tablefound(ta, object)
	if type(ta) ~= "table" then
		return false
	end
	for _, value in pairs(ta) do
		if value == object then
			return true
		end
	end
	return false
end

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = game.Players.LocalPlayer:GetMouse()

local ActualTypes = {
	RoundFrame = "ImageLabel",
	Shadow = "ImageLabel",
	Circle = "ImageLabel",
	CircleButton = "ImageButton",
	Frame = "Frame",
	Label = "TextLabel",
	Button = "TextButton",
	SmoothButton = "ImageButton",
	Box = "TextBox",
	ScrollingFrame = "ScrollingFrame",
	Menu = "ImageButton",
	NavBar = "ImageButton"
}


local Properties = {
	RoundFrame = {
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5554237731",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(3,3,297,297)
	},
	SmoothButton = {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5554237731",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(3,3,297,297)
	},
	Shadow = {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5554236805",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(23,23,277,277),
		Size = UDim2.fromScale(1,1) + UDim2.fromOffset(30,30),
		Position = UDim2.fromOffset(-15,-15)
	},
	Circle = {
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5554831670"
	},
	CircleButton = {
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Image = "http://www.roblox.com/asset/?id=5554831670"
	},
	Frame = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1,1)
	},
	Label = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(5,0),
		Size = UDim2.fromScale(1,1) - UDim2.fromOffset(5,0),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	},
	Button = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(5,0),
		Size = UDim2.fromScale(1,1) - UDim2.fromOffset(5,0),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	},
	Box = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(5,0),
		Size = UDim2.fromScale(1,1) - UDim2.fromOffset(5,0),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	},
	ScrollingFrame = {
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.fromScale(0,0),
		Size = UDim2.fromScale(1,1)
	},
	Menu = {
		Name = "More",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Image = "http://www.roblox.com/asset/?id=5555108481",
		Size = UDim2.fromOffset(20,20),
		Position = UDim2.fromScale(1,0.5) - UDim2.fromOffset(25,10)
	},
	NavBar = {
		Name = "SheetToggle",
		Image = "http://www.roblox.com/asset/?id=5576439039",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(20,20),
		Position = UDim2.fromOffset(5,5),
		AutoButtonColor = false
	}
}


local Objects = {}

local Types = {
	"RoundFrame",
	"Shadow",
	"Circle",
	"CircleButton",
	"Frame",     
	"Label",
	"Button",
	"SmoothButton",
	"Box",
	"ScrollingFrame",
	"Menu",
	"NavBar"
}


function FindType(String)
	for _, Type in next, Types do
		if Type:sub(1, #String):lower() == String:lower() then
			return Type
		end
	end
	return false
end

function Objects.new(Type)
	local TargetType = FindType(Type)
	if TargetType then
		local NewImage = Instance.new(ActualTypes[TargetType])
		if Properties[TargetType] then
			for Property, Value in next, Properties[TargetType] do
				NewImage[Property] = Value
			end
		end
		return NewImage
	else
		return Instance.new(Type)
	end
end

local function GetXY(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px/Max, Py/May
end

local function CircleAnim(GuiObject, EndColour, StartColour)
	local PX, PY = GetXY(GuiObject)
	local Circle = Objects.new("Shadow")
	Circle.Size = UDim2.fromScale(0,0)
	Circle.Position = UDim2.fromScale(PX,PY)
	Circle.ImageColor3 = StartColour or GuiObject.ImageColor3
	Circle.ZIndex = 1
	Circle.Parent = GuiObject
	GuiObject.ClipsDescendants = true
	local Size = GuiObject.AbsoluteSize.X
	TweenService:Create(Circle, TweenInfo.new(0.5), {Position = UDim2.fromScale(PX,PY) - UDim2.fromOffset(Size/2,Size/2), ImageTransparency = 1, ImageColor3 = EndColour, Size = UDim2.fromOffset(Size,Size)}):Play()
	spawn(function()
		wait(0.5)
		Circle:Destroy()
	end)
end


local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
	end

	topbarobject.InputBegan:Connect(
		function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPosition = object.Position

				input.Changed:Connect(
					function()
						if input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end
				)
			end
		end
	)

	topbarobject.InputChanged:Connect(
		function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement or
				input.UserInputType == Enum.UserInputType.Touch
			then
				DragInput = input
			end
		end
	)

	UserInputService.InputChanged:Connect(
		function(input)
			if input == DragInput and Dragging then
				Update(input)
			end
		end
	)
end

local Update = {}

function Update:CreateWindow(text,logo,keybind)
	local uihide = false
	local abc = false
	local logo = logo or 0
	local currentpage = ""
	local keybind = keybind or Enum.KeyCode.RightControl
	local TopDRAG = Instance.new("Frame")
	local yoo = string.gsub(tostring(keybind),"Enum.KeyCode.","")

	local ScreenGUIX = Instance.new("ScreenGui")
	ScreenGUIX.Name = "LUX2ICANTLUX"
	ScreenGUIX.Parent = game:GetService("CoreGui")
	ScreenGUIX.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	

	if game:GetService("CoreGui"):FindFirstChild("MainJek") then
		game:GetService("CoreGui"):FindFirstChild("MainJek"):Destroy()
	end

	local MainJek = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local TextButton = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")
	local ImageLabel = Instance.new("ImageLabel")
	local UICorner_2 = Instance.new("UICorner")

	MainJek.Name = "MainJek"
	MainJek.Parent = game:GetService("CoreGui")

	Frame.Parent = MainJek
	Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BackgroundTransparency = 0.600
	Frame.BorderColor3 = Color3.fromRGB(0, 144, 247)
	Frame.Position = UDim2.new(0.795573473, 0, 0.113636367, 230)
	Frame.Size = UDim2.new(0, 39, 0, 39)

	TextButton.Parent = Frame
	TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BackgroundTransparency = 0.6
	TextButton.BorderColor3 = Color3.fromRGB(46, 45, 45)
	TextButton.Position = UDim2.new(0, 0, -0.19999969, 7)
	TextButton.Size = UDim2.new(0, 39, 0, 39)
	TextButton.Font = Enum.Font.Code
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.TextSize = 35.000
	TextButton.TextTransparency = 0.500
	
	TextButton.MouseButton1Click:Connect(function()
		if game:GetService("CoreGui").LUX2ICANTLUX then
			game:GetService("CoreGui"):WaitForChild("LUX2ICANTLUX").Enabled = not game:GetService("CoreGui"):WaitForChild("LUX2ICANTLUX").Enabled
		end
	end)

	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = TextButton

	ImageLabel.Parent = TextButton
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1.000
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0, 0, -0.0344801694, 0)
	ImageLabel.Size = UDim2.new(0, 39, 0, 40)
	ImageLabel.Image = "rbxassetid://83390370208574"

    local UICorner_3 = Instance.new("UICorner")
	UICorner_3.CornerRadius = UDim.new(0, 12)
	UICorner_3.Parent = ImageLabel


	UICorner_2.CornerRadius = UDim.new(0, 12)
	UICorner_2.Parent = Frame
	
	MakeDraggable(TextButton, Frame)



	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Parent = ScreenGUIX
	Main.ClipsDescendants = true
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(9,9,9)
	Main.Position = UDim2.new(0.5, 0, 0.5, 0)
	Main.Size = UDim2.new(0, 545, 0, 385)
	Main.BackgroundTransparency = Config_Gui["Background Transparency"]
	local toggledis = false
	
	--function blur(Value)
	--	for _, v in pairs(ScreenGUIX:GetDescendants()) do
	--		if v:IsA("Frame") then
	--			Config_Gui["Background Transparency"] = Value
	--			print(Value)
	--			v.BackgroundTransparency = Value
	--		end
	--	end
	--end
	
	--function Theme(value)
	--	local OldColors = {}

	--	if value == true then
	--		Config_Gui["Theme"] = "Light"
	--		task.wait()
	--		for _, child in ipairs(ScreenGUIX:GetDescendants()) do
	--			if child:IsA("Frame") then
	--				OldColors[child] = child.BackgroundColor3
	--				local tween = game:GetService("TweenService"):Create(
	--					child,
	--					TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	--					{BackgroundColor3 = Color3.fromRGB(255, 255, 255)} 
	--				)
	--				tween:Play()
	--			elseif child:IsA("TextLabel") then
	--				local tween = game:GetService("TweenService"):Create(
	--					child,
	--					TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	--					{TextColor3 = Color3.fromRGB(0, 0, 0)}
	--				)
	--				tween:Play()
	--			end
	--		end
	--	elseif value == false then
	--		Config_Gui["Theme"] = "Dark"
	--		task.wait()
	--		for _, child in ipairs(ScreenGUIX:GetDescendants()) do
	--			if child:IsA("Frame") then
	--				local originalColor = OldColors[child] or Color3.fromRGB(36, 36, 36)
	--				local tween = game:GetService("TweenService"):Create(
	--					child,
	--					TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	--					{BackgroundColor3 = originalColor}
	--				)
	--				tween:Play()
	--			elseif child:IsA("TextLabel") then
	--				local tween = game:GetService("TweenService"):Create(
	--					child,
	--					TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	--					{TextColor3 = Color3.fromRGB(255, 255, 255)}
	--				)
	--				tween:Play()
	--			end
	--		end
	--	end
	--end



	
	local Top = Instance.new("Frame")
	Top.Name = "Top"
	Top.Parent = Main
	Top.BackgroundTransparency = Config_Gui["Top Transparency"]
	Top.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	Top.Position = UDim2.new(0, 5, 0, 2)
	Top.Size = UDim2.new(0, 190, 0, 38)

	local UiCORNERFAKEE = Instance.new("UICorner")

	UiCORNERFAKEE.CornerRadius = UDim.new(0, 5)
	UiCORNERFAKEE.Parent = Main
	
	--local Theme = Instance.new("TextButton")
	--local UICorner = Instance.new("UICorner")
	--local ImageLabel = Instance.new("ImageLabel")

	--Theme.Name = "Theme"
	--Theme.Parent = Top
	--Theme.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	--Theme.BackgroundTransparency = 1.000
	--Theme.Position = UDim2.new(0, 154, 0, 6)
	--Theme.Size = UDim2.new(0, 27, 0, 26)
	--Theme.ZIndex = 999
	--Theme.AutoButtonColor = false
	--Theme.TextSize = 1.000
	--Theme.TextTransparency = 1.000

	--UICorner.CornerRadius = UDim.new(0, 5)
	--UICorner.Parent = Theme

	--ImageLabel.Parent = Theme
	--ImageLabel.BackgroundTransparency = 1.000
	--ImageLabel.Position = UDim2.new(0.0884105563, 0, 0, 0)
	--ImageLabel.Size = UDim2.new(0, 24, 0, 26)
	--ImageLabel.Image = "rbxassetid://113802213053762"



	local UiCORNERFAKEES = Instance.new("UICorner")

	UiCORNERFAKEES.CornerRadius = UDim.new(0, 5)
	UiCORNERFAKEES.Parent = Top



	TopDRAG.Name = "TopDrags"
	TopDRAG.Parent = Main
	TopDRAG.Transparency = 1
	TopDRAG.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	TopDRAG.Position = UDim2.new(0, 0, 0, 0)
	TopDRAG.Size = UDim2.new(0, 545, 0, 40)

	local Logo = Instance.new("ImageLabel")
	Logo.Name = "Logo"
	Logo.Parent = Top
	Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Logo.BackgroundTransparency = 1.000
	Logo.Position = UDim2.new(0, 12, 0, 1)
	Logo.Size = UDim2.new(0, 35, 0, 35)
	Logo.Image = "rbxassetid://"..tostring(logo)

	local Name = Instance.new("TextLabel")
	Name.Name = "Name"
	Name.Parent = Top
	Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Name.BackgroundTransparency = 1.000
	Name.Position = UDim2.new(0.247, 0,0, 4)
	Name.TextColor3 = Color3.fromRGB(225, 208, 25)
	Name.Size = UDim2.new(0, 108, 0, 18)
	Name.Font = Enum.Font.RobotoMono
	Name.Text = text
	Name.TextSize = 17.000

	
	-- Gui to Lua
	-- Version: 3.2

	-- Instances:

	local BackgroundTopFrame = Instance.new("Frame")
	local Tab = Instance.new("Frame")
	local TCNR = Instance.new("UICorner")
	local ScrollTab = Instance.new("ScrollingFrame")
	local PLL = Instance.new("UIListLayout")
	local TopTab = Instance.new("Frame")
	local PLL_2 = Instance.new("UIListLayout")
	--local Hide = Instance.new("TextButton")
	--local Minimize = Instance.new("TextButton")
	local Top = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Name = Instance.new("TextLabel")
	local UICorner_2 = Instance.new("UICorner")

	--Properties:

	BackgroundTopFrame.Name = "BackgroundTopFrame"
	BackgroundTopFrame.Parent = Main
	BackgroundTopFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	BackgroundTopFrame.BackgroundTransparency = 0
	BackgroundTopFrame.Size = UDim2.new(0, 545, 0, 41)

	Tab.Name = "Tab"
	Tab.Parent = BackgroundTopFrame
	Tab.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	Tab.BackgroundTransparency = 1
	Tab.Position = UDim2.new(0, 130, 0, 2)
	Tab.Size = UDim2.new(0, 291, 0, 39)

	TCNR.Name = "TCNR"
	TCNR.Parent = Tab

	ScrollTab.Name = "ScrollTab"
	ScrollTab.Parent = Tab
	ScrollTab.Active = true
	ScrollTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollTab.BackgroundTransparency = 1.000
	ScrollTab.Position = UDim2.new(0, 0, 0, -2)
	ScrollTab.Size = UDim2.new(0, 284, 0, 39)
	ScrollTab.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollTab.ScrollBarThickness = 0

	PLL.Name = "PLL"
	PLL.Parent = ScrollTab
	PLL.FillDirection = Enum.FillDirection.Horizontal
	PLL.SortOrder = Enum.SortOrder.LayoutOrder
	PLL.VerticalAlignment = Enum.VerticalAlignment.Center
	PLL.Padding = UDim.new(0, 16)

	TopTab.Name = "TopTab"
	TopTab.Parent = BackgroundTopFrame
	TopTab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TopTab.BackgroundTransparency = 1.000
	TopTab.Position = UDim2.new(0, 424, 0, 2)
	TopTab.Size = UDim2.new(0, 120, 0, 39)

	--Close.Name = "Hide"
	--Close.Parent = TopTab
	--Close.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
	--Close.BackgroundTransparency = 1
	--Close.Size = UDim2.new(0, 32, 0, 36)
	--Close.Text = ""
	
	--Close.MouseEnter:Connect(function()
	--	Close.BackgroundTransparency = 0.7
	--end)
	
	--Close.MouseLeave:Connect(function()
	--	Close.BackgroundTransparency = 1
	--end)
	
	--Close.MouseButton1Click:Connect(function()
	--	ScreenGUIX.Enabled = false
	--end)

	--Logo.Name = "Logo"
	--Logo.Parent = Close
	--Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	--Logo.BackgroundTransparency = 1.000
	--Logo.Position = UDim2.new(0.100000381, 0, 0.169999436, 0)
	--Logo.Size = UDim2.new(0, 25, 0, 25)
	--Logo.Image = "rbxassetid://83888629831293"

	--UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(75, 75, 75)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
	--UIGradient.Rotation = -111
	--UIGradient.Parent = Logo

	--PLL_2.Name = "PLL"
	--PLL_2.Parent = TopTab
	--PLL_2.FillDirection = Enum.FillDirection.Horizontal
	--PLL_2.SortOrder = Enum.SortOrder.LayoutOrder
	--PLL_2.Padding = UDim.new(0, 10)

	--Hide.Name = "Minimize"
	--Hide.Parent = TopTab
	--Hide.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
	--Hide.BackgroundTransparency = 1.000
	--Hide.Size = UDim2.new(0, 32, 0, 36)
	--Hide.Text = ""
	
	--Hide.MouseEnter:Connect(function()
	--	Hide.BackgroundTransparency = 0.7
	--end)

	--Hide.MouseLeave:Connect(function()
	--	Hide.BackgroundTransparency = 1
	--end)

	--Logo_2.Name = "Logo"
	--Logo_2.Parent = Hide
	--Logo_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	--Logo_2.BackgroundTransparency = 1.000
	--Logo_2.Position = UDim2.new(0.100000381, 0, 0.169999436, 0)
	--Logo_2.Size = UDim2.new(0, 25, 0, 22)
	--Logo_2.Image = "rbxassetid://135657527897618"

	--UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(75, 75, 75)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
	--UIGradient_2.Rotation = -111
	--UIGradient_2.Parent = Logo_2

	--Minimize.Name = "Close"
	--Minimize.Parent = TopTab
	--Minimize.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
	--Minimize.BackgroundTransparency = 1.000
	--Minimize.Size = UDim2.new(0, 32, 0, 36)
	--Minimize.Text = ""
	
	--Minimize.MouseEnter:Connect(function()
	--	Minimize.BackgroundTransparency = 0.7
	--end)

	--Minimize.MouseLeave:Connect(function()
	--	Minimize.BackgroundTransparency = 1
	--end)

	--Logo_3.Name = "Logo"
	--Logo_3.Parent = Minimize
	--Logo_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	--Logo_3.BackgroundTransparency = 1.000
	--Logo_3.Position = UDim2.new(0.0999984741, 0, 0.0866661072, 0)
	--Logo_3.Size = UDim2.new(0, 29, 0, 28)
	--Logo_3.Image = "rbxassetid://10002373478"

	--UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(75, 75, 75)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
	--UIGradient_3.Rotation = -111
	--UIGradient_3.Parent = Logo_3

	Top.Name = "Top"
	Top.Parent = BackgroundTopFrame
	Top.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	Top.BackgroundTransparency = 1.000
	Top.Position = UDim2.new(0, 5, 0, 2)
	Top.Size = UDim2.new(0, 154, 0, 38)

	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.Parent = Top

	Name.Name = "Name"
	Name.Parent = Top
	Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Name.BackgroundTransparency = 1.000
	Name.Position = UDim2.new(0.175571397, 0, 0.131578952, 4)
	Name.Size = UDim2.new(0, 109, 0, 18)
	Name.Font = Enum.Font.RobotoMono
	Name.Text = text
	Name.TextColor3 = Color3.fromRGB(122, 13, 255)
	Name.TextSize = 17.000
	Name.TextXAlignment = Enum.TextXAlignment.Left

	UICorner_2.CornerRadius = UDim.new(0, 5)
	UICorner_2.Parent = BackgroundTopFrame
	
	--[[local ImageButton = Instance.new("ImageButton",Top)
	ImageButton.Image = "rbxassetid://5881046614"
	ImageButton.Size = UDim2.new(0,30,0,30)
	ImageButton.Position = UDim2.new(0, 155,0, 4)
	ImageButton.BackgroundTransparency = 1
	
	ImageButton.MouseButton1Click:Connect(function()
		if What == "Dark" then
			TextColorNow = Theme.Light.TextColor
			BackColorNow = Theme.Light.BackgroundColor
		end
	end)]]

	local Page = Instance.new("Frame")
	Page.Name = "Page"
	Page.Parent = Main
	Page.Transparency = 1
	Page.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Page.Size = UDim2.new(0, 545, 0, 340)
	Page.Position = UDim2.new(0, 0,0, 44)

	local BG = Instance.new("Frame")
	BG.Name = "BackgroundLolekzer"
	BG.Parent = Page
	BG.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	BG.Size = UDim2.new(0, 515,0, 303)
	BG.Position = UDim2.new(0, 15, 0.075, 7)
	BG.BackgroundTransparency = Config_Gui["Background Transparency"]

	local PCNRSSS = Instance.new("UICorner")
	PCNRSSS.Name = "PCNRSSS"
	PCNRSSS.Parent = BG
	PCNRSSS.CornerRadius = UDim.new(0,13)	

	local PCNR = Instance.new("UICorner")
	PCNR.Name = "PCNR"
	PCNR.Parent = Page

	local MainPage = Instance.new("Frame")
	MainPage.Name = "MainPage"
	MainPage.Parent = Page
	MainPage.ClipsDescendants = true
	MainPage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MainPage.BackgroundTransparency = 1.000
	MainPage.Size = UDim2.new(0, 545, 0, 340)

	local Searchbox = Instance.new("TextBox")
	Searchbox.Parent = MainPage
	Searchbox.Size = UDim2.new(0,300,0,18)
	Searchbox.Position = UDim2.new(0,230,0,4)
	Searchbox.PlaceholderText = "Search Options..."
	Searchbox.Text = ""
	Searchbox.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	Searchbox.TextColor3 = Color3.fromRGB(255,255,255)

	local PCNRS = Instance.new("UICorner")
	PCNRS.Name = "PCNRSS"
	PCNRS.Parent = Searchbox
	PCNRS.CornerRadius = UDim.new(0,18)

	local imagelabelsmalubchai  = Instance.new("ImageLabel") 
	imagelabelsmalubchai.Parent = Searchbox
	imagelabelsmalubchai.Size = UDim2.new(0, 15, 0, 15)
	imagelabelsmalubchai.Position = UDim2.new(0, 284,0, 2)
	imagelabelsmalubchai.BackgroundTransparency = 1
	imagelabelsmalubchai.Image = "rbxassetid://11713338272"
	imagelabelsmalubchai.ImageColor3 = Color3.fromRGB(255,255,255)

	local PageList = Instance.new("Folder")
	PageList.Name = "PageList"
	PageList.Parent = MainPage

	local UIPageLayout = Instance.new("UIPageLayout")

	UIPageLayout.Parent = PageList
	UIPageLayout.FillDirection = Enum.FillDirection.Horizontal
	UIPageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIPageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIPageLayout.Padding = UDim.new(0, 0)
	UIPageLayout.Animated = false
	UIPageLayout.GamepadInputEnabled = false
	UIPageLayout.ScrollWheelInputEnabled = false
	UIPageLayout.TouchInputEnabled = false

	MakeDraggable(TopDRAG,Main)

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode[yoo] then
			ScreenGUIX.Enabled = not ScreenGUIX.Enabled
		end
	end)

	local uitab = {}

	function uitab:Tab(text)
		local TabButton = Instance.new("TextButton")
		TabButton.Parent = ScrollTab
		TabButton.Name = text.."Server"
		TabButton.Text = text
		TabButton.BackgroundTransparency = 1.000
		TabButton.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
		TabButton.Size = UDim2.new(0, 43, 0, 33)
		TabButton.Font = Enum.Font.RobotoMono
		TabButton.TextColor3 = Color3.fromRGB(225, 225, 225)
		TabButton.TextSize = 18.000
		TabButton.TextTransparency = 0.500

		local uicorneriscreated = Instance.new("UICorner")
		uicorneriscreated.CornerRadius = UDim.new(0,12)
		uicorneriscreated.Parent = TabButton		


		local MainFramePage = Instance.new("ScrollingFrame")
		MainFramePage.Name = text.."_Page"
		MainFramePage.Parent = PageList
		MainFramePage.Active = true
		MainFramePage.Transparency = 0.5
		MainFramePage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		MainFramePage.BackgroundTransparency = 1.000
		MainFramePage.BorderSizePixel = 0
		MainFramePage.Size = UDim2.new(0, 545,0, 340)
		MainFramePage.Position = Page.Position
		MainFramePage.CanvasSize = UDim2.new(0, 0, 0, 0)
		MainFramePage.ScrollBarThickness = 0

		local TextSliders = Instance.new("TextLabel")
		TextSliders.Name = tostring(text)
		TextSliders.Parent = MainFramePage
		TextSliders.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextSliders.BackgroundTransparency = 1.000
		TextSliders.Position = UDim2.new(0, 30, 0, 0)
		TextSliders.Size = UDim2.new(0, 180, 0, 26)
		TextSliders.Font = Enum.Font.RobotoMono
		TextSliders.Text = text.." Tab"
		TextSliders.TextColor3 = Color3.fromRGB(225, 225, 225)
		TextSliders.TextSize = 23.000
		TextSliders.TextTransparency = 0

		TabButton.MouseButton1Click:Connect(function()
			for i,v in next, ScrollTab:GetChildren() do
				if v:IsA("TextButton") then
					TweenService:Create(
						v,
						TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
						{TextTransparency = 0.5}
					):Play()
				end
				TweenService:Create(
					TabButton,
					TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
					{TextTransparency = 0}
				):Play()
			end
			for i,v in next, PageList:GetChildren() do
				currentpage = string.gsub(TabButton.Name,"Server","").."_Page"
				if v.Name == currentpage then
					UIPageLayout:JumpTo(v)
				end
			end
		end)

		if abc == false then
			for i,v in next, ScrollTab:GetChildren() do
				if v:IsA("TextButton") then
					TweenService:Create(
						v,
						TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
						{TextTransparency = 0.5}
					):Play()
				end
				TweenService:Create(
					TabButton,
					TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
					{TextTransparency = 0}
				):Play()
			end
			UIPageLayout:JumpToIndex(1)
			abc = true
		end

		game:GetService("RunService").Stepped:Connect(function()
			pcall(function()
				MainFramePage.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y + 20)
				ScrollTab.CanvasSize = UDim2.new(0,0,0,PLL.AbsoluteContentSize.Y + 20)
			end)
		end)

		local section = {}

		function section:AddPage(Name, Slide)
			local Whhat
			local wwow
			local main = {}


			if Slide == "Right" then
				Whhat = UDim2.new(0, 275, 0, 30)
				wwow = UDim2.new(0,314, 0, 30)
			elseif Slide == "Left" then
				wwow = UDim2.new(0,45, 0, 30)
				Whhat = UDim2.new(0, 14, 0, 30)
			end

			local PageSlideKua = Instance.new("ScrollingFrame")
			PageSlideKua.Name = "Children_OF_"..text.."_Page_Silde"..Slide
			PageSlideKua.Parent = MainFramePage
			PageSlideKua.Active = true
			PageSlideKua.BackgroundColor3 = Color3.fromRGB(39,39,39)
			PageSlideKua.BackgroundTransparency = 1
			PageSlideKua.BorderSizePixel = 0
			PageSlideKua.Position =  Whhat
			PageSlideKua.Size = UDim2.new(0, 255, 0, 299)
			PageSlideKua.CanvasSize = UDim2.new(0, 0, 0, 0)
			PageSlideKua.ScrollBarThickness = 3
			PageSlideKua.ScrollBarImageColor3 = Color3.fromRGB(219, 150, 11)
			PageSlideKua.AutomaticCanvasSize = Enum.AutomaticSize.Y
			local TextSlider = Instance.new("TextLabel")
			TextSlider.Name = "TextChildrenof"..PageSlideKua.Name
			TextSlider.Parent = MainFramePage
			TextSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextSlider.BackgroundTransparency = 1.000
			TextSlider.Position = wwow
			TextSlider.Size = UDim2.new(0, 180, 0, 26)
			TextSlider.Font = Enum.Font.RobotoMono
			TextSlider.Text = Name
			TextSlider.TextColor3 = Color3.fromRGB(225, 225, 225)
			TextSlider.TextSize = 23.000
			TextSlider.TextTransparency = 0

			Searchbox.FocusLost:Connect(function()
				if #PageSlideKua:GetChildren() == 0 then
					return
				end
				for i, v in pairs(PageSlideKua:GetChildren()) do
					if v:IsA("GuiObject") then
						if string.find(string.lower(v.Name), string.lower(Searchbox.Text)) then
							v.Visible = true
						else
							v.Visible = false
						end
					end
				end
			end)


			local UIPadding = Instance.new("UIPadding")
			local UIListLayout = Instance.new("UIListLayout")

			UIPadding.Parent = PageSlideKua
			UIPadding.PaddingLeft = UDim.new(0, 10)
			UIPadding.PaddingTop = UDim.new(0, 36)

			UIListLayout.Padding = UDim.new(0,8)
			UIListLayout.Parent = PageSlideKua
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			function main:AddSection(config)
				local Label = Instance.new("TextLabel")
				Label.Name = "Label"
				Label.Parent = PageSlideKua
				Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Label.BackgroundTransparency = 1
				Label.Size = UDim2.new(0, 260, 0, 25)
				Label.Font = Enum.Font.RobotoMono
				Label.Text = config.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.TextWrapped = true
				Label.TextColor3 = Color3.fromRGB(225, 225, 225)
				Label.TextSize = 17
				Label.AutomaticSize = Enum.AutomaticSize.None
				local Linee = Instance.new("Frame")

				Linee.Name = "Linee"
				Linee.Parent = Label
				Linee.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Linee.Position = UDim2.new(0, 0, 0, 30)
				Linee.Size = UDim2.new(0, 230, 0, 1.5)
				local uisection = {}

				function uisection:Toggle(config)
					local Default = config.Default or false
					local toggled = Default
					local Toggle = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local Button = Instance.new("TextButton")
					local UICorner_2 = Instance.new("UICorner")
					local Label = Instance.new("TextLabel")
					local ToggleImage = Instance.new("Frame")
					local UICorner_3 = Instance.new("UICorner")
					local Circle = Instance.new("Frame")
					local UICorner_4 = Instance.new("UICorner")

					Toggle.Name = tostring(config.Name)
					Toggle.Parent = PageSlideKua
					Toggle.BackgroundColor3 = Color3.fromRGB(42,42,42)
					Toggle.Size = UDim2.new(0, 235, 0, 31)

					UICorner.CornerRadius = UDim.new(0, 5)
					UICorner.Parent = Toggle

					Button.Name = "Button"
					Button.Parent = Toggle
					Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					Button.Position = UDim2.new(0, 1, 0, 1)
					Button.Size = UDim2.new(0, 235, 0, 29)
					Button.AutoButtonColor = false
					Button.Font = Enum.Font.SourceSans
					Button.Text = ""
					Button.TextColor3 = Color3.fromRGB(0, 0, 0)
					Button.TextSize = 11.000

					UICorner_2.CornerRadius = UDim.new(0, 5)
					UICorner_2.Parent = Button

					local Label = Instance.new("TextLabel")
					local Labed = Instance.new("TextLabel")
					Label.Name = tostring(config.Name)
					Label.Parent = Toggle
					Label.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Label.Size = UDim2.new(0, 235, 0, 24)
					Label.BackgroundTransparency = 1
					Label.Font = Enum.Font.RobotoMono
					Label.Position = UDim2.new(0, 3,0, -3)
					Label.Text = tostring(config.Name)
					Label.TextWrapped = true
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 14
					Label.AutomaticSize = Enum.AutomaticSize.None

					Labed.Name = tostring(config.Description)
					Labed.Parent = Toggle
					Labed.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Labed.Size = UDim2.new(0, 235, 0, 24)
					Labed.BackgroundTransparency = 1
					Labed.Position =  UDim2.new(0, 9,0, 11)
					Labed.Font = Enum.Font.RobotoMono
					Labed.Text = tostring(config.Description)
					Labed.TextWrapped = true
					Labed.TextXAlignment = Enum.TextXAlignment.Left
					Labed.TextColor3 = Color3.fromRGB(94, 94, 94)
					Labed.TextSize = 9
					Labed.AutomaticSize = Enum.AutomaticSize.None

					ToggleImage.Name = "ToggleImage"
					ToggleImage.Parent = Toggle
					ToggleImage.BackgroundColor3 = Color3.fromRGB(36,36,36)
					ToggleImage.Position = UDim2.new(0, 184, 0, 5)
					ToggleImage.Size = UDim2.new(0, 45, 0, 20)

					local UISTORKET = Instance.new("UIStroke")
					UISTORKET.Color = Color3.fromRGB(43,43,43)
					UISTORKET.Thickness = 1.5
					UISTORKET.Parent = ToggleImage

					UICorner_3.CornerRadius = UDim.new(0, 5)
					UICorner_3.Parent = ToggleImage

					Circle.Name = "Circle"
					Circle.Parent = ToggleImage
					Circle.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
					Circle.Position = UDim2.new(0, 2, 0, 2)
					Circle.Size = UDim2.new(0, 16, 0, 16)

					UICorner_4.CornerRadius = UDim.new(0, 10)
					UICorner_4.Parent = Circle

					Button.MouseButton1Click:Connect(function()
						if toggled == false then
							toggled = true
							Circle:TweenPosition(UDim2.new(0,27,0,2),"Out","Sine",0.2,true)
							TweenService:Create(
								Circle,
								TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
								{BackgroundColor3 = Color3.fromRGB(255, 255, 255)}
							):Play()
						elseif toggled == true then
							toggled = false
							Circle:TweenPosition(UDim2.new(0,2,0,2),"Out","Sine",0.2,true)
							TweenService:Create(
								Circle,
								TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
								{BackgroundColor3 = Color3.fromRGB(44, 44, 44)}
							):Play()
						end
						pcall(config.Callback,toggled)
					end)

					if Default == true then
						toggled = not toggled
						Circle:TweenPosition(UDim2.new(0,27,0,2),"Out","Sine",0.4,true)
						TweenService:Create(
							Circle,
							TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
							{BackgroundColor3 = Color3.fromRGB(13, 107, 14)}
						):Play()
						pcall(config.Callback,toggled)
					end
				end
				
				--function uisection:AddColorPicker(config)
				--	-- Gui to Lua
				--	-- Version: 3.2

				--	-- Instances:

				--	local ColorPicker = Instance.new("Frame")
				--	local UICorner = Instance.new("UICorner")
				--	local DropTitle = Instance.new("TextLabel")
				--	local ThisIsMyFrame = Instance.new("Frame")
				--	local UICorner_2 = Instance.new("UICorner")
				--	local DropButton = Instance.new("TextButton")

				--	--Properties:

				--	ColorPicker.Name = "ColorPicker"
				--	ColorPicker.Parent = PageSlideKua
				--	ColorPicker.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				--	ColorPicker.Size = UDim2.new(0, 235, 0, 31)

				--	UICorner.CornerRadius = UDim.new(0, 5)
				--	UICorner.Parent = ColorPicker

				--	DropTitle.Name = "DropTitle"
				--	DropTitle.Parent = ColorPicker
				--	DropTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				--	DropTitle.BackgroundTransparency = 1.000
				--	DropTitle.Position = UDim2.new(0, 2, 0, 0)
				--	DropTitle.Size = UDim2.new(0, 170, 0, 31)
				--	DropTitle.Font = Enum.Font.RobotoMono
				--	DropTitle.Text = config.Name
				--	DropTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
				--	DropTitle.TextSize = 15.000
				--	DropTitle.TextXAlignment = Enum.TextXAlignment.Left

				--	ThisIsMyFrame.Name = "ThisIsMyFrame"
				--	ThisIsMyFrame.Parent = ColorPicker
				--	ThisIsMyFrame.BackgroundColor3 = config.Default
				--	ThisIsMyFrame.ClipsDescendants = true
				--	ThisIsMyFrame.Position = UDim2.new(0, 201, 0, 5)
				--	ThisIsMyFrame.Size = UDim2.new(0, 22, 0, 21)

				--	UICorner_2.Parent = ThisIsMyFrame

				--	DropButton.Name = "DropButton"
				--	DropButton.Parent = ColorPicker
				--	DropButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				--	DropButton.BackgroundTransparency = 1.000
				--	DropButton.Size = UDim2.new(0, 230, 0, 31)
				--	DropButton.Font = Enum.Font.SourceSans
				--	DropButton.Text = ""
				--	DropButton.TextColor3 = Color3.fromRGB(0, 0, 0)
				--	DropButton.TextSize = 14.000
					
				--	DropButton.MouseButton1Click:Connect(function()
				--		-- Gui to Lua
				--		-- Version: 3.2

				--		-- Instances:

				--		local ChoosingFrame = Instance.new("Frame")
				--		local UICorner = Instance.new("UICorner")
				--		local ColorMapFrame = Instance.new("Frame")
				--		local Map = Instance.new("ImageLabel")
				--		local UICorner_2 = Instance.new("UICorner")
				--		local MapOverlay = Instance.new("ImageLabel")
				--		local UICorner_3 = Instance.new("UICorner")
				--		local Choose = Instance.new("Frame")
				--		local UICorner_4 = Instance.new("UICorner")
				--		local TextBtn = Instance.new("TextButton")
				--		local UICorner_5 = Instance.new("UICorner")
				--		local Black = Instance.new("Frame")
				--		local UICorner_6 = Instance.new("UICorner")
				--		local ThisisaButton = Instance.new("TextLabel")
				--		local Decline = Instance.new("Frame")
				--		local UICorner_7 = Instance.new("UICorner")
				--		local TextBtn_2 = Instance.new("TextButton")
				--		local UICorner_8 = Instance.new("UICorner")
				--		local Black_2 = Instance.new("Frame")
				--		local UICorner_9 = Instance.new("UICorner")
				--		local ThisisaButton_2 = Instance.new("TextLabel")

				--		--Properties:

				--		ChoosingFrame.Name = "ChoosingFrame"
				--		ChoosingFrame.Parent = game.StarterGui["LUX2ICANTLUX"].Main.Page.MainPage.PageList.Main_Page
				--		ChoosingFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
				--		ChoosingFrame.ClipsDescendants = true
				--		ChoosingFrame.Position = UDim2.new(0, 111, 0, 51)
				--		ChoosingFrame.Size = UDim2.new(0, 330, 0, 235)
				--		ChoosingFrame.Visible = false

				--		UICorner.Parent = ChoosingFrame

				--		ColorMapFrame.Name = "ColorMapFrame"
				--		ColorMapFrame.Parent = ChoosingFrame
				--		ColorMapFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				--		ColorMapFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				--		ColorMapFrame.BorderSizePixel = 2
				--		ColorMapFrame.Position = UDim2.new(0.0575757585, 0, 0.0638297871, 0)
				--		ColorMapFrame.Size = UDim2.new(0.906886995, 0, 0.714893639, 0)
				--		ColorMapFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY

				--		Map.Name = "Map"
				--		Map.Parent = ColorMapFrame
				--		Map.AnchorPoint = Vector2.new(0.5, 0.5)
				--		Map.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				--		Map.BackgroundTransparency = 1.000
				--		Map.BorderColor3 = Color3.fromRGB(27, 42, 53)
				--		Map.Position = UDim2.new(0.5, 0, 0.5, 0)
				--		Map.Size = UDim2.new(1, 0, 1, 0)
				--		Map.Image = "rbxassetid://5416425915"

				--		UICorner_2.Parent = Map

				--		MapOverlay.Name = "MapOverlay"
				--		MapOverlay.Parent = ColorMapFrame
				--		MapOverlay.AnchorPoint = Vector2.new(0.5, 0.5)
				--		MapOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				--		MapOverlay.BackgroundTransparency = 1.000
				--		MapOverlay.BorderColor3 = Color3.fromRGB(27, 42, 53)
				--		MapOverlay.Position = UDim2.new(0.5, 0, 0.5, 0)
				--		MapOverlay.Size = UDim2.new(1, 0, 1, 0)
				--		MapOverlay.ZIndex = 2
				--		MapOverlay.Image = "rbxassetid://5416437936"
				--		MapOverlay.ImageTransparency = 0.920

				--		UICorner_3.Parent = ColorMapFrame

				--		Choose.Name = "Choose"
				--		Choose.Parent = ChoosingFrame
				--		Choose.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				--		Choose.Position = UDim2.new(0.672727287, 0, 0.834042549, 0)
				--		Choose.Size = UDim2.new(0, 89, 0, 31)

				--		UICorner_4.CornerRadius = UDim.new(0, 5)
				--		UICorner_4.Parent = Choose

				--		TextBtn.Name = "TextBtn"
				--		TextBtn.Parent = Choose
				--		TextBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				--		TextBtn.BackgroundTransparency = 1.000
				--		TextBtn.Position = UDim2.new(0, 1, 0, 1)
				--		TextBtn.Size = UDim2.new(0, 235, 0, 29)
				--		TextBtn.ZIndex = 999
				--		TextBtn.AutoButtonColor = false
				--		TextBtn.TextSize = 1.000
				--		TextBtn.TextTransparency = 1.000

				--		UICorner_5.CornerRadius = UDim.new(0, 5)
				--		UICorner_5.Parent = TextBtn

				--		Black.Name = "Black"
				--		Black.Parent = Choose
				--		Black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				--		Black.BackgroundTransparency = 1.000
				--		Black.BorderSizePixel = 0
				--		Black.Position = UDim2.new(0, 1, 0, 1)
				--		Black.Size = UDim2.new(0, 235, 0, 29)

				--		UICorner_6.CornerRadius = UDim.new(0, 5)
				--		UICorner_6.Parent = Black

				--		ThisisaButton.Name = "This is a Button"
				--		ThisisaButton.Parent = Choose
				--		ThisisaButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
				--		ThisisaButton.BackgroundTransparency = 1.000
				--		ThisisaButton.Position = UDim2.new(0, 3, 0, 0)
				--		ThisisaButton.Size = UDim2.new(0, 86, 0, 31)
				--		ThisisaButton.Font = Enum.Font.RobotoMono
				--		ThisisaButton.Text = "Choose"
				--		ThisisaButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				--		ThisisaButton.TextSize = 22.000
				--		ThisisaButton.TextWrapped = true

				--		Decline.Name = "Decline"
				--		Decline.Parent = ChoosingFrame
				--		Decline.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				--		Decline.Position = UDim2.new(0.0575757585, 0, 0.834042549, 0)
				--		Decline.Size = UDim2.new(0, 88, 0, 31)

				--		UICorner_7.CornerRadius = UDim.new(0, 5)
				--		UICorner_7.Parent = Decline

				--		TextBtn_2.Name = "TextBtn"
				--		TextBtn_2.Parent = Decline
				--		TextBtn_2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
				--		TextBtn_2.BackgroundTransparency = 1.000
				--		TextBtn_2.Position = UDim2.new(0, 1, 0, 1)
				--		TextBtn_2.Size = UDim2.new(0, 235, 0, 29)
				--		TextBtn_2.ZIndex = 999
				--		TextBtn_2.AutoButtonColor = false
				--		TextBtn_2.TextSize = 1.000
				--		TextBtn_2.TextTransparency = 1.000

				--		UICorner_8.CornerRadius = UDim.new(0, 5)
				--		UICorner_8.Parent = TextBtn_2

				--		Black_2.Name = "Black"
				--		Black_2.Parent = Decline
				--		Black_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				--		Black_2.BackgroundTransparency = 1.000
				--		Black_2.BorderSizePixel = 0
				--		Black_2.Position = UDim2.new(0, 1, 0, 1)
				--		Black_2.Size = UDim2.new(0, 235, 0, 29)

				--		UICorner_9.CornerRadius = UDim.new(0, 5)
				--		UICorner_9.Parent = Black_2

				--		ThisisaButton_2.Name = "This is a Button"
				--		ThisisaButton_2.Parent = Decline
				--		ThisisaButton_2.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
				--		ThisisaButton_2.BackgroundTransparency = 1.000
				--		ThisisaButton_2.Position = UDim2.new(0, 3, 0, 0)
				--		ThisisaButton_2.Size = UDim2.new(0, 86, 0, 31)
				--		ThisisaButton_2.Font = Enum.Font.RobotoMono
				--		ThisisaButton_2.Text = "Decline"
				--		ThisisaButton_2.TextColor3 = Color3.fromRGB(255, 255, 255)
				--		ThisisaButton_2.TextSize = 22.000
				--		ThisisaButton_2.TextWrapped = true
				--	end)
				--end
				
				function uisection:Keybind(config)
					local KeyBird = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local ThisIsMyFrame = Instance.new("Frame")
					local ChhTitle = Instance.new("TextLabel")
					local DropTitle = Instance.new("TextLabel")
					local UICorner_2 = Instance.new("UICorner")
					local DropButton = Instance.new("TextButton")

					KeyBird.Name = "KeyBird"
					KeyBird.Parent = PageSlideKua
					KeyBird.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					KeyBird.ClipsDescendants = true
					KeyBird.Size = UDim2.new(0, 235, 0, 31)

					UICorner.CornerRadius = UDim.new(0, 5)
					UICorner.Parent = KeyBird
					
					DropTitle.Name = "DropTitle"
					DropTitle.Parent = KeyBird
					DropTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropTitle.BackgroundTransparency = 1.000
					DropTitle.Position = UDim2.new(0, 2, 0, 0)
					DropTitle.Size = UDim2.new(0, 170, 0, 31)
					DropTitle.Font = Enum.Font.RobotoMono
					DropTitle.Text = config.Name
					DropTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
					DropTitle.TextSize = 15.000
					DropTitle.TextXAlignment = Enum.TextXAlignment.Left

					ThisIsMyFrame.Name = "ThisIsMyFrame"
					ThisIsMyFrame.Parent = KeyBird
					ThisIsMyFrame.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
					ThisIsMyFrame.ClipsDescendants = true
					ThisIsMyFrame.Position = UDim2.new(0, 180, 0, 5)
					ThisIsMyFrame.Size = UDim2.new(0, 43, 0, 21)

					ChhTitle.Name = "ChhTitle"
					ChhTitle.Parent = ThisIsMyFrame
					ChhTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ChhTitle.BackgroundTransparency = 1.000
					ChhTitle.Position = UDim2.new(0, 0, 0, 3)
					ChhTitle.Size = UDim2.new(0, 41, 0, 15)
					ChhTitle.Font = Enum.Font.RobotoMono
					ChhTitle.Text = config.Default
					ChhTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					ChhTitle.TextScaled = true
					ChhTitle.TextWrapped = true

					UICorner_2.Parent = ThisIsMyFrame

					DropButton.Name = "DropButton"
					DropButton.Parent = KeyBird
					DropButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropButton.BackgroundTransparency = 1.000
					DropButton.Size = UDim2.new(0, 230, 0, 31)
					DropButton.Font = Enum.Font.SourceSans
					DropButton.Text = ""
					DropButton.TextColor3 = Color3.fromRGB(0, 0, 0)
					DropButton.TextSize = 14.000
					
					if config.Default ~= nil then 
						ChhTitle.Text = config.Default
						yoo = config.Default
					end

					DropButton.MouseButton1Click:Connect(function()
						ChhTitle.Text = "..."
						local userInputService = game:GetService("UserInputService")

						local inputwait = userInputService.InputBegan:Wait() 
						local shiba

						if inputwait.UserInputType == Enum.UserInputType.MouseButton1 or inputwait.UserInputType == Enum.UserInputType.MouseButton2 then
							shiba = inputwait.UserInputType
						elseif inputwait.KeyCode ~= Enum.KeyCode.Unknown then
							shiba = inputwait.KeyCode
						else
							shiba = nil
						end

						if shiba and shiba.Name ~= "Focus" and shiba.Name ~= "MouseButton1" then
							ChhTitle.Text = shiba.Name
							yoo = shiba.Name
						else
							ChhTitle.Text = config.Default
						end
					end)
				end


				function uisection:Textbox(config)
					local UICorner = Instance.new("UICorner")
					local RealTextbox = Instance.new("TextBox")

					local callback = config.Callback or function() end

					RealTextbox.Name = tostring(config.Title)
					RealTextbox.Parent = PageSlideKua
					RealTextbox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
					RealTextbox.BackgroundTransparency = 0
					RealTextbox.Position = UDim2.new(0, 360, 0, 4)
					RealTextbox.Size = UDim2.new(0, 235, 0, 31)
					RealTextbox.Font = Enum.Font.RobotoMono
					RealTextbox.Text = ""
					RealTextbox.TextColor3 = Color3.fromRGB(225, 225, 225)
					RealTextbox.TextSize = 11.000
					RealTextbox.TextTransparency = 0
					RealTextbox.PlaceholderText = tostring(config.Title)

					RealTextbox.FocusLost:Connect(function()
						callback(RealTextbox.Text)
					end)

					UICorner.CornerRadius = UDim.new(0, 5)
					UICorner.Parent = RealTextbox
				end


				function uisection:AddLabel(config)
					local Label = Instance.new("TextLabel")
					Label.Name = tostring(config.Text)
					Label.Parent = PageSlideKua
					Label.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Label.Size = UDim2.new(0, 235, 0, 31)
					Label.Font = Enum.Font.RobotoMono
					Label.Text = config.Text
					Label.TextWrapped = true
					Label.TextColor3 = Color3.fromRGB(225, 225, 225)
					Label.TextSize = 14
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.AutomaticSize = Enum.AutomaticSize.None
					local UICorner = Instance.new("UICorner")
					UICorner.CornerRadius = UDim.new(0, 5)
					UICorner.Parent = Label

					local labelset = {}

					function labelset:SetupLabel(newtext)
						Label.Text = newtext
					end

					return labelset
				end

				function uisection:Dropdown(config)
					local isdropping = false
					local Dropdown = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local DropTitle = Instance.new("TextLabel")
					local DropScroll = Instance.new("ScrollingFrame")
					local UIListLayout = Instance.new("UIListLayout")
					local UIPadding = Instance.new("UIPadding")
					local DropButton = Instance.new("TextButton")
					local DropImage = Instance.new("ImageLabel") 
					local MultiList = {}

					local callback = config.Callback or function() end
					local name = config.Name
					local option = config.Option

					Dropdown.Name = tostring(config.Name)
					Dropdown.Parent = PageSlideKua
					Dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					Dropdown.ClipsDescendants = true
					Dropdown.Size = UDim2.new(0, 235, 0, 31)

					UICorner.CornerRadius = UDim.new(0, 5)
					UICorner.Parent = Dropdown

					DropTitle.Name = "DropTitle"
					DropTitle.Parent = Dropdown
					DropTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropTitle.BackgroundTransparency = 1.000
					DropTitle.Size = UDim2.new(0, 170, 0, 31)
					DropTitle.Font = Enum.Font.RobotoMono
					DropTitle.TextXAlignment = Enum.TextXAlignment.Left
					DropTitle.Text = tostring(name)
					DropTitle.Position = UDim2.new(0,2,0,0)
					DropTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
					DropTitle.TextSize = 15.000

					DropScroll.Name = "DropScroll"
					DropScroll.Parent = DropTitle
					DropScroll.Active = true
					DropScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropScroll.BackgroundTransparency = 1.000
					DropScroll.BorderSizePixel = 0
					DropScroll.Position = UDim2.new(0, 0, 0, 31)
					DropScroll.Size = UDim2.new(0, 230, 0, 100)
					DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
					DropScroll.ScrollBarThickness = 5
					DropScroll.ScrollBarImageColor3 = Color3.fromRGB(219, 150, 11)

					local Dropdownss = Instance.new("Frame")
					Dropdownss.Name = "ThisIsMyFrame"
					Dropdownss.Parent = Dropdown
					Dropdownss.BackgroundColor3 = Color3.fromRGB(63, 63, 63)
					Dropdownss.ClipsDescendants = true
					Dropdownss.Size = UDim2.new(0, 60,0, 21)
					Dropdownss.Position = UDim2.new(0, 163,0, 5)

					local DropTitlessd = Instance.new("TextLabel")
					DropTitlessd.Name = "ChhTitle"
					DropTitlessd.Parent = Dropdownss
					DropTitlessd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropTitlessd.BackgroundTransparency = 1.000
					DropTitlessd.Size = UDim2.new(0, 35, 0, 15)
					DropTitlessd.Position = UDim2.new(0, 6, 0, 3)
					DropTitlessd.Font = Enum.Font.RobotoMono
					DropTitlessd.Text = "..."
					DropTitlessd.TextColor3 = Color3.fromRGB(255,255,255)
					DropTitlessd.TextScaled = true

					local uisex = Instance.new("UICorner")
					uisex.CornerRadius = UDim.new(0, 8)
					uisex.Parent = Dropdownss

					DropImage.Name = "DropImage"
					DropImage.Parent = Dropdown
					DropImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropImage.BackgroundTransparency = 1.000
					DropImage.Position = UDim2.new(0, 207, 0, 7)
					DropImage.Rotation = 180.000
					DropImage.Size = UDim2.new(0, 20, 0, 20)
					DropImage.Image = "rbxassetid://6031090990"

					UIListLayout.Parent = DropScroll
					UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
					UIListLayout.Padding = UDim.new(0, 5)

					UIPadding.Parent = DropScroll
					UIPadding.PaddingLeft = UDim.new(0, 5)
					UIPadding.PaddingTop = UDim.new(0, 3)

					DropButton.Name = "DropButton"
					DropButton.Parent = Dropdown
					DropButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					DropButton.BackgroundTransparency = 1.000
					DropButton.Size = UDim2.new(0, 230, 0, 31)
					DropButton.Font = Enum.Font.SourceSans
					DropButton.Text = ""
					DropButton.TextColor3 = Color3.fromRGB(0, 0, 0)
					DropButton.TextSize = 14.000
					
					if type(option) == "table" and config.Multi == true then
						for i, v in ipairs(option) do

							local Item = Instance.new("TextButton")
							Item.Name = "Item"
							Item.Parent = DropScroll
							Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							Item.BackgroundTransparency = 1
							Item.Size = UDim2.new(0, 230, 0, 26)
							Item.Font = Enum.Font.RobotoMono
							Item.Text = tostring(v)
							Item.TextColor3 = Color3.fromRGB(225, 225, 225)
							Item.TextSize = 13
							Item.TextTransparency = 0.5

							Item.MouseEnter:Connect(function()
								TweenService:Create(
									Item,
									TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{ TextTransparency = 0 }
								):Play()
							end)

							Item.MouseLeave:Connect(function()
								TweenService:Create(
									Item,
									TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{ TextTransparency = 0.5 }
								):Play()
							end)
							
							if type(config.Default) == "table" then
								for _, p in pairs(config.Default) do
									if v == tostring(p) then
										if not tablefound(MultiList, p) then
											MultiList = MultiList or {}
											table.insert(MultiList, p)
										end
										if Item.Text == tostring(p) then
											Item.TextColor3 = Color3.fromRGB(255, 255, 146) -- เปลี่ยนสีของ Item
										end
										DropTitlessd.Text = tostring(table.concat(MultiList, ","))
										pcall(callback, p)
										pcall(callback, MultiList)
									end
								end
							end

							Item.MouseButton1Click:Connect(function()
								if not tablefound(MultiList, v) then
									table.insert(MultiList, v)
									Item.TextColor3 = Color3.fromRGB(255, 255, 146) -- Highlight color
								else
									for index, value in ipairs(MultiList) do
										if value == v then
											table.remove(MultiList, index)
											Item.TextColor3 = Color3.fromRGB(225, 225, 225) -- Default color
											break
										end
									end
								end
								if #MultiList == 0 then
									DropTitlessd.Text = "..."
								else
									DropTitlessd.Text = tostring(table.concat(MultiList, ","))
								end
								pcall(callback, MultiList)
							end)
						end

						DropScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

						DropButton.MouseButton1Click:Connect(function()
							if isdropping then
								isdropping = false
								Dropdown:TweenSize(UDim2.new(0, 235, 0, 31), "Out", "Quad", 0.3, true)
							else
								isdropping = true
								Dropdown:TweenSize(UDim2.new(0, 235, 0, 131), "Out", "Quad", 0.3, true)
							end
						end)

						local dropfunc = {}

						function dropfunc:Clear()
							DropTitlessd.Text = "..."
							isdropping = false
							Dropdown:TweenSize(UDim2.new(0, 235, 0, 31), "Out", "Quad", 0.3, true)
							for _, child in ipairs(DropScroll:GetChildren()) do
								if child:IsA("TextButton") then
									child:Destroy()
								end
							end
							MultiList = {}
						end

						return dropfunc
					end


					if type(option) == "table" and config.Multi == false then
						for i,v in ipairs(option) do
							local Item = Instance.new("TextButton")

							Item.Name = "Item"
							Item.Parent = DropScroll
							Item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							Item.BackgroundTransparency = 1.000
							Item.Size = UDim2.new(0, 230, 0, 26)
							Item.Font = Enum.Font.RobotoMono
							Item.Text = tostring(v)
							Item.TextColor3 = Color3.fromRGB(225, 225, 225)
							Item.TextSize = 13.000
							Item.TextTransparency = 0.500
							
							if type(config.Default) == "table" then
								for _, p in pairs(config.Default) do
									if v == tostring(p) then
										if Item.Text == tostring(p) then
											Item.TextColor3 = Color3.fromRGB(255, 255, 146)
										end
										DropTitlessd.Text = tostring(p)
										pcall(callback, p)
									end
								end
							end

							Item.MouseEnter:Connect(function()
								TweenService:Create(
									Item,
									TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
									{TextTransparency = 0}
								):Play()
							end)

							Item.MouseLeave:Connect(function()
								TweenService:Create(
									Item,
									TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
									{TextTransparency = 0.5}
								):Play()
							end)

							Item.MouseButton1Click:Connect(function()
								isdropping = false
								Dropdown:TweenSize(UDim2.new(0, 235, 0, 31), "Out", "Quad", 0.3, true)
								for _, child in ipairs(DropScroll:GetChildren()) do
									if child:IsA("TextButton") then
										child.TextColor3 = Color3.fromRGB(225, 225, 225) 
									end
								end
								Item.TextColor3 = Color3.fromRGB(255, 255, 146) 
								DropTitlessd.Text = Item.Text
								callback(Item.Text)
							end)
						end
					end

					DropScroll.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y + 10)

					DropButton.MouseButton1Click:Connect(function()
						if isdropping == false then
							isdropping = true
							Dropdown:TweenSize(UDim2.new(0,235,0,131),"Out","Quad",0.3,true)
						else
							isdropping = false
							Dropdown:TweenSize(UDim2.new(0,235,0,31),"Out","Quad",0.3,true)
						end
					end)

					local dropfunc = {}

					function dropfunc:Clear()
						DropTitlessd.Text = "..."
						isdropping = false
						Dropdown:TweenSize(UDim2.new(0,235,0,31),"Out","Quad",0.3,true)
						for i,v in next, DropScroll:GetChildren() do
							if v:IsA("TextButton") then
								v:Destroy()
							end
						end
					end
					return dropfunc
				end

				function uisection:Slider(config)
					local Slider = Instance.new("Frame")
					local slidercorner = Instance.new("UICorner")
					local sliderr = Instance.new("Frame")
					local sliderrcorner = Instance.new("UICorner")
					local AHEHE = Instance.new("TextButton")
					local bar = Instance.new("Frame")
					local bar1 = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local valuecorner = Instance.new("UICorner")

					local callback = config.Callback or function() end

					Slider.Name = tostring(config.Name)
					Slider.Parent = PageSlideKua
					Slider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					Slider.BackgroundTransparency = 0
					Slider.Size = UDim2.new(0, 235, 0, 31)

					slidercorner.CornerRadius = UDim.new(0, 5)
					slidercorner.Name = "slidercorner"
					slidercorner.Parent = Slider

					sliderr.Name = "sliderr"
					sliderr.Parent = Slider
					sliderr.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					sliderr.Position = UDim2.new(0, 1, 0, 1)
					sliderr.Size = UDim2.new(0, 235, 0, 37)

					sliderrcorner.CornerRadius = UDim.new(0, 5)
					sliderrcorner.Name = "sliderrcorner"
					sliderrcorner.Parent = sliderr

					local Label = Instance.new("TextLabel")
					local Labed = Instance.new("TextLabel")
					
					Label.Name = tostring(config.Name)
					Label.Parent = sliderr
					Label.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Label.Size = UDim2.new(0, 111,0, 24)
					Label.BackgroundTransparency = 1
					Label.Font = Enum.Font.RobotoMono
					Label.Position = UDim2.new(0, 3,0, 0)
					Label.Text = tostring(config.Name)
					Label.TextWrapped = true
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 14
					Label.AutomaticSize = Enum.AutomaticSize.XY

					Labed.Name = tostring(config.Description)
					Labed.Parent =sliderr
					Labed.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Labed.Size = UDim2.new(0, 235, 0, 24)
					Labed.BackgroundTransparency = 1
					Labed.Position =  UDim2.new(0, 9,0, 12)
					Labed.Font = Enum.Font.RobotoMono
					Labed.Text = tostring(config.Description)
					Labed.TextWrapped = true
					Labed.TextXAlignment = Enum.TextXAlignment.Left
					Labed.TextColor3 = Color3.fromRGB(94, 94, 94)
					Labed.TextSize = 9
					Labed.AutomaticSize = Enum.AutomaticSize.None


					AHEHE.Name = "AHEHE"
					AHEHE.Parent = sliderr
					AHEHE.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					AHEHE.BackgroundTransparency = 1.000
					AHEHE.Position = UDim2.new(0.502, 0,0.351, 0)
					AHEHE.Size = UDim2.new(0, 103,0, 20)
					AHEHE.Font = Enum.Font.SourceSans
					AHEHE.Text = ""
					AHEHE.TextColor3 = Color3.fromRGB(0, 0, 0)
					AHEHE.TextSize = 14.000

					bar.Name = "bar"
					bar.Parent = AHEHE
					bar.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
					bar.Size = UDim2.new(0, 103,0, 7)
					
					local UICORNERSEX = Instance.new("UICorner")
					UICORNERSEX.CornerRadius = UDim.new(0,12)
					UICORNERSEX.Parent = bar
					
					local Labeds = Instance.new("TextLabel")
					Labeds.Name = "JONGKUNUM"
					Labeds.Parent = sliderr
					Labeds.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Labeds.Size = UDim2.new(0, 81,0, 11)
					Labeds.BackgroundTransparency = 1
					Labeds.Position =  UDim2.new(0, 128,0, 1)
					Labeds.Font = Enum.Font.RobotoMono
					Labeds.Text = tonumber(config.min)
					Labeds.TextWrapped = true
					Labeds.TextColor3 = Color3.fromRGB(94, 94, 94)
					Labeds.TextSize = 9
					Labeds.AutomaticSize = Enum.AutomaticSize.None

					bar1.Name = "bar1"
					bar1.Parent = bar
					bar1.BackgroundColor3 = Color3.fromRGB(222, 186, 5)
					bar1.BackgroundTransparency = 0
					bar1.Size = UDim2.new(tonumber(config.set)/tonumber(config.max), 0,0, 7)
					local UICORNERSEX = Instance.new("UICorner")
					UICORNERSEX.CornerRadius = UDim.new(0,12)
					UICORNERSEX.Parent = bar1
					local mouse = game.Players.LocalPlayer:GetMouse()
					local uis = game:GetService("UserInputService")
						if Value == nil then
							Value = config.set
							pcall(function()
								callback(Value)
							end)
						end

					AHEHE.MouseButton1Down:Connect(function()
						Value = math.floor((((tonumber(config.max) - tonumber(config.min)) / 103) * bar1.AbsoluteSize.X) + tonumber(config.min)) or 0
						pcall(function()
							callback(Value)
						end)
						bar1.Size = UDim2.new(0, math.clamp(mouse.X - bar1.AbsolutePosition.X, 0, 103), 0, 7)
						moveconnection = mouse.Move:Connect(function()
							Value = (((tonumber(config.max) - tonumber(config.min)) / 103) * bar1.AbsoluteSize.X) + tonumber(config.min)
							Value = math.floor(Value * 100) / 100 
							bar1.Size = UDim2.new(0, math.clamp(mouse.X - bar1.AbsolutePosition.X, 0, 103), 0, 7)
							Labeds.Text = tostring(Value)
							pcall(function()
								callback(Value)
							end)
						end)
						releaseconnection = uis.InputEnded:Connect(function(Mouse)
							if Mouse.UserInputType == Enum.UserInputType.MouseButton1 then
								Value = math.floor((((tonumber(config.max) - tonumber(config.min)) / 103) * bar1.AbsoluteSize.X) + tonumber(config.min))
								pcall(function()
									callback(Value)
								end)
								moveconnection:Disconnect()
								releaseconnection:Disconnect()
							end
						end)
					end)
				end

				function uisection:AddButton(config)
					local Button = Instance.new("Frame")
					local UICorner = Instance.new("UICorner")
					local TextBtn = Instance.new("TextButton")
					local UICorner_2 = Instance.new("UICorner")
					local Black = Instance.new("Frame")
					local UICorner_3 = Instance.new("UICorner")
					local Label = Instance.new("TextLabel")
					local Labed = Instance.new("TextLabel")

					local callback = config.Callback or function() end

					Button.Name = tostring(config.Title)
					Button.Parent = PageSlideKua
					Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					Button.Size = UDim2.new(0, 235, 0, 31)

					UICorner.CornerRadius = UDim.new(0, 5)
					UICorner.Parent = Button

					TextBtn.Name = "TextBtn"
					TextBtn.Transparency = 1
					TextBtn.Parent = Button
					--TextBtn.TextXAlignment = Enum.TextXAlignment.Left
					TextBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					TextBtn.Position = UDim2.new(0, 1, 0, 1)
					TextBtn.Size = UDim2.new(0, 235, 0, 29)
					TextBtn.AutoButtonColor = false
					TextBtn.ZIndex =999
					TextBtn.TextSize=0
					--TextBtn.Font = Enum.Font.RobotoMono
					--TextBtn.Text = config.Title
					--TextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					--TextBtn.TextSize = 13.000
					
					local imagelabelsmalubchai  = Instance.new("ImageLabel") 
					imagelabelsmalubchai.Parent = Button
					imagelabelsmalubchai.Size = UDim2.new(0, 27, 0, 27)
					imagelabelsmalubchai.BackgroundTransparency = 1
					imagelabelsmalubchai.Position = UDim2.new(0, 205,0, 3)
					imagelabelsmalubchai.Image = "rbxassetid://7158102700"
					imagelabelsmalubchai.ImageColor3 = Color3.fromRGB(255,255,255)
					
					Label.Name = tostring(config.Title)
					Label.Parent = Button
					Label.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Label.Size = UDim2.new(0, 235, 0, 24)
					Label.BackgroundTransparency = 1
					Label.Font = Enum.Font.RobotoMono
					Label.Position = UDim2.new(0, 3,0, -3)
					Label.Text = tostring(config.Title)
					Label.TextWrapped = true
					Label.TextXAlignment = Enum.TextXAlignment.Left
					Label.TextColor3 = Color3.fromRGB(255, 255, 255)
					Label.TextSize = 14
					Label.AutomaticSize = Enum.AutomaticSize.None
					
					Labed.Name = tostring(config.Description)
					Labed.Parent = Button
					Labed.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
					Labed.Size = UDim2.new(0, 235, 0, 24)
					Labed.BackgroundTransparency = 1
					Labed.Position =  UDim2.new(0, 9,0, 11)
					Labed.Font = Enum.Font.RobotoMono
					Labed.Text = tostring(config.Description)
					Labed.TextWrapped = true
					Labed.TextXAlignment = Enum.TextXAlignment.Left
					Labed.TextColor3 = Color3.fromRGB(94, 94, 94)
					Labed.TextSize = 9
					Labed.AutomaticSize = Enum.AutomaticSize.None

					UICorner_2.CornerRadius = UDim.new(0, 5)
					UICorner_2.Parent = TextBtn

					Black.Name = "Black"
					Black.Parent = Button
					Black.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					Black.BackgroundTransparency = 1.000
					Black.BorderSizePixel = 0
					Black.Position = UDim2.new(0, 1, 0, 1)
					Black.Size = UDim2.new(0, 235, 0, 29)

					UICorner_3.CornerRadius = UDim.new(0, 5)
					UICorner_3.Parent = Black

					TextBtn.MouseEnter:Connect(function()
						TweenService:Create(
							Black,
							TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
							{BackgroundTransparency = 0.6}
						):Play()
					end)
					TextBtn.MouseLeave:Connect(function()
						TweenService:Create(
							Black,
							TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
							{BackgroundTransparency = 1}
						):Play()
					end)
					TextBtn.MouseButton1Click:Connect(function()
						CircleAnim(TextBtn,Color3.fromRGB(255,255,255),Color3.fromRGB(255,255,255))
						callback()
					end)
				end 
				return uisection
			end
			return main
		end
		return  section
	end
	return uitab
end


local Library = Update:CreateWindow("Alice Hub","100775705581086",Enum.KeyCode.Tab);
Main = Library:Tab("Main")
Misc = Library:Tab("Misc")


local MainPage = Main:AddPage("Main","Left")
local MiscPage = Main:AddPage("Misc","Right")

local MainSection = MainPage:AddSection({
	Text = "Main"
})

MainSection:AddButton({
	Title = "Jerk Off",
	Description = "jerk off script on your ass",
	Callback = function()
		loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))()
	end
})

ISCARBON = function()
	if game.ReplicatedStorage:FindFirstChild("SM7A2") then
	return "Special"		
	end

	if game.ReplicatedStorage:FindFirstChild("CarbonResource") or game.ReplicatedStorage:FindFirstChild("CE_Resource") then
	return true
	end 
	return false
end      

if ISCARBON() == true then
MainSection:AddButton({
	Title = "Kill All",
	Description = "die because my dick",
	Callback = function()
		if game.ReplicatedStorage:FindFirstChild("CarbonResource") then
			for _,player in pairs(game.Players:GetPlayers()) do
				if player ~= game.Players.LocalPlayer then
					 game.ReplicatedStorage.CarbonResource.Events:GetChildren()[4]:FireServer(player.Character.Humanoid, 100, "Head", {'nil', 'Auth', 'nil', 'nil'})
				end
			end
		  end
	end
})
end


MainSection:Slider({
		Name = "Walkspeed",
		Description = "Walkspeed",
		min = 32,
		max = 100,
		set = 32,
		Callback = function(value)
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
		end,
	})

	MainSection:Toggle({
		Name = "Noclip",
		Description = "ทะลุได้",
		Default = false,
		Callback = function(value)
			getgenv().Noclip = value
		end
	})
	
	spawn(function()
		while game:GetService("RunService").Stepped:wait() do
			pcall(function()
				if getgenv().Noclip then
					local character = game.Players.LocalPlayer.Character
					for _, v in pairs(character:GetChildren()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
				end
			end)
		end
	end)
	

--Background:Toggle({
--	Name = "Light Theme",
--	Description = "Light/Dark Theme",
--	Default = false,
--	Callback = function(value)
--		Theme(value)
--	end
--})