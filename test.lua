-- Murder Mystery 2 Script using Nova UI Library
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

-- Initialize Nova UI
local Window = Nova:Init({
    Name = "Murder Mystery 2",
    Size = Vector2.new(650, 450),
    Color = Color3.fromRGB(45, 45, 65)
})

-- Role Detection System
local RoleSystem = {
    murderer = nil,
    sheriff = nil,
    innocent = {},
    lastUpdate = 0,
    enabled = false
}

-- Silent Aim System
local SilentAim = {
    enabled = false,
    showFOV = false,
    fovSize = 400,
    targetPart = "Head",
    prediction = 0.165,
    targetMurderer = true,
    targetSheriff = false,
    targetInnocent = false
}

-- Create FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = SilentAim.fovSize
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.ZIndex = 999
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(255, 0, 0)

-- Functions
local function createRoleESP(plr, role)
    if not plr or not plr.Character then return end
    
    -- Remove existing ESP
    for _, item in ipairs(plr.Character:GetChildren()) do
        if item.Name:match("^RoleESP") then
            item:Destroy()
        end
    end
    
    -- Create ESP Container
    local espContainer = Instance.new("BillboardGui")
    espContainer.Name = "RoleESP_Main"
    espContainer.Size = UDim2.new(0, 200, 0, 50)
    espContainer.StudsOffset = Vector3.new(0, 3, 0)
    espContainer.AlwaysOnTop = true
    espContainer.Parent = plr.Character

    -- Create Background Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                            role == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                            Color3.fromRGB(0, 255, 0)
    frame.Parent = espContainer

    -- Add Corner Radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Create Name Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = frame

    -- Create Role Label
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = role
    roleLabel.TextColor3 = Color3.new(1, 1, 1)
    roleLabel.TextSize = 12
    roleLabel.Font = Enum.Font.GothamSemibold
    roleLabel.Parent = frame

    -- Add Highlight Effect
    local highlight = Instance.new("Highlight")
    highlight.Name = "RoleESP_Highlight"
    highlight.FillColor = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                         role == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                         Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = plr.Character

    -- Add Distance Counter
    spawn(function()
        while plr.Character and espContainer.Parent do
            local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            roleLabel.Text = string.format("%s [%d studs]", role, distance)
            wait(0.1)
        end
    end)

    -- Add Tracer Line
    local tracer = Drawing.new("Line")
    tracer.Visible = true
    tracer.Color = frame.BackgroundColor3
    tracer.Thickness = 1
    tracer.Transparency = 1

    RunService:BindToRenderStep("Tracer_" .. plr.Name, 1, function()
        if not plr.Character or not player.Character then
            tracer.Visible = false
            return
        end

        local vector, onScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
        if onScreen then
            tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
            tracer.To = Vector2.new(vector.X, vector.Y)
            tracer.Visible = true
        else
            tracer.Visible = false
        end
    end)
end

local function createItemESP(item, config)
    local esp = Instance.new("BillboardGui")
    esp.Name = "ItemESP"
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.AlwaysOnTop = true
    esp.Parent = item

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = config.color
    frame.Parent = esp

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = config.name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = frame

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextSize = 12
    distanceLabel.Font = Enum.Font.GothamSemibold
    distanceLabel.Parent = frame

    -- Add Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = config.color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = item

    -- Update distance using a unique identifier
    local uniqueId = tostring(item:GetFullName())
    RunService:BindToRenderStep("UpdateDistance_" .. uniqueId, 1, function()
        if not item.Parent then
            RunService:UnbindFromRenderStep("UpdateDistance_" .. uniqueId)
            return
        end
        local distance = (item.Position - player.Character.HumanoidRootPart.Position).Magnitude
        distanceLabel.Text = string.format("%.1f studs", distance)
    end)
end

local function detectRoles()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if plr.Character:FindFirstChild("Knife") then
                RoleSystem.murderer = plr
            elseif plr.Character:FindFirstChild("Gun") then
                RoleSystem.sheriff = plr
            else
                table.insert(RoleSystem.innocent, plr)
            end
        end
    end
end

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild(SilentAim.targetPart) then
            local role = "Innocent"
            if plr.Character:FindFirstChild("Knife") then
                role = "Murderer"
            elseif plr.Character:FindFirstChild("Gun") then
                role = "Sheriff"
            end
            
            if (role == "Murderer" and SilentAim.targetMurderer) or
               (role == "Sheriff" and SilentAim.targetSheriff) or
               (role == "Innocent" and SilentAim.targetInnocent) then
                
                local targetPart = plr.Character[SilentAim.targetPart]
                local pos = camera:WorldToViewportPoint(targetPart.Position)
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                
                if distance < SilentAim.fovSize then
                    local ray = Ray.new(camera.CFrame.Position, targetPart.Position - camera.CFrame.Position)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {character, targetPart.Parent})
                    
                    if not hit then
                        if distance < shortestDistance then
                            closestPlayer = plr
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function getCurrentMap()
    local maps = workspace:FindFirstChild("Maps")
    if not maps then return nil end
    
    for _, map in pairs(maps:GetChildren()) do
        if map:IsA("Model") and map.Parent.Name == "Maps" then
            local spawns = map:FindFirstChild("SpawnPoints")
            if spawns then
                return map
            end
        end
    end
    return nil
end

local function findSafeSpot(map)
    if not map then return nil end
    
    local spawns = map:FindFirstChild("SpawnPoints")
    if spawns and #spawns:GetChildren() > 0 then
        return spawns:GetChildren()[1]
    end
    
    local safeSpots = map:FindFirstChild("PlayerSpawn")
    if safeSpots then
        return safeSpots
    end
    
    return map:FindFirstChild("Lobby") or map.PrimaryPart
end

-- Create Tabs
local MainTab = Window:CreateTab("Main", "rbxassetid://7733674079")
local CombatTab = Window:CreateTab("Combat", "rbxassetid://7743878358")
local ESPTab = Window:CreateTab("ESP", "rbxassetid://7734042071")
local PlayerTab = Window:CreateTab("Player", "rbxassetid://7743875962")
local TeleportTab = Window:CreateTab("Teleport", "rbxassetid://7733920644")
local MiscTab = Window:CreateTab("Misc", "rbxassetid://7734042071")

-- Main Tab
local RoleSection = MainTab:CreateSection("Role Detection")

local RoleESPToggle = RoleSection:AddToggle({
    Name = "Enable Role ESP",
    Default = false,
    Callback = function(Value)
        RoleSystem.enabled = Value
        
        if Value then
            detectRoles()
            
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local role = "Innocent"
                    if plr == RoleSystem.murderer then
                        role = "Murderer"
                    elseif plr == RoleSystem.sheriff then
                        role = "Sheriff"
                    end
                    createRoleESP(plr, role)
                end
            end
            
            RunService:BindToRenderStep("RoleESP", 1, function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local role = "Innocent"
                        if plr.Character:FindFirstChild("Knife") then
                            role = "Murderer"
                            RoleSystem.murderer = plr
                        elseif plr.Character:FindFirstChild("Gun") then
                            role = "Sheriff"
                            RoleSystem.sheriff = plr
                        end
                        createRoleESP(plr, role)
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("RoleESP")
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, item in pairs(plr.Character:GetChildren()) do
                        if item.Name:match("^RoleESP") then
                            item:Destroy()
                        end
                    end
                end
            end
        end
    end
})

local DetectRolesButton = RoleSection:AddButton({
    Name = "Detect Roles",
    Callback = function()
        detectRoles()
        
        -- Create notification
        local notification = Instance.new("Frame")
        notification.Name = "Notification"
        notification.Size = UDim2.new(0, 300, 0, 100)
        notification.Position = UDim2.new(0.5, -150, 0.8, -50)
        notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        notification.BorderSizePixel = 0
        notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = notification
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.Text = "Roles Detected"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 18
        title.Font = Enum.Font.GothamBold
        title.Parent = notification
        
        local content = Instance.new("TextLabel")
        content.Size = UDim2.new(1, 0, 1, -30)
        content.Position = UDim2.new(0, 0, 0, 30)
        content.BackgroundTransparency = 1
        content.Text = "Murderer: " .. (RoleSystem.murderer and RoleSystem.murderer.Name or "Unknown") .. "\nSheriff: " .. (RoleSystem.sheriff and RoleSystem.sheriff.Name or "Unknown")
        content.TextColor3 = Color3.fromRGB(200, 200, 200)
        content.TextSize = 14
        content.Font = Enum.Font.Gotham
        content.Parent = notification
        
        -- Animate notification
        notification.Position = UDim2.new(0.5, -150, 1.1, -50)
        TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -150, 0.8, -50)
        }):Play()
        
        -- Remove notification after 5 seconds
        spawn(function()
            wait(5)
            TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -150, 1.1, -50)
            }):Play()
            wait(0.5)
            notification:Destroy()
        end)
    end
})

-- Combat Tab
local SilentAimSection = CombatTab:CreateSection("Silent Aim")

local SilentAimToggle = SilentAimSection:AddToggle({
    Name = "Enable Silent Aim",
    Default = false,
    Callback = function(Value)
        SilentAim.enabled = Value
        fovCircle.Visible = Value and SilentAim.showFOV

        if Value then
            RunService:BindToRenderStep("SilentAim", 1, function()
                fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                
                local closestPlayer = getClosestPlayerToMouse()
                
                if closestPlayer then
                    local targetPart = closestPlayer.Character[SilentAim.targetPart]
                    local predictedPos = targetPart.Position + (targetPart.Velocity * SilentAim.prediction)
                    
                    local beam = Instance.new("Beam")
                    beam.Transparency = NumberSequence.new(0.5)
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                    beam.FaceCamera = true
                    beam.Width0 = 0.1
                    beam.Width1 = 0.1
                    beam.Parent = workspace
                    
                    local attachment1 = Instance.new("Attachment")
                    attachment1.Parent = workspace.Terrain
                    
                    local attachment2 = Instance.new("Attachment")
                    attachment2.WorldPosition = predictedPos
                    attachment2.Parent = workspace.Terrain
                    
                    beam.Attachment0 = attachment1
                    beam.Attachment1 = attachment2
                    
                    game:GetService("Debris"):AddItem(beam, 0.05)
                    game:GetService("Debris"):AddItem(attachment1, 0.05)
                    game:GetService("Debris"):AddItem(attachment2, 0.05)
                end
            end)
            
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                
                if method == "FireServer" and self.Name == "ShootGun" and SilentAim.enabled then
                    local closestPlayer = getClosestPlayerToMouse()
                    if closestPlayer then
                        local targetPart = closestPlayer.Character[SilentAim.targetPart]
                        args[1] = targetPart.Position + (targetPart.Velocity * SilentAim.prediction)
                    end
                end
                
                return oldNamecall(self, unpack(args))
            end)
        else
            RunService:UnbindFromRenderStep("SilentAim")
        end
    end
})

local ShowFOVToggle = SilentAimSection:AddToggle({
    Name = "Show FOV",
    Default = false,
    Callback = function(Value)
        SilentAim.showFOV = Value
        fovCircle.Visible = SilentAim.enabled and Value
    end
})

local FOVSizeSlider = SilentAimSection:AddSlider({
    Name = "FOV Size",
    Min = 50,
    Max = 800,
    Default = 400,
    Increment = 10,
    Callback = function(Value)
        SilentAim.fovSize = Value
        fovCircle.Radius = Value
    end
})

local PredictionSlider = SilentAimSection:AddSlider({
    Name = "Prediction",
    Min = 0.1,
    Max = 0.3,
    Default = 0.165,
    Increment = 0.005,
    Callback = function(Value)
        SilentAim.prediction = Value
    end
})

local TargetSection = CombatTab:CreateSection("Target Selection")

local TargetMurdererToggle = TargetSection:AddToggle({
    Name = "Target Murderer",
    Default = true,
    Callback = function(Value)
        SilentAim.targetMurderer = Value
    end
})

local TargetSheriffToggle = TargetSection:AddToggle({
    Name = "Target Sheriff",
    Default = false,
    Callback = function(Value)
        SilentAim.targetSheriff = Value
    end
})

local TargetInnocentToggle = TargetSection:AddToggle({
    Name = "Target Innocent",
    Default = false,
    Callback = function(Value)
        SilentAim.targetInnocent = Value
    end
})

local AutoKillSection = CombatTab:CreateSection("Auto Kill")

local AutoKillMurdererToggle = AutoKillSection:AddToggle({
    Name = "Auto Kill Murderer",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("AutoKillMurderer", 1, function()
                if RoleSystem.murderer and player.Character:FindFirstChild("Gun") then
                    local targetPart = RoleSystem.murderer.Character:FindFirstChild("Head")
                    if targetPart then
                        local args = {
                            [1] = targetPart.Position
                        }
                        ReplicatedStorage.ShootGun:FireServer(unpack(args))
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoKillMurderer")
        end
    end
})

-- ESP Tab
local ItemESPSection = ESPTab:CreateSection("Item ESP")

local GunESPToggle = ItemESPSection:AddToggle({
    Name = "Gun ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("GunESP", 1, function()
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("Tool") and item.Name == "Gun" then
                        if not item:FindFirstChild("ItemESP") then
                            createItemESP(item, {
                                name = "Gun",
                                color = Color3.fromRGB(0, 0, 255)
                            })
                        end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("GunESP")
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Tool") and item.Name == "Gun" then
                    local esp = item:FindFirstChild("ItemESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
})

local KnifeESPToggle = ItemESPSection:AddToggle({
    Name = "Knife ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("KnifeESP", 1, function()
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("Tool") and item.Name == "Knife" then
                        if not item:FindFirstChild("ItemESP") then
                            createItemESP(item, {
                                name = "Knife",
                                color = Color3.fromRGB(255, 0, 0)
                            })
                        end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("KnifeESP")
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("Tool") and item.Name == "Knife" then
                    local esp = item:FindFirstChild("ItemESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
})

local CoinESPToggle = ItemESPSection:AddToggle({
    Name = "Coin ESP",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("CoinESP", 1, function()
                for _, coin in pairs(workspace:GetDescendants()) do
                    if coin.Name == "Coin" or coin.Name == "CoinContainer" then
                        if not coin:FindFirstChild("ItemESP") then
                            createItemESP(coin, {
                                name = "Coin",
                                color = Color3.fromRGB(255, 215, 0)
                            })
                        end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("CoinESP")
            for _, coin in pairs(workspace:GetDescendants()) do
                if coin.Name == "Coin" or coin.Name == "CoinContainer" then
                    local esp = coin:FindFirstChild("ItemESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
})

local XRaySection = ESPTab:CreateSection("X-Ray")

local XRayToggle = XRaySection:AddToggle({
    Name = "X-Ray Vision",
    Default = false,
    Callback = function(Value)
        if Value then
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(player.Character) then
                    if part.Transparency < 1 then
                        part.Transparency = 0.8
                    end
                end
            end
        else
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(player.Character) then
                    if part.Transparency == 0.8 then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
})

-- Player Tab
local MovementSection = PlayerTab:CreateSection("Movement")

local WalkSpeedSlider = MovementSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Callback = function(Value)
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

local JumpPowerSlider = MovementSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 1,
    Callback = function(Value)
        if humanoid then
            humanoid.JumpPower = Value
        end
    end
})

local InfiniteJumpToggle = MovementSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        UserInputService.JumpRequest:Connect(function()
            if Value and humanoid then
                humanoid:ChangeState("Jumping")
            end
        end)
    end
})

local NoclipToggle = MovementSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("Noclip", 1, function()
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("Noclip")
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

local CharacterSection = PlayerTab:CreateSection("Character")

local GodModeToggle = CharacterSection:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        if Value then
            local clone = character:Clone()
            clone.Parent = workspace
            player.Character = clone
            wait(0.1)
            character.Parent = nil
            
            -- Create notification
            local notification = Instance.new("Frame")
            notification.Name = "Notification"
            notification.Size = UDim2.new(0, 300, 0, 100)
            notification.Position = UDim2.new(0.5, -150, 0.8, -50)
            notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            notification.BorderSizePixel = 0
            notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = notification
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 30)
            title.BackgroundTransparency = 1
            title.Text = "God Mode"
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextSize = 18
            title.Font = Enum.Font.GothamBold
            title.Parent = notification
            
            local content = Instance.new("TextLabel")
            content.Size = UDim2.new(1, 0, 1, -30)
            content.Position = UDim2.new(0, 0, 0, 30)
            content.BackgroundTransparency = 1
            content.Text = "You are now in god mode. You are invisible to other players."
            content.TextColor3 = Color3.fromRGB(200, 200, 200)
            content.TextSize = 14
            content.Font = Enum.Font.Gotham
            content.Parent = notification
            
            -- Animate notification
            notification.Position = UDim2.new(0.5, -150, 1.1, -50)
            TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -150, 0.8, -50)
            }):Play()
            
            -- Remove notification after 5 seconds
            spawn(function()
                wait(5)
                TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -150, 1.1, -50)
                }):Play()
                wait(0.5)
                notification:Destroy()
            end)
        else
            character.Parent = workspace
            player.Character = character
            
            if clone then
                clone:Destroy()
            end
        end
    end
})

-- Teleport Tab
local MapTeleportSection = TeleportTab:CreateSection("Map Teleports")

local SafeSpotButton = MapTeleportSection:AddButton({
    Name = "Teleport to Safe Spot",
    Callback = function()
        local map = getCurrentMap()
        if map then
            local safeSpot = findSafeSpot(map)
            if safeSpot then
                local targetCFrame = safeSpot.CFrame + Vector3.new(0, 5, 0)
                
                local tweenInfo = TweenInfo.new(
                    1,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                local tween = TweenService:Create(rootPart, tweenInfo, {
                    CFrame = targetCFrame
                })
                
                tween:Play()
                
                -- Create notification
                local notification = Instance.new("Frame")
                notification.Name = "Notification"
                notification.Size = UDim2.new(0, 300, 0, 100)
                notification.Position = UDim2.new(0.5, -150, 0.8, -50)
                notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                notification.BorderSizePixel = 0
                notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = notification
                
                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0, 30)
                title.BackgroundTransparency = 1
                title.Text = "Teleported"
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextSize = 18
                title.Font = Enum.Font.GothamBold
                title.Parent = notification
                
                local content = Instance.new("TextLabel")
                content.Size = UDim2.new(1, 0, 1, -30)
                content.Position = UDim2.new(0, 0, 0, 30)
                content.BackgroundTransparency = 1
                content.Text = "Successfully teleported to safe spot"
                content.TextColor3 = Color3.fromRGB(200, 200, 200)
                content.TextSize = 14
                content.Font = Enum.Font.Gotham
                content.Parent = notification
                
                -- Animate notification
                notification.Position = UDim2.new(0.5, -150, 1.1, -50)
                TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -150, 0.8, -50)
                }):Play()
                
                -- Remove notification after 5 seconds
                spawn(function()
                    wait(5)
                    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -150, 1.1, -50)
                    }):Play()
                    wait(0.5)
                    notification:Destroy()
                end)
            end
        end
    end
})

local TeleportToMurdererButton = MapTeleportSection:AddButton({
    Name = "Teleport to Murderer",
    Callback = function()
        if RoleSystem.murderer and RoleSystem.murderer.Character then
            local targetRoot = RoleSystem.murderer.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local targetCFrame = targetRoot.CFrame + Vector3.new(0, 0, 3)
                
                local tweenInfo = TweenInfo.new(
                    1,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                local tween = TweenService:Create(rootPart, tweenInfo, {
                    CFrame = targetCFrame
                })
                
                tween:Play()
                
                -- Create notification
                local notification = Instance.new("Frame")
                notification.Name = "Notification"
                notification.Size = UDim2.new(0, 300, 0, 100)
                notification.Position = UDim2.new(0.5, -150, 0.8, -50)
                notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                notification.BorderSizePixel = 0
                notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = notification
                
                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0, 30)
                title.BackgroundTransparency = 1
                title.Text = "Teleported"
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextSize = 18
                title.Font = Enum.Font.GothamBold
                title.Parent = notification
                
                local content = Instance.new("TextLabel")
                content.Size = UDim2.new(1, 0, 1, -30)
                content.Position = UDim2.new(0, 0, 0, 30)
                content.BackgroundTransparency = 1
                content.Text = "Successfully teleported to murderer"
                content.TextColor3 = Color3.fromRGB(200, 200, 200)
                content.TextSize = 14
                content.Font = Enum.Font.Gotham
                content.Parent = notification
                
                -- Animate notification
                notification.Position = UDim2.new(0.5, -150, 1.1, -50)
                TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -150, 0.8, -50)
                }):Play()
                
                -- Remove notification after 5 seconds
                spawn(function()
                    wait(5)
                    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -150, 1.1, -50)
                    }):Play()
                    wait(0.5)
                    notification:Destroy()
                end)
            end
        else
            -- Create error notification
            local notification = Instance.new("Frame")
            notification.Name = "Notification"
            notification.Size = UDim2.new(0, 300, 0, 100)
            notification.Position = UDim2.new(0.5, -150, 0.8, -50)
            notification.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
            notification.BorderSizePixel = 0
            notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = notification
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 30)
            title.BackgroundTransparency = 1
            title.Text = "Error"
            title.TextColor3 = Color3.fromRGB(255, 100, 100)
            title.TextSize = 18
            title.Font = Enum.Font.GothamBold
            title.Parent = notification
            
            local content = Instance.new("TextLabel")
            content.Size = UDim2.new(1, 0, 1, -30)
            content.Position = UDim2.new(0, 0, 0, 30)
            content.BackgroundTransparency = 1
            content.Text = "Murderer not found"
            content.TextColor3 = Color3.fromRGB(200, 200, 200)
            content.TextSize = 14
            content.Font = Enum.Font.Gotham
            content.Parent = notification
            
            -- Animate notification
            notification.Position = UDim2.new(0.5, -150, 1.1, -50)
            TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -150, 0.8, -50)
            }):Play()
            
            -- Remove notification after 5 seconds
            spawn(function()
                wait(5)
                TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -150, 1.1, -50)
                }):Play()
                wait(0.5)
                notification:Destroy()
            end)
        end
    end
})

local TeleportToSheriffButton = MapTeleportSection:AddButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        if RoleSystem.sheriff and RoleSystem.sheriff.Character then
            local targetRoot = RoleSystem.sheriff.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local targetCFrame = targetRoot.CFrame + Vector3.new(0, 0, 3)
                
                local tweenInfo = TweenInfo.new(
                    1,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                local tween = TweenService:Create(rootPart, tweenInfo, {
                    CFrame = targetCFrame
                })
                
                tween:Play()
                
                -- Create notification
                local notification = Instance.new("Frame")
                notification.Name = "Notification"
                notification.Size = UDim2.new(0, 300, 0, 100)
                notification.Position = UDim2.new(0.5, -150, 0.8, -50)
                notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                notification.BorderSizePixel = 0
                notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = notification
                
                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, 0, 0, 30)
                title.BackgroundTransparency = 1
                title.Text = "Teleported"
                title.TextColor3 = Color3.fromRGB(255, 255, 255)
                title.TextSize = 18
                title.Font = Enum.Font.GothamBold
                title.Parent = notification
                
                local content = Instance.new("TextLabel")
                content.Size = UDim2.new(1, 0, 1, -30)
                content.Position = UDim2.new(0, 0, 0, 30)
                content.BackgroundTransparency = 1
                content.Text = "Successfully teleported to sheriff"
                content.TextColor3 = Color3.fromRGB(200, 200, 200)
                content.TextSize = 14
                content.Font = Enum.Font.Gotham
                content.Parent = notification
                
                -- Animate notification
                notification.Position = UDim2.new(0.5, -150, 1.1, -50)
                TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -150, 0.8, -50)
                }):Play()
                
                -- Remove notification after 5 seconds
                spawn(function()
                    wait(5)
                    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -150, 1.1, -50)
                    }):Play()
                    wait(0.5)
                    notification:Destroy()
                end)
            end
        else
            -- Create error notification
            local notification = Instance.new("Frame")
            notification.Name = "Notification"
            notification.Size = UDim2.new(0, 300, 0, 100)
            notification.Position = UDim2.new(0.5, -150, 0.8, -50)
            notification.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
            notification.BorderSizePixel = 0
            notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 10)
            corner.Parent = notification
            
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 30)
            title.BackgroundTransparency = 1
            title.Text = "Error"
            title.TextColor3 = Color3.fromRGB(255, 100, 100)
            title.TextSize = 18
            title.Font = Enum.Font.GothamBold
            title.Parent = notification
            
            local content = Instance.new("TextLabel")
            content.Size = UDim2.new(1, 0, 1, -30)
            content.Position = UDim2.new(0, 0, 0, 30)
            content.BackgroundTransparency = 1
            content.Text = "Sheriff not found"
            content.TextColor3 = Color3.fromRGB(200, 200, 200)
            content.TextSize = 14
            content.Font = Enum.Font.Gotham
            content.Parent = notification
            
            -- Animate notification
            notification.Position = UDim2.new(0.5, -150, 1.1, -50)
            TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -150, 0.8, -50)
            }):Play()
            
            -- Remove notification after 5 seconds
            spawn(function()
                wait(5)
                TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(0.5, -150, 1.1, -50)
                }):Play()
                wait(0.5)
                notification:Destroy()
            end)
        end
    end
})

-- Misc Tab
local CoinsSection = MiscTab:CreateSection("Coins")

local AutoCoinsToggle = CoinsSection:AddToggle({
    Name = "Auto Collect Coins",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("AutoCoins", 1, function()
                for _, coin in pairs(workspace:GetDescendants()) do
                    if coin.Name == "Coin" or coin.Name == "CoinContainer" then
                        coin.CFrame = rootPart.CFrame
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("AutoCoins")
        end
    end
})

local VisualEffectsSection = MiscTab:CreateSection("Visual Effects")

local FullBrightToggle = VisualEffectsSection:AddToggle({
    Name = "Full Bright",
    Default = false,
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
})

local RainbowCharToggle = VisualEffectsSection:AddToggle({
    Name = "Rainbow Character",
    Default = false,
    Callback = function(Value)
        if Value then
            RunService:BindToRenderStep("RainbowCharacter", 1, function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromHSV(tick() % 1, 1, 1)
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("RainbowCharacter")
        end
    end
})

local AntiCheatSection = MiscTab:CreateSection("Anti-Cheat")

local AntiBanToggle = AntiCheatSection:AddToggle({
    Name = "Anti-Ban",
    Default = true,
    Callback = function(Value)
        if Value then
            local mt = getrawmetatable(game)
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "FireServer" and self.Name == "BanRemote" then
                    return wait(9e9)
                end
                
                return oldNamecall(self, unpack(args))
            end)
            
            setreadonly(mt, true)
        end
    end
})

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Restore settings
    if WalkSpeedSlider.Value then
        humanoid.WalkSpeed = WalkSpeedSlider.Value
    end
    
    if JumpPowerSlider.Value then
        humanoid.JumpPower = JumpPowerSlider.Value
    end
    
    if RoleESPToggle.Value then
        RunService:UnbindFromRenderStep("RoleESP")
        detectRoles()
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player then
                local role = "Innocent"
                if plr == RoleSystem.murderer then
                    role = "Murderer"
                elseif plr == RoleSystem.sheriff then
                    role = "Sheriff"
                end
                createRoleESP(plr, role)
            end
        end
    end
})

-- Create initial notification
local notification = Instance.new("Frame")
notification.Name = "Notification"
notification.Size = UDim2.new(0, 300, 0, 100)
notification.Position = UDim2.new(0.5, -150, 0.8, -50)
notification.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
notification.BorderSizePixel = 0
notification.Parent = player.PlayerGui:FindFirstChild("NovaNotifications") or Instance.new("ScreenGui", player.PlayerGui)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = notification

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Script Loaded"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = notification

local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1
content.Text = "Murder Mystery 2 script has been loaded successfully!"
content.TextColor3 = Color3.fromRGB(200, 200, 200)
content.TextSize = 14
content.Font = Enum.Font.Gotham
content.Parent = notification

-- Animate notification
notification.Position = UDim2.new(0.5, -150, 1.1, -50)
TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0.8, -50)
}):Play()

-- Remove notification after 5 seconds
spawn(function()
    wait(5)
    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5, -150, 1.1, -50)
    }):Play()
    wait(0.5)
    notification:Destroy()
end)
