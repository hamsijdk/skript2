-- Frox Hack GUI | Turuncu Kurt Tasarımı
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Turuncu Kurt renkleri
local wolfColors = {
    primary = Color3.fromRGB(255, 140, 0),    -- Ana turuncu
    secondary = Color3.fromRGB(255, 165, 0),  -- Açık turuncu
    accent = Color3.fromRGB(255, 200, 100),   -- Sarımsı turuncu
    dark = Color3.fromRGB(40, 30, 20),        -- Koyu kahve
    background = Color3.fromRGB(25, 20, 15)   -- Arkaplan
}

-- Ayarlar
local flying, noclip, antiGravity = false, false, false
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50
local control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local bodyGyro, bodyVelocity
local flyKey = Enum.KeyCode.F

-- GUI sistemi
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton - Turuncu Kurt
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 120, 0, 45)
mainButton.Position = UDim2.new(0, 20, 0, 20)
mainButton.Text = "🦊 FROX"
mainButton.Font = Enum.Font.GothamBlack
mainButton.TextSize = 16
mainButton.TextColor3 = wolfColors.primary -- Frox yazısı turuncu
mainButton.BackgroundColor3 = Color3.new(0, 0, 0) -- Siyah arkaplan
mainButton.BorderSizePixel = 0
mainButton.AutoButtonColor = true
mainButton.Active = true
mainButton.Parent = screenGui

-- Buton gradient efekti
local buttonGradient = Instance.new("UIGradient")
buttonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.new(0.1, 0.1, 0.1))
})
buttonGradient.Rotation = 45
buttonGradient.Parent = mainButton

local mbCorner = Instance.new("UICorner", mainButton)
mbCorner.CornerRadius = UDim.new(0, 10)
local mbStroke = Instance.new("UIStroke", mainButton)
mbStroke.Color = wolfColors.primary -- Turuncu çerçeve
mbStroke.Thickness = 2

mainButton.Draggable = true

-- Panel - Turuncu Kurt teması
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 0, 0, 500)
panel.Position = UDim2.new(1, -20, 0.5, -250)
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.BackgroundColor3 = wolfColors.background
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = screenGui
panel.ClipsDescendants = true

-- Panel gradient
local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, wolfColors.background),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 25, 15))
})
panelGradient.Parent = panel

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 15)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = wolfColors.primary -- Turuncu çerçeve
panelStroke.Thickness = 2

-- Başlık bar - Turuncu Kurt
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = wolfColors.primary
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

-- Başlık gradient
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, wolfColors.primary),
    ColorSequenceKeypoint.new(1, wolfColors.secondary)
})
titleGradient.Rotation = 90
titleGradient.Parent = titleBar

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 15)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🦊 FROX HACK"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 60)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 6)

-- İçerik alanı
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -70)
contentFrame.Position = UDim2.new(0, 10, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = panel

-- Scroll frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = wolfColors.secondary
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.Parent = contentFrame

-- UI Helper fonksiyonları
local contentY = 0

local function createSection(title, y)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.Position = UDim2.new(0, 0, 0, y)
    section.BackgroundTransparency = 1
    section.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🦊 " .. title
    label.TextColor3 = wolfColors.accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return y + 40
end

local function createButton(text, y, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = wolfColors.dark
    btn.Text = icon .. " " .. text
    btn.TextColor3 = wolfColors.accent
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = scrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = wolfColors.primary -- Turuncu çerçeve
    stroke.Thickness = 1
    stroke.Parent = btn
    
    return btn, y + 50
end

local function createSlider(text, y, currentVal, minVal, maxVal)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 60)
    sliderFrame.Position = UDim2.new(0, 0, 0, y)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. " : " .. currentVal
    label.TextColor3 = wolfColors.accent
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 18)
    bg.Position = UDim2.new(0, 0, 0, 30)
    bg.BackgroundColor3 = wolfColors.dark
    bg.BorderSizePixel = 0
    bg.Parent = sliderFrame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 9)
    bgCorner.Parent = bg
    
    local fill = Instance.new("Frame")
    local frac = (currentVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(frac, 0, 1, 0)
    fill.BackgroundColor3 = wolfColors.primary
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 9)
    fillCorner.Parent = fill
    
    return label, bg, fill, minVal, maxVal, y + 70
end

-- GUI İÇERİĞİ - Genel Hileler
contentY = createSection("GENEL HİLELER", contentY)

local flyBtn, contentY = createButton("Fly: Kapalı (F Tuşu)", contentY, "🛸")
local antiGravityBtn, contentY = createButton("Anti-Gravity: Kapalı", contentY, "🪂")
local noClipBtn, contentY = createButton("NoClip: Kapalı", contentY, "🚷")

contentY = contentY + 10
contentY = createSection("AYARLAR", contentY)

local flyLabel, flySliderBG, flySliderFill, flyMin, flyMax, contentY = createSlider("Fly Hızı", contentY, flySpeed, 1, 200)
local walkLabel, walkSliderBG, walkSliderFill, walkMin, walkMax, contentY = createSlider("Yürüme Hızı", contentY, walkSpeed, 16, 150)
local jumpLabel, jumpSliderBG, jumpSliderFill, jumpMin, jumpMax, contentY = createSlider("Zıplama Gücü", contentY, jumpPower, 50, 300)

contentY = contentY + 10
contentY = createSection("SİSTEM", contentY)

local flyKeyBtn, contentY = createButton("Fly Tuşu: F (Değiştir)", contentY, "⌨️")

-- Canvas size güncelle
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentY + 20)

-- Panel animasyonları (sağdan genişleyen)
local panelOpen = false
local openTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Size = UDim2.new(0, 400, 0, 500)}
local closeGoal = {Size = UDim2.new(0, 0, 0, 500)}

local function togglePanel()
    if not panelOpen then
        TweenService:Create(panel, openTweenInfo, openGoal):Play()
        panel.Visible = true
        panelOpen = true
    else
        TweenService:Create(panel, closeTweenInfo, closeGoal):Play()
        panelOpen = false
    end
end

mainButton.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(togglePanel)

-- HİLE SİSTEMLERİ --
-- Fly Sistemi
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

-- Anti-Gravity
local function toggleAntiGravity()
    antiGravity = not antiGravity
    antiGravityBtn.Text = antiGravity and "🪂 Anti-Gravity: Açık" or "🪂 Anti-Gravity: Kapalı"
end

-- KONTROLLER
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == flyKey then
        if flying then stopFly() else startFly() end
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

-- BUTON EVENT'LERİ
flyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

noClipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noClipBtn.Text = noclip and "🚷 NoClip: Açık" or "🚷 NoClip: Kapalı"
end)

antiGravityBtn.MouseButton1Click:Connect(toggleAntiGravity)

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

-- SLIDER SİSTEMİ
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

-- Slider kurulum
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

-- NOCLIP SİSTEMİ
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ANTI-GRAVITY SİSTEMİ
RunService.Heartbeat:Connect(function()
    if antiGravity and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Velocity = Vector3.new(
            player.Character.HumanoidRootPart.Velocity.X,
            0,
            player.Character.HumanoidRootPart.Velocity.Z
        )
    end
end)

-- KARAKTER TAKİP
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

-- BAŞLANGIÇ AYARLARI
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkSpeed
        humanoid.JumpPower = jumpPower
    end
end

print("🦊 Frox Hack Turuncu Kurt yüklendi! Butona tıkla.")
