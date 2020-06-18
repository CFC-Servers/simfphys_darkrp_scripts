hook.Add( "OnEntityCreated", "CFC_OnSimfphysCreated", function( ent )
    if not IsValid( ent ) then return end
    if ent:GetClass() ~= "gmod_sent_vehicle_fphysics_base" then return end

    -- One frame timer to prevent editing the variable while it has not itself
    timer.Simple( 0, function()
        if not IsValid( ent ) then return end

        ent.Editable = false
    end )
end )
