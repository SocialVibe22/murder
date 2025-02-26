-- Murder Mystery 2 Script with Built-in UI Library
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
local existingGui = player.PlayerGui:FindFirstChild("MM2GUI")
if existingGui then existingGui:Destroy() end

-- Create Custom UI Library
local Library = {}
Library.Flags = {}
Library.Theme = {
    Background = Color3.fromRGB(25, 25, 35),
    Section = Color3.fromRGB(30, 30, 40),
    Element = Color3.fromRGB(35, 35, 45),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(100, 100, 255),
    DarkAccent = Color3.fromRGB(80, 80, 200),
    Red = Color3.fromRGB(255, 80, 80),
    Green = Color3.fromRGB(80, 255, 80),
    Blue = Color3.fromRGB(80, 80, 255)
}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

-- Helper Functions
local function createCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

local function createStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Library.Theme.Accent
    stroke.Thickness = thickness or 1
    stroke.Parent = instance
    return stroke
end

local function createShadow(instance, size, transparency)
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

local function tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Create Window
function Library:CreateWindow(options)
    options = options or {}
    
    local Window = {}
    Window.Tabs = {}
    Window.TabsContainer = {}
    Window.TabsContent = {}
    Window.CurrentTab = nil
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, options.Width or 650, 0, options.Height or 450)
    MainFrame.Position = UDim2.new(0.5, -(options.Width or 650)/2, 0.5, -(options.Height or 450)/2)
    MainFrame.BackgroundColor3 = Library.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    createCorner(MainFrame, 8)
    createShadow(MainFrame, 30, 0.5)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Library.Theme.Section
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    createCorner(TitleBar, 8)
    
    local TitleBarCover = Instance.new("Frame")
    TitleBarCover.Name = "TitleBarCover"
    TitleBarCover.Size = UDim2.new(1, 0, 0.5, 0)
    TitleBarCover.Position = UDim2.new(0, 0, 0.5, 0)
    TitleBarCover.BackgroundColor3 = Library.Theme.Section
    TitleBarCover.BorderSizePixel = 0
    TitleBarCover.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = options.Title or "MM2 Script"
    Title.TextColor3 = Library.Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
    CloseButton.BackgroundColor3 = Library.Theme.Red
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Library.Theme.Text
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    createCorner(CloseButton, 4)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 150, 1, 0)
    TabContainer.BackgroundColor3 = Library.Theme.Section
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = ContentContainer
    
    createCorner(TabContainer, 8)
    
    local TabContainerCover = Instance.new("Frame")
    TabContainerCover.Name = "TabContainerCover"
    TabContainerCover.Size = UDim2.new(0.5, 0, 1, 0)
    TabContainerCover.Position = UDim2.new(0.5, 0, 0, 0)
    TabContainerCover.BackgroundColor3 = Library.Theme.Section
    TabContainerCover.BorderSizePixel = 0
    TabContainerCover.Parent = TabContainer
    
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = "TabScroll"
    TabScroll.Size = UDim2.new(1, 0, 1, 0)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.ScrollingEnabled = true
    TabScroll.Parent = TabContainer
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabScroll
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = TabScroll
    
    -- Tab Content Container
    local TabContentContainer = Instance.new("Frame")
    TabContentContainer.Name = "TabContentContainer"
    TabContentContainer.Size = UDim2.new(1, -160, 1, -10)
    TabContentContainer.Position = UDim2.new(0, 155, 0, 5)
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
            startPos = MainFrame.Position
            
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
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Update tab list canvas size
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
    end)
    
    -- Create Tab function
    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab.Name = name
        Tab.Sections = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Library.Theme.Element
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabScroll
        
        createCorner(TabButton, 6)
        
        local TabIcon
        if icon then
            TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "Icon"
            TabIcon.Size = UDim2.new(0, 20, 0, 20)
            TabIcon.Position = UDim2.new(0, 10, 0.5, -10)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = icon
            TabIcon.ImageColor3 = Library.Theme.Text
            TabIcon.Parent = TabButton
        end
        
        local TabText = Instance.new("TextLabel")
        TabText.Name = "Text"
        TabText.Size = UDim2.new(1, icon and -40 or -20, 1, 0)
        TabText.Position = UDim2.new(0, icon and 40 or 10, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = name
        TabText.TextColor3 = Library.Theme.Text
        TabText.TextSize = 14
        TabText.Font = Enum.Font.GothamSemibold
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Library.Theme.Accent
        TabContent.Visible = false
        TabContent.Parent = TabContentContainer
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 10)
        ContentList.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 5)
        ContentPadding.PaddingLeft = UDim.new(0, 5)
        ContentPadding.PaddingRight = UDim.new(0, 5)
        ContentPadding.PaddingBottom = UDim.new(0, 5)
        ContentPadding.Parent = TabContent
        
        -- Update content canvas size
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab button click handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Library.Theme.Element
                if tab.Icon then
                    tab.Icon.ImageColor3 = Library.Theme.Text
                end
                tab.Content.Visible = false
            end
            
            -- Show selected tab
            TabButton.BackgroundColor3 = Library.Theme.Accent
            if TabIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)
        
        -- Tab hover effects
        TabButton.MouseEnter:Connect(function()
            if TabContent.Visible then return end
            tween(TabButton, {BackgroundColor3 = Library.Theme.DarkAccent}, 0.2)
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent.Visible then return end
            tween(TabButton, {BackgroundColor3 = Library.Theme.Element}, 0.2)
        end)
        
        -- Store tab references
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Content = TabContent
        
        -- Create Section function
        function Tab:CreateSection(name)
            local Section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = name .. "Section"
            SectionFrame.Size = UDim2.new(1, -10, 0, 36)
            SectionFrame.BackgroundColor3 = Library.Theme.Section
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = TabContent
            
            createCorner(SectionFrame, 6)
            createShadow(SectionFrame, 15, 0.5)
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -20, 0, 26)
            SectionTitle.Position = UDim2.new(0, 10, 0, 5)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = name
            SectionTitle.TextColor3 = Library.Theme.Text
            SectionTitle.TextSize = 15
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local SectionDivider = Instance.new("Frame")
            SectionDivider.Name = "Divider"
            SectionDivider.Size = UDim2.new(1, -20, 0, 1)
            SectionDivider.Position = UDim2.new(0, 10, 0, 30)
            SectionDivider.BackgroundColor3 = Library.Theme.Accent
            SectionDivider.BorderSizePixel = 0
            SectionDivider.Parent = SectionFrame
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Position = UDim2.new(0, 0, 0, 36)
            SectionContent.BackgroundTransparency = 1
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = SectionFrame
            
            local ContentList = Instance.new("UIListLayout")
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentList.Padding = UDim.new(0, 8)
            ContentList.Parent = SectionContent
            
            local ContentPadding = Instance.new("UIPadding")
            ContentPadding.PaddingTop = UDim.new(0, 5)
            ContentPadding.PaddingLeft = UDim.new(0, 10)
            ContentPadding.PaddingRight = UDim.new(0, 10)
            ContentPadding.PaddingBottom = UDim.new(0, 10)
            ContentPadding.Parent = SectionContent
            
            -- Update section size
            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 15)
            end)
            
            -- Create Toggle function
            function Section:AddToggle(options)
                options = options or {}
                options.Flag = options.Flag or (options.Text .. "Toggle")
                options.Default = options.Default or false
                
                Library.Flags[options.Flag] = options.Default
                
                local Toggle = {}
                Toggle.Value = options.Default
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = "Toggle"
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = SectionContent
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "Button"
                ToggleButton.Size = UDim2.new(0, 24, 0, 24)
                ToggleButton.Position = UDim2.new(0, 0, 0.5, -12)
                ToggleButton.BackgroundColor3 = Toggle.Value and Library.Theme.Accent or Library.Theme.Element
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = ToggleFrame
                
                createCorner(ToggleButton, 4)
                
                local ToggleInner = Instance.new("Frame")
                ToggleInner.Name = "Inner"
                ToggleInner.Size = UDim2.new(0, 18, 0, 18)
                ToggleInner.Position = UDim2.new(0.5, -9, 0.5, -9)
                ToggleInner.BackgroundColor3 = Library.Theme.Text
                ToggleInner.BackgroundTransparency = Toggle.Value and 0 or 1
                ToggleInner.BorderSizePixel = 0
                ToggleInner.Parent = ToggleButton
                
                createCorner(ToggleInner, 3)
                
                local ToggleText = Instance.new("TextLabel")
                ToggleText.Name = "Text"
                ToggleText.Size = UDim2.new(1, -30, 1, 0)
                ToggleText.Position = UDim2.new(0, 30, 0, 0)
                ToggleText.BackgroundTransparency = 1
                ToggleText.Text = options.Text or "Toggle"
                ToggleText.TextColor3 = Library.Theme.Text
                ToggleText.TextSize = 14
                ToggleText.Font = Enum.Font.Gotham
                ToggleText.TextXAlignment = Enum.TextXAlignment.Left
                ToggleText.Parent = ToggleFrame
                
                -- Toggle function
                local function updateToggle()
                    Toggle.Value = not Toggle.Value
                    Library.Flags[options.Flag] = Toggle.Value
                    
                    tween(ToggleButton, {BackgroundColor3 = Toggle.Value and Library.Theme.Accent or Library.Theme.Element}, 0.2)
                    tween(ToggleInner, {BackgroundTransparency = Toggle.Value and 0 or 1}, 0.2)
                    
                    if options.Callback then
                        options.Callback(Toggle.Value)
                    end
                end
                
                ToggleButton.MouseButton1Click:Connect(updateToggle)
                ToggleText.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        updateToggle()
                    end
                end)
                
                -- Return toggle object
                function Toggle:Set(value)
                    Toggle.Value = value
                    Library.Flags[options.Flag] = Toggle.Value
                    
                    tween(ToggleButton, {BackgroundColor3 = Toggle.Value and Library.Theme.Accent or Library.Theme.Element}, 0.2)
                    tween(ToggleInner, {BackgroundTransparency = Toggle.Value and 0 or 1}, 0.2)
                    
                    if options.Callback then
                        options.Callback(Toggle.Value)
                    end
                end
                
                return Toggle
            end
            
            -- Create Button function
            function Section:AddButton(options)
                options = options or {}
                
                local Button = {}
                
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Name = "Button"
                ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Parent = SectionContent
                
                local ButtonElement = Instance.new("TextButton")
                ButtonElement.Name = "Element"
                ButtonElement.Size = UDim2.new(1, 0, 1, 0)
                ButtonElement.BackgroundColor3 = Library.Theme.Element
                ButtonElement.BorderSizePixel = 0
                ButtonElement.Text = options.Text or "Button"
                ButtonElement.TextColor3 = Library.Theme.Text
                ButtonElement.TextSize = 14
                ButtonElement.Font = Enum.Font.Gotham
                ButtonElement.AutoButtonColor = false
                ButtonElement.Parent = ButtonFrame
                
                createCorner(ButtonElement, 4)
                
                -- Button effects
                ButtonElement.MouseEnter:Connect(function()
                    tween(ButtonElement, {BackgroundColor3 = Library.Theme.DarkAccent}, 0.2)
                end)
                
                ButtonElement.MouseLeave:Connect(function()
                    tween(ButtonElement, {BackgroundColor3 = Library.Theme.Element}, 0.2)
                end)
                
                ButtonElement.MouseButton1Down:Connect(function()
                    tween(ButtonElement, {BackgroundColor3 = Library.Theme.Accent}, 0.1)
                end)
                
                ButtonElement.MouseButton1Up:Connect(function()
                    tween(ButtonElement, {BackgroundColor3 = Library.Theme.DarkAccent}, 0.1)
                end)
                
                ButtonElement.MouseButton1Click:Connect(function()
                    if options.Callback then
                        options.Callback()
                    end
                end)
                
                return Button
            end
            
            -- Create Slider function
            function Section:AddSlider(options)
                options = options or {}
                options.Flag = options.Flag or (options.Text .. "Slider")
                options.Min = options.Min or 0
                options.Max = options.Max or 100
                options.Default = options.Default or options.Min
                options.Increment = options.Increment or 1
                
                Library.Flags[options.Flag] = options.Default
                
                local Slider = {}
                Slider.Value = options.Default
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = "Slider"
                SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SectionContent
                
                local SliderText = Instance.new("TextLabel")
                SliderText.Name = "Text"
                SliderText.Size = UDim2.new(1, 0, 0, 20)
                SliderText.BackgroundTransparency = 1
                SliderText.Text = options.Text or "Slider"
                SliderText.TextColor3 = Library.Theme.Text
                SliderText.TextSize = 14
                SliderText.Font = Enum.Font.Gotham
                SliderText.TextXAlignment = Enum.TextXAlignment.Left
                SliderText.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Name = "Value"
                SliderValue.Size = UDim2.new(0, 50, 0, 20)
                SliderValue.Position = UDim2.new(1, -50, 0, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(Slider.Value) .. (options.Suffix or "")
                SliderValue.TextColor3 = Library.Theme.Text
                SliderValue.TextSize = 14
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                local SliderBackground = Instance.new("Frame")
                SliderBackground.Name = "Background"
                SliderBackground.Size = UDim2.new(1, 0, 0, 10)
                SliderBackground.Position = UDim2.new(0, 0, 0, 25)
                SliderBackground.BackgroundColor3 = Library.Theme.Element
                SliderBackground.BorderSizePixel = 0
                SliderBackground.Parent = SliderFrame
                
                createCorner(SliderBackground, 5)
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new((Slider.Value - options.Min) / (options.Max - options.Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Library.Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBackground
                
                createCorner(SliderFill, 5)
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Name = "Button"
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.BackgroundTransparency = 1
                SliderButton.Text = ""
                SliderButton.Parent = SliderBackground
                
                -- Slider functionality
                local isDragging = false
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = true
                    end
                end)
                
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativePos = mousePos.X - SliderBackground.AbsolutePosition.X
                        local percent = math.clamp(relativePos / SliderBackground.AbsoluteSize.X, 0, 1)
                        
                        local value = options.Min + ((options.Max - options.Min) * percent)
                        value = math.floor(value / options.Increment + 0.5) * options.Increment
                        value = math.clamp(value, options.Min, options.Max)
                        
                        Slider.Value = value
                        Library.Flags[options.Flag] = value
                        
                        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        SliderValue.Text = tostring(value) .. (options.Suffix or "")
                        
                        if options.Callback then
                            options.Callback(value)
                        end
                    end
                end)
                
                -- Return slider object
                function Slider:Set(value)
                    value = math.clamp(value, options.Min, options.Max)
                    Slider.Value = value
                    Library.Flags[options.Flag] = value
                    
                    local percent = (value - options.Min) / (options.Max - options.Min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderValue.Text = tostring(value) .. (options.Suffix or "")
                    
                    if options.Callback then
                        options.Callback(value)
                    end
                end
                
                return Slider
            end
            
            -- Create Dropdown function
            function Section:AddDropdown(options)
                options = options or {}
                options.Flag = options.Flag or (options.Text .. "Dropdown")
                options.Default = options.Default or options.Options[1]
                options.Options = options.Options or {}
                
                Library.Flags[options.Flag] = options.Default
                
                local Dropdown = {}
                Dropdown.Value = options.Default
                Dropdown.Options = options.Options
                Dropdown.Open = false
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = "Dropdown"
                DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = SectionContent
                
                local DropdownText = Instance.new("TextLabel")
                DropdownText.Name = "Text"
                DropdownText.Size = UDim2.new(1, 0, 0, 20)
                DropdownText.BackgroundTransparency = 1
                DropdownText.Text = options.Text or "Dropdown"
                DropdownText.TextColor3 = Library.Theme.Text
                DropdownText.TextSize = 14
                DropdownText.Font = Enum.Font.Gotham
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left
                DropdownText.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "Button"
                DropdownButton.Size = UDim2.new(1, 0, 0, 20)
                DropdownButton.Position = UDim2.new(0, 0, 0, 20)
                DropdownButton.BackgroundColor3 = Library.Theme.Element
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = Dropdown.Value
                DropdownButton.TextColor3 = Library.Theme.Text
                DropdownButton.TextSize = 14
                DropdownButton.Font = Enum.Font.Gotham
                DropdownButton.Parent = DropdownFrame
                
                createCorner(DropdownButton, 4)
                
                local DropdownIcon = Instance.new("ImageLabel")
                DropdownIcon.Name = "Icon"
                DropdownIcon.Size = UDim2.new(0, 20, 0, 20)
                DropdownIcon.Position = UDim2.new(1, -25, 0, 0)
                DropdownIcon.BackgroundTransparency = 1
                DropdownIcon.Image = "rbxassetid://6031091004"
                DropdownIcon.ImageColor3 = Library.Theme.Text
                DropdownIcon.Parent = DropdownButton
                
                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Name = "Container"
                DropdownContainer.Size = UDim2.new(1, 0, 0, 0)
                DropdownContainer.Position = UDim2.new(0, 0, 1, 0)
                DropdownContainer.BackgroundColor3 = Library.Theme.Element
                DropdownContainer.BorderSizePixel = 0
                DropdownContainer.ClipsDescendants = true
                DropdownContainer.Visible = false
                DropdownContainer.Parent = DropdownButton
                
                createCorner(DropdownContainer, 4)
                
                local DropdownList = Instance.new("UIListLayout")
                DropdownList.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownList.Padding = UDim.new(0, 5)
                DropdownList.Parent = DropdownContainer
                
                local DropdownPadding = Instance.new("UIPadding")
                DropdownPadding.PaddingTop = UDim.new(0, 5)
                DropdownPadding.PaddingBottom = UDim.new(0, 5)
                DropdownPadding.PaddingLeft = UDim.new(0, 5)
                DropdownPadding.PaddingRight = UDim.new(0, 5)
                DropdownPadding.Parent = DropdownContainer
                
                -- Create dropdown options
                local function createOptions()
                    -- Clear existing options
                    for _, child in pairs(DropdownContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create new options
                    for _, option in pairs(Dropdown.Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = option
                        OptionButton.Size = UDim2.new(1, 0, 0, 20)
                        OptionButton.BackgroundColor3 = Library.Theme.Section
                        OptionButton.BorderSizePixel = 0
                        OptionButton.Text = option
                        OptionButton.TextColor3 = Library.Theme.Text
                        OptionButton.TextSize = 14
                        OptionButton.Font = Enum.Font.Gotham
                        OptionButton.Parent = DropdownContainer
                        
                        createCorner(OptionButton, 4)
                        
                        -- Option button effects
                        OptionButton.MouseEnter:Connect(function()
                            tween(OptionButton, {BackgroundColor3 = Library.Theme.DarkAccent}, 0.2)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            tween(OptionButton, {BackgroundColor3 = Library.Theme.Section}, 0.2)
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            Dropdown.Value = option
                            Library.Flags[options.Flag] = option
                            DropdownButton.Text = option
                            
                            -- Close dropdown
                            Dropdown.Open = false
                            tween(DropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                            tween(DropdownIcon, {Rotation = 0}, 0.2)
                            wait(0.2)
                            DropdownContainer.Visible = false
                            
                            if options.Callback then
                                options.Callback(option)
                            end
                        end)
                    end
                end
                
                createOptions()
                
                -- Update dropdown container size
                DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Dropdown.Open then
                        DropdownContainer.Size = UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 10)
                    end
                end)
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    
                    if Dropdown.Open then
                        DropdownContainer.Visible = true
                        tween(DropdownContainer, {Size = UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 10)}, 0.2)
                        tween(DropdownIcon, {Rotation = 180}, 0.2)
                    else
                        tween(DropdownContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        tween(DropdownIcon, {Rotation = 0}, 0.2)
                        wait(0.2)
                        DropdownContainer.Visible = false
                    end
                end)
                
                -- Return dropdown object
                function Dropdown:Set(value)
                    if table.find(Dropdown.Options, value) then
                        Dropdown.Value = value
                        Library.Flags[options.Flag] = value
                        DropdownButton.Text = value
                        
                        if options.Callback then
                            options.Callback(value)
                        end
                    end
                end
                
                function Dropdown:Refresh(newOptions, keepSelection)
                    Dropdown.Options = newOptions
                    
                    -- Update options
                    createOptions()
                    
                    -- Update selection
                    if not keepSelection or not table.find(newOptions, Dropdown.Value) then
                        Dropdown.Value = newOptions[1]
                        Library.Flags[options.Flag] = newOptions[1]
                        DropdownButton.Text = newOptions[1]
                    end
                end
                
                return Dropdown
            end
            
            -- Add section to tab
            table.insert(Tab.Sections, Section)
            
            return Section
        end
        
        -- Add tab to window
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Library.Theme.Accent
            if TabIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    -- Animate window
    MainFrame.Position = UDim2.new(0.5, -(options.Width or 650)/2, 1.5, 0)
    tween(MainFrame, {Position = UDim2.new(0.5, -(options.Width or 650)/2, 0.5, -(options.Height or 450)/2)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    return Window
end

-- Create notification function
function Library:Notify(options)
    options = options or {}
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "Notification"
    NotifFrame.Size = UDim2.new(0, 300, 0, 80)
    NotifFrame.Position = UDim2.new(1, 10, 1, -90)
    NotifFrame.BackgroundColor3 = Library.Theme.Section
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = ScreenGui
    
    createCorner(NotifFrame, 6)
    createShadow(NotifFrame, 15, 0.5)
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Name = "Title"
    NotifTitle.Size = UDim2.new(1, -20, 0, 30)
    NotifTitle.Position = UDim2.new(0, 10, 0, 5)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = options.Title or "Notification"
    NotifTitle.TextColor3 = Library.Theme.Text
    NotifTitle.TextSize = 16
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotifFrame
    
    local NotifText = Instance.new("TextLabel")
    NotifText.Name = "Text"
    NotifText.Size = UDim2.new(1, -20, 0, 40)
    NotifText.Position = UDim2.new(0, 10, 0, 35)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = options.Content or ""
    NotifText.TextColor3 = Library.Theme.Text
    NotifText.TextSize = 14
    NotifText.Font = Enum.Font.Gotham
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.TextWrapped = true
    NotifText.Parent = NotifFrame
    
    -- Animate notification
    tween(NotifFrame, {Position = UDim2.new(1, -310, 1, -90)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    -- Remove notification after duration
    wait(options.Duration or 3)
    tween(NotifFrame, {Position = UDim2.new(1, 10, 1, -90)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    wait(0.5)
    NotifFrame:Destroy()
end

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

-- Create Main Window
local Window = Library:CreateWindow({
    Title = "Murder Mystery 2",
    Width = 650,
    Height = 450
})

-- Create Tabs
local MainTab = Window:CreateTab("Main", "rbxassetid://7733674079")
local CombatTab = Window:CreateTab("Combat", "rbxassetid://7743878358")
local ESPTab = Window:CreateTab("ESP", "rbxassetid://7734042071")
local PlayerTab = Window:CreateTab("Player", "rbxassetid://7743875962")
local TeleportTab = Window:CreateTab("Teleport", "rbxassetid://7733920644")
local MiscTab = Window:CreateTab("Misc", "rbxassetid://7734042071")

-- Main Tab
local RoleSection = MainTab:CreateSection("Role Detection")

RoleSection:AddToggle({
    Text = "Enable Role ESP",
    Default = false,
    Flag = "RoleESP",
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
                    createRoleESP(plr, role)
                end
            end
            
            -- Update ESP
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

RoleSection:AddButton({
    Text = "Detect Roles",
    Callback = function()
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
        
        Library:Notify({
            Title = "Roles Detected",
            Content = "Murderer: " .. (RoleSystem.murderer and RoleSystem.murderer.Name or "Unknown") .. "\nSheriff: " .. (RoleSystem.sheriff and RoleSystem.sheriff.Name or "Unknown"),
            Duration = 5
        })
    end
})

-- Combat Tab
local SilentAimSection = CombatTab:CreateSection("Silent Aim")

SilentAimSection:AddToggle({
    Text = "Enable Silent Aim",
    Default = false,
    Flag = "SilentAim",
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
                    local closestPlayer = getClosestPlayer()
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

SilentAimSection:AddToggle({
    Text = "Show FOV",
    Default = false,
    Flag = "ShowFOV",
    Callback = function(Value)
        SilentAim.showFOV = Value
        fovCircle.Visible = SilentAim.enabled and Value
    end
})

SilentAimSection:AddSlider({
    Text = "FOV Size",
    Min = 50,
    Max = 800,
    Default = 400,
    Increment = 10,
    Flag = "FOVSize",
    Callback = function(Value)
        SilentAim.fovSize = Value
        fovCircle.Radius = Value
    end
})

SilentAimSection:AddSlider({
    Text = "Prediction",
    Min = 0.1,
    Max = 0.3,
    Default = 0.165,
    Increment = 0.005,
    Flag = "Prediction",
    Callback = function(Value)
        SilentAim.prediction = Value
    end
})

-- Target Selection Section
local TargetSection = CombatTab:CreateSection("Target Selection")

TargetSection:AddToggle({
    Text = "Target Murderer",
    Default = true,
    Flag = "TargetMurderer",
    Callback = function(Value)
        SilentAim.targetMurderer = Value
    end
})

TargetSection:AddToggle({
    Text = "Target Sheriff",
    Default = false,
    Flag = "TargetSheriff",
    Callback = function(Value)
        SilentAim.targetSheriff = Value
    end
})

TargetSection:AddToggle({
    Text = "Target Innocent",
    Default = false,
    Flag = "TargetInnocent",
    Callback = function(Value)
        SilentAim.targetInnocent = Value
    end
})

-- Auto Kill Section
local AutoKillSection = CombatTab:CreateSection("Auto Kill")

AutoKillSection:AddToggle({
    Text = "Auto Kill Murderer",
    Default = false,
    Flag = "AutoKillMurderer",
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

ItemESPSection:AddToggle({
    Text = "Gun ESP",
    Default = false,
    Flag = "GunESP",
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

ItemESPSection:AddToggle({
    Text = "Knife ESP",
    Default = false,
    Flag = "KnifeESP",
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

ItemESPSection:AddToggle({
    Text = "Coin ESP",
    Default = false,
    Flag = "CoinESP",
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

-- Player Tab
local MovementSection = PlayerTab:CreateSection("Movement")

MovementSection:AddSlider({
    Text = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Flag = "WalkSpeed",
    Callback = function(Value)
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end
})

MovementSection:AddSlider({
    Text = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 1,
    Flag = "JumpPower",
    Callback = function(Value)
        if humanoid then
            humanoid.JumpPower = Value
        end
    end
})

MovementSection:AddToggle({
    Text = "Infinite Jump",
    Default = false,
    Flag = "InfiniteJump",
    Callback = function(Value)
        UserInputService.JumpRequest:Connect(function()
            if Value and humanoid then
                humanoid:ChangeState("Jumping")
            end
        end)
    end
})

MovementSection:AddToggle({
    Text = "Noclip",
    Default = false,
    Flag = "Noclip",
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

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Restore settings
    if Library.Flags.WalkSpeed then
        humanoid.WalkSpeed = Library.Flags.WalkSpeed
    end
    if Library.Flags.JumpPower then
        humanoid.JumpPower = Library.Flags.JumpPower
    end
    
    -- Update ESP
    if Library.Flags.RoleESP then
        RunService:UnbindFromRenderStep("RoleESP")
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

-- Initial notification
Library:Notify({
    Title = "Script Loaded",
    Content = "Murder Mystery 2 script has been loaded successfully!",
    Duration = 5
})
