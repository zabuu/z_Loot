-- zLoot core helpers: compact item/loot decoding, item cache queries, list selection.
-- Lua 5.0 (WoW 1.12): no string.match/gmatch, no #, no %, no select().

ZLDB = ZLDB or {}
ZL_ShowRaids = false
ZL_ShowCollections = false

local strfind, strsub, tonumber, tinsert, getn = string.find, string.sub, tonumber, table.insert, table.getn

-- split s by a single-char separator (plain), keeping empty fields
local function split(s, sep)
    local out = {}
    local start = 1
    while true do
        local a = strfind(s, sep, start, true)
        if not a then
            tinsert(out, strsub(s, start))
            break
        end
        tinsert(out, strsub(s, start, a - 1))
        start = a + 1
    end
    return out
end
ZL_Split = split

local QualityByIndex = {[0] = "Poor", [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary", [6] = "Legendary"}

local EquipLocToSlot = {
    INVTYPE_HEAD = "Head", INVTYPE_NECK = "Neck", INVTYPE_SHOULDER = "Shoulder", INVTYPE_BODY = "Shirt",
    INVTYPE_CHEST = "Chest", INVTYPE_ROBE = "Chest", INVTYPE_WAIST = "Waist", INVTYPE_LEGS = "Legs",
    INVTYPE_FEET = "Feet", INVTYPE_WRIST = "Wrist", INVTYPE_HAND = "Hands", INVTYPE_FINGER = "Finger",
    INVTYPE_TRINKET = "Trinket", INVTYPE_CLOAK = "Back", INVTYPE_WEAPON = "OneHand", INVTYPE_SHIELD = "OffHand",
    INVTYPE_2HWEAPON = "TwoHand", INVTYPE_WEAPONMAINHAND = "MainHand", INVTYPE_WEAPONOFFHAND = "OffHand",
    INVTYPE_HOLDABLE = "HeldInOffHand", INVTYPE_RANGED = "Ranged", INVTYPE_RANGEDRIGHT = "Ranged",
    INVTYPE_THROWN = "Ranged", INVTYPE_RELIC = "Relic", INVTYPE_TABARD = "Tabard", INVTYPE_BAG = "Bag",
    INVTYPE_AMMO = "Projectile", INVTYPE_QUIVER = "Quiver"
}

local SubTypeToType = {
    ["Cloth"] = "Cloth", ["Leather"] = "Leather", ["Mail"] = "Mail", ["Plate"] = "Plate", ["Shields"] = "Shield",
    ["Bows"] = "Bow", ["Guns"] = "Gun", ["Crossbows"] = "Crossbow", ["Daggers"] = "Dagger", ["Fist Weapons"] = "FistWeapon",
    ["One-Handed Axes"] = "Axe", ["Two-Handed Axes"] = "TwoHandedAxe", ["One-Handed Maces"] = "Mace",
    ["Two-Handed Maces"] = "TwoHandedMace", ["One-Handed Swords"] = "Sword", ["Two-Handed Swords"] = "TwoHandedSword",
    ["Staves"] = "Staff", ["Polearms"] = "Polearm", ["Wands"] = "Wand", ["Thrown"] = "ThrownWeapon",
    ["Idols"] = "Idol", ["Librams"] = "Libram", ["Totems"] = "Totem", ["Fishing Pole"] = "FishingPole",
    ["Arrow"] = "Arrow", ["Bullet"] = "Bullet"
}

local function shortIcon(tex)
    if not tex then
        return nil
    end
    local a, b = strfind(tex, "[Ii]cons\\")
    if b then
        return strsub(tex, b + 1)
    end
    return tex
end

-- Pending item info requests (items the client has not cached yet)
local pending = {}
local pendingCount = 0
local queryTip
local refreshFrame = CreateFrame("Frame")
refreshFrame:Hide()
local refreshTimer, refreshTries = 0, 0

function ZL_QueryItem(id)
    if not id or pending[id] then
        return
    end
    if not queryTip then
        queryTip = CreateFrame("GameTooltip", "ZL_QueryTooltip", UIParent, "GameTooltipTemplate")
    end
    queryTip:SetOwner(UIParent, "ANCHOR_NONE")
    queryTip:SetHyperlink("item:" .. id .. ":0:0:0")
    queryTip:Hide()
    pending[id] = true
    pendingCount = pendingCount + 1
    refreshTries = 0
    refreshFrame:Show()
end

-- Re-draw the current loot view a few times while the server answers item queries
refreshFrame:SetScript("OnUpdate", function()
    refreshTimer = refreshTimer + arg1
    if refreshTimer < 0.7 then
        return
    end
    refreshTimer = 0
    refreshTries = refreshTries + 1

    local stillMissing = 0
    for id in pairs(pending) do
        if GetItemInfo(id) then
            pending[id] = nil
            pendingCount = pendingCount - 1
        else
            stillMissing = stillMissing + 1
        end
    end

    if ZL_RefreshLootView then
        ZL_RefreshLootView()
    end

    if stillMissing == 0 or refreshTries >= 6 then
        pending = {}
        pendingCount = 0
        this:Hide()
    end
end)

-- Builds a fresh item table (callers copy/modify it freely)
function ZL_GetItem(id)
    id = tonumber(id)
    if not id then
        return nil
    end

    local s = ZLDB.IS and ZLDB.IS[id]
    if s then
        local f = split(s, "|")
        local item = {
            Id = tostring(id),
            Name = f[1],
            Icon = (f[2] and f[2] ~= "") and f[2] or nil,
            Quality = ZLLib.Quality[f[3] or ""] or ZLLib.Quality.Common,
            ItemSlot = f[4] and ZLLib.ItemSlot[f[4]] or nil,
            ItemType = f[5] and ZLLib.ItemType[f[5]] or nil
        }
        if f[6] and f[6] ~= "" then
            item.ClassRestriction = {}
            for _, c in ipairs(split(f[6], ",")) do
                tinsert(item.ClassRestriction, ZLLib.Classes[c] or c)
            end
        end
        if f[7] and f[7] ~= "" then
            item.ChallengeRestriction = {}
            for _, c in ipairs(split(f[7], ",")) do
                tinsert(item.ChallengeRestriction, ZLLib.Challenges[c] or c)
            end
        end
        local liveName = GetItemInfo(id)
        if not liveName then
            item.Uncached = true
        end
        return item
    end

    local name, _, quality, _, _, subType, _, equipLoc, texture = GetItemInfo(id)
    if not name then
        return {Id = tostring(id), Name = ZLDB.CN and ZLDB.CN[id], Quality = ZLLib.Quality.Common, Uncached = true}
    end

    local item = {
        Id = tostring(id),
        Name = name,
        Icon = shortIcon(texture),
        Quality = ZLLib.Quality[QualityByIndex[quality or 1] or "Common"] or ZLLib.Quality.Common
    }
    local slotKey = equipLoc and EquipLocToSlot[equipLoc]
    if slotKey then
        item.ItemSlot = ZLLib.ItemSlot[slotKey]
    end
    local typeKey = subType and SubTypeToType[subType]
    if typeKey and slotKey then
        item.ItemType = ZLLib.ItemType[typeKey]
    end
    return item
end

-- Decodes a boss/page loot string into IJ-style entries: { [1] = item, DropChance = n, ... }
-- Journal format:     "id:chance[:h][:nN],..."
-- Collection format:  rows separated by \30, fields by \31: "id\31drop\31desc\31containerIds" or "#Header\31icon"
function ZL_LootEntries(boss)
    local out = {}
    local s = boss and boss.L
    if not s or s == "" then
        return out
    end

    if strfind(s, "\30", 1, true) or strfind(s, "\31", 1, true) or boss.IsCollection then
        for _, row in ipairs(split(s, "\30")) do
            if strsub(row, 1, 1) == "#" then
                local f = split(strsub(row, 2), "\31")
                tinsert(out, {Header = f[1], HeaderIcon = f[2]})
            elseif row ~= "" then
                local f = split(row, "\31")
                local item = ZL_GetItem(f[1])
                if item then
                    local e = {item}
                    if f[2] and f[2] ~= "" then
                        e.DropChance = tonumber(f[2])
                    end
                    if f[3] and f[3] ~= "" then
                        e.Disc = f[3]
                    end
                    if f[4] and f[4] ~= "" then
                        e.Container = split(f[4], " ")
                    end
                    if f[5] and f[5] ~= "" then
                        e.Sources = {}
                        for _, src in ipairs(split(f[5], "\28")) do
                            if strsub(src, 1, 1) == "+" then
                                e.Sources.more = tonumber(strsub(src, 2))
                            else
                                local p = split(src, "\29")
                                tinsert(e.Sources, {Boss = p[1], Instance = p[2], Rate = tonumber(p[3] or "")})
                            end
                        end
                    end
                    tinsert(out, e)
                end
            end
        end
        return out
    end

    for _, part in ipairs(split(s, ",")) do
        local f = split(part, ":")
        local item = ZL_GetItem(f[1])
        if item then
            local e = {item}
            if f[2] and f[2] ~= "" then
                e.DropChance = tonumber(f[2])
            end
            for i = 3, getn(f) do
                local flag = f[i]
                if flag == "h" then
                    e.IsHardMode = true
                elseif strsub(flag, 1, 1) == "n" then
                    e.Note = ZLDB.Notes and ZLDB.Notes[tonumber(strsub(flag, 2))]
                end
            end
            tinsert(out, e)
        end
    end
    return out
end

function ZL_GetActiveList()
    if ZL_ShowCollections then
        return ZLDB.C
    elseif ZL_ShowRaids then
        return ZLDB.R
    end
    return ZLDB.DG
end

function ZL_IsCollection(inst)
    return inst and inst.IsCollection and true or false
end

-- Selects the top tab that owns an instance (1 dungeons, 2 raids, 3 collections)
function ZL_SelectTabForInstance(inst)
    local tab = 1
    if ZL_IsCollection(inst) then
        tab = 3
    else
        for _, r in pairs(ZLDB.R or {}) do
            if r == inst then
                tab = 2
                break
            end
        end
    end
    ZL_ShowRaids = (tab == 2)
    ZL_ShowCollections = (tab == 3)
    if ZL_InstanceJournalFrame then
        PanelTemplates_SetTab(ZL_InstanceJournalFrame, tab)
    end
    return tab
end

-- Allocation-light helpers for search: walk the item ids of a loot string without building tables
function ZL_ForEachLootId(boss, fn)
    local s = boss and boss.L
    if not s or s == "" then
        return
    end
    if strfind(s, "\30", 1, true) or strfind(s, "\31", 1, true) or boss.IsCollection then
        for id in string.gfind("\30" .. s, "\30(%d+)") do
            fn(tonumber(id))
        end
    else
        for id in string.gfind("," .. s, ",(%d+)") do
            fn(tonumber(id))
        end
    end
end

function ZL_GetItemName(id)
    local s = ZLDB.IS and ZLDB.IS[id]
    if s then
        local bar = strfind(s, "|", 1, true)
        return bar and strsub(s, 1, bar - 1) or s
    end
    return (GetItemInfo(id)) or (ZLDB.CN and ZLDB.CN[id])
end
