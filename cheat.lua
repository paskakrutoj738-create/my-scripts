-- ============================================
-- MOBILE FLY GUI (Для Android/iOS)
-- Адаптировано для тачскрина
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local config = {
    flyEnabled = false,
    flySpeed = 50,
    walkSpeed = 16
}

local bodyVel, bodyGyro
local moveDirection = Vector3.new(0, 0, 0)

-- ============================================
-- GUI ДЛЯ МОБИЛЬНЫХ
-- ============================================

pcall(function()
    if player:WaitForChild("PlayerGui", 5):FindFirstChild("MobileFlyGui") then
        player.PlayerGui.MobileFlyGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MobileFlyGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = player.PlayerGui

    -- Кнопка включения полёта (БОЛЬШАЯ для пальца)
    local flyButton = Instance.new("TextButton")
    flyButton.Size = UDim2.new(0, 150, 0, 60)
    flyButton.Position = UDim2.new(0, 20, 0.7, 0)
    flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    flyButton.Text = "✈️ ПОЛЁТ"
    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyButton.Font = Enum.Font.GothamBold
    flyButton.TextSize = 20
    flyButton.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = flyButton

    -- Кнопка скорости
    local speedButton = Instance.new("TextButton")
    speedButton.Size = UDim2.new(0, 150, 0, 60)
    speedButton.Position = UDim2.new(0, 20, 0.8, 0)
    speedButton.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
    speedButton.Text = "🏃 СКОРОСТЬ"
    speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedButton.Font = Enum.Font.GothamBold
    speedButton.TextSize = 18
    speedButton.Parent = ScreenGui

    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 10)
    speedCorner.Parent = speedButton

    -- Джойстик для управления полётом (появляется при включении)
    local joystickFrame = Instance.new("Frame")
    joystickFrame.Size = UDim2.new(0, 200, 0, 200)
    joystickFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
    joystickFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    joystickFrame.BackgroundTransparency = 0.5
    joystickFrame.Visible = false
    joystickFrame.Parent = ScreenGui

    local joystickCorner = Instance.new("UICorner")
    joystickCorner.CornerRadius = UDim.new(1, 0)
    joystickCorner.Parent = joystickFrame

    local joystickKnob = Instance.new("Frame")
    joystickKnob.Size = UDim2.new(0, 60, 0, 60)
    joystickKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
    joystickKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joystickKnob.Parent = joystickFrame

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = joystickKnob

    -- Включение/выключение полёта
    flyButton.MouseButton1Click:Connect(function()
        config.flyEnabled = not config.flyEnabled
        if config.flyEnabled then
            flyButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            flyButton.Text = "✈️ СТОП"
            joystickFrame.Visible = true
        else
            flyButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            flyButton.Text = "✈️ ПОЛЁТ"
            joystickFrame.Visible = false
            moveDirection = Vector3.new(0, 0, 0)
        end
    end)

    -- Увеличение скорости
    speedButton.MouseButton1Click:Connect(function()
        config.walkSpeed = config.walkSpeed + 16
        if config.walkSpeed > 100 then config.walkSpeed = 16 end
        
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = config.walkSpeed end
        end
        
        speedButton.Text = "🏃 " .. config.walkSpeed
    end)

    -- Управление джойстиком
    local dragging = false
    local joystickCenter = Vector2.new(0, 0)

    joystickFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            joystickCenter = joystickFrame.AbsolutePosition + joystickFrame.AbsoluteSize / 2
        end
    end)

    joystickFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - joystickCenter
            local magnitude = delta.Magnitude
            local maxRadius = 100
            
            if magnitude > maxRadius then
                delta = (delta / magnitude) * maxRadius
            end
            
            joystickKnob.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
            
            -- Преобразуем в направление движения
            moveDirection = Vector3.new(delta.X, 0, -delta.Y).Unit * (magnitude / maxRadius)
        end
    end)

    joystickFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            joystickKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
            moveDirection = Vector3.new(0, 0, 0)
        end
    end)

    print("✅ Mobile Fly GUI загружен!")
end)

-- ============================================
-- ЛОГИКА ПОЛЁТА
-- ============================================

RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        if config.flyEnabled then
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
            
            -- Движение от джойстика
            local move = moveDirection
            
            -- Вверх/вниз (кнопки на экране можно добавить)
            if move.Magnitude > 0 then
                bodyVel.Velocity = move * config.flySpeed
                bodyGyro.CFrame = camera.CFrame
            else
                bodyVel.Velocity = Vector3.new(0, 0, 0)
            end
        else
            if bodyVel then bodyVel:Destroy(); bodyVel = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            if hum.PlatformStand then hum.PlatformStand = false end
        end
    end)
end)

