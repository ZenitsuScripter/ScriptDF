-- // AUTO BREATH GUI (Drag + ON/OFF Toggle + Status) \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
_G.autoBreath = false
local isBreathing = false

-- Criação da GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBreathGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 150, 0, 70)
Frame.Position = UDim2.new(0.05, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Auto Breath"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Name = "ToggleButton"
Toggle.Size = UDim2.new(1, 0, 0.3, 0)
Toggle.Position = UDim2.new(0, 0, 0.4, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextScaled = true
Toggle.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Name = "StatusLabel"
Status.Size = UDim2.new(1, 0, 0.3, 0)
Status.Position = UDim2.new(0, 0, 0.7, 0)
Status.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Status.Text = "PAUSED"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.Font = Enum.Font.GothamBold
Status.TextScaled = true
Status.Parent = Frame

-- Funções de respiração
local function spamBreath()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", true)
	Status.Text = "BREATHING"
	Status.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
end

local function haltBreath()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", false)
	Status.Text = "PAUSED"
	Status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

-- Toggle ON/OFF
local function toggleState()
	_G.autoBreath = not _G.autoBreath
	isBreathing = false -- resetar para permitir reinício
	Toggle.Text = _G.autoBreath and "ON" or "OFF"
	Toggle.BackgroundColor3 = _G.autoBreath and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(90, 90, 90)
end

Toggle.MouseButton1Click:Connect(toggleState)

-- Loop principal
task.spawn(function()
	while task.wait(0.45) do
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local breath = LocalPlayer:FindFirstChild("Breathing")
		if not breath then continue end

		if _G.autoBreath then
			if breath.Value >= 95 and isBreathing then
				isBreathing = false
				haltBreath()
			elseif breath.Value < 35 and not isBreathing then
				isBreathing = true
				spamBreath()
			end
		elseif isBreathing then
			isBreathing = false
			haltBreath()
		end
	end
end)

-- Persistência após morte
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(2)
	if _G.autoBreath then
		isBreathing = false -- resetar para reinício
	end
end)
