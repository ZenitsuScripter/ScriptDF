-- Verifica se já existe o GUI
if game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ButtonScreen") then
    return
end

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
Key.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- cor moderna escura
Key.BorderSizePixel = 0
Key.AnchorPoint = Vector2.new(0,0)
Key.Position = UDim2.new(0.02, 0, 0.02, 0) -- canto superior esquerdo com afastamento
Key.Size = UDim2.new(0.08, 0, 0.08, 0)
Key.Font = Enum.Font.GothamBold
Key.Text = "SH"
Key.TextColor3 = Color3.fromRGB(255, 255, 255)
Key.TextScaled = true
Key.TextWrapped = true
Key.AutoButtonColor = true

-- Cantos arredondados
UICorner.CornerRadius = UDim.new(0.2, 0)
UICorner.Parent = Key

-- Contorno suave
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(70, 70, 70)
UIStroke.Transparency = 0.5
UIStroke.Parent = Key

-- Função para vincular tecla com cooldown
local canClick = true
local function LinkKey(Button)
    if Button then
        if not (Button:IsA("TextButton") or Button:IsA("ImageButton")) then
            warn("Classe esperada: 'TextButton' ou 'ImageButton'. Obtido: "..Button.ClassName)
            return
        end

        local keey = Enum.KeyCode.K
        Button.MouseButton1Click:Connect(function()
            if not canClick then return end
            canClick = false

            keypress(keey)
            wait(0.05)
            keyrelease(keey)

            wait(0.5) -- cooldown
            canClick = true
        end)
    else
        warn("Botão não encontrado ou não definido.")
    end
end

LinkKey(Key)

-- Efeito flutuante vertical suave
local floatAmount = 8 -- altura máxima do movimento
local floatSpeed = 2 -- velocidade do movimento
local initialY = Key.Position.Y.Scale

RunService.RenderStepped:Connect(function()
    local offset = math.sin(tick() * floatSpeed) * floatAmount
    Key.Position = UDim2.new(Key.Position.X.Scale, 0, initialY, offset)
end)
