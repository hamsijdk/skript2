-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Debug
local DEBUG = true
local function log(...)
    if DEBUG then
        print("[ÇARPIŞMASIZ-TAKIP]", ...)
    end
end

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Settings
local settings = {
    followDistance = 1.5,
    followHeight = 1.8,
    sideOffset = 0.3,
    shakeIntensity = 0.3,
    shakeSpeed = 15,
    updateRate = 0.01,
    smoothness = 0.3,
    prediction = 0.05,
    lockMode = true,
    groundOffset = 0.5,
    useRaycast = true,
    useShake = true,
    collisionCheck = true,       -- Çarpışma kontrolü
    collisionRadius = 3.0,       -- Çarpışma kontrol mesafesi
    autoAdjustPosition = true,   -- Otomatik pozisyon ayarı
    avoidPlayers = true          -- Diğer oyunculardan kaçın
}

-- State
local selectedPlayer = nil
local isTracking = false
local trackingThread = nil
local timeOffset = 0
local lastTargetPos = Vector3.new(0, 0, 0)
local targetVelocity = Vector3.new(0, 0, 0)
local lastUpdate = tick()
local collisionParts = {}

-- ============================================
-- ÇARPIŞMA ÖNLEME SİSTEMİ
-- ============================================
local function setupCollision()
    -- Karakterin çarpışmasını kapat
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CollisionGroup = "NoCollision"
                table.insert(collisionParts, part)
            end
        end
    end
    
    -- Humanoid'ın çarpışmasını ayarla
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.AutoRotate = false
    end
    
    log("Çarpışma ayarları yapıldı")
end

local function restoreCollision()
    -- Çarpışmayı geri aç
    for _, part in ipairs(collisionParts) do
        if part then
            part.CanCollide = true
            part.CollisionGroup = "Default"
        end
    end
    collisionParts = {}
    
    log("Çarpışma geri açıldı")
end

local function checkPlayerCollision(position)
    if not settings.avoidPlayers then
        return false, nil
    end
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer ~= selectedPlayer then
            local otherCharacter = otherPlayer.Character
            if otherCharacter then
                local otherRoot = otherCharacter:FindFirstChild("HumanoidRootPart")
                if otherRoot then
                    local distance = (position - otherRoot.Position).Magnitude
                    if distance < settings.collisionRadius then
                        return true, otherPlayer
                    end
                end
            end
        end
    end
    
    return false, nil
end

local function findSafePosition(targetPos, targetCF, avoidPositions)
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    -- Farklı pozisyonları dene
    local positionsToTry = {
        -- Ana pozisyon
        {back = -settings.followDistance, side = settings.sideOffset},
        -- Sağa kay
        {back = -settings.followDistance, side = settings.sideOffset + 1.0},
        -- Sola kay
        {back = -settings.followDistance, side = settings.sideOffset - 1.0},
        -- Daha uzak
        {back = -settings.followDistance - 1.0, side = settings.sideOffset},
        -- Daha yakın
        {back = -settings.followDistance + 0.5, side = settings.sideOffset},
        -- Farklı açı
        {back = -settings.followDistance, side = 0, height = settings.followHeight + 1.0}
    }
    
    for _, posConfig in ipairs(positionsToTry) do
        local backOffset = lookVector * posConfig.back
        local sideOffset = rightVector * (posConfig.side or 0)
        local heightOffset = Vector3.new(0, posConfig.height or settings.followHeight, 0)
        
        local testPosition = targetPos + backOffset + sideOffset + heightOffset
        
        -- Çarpışma kontrolü
        local hasCollision, collidingPlayer = checkPlayerCollision(testPosition)
        if not hasCollision then
            -- Raycast ile yer kontrolü
            local rayOrigin = Vector3.new(testPosition.X, testPosition.Y + 10, testPosition.Z)
            local rayDirection = Vector3.new(0, -20, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {character}
            
            local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            if rayResult then
                local groundPos = rayResult.Position + Vector3.new(0, settings.groundOffset, 0)
                return Vector3.new(
                    testPosition.X,
                    groundPos.Y + settings.followHeight,
                    testPosition.Z
                )
            end
        end
    end
    
    -- Hiçbir pozisyon uygun değilse, ana pozisyonu döndür
    local backOffset = lookVector * -settings.followDistance
    local sideOffset = rightVector * settings.sideOffset
    local basePosition = targetPos + backOffset + sideOffset
    
    local rayOrigin = Vector3.new(basePosition.X, basePosition.Y + 10, basePosition.Z)
    local rayDirection = Vector3.new(0, -20, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if rayResult then
        local groundPos = rayResult.Position + Vector3.new(0, settings.groundOffset, 0)
        return Vector3.new(
            basePosition.X,
            groundPos.Y + settings.followHeight,
            basePosition.Z
        )
    end
    
    return targetPos + Vector3.new(0, settings.followHeight, 0)
end

-- ============================================
-- GUI SİSTEMİ
-- ============================================
local function createGUI()
    log("GUI oluşturuluyor...")
    
    local playerGui = player:WaitForChild("PlayerGui")
    local oldGUI = playerGui:FindFirstChild("SafeTakipGUI")
    if oldGUI then oldGUI:Destroy() end
    wait(0.05)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SafeTakipGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 100)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🛡️ ÇARPIŞMASIZ TAKİP 🛡️"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 60, 50)
    title.TextColor3 = Color3.fromRGB(0, 255, 150)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    -- Player List
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 0, 140)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 100)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollFrame
    uiListLayout.Padding = UDim.new(0, 3)
    
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, 5)
    uiPadding.PaddingTop = UDim.new(0, 5)
    uiPadding.Parent = scrollFrame
    
    -- Control Panel
    local controlPanel = Instance.new("Frame")
    controlPanel.Size = UDim2.new(1, -20, 0, 260)
    controlPanel.Position = UDim2.new(0, 10, 0, 200)
    controlPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    controlPanel.BorderSizePixel = 1
    controlPanel.BorderColor3 = Color3.fromRGB(50, 70, 60)
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 8)
    panelCorner.Parent = controlPanel
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "🔴 TAKİP KAPALI"
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14
    statusLabel.Parent = controlPanel
    
    -- Collision Status
    local collisionLabel = Instance.new("TextLabel")
    collisionLabel.Name = "CollisionLabel"
    collisionLabel.Text = "🛡️ Çarpışma: KAPALI"
    collisionLabel.Size = UDim2.new(1, -20, 0, 25)
    collisionLabel.Position = UDim2.new(0, 10, 0, 40)
    collisionLabel.BackgroundTransparency = 1
    collisionLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    collisionLabel.Font = Enum.Font.GothamBold
    collisionLabel.TextSize = 12
    collisionLabel.Parent = controlPanel
    
    -- Distance Control
    local distanceFrame = Instance.new("Frame")
    distanceFrame.Size = UDim2.new(1, -20, 0, 30)
    distanceFrame.Position = UDim2.new(0, 10, 0, 70)
    distanceFrame.BackgroundTransparency = 1
    distanceFrame.Parent = controlPanel
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Text = "📏 Mesafe: 1.5m"
    distanceLabel.Size = UDim2.new(0.6, 0, 1, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 230, 255)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = distanceFrame
    
    local distanceMinus = Instance.new("TextButton")
    distanceMinus.Text = "➖"
    distanceMinus.Size = UDim2.new(0, 25, 0, 25)
    distanceMinus.Position = UDim2.new(0.65, 0, 0, 0)
    distanceMinus.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    distanceMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    distanceMinus.Font = Enum.Font.GothamBold
    distanceMinus.TextSize = 12
    distanceMinus.Parent = distanceFrame
    
    local distancePlus = Instance.new("TextButton")
    distancePlus.Text = "➕"
    distancePlus.Size = UDim2.new(0, 25, 0, 25)
    distancePlus.Position = UDim2.new(0.8, 0, 0, 0)
    distancePlus.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    distancePlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    distancePlus.Font = Enum.Font.GothamBold
    distancePlus.TextSize = 12
    distancePlus.Parent = distanceFrame
    
    -- Height Control
    local heightFrame = Instance.new("Frame")
    heightFrame.Size = UDim2.new(1, -20, 0, 30)
    heightFrame.Position = UDim2.new(0, 10, 0, 105)
    heightFrame.BackgroundTransparency = 1
    heightFrame.Parent = controlPanel
    
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Name = "HeightLabel"
    heightLabel.Text = "📐 Yükseklik: 1.8m"
    heightLabel.Size = UDim2.new(0.6, 0, 1, 0)
    heightLabel.Position = UDim2.new(0, 0, 0, 0)
    heightLabel.BackgroundTransparency = 1
    heightLabel.TextColor3 = Color3.fromRGB(200, 230, 255)
    heightLabel.Font = Enum.Font.Gotham
    heightLabel.TextSize = 12
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = heightFrame
    
    local heightMinus = Instance.new("TextButton")
    heightMinus.Text = "➖"
    heightMinus.Size = UDim2.new(0, 25, 0, 25)
    heightMinus.Position = UDim2.new(0.65, 0, 0, 0)
    heightMinus.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    heightMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    heightMinus.Font = Enum.Font.GothamBold
    heightMinus.TextSize = 12
    heightMinus.Parent = heightFrame
    
    local heightPlus = Instance.new("TextButton")
    heightPlus.Text = "➕"
    heightPlus.Size = UDim2.new(0, 25, 0, 25)
    heightPlus.Position = UDim2.new(0.8, 0, 0, 0)
    heightPlus.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    heightPlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    heightPlus.Font = Enum.Font.GothamBold
    heightPlus.TextSize = 12
    heightPlus.Parent = heightFrame
    
    -- Shake Control
    local shakeFrame = Instance.new("Frame")
    shakeFrame.Size = UDim2.new(1, -20, 0, 30)
    shakeFrame.Position = UDim2.new(0, 10, 0, 140)
    shakeFrame.BackgroundTransparency = 1
    shakeFrame.Parent = controlPanel
    
    local shakeLabel = Instance.new("TextLabel")
    shakeLabel.Name = "ShakeLabel"
    shakeLabel.Text = "🌀 Titreme: %30"
    shakeLabel.Size = UDim2.new(0.6, 0, 1, 0)
    shakeLabel.Position = UDim2.new(0, 0, 0, 0)
    shakeLabel.BackgroundTransparency = 1
    shakeLabel.TextColor3 = Color3.fromRGB(255, 200, 255)
    shakeLabel.Font = Enum.Font.Gotham
    shakeLabel.TextSize = 12
    shakeLabel.TextXAlignment = Enum.TextXAlignment.Left
    shakeLabel.Parent = shakeFrame
    
    local shakeMinus = Instance.new("TextButton")
    shakeMinus.Text = "➖"
    shakeMinus.Size = UDim2.new(0, 25, 0, 25)
    shakeMinus.Position = UDim2.new(0.65, 0, 0, 0)
    shakeMinus.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    shakeMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    shakeMinus.Font = Enum.Font.GothamBold
    shakeMinus.TextSize = 12
    shakeMinus.Parent = shakeFrame
    
    local shakePlus = Instance.new("TextButton")
    shakePlus.Text = "➕"
    shakePlus.Size = UDim2.new(0, 25, 0, 25)
    shakePlus.Position = UDim2.new(0.8, 0, 0, 0)
    shakePlus.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    shakePlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    shakePlus.Font = Enum.Font.GothamBold
    shakePlus.TextSize = 12
    shakePlus.Parent = shakeFrame
    
    -- Collision Toggle
    local collisionFrame = Instance.new("Frame")
    collisionFrame.Size = UDim2.new(1, -20, 0, 30)
    collisionFrame.Position = UDim2.new(0, 10, 0, 175)
    collisionFrame.BackgroundTransparency = 1
    collisionFrame.Parent = controlPanel
    
    local collisionToggleLabel = Instance.new("TextLabel")
    collisionToggleLabel.Name = "CollisionToggleLabel"
    collisionToggleLabel.Text = "🚫 Oyuncu Kaçınma: AÇIK"
    collisionToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    collisionToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    collisionToggleLabel.BackgroundTransparency = 1
    collisionToggleLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    collisionToggleLabel.Font = Enum.Font.Gotham
    collisionToggleLabel.TextSize = 11
    collisionToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    collisionToggleLabel.Parent = collisionFrame
    
    local collisionToggleBtn = Instance.new("TextButton")
    collisionToggleBtn.Text = "🔄"
    collisionToggleBtn.Size = UDim2.new(0, 30, 0, 25)
    collisionToggleBtn.Position = UDim2.new(0.8, 0, 0, 0)
    collisionToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 80, 70)
    collisionToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    collisionToggleBtn.Font = Enum.Font.GothamBold
    collisionToggleBtn.TextSize = 12
    collisionToggleBtn.Parent = collisionFrame
    
    -- Action Buttons
    local actionFrame = Instance.new("Frame")
    actionFrame.Size = UDim2.new(1, -20, 0, 40)
    actionFrame.Position = UDim2.new(0, 10, 0, 210)
    actionFrame.BackgroundTransparency = 1
    actionFrame.Parent = controlPanel
    
    local startButton = Instance.new("TextButton")
    startButton.Name = "StartButton"
    startButton.Text = "🚀 BAŞLAT"
    startButton.Size = UDim2.new(0.48, 0, 1, 0)
    startButton.Position = UDim2.new(0, 0, 0, 0)
    startButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.Font = Enum.Font.GothamBold
    startButton.TextSize = 14
    startButton.Parent = actionFrame
    
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Text = "⛔ DURDUR"
    stopButton.Size = UDim2.new(0.48, 0, 1, 0)
    stopButton.Position = UDim2.new(0.52, 0, 0, 0)
    stopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.Font = Enum.Font.GothamBold
    stopButton.TextSize = 14
    stopButton.Visible = false
    stopButton.Parent = actionFrame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = mainFrame
    
    -- Add corners
    local function addCorner(obj)
        local crn = Instance.new("UICorner")
        crn.CornerRadius = UDim.new(0, 6)
        crn.Parent = obj
    end
    
    addCorner(distanceMinus)
    addCorner(distancePlus)
    addCorner(heightMinus)
    addCorner(heightPlus)
    addCorner(shakeMinus)
    addCorner(shakePlus)
    addCorner(collisionToggleBtn)
    addCorner(startButton)
    addCorner(stopButton)
    addCorner(closeBtn)
    
    -- Parent everything
    screenGui.Parent = playerGui
    title.Parent = mainFrame
    scrollFrame.Parent = mainFrame
    controlPanel.Parent = mainFrame
    mainFrame.Parent = screenGui
    
    log("GUI oluşturuldu!")
    
    return {
        ScreenGui = screenGui,
        ScrollFrame = scrollFrame,
        StatusLabel = statusLabel,
        CollisionLabel = collisionLabel,
        CollisionToggleLabel = collisionToggleLabel,
        DistanceLabel = distanceLabel,
        HeightLabel = heightLabel,
        ShakeLabel = shakeLabel,
        StartButton = startButton,
        StopButton = stopButton,
        DistanceMinus = distanceMinus,
        DistancePlus = distancePlus,
        HeightMinus = heightMinus,
        HeightPlus = heightPlus,
        ShakeMinus = shakeMinus,
        ShakePlus = shakePlus,
        CollisionToggleBtn = collisionToggleBtn,
        CloseBtn = closeBtn
    }
end

-- ============================================
-- ÇARPIŞMASIZ TAKİP SİSTEMİ
-- ============================================
local function calculateVelocity(currentPos, lastPos, deltaTime)
    if deltaTime > 0 then
        return (currentPos - lastPos) / deltaTime
    end
    return Vector3.new(0, 0, 0)
end

local function calculateShakeOffset()
    if not settings.useShake or settings.shakeIntensity <= 0 then
        return Vector3.new(0, 0, 0)
    end
    
    timeOffset = timeOffset + (tick() - lastUpdate) * settings.shakeSpeed
    
    local shakeX = math.sin(timeOffset * 2.5) * settings.shakeIntensity
    local shakeY = math.cos(timeOffset * 1.8) * settings.shakeIntensity * 0.6
    local shakeZ = math.sin(timeOffset * 3.2) * settings.shakeIntensity * 0.4
    
    return Vector3.new(shakeX, shakeY, shakeZ)
end

local function safeTeleport(targetCharacter)
    if not targetCharacter or not humanoidRootPart then
        return false
    end
    
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return false
    end
    
    local currentTime = tick()
    local deltaTime = currentTime - lastUpdate
    lastUpdate = currentTime
    
    -- HEDEF POZİSYONU
    local targetPos = targetRoot.Position
    local targetCF = targetRoot.CFrame
    
    -- HAREKET TAHMİNİ
    targetVelocity = calculateVelocity(targetPos, lastTargetPos, deltaTime)
    local predictedPos = targetPos + (targetVelocity * settings.prediction)
    lastTargetPos = targetPos
    
    -- GÜVENLİ POZİSYON BUL
    local safePosition = findSafePosition(predictedPos, targetCF)
    
    -- TİTREME EFEKTİ
    local shakeOffset = calculateShakeOffset()
    local finalPosition = safePosition + shakeOffset
    
    -- ÇARPIŞMA KONTROLÜ
    local hasCollision, collidingPlayer = checkPlayerCollision(finalPosition)
    if hasCollision and settings.avoidPlayers then
        -- Çarpışma varsa, pozisyonu ayarla
        log("Çarpışma tespit edildi: " .. collidingPlayer.Name)
        safePosition = findSafePosition(predictedPos, targetCF)
        finalPosition = safePosition + shakeOffset
    end
    
    -- TELEPORT
    humanoidRootPart.CFrame = CFrame.new(finalPosition, predictedPos)
    
    return true
end

local function safeTrackingLoop()
    log("Çarpışmasız takip döngüsü başladı!")
    
    while isTracking do
        if selectedPlayer then
            local targetCharacter = selectedPlayer.Character
            
            if targetCharacter then
                local success = safeTeleport(targetCharacter)
                
                if not success then
                    wait(0.5)
                end
            else
                wait(0.5)
            end
        else
            break
        end
        
        wait(settings.updateRate)
    end
    
    log("Takip döngüsü durdu")
end

-- ============================================
-- GUI MANAGEMENT
-- ============================================
local GUI = createGUI()

local function updatePlayerList()
    if not GUI or not GUI.ScrollFrame then return end
    
    local scrollFrame = GUI.ScrollFrame
    
    -- Clear
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create player buttons
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerButton = Instance.new("TextButton")
            playerButton.Name = otherPlayer.Name
            playerButton.Text = "👤 " .. otherPlayer.Name
            playerButton.Size = UDim2.new(1, -10, 0, 32)
            playerButton.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
            playerButton.TextColor3 = Color3.fromRGB(220, 255, 240)
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextSize = 12
            playerButton.AutoButtonColor = true
            playerButton.Parent = scrollFrame
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = playerButton
            
            -- Selection
            playerButton.MouseButton1Click:Connect(function()
                for _, btn in ipairs(scrollFrame:GetChildren()) do
                    if btn:IsA("TextButton") then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 50, 45)
                    end
                end
                
                playerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                selectedPlayer = otherPlayer
                GUI.StatusLabel.Text = "🎯 SEÇİLDİ: " .. otherPlayer.Name
                GUI.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                log("Oyuncu seçildi: " .. otherPlayer.Name)
            end)
        end
    end
end

local function updateDisplays()
    -- Mesafe
    GUI.DistanceLabel.Text = string.format("📏 Mesafe: %.1fm", settings.followDistance)
    
    -- Yükseklik
    GUI.HeightLabel.Text = string.format("📐 Yükseklik: %.1fm", settings.followHeight)
    
    -- Titreme
    local shakePercent = math.floor(settings.shakeIntensity * 100)
    GUI.ShakeLabel.Text = string.format("🌀 Titreme: %%%d", shakePercent)
    
    -- Çarpışma durumu
    if isTracking then
        GUI.CollisionLabel.Text = "🛡️ Çarpışma: KAPALI"
        GUI.CollisionLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        GUI.CollisionLabel.Text = "🛡️ Çarpışma: AÇIK"
        GUI.CollisionLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    -- Oyuncu kaçınma
    if settings.avoidPlayers then
        GUI.CollisionToggleLabel.Text = "🚫 Oyuncu Kaçınma: AÇIK"
        GUI.CollisionToggleLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        GUI.CollisionToggleLabel.Text = "🚫 Oyuncu Kaçınma: KAPALI"
        GUI.CollisionToggleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- ============================================
-- TAKİP KONTROLLERİ
-- ============================================
local function startSafeTracking()
    if not selectedPlayer then
        GUI.StatusLabel.Text = "⚠️ OYUNCU SEÇ!"
        wait(0.5)
        GUI.StatusLabel.Text = "🔴 TAKİP KAPALI"
        return
    end
    
    -- Stop old thread
    if trackingThread then
        coroutine.close(trackingThread)
        trackingThread = nil
    end
    
    -- Çarpışmayı kapat
    setupCollision()
    
    -- Reset
    isTracking = true
    timeOffset = 0
    lastTargetPos = Vector3.new(0, 0, 0)
    targetVelocity = Vector3.new(0, 0, 0)
    lastUpdate = tick()
    
    -- First teleport
    local targetCharacter = selectedPlayer.Character
    if targetCharacter then
        safeTeleport(targetCharacter)
    end
    
    -- Update GUI
    GUI.StatusLabel.Text = "✅ TAKİP: " .. selectedPlayer.Name
    GUI.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    GUI.StartButton.Visible = false
    GUI.StopButton.Visible = true
    updateDisplays()
    
    -- Start tracking
    trackingThread = coroutine.create(safeTrackingLoop)
    coroutine.resume(trackingThread)
    
    log("Çarpışmasız takip başlatıldı: " .. selectedPlayer.Name)
end

local function stopSafeTracking()
    isTracking = false
    
    -- Çarpışmayı geri aç
    restoreCollision()
    
    if trackingThread then
        coroutine.close(trackingThread)
        trackingThread = nil
    end
    
    GUI.StatusLabel.Text = "🔴 TAKİP KAPALI"
    GUI.StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    GUI.StartButton.Visible = true
    GUI.StopButton.Visible = false
    updateDisplays()
    
    log("Takip durduruldu")
end

-- ============================================
-- CONTROLS SETUP
-- ============================================
-- Distance controls
GUI.DistanceMinus.MouseButton1Click:Connect(function()
    settings.followDistance = math.max(0.5, settings.followDistance - 0.2)
    updateDisplays()
    log("Mesafe azaltıldı: " .. settings.followDistance)
    
    if isTracking and selectedPlayer then
        local targetCharacter = selectedPlayer.Character
        if targetCharacter then
            safeTeleport(targetCharacter)
        end
    end
end)

GUI.DistancePlus.MouseButton1Click:Connect(function()
    settings.followDistance = math.min(5.0, settings.followDistance + 0.2)
    updateDisplays()
    log("Mesafe arttırıldı: " .. settings.followDistance)
    
    if isTracking and selectedPlayer then
        local targetCharacter = selectedPlayer.Character
        if targetCharacter then
            safeTeleport(targetCharacter)
        end
    end
end)

-- Height controls
GUI.HeightMinus.MouseButton1Click:Connect(function()
    settings.followHeight = math.max(0.5, settings.followHeight - 0.2)
    updateDisplays()
    log("Yükseklik azaltıldı: " .. settings.followHeight)
    
    if isTracking and selectedPlayer then
        local targetCharacter = selectedPlayer.Character
        if targetCharacter then
            safeTeleport(targetCharacter)
        end
    end
end)

GUI.HeightPlus.MouseButton1Click:Connect(function()
    settings.followHeight = math.min(3.0, settings.followHeight + 0.2)
    updateDisplays()
    log("Yükseklik arttırıldı: " .. settings.followHeight)
    
    if isTracking and selectedPlayer then
        local targetCharacter = selectedPlayer.Character
        if targetCharacter then
            safeTeleport(targetCharacter)
        end
    end
end)

-- Shake controls
GUI.ShakeMinus.MouseButton1Click:Connect(function()
    settings.shakeIntensity = math.max(0.0, settings.shakeIntensity - 0.05)
    updateDisplays()
    log("Titreme şiddeti azaltıldı: " .. settings.shakeIntensity)
end)

GUI.ShakePlus.MouseButton1Click:Connect(function()
    settings.shakeIntensity = math.min(1.0, settings.shakeIntensity + 0.05)
    updateDisplays()
    log("Titreme şiddeti arttırıldı: " .. settings.shakeIntensity)
end)

-- Collision toggle
GUI.CollisionToggleBtn.MouseButton1Click:Connect(function()
    settings.avoidPlayers = not settings.avoidPlayers
    updateDisplays()
    log("Oyuncu kaçınma: " .. (settings.avoidPlayers and "AÇIK" or "KAPALI"))
end)

-- Start/Stop buttons
GUI.StartButton.MouseButton1Click:Connect(function()
    startSafeTracking()
end)

GUI.StopButton.MouseButton1Click:Connect(function()
    stopSafeTracking()
end)

-- Close button
GUI.CloseBtn.MouseButton1Click:Connect(function()
    GUI.ScreenGui.Enabled = not GUI.ScreenGui.Enabled
    if not GUI.ScreenGui.Enabled then
        stopSafeTracking()
    end
end)

-- Keyboard shortcuts
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        if selectedPlayer then
            if isTracking then
                stopSafeTracking()
            else
                startSafeTracking()
            end
        end
    elseif input.KeyCode == Enum.KeyCode.C then
        -- Çarpışma aç/kapat
        settings.avoidPlayers = not settings.avoidPlayers
        updateDisplays()
        log("Çarpışma kaçınma (C): " .. (settings.avoidPlayers and "AÇIK" or "KAPALI"))
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
-- Initial displays
updateDisplays()
updatePlayerList()

-- Player events
Players.PlayerAdded:Connect(function()
    wait(0.3)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function(exitingPlayer)
    wait(0.2)
    updatePlayerList()
    
    if selectedPlayer and exitingPlayer == selectedPlayer then
        log("Hedef oyuncu çıktı!")
        stopSafeTracking()
        selectedPlayer = nil
        GUI.StatusLabel.Text = "🔴 OYUNCU ÇIKTI"
        wait(1.5)
        GUI.StatusLabel.Text = "🔴 TAKİP KAPALI"
    end
end)

-- Character events
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    
    if isTracking and selectedPlayer then
        wait(0.2)
        startSafeTracking()
    end
end)

-- Global commands
_G.SafeTakip_Baslat = function(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == playerName then
            selectedPlayer = p
            startSafeTracking()
            break
        end
    end
end

_G.SafeTakip_Durdur = stopSafeTracking
_G.SafeTakip_Ayarlar = function()
    print("=== ÇARPIŞMASIZ TAKİP AYARLARI ===")
    print("Mesafe: " .. settings.followDistance .. "m")
    print("Yükseklik: " .. settings.followHeight .. "m")
    print("Titreme Şiddeti: %" .. math.floor(settings.shakeIntensity * 100))
    print("Çarpışma Kaçınma: " .. tostring(settings.avoidPlayers))
    print("Çarpışma Yarıçapı: " .. settings.collisionRadius .. "m")
    print("Seçili Oyuncu: " .. (selectedPlayer and selectedPlayer.Name or "Yok"))
    print("Takip Aktif: " .. tostring(isTracking))
    print("===================================")
end

_G.SafeTakip_Carpisma = function(durum)
    if durum ~= nil then
        settings.avoidPlayers = durum
        updateDisplays()
        print("Çarpışma kaçınma: " .. (settings.avoidPlayers and "AÇIK" or "KAPALI"))
    end
end

_G.SafeTakip_Mesafe = function(yeniMesafe)
    if yeniMesafe then
        settings.followDistance = math.clamp(yeniMesafe, 0.5, 5.0)
        updateDisplays()
        print("Mesafe ayarlandı: " .. settings.followDistance .. "m")
    end
end

print("==========================================")
print("🛡️ ÇARPIŞMASIZ TAKİP SİSTEMİ YÜKLENDİ! 🛡️")
print("==========================================")
print("✅ ÖZELLİKLER:")
print("   • OTOMATİK ÇARPIŞMA KAPATMA")
print("   • OYUNCULARDAN OTOMATİK KAÇINMA")
print("   • ÇOKLU POZİSYON DENEMESİ")
print("   • HAVAYA ÇIKMAZ - Yere basar")
print("   • AYARLANABİLİR TÜM PARAMETRELER")
print("==========================================")
print("🎮 KONTROLLER:")
print("   • T - Takip Aç/Kapat")
print("   • C - Çarpışma Kaçınma Aç/Kapat")
print("==========================================")
print("🔧 KOMUTLAR (konsola yaz):")
print("   _G.SafeTakip_Baslat('OyuncuAdı')")
print("   _G.SafeTakip_Durdur()")
print("   _G.SafeTakip_Carpisma(true/false)")
print("   _G.SafeTakip_Mesafe(2.0)")
print("   _G.SafeTakip_Ayarlar()")
print("==========================================")
print("⚠️ ARTIK OYUNCULAR ÇARPMAYACAK VE BOZULMAYACAK!")
print("==========================================")
