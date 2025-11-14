

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local Workspace = game:GetService("Workspace")

-- ==============================
-- 1) RemoteEvent otomatik
-- ==============================
local Remote = ReplicatedStorage:FindFirstChild("CezaBaslat")
if not Remote then
    Remote = Instance.new("RemoteEvent")
    Remote.Name = "CezaBaslat"
    Remote.Parent = ReplicatedStorage
    print("✔ RemoteEvent oluşturuldu: CezaBaslat")
end

-- ==============================
-- 2) LocalScript otomatik
-- ==============================
if not StarterPlayerScripts:FindFirstChild("CezaLocal") then
    local LS = Instance.new("LocalScript")
    LS.Name = "CezaLocal"
    LS.Parent = StarterPlayerScripts

    LS.Source = [[
local players = game:GetService("Players")
local player = players.LocalPlayer
local uis = game:GetService("UserInputService")

local Gui = Instance.new("ScreenGui")
Gui.Name = "KorkuEkrani"
Gui.Enabled = false
Gui.Parent = player.PlayerGui

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(1,0,1,0)
Frame.BackgroundColor3 = Color3.fromRGB(150,0,0)
Frame.BackgroundTransparency = 0.2

local Text = Instance.new("TextLabel", Frame)
Text.Size = UDim2.new(1,0,0.3,0)
Text.Position = UDim2.new(0,0,0.3,0)
Text.BackgroundTransparency = 1
Text.TextColor3 = Color3.fromRGB(255,255,255)
Text.TextScaled = true
Text.Text = "BİTTİN..."

game.ReplicatedStorage:WaitForChild("CezaBaslat").OnClientEvent:Connect(function()
	Gui.Enabled = true

	task.spawn(function()
		while Gui.Enabled do
			game.Workspace.CurrentCamera.CFrame *= CFrame.Angles(0,0,math.random(-10,10)/500)
			task.wait(0.02)
		end
	end)

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 4 end
	end
end)

uis.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.P then
		Gui.Enabled = false
		local char = player.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 end
		end
	end
end)
    ]]
    print("✔ LocalScript oluşturuldu: CezaLocal")
end

-- ==============================
-- 3) Otomatik Ceza Odası Oluşturma
-- ==============================
local CezaOda = Workspace:FindFirstChild("CezaOdasi")
if not CezaOda then
    CezaOda = Instance.new("Part")
    CezaOda.Name = "CezaOdasi"
    CezaOda.Anchored = true
    CezaOda.Size = Vector3.new(30, 20, 30)
    CezaOda.Position = Vector3.new(0, 10, 0)
    CezaOda.Color = Color3.fromRGB(50,0,0)
    CezaOda.Parent = Workspace
    print("✔ Ceza odası otomatik oluşturuldu")
end

local CezaCFrame = CezaOda.CFrame
local CezaListe = {}

-- ==============================
-- 4) Ceza başlatma ve teleport
-- ==============================
Remote.OnServerEvent:Connect(function(player)
    CezaListe[player.UserId] = true

    if player.Character then
        player.Character:MoveTo(CezaCFrame.Position)
    end

    Remote:FireClient(player)
end)

-- ==============================
-- 5) Ölünce tekrar Ceza Odasına ışınla
-- ==============================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if CezaListe[player.UserId] then
            char:MoveTo(CezaCFrame.Position)
        end
    end)
end)

print("✔ Tüm sistem hazır! Ceza Odası ve Korku Efekti otomatik.")
