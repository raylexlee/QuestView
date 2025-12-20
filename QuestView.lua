-- QuestView Addon for Vanilla 1.12.1
-- Usage: /qv [quest title]

-- Slash command registration
SLASH_QUESTVIEW1 = "/qv"
SlashCmdList["QUESTVIEW"] = function(msg)
    QuestView_ShowQuest(msg)
end

-------------------------------------------------
-- Frame Creation
-------------------------------------------------
local f = CreateFrame("Frame", "QuestViewFrame", UIParent)
f:SetWidth(400)
f:SetHeight(300)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f:Hide()

-- Backdrop
f:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0, 0, 0, 0.95)

-- Title
f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.title:SetPoint("TOP", f, "TOP", 0, -10)

-------------------------------------------------
-- ScrollFrame + EditBox
-------------------------------------------------
local scrollFrame = CreateFrame("ScrollFrame", "QuestViewScrollFrame", f)
scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 40)

local editBox = CreateFrame("EditBox", "QuestViewEditBox", scrollFrame)
editBox:SetMultiLine(true)
editBox:SetWidth(360)
editBox:SetAutoFocus(false)
editBox:SetFontObject(GameFontHighlight)
editBox:SetJustifyH("LEFT")
editBox:SetJustifyV("TOP")
editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

scrollFrame:SetScrollChild(editBox)

-------------------------------------------------
-- Scrollbar (Vanilla-safe handler)
-------------------------------------------------
local scrollbar = CreateFrame("Slider", "QuestViewScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -16, -40)
scrollbar:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 40)
scrollbar:SetMinMaxValues(0, 1)
scrollbar:SetValueStep(1)
scrollbar:SetWidth(16)

scrollbar:SetScript("OnValueChanged", function()
    scrollFrame:SetVerticalScroll(scrollbar:GetValue())
end)

-------------------------------------------------
-- Select All Button
-------------------------------------------------
local selectButton = CreateFrame("Button", "QuestViewSelectButton", f, "UIPanelButtonTemplate")
selectButton:SetWidth(80)
selectButton:SetHeight(22)
selectButton:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
selectButton:SetText("Select All")

selectButton:SetScript("OnClick", function()
    editBox:HighlightText()
    editBox:SetFocus()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Quest text selected — press Ctrl-C to copy.|r")
end)

-------------------------------------------------
-- Close Button
-------------------------------------------------
local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

-------------------------------------------------
-- Quest Lookup
-------------------------------------------------
function QuestView_FindQuest(title)
    for i = 1, GetNumQuestLogEntries() do
        local questTitle, _, _, _, _, _, _, questID = GetQuestLogTitle(i)
        if questTitle and questTitle == title then
            return i, questID
        end
    end
    return nil
end

-------------------------------------------------
-- Show Quest Text
-------------------------------------------------
function QuestView_ShowQuest(title)
    local index = QuestView_FindQuest(title)
    if not index then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Quest not found:|r " .. (title or ""))
        return
    end

    SelectQuestLogEntry(index)
    local description, objectives = GetQuestLogQuestText()

    f.title:SetText(title or "")

    local fullText = (description or "") .. "\n\n" .. (objectives or "")
    editBox:SetText(fullText)

    -- Auto-select text for convenience
    editBox:HighlightText()
    editBox:SetFocus()

    -- Adjust scrollbar range
    local textHeight = editBox:GetHeight()
    local viewHeight = scrollFrame:GetHeight()
    local maxScroll = textHeight - viewHeight
    if maxScroll < 0 then maxScroll = 0 end
    scrollbar:SetMinMaxValues(0, maxScroll)
    scrollbar:SetValue(0)

    f:Show()
end

