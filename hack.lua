local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Ayarlar (istediğin gibi değiştirebilirsin)
local SETTINGS = {
    HitBoxSize = Vector3.new(10, 10, 15), -- Hit box boyutu
    DamageMultiplier = 2.0, -- Hasar çarpanı
    BaseDamage = 25, -- Temel hasar
    Range = 20, -- Menzil
    Cooldown = 0.5, -- Saldırı bekleme süresi
    HitBoxColor = Color3.fromRGB(255, 50, 50), -- Kırmızı
    AutoSetup = true -- Otomatik kurulum
}

-- Değişkenler
local hitBoxSystem = {}
local playerCooldowns = {}

-- RemoteEvent'leri oluştur
local HitBoxRemote = Instance.new("RemoteEvent")
HitBoxRemote.Name = "HitBoxRemote"
HitBoxRemote.Parent = ReplicatedStorage

-- GUI'yi otomatik oluştur
local function createAutoGUI(player)
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- GUI'yi oluştur
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoHitBoxGUI"
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 200)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
    mainFrame.Parent = screenGui
    
    -- Başlık
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "⚡ OTOMATİK HIT BOX SİSTEMİ ⚡"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Durum bilgisi
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0.9, 0, 0, 60)
    statusLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
    statusLabel.Text = "✅ SİSTEM AKTİF!\n📏 Boyut: " .. tostring(SETTINGS.HitBoxSize) .. "\n⚔️ Hasar: " .. SETTINGS.BaseDamage .. " x " .. SETTINGS.DamageMultiplier
    statusLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextScaled = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = mainFrame
    
    -- Açma/Kapama butonu
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.8, 0, 0, 35)
    toggleButton.Position = UDim2.new(0.1, 0, 0.65, 0)
    toggleButton.Text = "🔥 SİSTEM AÇIK - TIKLA KAPAT"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = mainFrame
    
    -- Bilgi
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 25)
    infoLabel.Position = UDim2.new(0, 0, 0.9, 0)
    infoLabel.Text = "✨ Her şey otomatik! Sadece oyna!"
    infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextScaled = true
    infoLabel.Parent = mainFrame
    
    -- Buton event'i
    local systemEnabled = true
    toggleButton.MouseButton1Click:Connect(function()
        systemEnabled = not systemEnabled
        
        if systemEnabled then
            toggleButton.Text = "🔥 SİSTEM AÇIK - TIKLA KAPAT"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            statusLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
        else
            toggleButton.Text = "❌ SİSTEM KAPALI - TIKLA AÇ"
            toggleButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
        
        HitBoxRemote:FireClient(player, "ToggleSystem", systemEnabled)
    end)
    
    -- Animasyon efekti
    spawn(function()
        while screenGui.Parent do
            wait(2)
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(mainFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)})
            tween:Play()
            wait(0.5)
            tween = TweenService:Create(mainFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)})
            tween:Play()
        end
    end)
    
    return screenGui
end

-- Tool'u otomatik setup et
local function setupToolAutomatically(tool, player)
    if not tool:FindFirstChild("Handle") then return end
    
    -- Hit box part'ını oluştur
    local hitBoxPart = Instance.new("Part")
    hitBoxPart.Name = "AutoHitBox"
    hitBoxPart.Size = SETTINGS.HitBoxSize
    hitBoxPart.Transparency = 0.8
    hitBoxPart.Color = SETTINGS.HitBoxColor
    hitBoxPart.Material = Enum.Material.Neon
    hitBoxPart.CanCollide = false
    hitBoxPart.Anchored = true
    hitBoxPart.Parent = workspace
    
    -- Tool activated event
    tool.Activated:Connect(function()
        local character = player.Character
        if not character or playerCooldowns[player] then return end
        
        -- Cooldown kontrolü
        playerCooldowns[player] = true
        spawn(function()
            wait(SETTINGS.Cooldown)
            playerCooldowns[player] = nil
        end)
        
        -- Hit box'ı göster
        HitBoxRemote:FireClient(player, "ShowHitBox", {
            Position = tool.Handle.Position,
            Size = SETTINGS.HitBoxSize,
            Color = SETTINGS.HitBoxColor
        })
        
        -- Hit detection
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local otherCharacter = otherPlayer.Character
                if otherCharacter then
                    local otherHRP = otherCharacter:FindFirstChild("HumanoidRootPart")
                    local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
                    
                    if otherHRP and otherHumanoid and otherHumanoid.Health > 0 then
                        local distance = (humanoidRootPart.Position - otherHRP.Position).Magnitude
                        
                        if distance <= SETTINGS.Range then
                            -- Hasar ver
                            local damage = SETTINGS.BaseDamage * SETTINGS.DamageMultiplier
                            otherHumanoid:TakeDamage(damage)
                            
                            -- Efekt göster
                            HitBoxRemote:FireClient(player, "ShowHitEffect", otherHRP.Position)
                            
                            -- Vurulan oyuncuya efekti göster
                            HitBoxRemote:FireClient(otherPlayer, "ShowDamageEffect", damage)
                        end
                    end
                end
            end
        end
    end)
    
    -- Tool unequipped
    tool.Unequipped:Connect(function()
        hitBoxPart:Destroy()
    end)
    
    -- Hit box'ı takip et
    spawn(function()
        while tool.Parent and hitBoxPart.Parent do
            wait()
            if tool:FindFirstChild("Handle") then
                hitBoxPart.CFrame = tool.Handle.CFrame
            end
        end
        hitBoxPart:Destroy()
    end)
end

-- Oyuncu join olduğunda
local function onPlayerAdded(player)
    -- GUI'yi otomatik oluştur
    player.CharacterAdded:Connect(function(character)
        wait(3) -- Güvenli bekleme
        createAutoGUI(player)
        
        -- Backpack'teki tool'ları otomatik setup et
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    setupToolAutomatically(tool, player)
                end
            end
            
            -- Yeni tool eklendiğinde otomatik setup
            backpack.ChildAdded:Connect(function(tool)
                if tool:IsA("Tool") then
                    wait(1)
                    setupToolAutomatically(tool, player)
                end
            end)
        end
    end)
    
    -- Mevcut character varsa
    if player.Character then
        spawn(function()
            wait(3)
            createAutoGUI(player)
        end)
    end
end

-- Client tarafı efektler için
HitBoxRemote.OnServerEvent:Connect(function(player, action, data)
    if action == "Ready" then
        -- Client hazır olduğunda
        HitBoxRemote:FireClient(player, "SystemReady", SETTINGS)
    end
end)

-- Oyuncuları setup et
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Client scriptini otomatik oluştur
local function createClientScript()
    local clientScript = [[
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RunService = game:GetService("RunService")
        local TweenService = game:GetService("TweenService")
        
        local player = Players.LocalPlayer
        local HitBoxRemote = ReplicatedStorage:WaitForChild("HitBoxRemote")
        
        -- Değişkenler
        local hitBoxParts = {}
        local effects = {}
        
        -- Hit box göster
        local function showHitBox(data)
            local hitBox = Instance.new("Part")
            hitBox.Size = data.Size
            hitBox.CFrame = CFrame.new(data.Position)
            hitBox.Color = data.Color
            hitBox.Material = Enum.Material.Neon
            hitBox.Transparency = 0.7
            hitBox.CanCollide = false
            hitBox.Anchored = true
            hitBox.Parent = workspace
            
            table.insert(hitBoxParts, hitBox)
            
            -- 0.3 saniye sonra kaldır
            delay(0.3, function()
                if hitBox then
                    hitBox:Destroy()
                end
            end)
        end
        
        -- Hit efekti göster
        local function showHitEffect(position)
            local effect = Instance.new("Part")
            effect.Size = Vector3.new(3, 3, 3)
            effect.CFrame = CFrame.new(position)
            effect.Color = Color3.fromRGB(255, 0, 0)
            effect.Material = Enum.Material.Neon
            effect.Transparency = 0.5
            effect.CanCollide = false
            effect.Anchored = true
            effect.Parent = workspace
            
            -- Büyüme animasyonu
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(effect, tweenInfo, {
                Size = Vector3.new(8, 8, 8),
                Transparency = 1
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                effect:Destroy()
            end)
        end
        
        -- Hasar efekti göster
        local function showDamageEffect(damage)
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            -- Ekranda hasar yazısı
            local screenGui = player.PlayerGui:FindFirstChild("AutoHitBoxGUI")
            if screenGui then
                local damageText = Instance.new("TextLabel")
                damageText.Size = UDim2.new(0, 100, 0, 40)
                damageText.Position = UDim2.new(0.5, -50, 0.3, 0)
                damageText.Text = "💥 -" .. math.floor(damage)
                damageText.TextColor3 = Color3.fromRGB(255, 50, 50)
                damageText.BackgroundTransparency = 1
                damageText.TextScaled = true
                damageText.Font = Enum.Font.GothamBold
                damageText.Parent = screenGui
                
                -- Animasyon
                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(damageText, tweenInfo, {
                    Position = UDim2.new(0.5, -50, 0.2, 0),
                    TextTransparency = 1
                })
                tween:Play()
                
                tween.Completed:Connect(function()
                    damageText:Destroy()
                end)
            end
        end
        
        -- Remote event listener'ları
        HitBoxRemote.OnClientEvent:Connect(function(action, data)
            if action == "ShowHitBox" then
                showHitBox(data)
            elseif action == "ShowHitEffect" then
                showHitEffect(data)
            elseif action == "ShowDamageEffect" then
                showDamageEffect(data)
            elseif action == "ToggleSystem" then
                -- Sistem açma/kapama
                print("Sistem durumu: " .. tostring(data))
            elseif action == "SystemReady" then
                print("✨ Otomatik Hit Box Sistemi Hazır!")
                print("📏 Boyut: " .. tostring(data.HitBoxSize))
                print("⚔️ Hasar: " .. data.BaseDamage .. " x " .. data.DamageMultiplier)
            end
        end)
        
        -- Server'a hazır olduğunu bildir
        wait(2)
        HitBoxRemote:FireServer("Ready")
        
        print("🎮 Otomatik Hit Box Client Sistemi Yüklendi!")
    ]]
    
    -- Client script'i oluştur
    local script = Instance.new("Script")
    script.Name = "AutoHitBoxClient"
    script.Source = clientScript
    script.Parent = ServerScriptService
end

-- Sistem başlangıcı
createClientScript()

print("")
print("⚡ OTOMATİK HIT BOX SİSTEMİ AKTİF! ⚡")
print("📏 Hit Box Boyutu: " .. tostring(SETTINGS.HitBoxSize))
print("⚔️ Hasar: " .. SETTINGS.BaseDamage .. " x " .. SETTINGS.DamageMultiplier)
print("🎯 Menzil: " .. SETTINGS.Range)
print("✨ Her şey otomatik kurulacak!")
print("")
