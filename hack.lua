-- YerelScript (LocalScript) - StarterPlayer'ın içine
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.CharacterAdded:Wait()

local teleportEnabled = false

-- F tuşuna basıldığında
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        teleportEnabled = not teleportEnabled
        
        if teleportEnabled then
            print("Işınlanma aktif! Işınlanmak için T tuşuna basın.")
        else
            print("Işınlanma pasif")
        end
    end
    
    if input.KeyCode == Enum.KeyCode.T and teleportEnabled then
        -- Işınlanma efekti
        teleportCharacter()
    end
end)

function teleportCharacter()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    
    -- Işınlanma öncesi efektler
    spawnParticles()
    playSound()
    
    -- Rastgele konuma ışınlanma
    local randomPosition = Vector3.new(
        math.random(-100, 100),
        50, -- Yüksekte spawn
        math.random(-100, 100)
    )
    
    hrp.CFrame = CFrame.new(randomPosition)
    
    -- Işınlanma sonrası efektler
    afterTeleportEffects()
end

function spawnParticles()
    -- Işınlanma partikül efektleri
    local part = Instance.new("Part")
    part.Size = Vector3.new(5, 5, 5)
    part.Position = character.HumanoidRootPart.Position
    part.Anchored = true
    part.CanCollide = false
    part.Parent = workspace
    
    local particle = Instance.new("ParticleEmitter")
    particle.Parent = part
    
    game.Debris:AddItem(part, 2)
end

function playSound()
    -- Işınlanma sesi
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://YOUR_SOUND_ID_HERE"
    sound.Parent = character.HumanoidRootPart
    sound:Play()
    game.Debris:AddItem(sound, 3)
end

function afterTeleportEffects()
    -- Işınlandıktan sonraki efektler
    character.Humanoid.WalkSpeed = 25 -- Hız artışı
    wait(5)
    character.Humanoid.WalkSpeed = 16 -- Normal hız
end
