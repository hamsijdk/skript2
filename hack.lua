-- Frox Hack GUI | Ultimate Sürüm
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Gelişmiş ayarlar
local flying, noclip, speedBoost, superJump, infJump, noClip, antiGravity = false, false, false, false, false, false, false
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50
local control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local bodyGyro, bodyVelocity
local flyKey = Enum.KeyCode.F

-- ESP Sistemi
local espEnabled = false
local espStore = {}

-- ESP renkleri
local espColors = {
    Color3.new(1, 0, 0),    -- Kırmızı
    Color3.new(0, 1, 0),    -- Yeşil
    Color3.new(0, 0, 1),    -- Mavi
    Color3.new(1, 1, 0),    -- Sarı
    Color3.new(1, 0, 1),    -- Pembe
    Color3.new(0, 1, 1),    -- Camgöbeği
    Color3.new(1, 0.5, 0),  -- Turuncu
    Color3.new(0.5, 0, 1)   -- Mor
}

-- Gelişmiş GUI sistemi
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton - Gelişmiş
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 130, 0, 55)
mainButton.Position = UDim2.new(0, 50, 0, 150)
mainButton.Text = "🚀 Frox Hack"
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 16
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainButton.BorderSizePixel = 0
mainButton.AutoButtonColor = true
mainButton.Active = true
mainButton.Parent = screenGui

local mbCorner = Instance.new("UICorner", mainButton)
mbCorner.CornerRadius = UDim.new(0, 12)
local mbStroke = Instance.new("UIStroke", mainButton)
mbStroke.Color = Color3.fromRGB(100, 100, 255)
mbStroke.Thickness = 2

mainButton.Draggable = true

-- Gelişmiş panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 500, 0, 600)
panel.Position = UDim2.new(0.5, -250, -1, 0)
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.ClipsDescendants = true

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 15)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(60, 60, 60)
panelStroke.Thickness = 2

-- Scroll frame ekleyelim
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -30, 1, -60)
scrollFrame.Position = UDim2.new(0, 15, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200) -- Kaydırma alanı
scrollFrame.Parent = panel

-- Başlık bar - Gelişmiş
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 15)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🌟 Frox Hack Ultimate • efeakincipo"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Gelişmiş kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 8)

-- Gelişmiş UI helper fonksiyonları
local contentY = 0

local function makeSection(title, y)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.Position = UDim2.new(0, 0, 0, y)
    section.BackgroundTransparency = 1
    section.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🟢 " .. title
    label.TextColor3 = Color3.fromRGB(100, 255, 100)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return y + 40
end

local function makeButton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(80, 80, 80)
    btnStroke.Thickness = 1
    
    return btn, y + 52
end

local function makeSlider(text, y, currentVal, minVal, maxVal, color)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 65)
    sliderFrame.Position = UDim2.new(0, 0, 0, y)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = scrollFrame
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "📊 " .. text .. " : " .. currentVal
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sliderFrame
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 20)
    bg.Position = UDim2.new(0, 0, 0, 30)
    bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bg.BorderSizePixel = 0
    bg.Parent = sliderFrame
    
    local bgCorner = Instance.new("UICorner", bg)
    bgCorner.CornerRadius = UDim.new(0, 10)
    
    local fill = Instance.new("Frame")
    local frac = (currentVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(frac, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 10)
    
    return lbl, bg, fill, minVal, maxVal, y + 75
end

-- GUI oluşturma
contentY = makeSection("UÇUŞ ÖZELLİKLERİ", contentY)

local flyBtn, contentY = makeButton("🛸 Fly: Kapalı (F Tuşu)", contentY, Color3.fromRGB(70, 70, 180))
local antiGravityBtn, contentY = makeButton("🪂 Anti-Gravity: Kapalı", contentY, Color3.fromRGB(180, 100, 200))

contentY = contentY + 10
contentY = makeSection("HAREKET ÖZELLİKLERİ", contentY)

local speedBoostBtn, contentY = makeButton("⚡ Hız Artışı: Kapalı", contentY, Color3.fromRGB(255, 165, 0))
local superJumpBtn, contentY = makeButton("🦘 Süper Zıplama: Kapalı", contentY, Color3.fromRGB(255, 100, 100))
local infJumpBtn, contentY = makeButton("∞ Sonsuz Zıplama: Kapalı", contentY, Color3.fromRGB(100, 255, 100))
local noClipBtn, contentY = makeButton("🚷 NoClip: Kapalı", contentY, Color3.fromRGB(180, 70, 70))

contentY = contentY + 10
contentY = makeSection("AYARLAR", contentY)

local flyLabel, flySliderBG, flySliderFill, flyMin, flyMax, contentY = makeSlider("Fly Hızı", contentY, flySpeed, 1, 200, Color3.fromRGB(100, 100, 255))
local walkLabel, walkSliderBG, walkSliderFill, walkMin, walkMax, contentY = makeSlider("Yürüme Hızı", contentY, walkSpeed, 16, 150, Color3.fromRGB(100, 255, 100))
local jumpLabel, jumpSliderBG, jumpSliderFill, jumpMin, jumpMax, contentY = makeSlider("Zıplama Gücü", contentY, jumpPower, 50, 300, Color3.fromRGB(255, 100, 100))

contentY = contentY + 10
contentY = makeSection("GELİŞMİŞ AYARLAR", contentY)

local flyKeyBtn, contentY = makeButton("⌨️ Fly Tuşu: F (Değiştir)", contentY, Color3.fromRGB(180, 180, 70))
local antiAFKBtn, contentY = makeButton("⏰ Anti-AFK: Kapalı", contentY, Color3.fromRGB(70, 180, 180))
local espBtn, contentY = makeButton("🎯 ESP: Kapalı", contentY, Color3.fromRGB(255, 50, 50))

-- Canvas size'ı güncelle
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentY + 20)

-- Panel animasyonları
local panelOpen = false
local openTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5, -250, 0.05, 0)}
local closeGoal = {Position = UDim2.new(0.5, -250, -1, 0)}

local function togglePanel()
    if not panelOpen then
        TweenService:Create(panel, openTweenInfo, openGoal):Play()
        panelOpen = true
    else
        TweenService:Create(panel, closeTweenInfo, closeGoal):Play()
        panelOpen = false
    end
end

mainButton.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(togglePanel)

-- ESP SİSTEMİ FONKSİYONLARI --

-- ESP kutusu oluşturma
local function createESPBox(player)
    if espStore[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_" .. player.Name
    box.Adornee = humanoidRootPart
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(3, 5, 1)
    box.Transparency = 0.3
    box.Color3 = espColors[math.random(1, #espColors)]
    box.Parent = humanoidRootPart
    
    -- İsim etiketi
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name_" .. player.Name
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = humanoidRootPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = box.Color3
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    -- Sağlık çubuğu
    local healthBar = Instance.new("BillboardGui")
    healthBar.Name = "ESP_Health_" .. player.Name
    healthBar.Adornee = humanoidRootPart
    healthBar.Size = UDim2.new(0, 100, 0, 10)
    healthBar.StudsOffset = Vector3.new(0, 2.5, 0)
    healthBar.AlwaysOnTop = true
    healthBar.Parent = humanoidRootPart
    
    local healthBackground = Instance.new("Frame")
    healthBackground.Size = UDim2.new(1, 0, 1, 0)
    healthBackground.BackgroundColor3 = Color3.new(0, 0, 0)
    healthBackground.BorderSizePixel = 1
    healthBackground.BorderColor3 = Color3.new(1, 1, 1)
    healthBackground.Parent = healthBar
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBackground
    
    espStore[player] = {
        Box = box,
        Billboard = billboard,
        HealthBar = healthBar,
        HealthFill = healthFill
    }
    
    -- Sağlık takibi
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function()
            if espStore[player] and espStore[player].HealthFill then
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                espStore[player].HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                
                -- Sağlık rengi değişimi
                if healthPercent > 0.5 then
                    espStore[player].HealthFill.BackgroundColor3 = Color3.new(0, 1, 0)
                elseif healthPercent > 0.2 then
                    espStore[player].HealthFill.BackgroundColor3 = Color3.new(1, 1, 0)
                else
                    espStore[player].HealthFill.BackgroundColor3 = Color3.new(1, 0, 0)
                end
            end
        end)
    end
end

-- ESP'yi kaldırma
local function removeESP(player)
    if espStore[player] then
        for _, item in pairs(espStore[player]) do
            if item and item.Parent then
                item:Destroy()
            end
        end
        espStore[player] = nil
    end
end

-- Tüm oyuncular için ESP'yi aç/kapa
local function toggleAllESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        -- Mevcut oyunculara ESP ekle
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                if player.Character then
                    createESPBox(player)
                end
                player.CharacterAdded:Connect(function(character)
                    wait(1) -- Karakterin yüklenmesini bekle
                    if espEnabled then
                        createESPBox(player)
                    end
                end)
            end
        end
        
        -- Yeni oyuncuları takip et
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                wait(1)
                if espEnabled then
                    createESPBox(player)
                end
            end)
        end)
        
        espBtn.Text = "🎯 ESP: Açık"
    else
        -- Tüm ESP'leri kaldır
        for player, _ in pairs(espStore) do
            removeESP(player)
        end
        espStore = {}
        espBtn.Text = "🎯 ESP: Kapalı"
    end
end

-- Duvarın arkasından görünebilirlik (Occlusion)
local function updateESPVisibility()
    if not espEnabled then return end
    
    local localPlayer = Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    if not localRoot then return end
    
    for player, espData in pairs(espStore) do
        if player.Character and espData.Box then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                -- Raycast ile duvar kontrolü
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = {localCharacter, player.Character}
                
                local direction = (targetRoot.Position - localRoot.Position)
                local raycastResult = workspace:Raycast(localRoot.Position, direction, raycastParams)
                
                if raycastResult then
                    -- Duvar var, daha şeffaf yap
                    espData.Box.Transparency = 0.7
                    if espData.Billboard then
                        espData.Billboard.Enabled = false
                    end
                else
                    -- Duvar yok, normal görünüm
                    espData.Box.Transparency = 0.3
                    if espData.Billboard then
                        espData.Billboard.Enabled = true
                    end
                end
            end
        end
    end
end

-- YENİ HİLE SİSTEMLERİ --

-- ⚡ Hız Artışı
local function toggleSpeedBoost()
    speedBoost = not speedBoost
    if speedBoost then
        walkSpeed = walkSpeed * 3
        speedBoostBtn.Text = "⚡ Hız Artışı: Açık"
    else
        walkSpeed = walkSpeed / 3
        speedBoostBtn.Text = "⚡ Hız Artışı: Kapalı"
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
    end
end

-- 🦘 Süper Zıplama
local function toggleSuperJump()
    superJump = not superJump
    if superJump then
        jumpPower = jumpPower * 2
        superJumpBtn.Text = "🦘 Süper Zıplama: Açık"
    else
        jumpPower = jumpPower / 2
        superJumpBtn.Text = "🦘 Süper Zıplama: Kapalı"
    end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = jumpPower
    end
end

-- ∞ Sonsuz Zıplama
local function toggleInfJump()
    infJump = not infJump
    infJumpBtn.Text = infJump and "∞ Sonsuz Zıplama: Açık" or "∞ Sonsuz Zıplama: Kapalı"
end

-- 🪂 Anti-Gravity
local function toggleAntiGravity()
    antiGravity = not antiGravity
    antiGravityBtn.Text = antiGravity and "🪂 Anti-Gravity: Açık" or "🪂 Anti-Gravity: Kapalı"
    
    if antiGravity then
        RunService.Heartbeat:Connect(function()
            if not antiGravity then return end
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.Velocity = Vector3.new(
                    character.HumanoidRootPart.Velocity.X,
                    0,
                    character.HumanoidRootPart.Velocity.Z
                )
            end
        end)
    end
end

-- Fly Sistemi (Önceki gibi)
local function startFly()
    if flying then return end
    flying = true
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        flying = false
        return
    end
    
    local rootPart = character.HumanoidRootPart
    
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    
    bodyGyro = Instance.new("BodyGyro")
    bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 10000
    bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    bodyVelocity.Parent = rootPart
    
    character.Humanoid.PlatformStand = true
    
    flyBtn.Text = "🛸 Fly: Açık (F Tuşu)"
    
    local flyLoop
    flyLoop = RunService.Heartbeat:Connect(function()
        if not flying or not character or not rootPart.Parent then
            flyLoop:Disconnect()
            return
        end
        
        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame
        
        local direction = Vector3.new()
        if control.F > 0 then direction += cam.CFrame.LookVector end
        if control.B > 0 then direction -= cam.CFrame.LookVector end
        if control.L > 0 then direction -= cam.CFrame.RightVector end
        if control.R > 0 then direction += cam.CFrame.RightVector end
        if control.U > 0 then direction += Vector3.new(0, 1, 0) end
        if control.D > 0 then direction += Vector3.new(0, -1, 0) end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        
        bodyVelocity.Velocity = direction * flySpeed
    end)
end

local function stopFly()
    flying = false
    local character = player.Character
    if character then
        character.Humanoid.PlatformStand = false
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
    end
    flyBtn.Text = "🛸 Fly: Kapalı (F Tuşu)"
end

-- Anti-AFK
local antiAFK = false
local function toggleAntiAFK()
    antiAFK = not antiAFK
    if antiAFK then
        local virtualUser = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:connect(function()
            virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            wait(1)
            virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        antiAFKBtn.Text = "⏰ Anti-AFK: Açık"
    else
        antiAFKBtn.Text = "⏰ Anti-AFK: Kapalı"
    end
end

-- Kontrol sistemi
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == flyKey then
        if flying then stopFly() else startFly() end
    end
    
    -- Sonsuz zıplama
    if infJump and input.KeyCode == Enum.KeyCode.Space then
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    if flying then
        local key = input.KeyCode
        if key == Enum.KeyCode.W then control.F = 1
        elseif key == Enum.KeyCode.S then control.B = 1
        elseif key == Enum.KeyCode.A then control.L = 1
        elseif key == Enum.KeyCode.D then control.R = 1
        elseif key == Enum.KeyCode.Space then control.U = 1
        elseif key == Enum.KeyCode.LeftShift then control.D = 1 end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then control.F = 0
    elseif key == Enum.KeyCode.S then control.B = 0
    elseif key == Enum.KeyCode.A then control.L = 0
    elseif key == Enum.KeyCode.D then control.R = 0
    elseif key == Enum.KeyCode.Space then control.U = 0
    elseif key == Enum.KeyCode.LeftShift then control.D = 0 end
end)

-- Buton event'leri
flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

noClipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noClipBtn.Text = noclip and "🚷 NoClip: Açık" or "🚷 NoClip: Kapalı"
end)

speedBoostBtn.MouseButton1Click:Connect(toggleSpeedBoost)
superJumpBtn.MouseButton1Click:Connect(toggleSuperJump)
infJumpBtn.MouseButton1Click:Connect(toggleInfJump)
antiGravityBtn.MouseButton1Click:Connect(toggleAntiGravity)
antiAFKBtn.MouseButton1Click:Connect(toggleAntiAFK)
espBtn.MouseButton1Click:Connect(toggleAllESP) -- ESP butonu güncellendi

-- Fly tuş değiştirme
local waitingForKey = false
flyKeyBtn.MouseButton1Click:Connect(function()
    if not waitingForKey then
        waitingForKey = true
        flyKeyBtn.Text = "⌨️ Yeni tuşa basın..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                flyKey = input.KeyCode
                local keyName = tostring(flyKey):gsub("Enum.KeyCode.", "")
                flyKeyBtn.Text = "⌨️ Fly Tuşu: " .. keyName
                flyBtn.Text = "🛸 Fly: Kapalı (" .. keyName .. " Tuşu)"
                waitingForKey = false
                connection:Disconnect()
            end
        end)
    end
end)

-- Gelişmiş slider sistemi
local function setupSlider(sliderBG, sliderFill, label, minVal, maxVal, onChange)
    local dragging = false
    
    local function updateValue(x)
        local frac = math.clamp(x / sliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + frac * (maxVal - minVal))
        sliderFill.Size = UDim2.new(frac, 0, 1, 0)
        label.Text = string.gsub(label.Text, " : %d+", " : " .. value)
        onChange(value)
    end
    
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position.X - sliderBG.AbsolutePosition.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X - sliderBG.AbsolutePosition.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Slider kurulumu
setupSlider(flySliderBG, flySliderFill, flyLabel, flyMin, flyMax, function(val) flySpeed = val end)
setupSlider(walkSliderBG, walkSliderFill, walkLabel, walkMin, walkMax, function(val) 
    walkSpeed = val 
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
    end
end)
setupSlider(jumpSliderBG, jumpSliderFill, jumpLabel, jumpMin, jumpMax, function(val) 
    jumpPower = val 
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

-- Noclip sistemi
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ESP görünürlük güncelleme loop'u
RunService.Heartbeat:Connect(updateESPVisibility)

-- Oyuncu çıkışında ESP'yi temizle
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Karakter takip sistemi
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    wait(0.5)
    
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = walkSpeed
        character.Humanoid.JumpPower = jumpPower
    end
    
    if flying then
        stopFly()
        wait(0.2)
        startFly()
    end
end)

-- Başlangıç ayarları
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
        humanoid.JumpPower = jumpPower
    end
end

print("🎉 Frox Hack Ultimate yüklendi! Ana butona tıkla.")
