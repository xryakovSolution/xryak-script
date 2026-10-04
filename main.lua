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
   KeySystem = false -- Систему ключей пока отключили
})

-- Создаём вкладку "Main" (Главная)
local MainTab = Window:CreateTab("Main", 4483362458) -- Иконка вкладки

-- Раздел с настройками персонажа
MainTab:CreateSection("Настройки игрока")

-- Слайдер для управления скоростью ходьбы (WalkSpeed)
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

-- Слайдер для управления высотой прыжка (JumpPower)
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

-- Переключатель (Toggle) для полного сброса параметров
MainTab:CreateButton({
   Name = "Сбросить параметры (Default)",
   Callback = function()
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
   end,
})

-- Отправляем уведомление о готовности
Rayfield:Notify({
   Title = "xryak Loaded",
   Content = "Интерфейс успешно загружен!",
   Duration = 5,
   Image = 4483362458,
})
