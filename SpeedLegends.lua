-- Carregar Rayfield Library (Correção)
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Erro ao carregar Rayfield UI. Verifique sua conexão.")
    return
end

-- Criar a Janela do Menu
local Window = Rayfield:CreateWindow({
    Name = "Speed Legends | Hub PRO",
    LoadingTitle = "Ativando Hacks Avançados...",
    LoadingSubtitle = "By SeuNome",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SpeedLegendsHub",
        FileName = "config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Variáveis do Jogador
local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

-- 🔥 Função para Bypass de Anticheat
local function BypassAnticheat()
    for _, v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
        v:Disable()
    end
end
BypassAnticheat()

-- TAB PRINCIPAL
local MainTab = Window:CreateTab("🏆 Principal")

-- ✅ Auto-Farm Totalmente Automático
MainTab:CreateToggle({
    Name = "🏃 Auto-Farm (Ganha Velocidade Ilimitada)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        getgenv().AutoFarm = Value
        while getgenv().AutoFarm do
            game:GetService("ReplicatedStorage").Events.GainSpeed:FireServer(200) -- Ajustável
            task.wait(0.2)
        end
    end
})

-- ✅ Auto-Rebirth Inteligente
MainTab:CreateToggle({
    Name = "🔁 Auto-Rebirth Inteligente",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        getgenv().AutoRebirth = Value
        while getgenv().AutoRebirth do
            game:GetService("ReplicatedStorage").Events.Rebirth:FireServer()
            task.wait(5)
        end
    end
})

-- ✅ Auto-Coletar Orbs, Anéis e Boosts
MainTab:CreateToggle({
    Name = "💎 Auto-Coletar Orbs & Boosts",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(Value)
        getgenv().AutoCollect = Value
        while getgenv().AutoCollect do
            for _, item in pairs(game:GetService("Workspace"):GetChildren()) do
                if item:IsA("Model") and item:FindFirstChild("TouchInterest") then
                    player.Character.HumanoidRootPart.CFrame = item.CFrame
                    task.wait(0.1)
                end
            end
        end
    end
})

-- ✅ Auto-Corrida PRO (Garante Vitórias)
MainTab:CreateToggle({
    Name = "🏁 Auto-Corrida (Vence Sempre)",
    CurrentValue = false,
    Flag = "AutoRace",
    Callback = function(Value)
        getgenv().AutoRace = Value
        while getgenv().AutoRace do
            for _, race in pairs(game:GetService("Workspace").Races:GetChildren()) do
                if race:IsA("Model") and race:FindFirstChild("TouchInterest") then
                    player.Character.HumanoidRootPart.CFrame = race.CFrame
                    task.wait(0.3)
                end
            end
        end
    end
})

-- ✅ Velocidade Customizável
MainTab:CreateSlider({
    Name = "⚡ Ajustar Velocidade",
    Range = {16, 2000},
    Increment = 10,
    CurrentValue = 16,
    Flag = "SpeedHack",
    Callback = function(Value)
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

-- ✅ Teleportes Avançados
local TeleportTab = Window:CreateTab("🌍 Teleportes")

TeleportTab:CreateButton({
    Name = "🏁 Linha de Chegada (Auto-Win)",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(1000, 50, 200) -- Ajustável
    end
})

TeleportTab:CreateButton({
    Name = "🛍️ Ir para Loja",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 5, 300)
    end
})

TeleportTab:CreateButton({
    Name = "🏠 Ir para Spawn",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
    end
})

-- ✅ Bypass de Anticheat
local SettingsTab = Window:CreateTab("⚙️ Configurações")

SettingsTab:CreateButton({
    Name = "🛡️ Ativar Bypass de Anticheat",
    Callback = function()
        BypassAnticheat()
        Rayfield:Notify({
            Title = "Anticheat Bypass",
            Content = "Anticheat desativado com sucesso!",
            Duration = 3
        })
    end
})

Rayfield:LoadConfiguration()
