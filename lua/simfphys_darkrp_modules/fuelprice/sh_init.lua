if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "client/cl_fuel_pump_ui.lua" )
end

include( "sh_config.lua" )
include( "sh_utils.lua" )

if SERVER then
    include( "server/sv_main.lua" )
else
    include( "client/cl_fuel_pump_ui.lua" )
end

include( "modules/sh_init.lua" )

-- Setup hooks
hook.Add( "InitPostEntity", "LoadSimfPhysFuelPrices", function()
    if SERVER then
        FuelPrices:Init()
    else
        FuelPrices:InitPumps()
        FuelPrices:InitPumpUIs()
    end

    FuelPrices:InitWatcher()
end )
