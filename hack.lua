-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- Oyuncu değişkenleri
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- GUI'yi oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedCheatMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Ana menü
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Başlık
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "🔥 GELİŞMİŞ HİLE MENÜSÜ 🔥"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Tab butonları
local tabsFrame = Instance.new("Frame")
tabsFrame.Name = "TabsFrame"
tabsFrame.Size = UDim2.new(1, -20, 0, 30)
tabsFrame.Position = UDim2.new(0, 10, 0, 45)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = mainFrame

local tabs = {"📱 ANA", "⚡ HIZLI", "🎮 ESP", "🔧 GÖRÜNÜM", "⚔️ SAVAŞ"}
local currentTab = "📱 ANA"

local function createTabButton(text, xPos)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = text
    tabButton.Text = text
    tabButton.Size = UDim2.new(0.19, 0, 1, 0)
    tabButton.Position = UDim2.new(xPos, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 11
    tabButton.Parent = tabsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    return tabButton
end

-- Tab içerikleri
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 0, 330)
contentFrame.Position = UDim2.new(0, 10, 0, 85)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

-- ANA TAB (1. Sayfa)
local mainTab = Instance.new("ScrollingFrame")
mainTab.Name = "MainTab"
mainTab.Size = UDim2.new(1, 0, 1, 0)
mainTab.BackgroundTransparency = 1
mainTab.ScrollBarThickness = 4
mainTab.Visible = true
mainTab.Parent = contentFrame

local mainList = Instance.new("UIListLayout")
mainList.Padding = UDim.new(0, 5)
mainList.Parent = mainTab

-- HIZLI TAB (2. Sayfa)
local quickTab = Instance.new("ScrollingFrame")
quickTab.Name = "QuickTab"
quickTab.Size = UDim2.new(1, 0, 1, 0)
quickTab.BackgroundTransparency = 1
quickTab.ScrollBarThickness = 4
quickTab.Visible = false
quickTab.Parent = contentFrame

local quickList = Instance.new("UIListLayout")
quickList.Padding = UDim.new(0, 5)
quickList.Parent = quickTab

-- ESP TAB (3. Sayfa)
local espTab = Instance.new("ScrollingFrame")
espTab.Name = "EspTab"
espTab.Size = UDim2.new(1, 0, 1, 0)
espTab.BackgroundTransparency = 1
espTab.ScrollBarThickness = 4
espTab.Visible = false
espTab.Parent = contentFrame

local espList = Instance.new("UIListLayout")
espList.Padding = UDim.new(0, 5)
espList.Parent = espTab

-- GÖRÜNÜM TAB (4. Sayfa)
local visualTab = Instance.new("ScrollingFrame")
visualTab.Name = "VisualTab"
visualTab.Size = UDim2.new(1, 0, 1, 0)
visualTab.BackgroundTransparency = 1
visualTab.ScrollBarThickness = 4
visualTab.Visible = false
visualTab.Parent = contentFrame

local visualList = Instance.new("UIListLayout")
visualList.Padding = UDim.new(0, 5)
visualList.Parent = visualTab

-- SAVAŞ TAB (5. Sayfa)
local combatTab = Instance.new("ScrollingFrame")
combatTab.Name = "CombatTab"
combatTab.Size = UDim2.new(1, 0, 1, 0)
combatTab.BackgroundTransparency = 1
combatTab.ScrollBarThickness = 4
combatTab.Visible = false
combatTab.Parent = contentFrame

local combatList = Instance.new("UIListLayout")
combatList.Padding = UDim.new(0, 5)
combatList.Parent = combatTab

-- Alt bilgi
local footer = Instance.new("Frame")
footer.Name = "Footer"
footer.Size = UDim2.new(1, -20, 0, 30)
footer.Position = UDim2.new(0, 10, 1, -35)
footer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
footer.Parent = mainFrame

local footerCorner = Instance.new("UICorner")
footerCorner.CornerRadius = UDim.new(0, 6)
footerCorner.Parent = footer

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = "✅ MENÜ AKTİF | F9: Aç/Kapa"
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = footer

-- Değişkenler
local ESPEnabled = false
local AimbotEnabled = false
local NoClipEnabled = false
local SpeedEnabled = false
local JumpPowerEnabled = false
local FlyEnabled = false
local InvisibilityEnabled = false
local XRayEnabled = false
local FullBrightEnabled = false
local AntiAfkEnabled = true
local AutoClickerEnabled = false
local TriggerBotEnabled = false
local ESPInstances = {}
local ESPConnections = {}

-- UI element oluşturma fonksiyonu
local function createOption(parent, name, defaultValue, callback)
    local optionFrame = Instance.new("Frame")
    optionFrame.Name = name .. "Frame"
    optionFrame.Size = UDim2.new(1, -10, 0, 30)
    optionFrame.Position = UDim2.new(0, 5, 0, 0)
    optionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    optionFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = optionFrame
    
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = optionFrame
    
    local toggle = Instance.new("TextButton")
    toggle.Name = name .. "Toggle"
    toggle.Text = defaultValue and "✅" or "❌"
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.Parent = optionFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        toggle.Text = defaultValue and "✅" or "❌"
        toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        if callback then
            callback(defaultValue)
        end
    end)
    
    return optionFrame
end

-- ANA TAB İÇERİĞİ
createOption(mainTab, "NO CLIP", false, function(value)
    NoClipEnabled = value
    if value then
        statusLabel.Text = "🔄 NO CLIP AKTİF"
        startNoClip()
    else
        statusLabel.Text = "✅ NO CLIP KAPALI"
        stopNoClip()
    end
end)

createOption(mainTab, "SÜPER HIZ", false, function(value)
    SpeedEnabled = value
    if value then
        statusLabel.Text = "⚡ SÜPER HIZ AKTİF"
        humanoid.WalkSpeed = 100
    else
        statusLabel.Text = "✅ NORMAL HIZ"
        humanoid.WalkSpeed = 16
    end
end)

createOption(mainTab, "SÜPER ZIPLAMA", false, function(value)
    JumpPowerEnabled = value
    if value then
        statusLabel.Text = "🚀 SÜPER ZIPLAMA AKTİF"
        humanoid.JumpPower = 100
    else
        statusLabel.Text = "✅ NORMAL ZIPLAMA"
        humanoid.JumpPower = 50
    end
end)

createOption(mainTab, "UÇMA", false, function(value)
    FlyEnabled = value
    if value then
        statusLabel.Text = "✈️ UÇMA MODU AKTİF"
        startFlying()
    else
        statusLabel.Text = "✅ UÇMA MODU KAPALI"
        stopFlying()
    end
end)

createOption(mainTab, "GÖRÜNMEZLİK", false, function(value)
    InvisibilityEnabled = value
    if value then
        statusLabel.Text = "👻 GÖRÜNMEZLİK AKTİF"
        makeInvisible()
    else
        statusLabel.Text = "✅ GÖRÜNÜRLÜK"
        makeVisible()
    end
end)

-- HIZLI TAB İÇERİĞİ
createOption(quickTab, "AIMBOT", false, function(value)
    AimbotEnabled = value
    if value then
        statusLabel.Text = "🎯 AIMBOT AKTİF"
        startAimbot()
    else
        statusLabel.Text = "✅ AIMBOT KAPALI"
        stopAimbot()
    end
end)

createOption(quickTab, "TRIGGER BOT", false, function(value)
    TriggerBotEnabled = value
    if value then
        statusLabel.Text = "🔫 TRIGGER BOT AKTİF"
        startTriggerBot()
    else
        statusLabel.Text = "✅ TRIGGER BOT KAPALI"
        stopTriggerBot()
    end
end)

createOption(quickTab, "OTO TIKLAYICI", false, function(value)
    AutoClickerEnabled = value
    if value then
        statusLabel.Text = "⚡ OTO TIKLAYICI AKTİF (20 CPS)"
        startAutoClicker()
    else
        statusLabel.Text = "✅ OTO TIKLAYICI KAPALI"
        stopAutoClicker()
    end
end)

createOption(quickTab, "IŞINLANMA HILESİ", false, function(value)
    if value then
        statusLabel.Text = "🌀 IŞINLANMA AKTİF"
        setupTeleport()
    else
        statusLabel.Text = "✅ IŞINLANMA KAPALI"
    end
end)

createOption(quickTab, "SİLAHSIZ VURMA", false, function(value)
    if value then
        statusLabel.Text = "👊 SİLAHSIZ VURMA AKTİF"
        setupFistPunch()
    else
        statusLabel.Text = "✅ NORMAL VURMA"
    end
end)

-- ESP TAB İÇERİĞİ
createOption(espTab, "OYUNCU ESP", false, function(value)
    ESPEnabled = value
    if value then
        statusLabel.Text = "👁️ OYUNCU ESP AKTİF"
        startESP()
    else
        statusLabel.Text = "✅ ESP KAPALI"
        stopESP()
    end
end)

createOption(espTab, "ESP İSİMLERİ", true, function(value)
    -- ESP isimlerini göster/gizle
end)

createOption(espTab, "ESP CAN ÇUBUĞU", true, function(value)
    -- ESP can çubuğunu göster/gizle
end)

createOption(espTab, "ESP UZAKLIK", true, function(value)
    -- ESP mesafeyi göster/gizle
end)

createOption(espTab, "ESP TÜM EŞYALAR", false, function(value)
    -- Tüm eşyaları göster
end)

-- GÖRÜNÜM TAB İÇERİĞİ
createOption(visualTab, "X-RAY GÖRÜŞ", false, function(value)
    XRayEnabled = value
    if value then
        statusLabel.Text = "🔍 X-RAY AKTİF"
        enableXRay()
    else
        statusLabel.Text = "✅ NORMAL GÖRÜŞ"
        disableXRay()
    end
end)

createOption(visualTab, "FULL BRIGHT", false, function(value)
    FullBrightEnabled = value
    if value then
        statusLabel.Text = "💡 FULL BRIGHT AKTİF"
        enableFullBright()
    else
        statusLabel.Text = "✅ NORMAL AYDINLATMA"
        disableFullBright()
    end
end)

createOption(visualTab, "GÖKYÜZÜNÜ KALDIR", false, function(value)
    if value then
        statusLabel.Text = "☁️ GÖKYÜZÜ KALDIRILDI"
        removeSky()
    else
        statusLabel.Text = "✅ GÖKYÜZÜ GERİ"
        restoreSky()
    end
end)

createOption(visualTab, "KARANLIK MOD", false, function(value)
    if value then
        statusLabel.Text = "🌙 KARANLIK MOD AKTİF"
        enableDarkMode()
    else
        statusLabel.Text = "✅ AYDINLIK MOD"
        disableDarkMode()
    end
end)

-- SAVAŞ TAB İÇERİĞİ
createOption(combatTab, "OTO SAVUNMA", false, function(value)
    if value then
        statusLabel.Text = "🛡️ OTO SAVUNMA AKTİF"
        setupAutoDefense()
    else
        statusLabel.Text = "✅ NORMAL SAVUNMA"
    end
end)

createOption(combatTab, "HASAR ARTTIRICI", false, function(value)
    if value then
        statusLabel.Text = "💥 HASAR X2 AKTİF"
        setupDamageBoost()
    else
        statusLabel.Text = "✅ NORMAL HASAR"
    end
end)

createOption(combatTab, "CAN HİLESİ", false, function(value)
    if value then
        statusLabel.Text = "❤️ CAN HİLESİ AKTİF"
        setupHealthHack()
    else
        statusLabel.Text = "✅ NORMAL CAN"
    end
end)

createOption(combatTab, "SÜREKLİ SALDIRI", false, function(value)
    if value then
        statusLabel.Text = "⚔️ SÜREKLİ SALDIRI AKTİF"
        setupRapidAttack()
    else
        statusLabel.Text = "✅ NORMAL SALDIRI"
    end
end)

-- Tab butonlarını oluştur
for i, tabName in ipairs(tabs) do
    local tabBtn = createTabButton(tabName, (i-1) * 0.2)
    
    tabBtn.MouseButton1Click:Connect(function()
        currentTab = tabName
        
        -- Tüm tab'ları gizle
        mainTab.Visible = false
        quickTab.Visible = false
        espTab.Visible = false
        visualTab.Visible = false
        combatTab.Visible = false
        
        -- Seçili tab'ı göster
        if tabName == "📱 ANA" then
            mainTab.Visible = true
        elseif tabName == "⚡ HIZLI" then
            quickTab.Visible = true
        elseif tabName == "🎮 ESP" then
            espTab.Visible = true
        elseif tabName == "🔧 GÖRÜNÜM" then
            visualTab.Visible = true
        elseif tabName == "⚔️ SAVAŞ" then
            combatTab.Visible = true
        end
        
        -- Tüm tab butonlarını sıfırla
        for _, btn in ipairs(tabsFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        
        -- Seçili tab'ı işaretle
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

-- NO CLIP fonksiyonu
local noclipConnection
local function startNoClip()
    noclipConnection = RunService.Stepped:Connect(function()
        if NoClipEnabled and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- UÇMA fonksiyonu
local flyConnection
local flySpeed = 50
local flyKeys = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
    [Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
    [Enum.KeyCode.LeftShift] = Vector3.new(0, -1, 0)
}

local function startFlying()
    flyConnection = RunService.Heartbeat:Connect(function(delta)
        if FlyEnabled and humanoidRootPart then
            local velocity = Vector3.zero
            for key, direction in pairs(flyKeys) do
                if UserInputService:IsKeyDown(key) then
                    velocity = velocity + direction
                end
            end
            
            if velocity.Magnitude > 0 then
                velocity = velocity.Unit * flySpeed
                humanoidRootPart.Velocity = velocity
            else
                humanoidRootPart.Velocity = Vector3.zero
            end
            
            humanoid.PlatformStand = true
        end
    end)
end

local function stopFlying()
    if flyConnection then
        flyConnection:Disconnect()
    end
    humanoid.PlatformStand = false
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.zero
    end
end

-- GÖRÜNMEZLİK fonksiyonu
local function makeInvisible()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            elseif part:IsA("Decal") then
                part.Transparency = 1
            end
        end
    end
end

local function makeVisible()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            elseif part:IsA("Decal") then
                part.Transparency = 0
            end
        end
    end
end

-- AIMBOT fonksiyonu
local aimbotConnection
local aimbotRange = 100
local aimbotSmoothness = 0.2

local function startAimbot()
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local closestPlayer = nil
            local closestDistance = aimbotRange
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character then
                local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local camera = Workspace.CurrentCamera
                    local targetPos = targetRoot.Position + Vector3.new(0, 1.5, 0)
                    local cameraPos = camera.CFrame.Position
                    local direction = (targetPos - cameraPos).Unit
                    
                    local currentLook = camera.CFrame.LookVector
                    local smoothLook = currentLook:Lerp(direction, aimbotSmoothness)
                    
                    camera.CFrame = CFrame.new(cameraPos, cameraPos + smoothLook)
                end
            end
        end
    end)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
    end
end

-- TRIGGER BOT fonksiyonu
local triggerConnection
local function startTriggerBot()
    triggerConnection = RunService.RenderStepped:Connect(function()
        if TriggerBotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local mouse = Players.LocalPlayer:GetMouse()
            local target = mouse.Target
            
            if target and target.Parent then
                local humanoid = target.Parent:FindFirstChild("Humanoid") or target.Parent.Parent:FindFirstChild("Humanoid")
                if humanoid then
                    -- Oto ateş etme simülasyonu
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, false)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, false)
                end
            end
        end
    end)
end

local function stopTriggerBot()
    if triggerConnection then
        triggerConnection:Disconnect()
    end
end

-- AUTO CLICKER fonksiyonu
local clickerConnection
local function startAutoClicker()
    local cps = 20 -- Click per second
    clickerConnection = RunService.Heartbeat:Connect(function()
        if AutoClickerEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, nil, false)
            task.wait(1/cps)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, nil, false)
        end
    end)
end

local function stopAutoClicker()
    if clickerConnection then
        clickerConnection:Disconnect()
    end
end

-- IŞINLANMA fonksiyonu
local function setupTeleport()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.T then
            local mouse = Players.LocalPlayer:GetMouse()
            local targetPos = mouse.Hit.Position + Vector3.new(0, 5, 0)
            
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(targetPos)
            end
        end
    end)
end

-- SİLAHSIZ VURMA
local function setupFistPunch()
    local originalPunch = nil
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not humanoid then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            -- Uzak mesafeden vurma simülasyonu
            local ray = Ray.new(humanoidRootPart.Position, humanoidRootPart.CFrame.LookVector * 50)
            local hit, position = Workspace:FindPartOnRay(ray, character)
            
            if hit and hit.Parent then
                local targetHumanoid = hit.Parent:FindFirstChild("Humanoid")
                if targetHumanoid then
                    -- Hasarlı vuruş (normalden fazla)
                    targetHumanoid:TakeDamage(50)
                    
                    -- Efekt
                    local explosion = Instance.new("Explosion")
                    explosion.Position = position
                    explosion.BlastPressure = 0
                    explosion.BlastRadius = 5
                    explosion.Parent = Workspace
                    
                    task.wait(0.5)
                    explosion:Destroy()
                end
            end
        end
    end)
end

-- ESP fonksiyonları
local function createESP(player)
    local espFrame = Instance.new("BillboardGui")
    espFrame.Name = player.Name .. "ESP"
    espFrame.AlwaysOnTop = true
    espFrame.Size = UDim2.new(0, 200, 0, 50)
    espFrame.ExtentsOffset = Vector3.new(0, 3, 0)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Text = player.Name
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = espFrame
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    distanceLabel.TextSize = 12
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = espFrame
    
    if player.Character then
        local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRoot then
            espFrame.Adornee = humanoidRoot
            espFrame.Parent = player.Character
        end
    end
    
    ESPInstances[player] = espFrame
end

local function startESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            createESP(player)
        end
    end
    
    local playerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        createESP(player)
    end)
    
    local playerRemoving = Players.PlayerRemoving:Connect(function(player)
        if ESPInstances[player] then
            ESPInstances[player]:Destroy()
            ESPInstances[player] = nil
        end
    end)
    
    -- Mesafe güncelleme
    local updateConnection = RunService.Heartbeat:Connect(function()
        for player, esp in pairs(ESPInstances) do
            if player.Character and humanoidRootPart then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                    esp.DistanceLabel.Text = string.format("%.1fm", distance)
                    
                    -- Can durumuna göre renk
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        if healthPercent > 0.7 then
                            esp.NameLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                        elseif healthPercent > 0.3 then
                            esp.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 50)
                        else
                            esp.NameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                        end
                    end
                end
            end
        end
    end)
    
    ESPConnections = {playerAdded, playerRemoving, updateConnection}
end

local function stopESP()
    for _, connection in pairs(ESPConnections) do
        connection:Disconnect()
    end
    
    for _, esp in pairs(ESPInstances) do
        esp:Destroy()
    end
    
    ESPInstances = {}
    ESPConnections = {}
end

-- X-RAY fonksiyonu
local originalTransparencies = {}
local function enableXRay()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 0.5 then
            originalTransparencies[part] = part.Transparency
            part.Transparency = 0.5
            part.LocalTransparencyModifier = 0.5
        end
    end
end

local function disableXRay()
    for part, transparency in pairs(originalTransparencies) do
        if part and part.Parent then
            part.Transparency = transparency
            part.LocalTransparencyModifier = 0
        end
    end
    originalTransparencies = {}
end

-- FULL BRIGHT fonksiyonu
local function enableFullBright()
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

local function disableFullBright()
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    Lighting.Brightness = 1
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
end

-- GÖKYÜZÜ fonksiyonu
local originalSky
local function removeSky()
    originalSky = Lighting:FindFirstChildOfClass("Sky")
    if originalSky then
        originalSky:Destroy()
    end
end

local function restoreSky()
    if originalSky and not Lighting:FindFirstChildOfClass("Sky") then
        originalSky:Clone().Parent = Lighting
    end
end

-- KARANLIK MOD
local function enableDarkMode()
    Lighting.Ambient = Color3.new(0.1, 0.1, 0.1)
    Lighting.Brightness = 0.5
    Lighting.OutdoorAmbient = Color3.new(0.1, 0.1, 0.1)
end

local function disableDarkMode()
    Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    Lighting.Brightness = 1
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
end

-- OTO SAVUNMA
local function setupAutoDefense()
    RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.Health < 50 then
            -- Düşük can durumunda otomatik kaçış
            humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -20)
        end
    end)
end

-- HASAR ARTTIRICI
local function setupDamageBoost()
    -- Hasarlı vuruşlar için
    local originalTakeDamage
    originalTakeDamage = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if method == "TakeDamage" and self:IsA("Humanoid") then
            -- Hasarı iki katına çıkar
            args[1] = args[1] * 2
            return originalTakeDamage(self, unpack(args))
        end
        
        return originalTakeDamage(self, ...)
    end)
end

-- CAN HİLESİ
local function setupHealthHack()
    RunService.Heartbeat:Connect(function()
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

-- SÜREKLİ SALDIRI
local function setupRapidAttack()
    local attacking = false
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.G then
            attacking = not attacking
            
            while attacking and humanoid do
                -- Saldırı animasyonu
                if humanoidRootPart then
                    -- Etrafa hasar verme
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= Players.LocalPlayer and player.Character then
                            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                                if distance < 10 then
                                    local humanoid = player.Character:FindFirstChild("Humanoid")
                                    if humanoid then
                                        humanoid:TakeDamage(10)
                                    end
                                end
                            end
                        end
                    end
                end
                
                task.wait(0.1)
            end
        end
    end)
end

-- MENÜ KONTROLLERİ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F9 ile menüyü aç/kapa
    if input.KeyCode == Enum.KeyCode.F9 then
        mainFrame.Visible = not mainFrame.Visible
        statusLabel.Text = mainFrame.Visible and "✅ MENÜ AKTİF" or "⏸️ MENÜ GİZLİ"
    end
    
    -- INSERT ile hızlı menü
    if input.KeyCode == Enum.KeyCode.Insert then
        local quickMenu = Instance.new("Frame")
        quickMenu.Size = UDim2.new(0, 150, 0, 200)
        quickMenu.Position = UDim2.new(0, 10, 0, 10)
        quickMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        quickMenu.BorderSizePixel = 0
        quickMenu.Parent = screenGui
        
        local options = {
            {"⚡ Hız", function() humanoid.WalkSpeed = 50 end},
            {"🚀 Zıpla", function() humanoid.JumpPower = 100 end},
            {"👻 Görünmez", function() makeInvisible() end},
            {"🔫 Aimbot", function() AimbotEnabled = not AimbotEnabled end},
            {"👁️ ESP", function() ESPEnabled = not ESPEnabled end}
        }
        
        for i, option in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Text = option[1]
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.Position = UDim2.new(0, 5, 0, (i-1)*35 + 5)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.MouseButton1Click:Connect(option[2])
            btn.Parent = quickMenu
            
            task.delay(3, function()
                quickMenu:Destroy()
            end)
        end
    end
end)

-- Anti-AFK
if AntiAfkEnabled then
    local virtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        virtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        virtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

-- Karakter değişikliklerini dinle
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    
    -- Ayarları yeni karaktere uygula
    if SpeedEnabled then
        humanoid.WalkSpeed = 100
    end
    if JumpPowerEnabled then
        humanoid.JumpPower = 100
    end
    if InvisibilityEnabled then
        makeInvisible()
    end
end)

-- Başlangıç mesajı
print("==========================================")
print("🔥 GELİŞMİŞ HİLE MENÜSÜ YÜKLENDİ!")
print("==========================================")
print("🎮 ANAHTARLAR:")
print("   • F9 - Menüyü Aç/Kapa")
print("   • INSERT - Hızlı Menü")
print("   • T - Işınlan (farenin olduğu yere)")
print("   • F - Uzaktan vurma")
print("   • G - Sürekli saldırı")
print("==========================================")
print("📊 ÖZELLİKLER:")
print("   • 5 Farklı Menü Sekmesi")
print("   • ESP (İsim, Mesafe, Can)")
print("   • Aimbot + Trigger Bot")
print("   • NoClip + Uçma Modu")
print("   • Görünmezlik + X-Ray")
print("   • Oto Tıklayıcı (20 CPS)")
print("   • Süper Hız/Zıplama")
print("   • Işınlanma Hilesi")
print("   • Anti-AFK Sistemi")
print("   • Full Bright + Karanlık Mod")
print("   • Hasarlı vuruşlar")
print("==========================================")
print("⚠️ UYARI: Sadece tek oyunculu veya özel sunucularda kullanın!")
print("==========================================")

-- Güzel animasyon
task.spawn(function()
    while true do
        for i = 0, 1, 0.05 do
            if title then
                local r = math.sin(i * math.pi) * 0.5 + 0.5
                local g = math.sin(i * math.pi + 2) * 0.5 + 0.5
                local b = math.sin(i * math.pi + 4) * 0.5 + 0.5
                title.TextColor3 = Color3.new(r, g, b)
            end
            task.wait(0.05)
        end
    end
end)
