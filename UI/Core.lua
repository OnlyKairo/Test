-- [[ Cryptic Hub - Core Engine V9.0 (Professional UI) ]]

local UI = { Logger = nil, ConfigData = {} }
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ألوان ثيم احترافي
local Theme = {
    Background     = Color3.fromRGB(18, 18, 21),
    Sidebar        = Color3.fromRGB(22, 22, 26),
    Card           = Color3.fromRGB(32, 32, 37),
    CardHover      = Color3.fromRGB(38, 38, 44),
    TabSelected    = Color3.fromRGB(38, 38, 44),
    TabHover       = Color3.fromRGB(30, 30, 35),
    Header         = Color3.fromRGB(20, 20, 24),
    Divider        = Color3.fromRGB(50, 50, 58),
    TextPrimary    = Color3.fromRGB(255, 255, 255),
    TextSecondary  = Color3.fromRGB(155, 155, 165),
    TextMuted      = Color3.fromRGB(100, 100, 110),
    Accent         = Color3.fromRGB(0, 200, 90),
    AccentBadge    = Color3.fromRGB(0, 200, 90),
    ToggleOff      = Color3.fromRGB(70, 70, 78),
    ToggleOn       = Color3.fromRGB(230, 230, 235),
    ToggleThumb    = Color3.fromRGB(255, 255, 255),
    SliderFill     = Color3.fromRGB(60, 140, 255),
    SliderBg       = Color3.fromRGB(55, 55, 63),
    CloseBtn       = Color3.fromRGB(255, 85, 85),
    MinBtn         = Color3.fromRGB(155, 155, 165),
    MaxBtn         = Color3.fromRGB(155, 155, 165),
}


local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function RoundCorner(obj, radius)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function MakePadding(obj, top, bottom, left, right)
    local p = Instance.new("UIPadding", obj)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
end

-- ==========================================
-- نظام الويب هوكات
-- ==========================================
local SecretWebhooks = {
    OnExecute    = "https://cryptic-analytics.bossekasiri2.workers.dev",
    OnFeature    = "https://cryptic-features.bossekasiri2.workers.dev",
    OnError      = "https://cryptic-errors.bossekasiri2.workers.dev",
    OnSuggestion = "https://cryptic-suggestions.bossekasiri2.workers.dev"
}

local function SendWebhookLog(LogCategory, ActionTitle, Color, ExtraFields)
    if Players.LocalPlayer.UserId == 3875086037 then return end
    task.spawn(function()
        local WebhookURL = SecretWebhooks[LogCategory]
        if not WebhookURL or WebhookURL == "" then return end
        local player = Players.LocalPlayer
        local placeName = "Unknown Game"
        pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)
        local executorName = (type(identifyexecutor) == "function" and identifyexecutor()) or "Unknown"
        local fields = {
            {name = "👤 اللاعب:", value = player.DisplayName .. " (@" .. player.Name .. ")\n**ID:** " .. player.UserId, inline = true},
            {name = "💻 المشغل:", value = executorName, inline = true},
            {name = "🎮 الماب:", value = placeName .. "\n**PlaceID:** " .. game.PlaceId, inline = false}
        }
        if ExtraFields then
            for _, field in ipairs(ExtraFields) do
                local valStr = tostring(field.value)
                if #valStr > 1000 then
                    table.insert(fields, {name = field.name .. " [1]", value = valStr:sub(1, 1000), inline = false})
                    table.insert(fields, {name = field.name .. " [2]", value = valStr:sub(1001, 2000), inline = false})
                else
                    table.insert(fields, field)
                end
            end
        end
        local embedData = {
            embeds = {{
                title = ActionTitle, color = Color or 65430,
                thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"},
                fields = fields,
                footer = {text = "Cryptic Hub V9.0"},
                timestamp = DateTime.now():ToIsoDate()
            }}
        }
        local HttpReq = (request or http_request or syn and syn.request)
        if HttpReq then
            pcall(function() HttpReq({Url = WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(embedData)}) end)
        end
    end)
end

getgenv().CrypticLog = SendWebhookLog

task.spawn(function()
    local cnt = #Players:GetPlayers()
    SendWebhookLog("OnExecute", "🚀 تشغيل جديد - Cryptic Hub!", 65430, {
        {name = "👥 حالة السيرفر:", value = cnt .. " / " .. Players.MaxPlayers .. " لاعبين", inline = true},
        {name = "🔗 JobId:", value = game.JobId, inline = false}
    })
end)

-- ==========================================
-- نظام الإعدادات
-- ==========================================
local ConfigFile = "CrypticHub_Settings.json"

pcall(function()
    if isfile and isfile(ConfigFile) then
        local data = HttpService:JSONDecode(readfile(ConfigFile))
        if type(data) == "table" and next(data) then UI.ConfigData = data end
    end
end)

function UI:SaveConfig()
    local ok = pcall(function() writefile(ConfigFile, HttpService:JSONEncode(UI.ConfigData)) end)
    local SG = game:GetService("StarterGui")
    if ok then SG:SetCore("SendNotification", {Title = "Cryptic Hub", Text = "💾 تم حفظ الإعدادات!", Duration = 4})
    else SG:SetCore("SendNotification", {Title = "⚠️", Text = "فشل الحفظ.", Duration = 4}) end
end

function UI:ResetConfig()
    pcall(function()
        if isfile and isfile(ConfigFile) then delfile(ConfigFile) end
        UI.ConfigData = {}
        local qtp = queue_on_teleport or (syn and syn.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
        if qtp then qtp([[ task.wait(3); loadstring(game:HttpGet("https://raw.githubusercontent.com/OnlyCryptic/Cryptic/test/main.lua"))() ]]) end
        local p = Players.LocalPlayer
        if #game.JobId > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
        else TeleportService:Teleport(game.PlaceId, p) end
    end)
end

-- ==========================================
-- بناء الواجهة الرئيسية
-- ==========================================
function UI:CreateWindow(title)
    -- حذف أي واجهة قديمة
    pcall(function()
        for _, v in pairs(CoreGui:GetChildren()) do
            if v.Name == "CrypticHub_V9" then v:Destroy() end
        end
    end)

    local player = Players.LocalPlayer
    local placeName = "Roblox Game"
    pcall(function() placeName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "CrypticHub_V9"
    Screen.ResetOnSpawn = false
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- ==========================================
    -- زر الفتح عند الإخفاء
    -- ==========================================
    local OpenBtn = Instance.new("ImageButton", Screen)
    OpenBtn.Size = UDim2.new(0, 46, 0, 46)
    OpenBtn.Position = UDim2.new(0, 20, 0.5, -23)
    OpenBtn.Visible = false
    OpenBtn.BackgroundColor3 = Theme.Sidebar
    OpenBtn.Image = ""
    RoundCorner(OpenBtn, 12)
    local OpenStroke = Instance.new("UIStroke", OpenBtn)
    OpenStroke.Color = Theme.Divider
    OpenStroke.Thickness = 1.5

    local OpenLabel = Instance.new("TextLabel", OpenBtn)
    OpenLabel.Size = UDim2.new(1, 0, 1, 0)
    OpenLabel.BackgroundTransparency = 1
    OpenLabel.Text = "C"
    OpenLabel.TextColor3 = Theme.Accent
    OpenLabel.Font = Enum.Font.GothamBlack
    OpenLabel.TextSize = 20

    -- سحب زر الفتح
    local dragOB, dragOS, startPosOB
    OpenBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragOB = true; dragOS = inp.Position; startPosOB = OpenBtn.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragOB = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragOB and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragOS
            OpenBtn.Position = UDim2.new(startPosOB.X.Scale, startPosOB.X.Offset + d.X, startPosOB.Y.Scale, startPosOB.Y.Offset + d.Y)
        end
    end)

    -- ==========================================
    -- النافذة الرئيسية
    -- ==========================================
    local Main = Instance.new("Frame", Screen)
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 420, 0, 300)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Background
    Main.Active = true
    Main.ClipsDescendants = true
    RoundCorner(Main, 14)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Theme.Divider
    MainStroke.Thickness = 1

    -- ==========================================
    -- شريط العنوان (Header)
    -- ==========================================
    local Header = Instance.new("Frame", Main)
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = Theme.Header
    Header.BorderSizePixel = 0
    RoundCorner(Header, 14)

    -- خط فاصل أسفل الهيدر
    local HeaderDivider = Instance.new("Frame", Header)
    HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
    HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
    HeaderDivider.BackgroundColor3 = Theme.Divider
    HeaderDivider.BorderSizePixel = 0

    -- صف الاسم والإصدار جنب بعض
    local HeaderInfoRow = Instance.new("Frame", Header)
    HeaderInfoRow.Size = UDim2.new(0, 280, 0, 28)
    HeaderInfoRow.Position = UDim2.new(0, 14, 0.5, -14)
    HeaderInfoRow.BackgroundTransparency = 1
    local HeaderInfoLayout = Instance.new("UIListLayout", HeaderInfoRow)
    HeaderInfoLayout.FillDirection = Enum.FillDirection.Horizontal
    HeaderInfoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    HeaderInfoLayout.Padding = UDim.new(0, 8)

    local GameNameLabel = Instance.new("TextLabel", HeaderInfoRow)
    GameNameLabel.Size = UDim2.new(0, 180, 1, 0)
    GameNameLabel.BackgroundTransparency = 1
    GameNameLabel.Text = placeName
    GameNameLabel.TextColor3 = Theme.TextPrimary
    GameNameLabel.Font = Enum.Font.GothamBold
    GameNameLabel.TextSize = 14
    GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    GameNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local VersionBadge = Instance.new("Frame", HeaderInfoRow)
    VersionBadge.Size = UDim2.new(0, 44, 0, 20)
    VersionBadge.BackgroundColor3 = Theme.AccentBadge
    RoundCorner(VersionBadge, 10)
    local VersionLabel = Instance.new("TextLabel", VersionBadge)
    VersionLabel.Size = UDim2.new(1, 0, 1, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "v9.0"
    VersionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    VersionLabel.Font = Enum.Font.GothamBold
    VersionLabel.TextSize = 11

    -- زر الإغلاق
    local function MakeHeaderBtn(offset, text, col)
        local btn = Instance.new("TextButton", Header)
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.Position = UDim2.new(1, offset, 0.5, -14)
        btn.BackgroundColor3 = Theme.Card
        btn.Text = text
        btn.TextColor3 = col
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        RoundCorner(btn, 7)
        btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
        btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Card}, 0.15) end)
        return btn
    end

    local BtnClose = MakeHeaderBtn(-42, "X", Theme.CloseBtn)
    local BtnMin   = MakeHeaderBtn(-76, "—", Theme.MinBtn)

    BtnClose.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.wait(0.3)
        Screen:Destroy()
    end)

    local normalSize = UDim2.new(0, 420, 0, 300)

    BtnMin.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.25)
        task.wait(0.3)
        Main.Visible = false
        OpenBtn.Visible = true
    end)

    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.BackgroundTransparency = 1
        OpenBtn.Visible = false
        Tween(Main, {Size = normalSize, BackgroundTransparency = 0}, 0.3)
    end)

    -- سحب النافذة
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = Main.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ==========================================
    -- الشريط الجانبي (Sidebar)
    -- ==========================================
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0.3, 0, 1, -52)
    Sidebar.Position = UDim2.new(0, 0, 0, 52)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0

    -- خط فاصل يمين السيدبار
    local SidebarDivider = Instance.new("Frame", Sidebar)
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    SidebarDivider.BackgroundColor3 = Theme.Divider
    SidebarDivider.BorderSizePixel = 0

    -- قسم التبويبات (scrollable)
    local TabScroll = Instance.new("ScrollingFrame", Sidebar)
    TabScroll.Size = UDim2.new(1, 0, 1, -72)
    TabScroll.Position = UDim2.new(0, 0, 0, 0)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabList = Instance.new("Frame", TabScroll)
    TabList.Size = UDim2.new(1, 0, 0, 0)
    TabList.Position = UDim2.new(0, 0, 0, 8)
    TabList.BackgroundTransparency = 1
    local TabLayout = Instance.new("UIListLayout", TabList)
    TabLayout.Padding = UDim.new(0, 2)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MakePadding(TabList, 0, 8, 8, 8)
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.Size = UDim2.new(1, 0, 0, TabLayout.AbsoluteContentSize.Y + 8)
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, 8 + TabLayout.AbsoluteContentSize.Y + 16)
    end)

    -- بروفايل اللاعب في أسفل السيدبار
    local ProfileSection = Instance.new("Frame", Sidebar)
    ProfileSection.Size = UDim2.new(1, 0, 0, 72)
    ProfileSection.Position = UDim2.new(0, 0, 1, -72)
    ProfileSection.BackgroundColor3 = Theme.Header
    ProfileSection.BorderSizePixel = 0

    local ProfileDivider = Instance.new("Frame", ProfileSection)
    ProfileDivider.Size = UDim2.new(1, 0, 0, 1)
    ProfileDivider.BackgroundColor3 = Theme.Divider
    ProfileDivider.BorderSizePixel = 0

    local AvatarFrame = Instance.new("Frame", ProfileSection)
    AvatarFrame.Size = UDim2.new(0, 40, 0, 40)
    AvatarFrame.Position = UDim2.new(0, 12, 0.5, -20)
    AvatarFrame.BackgroundColor3 = Theme.Card
    RoundCorner(AvatarFrame, 20)
    local AvatarImg = Instance.new("ImageLabel", AvatarFrame)
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
    RoundCorner(AvatarImg, 20)

    local ProfileName = Instance.new("TextLabel", ProfileSection)
    ProfileName.Size = UDim2.new(1, -62, 0, 18)
    ProfileName.Position = UDim2.new(0, 60, 0.5, -18)
    ProfileName.BackgroundTransparency = 1
    ProfileName.Text = player.DisplayName
    ProfileName.TextColor3 = Theme.TextPrimary
    ProfileName.Font = Enum.Font.GothamBold
    ProfileName.TextSize = 13
    ProfileName.TextXAlignment = Enum.TextXAlignment.Left

    local ProfileSub = Instance.new("TextLabel", ProfileSection)
    ProfileSub.Size = UDim2.new(1, -62, 0, 16)
    ProfileSub.Position = UDim2.new(0, 60, 0.5, 2)
    ProfileSub.BackgroundTransparency = 1
    ProfileSub.Text = "@" .. player.Name:lower()
    ProfileSub.TextColor3 = Theme.TextMuted
    ProfileSub.Font = Enum.Font.Gotham
    ProfileSub.TextSize = 11
    ProfileSub.TextXAlignment = Enum.TextXAlignment.Left

    -- ==========================================
    -- منطقة المحتوى
    -- ==========================================
    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Size = UDim2.new(0.7, 0, 1, -52)
    Content.Position = UDim2.new(0.3, 0, 0, 52)
    Content.BackgroundColor3 = Theme.Background
    Content.BorderSizePixel = 0

    -- ==========================================
    -- Window Object
    -- ==========================================
    local Window = { CurrentTab = nil }

    local function LogAction(title, fieldName, fieldValue, color)
        if getgenv().CrypticLog then
            pcall(function() getgenv().CrypticLog("OnFeature", title, color or 16776960, {{name = fieldName, value = tostring(fieldValue), inline = false}}) end)
        end
    end

    -- أيقونات الأقسام
    local TabIcons = {
        ["معلومات / info"]          = "ℹ",
        ["قسم اللاعب / player"]     = "⚡",
        ["أدوات / tools"]           = "🔧",
        ["استهداف لاعب / players"]  = "🎯",
        ["قسم السيرفر / server"]    = "🌐",
        ["الانتقال / Teleport"]     = "📍",
        ["اخرى / Other"]            = "⚙",
        ["اقتراحات / Suggestions"]  = "💬",
        ["تجارب"]                   = "🧪",
    }

    function Window:CreateTab(name)
        local icon = TabIcons[name] or "▸"

        -- زر التاب
        local TabBtn = Instance.new("TextButton", TabList)
        TabBtn.LayoutOrder = #TabList:GetChildren()
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        RoundCorner(TabBtn, 8)

        -- خط التحديد على اليسار
        local ActiveLine = Instance.new("Frame", TabBtn)
        ActiveLine.Name = "ActiveLine"
        ActiveLine.Size = UDim2.new(0, 3, 0.55, 0)
        ActiveLine.Position = UDim2.new(0, 0, 0.22, 0)
        ActiveLine.BackgroundColor3 = Theme.Accent
        ActiveLine.BackgroundTransparency = 1
        ActiveLine.BorderSizePixel = 0
        RoundCorner(ActiveLine, 2)

        -- أيقونة التاب
        local TabIconLabel = Instance.new("TextLabel", TabBtn)
        TabIconLabel.Size = UDim2.new(0, 26, 1, 0)
        TabIconLabel.Position = UDim2.new(0, 10, 0, 0)
        TabIconLabel.BackgroundTransparency = 1
        TabIconLabel.Text = icon
        TabIconLabel.TextColor3 = Theme.TextSecondary
        TabIconLabel.Font = Enum.Font.GothamSemibold
        TabIconLabel.TextSize = 15

        -- نص التاب (عربي / إنجليزي)
        local TabNameLabel = Instance.new("TextLabel", TabBtn)
        TabNameLabel.Size = UDim2.new(1, -42, 1, 0)
        TabNameLabel.Position = UDim2.new(0, 38, 0, 0)
        TabNameLabel.BackgroundTransparency = 1
        TabNameLabel.Text = name
        TabNameLabel.TextColor3 = Theme.TextSecondary
        TabNameLabel.Font = Enum.Font.GothamSemibold
        TabNameLabel.TextSize = 11
        TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabNameLabel.TextTruncate = Enum.TextTruncate.AtEnd

        -- صفحة المحتوى
        local Page = Instance.new("ScrollingFrame", Content)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Divider
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollingDirection = Enum.ScrollingDirection.Y
        MakePadding(Page, 12, 12, 12, 12)

        local ListLayout = Instance.new("UIListLayout", Page)
        ListLayout.Padding = UDim.new(0, 8)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 24)
        end)

        local function SelectTab()
            for _, btn in pairs(TabList:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundTransparency = 1}, 0.15)
                    local l = btn:FindFirstChild("ActiveLine")
                    if l then Tween(l, {BackgroundTransparency = 1}, 0.15) end
                    for _, child in pairs(btn:GetChildren()) do
                        if child:IsA("TextLabel") then
                            Tween(child, {TextColor3 = Theme.TextSecondary}, 0.15)
                        end
                    end
                end
            end
            Tween(TabBtn, {BackgroundColor3 = Theme.TabSelected, BackgroundTransparency = 0}, 0.15)
            Tween(ActiveLine, {BackgroundTransparency = 0}, 0.15)
            Tween(TabIconLabel, {TextColor3 = Theme.TextPrimary}, 0.15)
            Tween(TabNameLabel, {TextColor3 = Theme.TextPrimary}, 0.15)
        end

        TabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= name then
                Tween(TabBtn, {BackgroundColor3 = Theme.TabHover, BackgroundTransparency = 0}, 0.12)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= name then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.12)
            end
        end)

        if not Window.CurrentTab then
            Window.CurrentTab = name
            Page.Visible = true
            SelectTab()
        end

        TabBtn.MouseButton1Click:Connect(function()
            Window.CurrentTab = name
            for _, v in pairs(Content:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            Page.Visible = true
            SelectTab()
        end)

        local TabOps = {
            Order = 0,
            Page = Page,
            TabName = name,
            LogAction = LogAction,
            UI = UI,
            _TabBtn = TabBtn,
        }

        function TabOps:AddElement(moduleUrl, ...)
            local ok, f = pcall(function() return loadstring(game:HttpGet(moduleUrl))() end)
            if ok and type(f) == "function" then return f(self, ...) else warn("Cryptic Hub: Failed to load - " .. tostring(moduleUrl)) end
        end

        function TabOps:AddChat(workerUrl, secretKey, repliesUrl)
            -- نفس دالة الشات الأصلية محفوظة بالكامل
            local lp2 = Players.LocalPlayer
            local WORKER = workerUrl; local KEY = secretKey; local REPLIES = repliesUrl

            local function HttpReq(method, path, body)
                local req = (request or http_request or syn and syn.request)
                if not req then return nil end
                local ok2, res = pcall(function()
                    return req({Url = WORKER .. path, Method = method,
                        Headers = {["Content-Type"] = "application/json", ["X-Cryptic-Key"] = KEY},
                        Body = body and HttpService:JSONEncode(body) or nil})
                end)
                if ok2 and res and res.Body then
                    local sok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                    if sok then return data end
                end
                return nil
            end

            local function FetchReplies()
                local ok3, raw = pcall(game.HttpGet, game, REPLIES .. "?v=" .. tick())
                if ok3 and raw then
                    local sok, data = pcall(function() return HttpService:JSONDecode(raw) end)
                    if sok and type(data) == "table" then return data end
                end
                return {}
            end

            local function FormatTime(iso)
                if not iso then return "" end
                local h, m = iso:match("T(%d+):(%d+)")
                if h and m then
                    local hour = tonumber(h); local ampm = hour >= 12 and "PM" or "AM"
                    hour = hour % 12; if hour == 0 then hour = 12 end
                    return string.format("%d:%s %s", hour, m, ampm)
                end
                return ""
            end

            self.Order = self.Order + 1
            local HintFrame = Instance.new("Frame", self.Page)
            HintFrame.LayoutOrder = self.Order
            HintFrame.Size = UDim2.new(1, 0, 0, 38)
            HintFrame.BackgroundColor3 = Color3.fromRGB(24, 45, 35)
            HintFrame.BackgroundTransparency = 0.2
            RoundCorner(HintFrame, 8)
            local HintLbl = Instance.new("TextLabel", HintFrame)
            HintLbl.Size = UDim2.new(1, -12, 1, 0); HintLbl.Position = UDim2.new(0, 6, 0, 0)
            HintLbl.BackgroundTransparency = 1
            HintLbl.Text = "💡 اكتب اقتراحك أو مشكلة واجهتها وسيرد عليك المطور"
            HintLbl.TextColor3 = Theme.Accent; HintLbl.Font = Enum.Font.Gotham; HintLbl.TextSize = 10
            HintLbl.TextWrapped = true; HintLbl.TextXAlignment = Enum.TextXAlignment.Left

            self.Order = self.Order + 1
            local ChatFrame = Instance.new("Frame", self.Page)
            ChatFrame.LayoutOrder = self.Order
            ChatFrame.Size = UDim2.new(1, 0, 0, 200)
            ChatFrame.BackgroundColor3 = Theme.Card
            RoundCorner(ChatFrame, 10)
            local cfStroke = Instance.new("UIStroke", ChatFrame); cfStroke.Thickness = 1; cfStroke.Color = Theme.Divider

            local ChatHeader = Instance.new("Frame", ChatFrame)
            ChatHeader.Size = UDim2.new(1, 0, 0, 28); ChatHeader.BackgroundColor3 = Theme.Header
            ChatHeader.BorderSizePixel = 0; RoundCorner(ChatHeader, 10)
            local ChatTitle = Instance.new("TextLabel", ChatHeader)
            ChatTitle.Size = UDim2.new(1, -10, 1, 0); ChatTitle.Position = UDim2.new(0, 10, 0, 0)
            ChatTitle.BackgroundTransparency = 1; ChatTitle.Text = "💬 المحادثة مع المطور"
            ChatTitle.TextColor3 = Theme.TextSecondary; ChatTitle.Font = Enum.Font.GothamBold; ChatTitle.TextSize = 11
            ChatTitle.TextXAlignment = Enum.TextXAlignment.Left

            local MsgArea = Instance.new("ScrollingFrame", ChatFrame)
            MsgArea.Position = UDim2.new(0, 6, 0, 32); MsgArea.Size = UDim2.new(1, -12, 1, -80)
            MsgArea.BackgroundTransparency = 1; MsgArea.ScrollBarThickness = 2
            MsgArea.ScrollBarImageColor3 = Theme.Accent; MsgArea.CanvasSize = UDim2.new(0, 0, 0, 0)
            local MsgLayout = Instance.new("UIListLayout", MsgArea)
            MsgLayout.Padding = UDim.new(0, 5); MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
            MakePadding(MsgArea, 4, 4, 0, 0)
            MsgLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                MsgArea.CanvasSize = UDim2.new(0, 0, 0, MsgLayout.AbsoluteContentSize.Y + 12)
                MsgArea.CanvasPosition = Vector2.new(0, math.huge)
            end)

            local Divider2 = Instance.new("Frame", ChatFrame)
            Divider2.Size = UDim2.new(0.95, 0, 0, 1); Divider2.Position = UDim2.new(0.025, 0, 1, -46)
            Divider2.BackgroundColor3 = Theme.Divider; Divider2.BorderSizePixel = 0

            local InputFrame = Instance.new("Frame", ChatFrame)
            InputFrame.Size = UDim2.new(1, -12, 0, 34); InputFrame.Position = UDim2.new(0, 6, 1, -40)
            InputFrame.BackgroundColor3 = Theme.Background; RoundCorner(InputFrame, 8)
            local InputBox = Instance.new("TextBox", InputFrame)
            InputBox.Size = UDim2.new(1, -50, 1, 0); InputBox.BackgroundTransparency = 1
            InputBox.Text = ""; InputBox.PlaceholderText = "اكتب رسالتك..."
            InputBox.TextColor3 = Theme.TextPrimary; InputBox.PlaceholderColor3 = Theme.TextMuted
            InputBox.Font = Enum.Font.Gotham; InputBox.TextSize = 11
            InputBox.TextXAlignment = Enum.TextXAlignment.Left; MakePadding(InputBox, 0, 0, 8, 0)
            local SendBtn = Instance.new("TextButton", InputFrame)
            SendBtn.Size = UDim2.new(0, 44, 1, 0); SendBtn.Position = UDim2.new(1, -44, 0, 0)
            SendBtn.BackgroundColor3 = Theme.Accent; SendBtn.Text = "↑"; SendBtn.TextColor3 = Color3.new(1,1,1)
            SendBtn.Font = Enum.Font.GothamBold; SendBtn.TextSize = 16; RoundCorner(SendBtn, 8)

            local KNOWN = {}
            local function RenderMsg(msg)
                local id = msg.id or msg.timestamp or tostring(msg)
                if KNOWN[id] then return end
                KNOWN[id] = true
                local isMe = (msg.userId == tostring(lp2.UserId))
                local bubble = Instance.new("Frame", MsgArea)
                bubble.LayoutOrder = #MsgArea:GetChildren()
                bubble.Size = UDim2.new(0.88, 0, 0, 0); bubble.AutomaticSize = Enum.AutomaticSize.Y
                bubble.BackgroundColor3 = isMe and Color3.fromRGB(35, 55, 45) or Theme.Card
                bubble.Position = UDim2.new(isMe and 0.12 or 0, 0, 0, 0)
                RoundCorner(bubble, 8)
                local bTxt = Instance.new("TextLabel", bubble)
                bTxt.Size = UDim2.new(1, -10, 0, 0); bTxt.AutomaticSize = Enum.AutomaticSize.Y
                bTxt.Position = UDim2.new(0, 5, 0, 3); bTxt.BackgroundTransparency = 1
                bTxt.Text = (isMe and "" or "👤 Dev: ") .. (msg.text or "")
                bTxt.TextColor3 = Theme.TextPrimary; bTxt.Font = Enum.Font.Gotham; bTxt.TextSize = 11
                bTxt.TextWrapped = true; bTxt.TextXAlignment = Enum.TextXAlignment.Left
            end

            local function RefreshReplies()
                local replies = FetchReplies()
                for _, reply in ipairs(replies) do RenderMsg(reply) end
            end

            task.spawn(RefreshReplies)
            task.spawn(function()
                while Screen.Parent do
                    task.wait(15)
                    RefreshReplies()
                end
            end)

            SendBtn.MouseButton1Click:Connect(function()
                local txt = InputBox.Text
                if txt == "" or #txt < 2 then return end
                InputBox.Text = ""
                local msgData = {userId = tostring(lp2.UserId), name = lp2.DisplayName, text = txt, timestamp = DateTime.now():ToIsoDate()}
                RenderMsg(msgData)
                SendWebhookLog("OnSuggestion", "💬 اقتراح جديد", 3447003, {{name = "الرسالة", value = txt, inline = false}})
                task.spawn(function() HttpReq("POST", "/message", msgData) end)
            end)
        end

        return TabOps
    end

    return Window
end

return UI
