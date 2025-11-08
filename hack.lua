-- Bu scripti executor ile çalıştır, her şeyi otomatik kuracak
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
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "🎯 HAPİSHANE SİSTEMİ 🎯"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Oyuncu listesi
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -20, 0.7, -60)
playerList.Position = UDim2.new(0, 10, 0, 50)
playerList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 8
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = mainFrame

-- Seçilen oyuncu
local selectedPlayer = nil

-- Hapset butonu
local imprisonBtn = Instance.new("TextButton")
imprisonBtn.Size = UDim2.new(1, -20, 0, 40)
imprisonBtn.Position = UDim2.new(0, 10, 0.85, 0)
imprisonBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
imprisonBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
imprisonBtn.Text = "🚨 HAPSED 🚨"
imprisonBtn.Font = Enum.Font.GothamBold
imprisonBtn.TextSize = 16
imprisonBtn.Parent = mainFrame

-- Serbest bırak butonu
local freeBtn = Instance.new("TextButton")
freeBtn.Size = UDim2.new(1, -20, 0, 40)
freeBtn.Position = UDim2.new(0, 10, 0.75, 0)
freeBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
freeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freeBtn.Text = "🔓 SERBEST BIRAK"
freeBtn.Font = Enum.Font.GothamBold
freeBtn.TextSize = 16
freeBtn.Parent = mainFrame

-- Kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(1, -20, 0, 30)
closeBtn.Position = UDim2.new(0, 10, 0.93, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "❌ KAPAT"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame

-- GUI'yi açmak için tuş (F tuşu)
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Hapishane oluşturma fonksiyonu
local function createPrison(targetChar)
    if not targetChar then return end
    
    local prison = Instance.new("Model")
    prison.Name = "Prison_" .. targetChar.Name
    
    local pos = targetChar.HumanoidRootPart.Position
    
    -- Zemin
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(15, 1, 15)
    floor.Position = Vector3.new(pos.X, pos.Y - 3, pos.Z)
    floor.Anchored = true
    floor.BrickColor = BrickColor.new("Dark stone grey")
    floor.Material = Enum.Material.Concrete
    floor.Parent = prison
    
    -- Duvarlar
    local wall1 = Instance.new("Part")
    wall1.Size = Vector3.new(15, 8, 1)
    wall1.Position = Vector3.new(pos.X, pos.Y + 1, pos.Z + 7.5)
    wall1.Anchored = true
    wall1.BrickColor = BrickColor.new("Really black")
    wall1.Material = Enum.Material.Metal
    wall1.Parent = prison
    
    local wall2 = Instance.new("Part")
    wall2.Size = Vector3.new(15, 8, 1)
    wall2.Position = Vector3.new(pos.X, pos.Y + 1, pos.Z - 7.5)
    wall2.Anchored = true
    wall2.BrickColor = BrickColor.new("Really black")
    wall2.Material = Enum.Material.Metal
    wall2.Parent = prison
    
    local wall3 = Instance.new("Part")
    wall3.Size = Vector3.new(1, 8, 15)
    wall3.Position = Vector3.new(pos.X + 7.5, pos.Y + 1, pos.Z)
    wall3.Anchored = true
    wall3.BrickColor = BrickColor.new("Really black")
    wall3.Material = Enum.Material.Metal
    wall3.Parent = prison
    
    local wall4 = Instance.new("Part")
    wall4.Size = Vector3.new(1, 8, 15)
    wall4.Position = Vector3.new(pos.X - 7.5, pos.Y + 1, pos.Z)
    wall4.Anchored = true
    wall4.BrickColor = BrickColor.new("Really black")
    wall4.Material = Enum.Material.Metal
    wall4.Parent = prison
    
    -- Tavan
    local ceiling = Instance.new("Part")
    ceiling.Size = Vector3.new(15, 1, 15)
    ceiling.Position = Vector3.new(pos.X, pos.Y + 5, pos.Z)
    ceiling.Anchored = true
    ceiling.BrickColor = BrickColor.new("Dark stone grey")
    ceiling.Material = Enum.Material.Concrete
    ceiling.Parent = prison
    
    prison.Parent = workspace
    
    return prison
end

-- Oyuncuyu hapsetme
local function imprisonPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character then
        local prison = createPrison(targetPlayer.Character)
        
        -- Oyuncuyu hapishaneye ışınla
        targetPlayer.Character.HumanoidRootPart.Position = prison:FindFirstChildOfClass("Part").Position + Vector3.new(0, 3, 0)
        
        -- Hapishaneyi kaydet
        if not workspace:FindFirstChild("PrisonData") then
            local prisonData = Instance.new("Folder")
            prisonData.Name = "PrisonData"
            prisonData.Parent = workspace
        end
        
        prison.Parent = workspace.PrisonData
        
        print("✅ " .. targetName .. " hapsedildi!")
    else
        print("❌ Oyuncu bulunamadı!")
    end
end

-- Oyuncuyu serbest bırakma
local function freePlayer(targetName)
    local prison = workspace.PrisonData:FindFirstChild("Prison_" .. targetName)
    if prison then
        prison:Destroy()
        print("✅ " .. targetName .. " serbest bırakıldı!")
    else
        print("❌ Hapishane bulunamadı!")
    end
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
            playerFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            playerFrame.BorderSizePixel = 0
            playerFrame.Parent = playerList
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0.7, 0, 1, 0)
            playerName.Position = UDim2.new(0, 5, 0, 0)
            playerName.BackgroundTransparency = 1
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.Text = "👤 " .. otherPlayer.Name
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 14
            playerName.Parent = playerFrame
            
            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(0.25, -5, 0.7, 0)
            selectBtn.Position = UDim2.new(0.75, 0, 0.15, 0)
            selectBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectBtn.Text = "Seç"
            selectBtn.Font = Enum.Font.Gotham
            selectBtn.TextSize = 12
            selectBtn.Parent = playerFrame
            
            selectBtn.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer.Name
                imprisonBtn.Text = "🚨 " .. otherPlayer.Name .. " HAPSED 🚨"
                freeBtn.Text = "🔓 " .. otherPlayer.Name .. " SERBEST BIRAK"
            end)
            
            yOffset = yOffset + 45
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

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Oyuncu listesini güncelle
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Başlangıç mesajı
print("🎯 Hapishane Sistemi Yüklendi!")
print("📝 F tuşuna basarak GUI'yi aç/kapat")
print("👤 Oyuncu seç ve HAPSET butonuna tıkla!")

-- PrisonData klasörünü oluştur
if not workspace:FindFirstChild("PrisonData") then
    local prisonData = Instance.new("Folder")
    prisonData.Name = "PrisonData"
    prisonData.Parent = workspace
end
