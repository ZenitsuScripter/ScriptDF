local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.1",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K,
    SaveConfig = false
})

-- ================================
-- ADICIONA ABAS
-- ================================
local Tabs = {
    Raid = Window:AddTab({ Title = "Raid", Icon = "star" }),
    PlayerTeleport = Window:AddTab({ Title = "Teleport", Icon = "eye" }),
    Discord = Window:AddTab({ Title = "Discord", Icon = "server" })
}

Window:SelectTab(1)

-- ================
-- BOTÕES ABA RAID
-- ================
Tabs.Raid:AddButton({
    Title = "TP Raid",
    Description = "Teleporte para Raid",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(7084.1, 1752.3, 1385.2)
        end
    end
})

Tabs.Raid:AddButton({
    Title = "TP NPC Raid",
    Description = "Teleporte para NPC Raid",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-2379.6, 1179.4, -1425.4)
        end
    end
})

-- ==============
-- AUTO BOSS RAID
-- ==============
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local autoRaid = false
local raidBosses = {"ShinobuRaid", "RengokuRaid", "KokushiboRaid", "Yoriichi"}

local function equipKatana()
    local args = {"Katana","EquippedEvents",true,true}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

local function findBoss()
    for _, name in ipairs(raidBosses) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and string.lower(obj.Name) == string.lower(name) then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    return obj
                end
            end
        end
    end
    return nil
end

local function attackBoss()
    local args = {"Katana","Server"}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

local function moveToBossGradual(targetPos)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart
    local direction = (targetPos - hrp.Position).Unit
    local newPos = hrp.Position + direction * 5
    hrp.CFrame = CFrame.new(newPos, targetPos)
end

Tabs.Raid:AddToggle("AutoRaidBossToggle", {
    Title = "Auto Boss Raid",
    Description = "Ataca automaticamente todos os bosses da raid",
    Default = false,
    Callback = function(state)
        autoRaid = state

        if autoRaid then
            equipKatana()
        end

        task.spawn(function()
            while autoRaid do
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    if autoRaid then equipKatana() end
                    continue
                end

                local boss = findBoss()
                if not boss then
                    task.wait(1)
                    continue
                end

                local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                local hum = boss:FindFirstChildOfClass("Humanoid")
                if not bossHRP or not hum then
                    task.wait(0.5)
                    continue
                end

                local hrp = char.HumanoidRootPart
                local distance = (hrp.Position - bossHRP.Position).Magnitude

                if distance > 50 then
                    hrp.CFrame = bossHRP.CFrame + Vector3.new(0,2,0)
                else
                    moveToBossGradual(bossHRP.Position + Vector3.new(0,2,0))
                end

                attackBoss()
                task.wait(0.5)

                if hum.Health <= 0 then
                    task.wait(10)
                end
            end
        end)
    end
})

-- ================================
-- ABA PLAYER TELEPORT (NOVA FUNÇÃO)
-- ================================
Tabs.PlayerTeleport:AddParagraph({
    Title = "Teleporte Personalizado(adm: Recomendo nao usar, estou testando)",
    Content = "Digite o nome do NPC e clique em Teleportar"
})

local npcTextBox = Instance.new("TextBox")
npcTextBox.Size = UDim2.new(0, 200, 0, 30)
npcTextBox.Position = UDim2.new(0, 10, 0, 50)
npcTextBox.PlaceholderText = "Nome do NPC"
npcTextBox.Text = ""
npcTextBox.ClearTextOnFocus = false
npcTextBox.Parent = Tabs.PlayerTeleport.Frame

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0, 100, 0, 30)
tpButton.Position = UDim2.new(0, 220, 0, 50)
tpButton.Text = "Teleporte"
tpButton.Parent = Tabs.PlayerTeleport.Frame

tpButton.MouseButton1Click:Connect(function()
    local npcName = npcTextBox.Text
    if npcName == "" then return end
    local player = game.Players.LocalPlayer
    local npc = workspace:FindFirstChild(npcName)
    if npc and npc:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
    end
end)

-- ===========
-- ABA DISCORD
-- ===========
Tabs.Discord:AddParagraph({
    Title = "Servidor Oficial do Sui Hub",
    Content = "Entre na nossa comunidade para receber atualizações e suporte!"
})

Tabs.Discord:AddButton({
    Title = "Copiar Link do Discord",
    Description = "Copia o link de convite para a área de transferência",
    Callback = function()
        setclipboard("https://discord.gg/MG7EPpfWwu")
        Fluent:Notify({
            Title = "Link Copiado!",
            Content = "O convite do Discord foi copiado para a área de transferência",
            Duration = 3
        })
    end
})
