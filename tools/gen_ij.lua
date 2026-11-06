dofile("/tmp/claude-0/w/gen/ij_load.lua")
local out={}
local function w(s) table.insert(out,s) end
local function q(s) return string.format("%q",s) end
local MEDIA="Interface\\AddOns\\InstanceJournal\\media\\"
local function media(s)
  if type(s)=="string" and string.sub(s,1,string.len(MEDIA))==MEDIA then return "M.."..q(string.sub(s,string.len(MEDIA)+1)) end
  return nil
end
-- reverse maps
local function rev(t) local r={} for k,v in pairs(t) do if r[v]==nil then r[v]=k end end return r end
local RQ=rev(IJLib.Quality) local RS=rev(IJLib.ItemSlot) local RT=rev(IJLib.ItemType) local RC=rev(IJLib.Classes) local RCH=rev(IJLib.Challenges)
local RF=rev(IJLib.AbilityFlags) local RIT=rev(IJLib.InstanceType)
-- generic serializer
local function ser(v,ind)
  ind=ind or ""
  local t=type(v)
  if t=="string" then return media(v) or q(v)
  elseif t=="number" then return tostring(v)
  elseif t=="boolean" then return tostring(v)
  elseif t=="table" then
    if RF[v] then return "F."..RF[v] end
    local parts={}
    local n=table.getn(v)
    for i=1,n do table.insert(parts,ser(v[i],ind)) end
    local keys={} for k in pairs(v) do if not(type(k)=="number" and k>=1 and k<=n and math.floor(k)==k) then table.insert(keys,k) end end
    table.sort(keys,function(a,b) return tostring(a)<tostring(b) end)
    for _,k in ipairs(keys) do
      local ks= type(k)=="string" and string.find(k,"^[%a_][%w_]*$") and k or "["..ser(k).."]"
      table.insert(parts,ks.."="..ser(v[k],ind))
    end
    return "{"..table.concat(parts,",").."}"
  end
  return "nil"
end
-- items used
local used={}
local notes={} local noteIdx={}
local function lootString(loot)
  local s={}
  for _,e in ipairs(loot or {}) do
    local it=e[1]
    if it and it.Id then
      local id=tonumber(it.Id) used[id]=it
      local f=id..":"..(e.DropChance or "")
      if e.IsHardMode then f=f..":h" end
      if e.Note then
        local ni=noteIdx[e.Note] if not ni then table.insert(notes,e.Note) ni=table.getn(notes) noteIdx[e.Note]=ni end
        f=f..":n"..ni
      end
      table.insert(s,f)
    end
  end
  return table.concat(s,",")
end
local BOSSKEYS={"Id","Name","Story","Portrait","Frame","MapCoordinateX","MapCoordinateY","MapId","MapZoneId","MapIsBelow","IsRare","Abilities"}
local INSTKEYS={"Name","Story","Background","GridBackground","MapId","ZoneId","IconScale","MinLevel","MaxLevel","Entrances"}
local function emitInst(db,key,inst)
  w(db.."["..q(key).."]={")
  for _,k in ipairs(INSTKEYS) do if inst[k]~=nil then w(k.."="..ser(inst[k])..",") end end
  if inst.Type then w("Type=T."..RIT[inst.Type]..",") end
  w("Key="..q(key)..",")
  w("Bosses={")
  for _,b in ipairs(inst.Bosses or {}) do
    local p={}
    for _,k in ipairs(BOSSKEYS) do if b[k]~=nil then table.insert(p,k.."="..ser(b[k])) end end
    local ls=lootString(b.Loot)
    if ls~="" then table.insert(p,"L="..q(ls)) end
    w("{"..table.concat(p,",").."},")
  end
  w("}}")
end
w("-- zLoot journal data. Generated from InstanceJournal (public domain). Do not edit by hand.")
w("local M=ZLLib.MediaPath local F=ZLLib.AbilityFlags local T=ZLLib.InstanceType")
w("ZLDB=ZLDB or {} ZLDB.DG={} ZLDB.R={}")
local function sortedKeys(t) local r={} for k in pairs(t) do table.insert(r,k) end table.sort(r) return r end
for _,k in ipairs(sortedKeys(IJDB.DG)) do emitInst("ZLDB.DG",k,IJDB.DG[k]) end
for _,k in ipairs(sortedKeys(IJDB.R)) do emitInst("ZLDB.R",k,IJDB.R[k]) end
-- notes
local np={} for i,n in ipairs(notes) do np[i]=q(n) end
w("ZLDB.Notes={"..table.concat(np,",").."}")
-- items: Name|Icon|Q|Slot|Type|Classes|Challenges
w("ZLDB.IS={")
local ids=sortedKeys(used)
local cnt=0
for _,id in ipairs(ids) do
  local it=used[id]
  local cl={} for _,c in ipairs(it.ClassRestriction or {}) do table.insert(cl,RC[c] or c) end
  local ch={} for _,c in ipairs(it.ChallengeRestriction or {}) do table.insert(ch,RCH[c] or c) end
  local s=table.concat({it.Name or "",it.Icon or "",RQ[it.Quality] or "",RS[it.ItemSlot] or "",RT[it.ItemType] or "",table.concat(cl,","),table.concat(ch,",")},"|")
  s=string.gsub(s,"|+$","")
  w("["..id.."]="..q(s)..",") cnt=cnt+1
end
w("}")
io.stderr:write("items "..cnt.." notes "..table.getn(notes).."\n")
local f=io.open(arg[1],"w") f:write(table.concat(out,"\n")) f:close()
