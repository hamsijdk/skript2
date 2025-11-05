-- Srox Hack GUI (tam çalışan) | LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Durumlar
local flying = false
local noclip = false
local flySpeed = 50
local control = {F=0,B=0,L=0,R=0}
local bodyGyro, bodyVelocity

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0,120,0,50)
mainButton.Position = UDim2.new(0,50,0,150)
mainButton.Text = "Srox Hack"
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 18
mainButton.TextColor3 = Color3.new(1,1,1)
mainButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
mainButton.BorderSizePixel = 0
mainButton.AutoButtonColor = true
mainButton.Active = true
mainButton.Parent = screenGui
local mbCorner = Instance.new("UICorner", mainButton)
mbCorner.CornerRadius = UDim.new(0,15)
mainButton.Draggable = true

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,400,0,300)
panel.Position = UDim2.new(0.5,-200,-1,0)
panel.AnchorPoint = Vector2.new(0.5,0)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.ClipsDescendants = true
local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0,10)

-- Panel draggable
local draggingPanel = false
local dragInput, dragStart, startPos
local titleBar = Instance.new("Frame", panel)
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.BackgroundTransparency = 1
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPanel = true
		dragStart = input.Position
		startPos = panel.Position
	end
end)
titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingPanel and input == dragInput then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPanel = false
	end
end)

-- Başlık yazısı
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1,0,1,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Srox Hack  •  efeakincipo"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 16

-- Kapat butonu
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,28,0,24)
closeBtn.Position = UDim2.new(1,-34,0,6)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0,6)

-- Panel içerik
local contentY = 46
local function makeButton(text, y)
	local btn = Instance.new("TextButton", panel)
	btn.Size = UDim2.new(0,360,0,40)
	btn.Position = UDim2.new(0.5,-180,y)
	btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BorderSizePixel = 0
	local c = Instance.new("UICorner", btn)
	c.CornerRadius = UDim.new(0,15)
	return btn
end

local flyBtn = makeButton("Fly: Kapalı", contentY)
contentY = contentY + 52

local speedLabel = Instance.new("TextLabel", panel)
speedLabel.Size = UDim2.new(0,360,0,20)
speedLabel.Position = UDim2.new(0.5,-180,0,contentY)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Hızı: "..flySpeed
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
contentY = contentY + 24

local sliderBG = Instance.new("Frame", panel)
sliderBG.Size = UDim2.new(0,360,0,18)
sliderBG.Position = UDim2.new(0.5,-180,0,contentY)
sliderBG.BackgroundColor3 = Color3.fromRGB(75,75,75)
sliderBG.BorderSizePixel = 0
local sliderBGCorner = Instance.new("UICorner", sliderBG)
sliderBGCorner.CornerRadius = UDim.new(0,9)

local sliderFill = Instance.new("Frame", sliderBG)
sliderFill.Size = UDim2.new(flySpeed/200,0,1,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120,120,255)
local sliderFillCorner = Instance.new("UICorner", sliderFill)
sliderFillCorner.CornerRadius = UDim.new(0,9)

contentY = contentY + 34
local noclipBtn = makeButton("Duvardan Geçme: Kapalı", contentY)

-- Panel animasyon
local panelOpen = false
local openTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5,-200,0.2,0)}
local closeGoal = {Position = UDim2.new(0.5,-200,-1,0)}

local function togglePanel()
	if not panelOpen then
		TweenService:Create(panel, openTweenInfo, openGoal):Play()
		panelOpen = true
	else
		TweenService:Create(panel, closeTweenInfo, closeGoal):Play()
		panelOpen = false
	end
end

mainButton.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(togglePanel)

-- Fly motor
local function startFly()
	if flying then return end
	flying = true
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart

	bodyGyro = Instance.new("BodyGyro", root)
	bodyVelocity = Instance.new("BodyVelocity", root)
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bodyGyro.CFrame = root.CFrame
	bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)

	RunService:BindToRenderStep("SroxFly",200,function()
		if not flying then return end
		local cam = workspace.CurrentCamera
		bodyGyro.CFrame = cam.CFrame
		local dir = (cam.CFrame.LookVector*(control.F+control.B)) + (cam.CFrame.RightVector*(control.R+control.L))
		bodyVelocity.Velocity = dir * flySpeed
	end)
end

local function stopFly()
	flying = false
	pcall(function() RunService:UnbindFromRenderStep("SroxFly") end)
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
end

-- Noclip
RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _,p in pairs(player.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end
end)

-- Key input
UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.W then control.F = 1 end
	if inp.KeyCode == Enum.KeyCode.S then control.B = -1 end
	if inp.KeyCode == Enum.KeyCode.A then control.L = -1 end
	if inp.KeyCode == Enum.KeyCode.D then control.R = 1 end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp.KeyCode == Enum.KeyCode.W then control.F = 0 end
	if inp.KeyCode == Enum.KeyCode.S then control.B = 0 end
	if inp.KeyCode == Enum.KeyCode.A then control.L = 0 end
	if inp.KeyCode == Enum.KeyCode.D then control.R = 0 end
end)

-- UI etkileşimleri
flyBtn.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyBtn.Text = "Fly: Kapalı"
	else
		startFly()
		flyBtn.Text = "Fly: Açık"
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "Duvardan Geçme: Açık" or "Duvardan Geçme: Kapalı"
end)

-- Slider
local draggingSlider = false
sliderBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local x = math.clamp(input.Position.X - sliderBG.AbsolutePosition.X, 0, sliderBG.AbsoluteSize.X)
		local frac = x / sliderBG.AbsoluteSize.X
		flySpeed = math.max(1, math.floor(frac*200))
		sliderFill.Size = UDim2.new(frac,0,1,0)
		speedLabel.Text = "Fly Hızı: "..tostring(flySpeed)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

-- Spawn olunca fly reset
player.CharacterAdded:Connect(function()
	wait(0.2)
	if flying then
		pcall(stopFly)
		pcall(startFly)
	end
end)
