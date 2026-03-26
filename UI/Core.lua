-- [[ Cryptic Hub - Core System (Simple & Clean) ]]

local Core = {}

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Simple Theme
local Theme = {
    Background = Color3.fromRGB(25, 25, 30),
    Header = Color3.fromRGB(35, 35, 45),
    Button = Color3.fromRGB(55, 55, 65),
    ButtonHover = Color3.fromRGB(75, 75, 85),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 200, 100),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(80, 80, 90)
}

-- Helper: Add corner
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

-- Helper: Tween animation
local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2), props):Play()
end

-- Create main window
function Core:CreateWindow(title)
    local player = Players.LocalPlayer
    
    -- Main GUI
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "CrypticHub"
    Gui.Parent = CoreGui
    
    -- Main frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = Gui
    Corner(Main, 10)
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    Header.Parent = Main
    Corner(Header, 10)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Cryptic Hub"
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Close button
    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Position = UDim2.new(1, -30, 0, 5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    Close.Text = "X"
    Close.TextColor3 = Theme.Text
    Close.TextSize = 12
    Close.Font = Enum.Font.GothamBold
    Close.Parent = Header
    Corner(Close, 5)
    
    Close.MouseButton1Click:Connect(function()
        Gui:Destroy()
    end)
    
    -- Content area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -45)
    Content.Position = UDim2.new(0, 10, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = Main
    
    -- Sidebar (tabs)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 100, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Header
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Content
    Corner(Sidebar, 8)
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = Sidebar
    
    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingTop = UDim.new(0, 8)
    TabPad.PaddingLeft = UDim.new(0, 8)
    TabPad.PaddingRight = UDim.new(0, 8)
    TabPad.Parent = Sidebar
    
    -- Pages container
    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Size = UDim2.new(1, -110, 1, 0)
    Pages.Position = UDim2.new(0, 110, 0, 0)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Content
    
    -- Make draggable
    local drag, startPos, startInput
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            startPos = Main.Position
            startInput = input.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
    
    local Window = {
        Gui = Gui,
        Main = Main,
        Sidebar = Sidebar,
        Pages = Pages,
        CurrentTab = nil
    }
    
    -- Create tab
    function Window:CreateTab(name)
        -- Tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundColor3 = Theme.Button
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.Text
        TabBtn.TextSize = 13
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = self.Sidebar
        Corner(TabBtn, 5)
        
        -- Tab page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.Visible = false
        Page.Parent = self.Pages
        
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 6)
        List.Parent = Page
        
        local Pad = Instance.new("UIPadding")
        Pad.PaddingTop = UDim.new(0, 5)
        Pad.PaddingLeft = UDim.new(0, 5)
        Pad.PaddingRight = UDim.new(0, 5)
        Pad.Parent = Page
        
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
        end)
        
        -- Hover effect
        TabBtn.MouseEnter:Connect(function()
            if self.CurrentTab ~= Page then
                Tween(TabBtn, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if self.CurrentTab ~= Page then
                Tween(TabBtn, {BackgroundColor3 = Theme.Button}, 0.15)
            end
        end)
        
        -- Switch tab
        TabBtn.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Visible = false
            end
            for _, btn in pairs(self.Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = Theme.Button}, 0.15)
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
            self.CurrentTab = Page
        end)
        
        -- Activate first tab
        if not self.CurrentTab then
            Page.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
            self.CurrentTab = Page
        end
        
        local Tab = { Page = Page }
        
        -- Add button
        function Tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Name = text
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Button
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.TextSize = 13
            Btn.Font = Enum.Font.Gotham
            Btn.Parent = self.Page
            Corner(Btn, 5)
            
            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
            end)
            
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = Theme.Button}, 0.15)
            end)
            
            Btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            
            return Btn
        end
        
        -- Add toggle
        function Tab:AddToggle(text, default, callback)
            local Frame = Instance.new("Frame")
            Frame.Name = text
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Frame.BackgroundColor3 = Theme.Button
            Frame.Parent = self.Page
            Corner(Frame, 5)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -55, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame
            
            local Toggle = Instance.new("TextButton")
            Toggle.Name = "Toggle"
            Toggle.Size = UDim2.new(0, 36, 0, 18)
            Toggle.Position = UDim2.new(1, -46, 0.5, -9)
            Toggle.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
            Toggle.Text = ""
            Toggle.Parent = Frame
            Corner(Toggle, 9)
            
            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Circle.BackgroundColor3 = Theme.Text
            Circle.Parent = Toggle
            Corner(Circle, 7)
            
            local enabled = default
            Toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                Tween(Toggle, {BackgroundColor3 = enabled and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                Tween(Circle, {Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                pcall(callback, enabled)
            end)
            
            return Frame
        end
        
        -- Add slider
        function Tab:AddSlider(text, min, max, default, callback)
            local Frame = Instance.new("Frame")
            Frame.Name = text
            Frame.Size = UDim2.new(1, 0, 0, 45)
            Frame.BackgroundColor3 = Theme.Button
            Frame.Parent = self.Page
            Corner(Frame, 5)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 18)
            Label.Position = UDim2.new(0, 10, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = text .. ": " .. default
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame
            
            local Bar = Instance.new("Frame")
            Bar.Name = "Bar"
            Bar.Size = UDim2.new(1, -20, 0, 6)
            Bar.Position = UDim2.new(0, 10, 0, 28)
            Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            Bar.Parent = Frame
            Corner(Bar, 3)
            
            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            local pct = (default - min) / (max - min)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.Parent = Bar
            Corner(Fill, 3)
            
            local dragging = false
            
            local function update(input)
                local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Label.Text = text .. ": " .. val
                pcall(callback, val)
            end
            
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            return Frame
        end
        
        -- Add label
        function Tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 22)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = self.Page
            return Label
        end
        
        -- Add dropdown
        function Tab:AddDropdown(text, options, callback)
            local Frame = Instance.new("Frame")
            Frame.Name = text
            Frame.Size = UDim2.new(1, 0, 0, 32)
            Frame.BackgroundColor3 = Theme.Button
            Frame.Parent = self.Page
            Corner(Frame, 5)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, -10, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame
            
            local Dropdown = Instance.new("TextButton")
            Dropdown.Name = "Dropdown"
            Dropdown.Size = UDim2.new(0.5, -5, 0, 24)
            Dropdown.Position = UDim2.new(0.5, 0, 0.5, -12)
            Dropdown.BackgroundColor3 = Theme.Header
            Dropdown.Text = options[1] or "Select"
            Dropdown.TextColor3 = Theme.Text
            Dropdown.TextSize = 12
            Dropdown.Font = Enum.Font.Gotham
            Dropdown.Parent = Frame
            Corner(Dropdown, 4)
            
            local open = false
            local selected = options[1]
            
            Dropdown.MouseButton1Click:Connect(function()
                open = not open
                -- Simple dropdown toggle
                if open then
                    Tween(Dropdown, {BackgroundColor3 = Theme.Accent}, 0.15)
                else
                    Tween(Dropdown, {BackgroundColor3 = Theme.Header}, 0.15)
                end
            end)
            
            return Frame
        end
        
        return Tab
    end
    
    return Window
end

return Core
