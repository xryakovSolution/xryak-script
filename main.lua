-- Загрузка библиотеки UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна xryak
local Window = Rayfield:CreateWindow({
   Name = "xryak Hub | Adopt Me!",
   LoadingTitle = "Загрузка xryak...",
   LoadingSubtitle = "by xryakovSolution",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

-- Переменные
local autoFarmPet = false
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Переменные для Fly
local flying = false
local flySpeed = 50
local flyKey = Enum.KeyCode.E
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil

-- Таблица для сохраненных точек телепорта
local customWaypoints = {}
local waypointDropdown = nil

-- Функция безопасной телепортации
local function teleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

-- Логика управления Fly
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    
    flying = true
    
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not char or not char:FindFirstChild("HumanoidRootPart") then
            if flyConnection then flyConnection:Disconnect() end
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        bodyGyro.CFrame = camera.CFrame
        bodyVelocity.Velocity = moveDir * flySpeed
    end)
end

local function stopFly()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

-- Активация Fly по клавише
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == flyKey then
        if flying then
            stopFly()
            Rayfield:Notify({Title = "Fly", Content = "Полет отключен", Duration = 2})
        else
            startFly()
            Rayfield:Notify({Title = "Fly", Content = "Полет включен", Duration = 2})
        end
    end
end)

-- ==========================================
-- ВКЛАДКА: MAIN
-- ==========================================
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("Настройки игрока")

MainTab:CreateSlider({
   Name = "Скорость ходьбы (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

MainTab:CreateSlider({
   Name = "Сила прыжка (JumpPower)",
   Range = {50, 300},
   Increment = 5,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

MainTab:CreateSection("Режим полета (Fly)")

MainTab:CreateToggle({
   Name = "Включить Полет (Fly)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      if Value then
          if not flying then startFly() end
      else
          if flying then stopFly() end
      end
   end,
})

MainTab:CreateSlider({
   Name = "Скорость полета",
   Range = {20, 300},
   Increment = 5,
   Suffix = " Speed",
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      flySpeed = Value
   end,
})

MainTab:CreateKeybind({
   Name = "Бинд переключения полета",
   CurrentKeybind = "E",
   HoldToInteract = false,
   Flag = "FlyKeybind",
   Callback = function(Keybind)
      flyKey = Enum.KeyCode[Keybind]
   end,
})

-- ==========================================
-- ВКЛАДКА: TELEPORTS (СВОИ ТОЧКИ)
-- ==========================================
local TeleportTab = Window:CreateTab("Teleports", 4483362458)

TeleportTab:CreateSection("Сохранение собственных точек")

local newWaypointName = "Точка 1"
local selectedWaypoint = ""

TeleportTab:CreateInput({
   Name = "Название новой точки",
   PlaceholderText = "Введите название...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      newWaypointName = Text
   end,
})

local coordsInput = nil

TeleportTab:CreateButton({
   Name = "Сохранить текущую позицию",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
          local pos = LocalPlayer.Character.HumanoidRootPart.Position
          local posStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
          
          customWaypoints[newWaypointName] = LocalPlayer.Character.HumanoidRootPart.CFrame
          
          -- Обновляем список выбора
          local keys = {}
          for k in pairs(customWaypoints) do
              table.insert(keys, k)
          end
          
          waypointDropdown:Refresh(keys, true)
          selectedWaypoint = newWaypointName
          
          if coordsInput then
              coordsInput:Set(posStr)
          end
          
          Rayfield:Notify({
             Title = "Точка сохранена",
             Content = string.format("Сохранено: %s (%s)", newWaypointName, posStr),
             Duration = 4,
             Image = 4483362458,
          })
      end
   end,
})

TeleportTab:CreateSection("Управление точками")

waypointDropdown = TeleportTab:CreateDropdown({
   Name = "Выберите сохраненную точку",
   Options = {"Нет сохраненных точек"},
   CurrentOption = {"Нет сохраненных точек"},
   MultipleOptions = false,
   Flag = "CustomWaypointsDropdown",
   Callback = function(Option)
      selectedWaypoint = Option[1]
      local cf = customWaypoints[selectedWaypoint]
      if cf and coordsInput then
          local pos = cf.Position
          coordsInput:Set(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
      end
   end,
})

coordsInput = TeleportTab:CreateInput({
   Name = "Координаты выданной точки",
   PlaceholderText = "Здесь появятся координаты...",
   RemoveTextAfterFocusLost = false,
   Callback = function() end,
})

TeleportTab:CreateButton({
   Name = "Телепортироваться к выбранной точке",
   Callback = function()
      local cf = customWaypoints[selectedWaypoint]
      if cf then
          teleportTo(cf)
          Rayfield:Notify({
             Title = "Телепорт",
             Content = "Телепортированы на точку: " .. selectedWaypoint,
             Duration = 3,
             Image = 4483362458,
          })
      else
          Rayfield:Notify({
             Title = "Ошибка",
             Content = "Выбранная точка не найдена!",
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})

TeleportTab:CreateSection("Универсальный телепорт")

TeleportTab:CreateButton({
   Name = "Клик-Телепорт (Ctrl + ЛКМ)",
   Callback = function()
      Rayfield:Notify({
         Title = "Click TP",
         Content = "Зажмите Ctrl и кликните по поверхности.",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Hit then
            teleportTo(mouse.Hit + Vector3.new(0, 3, 0))
        end
    end
end)

-- ==========================================
-- ВКЛАДКА: AUTO FARM (ADOPT ME!)
-- ==========================================
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateSection("Автофарм питомцев")

FarmTab:CreateToggle({
   Name = "Авто-выполнение потребностей",
   CurrentValue = false,
   Flag = "AutoPetFarmToggle",
   Callback = function(Value)
      autoFarmPet = Value
      if autoFarmPet then
         Rayfield:Notify({
            Title = "xryak Auto Farm",
            Content = "Автофарм запущен!",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "xryak Auto Farm",
            Content = "Автофарм остановлен.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- Функция автоматического поиска и выполнения нужд
local function doPetFarm()
   pcall(function()
      local API = ReplicatedStorage:FindFirstChild("API")
      if not API then return end

      for _, remote in pairs(API:GetChildren()) do
         if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
            if string.find(string.lower(remote.Name), "pet") or string.find(string.lower(remote.Name), "task") then
               if remote:IsA("RemoteFunction") then
                  remote:InvokeServer("sleepy")
                  remote:InvokeServer("hungry")
               end
            end
         end
      end
   end)
end

-- Фоновый поток автофарма
task.spawn(function()
   while true do
      if autoFarmPet then
         doPetFarm()
      end
      task.wait(5)
   end
end)

-- Уведомление
Rayfield:Notify({
   Title = "xryak Hub",
   Content = "Скрипт готов к работе!",
   Duration = 5,
   Image = 4483362458,
})
