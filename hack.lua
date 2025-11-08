-- Otomatik Her Şeyi Yapan Script
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- GUI ve sistem değişkenleri
local gui
local teleportActive = false
local selectedPlayer = nil
local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false

-- Otomatik GUI oluştur
local function createAutoGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Eski GUI'yi temizle
    if playerGui:FindFirstChild("AutoSystemGUI") then
        playerGui.AutoSystemGUI:Destroy()
    end

    -- Ana GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoSystemGUI"
    screenGui.Enabled = false
    screenGui.Parent = playerGui

    -- Ana Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    -- Gölge efekti
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(100, 100, 255)
    shadow.Thickness = 3
    shadow.Parent = mainFrame

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
    title.Text = "🚀 OTOMATİK HER ŞEY SİSTEMİ"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = title

    -- Kapatma butonu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Oyuncu listesi
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(1, -20, 0, 150)
    playerListFrame.Position = UDim2.new(0, 10, 0, 60)
    playerListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    playerListFrame.BorderSizePixel = 0
    playerListFrame.Parent = mainFrame

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = playerListFrame

    local playerListLabel = Instance.new("TextLabel")
    playerListLabel.Size = UDim2.new(1, 0, 0, 30)
    playerListLabel.Position = UDim2.new(0, 0, 0, 0)
    playerListLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
    playerListLabel.Text = "🎯 HEDEF OYUNCULAR"
    playerListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerListLabel.TextSize = 14
    playerListLabel.Font = Enum.Font.GothamBold
    playerListLabel.Parent = playerListFrame

    local playerList = Instance.new("ScrollingFrame")
    playerList.Size = UDim2.new(1, 0, 1, -30)
    playerList.Position = UDim2.new(0, 0, 0, 30)
    playerList.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 5
    playerList.Parent = playerListFrame

    -- Butonlar container
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -20, 0, 250)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 220)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame

    -- Işınlanma butonu
    local teleportBtn = createButton("🚀 UZAYA IŞINLA", Color3.fromRGB(255, 100, 100), 0, 0)
    teleportBtn.Parent = buttonsFrame

    -- Uçma butonu
    local flyBtn = createButton("🕊️ UÇMA AÇ/KAPA", Color3.fromRGB(100, 200, 255), 0, 50)
    flyBtn.Parent = buttonsFrame

    -- Noclip butonu
    local noclipBtn = createButton("👻 NOCLIP AÇ/KAPA", Color3.fromRGB(150, 100, 255), 0, 100)
    noclipBtn.Parent = buttonsFrame

    -- Hız butonu
    local speedBtn = createButton("⚡ SÜPER HIZ", Color3.fromRGB(100, 255, 150), 0, 150)
    speedBtn.Parent = buttonsFrame

    -- Tümünü seç butonu
    local selectAllBtn = createButton("✅ TÜMÜNÜ SEÇ", Color3.fromRGB(255, 200, 100), 0, 200)
    selectAllBtn.Parent = buttonsFrame

    -- Durum göstergesi
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 1, -40)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    statusLabel.Text = "🔴 SİSTEM HAZIR - INSERT TUŞU"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusLabel

    return screenGui, playerList, teleportBtn, flyBtn, noclipBtn, speedBtn, selectAllBtn, closeBtn, statusLabel
end

-- Buton oluşturma fonksiyonu
local function createButton(text, color, x, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, x, 0, y)
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    return button
end

-- Oyuncu listesini güncelle
local function updatePlayerList(playerList)
    playerList:ClearAllChildren()
    
    local players = Players:GetPlayers()
    local yOffset = 0
    
    for i, plr in ipairs(players) do
        if plr ~= player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1, -10, 0, 30)
            playerFrame.Position = UDim2.new(0, 5, 0, yOffset)
            playerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            playerFrame.Parent = playerList
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = playerFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.Parent = playerFrame
            
            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
            selectBtn.Position = UDim2.new(0.73, 0, 0.15, 0)
            selectBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
            selectBtn.Text = "SEÇ"
            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            selectBtn.TextSize = 10
            selectBtn.Font = Enum.Font.GothamBold
            selectBtn.Parent = playerFrame
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = selectBtn
            
            selectBtn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                updateStatus("✅ HEDEF: " .. plr.Name)
            end)
            
            yOffset = yOffset + 35
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Durum güncelleme
local function updateStatus(text)
    if statusLabel then
        statusLabel.Text = text
    end
end

-- Uzaya ışınlama fonksiyonu
local function teleportToSpace(targetPlayer)
    if not targetPlayer then
        updateStatus("❌ HEDEF SEÇİLMEDİ!")
        return
    end
    
    local character = targetPlayer.Character
    if not character then
        updateStatus("❌ HEDEF KARAKTER YOK!")
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then
        updateStatus("❌ KARAKTER HAZIR DEĞİL!")
        return
    end
    
    -- Işınlanma efekti
    createTeleportEffect(hrp.Position)
    
    -- Uzaya ışınla (çok yükseğe)
    hrp.CFrame = CFrame.new(0, 10000, 0)
    
    -- Yukarı doğru fırlat
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 500, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = hrp
    
    -- Süper güçler ver
    humanoid.WalkSpeed = 100
    humanoid.JumpPower = 200
    
    updateStatus("🚀 " .. targetPlayer.Name .. " UZAYA IŞINLANDI!")
    
    -- 5 saniye sonra efektleri kaldır
    wait(5)
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
end

-- Işınlanma efekti
local function createTeleportEffect(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(8, 8, 8)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Bright red")
    part.Transparency = 0.3
    part.Parent = workspace

    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 15
    pointLight.Range = 20
    pointLight.Color = Color3.new(1, 0, 0)
    pointLight.Parent = part

    -- Patlama efekti
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastPressure = 1000
    explosion.BlastRadius = 10
    explosion.Parent = workspace

    -- Yavaşça kaybol
    coroutine.wrap(function()
        for i = 1, 20 do
            if part then
                part.Transparency = part.Transparency + 0.05
                pointLight.Brightness = pointLight.Brightness - 0.5
                wait(0.1)
            end
        end
        if part then
            part:Destroy()
        end
    end)()
end

-- Uçma sistemi
local function toggleFly()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then return end
    
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        -- Uçma etkin
        humanoid.PlatformStand = true
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = hrp
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        bodyGyro.P = 1000
        bodyGyro.D = 100
        bodyGyro.Parent = hrp
        
        updateStatus("🕊️ UÇMA AKTİF - WASD İLE HAREKET ET")
    else
        -- Uçma devre dışı
        humanoid.PlatformStand = false
        
        if hrp:FindFirstChild("FlyVelocity") then
            hrp.FlyVelocity:Destroy()
        end
        if hrp:FindFirstChild("FlyGyro") then
            hrp.FlyGyro:Destroy()
        end
        
        updateStatus("🕊️ UÇMA PASİF")
    end
end

-- Noclip sistemi
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    local character = player.Character
    
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
    
    updateStatus(noclipEnabled and "👻 NOCLIP AKTİF" or "👻 NOCLIP PASİF")
end

-- Hız artışı
local function toggleSpeed()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    speedEnabled = not speedEnabled
    
    if speedEnabled then
        humanoid.WalkSpeed = 100
        updateStatus("⚡ SÜPER HIZ AKTİF")
    else
        humanoid.WalkSpeed = 16
        updateStatus("⚡ NORMAL HIZ")
    end
end

-- Tüm oyuncuları seç
local function selectAllPlayers()
    local players = Players:GetPlayers()
    selectedPlayer = players[1] -- İlk oyuncuyu seç
    if selectedPlayer == player then
        selectedPlayer = players[2] or players[1]
    end
    updateStatus("✅ TÜM OYUNCULAR HAZIR")
end

-- Ana sistem
local function setupAutoSystem()
    gui, playerList, teleportBtn, flyBtn, noclipBtn, speedBtn, selectAllBtn, closeBtn, statusLabel = createAutoGUI()
    
    -- Insert tuşu ile GUI aç/kapa
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Insert then
            gui.Enabled = not gui.Enabled
            if gui.Enabled then
                updatePlayerList(playerList)
                updateStatus("🎯 SİSTEM AKTİF - HEDEF SEÇ")
            end
        end
    end)
    
    -- Buton eventleri
    teleportBtn.MouseButton1Click:Connect(function()
        teleportToSpace(selectedPlayer)
    end)
    
    flyBtn.MouseButton1Click:Connect(function()
        toggleFly()
    end)
    
    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoclip()
    end)
    
    speedBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
    end)
    
    selectAllBtn.MouseButton1Click:Connect(function()
        selectAllPlayers()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)
    
    -- Uçma kontrolü
    RunService.Heartbeat:Connect(function()
        if flyEnabled then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local flyVelocity = hrp and hrp:FindFirstChild("FlyVelocity")
                local flyGyro = hrp and hrp:FindFirstChild("FlyGyro")
                
                if flyVelocity and flyGyro then
                    -- WASD kontrolü
                    local camera = workspace.CurrentCamera
                    flyGyro.CFrame = camera.CFrame
                    
                    local direction = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        direction = direction + camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        direction = direction - camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        direction = direction - camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        direction = direction + camera.CFrame.RightVector
                    end
                    
                    flyVelocity.Velocity = direction * 50
                end
            end
        end
    end)
    
    -- Noclip güncelleme
    RunService.Stepped:Connect(function()
        if noclipEnabled then
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    
    print("🎯 OTOMATİK SİSTEM YÜKLENDİ!")
    print("🎮 INSERT - GUI Aç/Kapa")
    print("🎮 Hedef seç ve butonlarla kontrol et!")
end

-- Sistemi başlat
wait(2)
setupAutoSystem()
