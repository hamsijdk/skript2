-- AutoExecutor - LocalScript (StarterPlayerScripts içine)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Otomatik GUI oluştur
wait(1) -- Yükleme için bekle

local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Eski GUI'yi temizle
    if playerGui:FindFirstChild("TeleportGUI") then
        playerGui.TeleportGUI:Destroy()
    end

    -- Yeni GUI oluştur
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGUI"
    screenGui.Parent = playerGui

    -- Ana frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 150)
    mainFrame.Position = UDim2.new(0.5, -150, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- Gölge efekti
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(100, 100, 255)
    shadow.Thickness = 2
    shadow.Parent = mainFrame

    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Text = "🌟 OTOMATİK IŞINLANMA SİSTEMİ"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title

    -- Durum
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 45)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "🔴 SİSTEM HAZIRLANIYOR..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.Parent = mainFrame

    -- Butonlar
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -20, 0, 50)
    buttonContainer.Position = UDim2.new(0, 10, 0, 80)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame

    local activateBtn = Instance.new("TextButton")
    activateBtn.Size = UDim2.new(0.48, 0, 1, 0)
    activateBtn.Position = UDim2.new(0, 0, 0, 0)
    activateBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    activateBtn.Text = "🚀 AKTİF ET (F)"
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.TextSize = 12
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.Parent = buttonContainer

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.48, 0, 1, 0)
    closeBtn.Position = UDim2.new(0.52, 0, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Text = "❌ KAPAT"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = buttonContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = activateBtn
    btnCorner:Clone().Parent = closeBtn

    return screenGui, statusLabel, activateBtn, closeBtn, mainFrame
end

-- Işınlanma sistemi
local function setupTeleportSystem()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    local teleportActive = false
    local gui, statusLabel, activateBtn, closeBtn, mainFrame = createGUI()

    -- Buton eventleri
    activateBtn.MouseButton1Click:Connect(function()
        toggleTeleport()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- F tuşu eventi
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F then
            toggleTeleport()
        end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 and teleportActive then
            teleportToMouse()
        end
        
        -- GUI'yi aç/kapa (Insert tuşu)
        if input.KeyCode == Enum.KeyCode.Insert then
            gui.Enabled = not gui.Enabled
        end
    end)

    function toggleTeleport()
        teleportActive = not teleportActive
        
        if teleportActive then
            statusLabel.Text = "✅ IŞINLANMA AKTİF"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            activateBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 80)
            activateBtn.Text = "🔴 DURDUR (F)"
            
            -- Efekt
            pulseEffect(mainFrame, Color3.fromRGB(80, 255, 80))
        else
            statusLabel.Text = "🔴 IŞINLANMA PASİF"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            activateBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
            activateBtn.Text = "🚀 AKTİF ET (F)"
            
            pulseEffect(mainFrame, Color3.fromRGB(255, 80, 80))
        end
    end

    function teleportToMouse()
        if not teleportActive then return end
        
        local mouse = player:GetMouse()
        local targetPosition = mouse.Hit.Position + Vector3.new(0, 5, 0)
        
        -- Işınlanma efektleri
        createTeleportEffect(hrp.Position, "Başlangıç")
        pulseEffect(mainFrame, Color3.fromRGB(200, 100, 255))
        
        -- Işınlanma
        hrp.CFrame = CFrame.new(targetPosition)
        
        -- Varış efektleri
        createTeleportEffect(targetPosition, "Varış")
        flyEffect()
        
        -- GUI güncelleme
        statusLabel.Text = "🎯 IŞINLANMA TAMAMLANDI!"
        wait(2)
        
        if teleportActive then
            statusLabel.Text = "✅ IŞINLANMA AKTİF"
        end
    end

    function createTeleportEffect(position, type)
        -- Ana part
        local part = Instance.new("Part")
        part.Size = Vector3.new(6, 6, 6)
        part.Position = position
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.BrickColor = type == "Başlangıç" and BrickColor.new("Bright blue") or BrickColor.new("Bright violet")
        part.Transparency = 0.2
        part.Parent = workspace

        -- Işık
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 10
        pointLight.Range = 15
        pointLight.Color = type == "Başlangıç" and Color3.new(0, 0.5, 1) or Color3.new(0.8, 0.2, 1)
        pointLight.Parent = part

        -- Patlama efekti
        local explosion = Instance.new("Explosion")
        explosion.Position = position
        explosion.BlastPressure = 0
        explosion.BlastRadius = 8
        explosion.Visible = false
        explosion.Parent = workspace

        -- Yavaşça kaybolma
        coroutine.wrap(function()
            for i = 1, 15 do
                if part then
                    part.Transparency = part.Transparency + 0.05
                    pointLight.Brightness = pointLight.Brightness - 0.3
                    wait(0.05)
                end
            end
            if part then
                part:Destroy()
            end
        end)()
    end

    function flyEffect()
        -- Yerçekimi etkisini kaldır
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        
        -- Yukarı itiş
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 80, 0)
        bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
        bodyVelocity.Parent = hrp

        -- Süper güçler
        humanoid.WalkSpeed = 50
        humanoid.JumpPower = 120
        
        -- Hover efekti
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.D = 1000
        bodyGyro.Parent = hrp

        -- 4 saniye süper güçler
        wait(4)
        
        -- Normale dön
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end

    function pulseEffect(frame, color)
        local originalColor = frame.BackgroundColor3
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        local tween = TweenService:Create(frame, tweenInfo, {BackgroundColor3 = color})
        tween:Play()
        
        tween.Completed:Connect(function()
            local tweenBack = TweenService:Create(frame, tweenInfo, {BackgroundColor3 = originalColor})
            tweenBack:Play()
        end)
    end

    -- Karakter değişikliği handler
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoid = newChar:WaitForChild("Humanoid")
        hrp = newChar:WaitForChild("HumanoidRootPart")
        
        if teleportActive then
            statusLabel.Text = "✅ IŞINLANMA AKTİF - YENİ KARAKTER"
        end
    end)

    -- Başlangıç mesajı
    statusLabel.Text = "🔵 SİSTEM HAZIR - F TUŞU İLE BAŞLAT"
    pulseEffect(mainFrame, Color3.fromRGB(100, 100, 255))
    
    print("🎯 Otomatik Işınlanma Sistemi Yüklendi!")
    print("🎮 F - Işınlanma Aç/Kapa")
    print("🎮 Insert - GUI Aç/Kapa")
    print("🎮 Sol Tık - Işınlan")
end

-- Sistem başlatma
coroutine.wrap(function()
    wait(2) -- Oyunun yüklenmesini bekle
    setupTeleportSystem()
end)()
