MyTotemsFrame = CreateFrame("Frame", "MyTotems")
local addonEnabled = false

function MyTotemsFrame:OnEvent(event, addOnName)
    if addOnName == "MyTotems" then
        if MyTotems_DB == nil then
            MyTotems_DB = CopyTable(MyTotemsFrame:GetDefaults())
        end
        self.db = MyTotems_DB
        self:Init()
        
        self:InitOptions()
        self:UnregisterEvent(event)
    end
end

MyTotemsFrame:SetScript("OnEvent", MyTotemsFrame.OnEvent)
MyTotemsFrame:RegisterEvent("ADDON_LOADED")

function MyTotemsFrame:UpdateBorders()
    local removeBorders = self.db.removeBorders

    if not addonEnabled then
        return
    end

    local function UpdateFrameVisibility(frame)
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
        UpdateFrameVisibility(overlayFrame)

        local frBackground = _G[totemFrame:GetName()..'Background']
        UpdateFrameVisibility(frBackground)
    end
end

function MyTotemsFrame:Init()
    if UnitClass("player") == "Shaman" then
        addonEnabled = true
    end
end

local function RemoveTotemRank(totemName)
    local i, n = string.find(totemName, "Totem")
    return string.sub(totemName, 0, n)
end

local function GetTotemData(cdButton)
    local slot = cdButton:GetParent():GetParent().slot
    if slot == 0 then
        return true, "", 0, 0
    end
    local _, totemName, startTime, duration = GetTotemInfo(slot)
    return totemName, startTime, duration
end

local function SetCooldown(frame, pulseTime, duration)
    frame:SetCooldown(pulseTime, duration, true)
    frame.lastPulse = pulseTime
end

local function CooldownOnUpdate(cdButton, elapsed)
    local totemName, startTime, duration = GetTotemData(cdButton)
    local info = MyTotemsFrame:GetTotemInfo()[RemoveTotemRank(totemName)]

    if info ~= nil and MyTotemsFrame.db[info.flag] then
        duration = info.duration
        startTime = GetTime()
        if cdButton:GetScript("OnUpdate") == nil then
            MyTotemsFrame:EnableButtonCooldown(cdButton)
        end

        if cdButton.lastPulse + duration <= startTime then
            SetCooldown(cdButton, startTime, duration)
        end
    else
        MyTotemsFrame:DisableButton(cdButton)
    end
end

local function InitCooldown(button)
    button.lastPulse = 0
    button.startTime = GetTime()
    button:Show()
    CooldownOnUpdate(button)
end

local function GetCdButtonByFrameNumber(buttonNum)
    return _G["TotemFrameTotem"..buttonNum.."IconCooldown"]
end


function MyTotemsFrame:DisableButton(button)
    button:SetScript("OnUpdate", nil)
    button:Hide()
end

function MyTotemsFrame:EnableButtonCooldown(button)
    button:SetScript("OnUpdate", CooldownOnUpdate)
    button:Show()
end

function MyTotemsFrame:LaunchCooldownByOption(totemName)
    if not addonEnabled then
        return
    end
    local info = MyTotemsFrame:GetTotemInfo()[totemName]
    local cdButton = GetCdButtonByFrameNumber(info.frameNumber)
    
    if MyTotemsFrame.db[info.flag] ~= 1 then
        self:DisableButton(cdButton)
        return
    end

    local _, totem, startTime, duration = GetTotemData(cdButton)
    if totem == "" then
        return
    end
    
    local lastPulseTime = GetTime() - ((GetTime() - (cdButton.startTime or startTime)) % info.duration)

    SetCooldown(cdButton, lastPulseTime, info.duration)
    self:EnableButtonCooldown(cdButton)
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
        button:SetScript("OnUpdate", TotemButton_OnUpdate)
        button:Show()
	else
		buttonIcon:Hide()
		buttonDuration:Hide()
        MyTotemsFrame:DisableButton(buttonCooldown)
        MyTotemsFrame:DisableButton(button)
	end
end
