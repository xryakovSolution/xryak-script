local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "xryak Hub | Adopt Me!",
   LoadingTitle = "Загрузка xryak Hub...",
   LoadingSubtitle = "by xryakovSolution",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
--  ПЕРЕМЕННЫЕ
-- ====================================================================
local walkSpeed = 16
local jumpPower = 50
local isFlyEnabled = false
local flySpeed = 50
local flyKeybind = Enum.KeyCode.F
local isNoclipEnabled = false
local isInfJumpEnabled = false

local autoGhostFarm = false
local autoAcceptTeleport = true

local selectedPlayer = nil

-- ====================================================================
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ====================================================================

-- Безопасный выход из дома на главную карту
local function ensureMainMap()
    pcall(function()
        local isHousing = Workspace:FindFirstChild("House") or Workspace:FindFirstChild("Housing")
        if isHousing then
            local API = ReplicatedStorage:FindFirstChild("API")
            if API then
                for _, remote in pairs(API:GetChildren()) do
                    if string.find(string.lower(remote.Name), "location") or string.find(string.lower(remote.Name), "door") then
                        if remote:IsA("RemoteFunction") then
                            remote:InvokeServer("MainDoor", {["destination"] = "MainMap"})
                        elseif remote:IsA("RemoteEvent") then
                            remote:FireServer("MainDoor", {["destination"] = "MainMap"})
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- Авто-экипировка Бластера
local function equipBlaster()
    local char = LocalPlayer.Character
    if not char then return nil end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    
    if bp then
        for _, item in pairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                char.Humanoid:EquipTool(item)
                return item
            end
        end
    end
    return nil
end

-- МОДЕРНИЗИРОВАННЫЙ АВТО-YES (Прямой клик по GUI в Adopt Me)
local function checkAndAcceptTeleport()
    if not autoAcceptTeleport then return end
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                -- Ищем диалоговые фреймы
                local hasGhostText = false
                for _, desc in pairs(gui:GetDescendants()) do
                    if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and string.find(string.lower(desc.Text or ""), "ghost gallery") then
                        hasGhostText = true
                        break
                    end
                end
                
                if hasGhostText then
                    for _, btn in pairs(gui:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            local bText = btn:IsA("TextButton") and string.lower(btn.Text) or string.lower(btn.Name)
                            if bText == "yes" or string.find(bText, "yes") or btn.Name == "YesButton" or btn.Name == "Confirm" then
                                -- Принудительный клик по сигналу или виртуальной мыши
                                if firesignal then
                                    firesignal(btn.MouseButton1Click)
                                    firesignal(btn.Activated)
                                else
                                    local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                                    task.wait(0.05)
                                    VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Вход в круг ожидания
local function stepInWaitingCircle()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if string.find(name, "circle") or string.find(name, "zone") or string.find(name, "ring") or string.find(name, "pad") then
                    if obj.Size.X > 5 and obj.Size.Z > 5 then
                        char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                        return
                    end
                end
            end
        end
    end)
end

-- Логика фарма Ghost Gallery
local function processGhostEvent()
    if not autoGhostFarm then return end
    
    checkAndAcceptTeleport()
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart
        local camera = Workspace.CurrentCamera
        
        local inMinigame = false
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    for _, label in pairs(gui:GetDescendants()) do
                        if label:IsA("TextLabel") and (string.find(string.lower(label.Text), "score") or string.find(string.lower(label.Text), "ghost gallery")) then
                            inMinigame = true
                            break
                        end
                    end
                end
            end
        end

        if inMinigame then
            equipBlaster()

            -- 1. Поиск Призрака
            local targetGhost = nil
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (string.find(string.lower(obj.Name), "ghost") or string.find(string.lower(obj.Name), "призрак")) then
                    local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        targetGhost = part
                        break
                    end
                end
            end

            if targetGhost then
                hrp.CFrame = CFrame.new(targetGhost.Position + Vector3.new(0, 1, 6), targetGhost.Position)
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetGhost.Position)
                VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, true, game, 0)
                return
            end

            -- 2. Поиск Мебели
            local targetProp = nil
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "furniture") or string.find(name, "chair") or string.find(name, "table") or string.find(name, "prop") or string.find(name, "breakable") then
                        targetProp = obj
                        break
                    end
                end
            end

            if targetProp then
                local pPos = targetProp:IsA("Model") and targetProp:GetPivot().Position or targetProp.Position
                hrp.CFrame = CFrame.new(pPos + Vector3.new(0, 2, 4), pPos)
                camera.CFrame = CFrame.new(camera.CFrame.Position, pPos)
                VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, true, game, 0)
            end
        else
            VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, false, game, 0)
            stepInWaitingCircle()
        end
    end)
end

-- ====================================================================
--  ФИЗИКА И МОДИФИКАЦИИ (Fly с Биндами, Noclip, WalkSpeed)
-- ====================================================================

RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = walkSpeed
            char.Humanoid.JumpPower = jumpPower
            
            if isNoclipEnabled then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    if isInfJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ПЕРЕРАБОТАННЫЙ И ИСПРАВЛЕННЫЙ ФЛАЙ (FLY)
local flyBodyVel, flyBodyGyro

local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBodyVel.Velocity = Vector3.new(0, 0, 0)
    flyBodyVel.Parent = hrp
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBodyGyro.P = 9e4
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
end

local function stopFly()
    if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
end

-- Переключение флая по бинду
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == flyKeybind then
        isFlyEnabled = not isFlyEnabled
        if isFlyEnabled then
            startFly()
        else
            stopFly()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if isFlyEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and flyBodyVel and flyBodyGyro then
                local cam = Workspace.CurrentCamera
                flyBodyGyro.CFrame = cam.CFrame
                
                local moveDir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                flyBodyVel.Velocity = moveDir * flySpeed
            end
        end)
    end
end)

-- ====================================================================
--  ВКЛАДКИ ИНТЕРФЕЙСА RAYFIELD
-- ====================================================================

-- 1. Новая прокачанная вкладка "Главная"
local MainTab = Window:CreateTab("Главное", 4483362458)

MainTab:CreateSection("Статус скрипта")
MainTab:CreateLabel("Игрок: " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")")

MainTab:CreateSection("Быстрые действия")

MainTab:CreateButton({
   Name = "Выйти из дома на главную карту",
   Callback = function()
      ensureMainMap()
   end,
})

MainTab:CreateButton({
   Name = "Экстренно выключить весь автофарм",
   Callback = function()
      autoGhostFarm = false
      VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
      Rayfield:Notify({ Title = "xryak Hub", Content = "Автофарм полностью остановлен!", Duration = 3 })
   end,
})

MainTab:CreateButton({
   Name = "Перезапустить интерфейс скрипта",
   Callback = function()
      Rayfield:Destroy()
   end,
})

-- 2. Вкладка "Персонаж"
local PlayerTab = Window:CreateTab("Персонаж", 4483362458)

PlayerTab:CreateSlider({
   Name = "Скорость бега (WalkSpeed)",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      walkSpeed = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "Высота прыжка (JumpPower)",
   Range = {50, 300},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      jumpPower = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Режим полета (Fly)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      isFlyEnabled = Value
      if Value then startFly() else stopFly() end
   end,
})

PlayerTab:CreateKeybind({
   Name = "Бинд на Флай (Включить / Выключить)",
   CurrentKeybind = "F",
   HoldToInteract = false,
   Flag = "FlyKeybind",
   Callback = function(Keybind)
      flyKeybind = Keybind
   end,
})

PlayerTab:CreateSlider({
   Name = "Скорость полета",
   Range = {20, 200},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      flySpeed = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Проход сквозь стены (Noclip)",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value)
      isNoclipEnabled = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Бесконечный прыжок (Inf Jump)",
   CurrentValue = false,
   Flag = "InfJumpToggle",
   Callback = function(Value)
      isInfJumpEnabled = Value
   end,
})

-- 3. Вкладка "Halloween Event"
local EventTab = Window:CreateTab("Halloween Event", 4483362458)

EventTab:CreateToggle({
   Name = "Авто-принятие Телепорта (Кнопка YES)",
   CurrentValue = true,
   Flag = "AutoAcceptToggle",
   Callback = function(Value)
      autoAcceptTeleport = Value
   end,
})

EventTab:CreateToggle({
   Name = "Авто-Фарм Ghost Gallery (Призраки + Мебель)",
   CurrentValue = false,
   Flag = "AutoGhostFarmToggle",
   Callback = function(Value)
      autoGhostFarm = Value
      if not Value then
          VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
      end
   end,
})

-- 4. Вкладка Телепортов
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)

local mainLocations = {
    ["Больница"] = Vector3.new(292.0, 31.0, -1451.0),
    ["Школа"] = Vector3.new(-180.0, 31.0, -1400.0),
    ["Пиццерия"] = Vector3.new(-120.0, 31.0, -1180.0),
    ["Кошачье кафе"] = Vector3.new(150.0, 31.0, -1100.0),
    ["Магазин питомцев"] = Vector3.new(-200.0, 31.0, -1600.0),
    ["Кемпинг"] = Vector3.new(-900.0, 31.0, -1100.0),
    ["Пляж"] = Vector3.new(-550.0, 31.0, -1700.0),
    ["Трейдинг Хаб"] = Vector3.new(245.0, 35.0, -1650.0)
}

TeleportTab:CreateDropdown({
   Name = "Телепорт по локациям",
   Options = {"Больница", "Школа", "Пиццерия", "Кошачье кафе", "Магазин питомцев", "Кемпинг", "Пляж", "Трейдинг Хаб"},
   CurrentOption = {"Больница"},
   MultipleOptions = false,
   Flag = "LocationDropdown",
   Callback = function(Option)
      ensureMainMap()
      local selected = type(Option) == "table" and Option[1] or Option
      local pos = mainLocations[selected]
      if pos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
      end
   end,
})

TeleportTab:CreateButton({
   Name = "Прямой переход в Трейдинг Хаб (Remote)",
   Callback = function()
      ensureMainMap()
      pcall(function()
         local API = ReplicatedStorage:FindFirstChild("API")
         if API then
            for _, remote in pairs(API:GetChildren()) do
               if string.find(string.lower(remote.Name), "location") or string.find(string.lower(remote.Name), "door") then
                  if remote:IsA("RemoteFunction") then
                     remote:InvokeServer("TradingHubDoor", {["destination"] = "TradingHub"})
                  elseif remote:IsA("RemoteEvent") then
                     remote:FireServer("TradingHubDoor", {["destination"] = "TradingHub"})
                  end
               end
            end
         end
      end)
   end,
})

-- Телепорт к игрокам
local function getPlayerList()
    local plrs = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(plrs, p.Name)
        end
    end
    return #plrs > 0 and plrs or {"Нет игроков"}
end

local playerDropdown = TeleportTab:CreateDropdown({
   Name = "Выберите игрока",
   Options = getPlayerList(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
      selectedPlayer = type(Option) == "table" and Option[1] or Option
   end,
})

TeleportTab:CreateButton({
   Name = "Телепортироваться к игроку",
   Callback = function()
      if selectedPlayer and Players:FindFirstChild(selectedPlayer) then
         local target = Players[selectedPlayer].Character
         if target and target:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
         end
      end
   end,
})

TeleportTab:CreateButton({
   Name = "Обновить список игроков",
   Callback = function()
      playerDropdown:Refresh(getPlayerList())
   end,
})

-- Цикл работы автофарма
task.spawn(function()
    while true do
        if autoGhostFarm then
            processGhostEvent()
        else
            checkAndAcceptTeleport()
        end
        task.wait(0.1)
    end
end)
