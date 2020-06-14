AddCSLuaFile()

local function spawnPumps()
    if SERVER then
        SimfPhysPersistence:SpawnPumps()
    end
end

hook.Add( "InitPostEntity", "SimfPhysPersistenceInitCommand", function()
    local respawnPumpsCommand = ulx.command( "SimfPhys", "ulx spawnpumps", spawnPumps, "!spawnpumps" )
    respawnPumpsCommand:defaultAccess( ULib.ACCESS_ADMIN )
    respawnPumpsCommand:help( "Respawns persisted SimfPhys pumps" )
end )
