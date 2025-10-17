--// CONFIG
_G.AutoFarm = false
_G.Speed = 45
_G.MobName = "GenericSlayer"

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

--// GUI FLOAT
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Button = Instance.new("TextButton", Frame)

ScreenGui.Name = "SuiAutoFarmGui"
Frame.Size = UDim2.new(0, 140, 0, 60)
Frame.Position = UDim2.new(0.8, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.ZIndex = 1000

Button.Size = UDim2.new(1, 0, 1, 0)
Button.Text = "Ativar AutoFarm"
Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true
Button.Font = Enum.Font.GothamBold
Button.ZIndex = 1001
Button.MouseButton1Click:Connect(function()
	_G.AutoFarm = not _G.AutoFarm
	Button.Text = _G.AutoFarm and "Desativar AutoFarm" or "Ativar AutoFarm"
end)

--// FUNÇÃO PARA ENCONTRAR O MOB MAIS PRÓXIMO
local function getClosestMob()
	local closest, dist = nil, math.huge
	for _,v in pairs(workspace:GetChildren()) do
		if v:IsA("Model") and v.Name == _G.MobName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") then
			if v.Health.Value > 0 and not v:FindFirstChild("Down") then
				local d = (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
				if d < dist then
					dist = d
					closest = v
				end
			end
		end
	end
	return closest
end

--// AUTO FARM LOOP
task.spawn(function()
	while task.wait(0.1) do
		if _G.AutoFarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
			local char = lp.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end
			
			local mob = getClosestMob()
			if mob and mob:FindFirstChild("HumanoidRootPart") then
				local mobHRP = mob.HumanoidRootPart
				local dist = (mobHRP.Position - hrp.Position).Magnitude
				
				-- Teleporta 15 studs perto se estiver longe
				if dist > 30 then
					hrp.CFrame = mobHRP.CFrame * CFrame.new(0, 15, 0)
				end
				
				-- Posiciona deitado, 4 studs acima
				local aboveCF = mobHRP.CFrame * CFrame.new(0, 4, 0) * CFrame.Angles(math.rad(-90), 0, 0)
				hrp.Anchored = true
				hrp.CFrame = aboveCF
				
				-- Detecta se é Demon Slayer pra usar katana
				local style = "Combat"
				if getrenv()._G.PlayerData and getrenv()._G.PlayerData.Race == "Demon Slayer" then
					style = "Katana"
				end
				
				-- Atacar o mob
				if mob:FindFirstChild("Health") and mob.Health.Value > 0 then
					ReplicatedStorage.Remotes.Async:FireServer(style, "Server")
					task.wait(0.45)
				end
			else
				if hrp.Anchored then hrp.Anchored = false end
			end
		else
			if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
				lp.Character.HumanoidRootPart.Anchored = false
			end
		end
	end
end)
