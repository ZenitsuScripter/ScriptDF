-- // AUTO BREATH HUB COMPLETO (Drag + Toggle + Status + Valor) \\ --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
_G.autoBreath = false
local isBreathing = false

-- Funções de respiração
local function spamBreath()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", true)
end

local function haltBreath()
	ReplicatedStorage.Remotes.Async:FireServer("Character", "Breath", false)
end

-- Criar GUI
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBreathHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0.3, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Auto Breath Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Name = "ToggleButton"
Toggle.Size = UDim2.new(1, 0, 0.25, 0)
Toggle.Position = UDim2.new(0, 0, 0.3, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
Toggle.Text = "OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextScaled = true
Toggle.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Name = "StatusLabel"
Status.Size = UDim2.new(1, 0, 0.2, 0)
Status.Position = UDim2.new(0, 0, 0.55, 0)
Status.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Status.Text = "PAUSED"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.Font = Enum.Font.GothamBold
Status.TextScaled = true
Status.Parent = Frame

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Name = "ValueLabel"
ValueLabel.Size = UDim2.new(1, 0, 0.25, 0)
ValueLabel.Position = UDim2.new(0, 0, 0.75, 0)
ValueLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ValueLabel.Text = "Breathing: 0"
ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.TextScaled = true
ValueLabel.Parent = Frame

-- Toggle ON/OFF
local function toggleState()
	_G.autoBreath = not _G.autoBreath
	isBreathing = false -- resetar
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

		ValueLabel.Text = "Breathing: "..breath.Value

		if _G.autoBreath then
			if breath.Value >= 95 and isBreathing then
				isBreathing = false
				haltBreath()
				Status.Text = "PAUSED"
				Status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			elseif breath.Value < 35 and not isBreathing then
				isBreathing = true
				spamBreath()
				Status.Text = "BREATHING"
				Status.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
			end
		elseif isBreathing then
			isBreathing = false
			haltBreath()
			Status.Text = "PAUSED"
			Status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		end
	end
end)

-- Persistência após morte
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(2)
	isBreathing = false
	if _G.autoBreath then
		local breath = LocalPlayer:FindFirstChild("Breathing")
		if breath and breath.Value < 35 then
			isBreathing = true
			spamBreath()
			Status.Text = "BREATHING"
			Status.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		end
	end
end)
