-- [[ UI بسيط وواضح ]]

local SimpleUI = {}

-- الخدمات
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- الألوان البسيطة
local Colors = {
    Background = Color3.fromRGB(30, 30, 35),
    Header = Color3.fromRGB(40, 40, 50),
    Button = Color3.fromRGB(60, 60, 70),
    ButtonHover = Color3.fromRGB(80, 80, 90),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(0, 200, 100),
    ToggleOn = Color3.fromRGB(0, 200, 100),
    ToggleOff = Color3.fromRGB(100, 100, 100)
}

-- دالة مساعدة: إنشاء زاوية دائرية
local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- دالة مساعدة: تأثير حركة
local function Tween(obj, properties, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2), properties):Play()
end

-- إنشاء النافذة الرئيسية
function SimpleUI:CreateWindow(title)
    local player = Players.LocalPlayer
    
    -- النافذة الرئيسية
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleUI"
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, 10)
    
    -- العنوان
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Colors.Header
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    AddCorner(Header, 10)
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title or "Menu"
    TitleText.TextColor3 = Colors.Text
    TitleText.TextSize = 18
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = Header
    
    -- زر الإغلاق
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Colors.Text
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Header
    AddCorner(CloseBtn, 6)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- منطقة المحتوى
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -50)
    Content.Position = UDim2.new(0, 10, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame
    
    -- قائمة التبويبات (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.BackgroundColor3 = Colors.Header
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Content
    AddCorner(Sidebar, 8)
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = Sidebar
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = Sidebar
    
    -- منطقة الصفحات
    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Size = UDim2.new(1, -130, 1, 0)
    Pages.Position = UDim2.new(0, 130, 0, 0)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Content
    
    -- جعل النافذة قابلة للسحب
    local dragging = false
    local dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Sidebar = Sidebar,
        Pages = Pages,
        Tabs = {},
        CurrentTab = nil
    }
    
    -- دالة إنشاء تبويب
    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Colors.Button
        TabBtn.Text = name
        TabBtn.TextColor3 = Colors.Text
        TabBtn.TextSize = 14
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.Parent = self.Sidebar
        AddCorner(TabBtn, 6)
        
        -- الصفحة
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.Visible = false
        Page.Parent = self.Pages
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.Parent = Page
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingLeft = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 5)
        Padding.Parent = Page
        
        -- تحديث حجم الصفحة
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- تأثير الهوفر
        TabBtn.MouseEnter:Connect(function()
            Tween(TabBtn, {BackgroundColor3 = Colors.ButtonHover}, 0.2)
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if self.CurrentTab ~= Page then
                Tween(TabBtn, {BackgroundColor3 = Colors.Button}, 0.2)
            end
        end)
        
        -- تبديل التبويب
        TabBtn.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Visible = false
            end
            for _, btn in pairs(self.Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundColor3 = Colors.Button}, 0.2)
                end
            end
            Page.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
            self.CurrentTab = Page
        end)
        
        -- تفعيل أول تبويب
        if not self.CurrentTab then
            Page.Visible = true
            Tween(TabBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
            self.CurrentTab = Page
        end
        
        local Tab = { Page = Page, Window = self }
        
        -- دالة إضافة زر
        function Tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Name = text
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Colors.Button
            Btn.Text = text
            Btn.TextColor3 = Colors.Text
            Btn.TextSize = 14
            Btn.Font = Enum.Font.Gotham
            Btn.Parent = self.Page
            AddCorner(Btn, 6)
            
            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = Colors.ButtonHover}, 0.2)
            end)
            
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = Colors.Button}, 0.2)
            end)
            
            Btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
            
            return Btn
        end
        
        -- دالة إضافة تبديل
        function Tab:AddToggle(text, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = text
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Colors.Button
            ToggleFrame.Parent = self.Page
            AddCorner(ToggleFrame, 6)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Colors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Name = "Toggle"
            ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
            ToggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleBtn.BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff
            ToggleBtn.Text = ""
            ToggleBtn.Parent = ToggleFrame
            AddCorner(ToggleBtn, 10)
            
            local Circle = Instance.new("Frame")
            Circle.Name = "Circle"
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Colors.Text
            Circle.Parent = ToggleBtn
            AddCorner(Circle, 8)
            
            local enabled = default
            
            ToggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                Tween(ToggleBtn, {BackgroundColor3 = enabled and Colors.ToggleOn or Colors.ToggleOff}, 0.2)
                Tween(Circle, {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                pcall(callback, enabled)
            end)
            
            return ToggleFrame
        end
        
        -- دالة إضافة شريط تمرير
        function Tab:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = text
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = Colors.Button
            SliderFrame.Parent = self.Page
            AddCorner(SliderFrame, 6)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = text .. ": " .. default
            Label.TextColor3 = Colors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local SliderBg = Instance.new("Frame")
            SliderBg.Name = "Background"
            SliderBg.Size = UDim2.new(1, -20, 0, 8)
            SliderBg.Position = UDim2.new(0, 10, 0, 30)
            SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            SliderBg.Parent = SliderFrame
            AddCorner(SliderBg, 4)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            local percent = (default - min) / (max - min)
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderFill.BackgroundColor3 = Colors.Accent
            SliderFill.Parent = SliderBg
            AddCorner(SliderFill, 4)
            
            local dragging = false
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                Label.Text = text .. ": " .. value
                pcall(callback, value)
            end
            
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            return SliderFrame
        end
        
        -- دالة إضافة نص
        function Tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 25)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Colors.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = self.Page
            return Label
        end
        
        return Tab
    end
    
    return Window
end

return SimpleUI
