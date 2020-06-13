AddCSLuaFile()

FuelPrices = FuelPrices or {}

FuelPrices.pumpTypes = {
    gmod_sent_vehicle_fphysics_gaspump_diesel = true,
    gmod_sent_vehicle_fphysics_gaspump_electric = true,
    gmod_sent_vehicle_fphysics_gaspump = true
}

FuelPrices.pumpFuelTypes = {
    gmod_sent_vehicle_fphysics_gaspump_diesel = "diesel",
    gmod_sent_vehicle_fphysics_gaspump_electric = "electric",
    gmod_sent_vehicle_fphysics_gaspump = "gas"
}

function FuelPrices:Log( ... )
    local prefix = "[FuelPrice] "

    print( prefix, ... )
end

function FuelPrices:IsPump( ent )
    return IsValid( ent ) and self.pumpTypes[ent:GetClass()]
end

function FuelPrices:AddPumpExtensions( pump )
    function pump:GetFuelType()
        return FuelPrices.pumpFuelTypes[pump:GetClass()]
    end

    function pump:GetFuelPricePerUnit()
        return pump:GetNWFloat( "FuelPricePerUnit", 0 )
    end

    function pump:GetUnitsUsed()
        -- Gets the units of fuel used
        -- Gallons for liquids, kw/h for electricity

        -- Fuel Used is in liters by default
        local usedFuel = pump:GetFuelUsed()

        local units = 0
        if pump:GetFuelType() == "electric" then
            -- Idk, this is how SimfPhys calculates kW/h
            units = usedFuel / 2
        else
            -- To gallons
            units = usedFuel * 0.264172
        end

        return units
    end

    function pump:CalculateFuelPrice()
        -- Calculates the total price of the used fuel
        -- Ends up getting called on Draw

        local priceStruct = {
            price = 0
        }

        function priceStruct:SetPrice( price )
            self.price = price
        end

        function priceStruct:ModifyPrice( mult )
            self.price = self.price * mult
        end

        local unitsUsed = pump:GetUnitsUsed()

        local fuelPrice = unitsUsed * self:GetFuelPricePerUnit()
        priceStruct:SetPrice( fuelPrice )

        hook.Run( "SimfPhysCalculateFuelPrice", pump, priceStruct )

        return priceStruct.price
    end

    if SERVER then
        function pump:ChargeCustomer()
            local finalPrice = pump:CalculateFuelPrice()

            if finalPrice == 0 then return end

            local formattedPrice = DarkRP.formatMoney( math.Round( finalPrice, 2 ) )
            local customer = pump:GetUser()

            local message = "You've been charged " .. formattedPrice .. " for fuel"
            DarkRP.notify( customer, 0, 5, message)

            customer:addMoney( -finalPrice )
        end

        -- Use Function was the only one I could use that would detect when the player actually put the nozzle away
        if not pump.wrappedUseFunction then
            local oldUse = pump.Use

            function pump:Use( ply )
                if not pump:GetActive() then return end
                if ply ~= pump:GetUser() then return end
                -- After the conditions above, we can be sure that the user has just put away the nozzle

                pump:ChargeCustomer()
                oldUse( pump, ply )
            end

            pump.wrappedUseFunction = true
        end

        -- Wrap the Disable function in case players don't put the nozzle down normally
        if not pump.wrappedDisableFunction then
            local oldDisable = pump.Disable

            function pump:Disable()
                pump:ChargeCustomer()
                oldDisable( pump )
            end

            pump.wrappedDisableFunction = true
        end

        -- Wrap the Think function so we can kill the Pump if the cost has exceeded their money
        if not pump.wrappedThinkFunction then
            local oldThink = pump.Think

            function pump:Think()
                local user = pump:GetUser()

                if  IsValid( user ) then
                    local userMoney = user:getDarkRPVar( "money" )
                    local currentCost = pump:CalculateFuelPrice()

                    if currentCost >= userMoney then
                        local message = "You can't afford any more fuel!"
                        DarkRP.notify( ply, 1, 8, message )

                        ply.gas_InUse = false
                        pump:Disable()
                    end
                end

                return oldThink( pump )
            end

            pump.wrappedThinkFunction = true
        end

        -- Pretty unrelated, but this allows us to modify how quickly the pump thinks
        if not pump.wrappedNextThinkFunction then
            local oldNextThink = pump.NextThink

            function pump:NextThink( value )
                oldNextThink( pump, value + FuelPrices.Config.fuelPumpNextThinkModifier )
            end

            pump.wrappedNextThinkFunction = true
        end
    end
end

function FuelPrices:InitPumps()
    for _, thing in pairs( ents.GetAll() ) do
        if self:IsPump( thing ) then
            self:AddPumpExtensions( thing )
        end
    end
end

function FuelPrices:InitWatcher()
    hook.Add( "OnEntityCreated", "InitSimfPhysFuelPrices", function( ent )
        if not FuelPrices:IsPump( ent ) then return end
        FuelPrices:Log( "Found new pump! Configuring...")

        FuelPrices:AddPumpExtensions( ent )

        if SERVER then
            FuelPrices:UpdatePump( ent )
        else
            -- Give the server a tick to initialize everything
            timer.Simple( 0, function()
                FuelPrices:InitPumpUI( ent )
            end )
        end
    end )
end
