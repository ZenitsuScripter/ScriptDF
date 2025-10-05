-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub v5.0",
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
    Discord = Window:AddTab({ Title = "Discord", Icon = "server" })
}

Window:SelectTab(1)

-- ================================
-- BOTÕES ABA RAID
-- ================================
Tabs.Raid:AddButton({
    Title = "TP Raid",
    Description = "Teleport to Raid",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(7084.1, 1752.3, 1385.2)
        end
    end
})

Tabs.Raid:AddButton({
    Title = "TP NPC Raid",
    Description = "Teleport to NPC Raid",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-2379.6, 1179.4, -1425.4)
        end
    end
})

-- ================================
-- ABA DISCORD
-- ================================
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

-- ================================
-- AUTO RAID BOSS
-- ================================
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local autoRaid = false
local raidBosses = {"Zenitsu","ShinobuRaid", "RengokuRaid", "KokushiboRaid", "Yoriichi"}

-- Função para equipar Katana
local function equipKatana()
    local args = {"Katana","EquippedEvents",true,true}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

-- Função para encontrar o boss vivo
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

-- Função de ataque
local function attackBoss()
    local args = {"Katana","Server"}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

-- Função para voar gradualmente até o boss (distância <=50)
local function moveToBossGradual(targetPos)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart
    local direction = (targetPos - hrp.Position).Unit
    local newPos = hrp.Position + direction * 5 -- ajusta a cada loop
    hrp.CFrame = CFrame.new(newPos, targetPos)
end

-- Cria toggle na aba Raid
Tabs.Raid:AddToggle("AutoRaidBossToggle", {
    Title = "Auto Boss Raid",
    Description = "Ataca automaticamente todos os bosses da raid",
    Default = false,
    Callback = function(state)
        autoRaid = state

        if autoRaid then
            -- Equipa Katana quando ligar
            equipKatana()
        end

        task.spawn(function()
            while task.wait(0.2) do
                if not autoRaid then break end
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then continue end

                -- Verifica se o player morreu e renasceu
                if not player.Character:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    equipKatana()
                    continue
                end

                local boss = findBoss()
                if not boss then continue end

                local hrp = player.Character.HumanoidRootPart
                local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                local hum = boss:FindFirstChildOfClass("Humanoid")
                if not hrp or not bossHRP or not hum then continue end

                local distance = (hrp.Position - bossHRP.Position).Magnitude

                if distance > 50 then
                    -- Teleporta diretamente se estiver longe
                    hrp.CFrame = bossHRP.CFrame + Vector3.new(0,2,0)
                else
                    -- Cola e vai gradualmente até o boss
                    moveToBossGradual(bossHRP.Position + Vector3.new(0,2,0))
                end

                -- Ataca
                attackBoss()

                -- Se o boss morrer, espera 1s antes de procurar outro
                if hum.Health <= 0 then
                    task.wait(3)
                end
            end
        end)
    end
})
