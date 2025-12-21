--// CEM PRO HORROR SYSTEM //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- MAVİ EKRAN
local blueFrame = Instance.new("Frame", gui)
blueFrame.Size = UDim2.new(1,0,1,0)
blueFrame.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
blueFrame.BackgroundTransparency = 0

-- FOTOĞRAF
local image = Instance.new("ImageLabel", blueFrame)
image.Size = UDim2.new(1,0,1,0)
image.BackgroundTransparency = 1
image.ImageTransparency = 0.1
image.Image = "rbxassetid://IMAGE_ID_BURAYA" -- FOTO ID
image.ScaleType = Enum.ScaleType.Stretch

-- GLITCH YAZI
local text = Instance.new("TextLabel", gui)
text.Size = UDim2.new(1,0,0.2,0)
text.Position = UDim2.new(0,0,0.75,0)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.new(1,1,1)
text.TextScaled = true
text.Font = Enum.Font.Arcade
text.Text = ""

local messages = {
	"KONTROL KAYBEDİLDİ",
	"SİSTEME ERİŞİLİYOR",
	"W ALGILANDI",
	"SPACE OVERRIDE",
	"EFE SENİ İZLİYOR",
	"KAÇMAYA ÇALIŞMA"
}

-- AŞIRI KAMERA TİTREME
local running = true
local originalCFrame = cam.CFrame

spawn(function()
	while running do
		cam.CFrame = originalCFrame *
			CFrame.new(
				math.random(-3,3)/10,
				math.random(-3,3)/10,
				math.random(-3,3)/10
			) *
			CFrame.Angles(
				math.rad(math.random(-8,8)),
				math.rad(math.random(-8,8)),
				math.rad(math.random(-5,5))
			)
		RunService.RenderStepped:Wait()
	end
end)

-- YAZI + GLITCH
spawn(function()
	while running do
		text.Text = messages[math.random(#messages)]
		text.Rotation = math.random(-5,5)
		text.Position = UDim2.new(
			math.random(-2,2)/100,
			0,
			0.75 + math.random(-2,2)/100,
			0
		)
		wait(math.random(0.3,0.8))
	end
end)

-- FOTOĞRAF GLITCH
spawn(function()
	while running do
		image.ImageColor3 = Color3.fromRGB(
			math.random(0,50),
			math.random(100,255),
			255
		)
		image.Rotation = math.random(-2,2)
		wait(0.05)
	end
end)

-- 5 DAKİKA
task.delay(300, function()
	running = false
	cam.CFrame = originalCFrame
	gui:Destroy()
end)
