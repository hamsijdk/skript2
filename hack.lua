-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Oyuncu değişkenleri
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- AYARLAR
local FOLLOW_DISTANCE = 2.0
local FOLLOW_HEIGHT = 1.5
local RESPONSE_SPEED = 0.02  -- Çok hızlı tepki
local SIDE_OFFSET = 0.5
local JUMP_DELAY = 0.05

-- Titreme ayarları
local TITREME_ENABLED = true
local TITREME_FREQUENCY = 20
local TITREME_AMPLITUDE = 0.15
local TITREME_VERTICAL = 0.1

-- Görüş açısı ayarları
local VIEW_ANGLE = 30  -- Derece cinsinden görüş açısı
local AVOID_VISION = true  -- Hedefin görüşünden kaç

-- GUI Oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmartFollowGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Başlık
local title = Instance.new("TextLabel")
title.Text = "🎯 AKILLI TAKİP SİSTEMİ 🎯"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12, 0, 0)
titleCorner.Parent = title

-- Durum
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "🔴 TAKİP KAPALI"
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- Oyuncu Listesi
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 200)
scrollFrame.Position = UDim2.new(0, 10, 0, 90)
scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

-- Butonlar
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(1, -20, 0, 100)
buttonsFrame.Position = UDim2.new(0, 10, 0, 300)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

local startButton = Instance.new("TextButton")
startButton.Text = "🚀 BAŞLAT"
startButton.Size = UDim2.new(0.48, 0, 0, 40)
startButton.Position = UDim2.new(0, 0, 0, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
startButton.TextColor3 = Color3.white
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 14
startButton.Parent = buttonsFrame

local stopButton = Instance.new("TextButton")
stopButton.Text = "⛔ DURDUR"
stopButton.Size = UDim2.new(0.48, 0, 0, 40)
stopButton.Position = UDim2.new(0.52, 0, 0, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
stopButton.TextColor3 = Color3.white
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Visible = false
stopButton.Parent = buttonsFrame

-- Buton köşeleri
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = startButton
btnCorner:Clone().Parent = stopButton

-- Ayarlar Butonları
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, 0, 0, 40)
settingsFrame.Position = UDim2.new(0, 0, 0, 50)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = buttonsFrame

local shakeToggle = Instance.new("TextButton")
shakeToggle.Text = "🌀 Titreme: AÇIK"
shakeToggle.Size = UDim2.new(0.48, 0, 1, 0)
shakeToggle.Position = UDim2.new(0, 0, 0, 0)
shakeToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
shakeToggle.TextColor3 = Color3.white
shakeToggle.Font = Enum.Font.Gotham
shakeToggle.TextSize = 12
shakeToggle.Parent = settingsFrame

local visionToggle = Instance.new("TextButton")
visionToggle.Text = "👁️ Görüşten Kaç: AÇIK"
visionToggle.Size = UDim2.new(0.48, 0, 1, 0)
visionToggle.Position = UDim2.new(0.52, 0, 0, 0)
visionToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
visionToggle.TextColor3 = Color3.white
visionToggle.Font = Enum.Font.Gotham
visionToggle.TextSize = 12
visionToggle.Parent = settingsFrame

btnCorner:Clone().Parent = shakeToggle
btnCorner:Clone().Parent = visionToggle

-- Değişkenler
local selectedPlayer = nil
local isTracking = false
local trackingConnection = nil
local time = 0
local lastSafePosition = humanoidRootPart.Position

-- Titreme efekti
local function getShakeOffset(t)
    if not TITREME_ENABLED then return Vector3.zero end
    
    local x = math.sin(t * TITREME_FREQUENCY) * TITREME_AMPLITUDE
    local y = math.cos(t * TITREME_FREQUENCY * 1.3) * TITREME_VERTICAL
    local z = math.cos(t * TITREME_FREQUENCY * 0.9) * TITREME_AMPLITUDE
    
    return Vector3.new(x, y, z)
end

-- Hedefin görüş açısını kontrol et
local function isInTargetView(targetRoot, myPosition)
    if not AVOID_VISION or not targetRoot then return false end
    
    local targetPos = targetRoot.Position
    local targetLook = targetRoot.CFrame.LookVector
    
    -- Hedeften bana doğru vektör
    local toMe = (myPosition - targetPos).Unit
    
    -- Açıyı hesapla (dot product)
    local angle = math.deg(math.acos(targetLook:Dot(toMe)))
    
    -- Eğer görüş açısı içindeyse true döndür
    return angle < VIEW_ANGLE
end

-- Güvenli pozisyon bul (görüşten kaç)
local function findSafePosition(targetRoot, basePosition)
    if not targetRoot then return basePosition end
    
    local targetPos = targetRoot.Position
    local targetCF = targetRoot.CFrame
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    -- Eğer görüş açısındaysak, yan tarafa geç
    if isInTargetView(targetRoot, basePosition) then
        -- Sağ veya sol tarafı rastgele seç
        local side = math.random() > 0.5 and 1 or -1
        local sideOffset = rightVector * (SIDE_OFFSET * 2 * side)
        
        return targetPos + (lookVector * -FOLLOW_DISTANCE) + 
               Vector3.new(0, FOLLOW_HEIGHT, 0) + sideOffset
    end
    
    return basePosition
end

-- Gelişmiş takip fonksiyonu
local function smartFollow(targetCharacter, deltaTime)
    if not targetCharacter or not isTracking then return end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not humanoidRootPart then return end
    
    local targetPos = targetRoot.Position
    local targetCF = targetRoot.CFrame
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    -- Temel pozisyon (arkasında)
    local basePosition = targetPos + (lookVector * -FOLLOW_DISTANCE) + 
                         Vector3.new(0, FOLLOW_HEIGHT, 0)
    
    -- Görüşten kaçma aktifse güvenli pozisyon bul
    if AVOID_VISION then
        basePosition = findSafePosition(targetRoot, basePosition)
    else
        -- Normalde yan pozisyon
        basePosition = basePosition + (rightVector * SIDE_OFFSET)
    end
    
    -- Titreme efekti ekle
    time = time + deltaTime
    local shakeOffset = getShakeOffset(time)
    local finalPosition = basePosition + shakeOffset
    
    -- ANINDA TELEPORT (çok yumuşak)
    local currentPos = humanoidRootPart.Position
    local distance = (finalPosition - currentPos).Magnitude
    
    if distance > 10 then
        -- Uzakta ise anında ışınlan
        humanoidRootPart.CFrame = CFrame.new(finalPosition, 
            Vector3.new(targetPos.X, finalPosition.Y, targetPos.Z))
    else
        -- Yakınsa yumuşak hareket
        local lerpAlpha = math.min(deltaTime * 30, 0.95)
        local smoothPos = currentPos:Lerp(finalPosition, lerpAlpha)
        
        humanoidRootPart.CFrame = CFrame.new(smoothPos,
            Vector3.new(targetPos.X, smoothPos.Y, targetPos.Z))
    end
    
    -- Son güvenli pozisyonu kaydet (durdurma için)
    lastSafePosition = finalPosition
    
    -- Zıplama senkronizasyonu
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    if targetHumanoid and humanoid and not humanoid.Jump then
        if targetHumanoid.Jump then
            task.wait(JUMP_DELAY)
            humanoid.Jump = true
        end
    end
end

-- Güvenli durdurma fonksiyonu
local function safeStopTracking()
    if not isTracking then return end
    
    isTracking = false
    statusLabel.Text = "🔴 TAKİP KAPALI"
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    startButton.Visible = true
    stopButton.Visible = false
    
    -- Takip bağlantısını kes
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    -- Karakteri SON GÜVENLİ POZİSYONA al
    -- BU KISIM ÇOK ÖNEMLİ: Sana girmesin diye
    if humanoidRootPart and humanoid then
        -- Önce karakteri durdur
        humanoid:MoveTo(lastSafePosition)
        
        -- 0.5 saniye bekle ve emin ol
        task.wait(0.5)
        
        -- Sonra güvenli pozisyona ışınla
        humanoidRootPart.CFrame = CFrame.new(lastSafePosition, 
            lastSafePosition + humanoidRootPart.CFrame.LookVector)
    end
    
    print("⛔ Takip GÜVENLİ bir şekilde durduruldu")
end

-- Takip başlat
local function startTracking()
    if not selectedPlayer then 
        statusLabel.Text = "⚠️ OYUNCU SEÇİLMEDİ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        task.wait(2)
        statusLabel.Text = "🔴 TAKİP KAPALI"
        return 
    end
    
    isTracking = true
    statusLabel.Text = "✅ TAKİP: " .. selectedPlayer.Name
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    startButton.Visible = false
    stopButton.Visible = true
    
    -- Başlangıç pozisyonunu kaydet
    lastSafePosition = humanoidRootPart.Position
    
    -- Takip bağlantısı
    trackingConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if isTracking and selectedPlayer then
            local targetChar = selectedPlayer.Character
            if targetChar then
                smartFollow(targetChar, deltaTime)
            end
        end
    end)
    
    print("✅ Takip başlatıldı: " .. selectedPlayer.Name)
end

-- Oyuncu listesini güncelle
local function updatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local btn = Instance.new("TextButton")
            btn.Text = "👤 " .. otherPlayer.Name
            btn.Size = UDim2.new(1, -10, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
            btn.TextColor3 = Color3.fromRGB(220, 220, 240)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.Parent = scrollFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                -- Tüm butonları sıfırla
                for _, b in ipairs(scrollFrame:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
                    end
                end
                
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
                selectedPlayer = otherPlayer
                statusLabel.Text = "🎯 SEÇİLDİ: " .. otherPlayer.Name
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            end)
        end
    end
end

-- Buton eventleri
startButton.MouseButton1Click:Connect(startTracking)
stopButton.MouseButton1Click:Connect(safeStopTracking)

shakeToggle.MouseButton1Click:Connect(function()
    TITREME_ENABLED = not TITREME_ENABLED
    shakeToggle.Text = TITREME_ENABLED and "🌀 Titreme: AÇIK" or "🌀 Titreme: KAPALI"
    shakeToggle.BackgroundColor3 = TITREME_ENABLED and 
        Color3.fromRGB(100, 100, 200) or Color3.fromRGB(80, 80, 80)
end)

visionToggle.MouseButton1Click:Connect(function()
    AVOID_VISION = not AVOID_VISION
    visionToggle.Text = AVOID_VISION and "👁️ Görüşten Kaç: AÇIK" or "👁️ Görüşten Kaç: KAPALI"
    visionToggle.BackgroundColor3 = AVOID_VISION and 
        Color3.fromRGB(100, 200, 100) or Color3.fromRGB(80, 80, 80)
end)

-- Klavye kontrolleri
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        if selectedPlayer then
            if isTracking then
                safeStopTracking()
            else
                startTracking()
            end
        end
        
    elseif input.KeyCode == Enum.KeyCode.R then
        -- En yakın oyuncuyu seç
        local closest = nil
        local minDist = math.huge
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (humanoidRootPart.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = p
                    end
                end
            end
        end
        
        if closest then
            selectedPlayer = closest
            statusLabel.Text = "🎯 OTOMATİK SEÇİLDİ: " .. closest.Name
            startTracking()
        end
        
    elseif input.KeyCode == Enum.KeyCode.T then
        -- Titreme şiddetini değiştir
        TITREME_AMPLITUDE = TITREME_AMPLITUDE == 0.15 and 0.3 or 0.15
        TITREME_VERTICAL = TITREME_VERTICAL == 0.1 and 0.2 or 0.1
        print("🎯 Titreme şiddeti: " .. TITREME_AMPLITUDE)
        
    elseif input.KeyCode == Enum.KeyCode.Y then
        -- Görüş açısını değiştir
        VIEW_ANGLE = VIEW_ANGLE == 30 and 60 or 30
        print("👁️ Görüş açısı: " .. VIEW_ANGLE .. "°")
    end
end)

-- Başlangıçta oyuncu listesini güncelle
task.wait(1)
updatePlayerList()

-- Oyuncu değişikliklerini dinle
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if selectedPlayer == leavingPlayer then
        safeStopTracking()
        selectedPlayer = nil
    end
    updatePlayerList()
end)

-- Karakter değişiklikleri
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    
    if isTracking and selectedPlayer then
        task.wait(1)
        startTracking()
    end
end)

print("==========================================")
print("🎯 AKILLI TAKİP SİSTEMİ YÜKLENDİ!")
print("==========================================")
print("✅ ÖZELLİKLER:")
print("   • Güvenli durdurma (sana girmez)")
print("   • Titreme efekti (T tuşu ile aç/kapat)")
print("   • Görüşten kaçma (Y tuşu ile ayarla)")
print("   • Yumuşak takip")
print("==========================================")
print("🎮 KONTROLLER:")
print("   • F - Takip başlat/durdur")
print("   • R - En yakın oyuncuyu seç")
print("   • T - Titreme şiddetini değiştir")
print("   • Y - Görüş açısını değiştir (30°/60°)")
print("==========================================")
print("📱 KULLANIM:")
print("   1. Oyuncu seç")
print("   2. BAŞLAT butonuna bas")
print("   3. DURDUR dediğinde sana gelmez")
print("   4. Titreme ile doğal görünür")
print("==========================================")
