hook.Add( "OnEntityCreated", "SimfPhysAlertExplode", function( ent )
    -- Delay because SimfPhys appears to take forever to actually exist
    timer.Simple( 2, function()
        if not simfphys.IsCar( ent ) then return end

        local oldOnDestroyed = ent.OnDestroyed()

        function ent:OnDestroyed()
            oldOnDestroyed( self )

            local owner = self.tcbOwner or self:GetOwner() or self:CPPIGetOwner()
            if not IsValid( owner ) then return end

            local message = "Your SimfPhys vehicle was destroyed!"

            DarkRP.notify( owner, 1, 8, message )
        end
    end )
end )
