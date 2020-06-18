AddCSLuaFile()

if SERVER then
    include( "server/sv_main.lua" )

    AddCSLuaFile( "client/cl_main.lua" )
end

if CLIENT then
    include( "client/cl_main.lua" )
end
