-- [[ Cryptic Hub - WalkFling Final Optimized Version ]]

return function(Tab, UI)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local PhysicsService = game:GetService("PhysicsService")
    local StarterGui = game:GetService("StarterGui")
    local lp = Players.LocalPlayer

    -- 📢 دالة الإشعارات
    local function Notify(ar, en)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Cryptic Hub",
                Text = ar .. "\n" .. en,
                Duration = 4
            })
        end)
    end

    -- 🔍 فحص تصادم الماب (Collision Check)
    local function CheckCollisionAllowed()
        local isAllowed = true
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local myTorso = lp.Character and (lp.Character:FindFirstChild("UpperTorso") or lp.Character:FindFirstChild("Torso"))
                local tgtTorso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
                if myTorso and tgtTorso then
                    local ok, can = pcall(function()
                        return PhysicsService:CollisionGroupsAreCollidable(myTorso.CollisionGroup, tgtTorso.CollisionGroup)
                    end)
                    if ok and not can then isAllowed = false break end
                end
            end
        end
        return isAllowed
    end

    -- 🛠️ دالة إنشاء الزر (AddAutoOffToggle) مع فحص مسبق - تصميم موحّد
    local function AddAutoOffToggle(label, callback)
        Tab.Order = Tab.Order or 0
        Tab.Order = Tab.Order + 1
        local ParentPage = Tab.Page or Tab.Container or Tab
        local TweenService = game:GetService("TweenService")
        local function Tw(obj, props, t)
            TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
        end

        local R = Instance.new("Frame", ParentPage)
        R.LayoutOrder = Tab.Order
        R.Size = UDim2.new(1, 0, 0, 52)
        R.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        R.BorderSizePixel = 0
        local rCorner = Instance.new("UICorner", R); rCorner.CornerRadius = UDim.new(0, 10)

        local Lbl = Instance.new("TextLabel", R)
        Lbl.Text = label
        Lbl.Size = UDim2.new(1, -80, 1, 0)
        Lbl.Position = UDim2.new(0, 16, 0, 0)
        Lbl.TextColor3 = Color3.fromRGB(230, 230, 235)
        Lbl.BackgroundTransparency = 1
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Font = Enum.Font.GothamSemibold
        Lbl.TextSize = 14
        Lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local Track = Instance.new("Frame", R)
        Track.Size = UDim2.new(0, 48, 0, 26)
        Track.Position = UDim2.new(1, -64, 0.5, -13)
        Track.BackgroundColor3 = Color3.fromRGB(65, 65, 73)
        Track.BorderSizePixel = 0
        local trCorner = Instance.new("UICorner", Track); trCorner.CornerRadius = UDim.new(1, 0)

        local Thumb = Instance.new("Frame", Track)
        Thumb.Size = UDim2.new(0, 20, 0, 20)
        Thumb.Position = UDim2.new(0, 3, 0.5, -10)
        Thumb.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
        Thumb.BorderSizePixel = 0
        local thCorner = Instance.new("UICorner", Thumb); thCorner.CornerRadius = UDim.new(1, 0)

        local ClickBtn = Instance.new("TextButton", R)
        ClickBtn.Size = UDim2.new(1, 0, 1, 0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 5

        local isActive = false
        local configKey = (Tab.TabName or "Tab") .. "_" .. label

        local function setState(state, isManual)
            if state == true and not CheckCollisionAllowed() then
                Notify("🚫 الماب لا يدعم التلامس", "🚫 Map doesn't support collision")
                return
            end
            isActive = state
            if isActive then
                Tw(Track, {BackgroundColor3 = Color3.fromRGB(225, 225, 230)}, 0.18)
                Tw(Thumb, {Position = UDim2.new(0, 25, 0.5, -10), BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.18)
            else
                Tw(Track, {BackgroundColor3 = Color3.fromRGB(65, 65, 73)}, 0.18)
                Tw(Thumb, {Position = UDim2.new(0, 3, 0.5, -10), BackgroundColor3 = Color3.fromRGB(200, 200, 205)}, 0.18)
            end
            if UI and UI.ConfigData then UI.ConfigData[configKey] = isActive end
            pcall(callback, isActive, isManual)
        end

        ClickBtn.MouseEnter:Connect(function() Tw(R, {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}, 0.12) end)
        ClickBtn.MouseLeave:Connect(function() Tw(R, {BackgroundColor3 = Color3.fromRGB(32, 32, 37)}, 0.12) end)
        ClickBtn.MouseButton1Click:Connect(function() setState(not isActive, true) end)

        local function setupDeathEvent(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.Died:Connect(function()
                    if isActive then
                        setState(false, false)
                        Notify("⚠️ تم إيقاف الميزة بسبب موتك", "⚠️ Feature disabled due to death")
                    end
                end)
            end
        end

        if lp.Character then task.spawn(function() setupDeathEvent(lp.Character) end) end
        lp.CharacterAdded:Connect(setupDeathEvent)

        return { SetState = function(self, state) setState(state, false) end }
    end

    -- 🚀 المتغيرات الأساسية للسكربت
    local walkflinging = false
    local noclipConn = nil
    local antiflingConn = nil
    local flingThread = nil

    -- 🛑 إيقاف كل شيء (Clean up)
    local function StopAll()
        walkflinging = false
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if antiflingConn then antiflingConn:Disconnect() antiflingConn = nil end
        if flingThread then task.cancel(flingThread) flingThread = nil end
    end

    -- 🟢 إنشاء الزر والتحكم في الوظائف
    local walkFlingToggle
    walkFlingToggle = AddAutoOffToggle("تطير ناس بلمسهم/ WalkFling", function(active, isManual)
        if active then
            walkflinging = true
            Notify("✅ تم التفعيل!", "✅ Walk into players to fling them")

            -- [1] النوكليب الكامل (Noclip)
            noclipConn = RunService.Stepped:Connect(function()
                if not walkflinging then return end
                if lp.Character then
                    for _, p in pairs(lp.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)

            -- [2] الأنتي فلينج القوي (Anti-Fling)
            antiflingConn = RunService.Stepped:Connect(function()
                if not walkflinging then return end
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= lp and pl.Character then
                        for _, part in pairs(pl.Character:GetDescendants()) do
                            if part:IsA("BasePart") then 
                                part.CanCollide = false 
                                part.Velocity = Vector3.new(0, 0, 0)
                                part.RotVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end
            end)

            -- [3] لوب التطير (Fling Loop) القوي
            flingThread = task.spawn(function()
                local movel = 0.1
                while walkflinging do
                    RunService.Heartbeat:Wait()
                    local char = lp.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if char and char.Parent and root and root.Parent then
                        local vel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                        
                        RunService.RenderStepped:Wait()
                        if root.Parent then root.AssemblyLinearVelocity = vel end
                        
                        RunService.Stepped:Wait()
                        if root.Parent then 
                            root.AssemblyLinearVelocity = vel + Vector3.new(0, movel, 0)
                            movel = movel * -1
                        end
                    end
                end
            end)
        else
            -- عند الإغلاق
            StopAll()
            
            -- ريستارت فقط إذا كان الإغلاق يدوياً والشخصية لا تزال حية
            if isManual then
                local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = 0
                    Notify("🔄 جاري إعادة الشخصية...", "🔄 Resetting character...")
                end
            end
        end
    end)
end
