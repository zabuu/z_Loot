-- WoW 1.12 mock harness (run with lua5.1)
string.gfind = string.gmatch
local realmatch, realgmatch = string.match, string.gmatch
string.match = nil; string.gmatch = nil  -- catch 5.1-only use
select = nil
local missing = {}
local Frame = {}
local FrameMT = {__index = function(t, k)
  local v = Frame[k]; if v then return v end
  if type(k) == "string" and string.find(k, "^[A-Z]") then return function(self) return self end end
  return nil
end}
local nameCount = 0
local function newFrame(kind, name)
  local f = setmetatable({_shown = true, _scripts = {}, _kind = kind, _name = name, _w = 100, _h = 20, _text = ""}, FrameMT)
  if name then _G[name] = f end
  return f
end
function Frame:Show() self._shown = true; if self._scripts.OnShow then local o=this; this=self; self._scripts.OnShow(); this=o end end
function Frame:Hide() self._shown = false end
function Frame:IsShown() return self._shown end
function Frame:IsVisible() return self._shown end
function Frame:GetName() return self._name end
function Frame:SetScript(k, fn) self._scripts[k] = fn end
function Frame:GetScript(k) return self._scripts[k] end
function Frame:SetWidth(w) self._w = w end
function Frame:SetHeight(h) self._h = h end
function Frame:GetWidth() return self._w end
function Frame:GetHeight() return self._h end
function Frame:GetStringWidth() return 50 end
function Frame:GetTextWidth() return 50 end
function Frame:GetFrameLevel() return 1 end
function Frame:GetFrameStrata() return "HIGH" end
function Frame:GetValue() return 0 end
function Frame:GetMinMaxValues() return 0, 100 end
function Frame:SetText(t) self._text = t end
function Frame:GetText() return self._text end
function Frame:IsEnabled() return 1 end
function Frame:GetNormalTexture() if not self._nt then self._nt = newFrame("Texture") end return self._nt end
function Frame:GetHighlightTexture() return self:GetNormalTexture() end
function Frame:GetPushedTexture() return self:GetNormalTexture() end
function Frame:CreateTexture(n) return newFrame("Texture", n) end
function Frame:CreateFontString(n) return newFrame("FontString", n) end
function Frame:GetParent() return UIParent end
function Frame:GetChildren() return end
function Frame:GetRegions() return end
function Frame:GetNumPoints() return 0 end
function Frame:GetVerticalScroll() return 0 end
function Frame:GetVerticalScrollRange() return 0 end
function Frame:GetScrollChild() return newFrame("Frame") end
function Frame:GetEffectiveScale() return 1 end
function Frame:GetLeft() return 0 end
function Frame:GetTop() return 0 end
function Frame:GetRight() return 0 end
function Frame:GetBottom() return 0 end
function Frame:GetCenter() return 0, 0 end
function Frame:HasFocus() return nil end
function Frame:GetID() return 1 end
function Frame:GetBackdropColor() return 0,0,0,1 end
function Frame:SetHyperlink(l) _G.__queried = (_G.__queried or 0) + 1 end
function Frame:NumLines() return 0 end

CreateFrame = function(kind, name, parent, tmpl)
  local f = newFrame(kind, name)
  if name and tmpl then
    for _, suf in ipairs({"Text","Button","ScrollBar","ScrollBarScrollUpButton","ScrollBarScrollDownButton","Left","Middle","Right","HighlightTexture","ScrollChildFrame","TextLeft1","TextRight1"}) do
      newFrame("Child", name .. suf)
    end
  end
  return f
end
UIParent = newFrame("Frame", "UIParent")
WorldMapFrame = newFrame("Frame", "WorldMapFrame"); WorldMapFrame._shown = false
GameTooltip = newFrame("GameTooltip", "GameTooltip")
DEFAULT_CHAT_FRAME = newFrame("Frame"); function DEFAULT_CHAT_FRAME:AddMessage(m) print("[chat] " .. m) end
UISpecialFrames = {}
SlashCmdList = {}
getglobal = function(n) return _G[n] end
setglobal = function(n, v) _G[n] = v end
GetLocale = function() return "enUS" end
UnitClass = function() return "Warrior", "WARRIOR" end
UnitName = function(u) if u == "target" then return _G.__target end return "Sam" end
UnitExists = function(u) return u == "target" and _G.__target ~= nil end
UnitRace = function() return "Orc", "Orc" end
UnitSex = function() return 2 end
UnitLevel = function() return 60 end
UnitFactionGroup = function() return "Horde" end
PlaySound = function() end
GetTime = function() return 0 end
IsShiftKeyDown = function() return nil end
IsControlKeyDown = function() return nil end
IsAltKeyDown = function() return nil end
IsAddOnLoaded = function(n) return nil end
local itemCache = {}
GetItemInfo = function(id)
  id = tonumber(id) or id
  if itemCache[id] then return "Item" .. id, "item:" .. id, 3, 60, "Armor", "Plate", 1, "INVTYPE_CHEST", "Interface\\Icons\\INV_Chest_Plate01" end
end
__cacheItem = function(id) itemCache[id] = true end
local mapC, mapZ = 0, 0
__mapCalls = 0
SetMapZoom = function(c, z) mapC, mapZ = c or 0, z or 0; __mapCalls = __mapCalls + 1 end
SetMapToCurrentZone = function() mapC, mapZ = 1, 14 end
GetCurrentMapContinent = function() return mapC end
GetCurrentMapZone = function() return mapZ end
GetMapInfo = function() if mapC == 999 then return nil end return "Map" .. mapC .. "_" .. mapZ end
GetMapZones = function(c) return "Floor A", "Floor B", "Floor C" end
GetMapContinents = function() return "Kalimdor", "Eastern Kingdoms" end
GetRealZoneText = function() return "Orgrimmar" end
GetZoneText = GetRealZoneText
GetBindingAction = function() return "" end
SetBinding = function() return 1 end
SaveBindings = function() end
GetCurrentBindingSet = function() return 1 end
LoadAddOn = function(n) return 1 end
HideUIPanel = function(f) f:Hide() end
ShowUIPanel = function(f) f:Show() end
ToggleDropDownMenu = function() end
CloseDropDownMenus = function() end
for _, n in ipairs({"UIDropDownMenu_SetWidth","UIDropDownMenu_Initialize","UIDropDownMenu_SetSelectedValue","UIDropDownMenu_SetText","UIDropDownMenu_AddButton","UIDropDownMenu_SetSelectedID","UIDropDownMenu_JustifyText","PanelTemplates_SetNumTabs","PanelTemplates_SetTab","PanelTemplates_TabResize","PanelTemplates_UpdateTabs","PanelTemplates_EnableTab","PanelTemplates_DisableTab","SetItemRef","ChatFrameEditBox","DressUpItemLink","SetDesaturation"}) do _G[n] = function() end end
UIDropDownMenu_CreateInfo = function() return {} end
UIDROPDOWNMENU_MENU_LEVEL = 1
RAID_CLASS_COLORS = setmetatable({}, {__index = function() return {r=1,g=1,b=1} end})
ITEM_QUALITY_COLORS = setmetatable({}, {__index = function() return {r=1,g=1,b=1,hex="|cffffffff"} end})
math.mod = math.fmod
table.setn = function() end
strlower, strupper, strfind, strsub, strlen, format, gsub, floor, ceil, abs, min, max, tinsert, tremove, getn =
  string.lower, string.upper, string.find, string.sub, string.len, string.format, string.gsub, math.floor, math.ceil, math.abs, math.min, math.max, table.insert, table.remove, table.getn

-- frames from XML
function __loadXMLNames(path)
  local s = io.open(path):read("*a")
  local parents = {}
  for tag, name in realgmatch(s, "<(%w+)%s+name=\"([^\"]+)\"") do
    if not realmatch(name, "%$parent") then
      local f = newFrame(tag, name)
      if tag == "Button" then newFrame("FontString", name .. "Text"); newFrame("Texture", name .. "HighlightTexture") end
      if tag == "EditBox" then f.SetFocus = function() end end
    end
  end
  -- $parent children: approximate by searching for parent names
  for name in realgmatch(s, "name=\"%$parent(%w+)\"") do
    for _, p in ipairs({"ZL_SearchBar","ZL_InstanceJournalFrame"}) do newFrame("Child", p .. name) end
  end
end
