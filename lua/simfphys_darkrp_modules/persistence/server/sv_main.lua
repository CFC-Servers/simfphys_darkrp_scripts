SimfPhysPersistence = {}

local thisMap = game.GetMap()

SimfPhysPersistence.saveDir = "simfphys_persist"
SimfPhysPersistence.saveFile = SimfPhysPersistence.saveDir .. "/" .. thisMap .. ".json"
SimfPhysPersistence.isPump = {
    gmod_sent_vehicle_fphysics_gaspump = true,
    gmod_sent_vehicle_fphysics_gaspump_diesel = true,
    gmod_sent_vehicle_fphysics_gaspump_electric = true
}
SimfPhysPersistence.pumpData = {}
SimfPhysPersistence.logPrefix = "[SimfPhysPersistence] "

function SimfPhysPersistence:log( ... )
    print( self.logPrefix, ... )
end

function SimfPhysPersistence:LoadPumpData()
    if file.Exists( self.saveFile, "DATA" ) then
        local data = file.Read( self.saveFile, "DATA" )
        data = util.JSONToTable( data )

        self.pumpData = data
    else
        file.CreateDir( self.saveDir )
        file.Write( self.saveFile, "[]" )
    end
end

function SimfPhysPersistence:SavePumpsToFile()
    local pumpData = util.TableToJSON( self.pumpData )

    file.Write( self.saveFile, pumpData )
end

function SimfPhysPersistence:SavePumps()
    local pumps = {}

    for _, v in pairs( ents.GetAll() ) do
        if v:IsValid() and self.isPump[v:GetClass()] then
            local pumpStruct = {
                pos = v:GetPos(),
                ang = v:GetAngles(),
                class = v:GetClass()
            }

            table.insert( pumps, pumpStruct )
        end
    end

    self.pumpData = pumps

    self:SavePumpsToFile()
end

function SimfPhysPersistence:DeletePumps()
    for _, v in pairs( ents.GetAll() ) do
        if v:IsValid() and self.isPump[v:GetClass()] then
            v:Remove()
        end
    end
end

function SimfPhysPersistence:SpawnPumps()
    self:DeletePumps()

    for _, data in pairs( self.pumpData ) do
        local pos = data.pos
        local ang = data.ang
        local class = data.class

        local ent = ents.Create( class )

        ent:SetPos( pos )
        ent:SetAngles( ang )
        ent:Spawn()

        self:log( "Spawned pump(" .. class .. ") at [" .. tostring( pos ) .. "]")
    end
end

hook.Add( "InitPostEntity", "SimfPhysPersistence", function()
    SimfPhysPersistence:LoadPumpData()
    SimfPhysPersistence:SpawnPumps()
end )

hook.Add( "PostCleanupMap", "SimfPhysPersistence", function()
    SimfPhysPersistence:SpawnPumps()
end )

hook.Add( "PlayerSay", "SimfPhysPersistence_ChatCommands", function( ply, text )
    if not ply:IsAdmin() then return end

    if text == "!simfphys save" then
        SimfPhysPersistence:SavePumps()
        ply:ChatPrint( "Saved pumps!" )
    end
end )
