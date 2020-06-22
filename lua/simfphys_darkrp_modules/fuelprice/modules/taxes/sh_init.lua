AddCSLuaFile()
include( "sh_config.lua" )
include( "sh_utils.lua" )

if SERVER then
    include( "server/sv_main.lua" )
end
