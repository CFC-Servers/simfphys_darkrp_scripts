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

    function pump:CalculateFuelPrice()
        -- Calculates the total price of the used fuel
        -- Ends up getting called on Draw

        -- Fuel Used is in liters by default
        local usedFuel = pump:GetFuelUsed()

        local priceStruct = {
            price = 0
        }

        function priceStruct:SetPrice( price )
            self.price = price
        end

        function priceStruct:ModifyPrice( mult )
            self.price = self.price * mult
        end

        local units = 0
        if pump:GetFuelType() == "electric" then
            -- Idk, this is how SimfPhys calculates kW/h
            units = usedFuel / 2
        else
            -- To gallons
            units = usedFuel * 0.264172
        end

        local fuelPrice = units * self:GetFuelPricePerUnit()
        priceStruct:SetPrice( fuelPrice )

        hook.Run( "SimfPhysCalculateFuelPrice", pump, priceStruct )

        return priceStruct.price
    end
end

function FuelPrices:InitPumps()
    for _, thing in pairs( ents.GetAll() ) do
        if self:IsPump( thing ) then
            self:AddPumpExtensions( thing )
        end
    end
end
