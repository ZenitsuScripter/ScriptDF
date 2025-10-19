-- LocalScript: Botão SH sofisticado (não cria duplicado)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Se já existe, não faz nada
if playerGui:FindFirstChild("SuiPremiumButton") then return end

-- ===== CONFIGURAÇÃO =====
local BUTTON_TEXT = "SH"
local SIMULATED_KEY = Enum.KeyCode.K
local BUTTON_SIZE = UDim2.new(0, 160, 0, 56)
local START_POS = UDim2.new(0.08, 0, 0.40, 0)
local FLOAT_DISTANCE = 8
local FLOAT_TIME = 2.6
-- =========================

-- ScreenGui container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuiPremiumButton"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

-- Sombra (leve)
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 0.85
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.Size = BUTTON_SIZE + UDim2.new(0, 8, 0, 8)
shadow.Position = START_POS + UDim2.new(0, 4, 0, 4)
shadow.AnchorPoint = Vector2.new(0, 0.5)
shadow.BorderSizePixel = 0
shadow.Parent = screenGui
local shCorner = Instance.new("UICorner", shadow)
shCorner.CornerRadius = UDim.new(1, 0)

-- Botão principal
local button = Instance.new("TextButton")
button.Name = BUTTON_TEXT
button.AnchorPoint = Vector2.new(0, 0.5)
button.BackgroundTransparency = 0
button.Size = BUTTON_SIZE
button.Position = START_POS
button.Parent = screenGui
button.Font = Enum.Font.Roboto
button.Text = "   " .. BUTTON_TEXT
button.TextScaled = true
button.TextWrapped = false
button.AutoButtonColor = false
button.TextColor3 = Color3.fromRGB(245,245,245)
button.TextStrokeTransparency = 0.85

-- Cantos arredondados
local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(1, 0)

-- Gradiente elegante
local grad = Instance.new("UIGradient", button)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45,45,48)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,22))
}
grad.Rotation = 90

-- Contorno delicado
local stroke = Instance.new("UIStroke", button)
stroke.Thickness = 1
stroke.Transparency = 0.45
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Faixa lateral (accent)
local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.Size = UDim2.new(0, 10, 1, 0)
accent.Position = UDim2.new(0, 0, 0, 0)
accent.BackgroundColor3 = Color3.fromRGB(95,205,255)
accent.Parent = button
local accentCorner = Instance.new("UICorner", accent)
accentCorner.CornerRadius = UDim.new(1, 0)

-- Ícone circular à esquerda
local icon = Instance.new("Frame")
icon.Name = "Icon"
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 14, 0.5, -20)
icon.AnchorPoint = Vector2.new(0, 0)
icon.BackgroundColor3 = Color3.fromRGB(18,18,20)
icon.Parent = button
local iconCorner = Instance.new("UICorner", icon)
iconCorner.CornerRadius = UDim.new(1, 0)

local iconDot = Instance.new("Frame")
iconDot.Size = UDim2.new(0, 12, 0, 12)
iconDot.Position = UDim2.new(0.5, -6, 0.5, -6)
iconDot.AnchorPoint = Vector2.new(0.5, 0.5)
iconDot.BackgroundColor3 = Color3.fromRGB(95,205,255)
iconDot.Parent = icon
local iconDotCorner = Instance.new("UICorner", iconDot)
iconDotCorner.CornerRadius = UDim.new(1, 0)

-- Escala de UI
local uiScale = Instance.new("UIScale", screenGui)
uiScale.Scale = 1

-- ZIndex: botão acima da sombra
shadow.ZIndex = 0
button.ZIndex = 1
accent.ZIndex = 2
icon.ZIndex = 2

-- ===== Dragging (arrastar) =====
local dragging = false
local dragStart = nil
local startPos = nil

local function isPointOverGui(point, guiObject)
    local absPos = guiObject.AbsolutePosition
    local absSize = guiObject.AbsoluteSize
    return point.X >= absPos.X and point.X <= absPos.X + absSize.X
       and point.Y >= absPos.Y and point.Y <= absPos.Y + absSize.Y
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        if isPointOverGui(mousePos, button) then
            dragging = true
            dragStart = mousePos
            startPos = button.Position
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        local screenW, screenH = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
        newX = math.clamp(newX, 0, screenW - button.AbsoluteSize.X)
        newY = math.clamp(newY, 0, screenH - button.AbsoluteSize.Y)
        button.Position = UDim2.new(0, newX, 0, newY)
        shadow.Position = UDim2.new(0, newX + 4, 0, newY + 4)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ===== Floating animation =====
spawn(function()
    local direction = 1
    local basePos = button.Position
    local baseShadowPos = shadow.Position
    while true do
        local targetY = basePos.Y.Offset + (FLOAT_DISTANCE * direction)
        local tweenInfo = TweenInfo.new(FLOAT_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(button, tweenInfo, {Position = UDim2.new(basePos.X.Scale, basePos.X.Offset, 0, targetY)})
        local shadowTween = TweenService:Create(shadow, tweenInfo, {Position = UDim2.new(baseShadowPos.X.Scale, baseShadowPos.X.Offset, 0, baseShadowPos.Y.Offset + (FLOAT_DISTANCE * direction) + 4)})
        tween:Play()
        shadowTween:Play()
        tween.Completed:Wait()
        direction = -direction
    end
end)

-- ===== Clique do botão =====
local function triggerAction()
    if type(keypress) == "function" and type(keyrelease) == "function" then
        pcall(function()
            keypress(SIMULATED_KEY)
            wait(0.06)
            keyrelease(SIMULATED_KEY)
        end)
    end
end

button.MouseButton1Click:Connect(function()
    local pinfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t1 = TweenService:Create(accent, pinfo, {Size = UDim2.new(0, 14, 1, 0)})
    local t2 = TweenService:Create(accent, pinfo, {Size = UDim2.new(0, 10, 1, 0)})
    t1:Play()
    t1.Completed:Wait()
    t2:Play()
    triggerAction()
end)

-- ===== Atalho de teclado =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == SIMULATED_KEY then
        triggerAction()
    end
end)
