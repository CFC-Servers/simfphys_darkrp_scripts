FuelPrices = FuelPrices or {}

hook.Add( "SimfPhysFuelPriceSetDefaults", "SimfPhysSetDefaultTaxes", function( defaultSaveData )
    defaultSaveData:Set( "taxRates", { gas = 0, diesel = 0, electric = 0 } )
end )

hook.Add( "OnSaveSimfPhysFuelPrice", "SimfPhysSaveTaxRates", function( saveData )
    saveData:Set( "taxRates", FuelPrices.taxRates )
end )


hook.Add( "OnLoadSimfPhysFuelPrice", "SimfPhysLoadTaxRates", function( data )
    FuelPrices.taxRates = data.taxRates
end )


hook.Run( "OnUpdateFuelPumpPrices", "SetTaxRatesOnPump", function( pump )
    local taxRates = FuelPrices.taxRates
    local fuelType = pump:GetFuelType()

    pump:SetNWFloat( "FuelTax", taxRates[fuelType] )
end )
