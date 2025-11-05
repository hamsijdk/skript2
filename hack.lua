-- Srox Hack - Fly + Noclip (Draggable GUI)
-- LocalScript -> StarterPlayerScripts veya StarterGui içine at

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- State
local flying = false
local noclip = false
local flySpeed = 50
local control = {F=0,B=0,L=0,R=0}
local bodyGyro, bodyVelocity

-- UI root
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton (Srox Hack)
local mainButton = Instance.new("TextButton")
mainButton.Name = "SroxMainButton"
mainButton.Size = UDim2.new(0,90,0,40)          -- biraz daha geniş
mainButton.Position = UDim2.new(0,20,0,120)
mainButton.AnchorPoint = Vector2.new(0,0)
mainButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
mainButton.TextColor3 = Color3.new(1,1,1)
mainButton.Text = "Srox Hack"
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 18
mainButton.Parent = screenGui
mainButton.AutoButtonColor = true
mainButton.Active = true
-- Oval
local mbCorner = Instance.new("UICorner", mainButton)
mbCorner.CornerRadius = UDim.new(0,12)

-- Panel (başlangıçta ekranın üstünde gizli)
local panel = Instance.new("Frame")
panel.Name = "SroxPanel"
panel.Size = UDim2.new(0,360,0,240)             -- genişletilmiş
panel.Position = UDim2.new(0.5,-180,-0.8,0)     -- yukardan gizli başlar
panel.AnchorPoint = Vector2.new(0.5,0)
panel.BackgroundColor3 = Color3.fromRGB(30,30,30)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.ClipsDescendants = true

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0,10)

-- Panel üst çubuğu (sürüklemek için tutma alanı)
local titleBar = Instance.new("Frame", panel)
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.Position = UDim2.new(0,0,0,0)
titleBar.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(0.9,0,1,0)
titleLabel.Position = UDim2.new(0.05,0,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Srox Hack  •  Yapan: efeakincipo"
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(225,225,225)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Kapat butonu (küçük X)
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

-- İçerik (butonları ve slider)
local contentY = 46
local function makeButton(text, y)
	local btn = Instance.new("TextButton", panel)
	btn.Size = UDim2.new(0,320,0,40)
	btn.Position = UDim2.new(0.5,-160,y)
	btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BorderSizePixel = 0
	local c = Instance.new("UICorner", btn)
	c.CornerRadius = UDim.new(0,12)
	return btn
end

local flyBtn = makeButton("Fly: Kapalı", contentY)
contentY = contentY + 52

-- Fly hız label + slider background
local speedLabel = Instance.new("TextLabel", panel)
speedLabel.Size = UDim2.new(0,320,0,20)
speedLabel.Position = UDim2.new(0.5,-160,0,contentY)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Hızı: "..tostring(flySpeed)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
contentY = contentY + 24

local sliderBG = Instance.new("Frame", panel)
sliderBG.Size = UDim2.new(0,320,0,18)
sliderBG.Position = UDim2.new(0.5,-160,0,contentY)
sliderBG.BackgroundColor3 = Color3.fromRGB(75,75,75)
sliderBG.BorderSizePixel = 0
local sliderBGCorner = Instance.new("UICorner", sliderBG)
sliderBGCorner.CornerRadius = UDim.new(0,9)

local sliderFill = Instance.new("Frame", sliderBG)
sliderFill.Size = UDim2.new( flySpeed/200, 0, 1, 0 ) -- 0..200 range
sliderFill.Position = UDim2.new(0,0,0,0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120,120,255)
local sliderFillCorner = Instance.new("UICorner", sliderFill)
sliderFillCorner.CornerRadius = UDim.new(0,9)

contentY = contentY + 34

local noclipBtn = makeButton("Duvardan Geçme: Kapalı", contentY)
contentY = contentY + 52

-- Başlangıç görünürlüğü: panel gizli (yukarıda)
panel.Visible = true -- görünür ama yukarda; açma animasyonu ile geleceğiz

-- Panel açma animasyonu (mainButton tıklayınca)
local openTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5,-180,0.2,0)}
local closeGoal = {Position = UDim2.new(0.5,-180,-0.8,0)}

local panelOpen = false
local function togglePanel()
	if not panelOpen then
		local t = TweenService:Create(panel, openTweenInfo, openGoal)
		t:Play()
		panelOpen = true
	else
		local t = TweenService:Create(panel, closeTweenInfo, closeGoal)
		t:Play()
		panelOpen = false
	end
end

mainButton.MouseButton1Click:Connect(function()
	togglePanel()
end)
closeBtn.MouseButton1Click:Connect(function()
	togglePanel()
end)

-- Drag: ana buton için (TextButton -> Draggable native)
mainButton.Active = true
mainButton.Draggable = true

-- Drag: panel için (manuel implement)
do
	local dragging = false
	local dragInput, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
			input:GetPropertyChangedSignal("Position"):Connect(function() end)
		end
	end)
	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			local newX = startPos.X.Offset + delta.X
			local newY = startPos.Y.Offset + delta.Y
			panel.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

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

-- Key kontrol (yön)
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

-- Slider etkileşimi (mouse pozisyonu üzerinden)
local draggingSlider = false
sliderBG.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
		-- update once
		local localX = math.clamp(UserInputService:GetMouseLocation().X - sliderBG.AbsolutePosition.X, 0, sliderBG.AbsoluteSize.X)
		local frac = localX / sliderBG.AbsoluteSize.X
		flySpeed = math.max(1, math.floor(frac * 200))
		sliderFill.Size = UDim2.new(frac,0,1,0)
		speedLabel.Text = "Fly Hızı: "..tostring(flySpeed)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local localX = math.clamp(input.Position.X - sliderBG.AbsolutePosition.X, 0, sliderBG.AbsoluteSize.X)
		local frac = localX / sliderBG.AbsoluteSize.X
		flySpeed = math.max(1, math.floor(frac * 200))
		sliderFill.Size = UDim2.new(frac,0,1,0)
		speedLabel.Text = "Fly Hızı: "..tostring(flySpeed)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

-- Eğer oyuncu spawn olursa karakter referansını güncellemek için
player.CharacterAdded:Connect(function()
	wait(0.2)
	-- eğer fly açıksa yeniden başlat
	if flying then
		pcall(stopFly)
		pcall(startFly)
	end
end)
