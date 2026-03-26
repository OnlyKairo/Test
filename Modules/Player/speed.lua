-- [[ Cryptic Hub - السرعة المطورة / Advanced WalkSpeed ]]
-- المطور: يامي (Yami) | التحديث: إضافة إشعار عند التفعيل فقط / Update: Added notification on activation only

return function(Tab, UI)
    local player = game.Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui") -- إضافة خدمة الإشعارات
    
    -- متغيرات لحفظ حالة الزر والسرعة لتطبيقها بعد الموت
    local isSpeedActive = false
    local currentSpeed = 50
    
    -- دالة إرسال الإشعارات المزدوجة / Dual notification function
    local function Notify(title, text)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 3
            })
        end)
    end

    -- أضفنا الرقم 50 في نهاية الدالة ليكون القيمة الافتراضية في الخانة / Added 50 as the default value in the input field
    Tab:AddSpeedControl("سرعة المشي / WalkSpeed", function(active, value)
        isSpeedActive = active
        currentSpeed = value

        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hum then
            hum.WalkSpeed = active and value or 16
        end
        
        if active then
            Notify("Cryptic Hub", "⚡ تم تفعيل السرعة المطورة!\n⚡ Advanced WalkSpeed activated!")
        end
    end, 50, 999)

    -- إرجاع السرعة تلقائياً عند ترسبن (respawn) اللاعب إذا كان الزر مفعل
    player.CharacterAdded:Connect(function(newChar)
        if isSpeedActive then
            -- ننتظر حتى يحمل الـ Humanoid الخاص بالشخصية الجديدة
            local hum = newChar:WaitForChild("Humanoid", 5)
            if hum then
                hum.WalkSpeed = currentSpeed
            end
        end
    end)
end
