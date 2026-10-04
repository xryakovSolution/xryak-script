local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "xryak Hub | Adopt Me!",
   LoadingTitle = "Загрузка xryak...",
   LoadingSubtitle = "by xryakovSolution",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Переменные состояний
local autoGhostFarm = false
local autoAcceptTeleport = true
local autoOpenTombs = false

-- Вспомогательная функция для выхода на главную карту
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

-- Клик на "Yes" в всплывающем окне ивента
local function checkAndAcceptTeleport()
    if not autoAcceptTeleport then return end
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in pairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local text = btn:IsA("TextButton") and string.lower(btn.Text) or ""
                        if text == "yes" or btn.Name == "Yes" or btn.Name == "ConfirmButton" then
                            for _, sample in pairs(gui:GetDescendants()) do
                                if sample:IsA("TextLabel") and string.find(string.lower(sample.Text), "ghost gallery") then
                                    if firesignal then
                                        firesignal(btn.MouseButton1Click)
                                    else
                                        local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
                                        task.wait(0.05)
                                        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
                                    end
                                    break
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

-- Модуль Автофарма ивента
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
--  ВКЛАДКИ ИНТЕРФЕЙСА RAYFIELD
-- ====================================================================

-- 1. Основное меню
local MainTab = Window:CreateTab("Главное", 4483362458)
MainTab:CreateLabel("Добро пожаловать в xryak Hub!")
MainTab:CreateButton({
   Name = "Выйти из дома на главную карту",
   Callback = function()
      ensureMainMap()
   end,
})

-- 2. Ивентовая вкладка (Ghost Gallery)
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

-- 3. Вкладка Телепортов (Включая Трейдинг Хаб)
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

-- Фоновый поток автофарма
task.spawn(function()
    while true do
        if autoGhostFarm then
            processGhostEvent()
        end
        task.wait(0.1)
    end
end)
