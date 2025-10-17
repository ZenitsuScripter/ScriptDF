--[[ 💀 SuiHub - GenericOni Autofarm with GUI + Teleport 💀 ]]--

_G.mob = "GenericOni"
_G.noclip = true
_G.speed = 45
_G.distFromMob = 6
_G.maxDist = math.huge
_G.autofarm = false
_G.notExecuted = true

-- Serviços
local lp = game:service"Players".LocalPlayer
local ts = game:service"TweenService"
local vu = game:service"VirtualUser"
local rs = game:service"ReplicatedStorage"
local ws = game:service"Workspace"
local runs = game:service"RunService"
local vim = game:service"VirtualInputManager"

----------------------------------
-- GUI (Flutuante + Persistente) --
----------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "SuiHubFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 60)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.5, 0)
label.Text = "👹 GenericOni Farm"
label.TextColor3 = Color3.fromRGB(255,255,255)
label.Font = Enum.Font.GothamBold
label.BackgroundTransparency = 1
label.TextScaled = true
label.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0.8, 0, 0.35, 0)
button.Position = UDim2.new(0.1, 0, 0.55, 0)
button.Text = "Ativar"
button.TextScaled = true
button.Font = Enum.Font.Gotham
button.TextColor3 = Color3.fromRGB(255,255,255)
button.BackgroundColor3 = Color3.fromRGB(60,60,60)
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
button.Parent = frame

button.MouseButton1Click:Connect(function()
	_G.autofarm = not _G.autofarm
	if _G.autofarm then
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		button.Text = "✅ Ativado"
	else
		button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
		button.Text = "⛔ Desativado"
	end
end)

-- Recria GUI após respawn
lp.CharacterAdded:Connect(function()
	task.wait(2)
	gui.Parent = game.CoreGui
end)

-----------------------------------
-- Funções auxiliares
-----------------------------------

-- Remove nome da cabeça
coroutine.wrap(function()
	runs.RenderStepped:Connect(function()
		pcall(function()
			if lp.Character and lp.Character:FindFirstChild("Head") then
				for i,v in pairs(lp.Character.Head:GetChildren()) do
					if v:IsA("BillboardGui") then v:Destroy() end
				end
			end
		end)
	end)
end)()

-- Noclip
coroutine.wrap(function()
	runs.RenderStepped:Connect(function()
		if _G.noclip and lp.Character and lp.Character:FindFirstChild("Humanoid") then
			lp.Character.Humanoid:ChangeState(11)
		end
	end)
end)()

-- Detecta estilo
local style = ""
if getrenv()._G.PlayerData and getrenv()._G.PlayerData.Race == "Demon Slayer" then
	style = "Katana"
else
	style = "Combat"
end

-- Encontra o GenericOni mais próximo
local function getClosestMob()
	local temp = nil
	for _,v in next, ws:GetChildren() do
		if v:IsA("Model") and v.Name == _G.mob and v:FindFirstChild("HumanoidRootPart")
		and v:FindFirstChild("Health") and v.Health.Value > 0 and not v:FindFirstChild("Down") then
			if not temp or (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude <
				(temp.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude then
				temp = v
			end
		end
	end
	return temp
end

-- Coleta todos os drops
ws.ChildAdded:Connect(function(c)
	task.spawn(function()
		if c.Name == "DropItem" then
			c:WaitForChild("ItemName", 5)
			rs.Remotes.Async:FireServer("Character", "Interaction", c)
			task.wait(0.2)
			vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
			task.wait(0.3)
			vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end
	end)
end)

-----------------------------------
-- LOOP PRINCIPAL
-----------------------------------
pcall(function()
	while task.wait() do
		if _G.autofarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
			
			-- ⚔️ Equipa Katana automaticamente
			if style == "Katana" and not lp.Character:FindFirstChild("Katana") then
				local inv = lp.Backpack:FindFirstChild("Katana")
				if inv then
					lp.Character.Humanoid:EquipTool(inv)
					task.wait(0.3)
				end
			end

			local closest = getClosestMob()
			repeat task.wait() closest = getClosestMob() until closest

			local dist = (closest.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude

			-- Se estiver longe (>30 studs), teleportar 15 studs próximo
			if dist > 30 then
				local direction = (closest.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Unit
				local targetPos = closest.HumanoidRootPart.Position - direction * 15
				lp.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos, closest.HumanoidRootPart.Position)
			else
				-- Se estiver próximo, usar tween normal
				local t = dist / _G.speed
				local tweenInfo = TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = ts:Create(lp.Character.HumanoidRootPart, tweenInfo, {
					CFrame = CFrame.new((closest.HumanoidRootPart.Position + Vector3.new(0, _G.distFromMob, 0)), closest.HumanoidRootPart.Position)
				})
				tween:Play()
				repeat task.wait() until (closest.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude <= 100
				tween:Cancel()
			end

			_G.notExecuted = true
			repeat
				task.wait()
				lp.Character.HumanoidRootPart.CFrame =
					CFrame.new((closest.HumanoidRootPart.Position + Vector3.new(0, _G.distFromMob, 0)),
						closest.HumanoidRootPart.Position)

				if closest:FindFirstChild("Block") and not closest:FindFirstChild("Ragdoll") then
					if lp.Stamina.Value >= 20 then
						rs.Remotes.Async:FireServer(style, "Heavy")
					end
				end
				
				if not closest:FindFirstChild("Ragdoll") and not closest:FindFirstChild("Block") then
					task.wait(0.45)
					rs.Remotes.Async:FireServer(style, "Server")
				end

				if closest:FindFirstChild("Down") then
					local count = 0
					repeat
						task.wait()
						lp.Character.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame
						rs.Remotes.Sync:InvokeServer("Character", "Execute")
						count += 1
					until closest:FindFirstChild("Executed") or count > 10
					_G.notExecuted = false
				end
			until not _G.autofarm or not _G.notExecuted
			_G.noclip = true
			task.wait(1.5)
		end
	end
end)
