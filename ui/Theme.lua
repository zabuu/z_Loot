-- zLoot UI kit: flat dark theme, text helpers, virtualized lists. Lua 5.0 (WoW 1.12).

ZLUI = {}
local U = ZLUI

U.FONT = "Fonts\\FRIZQT__.TTF"
U.WHITE = "Interface\\Buttons\\WHITE8X8"

U.C = {
    bg = {0.067, 0.075, 0.086, 0.97},
    panel = {0.094, 0.102, 0.118, 1},
    raised = {0.125, 0.133, 0.153, 1},
    hover = {1, 1, 1, 0.05},
    line = {1, 1, 1, 0.08},
    accent = {0.96, 0.74, 0.26, 1},
    accentSoft = {0.96, 0.74, 0.26, 0.14},
    text = {0.93, 0.93, 0.94, 1},
    sub = {0.66, 0.68, 0.72, 1},
    muted = {0.46, 0.48, 0.52, 1},
    danger = {0.95, 0.36, 0.36, 1},
}

function U.Tex(parent, layer, c)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND")
    t:SetTexture(U.WHITE)
    if c then
        t:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
    end
    return t
end

function U.Fill(frame, c, layer)
    local t = U.Tex(frame, layer or "BACKGROUND", c)
    t:SetAllPoints(frame)
    return t
end

-- 1px border made of four textures
function U.Border(frame, c)
    local b = {}
    local function edge()
        local t = U.Tex(frame, "BORDER", c)
        table.insert(b, t)
        return t
    end
    local t = edge() t:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0) t:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0) t:SetHeight(1)
    t = edge() t:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0) t:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0) t:SetHeight(1)
    t = edge() t:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0) t:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0) t:SetWidth(1)
    t = edge() t:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0) t:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0) t:SetWidth(1)
    frame.borderTex = b
    return b
end

function U.SetBorderColor(frame, c)
    for _, t in ipairs(frame.borderTex or {}) do
        t:SetVertexColor(c[1], c[2], c[3], c[4] or 1)
    end
end

function U.Text(parent, size, c, justify, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY")
    fs:SetFont(U.FONT, size or 13)
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 0.6)
    c = c or U.C.text
    fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)
    fs:SetJustifyH(justify or "LEFT")
    return fs
end

function U.Color(fs, c)
    fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)
end

-- Flat clickable row/button with hover + selected states
function U.Button(parent, w, h)
    local b = CreateFrame("Button", nil, parent)
    if w then b:SetWidth(w) end
    if h then b:SetHeight(h) end
    b.bg = U.Fill(b, {0, 0, 0, 0})
    b.hl = U.Fill(b, U.C.hover, "ARTWORK")
    b.hl:Hide()
    b:SetScript("OnEnter", function() this.hl:Show() if this.onEnter then this.onEnter(this) end end)
    b:SetScript("OnLeave", function() this.hl:Hide() if this.onLeave then this.onLeave(this) end GameTooltip:Hide() end)
    return b
end

-- Selected style: soft accent fill + 3px accent bar on the left
function U.SetSelected(b, on)
    if not b.selBar then
        b.selBar = U.Tex(b, "ARTWORK", U.C.accent)
        b.selBar:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
        b.selBar:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 0, 0)
        b.selBar:SetWidth(3)
    end
    if on then
        b.bg:SetVertexColor(U.C.accentSoft[1], U.C.accentSoft[2], U.C.accentSoft[3], U.C.accentSoft[4])
        b.selBar:Show()
    else
        b.bg:SetVertexColor(0, 0, 0, 0)
        b.selBar:Hide()
    end
end

-- Segmented control: labels -> buttons, onSelect(index)
function U.Segmented(parent, labels, w, h, onSelect)
    local seg = CreateFrame("Frame", nil, parent)
    seg:SetWidth(w * table.getn(labels))
    seg:SetHeight(h)
    U.Fill(seg, U.C.panel)
    U.Border(seg, U.C.line)
    seg.buttons = {}
    for i, label in ipairs(labels) do
        local b = U.Button(seg, w, h)
        b:SetPoint("TOPLEFT", seg, "TOPLEFT", (i - 1) * w, 0)
        b.text = U.Text(b, 13, U.C.sub, "CENTER")
        b.text:SetPoint("CENTER", b, "CENTER", 0, 0)
        b.text:SetText(label)
        b.under = U.Tex(b, "ARTWORK", U.C.accent)
        b.under:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 6, 1)
        b.under:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -6, 1)
        b.under:SetHeight(2)
        b.index = i
        b:SetScript("OnClick", function()
            if this.disabled then return end
            PlaySound("igMainMenuOptionCheckBoxOn")
            onSelect(this.index)
        end)
        seg.buttons[i] = b
    end
    function seg:Set(index)
        for i, b in ipairs(self.buttons) do
            if i == index then
                b.bg:SetVertexColor(U.C.raised[1], U.C.raised[2], U.C.raised[3], 1)
                U.Color(b.text, U.C.text)
                b.under:Show()
            else
                b.bg:SetVertexColor(0, 0, 0, 0)
                U.Color(b.text, b.disabled and U.C.muted or U.C.sub)
                b.under:Hide()
            end
        end
    end
    function seg:SetDisabled(index, off)
        local b = self.buttons[index]
        b.disabled = off
        b:EnableMouse(not off)
        b.text:SetAlpha(off and 0.35 or 1)
    end
    return seg
end

-- Thin vertical scrollbar (Slider)
local sliderCount = 0
function U.ScrollBar(parent)
    sliderCount = sliderCount + 1
    local s = CreateFrame("Slider", "ZLUIScroll" .. sliderCount, parent)
    s:SetOrientation("VERTICAL")
    s:SetWidth(6)
    U.Fill(s, {1, 1, 1, 0.03})
    s:SetThumbTexture(U.WHITE)
    local thumb = s:GetThumbTexture()
    thumb:SetVertexColor(1, 1, 1, 0.22)
    thumb:SetWidth(6)
    thumb:SetHeight(40)
    s:SetValueStep(1)
    s:SetMinMaxValues(0, 0)
    s:SetValue(0)
    return s
end

-- Virtualized list: only visible rows exist. makeRow(list) -> row, fillRow(row, item, index)
function U.List(parent, rowH, makeRow, fillRow)
    local list = CreateFrame("Frame", nil, parent)
    list.rowH = rowH
    list.rows = {}
    list.data = {}
    list.offset = 0
    list.makeRow = makeRow
    list.fillRow = fillRow
    list:EnableMouseWheel(true)
    local bar = U.ScrollBar(list)
    bar:SetPoint("TOPRIGHT", list, "TOPRIGHT", -2, -2)
    bar:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -2, 2)
    bar:SetScript("OnValueChanged", function()
        local v = math.floor(this:GetValue() + 0.5)
        if v ~= list.offset then
            list.offset = v
            list:Refresh(true)
        end
    end)
    list.bar = bar
    list:SetScript("OnMouseWheel", function()
        list.offset = list.offset - arg1 * 3
        list:Refresh()
    end)

    function list:Visible()
        return math.floor((self:GetHeight() or 0) / self.rowH)
    end

    function list:SetData(data, keepOffset)
        self.data = data or {}
        if not keepOffset then
            self.offset = 0
        end
        self:Refresh()
    end

    function list:Refresh(fromBar)
        local n = table.getn(self.data)
        local vis = self:Visible()
        local maxOff = n - vis
        if maxOff < 0 then maxOff = 0 end
        if self.offset > maxOff then self.offset = maxOff end
        if self.offset < 0 then self.offset = 0 end
        for i = 1, vis do
            local row = self.rows[i]
            if not row then
                row = self.makeRow(self)
                row:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(i - 1) * self.rowH)
                row:SetPoint("RIGHT", self, "RIGHT", -10, 0)
                row:SetHeight(self.rowH)
                self.rows[i] = row
            end
            local idx = self.offset + i
            local item = self.data[idx]
            if item then
                row.item = item
                row.index = idx
                self.fillRow(row, item, idx)
                row:Show()
            else
                row.item = nil
                row:Hide()
            end
        end
        for i = vis + 1, table.getn(self.rows) do
            self.rows[i]:Hide()
        end
        if maxOff > 0 then
            self.bar:SetMinMaxValues(0, maxOff)
            if not fromBar then self.bar:SetValue(self.offset) end
            self.bar:Show()
        else
            self.bar:Hide()
        end
    end

    function list:ScrollTo(idx)
        local vis = self:Visible()
        if idx <= self.offset then
            self.offset = idx - 1
        elseif idx > self.offset + vis then
            self.offset = idx - vis
        end
        self:Refresh()
    end

    return list
end

-- Simple flat dropdown: button + popup list of {text, value}
local openMenu
function U.Dropdown(parent, w, h, onPick)
    local d = U.Button(parent, w, h)
    d.bg:SetVertexColor(U.C.panel[1], U.C.panel[2], U.C.panel[3], 1)
    U.Border(d, U.C.line)
    d.text = U.Text(d, 12, U.C.text)
    d.text:SetPoint("LEFT", d, "LEFT", 10, 0)
    d.text:SetPoint("RIGHT", d, "RIGHT", -20, 0)
    d.arrow = U.Text(d, 12, U.C.sub, "RIGHT")
    d.arrow:SetPoint("RIGHT", d, "RIGHT", -8, 0)
    d.arrow:SetText("v")
    d.options = {}

    local menu = CreateFrame("Frame", nil, d)
    menu:SetFrameStrata("FULLSCREEN_DIALOG")
    menu:SetPoint("TOPLEFT", d, "BOTTOMLEFT", 0, -2)
    menu:SetWidth(w)
    U.Fill(menu, U.C.raised)
    U.Border(menu, U.C.line)
    menu:EnableMouse(true)
    menu:Hide()
    menu.rows = {}
    d.menu = menu

    function d:SetOptions(opts)
        self.options = opts
    end

    d:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
            return
        end
        if openMenu and openMenu ~= menu then openMenu:Hide() end
        openMenu = menu
        for i, opt in ipairs(d.options) do
            local r = menu.rows[i]
            if not r then
                r = U.Button(menu, w - 2, 24)
                r.text = U.Text(r, 12, U.C.text)
                r.text:SetPoint("LEFT", r, "LEFT", 10, 0)
                r:SetPoint("TOPLEFT", menu, "TOPLEFT", 1, -1 - (i - 1) * 24)
                r:SetScript("OnClick", function()
                    menu:Hide()
                    onPick(this.value)
                end)
                menu.rows[i] = r
            end
            r.value = opt.value
            r.text:SetText(opt.text)
            if opt.color then U.Color(r.text, opt.color) else U.Color(r.text, U.C.text) end
            r:Show()
        end
        for i = table.getn(d.options) + 1, table.getn(menu.rows) do
            menu.rows[i]:Hide()
        end
        menu:SetHeight(table.getn(d.options) * 24 + 2)
        menu:Show()
    end)
    return d
end
