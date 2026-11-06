-- z_Loot init. Saved variables arrive at VARIABLES_LOADED.
-- The loot data stays packed as two strings (Packed.lua) until zLoot is first opened.

ZL_Settings = ZL_Settings or {}

function ZL_EnsureData()
    if not ZL_PackedData then
        return
    end
    for i = 1, table.getn(ZL_PackedData) do
        local chunk, err = loadstring(ZL_PackedData[i], "z_Loot data " .. i)
        if chunk then
            chunk()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100zLoot:|r data error: " .. tostring(err))
        end
    end
    ZL_PackedData = nil

    for i, inst in ipairs(ZLDB.C or {}) do
        inst.IsCollection = true
        inst.Order = i
        for _, b in ipairs(inst.Bosses or {}) do
            b.IsCollection = true
        end
    end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("VARIABLES_LOADED")
initFrame:SetScript("OnEvent", function()
    this:UnregisterEvent("VARIABLES_LOADED")
    this:SetScript("OnEvent", nil)
    ZL_Settings = ZL_Settings or {}
    if not ZL_FilterClass then
        local _, token = UnitClass("player")
        for loc, unloc in pairs(ZLLib.ClassUnlocalizedLinks) do
            if unloc == token then
                ZL_FilterClass = loc
            end
        end
        ZL_FilterClass = ZL_FilterClass or "ALL"
    end
end)
