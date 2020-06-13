AddCSLuaFile()

local _, modules = file.Find( "simfphys_darkrp_modules/*", "LUA" )

for _, module in pairs( modules ) do
    include( module .. "/sh_init.lua" )
end
