AddCSLuaFile()

FuelPrices = FuelPrices or {}

FuelPrices.Config = {}

-- How many hours until the Fuel prices progress one month in the current cycle?
FuelPrices.Config.hoursPerMonth = 6

-- In dollars per kw/h
FuelPrices.Config.electricityCost = 0.10

-- What value to add to the Fuel Pump's default NextThink function?
-- Lower values cause it to update faster. Default is (CurTime() + 0.5)
FuelPrices.Config.fuelPumpNextThinkModifier = -0.25
