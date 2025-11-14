---------------------------------------------------------
--    KEY PANEL + ANA MENÜ + REMOTE TARAMA SİSTEMİ     --
---------------------------------------------------------

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

---------------------------------------------------------
--   ANA GUI / KEY GUI  OLUŞTURMA
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.Name = "MasterGUI"
ScreenGui.ResetOnSpawn = false

---------------------------------------------------------
-- KEY FRAME
---------------------------------------------------------
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 300, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -150, 0.4, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "Key Panel"
KeyTitle.TextColor3 = Color3.new(1,1,1)
KeyTitle.TextScaled = true

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.8, 0, 0, 35)
KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyBox.PlaceholderText = "Key Gir..."
KeyBox.TextScaled = true

local KeyEnter = Instance.new("TextButton", KeyFrame)
KeyEnter.Size = UDim2.new(0.8, 0, 0, 35)
KeyEnter.Position = UDim2.new(0.1, 0, 0.65, 0)
KeyEnter.Text = "Giriş"
KeyEnter.TextScaled = true

---------------------------------------------------------
-- GÜNLÜK KEY BURAYA
---------------------------------------------------------
local TodayKey = "1173563"
local OwnerName = "efeakincipo"  -- sadece sana özel

---------------------------------------------------------
-- ANA MENÜ FRAME
---------------------------------------------------------
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 350, 0, 350)
MainMenu.Position = UDim2.new(0.5, -175, 0.5, -175)
MainMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainMenu.Visible = false

local MenuTitle = Instance.new("TextLabel", MainMenu)
MenuTitle.Size = UDim2.new(1, 0, 0, 50)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "Hile Menü"
MenuTitle.TextColor3 = Color3.new(1,1,1)
MenuTitle.TextScaled = true

---------------------------------------------------------
-- HİLE BUTONLARI (Oto Bitki, Oto Ekipman, Oto Saldırı)
---------------------------------------------------------
local function CreateButton(text, order)
    local btn = Instance.new("TextButton", MainMenu)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = UDim2.new(0.1, 0, 0, 60 + (order * 50))
    btn.Text = text
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
    return btn
end

local AutoPlantBtn = CreateButton("Otomatik Bitki (Aç/Kapa)", 1)
local AutoEquipBtn = CreateButton("Otomatik Ekipman (Aç/Kapa)", 2)
local AutoAttackBtn = CreateButton("Otomatik Saldırı (Aç/Kapa)", 3)

local ScanBtn = CreateButton("RemoteEvent Tarama Paneli", 4)

---------------------------------------------------------
-- TARAYICI PANEL
---------------------------------------------------------
local ScanFrame = Instance.new("Frame", ScreenGui)
ScanFrame.Size = UDim2.new(0, 400, 0, 350)
ScanFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
ScanFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScanFrame.Visible = false

local ScanTitle = Instance.new("TextLabel", ScanFrame)
ScanTitle.Size = UDim2.new(1, 0, 0, 40)
ScanTitle.BackgroundTransparency = 1
ScanTitle.Text = "RemoteEvent Tarayıcı"
ScanTitle.TextScaled = true
ScanTitle.TextColor3 = Color3.new(1,1,1)

local Scroll = Instance.new("ScrollingFrame", ScanFrame)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 2000)
Scroll.BackgroundColor3 = Color3.fromRGB(50,50,50)

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)

local function AddLine(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 30)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text
    Label.TextScaled = true
    Label.Parent = Scroll
end

---------------------------------------------------------
-- TARAYICI ÇALIŞTIRMA FONKSİYONU
---------------------------------------------------------
local function Scan(folder)
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            AddLine("RemoteEvent: "..obj.Name)
        elseif obj:IsA("RemoteFunction") then
            AddLine("RemoteFunction: "..obj.Name)
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            Scan(obj)
        end
    end
end

---------------------------------------------------------
-- TÜM TARAYICI
---------------------------------------------------------
local function RunScanner()
    Scroll:ClearAllChildren()
    AddLine("Tarama Başladı...")
    task.wait(0.5)

    Scan(game.ReplicatedStorage)
    Scan(game.Workspace)
    Scan(game.StarterPlayer)

    AddLine("----- TARAMA BİTTİ -----")
end

---------------------------------------------------------
-- KEY GİRİŞ KONTROL
---------------------------------------------------------
KeyEnter.MouseButton1Click:Connect(function()
    if player.Name ~= OwnerName then
        KeyBox.Text = "Bu key sana ait değil!"
        return
    end
    
    if KeyBox.Text == TodayKey then
        KeyFrame.Visible = false
        MainMenu.Visible = true
    else
        KeyBox.Text = "Yanlış Key!"
    end
end)

---------------------------------------------------------
-- F ile GUI Aç/Kapa
---------------------------------------------------------
local guiEnabled = true
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        guiEnabled = not guiEnabled
        ScreenGui.Enabled = guiEnabled
    end
end)

---------------------------------------------------------
-- TARAYICI BUTONU
---------------------------------------------------------
ScanBtn.MouseButton1Click:Connect(function()
    ScanFrame.Visible = true
    RunScanner()
end)

---------------------------------------------------------
-- OTOMATİK HİLE TOGGLE (şimdilik boş)
---------------------------------------------------------
local AutoPlant = false
local AutoEquip = false
local AutoAttack = false

AutoPlantBtn.MouseButton1Click:Connect(function()
    AutoPlant = not AutoPlant
    AutoPlantBtn.Text = "Oto Bitki: " .. (AutoPlant and "Açık" or "Kapalı")
end)

AutoEquipBtn.MouseButton1Click:Connect(function()
    AutoEquip = not AutoEquip
    AutoEquipBtn.Text = "Oto Ekipman: " .. (AutoEquip and "Açık" or "Kapalı")
end)

AutoAttackBtn.MouseButton1Click:Connect(function()
    AutoAttack = not AutoAttack
    AutoAttackBtn.Text = "Oto Saldırı: " .. (AutoAttack and "Açık" or "Kapalı")
end)

---------------------------------------------------------
-- EVENT BAĞLAMALARI (Sen RemoteEvent isimlerini verince dolduracağız)
---------------------------------------------------------

