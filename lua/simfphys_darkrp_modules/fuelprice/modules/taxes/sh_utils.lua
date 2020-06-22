AddCSLuaFile()

hook.Add( "SimfPhysCalculateFuelPrice", "ModifyPriceWithTaxes", function( pump, priceStruct )
    local tax = pump:GetNWFloat( "FuelTax", 0 )
    local newPrice = priceStruct.price + ( priceStruct.price * tax )

    --FuelPrices:Log( "Modified price: [" .. priceStruct.price .. "] with tax rate [" .. tax * 100 .. "%], resulted in [" .. newPrice .. "]" )
    priceStruct:SetPrice( newPrice )
end )
