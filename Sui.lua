-- Evita criar múltiplos GUIs
if game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("ButtonScreen") then
    return
end

local Player = game.Players.LocalPlayer
local ButtonScreen = Instance.new("ScreenGui")
local Key = Instance.new("TextButton")
local UIStroke = Instance.new("UIStroke")

ButtonScreen.Name = "ButtonScreen"
ButtonScreen.Parent = Player:WaitForChild("PlayerGui")
ButtonScreen.DisplayOrder = 999

-- Configuração do botão
Key.Name = "Key"
Key.Parent = ButtonScreen
Key.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Key.BorderSizePixel = 0
Key.AnchorPoint = Vector2.new(0,0)
Key.Position = UDim2.new(0.02, 0, 0.02, 0)
Key.Size = UDim2.new(0.08, 0, 0.08, 0) -- quadrado
Key.Font = Enum.Font.GothamBold
Key.Text = "SH"
Key.TextColor3 = Color3.fromRGB(255, 255, 255)
Key.TextScaled = true
Key.TextWrapped = true
Key.AutoButtonColor = true

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

            wait(0.5)
            canClick = true
        end)
    else
        warn("Botão não encontrado ou não definido.")
    end
end

LinkKey(Key)

-- Tornar arrastável
local dragging = false
local dragInput, mousePos, framePos

Key.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = Key.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Key.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        Key.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)
