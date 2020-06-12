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

        local fuelPrice = units * self:GetFuelPricePerUnit()
        priceStruct:SetPrice( fuelPrice )

        hook.Run( "SimfPhysCalculateFuelPrice", pump, priceStruct )

        return priceStruct.price
    end

    if SERVER then
        function pump:ChargeCustomer()
            local finalPrice = pump:CalculateFuelPrice()
            local formattedPrice = DarkRP.formatMoney( finalPrice )

            local customer = pump:GetUser()

            local message = "You've been charged " .. formattedPrice .. " for fuel"
            DarkRP.notify( customer, 1, 5, message)

            customer:addMoney( -finalPrice )
        end

        if not pump.wrappedDisableFunction then
            local oldDisable = pump.Disable
            function pump:Disable()
                pump:ChargeCustomer()
                oldDisable( pump )
            end

            pump.wrappedDisableFunction = true
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

        FuelPrices:AddPumpExtensions( ent )

        if SERVER then
            FuelPrices:UpdatePump( ent )
        else
            FuelPrices:InitPumpUI( ent )
        end
    end )
end
