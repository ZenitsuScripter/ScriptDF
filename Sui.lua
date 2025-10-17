-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local rs = ReplicatedStorage
local ws = workspace

-- Variables
local autofarm = false
local targetMobName = "GenericSlayer"
local style = getrenv()._G.PlayerData.Race == "Demon Slayer" and "Katana" or "Combat"
local distFromMob = 6

-- Auto-equip Katana se for Slayer
if style == "Katana" then
    local args = {"Katana", "EquippedEvents", true, true}
    rs.Remotes.Async:FireServer(unpack(args))
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.Name = "AutoFarmGUI"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "Premium AutoFarm"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Mob input
local MobBox = Instance.new("TextBox")
MobBox.Size = UDim2.new(0.9,0,0,30)
MobBox.Position = UDim2.new(0.05,0,0,40)
MobBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
MobBox.TextColor3 = Color3.fromRGB(255,255,255)
MobBox.PlaceholderText = "Nome do Mob"
MobBox.Text = targetMobName
MobBox.ClearTextOnFocus = false
MobBox.Font = Enum.Font.Gotham
MobBox.TextSize = 14
MobBox.Parent = MainFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9,0,0,30)
ToggleButton.Position = UDim2.new(0.05,0,0,80)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "Autofarm: OFF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = MainFrame

-- Toggle logic
ToggleButton.MouseButton1Click:Connect(function()
    autofarm = not autofarm
    ToggleButton.Text = "Autofarm: " .. (autofarm and "ON" or "OFF")
    targetMobName = MobBox.Text
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

-- Seguir mob
local function followMob(mob)
    local hrp = lp.Character.HumanoidRootPart
    local mobPos = mob.HumanoidRootPart.Position
    local targetPos = mobPos + Vector3.new(0, distFromMob, 0)
    
    local dist = (hrp.Position - mobPos).Magnitude
    if dist > 30 then
        hrp.CFrame = CFrame.new(targetPos, mobPos) * CFrame.Angles(math.rad(-90),0,0)
        wait(0.1)
    else
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos, mobPos) * CFrame.Angles(math.rad(-90),0,0)})
        tween:Play()
    end
end

-- Ataque
local function attackMob(mob)
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
