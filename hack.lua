-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Debug
local DEBUG = true
local function log(...)
    if DEBUG then
        print("[ARKA-TAKIP]", ...)
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
    shakeIntensity = 0.3,  -- Titreme şiddeti (AYARLANABİLİR)
    shakeSpeed = 15,       -- Titreme hızı (AYARLANABİLİR)
    updateRate = 0.01,
    smoothness = 0.3,
    prediction = 0.05,
    lockMode = true,
    groundOffset = 0.5,
    useRaycast = true,
    useShake = true        -- Titreme açık/kapalı
}

-- State
local selectedPlayer = nil
local isTracking = false
local trackingThread = nil
local timeOffset = 0
local lastTargetPos = Vector3.new(0, 0, 0)
local targetVelocity = Vector3.new(0, 0, 0)
local lastUpdate = tick()

-- ============================================
-- YER TESPİT FONKSİYONLARI
-- ============================================
local function getGroundPosition(position)
    local rayOrigin = Vector3.new(position.X, position.Y + 10, position.Z)
    local rayDirection = Vector3.new(0, -20, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if rayResult then
        return rayResult.Position + Vector3.new(0, settings.groundOffset, 0)
    else
        return Vector3.new(position.X, position.Y, position.Z)
    end
end

local function getSafePosition(targetPos, targetCF)
    local lookVector = targetCF.LookVector
    local rightVector = targetCF.RightVector
    
    local backOffset = lookVector * -settings.followDistance
    local sideOffset = rightVector * settings.sideOffset
    
    local basePosition = targetPos + backOffset + sideOffset
    local groundPos = getGroundPosition(basePosition)
    
    local finalPosition = Vector3.new(
        groundPos.X,
        groundPos.Y + settings.followHeight,
        groundPos.Z
    )
    
    return finalPosition
end

-- ============================================
-- TİTREME FONKSİYONLARI
-- ============================================
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

-- ============================================
-- GENİŞLETİLMİŞ GUI SİSTEMİ
-- ============================================
local function createGUI()
    log("GUI oluşturuluyor...")
    
    local playerGui = player:WaitForChild("PlayerGui")
    local oldGUI = playerGui:FindFirstChild("FullTakipGUI")
    if oldGUI then oldGUI:Destroy() end
    wait(0.05)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FullTakipGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 420)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 200)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 TAM KONTROLLÜ TAKİP 🎯"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 50, 60)
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
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
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
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
    controlPanel.Size = UDim2.new(1, -20, 0, 240)
    controlPanel.Position = UDim2.new(0, 10, 0, 200)
    controlPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    controlPanel.BorderSizePixel = 1
    controlPanel.BorderColor3 = Color3.fromRGB(50, 50, 70)
    
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
    
    -- Distance Control
    local distanceFrame = Instance.new("Frame")
    distanceFrame.Size = UDim2.new(1, -20, 0, 30)
    distanceFrame.Position = UDim2.new(0, 10, 0, 40)
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
    distanceMinus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    distanceMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    distanceMinus.Font = Enum.Font.GothamBold
    distanceMinus.TextSize = 12
    distanceMinus.Parent = distanceFrame
    
    local distancePlus = Instance.new("TextButton")
    distancePlus.Text = "➕"
    distancePlus.Size = UDim2.new(0, 25, 0, 25)
    distancePlus.Position = UDim2.new(0.8, 0, 0, 0)
    distancePlus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    distancePlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    distancePlus.Font = Enum.Font.GothamBold
    distancePlus.TextSize = 12
    distancePlus.Parent = distanceFrame
    
    -- Height Control
    local heightFrame = Instance.new("Frame")
    heightFrame.Size = UDim2.new(1, -20, 0, 30)
    heightFrame.Position = UDim2.new(0, 10, 0, 75)
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
    heightMinus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    heightMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    heightMinus.Font = Enum.Font.GothamBold
    heightMinus.TextSize = 12
    heightMinus.Parent = heightFrame
    
    local heightPlus = Instance.new("TextButton")
    heightPlus.Text = "➕"
    heightPlus.Size = UDim2.new(0, 25, 0, 25)
    heightPlus.Position = UDim2.new(0.8, 0, 0, 0)
    heightPlus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    heightPlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    heightPlus.Font = Enum.Font.GothamBold
    heightPlus.TextSize = 12
    heightPlus.Parent = heightFrame
    
    -- Shake Intensity Control
    local shakeFrame = Instance.new("Frame")
    shakeFrame.Size = UDim2.new(1, -20, 0, 30)
    shakeFrame.Position = UDim2.new(0, 10, 0, 110)
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
    shakeMinus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    shakeMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    shakeMinus.Font = Enum.Font.GothamBold
    shakeMinus.TextSize = 12
    shakeMinus.Parent = shakeFrame
    
    local shakePlus = Instance.new("TextButton")
    shakePlus.Text = "➕"
    shakePlus.Size = UDim2.new(0, 25, 0, 25)
    shakePlus.Position = UDim2.new(0.8, 0, 0, 0)
    shakePlus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    shakePlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    shakePlus.Font = Enum.Font.GothamBold
    shakePlus.TextSize = 12
    shakePlus.Parent = shakeFrame
    
    -- Shake Speed Control
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -20, 0, 30)
    speedFrame.Position = UDim2.new(0, 10, 0, 145)
    speedFrame.BackgroundTransparency = 1
    speedFrame.Parent = controlPanel
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Text = "⚡ Titreme Hızı: 15"
    speedLabel.Size = UDim2.new(0.6, 0, 1, 0)
    speedLabel.Position = UDim2.new(0, 0, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = Color3.fromRGB(255, 230, 200)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedFrame
    
    local speedMinus = Instance.new("TextButton")
    speedMinus.Text = "➖"
    speedMinus.Size = UDim2.new(0, 25, 0, 25)
    speedMinus.Position = UDim2.new(0.65, 0, 0, 0)
    speedMinus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    speedMinus.TextColor3 = Color3.fromRGB(255, 150, 150)
    speedMinus.Font = Enum.Font.GothamBold
    speedMinus.TextSize = 12
    speedMinus.Parent = speedFrame
    
    local speedPlus = Instance.new("TextButton")
    speedPlus.Text = "➕"
    speedPlus.Size = UDim2.new(0, 25, 0, 25)
    speedPlus.Position = UDim2.new(0.8, 0, 0, 0)
    speedPlus.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    speedPlus.TextColor3 = Color3.fromRGB(150, 255, 150)
    speedPlus.Font = Enum.Font.GothamBold
    speedPlus.TextSize = 12
    speedPlus.Parent = speedFrame
    
    -- Shake Toggle
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 30)
    toggleFrame.Position = UDim2.new(0, 10, 0, 180)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = controlPanel
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Text = "🔘 Titreme: AÇIK"
    toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 12
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Text = "🔄"
    toggleBtn.Size = UDim2.new(0, 30, 0, 25)
    toggleBtn.Position = UDim2.new(0.8, 0, 0, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    toggleBtn.Parent = toggleFrame
    
    -- Action Buttons
    local actionFrame = Instance.new("Frame")
    actionFrame.Size = UDim2.new(1, -20, 0, 40)
    actionFrame.Position = UDim2.new(0, 10, 0, 215)
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
    addCorner(speedMinus)
    addCorner(speedPlus)
    addCorner(toggleBtn)
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
        DistanceLabel = distanceLabel,
        HeightLabel = heightLabel,
        ShakeLabel = shakeLabel,
        SpeedLabel = speedLabel,
        ToggleLabel = toggleLabel,
        StartButton = startButton,
        StopButton = stopButton,
        DistanceMinus = distanceMinus,
        DistancePlus = distancePlus,
        HeightMinus = heightMinus,
        HeightPlus = heightPlus,
        ShakeMinus = shakeMinus,
        ShakePlus = shakePlus,
        SpeedMinus = speedMinus,
        SpeedPlus = speedPlus,
        ToggleBtn = toggleBtn,
        CloseBtn = closeBtn
    }
end

-- ============================================
-- TAM KONTROLLÜ TAKİP SİSTEMİ
-- ============================================
local function calculateVelocity(currentPos, lastPos, deltaTime)
    if deltaTime > 0 then
        return (currentPos - lastPos) / deltaTime
    end
    return Vector3.new(0, 0, 0)
end

local function teleportWithShake(targetCharacter)
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
    
    -- TAM ARKAYA GÜVENLİ POZİSYON
    local safePosition = getSafePosition(predictedPos, targetCF)
    
    -- TİTREME EFEKTİ
    local shakeOffset = calculateShakeOffset()
    local finalPosition = safePosition + shakeOffset
    
    -- Karakteri teleport et
    humanoidRootPart.CFrame = CFrame.new(finalPosition, predictedPos)
    
    return true
end

local function fullTrackingLoop()
    log("Tam kontrollü takip döngüsü başladı!")
    
    while isTracking do
        if selectedPlayer then
            local targetCharacter = selectedPlayer.Character
            
            if targetCharacter then
                local success = teleportWithShake(targetCharacter)
                
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
            playerButton.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
            playerButton.TextColor3 = Color3.fromRGB(220, 230, 255)
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
                        btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
                    end
                end
                
                playerButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
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
    
    -- Titreme şiddeti
    local shakePercent = math.floor(settings.shakeIntensity * 100)
    GUI.ShakeLabel.Text = string.format("🌀 Titreme: %%%d", shakePercent)
    
    -- Titreme hızı
    GUI.SpeedLabel.Text = string.format("⚡ Titreme Hızı: %d", settings.shakeSpeed)
    
    -- Titreme açık/kapalı
    if settings.useShake then
        GUI.ToggleLabel.Text = "🔘 Titreme: AÇIK"
        GUI.ToggleLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        GUI.ToggleLabel.Text = "🔘 Titreme: KAPALI"
        GUI.ToggleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

-- ============================================
-- TAKİP KONTROLLERİ
-- ============================================
local function startFullTracking()
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
    
    -- Reset
    isTracking = true
    timeOffset = 0
    lastTargetPos = Vector3.new(0, 0, 0)
    targetVelocity = Vector3.new(0, 0, 0)
    lastUpdate = tick()
    
    -- First teleport
    local targetCharacter = selectedPlayer.Character
    if targetCharacter then
        teleportWithShake(targetCharacter)
    end
    
    -- Update GUI
    GUI.StatusLabel.Text = "✅ TAKİP: " .. selectedPlayer.Name
    GUI.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    GUI.StartButton.Visible = false
    GUI.StopButton.Visible = true
    
    -- Start tracking
    trackingThread = coroutine.create(fullTrackingLoop)
    coroutine.resume(trackingThread)
    
    log("Tam kontrollü takip başlatıldı: " .. selectedPlayer.Name)
end

local function stopFullTracking()
    isTracking = false
    
    if trackingThread then
        coroutine.close(trackingThread)
        trackingThread = nil
    end
    
    GUI.StatusLabel.Text = "🔴 TAKİP KAPALI"
    GUI.StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    GUI.StartButton.Visible = true
    GUI.StopButton.Visible = false
    
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
            teleportWithShake(targetCharacter)
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
            teleportWithShake(targetCharacter)
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
            teleportWithShake(targetCharacter)
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
            teleportWithShake(targetCharacter)
        end
    end
end)

-- Shake intensity controls
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

-- Shake speed controls
GUI.SpeedMinus.MouseButton1Click:Connect(function()
    settings.shakeSpeed = math.max(1, settings.shakeSpeed - 2)
    updateDisplays()
    log("Titreme hızı azaltıldı: " .. settings.shakeSpeed)
end)

GUI.SpeedPlus.MouseButton1Click:Connect(function()
    settings.shakeSpeed = math.min(50, settings.shakeSpeed + 2)
    updateDisplays()
    log("Titreme hızı arttırıldı: " .. settings.shakeSpeed)
end)

-- Shake toggle
GUI.ToggleBtn.MouseButton1Click:Connect(function()
    settings.useShake = not settings.useShake
    updateDisplays()
    log("Titreme: " .. (settings.useShake and "AÇIK" or "KAPALI"))
end)

-- Start/Stop buttons
GUI.StartButton.MouseButton1Click:Connect(function()
    startFullTracking()
end)

GUI.StopButton.MouseButton1Click:Connect(function()
    stopFullTracking()
end)

-- Close button
GUI.CloseBtn.MouseButton1Click:Connect(function()
    GUI.ScreenGui.Enabled = not GUI.ScreenGui.Enabled
    if not GUI.ScreenGui.Enabled then
        stopFullTracking()
    end
end)

-- Keyboard shortcuts
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        if selectedPlayer then
            if isTracking then
                stopFullTracking()
            else
                startFullTracking()
            end
        end
    elseif input.KeyCode == Enum.KeyCode.S then
        -- Titreme aç/kapat
        settings.useShake = not settings.useShake
        updateDisplays()
        log("Titreme (S): " .. (settings.useShake and "AÇIK" or "KAPALI"))
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
        stopFullTracking()
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
        startFullTracking()
    end
end)

-- Global commands
_G.TamTakip_Baslat = function(playerName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == playerName then
            selectedPlayer = p
            startFullTracking()
            break
        end
    end
end

_G.TamTakip_Durdur = stopFullTracking
_G.TamTakip_Ayarlar = function()
    print("=== TAM KONTROLLÜ TAKİP AYARLARI ===")
    print("Mesafe: " .. settings.followDistance .. "m")
    print("Yükseklik: " .. settings.followHeight .. "m")
    print("Titreme Şiddeti: %" .. math.floor(settings.shakeIntensity * 100))
    print("Titreme Hızı: " .. settings.shakeSpeed)
    print("Titreme Aktif: " .. tostring(settings.useShake))
    print("Seçili Oyuncu: " .. (selectedPlayer and selectedPlayer.Name or "Yok"))
    print("Takip Aktif: " .. tostring(isTracking))
    print("====================================")
end

_G.TamTakip_Mesafe = function(yeniMesafe)
    if yeniMesafe then
        settings.followDistance = math.clamp(yeniMesafe, 0.5, 5.0)
        updateDisplays()
        print("Mesafe ayarlandı: " .. settings.followDistance .. "m")
    end
end

_G.TamTakip_Yukseklik = function(yeniYukseklik)
    if yeniYukseklik then
        settings.followHeight = math.clamp(yeniYukseklik, 0.5, 3.0)
        updateDisplays()
        print("Yükseklik ayarlandı: " .. settings.followHeight .. "m")
    end
end

_G.TamTakip_Titreme = function(siddet, hiz)
    if siddet then
        settings.shakeIntensity = math.clamp(siddet, 0.0, 1.0)
    end
    if hiz then
        settings.shakeSpeed = math.clamp(hiz, 1, 50)
    end
    updateDisplays()
    print("Titreme ayarlandı: Şiddet=%" .. math.floor(settings.shakeIntensity * 100) .. ", Hız=" .. settings.shakeSpeed)
end

print("==========================================")
print("🎯 TAM KONTROLLÜ TAKİP SİSTEMİ YÜKLENDİ! 🎯")
print("==========================================")
print("✅ ÖZELLİKLER:")
print("   • HAVAYA ÇIKMAZ - Yere basar")
print("   • AYARLANABİLİR MESAFE")
print("   • AYARLANABİLİR YÜKSEKLİK")
print("   • AYARLANABİLİR TİTREME ŞİDDETİ")
print("   • AYARLANABİLİR TİTREME HIZI")
print("   • TİTREME AÇ/KAPAT özelliği")
print("==========================================")
print("🎮 KONTROLLER:")
print("   • T - Takip Aç/Kapat")
print("   • S - Titreme Aç/Kapat")
print("==========================================")
print("🔧 KOMUTLAR (konsola yaz):")
print("   _G.TamTakip_Baslat('OyuncuAdı')")
print("   _G.TamTakip_Durdur()")
print("   _G.TamTakip_Mesafe(2.0)")
print("   _G.TamTakip_Yukseklik(1.5)")
print("   _G.TamTakip_Titreme(0.5, 20)")
print("   _G.TamTakip_Ayarlar()")
print("==========================================")
print("⚠️ ARTIK TÜM AYARLARI KONTROL EDEBİLİRSİN!")
print("==========================================")
