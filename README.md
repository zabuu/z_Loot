# zLoot

Lightweight dungeon journal for OctoWoW (WoW 1.12), part of zSuite. Replaces Atlas-CFM, AtlasLoot and InstanceJournal.

* **Dungeons, Raids, Collections** tabs. Collections keep the AtlasLoot pages: tier and class sets, Legendary and
  Artifact items, world epics and blues, rare pets and mounts, tabards, PvP, factions, world events, rare mobs.
* **Loot**: every boss's drops with drop chance, filtered by class (defaults to yours) and slot.
  Hover for the tooltip, Shift-click to link in chat, Ctrl-click to preview.
* **Map**: always beside the loot. The game's own map art with numbered boss markers and floors for multi-level
  instances. Mouse wheel zooms, drag pans, Reset or middle-click resets. Click a marker to see that boss's loot.
* **About**: boss lore and abilities.
* **Search** items, bosses and instances from the header.
* **Aa** button: window size 90 / 100 / 115 / 130 %.

Open with /zloot, /zl, the zSuite key binding (SHIFT-J the first time if free), or /ij once InstanceJournal is off.
Esc closes it.

## Memory

| | at login | after opening |
|---|---|---|
| Atlas-CFM + AtlasLoot + InstanceJournal | about 31 MB | more |
| zLoot | about 0.8 MB (mostly one packed string the garbage collector skips) | about 1.8 MB |

The window and the data are only built the first time you open zLoot. No image files are needed.

## Rebuilding data

`tools/` has the Lua 5.1 generators that produce `src/Data.lua` (from InstanceJournal) and `src/Collections.lua`
(from Atlas-CFM, server filter TURTLE). Then run `python tools/pack.py` to rebuild `Packed.lua`.
Instance map files are listed in `ui/MapFiles.lua` (names from this client's WorldMap art).
