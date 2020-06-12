include( "sh_config.lua" )
include( "sh_utils.lua" )

if SERVER then
    include( "server/sv_main.lua" )
    include( "server/sv_net.lua" )

    AddCSLuaFile( "client/cl_fuel_pump_ui.lua" )
else
    include( "client/cl_fuel_pump_ui.lua" )
end

include( "modules/sh_init.lua" )
