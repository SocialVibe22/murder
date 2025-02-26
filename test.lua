local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "🔪 Murder Mystery 2 Pro",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MM2ProConfig",
    IntroEnabled = true,
    IntroText = "Murder Mystery 2 Pro",
    IntroIcon = "rbxassetid://7733955740",
    Icon = "rbxassetid://7733955740"
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Role Detection System
local RoleSystem = {
    murderer = nil,
    sheriff = nil,
    innocent = {},
    lastUpdate = 0,
    enabled = false
}

-- Advanced Role ESP System
local function createAdvancedESP(plr, role)
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

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://7733674079",
    PremiumOnly = false
})

-- Role Detection Section
local RoleSection = MainTab:AddSection({
    Name = "🎭 Role Detection"
})

RoleSection:AddToggle({
    Name = "Enable Role ESP",
    Default = false,
    Flag = "RoleESPEnabled",
    Save = true,
    Callback = function(Value)
        RoleSystem.enabled = Value
        
        if Value then
            -- Initial ESP Setup
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local role = "Innocent"
                    if plr.Character then
                        if plr.Character:FindFirstChild("Knife") then
                            role = "Murderer"
                        elseif plr.Character:FindFirstChild("Gun") then
                            role = "Sheriff"
                        end
                    end
                    createAdvancedESP(plr, role)
                end
            end
            
            -- Update ESP
            RunService:BindToRenderStep("RoleESP", 1, function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local role = "Innocent"
                        if plr.Character:FindFirstChild("Knife") then
                            role = "Murderer"
                        elseif plr.Character:FindFirstChild("Gun") then
                            role = "Sheriff"
                        end
                        createAdvancedESP(plr, role)
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

-- Combat Section
local CombatSection = MainTab:AddSection({
    Name = "⚔️ Combat"
})

-- Advanced Silent Aim
local SilentAim = {
    enabled = false,
    showFOV = false,
    fovSize = 400,
    targetPart = "Head",
    prediction = 0.165
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
fovCircle.Color = Color3.fromRGB(255, 255, 255)

CombatSection:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Flag = "SilentAimEnabled",
    Save = true,
    Callback = function(Value)
        SilentAim.enabled = Value
        fovCircle.Visible = Value and SilentAim.showFOV

        if Value then
            RunService:BindToRenderStep("SilentAim", 1, function()
                fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
                
                local closestPlayer = nil
                local shortestDistance = math.huge
                
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild(SilentAim.targetPart) then
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
                
                if closestPlayer then
                    local targetPart = closestPlayer.Character[SilentAim.targetPart]
                    local predictedPos = targetPart.Position + (targetPart.Velocity * SilentAim.prediction)
                    
                    -- Visual feedback with proper attachment parenting
                    local beam = Instance.new("Beam")
                    beam.Transparency = NumberSequence.new(0.5)
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                    beam.FaceCamera = true
                    beam.Width0 = 0.1
                    beam.Width1 = 0.1
                    beam.Parent = workspace
                    
                    local attachment1 = Instance.new("Attachment")
                    attachment1.Parent = workspace.Terrain
                    attachment1.WorldPosition = camera.CFrame.Position
                    
                    local attachment2 = Instance.new("Attachment")
                    attachment2.Parent = workspace.Terrain
                    attachment2.WorldPosition = predictedPos
                    
                    beam.Attachment0 = attachment1
                    beam.Attachment1 = attachment2
                    
                    game:GetService("Debris"):AddItem(beam, 0.1)
                    game:GetService("Debris"):AddItem(attachment1, 0.1)
                    game:GetService("Debris"):AddItem(attachment2, 0.1)
                end
            end)
        else
            RunService:UnbindFromRenderStep("SilentAim")
        end
    end
})

CombatSection:AddToggle({
    Name = "Show FOV",
    Default = false,
    Flag = "ShowFOV",
    Save = true,
    Callback = function(Value)
        SilentAim.showFOV = Value
        fovCircle.Visible = SilentAim.enabled and Value
    end
})

CombatSection:AddSlider({
    Name = "FOV Size",
    Min = 50,
    Max = 800,
    Default = 400,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 10,
    ValueName = "pixels",
    Flag = "FOVSize",
    Save = true,
    Callback = function(Value)
        SilentAim.fovSize = Value
        fovCircle.Radius = Value
    end    
})

-- Item ESP Section
local ESPSection = MainTab:AddSection({
    Name = "👁️ ESP Features"
})

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

ESPSection:AddToggle({
    Name = "Gun ESP",
    Default = false,
    Flag = "GunESP",
    Save = true,
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

ESPSection:AddToggle({
    Name = "Knife ESP",
    Default = false,
    Flag = "KnifeESP",
    Save = true,
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

-- Player Modifications Section
local PlayerSection = MainTab:AddSection({
    Name = "👤 Player Mods"
})

PlayerSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "speed",
    Flag = "WalkSpeed",
    Save = true,
    Callback = function(Value)
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end    
})

PlayerSection:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "power",
    Flag = "JumpPower",
    Save = true,
    Callback = function(Value)
        if humanoid then
            humanoid.JumpPower = Value
        end
    end    
})

PlayerSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "InfiniteJump",
    Save = true,
    Callback = function(Value)
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if Value then
                humanoid:ChangeState("Jumping")
            end
        end)
    end
})

-- Teleport Section
local TeleportSection = MainTab:AddSection({
    Name = "🌟 Teleports"
})

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

TeleportSection:AddButton({
    Name = "Teleport to Safe Spot",
    Callback = function()
        local map = getCurrentMap()
        if map then
            local safeSpot = findSafeSpot(map)
            if safeSpot then
                local targetCFrame = safeSpot.CFrame + Vector3.new(0, 5, 0)
                
                -- Smooth teleport
                local tweenInfo = TweenInfo.new(
                    1,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                
                local tween = TweenService:Create(rootPart, tweenInfo, {
                    CFrame = targetCFrame
                })
                
                tween:Play()
                
                OrionLib:MakeNotification({
                    Name = "Teleported",
                    Content = "Successfully teleported to safe spot",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
            end
        end
    end
})

-- Coin Section
local CoinSection = MainTab:AddSection({
    Name = "💰 Coins"
})

CoinSection:AddToggle({
    Name = "Auto Collect Coins",
    Default = false,
    Flag = "AutoCoins",
    Save = true,
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

CoinSection:AddToggle({
    Name = "Coin ESP",
    Default = false,
    Flag = "CoinESP",
    Save = true,
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

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Restore settings
    if OrionLib.Flags.WalkSpeed then
        humanoid.WalkSpeed = OrionLib.Flags.WalkSpeed.Value
    end
    if OrionLib.Flags.JumpPower then
        humanoid.JumpPower = OrionLib.Flags.JumpPower.Value
    end
end)

-- Initial notification
OrionLib:MakeNotification({
    Name = "Script Loaded",
    Content = "Murder Mystery 2 Pro has been loaded!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()
