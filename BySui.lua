-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.75",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 350),
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
    PlayerTeleport = Window:AddTab({ Title = "Teleport", Icon = "eye" })
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
-- BOTÃO FIXO NA TELA (SEM FLUTUAR)
-- ================================
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local MINIMIZE_KEY = Enum.KeyCode.K

-- Cria ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuiHubGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false -- mantém os controles mobile
screenGui.Parent = playerGui

-- Cria botão fixo
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHubButton"
toggleButton.Size = UDim2.fromOffset(60, 60)

-- Posição fixa no canto superior esquerdo
toggleButton.Position = UDim2.new(0, 10, 0, 50)

toggleButton.AnchorPoint = Vector2.new(0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.Text = "K"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.ZIndex = 1 -- baixo para não cobrir controles
toggleButton.AutoButtonColor = true
toggleButton.Parent = screenGui

-- ================================
-- FUNÇÃO DE TOGGLE DO HUB
-- ================================
local function toggleHub()
    Window.Visible = not Window.Visible
end

-- ================================
-- MESMA LOGICA DO BOTÃO DA TECLA C
-- ================================
local function LinkKey(Button, KeyCode)
    if not Button then
        warn("Botão não encontrado ou não definido.")
        return
    end
    if not (Button:IsA("TextButton") or Button:IsA("ImageButton")) then
        warn("Classe esperada: 'TextButton' ou 'ImageButton'. Obtido: '"..Button.ClassName.."'")
        return
    end

    Button.MouseButton1Click:Connect(function()
        if type(keypress) == "function" and type(keyrelease) == "function" then
            keypress(KeyCode)
            task.wait(0.05)
            keyrelease(KeyCode)
        end
    end)
end

-- vincula botão fixo à tecla K
LinkKey(toggleButton, MINIMIZE_KEY)

-- conecta a tecla K no teclado
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == MINIMIZE_KEY then
        toggleHub()
    end
end)
