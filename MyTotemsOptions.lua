local defaultSettings = {
    removeBorders = true,
    tremorPulse = true,
    earthBindPulse = true,
    cleansingPulse = true,
    searingPulse = true,
    magmaPulse = true,
    healingPulse = true,
    stoneclawPulse = true
}

local totemInfo = {
    ["Tremor Totem"] = {duration = 3, frameNumber = 1, flag = "tremorPulse", icon = "Interface\\Icons\\spell_nature_tremortotem"},
    ["Earthbind Totem"] = {duration = 3, frameNumber = 1, flag = "earthBindPulse", icon = "Interface\\Icons\\spell_nature_earthbindtotem"},
    ["Cleansing Totem"] = {duration = 3, frameNumber = 3, flag = "cleansingPulse", icon = "Interface\\Icons\\spell_nature_diseasecleansingtotem"},
    ["Searing Totem"] = {duration = 2.2, frameNumber = 2, flag = "searingPulse", icon = "Interface\\Icons\\spell_fire_searingtotem"},
    ["Magma Totem"] = {duration = 2, frameNumber = 2, flag = "magmaPulse", icon = "Interface\\Icons\\spell_fire_selfdestruct"},
    ["Healing Stream Totem"] = {duration = 2, frameNumber = 3, flag = "healingPulse", icon = "Interface\\Icons\\INV_SPEAR_04"},
    ["Stoneclaw Totem"] = {duration = 3, frameNumber = 1, flag = "stoneclawPulse", icon = "Interface\\Icons\\spell_nature_stoneclawtotem"}
}

function MyTotemsFrame:GetDefaults()
    return defaultSettings
end

function MyTotemsFrame:GetTotemInfo()
    return totemInfo
end

local function BoolToOptValue(option)
    return option and 1 or nil
end

local function CreateTextFrame(label, parent)
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetFont("fonts/frizqt__.ttf", 12)
    text:SetText(label)
    return text
end

local function GetCheckbox(option, label, parent, updateFunc, image)
	local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")

    local cbText = CreateTextFrame(label, cb)
    local offset = 0
    if image ~= nil then
        offset = 5
        local icon = cb:CreateTexture(nil, BORDER)
        icon:SetPoint("LEFT", cb, "RIGHT", 0, 0)
        icon:SetTexture(image)
        icon:SetAllPoints()
    end
    cbText:SetPoint("LEFT", cb, "RIGHT", offset, 0)

	local function UpdateOption(value)
		MyTotemsFrame.db[option] = value
		cb:SetChecked(value)
		if updateFunc then
			updateFunc(value)
		end
	end
    UpdateOption(MyTotemsFrame.db[option])
    cb:HookScript("OnClick", function(_, btn, down) UpdateOption(cb:GetChecked()) end)
	return cb
end

local function GetTotemCheckbox(option, label, parent, image)
    return GetCheckbox(option, label, parent, function() MyTotemsFrame:LaunchCooldownByOption(label) end, image)
end

function MyTotemsFrame:InitOptions()
    self.panel = CreateFrame("Frame")
    self.panel.name = "My Totems"

    local cbRemoveBorders = GetCheckbox("removeBorders", "Remove borders from default frames", self.panel, function() self:UpdateBorders() end)
	cbRemoveBorders:SetPoint("TOPLEFT", 20, -20)

    local lastFrame = cbRemoveBorders

    local pulseText = CreateTextFrame('Pulse settings', cbRemoveBorders)
    pulseText:SetPoint("TOPLEFT", 0, -30)

    for name, value in pairs(totemInfo) do
        local pulseCb = GetTotemCheckbox(value.flag, name, lastFrame, value.icon)
        local yOffset = -30
        if lastFrame == cbRemoveBorders then
            yOffset = -50
        end
        pulseCb:SetPoint("TOPLEFT", 0, yOffset)
        lastFrame = pulseCb
    end

    InterfaceOptions_AddCategory(self.panel)
end