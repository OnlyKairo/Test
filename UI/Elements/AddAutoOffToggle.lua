-- [[ Cryptic Hub V9 - Element: Toggle (Auto-Off On Death) ]]
return function(TabOps, label, callback)
    TabOps.Order = TabOps.Order + 1

    local TweenService = game:GetService("TweenService")
    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end

    local Card = Instance.new("Frame", TabOps.Page)
    Card.LayoutOrder = TabOps.Order
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    Card.BorderSizePixel = 0
    local cc = Instance.new("UICorner", Card); cc.CornerRadius = UDim.new(0, 10)

    local Lbl = Instance.new("TextLabel", Card)
    Lbl.Size = UDim2.new(1, -80, 1, 0); Lbl.Position = UDim2.new(0, 16, 0, 0)
    Lbl.BackgroundTransparency = 1; Lbl.Text = label
    Lbl.TextColor3 = Color3.fromRGB(230, 230, 235); Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 14; Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextTruncate = Enum.TextTruncate.AtEnd

    local ToggleTrack = Instance.new("Frame", Card)
    ToggleTrack.Size = UDim2.new(0, 48, 0, 26); ToggleTrack.Position = UDim2.new(1, -64, 0.5, -13)
    ToggleTrack.BackgroundColor3 = Color3.fromRGB(65, 65, 73); ToggleTrack.BorderSizePixel = 0
    local tc = Instance.new("UICorner", ToggleTrack); tc.CornerRadius = UDim.new(1, 0)

    local Thumb = Instance.new("Frame", ToggleTrack)
    Thumb.Size = UDim2.new(0, 20, 0, 20); Thumb.Position = UDim2.new(0, 3, 0.5, -10)
    Thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 205); Thumb.BorderSizePixel = 0
    local thc = Instance.new("UICorner", Thumb); thc.CornerRadius = UDim.new(1, 0)

    local ClickBtn = Instance.new("TextButton", Card)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0); ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""; ClickBtn.ZIndex = 5

    local isActive = false
    local configKey = TabOps.TabName .. "_" .. label

    if TabOps.UI.ConfigData[configKey] ~= nil then isActive = TabOps.UI.ConfigData[configKey] end

    local function setState(state, isClick)
        isActive = state
        if isActive then
            Tween(ToggleTrack, {BackgroundColor3 = Color3.fromRGB(225, 225, 230)}, 0.18)
            Tween(Thumb, {Position = UDim2.new(0, 25, 0.5, -10), BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.18)
        else
            Tween(ToggleTrack, {BackgroundColor3 = Color3.fromRGB(65, 65, 73)}, 0.18)
            Tween(Thumb, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(200, 200, 205)}, 0.18)
        end
        TabOps.UI.ConfigData[configKey] = isActive
        pcall(callback, isActive)
        if isClick and TabOps.LogAction then
            TabOps.LogAction("⚙️ تفعيل ميزة", label, isActive and "مفعل ✅" or "معطل ❌", isActive and 5763719 or 15548997)
        end
    end

    if isActive then
        ToggleTrack.BackgroundColor3 = Color3.fromRGB(225, 225, 230)
        Thumb.Position = UDim2.new(0, 25, 0.5, -10)
        Thumb.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        task.spawn(function() task.wait(1.5); pcall(callback, isActive) end)
    end

    ClickBtn.MouseEnter:Connect(function() Tween(Card, {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}, 0.12) end)
    ClickBtn.MouseLeave:Connect(function() Tween(Card, {BackgroundColor3 = Color3.fromRGB(32, 32, 37)}, 0.12) end)
    ClickBtn.MouseButton1Click:Connect(function() setState(not isActive, true) end)

    -- إطفاء تلقائي عند الموت
    local player = game.Players.LocalPlayer
    local function setupDeathEvent(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                if isActive then setState(false, false) end
            end)
        end
    end
    if player.Character then task.spawn(function() setupDeathEvent(player.Character) end) end
    player.CharacterAdded:Connect(function(char) setupDeathEvent(char) end)

    return {SetState = function(self, state) setState(state, false) end}
end
