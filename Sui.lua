--// Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local ws = game:GetService("Workspace")

--// Configurações
_G.autofarm = false
_G.noclip = true
_G.speed = 45
_G.mobName = "GenericSlayer"
_G.distCheck = 30
_G.aboveDist = 2

--// Detectar estilo de ataque
local style = ""
if getrenv()._G.PlayerData and getrenv()._G.PlayerData.Race == "Demon Slayer" then
	style = "Katana"
else
	style = "Combat"
end

--// Função noclip confiável
RunService.RenderStepped:Connect(function()
	if _G.noclip and lp.Character then
		for _, part in pairs(lp.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

--// Pegar mob mais próximo
local function getClosestMob()
	local closest, dist = nil, math.huge
	for _, v in pairs(ws:GetChildren()) do
		if v:IsA("Model") and v.Name == _G.mobName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") and v.Health.Value > 0 then
			local mag = (lp.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude
			if mag < dist then
				closest, dist = v, mag
			end
		end
	end
	return closest, dist
end

--// Loop principal do autofarm
coroutine.wrap(function()
	while task.wait(0.1) do
		if _G.autofarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
			local mob, distance = getClosestMob()
			if mob then
				local mobHRP = mob:FindFirstChild("HumanoidRootPart")
				if mobHRP then
					local targetPos = mobHRP.Position + Vector3.new(0, _G.aboveDist, 0)
					
					-- Teleporta caso esteja longe
					if distance > _G.distCheck then
						lp.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 30, 0))
					end
					
					-- Ajusta posição com tween (suavemente desce)
					local tween = TweenService:Create(
						lp.Character.HumanoidRootPart,
						TweenInfo.new(0.2, Enum.EasingStyle.Linear),
						{CFrame = CFrame.new(targetPos, mobHRP.Position - Vector3.new(0, 5, 0))}
					)
					tween:Play()
					
					-- Ataque
					task.wait(0.2)
					if mob:FindFirstChild("Block") then
						ReplicatedStorage.Remotes.Async:FireServer(style, "Heavy")
					else
						ReplicatedStorage.Remotes.Async:FireServer(style, "Server")
					end
				end
			end
		end
	end
end)()

--// GUI flutuante simples
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 60)
Frame.Position = UDim2.new(0, 20, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.BackgroundTransparency = 0.1

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1, -20, 1, -20)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Text = "Ativar Autofarm"
Toggle.Font = Enum.Font.Gotham
Toggle.TextSize = 16
Toggle.BorderSizePixel = 0

Toggle.MouseButton1Click:Connect(function()
	_G.autofarm = not _G.autofarm
	Toggle.Text = _G.autofarm and "Desativar Autofarm" or "Ativar Autofarm"
	Toggle.BackgroundColor3 = _G.autofarm and Color3.fromRGB(0, 170, 70) or Color3.fromRGB(50, 50, 50)
end)
