-- [ FULL OTOMATİK KEY PANEL SİSTEMİ ] 
-- tek bir LocalScript ile GUI'yi ve sistemi tamamen kurar.

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- GÜNLÜK KEY HESAPLAMA
---------------------------------------------------------
local BASE_KEY = 1173563

local function GetDailyKey()
    local now = DateTime.now():ToLocalTime()
    local y, m, d = now.Year, now.Month, now.Day
    local offset = (y * 365 + m * 31 + d) % 1000000
    return tostring(BASE_KEY + offset)
end

local DAILY_KEY = GetDailyKey()

---------------------------------------------------------
-- GUI OLUŞTURMA
---------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "KeySystem"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 180)
frame.Position = UDim2.new(0.5, -175, 0.35, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Key Panel"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 28)
info.Position = UDim2.new(0, 10, 0, 40)
info.BackgroundTransparency = 1
info.Text = "F ile aç/kapa"
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = frame

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -20, 0, 28)
keyLabel.Position = UDim2.new(0, 10, 0, 70)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Bugünün Key'i: "..DAILY_KEY
keyLabel.TextColor3 = Color3.fromRGB(255,220,80)
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -140, 0, 32)
input.Position = UDim2.new(0, 10, 0, 105)
input.PlaceholderText = "Key gir..."
input.BackgroundColor3 = Color3.fromRGB(255,255,255)
input.Text = ""
input.Parent = frame

local giris = Instance.new("TextButton")
giris.Size = UDim2.new(0, 60, 0, 32)
giris.Position = UDim2.new(1, -70, 0, 105)
giris.Text = "Giriş"
giris.Parent = frame

local keyal = Instance.new("TextButton")
keyal.Size = UDim2.new(0, 60, 0, 32)
keyal.Position = UDim2.new(1, -140, 0, 105)
keyal.Text = "Key Al"
keyal.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 28)
status.Position = UDim2.new(0, 10, 0, 140)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(180,180,180)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame


---------------------------------------------------------
-- F tuşu ile aç/kapa
---------------------------------------------------------
local visible = false
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.F then
        visible = not visible
        frame.Visible = visible
    end
end)

---------------------------------------------------------
-- Giriş butonu
---------------------------------------------------------
giris.MouseButton1Click:Connect(function()
    local entered = input.Text
    if entered == "" then
        status.Text = "Key gir!"
        return
    end

    if tostring(entered) == DAILY_KEY then
        status.Text = "Giriş Başarılı!"
    else
        status.Text = "Yanlış Key!"
    end
end)

---------------------------------------------------------
-- Key Al butonu (şimdilik boş)
---------------------------------------------------------
keyal.MouseButton1Click:Connect(function()
    status.Text = "Key Al şu an çalışmıyor."
end)

---------------------------------------------------------
-- Eğer oyuncu adın efeakincipo ise sana otomatik key mesajı
---------------------------------------------------------
if player.Name:lower() == "efeakincipo" then
    status.Text = "Senin Günlük Key'in: "..DAILY_KEY
end
