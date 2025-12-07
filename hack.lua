-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Oyuncu değişkenleri
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- HIZLI AYARLAR (Güncellendi)
local FOLLOW_DISTANCE = 1.5
local FOLLOW_HEIGHT = 1.5
local RESPONSE_SPEED = 0.05  -- Çok daha hızlı tepki
local PREDICTION_STRENGTH = 0.3  -- Hareket tahmini
local SIDE_OFFSET = 0.3
local JUMP_DELAY = 0.05  -- Daha hızlı zıplama

-- Titreme ayarları (geliştirildi)
local TITREME_FREQUENCY = 25
local TITREME_AMPLITUDE = 0.08
local TITREME_SMOOTHNESS = 0.8

-- Hız takip ayarları
local MAX_SPEED_MULTIPLIER = 3.0
local MIN_SPEED_MULTIPLIER = 1.5
local SPEED_ADAPT_RATE = 0.5

-- GUI (Aynı kalabilir veya kaldırılabilir)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFastFollowGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "⚡ SÜPER HIZLI TAKİP ⚡"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.white
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "🔴 KAPALI"
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- Değişkenler
local selectedPlayer = nil
local isTracking = false
local trackingConnection = nil
local time = 0
local lastTargetPos = nil
local targetVelocity = Vector3.zero
local currentSpeedMultiplier = MIN_SPEED_MULTIPLIER
local isTeleporting = false
local teleportCooldown = 0

-- Geliştirilmiş titreme efekti
local function getDynamicShake(t, velocityMagnitude)
    local speedFactor = math.clamp(velocityMagnitude / 50, 0, 1)
    
    -- Hıza bağlı titreme
    local baseAmplitude = TITREME_AMPLITUDE * (0.5 + speedFactor * 0.5)
    local baseFrequency = TITREME_FREQUENCY * (1 + speedFactor * 0.5)
    
    -- Çoklu frekans titremesi
    local x = (math.sin(t * baseFrequency) * 0.7 + 
               math.sin(t * baseFrequency * 1.7) * 0.3) * baseAmplitude
    local y = (math.cos(t * baseFrequency * 0.8) * 0.6 + 
               math.cos(t * baseFrequency * 2.1) * 0.4) * baseAmplitude
    local z = (math.sin(t * baseFrequency * 1.2) * 0.5 + 
               math.sin(t * baseFrequency * 1.9) * 0.5) * baseAmplitude
    
    return Vector3.new(x, y, z) * TITREME_SMOOTHNESS
end

-- Hedef hız analizi (geliştirilmiş)
local function analyzeTargetVelocity(targetRoot, deltaTime)
    if not targetRoot then return Vector3.zero end
    
    local currentPos = targetRoot.Position
    
    if lastTargetPos then
        local rawVelocity = (currentPos - lastTargetPos) / deltaTime
        local speed = rawVelocity.Magnitude
        
        -- Hızı filtrele
        targetVelocity = targetVelocity:Lerp(rawVelocity, 0.7)
        
        -- Hız çarpanını ayarla
        if speed > 10 then
            currentSpeedMultiplier = math.min(
                currentSpeedMultiplier + SPEED_ADAPT_RATE * deltaTime,
                MAX_SPEED_MULTIPLIER
            )
        else
            currentSpeedMultiplier = math.max(
                currentSpeedMultiplier - SPEED_ADAPT_RATE * deltaTime * 0.5,
                MIN_SPEED_MULTIPLIER
            )
        end
    end
    
    lastTargetPos = currentPos
    return targetVelocity
end

-- Geliştirilmiş pozisyon tahmini
local function getPredictedPosition(targetRoot, deltaTime)
    if not targetRoot then return nil end
    
    local currentPos = targetRoot.Position
    local velocity = analyzeTargetVelocity(targetRoot, deltaTime)
    
    -- Hareket yönü tahmini
    local moveDirection = velocity.Unit
    local speed = velocity.Magnitude
    
    -- İleri görüşlü tahmin
    local predictionTime = RESPONSE_SPEED * (1 + speed / 100)
    local predictedPos = currentPos + (velocity * predictionTime)
    
    -- Hedefin dönüşünü de tahmin et
    local targetCF = targetRoot.CFrame
    local lookVector = targetCF.LookVector
    
    -- Eğer hızlı hareket ediyorsa, hareket yönüne göre ayarla
    if speed > 5 then
        predictedPos = predictedPos + (moveDirection * speed * 0.1)
    end
    
    return predictedPos, moveDirection, speed
end

-- SÜPER HIZLI TAKİP FONKSİYONU
local function ultraFastFollow(targetCharacter, deltaTime)
    if not targetCharacter or not isTracking then return end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    
    if not targetRoot or not humanoidRootPart then return end
    
    -- Tahmini pozisyon ve hız
    local predictedPos, moveDirection, speed = getPredictedPosition(targetRoot, deltaTime)
    if not predictedPos then predictedPos = targetRoot.Position end
    
    -- Hedefin yön vektörleri
    local targetCF = targetRoot.CFrame
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    -- ARKASINDA KALMA stratejisi
    local behindOffset = lookVector * -FOLLOW_DISTANCE
    local sideOffset = rightVector * SIDE_OFFSET
    local heightOffset = Vector3.new(0, FOLLOW_HEIGHT, 0)
    
    -- Temel pozisyon
    local basePosition = predictedPos + behindOffset + heightOffset + sideOffset
    
    -- Dinamik titreme ekle
    time = time + deltaTime
    local shakeOffset = getDynamicShake(time, speed)
    local finalPosition = basePosition + shakeOffset
    
    -- ANINDA TELEPORT (çok hızlı hareket için)
    if speed > 30 or teleportCooldown <= 0 then
        isTeleporting = true
        humanoidRootPart.CFrame = CFrame.new(finalPosition, predictedPos)
        teleportCooldown = 0.1
        isTeleporting = false
        return
    end
    
    -- HIZLI LERP ile takip
    local currentPos = humanoidRootPart.Position
    local distanceToTarget = (finalPosition - currentPos).Magnitude
    
    -- Hıza bağlı interpolasyon
    local lerpAlpha = math.min(RESPONSE_SPEED * currentSpeedMultiplier * 60 * deltaTime, 0.9)
    
    -- Çok hızlı hareket
    if distanceToTarget > 5 then
        lerpAlpha = math.min(lerpAlpha * 2, 0.95)
    end
    
    local smoothPosition = currentPos:Lerp(finalPosition, lerpAlpha)
    
    -- Hedefe bak
    local lookAtCF = CFrame.new(smoothPosition, Vector3.new(predictedPos.X, smoothPosition.Y, predictedPos.Z))
    humanoidRootPart.CFrame = lookAtCF
    
    -- Zıplama senkronizasyonu
    if targetHumanoid and humanoid then
        if targetHumanoid.Jump and not humanoid.Jump then
            task.spawn(function()
                task.wait(JUMP_DELAY)
                if isTracking then
                    humanoid.Jump = true
                end
            end)
        end
    end
    
    -- Teleport cooldown
    if teleportCooldown > 0 then
        teleportCooldown = teleportCooldown - deltaTime
    end
end

-- TAKİP BAŞLAT (Güncellendi)
local function startTracking()
    if not selectedPlayer then 
        statusLabel.Text = "⚠️ OYUNCU SEÇİLMEDİ"
        task.wait(1)
        statusLabel.Text = "🔴 KAPALI"
        return 
    end
    
    -- Önceki bağlantıları temizle
    if trackingConnection then
        trackingConnection:Disconnect()
    end
    
    isTracking = true
    statusLabel.Text = "✅ TAKİP: " .. selectedPlayer.Name
    statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    
    -- İlk anında teleport
    local targetCharacter = selectedPlayer.Character
    if targetCharacter then
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local lookVector = targetRoot.CFrame.LookVector
            local startPos = targetRoot.Position + (lookVector * -FOLLOW_DISTANCE) + 
                            Vector3.new(0, FOLLOW_HEIGHT, 0) +
                            (targetRoot.CFrame.RightVector * SIDE_OFFSET)
            
            humanoidRootPart.CFrame = CFrame.new(startPos, targetRoot.Position)
        end
    end
    
    -- Yüksek frekanslı takip döngüsü
    trackingConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if isTracking and selectedPlayer then
            local targetCharacter = selectedPlayer.Character
            if targetCharacter then
                ultraFastFollow(targetCharacter, deltaTime)
            end
        end
    end)
    
    print("⚡ SÜPER HIZLI TAKİP BAŞLATILDI: " .. selectedPlayer.Name)
end

-- Takip durdur
local function stopTracking()
    isTracking = false
    statusLabel.Text = "🔴 KAPALI"
    statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    lastTargetPos = nil
    targetVelocity = Vector3.zero
    currentSpeedMultiplier = MIN_SPEED_MULTIPLIER
end

-- Oyun içi kontroller (daha hızlı)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        -- En yakın oyuncuyu otomatik seç
        local closestPlayer = nil
        local closestDistance = math.huge
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local targetRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                    if distance < closestDistance and distance < 50 then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
        
        if closestPlayer then
            selectedPlayer = closestPlayer
            if not isTracking then
                startTracking()
            else
                stopTracking()
            end
        end
        
    elseif input.KeyCode == Enum.KeyCode.G then
        -- Takip modunu değiştir
        if isTracking then
            stopTracking()
        elseif selectedPlayer then
            startTracking()
        end
        
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Anında arkasına teleport
        if selectedPlayer and selectedPlayer.Character then
            local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local lookVector = targetRoot.CFrame.LookVector
                local teleportPos = targetRoot.Position + (lookVector * -FOLLOW_DISTANCE) + 
                                   Vector3.new(0, FOLLOW_HEIGHT, 0)
                humanoidRootPart.CFrame = CFrame.new(teleportPos, targetRoot.Position)
            end
        end
    end
end)

-- Oyuncu değişikliklerini dinle
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    
    if isTracking and selectedPlayer then
        task.wait(0.3)
        startTracking()
    end
end)

-- Mesaj
print("==========================================")
print("⚡ SÜPER HIZLI ARKADAN TAKİP SİSTEMİ ⚡")
print("==========================================")
print("🎯 ÖZELLİKLER:")
print("   • ANINDA TELEPORT (Hızlı hareketlerde)")
print("   • HAREKET TAHMİNİ ALGORİTMASI")
print("   • HIZA DUYARLI TAKİP")
print("   • SÜREKLİ ARKADA KALMA")
print("   • DINAMIK TITREME EFEKTI")
print("==========================================")
print("🎮 KONTROLLER:")
print("   • F - En yakın oyuncuyu seç ve takip et")
print("   • G - Takibi aç/kapat")
print("   • H - Anında arkasına ışınlan")
print("==========================================")
print("📊 SİSTEM:")
print("   • Tepki süresi: " .. RESPONSE_SPEED .. "s")
print("   • Maksimum hız çarpanı: " .. MAX_SPEED_MULTIPLIER .. "x")
print("   • Takip mesafesi: " .. FOLLOW_DISTANCE .. "m")
print("==========================================")
