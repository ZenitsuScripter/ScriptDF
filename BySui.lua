-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub v2.65",
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
    Boss = Window:AddTab({ Title = "Boss", Icon = "skull" }),
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
-- ABA BOSS
-- ================================
local selectedBosses = {}
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")

local MultiDropdown = Tabs.Boss:AddDropdown("BossDropdown", {
    Title = "Bosses disponíveis",
    Description = "Selecione os bosses que deseja farmar",
    Values = {"Kaigaku", "Boss2", "Boss3", "Boss4", "Boss5"},
    Multi = true,
    Default = {"Kaigaku"}
})

MultiDropdown:OnChanged(function(values)
    selectedBosses = values
end)

local farming = false

-- Função para encontrar o boss
local function findBoss(name)
    name = string.lower(name)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.lower(obj.Name) == name then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                return obj
            end
        end
    end
    return nil
end

-- Função de ataque M1
local function attackBoss()
    local args = {"Katana", "Server"}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

-- Função de movimentação até o boss
local function moveToTarget(targetPos)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end

    local hrp = char.HumanoidRootPart
    local direction = (targetPos - hrp.Position).Unit
    local newPos = hrp.Position + direction * 5 -- move gradualmente
    hrp.CFrame = CFrame.new(newPos, targetPos)
end

-- Farm principal
Tabs.Boss:AddToggle("FarmToggle", {
    Title = "Auto Farm Boss",
    Description = "Ataca automaticamente os bosses selecionados",
    Default = false,
    Callback = function(state)
        farming = state

        if farming then
            Fluent:Notify({
                Title = "Sui Hub",
                Content = "Farm iniciado.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Sui Hub",
                Content = "Farm finalizado.",
                Duration = 3
            })
        end

        task.spawn(function()
            while farming do
                local boss = nil

                -- verifica o primeiro boss vivo
                for _, name in ipairs(selectedBosses) do
                    boss = findBoss(name)
                    if boss then break end
                end

                if not boss then
                    Fluent:Notify({
                        Title = "Sui Hub",
                        Content = "Nenhum boss vivo encontrado.",
                        Duration = 3
                    })
                    farming = false
                    break
                end

                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local bossHRP = boss.HumanoidRootPart
                    local distance = (hrp.Position - bossHRP.Position).Magnitude

                    if distance > 100 then
                        -- Teleporta se estiver longe
                        hrp.CFrame = bossHRP.CFrame + Vector3.new(0, 2, 0)
                    elseif distance > 5 then
                        -- Move gradualmente até ele
                        moveToTarget(bossHRP.Position + Vector3.new(0, 2, 0))
                    else
                        -- Ataca quando perto
                        attackBoss()
                    end
                end

                -- Se o boss morrer, tenta o próximo
                if boss and boss:FindFirstChildOfClass("Humanoid") and boss.Humanoid.Health <= 0 then
                    boss = nil
                end

                task.wait(0.1)
            end
        end)
    end
})
