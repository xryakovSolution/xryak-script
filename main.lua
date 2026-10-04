-- Загрузка библиотеки UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создание главного окна xryak
local Window = Rayfield:CreateWindow({
   Name = "xryak Hub | Roblox",
   LoadingTitle = "Загрузка xryak...",
   LoadingSubtitle = "by xryakovSolution",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false
})

-- Переменные для автофарма
local autoFarmPet = false

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
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
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
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

-- ==========================================
-- ВКЛАДКА: AUTO FARM
-- ==========================================
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateSection("Автоматизация питомцев")

FarmTab:CreateToggle({
   Name = "Авто-выполнение потребностей питомца",
   CurrentValue = false,
   Flag = "AutoPetFarmToggle",
   Callback = function(Value)
      autoFarmPet = Value
      if autoFarmPet then
         Rayfield:Notify({
            Title = "xryak Auto Farm",
            Content = "Автофарм питомца включён!",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "xryak Auto Farm",
            Content = "Автофарм выключен.",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

-- Фоновый цикл автофарма
task.spawn(function()
   while true do
      if autoFarmPet then
         -- ЗДЕСЬ БУДЕТ ЛОГИКА ДЛЯ КОНКРЕТНОЙ ИГРЫ
         -- Например: проверка потребностей (сон, еда, купание) и вызов RemoteEvents
         print("[xryak] Проверка потребностей питомца...")
      end
      task.wait(5) -- Проверка каждые 5 секунд
   end
end)

-- Отправляем уведомление
Rayfield:Notify({
   Title = "xryak Loaded",
   Content = "Интерфейс успешно загружен!",
   Duration = 5,
   Image = 4483362458,
})
