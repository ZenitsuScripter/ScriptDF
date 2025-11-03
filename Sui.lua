-- // AUTO BREATH GUI + SMART LOOP (35↔95) \\ --

local lp = game:service"Players".LocalPlayer
local ws = game:service"Workspace"
local rs = game:service"ReplicatedStorage"

_G.autoBreath = false
local isB = false
local state = "idle" -- "idle", "breathing", "waiting"

-- Garante que player tem o stat
if not lp:FindFirstChild("Breathing") then
	repeat task.wait(1) until lp:FindFirstChild("Breathing")
end

-- Cria GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoBreathGUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 50)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.5, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Breath"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, 0, 0.5, 0)
toggle.Position = UDim2.new(0, 0, 0.5, 0)
toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
toggle.Text = "OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.Parent = frame

-- Funções
local function spamB()
	rs.Remotes.Async:FireServer("Character", "Breath", true)
end

local function haltB()
	rs.Remotes.Async:FireServer("Character", "Breath", false)
end

local function toggleState()
	_G.autoBreath = not _G.autoBreath
	toggle.Text = _G.autoBreath and "ON" or "OFF"
	toggle.BackgroundColor3 = _G.autoBreath and Color3.fromRGB(0,200,100) or Color3.fromRGB(90,90,90)

	if not _G.autoBreath then
		haltB()
		isB = false
		state = "idle"
	end
end

toggle.MouseButton1Click:Connect(toggleState)

-- Loop principal
coroutine.wrap(function()
	while task.wait(0.45) do
		if not _G.autoBreath then
			task.wait(0.2)
			continue
		end

		local breath = lp:FindFirstChild("Breathing")
		if not breath then continue end
		local val = breath.Value

		if state == "breathing" and val >= 95 then
			isB = false
			state = "waiting"
			haltB()

		elseif state == "waiting" and val < 35 then
			isB = true
			state = "breathing"
			spamB()

		elseif state == "idle" and val < 35 then
			isB = true
			state = "breathing"
			spamB()
		end
	end
end)()

-- Mantém após respawn
lp.CharacterAdded:Connect(function()
	task.wait(2)
	if _G.autoBreath then
		local breath = lp:FindFirstChild("Breathing")
		if breath and breath.Value < 35 then
			isB = true
			state = "breathing"
			spamB()
		end
	end
end)
