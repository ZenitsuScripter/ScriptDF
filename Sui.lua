-- carregar script externo
local success, err = pcall(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/AJyhhWtz"))()
end)

if not success then
    warn("Erro ao carregar o script externo:", err)
end

-- ========== SUI HUB ==========
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.4",
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

Window:SelectTab(1)

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
local monitored = false -- evita múltiplas conexões do monitor

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
        -- Evita duplicatas
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
        -- se char não existir ou não tiver HRP, espera e continua (isso permite o respawn)
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
                    -- teleporta perto do trinket (sobe 3 studs para evitar ficar preso no chão)
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
            -- nada pra coletar: volta pro checkpoint se existir e o char permitir
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
    -- monitora workspace e replicatedStorage (ou onde os trinkets realmente aparecem)
    monitor(workspace)
    monitor(replicatedStorage)
end

local function ativarAutoTP()
    char = player.Character or player.CharacterAdded:Wait()
    -- espera HRP para evitar problemas imediatos
    char:WaitForChild("HumanoidRootPart", 5)
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        -- se não conseguiu, tenta continuar; o processarTrinkets lida com ausência temporária
    end
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

-- Atualiza 'char' quando o player respawna, mantendo o sistema ativo
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    -- pequena espera para o HRP existir
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if hrp then
        -- se o auto estiver ativo, atualiza checkpoint pro novo hrp (ou mantém o anterior se quiser)
        if ativo then
            -- coluna de decisão: manter checkpoint antigo ou atualizar pro novo? vamos manter o checkpoint salvo
            -- mas teleporta o player de volta ao checkpoint para retomar coleta
            if checkpoint then
                pcall(function() char.HumanoidRootPart.CFrame = CFrame.new(checkpoint) end)
            else
                checkpoint = hrp.Position
            end
        end
    end
end)

-- também opcional: se quiser limpar lista de trinkets quando o personagem for removido
player.CharacterRemoving:Connect(function(oldChar)
    -- não limpa trinketsAtivos aqui, pois queremos que o loop só ignore enquanto não houver char
    -- mas poderíamos limpar referências inválidas para evitar vazamento de memória:
    for i = #trinketsAtivos, 1, -1 do
        local v = trinketsAtivos[i]
        if not v or not v.Parent then
            table.remove(trinketsAtivos, i)
        end
    end
end)

-- toggle no Fluent
Tabs.AutoFarm:Remove("AutoTrinketToggle") -- garante que não duplique caso o toggle exista (opcional)
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
