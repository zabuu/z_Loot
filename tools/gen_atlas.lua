dofile("/tmp/claude-0/w/atlasload.lua")
local S=AtlasCFM.Server
S.GetActive=function() return S.TURTLE end
local vis=function(e) return S.IsVisible(e) end
local captured
AtlasCFM.LootBrowserUI=AtlasCFM.LootBrowserUI or {}
AtlasCFM.LootBrowserUI.PrepMenu=function(title,menu) captured={title=title,menu=menu} end
local out={}
local function w(s) table.insert(out,s) end
local function q(s) return string.format("%q",s) end
local function clean(s) s=tostring(s or "") s=string.gsub(s,"|c%x%x%x%x%x%x%x%x","") s=string.gsub(s,"|r","") return s end
local function seq(t) local r={} if type(t)~="table" then return r end local n=0 for k in pairs(t) do if type(k)=="number" and k>n then n=k end end for i=1,n do if t[i]~=nil then table.insert(r,t[i]) end end return r end
local RS,FS="\30","\31"
-- where each item drops: id -> { {boss, instance, rate}, ... } from every Atlas instance table
local SOURCES={}
do
  local skip={RareMobs=false}
  for key,data in pairs(AtlasCFM.InstanceData) do
    if type(data)=="table" and type(data.Bosses)=="table" then
      local iname=clean(data.Name or key)
      for _,b in ipairs(seq(data.Bosses)) do
        if type(b)=="table" and vis(b) and b.name then
          local bname=clean(b.name)
          for _,e in ipairs(seq(b.items or b.loot)) do
            if type(e)=="table" and type(e.id)=="number" and vis(e) and not e.skill then
              local list=SOURCES[e.id] or {}
              SOURCES[e.id]=list
              local dup=false
              for _,s0 in ipairs(list) do if s0[1]==bname and s0[2]==iname then dup=true end end
              if not dup then table.insert(list,{bname,iname,e.dropRate}) end
            end
          end
        end
      end
    end
  end
end
local SS,SF="\28","\29"
local function sourceString(id)
  local list=SOURCES[id]
  if not list then return "" end
  local r={}
  for i,s0 in ipairs(list) do
    if i>4 then break end
    table.insert(r,s0[1]..SF..s0[2]..SF..(s0[3] and tostring(s0[3]) or ""))
  end
  if table.getn(list)>4 then table.insert(r,"+"..(table.getn(list)-4)) end
  return table.concat(r,SS)
end
local function icon(s) if not s or s=="" then return nil end s=string.gsub(s,"^Interface\\Icons\\","") s=string.gsub(s,"^Interface\\icons\\","") return s end
local nItems=0
COLLECTION_IDS={}
local function pageString(rows)
  local r={}
  -- Atlas pages are laid out in blocks of 15: blocks 1,3,5.. form the left column and 2,4,6.. the right.
  -- Read them column by column so a set that continues in a later block stays under its own header.
  local ordered={}
  if type(rows)=="table" then
    local n=0 for k in pairs(rows) do if type(k)=="number" and k>n then n=k end end
    local idx={} for i=1,n do if rows[i]~=nil then table.insert(idx,i) end end
    local function key(i) local b=math.floor((i-1)/15) return math.mod(b,2)*1e6+i end
    table.sort(idx,function(a,b) return key(a)<key(b) end)
    for _,i in ipairs(idx) do table.insert(ordered,rows[i]) end
  end
  for _,e in ipairs(ordered) do
    if type(e)=="table" and vis(e) then
      if e.id and type(e.id)=="number" and not e.skill then
        local cont={}
        if type(e.container)=="table" then
          for _,c in ipairs(e.container) do
            if type(c)=="number" then table.insert(cont,c)
            elseif type(c)=="table" and vis(c) and type(c[1])=="number" then table.insert(cont,c[1]) end
          end
        end
        local f={tostring(e.id), e.dropRate and tostring(e.dropRate) or "", clean(e.disc), table.concat(cont," "), sourceString(e.id)}
        local s=table.concat(f,FS) s=string.gsub(s,FS.."+$","")
        table.insert(r,s) nItems=nItems+1 COLLECTION_IDS[e.id]=true
      elseif e.name and not e.id then
        table.insert(r,"#"..clean(e.name)..(icon(e.icon) and (FS..icon(e.icon)) or ""))
      end
    end
  end
  -- drop trailing headers with nothing after them
  return table.concat(r,RS)
end
local function resolve(lp)
  if not lp then return nil end
  if AtlasCFMLoot_Data[lp] then return "page",AtlasCFMLoot_Data[lp] end
  if AtlasCFM.InstanceData[lp] then return "inst",AtlasCFM.InstanceData[lp] end
  if AtlasCFM.MenuData[lp] then return "menu",AtlasCFM.MenuData[lp] end
  if type(_G[lp])=="function" then captured=nil pcall(_G[lp]) if captured then return "menu",captured.menu end end
  return nil
end
local tiles={}
local function addTile(name,iconp,entries) if table.getn(entries)>0 then table.insert(tiles,{name=name,icon=iconp,entries=entries}) end end
local unresolved={}
-- turn a menu into leaf entries; submenus become their own tiles when top=true
local function leaves(menu,prefix,acc,depth)
  for _,m in ipairs(seq(menu)) do
    if type(m)=="table" and m.name and vis(m) then
      local kind,data=resolve(m.lootpage)
      local nm=(prefix and (prefix.." - ") or "")..clean(m.name)
      if kind=="page" then
        local ps=pageString(data) if ps~="" then table.insert(acc,{name=nm,icon=icon(m.icon),L=ps}) end
      elseif kind=="inst" then
        for _,b in ipairs(seq(data.Bosses)) do if vis(b) then
          local ps=pageString(b.items or b.loot) if ps~="" then table.insert(acc,{name=clean(b.name),icon=icon(m.icon),L=ps}) end end end
      elseif kind=="menu" and depth<4 then
        leaves(data,nm,acc,depth+1)
      else unresolved[tostring(m.lootpage)]=true end
    end
  end
end
local function topMenu(title,menu,iconp)
  local direct={} local startIdx=table.getn(tiles)
  for _,m in ipairs(seq(menu)) do
    if type(m)=="table" and m.name and vis(m) then
      local kind,data=resolve(m.lootpage)
      if kind=="menu" then
        local acc={} leaves(data,nil,acc,1) addTile(clean(m.name),icon(m.icon),acc)
      elseif kind=="page" then
        local ps=pageString(data) if ps~="" then table.insert(direct,{name=clean(m.name),icon=icon(m.icon),L=ps}) end
      elseif kind=="inst" then
        local acc={} for _,b in ipairs(seq(data.Bosses)) do if vis(b) then local ps=pageString(b.items or b.loot) if ps~="" then table.insert(acc,{name=clean(b.name),icon=icon(m.icon),L=ps}) end end end
        if table.getn(acc)==1 then acc[1].name=clean(m.name) table.insert(direct,acc[1]) else addTile(clean(m.name),icon(m.icon),acc) end
      else unresolved[tostring(m.lootpage)]=true end
    end
  end
  if table.getn(direct)>0 then table.insert(tiles,startIdx+1,{name=title,icon=iconp,entries=direct,first=true}) end
end
local L=AtlasCFM.Localization.UI
local groups={
 {"Sets & Collections",AtlasCFM.MenuData.Sets,"INV_Staff_Medivh"},
 {"PvP",AtlasCFM.MenuData.PVP,"INV_Jewelry_Necklace_21"},
 {"Factions",AtlasCFM.MenuData.Factions,"INV_Misc_Tabard_Shendralar"},
 {"World Events",AtlasCFM.MenuData.WorldEvents,"INV_Misc_Bag_17"},
}
local order={}
for gi,g in ipairs(groups) do
  local before=table.getn(tiles)
  topMenu(g[1],g[2],g[3])
  for i=before+1,table.getn(tiles) do tiles[i].group=g[1] end
end
-- rare mobs
do local d=AtlasCFM.InstanceData.RareMobs local acc={}
  for _,b in ipairs(d.Bosses or {}) do if vis(b) then local ps=pageString(b.items or b.loot) if ps~="" then table.insert(acc,{name=clean(b.name),L=ps}) end end end
  addTile("Rare Mobs","INV_Misc_Head_Dragon_01",acc) tiles[table.getn(tiles)].group="World" end
w("-- zLoot collections data. Generated from Atlas-CFM loot tables (GPL). Do not edit by hand.")
w("ZLDB=ZLDB or {} ZLDB.C={}")
for i,t in ipairs(tiles) do
  w("ZLDB.C["..i.."]={Key="..q("C"..i)..",Name="..q(t.name)..",Group="..q(t.group or "")..",Icon="..q(t.icon or "INV_Misc_QuestionMark")..",Bosses={")
  for _,e in ipairs(t.entries) do
    w("{Name="..q(e.name)..(e.icon and (",Icon="..q(e.icon)) or "")..",L="..q(e.L).."},")
  end
  w("}}")
end
-- trash drops for each journal instance (journal loot format "id:chance,...")
do
  local MAP={BFD={"BlackfathomDeeps"},BRD={"BlackrockDepths"},LBRS={"BlackrockSpireLower"},UBRS={"BlackrockSpireUpper"},
    BWL={"BlackwingLair"},BM={"CavernsOfTimeBlackMorass"},DME={"DireMaulEast"},DMN={"DireMaulNorth"},DMW={"DireMaulWest"},
    DMR={"DragonmawRetreat"},ES={"EmeraldSanctum"},GC={"GilneasCity"},GNOMEREGAN={"Gnomeregan","GnomereganEnt"},
    HQ={"HateforgeQuarry"},KC={"KarazhanCrypt"},KARA10={"LowerKarazhan"},KARA40={"TowerofKarazhan"},MARA={"Maraudon"},
    MC={"MoltenCore"},NAXX={"Naxxramas"},RFC={"RagefireChasm"},RFD={"RazorfenDowns"},RFK={"RazorfenKraul"},
    SMARM={"ScarletMonasteryArmory"},SMCATH={"ScarletMonasteryCathedral"},SMGY={"ScarletMonasteryGraveyard"},
    SMLIB={"ScarletMonasteryLibrary"},SCHOLO={"Scholomance"},SFK={"ShadowfangKeep"},SV={"StormwindVault"},
    SWR={"StormwroughtRuins"},STRAT={"Stratholme"},CG={"TheCrescentGrove"},DEADMINES={"TheDeadmines"},
    AQ20={"TheRuinsofAhnQiraj"},STOCKADES={"TheStockade"},ST={"TheSunkenTemple"},AQ40={"TheTempleofAhnQiraj"},
    TH={"TimbermawHold"},ULDA={"Uldaman"},WC={"WailingCaverns"},WHC={"WindhornCanyon"},ZF={"ZulFarrak"},ZG={"ZulGurub"}}
  local keys={} for k in pairs(MAP) do table.insert(keys,k) end table.sort(keys)
  local parts={}
  for _,k in ipairs(keys) do
    local seen,list={},{}
    for _,ak in ipairs(MAP[k]) do
      local d=AtlasCFM.InstanceData[ak]
      if not d then io.stderr:write("trash: no atlas data "..ak.."\n") end
      for _,b in ipairs(seq(d and d.Bosses)) do
        if type(b)=="table" and vis(b) and b.id and string.find(tostring(b.id),"Trash") then
          local def=type(b.defaults)=="table" and b.defaults.dropRate
          for _,e in ipairs(seq(b.items or b.loot)) do
            if type(e)=="table" and vis(e) and type(e.id)=="number" and not e.skill and not seen[e.id] then
              seen[e.id]=true
              local r=e.dropRate or def
              table.insert(list,e.id..(r and (":"..r) or ""))
              COLLECTION_IDS[e.id]=true
            end
          end
        end
      end
    end
    if table.getn(list)>0 then table.insert(parts,k.."="..q(table.concat(list,","))) end
  end
  w("ZLDB.TRASH={"..table.concat(parts,",").."}")
  io.stderr:write("trash instances "..table.getn(parts).."\n")
end
-- item names from the comments in Atlas-CFM's data files (fills names for items the journal lacks)
do
  local names={}
  local function scan(path)
    local fh=io.open(path) if not fh then return end
    for line in fh:lines() do
      local _,_,id,name=string.find(line,"id%s*=%s*(%d+).-%-%-%s*(.-)%s*$")
      if id and name and name~="" and not names[tonumber(id)] then names[tonumber(id)]=name end
    end
    fh:close()
  end
  local base="/mnt/user-data/uploads/AddOns/Atlas-CFM/CFMLoot/Data/"
  local p=io.popen('find "'..base..'" -name "*.lua"')
  for path in p:lines() do scan(path) end
  p:close()
  local ids={}
  local known={}
  local dfh=io.open("/tmp/claude-0/w/build/one/z_Loot/src/Data.lua")
  local dsrc=dfh:read("*a") dfh:close()
  local _,isStart=string.find(dsrc,"ZLDB.IS={",1,true)
  for id in string.gmatch(string.sub(dsrc,isStart or 1),"%[(%d+)%]=") do known[tonumber(id)]=true end
  for id in pairs(names) do if COLLECTION_IDS[id] and not known[id] then table.insert(ids,id) end end
  table.sort(ids)
  local parts={}
  for _,id in ipairs(ids) do table.insert(parts,"["..id.."]="..q(names[id])) end
  w("ZLDB.CN={"..table.concat(parts,",").."}")
  io.stderr:write("names "..table.getn(ids).."\n")
end
local u={} for k in pairs(unresolved) do table.insert(u,k) end table.sort(u)
io.stderr:write("tiles "..table.getn(tiles).." rows "..nItems.." unresolved: "..table.concat(u,", ").."\n")
for i,t in ipairs(tiles) do io.stderr:write(string.format("%2d %-22s %-32s %d\n",i,t.group or "",t.name,table.getn(t.entries))) end
local f=io.open(arg[1],"w") f:write(table.concat(out,"\n")) f:close()
