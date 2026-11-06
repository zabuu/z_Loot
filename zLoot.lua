-- zLoot entry points: slash commands, key binding, first-time SHIFT-J.
-- Lua 5.0 (WoW 1.12).

BINDING_HEADER_ZSUITE = BINDING_HEADER_ZSUITE or "zSuite"
BINDING_NAME_ZLOOT_TOGGLE = "Toggle zLoot"

local function say(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100zLoot:|r " .. msg)
end

local function ensureLoaded()
    if ZL_Toggle then
        return true
    end
    say("window failed to load; check for Lua errors at login.")
    return false
end

function ZLoot_Toggle()
    if ensureLoaded() then
        ZL_Toggle()
    end
end

SLASH_ZLOOT1 = "/zloot"
SLASH_ZLOOT2 = "/zl"
SlashCmdList["ZLOOT"] = function()
    ZLoot_Toggle()
end

local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function()
    f:UnregisterEvent("VARIABLES_LOADED")

    -- keep the old /ij habit working once InstanceJournal is turned off
    if not IsAddOnLoaded("InstanceJournal") then
        SLASH_ZLOOTIJ1 = "/ij"
        SlashCmdList["ZLOOTIJ"] = ZLoot_Toggle
    end

    -- one-time: put zLoot on SHIFT-J if that key is free (or still points at a disabled InstanceJournal)
    if not ZL_FirstTimeBindingDone then
        local action = GetBindingAction("SHIFT-J")
        if action == nil or action == "" or (action == "TOGGLEJOURNAL" and not IsAddOnLoaded("InstanceJournal")) then
            if SetBinding("SHIFT-J", "ZLOOT_TOGGLE") then
                SaveBindings(GetCurrentBindingSet())
                say("bound to SHIFT-J. Also /zloot.")
            end
            ZL_FirstTimeBindingDone = true
        elseif action ~= "TOGGLEJOURNAL" then
            ZL_FirstTimeBindingDone = true
        end
    end
end)
