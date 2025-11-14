-- Gerçek Hapis Sistemi - Server Side
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Server script olduğunu kontrol et
if RunService:IsClient() then
    error("Bu script Server'da çalıştırılmalı!")
    return
end

-- GUI'yi client'a gönder
local function createPrisonGUI(player)
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PrisonControl"
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 150)
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 280, 0, 40)
    TitleLabel.Position = UDim2.new(0, 10, 0, 10)
    TitleLabel.Text = "🔒 Hapis Kontrol Paneli"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(0, 280, 0, 300)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame

    return ScreenGui, ScrollFrame
end

-- Global hapis verisi
local prisonData = {
    imprisonedPlayers = {},
    prisonCells = {}
}

-- Gerçek hapis hücresi oluştur
function createPrisonCell(position)
    local cell = Instance.new("Model")
    cell.Name = "PrisonCell"
    
    -- Hücre zemin
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(20, 2, 20)
    floor.Position = position + Vector3.new(0, -3, 0)
    floor.Anchored = true
    floor.CanCollide = true
    floor.Material = Enum.ConcreteMaterial
    floor.BrickColor = BrickColor.new("Dark stone grey")
    floor.Name = "Floor"
    floor.Parent = cell
    
    -- Duvarlar
    local wallHeight = 15
    local wallThickness = 2
    
    local walls = {
        {pos = Vector3.new(10, wallHeight/2-1.5, 0), size = Vector3.new(wallThickness, wallHeight, 20)}, -- Sağ
        {pos = Vector3.new(-10, wallHeight/2-1.5, 0), size = Vector3.new(wallThickness, wallHeight, 20)}, -- Sol
        {pos = Vector3.new(0, wallHeight/2-1.5, 10), size = Vector3.new(20, wallHeight, wallThickness)}, -- Ön
        {pos = Vector3.new(0, wallHeight/2-1.5, -10), size = Vector3.new(20, wallHeight, wallThickness)} -- Arka
    }
    
    for i, wallData in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Size = wallData.size
        wall.Position = position + wallData.pos
        wall.Anchored = true
        wall.CanCollide = true
        wall.Material = Enum.MetalMaterial
        wall.BrickColor = BrickColor.new("Dark grey")
        wall.Name = "Wall_" .. i
        wall.Parent = cell
        
        -- Görünmez bariyer ekle (güvenlik için)
        local barrier = Instance.new("Part")
        barrier.Size = wallData.size + Vector3.new(0, 5, 0)
        barrier.Position = position + wallData.pos
        barrier.Anchored = true
        barrier.CanCollide = true
        barrier.Transparency = 1
        barrier.Name = "Barrier_" .. i
        barrier.Parent = cell
    end
    
    -- Tavan
    local ceiling = Instance.new("Part")
    ceiling.Size = Vector3.new(20, 2, 20)
    ceiling.Position = position + Vector3.new(0, wallHeight - 1, 0)
    ceiling.Anchored = true
    ceiling.CanCollide = true
    ceiling.Material = Enum.MetalMaterial
    ceiling.BrickColor = BrickColor.new("Dark grey")
    ceiling.Name = "Ceiling"
    ceiling.Parent = cell
    
    cell.Parent = workspace
    return cell
end

-- Oyuncuyu hapse at
function imprisonPlayer(targetPlayer, imprisoner)
    if prisonData.imprisonedPlayers[targetPlayer] then
        return false -- Zaten hapiste
    end
    
    -- Hücre pozisyonu
    local cellPosition = Vector3.new(0, 10, 0) + Vector3.new(
        (math.random() - 0.5) * 100,
        0,
        (math.random() - 0.5) * 100
    )
    
    -- Hücre oluştur
    local cell = createPrisonCell(cellPosition)
    prisonData.prisonCells[targetPlayer] = cell
    
    -- Oyuncuyu hücreye ışınla
    local character = targetPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(cellPosition + Vector3.new(0, 5, 0))
        end
    end
    
    -- Hapis verisini kaydet
    prisonData.imprisonedPlayers[targetPlayer] = {
        cell = cell,
        imprisoner = imprisoner,
        timeImprisoned = os.time()
    }
    
    -- Kaçışı önleme sistemini başlat
    preventEscape(targetPlayer)
    
    return true
end

-- Oyuncuyu serbest bırak
function releasePlayer(targetPlayer)
    local prisonInfo = prisonData.imprisonedPlayers[targetPlayer]
    if not prisonInfo then return false end
    
    -- Hücreyi temizle
    if prisonInfo.cell and prisonInfo.cell.Parent then
        prisonInfo.cell:Destroy()
    end
    
    -- Veriyi temizle
    prisonData.imprisonedPlayers[targetPlayer] = nil
    prisonData.prisonCells[targetPlayer] = nil
    
    return true
end

-- Kaçışı önleme sistemi
function preventEscape(player)
    local escapeCheckConnection
    local characterAddedConnection
    
    local function checkEscape(character)
        if not character then return end
        
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then return end
        
        escapeCheckConnection = RunService.Heartbeat:Connect(function()
            local prisonInfo = prisonData.imprisonedPlayers[player]
            if not prisonInfo or not prisonInfo.cell then
                if escapeCheckConnection then
                    escapeCheckConnection:Disconnect()
                end
                return
            end
            
            local cellPosition = prisonInfo.cell:GetPivot().Position
            local playerPosition = humanoidRootPart.Position
            
            -- Hücre dışına çıkmışsa geri ışınla
            if (playerPosition - cellPosition).Magnitude > 12 then
                humanoidRootPart.CFrame = CFrame.new(cellPosition + Vector3.new(0, 5, 0))
                
                -- Client'a mesaj gönder
                local releaseEvent = Instance.new("RemoteEvent")
                releaseEvent.Name = "PrisonMessage"
                releaseEvent.OnServerEvent:Connect(function() end)
                releaseEvent:FireClient(player, "⚠️ Hücreden kaçamazsın!")
                releaseEvent:Destroy()
            end
        end)
    end
    
    -- Mevcut karakteri kontrol et
    if player.Character then
        checkEscape(player.Character)
    end
    
    -- Yeni karakter spawn olduğunda kontrol et
    characterAddedConnection = player.CharacterAdded:Connect(function(character)
        checkEscape(character)
    end)
    
    -- Temizleme fonksiyonu
    prisonData.imprisonedPlayers[player].cleanup = function()
        if escapeCheckConnection then
            escapeCheckConnection:Disconnect()
        end
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end
    end
end

-- GUI'yi güncelle
function updatePrisonGUI(scrollFrame, imprisoner)
    scrollFrame:ClearAllChildren()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= imprisoner then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(0, 260, 0, 60)
            playerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            playerFrame.Parent = scrollFrame
            
            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = playerFrame
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0, 150, 0, 30)
            playerName.Position = UDim2.new(0, 10, 0, 5)
            playerName.Text = player.Name
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.BackgroundTransparency = 1
            playerName.Font = Enum.Font.Gotham
            playerName.TextSize = 14
            playerName.Parent = playerFrame
            
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0, 150, 0, 20)
            statusLabel.Position = UDim2.new(0, 10, 0, 35)
            statusLabel.Text = prisonData.imprisonedPlayers[player] and "🔒 Hapiste" or "🟢 Serbest"
            statusLabel.TextColor3 = prisonData.imprisonedPlayers[player] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Font = Enum.Font.Gotham
            statusLabel.TextSize = 12
            statusLabel.Parent = playerFrame
            
            local imprisonButton = Instance.new("TextButton")
            imprisonButton.Size = UDim2.new(0, 80, 0, 25)
            imprisonButton.Position = UDim2.new(0, 170, 0, 5)
            imprisonButton.Text = "Hapsed"
            imprisonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            imprisonButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            imprisonButton.Font = Enum.Font.GothamBold
            imprisonButton.TextSize = 12
            imprisonButton.Parent = playerFrame
            
            local releaseButton = Instance.new("TextButton")
            releaseButton.Size = UDim2.new(0, 80, 0, 25)
            releaseButton.Position = UDim2.new(0, 170, 0, 35)
            releaseButton.Text = "Serbest Bırak"
            releaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            releaseButton.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
            releaseButton.Font = Enum.Font.GothamBold
            releaseButton.TextSize = 12
            releaseButton.Parent = playerFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = imprisonButton
            buttonCorner:Clone().Parent = releaseButton
            
            imprisonButton.MouseButton1Click:Connect(function()
                imprisonPlayer(player, imprisoner)
                updatePrisonGUI(scrollFrame, imprisoner)
            end)
            
            releaseButton.MouseButton1Click:Connect(function()
                releasePlayer(player)
                updatePrisonGUI(scrollFrame, imprisoner)
            end)
        end
    end
end

-- Ana sistem
Players.PlayerAdded:Connect(function(player)
    -- Her oyuncu için GUI oluştur
    local screenGui, scrollFrame = createPrisonGUI(player)
    
    -- F tuşu ile GUI aç/kapa
    local guiVisible = false
    
    local function onInput(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            guiVisible = not guiVisible
            screenGui.Enabled = guiVisible
            
            if guiVisible then
                updatePrisonGUI(scrollFrame, player)
            end
        end
    end
    
    -- Input için remote event
    local inputEvent = Instance.new("RemoteEvent")
    inputEvent.Name = "PrisonInput"
    inputEvent.Parent = player:WaitForChild("PlayerGui")
    
    inputEvent.OnServerEvent:Connect(function(plr, keyCode)
        if plr == player then
            onInput({KeyCode = keyCode}, false)
        end
    end)
end)

-- Client input script (LocalScript olarak çalıştırılacak)
local clientInputScript = [[
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    
    local inputEvent = PlayerGui:WaitForChild("PrisonInput")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            inputEvent:FireServer(input.KeyCode)
        end
    end)
]]

print("🔒 Gerçek Hapis Sistemi Aktif!")
print("F tuşu ile kontrol panelini açabilirsin")
print("Her oyuncu gerçekten hapisten çıkamaz!")
