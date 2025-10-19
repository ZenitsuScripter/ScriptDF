local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.31",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K,
    SaveConfig = false
})

-- BOTÃO "K" PARA MOBILE
local ButtonScreen = Instance.new("ScreenGui")
local OpenButton = Instance.new("TextButton")

ButtonScreen.Name = "HubButton"
ButtonScreen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ButtonScreen.DisplayOrder = 999

OpenButton.Text = "K"
OpenButton.Size = UDim2.new(0.06, 0, 0.08, 0)
OpenButton.Position = UDim2.new(0.02, 0, 0.98, 0)
OpenButton.AnchorPoint = Vector2.new(0, 1)
OpenButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OpenButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.Font = Enum.Font.SourceSans
OpenButton.TextScaled = true
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextWrapped = true
OpenButton.Parent = ButtonScreen

OpenButton.MouseButton1Click:Connect(function()
    Window:Toggle() -- abre/fecha o hub corretamente no mobile
end)

-- ====================
-- ADICIONA ABAS
-- ====================
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
-- TREINADORES / RESPIRAÇÕES
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
