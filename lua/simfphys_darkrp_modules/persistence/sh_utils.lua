AddCSLuaFile()

local function spawnPumps()
    if SERVER then
        SimfPhysPersistence:SpawnPumps()
    end
end

hook.Add( "Initialize", "InitializeSimfPhysPersistenceCommand", function()
    local respawnPumpsCommand = ulx.command( ULX_CATEGORY_NAME, "ulx spawnpumps", spawnPumps, "!spawnpumps" )
    respawnPumpsCommand:defaultAccess( ULib.ACCESS_ADMIN )
    respawnPumpsCommand:help( "Respawns persisted SimfPhys pumps" )
end )
