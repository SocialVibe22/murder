-- Murder Mystery 2 Ultimate Script
-- Created by Master

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Load Nova UI Library
local Nova = loadstring(game:HttpGet("https://raw.githubusercontent.com/SocialVibe22/NovaUIlibrary/refs/heads/main/NovaUIlibrary.lua"))()

-- Initialize Nova UI with enhanced design
local Window = Nova:Init({
    Name = "Murder Mystery 2 Ultimate",
    Size = Vector2.new(650, 450),
    Color = Color3.fromRGB(45, 45, 65),
    Blur = true,
    Title = "MM2 Ultimate",
    SubTitle = "by Master",
    ButtonColor = Color3.fromRGB(60, 60, 80),
    AccentColor = Color3.fromRGB(100, 100, 255),
    TextColor = Color3.fromRGB(240, 240, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Animation = true,
    AnimationSpeed = 0.5,
    Draggable = true
})

-- Enhanced Systems
local Systems = {
    Roles = {
        enabled = false,
        murderer = nil,
        sheriff = nil,
        innocent = {},
        lastUpdate = 0,
        espColor = {
            murderer = Color3.fromRGB(255, 0, 0),
            sheriff = Color3.fromRGB(0, 0, 255),
            innocent = Color3.fromRGB(0, 255, 0)
        },
        espSettings = {
            showDistance = true,
            showHealth = true,
            showBoxes = true,
            showTracers = true,
            rainbow = false
        }
    },
    
    Combat = {
        silentAim = {
            enabled = false,
            showFOV = false,
            fovSize = 400,
            fovColor = Color3.fromRGB(255, 0, 0),
            hitChance = 100,
            prediction = 0.165,
            targetPart = "Head",
            smoothness = 0.5,
            visibilityCheck = true,
            teamCheck = true
        },
        autoShoot = {
            enabled = false,
            targetMurderer = true,
            targetSheriff = false,
            targetInnocent = false,
            range = 15,
            delay = 0.1
        },
        killAura = {
            enabled = false,
            range = 10,
            hitDelay = 0.1,
            targetAll = false
        }
    },
    
    Movement = {
        speed = {
            enabled = false,
            value = 16,
            boost = 1.5
        },
        jump = {
            enabled = false,
            power = 50,
            infinite = false,
            bunnyHop = false
        },
        flight = {
            enabled = false,
            speed = 50,
            mode = "Default", -- Default, Glide, Float
            noclip = false
        }
    },
    
    Visuals = {
        esp = {
            enabled = false,
            players = true,
            items = true,
            coins = true,
            boxes = true,
            tracers = true,
            names = true,
            distance = true,
            health = true,
            chams = false
        },
        world = {
            fullbright = false,
            noFog = false,
            customSky = false,
            customTime = false,
            rainbowMode = false,
            xray = false
        },
        effects = {
            bulletTracers = false,
            hitMarkers = false,
            killEffects = false
        }
    },
    
    Farming = {
        coins = {
            enabled = false,
            magnet = false,
            radius = 50,
            teleport = false,
            autoCollect = false
        },
        xp = {
            enabled = false,
            method = "Rounds", -- Rounds, Kills, Survival
            autoFarm = false
        }
    },
    
    Settings = {
        interface = {
            visible = true,
            theme = "Default",
            transparency = 0,
            blur = true
        },
        performance = {
            quality = "High",
            renderDistance = 1000,
            shadows = true
        },
        sounds = {
            enabled = true,
            volume = 0.5,
            hitMarker = true,
            killSound = true
        }
    }
}

-- Create Enhanced Tabs
local MainTab = Window:CreateTab("Main", "rbxassetid://7733674079")
local CombatTab = Window:CreateTab("Combat", "rbxassetid://7743878358")
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://7734042071")
local MovementTab = Window:CreateTab("Movement", "rbxassetid://7743875962")
local TeleportsTab = Window:CreateTab("Teleport", "rbxassetid://7733920644")
local FarmingTab = Window:CreateTab("Farming", "rbxassetid://7734042071")
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://7734042071")

[Rest of the enhanced code continues with all features...]

-- Add toggle functionality with E key
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.E then
        Systems.Settings.interface.visible = not Systems.Settings.interface.visible
        Window:Toggle(Systems.Settings.interface.visible)
        
        -- Enhanced toggle effect
        if Systems.Settings.sounds.enabled then
            local sound = Instance.new("Sound")
            sound.SoundId = Systems.Settings.interface.visible and "rbxassetid://6895079853" or "rbxassetid://6895079725"
            sound.Volume = Systems.Settings.sounds.volume
            sound.Parent = game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 1)
        end
        
        -- Visual feedback
        local notification = Window:CreateNotification({
            Title = Systems.Settings.interface.visible and "Interface Enabled" or "Interface Hidden",
            Content = Systems.Settings.interface.visible and "Press E to hide interface" or "Press E to show interface",
            Time = 2,
            Type = "Info"
        })
        
        -- Animate notification
        TweenService:Create(notification, TweenInfo.new(0.5), {
            Position = UDim2.new(1, -310, 1, -90)
        }):Play()
    end
end)
