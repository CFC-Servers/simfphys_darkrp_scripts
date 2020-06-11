local drowningCars = {}
local WATER_MAJORITY = 2

local config = SimfphysDarkRPScripts.Config

hook.Add( "Tick", "cfc_simfphys_drowning", function()
    for _, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
        if simfphys.IsCar( ent ) then
            if ent:WaterLevel() >= WATER_MAJORITY then
                if CurTime() >= ( drowningCars[ent] or 0 ) + config.DrowningDelay then
                    local tickDamage = ent:GetMaxHealth() * ( config.DrowningDamagePercent / 100 )
                    local curHealth = ent:GetCurHealth()
                    local owner = ent:CPPIGetOwner()

                    ent:ApplyDamage( tickDamage )

                    if tickDamage <= curHealth then
                        owner:ChatPrint( config.DrownedVehicleMessage )
                    end

                    drowningCars[ent] = CurTime()
                end
            else
                drowningCars[ent] = nil
            end
        end
    end
end )
