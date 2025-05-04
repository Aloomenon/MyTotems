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

function MyTotemsFrame:GetDefaults()
    return defaultSettings
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
    --cb:SetChecked(MyTotemsFrame.db[option])
    cb:HookScript("OnClick", function(_, btn, down) UpdateOption(cb:GetChecked()) end)
	return cb
end

local function GetTotemCheckbox(option, label, parent, image)
    return GetCheckbox(option, label, parent, function(value) if value == 1 then MyTotemsFrame:LaunchCooldownByOption(label, value) end end, image)
end

function MyTotemsFrame:InitOptions()
    self.panel = CreateFrame("Frame")
    self.panel.name = "My Totems"

    local cbRemoveBorders = GetCheckbox("removeBorders", "Remove borders from default frames", self.panel, function() self:UpdateBorders() end)
	cbRemoveBorders:SetPoint("TOPLEFT", 20, -20)

    local pulseText = CreateTextFrame('Pulse settings', cbRemoveBorders)
    pulseText:SetPoint("TOPLEFT", 0, -30)

	local tremorPulse = GetTotemCheckbox("tremorPulse", "Tremor Totem", cbRemoveBorders, "Interface\\Icons\\spell_nature_tremortotem")
	tremorPulse:SetPoint("TOPLEFT", 0, -50)

    local earthbindPulse = GetTotemCheckbox("earthBindPulse", "Earthbind Totem", tremorPulse, "Interface\\Icons\\spell_nature_earthbindtotem")
	earthbindPulse:SetPoint("TOPRIGHT", 100, 0)

    local cleansingPulse = GetTotemCheckbox("cleansingPulse", "Cleansing Totem", earthbindPulse, "Interface\\Icons\\spell_nature_diseasecleansingtotem")
	cleansingPulse:SetPoint("TOPRIGHT", 100, 0)

    local searingPulse = GetTotemCheckbox("searingPulse", "Searing Totem", tremorPulse, "Interface\\Icons\\spell_fire_searingtotem")
	searingPulse:SetPoint("TOPLEFT", 0, -30)

    local magmaPulse = GetTotemCheckbox("magmaPulse", "Magma Totem", searingPulse, "Interface\\Icons\\spell_fire_selfdestruct")
	magmaPulse:SetPoint("TOPRIGHT", 100, 0)

    local healingPulse = GetTotemCheckbox("healingPulse", "Healing Stream Totem", magmaPulse, "Interface\\Icons\\INV_SPEAR_04")
	healingPulse:SetPoint("TOPRIGHT", 100, 0)

    local stoneclawPulse = GetTotemCheckbox("stoneclawPulse", "Stoneclaw Totem", searingPulse, "Interface\\Icons\\spell_nature_stoneclawtotem")
	stoneclawPulse:SetPoint("TOPLEFT", 0, -30)

    InterfaceOptions_AddCategory(self.panel)
end