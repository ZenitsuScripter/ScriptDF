
-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub v4.1",
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
-- ABA RAID - BOTÕES EXISTENTES
-- ================================
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local autoRaidBoss = false
local raidBosses = {"ShinobuRaid", "RengokuRaid", "KokushiboRaid", "Yoriichi"}

Tabs.Raid:AddButton({
    Title = "TP Raid",
    Description = "Teleport to Raid",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(7084.1, 1752.3, 1385.2)
        end
    end
})

Tabs.Raid:AddButton({
    Title = "TP NPC Raid",
    Description = "Teleport to NPC Raid",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(-2379.6, 1179.4, -1425.4)
        end
    end
})

-- ================================
-- FUNÇÕES AUTO RAID BOSS
-- ================================
local function findRaidBoss()
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
    local args = {"Katana", "Server"}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

local function equipKatana()
    local args = {"Katana", "EquippedEvents", true, true}
    replicatedStorage:WaitForChild("Remotes"):WaitForChild("Async"):FireServer(unpack(args))
end

-- ================================
-- TOGGLE AUTO RAID BOSS
-- ================================
Tabs.Raid:AddToggle("AutoRaidBoss", {
    Title = "Auto Boss Raid",
    Description = "Ataca automaticamente todos os bosses da raid",
    Default = false,
    Callback = function(state)
        autoRaidBoss = state
        if autoRaidBoss then
            equipKatana()
        end

        task.spawn(function()
            while task.wait(0.1) do
                if not autoRaidBoss then break end

                local boss = findRaidBoss()
                if boss and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                    if bossHRP then
                        -- Mantém a lógica de TP original sem alterações
                        hrp.CFrame = bossHRP.CFrame + Vector3.new(0,2,0)
                        attackBoss()
                    end
                end
            end
        end)
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
