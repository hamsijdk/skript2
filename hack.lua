-- Frox Hack GUI | Gelişmiş Sürüm
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Gelişmiş ayarlar
local flying, noclip, invisible = false, false, false
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50
local control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local bodyGyro, bodyVelocity
local flyKey = Enum.KeyCode.F

-- Gelişmiş GUI sistemi
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton - Gelişmiş
local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 120, 0, 50)
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
panel.Size = UDim2.new(0, 480, 0, 550)
panel.Position = UDim2.new(0.5, -240, -1, 0)
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
titleLabel.Text = "🌟 Frox Hack Premium • efeakincipo"
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

-- İçerik alanı
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -30, 1, -60)
contentFrame.Position = UDim2.new(0, 15, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = panel

-- Gelişmiş UI helper fonksiyonları
local contentY = 0

local function makeSection(title, y)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 35)
    section.Position = UDim2.new(0, 0, 0, y)
    section.BackgroundTransparency = 1
    section.Parent = contentFrame
    
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
    btn.Parent = contentFrame
    
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
    sliderFrame.Parent = contentFrame
    
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
contentY = makeSection("TEMEL ÖZELLİKLER", contentY)

local flyBtn, contentY = makeButton("🛸 Fly: Kapalı (F Tuşu)", contentY, Color3.fromRGB(70, 70, 180))
local noclipBtn, contentY = makeButton("🚷 Duvardan Geçme: Kapalı", contentY, Color3.fromRGB(180, 70, 70))
local invisibleBtn, contentY = makeButton("👻 Görünmezlik: Kapalı", contentY, Color3.fromRGB(70, 180, 70))

contentY = contentY + 10
contentY = makeSection("HAREKET AYARLARI", contentY)

local flyLabel, flySliderBG, flySliderFill, flyMin, flyMax, contentY = makeSlider("Fly Hızı", contentY, flySpeed, 1, 200, Color3.fromRGB(100, 100, 255))
local walkLabel, walkSliderBG, walkSliderFill, walkMin, walkMax, contentY = makeSlider("Yürüme Hızı", contentY, walkSpeed, 16, 100, Color3.fromRGB(100, 255, 100))
local jumpLabel, jumpSliderBG, jumpSliderFill, jumpMin, jumpMax, contentY = makeSlider("Zıplama Gücü", contentY, jumpPower, 50, 200, Color3.fromRGB(255, 100, 100))

contentY = contentY + 10
contentY = makeSection("GELİŞMİŞ AYARLAR", contentY)

local flyKeyBtn, contentY = makeButton("⌨️ Fly Tuşu: F (Değiştir)", contentY, Color3.fromRGB(180, 180, 70))
local antiAFKBtn, contentY = makeButton("⏰ Anti-AFK: Kapalı", contentY, Color3.fromRGB(70, 180, 180))

-- Panel animasyonları
local panelOpen = false
local openTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local closeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5, -240, 0.1, 0)}
local closeGoal = {Position = UDim2.new(0.5, -240, -1, 0)}

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

-- Gelişmiş Fly Sistemi
local function startFly()
    if flying then return end
    flying = true
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        flying = false
        return
    end
    
    local rootPart = character.HumanoidRootPart
    
    -- Eski bileşenleri temizle
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    
    -- Yeni bileşenler
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
    
    -- Fly loop
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

-- Gelişmiş Görünmezlik
local originalValues = {}
local function toggleInvisibility()
    invisible = not invisible
    local character = player.Character
    
    if character then
        if invisible then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    originalValues[part] = part.Transparency
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    originalValues[part] = part.Transparency
                    part.Transparency = 1
                end
            end
        else
            for part, original in pairs(originalValues) do
                if part and part.Parent then
                    part.Transparency = original
                end
            end
            originalValues = {}
        end
    end
    
    invisibleBtn.Text = invisible and "👻 Görünmezlik: Açık" or "👻 Görünmezlik: Kapalı"
end

-- Gelişmiş Anti-AFK
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

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "🚷 Duvardan Geçme: Açık" or "🚷 Duvardan Geçme: Kapalı"
end)

invisibleBtn.MouseButton1Click:Connect(toggleInvisibility)
antiAFKBtn.MouseButton1Click:Connect(toggleAntiAFK)

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

-- Karakter takip sistemi
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    wait(0.5)
    
    -- Ayarları uygula
    if character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = walkSpeed
        character.Humanoid.JumpPower = jumpPower
    end
    
    -- Durumları koru
    if flying then
        stopFly()
        wait(0.2)
        startFly()
    end
    
    if invisible then
        wait(0.5)
        toggleInvisibility()
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

print("🎉 Frox Hack Premium yüklendi! Ana butona tıkla.")
