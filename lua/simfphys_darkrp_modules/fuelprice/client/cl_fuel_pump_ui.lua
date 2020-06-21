FuelPrices = FuelPrices or {}

function FuelPrices:GetDigits( value )
    local fvalue = math.floor(value,0)

    local decimal = 1000 + (value - fvalue) * 1000

    local digit1 =  fvalue % 10
    local digit2 =  (fvalue - digit1) % 100
    local digit3 = (fvalue - digit1 - digit2) % 1000

    local digit4 =  decimal % 10
    local digit5 =  (decimal - digit4) % 100
    local digit6 = (decimal - digit4 - digit5) % 1000

    local digits = {
        [1] = math.Round(digit1,0),
        [2] = math.Round(digit2 / 10,0),
        [3] = math.Round(digit3 / 100,0),
        [4] = math.Round(digit5 / 10,0),
        [5] = math.Round(digit6 / 100,0),
    }
    return digits
end

function FuelPrices:InitPumpUI( pump )
    -- Modifies the text on the screen of the fuel pump

    if not pump.fuelCostInitialized then

        local oldDraw = pump.Draw

        -- How the total price is calculated

        pump.Draw = function( ... )
            local oldSimpleText = draw.SimpleText
            draw.SimpleText = function( text, ... )
                -- Removing some disclaimer at the bottom of each screen
                if text == "Tropfmengen sind sofort aufzunehmen" then return end

                -- Inject some freedom
                local newText = text
                if text == "," then
                    newText = "."
                end

                if text == "LITER" then
                    newText = "LITERS"
                end

                oldSimpleText( newText, ... )
            end

            local old3D2D = cam.End3D2D
            cam.End3D2D = function( ... )
                -- This is a very gross implementation of a very gross hack

                local boxY = 30

                -- Electric pumps only have one box, so we move ours up a bit
                if pump:GetFuelType() == "electric" then
                    boxY = -25
                end

                draw.RoundedBox( 5, -91, boxY - 2, 182, 30, Color( 100,255,100,150 ) )
                draw.RoundedBox( 5, -90, boxY - 1, 180, 28, Color( 50, 50, 50, 255 ) )

                local startingX = -88
                local boxSpacing = 20
                for i=1, 5 do
                    local boxX = startingX + ( boxSpacing * ( i - 1 ) )
                    draw.RoundedBox( 5, boxX, boxY, 19, 24, Color( 0, 0, 0, 255 ) )
                end

                draw.RoundedBox( 5, 12, boxY, 76, 24, Color( 0, 0, 0, 255 ) )
                draw.SimpleText( "DOLLARS", "simfphys_gaspump", 50, boxY + 2, Color( 200, 200, 200, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

                local fuelPrice = pump:CalculateFuelPrice()
                local d_digits = FuelPrices:GetDigits( fuelPrice )

                -- Text is a little offset from the boxes
                local textY = boxY + 2

                -- Placing digits from right to left
                local digitOrder = {
                    d_digits[4],
                    d_digits[5],
                    d_digits[1],
                    d_digits[2],
                    d_digits[3],
                }

                local digitStartingX = 6
                for i=1, 5 do
                    local digit = digitOrder[i]
                    local digitX = digitStartingX - ( boxSpacing * ( i - 1 ) )

                    draw.SimpleText( digit, "simfphys_gaspump", digitX, textY, Color( 200, 200, 200, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
                end

                -- The dot has to be even more offset
                local dotY = textY + 5
                draw.SimpleText( ".", "simfphys_gaspump", -26, dotY, Color( 200, 200, 200, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )

                old3D2D( ... )
            end

            oldDraw( ... )

            draw.SimpleText = oldSimpleText
            cam.End3D2D = old3D2D
        end

        pump.fuelCostInitialized = true
    end

    if not pump.wrappedDrawTranslucent then
        local oldDrawTranslucent = pump.DrawTranslucent
        pump.RenderGroup = RENDERGROUP_TRANSLUCENT

        surface.CreateFont("AIRBOAT_VENDOR_FONT", {font = "Circular Std Bold", size = 200})
        local offset = Vector( 0, 0, 80 )

        local breensFace = Material( "models/debug/debugwhite" )

        function pump:DrawTranslucent()
            local origin = pump:GetPos()
            if (LocalPlayer():GetPos():Distance(origin) >= 768) then return end

            local pos = origin + offset
            local ang = (LocalPlayer():EyePos() - pos):Angle()
            ang.p = 0
            ang:RotateAroundAxis(ang:Right(), 90)
            ang:RotateAroundAxis(ang:Up(), 90)
            ang:RotateAroundAxis(ang:Forward(), 180)

            local pricePerUnit = pump:GetFuelPricePerUnit()
            pricePerUnit = DarkRP.formatMoney( math.Round( pricePerUnit, 2 ) )

            local taxPercent = pump:GetNWFloat( "FuelTax" )
            local taxText = math.Round( taxPercent, 2 ) .. "%"

            local text = pricePerUnit .. " / " .. pump:GetFuelUnits()
            local size = 60

            cam.Start3D2D(pos, ang, 0.7)

                draw.RoundedBox( 5, -size / 2, -size / 2, size, size, Color( 52, 152, 219 ) )

                surface.SetFont( "AIRBOAT_VENDOR_FONT" )
                draw.SimpleText( text, "AIRBOAT_VENDOR_FONT", 0, -size * 0.1, Color( 24, 126, 55 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                local faceSize = size * 0.2
                surface.SetDrawColor( Color( 255, 255, 255 ) )
                surface.SetMaterial( breensFace )
                surface.DrawTexturedRect( -size * 0.25, size * 0.1 - faceSize / 2, faceSize, faceSize )

                draw.SimpleText( taxText, "AIRBOAT_VENDOR_FONT", 0, size * 0.1, Color( 255, 127, 39 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            -- surface.SetFont("AIRBOAT_VENDOR_FONT")
            -- local wi, he = surface.GetTextSize(text)
            -- local pad = 16
            -- wi = wi + pad * 2
            -- he = he + pad * 2

            -- draw.RoundedBox(8, -wi * 0.5, -pad, wi, he, Color( 52, 152, 219, 255) )

            -- draw.SimpleText(text, "AIRBOAT_VENDOR_FONT", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            cam.End3D2D()

            oldDrawTranslucent( pump )
        end

        pump.wrappedDrawTranslucent = true
    end


end

function FuelPrices:InitPumpUIs()
    for _, thing in pairs( ents.GetAll() ) do
        if self:IsPump( thing ) then
            self:InitPumpUI( thing )
        end
    end
end
