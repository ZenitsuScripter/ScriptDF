-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local AutoFarmActive = false
local followingSlayer = nil
local connection = nil
local executing = false

-- Helper functions
local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart") 
        or model:FindFirstChild("Torso") 
        or model:FindFirstChild("UpperTorso")
end

local function getHealth(model)
    return model:FindFirstChild("Health")
end

local function pickRandomSlayer()
    local slayers = {}
    for _, npc in ipairs(workspace:GetChildren()) do
        if npc.Name == "GenericSlayer" and npc:IsA("Model") then
            local root = getRoot(npc)
            local health = getHealth(npc)
            if root and health and health.Value > 0 then
                table.insert(slayers, npc)
            end
        end
    end
    if #slayers == 0 then return nil end
    return slayers[math.random(1, #slayers)]
end

local function attackSlayer(npc)
    if executing then return end
    local attackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Async")
    if npc:FindFirstChild("Block") then
        attackRemote:FireServer("Katana","Heavy")
    else
        attackRemote:FireServer("Katana","Server")
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,200,0,70)
Frame.Position = UDim2.new(0.05,0,0.05,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1,-10,1,-10)
ToggleButton.Position = UDim2.new(0,5,0,5)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.Text = "Autofarm: OFF"
ToggleButton.Parent = Frame

-- Toggle functionality
ToggleButton.MouseButton1Click:Connect(function()
    AutoFarmActive = not AutoFarmActive
    ToggleButton.Text = "Autofarm: " .. (AutoFarmActive and "ON" or "OFF")
    
    if AutoFarmActive then
        -- Start autofarm loop
        if connection then connection:Disconnect() end
        connection = RunService.RenderStepped:Connect(function()
            if not AutoFarmActive then return end
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart

            if not followingSlayer then
                followingSlayer = pickRandomSlayer()
                if followingSlayer then
                    print("Now following", followingSlayer.Name)
                else
                    return
                end
            end

            local root = getRoot(followingSlayer)
            local health = getHealth(followingSlayer)
            if not root or not health then return end

            -- Position 6 studs above NPC
            hrp.CFrame = CFrame.new(root.Position + Vector3.new(0,6,0), root.Position)

            if health.Value > 0 then
                attackSlayer(followingSlayer)
            else
                followingSlayer = nil
            end
        end)
    else
        -- Stop autofarm loop
        if connection then
            connection:Disconnect()
            connection = nil
        end
        followingSlayer = nil
        executing = false
    end
end)
