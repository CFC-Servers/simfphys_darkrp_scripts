AddCSLuaFile()

include( "sh_config.lua" )

if FuelPrices.Config.Modules.taxes then
    include( "taxes/sh_init.lua" )
end
