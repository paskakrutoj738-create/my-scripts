-- ============================================
-- FLY через встроенный джойстик Roblox
-- Работает и на ПК (WASD), и на телефоне
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local config = {
    flyEnabled = false,
    flySpeed = 50,
    vertical = 0  -- -1 вниз, 0 стоять, 1 вверх
}

local bodyVel, bodyGyro

-- ============================================
-- ПРОСТОЙ GUI
-- ============================================

pcall(function()
    if player:WaitForChild("PlayerGui", 5):FindFirstChild("SimpleFly") then
        player.PlayerGui.SimpleFly:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleFly"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = player.PlayerGui

    -- Кнопка полёта
    local flyBtn = Instance.new("TextButton")
    flyBtn.Size = UDim2.new(0, 120, 0, 50)
    flyBtn.Position = UDim2.new(0, 20, 0.7, 0)
    flyBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    flyBtn.Text = "✈️ ПОЛЁТ"
    flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 16
    flyBtn.Parent = ScreenGui
    local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 10); c1.Parent = flyBtn

    -- Кнопка скорости
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(0, 120, 0, 50)
    speedBtn.Position = UDim2.new(0, 20, 0.8, 0)
    speedBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
    speedBtn.Text = "СКОР: 50"
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.TextSize = 14
    speedBtn.Parent = ScreenGui
    local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 10); c2.Parent = speedBtn

    -- 🔥 Кнопка ВВЕРХ (для мобильных)
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 90, 0, 60)
    upBtn.Position = UDim2.new(1, -110, 0.65, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    upBtn.BackgroundTransparency = 0.3
    upBtn.Text = "▲"
    upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 30
    upBtn.Parent = ScreenGui
    local c3 = Instance.new("UICorner"); c3.CornerRadius = UDim.new(0, 10); c3.Parent = upBtn

    -- 🔥 Кнопка ВНИЗ (для мобильных)
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 90, 0, 60)
    downBtn.Position = UDim2.new(1, -110, 0.75, 0)
    downBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    downBtn.BackgroundTransparency = 0.3
    downBtn.Text = "▼"
    downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    downBtn.Font = Enum.Font.GothamBold
    downBtn.TextSize = 30
    downBtn.Parent = ScreenGui
    local c4 = Instance.new("UICorner"); c4.CornerRadius = UDim.new(0, 10); c4.Parent = downBtn

    -- Логика кнопок
    flyBtn.MouseButton1Click:Connect(function()
        config.flyEnabled = not config.flyEnabled
        if config.flyEnabled then
            flyBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            flyBtn.Text = "✈️ СТОП"
        else
            flyBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            flyBtn.Text = "✈️ ПОЛЁТ"
        end
    end)

    local speeds = {20, 50, 100, 150, 200}
    local speedIdx = 2
    speedBtn.MouseButton1Click:Connect(function()
        speedIdx = speedIdx + 1
        if speedIdx > #speeds then speedIdx = 1 end
        config.flySpeed = speeds[speedIdx]
        speedBtn.Text = "СКОР: " .. config.flySpeed
    end)

    -- Вверх/вниз (зажатие)
    local upHeld, downHeld = false, false

    upBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            upHeld = true
        end
    end)
    upBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            upHeld = false
        end
    end)

    downBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            downHeld = true
        end
    end)
    downBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            downHeld = false
        end
    end)

    -- Обновляем vertical каждый кадр
    RunService.RenderStepped:Connect(function()
        if upHeld and not downHeld then
            config.vertical = 1
        elseif downHeld and not upHeld then
            config.vertical = -1
        else
            config.vertical = 0
        end
    end)

    print("✅ Fly загружен! Используй стандартный джойстик Roblox")
end)

-- ============================================
-- ЛОГИКА ПОЛЁТА
-- 🔥 Используем Humanoid.MoveDirection (стандартный джойстик!)
-- ============================================

RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if config.flyEnabled then
            -- Создаём BodyVelocity один раз
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.Velocity = Vector3.new(0, 0, 0)
                bodyVel.Parent = root
                
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bodyGyro.P = 9000
                bodyGyro.Parent = root
                
                hum.PlatformStand = true
            end
            
            -- 🔥 ГЛАВНОЕ: берём направление из стандартного джойстика Roblox
            -- MoveDirection работает и на ПК (WASD), и на мобильных (встроенный джойстик)
            local moveDir = hum.MoveDirection
            
            -- Добавляем вертикальное движение (кнопки ▲▼)
            local vertical = Vector3.new(0, config.vertical, 0)
            
            -- ПК: Space/Shift тоже работают
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vertical = Vector3.new(0, 1, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vertical = Vector3.new(0, -1, 0)
            end
            
            -- Итоговое движение
            local finalMove = moveDir + vertical
            
            if finalMove.Magnitude > 0 then
                finalMove = finalMove.Unit
            end
            
            bodyVel.Velocity = finalMove * config.flySpeed
            bodyGyro.CFrame = camera.CFrame
            
        else
            -- Выключаем полёт
            if bodyVel then bodyVel:Destroy(); bodyVel = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            if hum.PlatformStand then hum.PlatformStand = false end
        end
    end)
end)

