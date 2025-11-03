-- // AUTO BREATH GUI (Drag + Smart ON/OFF Loop) \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

_G.autoBreath = false
local isBreathing = false

-- Criação da GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBreathGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
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
local function spamBreath()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", true)
end

local function haltBreath()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", false)
end

local function toggleState()
	_G.autoBreath = not _G.autoBreath
	Toggle.Text = _G.autoBreath and "ON" or "OFF"
	Toggle.BackgroundColor3 = _G.autoBreath and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(90, 90, 90)

	if not _G.autoBreath then
		haltBreath()
		isBreathing = false
	end
end

Toggle.MouseButton1Click:Connect(toggleState)

-- Loop inteligente
task.spawn(function()
	while task.wait(0.25) do
		if not _G.autoBreath then continue end

		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local breathStat = LocalPlayer:FindFirstChild("Breathing")
		if not breathStat or not breathStat:FindFirstChild("Value") then continue end

		local current = breathStat.Value

		-- Se abaixo de 35 → respira
		if current < 35 and not isBreathing then
			isBreathing = true
			spamBreath()
		
		-- Se chegou em 95 → para
		elseif current >= 95 and isBreathing then
			isBreathing = false
			haltBreath()
		end
	end
end)

-- Mantém ativo após renascer
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(2)
	if _G.autoBreath then
		local breathStat = LocalPlayer:FindFirstChild("Breathing")
		if breathStat and breathStat.Value < 35 then
			spamBreath()
		end
	end
end)
