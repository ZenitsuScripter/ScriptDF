-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local rs = ReplicatedStorage
local ws = workspace

-- GUI
local ScreenGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoFarmGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 60)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(1, -10, 1, -10)
ToggleButton.Position = UDim2.new(0, 5, 0, 5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "Autofarm: OFF"

-- Variables
local autofarm = false
local targetMobName = "GenericSlayer"
local style = getrenv()._G.PlayerData.Race == "Demon Slayer" and "Katana" or "Combat"
local distFromMob = 4

-- Auto-equip Katana se for Slayer
if style == "Katana" then
    local args = {"Katana", "EquippedEvents", true, true}
    rs.Remotes.Async:FireServer(unpack(args))
end

-- Toggle GUI
ToggleButton.MouseButton1Click:Connect(function()
    autofarm = not autofarm
    ToggleButton.Text = "Autofarm: " .. (autofarm and "ON" or "OFF")
end)

-- Função para pegar o mob mais próximo
local function getClosestMob()
    local closest = nil
    for _, v in pairs(ws:GetChildren()) do
        if v:IsA("Model") and v.Name == targetMobName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Health") and v.Health.Value > 0 then
            if not closest or (v.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude < 
               (closest.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude then
                closest = v
            end
        end
    end
    return closest
end

-- Função de movimentação suave
local function followMob(mob)
    local hrp = lp.Character.HumanoidRootPart
    local mobPos = mob.HumanoidRootPart.Position
    local targetPos = mobPos + Vector3.new(0, distFromMob, 0)
    
    local dist = (hrp.Position - mobPos).Magnitude
    if dist > 30 then
        -- Teleporta se muito longe
        hrp.CFrame = CFrame.new(targetPos)
        wait(0.1)
    else
        -- Move suavemente
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos, mobPos) * CFrame.Angles(math.rad(-90),0,0)})
        tween:Play()
    end
end

-- Função de ataque
local function attackMob(mob)
    local hrp = lp.Character.HumanoidRootPart
    if mob:FindFirstChild("Block") then
        if lp.Stamina.Value >= 20 then
            rs.Remotes.Async:FireServer(style, "Heavy")
        end
    else
        rs.Remotes.Async:FireServer(style, "Server")
    end
end

-- Loop principal
coroutine.wrap(function()
    while true do
        RunService.RenderStepped:Wait()
        if autofarm and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local mob = getClosestMob()
            if mob then
                followMob(mob)
                attackMob(mob)
            end
        end
    end
end)()
