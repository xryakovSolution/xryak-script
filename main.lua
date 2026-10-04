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
local LocalPlayer = Players.LocalPlayer

-- Функция для безопасной телепортации
local function teleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

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

-- ==========================================
-- ВКЛАДКА: TELEPORTS (ТЕЛЕПОРТАЦИЯ)
-- ==========================================
local TeleportTab = Window:CreateTab("Teleports", 4483362458)

TeleportTab:CreateSection("Быстрый телепорт по локациям")

local locations = {
    ["Центр (Nursery / Main Center)"] = Vector3.new(-175, 35, -1510),
    ["Больница (Hospital)"] = Vector3.new(-285, 30, -1770),
    ["Школа (School)"] = Vector3.new(-330, 30, -1450),
    ["Зоомагазин (Pet Shop)"] = Vector3.new(-110, 30, -1650),
    ["Игровая площадка (Playground)"] = Vector3.new(-215, 30, -1660),
    ["Пляж (Beach)"] = Vector3.new(-980, 25, -1400),
    ["Пиццерия (Pizza Shop)"] = Vector3.new(-120, 30, -1350)
}

local selectedLocation = "Центр (Nursery / Main Center)"

TeleportTab:CreateDropdown({
   Name = "Выберите локацию",
   Options = {"Центр (Nursery / Main Center)", "Больница (Hospital)", "Школа (School)", "Зоомагазин (Pet Shop)", "Игровая площадка (Playground)", "Пляж (Beach)", "Пиццерия (Pizza Shop)"},
   CurrentOption = {"Центр (Nursery / Main Center)"},
   MultipleOptions = false,
   Flag = "TeleportDropdown",
   Callback = function(Option)
      selectedLocation = Option[1]
   end,
})

TeleportTab:CreateButton({
   Name = "Телепортироваться",
   Callback = function()
      local targetPos = locations[selectedLocation]
      if targetPos then
          teleportTo(CFrame.new(targetPos))
          Rayfield:Notify({
             Title = "Телепорт",
             Content = "Вы успешно телепортированы в: " .. selectedLocation,
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
         Content = "Зажмите Ctrl и нажмите ЛКМ в любую точку на карте, чтобы телепортироваться.",
         Duration = 5,
         Image = 4483362458,
      })
   end,
})

-- Логика телепорта по Ctrl + Click
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
            Content = "Автофарм запущен! Ожидайте появления задач...",
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

      -- Список стандартных сервисов Adopt Me
      local LocationAPI = API:FindFirstChild("HousingAPI/BuyItem") or API:FindFirstChild("DailyQuestsAPI/ClaimQuest")
      
      -- Ищем активные ремоуты ухода за питомцем
      for _, remote in pairs(API:GetChildren()) do
         if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
            -- Пробуем отправить сигналы на закрытие потребностей
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
