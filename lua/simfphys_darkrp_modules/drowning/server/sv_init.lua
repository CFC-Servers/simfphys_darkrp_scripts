local WATER_MAJORITY = 2

local config = SimfphysDarkRPScripts.Config

timer.Create( "CFC_SimfPhys_Drowning", config.DrowningDelay, 0, function()
    for _, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
        if simfphys.IsCar( ent ) then
            if ent:WaterLevel() >= WATER_MAJORITY then
                local tickDamage = ent:GetMaxHealth() * ( config.DrowningDamagePercent / 100 )
                local curHealth = ent:GetCurHealth()
                local owner = ent:CPPIGetOwner()

                ent:ApplyDamage( tickDamage )

                if tickDamage <= curHealth then
                    owner:ChatPrint( config.DrownedVehicleMessage )
                end
            end
        end
    end
end )
