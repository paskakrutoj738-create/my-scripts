-- ============================================
-- FLY GUI v3.0 — С ДЖОЙСТИКОМ ДЛЯ МОБИЛЬНЫХ
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local config = {
    flyEnabled = false,
    flySpeed = 50,
    speedEnabled = false,
    walkSpeed = 16,
    noclipEnabled = false
}

local bodyVel, bodyGyro

-- 🔥 ПЕРЕМЕННЫЕ ДЛЯ ДЖОЙСТИКА
local joystickMoveVector = Vector3.new(0, 0, 0)  -- Направление движения
local joystickVertical = 0                        -- Вверх/вниз (-1 до 1)
local joystickActive = false
local joystickTouchId = nil

-- ============================================
-- GUI
-- ============================================

pcall(function()
    if player:WaitForChild("PlayerGui", 5):FindFirstChild("FlyGui") then
        player.PlayerGui.FlyGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlyGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = player.PlayerGui

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 420)
    MainFrame.Position = UDim2.new(0, 20, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame

    -- Заголовок
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Header.Parent = MainFrame

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 12)
    hCorner.Parent = Header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "✈️ Fly Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = Header

    -- Контейнер с UIListLayout
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)
    UIList.Parent = Container

    -- Функция кнопки-переключателя
    local function createToggle(title, defaultState, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.Text = title .. ": " .. (defaultState and "ВКЛ" or "ВЫКЛ")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.AutoButtonColor = true
        btn.Parent = Container

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn

        local state = defaultState

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = title .. ": " .. (state and "ВКЛ" or "ВЫКЛ")
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end
            callback(state)
        end)
    end

    -- Функция кнопки скорости (циклическая)
    local function createSpeedButton(title, speeds, defaultIdx, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 45)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        btn.Text = title .. ": " .. speeds[defaultIdx]
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.AutoButtonColor = true
        btn.Parent = Container

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn

        local idx = defaultIdx

        btn.MouseButton1Click:Connect(function()
            idx = idx + 1
            if idx > #speeds then idx = 1 end
            btn.Text = title .. ": " .. speeds[idx]
            callback(speeds[idx])
        end)
    end

    -- Создаём кнопки
    createToggle("✈️ Полёт", false, function(state)
        config.flyEnabled = state
    end)

    createSpeedButton("Скорость полёта", {20, 50, 100, 150, 200}, 2, function(v)
        config.flySpeed = v
    end)

    createToggle("🏃 Ускорение", false, function(state)
        config.speedEnabled = state
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = state and config.walkSpeed or 16
            end
        end
    end)

    createSpeedButton("Скорость бега", {16, 30, 50, 100, 150}, 3, function(v)
        config.walkSpeed = v
        if config.speedEnabled then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = v end
            end
        end
    end)

    createToggle("👻 NoClip", false, function(state)
        config.noclipEnabled = state
    end)

    -- ============================================
    -- 🔥 ДЖОЙСТИК ДЛЯ МОБИЛЬНЫХ
    -- ============================================
    
    -- База джойстика (большой круг)
    local joyBase = Instance.new("Frame")
    joyBase.Name = "JoyBase"
    joyBase.Size = UDim2.new(0, 160, 0, 160)
    joyBase.Position = UDim2.new(0, 50, 1, -220)
    joyBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joyBase.BackgroundTransparency = 0.7
    joyBase.Visible = false
    joyBase.Parent = ScreenGui

    local baseCorner = Instance.new("UICorner")
    baseCorner.CornerRadius = UDim.new(1, 0)
    baseCorner.Parent = joyBase

    -- Стик (маленький круг внутри)
    local joyStick = Instance.new("Frame")
    joyStick.Name = "JoyStick"
    joyStick.Size = UDim2.new(0, 60, 0, 60)
    joyStick.Position = UDim2.new(0.5, -30, 0.5, -30)
    joyStick.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    joyStick.Parent = joyBase

    local stickCorner = Instance.new("UICorner")
    stickCorner.CornerRadius = UDim.new(1, 0)
    stickCorner.Parent = joyStick

    -- Кнопка "ВВЕРХ"
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 80, 0, 60)
    upBtn.Position = UDim2.new(1, -130, 1, -220)
    upBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    upBtn.BackgroundTransparency = 0.3
    upBtn.Text = "▲ ВВЕРХ"
    upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 14
    upBtn.Visible = false
    upBtn.Parent = ScreenGui

    local upCorner = Instance.new("UICorner")
    upCorner.CornerRadius = UDim.new(0, 10)
    upCorner.Parent = upBtn

    -- Кнопка "ВНИЗ"
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 80, 0, 60)
    downBtn.Position = UDim2.new(1, -130, 1, -150)
    downBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    downBtn.BackgroundTransparency = 0.3
    downBtn.Text = "▼ ВНИЗ"
    downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    downBtn.Font = Enum.Font.GothamBold
    downBtn.TextSize = 14
    downBtn.Visible = false
    downBtn.Parent = ScreenGui

    local downCorner = Instance.new("UICorner")
    downCorner.CornerRadius = UDim.new(0, 10)
    downCorner.Parent = downBtn

    -- Функция показать/скрыть джойстик
    local function setJoystickVisible(visible)
        joyBase.Visible = visible
        upBtn.Visible = visible
        downBtn.Visible = visible
        if not visible then
            joystickMoveVector = Vector3.new(0, 0, 0)
            joystickVertical = 0
            joyStick.Position = UDim2.new(0.5, -30, 0.5, -30)
        end
    end

    -- Обработчик полёта — показываем/скрываем джойстик
    -- (через callback, который мы уже создали выше — модифицируем)
    -- НО проще: отслеживаем config.flyEnabled в RenderStepped
    local lastFlyState = false

    -- Управление джойстиком (тач)
    joyBase.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = true
            joystickTouchId = input.TouchId or input.UserInputType
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not joystickActive then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            if input.TouchId ~= joystickTouchId and joystickTouchId ~= Enum.UserInputType.Touch then
                return
            end
            
            local baseCenter = joyBase.AbsolutePosition + joyBase.AbsoluteSize / 2
            local delta = input.Position - baseCenter
            local maxRadius = 60
            local distance = math.min(delta.Magnitude, maxRadius)
            
            local direction
            if delta.Magnitude > 0 then
                direction = delta.Unit
            else
                direction = Vector2.new(0, 0)
            end
            
            -- Двигаем стик
            local stickPos = direction * distance
            joyStick.Position = UDim2.new(0.5, stickPos.X - 30, 0.5, stickPos.Y - 30)
            
            -- Вычисляем вектор движения (X и Z — горизонтально)
            local normalized = distance / maxRadius
            joystickMoveVector = Vector3.new(direction.X, 0, direction.Y) * normalized
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if input.TouchId == joystickTouchId or joystickTouchId == Enum.UserInputType.Touch then
                joystickActive = false
                joystickTouchId = nil
                joyStick.Position = UDim2.new(0.5, -30, 0.5, -30)
                joystickMoveVector = Vector3.new(0, 0, 0)
            end
        end
    end)

    -- Кнопки вверх/вниз
    local upHeld = false
    local downHeld = false

    upBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            upHeld = true
            joystickVertical = 1
        end
    end)

    upBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            upHeld = false
            if not downHeld then joystickVertical = 0 end
        end
    end)

    downBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            downHeld = true
            joystickVertical = -1
        end
    end)

    downBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            downHeld = false
            if not upHeld then joystickVertical = 0 end
        end
    end)

    -- 🔥 ВАЖНО: показываем/скрываем джойстик когда меняется полёт
    local flyToggleBtn = Container:FindFirstChildWhichIsA("TextButton")
    if flyToggleBtn then
        flyToggleBtn.MouseButton1Click:Connect(function()
            setJoystickVisible(config.flyEnabled)
        end)
    end

    -- Также в RenderStepped будем проверять
    RunService.RenderStepped:Connect(function()
        if config.flyEnabled ~= lastFlyState then
            lastFlyState = config.flyEnabled
            setJoystickVisible(config.flyEnabled)
        end
    end)

    print("✅ Fly GUI v3.0 с джойстиком загружен!")
end)

-- ============================================
-- ИГРОВАЯ ЛОГИКА (ИСПРАВЛЕННАЯ)
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
            
            -- 🔥 ИСПРАВЛЕННАЯ ЛОГИКА ДВИЖЕНИЯ
            local move = Vector3.new(0, 0, 0)
            
            -- 1. ПК: WASD
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            
            -- 2. МОБИЛЬНЫЙ: джойстик (только если WASD не нажаты)
            if move.Magnitude == 0 and joystickMoveVector.Magnitude > 0.1 then
                -- Используем LookVector и RightVector камеры
                local camLook = camera.CFrame.LookVector
                local camRight = camera.CFrame.RightVector
                
                -- joystickMoveVector.X = влево/вправо
                -- joystickMoveVector.Z = вперёд/назад
                move = (camRight * joystickMoveVector.X) + (camLook * joystickMoveVector.Z)
            end
            
            -- 3. Вверх/вниз с кнопок на мобильном
            if move.Y == 0 and joystickVertical ~= 0 then
                move = move + Vector3.new(0, joystickVertical, 0)
            end
            
            -- Нормализуем и применяем
            if move.Magnitude > 0 then
                move = move.Unit
            end
            
            bodyVel.Velocity = move * config.flySpeed
            bodyGyro.CFrame = camera.CFrame
            
        else
            if bodyVel then bodyVel:Destroy(); bodyVel = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            if hum.PlatformStand then hum.PlatformStand = false end
        end
    end)
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    pcall(function()
        if config.noclipEnabled then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

