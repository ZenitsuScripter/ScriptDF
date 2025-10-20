-- Verifica se já existe o GUI
if game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ButtonScreen") then
    return -- Sai do script se o GUI já existir
end

-- Criação do GUI
local ButtonScreen = Instance.new("ScreenGui")
local Key = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local RunService = game:GetService("RunService")

ButtonScreen.Name = "ButtonScreen"
ButtonScreen.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ButtonScreen.DisplayOrder = 999

-- Configuração do botão
Key.Name = "Key"
Key.Parent = ButtonScreen
Key.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Key.BorderSizePixel = 0
Key.AnchorPoint = Vector2.new(1, 1)
Key.Position = UDim2.new(0.98, 0, 0.98, 0)
Key.Size = UDim2.new(0.08, 0, 0.08, 0)
Key.Font = Enum.Font.GothamSemibold
Key.Text = "SH"
Key.TextColor3 = Color3.fromRGB(255, 255, 255)
Key.TextScaled = true
Key.TextWrapped = true
Key.AutoButtonColor = true

-- Cantos arredondados
UICorner.CornerRadius = UDim.new(0.25, 0)
UICorner.Parent = Key

-- Contorno suave
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Transparency = 0.5
UIStroke.Parent = Key

-- Função para vincular a tecla com cooldown
local canClick = true -- controla se pode clicar

local function LinkKey(Button)
    if Button then
        if not (Button:IsA("TextButton") or Button:IsA("ImageButton")) then
            warn("Classe esperada: 'TextButton' ou 'ImageButton'. Obtido: '"..Button.ClassName.."'")
            return nil
        end

        local keey = Enum.KeyCode.K
        Button.MouseButton1Click:Connect(function()
            if not canClick then return end
            canClick = false

            -- Dispara imediatamente
            keypress(keey)
            wait(0.05)
            keyrelease(keey)

            -- Espera 0.5s antes de permitir outro clique
            wait(0.5)
            canClick = true
        end)

    else
        warn("Botão não encontrado ou não definido.")
    end
end

LinkKey(Key)

-- Efeito flutuante
local floatAmount = 10 -- altura máxima do movimento
local floatSpeed = 2 -- velocidade do movimento
local initialPosition = Key.Position

RunService.RenderStepped:Connect(function(deltaTime)
    local offset = math.sin(tick() * floatSpeed) * floatAmount
    Key.Position = initialPosition + UDim2.new(0, 0, 0, -offset)
end)
