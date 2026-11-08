-- zLoot window: header (tabs, search), instance sidebar, instance view (boss list + Loot / Map / About).
-- Lua 5.0 (WoW 1.12). Everything here is created the first time the window opens.

local U = ZLUI
local C = U.C

local W, H = 980, 600
local HEADER_H = 44
local SIDEBAR_W = 200
local CENTER_W = 460
local INST_H = 50
local PAD = 10
local VW, VH = 444, 296 -- map viewport (1002:668)
local MAX_ZOOM = 5

local S = {tab = 1, pane = 1, inst = nil, boss = nil, slot = "ALL", floor = nil}
ZL_State = S

local F -- main frame
local sideList, bossList, lootList, searchList
local paneSeg, tabSeg, classDD, slotDD, countText
local panes = {}
local mapPins, mapTiles, floorButtons = {}, {}, {}

local TAB_LABELS = {"Dungeons", "Raids", "Collections"}
local SCALES = {0.6, 0.7, 0.8, 0.9, 1.0, 1.15, 1.3}

---------------------------------------------------------------- data helpers

local function tabList(tab)
    if tab == 3 then
        return ZLDB.C or {}
    end
    local src = (tab == 2) and ZLDB.R or ZLDB.DG
    local out = {}
    for _, inst in pairs(src or {}) do
        table.insert(out, inst)
    end
    local byLevel = ZL_Settings.sort == "LEVEL"
    table.sort(out, function(a, b)
        if byLevel and (a.MinLevel or 0) ~= (b.MinLevel or 0) then
            return (a.MinLevel or 0) < (b.MinLevel or 0)
        end
        return (a.Name or "") < (b.Name or "")
    end)
    return out
end

local function tabOf(inst)
    if inst.IsCollection then return 3 end
    for _, r in pairs(ZLDB.R or {}) do
        if r == inst then return 2 end
    end
    return 1
end

local function levelColor(inst)
    if not inst.MinLevel or not inst.MaxLevel then return C.muted end
    local c = ZLLib:GetColorFromInstanceMinMax(inst.MinLevel, inst.MaxLevel)
    if c and c.RGB then return {c.RGB[1], c.RGB[2], c.RGB[3], 1} end
    return C.sub
end

local function itemDisplayName(e)
    local name = e.Name
    if not name or name == "" then
        name = GetItemInfo(tonumber(e.Id))
    end
    if not name then
        ZL_QueryItem(tonumber(e.Id))
        return "Item #" .. tostring(e.Id), true
    end
    return name
end

local function slotCategories(s)
    local IS = ZLLib.ItemSlot
    if s == IS.MainHand or s == IS.TwoHand then return {IS.MainHand} end
    if s == IS.OffHand or s == IS.HeldInOffHand then return {IS.OffHand} end
    if s == IS.OneHand then return {IS.MainHand, IS.OffHand} end
    if ZLLib.NonMainSlotsLinks[s] then return {IS.Other} end
    return {s}
end

local function chatLink(id, name, quality)
    local hex = (quality and quality.Hex) or "|cffffffff"
    return hex .. "|Hitem:" .. id .. ":0:0:0|h[" .. name .. "]|h|r"
end

local function itemClick(id, name, quality)
    if not id then return end
    if IsControlKeyDown() then
        DressUpItemLink("item:" .. id .. ":0:0:0")
    elseif IsShiftKeyDown() and ChatFrameEditBox and ChatFrameEditBox:IsVisible() and name then
        ChatFrameEditBox:Insert(chatLink(id, name, quality))
    end
end

local function itemTooltip(owner, id)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    if GetItemInfo(tonumber(id)) then
        GameTooltip:SetHyperlink("item:" .. id .. ":0:0:0")
    else
        ZL_QueryItem(tonumber(id))
        GameTooltip:SetText("Loading item " .. id .. "...", 0.7, 0.7, 0.7)
    end
    GameTooltip:AddLine("Shift-click to link, Ctrl-click to preview", 0.45, 0.48, 0.52)
    GameTooltip:Show()
end

-- journal boss for an Atlas source (boss name + instance name), if zLoot has it
local function findBoss(bossName, instName)
    local fallback
    for _, l in ipairs({ZLDB.DG or {}, ZLDB.R or {}}) do
        for _, inst in pairs(l) do
            for _, b in ipairs(inst.Bosses or {}) do
                if b.Name == bossName then
                    if inst.Name == instName then return inst, b end
                    fallback = fallback or {inst, b}
                end
            end
        end
    end
    if fallback then return fallback[1], fallback[2] end
end

local function sourceLine(e)
    local s1 = e.Sources and e.Sources[1]
    if not s1 then return nil end
    local line = s1.Boss
    if s1.Instance and s1.Instance ~= "" and s1.Instance ~= s1.Boss then
        line = line .. "  ·  " .. s1.Instance
    end
    local extra = table.getn(e.Sources) - 1 + (e.Sources.more or 0)
    if extra > 0 then line = line .. "  (+" .. extra .. " more)" end
    return line
end

---------------------------------------------------------------- forward decls

local SelectInstance, SelectBoss, SetPane, RefreshLoot, RefreshMap, RefreshAbout, RefreshSidebar, ShowSearch

---------------------------------------------------------------- sidebar

local function makeSideRow(list)
    local r = U.Button(list)
    r.name = U.Text(r, 12, C.text)
    r.name:SetPoint("LEFT", r, "LEFT", 12, 0)
    r.name:SetPoint("RIGHT", r, "RIGHT", -48, 0)
    r.level = U.Text(r, 10, C.muted, "RIGHT")
    r.level:SetPoint("RIGHT", r, "RIGHT", -10, 0)
    r:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        SelectInstance(this.item)
    end)
    return r
end

local function fillSideRow(r, inst)
    r.name:SetText(inst.Name or "?")
    if inst.MinLevel and inst.MaxLevel then
        r.level:SetText(inst.MinLevel .. "-" .. inst.MaxLevel)
        U.Color(r.level, levelColor(inst))
    elseif inst.IsCollection then
        r.level:SetText(table.getn(inst.Bosses or {}))
        U.Color(r.level, C.muted)
    else
        r.level:SetText("")
    end
    U.SetSelected(r, inst == S.inst)
end

RefreshSidebar = function(keepOffset)
    sideList:SetData(tabList(S.tab), keepOffset)
    if F.sortRow then
        if S.tab == 3 then F.sortRow:Hide() else F.sortRow:Show() end
    end
end

---------------------------------------------------------------- boss list

local function makeBossCell(row)
    local c = U.Button(row)
    c.badge = U.Tex(c, "ARTWORK", C.raised)
    c.badge:SetWidth(18)
    c.badge:SetHeight(18)
    c.badge:SetPoint("LEFT", c, "LEFT", 8, 0)
    c.num = U.Text(c, 10, C.sub, "CENTER")
    c.num:SetPoint("CENTER", c.badge, "CENTER", 0, 0)
    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetWidth(18)
    c.icon:SetHeight(18)
    c.icon:SetPoint("LEFT", c, "LEFT", 8, 0)
    c.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    c.name = U.Text(c, 12, C.text)
    c.name:SetPoint("LEFT", c, "LEFT", 32, 0)
    c.name:SetPoint("RIGHT", c, "RIGHT", -4, 0)
    c:SetScript("OnClick", function()
        PlaySound("igMainMenuOptionCheckBoxOn")
        SelectBoss(this.boss, true)
    end)
    c.onEnter = function(self)
        if self.boss and self.boss.pin then self.boss.pin:Hover(true) end
    end
    c.onLeave = function(self)
        if self.boss and self.boss.pin then self.boss.pin:Hover(false) end
    end
    return c
end

local function makeBossRow(list)
    local r = CreateFrame("Frame", nil, list)
    r.cells = {makeBossCell(r), makeBossCell(r)}
    r.cells[1]:SetPoint("TOPLEFT", r, "TOPLEFT", 0, 0)
    r.cells[1]:SetPoint("BOTTOMRIGHT", r, "BOTTOM", -1, 0)
    r.cells[2]:SetPoint("TOPLEFT", r, "TOP", 1, 0)
    r.cells[2]:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", 0, 0)
    return r
end

local function fillBossRow(r, pair)
    local single = pair.single
    for k = 1, 2 do
        local c = r.cells[k]
        local boss = pair[k]
        if boss then
            c.boss = boss
            c.name:SetText(boss.Name or "?")
            if S.inst and S.inst.IsCollection then
                c.badge:Hide()
                c.num:Hide()
                if boss.Icon then
                    c.icon:SetTexture("Interface\\Icons\\" .. boss.Icon)
                    c.icon:Show()
                else
                    c.icon:Hide()
                end
            else
                c.icon:Hide()
                c.badge:Show()
                c.num:Show()
                c.num:SetText(pair.idx[k])
                if ZL_BossMapFile(S.inst, boss) then
                    c.badge:SetVertexColor(C.raised[1], C.raised[2], C.raised[3], 1)
                else
                    c.badge:SetVertexColor(0, 0, 0, 0)
                end
            end
            U.SetSelected(c, boss == S.boss)
            c:Show()
        else
            c.boss = nil
            c:Hide()
        end
    end
    r.cells[1]:ClearAllPoints()
    r.cells[1]:SetPoint("TOPLEFT", r, "TOPLEFT", 0, 0)
    if single then
        r.cells[1]:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", 0, 0)
    else
        r.cells[1]:SetPoint("BOTTOMRIGHT", r, "BOTTOM", -1, 0)
    end
end

-- bosses -> rows; two columns read top to bottom (1..n in the left column first). One column for collections.
local function bossRows(inst)
    local out = {}
    local bosses = inst.Bosses or {}
    local n = table.getn(bosses)
    if inst.IsCollection or n <= 6 then
        for i, b in ipairs(bosses) do
            table.insert(out, {b, idx = {i}, single = true})
            b.listRow = i
        end
        return out
    end
    local rows = math.ceil(n / 2)
    for r = 1, rows do
        local row = {idx = {r}, single = false}
        row[1] = bosses[r]
        bosses[r].listRow = r
        local j = r + rows
        if bosses[j] then
            row[2] = bosses[j]
            row.idx[2] = j
            bosses[j].listRow = r
        end
        table.insert(out, row)
    end
    return out
end

---------------------------------------------------------------- loot pane

local function makeLootRow(list)
    local r = U.Button(list)
    r.iconBorder = U.Tex(r, "ARTWORK", C.line)
    r.iconBorder:SetWidth(30)
    r.iconBorder:SetHeight(30)
    r.iconBorder:SetPoint("LEFT", r, "LEFT", 8, 0)
    r.icon = r:CreateTexture(nil, "OVERLAY")
    r.icon:SetWidth(28)
    r.icon:SetHeight(28)
    r.icon:SetPoint("CENTER", r.iconBorder, "CENTER", 0, 0)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.name = U.Text(r, 12, C.text)
    r.name:SetPoint("TOPLEFT", r, "TOPLEFT", 46, -6)
    r.name:SetPoint("RIGHT", r, "RIGHT", -44, 0)
    r.info = U.Text(r, 10, C.sub)
    r.info:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
    r.info:SetPoint("RIGHT", r, "RIGHT", -44, 0)
    r.chance = U.Text(r, 11, C.sub, "RIGHT")
    r.chance:SetPoint("RIGHT", r, "RIGHT", -8, 0)
    r.header = U.Text(r, 11, C.accent)
    r.header:SetPoint("BOTTOMLEFT", r, "BOTTOMLEFT", 10, 8)
    r.headerLine = U.Tex(r, "ARTWORK", C.line)
    r.headerLine:SetHeight(1)
    r.headerLine:SetPoint("BOTTOMLEFT", r, "BOTTOMLEFT", 10, 4)
    r.headerLine:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", -8, 4)
    r:SetScript("OnClick", function()
        local e = this.item
        if not e or e.IsHeader then return end
        if not IsShiftKeyDown() and not IsControlKeyDown() and e.Sources and e.Sources[1] then
            local inst, boss = findBoss(e.Sources[1].Boss, e.Sources[1].Instance)
            if inst then
                PlaySound("igMainMenuOptionCheckBoxOn")
                SelectInstance(inst, boss)
                return
            end
        end
        itemClick(e.Id, GetItemInfo(tonumber(e.Id)) or e.Name, e.Quality)
    end)
    r.onEnter = function(self)
        local e = self.item
        if not e or e.IsHeader then return end
        itemTooltip(self, e.Id)
        if e.Sources and e.Sources[1] then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Drops from:", 1, 0.82, 0)
            for _, src in ipairs(e.Sources) do
                local where = src.Boss
                if src.Instance and src.Instance ~= "" and src.Instance ~= src.Boss then where = where .. " - " .. src.Instance end
                GameTooltip:AddDoubleLine("  " .. where, src.Rate and (src.Rate .. "%") or "", 0.9, 0.9, 0.9, 0.7, 0.7, 0.7)
            end
            if e.Sources.more then
                GameTooltip:AddLine("  and " .. e.Sources.more .. " more", 0.6, 0.6, 0.6)
            end
            if findBoss(e.Sources[1].Boss, e.Sources[1].Instance) then
                GameTooltip:AddLine("Click to open " .. e.Sources[1].Boss, C.accent[1], C.accent[2], C.accent[3])
            end
            GameTooltip:Show()
        end
        if e.Container then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(ZL_GUI_CONTAINS or "Contains:", 1, 0.82, 0)
            for _, cid in ipairs(e.Container) do
                local n = ZL_GetItemName(tonumber(cid)) or ("Item #" .. cid)
                GameTooltip:AddLine("  " .. n, 0.9, 0.9, 0.9)
            end
            GameTooltip:Show()
        end
    end
    return r
end

local function fillLootRow(r, e)
    if e.IsHeader then
        r.header:SetText(e.Name or "")
        r.header:Show()
        r.headerLine:Show()
        r.iconBorder:Hide() r.icon:Hide() r.name:Hide() r.info:Hide() r.chance:Hide()
        r:EnableMouse(false)
        return
    end
    r:EnableMouse(true)
    r.header:Hide()
    r.headerLine:Hide()
    r.iconBorder:Show() r.icon:Show() r.name:Show() r.info:Show() r.chance:Show()
    local name, pending = itemDisplayName(e)
    local q = e.Quality and e.Quality.RGB or {1, 1, 1}
    r.name:SetText(name)
    if pending then
        U.Color(r.name, C.muted)
    else
        r.name:SetTextColor(q[1], q[2], q[3])
    end
    r.iconBorder:SetVertexColor(q[1], q[2], q[3], 0.7)
    local icon = e.Icon
    if not icon then
        local _, _, _, _, _, _, _, _, tex = GetItemInfo(tonumber(e.Id))
        icon = tex
    end
    if icon and not string.find(icon, "\\", 1, true) then
        icon = "Interface\\Icons\\" .. icon
    end
    r.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    local info = sourceLine(e) or e.Disc
    if not info or info == "" then
        if e.ItemSlot and e.ItemType then
            info = e.ItemSlot .. "  ·  " .. e.ItemType
        else
            info = e.ItemSlot or e.ItemType or ""
        end
    end
    if e.Note then
        info = info .. "  ·  " .. e.Note
    end
    r.info:SetText(info)
    local chance = e.DropChance or (e.Sources and e.Sources[1] and e.Sources[1].Rate)
    if chance then
        r.chance:SetText(chance .. "%")
    else
        r.chance:SetText("")
    end
end

local function buildLootData()
    local boss = S.boss
    local out = {}
    if not boss then return out end
    local isColl = S.inst and S.inst.IsCollection
    for _, entry in ipairs(ZL_LootEntries(boss)) do
        if entry.Header then
            table.insert(out, {IsHeader = true, Name = entry.Header})
        elseif entry[1] then
            local e = {}
            for k, v in pairs(entry[1]) do e[k] = v end
            for k, v in pairs(entry) do
                if type(k) ~= "number" then e[k] = v end
            end
            table.insert(out, e)
        end
    end
    if isColl then
        -- drop headers with nothing under them
        local clean = {}
        for i, e in ipairs(out) do
            local nextE = out[i + 1]
            if not e.IsHeader or (nextE and not nextE.IsHeader) then
                table.insert(clean, e)
            end
        end
        return clean
    end
    local cls = ZL_FilterClass or "ALL"
    out = ZLLib:FilterItemListByClass(out, cls)
    if S.slot ~= "ALL" then
        local f = {}
        for _, e in ipairs(out) do
            for _, c in ipairs(slotCategories(e.ItemSlot)) do
                if c == S.slot then table.insert(f, e) break end
            end
        end
        out = f
    end
    return out
end

local function updateFilters()
    local isColl = S.inst and S.inst.IsCollection
    if isColl then
        classDD:Hide() slotDD:Hide()
        return
    end
    classDD:Show() slotDD:Show()
    local cls = ZL_FilterClass or "ALL"
    classDD.text:SetText("Class: " .. (cls == "ALL" and "All" or cls))
    slotDD.text:SetText("Slot: " .. (S.slot == "ALL" and "All" or S.slot))
    -- slot options from this boss's loot
    local opts, seen = {{text = "All slots", value = "ALL"}}, {}
    if S.boss then
        for _, entry in ipairs(ZL_LootEntries(S.boss)) do
            local it = entry[1]
            if it and it.ItemSlot then
                for _, c in ipairs(slotCategories(it.ItemSlot)) do
                    if c and not seen[c] then
                        seen[c] = true
                        table.insert(opts, {text = c, value = c})
                    end
                end
            end
        end
    end
    slotDD:SetOptions(opts)
end

RefreshLoot = function(keepOffset)
    updateFilters()
    local data = buildLootData()
    lootList:SetData(data, keepOffset)
    local n = 0
    for _, e in ipairs(data) do if not e.IsHeader then n = n + 1 end end
    countText:SetText(n == 1 and "1 item" or (n .. " items"))
    if n == 0 then
        F.lootEmpty:Show()
    else
        F.lootEmpty:Hide()
    end
end

-- Core.lua calls this while uncached items arrive from the server
function ZL_RefreshLootView()
    if F and F:IsShown() and not F.search:IsShown() then
        lootList:Refresh()
    elseif F and F.search:IsShown() then
        searchList:Refresh()
    end
end

---------------------------------------------------------------- map (always visible, zoom + pan)
-- Same feel as z_Map: smooth cursor-anchored zoom, drag to pan (also over markers), a little slack past the edges.

local Z = {zoom = 1, u = 0.5, v = 0.5}
local SLACK = 0.35 -- how far past the map edge you can pan, as a share of the viewport

local function mapSize()
    return VW * Z.zoom, VH * Z.zoom
end

local function constrain()
    if Z.zoom <= 1.001 then
        Z.zoom = math.max(Z.zoom, 1)
        Z.u, Z.v = 0.5, 0.5
        return
    end
    local mw, mh = mapSize()
    local mu = (VW / 2 - VW * SLACK) / mw
    local mv = (VH / 2 - VH * SLACK) / mh
    if Z.u < mu then Z.u = mu end
    if Z.u > 1 - mu then Z.u = 1 - mu end
    if Z.v < mv then Z.v = mv end
    if Z.v > 1 - mv then Z.v = 1 - mv end
end

-- No ScrollFrame: like z_Map, tiles are cropped to the viewport with texture coordinates.
local TEX_R = {1, 1, 1, (1002 - 768) / 256}
local TEX_B = {1, 1, (668 - 512) / 256}

local function layoutMap()
    constrain()
    local mw, mh = mapSize()
    local ox, oy = VW / 2 - Z.u * mw, VH / 2 - Z.v * mh
    local tw, th = mw / 1002 * 256, mh / 668 * 256
    local vp = F.viewport
    for row = 1, 3 do
        for col = 1, 4 do
            local t = mapTiles[(row - 1) * 4 + col]
            local x0, y0 = ox + (col - 1) * tw, oy + (row - 1) * th
            local w = (col == 4) and (mw - 3 * tw) or tw
            local h = (row == 3) and (mh - 2 * th) or th
            local cx0, cy0 = math.max(x0, 0), math.max(y0, 0)
            local cx1, cy1 = math.min(x0 + w, VW), math.min(y0 + h, VH)
            if cx1 - cx0 < 0.5 or cy1 - cy0 < 0.5 or not F.mapHasArt then
                t:Hide()
            else
                local rr, bb = TEX_R[col], TEX_B[row]
                t:SetTexCoord((cx0 - x0) / w * rr, (cx1 - x0) / w * rr, (cy0 - y0) / h * bb, (cy1 - y0) / h * bb)
                t:ClearAllPoints()
                t:SetPoint("TOPLEFT", vp, "TOPLEFT", cx0, -cy0)
                t:SetWidth(cx1 - cx0)
                t:SetHeight(cy1 - cy0)
                t:Show()
            end
        end
    end
    for _, p in ipairs(mapPins) do
        if p.boss then
            local x = ox + p.boss.MapCoordinateX / 100 * mw
            local y = oy + (p.boss.MapCoordinateY or 0) / 100 * mh
            if x < 0 or y < 0 or x > VW or y > VH then
                p:Hide()
            else
                p:ClearAllPoints()
                p:SetPoint("CENTER", vp, "TOPLEFT", x, -y)
                p:Show()
            end
        end
    end
    F.zoomText:SetText(math.floor(Z.zoom * 100 + 0.5) .. "%")
end
local applyScroll = layoutMap

-- start an eased zoom to target, keeping the map point under viewport pixel (sx, sy) in place
local function zoomTo(target, sx, sy)
    if target < 1 then target = 1 end
    if target > MAX_ZOOM then target = MAX_ZOOM end
    sx = sx or VW / 2
    sy = sy or VH / 2
    local mw, mh = mapSize()
    Z.anim = {target = target, wu = Z.u + (sx - VW / 2) / mw, wv = Z.v + (sy - VH / 2) / mh, sx = sx, sy = sy}
end

local function zoomAt(target, sx, sy)
    zoomTo(target, sx, sy)
end

local function resetMap()
    Z.anim = nil
    Z.drag = nil
    Z.zoom, Z.u, Z.v = 1, 0.5, 0.5
    layoutMap()
end

local function animateMap(elapsed)
    local a = Z.anim
    if not a then return end
    local z = Z.zoom + (a.target - Z.zoom) * (1 - math.exp(-18 * math.min(elapsed, 0.1)))
    local done = math.abs(z - a.target) < a.target * 0.002
    if done then z = a.target end
    Z.zoom = z
    local mw, mh = mapSize()
    Z.u = a.wu - (a.sx - VW / 2) / mw
    Z.v = a.wv - (a.sy - VH / 2) / mh
    if done then Z.anim = nil end
    layoutMap()
end

local function cursorInViewport()
    local cx, cy = GetCursorPosition()
    local sc = F.viewport:GetEffectiveScale()
    return cx / sc - F.viewport:GetLeft(), F.viewport:GetTop() - cy / sc
end

local function mapMouseDown()
    if arg1 == "LeftButton" then
        Z.anim = nil
        local x, y = cursorInViewport()
        Z.drag = {x = x, y = y, u = Z.u, v = Z.v}
        Z.moved = false
    elseif arg1 == "RightButton" then
        local x, y = cursorInViewport()
        zoomTo((Z.anim and Z.anim.target or Z.zoom) / 1.6, x, y)
    end
end

local function mapMouseUp()
    if arg1 == "MiddleButton" then
        resetMap()
    end
    Z.drag = nil
end

local function mapWheel()
    local x, y = cursorInViewport()
    zoomTo((Z.anim and Z.anim.target or Z.zoom) * math.exp(arg1 * 0.24), x, y)
end

local function dragMap()
    local d = Z.drag
    if not d then return end
    local x, y = cursorInViewport()
    if math.abs(x - d.x) + math.abs(y - d.y) > 4 then Z.moved = true end
    if not Z.moved then return end
    local mw, mh = mapSize()
    Z.u = d.u - (x - d.x) / mw
    Z.v = d.v - (y - d.y) / mh
    constrain()
    applyScroll()
end

-- pan so a boss marker is in view (when zoomed in)
local function focusBoss(boss)
    if Z.zoom <= 1.001 or not boss or not boss.MapCoordinateX then return end
    local mw, mh = mapSize()
    local bu, bv = boss.MapCoordinateX / 100, (boss.MapCoordinateY or 0) / 100
    local dx, dy = (bu - Z.u) * mw, (bv - Z.v) * mh
    if math.abs(dx) > VW / 2 - 30 or math.abs(dy) > VH / 2 - 30 then
        Z.anim = nil
        Z.u, Z.v = bu, bv
        layoutMap()
    end
end

local function makePin(i)
    local p = CreateFrame("Button", nil, F.viewport)
    p:SetWidth(22)
    p:SetHeight(22)
    p:SetFrameLevel(F.viewport:GetFrameLevel() + 3)
    p.bg = U.Fill(p, {0.08, 0.08, 0.09, 0.92})
    U.Border(p, C.accent)
    p.num = U.Text(p, 11, C.text, "CENTER")
    p.num:SetPoint("CENTER", p, "CENTER", 0, 0)
    function p:Hover(on)
        if on or self.boss == S.boss then
            self.bg:SetVertexColor(C.accent[1], C.accent[2], C.accent[3], 1)
            self.num:SetTextColor(0.08, 0.08, 0.09)
        else
            self.bg:SetVertexColor(0.08, 0.08, 0.09, 0.92)
            U.Color(self.num, C.text)
        end
    end
    p:SetScript("OnEnter", function()
        this:Hover(true)
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(this.idx .. ". " .. (this.boss.Name or "?"), 1, 1, 1)
        if this.boss.MapIsBelow then
            GameTooltip:AddLine("On a lower level", 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine("Click to see loot", C.accent[1], C.accent[2], C.accent[3])
        GameTooltip:Show()
    end)
    p:SetScript("OnLeave", function()
        this:Hover(false)
        GameTooltip:Hide()
    end)
    p:RegisterForClicks("LeftButtonUp")
    p:SetScript("OnMouseDown", mapMouseDown)
    p:SetScript("OnMouseUp", mapMouseUp)
    p:EnableMouseWheel(true)
    p:SetScript("OnMouseWheel", mapWheel)
    p:SetScript("OnClick", function()
        if Z.moved then return end
        PlaySound("igMainMenuOptionCheckBoxOn")
        SelectBoss(this.boss)
    end)
    mapPins[i] = p
    return p
end

RefreshMap = function(newInstance)
    local inst = S.inst
    if inst and inst.IsCollection then
        F.mapBox:Hide()
        return
    end
    F.mapBox:Show()
    local files = ZL_InstanceMapFiles(inst)
    for _, b in ipairs(inst and inst.Bosses or {}) do b.pin = nil end
    for _, b in ipairs(floorButtons) do b:Hide() end
    if table.getn(files) == 0 then
        F.mapHasArt = false
        for i = 1, 12 do mapTiles[i]:Hide() end
        for _, p in ipairs(mapPins) do p:Hide() p.boss = nil end
        F.mapEmpty:Show()
        F.mapTools:Hide()
        resetMap()
        return
    end
    F.mapEmpty:Hide()
    F.mapTools:Show()
    local file = S.boss and ZL_BossMapFile(inst, S.boss)
    if not file then
        file = S.floor
        local ok = false
        for _, f in ipairs(files) do if f == file then ok = true end end
        if not ok then file = files[1] end
    end
    local floorChanged = (file ~= S.floor)
    S.floor = file
    if newInstance or floorChanged then
        Z.anim, Z.drag = nil, nil
        Z.zoom, Z.u, Z.v = 1, 0.5, 0.5
    end
    F.mapHasArt = true
    for i = 1, 12 do
        mapTiles[i]:SetTexture("Interface\\WorldMap\\" .. file .. "\\" .. file .. i)
    end
    if table.getn(files) > 1 then
        local x = 6
        for i, f in ipairs(files) do
            local b = floorButtons[i]
            if not b then
                b = U.Button(F.mapBox, 10, 20)
                b:SetFrameLevel(F.viewport:GetFrameLevel() + 6)
                U.Border(b, C.line)
                b.text = U.Text(b, 11, C.sub, "CENTER")
                b.text:SetPoint("CENTER", b, "CENTER", 0, 0)
                b:SetScript("OnClick", function()
                    S.floor = this.file
                    if S.boss and ZL_BossMapFile(S.inst, S.boss) ~= this.file then
                        S.boss = nil
                        bossList:Refresh()
                        RefreshLoot()
                    end
                    resetMap()
                    RefreshMap()
                end)
                floorButtons[i] = b
            end
            b.file = f
            b.text:SetText(ZL_MapFileNames[f] or ("Floor " .. i))
            b:SetWidth(b.text:GetStringWidth() + 18)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", F.viewport, "TOPLEFT", x, -6)
            x = x + b:GetWidth() + 4
            if f == file then
                b.bg:SetVertexColor(C.raised[1], C.raised[2], C.raised[3], 0.95)
                U.Color(b.text, C.text)
                U.SetBorderColor(b, C.accent)
            else
                b.bg:SetVertexColor(0.05, 0.05, 0.06, 0.85)
                U.Color(b.text, C.sub)
                U.SetBorderColor(b, C.line)
            end
            b:Show()
        end
    end
    local used = 0
    for idx, boss in ipairs(inst.Bosses) do
        if ZL_BossMapFile(inst, boss) == file then
            used = used + 1
            local p = mapPins[used] or makePin(used)
            p.boss = boss
            p.idx = idx
            p.num:SetText(idx)
            p:Hover(false)
            boss.pin = p
        end
    end
    for i = used + 1, table.getn(mapPins) do mapPins[i]:Hide() mapPins[i].boss = nil end
    layoutMap()
end

---------------------------------------------------------------- about pane

local aboutPool = {}
local aboutUsed = 0

local function aboutText(size, c, indent, y, text, iconTex)
    aboutUsed = aboutUsed + 1
    local o = aboutPool[aboutUsed]
    local child = F.aboutChild
    if not o then
        o = {}
        o.fs = U.Text(child, size, c)
        o.icon = child:CreateTexture(nil, "ARTWORK")
        o.icon:SetWidth(18)
        o.icon:SetHeight(18)
        o.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        aboutPool[aboutUsed] = o
    end
    local w = F.aboutScroll:GetWidth() - 24 - indent
    o.fs:SetFont(U.FONT, size)
    U.Color(o.fs, c)
    o.fs:ClearAllPoints()
    if iconTex then
        o.icon:SetTexture(iconTex)
        o.icon:ClearAllPoints()
        o.icon:SetPoint("TOPLEFT", child, "TOPLEFT", indent, -y + 1)
        o.icon:Show()
        o.fs:SetPoint("TOPLEFT", child, "TOPLEFT", indent + 26, -y)
        w = w - 26
    else
        o.icon:Hide()
        o.fs:SetPoint("TOPLEFT", child, "TOPLEFT", indent, -y)
    end
    o.fs:SetWidth(w)
    o.fs:SetText(text)
    o.fs:Show()
    local h = o.fs:GetHeight()
    if iconTex and h < 18 then h = 18 end
    return y + h
end

RefreshAbout = function()
    for _, o in ipairs(aboutPool) do o.fs:Hide() o.icon:Hide() end
    aboutUsed = 0
    local y = 4
    local boss, inst = S.boss, S.inst
    if boss then
        y = aboutText(15, C.text, 0, y, boss.Name or "") + 6
        if boss.Story and boss.Story ~= "" then
            y = aboutText(12, C.sub, 0, y, boss.Story) + 14
        end
        if boss.Abilities then
            y = aboutText(13, C.accent, 0, y, "Abilities") + 6
            local function walk(list, indent)
                for _, ab in ipairs(list) do
                    local icon = ab.Icon and ("Interface\\Icons\\" .. ab.Icon) or nil
                    y = aboutText(12, C.text, indent, y, ab.Name or "", icon) + 2
                    if ab.Effect and ab.Effect ~= "" then
                        y = aboutText(11, C.sub, indent + (icon and 26 or 0), y, ab.Effect) + 8
                    end
                    if ab.SubAbilities then walk(ab.SubAbilities, indent + 16) end
                end
            end
            walk(boss.Abilities, 0)
            y = y + 8
        end
    end
    if inst and inst.Story and inst.Story ~= "" then
        y = aboutText(13, C.accent, 0, y, "About " .. (inst.Name or "")) + 6
        y = aboutText(12, C.sub, 0, y, inst.Story) + 12
    end
    F.aboutChild:SetHeight(y)
    F.aboutScroll:SetVerticalScroll(0)
    F.aboutScroll:UpdateScrollChildRect()
end

---------------------------------------------------------------- selection

SetPane = function(i)
    S.pane = i
    paneSeg:Set(i)
    for k, p in pairs(panes) do
        if k == i then p:Show() else p:Hide() end
    end
    if i == 1 then RefreshLoot() else RefreshAbout() end
end

SelectBoss = function(boss, fromList)
    local oldFloor = S.floor
    S.boss = boss
    bossList:Refresh()
    if boss and boss.listRow then bossList:ScrollTo(boss.listRow) end
    if S.pane == 1 then RefreshLoot() else RefreshAbout() end
    if S.inst and not S.inst.IsCollection then
        local f = boss and ZL_BossMapFile(S.inst, boss)
        if f and f ~= oldFloor then
            RefreshMap()
        else
            for _, p in ipairs(mapPins) do if p:IsShown() then p:Hover(false) end end
        end
        if fromList then focusBoss(boss) end
    end
end

SelectInstance = function(inst, boss)
    if not inst then return end
    if F.search:IsShown() then ShowSearch(false) end
    S.inst = inst
    local t = tabOf(inst)
    if t ~= S.tab then
        S.tab = t
        tabSeg:Set(t)
        RefreshSidebar()
    end
    sideList:Refresh()
    F.instName:SetText(inst.Name or "")
    local sub
    if inst.IsCollection then
        sub = "Collection  ·  " .. table.getn(inst.Bosses or {}) .. " pages"
    else
        sub = (t == 2) and "Raid" or "Dungeon"
        if inst.MinLevel and inst.MaxLevel then
            sub = sub .. "  ·  Level " .. inst.MinLevel .. "-" .. inst.MaxLevel
        end
        local n = table.getn(inst.Bosses or {})
        sub = sub .. "  ·  " .. n .. (n == 1 and " boss" or " bosses")
    end
    F.instSub:SetText(sub)
    paneSeg:SetDisabled(2, inst.IsCollection and true or false)
    S.floor = nil
    S.slot = "ALL"
    local bosses = inst.Bosses or {}
    S.boss = boss or bosses[1]
    -- collections: the page list takes the whole centre column
    bossList:ClearAllPoints()
    if inst.IsCollection then
        bossList:SetPoint("TOPLEFT", F.center, "TOPLEFT", PAD, -PAD)
        bossList:SetHeight(H - HEADER_H - INST_H - 2 * PAD)
    else
        bossList:SetPoint("TOPLEFT", F.center, "TOPLEFT", PAD, -(PAD + VH + 10))
        bossList:SetHeight(H - HEADER_H - INST_H - VH - 2 * PAD - 10)
    end
    bossList:SetData(bossRows(inst))
    if S.boss and S.boss.listRow then bossList:ScrollTo(S.boss.listRow) end
    if S.pane == 2 and inst.IsCollection then S.pane = 1 end
    RefreshMap(true)
    SetPane(S.pane)
end

local function SelectTab(t)
    S.tab = t
    tabSeg:Set(t)
    RefreshSidebar()
    local list = sideList.data
    local keep = S.inst and tabOf(S.inst) == t
    if not keep and list[1] then
        SelectInstance(list[1])
    end
end

---------------------------------------------------------------- search

local function makeSearchRow(list)
    local r = U.Button(list)
    r.kind = U.Text(r, 10, C.muted)
    r.kind:SetPoint("LEFT", r, "LEFT", 14, 0)
    r.kind:SetWidth(64)
    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetWidth(24)
    r.icon:SetHeight(24)
    r.icon:SetPoint("LEFT", r, "LEFT", 80, 0)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.name = U.Text(r, 13, C.text)
    r.name:SetPoint("TOPLEFT", r, "TOPLEFT", 114, -6)
    r.name:SetPoint("RIGHT", r, "RIGHT", -10, 0)
    r.where = U.Text(r, 11, C.sub)
    r.where:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
    r.where:SetPoint("RIGHT", r, "RIGHT", -10, 0)
    r:SetScript("OnClick", function()
        local res = this.item
        if not res then return end
        if res.type == "Item" and (IsShiftKeyDown() or IsControlKeyDown()) then
            itemClick(res.item.Id, res.name, res.item.Quality)
            return
        end
        PlaySound("igMainMenuOptionCheckBoxOn")
        F.searchBox:SetText("")
        F.searchBox:ClearFocus()
        SelectInstance(res.instance, res.boss)
        if res.type == "Ability" then SetPane(2) else SetPane(1) end
    end)
    r.onEnter = function(self)
        local res = self.item
        if res and res.type == "Item" then itemTooltip(self, res.item.Id) end
    end
    return r
end

local function fillSearchRow(r, res)
    r.kind:SetText(string.upper(res.type))
    r.name:SetText(res.name or "?")
    local where = res.instance and res.instance.Name or ""
    if res.boss and res.type ~= "Boss" then where = res.boss.Name .. "  ·  " .. where end
    r.where:SetText(where)
    U.Color(r.name, C.text)
    r.icon:Hide()
    if res.type == "Item" then
        local q = res.item.Quality and res.item.Quality.RGB
        if q then r.name:SetTextColor(q[1], q[2], q[3]) end
        local icon = res.item.Icon
        if icon and not string.find(icon, "\\", 1, true) then icon = "Interface\\Icons\\" .. icon end
        r.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        r.icon:Show()
    elseif res.type == "Ability" and res.ability and res.ability.Icon then
        r.icon:SetTexture("Interface\\Icons\\" .. res.ability.Icon)
        r.icon:Show()
    end
end

ShowSearch = function(on, query)
    if on then
        local results = ZLLib:Search(query) or {}
        local filtered = {}
        for _, res in ipairs(results) do
            if res.type ~= "Quest" then table.insert(filtered, res) end
        end
        F.searchTitle:SetText(table.getn(filtered) .. " results for \"" .. query .. "\"")
        F.search:Show()
        F.inst:Hide()
        searchList:SetData(filtered)
        if table.getn(filtered) == 0 then F.searchEmpty:Show() else F.searchEmpty:Hide() end
    else
        F.search:Hide()
        F.inst:Show()
    end
end

---------------------------------------------------------------- build

local function build()
    F = CreateFrame("Frame", "ZL_Main", UIParent)
    F:SetWidth(W)
    F:SetHeight(H)
    local pos = ZL_Settings.pos
    if pos and pos.x and pos.y then
        F:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", pos.x, pos.y)
    else
        F:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    end
    F:SetFrameStrata("HIGH")
    F:SetToplevel(true)
    F:EnableMouse(true)
    F:SetMovable(true)
    F:SetClampedToScreen(true)
    F:Hide()
    U.Fill(F, C.bg)
    U.Border(F, {0, 0, 0, 0.9})
    table.insert(UISpecialFrames, "ZL_Main")
    F:SetScale(ZL_Settings.scale or 1)
    F:SetScript("OnShow", function() PlaySound("igCharacterInfoOpen") end)
    F:SetScript("OnHide", function() PlaySound("igCharacterInfoClose") end)

    -- header
    local head = CreateFrame("Frame", nil, F)
    head:SetPoint("TOPLEFT", F, "TOPLEFT", 0, 0)
    head:SetPoint("TOPRIGHT", F, "TOPRIGHT", 0, 0)
    head:SetHeight(HEADER_H)
    head:EnableMouse(true)
    head:RegisterForDrag("LeftButton")
    -- Moving the full window makes the game re-lay out every region on each frame, which lags.
    -- Drag a light outline instead and drop the window where it ends up.
    local ghost = CreateFrame("Frame", nil, UIParent)
    ghost:SetFrameStrata("TOOLTIP")
    ghost:SetMovable(true)
    ghost:SetClampedToScreen(true)
    ghost:Hide()
    U.Fill(ghost, {C.bg[1], C.bg[2], C.bg[3], 0.35})
    U.Border(ghost, C.accent)
    head:SetScript("OnDragStart", function()
        ghost:SetScale(F:GetScale())
        ghost:SetWidth(F:GetWidth())
        ghost:SetHeight(F:GetHeight())
        ghost:ClearAllPoints()
        ghost:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", F:GetLeft(), F:GetTop())
        ghost:Show()
        ghost:StartMoving()
    end)
    head:SetScript("OnDragStop", function()
        if not ghost:IsShown() then return end
        ghost:StopMovingOrSizing()
        local x, y = ghost:GetLeft(), ghost:GetTop()
        ghost:Hide()
        if x and y then
            F:ClearAllPoints()
            F:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
            ZL_Settings.pos = {x = x, y = y}
        end
    end)
    head:SetScript("OnHide", function()
        if ghost:IsShown() then ghost:StopMovingOrSizing() ghost:Hide() end
    end)
    U.Fill(head, C.panel)
    local hl = U.Tex(head, "ARTWORK", C.line)
    hl:SetHeight(1)
    hl:SetPoint("BOTTOMLEFT", head, "BOTTOMLEFT", 0, 0)
    hl:SetPoint("BOTTOMRIGHT", head, "BOTTOMRIGHT", 0, 0)

    local title = U.Text(head, 18, C.text)
    title:SetPoint("LEFT", head, "LEFT", PAD + 4, 0)
    title:SetFont(U.FONT, 16)
    title:SetText("|cfff5bd42z|rLoot")

    tabSeg = U.Segmented(head, TAB_LABELS, 96, 28, function(i) SelectTab(i) end)
    tabSeg:SetPoint("LEFT", title, "RIGHT", 40, 0)

    local close = U.Button(head, 28, 28)
    close:SetPoint("RIGHT", head, "RIGHT", -12, 0)
    close.text = U.Text(close, 16, C.sub, "CENTER")
    close.text:SetPoint("CENTER", close, "CENTER", 0, 0)
    close.text:SetText("x")
    close.onEnter = function(self) U.Color(self.text, C.danger) end
    close.onLeave = function(self) U.Color(self.text, C.sub) end
    close:SetScript("OnClick", function() F:Hide() end)

    local size = U.Button(head, 32, 28)
    size:SetPoint("RIGHT", close, "LEFT", -4, 0)
    size.text = U.Text(size, 14, C.sub, "CENTER")
    size.text:SetPoint("CENTER", size, "CENTER", 0, 0)
    size.text:SetText("Aa")
    size.onEnter = function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Window size: " .. math.floor((ZL_Settings.scale or 1) * 100 + 0.5) .. "%", 1, 1, 1)
        GameTooltip:AddLine("Click to make zLoot bigger, right-click for smaller", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end
    size:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    size:SetScript("OnClick", function()
        local cur = ZL_Settings.scale or 1
        local idx, best = 5, 99
        for i, s in ipairs(SCALES) do
            if math.abs(s - cur) < best then idx, best = i, math.abs(s - cur) end
        end
        if arg1 == "RightButton" then idx = idx - 1 else idx = idx + 1 end
        if idx < 1 then idx = 1 end
        if idx > table.getn(SCALES) then idx = table.getn(SCALES) end
        local old, l, t = F:GetScale(), F:GetLeft(), F:GetTop()
        ZL_Settings.scale = SCALES[idx]
        F:SetScale(SCALES[idx])
        if l and t then -- keep the top-left corner where it was
            local x, y = l * old / SCALES[idx], t * old / SCALES[idx]
            F:ClearAllPoints()
            F:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
            ZL_Settings.pos = {x = x, y = y}
        end
        this.onEnter(this)
    end)

    -- search box
    local sb = CreateFrame("EditBox", "ZL_SearchBox", head)
    sb:SetWidth(220)
    sb:SetHeight(28)
    sb:SetPoint("RIGHT", size, "LEFT", -10, 0)
    sb:SetAutoFocus(false)
    sb:SetFont(U.FONT, 12)
    sb:SetTextColor(C.text[1], C.text[2], C.text[3])
    sb:SetTextInsets(12, 12, 0, 0)
    sb:SetMaxLetters(60)
    U.Fill(sb, C.bg)
    U.Border(sb, C.line)
    local ph = U.Text(sb, 13, C.muted)
    ph:SetPoint("LEFT", sb, "LEFT", 12, 0)
    ph:SetText("Search items, bosses...")
    local delay = CreateFrame("Frame")
    delay:Hide()
    delay:SetScript("OnUpdate", function()
        this.t = this.t - arg1
        if this.t <= 0 then
            this:Hide()
            local q = sb:GetText() or ""
            if string.len(q) >= 3 then ShowSearch(true, q) else ShowSearch(false) end
        end
    end)
    sb:SetScript("OnTextChanged", function()
        local q = this:GetText() or ""
        if q == "" then ph:Show() else ph:Hide() end
        delay.t = 0.25
        delay:Show()
    end)
    sb:SetScript("OnEscapePressed", function()
        if (this:GetText() or "") ~= "" then this:SetText("") else this:ClearFocus() end
    end)
    sb:SetScript("OnEnterPressed", function() this:ClearFocus() end)
    sb:SetScript("OnEditFocusGained", function() U.SetBorderColor(this, C.accent) end)
    sb:SetScript("OnEditFocusLost", function() U.SetBorderColor(this, C.line) end)
    F.searchBox = sb

    -- sidebar
    local side = CreateFrame("Frame", nil, F)
    side:SetPoint("TOPLEFT", F, "TOPLEFT", 0, -HEADER_H)
    side:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 0, 0)
    side:SetWidth(SIDEBAR_W)
    U.Fill(side, {0, 0, 0, 0.18})
    local sl = U.Tex(side, "ARTWORK", C.line)
    sl:SetWidth(1)
    sl:SetPoint("TOPRIGHT", side, "TOPRIGHT", 0, 0)
    sl:SetPoint("BOTTOMRIGHT", side, "BOTTOMRIGHT", 0, 0)

    local sortRow = CreateFrame("Frame", nil, side)
    sortRow:SetPoint("TOPLEFT", side, "TOPLEFT", 12, -8)
    sortRow:SetPoint("TOPRIGHT", side, "TOPRIGHT", -12, -8)
    sortRow:SetHeight(24)
    local sortLabel = U.Text(sortRow, 11, C.muted)
    sortLabel:SetPoint("LEFT", sortRow, "LEFT", 0, 0)
    sortLabel:SetText("SORT BY")
    local sortSeg = U.Segmented(sortRow, {"Name", "Level"}, 56, 22, function(i)
        ZL_Settings.sort = (i == 2) and "LEVEL" or "NAME"
        this:GetParent():Set(i)
        RefreshSidebar()
    end)
    sortSeg:SetPoint("RIGHT", sortRow, "RIGHT", 0, 0)
    sortSeg:Set(ZL_Settings.sort == "LEVEL" and 2 or 1)
    for _, b in ipairs(sortSeg.buttons) do b.text:SetFont(U.FONT, 11) end
    F.sortRow = sortRow

    sideList = U.List(side, 28, makeSideRow, fillSideRow)
    sideList:SetPoint("TOPLEFT", side, "TOPLEFT", 0, -38)
    sideList:SetWidth(SIDEBAR_W - 1)
    sideList:SetHeight(H - HEADER_H - 44)

    -- instance view
    local inst = CreateFrame("Frame", nil, F)
    inst:SetPoint("TOPLEFT", F, "TOPLEFT", SIDEBAR_W, -HEADER_H)
    inst:SetWidth(W - SIDEBAR_W)
    inst:SetHeight(H - HEADER_H)
    F.inst = inst

    F.instName = U.Text(inst, 18, C.text)
    F.instName:SetPoint("TOPLEFT", inst, "TOPLEFT", PAD + 6, -9)
    F.instSub = U.Text(inst, 11, C.sub)
    F.instSub:SetPoint("TOPLEFT", F.instName, "BOTTOMLEFT", 0, -4)

    local il = U.Tex(inst, "ARTWORK", C.line)
    il:SetHeight(1)
    il:SetPoint("TOPLEFT", inst, "TOPLEFT", 0, -INST_H)
    il:SetPoint("TOPRIGHT", inst, "TOPRIGHT", 0, -INST_H)

    local bodyH = H - HEADER_H - INST_H
    local RIGHT_W = W - SIDEBAR_W - CENTER_W

    -- centre: map on top, bosses below
    local center = CreateFrame("Frame", nil, inst)
    center:SetPoint("TOPLEFT", inst, "TOPLEFT", 0, -INST_H)
    center:SetWidth(CENTER_W)
    center:SetHeight(bodyH)
    F.center = center
    local cl = U.Tex(center, "ARTWORK", C.line)
    cl:SetWidth(1)
    cl:SetPoint("TOPRIGHT", center, "TOPRIGHT", 0, 0)
    cl:SetPoint("BOTTOMRIGHT", center, "BOTTOMRIGHT", 0, 0)

    local box = CreateFrame("Frame", nil, center)
    box:SetPoint("TOPLEFT", center, "TOPLEFT", PAD, -PAD)
    box:SetWidth(VW)
    box:SetHeight(VH)
    U.Fill(box, {0, 0, 0, 0.55})
    F.mapBox = box

    local vp = CreateFrame("Frame", nil, box)
    vp:SetAllPoints(box)
    vp:EnableMouse(true)
    vp:EnableMouseWheel(true)
    F.viewport = vp
    for i = 1, 12 do
        mapTiles[i] = vp:CreateTexture(nil, "ARTWORK")
    end
    local frameBorder = CreateFrame("Frame", nil, box)
    frameBorder:SetAllPoints(box)
    frameBorder:SetFrameLevel(vp:GetFrameLevel() + 5)
    U.Border(frameBorder, C.line)

    vp:SetScript("OnMouseWheel", mapWheel)
    vp:SetScript("OnMouseDown", mapMouseDown)
    vp:SetScript("OnMouseUp", mapMouseUp)
    vp:SetScript("OnHide", function() Z.drag = nil Z.anim = nil end)
    vp:SetScript("OnUpdate", function()
        if Z.anim then animateMap(arg1) end
        if Z.drag then dragMap() end
    end)

    -- zoom tools (bottom-right of the map)
    local tools = CreateFrame("Frame", nil, box)
    tools:SetFrameLevel(vp:GetFrameLevel() + 6)
    tools:SetWidth(122)
    tools:SetHeight(22)
    tools:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -6, 6)
    F.mapTools = tools
    local function tool(label, w, x, onClick, tip)
        local b = U.Button(tools, w, 22)
        b.bg:SetVertexColor(0.05, 0.05, 0.06, 0.88)
        U.Border(b, C.line)
        b.text = U.Text(b, 12, C.text, "CENTER")
        b.text:SetPoint("CENTER", b, "CENTER", 0, 0)
        b.text:SetText(label)
        b:SetPoint("LEFT", tools, "LEFT", x, 0)
        b:SetScript("OnClick", onClick)
        b.onEnter = function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tip, 1, 1, 1)
            GameTooltip:Show()
        end
        return b
    end
    tool("-", 22, 0, function() zoomTo((Z.anim and Z.anim.target or Z.zoom) / 1.6) end, "Zoom out (mouse wheel down, right-click)")
    F.zoomText = U.Text(tools, 10, C.sub, "CENTER")
    F.zoomText:SetPoint("LEFT", tools, "LEFT", 22, 0)
    F.zoomText:SetWidth(32)
    tool("+", 22, 54, function() zoomTo((Z.anim and Z.anim.target or Z.zoom) * 1.6) end, "Zoom in (mouse wheel up)")
    tool("Reset", 42, 80, function() resetMap() end, "Reset view (or middle-click the map). Drag to pan.")

    F.mapEmpty = U.Text(box, 12, C.muted, "CENTER")
    F.mapEmpty:SetPoint("CENTER", box, "CENTER", 0, 0)
    F.mapEmpty:SetText("No map for this instance yet.")
    F.mapEmpty:Hide()

    bossList = U.List(center, 28, makeBossRow, fillBossRow)
    bossList:SetPoint("TOPLEFT", center, "TOPLEFT", PAD, -(PAD + VH + 10))
    bossList:SetWidth(VW + 10)
    bossList:SetHeight(bodyH - VH - 2 * PAD - 10)

    -- right: Loot / About
    local right = CreateFrame("Frame", nil, inst)
    right:SetPoint("TOPLEFT", inst, "TOPLEFT", CENTER_W, -INST_H)
    right:SetWidth(RIGHT_W)
    right:SetHeight(bodyH)

    paneSeg = U.Segmented(inst, {"Loot", "About"}, 72, 26, function(i) SetPane(i) end)
    paneSeg:SetPoint("TOPRIGHT", inst, "TOPRIGHT", -PAD, -12)

    local function newPane()
        local p = CreateFrame("Frame", nil, right)
        p:SetPoint("TOPLEFT", right, "TOPLEFT", 0, 0)
        p:SetWidth(RIGHT_W)
        p:SetHeight(bodyH)
        p:Hide()
        return p
    end

    local lp = newPane()
    panes[1] = lp
    classDD = U.Dropdown(lp, 128, 24, function(v)
        ZL_FilterClass = v
        RefreshLoot()
    end)
    classDD:SetPoint("TOPLEFT", lp, "TOPLEFT", PAD, -PAD)
    classDD.text:SetFont(U.FONT, 11)
    local copts = {{text = "All classes", value = "ALL"}}
    local classNames = {}
    for _, v in pairs(ZLLib.Classes) do table.insert(classNames, v) end
    table.sort(classNames)
    for _, v in ipairs(classNames) do
        local col = ZLLib.ClassColorLinks[v]
        table.insert(copts, {text = v, value = v, color = col and col.RGB and {col.RGB[1], col.RGB[2], col.RGB[3], 1}})
    end
    classDD:SetOptions(copts)
    slotDD = U.Dropdown(lp, 128, 24, function(v)
        S.slot = v
        RefreshLoot()
    end)
    slotDD:SetPoint("LEFT", classDD, "RIGHT", 6, 0)
    slotDD.text:SetFont(U.FONT, 11)
    countText = U.Text(lp, 10, C.muted, "RIGHT")
    countText:SetPoint("TOPRIGHT", lp, "TOPRIGHT", -PAD, -PAD - 32)
    lootList = U.List(lp, 40, makeLootRow, fillLootRow)
    lootList:SetPoint("TOPLEFT", lp, "TOPLEFT", 2, -PAD - 46)
    lootList:SetWidth(RIGHT_W - 4)
    lootList:SetHeight(bodyH - PAD - 50)
    F.lootEmpty = U.Text(lp, 12, C.muted, "CENTER")
    F.lootEmpty:SetPoint("TOP", lp, "TOP", 0, -100)
    F.lootEmpty:SetWidth(RIGHT_W - 40)
    F.lootEmpty:SetText("No loot matches these filters.")
    F.lootEmpty:Hide()

    local ap = newPane()
    panes[2] = ap
    local scroll = CreateFrame("ScrollFrame", nil, ap)
    scroll:SetPoint("TOPLEFT", ap, "TOPLEFT", PAD + 4, -PAD - 4)
    scroll:SetWidth(RIGHT_W - 2 * PAD - 8)
    scroll:SetHeight(bodyH - 2 * PAD - 8)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(RIGHT_W - 2 * PAD - 8)
    child:SetHeight(10)
    scroll:SetScrollChild(child)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function()
        local maxS = math.max(0, child:GetHeight() - this:GetHeight())
        local v = this:GetVerticalScroll() - arg1 * 40
        if v < 0 then v = 0 end
        if v > maxS then v = maxS end
        this:SetVerticalScroll(v)
    end)
    F.aboutScroll = scroll
    F.aboutChild = child

    -- search results (covers the instance view)
    local sr = CreateFrame("Frame", nil, F)
    sr:SetPoint("TOPLEFT", F, "TOPLEFT", SIDEBAR_W, -HEADER_H)
    sr:SetPoint("BOTTOMRIGHT", F, "BOTTOMRIGHT", 0, 0)
    sr:Hide()
    F.search = sr
    F.searchTitle = U.Text(sr, 15, C.text)
    F.searchTitle:SetPoint("TOPLEFT", sr, "TOPLEFT", PAD + 8, -20)
    searchList = U.List(sr, 42, makeSearchRow, fillSearchRow)
    searchList:SetPoint("TOPLEFT", sr, "TOPLEFT", 6, -50)
    searchList:SetWidth(W - SIDEBAR_W - 12)
    searchList:SetHeight(H - HEADER_H - 56)
    F.searchEmpty = U.Text(sr, 13, C.muted, "CENTER")
    F.searchEmpty:SetPoint("TOP", sr, "TOP", 0, -100)
    F.searchEmpty:SetText("Nothing found. Item names appear once the game has seen the item.")
    F.searchEmpty:Hide()

    tabSeg:Set(S.tab)
    paneSeg:Set(S.pane)
end

---------------------------------------------------------------- open / auto-select

local function currentInstance()
    local zone = GetRealZoneText and GetRealZoneText()
    if not zone or zone == "" then return nil end
    for _, l in ipairs({ZLDB.DG or {}, ZLDB.R or {}}) do
        for _, inst in pairs(l) do
            if inst.Name == zone then return inst end
        end
    end
    -- Dire Maul wings, Blackrock Spire halves, Scarlet Monastery wings: match the start of the name
    for _, l in ipairs({ZLDB.DG or {}, ZLDB.R or {}}) do
        for _, inst in pairs(l) do
            if inst.Name and string.find(inst.Name, zone, 1, true) then return inst end
        end
    end
end

local function targetBoss(inst)
    if not inst or not UnitExists("target") then return nil end
    local name = UnitName("target")
    for _, b in ipairs(inst.Bosses or {}) do
        if b.Name == name then return b end
    end
end

function ZL_Open()
    ZL_EnsureData()
    if not F then build() end
    local here = currentInstance()
    if here then
        local boss = targetBoss(here)
        if here ~= S.inst or boss then
            SelectInstance(here, boss)
        end
    elseif not S.inst then
        S.tab = 1
        tabSeg:Set(1)
        RefreshSidebar()
        SelectInstance(sideList.data[1])
    end
    F:Show()
end

function ZL_Toggle()
    if F and F:IsShown() then
        F:Hide()
    else
        ZL_Open()
    end
end

-- Small public API (other zSuite addons, tests)
ZL_API = {
    Open = function() ZL_Open() end,
    SelectInstance = function(inst, boss) ZL_Open() SelectInstance(inst, boss) end,
    SelectBoss = function(boss) SelectBoss(boss) end,
    SetPane = function(i) SetPane(i) end,
    SelectTab = function(t) SelectTab(t) end,
    Search = function(q) F.searchBox:SetText(q or "") ShowSearch(q and string.len(q) >= 3, q) end,
    Lists = function() return sideList, bossList, lootList, searchList end,
    Zoom = function(z, x, y) zoomAt(z, x, y) end,
    ResetMap = function() resetMap() end,
    MapState = function() return Z end,
    Tick = function(e) animateMap(e or 0.05) end,
    Drag = function() dragMap() end,
}
