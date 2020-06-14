AddCSLuaFile()
include( "sh_config.lua" )

if SERVER then
    include( "server/sv_init.lua" )
end
