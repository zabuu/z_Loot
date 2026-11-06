-- Map art for each instance floor, by the client's own WorldMap file names (from this OctoWoW client,
-- via z_Map's generated data). Index = floor number used by the boss coordinates (MapId on a boss).
-- [0] is used for instances without floors. WORLD bosses are mapped by name.

ZL_MapFiles = {
    AQ20 = {[0] = "RuinsofAhnQiraj"},
    AQ40 = {[1] = "AhnQiraj", [2] = "AhnQiraj2f"},
    BFD = {[0] = "BlackFathomDeeps"},
    BM = {[1] = "BlackMorass", [2] = "BlackMorass2f"},
    BRD = {[0] = "BlackrockDepths"},
    BWL = {[0] = "BlackwingLair"},
    CG = {[0] = "CrescentGrove"},
    DEADMINES = {[0] = "TheDeadmines"},
    DME = {[0] = "DireMaul"},
    DMN = {[0] = "DireMaul"},
    DMW = {[0] = "DireMaul"},
    DMR = {[0] = "DragonmawRetreat"},
    ES = {[0] = "EmeraldSanctum"},
    FH = {[0] = "FrostmaneHollow"},
    GC = {[0] = "GilneasCity"},
    GNOMEREGAN = {[0] = "Gnomeregan"},
    HQ = {[0] = "HateforgeQuarry"},
    KARA10 = {[0] = "Karazhan"},
    KARA40 = {[1] = "UpperKarazhan2f", [2] = "UpperKarazhan"},
    KC = {[0] = "KarazhanCrypt"},
    LBRS = {[0] = "BlackrockSpire"},
    UBRS = {[0] = "BlackrockSpire"},
    MARA = {[0] = "Maraudon"},
    MC = {[0] = "MoltenCore"},
    NAXX = {[1] = "Naxxramas", [2] = "Naxxramas2f"},
    ONY = {[0] = "OnyxiasLair"},
    RFC = {[0] = "Ragefire"},
    RFD = {[0] = "RazorfenDowns"},
    RFK = {[0] = "RazorfenKraul"},
    SCHOLO = {[0] = "Scholomance"},
    SFK = {[0] = "ShadowfangKeep"},
    SMARM = {[1] = "ScarletMonastery3f"},
    SMCATH = {[2] = "ScarletMonastery4f"},
    SMGY = {[3] = "ScarletMonastery"},
    SMLIB = {[4] = "ScarletMonastery2f"},
    ST = {[0] = "TheTempleOfAtalHakkar"},
    STOCKADES = {[0] = "TheStockade"},
    STRAT = {[0] = "Stratholme"},
    SV = {[0] = "StormwindVault"},
    SWR = {[0] = "StormwroughtRuins"},
    TH = {[0] = "Timbermaw"},
    ULDA = {[0] = "Uldaman"},
    WC = {[0] = "WailingCaverns"},
    WHC = {[0] = "WindhornCanyon"},
    ZF = {[0] = "ZulFarrak"},
    ZG = {[0] = "ZulGurub"},
}

-- Floor names shown on the floor buttons
ZL_MapFileNames = {
    AhnQiraj = "Temple", AhnQiraj2f = "Upper level", BlackMorass = "The swamp", BlackMorass2f = "The Black Morass",
    UpperKarazhan = "Tower of Karazhan", UpperKarazhan2f = "The Rock of Desolation",
    Naxxramas = "Naxxramas", Naxxramas2f = "The Upper Necropolis",
    Aszhara = "Azshara", Desolace = "Desolace", Ashenvale = "Ashenvale", Feralas = "Feralas", Tanaris = "Tanaris",
    BlastedLands = "Blasted Lands", DeadwindPass = "Deadwind Pass", EasternPlaguelands = "Eastern Plaguelands",
    Duskwood = "Duskwood", Hinterlands = "The Hinterlands",
}

ZL_WorldBossFiles = {
    ["Azuregos"] = "Aszhara", ["Cla'ckora"] = "Aszhara", ["Concavius"] = "Desolace", ["Taerar"] = "Ashenvale",
    ["Ysondre"] = "Feralas", ["Ostarius"] = "Tanaris", ["Lord Kazzak"] = "BlastedLands",
    ["Dark Reaver of Karazhan"] = "DeadwindPass", ["Nerubian Overseer"] = "EasternPlaguelands",
    ["Emeriss"] = "Duskwood", ["Lethon"] = "Hinterlands",
}

-- The map file a boss is drawn on, or nil
function ZL_BossMapFile(instance, boss)
    if not boss.MapCoordinateX then
        return nil
    end
    if instance.Key == "WORLD" then
        return ZL_WorldBossFiles[boss.Name]
    end
    local files = ZL_MapFiles[instance.Key]
    if not files then
        return nil
    end
    if boss.MapZoneId then
        return nil
    end
    if boss.MapId then
        return files[tonumber(boss.MapId)] or files[0]
    end
    if files[0] then
        return files[0]
    end
    for _, f in pairs(files) do
        return f
    end
end

-- Ordered list of map files used by an instance
function ZL_InstanceMapFiles(instance)
    if not instance or instance.IsCollection or not instance.Bosses then
        return {}
    end
    if instance.MapFilesCache then
        return instance.MapFilesCache
    end
    local out, seen = {}, {}
    local files = ZL_MapFiles[instance.Key]
    if files then
        for i = 0, 9 do
            local f = files[i]
            if f and not seen[f] then
                seen[f] = true
                table.insert(out, f)
            end
        end
    end
    -- keep only floors that actually have bosses, except single-floor instances
    local used = {}
    for _, b in ipairs(instance.Bosses) do
        local f = ZL_BossMapFile(instance, b)
        if f then
            used[f] = true
            if not seen[f] then
                seen[f] = true
                table.insert(out, f)
            end
        end
    end
    local final = {}
    for _, f in ipairs(out) do
        if used[f] then
            table.insert(final, f)
        end
    end
    instance.MapFilesCache = final
    return final
end
