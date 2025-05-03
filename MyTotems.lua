local MyTotemsFrame = CreateFrame("Frame", "MyTotems")

local PULSE_DURATIONS = {
    ["Tremor Totem"] = 3,
    ["Earthbind Totem"] = 3,
    ["Cleansing Totem"] = 3,
    ["Searing Totem"] = 2.2, -- scaling from haste ?
    ["Magma Totem"] = 2,
    ["Healing Stream Totem"] = 2,
    ["Stoneclaw Totem"] = 2
}

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

local function RemoveTotemRank(totemName)
    local i, n = string.find(totemName, "Totem")
    return string.sub(totemName, 0, n)
end

local function GetPulseDuration(cdButton)
    local _, totemName, _, duration = GetTotemInfo(cdButton:GetParent():GetParent().slot)
    local data_dur = PULSE_DURATIONS[RemoveTotemRank(totemName)]
    if data_dur ~= nil then
        return data_dur, true
    end
    return duration, false
end

local function SetCooldown(frame, pulseTime, duration)
    frame:SetCooldown(pulseTime, duration, true)
    frame.lastPulse = pulseTime
end

local function CooldownOnUpdate(cdButton, elapsed)
    local nextPulseTime = GetTime()
    local duration, extended = GetPulseDuration(cdButton)
    if extended and cdButton.lastPulse + duration <= nextPulseTime then
        SetCooldown(cdButton, nextPulseTime, duration)
    end
end

function TotemButton_Update(button, startTime, duration, icon)
	local buttonName = button:GetName()
	local buttonIcon = _G[buttonName.."IconTexture"]
	local buttonDuration = _G[buttonName.."Duration"]
	local buttonCooldown = _G[buttonName.."IconCooldown"]
	if ( duration > 0 ) then
        local pulseDuration, extended = GetPulseDuration(buttonCooldown)
		buttonIcon:SetTexture(icon)
		buttonIcon:Show()
        SetCooldown(buttonCooldown, GetTime(), pulseDuration)
        buttonCooldown:SetScript("OnUpdate", CooldownOnUpdate)
		buttonCooldown:Show()
		button:SetScript("OnUpdate", TotemButton_OnUpdate)
		button:Show()
	else
		buttonIcon:Hide()
		buttonDuration:Hide()
        buttonCooldown:SetScript("OnUpdate", nil)
		buttonCooldown:Hide()
		button:SetScript("OnUpdate", nil)
		button:Hide()
	end
end
