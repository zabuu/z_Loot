-- Loads InstanceJournal data in plain Lua 5.1 with WoW stubs
GetLocale=function() return "enUS" end
UnitClass=function() return "Warrior","WARRIOR" end
local IJB="/mnt/user-data/uploads/AddOns/InstanceJournal/"
local function L(f) local ok,e=pcall(dofile,IJB..f) if not ok then io.stderr:write("ERR "..f.." "..tostring(e).."\n") end end
L("locale/InstanceJournal-enUS.lua")
L("InstanceJournalLib.lua")
L("InstanceJournalDB.lua")
for line in io.lines(IJB.."InstanceJournal.toc") do
  line=string.gsub(line,"\r","")
  if string.find(line,"^db\\") then L(string.gsub(line,"\\","/")) end
end
