-- [[ Cryptic Hub V9 - Element: SpeedControl (Toggle + Slider) ]]
return function(TabOps, label, callback, default, maxOverride)
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")

    local function Tween(obj, props, t)
        TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
    end

    local configKey = TabOps.TabName .. "_" .. label .. "_Speed"
    local minVal = 1
    local maxVal = maxOverride or ((label:lower():find("jump") and 500) or 999)
    local defaultVal = default or ((label:lower():find("jump") and 50) or 16)
    local currentVal = defaultVal
    local active = false

    if TabOps.UI.ConfigData[configKey] ~= nil then
        active = TabOps.UI.ConfigData[configKey].active
        currentVal = TabOps.UI.ConfigData[configKey].val or defaultVal
    end

    -- ============ كارد التوجل ============
    TabOps.Order = TabOps.Order + 1
    local ToggleCard = Instance.new("Frame", TabOps.Page)
    ToggleCard.LayoutOrder = TabOps.Order
    ToggleCard.Size = UDim2.new(1, 0, 0, 52)
    ToggleCard.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    ToggleCard.BorderSizePixel = 0
    local cc1 = Instance.new("UICorner", ToggleCard); cc1.CornerRadius = UDim.new(0, 10)

    local ToggleLbl = Instance.new("TextLabel", ToggleCard)
    ToggleLbl.Size = UDim2.new(1, -76, 1, 0)
    ToggleLbl.Position = UDim2.new(0, 16, 0, 0)
    ToggleLbl.BackgroundTransparency = 1
    ToggleLbl.Text = "Enable " .. label
    ToggleLbl.TextColor3 = Color3.fromRGB(230, 230, 235)
    ToggleLbl.Font = Enum.Font.GothamSemibold
    ToggleLbl.TextScaled = true
    ToggleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local tsc = Instance.new("UITextSizeConstraint", ToggleLbl)
    tsc.MaxTextSize = 14; tsc.MinTextSize = 8

    local ToggleTrack = Instance.new("Frame", ToggleCard)
    ToggleTrack.Size = UDim2.new(0, 48, 0, 26)
    ToggleTrack.AnchorPoint = Vector2.new(1, 0.5)
    ToggleTrack.Position = UDim2.new(1, -16, 0.5, 0)
    ToggleTrack.BackgroundColor3 = Color3.fromRGB(65, 65, 73); ToggleTrack.BorderSizePixel = 0
    local tc = Instance.new("UICorner", ToggleTrack); tc.CornerRadius = UDim.new(1, 0)

    local Thumb = Instance.new("Frame", ToggleTrack)
    Thumb.Size = UDim2.new(0, 20, 0, 20); Thumb.Position = UDim2.new(0, 3, 0.5, -10)
    Thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 205); Thumb.BorderSizePixel = 0
    local thc = Instance.new("UICorner", Thumb); thc.CornerRadius = UDim.new(1, 0)

    local ToggleClick = Instance.new("TextButton", ToggleCard)
    ToggleClick.Size = UDim2.new(1, 0, 1, 0); ToggleClick.BackgroundTransparency = 1
    ToggleClick.Text = ""; ToggleClick.ZIndex = 5

    -- ============ كارد السلايدر ============
    TabOps.Order = TabOps.Order + 1
    local SliderCard = Instance.new("Frame", TabOps.Page)
    SliderCard.LayoutOrder = TabOps.Order
    SliderCard.Size = UDim2.new(1, 0, 0, 52)
    SliderCard.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    SliderCard.BorderSizePixel = 0
    local cc2 = Instance.new("UICorner", SliderCard); cc2.CornerRadius = UDim.new(0, 10)

    -- التخطيط: Label | ValBtn | ←SliderBg→ | margin
    -- نستخدم anchoring من اليمين لضمان عدم التداخل
    local SliderLbl = Instance.new("TextLabel", SliderCard)
    SliderLbl.Size = UDim2.new(1, -160, 1, 0); SliderLbl.Position = UDim2.new(0, 16, 0, 0)
    SliderLbl.BackgroundTransparency = 1; SliderLbl.Text = label
    SliderLbl.TextColor3 = Color3.fromRGB(230, 230, 235); SliderLbl.Font = Enum.Font.GothamSemibold
    SliderLbl.TextScaled = true; SliderLbl.TextXAlignment = Enum.TextXAlignment.Left
    local slsc = Instance.new("UITextSizeConstraint", SliderLbl)
    slsc.MaxTextSize = 13; slsc.MinTextSize = 8

    -- رقم القيمة (مرسَّخ من اليمين)
    local ValBtn = Instance.new("TextButton", SliderCard)
    ValBtn.Size = UDim2.new(0, 40, 0, 26)
    ValBtn.Position = UDim2.new(1, -136, 0.5, -13)
    ValBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    ValBtn.Text = tostring(math.floor(currentVal))
    ValBtn.TextColor3 = Color3.fromRGB(155, 155, 165)
    ValBtn.Font = Enum.Font.GothamSemibold
    ValBtn.TextSize = 12
    ValBtn.AutoButtonColor = false
    local vbCorner = Instance.new("UICorner", ValBtn); vbCorner.CornerRadius = UDim.new(0, 6)

    -- صندوق الكتابة (مخفي بالأساس)
    local ValInput = Instance.new("TextBox", SliderCard)
    ValInput.Size = UDim2.new(0, 40, 0, 26)
    ValInput.Position = UDim2.new(1, -136, 0.5, -13)
    ValInput.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ValInput.Text = ""
    ValInput.PlaceholderText = "..."
    ValInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValInput.Font = Enum.Font.GothamSemibold
    ValInput.TextSize = 12
    ValInput.Visible = false
    ValInput.ZIndex = 10
    local viCorner = Instance.new("UICorner", ValInput); viCorner.CornerRadius = UDim.new(0, 6)
    local viStroke = Instance.new("UIStroke", ValInput); viStroke.Color = Color3.fromRGB(60, 140, 255); viStroke.Thickness = 1.5

    -- السلايدر (مرسَّخ من اليمين، يبدأ بعد ValBtn بـ4px)
    local SliderBg = Instance.new("Frame", SliderCard)
    SliderBg.Size = UDim2.new(0, 82, 0, 6); SliderBg.Position = UDim2.new(1, -92, 0.5, -3)
    SliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 63); SliderBg.BorderSizePixel = 0
    local sb = Instance.new("UICorner", SliderBg); sb.CornerRadius = UDim.new(1, 0)

    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new(0, 0, 1, 0); SliderFill.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
    SliderFill.BorderSizePixel = 0
    local sf = Instance.new("UICorner", SliderFill); sf.CornerRadius = UDim.new(1, 0)

    local SliderThumb = Instance.new("Frame", SliderBg)
    SliderThumb.Size = UDim2.new(0, 16, 0, 16); SliderThumb.Position = UDim2.new(0, 0, 0.5, -8)
    SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255); SliderThumb.BorderSizePixel = 0
    local st = Instance.new("UICorner", SliderThumb); st.CornerRadius = UDim.new(1, 0)
    local stStroke = Instance.new("UIStroke", SliderThumb); stStroke.Color = Color3.fromRGB(60, 140, 255); stStroke.Thickness = 2

    -- تحديث الـ UI
    local function updateSliderVisual(val)
        local pct = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
        local trackW = SliderBg.AbsoluteSize.X
        Tween(SliderFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.08)
        Tween(SliderThumb, {Position = UDim2.new(0, math.max(0, pct * trackW - 8), 0.5, -8)}, 0.08)
        ValBtn.Text = tostring(math.floor(val))
    end

    local function setToggle(state)
        active = state
        if active then
            Tween(ToggleTrack, {BackgroundColor3 = Color3.fromRGB(225, 225, 230)}, 0.18)
            Tween(Thumb, {Position = UDim2.new(0, 25, 0.5, -10), BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.18)
        else
            Tween(ToggleTrack, {BackgroundColor3 = Color3.fromRGB(65, 65, 73)}, 0.18)
            Tween(Thumb, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(200, 200, 205)}, 0.18)
        end
        TabOps.UI.ConfigData[configKey] = {active = active, val = currentVal}
        pcall(callback, active, currentVal)
    end

    -- تحديث قيمة السلايدر (بدون استدعاء callback — يُستدعى عند الإفلات فقط)
    local function setSliderVisualOnly(val)
        currentVal = math.clamp(val, minVal, maxVal)
        updateSliderVisual(currentVal)
        TabOps.UI.ConfigData[configKey] = {active = active, val = currentVal}
    end

    local function applySliderVal()
        if active then pcall(callback, active, currentVal) end
    end

    -- تطبيق الحالة الابتدائية
    if active then
        ToggleTrack.BackgroundColor3 = Color3.fromRGB(225, 225, 230)
        Thumb.Position = UDim2.new(0, 25, 0.5, -10)
        Thumb.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    end

    task.spawn(function()
        task.wait(0.05)
        updateSliderVisual(currentVal)
        if active then task.wait(1.5); pcall(callback, active, currentVal) end
    end)

    ToggleClick.MouseEnter:Connect(function() Tween(ToggleCard, {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}, 0.12) end)
    ToggleClick.MouseLeave:Connect(function() Tween(ToggleCard, {BackgroundColor3 = Color3.fromRGB(32, 32, 37)}, 0.12) end)
    ToggleClick.MouseButton1Click:Connect(function()
        setToggle(not active)
        if TabOps.LogAction then
            TabOps.LogAction("⚡ تحكم", label, active and tostring(currentVal) or "معطل", active and 5763719 or 15548997)
        end
    end)

    -- النقر على الرقم لكتابة قيمة مخصصة
    ValBtn.MouseButton1Click:Connect(function()
        ValBtn.Visible = false
        ValInput.Text = tostring(math.floor(currentVal))
        ValInput.Visible = true
        ValInput:CaptureFocus()
    end)

    ValInput.FocusLost:Connect(function(enterPressed)
        local typed = tonumber(ValInput.Text)
        if typed and typed > 0 then
            -- السماح بأي قيمة موجبة حتى لو تجاوزت حد السلايدر
            currentVal = typed
            local displayPct = math.clamp((currentVal - minVal) / (maxVal - minVal), 0, 1)
            local trackW = SliderBg.AbsoluteSize.X
            Tween(SliderFill, {Size = UDim2.new(math.min(displayPct, 1), 0, 1, 0)}, 0.08)
            Tween(SliderThumb, {Position = UDim2.new(0, math.max(0, math.min(displayPct, 1) * trackW - 8), 0.5, -8)}, 0.08)
            ValBtn.Text = tostring(math.floor(currentVal))
            TabOps.UI.ConfigData[configKey] = {active = active, val = currentVal}
            applySliderVal()
        end
        ValInput.Visible = false
        ValBtn.Visible = true
    end)

    -- سحب السلايدر
    local dragging = false
    local SliderBtn = Instance.new("TextButton", SliderBg)
    SliderBtn.Size = UDim2.new(1, 16, 1, 16); SliderBtn.Position = UDim2.new(0, -8, 0, -5)
    SliderBtn.BackgroundTransparency = 1; SliderBtn.Text = ""; SliderBtn.ZIndex = 5

    SliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)

    -- عند الإفلات نستدعي الـ callback مرة واحدة فقط
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                applySliderVal()
            end
        end
    end)

    -- أثناء السحب نحدّث الـ UI فقط بدون إشعارات
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local bgPos = SliderBg.AbsolutePosition.X
            local bgW = SliderBg.AbsoluteSize.X
            local mouseX = inp.Position.X
            local pct = math.clamp((mouseX - bgPos) / bgW, 0, 1)
            setSliderVisualOnly(minVal + (maxVal - minVal) * pct)
        end
    end)
end
