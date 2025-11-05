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
local control = {F = 0, B = 0, L = 0, R = 0}
local bodyGyro, bodyVelocity

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
panel.Size = UDim2.new(0, 400, 0, 420)
panel.Position = UDim2.new(0.5, -200, -1, 0)
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
titleBar.Size = UDim2.new(1, 0, 0, 36)
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
titleLabel.TextSize = 16

-- Kapat
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- Buton ve slider helper
local contentY = 46
local function makeButton(text, y)
    local btn = Instance.new("TextButton", panel)
    btn.Size = UDim2.new(0, 360, 0, 40)
    btn.Position = UDim2.new(0.5, -180, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)
    return btn
end

local function makeSlider(text, y, currentVal, minVal, maxVal, color)
    local lbl = Instance.new("TextLabel", panel)
    lbl.Size = UDim2.new(0, 360, 0, 20)
    lbl.Position = UDim2.new(0.5, -180, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. " " .. currentVal
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = color
    y = y + 24
    local bg = Instance.new("Frame", panel)
    bg.Size = UDim2.new(0, 360, 0, 18)
    bg.Position = UDim2.new(0.5, -180, 0, y)
    bg.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    bg.BorderSizePixel = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 9)
    local fill = Instance.new("Frame", bg)
    local frac = (currentVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(frac, 0, 1, 0)
    fill.BackgroundColor3 = color
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 9)
    return lbl, bg, fill, minVal, maxVal
end

-- Butonlar
local flyBtn = makeButton("Fly: Kapalı", contentY) 
contentY = contentY + 52

local noclipBtn = makeButton("Duvardan Geçme: Kapalı", contentY) 
contentY = contentY + 52

local invisibleBtn = makeButton("Görünmezlik: Kapalı", contentY) 
contentY = contentY + 52

-- Sliderlar
local flyLabel, flySliderBG, flySliderFill, flyMin, flyMax = makeSlider("Fly Hızı:", contentY, flySpeed, 1, 200, Color3.fromRGB(120, 120, 255)) 
contentY = contentY + 34

local walkLabel, walkSliderBG, walkSliderFill, walkMin, walkMax = makeSlider("Walk Speed:", contentY, walkSpeed, 0, 100, Color3.fromRGB(120, 255, 120)) 
contentY = contentY + 34

local jumpLabel, jumpSliderBG, jumpSliderFill, jumpMin, jumpMax = makeSlider("Jump Power:", contentY, jumpPower, 0, 200, Color3.fromRGB(255, 120, 120)) 
contentY = contentY + 34

-- Panel animasyon
local panelOpen = false
local openTweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5, -200, 0.1, 0)}
local closeGoal = {Position = UDim2.new(0.5, -200, -1, 0)}

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
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    
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
    
    -- Fly render loop
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying or not character or not rootPart.Parent then
            flyConnection:Disconnect()
            return
        end
        
        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame
        
        -- Tüm yönler için kontrol
        local direction = Vector3.new()
        if control.F > 0 then direction = direction + cam.CFrame.LookVector end
        if control.B > 0 then direction = direction - cam.CFrame.LookVector end
        if control.L > 0 then direction = direction - cam.CFrame.RightVector end
        if control.R > 0 then direction = direction + cam.CFrame.RightVector end
        
        -- Y ekseni için kontrol (Space ve Shift)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            direction = direction + Vector3.new(0, -1, 0)
        end
        
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
end

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

-- Görünmezlik fonksiyonu
local function toggleInvisibility()
    invisible = not invisible
    local character = player.Character
    
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                if invisible then
                    part.Transparency = 1
                    -- Decal'leri de gizle
                    for _, decal in pairs(part:GetChildren()) do
                        if decal:IsA("Decal") then
                            decal.Transparency = 1
                        end
                    end
                else
                    part.Transparency = 0
                    -- Decal'leri geri getir
                    for _, decal in pairs(part:GetChildren()) do
                        if decal:IsA("Decal") then
                            decal.Transparency = 0
                        end
                    end
                end
            elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                local handle = part.Handle
                if invisible then
                    handle.Transparency = 1
                else
                    handle.Transparency = 0
                end
            end
        end
        
        -- Humanoid'i de gizle/göster (bazı oyunlarda gerekli)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if invisible then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            else
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end
    
    invisibleBtn.Text = invisible and "Görünmezlik: Açık" or "Görünmezlik: Kapalı"
end

-- Hareket hızı fonksiyonları
local function updateWalkSpeed()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
    end
end

local function updateJumpPower()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = jumpPower
    end
end

-- Klavye kontrolleri
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        control.F = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        control.B = -1
    elseif input.KeyCode == Enum.KeyCode.A then
        control.L = -1
    elseif input.KeyCode == Enum.KeyCode.D then
        control.R = 1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        control.F = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        control.B = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        control.L = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        control.R = 0
    end
end)

-- Buton eventleri
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        flyBtn.Text = "Fly: Kapalı"
    else
        startFly()
        flyBtn.Text = "Fly: Açık"
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "Duvardan Geçme: Açık" or "Duvardan Geçme: Kapalı"
end)

invisibleBtn.MouseButton1Click:Connect(toggleInvisibility)

-- Slider eventleri
local draggingFly = false
flySliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFly = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFly and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp(input.Position.X - flySliderBG.AbsolutePosition.X, 0, flySliderBG.AbsoluteSize.X)
        local frac = x / flySliderBG.AbsoluteSize.X
        flySpeed = math.floor(flyMin + frac * (flyMax - flyMin))
        flySliderFill.Size = UDim2.new(frac, 0, 1, 0)
        flyLabel.Text = "Fly Hızı: " .. flySpeed
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
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWalk and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp(input.Position.X - walkSliderBG.AbsolutePosition.X, 0, walkSliderBG.AbsoluteSize.X)
        local frac = x / walkSliderBG.AbsoluteSize.X
        walkSpeed = math.floor(walkMin + frac * (walkMax - walkMin))
        walkSliderFill.Size = UDim2.new(frac, 0, 1, 0)
        walkLabel.Text = "Walk Speed: " .. walkSpeed
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
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingJump and input.UserInputType == Enum.UserInputType.MouseMovement then
        local x = math.clamp(input.Position.X - jumpSliderBG.AbsolutePosition.X, 0, jumpSliderBG.AbsoluteSize.X)
        local frac = x / jumpSliderBG.AbsoluteSize.X
        jumpPower = math.floor(jumpMin + frac * (jumpMax - jumpMin))
        jumpSliderFill.Size = UDim2.new(frac, 0, 1, 0)
        jumpLabel.Text = "Jump Power: " .. jumpPower
        updateJumpPower()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingJump = false
    end
end)

-- Karakter değişikliklerini takip et
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    wait(0.5)
    
    -- Orijinal değerleri al
    getOriginalValues()
    
    -- Slider değerlerini güncelle
    walkSpeed = originalWalkSpeed
    jumpPower = originalJumpPower
    
    -- UI'ı güncelle
    walkLabel.Text = "Walk Speed: " .. walkSpeed
    jumpLabel.Text = "Jump Power: " .. jumpPower
    
    local walkFrac = (walkSpeed - walkMin) / (walkMax - walkMin)
    local jumpFrac = (jumpPower - jumpMin) / (jumpMax - jumpMin)
    
    walkSliderFill.Size = UDim2.new(walkFrac, 0, 1, 0)
    jumpSliderFill.Size = UDim2.new(jumpFrac, 0, 1, 0)
    
    updateWalkSpeed()
    updateJumpPower()
    
    if flying then
        stopFly()
        wait(0.1)
        startFly()
    end
    
    if invisible then
        wait(0.5)
        -- Görünmezlik durumunu sıfırla
        invisible = false
        invisibleBtn.Text = "Görünmezlik: Kapalı"
    end
end)

-- Başlangıç ayarları
getOriginalValues()
if player.Character then
    updateWalkSpeed()
    updateJumpPower()
end
