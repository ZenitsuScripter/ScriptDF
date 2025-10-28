-- ========== SUI HUB ==========
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.52",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K,
    SaveConfig = false
})

-- =============
-- ADICIONA ABAS
-- =============
local Tabs = {
    Raid = Window:AddTab({ Title = "Raid", Icon = "star" }),
    PlayerTeleport = Window:AddTab({ Title = "Teleport", Icon = "eye" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Discord = Window:AddTab({ Title = "Discord", Icon = "server" })
}

-- ===============
-- BOTÕES ABA RAID
-- ===============
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

-- ====================
-- ABA TELEPORT PLAYERS
-- ====================
local selectedPlayer = nil
local selectedBreath = nil

local PlayersDropdown = Tabs.PlayerTeleport:AddDropdown("PlayersDropdown", {
    Title = "Teleporte Player",
    Description = "Selecione um Player",
    Values = {},
    Multi = false,
    Default = "Selecionar"
})

PlayersDropdown:OnChanged(function(value)
    selectedPlayer = value
end)

local function updatePlayerList()
    local players = game:GetService("Players"):GetPlayers()
    local names = {}
    for _, p in ipairs(players) do
        table.insert(names, p.Name)
    end
    PlayersDropdown:SetValues(names)
end

game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

Tabs.PlayerTeleport:AddButton({
    Title = "Teleporte para o Player",
    Description = "Teleporte para o Player Selecionado",
    Callback = function()
        if not selectedPlayer then return end
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

-- ===========
-- TREINADORES
-- ===========
local BreathLocations = {
    ["Água"] = CFrame.new(-926.5, 849.2, -989.1),
    ["Rocha"] = CFrame.new(-1707.1, 1045.5, -1371.2),
    ["Besta"] = CFrame.new(-3104.5, 783.6, -6599.5),
    ["Chamas"] = CFrame.new(1492.0, 1240.0, -353.7),
    ["Amor"] = CFrame.new(1188.3, 1082.1, -1113.8),
    ["Cobra"] = CFrame.new(989.9, 1075.8, -1136.3),
    ["Som"] = CFrame.new(-1258.8, 873.0, -6438.8),
    ["Flor"] = CFrame.new(-1315.6, 878.4, -6236.8),
    ["Inseto"] = CFrame.new(-1642.8, 912.3, -6488.4),
    ["Névoa"] = CFrame.new(3235.8, 784.7, -4046.5),
    ["Vento"] = CFrame.new(-3288.6, 712.6, -1255.1),
    ["Trovão"] = CFrame.new(-699.1, 700.0, 538.6),
    ["Sol"] = CFrame.new(389.2, 821.8, -416.5),
    ["Lua"] = CFrame.new(1833.4, 1121.7, -5949.5)
}

local RespDropdown = Tabs.PlayerTeleport:AddDropdown("RespDropdown", {
    Title = "Respirações",
    Description = "Selecione uma respiração",
    Values = {"Água", "Rocha", "Besta", "Chamas", "Amor", "Cobra", "Som", "Flor", "Inseto", "Névoa", "Vento", "Trovão", "Sol", "Lua"},
    Multi = false,
    Default = "Selecionar"
})

RespDropdown:OnChanged(function(value)
    selectedBreath = value
end)

Tabs.PlayerTeleport:AddButton({
    Title = "Teleporte para a Respiração",
    Description = "Teleporte para a Respiração Selecionada",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        if selectedBreath and BreathLocations[selectedBreath] then
            hrp.CFrame = BreathLocations[selectedBreath]
        end
    end
})

-- ================
-- AUTO TP TRINKETS
-- ================
local TrinketPriority = {
    ["Perfect Crystal"] = 1,
    ["Green Jewel"] = 2,
    ["Red Jewel"] = 3,
    ["Gold Crown"] = 4,
    ["Ancient Coin"] = 5,
    ["Gold Jar"] = 6,
    ["Golden Ring"] = 7,
    ["Gold Goblet"] = 8,
    ["Silver Jar"] = 9,
    ["Silver Ring"] = 10,
    ["Silver Goblet"] = 11,
    ["Bronze Jar"] = 12,
    ["Copper Goblet"] = 13,
    ["Rusty Goblet"] = 14
}

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local ativo = false
local checkpoint = nil
local char = player.Character or player.CharacterAdded:Wait()
local trinketsAtivos = {}
local monitored = false

local function getPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then return p.Position end
        end
    end
    return nil
end

local function interact(item)
    if not item then return end
    for _, prompt in ipairs(item:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(prompt) end)
        end
    end
end

local function addTrinket(item)
    if not item or not item.Name then return end
    if TrinketPriority[item.Name] then
        for _, v in ipairs(trinketsAtivos) do
            if v == item then return end
        end
        table.insert(trinketsAtivos, item)
    end
end

local function removeTrinket(item)
    for i, v in ipairs(trinketsAtivos) do
        if v == item then
            table.remove(trinketsAtivos, i)
            break
        end
    end
end

local function processarTrinkets()
    while ativo do
        if not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.3)
            continue
        end

        if #trinketsAtivos > 0 then
            table.sort(trinketsAtivos, function(a, b)
                local pa = TrinketPriority[a and a.Name or ""] or 999
                local pb = TrinketPriority[b and b.Name or ""] or 999
                return pa < pb
            end)

            local alvo = trinketsAtivos[1]
            if alvo and alvo.Parent then
                local pos = getPosition(alvo)
                if pos and char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    task.wait(0.25)
                    interact(alvo)
                    removeTrinket(alvo)
                    task.wait(0.4)
                else
                    removeTrinket(alvo)
                end
            else
                removeTrinket(alvo)
            end
        else
            if checkpoint and char and char:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    char.HumanoidRootPart.CFrame = CFrame.new(checkpoint)
                end)
            end
            task.wait(0.3)
        end
        task.wait(0.1)
    end
end

local function monitor(container)
    if not container then return end
    for _, obj in pairs(container:GetChildren()) do
        addTrinket(obj)
    end
    container.ChildAdded:Connect(function(child)
        if ativo then addTrinket(child) end
    end)
    container.ChildRemoved:Connect(function(child)
        removeTrinket(child)
    end)
end

local function iniciarMonitoramento()
    if monitored then return end
    monitored = true
    monitor(workspace)
    monitor(replicatedStorage)
end

local function ativarAutoTP()
    char = player.Character or player.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart", 5)
    if not ativo then
        checkpoint = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or checkpoint
        ativo = true
        iniciarMonitoramento()
        task.spawn(processarTrinkets)
    end
end

local function desativarAutoTP()
    ativo = false
    if checkpoint and char and char:FindFirstChild("HumanoidRootPart") then
        pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(checkpoint) end)
    end
    trinketsAtivos = {}
end

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        if ativo then
            if checkpoint then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(checkpoint) end)
            else
                checkpoint = hrp.Position
            end
        end
    end
end)

player.CharacterRemoving:Connect(function(oldChar)
    for i = #trinketsAtivos, 1, -1 do
        local v = trinketsAtivos[i]
        if not v or not v.Parent then
            table.remove(trinketsAtivos, i)
        end
    end
end)

-- ===========
-- ABA AUTO FARM
-- ===========
Tabs.AutoFarm:AddToggle("AutoTrinketToggle", {
    Title = "Auto Trinkets",
    Description = "Colete todos os trinkets automaticamente",
    Default = false,
    Callback = function(state)
        if state then
            ativarAutoTP()
        else
            desativarAutoTP()
        end
    end
})

-- =====================
-- AUTO PICKUP (AURA / TELEPORT) REFACTORED
-- =====================
local lp = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local autoPickupType = "Selecionar" -- valor inicial
local autoPickupActive = false
local pickupRange = 20
local teleportCheckpoint = nil -- só para Teleport
local monitoredDrops = {} -- tabela de drops ativos

-- Função para coletar drops
local function collectDrop(drop)
    if drop and drop.Parent then
        pcall(function()
            rs.Remotes.Async:FireServer("Character", "Interaction", drop)
        end)
    end
end

-- Função para adicionar drops à lista
local function monitorContainer(container)
    for _, obj in pairs(container:GetChildren()) do
        if obj.Name == "DropItem" then
            monitoredDrops[obj] = obj
        end
    end
    container.ChildAdded:Connect(function(child)
        if child.Name == "DropItem" then
            monitoredDrops[child] = child
        end
    end)
    container.ChildRemoved:Connect(function(child)
        monitoredDrops[child] = nil
    end)
end

-- Inicializa monitoramento
monitorContainer(ws)

-- Loop do Auto Pickup
local function AutoPickupLoop()
    while autoPickupActive do
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
        else
            local hrp = lp.Character.HumanoidRootPart

            if autoPickupType == "Selecionar" then
                task.wait(0.3)
            else
                local drops = {}
                for dropObj, drop in pairs(monitoredDrops) do
                    if drop and drop.Parent then
                        local pos = (drop:IsA("BasePart") and drop.Position) or (drop.PrimaryPart and drop.PrimaryPart.Position)
                        if pos then
                            table.insert(drops, {obj = drop, pos = pos, dist = (pos - hrp.Position).Magnitude})
                        end
                    end
                end

                if #drops > 0 then
                    table.sort(drops, function(a, b)
                        return a.dist < b.dist
                    end)

                    for _, dropData in ipairs(drops) do
                        local drop = dropData.obj
                        local pos = dropData.pos
                        if drop and drop.Parent then
                            if autoPickupType == "Teleport" then
                                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                                collectDrop(drop)
                                task.wait(0.5)
                            else -- Aura
                                if dropData.dist <= pickupRange then
                                    collectDrop(drop)
                                end
                            end
                        end
                    end
                else
                    -- Sem drops: volta pro checkpoint se Teleport
                    if autoPickupType == "Teleport" and teleportCheckpoint then
                        hrp.CFrame = CFrame.new(teleportCheckpoint)
                    end
                    task.wait(0.3)
                end
            end
        end
        RunService.Heartbeat:Wait()
    end

    -- Ao desativar, Teleport volta para checkpoint
    if autoPickupType == "Teleport" and teleportCheckpoint and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(teleportCheckpoint)
    end
end

-- Mantém loop ativo mesmo após respawn
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if autoPickupActive then
        if autoPickupType == "Teleport" and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(teleportCheckpoint)
        end
        coroutine.wrap(AutoPickupLoop)()
    end
end)

-- Dropdown do Auto Pickup
local PickupDropdown = Tabs.AutoFarm:AddDropdown("PickupMode", {
    Title = "Modo Pickup",
    Description = "Selecionar",
    Values = {"Aura", "Teleport"},
    Multi = false,
    Default = "Selecionar"
})

PickupDropdown:OnChanged(function(value)
    autoPickupType = value
end)

-- Toggle para ativar/desativar
Tabs.AutoFarm:AddToggle("AutoPickupToggle", {
    Title = "Auto Pickup",
    Description = "Ativa o Auto Pickup selecionado",
    Default = false,
    Callback = function(state)
        autoPickupActive = state
        if state then
            if autoPickupType == "Teleport" and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                teleportCheckpoint = lp.Character.HumanoidRootPart.Position
            end
            coroutine.wrap(AutoPickupLoop)()
        end
    end
})

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
            Duration = 5
        })
    end
})

Window:SelectTab(1)
