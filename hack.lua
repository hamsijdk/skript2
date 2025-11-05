-- Frox Hack (admin-only testing tool)
-- LocalScript -> StarterPlayerScripts içine at
-- NOT: Bu sadece oyun sahibine / izin verilen UserId'lere çalışacak.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ---------- PERMISSION (DEĞİŞTİR / EKLE) ----------
local allowedUserIds = {
    game.CreatorId, -- oyun sahibi
    -- örnek ekleme: 12345678,
}
local function isAllowed()
    for _, id in ipairs(allowedUserIds) do
        if player.UserId == id then return true end
    end
    return false
end
if not isAllowed() then
    -- izin yoksa script hiçbir şey yapmaz
    return
end
-- --------------------------------------------------

-- State
local flying = false
local noclip = false
local flySpeed = 50
local walkSpeed = 16 -- default Roblox walk speed
local control = {F=0,B=0,L=0,R=0}
local bodyGyro, bodyVelocity

-- UI (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "FroxHackGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Ana buton (draggable)
local mainBtn = Instance.new("TextButton", screenGui)
mainBtn.Name = "FroxMain"
mainBtn.Size = UDim2.new(0,120,0,48)
mainBtn.Position = UDim2.new(0,20,0,120)
mainBtn.Text = "Frox Hack"
mainBtn.Font = Enum.Font.GothamBold
mainBtn.TextSize = 18
mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
mainBtn.BorderSizePixel = 0
mainBtn.AutoButtonColor = true
mainBtn.Active = true
mainBtn.Draggable = true
local mainCorner = Instance.new("UICorner", mainBtn)
mainCorner.CornerRadius = UDim.new(0,12)

-- Panel (başlangıçta gizli yukarıda)
local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0,420,0,340)
panel.Position = UDim2.new(0.5,-210,-1.2,0) -- yukarıda gizli
panel.AnchorPoint = Vector2.new(0.5,0)
panel.BackgroundColor3 = Color3.fromRGB(28,28,28)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0,12)

-- Title bar (drag için)
local titleBar = Instance.new("Frame", panel)
titleBar.Size = UDim2.new(1,0,0,40)
titleBar.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0,10,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Frox Hack  •  Yapan: efeakincipo"
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,28,0,24)
closeBtn.Position = UDim2.new(1,-38,0,8)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 14
closeBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0,6)

-- İçerik helper
local curY = 54
local function makeBtn(text)
    local b = Instance.new("TextButton", panel)
    b.Size = UDim2.new(0,380,0,44)
    b.Position = UDim2.new(0.5,-190,0,curY)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    local uc = Instance.new("UICorner", b)
    uc.CornerRadius = UDim.new(0,12)
    curY = curY + 54
    return b
end

-- Fly button
local flyBtn = makeBtn("Fly: Kapalı")

-- Fly speed slider (label + bar)
local flySpeedLabel = Instance.new("TextLabel", panel)
flySpeedLabel.Size = UDim2.new(0,380,0,20)
flySpeedLabel.Position = UDim2.new(0.5,-190,0,curY)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Hızı: "..tostring(flySpeed)
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.TextSize = 14
flySpeedLabel.TextColor3 = Color3.fromRGB(220,220,220)
curY = curY + 26

local flySliderBG = Instance.new("Frame", panel)
flySliderBG.Size = UDim2.new(0,380,0,18)
flySliderBG.Position = UDim2.new(0.5,-190,0,curY)
flySliderBG.BackgroundColor3 = Color3.fromRGB(70,70,70)
flySliderBG.BorderSizePixel = 0
local flyBGcorner = Instance.new("UICorner", flySliderBG); flyBGcorner.CornerRadius = UDim.new(0,9)
local flyFill = Instance.new("Frame", flySliderBG)
flyFill.Size = UDim2.new(flySpeed/300,0,1,0) -- max 300
flyFill.BackgroundColor3 = Color3.fromRGB(120,120,255)
local flyFillCorner = Instance.new("UICorner", flyFill); flyFillCorner.CornerRadius = UDim.new(0,9)
curY = curY + 34

-- Walk speed slider
local walkLabel = Instance.new("TextLabel", panel)
walkLabel.Size = UDim2.new(0,380,0,20)
walkLabel.Position = UDim2.new(0.5,-190,0,curY)
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "Walk Speed: "..tostring(walkSpeed)
walkLabel.Font = Enum.Font.Gotham
walkLabel.TextSize = 14
walkLabel.TextColor3 = Color3.fromRGB(220,220,220)
curY = curY + 26

local walkSliderBG = Instance.new("Frame", panel)
walkSliderBG.Size = UDim2.new(0,380,0,18)
walkSliderBG.Position = UDim2.new(0.5,-190,0,curY)
walkSliderBG.BackgroundColor3 = Color3.fromRGB(70,70,70)
walkSliderBG.BorderSizePixel = 0
local walkBGcorner = Instance.new("UICorner", walkSliderBG); walkBGcorner.CornerRadius = UDim.new(0,9)
local walkFill = Instance.new("Frame", walkSliderBG)
walkFill.Size = UDim2.new(walkSpeed/100,0,1,0) -- max 100
walkFill.BackgroundColor3 = Color3.fromRGB(120,255,120)
local walkFillCorner = Instance.new("UICorner", walkFill); walkFillCorner.CornerRadius = UDim.new(0,9)
curY = curY + 34

-- Noclip button
local noclipBtn = makeBtn("Noclip: Kapalı")

-- Panel aç/kapa animasyon
local panelOpen = false
local openTween = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local closeTween = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local openGoal = {Position = UDim2.new(0.5,-210,0.15,0)}
local closeGoal = {Position = UDim2.new(0.5,-210,-1.2,0)}

local function togglePanel()
    if not panelOpen then
        TweenService:Create(panel, openTween, openGoal):Play()
        panelOpen = true
    else
        TweenService:Create(panel, closeTween, closeGoal):Play()
        panelOpen = false
    end
end

mainBtn.MouseButton1Click:Connect(togglePanel)
closeBtn.MouseButton1Click:Connect(togglePanel)

-- Panel draggable (titleBar)
do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Fly implementation
local function startFly()
    if flying then return end
    flying = true
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.D = 500

    bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0)

    RunService:BindToRenderStep("FroxFly", Enum.RenderPriority.Camera.Value + 1, function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        bodyGyro.CFrame = cam.CFrame
        local dir = (cam.CFrame.LookVector*(control.F+control.B)) + (cam.CFrame.RightVector*(control.R+control.L))
        bodyVelocity.Velocity = dir * flySpeed + Vector3.new(0,0,0)
    end)
end

local function stopFly()
    flying = false
    pcall(function() RunService:UnbindFromRenderStep("FroxFly") end)
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

-- Noclip
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Walk speed apply
local function applyWalkSpeed()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = walkSpeed
    end
end

-- Key controls
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.W then control.F = 1 end
    if inp.KeyCode == Enum.KeyCode.S then control.B = -1 end
    if inp.KeyCode == Enum.KeyCode.A then control.L = -1 end
    if inp.KeyCode == Enum.KeyCode.D then control.R = 1 end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.W then control.F = 0 end
    if inp.KeyCode == Enum.KeyCode.S then control.B = 0 end
    if inp.KeyCode == Enum.KeyCode.A then control.L = 0 end
    if inp.KeyCode == Enum.KeyCode.D then control.R = 0 end
end)

-- UI interactions
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
    noclipBtn.Text = noclip and "Noclip: Açık" or "Noclip: Kapalı"
end)

-- Slider interactions (fly)
do
    local dragging = false
    flySliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp(input.Position.X - flySliderBG.AbsolutePosition.X, 0, flySliderBG.AbsoluteSize.X)
            local frac = x / flySliderBG.AbsoluteSize.X
            flySpeed = math.max(1, math.floor(frac * 300))
            flyFill.Size = UDim2.new(frac,0,1,0)
            flySpeedLabel.Text = "Fly Hızı: "..tostring(flySpeed)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Slider interactions (walk)
do
    local dragging = false
    walkSliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math.clamp(input.Position.X - walkSliderBG.AbsolutePosition.X, 0, walkSliderBG.AbsoluteSize.X)
            local frac = x / walkSliderBG.AbsoluteSize.X
            walkSpeed = math.max(1, math.floor(frac * 100))
            walkFill.Size = UDim2.new(frac,0,1,0)
            walkLabel.Text = "Walk Speed: "..tostring(walkSpeed)
            applyWalkSpeed()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Uygula spawn sonrası
player.CharacterAdded:Connect(function(char)
    task.wait(0.2)
    applyWalkSpeed()
    if flying then
        pcall(stopFly)
        pcall(startFly)
    end
end)

-- Başlangıç olarak yürüyüş hızını uygula
applyWalkSpeed()
