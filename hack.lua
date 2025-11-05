-- Frox Hack GUI | LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Durumlar
local flying, noclip, invisible = false, false, false
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50
local control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local bodyGyro, bodyVelocity
local flyKey = Enum.KeyCode.F

-- Orijinal değerleri sakla
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 120, 0, 50)
mainButton.Position = UDim2.new(0, 50, 0, 150)
mainButton.Text = "Frox Hack"
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 18
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainButton.BorderSizePixel = 0
mainButton.AutoButtonColor = true
mainButton.Active = true
mainButton.Parent = screenGui
local mbCorner = Instance.new("UICorner", mainButton)
mbCorner.CornerRadius = UDim.new(0, 15)
mainButton.Draggable = true

-- Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 450, 0, 500)
panel.Position = UDim2.new(0.5, -225, -1, 0)
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panel.BorderSizePixel = 0
panel.Parent = screenGui
panel.ClipsDescendants = true
local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 10)

-- Panel draggable
local draggingPanel = false
local dragInput, dragStart, startPos
local titleBar = Instance.new("Frame", panel)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingPanel and input == dragInput then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingPanel = false
    end
end)

-- Başlık
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Frox Hack  •  efeakincipo"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 18

-- Kapat
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 32, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 6)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- Buton ve slider helper
local contentY = 50

local function makeSection(title, y)
    local sectionLabel = Instance.new("TextLabel", panel)
    sectionLabel.Size = UDim2.new(0, 400, 0, 25)
    sectionLabel.Position = UDim2.new(0.5, -200, 0, y)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = title
    sectionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 16
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    return y + 30
end

local function makeButton(text, y, width)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(0, width or 400, 0, 45)
    btn.Position = UDim2.new(0.5, -200, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    return btn, y + 55
end

local function makeSlider(text, y, currentVal, minVal, maxVal, color)
    local sliderFrame = Instance.new("Frame", panel)
    sliderFrame.Size = UDim2.new(0, 400, 0, 60)
    sliderFrame.Position = UDim2.new(0.5, -200, 0, y)
    sliderFrame.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", sliderFrame)
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. " : " .. currentVal
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local bg = Instance.new("Frame", sliderFrame)
    bg.Size = UDim2.new(1, 0, 0, 20)
    bg.Position = UDim2.new(0, 0, 0, 30)
    bg.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)
    
    local fill = Instance.new("Frame", bg)
    local frac = (currentVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(frac, 0, 1, 0)
    fill.BackgroundColor3 = color
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 10)
    
    return lbl, bg, fill, minVal, maxVal, y + 70
end

-- Bölümler ve Butonlar
contentY = makeSection("TEMEL ÖZELLİKLER", contentY)

local flyBtn, contentY = makeButton("Fly: Kapalı (F Tuşu)", contentY)
local noclipBtn, contentY = makeButton("Duvardan Geçme: Kapalı", contentY)
local invisibleBtn, contentY = makeButton("Görünmezlik: Kapalı", contentY)

contentY = contentY + 10
contentY = makeSection("AYARLAR", contentY)

-- Sliderlar
local flyLabel, flySliderBG, flySliderFill, flyMin, flyMax, contentY = makeSlider("Fly Hızı", contentY, flySpeed, 1, 200, Color3.fromRGB(120, 120, 255))
local walkLabel, walkSliderBG, walkSliderFill, walkMin, walkMax, contentY = makeSlider("Yürüme Hızı", contentY, walkSpeed, 16, 100, Color3.fromRGB(120, 255, 120))
local jumpLabel, jumpSliderBG, jumpSliderFill, jumpMin, jumpMax, contentY = makeSlider("Zıplama Gücü", contentY, jumpPower, 50, 200, Color3.fromRGB(255, 120, 120))

contentY = contentY + 10
contentY = makeSection("TUŞ AYARLARI", contentY)

-- Fly tuş ayarı butonu
local flyKeyBtn, contentY = makeButton("Fly Tuşu: F (Değiştirmek için tıkla)", contentY, 400)

-- Panel animasyon
local panelOpen = false
local openTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5, -225, 0.05, 0)}
local closeGoal = {Position = UDim2.new(0.5, -225, -1, 0)}

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

-- Orijinal değerleri al
local function getOriginalValues()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed
            originalJumpPower = humanoid.JumpPower
            
            -- Slider minimum değerlerini orijinal değerlere ayarla
            walkMin = originalWalkSpeed
            jumpMin = originalJumpPower
            
            -- Eğer mevcut değerler minimumdan düşükse, minimuma ayarla
            if walkSpeed < originalWalkSpeed then
                walkSpeed = originalWalkSpeed
            end
            if jumpPower < originalJumpPower then
                jumpPower = originalJumpPower
            end
        end
    end
end

-- Fly fonksiyonu
local function startFly()
    if flying then return end
    flying = true
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        flying = false
        return
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character.HumanoidRootPart
    
    -- Eski fly bileşenlerini temizle
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    
    -- Yeni fly bileşenleri
    bodyGyro = Instance.new("BodyGyro")
    bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = rootPart
    
    if humanoid then
        humanoid.PlatformStand = true
    end
    
    flyBtn.Text = "Fly: Açık (F Tuşu)"
    
    -- Fly render loop
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying or not character or not rootPart.Parent then
            if flyConnection then
                flyConnection:Disconnect()
            end
            return
        end
        
        local cam = workspace.CurrentCamera
        
        -- Tüm yönler için kontrol
        local direction = Vector3.new()
        
        -- İleri/Geri (W/S)
        if control.F > 0 then 
            direction = direction + cam.CFrame.LookVector 
        elseif control.B > 0 then 
            direction = direction - cam.CFrame.LookVector 
        end
        
        -- Sağ/Sol (D/A)
        if control.R > 0 then 
            direction = direction + cam.CFrame.RightVector 
        elseif control.L > 0 then 
            direction = direction - cam.CFrame.RightVector 
        end
        
        -- Yukarı/Aşağı (Space/Shift)
        if control.U > 0 then 
            direction = direction + Vector3.new(0, 1, 0)
        elseif control.D > 0 then 
            direction = direction + Vector3.new(0, -1, 0)
        end
        
        -- Hızı uygula
        if direction.Magnitude > 0 then
            direction = direction.Unit
        end
        
        bodyVelocity.Velocity = direction * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        
        if bodyGyro then 
            bodyGyro:Destroy() 
            bodyGyro = nil
        end
        if bodyVelocity then 
            bodyVelocity:Destroy() 
            bodyVelocity = nil
        end
    end
    
    flyBtn.Text = "Fly: Kapalı (F Tuşu)"
end

-- Fly tuşu değiştirme
local waitingForFlyKey = false
flyKeyBtn.MouseButton1Click:Connect(function()
    if not waitingForFlyKey then
        waitingForFlyKey = true
        flyKeyBtn.Text = "Yeni tuşa basın..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                flyKey = input.KeyCode
                local keyName = tostring(flyKey):gsub("Enum.KeyCode.", "")
                flyKeyBtn.Text = "Fly Tuşu: " .. keyName .. " (Değiştirmek için tıkla)"
                flyBtn.Text = "Fly: Kapalı (" .. keyName .. " Tuşu)"
                waitingForFlyKey = false
                connection:Disconnect()
            end
        end)
    end
end)

-- GÖRÜNMEZLİK FONKSİYONU - %100 ÇALIŞAN
local originalTransparency = {}
local originalSizes = {}

local function toggleInvisibility()
    invisible = not invisible
    local character = player.Character
    
    if character then
        if invisible then
            -- Görünmez yap
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    -- Orijinal değerleri sakla
                    originalTransparency[part] = part.Transparency
                    originalSizes[part] = part.Size
                    
                    -- Görünmez yap
                    part.Transparency = 1
                    part.CanCollide = false
                    
                    -- Eğer part zaten küçük değilse, mikroskobik yap
                    if part.Size.Magnitude > 0.5 then
                        part.Size = Vector3.new(0.01, 0.01, 0.01)
                    end
                elseif part:IsA("Decal") then
                    originalTransparency[part] = part.Transparency
                    part.Transparency = 1
                elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then
                    part.Enabled = false
                end
            end
            
            -- Humanoid'i gizle
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
            
        else
            -- Görünür yap
            for part, originalTrans in pairs(originalTransparency) do
                if part and part.Parent then
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Transparency = originalTrans
                        part.CanCollide = true
                        
                        -- Orijinal boyutu geri yükle
                        if originalSizes[part] then
                            part.Size = originalSizes[part]
                        end
                    elseif part:IsA("Decal") then
                        part.Transparency = originalTrans
                    elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then
                        part.Enabled = true
                    end
                end
            end
            
            -- Humanoid'i geri getir
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
            
            -- Temizle
            originalTransparency = {}
            originalSizes = {}
        end
    end
    
    invisibleBtn.Text = invisible and "Görünmezlik: Açık" or "Görünmezlik: Kapalı"
end

-- Klavye kontrolleri
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Fly açma/kapama
    if input.KeyCode == flyKey then
        if flying then
            stopFly()
        else
            startFly()
        end
    end
    
    -- Fly kontrolleri
    if flying then
        if input.KeyCode == Enum.KeyCode.W then
            control.F = 1
        elseif input.KeyCode == Enum.KeyCode.S then
            control.B = 1
        elseif input.KeyCode == Enum.KeyCode.A then
            control.L = 1
        elseif input.KeyCode == Enum.KeyCode.D then
            control.R = 1
        elseif input.KeyCode == Enum.KeyCode.Space then
            control.U = 1
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            control.D = 1
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    -- Fly kontrolleri
    if input.KeyCode == Enum.KeyCode.W then
        control.F = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        control.B = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        control.L = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        control.R = 0
    elseif input.KeyCode == Enum.KeyCode.Space then
        control.U = 0
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        control.D = 0
    end
end)

-- Noclip fonksiyonu
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Hareket hızı fonksiyonları - GÜNCELLENMİŞ
local function updateWalkSpeed()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid.WalkSpeed = walkSpeed
        print("WalkSpeed güncellendi: " .. walkSpeed)
    else
        -- Eğer karakter yoksa, bir sonraki karakterde güncelle
        if character then
            character:WaitForChild("Humanoid", 5)
            if character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = walkSpeed
            end
        end
    end
end

local function updateJumpPower()
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid.JumpPower = jumpPower
        print("JumpPower güncellendi: " .. jumpPower)
    else
        -- Eğer karakter yoksa, bir sonraki karakterde güncelle
        if character then
            character:WaitForChild("Humanoid", 5)
            if character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = jumpPower
            end
        end
    end
end

-- Buton eventleri
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "Duvardan Geçme: Açık" or "Duvardan Geçme: Kapalı"
end)

invisibleBtn.MouseButton1Click:Connect(toggleInvisibility)

-- Slider eventleri - GÜNCELLENMİŞ
local draggingFly = false
flySliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFly = true
        -- Anında güncelle
        local x = math.clamp(input.Position.X - flySliderBG.AbsolutePosition.X, 0, flySliderBG.AbsoluteSize.X)
        local frac = x / flySliderBG.AbsoluteSize.X
        flySpeed = math.floor(flyMin + frac * (flyMax - flyMin))
        flySliderFill.Size = UDim2.new(frac, 0, 1, 0)
        flyLabel.Text = "Fly Hızı : " .. flySpeed
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFly and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp(input.Position.X - flySliderBG.AbsolutePosition.X, 0, flySliderBG.AbsoluteSize.X)
        local frac = x / flySliderBG.AbsoluteSize.X
        flySpeed = math.floor(flyMin + frac * (flyMax - flyMin))
        flySliderFill.Size = UDim2.new(frac, 0, 1, 0)
        flyLabel.Text = "Fly Hızı : " .. flySpeed
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFly = false
    end
end)

local draggingWalk = false
walkSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWalk = true
        -- Anında güncelle
        local x = math.clamp(input.Position.X - walkSliderBG.AbsolutePosition.X, 0, walkSliderBG.AbsoluteSize.X)
        local frac = x / walkSliderBG.AbsoluteSize.X
        walkSpeed = math.floor(walkMin + frac * (walkMax - walkMin))
        walkSliderFill.Size = UDim2.new(frac, 0, 1, 0)
        walkLabel.Text = "Yürüme Hızı : " .. walkSpeed
        updateWalkSpeed()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWalk and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp(input.Position.X - walkSliderBG.AbsolutePosition.X, 0, walkSliderBG.AbsoluteSize.X)
        local frac = x / walkSliderBG.AbsoluteSize.X
        walkSpeed = math.floor(walkMin + frac * (walkMax - walkMin))
        walkSliderFill.Size = UDim2.new(frac, 0, 1, 0)
        walkLabel.Text = "Yürüme Hızı : " .. walkSpeed
        updateWalkSpeed()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingWalk = false
    end
end)

local draggingJump = false
jumpSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingJump = true
        -- Anında güncelle
        local x = math.clamp(input.Position.X - jumpSliderBG.AbsolutePosition.X, 0, jumpSliderBG.AbsoluteSize.X)
        local frac = x / jumpSliderBG.AbsoluteSize.X
        jumpPower = math.floor(jumpMin + frac * (jumpMax - jumpMin))
        jumpSliderFill.Size = UDim2.new(frac, 0, 1, 0)
        jumpLabel.Text = "Zıplama Gücü : " .. jumpPower
        updateJumpPower()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingJump and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp(input.Position.X - jumpSliderBG.AbsolutePosition.X, 0, jumpSliderBG.AbsoluteSize.X)
        local frac = x / jumpSliderBG.AbsoluteSize.X
        jumpPower = math.floor(jumpMin + frac * (jumpMax - jumpMin))
        jumpSliderFill.Size = UDim2.new(frac, 0, 1, 0)
        jumpLabel.Text = "Zıplama Gücü : " .. jumpPower
        updateJumpPower()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingJump = false
    end
end)

-- Karakter değişikliklerini takip et - GÜNCELLENMİŞ
player.CharacterAdded:Connect(function(character)
    -- Humanoid'i bekle
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Orijinal değerleri al
    getOriginalValues()
    
    -- Değerleri güncelle
    walkSpeed = originalWalkSpeed
    jumpPower = originalJumpPower
    
    -- UI'ı güncelle
    walkLabel.Text = "Yürüme Hızı : " .. walkSpeed
    jumpLabel.Text = "Zıplama Gücü : " .. jumpPower
    
    local walkFrac = (walkSpeed - walkMin) / (walkMax - walkMin)
    local jumpFrac = (jumpPower - jumpMin) / (jumpMax - jumpMin)
    
    walkSliderFill.Size = UDim2.new(walkFrac, 0, 1, 0)
    jumpSliderFill.Size = UDim2.new(jumpFrac, 0, 1, 0)
    
    -- Hemen güncelle
    updateWalkSpeed()
    updateJumpPower()
    
    -- 1 saniye sonra tekrar kontrol et (güvence)
    wait(1)
    updateWalkSpeed()
    updateJumpPower()
    
    -- Fly durumunu koru
    if flying then
        stopFly()
        wait(0.2)
        startFly()
    end
    
    -- Görünmezlik durumunu koru
    if invisible then
        wait(0.5)
        toggleInvisibility()
    end
end)

-- Başlangıç ayarları
getOriginalValues()
if player.Character then
    updateWalkSpeed()
    updateJumpPower()
    
    -- 2 saniye sonra tekrar kontrol et
    wait(2)
    updateWalkSpeed()
    updateJumpPower()
end

-- Sürekli kontrol (güvence)
while true do
    wait(5)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if humanoid.WalkSpeed ~= walkSpeed then
            humanoid.WalkSpeed = walkSpeed
        end
        if humanoid.JumpPower ~= jumpPower then
            humanoid.JumpPower = jumpPower
        end
    end
end
