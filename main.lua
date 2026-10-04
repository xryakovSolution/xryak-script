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

-- Функция правильной загрузки основного мира Adopt Me!
local function loadMainMap()
    pcall(function()
        local Fsys = require(ReplicatedStorage:WaitForChild("Fsys"))
        local RouterClient = Fsys.load("RouterClient")
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

        -- Вызываем официальный переход игры на MainMap
        RouterClient.get("LocationAPI/SetLocation"):FireServer("MainMap", "Shop", "MainDoor")
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
@@ -72,71 +150,137 @@ MainTab:CreateSlider({
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
-- ВКЛАДКА: TELEPORTS (ТЕЛЕПОРТАЦИЯ)
-- ВКЛАДКА: TELEPORTS (СВОИ ТОЧКИ)
-- ==========================================
local TeleportTab = Window:CreateTab("Teleports", 4483362458)

TeleportTab:CreateSection("Переход в Главный Город")
TeleportTab:CreateSection("Сохранение собственных точек")

TeleportTab:CreateButton({
   Name = "Загрузить Главный Город (Main Map)",
   Callback = function()
      loadMainMap()
      Rayfield:Notify({
         Title = "Телепорт",
         Content = "Загружаем основной мир...",
         Duration = 3,
         Image = 4483362458,
      })
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
   Name = "Подняться на карту (Выбраться из пустоты)",
   Name = "Сохранить текущую позицию",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local currentCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
         LocalPlayer.Character.HumanoidRootPart.CFrame = currentCFrame + Vector3.new(0, 500, 0)
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

TeleportTab:CreateSection("Точные координаты (Основная карта)")

-- Координаты с учетом реальной высоты карты в Adopt Me
local locations = {
    ["Центр / Nursery"] = Vector3.new(-242, 30, -1742),
    ["Больница (Hospital)"] = Vector3.new(-290, 30, -1770),
    ["Школа (School)"] = Vector3.new(-330, 30, -1450),
    ["Зоомагазин (Pet Shop)"] = Vector3.new(-110, 30, -1650),
    ["Игровая площадка (Playground)"] = Vector3.new(-215, 30, -1660),
    ["Пляж (Beach)"] = Vector3.new(-980, 25, -1400),
    ["Пиццерия (Pizza Shop)"] = Vector3.new(-120, 30, -1350)
}

local selectedLocation = "Центр / Nursery"

TeleportTab:CreateDropdown({
   Name = "Выберите локацию",
   Options = {"Центр / Nursery", "Больница (Hospital)", "Школа (School)", "Зоомагазин (Pet Shop)", "Игровая площадка (Playground)", "Пляж (Beach)", "Пиццерия (Pizza Shop)"},
   CurrentOption = {"Центр / Nursery"},
TeleportTab:CreateSection("Управление точками")

waypointDropdown = TeleportTab:CreateDropdown({
   Name = "Выберите сохраненную точку",
   Options = {"Нет сохраненных точек"},
   CurrentOption = {"Нет сохраненных точек"},
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Flag = "CustomWaypointsDropdown",
   Callback = function(Option)
      selectedLocation = Option[1]
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
   Name = "Телепортироваться",
   Name = "Телепортироваться к выбранной точке",
   Callback = function()
      local targetPos = locations[selectedLocation]
      if targetPos then
          teleportTo(CFrame.new(targetPos))
      local cf = customWaypoints[selectedWaypoint]
      if cf then
          teleportTo(cf)
          Rayfield:Notify({
             Title = "Телепорт",
             Content = "Перемещение в: " .. selectedLocation,
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
@@ -151,14 +295,13 @@ TeleportTab:CreateButton({
   Callback = function()
      Rayfield:Notify({
         Title = "Click TP",
         Content = "Зажмите Ctrl и нажмите ЛКМ по поверхности.",
         Content = "Зажмите Ctrl и кликните по поверхности.",
         Duration = 4,
         Image = 4483362458,
      })
   end,
})

-- Логика телепорта по Ctrl + Click
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
