-- [[ Cryptic Hub V9 - Element: Dropdown ]]
return function(TabOps, label, options, callback)
    TabOps.Order = TabOps.Order + 1

    local TweenService = game:GetService("TweenService")
    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end

    local isOpen = false

    -- الكارد
    local Card = Instance.new("Frame", TabOps.Page)
    Card.LayoutOrder = TabOps.Order
    Card.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    Card.ClipsDescendants = true
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BorderSizePixel = 0
    local cc = Instance.new("UICorner", Card); cc.CornerRadius = UDim.new(0, 10)

    -- رأس القائمة
    local HeaderBtn = Instance.new("TextButton", Card)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 52)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false

    local TitleLbl = Instance.new("TextLabel", HeaderBtn)
    TitleLbl.Size = UDim2.new(1, -60, 1, 0)
    TitleLbl.Position = UDim2.new(0, 16, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = label .. "  :  اختر..."
    TitleLbl.TextColor3 = Color3.fromRGB(230, 230, 235)
    TitleLbl.Font = Enum.Font.GothamSemibold
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local ArrowLbl = Instance.new("TextLabel", HeaderBtn)
    ArrowLbl.Size = UDim2.new(0, 36, 1, 0)
    ArrowLbl.Position = UDim2.new(1, -44, 0, 0)
    ArrowLbl.BackgroundTransparency = 1
    ArrowLbl.Text = "∨"
    ArrowLbl.TextColor3 = Color3.fromRGB(120, 120, 130)
    ArrowLbl.Font = Enum.Font.GothamBold
    ArrowLbl.TextSize = 16

    -- فاصل
    local Divider = Instance.new("Frame", Card)
    Divider.Size = UDim2.new(1, -24, 0, 1)
    Divider.Position = UDim2.new(0, 12, 0, 52)
    Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    Divider.BorderSizePixel = 0
    Divider.Visible = false

    -- حاوية الخيارات
    local OptionsFrame = Instance.new("ScrollingFrame", Card)
    OptionsFrame.Position = UDim2.new(0, 0, 0, 53)
    OptionsFrame.Size = UDim2.new(1, 0, 1, -53)
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.ScrollBarThickness = 2
    OptionsFrame.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 63)
    OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    local OptLayout = Instance.new("UIListLayout", OptionsFrame)
    OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptLayout.Padding = UDim.new(0, 2)

    local UIPad = Instance.new("UIPadding", OptionsFrame)
    UIPad.PaddingLeft = UDim.new(0, 8)
    UIPad.PaddingRight = UDim.new(0, 8)
    UIPad.PaddingTop = UDim.new(0, 4)
    UIPad.PaddingBottom = UDim.new(0, 4)

    local function RefreshSize()
        if isOpen then
            local h = math.clamp(OptLayout.AbsoluteContentSize.Y + 8, 20, 140)
            Tween(Card, {Size = UDim2.new(1, 0, 0, 52 + 1 + h)}, 0.2)
            OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, OptLayout.AbsoluteContentSize.Y + 8)
            Divider.Visible = true
        else
            Tween(Card, {Size = UDim2.new(1, 0, 0, 52)}, 0.2)
            Divider.Visible = false
        end
    end

    HeaderBtn.MouseEnter:Connect(function() Tween(Card, {BackgroundColor3 = isOpen and Color3.fromRGB(32,32,37) or Color3.fromRGB(38,38,44)}, 0.12) end)
    HeaderBtn.MouseLeave:Connect(function() Tween(Card, {BackgroundColor3 = Color3.fromRGB(32,32,37)}, 0.12) end)

    HeaderBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        ArrowLbl.Text = isOpen and "∧" or "∨"
        RefreshSize()
    end)

    local function buildOptions(newOptions)
        for _, v in pairs(OptionsFrame:GetChildren()) do
            if v:IsA("TextButton") or v:IsA("Frame") then v:Destroy() end
        end
        for i, opt in ipairs(newOptions) do
            local OptBtn = Instance.new("TextButton", OptionsFrame)
            OptBtn.LayoutOrder = i
            OptBtn.Size = UDim2.new(1, 0, 0, 36)
            OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
            OptBtn.Text = ""
            OptBtn.AutoButtonColor = false
            OptBtn.BorderSizePixel = 0
            local oc = Instance.new("UICorner", OptBtn); oc.CornerRadius = UDim.new(0, 7)

            local OptLbl = Instance.new("TextLabel", OptBtn)
            OptLbl.Size = UDim2.new(1, -16, 1, 0)
            OptLbl.Position = UDim2.new(0, 10, 0, 0)
            OptLbl.BackgroundTransparency = 1
            OptLbl.Text = tostring(opt)
            OptLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
            OptLbl.Font = Enum.Font.Gotham
            OptLbl.TextSize = 13
            OptLbl.TextXAlignment = Enum.TextXAlignment.Left

            OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 58)}, 0.1) end)
            OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 46)}, 0.1) end)
            OptBtn.MouseButton1Click:Connect(function()
                TitleLbl.Text = label .. "  :  " .. tostring(opt)
                isOpen = false
                ArrowLbl.Text = "∨"
                RefreshSize()
                if TabOps.LogAction then TabOps.LogAction("🔽 اختيار", label, tostring(opt), 15105570) end
                pcall(callback, opt)
            end)
        end
        if isOpen then RefreshSize() end
    end

    buildOptions(options)
    return { Refresh = buildOptions }
end
