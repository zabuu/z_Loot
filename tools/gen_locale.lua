local before={} for k in pairs(_G) do before[k]=true end
GetLocale=function() return "enUS" end
dofile("/mnt/user-data/uploads/AddOns/InstanceJournal/locale/InstanceJournal-enUS.lua")
local keys={}
for k,v in pairs(_G) do
  if not before[k] and type(k)=="string" and string.find(k,"^IJ_") and type(v)=="string"
    and not string.find(k,"^IJ_LOOT_NAME") and not string.find(k,"^IJ_QUEST_") and not string.find(k,"^IJ_NPC_NAME") and not string.find(k,"^IJ_DB_") and not string.find(k,"^IJ_SPELL_NAME") then
    table.insert(keys,k) end
end
table.sort(keys)
local o={"-- zLoot strings (enUS), trimmed from InstanceJournal's locale.","BINDING_HEADER_ZLOOT = \"zLoot\"","BINDING_NAME_ZLOOT_TOGGLE = \"Toggle zLoot\""}
for _,k in ipairs(keys) do table.insert(o,"ZL_"..string.sub(k,4).." = "..string.format("%q",_G[k])) end
local f=io.open(arg[1],"w") f:write(table.concat(o,"\n").."\n") f:close()
print(table.getn(keys))
