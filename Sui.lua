local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,360,0,56)
frame.Position = UDim2.new(0.5, -180, 0, 10)
frame.BackgroundTransparency = 0.25

local raidBtn = Instance.new("TextButton", frame)
raidBtn.Size = UDim2.new(0,120,0,48)
raidBtn.Position = UDim2.new(0,10,0,4)
raidBtn.Text = "TP Raid"

local coordsBtn = Instance.new("TextButton", frame)
coordsBtn.Size = UDim2.new(0,120,0,48)
coordsBtn.Position = UDim2.new(0,140,0,4)
coordsBtn.Text = "TP NPC Raid"

local nameBox = Instance.new("TextBox", frame)
nameBox.Size = UDim2.new(0,80,0,28)
nameBox.Position = UDim2.new(0,270,0,6)
nameBox.PlaceholderText = "player"
nameBox.ClearTextOnFocus = false

local tpSquare = Instance.new("TextButton", frame)
tpSquare.Size = UDim2.new(0,28,0,28)
tpSquare.Position = UDim2.new(0,352,0,6)
tpSquare.Text = "TP"

raidBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(7084.1,1752.3,1385.2) end
end)

coordsBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(-2379.6,1179.4,-1425.4) end
end)

local function findPlayerByPartial(text)
    if text=="" then return nil end
    text = string.lower(text)
    for _,p in pairs(game.Players:GetPlayers()) do
        if string.find(string.lower(p.Name), text, 1, true) then return p end
    end
    return nil
end

local function tpToPlayerByText()
    local txt = nameBox.Text or ""
    local target = findPlayerByPartial(txt)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end

tpSquare.MouseButton1Click:Connect(tpToPlayerByText)

nameBox.FocusLost:Connect(function(enter)
    if enter then tpToPlayerByText() end
end)
