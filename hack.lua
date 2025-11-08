-- Bu scripti executor ile çalıştır, her şey otomatik kurulsun
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvent'leri oluştur
local freezeEvent = Instance.new("RemoteEvent")
freezeEvent.Name = "FreezePlayer"
freezeEvent.Parent = ReplicatedStorage

local kickEvent = Instance.new("RemoteEvent")
kickEvent.Name = "KickPlayer"
kickEvent.Parent = ReplicatedStorage

-- GUI'yi temizle (varsa)
if playerGui:FindFirstChild("TrollerMenu") then
    playerGui.TrollerMenu:Destroy()
end

-- Ana GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrollerMenu"
screenGui.Parent = playerGui

-- Sol tarafta Troller butonu
local trollBtn = Instance.new("TextButton")
trollBtn.Size = UDim2.new(0, 100, 0, 50)
trollBtn.Position = UDim2.new(0, 10, 0.5, -25)
trollBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
trollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
trollBtn.Text = "🎮 TROLLER 🎮"
trollBtn.Font = Enum.Font.GothamBold
trollBtn.TextSize = 14
trollBtn.BorderSizePixel = 2
trollBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
trollBtn.Parent = screenGui

-- Sağ tarafta ana menü (başlangıçta gizli)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 550)
mainFrame.Position = UDim2.new(1, -470, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "🎮 TROLLER MENÜSÜ 🎮"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

-- Sekmeler
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, 0, 0, 40)
tabsFrame.Position = UDim2.new(0, 0, 0, 50)
tabsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = mainFrame

-- Donutma sekmesi
local freezeTab = Instance.new("TextButton")
freezeTab.Size = UDim2.new(0.5, 0, 1, 0)
freezeTab.Position = UDim2.new(0, 0, 0, 0)
freezeTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
freezeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
freezeTab.Text = "❄️ DONUTMA"
freezeTab.Font = Enum.Font.GothamBold
freezeTab.TextSize = 14
freezeTab.Parent = tabsFrame

-- Oyundan atma sekmesi
local kickTab = Instance.new("TextButton")
kickTab.Size = UDim2.new(0.5, 0, 1, 0)
kickTab.Position = UDim2.new(0.5, 0, 0, 0)
kickTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
kickTab.TextColor3 = Color3.fromRGB(255, 255, 255)
kickTab.Text = "🚪 OYUNDAN ATMA"
kickTab.Font = Enum.Font.GothamBold
kickTab.TextSize = 14
kickTab.Parent = tabsFrame

-- İçerik alanı
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -90)
contentFrame.Position = UDim2.new(0, 0, 0, 90)
contentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

-- Donutma içeriği
local freezeContent = Instance.new("ScrollingFrame")
freezeContent.Size = UDim2.new(1, 0, 1, 0)
freezeContent.Position = UDim2.new(0, 0, 0, 0)
freezeContent.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
freezeContent.BorderSizePixel = 0
freezeContent.ScrollBarThickness = 8
freezeContent.CanvasSize = UDim2.new(0, 0, 0, 0)
freezeContent.Visible = true
freezeContent.Parent = contentFrame

-- Oyundan atma içeriği
local kickContent = Instance.new("ScrollingFrame")
kickContent.Size = UDim2.new(1, 0, 1, 0)
kickContent.Position = UDim2.new(0, 0, 0, 0)
kickContent.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
kickContent.BorderSizePixel = 0
kickContent.ScrollBarThickness = 8
kickContent.CanvasSize = UDim2.new(0, 0, 0, 0)
kickContent.Visible = false
kickContent.Parent = contentFrame

-- Değişkenler
local selectedPlayer = nil
local frozenPlayers = {}

-- Troller butonu event
trollBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Kapat butonu event
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Sekme değiştirme
freezeTab.MouseButton1Click:Connect(function()
    freezeContent.Visible = true
    kickContent.Visible = false
    freezeTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    kickTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

kickTab.MouseButton1Click:Connect(function()
    freezeContent.Visible = false
    kickContent.Visible = true
    kickTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    freezeTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

-- Oyuncuyu gerçekten dondur (RemoteEvent ile)
local function freezePlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer then
        freezeEvent:FireServer(targetName)
        frozenPlayers[targetName] = true
        print("❄️ " .. targetName .. " donutuldu!")
    end
end

-- Oyuncunun donunu çöz
local function unfreezePlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer then
        freezeEvent:FireServer(targetName, "unfreeze")
        frozenPlayers[targetName] = false
        print("✅ " .. targetName .. " serbest bırakıldı!")
    end
end

-- Oyuncuyu gerçekten oyundan at
local function kickPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer then
        kickEvent:FireServer(targetName)
        print("🚪 " .. targetName .. " oyundan atıldı!")
    end
end

-- Tüm oyuncuları donut
local function freezeAllPlayers()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            freezePlayer(otherPlayer.Name)
        end
    end
    print("❄️ Tüm oyuncular donutuldu!")
end

-- Tüm oyuncuların donunu çöz
local function unfreezeAllPlayers()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            unfreezePlayer(otherPlayer.Name)
        end
    end
    print("✅ Tüm oyuncular serbest bırakıldı!")
end

-- Tüm oyuncuları at
local function kickAllPlayers()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            kickPlayer(otherPlayer.Name)
        end
    end
    print("🚪 Tüm oyuncular atıldı!")
end

-- Donutma içeriğini oluştur
local function createFreezeContent()
    freezeContent:ClearAllChildren()
    
    local yOffset = 0
    
    -- Oyuncu listesi
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, -20, 0, 50)
            playerFrame.Position = UDim2.new(0, 10, 0, yOffset)
            playerFrame.BackgroundColor3 = frozenPlayers[otherPlayer.Name] and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(60, 60, 60)
            playerFrame.BorderSizePixel = 1
            playerFrame.Parent = freezeContent
            
            local playerIcon = Instance.new("TextLabel")
            playerIcon.Size = UDim2.new(0, 40, 1, 0)
            playerIcon.Position = UDim2.new(0, 5, 0, 0)
            playerIcon.BackgroundTransparency = 1
            playerIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerIcon.Text = frozenPlayers[otherPlayer.Name] and "❄️" or "👤"
            playerIcon.TextSize = 20
            playerIcon.Font = Enum.Font.GothamBold
            playerIcon.Parent = playerFrame
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0.4, -45, 1, 0)
            playerName.Position = UDim2.new(0, 45, 0, 0)
            playerName.BackgroundTransparency = 1
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.Text = otherPlayer.Name
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 14
            playerName.Parent = playerFrame
            
            local freezeBtn = Instance.new("TextButton")
            freezeBtn.Size = UDim2.new(0.25, -5, 0.7, 0)
            freezeBtn.Position = UDim2.new(0.4, 5, 0.15, 0)
            freezeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            freezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            freezeBtn.Text = "DONDUR"
            freezeBtn.Font = Enum.Font.GothamBold
            freezeBtn.TextSize = 12
            freezeBtn.Parent = playerFrame
            
            local unfreezeBtn = Instance.new("TextButton")
            unfreezeBtn.Size = UDim2.new(0.25, -5, 0.7, 0)
            unfreezeBtn.Position = UDim2.new(0.65, 5, 0.15, 0)
            unfreezeBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            unfreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            unfreezeBtn.Text = "ÇÖZ"
            unfreezeBtn.Font = Enum.Font.GothamBold
            unfreezeBtn.TextSize = 12
            unfreezeBtn.Parent = playerFrame
            
            freezeBtn.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer.Name
                freezePlayer(otherPlayer.Name)
                wait(0.1)
                createFreezeContent()
            end)
            
            unfreezeBtn.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer.Name
                unfreezePlayer(otherPlayer.Name)
                wait(0.1)
                createFreezeContent()
            end)
            
            yOffset = yOffset + 55
        end
    end
    
    -- Tümünü dondur/çöz butonları
    local allFrame = Instance.new("Frame")
    allFrame.Size = UDim2.new(1, -20, 0, 90)
    allFrame.Position = UDim2.new(0, 10, 0, yOffset)
    allFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    allFrame.BorderSizePixel = 1
    allFrame.Parent = freezeContent
    
    local freezeAllBtn = Instance.new("TextButton")
    freezeAllBtn.Size = UDim2.new(0.9, 0, 0, 35)
    freezeAllBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    freezeAllBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    freezeAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeAllBtn.Text = "❄️ TÜMÜNÜ DONDUR ❄️"
    freezeAllBtn.Font = Enum.Font.GothamBold
    freezeAllBtn.TextSize = 14
    freezeAllBtn.Parent = allFrame
    
    local unfreezeAllBtn = Instance.new("TextButton")
    unfreezeAllBtn.Size = UDim2.new(0.9, 0, 0, 35)
    unfreezeAllBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
    unfreezeAllBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    unfreezeAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unfreezeAllBtn.Text = "✅ TÜMÜNÜ ÇÖZ ✅"
    unfreezeAllBtn.Font = Enum.Font.GothamBold
    unfreezeAllBtn.TextSize = 14
    unfreezeAllBtn.Parent = allFrame
    
    freezeAllBtn.MouseButton1Click:Connect(function()
        freezeAllPlayers()
        wait(0.1)
        createFreezeContent()
    end)
    
    unfreezeAllBtn.MouseButton1Click:Connect(function()
        unfreezeAllPlayers()
        wait(0.1)
        createFreezeContent()
    end)
    
    freezeContent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 100)
end

-- Oyundan atma içeriğini oluştur
local function createKickContent()
    kickContent:ClearAllChildren()
    
    local yOffset = 0
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, -20, 0, 50)
            playerFrame.Position = UDim2.new(0, 10, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            playerFrame.BorderSizePixel = 1
            playerFrame.Parent = kickContent
            
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
            playerName.Size = UDim2.new(0.5, -45, 1, 0)
            playerName.Position = UDim2.new(0, 45, 0, 0)
            playerName.BackgroundTransparency = 1
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.Text = otherPlayer.Name
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 14
            playerName.Parent = playerFrame
            
            local kickBtn = Instance.new("TextButton")
            kickBtn.Size = UDim2.new(0.35, -5, 0.7, 0)
            kickBtn.Position = UDim2.new(0.5, 5, 0.15, 0)
            kickBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            kickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            kickBtn.Text = "🚪 OYUNDAN AT"
            kickBtn.Font = Enum.Font.GothamBold
            kickBtn.TextSize = 12
            kickBtn.Parent = playerFrame
            
            kickBtn.MouseButton1Click:Connect(function()
                selectedPlayer = otherPlayer.Name
                kickPlayer(otherPlayer.Name)
            end)
            
            yOffset = yOffset + 55
        end
    end
    
    -- Tümünü at butonu
    local kickAllFrame = Instance.new("Frame")
    kickAllFrame.Size = UDim2.new(1, -20, 0, 60)
    kickAllFrame.Position = UDim2.new(0, 10, 0, yOffset)
    kickAllFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    kickAllFrame.BorderSizePixel = 1
    kickAllFrame.Parent = kickContent
    
    local kickAllBtn = Instance.new("TextButton")
    kickAllBtn.Size = UDim2.new(0.9, 0, 0, 40)
    kickAllBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    kickAllBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    kickAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    kickAllBtn.Text = "🚪 TÜMÜNÜ AT 🚪"
    kickAllBtn.Font = Enum.Font.GothamBold
    kickAllBtn.TextSize = 16
    kickAllBtn.Parent = kickAllFrame
    
    kickAllBtn.MouseButton1Click:Connect(kickAllPlayers)
    
    kickContent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 70)
end

-- İçerikleri oluştur
createFreezeContent()
createKickContent()

-- Oyuncu değişikliklerini takip et
Players.PlayerAdded:Connect(function()
    wait(0.5)
    createFreezeContent()
    createKickContent()
end)

Players.PlayerRemoving:Connect(function()
    wait(0.1)
    createFreezeContent()
    createKickContent()
end)

-- Sunucu scriptini otomatik ekle (exploit ile)
local function createServerScript()
    local source = [[
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        local freezeEvent = ReplicatedStorage:WaitForChild("FreezePlayer")
        local kickEvent = ReplicatedStorage:WaitForChild("KickPlayer")
        
        freezeEvent.OnServerEvent:Connect(function(player, targetName, action)
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer and targetPlayer.Character then
                local char = targetPlayer.Character
                local humanoid = char:FindFirstChild("Humanoid")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                
                if action == "unfreeze" then
                    -- Donu çöz
                    if humanoid then
                        humanoid.WalkSpeed = 16
                        humanoid.JumpPower = 50
                    end
                    if rootPart then
                        rootPart.Anchored = false
                        for _, obj in pairs(rootPart:GetChildren()) do
                            if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                                obj:Destroy()
                            end
                        end
                    end
                else
                    -- Dondur
                    if humanoid then
                        humanoid.WalkSpeed = 0
                        humanoid.JumpPower = 0
                    end
                    if rootPart then
                        rootPart.Anchored = true
                        for _, obj in pairs(rootPart:GetChildren()) do
                            if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                                obj:Destroy()
                            end
                        end
                        
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
                end
            end
        end)
        
        kickEvent.OnServerEvent:Connect(function(player, targetName)
            local targetPlayer = Players:FindFirstChild(targetName)
            if targetPlayer then
                targetPlayer:Kick("Troller menüsü ile atıldınız! 😈")
            end
        end)
    ]]
    
    -- ServerScriptService'e script ekle
    local serverScript = Instance.new("Script")
    serverScript.Source = source
    serverScript.Parent = game:GetService("ServerScriptService")
end

-- Sunucu scriptini oluştur
spawn(createServerScript)

-- Başlangıç mesajı
print("🎮 TROLLER MENÜSÜ YÜKLENDİ!")
print("📝 Sol taraftaki TROLLER butonuna tıkla!")
print("❄️ Gerçek donutma ve 🚪 oyundan atma aktif!")
print("⚠️ Sunucu scripti otomatik eklendi!")
