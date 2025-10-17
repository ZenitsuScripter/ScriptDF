--// 🔥 SUI HUB - GenericOni Autofarm GUI 🔥 //--
--// Feito por Suiryuu //--

-- CONFIGURAÇÃO --
_G.autofarm = false
_G.speed = 45
_G.distFromMob = 6
_G.noclip = true

-- SERVIÇOS --
local lp = game.Players.LocalPlayer
local ts = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")
local runs = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")

-- ESTILO DE ATAQUE (Katana ou Combat) --
local style = (getrenv()._G.PlayerData and getrenv()._G.PlayerData.Race == "Demon Slayer") and "Katana" or "Combat"

--== [FUNÇÕES AUXILIARES] ==--

-- Mantém noclip e oculta nome
runs.RenderStepped:Connect(function()
    pcall(function()
        if _G.noclip and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid:ChangeState(11)
        end
        if lp.Character and lp.Character:FindFirstChild("Head") then
            for _,v in pairs(lp.Character.Head:GetChildren()) do
                if v:IsA("BillboardGui") then v:Destroy() end
            end
        end
    end)
end)

-- Garante que GUI não desapareça ao morrer
lp.CharacterAdded:Connect(function()
    task.wait(2)
    if _G.farmGui and _G.farmGui.Parent == nil then
        _G.farmGui.Parent = game.CoreGui
    end
end)

-- Localiza o GenericOni mais próximo
local function getClosestOni()
    local closest, dist = nil, math.huge
    for _,v in pairs(ws:GetChildren()) do
        if v:IsA("Model") and v.Name == "GenericOni" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") and v.Health.Value > 0 then
            local d = (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).magnitude
            if d < dist then
                closest, dist = v, d
            end
        end
    end
    return closest
end

--== [AUTOFARM LOOP] ==--
task.spawn(function()
    while task.wait() do
        if _G.autofarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local target = getClosestOni()
            if target then
                local dist = (target.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).magnitude
                local tweenTime = dist / _G.speed

                -- Tween até o Oni
                local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = ts:Create(lp.Character.HumanoidRootPart, tweenInfo, {
                    CFrame = CFrame.new(target.HumanoidRootPart.Position + Vector3.new(0, _G.distFromMob, 0), target.HumanoidRootPart.Position)
                })
                tween:Play()
                repeat task.wait() until not _G.autofarm or not target:FindFirstChild("HumanoidRootPart") or (target.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).magnitude <= 10
                tween:Cancel()

                -- Atacar o Oni
                repeat task.wait()
                    if target:FindFirstChild("Health") and target.Health.Value > 0 and not target:FindFirstChild("Down") then
                        rs.Remotes.Async:FireServer(style, "Server")
                        task.wait(0.4)
                    end
                until not _G.autofarm or not target or not target:FindFirstChild("Health") or target.Health.Value <= 0

                -- Executar automaticamente
                if target and target:FindFirstChild("Down") then
                    for i = 1, 10 do
                        if not _G.autofarm then break end
                        lp.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                        vim:SendKeyEvent(true, Enum.KeyCode.B, false, game)
                        task.wait(0.2)
                        vim:SendKeyEvent(false, Enum.KeyCode.B, false, game)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

--== [DROP AUTO COLECT] ==--
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

--== [GUI FLOTANTE] ==--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuiFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui
_G.farmGui = ScreenGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 60)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.BackgroundTransparency = 0.2
Frame.ClipsDescendants = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Text = "🩸 GenericOni Autofarm"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.8, 0, 0.4, 0)
ToggleButton.Position = UDim2.new(0.1, 0, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.Gotham
ToggleButton.TextScaled = true
ToggleButton.Text = "Ativar"
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

ToggleButton.MouseButton1Click:Connect(function()
	_G.autofarm = not _G.autofarm
	if _G.autofarm then
		ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		ToggleButton.Text = "✅ Ativado"
	else
		ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
		ToggleButton.Text = "⛔ Desativado"
	end
end)
