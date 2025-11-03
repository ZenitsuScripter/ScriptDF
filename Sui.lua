-- // AUTO BREATH GUI (Bug corrigido) \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

_G.autoBreath = false

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBreathGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 150, 0, 50)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.5, 0)
Title.BackgroundTransparency = 1
Title.Text = "Auto Breath"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, 0, 0.5, 0)
Toggle.Position = UDim2.new(0, 0, 0.5, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextScaled = true
Toggle.Parent = Frame

-- Funções
local function spamB()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", true)
end

local function haltB()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", false)
end

-- Toggle ON/OFF
Toggle.MouseButton1Click:Connect(function()
	_G.autoBreath = not _G.autoBreath
	Toggle.Text = _G.autoBreath and "ON" or "OFF"
	Toggle.BackgroundColor3 = _G.autoBreath and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(90, 90, 90)

	if not _G.autoBreath then
		haltB()
	else
		-- garante que na próxima verificação o loop respira normalmente
		-- resetando a respiração se necessário
		if LocalPlayer:FindFirstChild("Breathing") and LocalPlayer.Breathing.Value < 35 then
			spamB()
		end
	end
end)

-- Loop principal
task.spawn(function()
	while true do
		task.wait(0.45)
		if not _G.autoBreath then continue end

		local breath = LocalPlayer:FindFirstChild("Breathing") and LocalPlayer.Breathing.Value or 0

		if breath < 35 then
			spamB()
		elseif breath >= 95 then
			haltB()
		end
	end
end)

-- Persistência após respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(2)
	if _G.autoBreath then
		local breath = LocalPlayer:FindFirstChild("Breathing") and LocalPlayer.Breathing.Value or 0
		if breath < 35 then
			spamB()
		end
	end
end)
