-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer

-- Config
_G.autofarm = false
_G.noclip = true
_G.speed = 45
_G.distFromMob = 6

-- Detecta estilo
local style = ""
if getrenv()._G.PlayerData.Race == "Demon Slayer" then
    style = "Katana"
else
    style = "Combat"
end

-- Função noclip real
RunService.RenderStepped:Connect(function()
    if _G.noclip and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Função pra pegar o mob mais próximo pelo nome
local function getClosestMob(name)
    local temp = nil
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == name and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") and v.Health.Value > 0 then
            if not temp or (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude < 
               (temp.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude then
                temp = v
            end
        end
    end
    return temp
end

-- Loop autofarm
coroutine.wrap(function()
    while true do
        wait(0.1)
        if _G.autofarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and _G.mobName then
            local mob = getClosestMob(_G.mobName)
            if mob then
                local dist = (mob.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                -- Teleporta para 15 studs de distância
                local direction = (lp.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Unit
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(mob.HumanoidRootPart.Position + direction*15, mob.HumanoidRootPart.Position)
                
                -- Ataque simples
                if mob:FindFirstChild("Block") then
                    if lp:FindFirstChild("Stamina") and lp.Stamina.Value >= 20 then
                        ReplicatedStorage.Remotes.Async:FireServer(style, "Heavy")
                    end
                else
                    ReplicatedStorage.Remotes.Async:FireServer(style, "Server")
                end
            end
        end
    end
end)()

-- GUI simples
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 100)
Frame.Position = UDim2.new(0, 20, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

local TextBox = Instance.new("TextBox", Frame)
TextBox.PlaceholderText = "Nome do Mob"
TextBox.Size = UDim2.new(0, 200, 0, 30)
TextBox.Position = UDim2.new(0, 10, 0, 10)
TextBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
TextBox.TextColor3 = Color3.new(1,1,1)

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0, 200, 0, 30)
ToggleButton.Position = UDim2.new(0, 10, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Text = "Ativar Autofarm"

ToggleButton.MouseButton1Click:Connect(function()
    _G.autofarm = not _G.autofarm
    _G.mobName = TextBox.Text ~= "" and TextBox.Text or nil
    ToggleButton.Text = _G.autofarm and "Desativar Autofarm" or "Ativar Autofarm"
end)
