-- LocalScript (StarterPlayerScripts içine)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local teleportActive = false

-- F tuşu ile aktif/pasif yap
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        teleportActive = not teleportActive
        
        if teleportActive then
            game.StarterGui:SetCore("SendNotification", {
                Title = "Işınlanma Aktif!",
                Text = "Sol tıkla ile ışınlan",
                Duration = 3
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Işınlanma Pasif",
                Text = "F tuşuna basarak tekrar aç",
                Duration = 3
            })
        end
    end
end)

-- Mouse tıklaması ile ışınlanma
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not teleportActive then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        teleportToMouse()
    end
end)

function teleportToMouse()
    -- Mouse pozisyonunu al
    local mouse = player:GetMouse()
    local targetPosition = mouse.Hit.Position + Vector3.new(0, 5, 0) -- Yerden 5 birim yukarı
    
    -- Işınlanma öncesi efekt
    createTeleportEffect(hrp.Position)
    
    -- Karakteri ışınla
    hrp.CFrame = CFrame.new(targetPosition)
    
    -- Işınlanma sonrası efekt
    createTeleportEffect(targetPosition)
    
    -- Uçma efekti
    flyEffect()
end

function createTeleportEffect(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 4, 4)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new("Bright blue")
    part.Transparency = 0.5
    part.Parent = workspace
    
    -- Işık efekti
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 5
    pointLight.Range = 10
    pointLight.Color = Color3.new(0, 0.5, 1)
    pointLight.Parent = part
    
    -- Patlama efekti
    part:SetAttribute("Explosion", true)
    
    game.Debris:AddItem(part, 1)
end

function flyEffect()
    -- Yerçekimini geçici kapat
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    
    -- Havada kalma
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 50, 0) -- Yukarı doğru hız
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = hrp
    
    -- Hız artışı
    humanoid.WalkSpeed = 35
    humanoid.JumpPower = 75
    
    -- Bir süre sonra efektleri kaldır
    wait(3)
    
    bodyVelocity:Destroy()
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    
    -- Yerçekimini geri aç
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
end

-- Karakter değiştiğinde update et
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)

print("Işınlanma sistemi yüklendi! F tuşu ile aktif/pasif yap, sol tık ile ışınlan")
