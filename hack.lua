-- Bu tek script'i ServerScriptService'e sürükle
-- Her şeyi otomatik kuracak!

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- RemoteEvent oluştur
local resetEvent = Instance.new("RemoteEvent")
resetEvent.Name = "ResetServer"
resetEvent.Parent = ReplicatedStorage

-- GUI'yi her oyuncu için otomatik oluştur
local function createGUI(player)
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
        resetEvent:FireServer()
    end)
end

-- Yeni oyuncular için GUI oluştur
Players.PlayerAdded:Connect(createGUI)

-- Zaten oyun içinde olan oyuncular için
for _, player in ipairs(Players:GetPlayers()) do
    createGUI(player)
end

-- Sunucu resetleme
resetEvent.OnServerEvent:Connect(function(player)
    -- Admin ID'lerini buraya yaz (isteğe bağlı)
    local adminIDs = {
        1234567,  -- SENİN ID'Nİ YAZ
        7654321   -- BAŞKA ADMIN
    }
    
    -- Admin kontrolü (istersen bu kısmı silebilirsin)
    local isAdmin = false
    for _, id in ipairs(adminIDs) do
        if player.UserId == id then
            isAdmin = true
            break
        end
    end
    
    -- Eğer admin kontrolü istemiyorsan, aşağıdaki 3 satırı sil
    if not isAdmin then
        player:Kick("Bu işlem için yetkin yok!")
        return
    end
    
    -- Sunucuyu resetle
    for _, plr in ipairs(Players:GetPlayers()) do
        plr:Kick("Sunucu yeniden başlatılıyor...")
    end
    wait(3)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

print("✅ Sunucu Reset Sistemi kuruldu!")
