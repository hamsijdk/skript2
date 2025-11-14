-- Basit ve Etkili Hapis Sistemi (LocalScript)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI Oluştur
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrisonSystem"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 100, 150)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 330, 0, 40)
TitleLabel.Position = UDim2.new(0, 10, 0, 10)
TitleLabel.Text = "🔒 HAPİS KONTROL"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0, 330, 0, 400)
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- Hapis verileri
local prisonData = {
    imprisonedPlayers = {},
    prisonCells = {}
}

-- Hücre oluştur
function createPrisonCell(targetPlayer)
    local character = targetPlayer.Character
    if not character then return nil end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return nil end
    
    local cell = Instance.new("Model")
    cell.Name = "PrisonCell_" .. targetPlayer.Name
    
    -- Hücre pozisyonu
    local cellPosition = humanoidRootPart.Position + Vector3.new(0, 5, 0)
    
    -- Zemin
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(15, 1, 15)
    floor.Position = Vector3.new(cellPosition.X, cellPosition.Y - 4, cellPosition.Z)
    floor.Anchored = true
    floor.CanCollide = true
    floor.Material = Enum.ConcreteMaterial
    floor.BrickColor = BrickColor.new("Dark stone grey")
    floor.Name = "Floor"
    floor.Parent = cell
    
    -- Duvarlar
    local wallHeight = 12
    local walls = {
        {position = Vector3.new(7.5, wallHeight/2 - 2, 0), size = Vector3.new(1, wallHeight, 15)},
        {position = Vector3.new(-7.5, wallHeight/2 - 2, 0), size = Vector3.new(1, wallHeight, 15)},
        {position = Vector3.new(0, wallHeight/2 - 2, 7.5), size = Vector3.new(15, wallHeight, 1)},
        {position = Vector3.new(0, wallHeight/2 - 2, -7.5), size = Vector3.new(15, wallHeight, 1)}
    }
    
    for i, wall in ipairs(walls) do
        local wallPart = Instance.new("Part")
        wallPart.Size = wall.size
        wallPart.Position = cellPosition + wall.position
        wallPart.Anchored = true
        wallPart.CanCollide = true
        wallPart.Material = Enum.MetalMaterial
        wallPart.BrickColor = BrickColor.new("Dark grey")
        wallPart.Name = "Wall_" .. i
        wallPart.Parent = cell
    end
    
    -- Tavan
    local ceiling = Instance.new("Part")
    ceiling.Size = Vector3.new(15, 1, 15)
    ceiling.Position = Vector3.new(cellPosition.X, cellPosition.Y + wallHeight - 2, cellPosition.Z)
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
function imprisonPlayer(targetPlayer)
    if prisonData.imprisonedPlayers[targetPlayer] then
        return false
    end
    
    local cell = createPrisonCell(targetPlayer)
    if not cell then return false end
    
    prisonData.imprisonedPlayers[targetPlayer] = true
    prisonData.prisonCells[targetPlayer] = cell
    
    -- Kaçış önleme
    startEscapePrevention(targetPlayer, cell)
    
    return true
end

-- Oyuncuyu serbest bırak
function releasePlayer(targetPlayer)
    if not prisonData.imprisonedPlayers[targetPlayer] then
        return false
    end
    
    local cell = prisonData.prisonCells[targetPlayer]
    if cell and cell.Parent then
        cell:Destroy()
    end
    
    prisonData.imprisonedPlayers[targetPlayer] = nil
    prisonData.prisonCells[targetPlayer] = nil
    
    return true
end

-- Kaçış önleme sistemi
function startEscapePrevention(targetPlayer, cell)
    spawn(function()
        while prisonData.imprisonedPlayers[targetPlayer] and cell and cell.Parent do
            wait(0.1)
            
            local character = targetPlayer.Character
            if not character then continue end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then continue end
            
            local cellCenter = cell:GetPivot().Position
            local playerPos = humanoidRootPart.Position
            
            -- Hücre dışına çıkmışsa geri ışınla
            if (playerPos - cellCenter).Magnitude > 8 then
                humanoidRootPart.CFrame = CFrame.new(cellCenter + Vector3.new(0, 3, 0))
            end
        end
    end)
end

-- GUI'yi güncelle
function updateGUI()
    ScrollFrame:ClearAllChildren()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(0, 310, 0, 80)
            playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            playerFrame.Parent = ScrollFrame
            
            local frameCorner = Instance.new("UICorner")
            frameCorner.CornerRadius = UDim.new(0, 8)
            frameCorner.Parent = playerFrame
            
            local playerName = Instance.new("TextLabel")
            playerName.Size = UDim2.new(0, 200, 0, 30)
            playerName.Position = UDim2.new(0, 10, 0, 10)
            playerName.Text = "👤 " .. player.Name
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.BackgroundTransparency = 1
            playerName.Font = Enum.Font.GothamBold
            playerName.TextSize = 16
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Parent = playerFrame
            
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0, 200, 0, 20)
            statusLabel.Position = UDim2.new(0, 10, 0, 40)
            statusLabel.Text = prisonData.imprisonedPlayers[player] and "🔒 HAPİSTE" or "🟢 SERBEST"
            statusLabel.TextColor3 = prisonData.imprisonedPlayers[player] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Font = Enum.Font.Gotham
            statusLabel.TextSize = 14
            statusLabel.TextXAlignment = Enum.TextXAlignment.Left
            statusLabel.Parent = playerFrame
            
            local imprisonButton = Instance.new("TextButton")
            imprisonButton.Size = UDim2.new(0, 80, 0, 30)
            imprisonButton.Position = UDim2.new(0, 220, 0, 10)
            imprisonButton.Text = "HAPSED"
            imprisonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            imprisonButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            imprisonButton.Font = Enum.Font.GothamBold
            imprisonButton.TextSize = 12
            imprisonButton.Parent = playerFrame
            
            local releaseButton = Instance.new("TextButton")
            releaseButton.Size = UDim2.new(0, 80, 0, 30)
            releaseButton.Position = UDim2.new(0, 220, 0, 45)
            releaseButton.Text = "SERBEST"
            releaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            releaseButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
            releaseButton.Font = Enum.Font.GothamBold
            releaseButton.TextSize = 12
            releaseButton.Parent = playerFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = imprisonButton
            buttonCorner:Clone().Parent = releaseButton
            
            -- Buton eventleri
            imprisonButton.MouseButton1Click:Connect(function()
                imprisonPlayer(player)
                updateGUI()
            end)
            
            releaseButton.MouseButton1Click:Connect(function()
                releasePlayer(player)
                updateGUI()
            end)
        end
    end
    
    -- Scroll frame boyutunu ayarla
    wait()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- F tuşu kontrolü
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            updateGUI()
        end
    end
end)

-- Oyuncu değişikliklerini dinle
Players.PlayerAdded:Connect(updateGUI)
Players.PlayerRemoving:Connect(updateGUI)

print("✅ Hapis Sistemi Aktif!")
print("🎮 F tuşuna basarak menüyü aç")
print("🔒 Oyuncuları hapsedebilirsin!")
