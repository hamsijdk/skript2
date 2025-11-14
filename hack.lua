-- SAHTE VİRÜS KORKU EFEKTİ (ZARARSIZ)
-- Sadece görsel + ses efekti, bilgisayara zarar vermez

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Ekran GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "VirusFX"

-- Oyuncuyu kilitle
local function lockControls()
    UIS.InputBegan:Connect(function(input)
        if true then return end
    end)
end
lockControls()

-- Arka plan kırmızı
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(255,0,0)
bg.BackgroundTransparency = 0.3

-- Titreme efekti
spawn(function()
    while gui.Parent do
        bg.Position = UDim2.new(0, math.random(-10,10), 0, math.random(-10,10))
        bg.Rotation = math.random(-5,5)
        task.wait(0.05)
    end
end)

-- Ekranda X işaretleri oluşturma
spawn(function()
    while gui.Parent do
        local X = Instance.new("TextLabel", gui)
        X.Size = UDim2.new(0,100,0,100)
        X.Position = UDim2.new(math.random(),0, math.random(),0)
        X.Text = "✖"
        X.TextColor3 = Color3.fromRGB(255,0,0)
        X.TextScaled = true
        X.BackgroundTransparency = 1
        X.Rotation = math.random(-45,45)

        game:GetService("TweenService"):Create(
            X,
            TweenInfo.new(1),
            {TextTransparency = 1}
        ):Play()

        game:GetService("Debris"):AddItem(X, 1.2)
        task.wait(0.1)
    end
end)

-- Glitch yazılar
spawn(function()
    local messages = {
        "SİSTEM HATASI",
        "VİRÜS ALGILANDI",
        "DOSYALAR BOZULUYOR...",
        "GÜVENLİK DUVARI AŞILDI!",
        "HATA KODU: X00024",
        "KONTROL KAYBEDİLDİ"
    }

    while gui.Parent do
        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.new(1,0,0,60)
        txt.Position = UDim2.new(0,0,0, math.random(0,600))
        txt.Text = messages[math.random(1,#messages)]
        txt.TextScaled = true
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1,1,1)
        txt.Rotation = math.random(-10,10)

        game:GetService("TweenService"):Create(
            txt,
            TweenInfo.new(0.7),
            {TextTransparency = 1}
        ):Play()

        game:GetService("Debris"):AddItem(txt, 0.8)
        task.wait(0.2)
    end
end)

-- Bozulma sesi
local sound = Instance.new("Sound", player:WaitForChild("PlayerGui"))
sound.SoundId = "rbxassetid://9125675529" -- glitch sesi
sound.Volume = 5
sound.Looped = true
sound:Play()

-- 10 saniye sonra kapanır
task.wait(10)
gui:Destroy()
sound:Destroy()
