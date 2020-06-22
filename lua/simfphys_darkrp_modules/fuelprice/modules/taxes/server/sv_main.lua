FuelPrices = FuelPrices or {}
FuelPrices.taxRates = FuelPrices.taxRates or {}

hook.Add( "SimfPhysFuelPriceSetDefaults", "SimfPhysSetDefaultTaxes", function( defaultSaveData )
    defaultSaveData:Set( "taxRates", { gas = 0, diesel = 0, electric = 0 } )
end )

hook.Add( "OnSaveSimfPhysFuelPrice", "SimfPhysSaveTaxRates", function( saveData )
    saveData:Set( "taxRates", FuelPrices.taxRates )
end )

hook.Add( "OnLoadSimfPhysFuelPrice", "SimfPhysLoadTaxRates", function( data )
    FuelPrices.taxRates = data.taxRates or {}
end )

hook.Add( "OnUpdateFuelPumpPrices", "SetTaxRatesOnPump", function( pump )
    local taxRates = FuelPrices.taxRates
    local fuelType = pump:GetFuelType()

    pump:SetNWFloat( "FuelTax", taxRates[fuelType] )
end )

function FuelPrices:UpdateTaxRates( newRates )
    FuelPrices.taxRates.gas = newRates.gas or FuelPrices.taxRates.gas
    FuelPrices.taxRates.diesel = newRates.diesel or FuelPrices.taxRates.diesel
    FuelPrices.taxRates.electric = newRates.electric or FuelPrices.taxRates.electric

    self:UpdatePumps()

    self:Log( "Updated Tax Rates as follows: ", "Gas: " .. newRates.gas or "<Not provided>", "Diesel: " .. newRates.diesel or "<Not provided>", "Electric: " .. newRates.electric or "<Not provided>" )
end

hook.Add( "Slawer.UpdateTaxes", "CheckForUpdatedFuelTaxes", function( ply, taxData )
    if not taxData.fuelTaxes then return end

    FuelPrices:Log( "Received Slawer.UpdateTaxes hook, forwarding taxData.fuelTaxes to UpdateTaxRates" )
    FuelPrices:UpdateTaxRates( taxData.fuelTaxes )
end )

util.AddNetworkString( "Slawer.SyncFuelTaxes" )
hook.Add( "Slawer.WillSyncTaxes", "SyncFuelTaxes", function( ply, taxData )
    FuelPrices:Log( "Received Slawer.WillSyncTaxes, preparing to sync fuel taxes" )
    local taxRates = FuelPrices.taxRates
    PrintTable( taxRates )

    net.Start( "Slawer.SyncFuelTaxes" )

    net.WriteTable( taxRates )

    if ply and IsValid( ply ) then
        net.Send( ply )
    else
        net.Broadcast()
    end
end )
