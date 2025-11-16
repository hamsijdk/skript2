-- LocalScript - StarterPlayerScripts içine koyun
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Ayarlar
local settings = {
    enabled = false,
    aimKey = Enum.KeyCode.F,
    maxDistance = 50,
    smoothness = 0.3,
    autoShoot = false,
    aimAtHead = true,
    selectedTarget = nil -- Seçilen hedef
}

-- Değişkenler
local currentTarget = nil
local isAiming = false
local connection
local playerButtons = {}

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimBotGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🎯 GELİŞMİŞ AIM BOT"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Sekmeler
local tabButtonsFrame = Instance.new("Frame")
tabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
tabButtonsFrame.Position = UDim2.new(0, 0, 0, 30)
tabButtonsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabButtonsFrame.BorderSizePixel = 0
tabButtonsFrame.Parent = mainFrame

local aimTabButton = Instance.new("TextButton")
aimTabButton.Size = UDim2.new(0.5, 0, 1, 0)
aimTabButton.Position = UDim2.new(0, 0, 0, 0)
aimTabButton.Text = "AIM AYARLARI"
aimTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
aimTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
aimTabButton.TextSize = 11
aimTabButton.Font = Enum.Font.Gotham
aimTabButton.Parent = tabButtonsFrame

local playersTabButton = Instance.new("TextButton")
playersTabButton.Size = UDim2.new(0.5, 0, 1, 0)
playersTabButton.Position = UDim2.new(0.5, 0, 0, 0)
playersTabButton.Text = "OYUNCU LİSTESİ"
playersTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playersTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
playersTabButton.TextSize = 11
playersTabButton.Font = Enum.Font.Gotham
playersTabButton.Parent = tabButtonsFrame

-- AIM AYARLARI Sekmesi
local aimTab = Instance.new("Frame")
aimTab.Size = UDim2.new(1, 0, 1, -60)
aimTab.Position = UDim2.new(0, 0, 0, 60)
aimTab.BackgroundTransparency = 1
aimTab.Visible = true
aimTab.Parent = mainFrame

-- OYUNCU LİSTESİ Sekmesi
local playersTab = Instance.new("Frame")
playersTab.Size = UDim2.new(1, 0, 1, -60)
playersTab.Position = UDim2.new(0, 0, 0, 60)
playersTab.BackgroundTransparency = 1
playersTab.Visible = false
playersTab.Parent = mainFrame

-- AIM AYARLARI İçeriği
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
toggleButton.Position = UDim2.new(0.05, 0, 0, 10)
toggleButton.Text = "AIMBOT: KAPALI"
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 12
toggleButton.Font = Enum.Font.Gotham
toggleButton.Parent = aimTab

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0, 55)
statusLabel.Text = "Durum: Pasif"
statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = aimTab

local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(0.9, 0, 0, 25)
targetLabel.Position = UDim2.new(0.05, 0, 0, 85)
targetLabel.Text = "Hedef: OTOMATİK"
targetLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetLabel.TextSize = 11
targetLabel.Font = Enum.Font.Gotham
targetLabel.Parent = aimTab

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(0.9, 0, 0, 25)
distanceLabel.Position = UDim2.new(0.05, 0, 0, 115)
distanceLabel.Text = "Mesafe: -"
distanceLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLabel.TextSize = 11
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.Parent = aimTab

-- Ayarlar butonları
local autoTargetButton = Instance.new("TextButton")
autoTargetButton.Size = UDim2.new(0.9, 0, 0, 30)
autoTargetButton.Position = UDim2.new(0.05, 0, 0, 150)
autoTargetButton.Text = "OTO HEDEF: AÇIK"
autoTargetButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
autoTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoTargetButton.TextSize = 11
autoTargetButton.Font = Enum.Font.Gotham
autoTargetButton.Parent = aimTab

local clearTargetButton = Instance.new("TextButton")
clearTargetButton.Size = UDim2.new(0.9, 0, 0, 30)
clearTargetButton.Position = UDim2.new(0.05, 0, 0, 185)
clearTargetButton.Text = "HEDEFİ TEMİZLE"
clearTargetButton.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
clearTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearTargetButton.TextSize = 11
clearTargetButton.Font = Enum.Font.Gotham
clearTargetButton.Parent = aimTab

-- Kapatma Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.4, 0, 0, 25)
closeButton.Position = UDim2.new(0.55, 0, 1, -35)
closeButton.Text = "Kapat"
closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 11
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = aimTab

-- OYUNCU LİSTESİ İçeriği
local playersScroll = Instance.new("ScrollingFrame")
playersScroll.Size = UDim2.new(0.95, 0, 0.85, 0)
playersScroll.Position = UDim2.new(0.025, 0, 0.05, 0)
playersScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
playersScroll.BorderSizePixel = 0
playersScroll.ScrollBarThickness = 6
playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playersScroll.Parent = playersTab

local noPlayersLabel = Instance.new("TextLabel")
noPlayersLabel.Size = UDim2.new(1, 0, 0, 50)
noPlayersLabel.Position = UDim2.new(0, 0, 0.4, 0)
noPlayersLabel.Text = "Oyuncu bulunamadı..."
noPlayersLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
noPlayersLabel.TextSize = 12
noPlayersLabel.BackgroundTransparency = 1
noPlayersLabel.Parent = playersScroll

-- Oyuncu Listesini Güncelle
local function updatePlayersList()
    playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    -- Eski butonları temizle
    for _, button in pairs(playerButtons) do
        button:Destroy()
    end
    playerButtons = {}
    
    local playerCount = 0
    local yOffset = 5
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            playerCount = playerCount + 1
            
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(0.95, 0, 0, 40)
            playerButton.Position = UDim2.new(0.025, 0, 0, yOffset)
            playerButton.Text = otherPlayer.Name
            playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.TextSize = 11
            playerButton.Font = Enum.Font.Gotham
            playerButton.Parent = playersScroll
            
            -- Seçili hedefi işaretle
            if settings.selectedTarget == otherPlayer then
                playerButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                playerButton.Text = "🎯 " .. otherPlayer.Name
            end
            
            playerButton.MouseButton1Click:Connect(function()
                if settings.selectedTarget == otherPlayer then
                    -- Aynı oyuncuya tıklandı, hedefi kaldır
                    settings.selectedTarget = nil
                    playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    playerButton.Text = otherPlayer.Name
                    targetLabel.Text = "Hedef: OTOMATİK"
                else
                    -- Yeni hedef seç
                    settings.selectedTarget = otherPlayer
                    playerButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                    playerButton.Text = "🎯 " .. otherPlayer.Name
                    targetLabel.Text = "Hedef: " .. otherPlayer.Name
                    
                    -- Diğer butonları sıfırla
                    for _, btn in pairs(playerButtons) do
                        if btn ~= playerButton then
                            local playerName = string.gsub(btn.Text, "🎯 ", "")
                            btn.Text = playerName
                            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                        end
                    end
                end
            end)
            
            table.insert(playerButtons, playerButton)
            yOffset = yOffset + 45
        end
    end
    
    playersScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    if playerCount == 0 then
        noPlayersLabel.Visible = true
    else
        noPlayersLabel.Visible = false
    end
end

-- En Yakın Oyuncuyu Bulma
local function findClosestPlayer()
    if settings.selectedTarget then
        -- Manuel hedef seçilmişse
        local targetPlayer = settings.selectedTarget
        if targetPlayer and targetPlayer.Character then
            local character = targetPlayer.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local head = character:FindFirstChild("Head")
            local localHead = player.Character and player.Character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head and localHead then
                local distance = (localHead.Position - head.Position).Magnitude
                if distance <= settings.maxDistance then
                    return targetPlayer, distance
                end
            end
        end
        return nil, 0
    else
        -- Otomatik hedef bulma
        local closestPlayer = nil
        local closestDistance = settings.maxDistance
        local localCharacter = player.Character
        
        if not localCharacter then return nil, 0 end
        
        local localHead = localCharacter:FindFirstChild("Head")
        if not localHead then return nil, 0 end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local character = otherPlayer.Character
                local humanoid = character:FindFirstChild("Humanoid")
                local head = character:FindFirstChild("Head")
                
                if humanoid and humanoid.Health > 0 and head then
                    local distance = (localHead.Position - head.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
        
        return closestPlayer, closestDistance
    end
end

-- Aim Fonksiyonu
local function aimAtTarget(target)
    if not target or not target.Character then return false end
    
    local targetPart = settings.aimAtHead and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return false end
    
    local camera = workspace.CurrentCamera
    local screenPoint = camera:WorldToScreenPoint(targetPart.Position)
    
    if screenPoint.Z > 0 then
        local targetX, targetY = screenPoint.X, screenPoint.Y
        local currentX, currentY = mouse.X, mouse.Y
        
        local newX = currentX + (targetX - currentX) * settings.smoothness
        local newY = currentY + (targetY - currentY) * settings.smoothness
        
        mousemoverel(newX - currentX, newY - currentY)
        return true
    end
    return false
end

-- Ana Aim Döngüsü
local function startAiming()
    if connection then connection:Disconnect() end
    
    connection = RunService.Heartbeat:Connect(function()
        if not settings.enabled then return end
        
        local target, distance = findClosestPlayer()
        currentTarget = target
        
        if target then
            statusLabel.Text = "Durum: HEDEF KİTLENDİ"
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            distanceLabel.Text = "Mesafe: " .. math.floor(distance) .. "m"
            
            if isAiming then
                local aimSuccess = aimAtTarget(target)
                
                if aimSuccess and settings.autoShoot then
                    mouse1click()
                end
            end
        else
            statusLabel.Text = "Durum: HEDEF ARANIYOR"
            statusLabel.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            distanceLabel.Text = "Mesafe: -"
        end
    end)
end

-- Sekme Değiştirme
aimTabButton.MouseButton1Click:Connect(function()
    aimTab.Visible = true
    playersTab.Visible = false
    aimTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    playersTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

playersTabButton.MouseButton1Click:Connect(function()
    aimTab.Visible = false
    playersTab.Visible = true
    playersTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    aimTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    updatePlayersList()
end)

-- GUI Kontrolleri
toggleButton.MouseButton1Click:Connect(function()
    settings.enabled = not settings.enabled
    
    if settings.enabled then
        toggleButton.Text = "AIMBOT: AÇIK"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        startAiming()
    else
        toggleButton.Text = "AIMBOT: KAPALI"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        statusLabel.Text = "Durum: Pasif"
        statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        distanceLabel.Text = "Mesafe: -"
        if connection then
            connection:Disconnect()
        end
    end
end)

autoTargetButton.MouseButton1Click:Connect(function()
    settings.selectedTarget = nil
    targetLabel.Text = "Hedef: OTOMATİK"
    updatePlayersList()
end)

clearTargetButton.MouseButton1Click:Connect(function()
    settings.selectedTarget = nil
    targetLabel.Text = "Hedef: OTOMATİK"
    updatePlayersList()
end)

closeButton.MouseButton1Click:Connect(function()
    if connection then
        connection:Disconnect()
    end
    screenGui:Destroy()
end)

-- F Tuşu ile Aim Aç/Kapa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == settings.aimKey then
        isAiming = not isAiming
        
        if isAiming then
            statusLabel.Text = "Durum: F TUŞU BASILI"
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        else
            statusLabel.Text = "Durum: HEDEF ARANIYOR"
            statusLabel.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        end
    end
end)

-- Fare Tıklaması ile Aim
mouse.Button1Down:Connect(function()
    if settings.enabled and currentTarget then
        aimAtTarget(currentTarget)
    end
end)

-- Oyuncu değişikliklerini dinle
Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)

-- GUI'yi sürükleme
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- İlk güncelleme
updatePlayersList()
print("Gelişmiş Aim Bot Sistemi Yüklendi! F tuşu ile aim yapabilirsiniz.")
