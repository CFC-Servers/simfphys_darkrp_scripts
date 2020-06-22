AddCSLuaFile()
include( "sh_config.lua" )
include( "sh_utils.lua" )

if SERVER then
    include( "server/sv_main.lua" )
else
    include( "client/cl_main.lua" )
end

FuelPrices.modules = {}
FuelPrices.modules.taxes = true
