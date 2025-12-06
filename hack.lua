-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Oyuncu değişkenleri
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Ayarlar
local FOLLOW_DISTANCE = 1.5  -- Çok yakın (1.5m)
local FOLLOW_HEIGHT = 1      -- Minimum yükseklik
local SMOOTHNESS = 0.25      -- Daha sert takip (titremeyi önlemek için)
local SIDE_OFFSET = 0.3      -- Yan pozisyon (görüş için)
local JUMP_DELAY = 0.1       -- Zıplama gecikmesi
local RESPONSE_TIME = 0.05   -- Tepki süresi (saniye)

-- Titreme için ayarlar
local TITREME_FREQUENCY = 20 -- Titreme frekansı (Hz)
local TITREME_AMPLITUDE = 0.1 -- Titreme genliği
local TITREME_OFFSET = Vector3.new(0, 0.1, 0) -- Titreme offset

-- GUI'yi oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Başlık
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "🎯 YAKIN TAKİP SİSTEMİ 🎯"
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Oyuncu listesi
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -15, 0, 160)
scrollFrame.Position = UDim2.new(0, 8, 0, 45)
scrollFrame.BackgroundTransparency = 0.9
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.Padding = UDim.new(0, 3)

-- Kontrol Paneli
local controlFrame = Instance.new("Frame")
controlFrame.Name = "ControlFrame"
controlFrame.Size = UDim2.new(1, -15, 0, 150)
controlFrame.Position = UDim2.new(0, 8, 0, 215)
controlFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
controlFrame.Parent = mainFrame

local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0, 6)
controlCorner.Parent = controlFrame

-- Takip Durumu
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = "🔴 TAKİP KAPALI"
statusLabel.Size = UDim2.new(1, -10, 0, 25)
statusLabel.Position = UDim2.new(0, 5, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.Parent = controlFrame

-- Mesafe Ayarı
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Name = "DistanceLabel"
distanceLabel.Text = "📏 MESAFE: 1.5m"
distanceLabel.Size = UDim2.new(0.6, 0, 0, 20)
distanceLabel.Position = UDim2.new(0, 5, 0, 35)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.TextSize = 11
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = controlFrame

-- Titreme Ayarı
local shakeLabel = Instance.new("TextLabel")
shakeLabel.Name = "ShakeLabel"
shakeLabel.Text = "🌀 TİTREME: 0.1"
shakeLabel.Size = UDim2.new(0.6, 0, 0, 20)
shakeLabel.Position = UDim2.new(0, 5, 0, 60)
shakeLabel.BackgroundTransparency = 1
shakeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
shakeLabel.Font = Enum.Font.Gotham
shakeLabel.TextSize = 11
shakeLabel.TextXAlignment = Enum.TextXAlignment.Left
shakeLabel.Parent = controlFrame

-- Butonlar
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -10, 0, 40)
buttonsFrame.Position = UDim2.new(0, 5, 0, 90)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = controlFrame

local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Text = "🚀 BAŞLAT"
startButton.Size = UDim2.new(0.48, 0, 1, 0)
startButton.Position = UDim2.new(0, 0, 0, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 12
startButton.Parent = buttonsFrame

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Text = "⛔ DURDUR"
stopButton.Size = UDim2.new(0.48, 0, 1, 0)
stopButton.Position = UDim2.new(0.52, 0, 0, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 12
stopButton.Visible = false
stopButton.Parent = buttonsFrame

-- Buton köşeleri
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = startButton
buttonCorner:Clone().Parent = stopButton

-- Kapatma butonu
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 22, 0, 22)
closeButton.Position = UDim2.new(1, -27, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Değişkenler
local selectedPlayer = nil
local isTracking = false
local trackingConnection = nil
local currentDistance = FOLLOW_DISTANCE
local currentShake = TITREME_AMPLITUDE
local isTeleporting = false
local time = 0
local lastPosition = nil
local velocity = Vector3.zero

-- Titreme efekti fonksiyonu
local function getShakeOffset(t)
    local x = math.sin(t * TITREME_FREQUENCY) * currentShake
    local y = math.cos(t * TITREME_FREQUENCY * 1.1) * currentShake
    local z = math.sin(t * TITREME_FREQUENCY * 0.9) * currentShake
    return Vector3.new(x, y, z) + TITREME_OFFSET
end

-- Hedefin hızını ve hareket yönünü analiz et
local function analyzeTargetMovement(targetRoot, deltaTime)
    if not targetRoot then return Vector3.zero end
    
    local currentPos = targetRoot.Position
    
    if lastPosition then
        -- Hızı hesapla
        velocity = (currentPos - lastPosition) / deltaTime
        
        -- Çok yüksek hızları sınırla
        local speed = velocity.Magnitude
        if speed > 50 then
            velocity = velocity.Unit * 50
        end
    end
    
    lastPosition = currentPos
    return velocity
end

-- Tepki süresi ile tahmin edilen pozisyon
local function getPredictedPosition(targetRoot, deltaTime)
    if not targetRoot then return nil end
    
    local currentPos = targetRoot.Position
    local vel = analyzeTargetMovement(targetRoot, deltaTime)
    
    -- Tepki süresi ile tahmin yap
    return currentPos + (vel * RESPONSE_TIME)
end

-- Saniyede işlem yapan hızlı takip
local function rapidFollow(targetCharacter, deltaTime)
    if not targetCharacter or not isTracking then return end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not humanoidRootPart then return end
    
    -- Hedefin hareketini tahmin et
    local predictedTargetPos = getPredictedPosition(targetRoot, deltaTime) or targetRoot.Position
    
    -- Hedefin yön vektörleri
    local targetCF = targetRoot.CFrame
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    -- Hedefin arkasında pozisyon
    local behindOffset = lookVector * -currentDistance
    local sideOffset = rightVector * SIDE_OFFSET
    local heightOffset = Vector3.new(0, FOLLOW_HEIGHT, 0)
    
    -- Temel pozisyon
    local basePosition = predictedTargetPos + behindOffset + heightOffset + sideOffset
    
    -- Titreme efekti ekle
    time = time + deltaTime
    local shakeOffset = getShakeOffset(time)
    local finalPosition = basePosition + shakeOffset
    
    -- Anında ışınlanma (teleport)
    if isTeleporting then
        humanoidRootPart.CFrame = CFrame.new(finalPosition, Vector3.new(predictedTargetPos.X, finalPosition.Y, predictedTargetPos.Z))
        return
    end
    
    -- Yumuşak geçiş
    local currentPos = humanoidRootPart.Position
    local distanceToTarget = (finalPosition - currentPos).Magnitude
    
    -- Hızlı takip için agresif hareket
    if distanceToTarget > 0.05 then
        local alpha = math.min(SMOOTHNESS * 3 * deltaTime * 60, 0.8)
        local smoothPosition = currentPos:Lerp(finalPosition, alpha)
        
        -- Hedefe bak
        local lookAtCF = CFrame.new(smoothPosition, Vector3.new(predictedTargetPos.X, smoothPosition.Y, predictedTargetPos.Z))
        
        -- Işınlan
        humanoidRootPart.CFrame = lookAtCF
    end
    
    -- Hedef zıplıyorsa zıpla
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    local myHumanoid = character:FindFirstChild("Humanoid")
    
    if targetHumanoid and myHumanoid and not isTeleporting then
        if targetHumanoid.Jump and not myHumanoid.Jump then
            task.wait(JUMP_DELAY)
            myHumanoid.Jump = true
        end
    end
end

-- Takip sistemini BAŞLAT
local function startTracking()
    if not selectedPlayer then 
        statusLabel.Text = "⚠️ OYUNCU SEÇİLMEDİ"
        task.wait(1)
        statusLabel.Text = "🔴 TAKİP KAPALI"
        return 
    end
    
    -- Önceki takibi durdur
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    isTracking = true
    statusLabel.Text = "✅ TAKİP AÇIK: " .. selectedPlayer.Name
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    startButton.Visible = false
    stopButton.Visible = true
    
    -- İlk ışınlanma
    isTeleporting = true
    local targetCharacter = selectedPlayer.Character
    if targetCharacter then
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if targetRoot and humanoidRootPart then
            -- Arkasında başla
            local lookVector = targetRoot.CFrame.LookVector
            local behindOffset = lookVector * -currentDistance
            local heightOffset = Vector3.new(0, FOLLOW_HEIGHT, 0)
            local sideOffset = targetRoot.CFrame.RightVector * SIDE_OFFSET
            local startPosition = targetRoot.Position + behindOffset + heightOffset + sideOffset
            
            -- Titreme ekle
            local shakeOffset = getShakeOffset(time)
            startPosition = startPosition + shakeOffset
            
            humanoidRootPart.CFrame = CFrame.new(startPosition, targetRoot.Position)
        end
    end
    isTeleporting = false
    
    -- Hızlı takip bağlantısı
    trackingConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if isTracking and selectedPlayer then
            local targetCharacter = selectedPlayer.Character
            if targetCharacter then
                rapidFollow(targetCharacter, deltaTime)
            end
        end
    end)
    
    print("✅ Takip başlatıldı: " .. selectedPlayer.Name)
end

-- Takip sistemini DURDUR
local function stopTracking()
    isTracking = false
    statusLabel.Text = "🔴 TAKİP KAPALI"
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    startButton.Visible = true
    stopButton.Visible = false
    lastPosition = nil
    velocity = Vector3.zero
    
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(humanoidRootPart.Position)
    end
end

-- Mesafe değiştirme
local function changeDistance(amount)
    currentDistance = math.clamp(currentDistance + amount, 0.1, 5)
    distanceLabel.Text = "📏 MESAFE: " .. string.format("%.1f", currentDistance) .. "m"
end

-- Titreme değiştirme
local function changeShake(amount)
    currentShake = math.clamp(currentShake + amount, 0, 0.5)
    shakeLabel.Text = "🌀 TİTREME: " .. string.format("%.2f", currentShake)
end

-- Oyuncu listesini güncelle
local function updatePlayerList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local playerCount = 0
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            playerCount = playerCount + 1
            
            local playerButton = Instance.new("TextButton")
            playerButton.Name = otherPlayer.Name
            playerButton.Text = "👤 " .. otherPlayer.Name
            playerButton.Size = UDim2.new(1, -5, 0, 28)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            playerButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextSize = 11
            playerButton.AutoButtonColor = true
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = playerButton
            
            playerButton.MouseButton1Click:Connect(function()
                for _, btn in ipairs(scrollFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    end
                end
                
                playerButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
                selectedPlayer = otherPlayer
                statusLabel.Text = "🎯 SEÇİLDİ: " .. otherPlayer.Name
                statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                
                if isTracking then
                    startTracking()
                end
            end)
            
            playerButton.Parent = scrollFrame
        end
    end
    
    if playerCount == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Name = "EmptyLabel"
        emptyLabel.Text = "🌙 Sunucuda başka oyuncu yok"
        emptyLabel.Size = UDim2.new(1, 0, 0, 28)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 11
        emptyLabel.Parent = scrollFrame
    end
end

-- Buton eventleri
startButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        startTracking()
    else
        local oldText = startButton.Text
        startButton.Text = "⚠️ OYUNCU SEÇ!"
        task.wait(0.5)
        startButton.Text = oldText
    end
end)

stopButton.MouseButton1Click:Connect(function()
    stopTracking()
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
    if not screenGui.Enabled then
        stopTracking()
    end
end)

-- Mesafe kontrol butonları
local minusBtn = Instance.new("TextButton")
minusBtn.Text = "-"
minusBtn.Size = UDim2.new(0, 22, 0, 22)
minusBtn.Position = UDim2.new(0.65, 0, 0.2, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 12
minusBtn.Parent = controlFrame

local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+"
plusBtn.Size = UDim2.new(0, 22, 0, 22)
plusBtn.Position = UDim2.new(0.8, 0, 0.2, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 12
plusBtn.Parent = controlFrame

-- Titreme kontrol butonları
local minusShakeBtn = Instance.new("TextButton")
minusShakeBtn.Text = "-"
minusShakeBtn.Size = UDim2.new(0, 22, 0, 22)
minusShakeBtn.Position = UDim2.new(0.65, 0, 0.5, 0)
minusShakeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minusShakeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusShakeBtn.Font = Enum.Font.GothamBold
minusShakeBtn.TextSize = 12
minusShakeBtn.Parent = controlFrame

local plusShakeBtn = Instance.new("TextButton")
plusShakeBtn.Text = "+"
plusShakeBtn.Size = UDim2.new(0, 22, 0, 22)
plusShakeBtn.Position = UDim2.new(0.8, 0, 0.5, 0)
plusShakeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
plusShakeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusShakeBtn.Font = Enum.Font.GothamBold
plusShakeBtn.TextSize = 12
plusShakeBtn.Parent = controlFrame

local smallCorner = Instance.new("UICorner")
smallCorner.CornerRadius = UDim.new(0, 4)
smallCorner.Parent = minusBtn
smallCorner:Clone().Parent = plusBtn
smallCorner:Clone().Parent = minusShakeBtn
smallCorner:Clone().Parent = plusShakeBtn

minusBtn.MouseButton1Click:Connect(function() changeDistance(-0.2) end)
plusBtn.MouseButton1Click:Connect(function() changeDistance(0.2) end)
minusShakeBtn.MouseButton1Click:Connect(function() changeShake(-0.02) end)
plusShakeBtn.MouseButton1Click:Connect(function() changeShake(0.02) end)

-- Klavye kontrolleri
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        if selectedPlayer then
            if isTracking then
                stopTracking()
            else
                startTracking()
            end
        end
    elseif input.KeyCode == Enum.KeyCode.R then
        if selectedPlayer then
            startTracking()
        end
    elseif input.KeyCode == Enum.KeyCode.Q then
        changeDistance(-0.2)
    elseif input.KeyCode == Enum.KeyCode.E then
        changeDistance(0.2)
    elseif input.KeyCode == Enum.KeyCode.Z then
        changeShake(-0.02)
    elseif input.KeyCode == Enum.KeyCode.X then
        changeShake(0.02)
    end
end)

-- Oyuncu listesini başlat
updatePlayerList()

-- Oyuncu değişikliklerini dinle
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    task.wait(0.3)
    updatePlayerList()
    
    if selectedPlayer and selectedPlayer == leavingPlayer then
        stopTracking()
        selectedPlayer = nil
        statusLabel.Text = "🔴 OYUNCU ÇIKTI"
        task.wait(1)
        statusLabel.Text = "🔴 TAKİP KAPALI"
    end
end)

-- Karakter değişikliklerini dinle
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if isTracking and selectedPlayer then
        task.wait(0.5)
        startTracking()
    end
end)

-- Başlangıç mesajı
print("==========================================")
print("✅ YAKIN TAKİP SİSTEMİ YÜKLENDİ!")
print("==========================================")
print("🎯 YENİ ÖZELLİKLER:")
print("   • TİTREME EFEKTİ (Z/X ile kontrol)")
print("   • SÜPER HIZLI TEPKİ SÜRESİ (0.05s)")
print("   • HAREKET TAHMİNİ ALGORİTMASI")
print("   • HEDEF ZIPLADIĞINDA ZIPLAMA")
print("   • ARKASINDAN TAKİP (Sürekli arkada kal)")
print("==========================================")
print("🎮 KONTROLLER:")
print("   • T - Takip Aç/Kapat")
print("   • R - Arkasına ışınlan ve Takip Başlat")
print("   • Q/E - Mesafe Ayarla (0.1m - 5m)")
print("   • Z/X - Titreme Şiddeti (0 - 0.5)")
print("==========================================")
print("🚀 KULLANIM:")
print("   1. Oyuncu seç")
print("   2. BAŞLAT butonuna tıkla")
print("   3. Sürekli hedefin ARKASINDA kalacak")
print("   4. Titreme ile daha organik görünüm")
print("==========================================")
