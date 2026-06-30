-- ============================================
-- SIMPLE JOYSTICK FLY (Mobile)
-- Рабочий джойстик без глюков
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local config = {
    flyEnabled = false,
    flySpeed = 50
}

local bodyVel, bodyGyro
local joystickActive = false
local joystickPosition = nil
local moveVector = Vector3.new(0, 0, 0)

-- ============================================
-- ПРОСТОЙ GUI
-- ============================================

pcall(function()
    if player:WaitForChild("PlayerGui", 5):FindFirstChild("SimpleFlyGui") then
        player.PlayerGui.SimpleFlyGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleFlyGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = player.PlayerGui

    -- Кнопка ВКЛ/ВЫКЛ полёт
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 120, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0.7, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    toggleBtn.Text = "ПОЛЁТ: ВЫКЛ"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 16
    toggleBtn.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleBtn

    -- Кнопка скорости
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(0, 120, 0, 50)
    speedBtn.Position = UDim2.new(0, 20, 0.8, 0)
    speedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    speedBtn.Text = "СКОРОСТЬ: 50"
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.TextSize = 14
    speedBtn.Parent = ScreenGui

    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedBtn

    -- Джойстик (круг)
    local joystickBase = Instance.new("Frame")
    joystickBase.Name = "JoystickBase"
    joystickBase.Size = UDim2.new(0, 150, 0, 150)
    joystickBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joystickBase.BackgroundTransparency = 0.7
    joystickBase.BorderSizePixel = 2
    joystickBase.BorderColor3 = Color3.fromRGB(100, 100, 100)
    joystickBase.Visible = false
    joystickBase.Parent = ScreenGui

    local baseCircle = Instance.new("UICorner")
    baseCircle.CornerRadius = UDim.new(1, 0)
    baseCircle.Parent = joystickBase

    -- Стик (маленький круг)
    local joystickStick = Instance.new("Frame")
    joystickStick.Name = "JoystickStick"
    joystickStick.Size = UDim2.new(0, 50, 0, 50)
    joystickStick.Position = UDim2.new(0.5, -25, 0.5, -25)
    joystickStick.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    joystickStick.BorderSizePixel = 0
    joystickStick.Parent = joystickBase

    local stickCircle = Instance.new("UICorner")
    stickCircle.CornerRadius = UDim.new(1, 0)
    stickCircle.Parent = joystickStick

    -- Инструкция
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 200, 0, 30)
    info.Position = UDim2.new(0.5, -100, 0.9, 0)
    info.BackgroundTransparency = 1
    info.Text = "Коснись экрана для джойстика"
    info.TextColor3 = Color3.fromRGB(255, 255, 255)
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.TextStrokeTransparency = 0.5
    info.Parent = ScreenGui

    -- ВКЛ/ВЫКЛ полёт
    toggleBtn.MouseButton1Click:Connect(function()
        config.flyEnabled = not config.flyEnabled
        if config.flyEnabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            toggleBtn.Text = "ПОЛЁТ: ВКЛ"
            joystickBase.Visible = true
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            toggleBtn.Text = "ПОЛЁТ: ВЫКЛ"
            joystickBase.Visible = false
            moveVector = Vector3.new(0, 0, 0)
        end
    end)

    -- Смена скорости
    local speeds = {16, 30, 50, 80, 100}
    local currentSpeedIndex = 3
    
    speedBtn.MouseButton1Click:Connect(function()
        currentSpeedIndex = currentSpeedIndex + 1
        if currentSpeedIndex > #speeds then currentSpeedIndex = 1 end
        config.flySpeed = speeds[currentSpeedIndex]
        speedBtn.Text = "СКОРОСТЬ: " .. config.flySpeed
    end)

    -- Управление джойстиком через касание экрана
    local screenGui = ScreenGui
    
    screenGui.InputBegan:Connect(function(input)
        if not config.flyEnabled then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = true
            joystickPosition = input.Position
            joystickBase.Position = UDim2.new(0, joystickPosition.X - 75, 0, joystickPosition.Y - 75)
            joystickBase.Visible = true
        end
    end)

    screenGui.InputChanged:Connect(function(input)
        if not joystickActive then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            local center = joystickBase.AbsolutePosition + joystickBase.AbsoluteSize / 2
            local delta = input.Position - center
            local distance = math.min(delta.Magnitude, 75)
            local direction = delta.Unit
            
            local newPos = center + direction * distance
            joystickStick.Position = UDim2.new(0, newPos.X - joystickBase.AbsolutePosition.X - 25, 0, newPos.Y - joystickBase.AbsolutePosition.Y - 25)
            
            -- Вычисляем вектор движения
            local x = delta.X / 75
            local y = delta.Y / 75
            moveVector = Vector3.new(x, -y, 0)
        end
    end)

    screenGui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = false
            joystickStick.Position = UDim2.new(0.5, -25, 0.5, -25)
            moveVector = Vector3.new(0, 0, 0)
        end
    end)

    print("✅ Simple Joystick Fly загружен!")
    print("📱 Коснись экрана чтобы управлять")
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
                bodyGyro.CFrame = camera.CFrame
                bodyGyro.Parent = root
                
                hum.PlatformStand = true
            end
            
            -- Движение по джойстику
            if moveVector.Magnitude > 0.1 then
                local camCFrame = camera.CFrame
                local moveDirection = (camCFrame.RightVector * moveVector.X) + (camCFrame.UpVector * -moveVector.Y)
                bodyVel.Velocity = moveDirection * config.flySpeed
            else
                bodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            
            bodyGyro.CFrame = camera.CFrame
        else
            if bodyVel then 
                bodyVel:Destroy()
                bodyVel = nil 
            end
            if bodyGyro then 
                bodyGyro:Destroy()
                bodyGyro = nil 
            end
            if hum and hum.PlatformStand then 
                hum.PlatformStand = false 
            end
        end
    end)
end)

