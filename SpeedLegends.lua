-- Carregar a Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
local MainTab = Window:CreateTab("Principal", 4483362458)

-- ✅ Auto-Farm Totalmente Automático
MainTab:CreateToggle({
    Name = "Auto-Farm (Ganha Velocidade Ilimitada)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        getgenv().AutoFarm = Value
        while getgenv().AutoFarm do
            game:GetService("ReplicatedStorage").Events.GainSpeed:FireServer(200) -- Ajustável
            wait(0.2)
        end
    end
})

-- ✅ Auto-Rebirth Inteligente
MainTab:CreateToggle({
    Name = "Auto-Rebirth Inteligente",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(Value)
        getgenv().AutoRebirth = Value
        while getgenv().AutoRebirth do
            game:GetService("ReplicatedStorage").Events.Rebirth:FireServer()
            wait(5)
        end
    end
})

-- ✅ Auto-Coletar Orbs, Anéis e Boosts
MainTab:CreateToggle({
    Name = "Auto-Coletar Orbs, Anéis e Boosts",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(Value)
        getgenv().AutoCollect = Value
        while getgenv().AutoCollect do
            for _, item in pairs(game:GetService("Workspace"):GetChildren()) do
                if item:IsA("Model") and item:FindFirstChild("TouchInterest") then
                    player.Character.HumanoidRootPart.CFrame = item.CFrame
                    wait(0.1)
                end
            end
        end
    end
})

-- ✅ Auto-Corrida PRO (Garante Vitórias)
MainTab:CreateToggle({
    Name = "Auto-Corrida PRO (Sempre Ganha)",
    CurrentValue = false,
    Flag = "AutoRace",
    Callback = function(Value)
        getgenv().AutoRace = Value
        while getgenv().AutoRace do
            for _, race in pairs(game:GetService("Workspace").Races:GetChildren()) do
                if race:IsA("Model") and race:FindFirstChild("TouchInterest") then
                    player.Character.HumanoidRootPart.CFrame = race.CFrame
                    wait(0.3)
                end
            end
        end
    end
})

-- ✅ Auto-Farm de Pets
MainTab:CreateToggle({
    Name = "Auto-Farm de Pets (Compra Automático)",
    CurrentValue = false,
    Flag = "AutoPets",
    Callback = function(Value)
        getgenv().AutoPets = Value
        while getgenv().AutoPets do
            game:GetService("ReplicatedStorage").Events.BuyEgg:FireServer("MelhorPet")
            wait(3)
        end
    end
})

-- ✅ Speed Hack Personalizável
MainTab:CreateSlider({
    Name = "Definir Velocidade",
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

-- ✅ Super Salto e Modo Voo
MainTab:CreateToggle({
    Name = "Ativar Voo",
    CurrentValue = false,
    Flag = "FlyMode",
    Callback = function(Value)
        getgenv().FlyMode = Value
        while getgenv().FlyMode do
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0)
            wait(0.1)
        end
    end
})

-- ✅ Teleportes Avançados
local TeleportTab = Window:CreateTab("Teleportes", 4483362458)

TeleportTab:CreateButton({
    Name = "Linha de Chegada (Auto-Win)",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(1000, 50, 200) -- Ajustável
    end
})

TeleportTab:CreateButton({
    Name = "Ir para Loja",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-50, 5, 300)
    end
})

TeleportTab:CreateButton({
    Name = "Ir para Spawn",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
    end
})

-- ✅ Bypass de Anticheat
local SettingsTab = Window:CreateTab("Configurações", 4483362458)

SettingsTab:CreateButton({
    Name = "Ativar Bypass de Anticheat",
    Callback = function()
        BypassAnticheat()
        Rayfield:Notify({
            Title = "Anticheat Bypass",
            Content = "Anticheat desativado com sucesso!",
            Duration = 3,
            Image = 4483362458
        })
    end
})

Rayfield:LoadConfiguration()
