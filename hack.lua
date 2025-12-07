--== SETTINGS ==--
local FOLLOW_DISTANCE = 4
local FOLLOW_SPEED = 1.5
local GUI_TOGGLE_KEY = Enum.KeyCode.F


--== SERVICES ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local currentTarget = nil
local isFollowing = false


--== GUI CREATE ==--
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 25, 0, 25)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

-- TOGGLE BUTTON
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -35, 0, 5)
toggleButton.Text = "X"
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- LABEL
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 30)
label.Text = "OYUNCU SEC"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
label.Parent = frame

-- SCROLL LIST
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -70)
scroll.Position = UDim2.new(0, 0, 0, 35)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = frame

local UIList = Instance.new("UIListLayout")
UIList.Parent = scroll


--== UPDATE PLAYER LIST ==--
local function refreshList()
	-- cleanup
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 32)
			btn.Text = plr.Name
			btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
			btn.TextColor3 = Color3.fromRGB(255,255,255)
			btn.Parent = scroll

			btn.MouseButton1Click:Connect(function()
				currentTarget = plr
				for _, b in ipairs(scroll:GetChildren()) do
					if b:IsA("TextButton") then
						b.BackgroundColor3 = Color3.fromRGB(70,70,70)
					end
				end
				btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
			end)
		end
	end
end

refreshList()

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(function(plr)
	if currentTarget == plr then
		currentTarget = nil
		isFollowing = false
	end
	refreshList()
end)


--== FOLLOW ==--
local function followStep()
	if not isFollowing or not currentTarget then return end

	local targetChar = currentTarget.Character
	if not targetChar then return end

	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	-- desired pos behind target
	local behind = targetRoot.CFrame.LookVector * -FOLLOW_DISTANCE
	local desiredPos = targetRoot.Position + behind

	-- smooth move
	local newPos = root.Position:Lerp(desiredPos, FOLLOW_SPEED * RunService.Heartbeat:Wait())
	root.CFrame = CFrame.new(newPos, Vector3.new(targetRoot.Position.X, newPos.Y, targetRoot.Position.Z))
end

RunService.Heartbeat:Connect(followStep)


--== START/STOP BUTTON ==--
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0, 145, 0, 30)
startBtn.Position = UDim2.new(0, 5, 1, -35)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
startBtn.Text = "BASLAT"
startBtn.Parent = frame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 145, 0, 30)
stopBtn.Position = UDim2.new(1, -150, 1, -35)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
stopBtn.Text = "DURDUR"
stopBtn.Parent = frame

startBtn.MouseButton1Click:Connect(function()
	if currentTarget then
		isFollowing = true
	end
end)

stopBtn.MouseButton1Click:Connect(function()
	isFollowing = false
end)


--== RESPAWN KEEP ==--
LocalPlayer.CharacterAdded:Connect(function(newChar)
	character = newChar
	root = newChar:WaitForChild("HumanoidRootPart")
end)

Players.PlayerAdded:Connect(refreshList)


--== F KEY TOGGLE GUI ==--
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == GUI_TOGGLE_KEY then
		frame.Visible = not frame.Visible
	end
end)
