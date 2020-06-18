AddCSLuaFile()

include( "server/sv_main.lua" )

AddCSLuaFile( "client/cl_main.lua" )
if CLIENT then
    include( "client/cl_main.lua" )
end
