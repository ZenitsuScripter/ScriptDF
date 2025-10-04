-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 400),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K, -- tecla K
    SaveConfig = false
})

-- ================================
-- ADICIONA ABAS
-- ================================
local Tabs = {
    Raid = Window:AddTab({ Title = "Raid", Icon = "eye" }),
    PlayerTeleport = Window:AddTab({ Title = "Teleport", Icon = "eye" })
}

-- Seleciona a primeira aba por padrão
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
-- BOTÃO FLUTUANTE (PC + MOBILE)
-- ================================
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local MINIMIZE_KEY = Enum.KeyCode.K

-- Cria ScreenGui no topo
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuiHubGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

-- Cria botão flutuante
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.fromOffset(50, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 70) -- abaixado para 70px do topo
toggleButton.AnchorPoint = Vector2.new(0,0)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.Text = "K"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.ZIndex = 9999
toggleButton.AutoButtonColor = true
toggleButton.Draggable = true -- permite arrastar
toggleButton.Parent = screenGui

-- ================================
-- FUNÇÃO DE TOGGLE (mesma lógica da tecla K)
-- ================================
local function toggleHub()
    Window.Visible = not Window.Visible
end

-- ================================
-- SIMULA A TECLA K (como seu código C)
-- ================================
local function simulateKeyPress(key)
    local usedExploit = false

    if type(keypress) == "function" then
        local ok, _ = pcall(function()
            keypress(key)
            task.wait(0.05)
            if type(keyrelease) == "function" then
                keyrelease(key)
            end
        end)
        if ok then usedExploit = true end
    end

    if not usedExploit and type(press_key) == "function" then
        local ok, _ = pcall(function()
            press_key(key)
            task.wait(0.05)
            if type(release_key) == "function" then release_key(key) end
        end)
        usedExploit = ok
    end

    -- fallback caso não haja funções de exploit
    if not usedExploit then
        toggleHub()
    end
end

-- conecta o clique do botão flutuante
toggleButton.MouseButton1Click:Connect(function()
    simulateKeyPress(MINIMIZE_KEY)
end)

-- conecta a tecla K no teclado
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == MINIMIZE_KEY then
        toggleHub()
    end
end)
