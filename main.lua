local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "xryak Hub | Ghost Gallery Farm",
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

local autoGhostFarm = false
local autoAcceptTeleport = true

-- 1. Авто-кликер для всплывающего окна "Ghost Gallery is starting soon! Teleport there now?"
local function checkAndAcceptTeleport()
    if not autoAcceptTeleport then return end
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, btn in pairs(gui:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        local text = ""
                        if btn:IsA("TextButton") then
                            text = string.lower(btn.Text)
                        end
                        -- Проверяем кнопку Yes или зеленую кнопку принятия телепорта
                        if text == "yes" or btn.Name == "Yes" or btn.Name == "ConfirmButton" then
                            local parentText = string.lower(btn.Parent and btn.Parent.ClassName or "")
                            -- Нажимаем кнопку кликом
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

-- 2. Поиск и экипировка Бластера
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

-- 3. Вход в круг ожидания (NEXT GAME IN: 00:10)
local function stepInWaitingCircle()
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- Ищем светящееся кольцо/зону ожидания
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

-- 4. Главный логический модуль Охоты на Призраков
local function processGhostEvent()
    if not autoGhostFarm then return end
    
    checkAndAcceptTeleport()
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = char.HumanoidRootPart
        local camera = Workspace.CurrentCamera
        
        -- Проверяем, находимся ли мы уже внутри самой мини-игры (по наличию кнопки Exit Minigame / интерфейса Score)
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

        -- Если идет мини-игра
        if inMinigame then
            equipBlaster()

            -- А. Ищем Призрака
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
                -- Телепортируемся лицом к призраку
                hrp.CFrame = CFrame.new(targetGhost.Position + Vector3.new(0, 1, 6), targetGhost.Position)
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetGhost.Position)
                
                -- Зажимаем атакующую клавишу/мышь
                VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, true, game, 0)
                
                -- Отправка прямого вызова на сервер
                local API = ReplicatedStorage:FindFirstChild("API")
                if API then
                    for _, remote in pairs(API:GetChildren()) do
                        if string.find(string.lower(remote.Name), "shoot") or string.find(string.lower(remote.Name), "blaster") or string.find(string.lower(remote.Name), "hit") then
                            if remote:IsA("RemoteEvent") then
                                remote:FireServer(targetGhost.Position, targetGhost.Parent)
                            end
                        end
                    end
                end
                return
            end

            -- Б. Если призрака нет — ищем Мебель/Предмет
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
            -- Если мы еще в лобби ожидания — встаем в круг
            VirtualInputManager:SendMouseButtonEvent(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2, 0, false, game, 0)
            stepInWaitingCircle()
        end
    end)
end

-- Интерфейс Rayfield
local Tab = Window:CreateTab("Ghost Gallery", 4483362458)

Tab:CreateToggle({
   Name = "Авто-принятие Телепорта (Кнопка YES)",
   CurrentValue = true,
   Flag = "AutoAcceptToggle",
   Callback = function(Value)
      autoAcceptTeleport = Value
   end,
})

Tab:CreateToggle({
   Name = "Авто-Фарм Ивента (Полный цикл)",
   CurrentValue = false,
   Flag = "AutoGhostFarmToggle",
   Callback = function(Value)
      autoGhostFarm = Value
      if not Value then
          VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
      end
   end,
})

-- Запуск фонового цикла
task.spawn(function()
    while true do
        if autoGhostFarm then
            processGhostEvent()
        end
        task.wait(0.1)
    end
end)
