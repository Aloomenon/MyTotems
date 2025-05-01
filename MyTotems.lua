local function RemoveBackgroundWithBorder()
    local totem1, totem2, totem3, totem4 = TotemFrame:GetChildren()
    for i, totemFrame in ipairs({totem1, totem2, totem3, totem4}) do
        local frameIcon, overlayFrame = totemFrame:GetChildren()

        if overlayFrame:GetFrameLevel() < frameIcon:GetFrameLevel() then
            overlayFrame = frameIcon
        end

        overlayFrame:Hide()

        local frBackground = _G[totemFrame:GetName()..'Background']
        frBackground:Hide()
    end
end

if UnitClass("player") == "Shaman" then
    RemoveBackgroundWithBorder()
end
