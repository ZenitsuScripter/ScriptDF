-- ================================
-- CARREGA FLUENT
-- ================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- ================================
-- CRIA A JANELA DO HUB
-- ================================
local Window = Fluent:CreateWindow({
    Title = "Sui Hub v1.1",
    SubTitle = "by Suiryuu",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K, -- tecla K
    SaveConfig = false
})

-- ================================
-- ADICIONA ABAS
-- ================================
local Tabs = {
    Raid = Window:AddTab({ Title = "Raid", Icon = "star" }),
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

-- Cria ScreenGui
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
toggleButton.Draggable = true
toggleButton.Parent = screenGui

-- ================================
-- FUNÇÕES DE ABRIR/FECHAR HUB
-- ================================
-- Minimiza o Hub, botão continua visível
local function minimizeHub()
    Window.Visible = false
end

-- Fecha completamente o Hub, remove botão flutuante
local function closeHub()
    Window.Visible = false
    if toggleButton and toggleButton.Parent then
        toggleButton:Destroy()
    end
end

-- Alterna Hub (usado no botão flutuante e tecla K)
local function toggleHub()
    if Window.Visible then
        minimizeHub()
    else
        Window.Visible = true
    end
end

-- ================================
-- BOTÃO FLUTUANTE
-- ================================
toggleButton.MouseButton1Click:Connect(toggleHub)

-- ================================
-- TECLA K
-- ================================
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == MINIMIZE_KEY then
        toggleHub()
    end
end)

-- ================================
-- OPCIONAL: botão “X” dentro do Hub para fechar completamente
-- ================================
local CloseButton = Window:AddButton({
    Title = "Fechar Hub",
    Description = "Fecha o Hub e remove o botão flutuante",
    Callback = closeHub
})
