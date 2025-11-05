-- Frox Hack | Admin-only LocalScript
local P,S,UIS,RS=game.Players,game:GetService("StarterGui"),game:GetService("UserInputService"),game:GetService("RunService")
local pl=P.LocalPlayer
if not table.find({game.CreatorId},pl.UserId) then return end
-- State
local fly,noclip=false,false;local flySpeed,walkSpeed=50,16;local ctrl={F=0,B=0,L=0,R=0}
local bv,bg
-- UI
local sg=Instance.new("ScreenGui",pl:WaitForChild("PlayerGui"));sg.ResetOnSpawn=false
local btn=Instance.new("TextButton",sg)
btn.Size=UDim2.new(0,120,0,48);btn.Position=UDim2.new(0,20,0,120)
btn.Text="Frox Hack";btn.Font=Enum.Font.GothamBold;btn.TextSize=18;btn.TextColor3=Color3.new(1,1,1)
btn.BackgroundColor3=Color3.fromRGB(45,45,45);btn.BorderSizePixel=0;btn.Active=true;btn.Draggable=true
local btnC=Instance.new("UICorner",btn);btnC.CornerRadius=UDim.new(0,12)
local panel=Instance.new("Frame",sg);panel.Size=UDim2.new(0,420,0,300);panel.Position=UDim2.new(0.5,-210,-1.2,0)
panel.AnchorPoint=Vector2.new(0.5,0);panel.BackgroundColor3=Color3.fromRGB(28,28,28);panel.BorderSizePixel=0
local pc=Instance.new("UICorner",panel);pc.CornerRadius=UDim.new(0,12)
local tb=Instance.new("Frame",panel);tb.Size=UDim2.new(1,0,0,40);tb.BackgroundTransparency=1
local tl=Instance.new("TextLabel",tb);tl.Size=UDim2.new(1,-40,1,0);tl.Position=UDim2.new(0,10,0,0)
tl.BackgroundTransparency=1;tl.Text="Frox Hack  •  efeakincipo";tl.Font=Enum.Font.GothamSemibold
tl.TextSize=16;tl.TextColor3=Color3.new(1,1,1);tl.TextXAlignment=Enum.TextXAlignment.Left
local close=Instance.new("TextButton",tb);close.Size=UDim2.new(0,28,0,24);close.Position=UDim2.new(1,-38,0,8)
close.Text="X";close.Font=Enum.Font.Gotham;close.TextSize=14;close.BackgroundColor3=Color3.fromRGB(70,70,70)
close.TextColor3=Color3.new(1,1,1);close.BorderSizePixel=0;local cc=Instance.new("UICorner",close);cc.CornerRadius=UDim.new(0,6)
-- Panel anim
local open=false;local tw1=TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local tw2=TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
local goOpen={Position=UDim2.new(0.5,-210,0.15,0)};local goClose={Position=UDim2.new(0.5,-210,-1.2,0)}
btn.MouseButton1Click:Connect(function() if not open then requireTween(panel,tw1,goOpen) open=true else requireTween(panel,tw2,goClose) open=false end end)
close.MouseButton1Click:Connect(function() requireTween(panel,tw2,goClose) open=false end)
function requireTween(o,i,g) TweenService:Create(o,i,g):Play() end
-- Buttons
local function mkBtn(txt,y)
	local b=Instance.new("TextButton",panel);b.Size=UDim2.new(0,380,0,40);b.Position=UDim2.new(0.5,-190,0,y)
	b.BackgroundColor3=Color3.fromRGB(55,55,55);b.BorderSizePixel=0;b.Font=Enum.Font.Gotham
	b.TextSize=16;b.TextColor3=Color3.new(1,1,1);b.Text=txt
	local uc=Instance.new("UICorner",b);uc.CornerRadius=UDim.new(0,12)
	return b
end
local curY=50
local flyBtn=mkBtn("Fly: Kapalı",curY);curY=curY+50
local nocBtn=mkBtn("Noclip: Kapalı",curY);curY=curY+50
-- Sliders
local function mkSlider(labelY,txt,maxVal,init)
	local lab=Instance.new("TextLabel",panel);lab.Size=UDim2.new(0,380,0,20)
	lab.Position=UDim2.new(0.5,-190,0,labelY);lab.BackgroundTransparency=1;lab.Text=txt.." "..tostring(init)
	lab.Font=Enum.Font.Gotham;lab.TextSize=14;lab.TextColor3=Color3.fromRGB(220,220,220)
	local bg=Instance.new("Frame",panel);bg.Size=UDim2.new(0,380,0,18);bg.Position=UDim2.new(0.5,-190,0,labelY+22)
	bg.BackgroundColor3=Color3.fromRGB(70,70,70);bg.BorderSizePixel=0
	local fg=Instance.new("Frame",bg);fg.Size=UDim2.new(init/maxVal,0,1,0);fg.BackgroundColor3=(txt=="Fly Hızı:" and Color3.fromRGB(120,120,255) or Color3.fromRGB(120,255,120))
	local uc=Instance.new("UICorner",bg);uc.CornerRadius=UDim.new(0,9);local uc2=Instance.new("UICorner",fg);uc2.CornerRadius=UDim.new(0,9)
	return lab,bg,fg
end
local flyLab,flyBG,flyFG=mkSlider(curY,"Fly Hızı:",300,flySpeed);curY=curY+40
local walkLab,walkBG,walkFG=mkSlider(curY,"Walk Speed:",100,walkSpeed);curY=curY+40
-- Drag sliders
local function sliderLogic(bg,fg,lab,maxVal,callback)
	local drag=false
	bg.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
	UIS.InputChanged:Connect(function(input)
		if drag and input.UserInputType==Enum.UserInputType.MouseMovement then
			local x=math.clamp(input.Position.X-bg.AbsolutePosition.X,0,bg.AbsoluteSize.X)
			local frac=x/bg.AbsoluteSize.X;fg.Size=UDim2.new(frac,0,1,0);callback(math.floor(frac*maxVal));lab.Text=lab.Text:match("^[^:]+:").." "..tostring(math.floor(frac*maxVal)) end
	end)
	UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end
sliderLogic(flyBG,flyFG,flyLab,300,function(v) flySpeed=v end)
sliderLogic(walkBG,walkFG,walkLab,100,function(v) walkSpeed=v if pl.Character and pl.Character:FindFirstChild("Humanoid") then pl.Character.Humanoid.WalkSpeed=v end end)
-- Fly logic
local ctrlKeys={F=0,B=0,L=0,R=0}
UIS.InputBegan:Connect(function(i,gp) if gp then return end
	if i.KeyCode==Enum.KeyCode.W then ctrlKeys.F=1 end
	if i.KeyCode==Enum.KeyCode.S then ctrlKeys.B=-1 end
	if i.KeyCode==Enum.KeyCode.A then ctrlKeys.L=-1 end
	if i.KeyCode==Enum.KeyCode.D then ctrlKeys.R=1 end
end)
UIS.InputEnded:Connect(function(i) 
	if i.KeyCode==Enum.KeyCode.W then ctrlKeys.F=0 end
	if i.KeyCode==Enum.KeyCode.S then ctrlKeys.B=0 end
	if i.KeyCode==Enum.KeyCode.A then ctrlKeys.L=0 end
	if i.KeyCode==Enum.KeyCode.D then ctrlKeys.R=0 end
end)
local function startFly()
	if fly then return end
	fly=true
	local char=pl.Character; if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	bg=Instance.new("BodyGyro",hrp);bg.P=9e4;bg.MaxTorque=Vector3.new(9e9,9e9,9e9);bg.D=500
	bv=Instance.new("BodyVelocity",hrp);bv.MaxForce=Vector3.new(9e9,9e9,9e9);bv.Velocity=Vector3.new(0,0,0)
	RS.Heartbeat:Connect(function()
		if not fly then return end
		local cam=workspace.CurrentCamera
		bg.CFrame=cam.CFrame
		local dir=(cam.CFrame.LookVector*(ctrlKeys.F+ctrlKeys.B))+(cam.CFrame.RightVector*(ctrlKeys.R+ctrlKeys.L))
		bv.Velocity=dir*flySpeed
	end)
end
local function stopFly() fly=false; if bg then bg:Destroy() end if bv then bv:Destroy() end end
flyBtn.MouseButton1Click:Connect(function() if fly then stopFly();flyBtn.Text="Fly: Kapalı" else startFly();flyBtn.Text="Fly: Açık" end end)
-- Noclip
nocBtn.MouseButton1Click:Connect(function() noclip=not noclip;nocBtn.Text=noclip and "Noclip: Açık" or "Noclip: Kapalı" end)
RS.Stepped:Connect(function()
	if noclip and pl.Character then
		for _,p in pairs(pl.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
	end
end)
-- Spawn
pl.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	if char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed=walkSpeed end
	if fly then pcall(stopFly);pcall(startFly) end
end)
if pl.Character and pl.Character:FindFirstChild("Humanoid") then pl.Character.Humanoid.WalkSpeed=walkSpeed end
