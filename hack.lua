-- Bu scripti executor ile çalıştır, her şey otomatik kurulsun
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI'yi temizle (varsa)
if playerGui:FindFirstChild("PrisonSystem") then
    playerGui.PrisonSystem:Destroy()
end

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PrisonSystem"
screenGui.Parent = playerGui

-- Ana frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "🔒 HAREKET ENGELLEYİCİ 🔒"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Oyuncu listesi
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 0, 350)
playerList.Position = UDim2.new(0, 10, 0, 60)
playerList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 8
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = mainFrame

-- Seçilen oyuncu
local selectedPlayer = nil
local imprisonedPlayers = {}

-- Hapset butonu
local imprisonBtn = Instance.new("TextButton")
imprisonBtn.Size = UDim2.new(1, -20, 0, 45)
imprisonBtn.Position = UDim2.new(0, 10, 0, 420)
imprisonBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
imprisonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
imprisonBtn.Text = "🚨 HAREKETİ ENGELLE 🚨"
imprisonBtn.Font = Enum.Font.GothamBold
imprisonBtn.TextSize = 16
imprisonBtn.Parent = mainFrame

-- Serbest bırak butonu
local freeBtn = Instance.new("TextButton")
freeBtn.Size = UDim2.new(1, -20, 0, 45)
freeBtn.Position = UDim2.new(0, 10, 0, 470)
freeBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
freeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freeBtn.Text = "🔓 HAREKETİ AÇ"
freeBtn.Font = Enum.Font.GothamBold
freeBtn.TextSize = 16
freeBtn.Parent = mainFrame

-- GUI'yi açmak için tuş (F tuşu)
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Oyuncunun hareketini engelle
local function imprisonPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character then
        local char = targetPlayer.Character
        
        -- Humanoid'i bul veya bekle
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid then
            char.ChildAdded:Wait()
            humanoid = char:FindFirstChild("Humanoid")
        end
        
        if humanoid then
            -- Hareketi engelle
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            
            -- RootPart'ı kilitle
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Anchored = true
                
                -- Eski kontrolleri temizle
                for _, obj in pairs(rootPart:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                        obj:Destroy()
                    end
                end
                
                -- Yeni kontroller ekle
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
                bodyVelocity.Parent = rootPart
                
                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                bodyGyro.P = 10000
                bodyGyro.D = 1000
                bodyGyro.Parent = rootPart
            end
            
            -- Karakter değişirse tekrar kilitle
            local function lockCharacter(newChar)
                wait(0.5)
                local newHumanoid = newChar:FindFirstChild("Humanoid")
                local newRootPart = newChar:FindFirstChild("HumanoidRootPart")
                
                if newHumanoid then
                    newHumanoid.WalkSpeed = 0
                    newHumanoid.JumpPower = 0
                end
                
                if newRootPart then
                    newRootPart.Anchored = true
                    
                    local newBodyVelocity = Instance.new("BodyVelocity")
                    newBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    newBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
                    newBodyVelocity.Parent = newRootPart
                    
                    local newBodyGyro = Instance.new("BodyGyro")
                    newBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                    newBodyGyro.P = 10000
                    newBodyGyro.D = 1000
                    newBodyGyro.Parent = newRootPart
                end
            end
            
            -- Karakter değişikliklerini takip et
            targetPlayer.CharacterAdded:Connect(lockCharacter)
            
            -- Hapsedilen oyuncular listesine ekle
            imprisonedPlayers[targetName] = true
            
            print("✅ " .. targetName .. " hareketi engellendi!")
        end
    else
        print("❌ Oyuncu bulunamadı!")
    end
end

-- Oyuncunun hareketini serbest bırak
local function freePlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    
    if targetPlayer and targetPlayer.Character then
        local char = targetPlayer.Character
        local humanoid = char:FindFirstChild("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        
        if rootPart then
            rootPart.Anchored = false
            
            -- BodyVelocity ve BodyGyro'yu temizle
            for _, obj in pairs(rootPart:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                    obj:Destroy()
                end
            end
        end
        
        -- Hapsedilen oyuncular listesinden çıkar
        imprisonedPlayers[targetName] = nil
        
        print("✅ " .. targetName .. " hareketi serbest bırakıldı!")
    else
        print("❌ Oyuncu bulunamadı!")
    end
end

-- Tüm oyuncuları hapset
local function imprisonAllPlayers()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            imprisonPlayer(otherPlayer.Name)
        end
    end
    print("✅ Tüm oyuncular hapsedildi!")
end

-- Tüm oyuncuları serbest bırak
local function freeAllPlayers()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            freePlayer(otherPlayer.Name)
        end
    end
    print("✅ Tüm oyuncular serbest bırakıldı!")
end

-- Oyuncu listesini doldur
local function updatePlayerList()
    playerList:ClearAllChildren()
    
    local yOffset = 0
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, 0, 0, 40)
            playerFrame.Position = UDim2.new(0, 0, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            playerFrame.BorderSizePixel = 1
            playerFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
            playerFrame.Parent = playerList
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0.7, 0, 1, 0)
            playerName.Position = UDim2.new(0, 10, 0, 0)
            playerName.BackgroundTransparency = 1
            playerName.TextColor3 = imprisonedPlayers[otherPlayer.Name] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(255, 255, 255)
            playerName.Text = otherPlayer.Name .. (imprisonedPlayers[otherPlayer.Name] and " 🔒" or " 🔓")
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 14
            playerName.Parent = playerFrame
            
            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(0.25, -5, 0.7, 0)
            selectBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
            selectBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectBtn.Text = "SEÇ"
            selectBtn.Font = Enum.Font.GothamBold
            selectBtn.TextSize = 12
            selectBtn.Parent = playerFrame
            
            selectBtn.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer.Name
                imprisonBtn.Text = "🚨 " .. otherPlayer.Name .. " ENGELLE 🚨"
                freeBtn.Text = "🔓 " .. otherPlayer.Name .. " SERBEST BIRAK"
            end)
            
            yOffset = yOffset + 45
        end
    end
    
    -- Tümünü hapset/serbest bırak butonları
    local allFrame = Instance.new("Frame")
    allFrame.Size = UDim2.new(1, 0, 0, 80)
    allFrame.Position = UDim2.new(0, 0, 0, yOffset)
    allFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    allFrame.BorderSizePixel = 1
    allFrame.Parent = playerList
    
    local imprisonAllBtn = Instance.new("TextButton")
    imprisonAllBtn.Size = UDim2.new(0.9, 0, 0, 30)
    imprisonAllBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    imprisonAllBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    imprisonAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    imprisonAllBtn.Text = "🚨 TÜMÜNÜ HAPSED 🚨"
    imprisonAllBtn.Font = Enum.Font.GothamBold
    imprisonAllBtn.TextSize = 12
    imprisonAllBtn.Parent = allFrame
    
    local freeAllBtn = Instance.new("TextButton")
    freeAllBtn.Size = UDim2.new(0.9, 0, 0, 30)
    freeAllBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
    freeAllBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    freeAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freeAllBtn.Text = "🔓 TÜMÜNÜ SERBEST BIRAK 🔓"
    freeAllBtn.Font = Enum.Font.GothamBold
    freeAllBtn.TextSize = 12
    freeAllBtn.Parent = allFrame
    
    imprisonAllBtn.MouseButton1Click:Connect(imprisonAllPlayers)
    freeAllBtn.MouseButton1Click:Connect(freeAllPlayers)
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 90)
end

-- Buton eventleri
imprisonBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        imprisonPlayer(selectedPlayer)
        wait(0.1)
        updatePlayerList()
    else
        print("❌ Lütfen önce bir oyuncu seçin!")
    end
end)

freeBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        freePlayer(selectedPlayer)
        wait(0.1)
        updatePlayerList()
    else
        print("❌ Lütfen önce bir oyuncu seçin!")
    end
end)

-- Oyuncu listesini güncelle
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Başlangıç mesajı
print("🎯 HAREKET ENGELLEYİCİ SİSTEM YÜKLENDİ!")
print("📝 F tuşuna basarak GUI'yi aç/kapat")
print("👤 Oyuncu seç ve HAREKETİ ENGELLE butonuna tıkla!")
print("🚫 Hapsedilen oyuncular HİÇBİR ŞEKİLDE HAREKET EDEMEZ!")

-- Mevcut oyuncuları kontrol et
spawn(function()
    wait(2)
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            if imprisonedPlayers[otherPlayer.Name] then
                imprisonPlayer(otherPlayer.Name)
            end
        end
    end
end)
