local drowningCars = {}
local drowningDelay = 1
local drowningDamagePercent = 5
local WATER_MAJORITY = 2

hook.Add( "Tick", "cfc_simfphys_drowning", function()
    for _, ent in pairs( ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) ) do
        if simfphys.IsCar( ent ) then
            if ent:WaterLevel() >= WATER_MAJORITY then
                if CurTime() >= ( drowningCars[ent] or 0 ) + drowningDelay then
                    drowningCars[ent] = CurTime()
                    ent:ApplyDamage( ent:GetMaxHealth() * ( drowningDamagePercent / 100 ) )
                end
            else
                drowningCars[ent] = nil
            end
        end
    end
end )
