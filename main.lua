-- [[ Cryptic Hub - Main Script (Simple Version) ]]

local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyKairo/Test/main/UI/Core.lua"))()

-- إنشاء النافذة
local Window = Core:CreateWindow("Cryptic Hub")

-- تبويب اللاعب
local PlayerTab = Window:CreateTab("Player")

PlayerTab:AddToggle("Fly", false, function(enabled)
    print("Fly:", enabled)
    -- كود الطيران هنا
end)

PlayerTab:AddToggle("Speed", false, function(enabled)
    print("Speed:", enabled)
    -- كود السرعة هنا
end)

PlayerTab:AddToggle("Noclip", false, function(enabled)
    print("Noclip:", enabled)
    -- كود Noclip هنا
end)

PlayerTab:AddSlider("Speed Value", 16, 200, 50, function(value)
    print("Speed:", value)
end)

-- تبويب القتال
local CombatTab = Window:CreateTab("Combat")

CombatTab:AddToggle("Aimbot", false, function(enabled)
    print("Aimbot:", enabled)
end)

CombatTab:AddToggle("ESP", false, function(enabled)
    print("ESP:", enabled)
end)

CombatTab:AddButton("Target Player", function()
    print("Targeting...")
end)

-- تبويب المتنوعات
local MiscTab = Window:CreateTab("Misc")

MiscTab:AddToggle("Fullbright", false, function(enabled)
    print("Fullbright:", enabled)
end)

MiscTab:AddToggle("X-Ray", false, function(enabled)
    print("X-Ray:", enabled)
end)

MiscTab:AddButton("Rejoin Server", function()
    print("Rejoining...")
end)

-- تبويب الاستدعاء
local TeleportTab = Window:CreateTab("Teleport")

TeleportTab:AddButton("Teleport to Random", function()
    print("Teleporting...")
end)

print("Cryptic Hub Loaded!")
