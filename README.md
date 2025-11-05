--// SROX Fly Script (Geliştirilmiş) //--
-- StarterGui içine LocalScript olarak atılmalı

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local flying = false
local noclip = false
local flySpeed = 50

-- GUI OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SroxGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 120, 0, 40)
MainButton.Position = UDim2.new(0.5, -60, 0.4, -20) -- Ortada olacak
MainButton.Text = "🌀 Srox"
MainButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainButton.TextColor3 = Color3.new(1, 1, 1)
MainButton.BorderSizePixel = 0
MainButton.Font = Enum.Font.SourceSansBold
MainButton.TextSize = 22
MainButton.Active = true
MainButton.Draggable = true
MainButton.Parent = ScreenGui

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 220, 0, 150)
Panel.Position = UDim2.new(0.5, -110, 0.5, -75)
Panel.Visible = false
Panel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Panel.BorderSizePixel = 0
Panel.Parent = ScreenGui

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(1, -20, 0, 30)
FlyButton.Position = UDim2.new(0, 10, 0, 10)
FlyButton.Text = "✈️ Fly: KAPALI"
FlyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FlyButton.TextColor3 = Color3.new(1, 1, 1)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 18
FlyButton.Parent = Panel

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 50)
SpeedBox.PlaceholderText = "Fly Hızı: " .. flySpeed
SpeedBox.Text = ""
SpeedBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.Font = Enum.Font.SourceSansBold
SpeedBox.TextSize = 18
SpeedBox.Parent = Panel

local NoclipButton = Instance.new("TextButton")
NoclipButton.Size = UDim2.new(1, -20, 0, 30)
NoclipButton.Position = UDim2.new(0, 10, 0, 90)
NoclipButton.Text = "🚪 Duvardan Geçme: KAPALI"
NoclipButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
NoclipButton.TextColor3 = Color3.new(1, 1, 1)
NoclipButton.Font = Enum.Font.SourceSansBold
NoclipButton.TextSize = 16
NoclipButton.Parent = Panel

-- Panel Aç/Kapa
MainButton.MouseButton1Click:Connect(function()
	Panel.Visible = not Panel.Visible
end)

-- Fly sistemi
local bodyGyro, bodyVelocity

local function startFly()
	local hrp = character:WaitForChild("HumanoidRootPart")
	bodyGyro = Instance.new("BodyGyro", hrp)
	bodyVelocity = Instance.new("BodyVelocity", hrp)
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	flying = true
	FlyButton.Text = "✈️ Fly: AÇIK"

	while flying do
		task.wait()
		bodyGyro.CFrame = workspace.CurrentCamera.CFrame
		local direction = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			direction = direction + workspace.CurrentCamera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			direction = direction - workspace.CurrentCamera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			direction = direction - workspace.CurrentCamera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			direction = direction + workspace.CurrentCamera.CFrame.RightVector
		end
		bodyVelocity.Velocity = direction * flySpeed
	end
end

local function stopFly()
	flying = false
	FlyButton.Text = "✈️ Fly: KAPALI"
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
end

FlyButton.MouseButton1Click:Connect(function()
	if flying then
		stopFly()
	else
		startFly()
	end
end)

-- Hız ayarlama
SpeedBox.FocusLost:Connect(function()
	local newSpeed = tonumber(SpeedBox.Text)
	if newSpeed and newSpeed > 0 then
		flySpeed = newSpeed
		SpeedBox.PlaceholderText = "Fly Hızı: " .. flySpeed
	end
	SpeedBox.Text = ""
end)

-- DUVAR GEÇME (Noclip) sistemi düzeltildi
RunService.Stepped:Connect(function()
	if noclip and character and character:FindFirstChild("HumanoidRootPart") then
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

NoclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	NoclipButton.Text = noclip and "🚪 Duvardan Geçme: AÇIK" or "🚪 Duvardan Geçme: KAPALI"
	if not noclip then
		-- tekrar açılırsa normal çarpışma geri gelsin
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end)
