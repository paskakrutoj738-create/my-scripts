-- ============================================
-- DEV TOOLS v2.0 (Для тестов в своей игре)
-- Функции: Fly, Custom Speed, Kill Aura, Damage Players
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local config = {
    flySpeed = 50,
    customSpeed = 16,        -- Произвольная скорость
    autoSpeed = false,       -- Авто-наращивание
    isFlying = false,
    isKillAura = false,
    damagePlayers = false,   -- Урон по игрокам (тест)
    damageAmount = 100,      -- Количество урона
    killRadius = 15          -- Радиус действия
}

-- ============================================
-- СОЗДАНИЕ GUI
-- ============================================

if player.PlayerGui:FindFirstChild("DevToolsUI") then
    player.PlayerGui.DevToolsUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DevToolsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 520)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 120)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Заголовок
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Header.Parent = MainFrame
local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🛠️ Dev Tools v2.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Header

-- Скроллируемый контейнер
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- ============================================
-- КОМПОНЕНТЫ UI
-- ============================================

-- Заголовок секции
local function createSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = ScrollFrame
    return label
end

-- Переключатель (Toggle)
local function createToggle(title, defaultState, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, 0, 0, 45)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = ScrollFrame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bg.Parent = btnFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 42, 0, 22)
    toggleBg.Position = UDim2.new(1, -52, 0.5, -11)
    toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleBg.Parent = bg
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = toggleBg

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = toggleBg
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = toggleCircle

    local currentState = defaultState

    local function updateVisual(state)
        currentState = state
        if state then
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0.5, -9)}):Play()
        else
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
    end

    updateVisual(defaultState)

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            currentState = not currentState
            updateVisual(currentState)
            callback(currentState)
        end
    end)

    return updateVisual
end

-- Поле ввода числа
local function createNumberInput(title, defaultValue, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundTransparency = 1
    frame.Parent = ScrollFrame

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bg.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, 30)
    input.Position = UDim2.new(0, 10, 0, 28)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    input.Text = tostring(defaultValue)
    input.PlaceholderText = placeholder
    input.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.Parent = bg

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    -- Применяем значение при потере фокуса
    input.FocusLost:Connect(function(enterPressed)
        local value = tonumber(input.Text)
        if value then
            callback(value)
        else
            input.Text = tostring(defaultValue)
        end
    end)

    return input
end

-- Обычная кнопка
local function createButton(title, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 100, 200)
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = ScrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================
-- СОЗДАЁМ ИНТЕРФЕЙС
-- ============================================

createSection("🏃 СКОРОСТЬ")

createNumberInput("Установить скорость (WalkSpeed)", 16, "Введите число...", function(value)
    config.customSpeed = value
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = value
            print("✅ Скорость установлена: " .. value)
        end
    end
end)

createToggle("🔄 Авто-наращивание скорости", false, function(state)
    config.autoSpeed = state
end)

createSection("✈️ ПОЛЁТ")

createNumberInput("Скорость полёта", 50, "Введите число...", function(value)
    config.flySpeed = value
end)

createToggle("✈️ Режим полёта", false, function(state)
    config.isFlying = state
end)

createSection("⚔️ БОЕВЫЕ ТЕСТЫ")

createNumberInput("Радиус действия (стадов)", 15, "Введите радиус...", function(value)
    config.killRadius = value
end)

createNumberInput("Урон за удар", 100, "Введите урон...", function(value)
    config.damageAmount = value
end)

createToggle("💀 Kill Aura (только NPC)", false, function(state)
    config.isKillAura = state
end)

createToggle("🎯 Урон по ИГРОКАМ (тест)", false, function(state)
    config.damagePlayers = state
    if state then
        warn("⚠️ ВНИМАНИЕ: Урон по игрокам включён! Это для тестов в своей игре.")
    end
end)

createButton("💥 Нанести урон ВСЕМ рядом (разово)", Color3.fromRGB(200, 50, 50), function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local count = 0
    for _, otherChar in ipairs(workspace:GetChildren()) do
        if otherChar:IsA("Model") and otherChar ~= char then
            local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
            local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
            if otherHum and otherRoot then
                local dist = (root.Position - otherRoot.Position).Magnitude
                if dist < config.killRadius then
                    otherHum:TakeDamage(config.damageAmount)
                    count = count + 1
                end
            end
        end
    end
    print("💥 Урон нанесён " .. count .. " целям")
end)

createButton("❤️ Полное лечение себя", Color3.fromRGB(50, 200, 100), function()
    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            print("❤️ Здоровье восстановлено")
        end
    end
end)

-- ============================================
-- ОБРАБОТЧИКИ
-- ============================================

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Перетаскивание меню
local dragging = false
local dragInput, mousePos, framePos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- ИГРОВАЯ ЛОГИКА
-- ============================================

-- FLY
local bodyVel, bodyGyro
RunService.RenderStepped:Connect(function()
    if config.isFlying then
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                if not bodyVel then
                    bodyVel = Instance.new("BodyVelocity")
                    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bodyVel.Parent = root
                    bodyGyro = Instance.new("BodyGyro")
                    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bodyGyro.P = 9000
                    bodyGyro.Parent = root
                    hum.PlatformStand = true
                end
                
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                
                if move.Magnitude > 0 then move = move.Unit end
                bodyVel.Velocity = move * config.flySpeed
                bodyGyro.CFrame = camera.CFrame
            end
        end
    else
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)

-- AUTO SPEED + KILL AURA + DAMAGE PLAYERS
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    -- Авто-наращивание скорости
    if config.autoSpeed then
        hum.WalkSpeed = hum.WalkSpeed + 1
        if hum.WalkSpeed > 500 then hum.WalkSpeed = 500 end
    end

    -- Kill Aura / Damage Players
    if config.isKillAura or config.damagePlayers then
        for _, otherChar in ipairs(workspace:GetChildren()) do
            if otherChar:IsA("Model") and otherChar ~= char then
                local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                if otherHum and otherRoot then
                    local dist = (root.Position - otherRoot.Position).Magnitude
                    if dist < config.killRadius then
                        local isPlayer = Players:GetPlayerFromCharacter(otherChar)
                        
                        -- NPC (если включена Kill Aura)
                        if config.isKillAura and not isPlayer then
                            otherHum:TakeDamage(config.damageAmount)
                        end
                        
                        -- Игроки (если включен Damage Players)
                        if config.damagePlayers and isPlayer and isPlayer ~= player then
                            otherHum:TakeDamage(config.damageAmount)
                        end
                    end
                end
            end
        end
    end
end)

print("✅ Dev Tools v2.0 загружены!")
print("📌 Меню в центре экрана")
print("📌 Введи свою скорость и тестируй!")
