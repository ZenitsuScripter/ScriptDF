-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub v2.2",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 350),
    Acrylic = true,
    Theme = "Dark",
    SaveConfig = false
})

-- ================================
-- ADICIONA ABAS
-- ================================
local Tabs = {
    Raid = Window:AddTab({ Title = "Raid", Icon = "star" }),
    Boss = Window:AddTab({ Title = "Boss", Icon = "swords" }),
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
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local selectedBosses = {}
local farmActive = false
local farmingThread = nil

local BossDropdown = Tabs.Boss:AddDropdown("BossSelector", {
    Title = "Selecione os Bosses",
    Description = "Escolha múltiplos bosses para farmar (prioridade: ordem da lista)",
    Values = {"Kaigaku", "Boss 2", "Boss 3", "Boss 4", "Boss 5"},
    Multi = true,
    Default = {"Kaigaku"}
})

BossDropdown:OnChanged(function(values)
    selectedBosses = values
end)

local function getBossByName(name)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower() == name:lower() and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
            return obj
        end
    end
end

local function moveToBoss(boss)
    local char = player.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart
    local targetPos = boss:FindFirstChild("HumanoidRootPart") and boss.HumanoidRootPart.Position
    if not targetPos then return end

    local dist = (hrp.Position - targetPos).Magnitude

    if dist > 100 then
        hrp.CFrame = boss.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
    else
        -- voo gradual
        local direction = (targetPos - hrp.Position).Unit
        hrp.CFrame = hrp.CFrame + direction * 3
    end
end

local function attackBoss()
    VirtualUser:Button1Down(Vector2.new(0, 0))
    task.wait(0.1)
    VirtualUser:Button1Up(Vector2.new(0, 0))
end

local function startFarming()
    farmingThread = task.spawn(function()
        while farmActive do
            task.wait(0.1)

            local bossFound = nil
            for _, name in ipairs(selectedBosses) do
                local boss = getBossByName(name)
                if boss then
                    bossFound = boss
                    break
                end
            end

            if bossFound then
                moveToBoss(bossFound)
                attackBoss()
            end
        end
    end)
end

local function stopFarming()
    farmActive = false
    if farmingThread then
        task.cancel(farmingThread)
        farmingThread = nil
    end
end

Tabs.Boss:AddToggle("AutoFarmBoss", {
    Title = "Auto Farm Boss",
    Description = "Ataca automaticamente os bosses selecionados",
    Default = false,
    Callback = function(state)
        farmActive = state
        if state then
            startFarming()
            Fluent:Notify({
                Title = "Auto Farm Ativado",
                Content = "O farm de bosses foi iniciado.",
                Duration = 3
            })
        else
            stopFarming()
            Fluent:Notify({
                Title = "Auto Farm Desativado",
                Content = "O farm de bosses foi interrompido.",
                Duration = 3
            })
        end
    end
})
