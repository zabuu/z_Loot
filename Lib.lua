ZLLib = ZLLib or {}

ZLLib.MediaPath = "Interface\\AddOns\\z_Loot\\Media\\"
ZLLib.MediaPathDungeons = "dungeons\\"
ZLLib.MediaPathRaids = "raids\\"
ZLLib.MediaPathPois = "pois\\"
ZLLib.MediaPathPortrait = "-portrait"
ZLLib.MediaPathFrame = "-frame"

ZLLib.StrataOrder = {"BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"}

ZLLib.EntranceIconType = {Up = "map-icon-up", Down = "map-icon-down", Left = "map-icon-left", Right = "map-icon-right"}

ZLLib.Colors = {
    Red = {Hex = "|cffdb2121", RGB = {0.85, 0.1, 0.1}},
    LightRed = {Hex = "|cffffaaaa", RGB = {1.0, 0.66, 0.66}},
    DarkRed = {Hex = "|cff980302", RGB = {0.59, 0.01, 0}},
    Orange = {Hex = "|cffff8040", RGB = {1.0, 0.50, 0.25}},
    DarkOrange = {Hex = "|cffff7c0a", RGB = {1.0, 0.49, 0.04}},
    DarkerOrange = {Hex = "|cffff8000", RGB = {1.0, 0.50, 0}},
    Yellow = {Hex = "|cffffff00", RGB = {1.0, 1.0, 0}},
    LightYellow = {Hex = "|cfffff468", RGB = {1.0, 0.96, 0.41}},
    Green = {Hex = "|cff40bd40", RGB = {0.25, 0.74, 0.25}},
    LightGreen = {Hex = "|cff1eff00", RGB = {0.11, 1.0, 0}},
    DarkGreen = {Hex = "|cff007514", RGB = {0, 0.45, 0.07}},
    Pistachio = {Hex = "|cffaad372", RGB = {0.67, 0.83, 0.45}},
    Blue = {Hex = "|cff0070dd", RGB = {0, 0.44, 0.87}},
    LightBlue = {Hex = "|cff3fc7eb", RGB = {0.25, 0.78, 0.92}},
    Purple = {Hex = "|cffa335ee", RGB = {0.63, 0.20, 0.93}},
    DarkPurple = {Hex = "|cff7b03fc", RGB = {0.48, 0.01, 0.98}},
    DarkerPurple = {Hex = "|cff5e185e", RGB = {0.36, 0.09, 0.36}},
    LightPurple = {Hex = "|cff8788ee", RGB = {0.53, 0.53, 0.93}},
    Pink = {Hex = "|cfff48cba", RGB = {0.96, 0.55, 0.73}},
    Gray = {Hex = "|cff808080", RGB = {0.50, 0.50, 0.50}},
    Tan = {Hex = "|cffc69b6d", RGB = {0.78, 0.61, 0.43}},
    LightGray = {Hex = "|cffcccccc", RGB = {0.8, 0.8, 0.8}},
    MediumGray = {Hex = "|cff9d9d9d", RGB = {0.61, 0.61, 0.61}},
    DarkGray = {Hex = "|cff555555", RGB = {0.33, 0.33, 0.33}},
    White = {Hex = "|cffffffff", RGB = {1.0, 1.0, 1.0}},
    Black = {Hex = "|cff000000", RGB = {0, 0, 0}}
}

ZLLib.Quality = {Poor = ZLLib.Colors.MediumGray, Common = ZLLib.Colors.White, Uncommon = ZLLib.Colors.LightGreen, Rare = ZLLib.Colors.Blue, Epic = ZLLib.Colors.Purple, Legendary = ZLLib.Colors.DarkerOrange}

ZLLib.ItemSlot = {
    Head = ZL_ITEMSLOT_HEAD,
    Neck = ZL_ITEMSLOT_NECK,
    Shoulder = ZL_ITEMSLOT_SHOULDER,
    Shirt = ZL_ITEMSLOT_SHIRT,
    Chest = ZL_ITEMSLOT_CHEST,
    Waist = ZL_ITEMSLOT_WAIST,
    Legs = ZL_ITEMSLOT_LEGS,
    Feet = ZL_ITEMSLOT_FEET,
    Wrist = ZL_ITEMSLOT_WRIST,
    Hands = ZL_ITEMSLOT_HANDS,
    Finger = ZL_ITEMSLOT_FINGER,
    Trinket = ZL_ITEMSLOT_TRINKET,
    Back = ZL_ITEMSLOT_BACK,
    MainHand = ZL_ITEMSLOT_MAINHAND,
    OffHand = ZL_ITEMSLOT_OFFHAND,
    HeldInOffHand = ZL_ITEMSLOT_HELDINOFFHAND,
    Ranged = ZL_ITEMSLOT_RANGED,
    Tabard = ZL_ITEMSLOT_TABARD,
    OneHand = ZL_ITEMSLOT_ONEHAND,
    TwoHand = ZL_ITEMSLOT_TWOHAND,
    Relic = ZL_ITEMSLOT_RELIC,
    Other = ZL_ITEMSLOT_OTHER,
    Pet = ZL_ITEMSLOT_PET,
    Transmog = ZL_ITEMSLOT_TRANSMOG,
    Quest = ZL_ITEMSLOT_QUEST,
    Ability = ZL_ITEMSLOT_ABILITY,
    Mount = ZL_ITEMSLOT_MOUNT,
    Bag = ZL_ITEMSLOT_BAG,
    Profession = ZL_ITEMSLOT_PROFESSION,
    Reagent = ZL_ITEMSLOT_REAGENT,
    Toy = ZL_ITEMSLOT_TOY,
    Enchantment = ZL_ITEMSLOT_ENCHANTMENT,
    Projectile = ZL_ITEMSLOT_PROJECTILE,
    AmmoPouch = ZL_ITEMSLOT_AMMOPOUCH,
    Quiver = ZL_ITEMSLOT_QUIVER,
    Key = ZL_ITEMSLOT_KEY
}

ZLLib.ItemType = {
    Polearm = ZL_ITEMTYPE_POLEARM,
    Staff = ZL_ITEMTYPE_STAFF,
    Axe = ZL_ITEMTYPE_AXE,
    TwoHandedAxe = ZL_ITEMTYPE_AXE,
    Mace = ZL_ITEMTYPE_MACE,
    TwoHandedMace = ZL_ITEMTYPE_MACE,
    Sword = ZL_ITEMTYPE_SWORD,
    TwoHandedSword = ZL_ITEMTYPE_SWORD,
    Bow = ZL_ITEMTYPE_BOW,
    Crossbow = ZL_ITEMTYPE_CROSSBOW,
    Dagger = ZL_ITEMTYPE_DAGGER,
    FistWeapon = ZL_ITEMTYPE_FISTWEAPON,
    Gun = ZL_ITEMTYPE_GUN,
    ThrownWeapon = ZL_ITEMTYPE_THROWNWEAPON,
    Wand = ZL_ITEMTYPE_WAND,
    FishingPole = ZL_ITEMTYPE_FISHINGPOLE,
    Cloth = ZL_ITEMTYPE_CLOTH,
    Leather = ZL_ITEMTYPE_LEATHER,
    Mail = ZL_ITEMTYPE_MAIL,
    Plate = ZL_ITEMTYPE_PLATE,
    Shield = ZL_ITEMTYPE_SHIELD,
    Idol = ZL_ITEMTYPE_IDOL,
    Libram = ZL_ITEMTYPE_LIBRAM,
    Totem = ZL_ITEMTYPE_TOTEM,
    Alchemy = ZL_ITEMTYPE_ALCHEMY,
    Blacksmithing = ZL_ITEMTYPE_BLACKSMITHING,
    Cooking = ZL_ITEMTYPE_COOKING,
    Enchanting = ZL_ITEMTYPE_ENCHANTING,
    Engineering = ZL_ITEMTYPE_ENGINEERING,
    FirstAid = ZL_ITEMTYPE_FIRSTAID,
    Jewelcrafting = ZL_ITEMTYPE_JEWELCRAFTING,
    Leatherworking = ZL_ITEMTYPE_LEATHERWORKING,
    Tailoring = ZL_ITEMTYPE_TAILORING,
    Survival = ZL_ITEMTYPE_SURVIVAL,
    Mining = ZL_ITEMTYPE_MINING,
    Bullet = ZL_ITEMTYPE_BULLET,
    Arrow = ZL_ITEMTYPE_ARROW
}

ZLLib.Continents = {Kalimdor = ZL_CONTINENT_KALIMDOR, EasternKingdoms = ZL_CONTINENT_EASTERNKINGDOMS}

ZLLib.MapId = {
    World = 0,
    Kalimdor = 1,
    EasternKingdoms = 2,
    WinterVeilVale = 3,
    RagefireChasm = 4,
    ZulFarrak = 5,
    TheTempleOfAtalHakkar = 6,
    BlackfathomDeeps = 7,
    TheStockade = 8,
    Gnomeregan = 9,
    Uldaman = 10,
    MoltenCore = 11,
    ZulGurub = 12,
    DireMaul = 13,
    BlackrockDepths = 14,
    RuinsOfAhnQiraj = 15,
    OnyxiasLair = 16,
    BlackrockSpire = 17,
    WailingCaverns = 18,
    Maraudon = 19,
    BlackwingLair = 20,
    TheDeadmines = 21,
    RazorfenDowns = 22,
    RazorfenKraul = 23,
    ScarletMonastery = 24,
    Scholomance = 25,
    ShadowfangKeep = 26,
    Stratholme = 27,
    TempleOfAhnQiraj = 28,
    LowerKarazhanHalls = 29,
    DeeprunTram = 30,
    TheBlackMorass = 31,
    GilneasCity = 32,
    Naxxramas = 33,
    CrescentGrove = 34,
    HateforgeQuarry = 35,
    KarazhanCrypt = 36,
    StormwindVault = 37,
    EmeraldSanctum = 38,
    MoomooGrove = 39,
    TowerOfKarazhan = 40,
    DragonmawRetreat = 41,
    StormwroughtRuins = 42,
    AlahThalas = 43,
    TimbermawHold = 44,
    WindhornCanyon = 45,
    FrostmaneHollow = 46
}

ZLLib.ZoneId = {
    None = 0,
    AlahThalas = 1,
    AlteracMountains = 2,
    ArathiHighlands = 3,
    Badlands = 4,
    Balor = 5,
    BlackrockMountain = 6,
    BlastedLands = 7,
    BurningSteppes = 8,
    DeadwindPass = 9,
    DunMorogh = 10,
    Duskwood = 11,
    EasternPlaguelands = 12,
    ElwynnForest = 13,
    GillijimsIsle = 14,
    Gilneas = 15,
    Gnomeregan = 16,
    GrimReaches = 17,
    HillsbradFoothills = 18,
    Ironforge = 19,
    LapidisIsle = 20,
    LochModan = 21,
    Northwind = 22,
    RedridgeMountains = 23,
    ScarletEnclave = 24,
    ScarletMonastery = 25,
    SearingGorge = 26,
    SilverpineForest = 27,
    StormwindCity = 28,
    StranglethornVale = 29,
    SwampOfSorrows = 30,
    ThalassianHighlands = 31,
    TheDeadmines = 32,
    TheHinterlands = 33,
    TirisfalGlades = 34,
    Uldaman = 35,
    Undercity = 36,
    WesternPlaguelands = 37,
    Westfall = 38,
    Wetlands = 39,
    Ashenvale = 1,
    Azshara = 2,
    BlackstoneIsland = 3,
    CavernsOfTime = 4,
    Darkshore = 5,
    Darnassus = 6,
    Desolace = 7,
    DireMaul = 8,
    Durotar = 9,
    DustwallowMarsh = 10,
    Felwood = 11,
    Feralas = 12,
    GMIsland = 13,
    GatesOfAhnQiraj = 14,
    Hyjal = 15,
    IcepointRock = 16,
    Maraudon = 17,
    Moonglade = 18,
    MoonwhisperCoast = 19,
    Mulgore = 20,
    Orgrimmar = 21,
    Silithus = 22,
    StonetalonMountains = 23,
    Tanaris = 24,
    TelAbim = 25,
    Teldrassil = 26,
    TheBarrens = 27,
    ThousandNeedles = 28,
    ThunderBluff = 29,
    TimbermawHold = 30,
    TimbermawTunnels = 31,
    UnGoroCrater = 32,
    WailingCaverns = 33,
    WindhornCaverns = 34,
    Winterspring = 35,
    BM1 = 1,
    BM2 = 2,
    AQ401 = 1,
    AQ402 = 2,
    KARA401 = 1,
    KARA402 = 2,
    NAXX1 = 1,
    NAXX2 = 2,
    SMArm = 1,
    SMCath = 2,
    SMGy = 3,
    SMLib = 4
}

local currentLocale = GetLocale()

if currentLocale == "esES" and ZL_ZoneId_esES then
    ZLLib.ZoneId = ZL_ZoneId_esES
elseif currentLocale == "frFR" and ZL_ZoneId_frFR then
    ZLLib.ZoneId = ZL_ZoneId_frFR
elseif currentLocale == "deDE" and ZL_ZoneId_deDE then
    ZLLib.ZoneId = ZL_ZoneId_deDE
elseif currentLocale == "zhCN" and ZL_ZoneId_zhCN then
    ZLLib.ZoneId = ZL_ZoneId_zhCN
elseif currentLocale == "ruRU" and ZL_ZoneId_ruRU then
    ZLLib.ZoneId = ZL_ZoneId_ruRU
elseif currentLocale == "ptBR" and ZL_ZoneId_ptBR then
    ZLLib.ZoneId = ZL_ZoneId_ptBR
end

ZL_ZoneId_esES = nil
ZL_ZoneId_frFR = nil
ZL_ZoneId_deDE = nil
ZL_ZoneId_zhCN = nil
ZL_ZoneId_ruRU = nil
ZL_ZoneId_ptBR = nil

ZLLib.Reputations = {
    ArgentDawn = ZL_REPUTATION_ARGENTDAWN,
    SteamwheedleCartel = ZL_REPUTATION_STEAMWHEEDLECARTEL,
    Everlook = ZL_REPUTATION_EVERLOOK,
    Undercity = ZL_REPUTATION_UNDERCITY,
    Orgrimmar = ZL_REPUTATION_ORGRIMMAR,
    ThunderBluff = ZL_REPUTATION_THUNDERBLUFF,
    Stormwind = ZL_REPUTATION_STORMWIND,
    GnomereganExiles = ZL_REPUTATION_GNOMEREGANEXILES,
    Ironforge = ZL_REPUTATION_IRONFORGE,
    Darnassus = ZL_REPUTATION_DARNASSUS,
    DarkspearTrolls = ZL_REPUTATION_DARKSPEARTROLLS,
    Shendralar = ZL_REPUTATION_SHENDRALAR,
    Alliance = ZL_REPUTATION_ALLIANCE,
    Horde = ZL_REPUTATION_HORDE,
    CenarionCircle = ZL_REPUTATION_CENARIONCIRCLE,
    BloodsailBuccaneers = ZL_REPUTATION_BLOODSAILBUCCANEERS,
    BootyBay = ZL_REPUTATION_BOOTYBAY,
    Gadgetzan = ZL_REPUTATION_GADGETZAN,
    Ratchet = ZL_REPUTATION_RATCHET,
    WildhammerClan = ZL_REPUTATION_WILDHAMMERCLAN,
    Ravenholdt = ZL_REPUTATION_RAVENHOLDT,
    BroodOfNozdormu = ZL_REPUTATION_BROODOFNOZDORMU,
    ThoriumBrotherhood = ZL_REPUTATION_THORIUMBROTHERHOOD,
    ZandalarTribe = ZL_REPUTATION_ZANDALARTRIBE,
    RevantuskTrolls = ZL_REPUTATION_REVANTUSKTROLLS,
    HydraxianWaterlords = ZL_REPUTATION_HYDRAXIANWATERLORDS,
    Theramore = ZL_REPUTATION_THERAMORE,
    Dalaran = ZL_REPUTATION_DALARAN,
    SilvermoonRemnant = ZL_REPUTATION_SILVERMOONREMNANT
}

ZLLib.Factions = {Alliance = ZL_FACTION_ALLIANCE, Horde = ZL_FACTION_HORDE}

ZLLib.Races = {
    Human = ZL_RACE_HUMAN,
    Dwarf = ZL_RACE_DWARF,
    Gnome = ZL_RACE_GNOME,
    NightElf = ZL_RACE_NIGHTELF,
    HighElf = ZL_RACE_HIGHELF,
    Orc = ZL_RACE_ORC,
    Troll = ZL_RACE_TROLL,
    Tauren = ZL_RACE_TAUREN,
    Undead = ZL_RACE_UNDEAD,
    Goblin = ZL_RACE_GOBLIN
}

ZLLib.Classes = {
    Warrior = ZL_CLASS_WARRIOR,
    Mage = ZL_CLASS_MAGE,
    Rogue = ZL_CLASS_ROGUE,
    Hunter = ZL_CLASS_HUNTER,
    Warlock = ZL_CLASS_WARLOCK,
    Priest = ZL_CLASS_PRIEST,
    Druid = ZL_CLASS_DRUID,
    Paladin = ZL_CLASS_PALADIN,
    Shaman = ZL_CLASS_SHAMAN
}

ZLLib.AbilityFlags = {
    Tank = {Tooltip = ZL_ABILITYFLAG_TANK, Icon = ZLLib.MediaPath .. "ui\\flag-tank"},
    DPS = {Tooltip = ZL_ABILITYFLAG_DPS, Icon = ZLLib.MediaPath .. "ui\\flag-dps"},
    Heal = {Tooltip = ZL_ABILITYFLAG_HEAL, Icon = ZLLib.MediaPath .. "ui\\flag-heal"},
    Important = {Tooltip = ZL_ABILITYFLAG_IMPORTANT, Icon = ZLLib.MediaPath .. "ui\\flag-important"},
    Interruptible = {Tooltip = ZL_ABILITYFLAG_INTERRUPTIBLE, Icon = ZLLib.MediaPath .. "ui\\flag-interruptible"},
    Enrage = {Tooltip = ZL_ABILITYFLAG_ENRAGE, Icon = ZLLib.MediaPath .. "ui\\flag-enrage"},
    Deadly = {Tooltip = ZL_ABILITYFLAG_DEADLY, Icon = ZLLib.MediaPath .. "ui\\flag-deadly"},
    Magic = {Tooltip = ZL_ABILITYFLAG_MAGIC, Icon = ZLLib.MediaPath .. "ui\\flag-magic"},
    Curse = {Tooltip = ZL_ABILITYFLAG_CURSE, Icon = ZLLib.MediaPath .. "ui\\flag-curse"},
    Poison = {Tooltip = ZL_ABILITYFLAG_POISON, Icon = ZLLib.MediaPath .. "ui\\flag-poison"},
    Disease = {Tooltip = ZL_ABILITYFLAG_DISEASE, Icon = ZLLib.MediaPath .. "ui\\flag-disease"}
}

ZLLib.Challenges = {LevelOneLunatic = ZL_CHALLENGES_LEVELONELUNATIC}

ZLLib.InstanceType = {Dungeon = ZL_GUI_DUNGEON, Raid = ZL_GUI_RAID}

local IJC = ZLLib.Classes
local IJR = ZLLib.Races
local IJF = ZLLib.Factions
local IJIT = ZLLib.ItemType
local IJIS = ZLLib.ItemSlot
local IJCL = ZLLib.Colors

ZLLib.FactionUnlocalizedLinks = {[IJF.Alliance] = "Alliance", [IJF.Horde] = "Horde"}

ZLLib.RaceUnlocalizedLinks = {
    [IJR.Human] = "Human",
    [IJR.Dwarf] = "Dwarf",
    [IJR.Gnome] = "Gnome",
    [IJR.NightElf] = "NightElf",
    [IJR.HighElf] = "HighElf",
    [IJR.Orc] = "Orc",
    [IJR.Troll] = "Troll",
    [IJR.Tauren] = "Tauren",
    [IJR.Undead] = "Scourge",
    [IJR.Goblin] = "Goblin"
}

ZLLib.ClassUnlocalizedLinks = {
    [IJC.Druid] = "DRUID",
    [IJC.Hunter] = "HUNTER",
    [IJC.Mage] = "MAGE",
    [IJC.Paladin] = "PALADIN",
    [IJC.Priest] = "PRIEST",
    [IJC.Rogue] = "ROGUE",
    [IJC.Shaman] = "SHAMAN",
    [IJC.Warlock] = "WARLOCK",
    [IJC.Warrior] = "WARRIOR"
}

ZLLib.RaceGearLinks = {[IJR.NightElf] = {IJIT.Bow, IJIS.Ranged, IJIS.Projectile, IJIS.Arrow}}

ZLLib.ClassGearLinks = {
    [IJC.Druid] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Dagger, IJIT.FistWeapon,
        IJIT.Staff, IJIT.Mace, IJIT.TwoHandedMace, IJIT.Cloth, IJIT.Leather, IJIT.Polearm, IJIT.Idol, IJIS.Relic, IJIS.HeldInOffHand
    },
    [IJC.Hunter] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Bow, IJIT.Arrow, IJIT.Crossbow,
        IJIT.Gun, IJIT.Bullet, IJIT.Axe, IJIT.TwoHandedAxe, IJIT.Dagger, IJIT.Staff, IJIT.Polearm, IJIT.Sword, IJIT.TwoHandedSword, IJIT.FistWeapon, IJIT.ThrownWeapon, IJIT.Cloth, IJIT.Leather, IJIT.Mail, IJIS.Ranged,
        IJIS.OffHand, IJIS.Projectile
    },
    [IJC.Mage] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Wand, IJIT.Staff, IJIT.Dagger,
        IJIT.Sword, IJIT.Cloth, IJIS.Ranged, IJIS.HeldInOffHand
    },
    [IJC.Paladin] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Mace, IJIT.TwoHandedMace,
        IJIT.Shield, IJIT.Axe, IJIT.TwoHandedAxe, IJIT.Sword, IJIT.TwoHandedSword, IJIT.Polearm, IJIT.Cloth, IJIT.Leather, IJIT.Mail, IJIT.Plate, IJIT.Libram, IJIS.Relic, IJIS.HeldInOffHand
    },
    [IJC.Priest] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Wand, IJIT.Mace, IJIT.Dagger,
        IJIT.Staff, IJIT.Cloth, IJIS.Ranged, IJIS.HeldInOffHand
    },
    [IJC.Rogue] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Dagger, IJIT.ThrownWeapon,
        IJIT.Bow, IJIT.Arrow, IJIT.FistWeapon, IJIT.Crossbow, IJIT.Gun, IJIT.Bullet, IJIT.Mace, IJIT.Sword, IJIT.Cloth, IJIT.Leather, IJIS.Ranged, IJIS.OffHand, IJIS.Projectile
    },
    [IJC.Shaman] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Mace, IJIT.Staff, IJIT.Shield,
        IJIT.Axe, IJIT.TwoHandedAxe, IJIT.TwoHandedMace, IJIT.Dagger, IJIT.Cloth, IJIT.Leather, IJIT.Mail, IJIT.Totem, IJIS.Relic, IJIS.OffHand, IJIS.HeldInOffHand
    },
    [IJC.Warlock] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Wand, IJIT.Staff, IJIT.Sword,
        IJIT.Dagger, IJIT.Cloth, IJIS.Ranged, IJIS.HeldInOffHand
    },
    [IJC.Warrior] = {
        IJIT.Alchemy, IJIT.Blacksmithing, IJIT.Cooking, IJIT.Enchanting, IJIT.Engineering, IJIT.FirstAid, IJIT.Jewelcrafting, IJIT.Leatherworking, IJIT.Tailoring, IJIT.FishingPole, IJIT.Bow, IJIT.Arrow, IJIT.Crossbow,
        IJIT.Dagger, IJIT.FistWeapon, IJIT.Gun, IJIT.Bullet, IJIT.Polearm, IJIT.Axe, IJIT.TwoHandedAxe, IJIT.Mace, IJIT.TwoHandedMace, IJIT.Sword, IJIT.TwoHandedSword, IJIT.Staff, IJIT.ThrownWeapon, IJIT.Cloth,
        IJIT.Leather, IJIT.Mail, IJIT.Plate, IJIT.Shield, IJIS.Ranged, IJIS.OffHand, IJIS.HeldInOffHand, IJIS.Projectile
    }
}

ZLLib.ClassColorLinks = {
    [IJC.Druid] = IJCL.DarkOrange,
    [IJC.Hunter] = IJCL.Pistachio,
    [IJC.Mage] = IJCL.LightBlue,
    [IJC.Paladin] = IJCL.Pink,
    [IJC.Priest] = IJCL.White,
    [IJC.Rogue] = IJCL.LightYellow,
    [IJC.Shaman] = IJCL.Blue,
    [IJC.Warlock] = IJCL.LightPurple,
    [IJC.Warrior] = IJCL.Tan
}

ZLLib.NonMainSlotsLinks = {
    [IJIS.Pet] = true,
    [IJIS.Transmog] = true,
    [IJIS.Quest] = true,
    [IJIS.Ability] = true,
    [IJIS.Mount] = true,
    [IJIS.Bag] = true,
    [IJIS.Profession] = true,
    [IJIS.Reagent] = true,
    [IJIS.Toy] = true,
    [IJIS.Enchantment] = true,
    [IJIS.Projectile] = true,
    [IJIS.AmmoPouch] = true,
    [IJIS.Quiver] = true,
    [IJIS.Key] = true
}

function ZLLib:GetInstanceFromMapID(mapId)
    if ZLDB and ZLDB.DG and ZLDB.R then
        local instance = nil

        -- Dungeons
        for _, dg in pairs(ZLDB.DG) do
            if dg.MapId and tostring(dg.MapId) == tostring(mapId) then
                instance = dg
            end
        end

        -- Raids
        for _, r in pairs(ZLDB.R) do
            if r.MapId and tostring(r.MapId) == tostring(mapId) then
                instance = r
            end
        end

        return instance
    end

    return nil
end

function ZLLib:GetAllInstancesFromContinentIdAndZoneId(continentId, zoneId)
    if ZLDB and ZLDB.DG and ZLDB.R then
        local list = {}

        -- Dungeons
        for _, dg in pairs(ZLDB.DG) do
            if dg.Entrances then
                for _, ent in pairs(dg.Entrances) do
                    if ent.MapContinentId and ent.MapZoneId and tostring(ent.MapContinentId) == tostring(continentId) and tostring(ent.MapZoneId) == tostring(zoneId) then
                        table.insert(list, dg)
                    end
                end
            end
        end

        -- Raids
        for _, r in pairs(ZLDB.R) do
            if r.Entrances then
                for _, ent in pairs(r.Entrances) do
                    if ent.MapContinentId and ent.MapZoneId and tostring(ent.MapContinentId) == tostring(continentId) and tostring(ent.MapZoneId) == tostring(zoneId) then
                        table.insert(list, r)
                    end
                end
            end
        end

        return list
    end

    return nil
end

function ZLLib:GetAllInstancesMapIDs()
    if ZLDB and ZLDB.DG and ZLDB.R then
        local list = {}

        -- Dungeons
        for _, dg in pairs(ZLDB.DG) do
            if dg.MapId then
                table.insert(list, dg.MapId)
            end
        end

        -- Raids
        for _, r in pairs(ZLDB.R) do
            if r.MapId then
                table.insert(list, r.MapId)
            end
        end

        return list
    end

    return nil
end

function ZLLib:IsItemRestrictedForSpecificClass(item, passedClassKey)
    if not item then
        return false, false, false, false
    end

    local classKey = UnitClass("player")

    if passedClassKey then
        classKey = passedClassKey
    end

    local isRestricted = false
    local failClass = false
    local failSlot = false
    local failType = false

    if item.ClassRestriction then
        local foundClass = false

        for _, c in ipairs(item.ClassRestriction) do
            if c == classKey then
                foundClass = true

                break
            end
        end

        if not foundClass then
            failClass = true
            isRestricted = true
        end
    end

    local allowedGear = ZLLib.ClassGearLinks[classKey] or {}
    local _, raceToken = UnitRace("player")
    local raceKey = nil

    for k, v in pairs(ZLLib.RaceUnlocalizedLinks) do
        if v == raceToken then
            raceKey = k

            break
        end
    end

    local allowedRaceGear = raceKey and ZLLib.RaceGearLinks[raceKey] or {}

    if item.ItemSlot == ZLLib.ItemSlot.Relic or item.ItemSlot == ZLLib.ItemSlot.HeldInOffHand or item.ItemSlot == ZLLib.ItemSlot.Ranged or item.ItemSlot == ZLLib.ItemSlot.Projectile then
        local slotAllowed = false

        for _, allowedSlot in ipairs(allowedGear) do
            if item.ItemSlot == allowedSlot then
                slotAllowed = true

                break
            end
        end

        if not slotAllowed then
            for _, allowedSlot in ipairs(allowedRaceGear) do
                if item.ItemSlot == allowedSlot then
                    slotAllowed = true

                    break
                end
            end
        end

        if not slotAllowed then
            failSlot = true
            isRestricted = true
        end
    end

    if item.ItemType then
        local typeAllowed = false

        for _, allowedType in ipairs(allowedGear) do
            if item.ItemType == allowedType then
                typeAllowed = true

                break
            end
        end

        if not typeAllowed then
            for _, allowedType in ipairs(allowedRaceGear) do
                if item.ItemType == allowedType then
                    typeAllowed = true

                    break
                end
            end
        end

        if typeAllowed and item.ItemSlot == ZLLib.ItemSlot.TwoHand then
            if item.ItemType == ZLLib.ItemType.Sword then
                if classKey ~= IJC.Warrior and classKey ~= IJC.Paladin and classKey ~= IJC.Hunter then
                    typeAllowed = false
                end
            elseif item.ItemType == ZLLib.ItemType.Axe then
                if classKey ~= IJC.Warrior and classKey ~= IJC.Paladin and classKey ~= IJC.Hunter and classKey ~= IJC.Shaman then
                    typeAllowed = false
                end
            elseif item.ItemType == ZLLib.ItemType.Mace then
                if classKey ~= IJC.Warrior and classKey ~= IJC.Paladin and classKey ~= IJC.Shaman and classKey ~= IJC.Druid then
                    typeAllowed = false
                end
            end
        end

        if not typeAllowed then
            failType = true
            isRestricted = true
        end
    end

    return isRestricted, failClass, failSlot, failType
end

function ZLLib:FilterItemListByClass(itemList, classKey)
    if not classKey or classKey == "ALL" then
        return itemList
    end

    local filtered = {}

    for _, item in ipairs(itemList) do
        if not ZLLib:IsItemRestrictedForSpecificClass(item, classKey) then
            table.insert(filtered, item)
        end
    end

    return filtered
end

function ZLLib:FilterItemListBySlot(itemList, slotKey)
    if not slotKey or slotKey == "ALL" then
        return itemList
    end

    local filtered = {}

    for _, item in ipairs(itemList) do
        local match = false
        local s = item.ItemSlot

        if slotKey == ZLLib.ItemSlot.MainHand then
            if s == ZLLib.ItemSlot.MainHand or s == ZLLib.ItemSlot.OneHand or s == ZLLib.ItemSlot.TwoHand then
                match = true
            end
        elseif slotKey == ZLLib.ItemSlot.OffHand then
            if s == ZLLib.ItemSlot.OffHand or s == ZLLib.ItemSlot.OneHand or s == ZLLib.ItemSlot.HeldInOffHand then
                match = true
            end
        elseif slotKey == ZLLib.ItemSlot.Other then
            if s and ZLLib.NonMainSlotsLinks[s] then
                match = true
            end
        else
            if s == slotKey then
                match = true
            end
        end

        if match then
            table.insert(filtered, item)
        end
    end

    return filtered
end

function ZLLib:Search(query)
    if not query or string.len(query) < 3 then
        return {}
    end

    query = string.lower(query)

    local results = {}
    local seenItems = {}

    local function checkMatch(text)
        return text and string.find(string.lower(text), query, 1, true)
    end

    local function searchDB(dbType)
        if not dbType then
            return
        end

        for _, inst in pairs(dbType) do
            if checkMatch(inst.Name) then
                table.insert(results, {type = "Instance", name = inst.Name, instance = inst})
            end

            if inst.Bosses then
                for _, boss in ipairs(inst.Bosses) do
                    if checkMatch(boss.Name) then
                        table.insert(results, {type = "Boss", name = boss.Name, instance = inst, boss = boss})
                    end

                    if boss.L then
                        ZL_ForEachLootId(boss, function(id)
                            local itemName = ZL_GetItemName(id)

                            if itemName and not seenItems[id] and checkMatch(itemName) then
                                seenItems[id] = true
                                local item = ZL_GetItem(id)
                                item.Name = itemName
                                table.insert(results, {type = "Item", name = itemName, item = item, instance = inst, boss = boss})
                            end
                        end)
                    end

                    if boss.Abilities then
                        local function searchAbilities(abs)
                            for _, ab in ipairs(abs) do
                                if checkMatch(ab.Name) or checkMatch(ab.Effect) then
                                    table.insert(results, {type = "Ability", name = ab.Name, ability = ab, instance = inst, boss = boss})
                                end

                                if ab.SubAbilities then
                                    searchAbilities(ab.SubAbilities)
                                end
                            end
                        end

                        searchAbilities(boss.Abilities)
                    end
                end
            end

            if inst.Quests then
                local function searchQuests(quests)
                    for _, q in ipairs(quests) do
                        if checkMatch(q.Name) then
                            table.insert(results, {type = "Quest", name = q.Name, quest = q, instance = inst})
                        end

                        if q.RequiredQuests then
                            searchQuests(q.RequiredQuests)
                        end
                    end
                end

                searchQuests(inst.Quests)
            end
        end
    end

    searchDB(ZLDB.DG)
    searchDB(ZLDB.R)
    searchDB(ZLDB.C)

    local sortOrder = {Instance = 1, Boss = 2, Item = 3, Quest = 4, Ability = 5}

    table.sort(results, function(a, b)
        if sortOrder[a.type] ~= sortOrder[b.type] then
            return sortOrder[a.type] < sortOrder[b.type]
        end

        return (a.name or "") < (b.name or "")
    end)

    return results
end

function ZLLib:GetColorFromInstanceMinMax(instanceMin, instanceMax)
    local averageLevel = floor((instanceMax - instanceMin) / 2) + instanceMin
    local levelDiff = averageLevel - UnitLevel("player")
    local color = ZLLib.Colors.White

    if levelDiff > 4 then
        color = ZLLib.Colors.Red
    elseif levelDiff > 2 then
        color = ZLLib.Colors.Orange
    elseif levelDiff > -3 then
        color = ZLLib.Colors.Yellow
    elseif levelDiff > -12 then
        color = ZLLib.Colors.Green
    else
        color = ZLLib.Colors.Gray
    end

    return color
end

function ZLLib:GetQuestDifficultyColor(questLevel)
    local levelDiff = questLevel - UnitLevel("player")
    local questGreenRange = 0

    if GetQuestGreenRange then
        questGreenRange = GetQuestGreenRange()
    else
        questGreenRange = 10
    end

    local color

    if levelDiff >= 5 then
        color = ZLLib.Colors.Red
    elseif levelDiff >= 3 then
        color = ZLLib.Colors.Orange
    elseif levelDiff >= -2 then
        color = ZLLib.Colors.Yellow
    elseif -levelDiff <= questGreenRange then
        color = ZLLib.Colors.Green
    else
        color = ZLLib.Colors.Gray
    end

    return color
end

function ZLLib:GetColorFromDropChance(dropChance)
    local color = ZLLib.Colors.White
    local chance = dropChance

    if not chance then
        return color
    end

    if chance <= 10 then
        color = ZLLib.Colors.DarkerOrange
    elseif chance <= 20 then
        color = ZLLib.Colors.Purple
    elseif chance <= 40 then
        color = ZLLib.Colors.Blue
    elseif chance <= 60 then
        color = ZLLib.Colors.LightGreen
    else
        color = ZLLib.Colors.White
    end

    return color
end

function ZLLib:SetFrameStrataBelowMap(frame)
    if not frame or not WorldMapFrame then
        return
    end

    local mapStrata = WorldMapFrame:GetFrameStrata()
    local currentStrataIndex = 6

    for i, strata in ipairs(self.StrataOrder) do
        if strata == mapStrata then
            currentStrataIndex = i

            break
        end
    end

    local newStrataIndex = math.max(1, currentStrataIndex - 1)
    frame:SetFrameStrata(self.StrataOrder[newStrataIndex])
end
