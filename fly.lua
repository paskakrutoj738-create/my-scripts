-- ============================================
-- УНИВЕРСАЛЬНЫЙ Скрипт с GUI-меню
-- Speed, Teleport, NoClip, ESP
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local settings = {
    speed = 50,        -- Скорость (по умолчанию)
    noclip = false,    -- NoClip выключен
    esp = false,       -- ESP выключен
    guiVisible = true  -- Меню видимо
}

-- ============================================
-- СОЗДАНИЕ GUI-МЕНЮ
-- ============================================

-- Удаляем старое меню
if player:FindFirstChild("PlayerGui"):FindFirstChild("UniversalMenu") then
    player:FindFirstChild("PlayerGui"):FindFirstChild("UniversalMenu"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 350)
mainFrame.Position = UDim2.new(0, 20, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
title.Text = "🎮 Universal Script"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Функция создания кнопок
local function createButton(name, position, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================
-- ФУНКЦИИ
-- ============================================

-- 1. SPEED (Ускорение)
local function setSpeed(value)
    settings.speed = value
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
    showNotification("🏃 Скорость: " .. value)
end

-- 2. NOCLIP (Проходить сквозь стены)
local function toggleNoclip()
    settings.noclip = not settings.noclip
    if settings.noclip then
        showNotification("👻 NoClip: ВКЛЮЧЕН")
    else
        showNotification("👻 NoClip: ВЫКЛЮЧЕН")
    end
end

-- 3. TELEPORT (Телепорт по клику)
local teleportEnabled = false
local function toggleTeleport()
    teleportEnabled = not teleportEnabled
    if teleportEnabled then
        showNotification("🌀 Teleport: ВКЛЮЧЕН (Ctrl+Click)")
    else
        showNotification("🌀 Teleport: ВЫКЛЮЧЕН")
    end
end

-- 4. ESP (Видеть игроков сквозь стены)
local function toggleESP()
    settings.esp = not settings.esp
    if settings.esp then
        createESP()
        showNotification("🎯 ESP: ВКЛЮЧЕН")
    else
        removeESP()
        showNotification("🎯 ESP: ВЫКЛЮЧЕН")
    end
end

-- 5. TELEPORT TO STAGES (Телепорт на этапы)
local function teleportToStage(stageNumber)
    -- Ищем папку Stages в workspace
    local stages = workspace:FindFirstChild("Stages") or workspace:FindFirstChild("stages")
    
    if stages then
        local stage = stages:FindFirstChild(tostring(stageNumber)) or stages:FindFirstChild("Stage" .. stageNumber)
        if stage then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.CFrame = stage.CFrame + Vector3.new(0, 5, 0)
                    showNotification("🎯 Этап " .. stageNumber)
                end
            end
        else
            showNotification("❌ Этап не найден")
        end
    else
        showNotification("❌ Папка Stages не найдена в игре")
    end
end

-- ============================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================

function showNotification(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Скрипт";
        Text = text;
        Duration = 2;
    })
end

function createESP()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local character = otherPlayer.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head and not head:FindFirstChild("ESPLabel") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESPLabel"
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = head
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = otherPlayer.Name
                    label.TextColor3 = Color3.fromRGB(255, 0, 0)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 20
                    label.Parent = billboard
                end
            end
        end
    end
end

function removeESP()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        local character = otherPlayer.Character
        if character then
            local head = character:FindFirstChild("Head")
            if head and head:FindFirstChild("ESPLabel") then
                head:FindFirstChild("ESPLabel"):Destroy()
            end
        end
    end
end

-- ============================================
-- СОЗДАЁМ КНОПКИ В МЕНЮ
-- ============================================

createButton("🏃 Speed: 50", UDim2.new(0.05, 0, 0.15, 0), function() setSpeed(50) end)
createButton("🏃 Speed: 100", UDim2.new(0.05, 0, 0.25, 0), function() setSpeed(100) end)
createButton("🏃 Speed: 200", UDim2.new(0.05, 0, 0.35, 0), function() setSpeed(200) end)
createButton("👻 NoClip", UDim2.new(0.05, 0, 0.45, 0), toggleNoclip)
createButton("🌀 Teleport (Ctrl+Click)", UDim2.new(0.05, 0, 0.55, 0), toggleTeleport)
createButton("🎯 ESP", UDim2.new(0.05, 0, 0.65, 0), toggleESP)
createButton("📍 Этап 10", UDim2.new(0.05, 0, 0.75, 0), function() teleportToStage(10) end)
createButton("📍 Этап 50", UDim2.new(0.05, 0, 0.85, 0), function() teleportToStage(50) end)

-- ============================================
-- ОБРАБОТЧИКИ СОБЫТИЙ
-- ============================================

-- NoClip работает каждый кадр
RunService.Stepped:Connect(function()
    if settings.noclip then
        local character = player.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Teleport по Ctrl+Click
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if teleportEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            local mouse = player:GetMouse()
            local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
            local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            
            if raycastResult then
                local character = player.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
    end
end)

-- Делаем окно перетаскиваемым
local dragging = false
local dragInput, mousePos, framePos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(
            framePos.X.Scale, 
            framePos.X.Offset + delta.X, 
            framePos.Y.Scale, 
            framePos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- ПРИВЕТСТВЕННОЕ УВЕДОМЛЕНИЕ
-- ============================================

showNotification("✅ Скрипт загружен!")
print("Universal Script загружен! Меню слева.")
