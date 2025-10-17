-- // CONFIG
_G.autofarm = false
_G.noclip = true
_G.mob = "GenericSlayer"
_G.speed = 40

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

-- cria gui flutuante
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.Visible = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Sui AutoFarm"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local Button = Instance.new("TextButton", Frame)
Button.Size = UDim2.new(0.8, 0, 0, 30)
Button.Position = UDim2.new(0.1, 0, 0.5, 0)
Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Button.Text = "Ativar"
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Instance.new("UICorner", Button)

Button.MouseButton1Click:Connect(function()
	_G.autofarm = not _G.autofarm
	Button.Text = _G.autofarm and "Desativar" or "Ativar"
	Button.BackgroundColor3 = _G.autofarm and Color3.fromRGB(0,170,0) or Color3.fromRGB(40,40,40)
end)

-- Noclip
RunService.Stepped:Connect(function()
	if _G.noclip and lp.Character and lp.Character:FindFirstChild("Humanoid") then
		lp.Character.Humanoid:ChangeState(11)
	end
end)

-- Define estilo de ataque
local style = (getrenv()._G.PlayerData and getrenv()._G.PlayerData.Race == "Demon Slayer") and "Katana" or "Combat"

local function getClosestMob()
	local target = nil
	local shortest = math.huge
	for _,v in ipairs(workspace:GetChildren()) do
		if v:IsA("Model") and v.Name == _G.mob and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") then
			if v.Health.Value > 0 then
				local mag = (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
				if mag < shortest then
					shortest = mag
					target = v
				end
			end
		end
	end
	return target
end

task.spawn(function()
	while task.wait() do
		if _G.autofarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
			local mob = getClosestMob()
			if mob then
				local dist = (mob.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
				
				-- teleporta se tiver longe
				if dist > 30 then
					lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0)
					task.wait(0.2)
				end
				
				-- ataca enquanto vivo
				while _G.autofarm and mob and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Health") and mob.Health.Value > 0 do
					local followPos = mob.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(math.rad(90), 0, 0)
					lp.Character.HumanoidRootPart.CFrame = followPos
					
					if not mob:FindFirstChild("Block") and not mob:FindFirstChild("Ragdoll") then
						ReplicatedStorage.Remotes.Async:FireServer(style, "Server")
					elseif mob:FindFirstChild("Block") then
						ReplicatedStorage.Remotes.Async:FireServer(style, "Heavy")
					end
					task.wait(0.45)
				end
				
				-- executa após morrer
				if mob and mob:FindFirstChild("Down") and not mob:FindFirstChild("Executed") then
					local tries = 0
					repeat
						lp.Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame
						task.wait(0.1)
						VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.B, false, game)
						task.wait(0.4)
						VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.B, false, game)
						tries += 1
					until mob:FindFirstChild("Executed") or tries >= 10
				end
			end
		end
	end
end)
