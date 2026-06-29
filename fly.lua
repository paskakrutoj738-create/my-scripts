-- ============================================
-- ПОЛЁТ ДЛЯ ROBLOX (Fly Script)
-- Управление: F - вкл/выкл, WASD - движение
-- Space - вверх, Left Shift - вниз
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local speed = 50 -- Скорость полёта (можно менять)
local bodyVelocity = nil
local bodyGyro = nil

-- Функция включения/выключения полёта
local function toggleFly()
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    flying = not flying
    
    if flying then
        -- Создаём BodyVelocity для движения
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        -- Создаём BodyGyro для поворота по камере
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 9000
        bodyGyro.Parent = rootPart
        
        humanoid.PlatformStand = true -- Отключаем гравитацию
        
        -- Уведомление
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✈️ Полёт";
            Text = "Включён! F - выключить";
            Duration = 2;
        })
    else
        -- Удаляем объекты
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        bodyVelocity = nil
        bodyGyro = nil
        
        humanoid.PlatformStand = false
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✈️ Полёт";
            Text = "Выключен";
            Duration = 2;
        })
    end
end

-- Обработка нажатия F для вкл/выкл
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- Основной цикл полёта
RunService.RenderStepped:Connect(function()
    if not flying then return end
    
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not bodyVelocity or not bodyGyro then return end
    
    -- Направление камеры
    local camCFrame = camera.CFrame
    
    -- Считываем нажатые клавиши
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + camCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - camCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - camCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + camCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    
    -- Нормализуем вектор (чтобы по диагонали не летел быстрее)
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end
    
    -- Применяем скорость
    bodyVelocity.Velocity = moveDirection * speed
    
    -- Поворачиваем персонажа по камере
    bodyGyro.CFrame = camCFrame
end)

print("✅ Скрипт полёта загружен! Нажми F для включения.")
