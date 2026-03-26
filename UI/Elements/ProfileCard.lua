-- [[ Cryptic Hub V9 - Element: Profile Card ]]
return function(TabOps, player)
    TabOps.Order = TabOps.Order + 1

    local Card = Instance.new("Frame", TabOps.Page)
    Card.LayoutOrder = TabOps.Order
    Card.Size = UDim2.new(1, 0, 0, 76)
    Card.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
    Card.BorderSizePixel = 0
    local cc = Instance.new("UICorner", Card); cc.CornerRadius = UDim.new(0, 10)
    local cs = Instance.new("UIStroke", Card); cs.Color = Color3.fromRGB(50, 50, 58); cs.Thickness = 1

    local AvatarFrame = Instance.new("Frame", Card)
    AvatarFrame.Size = UDim2.new(0, 50, 0, 50)
    AvatarFrame.Position = UDim2.new(1, -66, 0.5, -25)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    local afc = Instance.new("UICorner", AvatarFrame); afc.CornerRadius = UDim.new(1, 0)

    local Avatar = Instance.new("ImageLabel", AvatarFrame)
    Avatar.Size = UDim2.new(1, 0, 1, 0)
    Avatar.BackgroundTransparency = 1
    local avc = Instance.new("UICorner", Avatar); avc.CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        local s, thumb = pcall(function()
            return game:GetService("Players"):GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if s and thumb then Avatar.Image = thumb end
    end)

    local NameLbl = Instance.new("TextLabel", Card)
    NameLbl.Size = UDim2.new(1, -80, 0, 24)
    NameLbl.Position = UDim2.new(0, 14, 0, 14)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text = player.DisplayName
    NameLbl.TextColor3 = Color3.fromRGB(230, 230, 235)
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 14

    local UserLbl = Instance.new("TextLabel", Card)
    UserLbl.Size = UDim2.new(1, -80, 0, 18)
    UserLbl.Position = UDim2.new(0, 14, 0, 38)
    UserLbl.BackgroundTransparency = 1
    UserLbl.Text = "@" .. player.Name:lower()
    UserLbl.TextColor3 = Color3.fromRGB(110, 110, 122)
    UserLbl.TextXAlignment = Enum.TextXAlignment.Left
    UserLbl.Font = Enum.Font.Gotham
    UserLbl.TextSize = 12
end
