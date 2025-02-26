local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local SolarisLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/sol"))()

local Window = SolarisLib:New({
    Name = "Murder Mystery 2 Ultimate",
    FolderToSave = "MM2UltimateSave",
    Dark = true
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

local RoleSystem = {
    murderer = nil,
    sheriff = nil,
    innocent = {},
    lastUpdate = 0,
    enabled = false
}

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

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Radius = SilentAim.fovSize
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.ZIndex = 999
fovCircle.Transparency = 1
fovCircle.Color = Color3.fromRGB(255, 0, 0)

local function createRoleESP(plr, role)
    if not plr or not plr.Character then return end
    
    for _, item in ipairs(plr.Character:GetChildren()) do
        if item.Name:match("^RoleESP") then
            item:Destroy()
        end
    end
    
    local espContainer = Instance.new("BillboardGui")
    espContainer.Name = "RoleESP_Main"
    espContainer.Size = UDim2.new(0, 200, 0, 50)
    espContainer.StudsOffset = Vector3.new(0, 3, 0)
    espContainer.AlwaysOnTop = true
    espContainer.Parent = plr.Character

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                            role == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                            Color3.fromRGB(0, 255, 0)
    frame.Parent = espContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = frame

    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    roleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = role
    roleLabel.TextColor3 = Color3.new(1, 1, 1)
    roleLabel.TextSize = 12
    roleLabel.Font = Enum.Font.GothamSemibold
    roleLabel.Parent = frame

    local highlight = Instance.new("Highlight")
    highlight.Name = "RoleESP_Highlight"
    highlight.FillColor = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                         role == "Sheriff" and Color3.fromRGB(0, 0, 255) or 
                         Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = plr.Character

    spawn(function()
        while plr.Character and espContainer.Parent do
            local distance = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            roleLabel.Text = string.format("%s [%d studs]", role, distance)
            wait(0.1)
        end
    end)

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

    local highlight = Instance.new("Highlight")
    highlight.FillColor = config.color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.Parent = item

    RunService:BindToRenderStep("UpdateDistance_" .. item:GetDebugId(), 1, function()
        if not item.Parent then
            RunService:UnbindFromRenderStep("UpdateDistance_" .. item:GetDebugId())
            return
        end
        local distance = (item.Position - player.Character.HumanoidRootPart.Position).Magnitude
        distanceLabel.Text = string.format("%.1f studs", distance)
    end)
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

local MainTab = Window:Tab("Main")
local CombatTab = Window:Tab("Combat")
local ESPTab = Window:Tab("ESP")
local PlayerTab = Window:Tab("Player")
local TeleportTab = Window:Tab("Teleport")
local MiscTab = Window:Tab("Misc")

MainTab:Section("Role Detection")

MainTab:Toggle("Enable Role ESP", false, "RoleESPToggle", function(value)
    RoleSystem.enabled = value
    
    if value then
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
end)

MainTab:Button("Detect Roles", function()
    detectRoles()
    
    SolarisLib:Notification("Roles Detected", "Murderer: " .. (RoleSystem.murderer and RoleSystem.murderer.Name or "Unknown") .. "\nSheriff: " .. (RoleSystem.sheriff and RoleSystem.sheriff.Name or "Unknown"), 5)
end)

CombatTab:Section("Silent Aim")

CombatTab:Toggle("Enable Silent Aim", false, "SilentAimToggle", function(value)
    SilentAim.enabled = value
    fovCircle.Visible = value and SilentAim.showFOV

    if value then
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
                attachment1.Parent = camera.CFrame
                
                local attachment2 = Instance.new("Attachment")
                attachment2.WorldPosition = predictedPos
                attachment2.Parent = workspace.Terrain
                
                beam.Attachment0 = attachment1
                beam.Attachment1 = attachment2
                
                game:GetService("Debris"):AddItem(beam, 0.05)
                game:GetService("Debris"):AddItem(attachment1, 0.05)
                game:GetService("Debris"):AddItem(attachment2, 0.05)
                
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local args = {...}
                    local method = getnamecallmethod()
                    
                    if method == "FireServer" and self.Name == "ShootGun" and SilentAim.enabled then
                        args[1] = predictedPos
                        return oldNamecall(self, unpack(args))
                    end
                    
                    return oldNamecall(self, ...)
                end)
            end
        end)
    else
        RunService:UnbindFromRenderStep("SilentAim")
    end
end)

CombatTab:Toggle("Show FOV", false, "ShowFOVToggle", function(value)
    SilentAim.showFOV = value
    fovCircle.Visible = SilentAim.enabled and value
end)

CombatTab:Slider("FOV Size", 50, 800, 400, 10, "FOVSizeSlider", function(value)
    SilentAim.fovSize = value
    fovCircle.Radius = value
end)

CombatTab:Slider("Prediction", 0.1, 0.3, 0.165, 0.005, "PredictionSlider", function(value)
    SilentAim.prediction = value
end)

CombatTab:Section("Target Selection")

CombatTab:Toggle("Target Murderer", true, "TargetMurdererToggle", function(value)
    SilentAim.targetMurderer = value
end)

CombatTab:Toggle("Target Sheriff", false, "TargetSheriffToggle", function(value)
    SilentAim.targetSheriff = value
end)

CombatTab:Toggle("Target Innocent", false, "TargetInnocentToggle", function(value)
    SilentAim.targetInnocent = value
end)

CombatTab:Section("Auto Kill")

CombatTab:Toggle("Auto Kill Murderer", false, "AutoKillMurdererToggle", function(value)
    if value then
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
end)

ESPTab:Section("Item ESP")

ESPTab:Toggle("Gun ESP", false, "GunESPToggle", function(value)
    if value then
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
end)

ESPTab:Toggle("Knife ESP", false, "KnifeESPToggle", function(value)
    if value then
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
end)

ESPTab:Toggle("Coin ESP", false, "CoinESPToggle", function(value)
    if value then
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
end)

ESPTab:Section("X-Ray")

ESPTab:Toggle("X-Ray Vision", false, "XRayToggle", function(value)
    if value then
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
end)

PlayerTab:Section("Movement")

PlayerTab:Slider("Walk Speed", 16, 500, 16, 1, "WalkSpeedSlider", function(value)
    if humanoid then
        humanoid.WalkSpeed = value
    end
end)

PlayerTab:Slider("Jump Power", 50, 500, 50, 1, "JumpPowerSlider", function(value)
    if humanoid then
        humanoid.JumpPower = value
    end
end)

PlayerTab:Toggle("Infinite Jump", false, "InfiniteJumpToggle", function(value)
    UserInputService.JumpRequest:Connect(function()
        if value and humanoid then
            humanoid:ChangeState("Jumping")
        end
    end)
end)

PlayerTab:Toggle("Noclip", false, "NoclipToggle", function(value)
    if value then
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
end)

PlayerTab:Section("Character")

PlayerTab:Toggle("God Mode", false, "GodModeToggle", function(value)
    if value then
        local clone = character:Clone()
        clone.Parent = workspace
        player.Character = clone
        wait(0.1)
        character.Parent = nil
        
        SolarisLib:Notification("God Mode", "You are now in god mode. You are invisible to other players.", 5)
    else
        character.Parent = workspace
        player.Character = character
        
        if clone then
            clone:Destroy()
        end
    end
end)

TeleportTab:Section("Map Teleports")

TeleportTab:Button("Teleport to Safe Spot", function()
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
            
            SolarisLib:Notification("Teleported", "Successfully teleported to safe spot", 5)
        end
    end
end)

TeleportTab:Button("Teleport to Murderer", function()
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
            
            SolarisLib:Notification("Teleported", "Successfully teleported to murderer", 5)
        end
    else
        SolarisLib:Notification("Error", "Murderer not found", 5)
    end
end)

TeleportTab:Button("Teleport to Sheriff", function()
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
            
            SolarisLib:Notification("Teleported", "Successfully teleported to sheriff", 5)
        end
    else
        SolarisLib:Notification("Error", "Sheriff not found", 5)
    end
end)

MiscTab:Section("Coins")

MiscTab:Toggle("Auto Collect Coins", false, "AutoCoinsToggle", function(value)
    if value then
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
end)

MiscTab:Section("Visual Effects")

MiscTab:Toggle("Full Bright", false, "FullBrightToggle", function(value)
    if value then
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
end)

MiscTab:Toggle("Rainbow Character", false, "RainbowCharToggle", function(value)
    if value then
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
end)

MiscTab:Section("Anti-Cheat")

MiscTab:Toggle("Anti-Ban", true, "AntiBanToggle", function(value)
    if value then
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
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if SolarisLib.Flags["WalkSpeedSlider"].Value then
        humanoid.WalkSpeed = SolarisLib.Flags["WalkSpeedSlider"].Value
    end
    
    if SolarisLib.Flags["JumpPowerSlider"].Value then
        humanoid.JumpPower = SolarisLib.Flags["JumpPowerSlider"].Value
    end
    
    if SolarisLib.Flags["RoleESPToggle"].Value then
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
end)

SolarisLib:Notification("Script Loaded", "Murder Mystery 2 Ultimate has been loaded successfully!", 5)
