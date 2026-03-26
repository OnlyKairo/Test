-- [[ Cryptic Hub V9 - UI Element: Open (Collapsible Section) ]]
return function(TabRef, title, icon)
    TabRef.Order = TabRef.Order + 1
    icon = icon or "▸"

    local TweenService = game:GetService("TweenService")
    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end

    -- الإطار الرئيسي
    local Container = Instance.new("Frame", TabRef.Page)
    Container.LayoutOrder = TabRef.Order
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
    Container.ClipsDescendants = true
    Container.BorderSizePixel = 0
    local ContCorner = Instance.new("UICorner", Container)
    ContCorner.CornerRadius = UDim.new(0, 10)
    local ContStroke = Instance.new("UIStroke", Container)
    ContStroke.Color = Color3.fromRGB(50, 50, 58)
    ContStroke.Thickness = 1

    -- هيدر الضغط
    local Header = Instance.new("TextButton", Container)
    Header.Size = UDim2.new(1, 0, 0, 48)
    Header.BackgroundTransparency = 1
    Header.Text = ""; Header.AutoButtonColor = false

    -- أيقونة + عنوان
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -52, 1, 0)
    TitleLbl.Position = UDim2.new(0, 14, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = icon .. "  " .. title
    TitleLbl.TextColor3 = Color3.fromRGB(220, 220, 228)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- سهم الفتح
    local Arrow = Instance.new("TextLabel", Header)
    Arrow.Size = UDim2.new(0, 28, 0, 28)
    Arrow.Position = UDim2.new(1, -38, 0.5, -14)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "∨"
    Arrow.TextColor3 = Color3.fromRGB(120, 120, 130)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 14

    -- فاصل
    local Divider = Instance.new("Frame", Container)
    Divider.Size = UDim2.new(1, -24, 0, 1)
    Divider.Position = UDim2.new(0, 12, 0, 48)
    Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    Divider.BorderSizePixel = 0
    Divider.Visible = false

    -- منطقة المحتوى
    local Inner = Instance.new("Frame", Container)
    Inner.Position = UDim2.new(0, 0, 0, 49)
    Inner.Size = UDim2.new(1, 0, 0, 0)
    Inner.BackgroundTransparency = 1

    local InnerLayout = Instance.new("UIListLayout", Inner)
    InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InnerLayout.Padding = UDim.new(0, 8)
    InnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local InnerPad = Instance.new("UIPadding", Inner)
    InnerPad.PaddingTop = UDim.new(0, 8)
    InnerPad.PaddingBottom = UDim.new(0, 10)
    InnerPad.PaddingLeft = UDim.new(0, 4)
    InnerPad.PaddingRight = UDim.new(0, 4)

    local isOpen = false

    local function UpdateSize()
        local contentH = InnerLayout.AbsoluteContentSize.Y
        if isOpen then
            local totalH = 48 + 1 + contentH + 18
            Tween(Container, {Size = UDim2.new(1, 0, 0, totalH)}, 0.25)
            Arrow.Text = "∧"
            Tween(Arrow, {TextColor3 = Color3.fromRGB(200, 200, 210)}, 0.2)
            Tween(TitleLbl, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            Divider.Visible = true
            Inner.Size = UDim2.new(1, 0, 0, contentH + 18)
        else
            Tween(Container, {Size = UDim2.new(1, 0, 0, 48)}, 0.22)
            Arrow.Text = "∨"
            Tween(Arrow, {TextColor3 = Color3.fromRGB(120, 120, 130)}, 0.2)
            Tween(TitleLbl, {TextColor3 = Color3.fromRGB(220, 220, 228)}, 0.2)
            Divider.Visible = false
        end
    end

    InnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then UpdateSize() end
    end)

    Header.MouseEnter:Connect(function()
        if not isOpen then Tween(Container, {BackgroundColor3 = Color3.fromRGB(30, 30, 36)}, 0.15) end
    end)
    Header.MouseLeave:Connect(function()
        Tween(Container, {BackgroundColor3 = Color3.fromRGB(26, 26, 31)}, 0.15)
    end)
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        UpdateSize()
    end)

    local OpenTab = setmetatable({
        Page = Inner,
        Order = 0,
        TabName = TabRef.TabName .. "_" .. title,
        LogAction = TabRef.LogAction,
        UI = TabRef.UI,
        Open = function() isOpen = true; UpdateSize() end,
        Close = function() isOpen = false; UpdateSize() end,
        Toggle = function() isOpen = not isOpen; UpdateSize() end,
    }, {__index = TabRef})

    return OpenTab
end
