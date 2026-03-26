-- [[ Cryptic Hub V9 - Element: Label ]]
return function(TabOps, text)
    TabOps.Order = TabOps.Order + 1

    local Card = Instance.new("Frame", TabOps.Page)
    Card.LayoutOrder = TabOps.Order
    Card.Size = UDim2.new(1, 0, 0, 38)
    Card.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
    Card.BorderSizePixel = 0
    local cc = Instance.new("UICorner", Card); cc.CornerRadius = UDim.new(0, 8)

    local L = Instance.new("TextLabel", Card)
    L.Size = UDim2.new(1, -20, 1, 0)
    L.Position = UDim2.new(0, 10, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(0, 200, 90)
    L.Font = Enum.Font.GothamSemibold
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextWrapped = true

    return {
        SetText = function(nt) L.Text = nt end,
        SetColor = function(col) L.TextColor3 = col end,
    }
end
