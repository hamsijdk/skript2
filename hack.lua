-- LocalScript'i StarterGui'ye koy
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI'yi oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SunucuGUI"
screenGui.Parent = playerGui

-- Ana frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "SUNUCU KONTROL"
title.TextScaled = true
title.Parent = mainFrame

-- Buton
local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0, 200, 0, 60)
resetButton.Position = UDim2.new(0.5, -100, 0.5, -30)
resetButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Text = "SUNUCUYU KAPAT"
resetButton.TextScaled = true
resetButton.Parent = mainFrame

-- Buton tıklama olayı
resetButton.MouseButton1Click:Connect(function()
    -- Sunucu kapatma isteğini server'a gönder
    game:GetService("ReplicatedStorage"):WaitForChild("ResetServer"):FireServer()
end)


-- Bu script'i ServerScriptService'e koy
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- RemoteEvent oluştur
local resetEvent = Instance.new("RemoteEvent")
resetEvent.Name = "ResetServer"
resetEvent.Parent = ReplicatedStorage

-- Sunucuyu resetleme fonksiyonu
resetEvent.OnServerEvent:Connect(function(player)
    -- Sadece admin/owner kontrolü eklemek istersen burayı düzenleyebilirsin
    -- Örnek: if player.UserId == 1234567 then
    
    -- Tüm oyunculara mesaj göster
    for _, plr in ipairs(Players:GetPlayers()) do
        plr:Kick("Sunucu yeniden başlatılıyor...")
    end
    
    -- 3 saniye bekle ve oyunu resetle
    wait(3)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
    
    -- end (admin kontrolünün sonu)
end)
