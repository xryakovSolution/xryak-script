local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "xryak Hub | Adopt Me!",
   LoadingTitle = "Загрузка xryak...",
   LoadingSubtitle = "by xryakovSolution",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

local autoFarmPet = false
local autoGhostFarm = false
local autoOpenTombs = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local flying = false
local flySpeed = 50
local flyKey = Enum.KeyCode.E
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil

local customWaypoints = {}
local waypointDropdown = nil

local function teleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

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
        
        local camera = Workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
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

local HalloweenTab = Window:CreateTab("Halloween", 4483362458)

HalloweenTab:CreateSection("План 1: Фарм Ивента (Охота на призрака)")

HalloweenTab:CreateToggle({
   Name = "Авто-фарм Ивента (Призрак + Бластер)",
   CurrentValue = false,
   Flag = "AutoGhostFarmToggle",
   Callback = function(Value)
      autoGhostFarm = Value
      Rayfield:Notify({
         Title = "Halloween Event",
         Content = Value and "Авто-фарм призрака запущен!" or "Авто-фарм призрака остановлен.",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

HalloweenTab:CreateSection("План 2: Открытие Гробов в Гробнице")

HalloweenTab:CreateToggle({
   Name = "Авто-открытие Гробов",
   CurrentValue = false,
   Flag = "AutoOpenTombsToggle",
   Callback = function(Value)
      autoOpenTombs = Value
      Rayfield:Notify({
         Title = "Halloween Tomb",
         Content = Value and "Авто-открытие гробов включено!" or "Авто-открытие гробов выключено.",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

HalloweenTab:CreateSection("Halloween Locations")

local halloweenLocations = {
    ["Halloween Event"] = Vector3.new(-262.0, 91.4, -1128.5),
    ["Halloween Tomb"] = Vector3.new(-334.4, 41.2, -1199.2),
    ["Halloween Hotel"] = Vector3.new(-295.6, 42.5, -1434.3),
    ["Halloween Circus"] = Vector3.new(-316.9, 36.7, -1705.2)
}

local selectedHalloweenPreset = "Halloween Event"

HalloweenTab:CreateDropdown({
   Name = "Выберите локацию",
   Options = {
       "Halloween Event",
       "Halloween Tomb",
       "Halloween Hotel",
       "Halloween Circus"
   },
   CurrentOption = {"Halloween Event"},
   MultipleOptions = false,
   Flag = "HalloweenLocationsDropdown",
   Callback = function(Option)
      selectedHalloweenPreset = Option[1]
   end,
})

HalloweenTab:CreateButton({
   Name = "Телепортироваться",
   Callback = function()
      local targetPos = halloweenLocations[selectedHalloweenPreset]
      if targetPos then
          teleportTo(CFrame.new(targetPos))
          Rayfield:Notify({
             Title = "Halloween Teleport",
             Content = "Перемещение в: " .. selectedHalloweenPreset,
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})

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

local TeleportTab = Window:CreateTab("Teleports", 4483362458)

TeleportTab:CreateSection("Основные Локации Города")

local mainLocations = {
    ["Больница"] = Vector3.new(-214.9, 45.4, -1524.2),
    ["Школа"] = Vector3.new(-304.9, 39.3, -1495.3),
    ["Пиццерия"] = Vector3.new(-133.7, 39.9, -1662.2),
    ["Кошачье кафе"] = Vector3.new(-27.5, 42.0, -1646.5),
    ["Магазин питомцев"] = Vector3.new(-245.5, 34.2, -1479.1),
    ["Кемпинг"] = Vector3.new(-34.8, 44.0, -1087.6),
    ["Пляж"] = Vector3.new(-594.3, 35.6, -1472.4)
}

local selectedMainPreset = "Больница"

TeleportTab:CreateDropdown({
   Name = "Выберите локацию",
   Options = {
       "Больница",
       "Школа",
       "Пиццерия",
       "Кошачье кафе",
       "Магазин питомцев",
       "Кемпинг",
       "Пляж"
   },
   CurrentOption = {"Больница"},
   MultipleOptions = false,
   Flag = "MainLocationsDropdown",
   Callback = function(Option)
      selectedMainPreset = Option[1]
   end,
})

TeleportTab:CreateButton({
   Name = "Телепортироваться",
   Callback = function()
      local targetPos = mainLocations[selectedMainPreset]
      if targetPos then
          teleportTo(CFrame.new(targetPos))
          Rayfield:Notify({
             Title = "Телепорт",
             Content = "Вы телепортированы в: " .. selectedMainPreset,
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})

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

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateSection("Автофарм питомцев")

FarmTab:CreateToggle({
   Name = "Авто-выполнение потребностей",
   CurrentValue = false,
   Flag = "AutoPetFarmToggle",
   Callback = function(Value)
      autoFarmPet = Value
      Rayfield:Notify({
         Title = "xryak Auto Farm",
         Content = Value and "Автофарм запущен!" or "Автофарм остановлен.",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

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

local function equipBlaster()
   pcall(function()
      local char = LocalPlayer.Character
      local bp = LocalPlayer:FindFirstChild("Backpack")
      if not char then return end
      
      local blaster = bp:FindFirstChild("Blaster") or char:FindFirstChild("Blaster")
      if not blaster then
         for _, item in pairs(bp:GetChildren()) do
            if string.find(string.lower(item.Name), "blaster") or string.find(string.lower(item.Name), "ghost") then
               blaster = item
               break
            end
         end
      end
      if blaster and blaster.Parent == bp then
         LocalPlayer.Character.Humanoid:EquipTool(blaster)
      end
   end)
end

local function processGhostFarm()
   if not autoGhostFarm then return end
   pcall(function()
      equipBlaster()
      
      local char = LocalPlayer.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end
      
      local ghost = nil
      local breakableObj = nil
      
      for _, obj in pairs(Workspace:GetDescendants()) do
         if obj:IsA("Model") and (string.find(string.lower(obj.Name), "ghost") or string.find(string.lower(obj.Name), "призрак")) then
            ghost = obj
            break
         end
      end
      
      if not ghost then
         for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
               if obj:getAttribute("Breakable") or string.find(string.lower(obj.Name), "breakable") or string.find(string.lower(obj.Name), "furniture") then
                  breakableObj = obj
                  break
               end
            end
         end
      end

      local API = ReplicatedStorage:FindFirstChild("API")

      if ghost then
         local ghostPart = ghost:FindFirstChild("HumanoidRootPart") or ghost:FindFirstChildWhichIsA("BasePart")
         if ghostPart then
            char.HumanoidRootPart.CFrame = ghostPart.CFrame * CFrame.new(0, 0, 4)
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, ghostPart.Position)
            
            if API then
               for _, remote in pairs(API:GetChildren()) do
                  if string.find(string.lower(remote.Name), "shoot") or string.find(string.lower(remote.Name), "blaster") or string.find(string.lower(remote.Name), "ghost") then
                     if remote:IsA("RemoteEvent") then
                        remote:FireServer(ghostPart.Position, ghost)
                     end
                  end
               end
            end
         end
      elseif breakableObj then
         local targetPos = breakableObj:IsA("Model") and breakableObj:GetPivot().Position or breakableObj.Position
         char.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 3))
         
         if API then
            for _, remote in pairs(API:GetChildren()) do
               if string.find(string.lower(remote.Name), "break") or string.find(string.lower(remote.Name), "blaster") then
                  if remote:IsA("RemoteEvent") then
                     remote:FireServer(targetPos, breakableObj)
                  end
               end
            end
         end
      else
         teleportTo(CFrame.new(halloweenLocations["Halloween Event"]))
      end
   end)
end

local function processTombFarm()
   if not autoOpenTombs then return end
   pcall(function()
      local char = LocalPlayer.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") then return end
      
      local tombPos = halloweenLocations["Halloween Tomb"]
      if (char.HumanoidRootPart.Position - tombPos).Magnitude > 60 then
         teleportTo(CFrame.new(tombPos))
         task.wait(0.8)
      end
      
      local portalOffset = CFrame.new(0, 0, -8)
      local portalDoor = Workspace:FindFirstChild("TombDoor", true) or Workspace:FindFirstChild("Portal", true)
      if portalDoor then
         char.HumanoidRootPart.CFrame = portalDoor.CFrame * CFrame.new(0, 0, -5)
      else
         char.HumanoidRootPart.CFrame = CFrame.new(tombPos) * CFrame.Angles(0, math.rad(180), 0) * portalOffset
      end
      
      task.wait(1)
      
      local coffins = {}
      for _, obj in pairs(Workspace:GetDescendants()) do
         if obj:IsA("Model") or obj:IsA("BasePart") then
            if string.find(string.lower(obj.Name), "coffin") or string.find(string.lower(obj.Name), "grob") or string.find(string.lower(obj.Name), "гроб") then
               table.insert(coffins, obj)
            end
         end
      end
      
      if #coffins > 0 then
         local chosenCoffin = coffins[math.random(1, #coffins)]
         local pos = chosenCoffin:IsA("Model") and chosenCoffin:GetPivot().Position or chosenCoffin.Position
         
         char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 3))
         task.wait(0.4)
         
         local API = ReplicatedStorage:FindFirstChild("API")
         if API then
            for _, remote in pairs(API:GetChildren()) do
               if string.find(string.lower(remote.Name), "tomb") or string.find(string.lower(remote.Name), "coffin") or string.find(string.lower(remote.Name), "open") or string.find(string.lower(remote.Name), "key") then
                  if remote:IsA("RemoteEvent") then
                     remote:FireServer(chosenCoffin)
                  elseif remote:IsA("RemoteFunction") then
                     remote:InvokeServer(chosenCoffin)
                  end
               end
            end
         end
         
         fireprompt = fireproximityprompt or function(p) if p then p:InputHoldBegin() task.wait(0.1) p:InputHoldEnd() end end
         local prompt = chosenCoffin:FindFirstChildWhichIsA("ProximityPrompt", true)
         if prompt then
            fireprompt(prompt)
         end
      end
   end)
end

task.spawn(function()
   while true do
      if autoFarmPet then
         doPetFarm()
      end
      if autoGhostFarm then
         processGhostFarm()
      end
      if autoOpenTombs then
         processTombFarm()
      end
      task.wait(0.5)
   end
end)

Rayfield:Notify({
   Title = "xryak Hub",
   Content = "Скрипт готов к работе!",
   Duration = 5,
   Image = 4483362458,
})
