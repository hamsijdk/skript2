-- Executor ile çalıştırılacak script
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Kılıç efekti vermek için
local tool = Instance.new("Tool")
tool.Name = "Ban Sword"
tool.Parent = localPlayer.Backpack

-- Dokunma ile atma
tool.Activated:Connect(function()
    local character = localPlayer.Character
    if character then
        local ray = Ray.new(character.Head.Position, character.Head.CFrame.LookVector * 50)
        local part, position = workspace:FindPartOnRay(ray)
        
        if part then
            local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local targetPlayer = Players:GetPlayerFromCharacter(part.Parent)
                if targetPlayer then
                    -- Bu kısım exploitin yeteneklerine bağlı
                    targetPlayer:Kick("Hile ile atıldın!")
                end
            end
        end
    end
end)
