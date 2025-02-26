-- Murder Mystery 2 Script with Built-in Nova UI Library
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

-- Remove existing GUI
local existingGui = player.PlayerGui:FindFirstChild("NovaGUI")
if existingGui then existingGui:Destroy() end

-- Create Nova UI Library
local Nova = {}
Nova.Font = Enum.Font.Gotham
Nova.FontBold = Enum.Font.GothamBold
Nova.CurrentTheme = {
    Primary = Color3.fromRGB(30, 30, 45),
    Secondary = Color3.fromRGB(40, 40, 60),
    Tertiary = Color3.fromRGB(50, 50, 75),
    Accent = Color3.fromRGB(100, 100, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

-- Create GUI
local NovaGui = Instance.new("ScreenGui")
NovaGui.Name = "NovaGUI"
NovaGui.ResetOnSpawn = false
NovaGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NovaGui.Parent = player.PlayerGui

-- Helper Functions
local function createCorner(instance, radius, topOnly, rightOnly)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    
    if topOnly then
        corner.CornerRadius = UDim.new(0, 0)
    end
    
    if rightOnly then
        corner.CornerRadius = UDim.new(0, 0)
    end
    
    corner.Parent = instance
    return corner
end

local function createShadow(instance, size, transparency, offset)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
    shadow.Position = UDim2.new(0, -(size or 20)/2, 0, -(size or 20)/2)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Parent = instance
    return shadow
end

local function tween(instance, info, properties)
    local tweenInfo = TweenInfo.new(
        info.Time or 0.5,
        info.EasingStyle or Enum.EasingStyle.Quad,
        info.EasingDirection or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Nova UI Library Functions
function Nova:Init(windowOptions)
    self.Tabs = {}
    
    -- Create main window
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, windowOptions.Size and windowOptions.Size.X or 650, 0, windowOptions.Size and windowOptions.Size.Y or 450)
    MainWindow.Position = UDim2.new(0.5, -(windowOptions.Size and windowOptions.Size.X or 650)/2, 0.5, -(windowOptions.Size and windowOptions.Size.Y or 450)/2)
    MainWindow.BackgroundColor3 = Nova.CurrentTheme.Primary
    MainWindow.BorderSizePixel = 0
    MainWindow.Parent = NovaGui
    
    createCorner(MainWindow)
    createShadow(MainWindow, 15, 0.5, 2)
    
    -- Create title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Nova.CurrentTheme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow
    
    createCorner(TitleBar, 10, true)
    
    local TitleBarLine = Instance.new("Frame")
    TitleBarLine.Name = "TitleBarLine"
    TitleBarLine.Size = UDim2.new(1, 0, 0, 1)
    TitleBarLine.Position = UDim2.new(0, 0, 1, 0)
    TitleBarLine.BackgroundColor3 = Nova.CurrentTheme.Accent
    TitleBarLine.BorderSizePixel = 0
    TitleBarLine.ZIndex = 2
    TitleBarLine.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = windowOptions.Name or "Nova UI Library"
    Title.TextColor3 = Nova.CurrentTheme.Text
    Title.TextSize = 18
    Title.Font = Nova.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Create close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = ""
    CloseButton.Parent = TitleBar
    
    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Name = "CloseIcon"
    CloseIcon.Size = UDim2.new(1, 0, 1, 0)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://6031094678"
    CloseIcon.ImageColor3 = Nova.CurrentTheme.Text
    CloseIcon.Parent = CloseButton
    
    -- Create minimize button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = ""
    MinimizeButton.Parent = TitleBar
    
    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Size = UDim2.new(1, 0, 1, 0)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Image = "rbxassetid://6031090990"
    MinimizeIcon.ImageColor3 = Nova.CurrentTheme.Text
    MinimizeIcon.Parent = MinimizeButton
    
    -- Create content container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainWindow
    
    -- Create tab container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, 0)
    TabContainer.BackgroundColor3 = Nova.CurrentTheme.Secondary
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = ContentContainer
    
    createCorner(TabContainer, 10, false, true)
    
    local TabContainerLine = Instance.new("Frame")
    TabContainerLine.Name = "TabContainerLine"
    TabContainerLine.Size = UDim2.new(0, 1, 1, 0)
    TabContainerLine.Position = UDim2.new(1, 0, 0, 0)
    TabContainerLine.BackgroundColor3 = Nova.CurrentTheme.Accent
    TabContainerLine.BorderSizePixel = 0
    TabContainerLine.ZIndex = 2
    TabContainerLine.Parent = TabContainer
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.ScrollingEnabled = true
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabList
    
    local TabListPadding = Instance.new("UIPadding")
    TabListPadding.PaddingTop = UDim.new(0, 10)
    TabListPadding.PaddingLeft = UDim.new(0, 10)
    TabListPadding.PaddingRight = UDim.new(0, 10)
    TabListPadding.Parent = TabList
    
    -- Create tab content container
    local TabContentContainer = Instance.new("Frame")
    TabContentContainer.Name = "TabContentContainer"
    TabContentContainer.Size = UDim2.new(1, -150, 1, 0)
    TabContentContainer.Position = UDim2.new(0, 150, 0, 0)
    TabContentContainer.BackgroundTransparency = 1
    TabContentContainer.Parent = ContentContainer
    
    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        tween(MainWindow, {Time = 0.5}, {Position = UDim2.new(0.5, -(windowOptions.Size and windowOptions.Size.X or 650)/2, 1.5, -(windowOptions.Size and windowOptions.Size.Y or 450)/2)})
        wait(0.5)
        NovaGui:Destroy()
    end)
    
    -- Minimize button functionality
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            tween(MainWindow, {Time = 0.5}, {Size = UDim2.new(0, windowOptions.Size and windowOptions.Size.X or 650, 0, 40)})
        else
            tween(MainWindow, {Time = 0.5}, {Size = UDim2.new(0, windowOptions.Size and windowOptions.Size.X or 650, 0, windowOptions.Size and windowOptions.Size.Y or 450)})
        end
    end)
    
    -- Store references
    self.MainWindow = MainWindow
    self.TabList = TabList
    self.TabContentContainer = TabContentContainer
    
    -- Animate window
    MainWindow.Position = UDim2.new(0.5, -(windowOptions.Size and windowOptions.Size.X or 650)/2, 1.5, -(windowOptions.Size and windowOptions.Size.Y or 450)/2)
    tween(MainWindow, {Time = 0.5}, {Position = UDim2.new(0.5, -(windowOptions.Size and windowOptions.Size.X or 650)/2, 0.5, -(windowOptions.Size and windowOptions.Size.Y or 450)/2)})
    
    return self
end

function Nova:CreateTab(title, icon)
    -- Create tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = "Tab_" .. title
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Nova.CurrentTheme.Tertiary
    TabButton.BorderSizePixel = 0
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabList
    
    createCorner(TabButton, 8)
    
    local TabIcon
    if icon then
        TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "TabIcon"
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Position = UDim2.new(0, 10, 0.5, -10)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = icon
        TabIcon.ImageColor3 = Nova.CurrentTheme.Text
        TabIcon.Parent = TabButton
    end
    
    local TabTitle = Instance.new("TextLabel")
    TabTitle.Name = "TabTitle"
    TabTitle.Size = UDim2.new(1, icon and -40 or -20, 1, 0)
    TabTitle.Position = UDim2.new(0, icon and 40 or 10, 0, 0)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = title
    TabTitle.TextColor3 = Nova.CurrentTheme.Text
    TabTitle.TextSize = 14
    TabTitle.Font = Nova.Font
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.Parent = TabButton
    
    -- Create tab content
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = "TabContent_" .. title
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.ScrollBarImageColor3 = Nova.CurrentTheme.Accent
    TabContent.Visible = false
    TabContent.Parent = self.TabContentContainer
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabContentLayout.Padding = UDim.new(0, 10)
    TabContentLayout.Parent = TabContent
    
    local TabContentPadding = Instance.new("UIPadding")
    TabContentPadding.PaddingTop = UDim.new(0, 10)
    TabContentPadding.PaddingLeft = UDim.new(0, 10)
    TabContentPadding.PaddingRight = UDim.new(0, 10)
    TabContentPadding.PaddingBottom = UDim.new(0, 10)
    TabContentPadding.Parent = TabContent
    
    -- Tab functionality
    local tab = {
        Button = TabButton,
        Content = TabContent,
        Sections = {}
    }
    
    -- Select tab function
    local function selectTab()
        -- Deselect all tabs
        for _, otherTab in ipairs(self.Tabs) do
            tween(otherTab.Button, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Tertiary})
            otherTab.Content.Visible = false
        end
        
        -- Select this tab
        tween(TabButton, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Accent})
        TabContent.Visible = true
        
        -- Update icon color
        if TabIcon then
            TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end
        
        -- Update text color
        TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    TabButton.MouseButton1Click:Connect(selectTab)
    
    -- Add hover effect
    TabButton.MouseEnter:Connect(function()
        if TabContent.Visible then return end
        tween(TabButton, {Time = 0.2}, {BackgroundColor3 = Color3.fromRGB(
            Nova.CurrentTheme.Tertiary.R * 1.1,
            Nova.CurrentTheme.Tertiary.G * 1.1,
            Nova.CurrentTheme.Tertiary.B * 1.1
        )})
    end)
    
    TabButton.MouseLeave:Connect(function()
        if TabContent.Visible then return end
        tween(TabButton, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Tertiary})
    end)
    
    -- Create section function
    function tab:CreateSection(title)
        local Section = Instance.new("Frame")
        Section.Name = "Section_" .. title
        Section.Size = UDim2.new(1, -20, 0, 40)
        Section.BackgroundColor3 = Nova.CurrentTheme.Secondary
        Section.BorderSizePixel = 0
        Section.AutomaticSize = Enum.AutomaticSize.Y
        Section.Parent = TabContent
        
        createCorner(Section)
        createShadow(Section, 10, 0.5, 2)
        
        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "SectionTitle"
        SectionTitle.Size = UDim2.new(1, -20, 0, 30)
        SectionTitle.Position = UDim2.new(0, 10, 0, 5)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Text = title
        SectionTitle.TextColor3 = Nova.CurrentTheme.Text
        SectionTitle.TextSize = 16
        SectionTitle.Font = Nova.FontBold
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = Section
        
        local SectionDivider = Instance.new("Frame")
        SectionDivider.Name = "SectionDivider"
        SectionDivider.Size = UDim2.new(1, -20, 0, 1)
        SectionDivider.Position = UDim2.new(0, 10, 0, 35)
        SectionDivider.BackgroundColor3 = Nova.CurrentTheme.Accent
        SectionDivider.BorderSizePixel = 0
        SectionDivider.Parent = Section
        
        local SectionContainer = Instance.new("Frame")
        SectionContainer.Name = "SectionContainer"
        SectionContainer.Size = UDim2.new(1, 0, 0, 0)
        SectionContainer.Position = UDim2.new(0, 0, 0, 45)
        SectionContainer.BackgroundTransparency = 1
        SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
        SectionContainer.Parent = Section
        
        local SectionLayout = Instance.new("UIListLayout")
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SectionLayout.Padding = UDim.new(0, 10)
        SectionLayout.Parent = SectionContainer
        
        local SectionPadding = Instance.new("UIPadding")
        SectionPadding.PaddingTop = UDim.new(0, 5)
        SectionPadding.PaddingLeft = UDim.new(0, 10)
        SectionPadding.PaddingRight = UDim.new(0, 10)
        SectionPadding.PaddingBottom = UDim.new(0, 10)
        SectionPadding.Parent = SectionContainer
        
        -- Update canvas size
        SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Section.Size = UDim2.new(1, -20, 0, SectionLayout.AbsoluteContentSize.Y + 55)
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Create section object
        local section = {
            Container = SectionContainer
        }
        
        -- Add toggle function
        function section:AddToggle(options)
            local toggleValue = options.Default or false
            
            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Name = "Toggle_" .. options.Name
            ToggleContainer.Size = UDim2.new(1, 0, 0, 30)
            ToggleContainer.BackgroundTransparency = 1
            ToggleContainer.Parent = self.Container
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "ToggleLabel"
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = options.Name
            ToggleLabel.TextColor3 = Nova.CurrentTheme.Text
            ToggleLabel.TextSize = 14
            ToggleLabel.Font = Nova.Font
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleContainer
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
            ToggleButton.BackgroundColor3 = toggleValue and Nova.CurrentTheme.Accent or Color3.fromRGB(60, 60, 90)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = ToggleContainer
            
            createCorner(ToggleButton, 10)
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "ToggleCircle"
            ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
            ToggleCircle.Position = UDim2.new(toggleValue and 0.6 or 0.1, 0, 0.5, -8)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            
            createCorner(ToggleCircle, 8)
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggleValue = not toggleValue
                tween(ToggleButton, {Time = 0.2}, {BackgroundColor3 = toggleValue and Nova.CurrentTheme.Accent or Color3.fromRGB(60, 60, 90)})
                tween(ToggleCircle, {Time = 0.2}, {Position = UDim2.new(toggleValue and 0.6 or 0.1, 0, 0.5, -8)})
                options.Callback(toggleValue)
            end)
            
            -- Return toggle object with value property
            local toggle = {
                Value = toggleValue,
                Instance = ToggleContainer
            }
            
            return toggle
        end
        
        -- Add button function
        function section:AddButton(options)
            local ButtonContainer = Instance.new("Frame")
            ButtonContainer.Name = "Button_" .. options.Name
            ButtonContainer.Size = UDim2.new(1, 0, 0, 30)
            ButtonContainer.BackgroundTransparency = 1
            ButtonContainer.Parent = self.Container
            
            local Button = Instance.new("TextButton")
            Button.Name = "Button"
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.BackgroundColor3 = Nova.CurrentTheme.Tertiary
            Button.BorderSizePixel = 0
            Button.Text = options.Name
            Button.TextColor3 = Nova.CurrentTheme.Text
            Button.TextSize = 14
            Button.Font = Nova.Font
            Button.AutoButtonColor = false
            Button.Parent = ButtonContainer
            
            createCorner(Button, 6)
            
            -- Add hover effect
            Button.MouseEnter:Connect(function()
                tween(Button, {Time = 0.2}, {BackgroundColor3 = Color3.fromRGB(
                    Nova.CurrentTheme.Tertiary.R * 1.1,
                    Nova.CurrentTheme.Tertiary.G * 1.1,
                    Nova.CurrentTheme.Tertiary.B * 1.1
                )})
            end)
            
            Button.MouseLeave:Connect(function()
                tween(Button, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Tertiary})
            end)
            
            Button.MouseButton1Click:Connect(function()
                tween(Button, {Time = 0.1}, {BackgroundColor3 = Nova.CurrentTheme.Accent})
                options.Callback()
                wait(0.1)
                tween(Button, {Time = 0.1}, {BackgroundColor3 = Nova.CurrentTheme.Tertiary})
            end)
            
            return Button
        end
        
        -- Add slider function
        function section:AddSlider(options)
            local sliderValue = options.Default or options.Min
            
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Name = "Slider_" .. options.Name
            SliderContainer.Size = UDim2.new(1, 0, 0, 50)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.Parent = self.Container
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "SliderLabel"
            SliderLabel.Size = UDim2.new(1, 0, 0, 20)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = options.Name .. ": " .. sliderValue .. (options.Suffix or "")
            SliderLabel.TextColor3 = Nova.CurrentTheme.Text
            SliderLabel.TextSize = 14
            SliderLabel.Font = Nova.Font
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderContainer
            
            local SliderBackground = Instance.new("Frame")
            SliderBackground.Name = "SliderBackground"
            SliderBackground.Size = UDim2.new(1, 0, 0, 10)
            SliderBackground.Position = UDim2.new(0, 0, 0.5, 0)
            SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            SliderBackground.BorderSizePixel = 0
            SliderBackground.Parent = SliderContainer
            
            createCorner(SliderBackground, 5)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "SliderFill"
            SliderFill.Size = UDim2.new((sliderValue - options.Min) / (options.Max - options.Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Nova.CurrentTheme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBackground
            
            createCorner(SliderFill, 5)
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Name = "SliderButton"
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderBackground
            
            local function updateSlider(input)
                local sizeX = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                
                local value = math.floor((options.Min + ((options.Max - options.Min) * sizeX)) / options.Increment + 0.5) * options.Increment
                value = math.clamp(value, options.Min, options.Max)
                
                SliderLabel.Text = options.Name .. ": " .. value .. (options.Suffix or "")
                sliderValue = value
                options.Callback(value)
            end
            
            SliderButton.MouseButton1Down:Connect(function(input)
                updateSlider(input)
                local connection
                connection = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if connection then
                            connection:Disconnect()
                        end
                    end
                end)
            end)
            
            -- Return slider object with value property
            local slider = {
                Value = sliderValue,
                Instance = SliderContainer
            }
            
            return slider
        end
        
        -- Add dropdown function
        function section:AddDropdown(options)
            local dropdownValue = options.Default or options.Options[1]
            local dropdownOpen = false
            
            local DropdownContainer = Instance.new("Frame")
            DropdownContainer.Name = "Dropdown_" .. options.Name
            DropdownContainer.Size = UDim2.new(1, 0, 0, 30)
            DropdownContainer.BackgroundTransparency = 1
            DropdownContainer.Parent = self.Container
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "DropdownLabel"
            DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = options.Name
            DropdownLabel.TextColor3 = Nova.CurrentTheme.Text
            DropdownLabel.TextSize = 14
            DropdownLabel.Font = Nova.Font
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownContainer
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "DropdownButton"
            DropdownButton.Size = UDim2.new(1, 0, 0, 30)
            DropdownButton.Position = UDim2.new(0, 0, 0, 20)
            DropdownButton.BackgroundColor3 = Nova.CurrentTheme.Tertiary
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Text = dropdownValue
            DropdownButton.TextColor3 = Nova.CurrentTheme.Text
            DropdownButton.TextSize = 14
            DropdownButton.Font = Nova.Font
            DropdownButton.Parent = DropdownContainer
            
            createCorner(DropdownButton, 6)
            
            local DropdownArrow = Instance.new("ImageLabel")
            DropdownArrow.Name = "DropdownArrow"
            DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
            DropdownArrow.Position = UDim2.new(1, -25, 0.5, -10)
            DropdownArrow.BackgroundTransparency = 1
            DropdownArrow.Image = "rbxassetid://6031091004"
            DropdownArrow.ImageColor3 = Nova.CurrentTheme.Text
            DropdownArrow.Parent = DropdownButton
            
            local DropdownMenu = Instance.new("Frame")
            DropdownMenu.Name = "DropdownMenu"
            DropdownMenu.Size = UDim2.new(1, 0, 0, 0)
            DropdownMenu.Position = UDim2.new(0, 0, 1, 5)
            DropdownMenu.BackgroundColor3 = Nova.CurrentTheme.Tertiary
            DropdownMenu.BorderSizePixel = 0
            DropdownMenu.ClipsDescendants = true
            DropdownMenu.Visible = false
            DropdownMenu.ZIndex = 5
            DropdownMenu.Parent = DropdownButton
            
            createCorner(DropdownMenu, 6)
            
            local DropdownLayout = Instance.new("UIListLayout")
            DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropdownLayout.Padding = UDim.new(0, 5)
            DropdownLayout.Parent = DropdownMenu
            
            local DropdownPadding = Instance.new("UIPadding")
            DropdownPadding.PaddingTop = UDim.new(0, 5)
            DropdownPadding.PaddingBottom = UDim.new(0, 5)
            DropdownPadding.PaddingLeft = UDim.new(0, 5)
            DropdownPadding.PaddingRight = UDim.new(0, 5)
            DropdownPadding.Parent = DropdownMenu
            
            -- Create dropdown options
            for _, option in ipairs(options.Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = "Option_" .. option
                OptionButton.Size = UDim2.new(1, 0, 0, 25)
                OptionButton.BackgroundColor3 = Nova.CurrentTheme.Secondary
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = option
                OptionButton.TextColor3 = Nova.CurrentTheme.Text
                OptionButton.TextSize = 14
                OptionButton.Font = Nova.Font
                OptionButton.ZIndex = 6
                OptionButton.Parent = DropdownMenu
                
                createCorner(OptionButton, 4)
                
                OptionButton.MouseEnter:Connect(function()
                    tween(OptionButton, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Accent})
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    tween(OptionButton, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Secondary})
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    dropdownValue = option
                    DropdownButton.Text = option
                    options.Callback(option)
                    
                    -- Close dropdown
                    dropdownOpen = false
                    tween(DropdownMenu, {Time = 0.2}, {Size = UDim2.new(1, 0, 0, 0)})
                    wait(0.2)
                    DropdownMenu.Visible = false
                    tween(DropdownArrow, {Time = 0.2}, {Rotation = 0})
                end)
            end
            
            -- Toggle dropdown
            DropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                
                if dropdownOpen then
                    DropdownMenu.Visible = true
                    tween(DropdownMenu, {Time = 0.2}, {Size = UDim2.new(1, 0, 0, DropdownLayout.AbsoluteContentSize.Y + 10)})
                    tween(DropdownArrow, {Time = 0.2}, {Rotation = 180})
                else
                    tween(DropdownMenu, {Time = 0.2}, {Size = UDim2.new(1, 0, 0, 0)})
                    wait(0.2)
                    DropdownMenu.Visible = false
                    tween(DropdownArrow, {Time = 0.2}, {Rotation = 0})
                end
            end)
            
            -- Update dropdown size
            DropdownLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if dropdownOpen then
                    DropdownMenu.Size = UDim2.new(1, 0, 0, DropdownLayout.AbsoluteContentSize.Y + 10)
                end
            end)
            
            -- Return dropdown object with value property and refresh function
            local dropdown = {
                Value = dropdownValue,
                Instance = DropdownContainer,
                Refresh = function(self, newOptions, keepSelection)
                    -- Clear existing options
                    for _, child in ipairs(DropdownMenu:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Update options
                    for _, option in ipairs(newOptions) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "Option_" .. option
                        OptionButton.Size = UDim2.new(1, 0, 0, 25)
                        OptionButton.BackgroundColor3 = Nova.CurrentTheme.Secondary
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Nova.CurrentTheme.Text
                        OptionButton.TextSize = 14
                        OptionButton.Font = Nova.Font
                        OptionButton.ZIndex = 6
                        OptionButton.Parent = DropdownMenu
                        
                        createCorner(OptionButton, 4)
                        
                        OptionButton.MouseEnter:Connect(function()
                            tween(OptionButton, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Accent})
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            tween(OptionButton, {Time = 0.2}, {BackgroundColor3 = Nova.CurrentTheme.Secondary})
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            dropdownValue = option
                            DropdownButton.Text = option
                            options.Callback(option)
                            
                            -- Close dropdown
                            dropdownOpen = false
                            tween(DropdownMenu, {Time = 0.2}, {Size = UDim2.new(1, 0, 0, 0)})
                            wait(0.2)
                            DropdownMenu.Visible = false
                            tween(DropdownArrow, {Time = 0.2}, {Rotation = 0})
                        end)
                    end
                    
                    -- Update dropdown value
                    if not keepSelection or not table.find(newOptions, dropdownValue) then
                        dropdownValue = newOptions[1]
                        DropdownButton.Text = dropdownValue
                    end
                    
                    options.Options = newOptions
                end
            }
            
            return dropdown
        end
        
        -- Add section to tab
        table.insert(tab.Sections, section)
        
        return section
    end
    
    -- Add tab to tabs table
    table.insert(self.Tabs, tab)
    
    -- Select first tab
    if #self.Tabs == 1 then
        selectTab()
    end
    
    -- Update canvas size
    TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    return tab
end

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

[Rest of the code continues with all the sections and features as shown in the previous messages...]

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
end)

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
