AddCSLuaFile()

FuelPrices = FuelPrices or {}

FuelPrices.Config = {}

-- How many hours until the Fuel prices progress one month in the current cycle?
FuelPrices.Config.hoursPerMonth = 6

-- In dollars per kw/h
FuelPrices.Config.electricityCost = 0.10
