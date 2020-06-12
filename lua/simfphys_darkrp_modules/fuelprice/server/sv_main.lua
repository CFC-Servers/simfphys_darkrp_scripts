FuelPrices = FuelPrices or {}

FuelPrices.SaveDir = "fuel_prices"
FuelPrices.SaveFileName = "progress_data.json"
FuelPrices.SaveFile = FuelPrices.SaveDir .. "/" .. FuelPrices.SaveFileName

function FuelPrices:FileInit()
    -- Initializes the file structure (if needed)

    local exists = file.Exists( self.SaveFile, "DATA" )

    if exists then self:Log( "Save file already exists!" ) end

    if exists then return end

    self:Log( "Save file does not exist, creating file structure..." )

    local defaultSaveData = {
        data = {
            dayIndex = 1,
            progressDirection = "forward",
            lastProgressed = os.time()
        }
    }

    function defaultSaveData:Set( key, value )
        self.data[key] = value
    end

    hook.Run( "SimfPhysFuelPriceSetDefaults", defaultSaveData )

    file.CreateDir( self.SaveDir )
    file.Write( self.SaveFile, util.TableToJSON( defaultSaveData.data ) )

    self:Log( "Save file initialized with default data!" )
end

function FuelPrices:SaveData()
    -- Save data to save file

    self:Log( "Saving all data!" )

    local saveData = {
        data = {
            lastProgressed = self.lastProgressed,
            progressDirection = self.progressDirection,
            dayIndex = self.dayIndex
        }
    }

    function saveData:Set( key, value )
        self.data[key] = value
    end

    hook.Run( "OnSaveSimfPhysFuelPrice", saveData )

    local data = util.TableToJSON( saveData.data )

    file.Write( self.SaveFile, data )
end

function FuelPrices:ProgressDayIndex()
    -- Progresses the current FuelDay based on the current progress direction
    -- Writes to save file

    local delta = self.progressDirection == "forward" and 1 or -1
    self.dayIndex = self.dayIndex + delta
    self.lastProgressed = os.time()

    if self.dayIndex == #self.historicData and self.progressDirection == "forward" then
        self.progressDirection = "backward"
    elseif self.dayIndex == 1 and self.progressDirection == "backward" then
        self.progressDirection = "forward"
    end

    self:SaveData()
end

function FuelPrices:LoadHistoricData()
    self.historicData = include( "simfphys_darkrp_modules/fuelprice/data/fuel_prices.lua" )
end

function FuelPrices:ProgressDay()
    self:ProgressDayIndex()
    self:UpdatePumps()
    self:AlertPrices()
end

function FuelPrices:LoadSaveData()
    -- Loads all fuel data from save file

    local data = file.Read( self.SaveFile, "DATA" )
    data = util.JSONToTable( data )

    self.lastProgressed = data.lastProgressed
    self.progressDirection = data.progressDirection
    self.dayIndex = data.dayIndex

    hook.Run( "OnLoadSimfPhysFuelPrice", data )

    local updateThreshold = os.time() - ( self.Config.hoursPerMonth * 60 )
    if self.lastProgressed <= updateThreshold then
        self:ProgressDayIndex()
    end
end

function FuelPrices:GetFuelDate()
    local historicData = self.historicData[self.dayIndex]

    return historicData[self.dayIndex].day
end

function FuelPrices:GetFuelPrices()
    -- Returns price for gas, diesel, and electricity

    local historicData = self.historicData[self.dayIndex]

    return {
        gas = historicData.gas,
        diesel = historicData.diesel,
        electric = self.Config.electricityPrice
    }
end

function FuelPrices:UpdatePump( pump )
    local prices = self:GetFuelPrices()
    local fuelType = pump:GetFuelType()

    pump:SetNWFloat( "FuelPricePerUnit", prices[fuelType] )

    hook.Run( "OnUpdateFuelPumpPrices", pump )
end

function FuelPrices:UpdatePumps()
    for _, thing in pairs( ents.GetAll() ) do
        if self:IsPump( thing ) then
            self:UpdatePump( thing )
        end
    end
end

function FuelPrices:AlertPrices()
    -- Writes a message to every player's console informing them of the current fuel prices

    local prices = self:GetFuelPrices()
    local date = self:GetFuelDate()

    for _, ply in pairs( player.GetAll() ) do
        ply:ChatPrint( "Fuel prices are now equivalent to fuel prices on " .. date )
        ply:ChatPrint( "Gasoline: $" .. math.Round( prices.gas, 2 ) .. "/g")
        ply:ChatPrint( "Diesel: $" .. math.Round( prices.diesel, 2 ) .. "/g")
    end
end

function FuelPrices:InitTimer( restart )
    -- Initializes the cost update timer
    -- restart parameter will force the timer to restart

    local this = self
    local delay = self.Config.hoursPerMonth * 60

    local timerName = "SimfPhysFuelPriceUpdater"

    if timer.Exists( timerName ) and restart ~= true then return end

    timer.Create( timerName, delay, 0, function()
        this:ProgressDay()
    end )
end

function FuelPrices:Init()
    self:FileInit()
    self:LoadHistoricData()
    self:LoadSaveData()
    self:InitTimer()
    self:UpdatePumps()
end

hook.Add( "InitPostEntity", "LoadSimfPhysFuelPrices", function()
    FuelPrices:Init()
end )
