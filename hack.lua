-- Srox Fly + Noclip GUI Script
-- LocalScript olarak çalıştır

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local flying = false
local noclip = false
local flySpeed = 50
local control = {F=0, B=0, L=0, R=0}

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 150)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)

-- Fly Butonu
local flyButton = Instance.new("TextButton", mainFrame)
flyButton.Size = UDim2.new(0, 220, 0, 40)
flyButton.Position = UDim2.new(0,15,0,10)
flyButton.Text = "Fly: Kapalı"
flyButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
flyButton.TextColor3 = Color3.new(1,1,1)
flyButton.BorderSizePixel = 0

-- Noclip Butonu
local noclipButton = Instance.new("TextButton", mainFrame)
noclipButton.Size = UDim2.new(0, 220, 0, 40)
noclipButton.Position = UDim2.new(0,15,0,60)
noclipButton.Text = "Duvardan Geçme: Kapalı"
noclipButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
noclipButton.TextColor3 = Color3.new(1,1,1)
noclipButton.BorderSizePixel = 0

-- Hız Slider
local speedLabel = Instance.new("TextLabel", mainFrame)
speedLabel.Size = UDim2.new(0, 220, 0, 20)
speedLabel.Position = UDim2.new(0,15,0,110)
speedLabel.Text = "Fly Hızı: 50"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.SourceSans

local speedSlider = Instance.new("TextButton", mainFrame)
speedSlider.Size = UDim2.new(0, 220, 0, 20)
speedSlider.Position = UDim2.new(0,15,0,130)
speedSlider.BackgroundColor3 = Color3.fromRGB(70,70,70)
speedSlider.Text = "Kaydırarak Ayarla"

-- Fly fonksiyonları
local bodyGyro
local bodyVelocity

local function startFly()
	if flying then return end
	flying = true
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local root = character.HumanoidRootPart

	bodyGyro = Instance.new("BodyGyro", root)
	bodyVelocity = Instance.new("BodyVelocity", root)
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bodyGyro.CFrame = root.CFrame
	bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)

	RunService:BindToRenderStep("FlyStep",200,function()
		if not flying then return end
		local cam = workspace.CurrentCamera
		bodyGyro.CFrame = cam.CFrame
		bodyVelocity.Velocity = ((cam.CFrame.LookVector*(control.F+control.B)) + (cam.CFrame.RightVector*(control.R+control.L)))*flySpeed
	end)
end

local function stopFly()
	flying = false
	RunService:UnbindFromRenderStep("FlyStep")
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
end

-- Noclip fonksiyonu
RunService.Stepped:Connect(function()
	if noclip and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Key kontrol
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.W then control.F = 1 end
	if input.KeyCode == Enum.KeyCode.S then control.B = -1 end
	if input.KeyCode == Enum.KeyCode.A then control.L = -1 end
	if input.KeyCode == Enum.KeyCode.D then control.R = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then control.F = 0 end
	if input.KeyCode == Enum.KeyCode.S then control.B = 0 end
	if input.KeyCode == Enum.KeyCode.A then control.L = 0 end
	if input.KeyCode == Enum.KeyCode.D then control.R = 0 end
end)

-- Buton tıklamaları
flyButton.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
		flyButton.Text = "Fly: Kapalı"
	else
		startFly()
		flyButton.Text = "Fly: Açık"
	end
end)

noclipButton.MouseButton1Click:Connect(function()
	if noclip then
		noclip = false
		noclipButton.Text = "Duvardan Geçme: Kapalı"
	else
		noclip = true
		noclipButton.Text = "Duvardan Geçme: Açık"
	end
end)

-- Hız slider
local dragging = false
speedSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

speedSlider.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

speedSlider.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = UserInputService:GetMouseLocation()
		local relativeX = math.clamp(mousePos.X - speedSlider.AbsolutePosition.X, 0, speedSlider.AbsoluteSize.X)
		flySpeed = math.floor((relativeX / speedSlider.AbsoluteSize.X) * 200)
		speedLabel.Text = "Fly Hızı: "..flySpeed
	end
end)
