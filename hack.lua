-- LocalScript - StarterPlayerScripts içine koyun
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Ayarlar
local settings = {
    enabled = false,
    aimKey = Enum.KeyCode.F,
    maxDistance = 50,
    smoothness = 0.3,
    autoShoot = false,
    aimAtHead = true
}

-- Değişkenler
local currentTarget = nil
local isAiming = false
local connection

-- GUI Oluşturma
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimBotGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 180)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "AIM BOT SİSTEMİ"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Aç/Kapa Butonu
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
toggleButton.Position = UDim2.new(0.05, 0, 0, 40)
toggleButton.Text = "AIMBOT: KAPALI"
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 12
toggleButton.Font = Enum.Font.Gotham
toggleButton.Parent = mainFrame

-- Durum Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 25)
statusLabel.Position = UDim2.new(0.05, 0, 0, 85)
statusLabel.Text = "Durum: Pasif"
statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Mesafe Label
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(0.9, 0, 0, 25)
distanceLabel.Position = UDim2.new(0.05, 0, 0, 115)
distanceLabel.Text = "Hedef: Yok"
distanceLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLabel.TextSize = 11
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.Parent = mainFrame

-- Kapatma Butonu
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.4, 0, 0, 25)
closeButton.Position = UDim2.new(0.55, 0, 0, 145)
closeButton.Text = "Kapat"
closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 11
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = mainFrame

-- En Yakın Oyuncuyu Bulma
local function findClosestPlayer()
    local closestPlayer = nil
    local closestDistance = settings.maxDistance
    local localPlayer = player
    local localCharacter = localPlayer.Character
    
    if not localCharacter then return nil end
    
    local localHead = localCharacter:FindFirstChild("Head")
    if not localHead then return nil end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= localPlayer and otherPlayer.Character then
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

-- Aim Fonksiyonu
local function aimAtTarget(target)
    if not target or not target.Character then return end
    
    local targetPart = settings.aimAtHead and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    
    local camera = workspace.CurrentCamera
    local screenPoint = camera:WorldToScreenPoint(targetPart.Position)
    
    -- Mouse'u hedefe yönlendir (smooth)
    if screenPoint.Z > 0 then
        local targetX, targetY = screenPoint.X, screenPoint.Y
        local currentX, currentY = mouse.X, mouse.Y
        
        -- Smooth aim
        local newX = currentX + (targetX - currentX) * settings.smoothness
        local newY = currentY + (targetY - currentY) * settings.smoothness
        
        mousemoverel(newX - currentX, newY - currentY)
    end
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
            distanceLabel.Text = "Hedef: " .. target.Name .. " (" .. math.floor(distance) .. "m)"
            
            if isAiming then
                aimAtTarget(target)
                
                -- Auto shoot
                if settings.autoShoot and mouse.Target then
                    local hitPlayer = Players:GetPlayerFromCharacter(mouse.Target.Parent)
                    if hitPlayer == target then
                        mouse1click()
                    end
                end
            end
        else
            statusLabel.Text = "Durum: HEDEF ARANIYOR"
            statusLabel.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
            distanceLabel.Text = "Hedef: Yok"
        end
    end)
end

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
        distanceLabel.Text = "Hedef: Yok"
        if connection then
            connection:Disconnect()
        end
    end
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

print("Aim Bot Sistemi Yüklendi! F tuşu ile aim yapabilirsiniz.")
