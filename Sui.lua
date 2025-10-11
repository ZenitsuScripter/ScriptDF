-- // WindUI Loader
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- // Cria a Janela Principal
local Window = WindUI:CreateWindow({
    Title = "Sui Hub v1.21",
    SubTitle = "by Suiryuu",
    Theme = "Dark",
    Size = UDim2.fromOffset(500, 350),
    Transparent = false
})

-- // Cria Abas
local RaidTab = Window:CreateTab("Raid", { Icon = "star" })
local TeleportTab = Window:CreateTab("Teleport", { Icon = "eye" })
local AutoFarmTab = Window:CreateTab("Auto Farm", { Icon = "swords" })
local DiscordTab = Window:CreateTab("Discord", { Icon = "server" })

Window:SelectTab(1)

---------------------------------------------------
-- ABA RAID
---------------------------------------------------
RaidTab:CreateButton({
    Title = "TP Raid",
    Description = "Teleporte para Raid",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(7084.1, 1752.3, 1385.2)
        end
    end
})

RaidTab:CreateButton({
    Title = "TP NPC Raid",
    Description = "Teleporte para NPC Raid",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-2379.6, 1179.4, -1425.4)
        end
    end
})

---------------------------------------------------
-- ABA TELEPORT
---------------------------------------------------
local selectedPlayer = nil
local PlayersDropdown = TeleportTab:CreateDropdown({
    Title = "Selecionar Player",
    Description = "Escolha um player para teleportar",
    Values = {},
    Multi = false,
    Default = "Selecione",
    Callback = function(value)
        selectedPlayer = value
    end
})

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

TeleportTab:CreateButton({
    Title = "Teleporte para o Player",
    Description = "Teleporta para o player selecionado",
    Callback = function()
        if not selectedPlayer then return end
        local target = game.Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

---------------------------------------------------
-- AUTO FARM TRINKETS
---------------------------------------------------
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

local function getPosition(obj)
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
    for _, prompt in ipairs(item:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(prompt) end)
        end
    end
end

local function addTrinket(item)
    if TrinketPriority[item.Name] then
        table.insert(trinketsAtivos, item)
    end
end

local function removeTrinket(item)
    for i,v in ipairs(trinketsAtivos) do
        if v == item then
            table.remove(trinketsAtivos, i)
            break
        end
    end
end

local function processarTrinkets()
    while ativo do
        if #trinketsAtivos > 0 then
            table.sort(trinketsAtivos, function(a,b)
                return TrinketPriority[a.Name] < TrinketPriority[b.Name]
            end)

            local alvo = trinketsAtivos[1]
            if alvo and alvo.Parent then
                local pos = getPosition(alvo)
                if pos and char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
                    task.wait(0.3)
                    interact(alvo)
                    removeTrinket(alvo)
                    task.wait(0.5)
                else
                    removeTrinket(alvo)
                end
            else
                removeTrinket(alvo)
            end
        else
            if checkpoint and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(checkpoint)
            end
            task.wait(0.3)
        end
        task.wait(0.1)
    end
end

local function monitor(container)
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
    monitor(workspace)
    monitor(replicatedStorage)
end

local function ativarAutoTP()
    char = player.Character or player.CharacterAdded:Wait()
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if not ativo then
        checkpoint = char.HumanoidRootPart.Position
        ativo = true
        iniciarMonitoramento()
        task.spawn(processarTrinkets)
    end
end

local function desativarAutoTP()
    ativo = false
    if checkpoint and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(checkpoint)
    end
    trinketsAtivos = {}
end

AutoFarmTab:CreateToggle({
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

---------------------------------------------------
-- DISCORD TAB
---------------------------------------------------
DiscordTab:CreateParagraph({
    Title = "Servidor Oficial do Sui Hub",
    Content = "Entre na nossa comunidade para receber atualizações e suporte!"
})

DiscordTab:CreateButton({
    Title = "Copiar Link do Discord",
    Description = "Copia o link de convite para a área de transferência",
    Callback = function()
        setclipboard("https://discord.gg/MG7EPpfWwu")
        WindUI:Notify({
            Title = "Link Copiado!",
            Content = "O convite do Discord foi copiado para a área de transferência",
            Duration = 5
        })
    end
})
