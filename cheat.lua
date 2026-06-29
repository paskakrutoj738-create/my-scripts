-- ============================================
-- FLY GUI v1.0 — Современный интерфейс + Полёт
-- Стабильная версия без крашей
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local config = {
    flyEnabled = false,
    flySpeed = 50,
    speedEnabled = false,
    walkSpeed = 16,
    noclipEnabled = false,
    teleportEnabled = false
}

local bodyVel, bodyGyro

-- ============================================
-- СОЗДАНИЕ GUI
-- ============================================

pcall(function()
    -- Удаляем старое меню
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
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0, 30, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui

    -- Градиент фона
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    gradient.Rotation = 90
    gradient.Parent = MainFrame

    -- Скругление
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = MainFrame

    -- Обводка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 100, 200)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = MainFrame

    -- Тень
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = MainFrame

    -- Заголовок
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 14)
    headerCorner.Parent = Header

    -- Иконка и название
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 15, 0.5, -14)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://7072716368"
    icon.ImageColor3 = Color3.fromRGB(100, 150, 255)
    icon.Parent = Header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, 50, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "✈️ Fly Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = Header

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.BackgroundTransparency = 0.8
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = Header

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Контейнер для кнопок
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -30, 1, -75)
    Container.Position = UDim2.new(0, 15, 0, 65)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- ============================================
    -- ФУНКЦИЯ СОЗДАНИЯ КНОПКИ-ПЕРЕКЛЮЧАТЕЛЯ
    -- ============================================
    local function createToggle(title, description, defaultState, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = Container

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 10)
        fCorner.Parent = frame

        local fStroke = Instance.new("UIStroke")
        fStroke.Color = Color3.fromRGB(60, 70, 100)
        fStroke.Thickness = 1
        fStroke.Transparency = 0.5
        fStroke.Parent = frame

        -- Название
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 0, 22)
        label.Position = UDim2.new(0, 15, 0, 8)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        -- Описание
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -70, 0, 18)
        desc.Position = UDim2.new(0, 15, 0, 30)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = Color3.fromRGB(150, 150, 170)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 12
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame

        -- Переключатель
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 46, 0, 24)
        toggleBg.Position = UDim2.new(1, -58, 0.5, -12)
        toggleBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        toggleBg.BorderSizePixel = 0
        toggleBg.Parent = frame

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(1, 0)
        tCorner.Parent = toggleBg

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 18, 0, 18)
        circle.Position = UDim2.new(0, 3, 0.5, -9)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = toggleBg

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(1, 0)
        cCorner.Parent = circle

        local state = defaultState

        local function updateVisual(newState)
            state = newState
            if state then
                TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Color3.fromRGB(80, 150, 255)
                }):Play()
                TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 25, 0.5, -9)
                }):Play()
            else
                TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                }):Play()
                TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 3, 0.5, -9)
                }):Play()
            end
        end

        updateVisual(defaultState)

        -- Hover эффект
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.1
                }):Play()
            end
        end)

        frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.3
                }):Play()
            end
        end)

        -- Клик
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                updateVisual(state)
                callback(state)
            end
        end)

        return updateVisual
    end

    -- ============================================
    -- ФУНКЦИЯ СОЗДАНИЯ КНОПКИ СЛАЙДЕРА
    -- ============================================
    local function createSlider(title, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 65)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = Container

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 10)
        fCorner.Parent = frame

        local fStroke = Instance.new("UIStroke")
        fStroke.Color = Color3.fromRGB(60, 70, 100)
        fStroke.Thickness = 1
        fStroke.Transparency = 0.5
        fStroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 0, 22)
        label.Position = UDim2.new(0, 15, 0, 8)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, -20, 0, 22)
        valueLabel.Position = UDim2.new(0.7, 5, 0, 8)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame

        -- Полоса слайдера
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -30, 0, 6)
        sliderBg.Position = UDim2.new(0, 15, 0, 45)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame

        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(1, 0)
        sCorner.Parent = sliderBg

        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg

        local sfCorner = Instance.new("UICorner")
        sfCorner.CornerRadius = UDim.new(1, 0)
        sfCorner.Parent = sliderFill

        local dragging = false

        local function updateSlider(inputX)
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderSize = sliderBg.AbsoluteSize.X
            local percentage = math.clamp((inputX - sliderPos) / sliderSize, 0, 1)
            local value = math.floor(min + (max - min) * percentage)
            
            TweenService:Create(sliderFill, TweenInfo.new(0.1), {
                Size = UDim2.new(percentage, 0, 1, 0)
            }):Play()
            
            valueLabel.Text = tostring(value)
            callback(value)
        end

        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input.Position.X)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- ============================================
    -- СОЗДАЁМ ЭЛЕМЕНТЫ ИНТЕРФЕЙСА
    -- ============================================

    createToggle("✈️ Полёт", "WASD + Space/Shift", false, function(state)
        config.flyEnabled = state
    end)

    createSlider("Скорость полёта", 10, 200, 50, function(value)
        config.flySpeed = value
    end)

    createToggle("🏃 Ускорение", "Быстрый бег", false, function(state)
        config.speedEnabled = state
        if state then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = config.walkSpeed end
            end
        else
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end)

    createSlider("Скорость бега", 16, 200, 50, function(value)
        config.walkSpeed = value
        if config.speedEnabled then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = value end
            end
        end
    end)

    createToggle("👻 NoClip", "Проходить сквозь стены", false, function(state)
        config.noclipEnabled = state
    end)

    createToggle("🌀 Teleport", "Ctrl + ЛКМ — телепорт", false, function(state)
        config.teleportEnabled = state
    end)

    -- Кнопка закрытия
    closeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    -- ============================================
    -- ПЕРЕТАСКИВАНИЕ МЕНЮ
    -- ============================================
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

    -- Горячая клавиша для скрытия/показа меню (правый Shift)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    print("✅ Fly GUI загружен!")
    print("📌 Правый Shift — скрыть/показать меню")
end)

-- ============================================
-- ИГРОВАЯ ЛОГИКА
-- ============================================

-- ПОЛЁТ
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
            
            -- Проверка, что не печатаем
            local isTyping = (UserInputService:GetFocusedTextBox() ~= nil)
            
            local move = Vector3.new(0, 0, 0)
            if not isTyping then
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
            end
            
            if move.Magnitude > 0 then move = move.Unit end
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

-- TELEPORT ПО CTRL+CLICK
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    pcall(function()
        if gameProcessed then return end
        if config.teleportEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = player:GetMouse()
                local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
                local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
                
                if result then
                    local char = player.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end
        end
    end)
end)
