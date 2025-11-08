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
mainFrame.Size = UDim2.new(0, 450, 0, 550)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
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
title.Text = "🔒 HAPİSHANE SİSTEMİ 🔒"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
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

-- Hapset butonu
local imprisonBtn = Instance.new("TextButton")
imprisonBtn.Size = UDim2.new(1, -20, 0, 45)
imprisonBtn.Position = UDim2.new(0, 10, 0, 420)
imprisonBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
imprisonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
imprisonBtn.Text = "🚨 HAPSED 🚨"
imprisonBtn.Font = Enum.Font.GothamBold
imprisonBtn.TextSize = 16
imprisonBtn.Parent = mainFrame

-- Serbest bırak butonu
local freeBtn = Instance.new("TextButton")
freeBtn.Size = UDim2.new(1, -20, 0, 45)
freeBtn.Position = UDim2.new(0, 10, 0, 470)
freeBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
freeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freeBtn.Text = "🔓 SERBEST BIRAK"
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

-- Parmaklık oluşturma fonksiyonu
local function createBars(targetChar)
    if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    local bars = Instance.new("Model")
    bars.Name = "PrisonBars_" .. targetChar.Name
    
    local rootPart = targetChar.HumanoidRootPart
    local pos = rootPart.Position
    
    -- Zemindeki daire parmaklık
    local baseRing = Instance.new("Part")
    baseRing.Name = "BaseRing"
    baseRing.Size = Vector3.new(12, 0.5, 12)
    baseRing.Position = Vector3.new(pos.X, pos.Y - 3.5, pos.Z)
    baseRing.Anchored = true
    baseRing.BrickColor = BrickColor.new("Dark stone grey")
    baseRing.Material = Enum.Material.Metal
    baseRing.Shape = Enum.PartType.Cylinder
    baseRing.Parent = bars
    
    -- Dikey parmaklıklar (8 adet)
    local barCount = 8
    local radius = 6
    
    for i = 1, barCount do
        local angle = (i - 1) * (360 / barCount)
        local x = math.cos(math.rad(angle)) * radius
        local z = math.sin(math.rad(angle)) * radius
        
        local bar = Instance.new("Part")
        bar.Name = "Bar_" .. i
        bar.Size = Vector3.new(0.5, 8, 0.5)
        bar.Position = Vector3.new(pos.X + x, pos.Y + 1, pos.Z + z)
        bar.Anchored = true
        bar.BrickColor = BrickColor.new("Dark stone grey")
        bar.Material = Enum.Material.Metal
        bar.Parent = bars
        
        -- Üst halka
        local topRing = Instance.new("Part")
        topRing.Name = "TopRing_" .. i
        topRing.Size = Vector3.new(12, 0.3, 12)
        topRing.Position = Vector3.new(pos.X, pos.Y + 5, pos.Z)
        topRing.Anchored = true
        topRing.BrickColor = BrickColor.new("Dark stone grey")
        topRing.Material = Enum.Material.Metal
        topRing.Shape = Enum.PartType.Cylinder
        topRing.Parent = bars
    end
    
    -- Oyuncuyu hapsetme
    local function imprisonCharacter()
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            -- Humanoid'i devre dışı bırak
            local humanoid = targetChar:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
            end
            
            -- RootPart'ı kilitle
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
            bodyVelocity.Parent = rootPart
            
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
            bodyGyro.P = 10000
            bodyGyro.D = 1000
            bodyGyro.Parent = rootPart
            
            -- Pozisyonu sabitle
            rootPart.Anchored = true
        end
    end
    
    -- Hemen hapset
    imprisonCharacter()
    
    -- Karakter değişirse tekrar hapset
    targetChar.ChildAdded:Connect(function(child)
        if child:IsA("Humanoid") then
            wait(0.5)
            imprisonCharacter()
        end
    end)
    
    bars.Parent = workspace
    return bars
end

-- Oyuncuyu hapsetme
local function imprisonPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character then
        -- Önce eski parmaklıkları temizle
        local oldBars = workspace:FindFirstChild("PrisonBars_" .. targetName)
        if oldBars then
            oldBars:Destroy()
        end
        
        -- Yeni parmaklık oluştur
        local bars = createBars(targetPlayer.Character)
        
        if bars then
            -- Hapishane verilerini kaydet
            if not workspace:FindFirstChild("PrisonData") then
                local prisonData = Instance.new("Folder")
                prisonData.Name = "PrisonData"
                prisonData.Parent = workspace
            end
            
            bars.Parent = workspace.PrisonData
            
            print("✅ " .. targetName .. " parmaklıklarla hapsedildi!")
        end
    else
        print("❌ Oyuncu bulunamadı!")
    end
end

-- Oyuncuyu serbest bırakma
local function freePlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    
    -- Parmaklıkları kaldır
    local bars = workspace.PrisonData:FindFirstChild("PrisonBars_" .. targetName)
    if bars then
        bars:Destroy()
    end
    
    -- Oyuncunun hareketini geri ver
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
    end
    
    print("✅ " .. targetName .. " serbest bırakıldı!")
end

-- Oyuncu listesini doldur
local function updatePlayerList()
    playerList:ClearAllChildren()
    
    local yOffset = 0
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, 0, 0, 50)
            playerFrame.Position = UDim2.new(0, 0, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            playerFrame.BorderSizePixel = 1
            playerFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
            playerFrame.Parent = playerList
            
            local playerIcon = Instance.new("TextLabel")
            playerIcon.Size = UDim2.new(0, 40, 1, 0)
            playerIcon.Position = UDim2.new(0, 5, 0, 0)
            playerIcon.BackgroundTransparency = 1
            playerIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerIcon.Text = "👤"
            playerIcon.TextSize = 20
            playerIcon.Font = Enum.Font.GothamBold
            playerIcon.Parent = playerFrame
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0.6, -45, 1, 0)
            playerName.Position = UDim2.new(0, 45, 0, 0)
            playerName.BackgroundTransparency = 1
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.Text = otherPlayer.Name
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 14
            playerName.Parent = playerFrame
            
            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(0.3, -5, 0.7, 0)
            selectBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
            selectBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectBtn.Text = "SEÇ"
            selectBtn.Font = Enum.Font.GothamBold
            selectBtn.TextSize = 12
            selectBtn.Parent = playerFrame
            
            selectBtn.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer.Name
                imprisonBtn.Text = "🚨 " .. otherPlayer.Name .. " HAPSED 🚨"
                freeBtn.Text = "🔓 " .. otherPlayer.Name .. " SERBEST BIRAK"
                
                -- Seçili frame'i vurgula
                for _, frame in pairs(playerList:GetChildren()) do
                    if frame:IsA("Frame") then
                        frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end
                end
                playerFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
            end)
            
            yOffset = yOffset + 55
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Buton eventleri
imprisonBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        imprisonPlayer(selectedPlayer)
    else
        print("❌ Lütfen önce bir oyuncu seçin!")
    end
end)

freeBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        freePlayer(selectedPlayer)
    else
        print("❌ Lütfen önce bir oyuncu seçin!")
    end
end)

-- Oyuncu listesini güncelle
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- PrisonData klasörünü oluştur
if not workspace:FindFirstChild("PrisonData") then
    local prisonData = Instance.new("Folder")
    prisonData.Name = "PrisonData"
    prisonData.Parent = workspace
end

-- Başlangıç mesajı
print("🎯 GELİŞMİŞ HAPİSHANE SİSTEMİ YÜKLENDİ!")
print("📝 F tuşuna basarak GUI'yi aç/kapat")
print("👤 Oyuncu seç ve HAPSET butonuna tıkla!")
print("🔒 Hapsedilen oyuncu hareket edemez!")

-- Tüm oyuncuları kontrol et (zaten hapsedilmiş olanlar için)
spawn(function()
    wait(3)
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local bars = workspace.PrisonData:FindFirstChild("PrisonBars_" .. otherPlayer.Name)
            if bars then
                print("ℹ️ " .. otherPlayer.Name .. " zaten hapiste!")
            end
        end
    end
end)
