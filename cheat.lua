-- ============================================
-- DEV TOOLS v3.0 (CRASH-FIX VERSION)
-- Упрощённый GUI без крашей
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Настройки
local config = {
    flySpeed = 50,
    customSpeed = 16,
    autoSpeed = false,
    isFlying = false,
    isKillAura = false,
    damagePlayers = false,
    damageAmount = 100,
    killRadius = 15
}

-- Переменные для полета
local bodyVel, bodyGyro

-- ============================================
-- ПРОСТОЙ GUI (БЕЗ КРАШЕЙ)
-- ============================================

pcall(function()
    if player.PlayerGui:FindFirstChild("DevToolsUI") then
        player.PlayerGui.DevToolsUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DevToolsUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player.PlayerGui

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Заголовок
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Header.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "🛠️ Dev Tools v3.0"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.Parent = Header

    -- Контейнер для кнопок (БЕЗ ScrollingFrame!)
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(1, -20, 1, -60)
    ButtonContainer.Position = UDim2.new(0, 10, 0, 50)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = MainFrame

    local currentY = 0

    -- Функция создания простой кнопки
    local function createButton(title, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        btn.Text = title
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = ButtonContainer
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Создаём кнопки
    createButton("🏃 Скорость: 50", 0, function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 50
                config.customSpeed = 50
                print("✅ Скорость: 50")
            end
        end
    end)

    createButton("🏃 Скорость: 100", 40, function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 100
                config.customSpeed = 100
                print("✅ Скорость: 100")
            end
        end
    end)

    createButton("🏃 Скорость: 200", 80, function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 200
                config.customSpeed = 200
                print("✅ Скорость: 200")
            end
        end
    end)

    createButton("✈️ Полёт: ВКЛ/ВЫКЛ", 130, function()
        config.isFlying = not config.isFlying
        if config.isFlying then
            print("✈️ Полёт ВКЛЮЧЕН")
        else
            print("✈️ Полёт ВЫКЛЮЧЕН")
        end
    end)

    createButton("💀 Kill Aura: ВКЛ/ВЫКЛ", 170, function()
        config.isKillAura = not config.isKillAura
        if config.isKillAura then
            print("💀 Kill Aura ВКЛЮЧЕНА")
        else
            print("💀 Kill Aura ВЫКЛЮЧЕНА")
        end
    end)

    createButton("🎯 Damage Players: ВКЛ/ВЫКЛ", 210, function()
        config.damagePlayers = not config.damagePlayers
        if config.damagePlayers then
            warn("⚠️ Урон по игрокам ВКЛЮЧЕН!")
        else
            print("🎯 Урон по игрокам ВЫКЛЮЧЕН")
        end
    end)

    createButton("💥 Удар ВСЕМ рядом", 260, function()
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

    createButton("❤️ Лечение себя", 300, function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                print("❤️ Здоровье восстановлено")
            end
        end
    end)

    print("✅ Dev Tools v3.0 загружены!")
    print("📌 Меню в центре экрана")
end)

-- ============================================
-- ИГРОВАЯ ЛОГИКА (С ЗАЩИТОЙ)
-- ============================================

-- FLY
pcall(function()
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if config.isFlying then
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if root and hum then
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
                        
                        -- Проверяем, что не печатаем в TextBox
                        local focusedTextBox = UserInputService:GetFocusedTextBox()
                        local isTyping = (focusedTextBox ~= nil)
                        
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
                    end
                end
            else
                if bodyVel then 
                    bodyVel:Destroy()
                    bodyVel = nil 
                end
                if bodyGyro then 
                    bodyGyro:Destroy()
                    bodyGyro = nil 
                end
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then 
                        hum.PlatformStand = false 
                    end
                end
            end
        end)
    end)
end)

-- KILL AURA + DAMAGE PLAYERS
pcall(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = player.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum then return end

            if config.isKillAura or config.damagePlayers then
                for _, otherChar in ipairs(workspace:GetChildren()) do
                    if otherChar:IsA("Model") and otherChar ~= char then
                        local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
                        local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
                        if otherHum and otherRoot then
                            local dist = (root.Position - otherRoot.Position).Magnitude
                            if dist < config.killRadius then
                                local isPlayer = Players:GetPlayerFromCharacter(otherChar)
                                
                                if config.isKillAura and not isPlayer then
                                    otherHum:TakeDamage(config.damageAmount)
                                end
                                
                                if config.damagePlayers and isPlayer and isPlayer ~= player then
                                    otherHum:TakeDamage(config.damageAmount)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)
end)

print("✅ Все системы загружены!")
