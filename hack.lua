-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Oyuncu değişkenleri
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- HIZLI AYARLAR
local FOLLOW_DISTANCE = 1.5
local FOLLOW_HEIGHT = 1.5
local RESPONSE_SPEED = 0.03  -- Çok daha hızlı tepki
local SIDE_OFFSET = 0.3
local JUMP_DELAY = 0.05

-- GUI OLUŞTURMA (DÜZELTİLDİ)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFastFollowGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  -- Önemli!
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ANA FRAME
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 230)
mainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Köşe yuvarlama
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Gölge efekti
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Image = "rbxassetid://5554236805"
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Size = UDim2.new(1, 14, 1, 14)
shadow.Position = UDim2.new(0, -7, 0, -7)
shadow.BackgroundTransparency = 1
shadow.ImageTransparency = 0.5
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.Parent = mainFrame

-- BAŞLIK
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "⚡ SÜPER HIZLI TAKİP ⚡"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextStrokeTransparency = 0.8
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12, 0, 0)
titleCorner.Parent = title

-- DURUM GÖSTERGESİ
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(1, -20, 0, 35)
statusFrame.Position = UDim2.new(0, 10, 0, 45)
statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusFrame.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = "🔴 TAKİP KAPALI"
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.Parent = statusFrame

-- OYUNCU LİSTESİ
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerScroll"
scrollFrame.Size = UDim2.new(1, -20, 0, 100)
scrollFrame.Position = UDim2.new(0, 10, 0, 90)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.SortOrder = Enum.SortOrder.Name

-- BUTONLAR
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -20, 0, 40)
buttonsFrame.Position = UDim2.new(0, 10, 0, 200)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Text = "🚀 BAŞLAT"
startButton.Size = UDim2.new(0.48, 0, 1, 0)
startButton.Position = UDim2.new(0, 0, 0, 0)
startButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 14
startButton.AutoButtonColor = true
startButton.Parent = buttonsFrame

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Text = "⛔ DURDUR"
stopButton.Size = UDim2.new(0.48, 0, 1, 0)
stopButton.Position = UDim2.new(0.52, 0, 0, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.AutoButtonColor = true
stopButton.Visible = false
stopButton.Parent = buttonsFrame

-- Buton köşeleri
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = startButton
buttonCorner:Clone().Parent = stopButton

-- Buton efektleri
local function setupButtonHover(button)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3 * Color3.new(1.2, 1.2, 1.2)
    end)
    
    button.MouseLeave:Connect(function()
        if button.Name == "StartButton" then
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        else
            button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3 * Color3.new(0.8, 0.8, 0.8)
    end)
    
    button.MouseButton1Up:Connect(function()
        if button.Name == "StartButton" then
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        else
            button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        end
    end)
end

setupButtonHover(startButton)
setupButtonHover(stopButton)

-- KAPATMA BUTONU
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.AutoButtonColor = true
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
    if not screenGui.Enabled then
        stopTracking()
    end
end)

-- Değişkenler
local selectedPlayer = nil
local isTracking = false
local trackingConnection = nil
local lastTargetPos = nil
local targetVelocity = Vector3.zero

-- OYUNCU LİSTESİNİ GÜNCELLE
local function updatePlayerList()
    -- Temizle
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local playersAdded = 0
    
    -- Diğer oyuncuları listele
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            playersAdded = playersAdded + 1
            
            local playerButton = Instance.new("TextButton")
            playerButton.Name = otherPlayer.Name
            playerButton.Text = "👤 " .. otherPlayer.Name
            playerButton.Size = UDim2.new(1, -10, 0, 30)
            playerButton.Position = UDim2.new(0, 5, 0, (playersAdded-1)*35)
            playerButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            playerButton.TextColor3 = Color3.fromRGB(200, 200, 220)
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextSize = 12
            playerButton.AutoButtonColor = true
            playerButton.TextXAlignment = Enum.TextXAlignment.Left
            playerButton.TextTruncate = Enum.TextTruncate.AtEnd
            
            -- Hover efekti
            playerButton.MouseEnter:Connect(function()
                if selectedPlayer ~= otherPlayer then
                    playerButton.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
                end
            end)
            
            playerButton.MouseLeave:Connect(function()
                if selectedPlayer ~= otherPlayer then
                    playerButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
                end
            end)
            
            playerButton.MouseButton1Click:Connect(function()
                -- Tüm butonları sıfırla
                for _, btn in ipairs(scrollFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        if btn.Name == otherPlayer.Name then
                            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
                        else
                            btn.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
                        end
                    end
                end
                
                selectedPlayer = otherPlayer
                statusLabel.Text = "🎯 SEÇİLDİ: " .. otherPlayer.Name
                statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                
                print("✅ Oyuncu seçildi: " .. otherPlayer.Name)
            end)
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = playerButton
            
            playerButton.Parent = scrollFrame
        end
    end
    
    -- Eğer oyuncu yoksa
    if playersAdded == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Text = "🌙 Başka oyuncu yok..."
        emptyLabel.Size = UDim2.new(1, 0, 0, 30)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 12
        emptyLabel.Parent = scrollFrame
    end
    
    -- ScrollFrame boyutunu ayarla
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, playersAdded * 35)
end

-- HIZLI TAKİP ALGORİTMASI
local function ultraFastFollow(targetCharacter, deltaTime)
    if not targetCharacter or not isTracking then return end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not humanoidRootPart then return end
    
    -- Hedef pozisyonu
    local targetPos = targetRoot.Position
    local targetCF = targetRoot.CFrame
    
    -- Hız hesaplama
    if lastTargetPos then
        local velocity = (targetPos - lastTargetPos) / deltaTime
        targetVelocity = targetVelocity:Lerp(velocity, 0.5)
    end
    lastTargetPos = targetPos
    
    -- Arkasında pozisyon
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    -- Temel pozisyon
    local basePos = targetPos + 
                    (lookVector * -FOLLOW_DISTANCE) + 
                    Vector3.new(0, FOLLOW_HEIGHT, 0) + 
                    (rightVector * SIDE_OFFSET)
    
    -- Hedef hızlı hareket ediyorsa, tahmin yap
    if targetVelocity.Magnitude > 5 then
        local prediction = targetVelocity * RESPONSE_SPEED * 2
        basePos = basePos + prediction
    end
    
    -- ANINDA TELEPORT
    humanoidRootPart.CFrame = CFrame.new(basePos, 
        Vector3.new(targetPos.X, basePos.Y, targetPos.Z))
    
    -- Zıplama senkronizasyonu
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    if targetHumanoid and humanoid then
        if targetHumanoid.Jump and not humanoid.Jump then
            task.wait(JUMP_DELAY)
            humanoid.Jump = true
        end
    end
end

-- TAKİP BAŞLAT
local function startTracking()
    if not selectedPlayer then 
        statusLabel.Text = "⚠️ OYUNCU SEÇİLMEDİ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        
        -- Geri sayım animasyonu
        for i = 3, 1, -1 do
            statusLabel.Text = "⚠️ " .. i .. " saniye..."
            task.wait(1)
        end
        statusLabel.Text = "🔴 TAKİP KAPALI"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return 
    end
    
    -- Takip zaten açıksa durdur
    if isTracking then
        stopTracking()
        return
    end
    
    isTracking = true
    statusLabel.Text = "✅ TAKİP AÇIK: " .. selectedPlayer.Name
    statusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    startButton.Visible = false
    stopButton.Visible = true
    
    -- Takip bağlantısını başlat
    if trackingConnection then
        trackingConnection:Disconnect()
    end
    
    trackingConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if isTracking and selectedPlayer then
            local targetCharacter = selectedPlayer.Character
            if targetCharacter then
                ultraFastFollow(targetCharacter, deltaTime)
            end
        end
    end)
    
    print("✅ Takip başlatıldı: " .. selectedPlayer.Name)
end

-- TAKİP DURDUR
local function stopTracking()
    isTracking = false
    statusLabel.Text = "🔴 TAKİP KAPALI"
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    startButton.Visible = true
    stopButton.Visible = false
    
    if trackingConnection then
        trackingConnection:Disconnect()
        trackingConnection = nil
    end
    
    lastTargetPos = nil
    targetVelocity = Vector3.zero
    
    print("⛔ Takip durduruldu")
end

-- BUTON EVENTLERİ
startButton.MouseButton1Click:Connect(startTracking)
stopButton.MouseButton1Click:Connect(stopTracking)

-- KLAVYE KONTROLLERİ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        if selectedPlayer then
            if isTracking then
                stopTracking()
            else
                startTracking()
            end
        else
            print("⚠️ Önce bir oyuncu seçin!")
        end
        
    elseif input.KeyCode == Enum.KeyCode.R then
        -- En yakın oyuncuyu otomatik seç
        local closestPlayer = nil
        local closestDistance = math.huge
        
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local targetRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
        end
        
        if closestPlayer then
            selectedPlayer = closestPlayer
            statusLabel.Text = "🎯 OTOMATİK SEÇİLDİ: " .. closestPlayer.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
            print("✅ En yakın oyuncu seçildi: " .. closestPlayer.Name)
            
            -- Takip et
            if not isTracking then
                startTracking()
            end
        end
        
    elseif input.KeyCode == Enum.KeyCode.H then
        -- GUI'yi gizle/göster
        screenGui.Enabled = not screenGui.Enabled
        if screenGui.Enabled then
            print("📱 GUI açıldı")
        else
            print("📱 GUI kapandı")
        end
    end
end)

-- OYUNCU LİSTESİNİ BAŞLAT
task.wait(1)  -- Kısa bir bekleme
updatePlayerList()

-- OYUNCU DEĞİŞİKLİKLERİNİ DİNLE
Players.PlayerAdded:Connect(function()
    task.wait(1)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(leavingPlayer)
    task.wait(0.5)
    updatePlayerList()
    
    if selectedPlayer and selectedPlayer == leavingPlayer then
        stopTracking()
        selectedPlayer = nil
        statusLabel.Text = "🔴 OYUNCU AYRILDI"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(2)
        statusLabel.Text = "🔴 TAKİP KAPALI"
    end
end)

-- KARAKTER DEĞİŞİKLİKLERİ
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    
    if isTracking and selectedPlayer then
        task.wait(0.5)
        startTracking()
    end
end)

-- GUI GÖRÜNÜRLÜĞÜ İÇİN TEST
task.spawn(function()
    task.wait(2)
    if screenGui and screenGui.Parent then
        print("✅ GUI başarıyla yüklendi!")
        print("📱 GUI Ekranda görünüyor")
        print("🎮 Kontroller:")
        print("   • T - Takip aç/kapat")
        print("   • R - En yakın oyuncuyu seç ve takip et")
        print("   • H - GUI'yi gizle/göster")
        print("   • Mouse ile GUI'yi sürükleyebilirsin")
    else
        print("❌ GUI yüklenemedi!")
    end
end)

print("==========================================")
print("🎮 SÜPER HIZLI TAKİP SİSTEMİ AKTİF!")
print("==========================================")
print("✅ GUI yüklendi - Ekranın sol üstünde")
print("✅ Herhangi bir oyuncuya tıkla ve BAŞLAT'a bas")
print("✅ Takip başladığında sürekli arkada kalacaksın")
print("==========================================")
