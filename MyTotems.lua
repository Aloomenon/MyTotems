MyTotemsFrame = CreateFrame("Frame", "MyTotems")

local addonEnabled = false

function MyTotemsFrame:OnEvent(event, addOnName)
    if addOnName == "MyTotems" then
        if MyTotems_DB == nil then
            MyTotems_DB = CopyTable(MyTotemsFrame:GetDefaults())
        end
        self.db = MyTotems_DB
        self:InitOptions()
        self:Init()
        self:UnregisterEvent(event)
    end
end

MyTotemsFrame:SetScript("OnEvent", MyTotemsFrame.OnEvent)
MyTotemsFrame:RegisterEvent("ADDON_LOADED")

local TOTEM_INFO = {
    ["Tremor Totem"] = {duration = 3, slot = 2, flag = function() return MyTotemsFrame.db.tremorPulse end},
    ["Earthbind Totem"] = {duration = 3, slot = 2, flag = function() return MyTotemsFrame.db.earthBindPulse end},
    ["Cleansing Totem"] = {duration = 3, slot = 3, flag = function() return MyTotemsFrame.db.cleansingPulse end},
    ["Searing Totem"] = {duration = 2.2, slot = 1, flag = function() return MyTotemsFrame.db.searingPulse end}, -- scaling by haste ?
    ["Magma Totem"] = {duration = 2, slot = 1, flag = function() return MyTotemsFrame.db.magmaPulse end},
    ["Healing Stream Totem"] = {duration = 2, slot = 2, flag = function() return MyTotemsFrame.db.healingPulse end},
    ["Stoneclaw Totem"] = {duration = 3, slot = 2, flag = function() return MyTotemsFrame.db.stoneclawPulse end}
}

function MyTotemsFrame:UpdateBorders()
    local removeBorders = self.db.removeBorders
    print(self.db, self.db.removeBorders)
    local function UpdateBorder(frame)
        if removeBorders then
            frame:Hide()
        else
            frame:Show()
        end
    end

    local totem1, totem2, totem3, totem4 = TotemFrame:GetChildren()
    for i, totemFrame in ipairs({totem1, totem2, totem3, totem4}) do
        local frameIcon, overlayFrame = totemFrame:GetChildren()

        if overlayFrame:GetFrameLevel() < frameIcon:GetFrameLevel() then
            overlayFrame = frameIcon
        end
        UpdateBorder(overlayFrame)

        local frBackground = _G[totemFrame:GetName()..'Background']
        UpdateBorder(frBackground)
    end
end

function MyTotemsFrame:Init()
    if UnitClass("player") == "Shaman" then
        addonEnabled = true
        self:UpdateBorders()
    end
end

local function RemoveTotemRank(totemName)
    local i, n = string.find(totemName, "Totem")
    return string.sub(totemName, 0, n)
end

local function GetTotemData(cdButton)
    local _, totemName, startTime, duration = GetTotemInfo(cdButton:GetParent():GetParent().slot)
    return totemName, startTime, duration
end

local function SetCooldown(frame, pulseTime, duration)
    frame:SetCooldown(pulseTime, duration, true)
    frame.lastPulse = pulseTime
end

local function CooldownOnUpdate(cdButton, elapsed)
    local totemName, startTime, duration = GetTotemData(cdButton)
    local info = TOTEM_INFO[RemoveTotemRank(totemName)]

    if info ~= nil and info.flag() then
        duration = info.duration
        startTime = GetTime()
    else
        cdButton:SetScript("OnUpdate", nil)
        cdButton.lastPulse = 0
    end
    
    if cdButton.lastPulse + duration <= startTime then
        SetCooldown(cdButton, startTime, duration)
    end
end

local function InitCooldown(button)
    button.lastPulse = 0
    button.startTime = GetTime()
    CooldownOnUpdate(button)
end

local function GetButtonBySlot(slot)
    local buttonNum
    if slot == 1 then
        buttonNum = 2
    elseif slot == 2 then
        buttonNum = 1
    else
        buttonNum = slot
    end
    return _G["TotemFrameTotem"..buttonNum.."IconCooldown"]
end

function MyTotemsFrame:LaunchCooldownByOption(totemName, optValue)
    local info = TOTEM_INFO[totemName]
    local cdButton = GetButtonBySlot(info.slot)
    local _, _, startTime, duration = GetTotemInfo(info.slot)
    local lastPulseTime = GetTime() - ((GetTime() - (cdButton.startTime or startTime)) % info.duration)
    
    SetCooldown(cdButton, lastPulseTime, info.duration)
    cdButton:SetScript("OnUpdate", CooldownOnUpdate)
    
end

function TotemButton_Update(button, startTime, duration, icon)
	local buttonName = button:GetName()
	local buttonIcon = _G[buttonName.."IconTexture"]
	local buttonDuration = _G[buttonName.."Duration"]
	local buttonCooldown = _G[buttonName.."IconCooldown"]
	if ( duration > 0 ) then
		buttonIcon:SetTexture(icon)
		buttonIcon:Show()
        InitCooldown(buttonCooldown)
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
