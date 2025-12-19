--==============================
-- SERVICES
--==============================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

--==============================
-- STATE / AYARLAR
--==============================
local guiOpen = true
local follow = false
local autoclick = false

local followTarget = nil
local followTargetName = nil -- respawn için

local followDistance = 5
local followHeight = 0
local sideOffset = 0

local MIN_VAL = -100
local MAX_VAL = 100

local SMOOTH = 0.15 -- 0.1 çok yumuşak | 0.3 daha hızlı

--==============================
-- GUI
--==============================
local gui = Instance.new("ScreenGui")
gui.Name = "FollowFullGui"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(320, 420)
frame.Position = UDim2.fromScale(0.05, 0.25)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local function button(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.fromOffset(300, 34)
	b.Position = UDim2.fromOffset(10, y)
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.Text = text
	return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(300, 30)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "FOLLOW + AUTOCLICKER (SMOOTH)"
title.TextColor3 = Color3.fromRGB(0,170,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local followBtn = button("Follow: OFF", 45)
local acBtn = button("AutoClicker (F): OFF", 85)

local distMinus = button("Mesafe -5", 130)
local distPlus  = button("Mesafe +5", 165)

local hMinus = button("Yükseklik -5", 205)
local hPlus  = button("Yükseklik +5", 240)

local sideMinus = button("Sol -5", 280)
local sidePlus  = button("Sağ +5", 315)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.fromOffset(300, 70)
info.Position = UDim2.fromOffset(10, 350)
info.BackgroundTransparency = 1
info.TextWrapped = true
info.TextColor3 = Color3.new(1,1,1)
info.Font = Enum.Font.SourceSans
info.TextSize = 14

local function updateInfo()
	info.Text =
		"Mesafe: "..followDistance..
		"\nYükseklik: "..followHeight..
		"\nSağ / Sol: "..sideOffset
end
updateInfo()

--==============================
-- TARGET SEÇME (SOL TIK)
--==============================
mouse.Button1Down:Connect(function()
	if mouse.Target then
		local model = mouse.Target:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("HumanoidRootPart") then
			followTarget = model
			followTargetName = model.Name
		end
	end
end)

--==============================
-- BUTONLAR
--==============================
followBtn.MouseButton1Click:Connect(function()
	follow = not follow
	followBtn.Text = follow and "Follow: ON" or "Follow: OFF"
end)

acBtn.MouseButton1Click:Connect(function()
	autoclick = not autoclick
	acBtn.Text = autoclick and "AutoClicker (F): ON" or "AutoClicker (F): OFF"
end)

distMinus.MouseButton1Click:Connect(function()
	followDistance = math.clamp(followDistance - 5, MIN_VAL, MAX_VAL)
	updateInfo()
end)

distPlus.MouseButton1Click:Connect(function()
	followDistance = math.clamp(followDistance + 5, MIN_VAL, MAX_VAL)
	updateInfo()
end)

hMinus.MouseButton1Click:Connect(function()
	followHeight = math.clamp(followHeight - 5, MIN_VAL, MAX_VAL)
	updateInfo()
end)

hPlus.MouseButton1Click:Connect(function()
	followHeight = math.clamp(followHeight + 5, MIN_VAL, MAX_VAL)
	updateInfo()
end)

sideMinus.MouseButton1Click:Connect(function()
	sideOffset = math.clamp(sideOffset - 5, MIN_VAL, MAX_VAL)
	updateInfo()
end)

sidePlus.MouseButton1Click:Connect(function()
	sideOffset = math.clamp(sideOffset + 5, MIN_VAL, MAX_VAL)
	updateInfo()
end)

--==============================
-- TUŞLAR
--==============================
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end

	if i.KeyCode == Enum.KeyCode.G then
		guiOpen = not guiOpen
		gui.Enabled = guiOpen
	end

	if i.KeyCode == Enum.KeyCode.F then
		autoclick = not autoclick
		acBtn.Text = autoclick and "AutoClicker (F): ON" or "AutoClicker (F): OFF"
	end
end)

--==============================
-- AUTOCLICKER
--==============================
task.spawn(function()
	while true do
		if autoclick then
			VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.01)
			VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
		end
		task.wait()
	end
end)

--==============================
-- TARGET RESPAWN BULUCU
--==============================
local function findTargetAgain()
	if not followTargetName then return end
	for _,m in ipairs(workspace:GetChildren()) do
		if m:IsA("Model") and m.Name == followTargetName and m:FindFirstChild("HumanoidRootPart") then
			followTarget = m
			return
		end
	end
end

--==============================
-- FOLLOW LOOP (SMOOTH + DÜZ)
--==============================
RunService.RenderStepped:Connect(function()
	if not follow then return end

	if not followTarget or not followTarget:FindFirstChild("HumanoidRootPart") then
		findTargetAgain()
		return
	end

	local char = lp.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local tHRP = followTarget.HumanoidRootPart

	local back = tHRP.CFrame.LookVector * followDistance
	local right = tHRP.CFrame.RightVector * sideOffset
	local height = Vector3.new(0, followHeight, 0)

	local goalPos = tHRP.Position + back + right + height

	local newPos = hrp.Position:Lerp(goalPos, SMOOTH)

	-- 🔒 ROTASYON YOK
	hrp.CFrame = CFrame.new(newPos)
end)

print("FULL FOLLOW + RESPAWN + SMOOTH AKTİF")
