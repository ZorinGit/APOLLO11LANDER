function love.load()


    -- set resolution
    SCREEN_X = 1280
    SCREEN_Y = 800
    love.window.setMode(SCREEN_X, SCREEN_Y)


    -- set lunar properties
    LUNAR = {}
    LUNAR.gravity_force_N_per_kg = 1.6


    -- set lander properties 
    LANDER = {}
    LANDER.mass_kg = 15103
    LANDER.fuel_s = 120

    -- x axis lander variables
    -- LANDER.x = 200
    -- test
    LANDER.x = 1105
    LANDER.x_velocity = 0
    LANDER.x_thruster = 0
    LANDER.x_thruster_force_N = 7200
    LANDER.x_thruster_acceleration = tonumber(string.format("%.2f", (LANDER.x_thruster_force_N / LANDER.mass_kg)))

    -- y axis lander variables 
    -- LANDER.y = 40
    -- test
    LANDER.y = 650
    LANDER.y_velocity = 0
    LANDER.y_only_lunar_force_N = LANDER.mass_kg * LUNAR.gravity_force_N_per_kg
    LANDER.y_only_lunar_force_acceleration = LANDER.y_only_lunar_force_N / LANDER.mass_kg
    LANDER.y_thruster = false
    LANDER.y_only_thruster_force_N = - 45000
    LANDER.y_total_thruster_and_lunar_force_N = LANDER.y_only_lunar_force_N + LANDER.y_only_thruster_force_N
    LANDER.y_total_thruster_and_lunar_acceleration = tonumber(string.format("%.2f", (LANDER.y_total_thruster_and_lunar_force_N / LANDER.mass_kg)))

    -- lander collision pixels
    LANDER_COLLISION_PIXELS = {
        {x = LANDER.x , y = LANDER.y}, -- upper left
        {x = LANDER.x + 24 , y = LANDER.y}, -- upper right
        {x = LANDER.x, y = LANDER.y + 24}, -- lower left
        {x = LANDER.x + 24, y = LANDER.y + 24} -- lover right
    }


    -- define the surface line points
    SURFACE_LINE_POINTS = {0, 750, 500, 750, 550, 780, 920, 780, 970, 750, 1280, 750}

    -- populate table for all collision pixels in the surface line based on the SURFACE_LINE_POINTS
    -- NOTE WILL NOT HANDLE VERTICAL LINES - divide by 0
    LINE_COLLISION_PIXELS = {}

    for i = 1, #SURFACE_LINE_POINTS - 2 , 2 do
        -- declare x and y values for point1 and point2
        local x1 = SURFACE_LINE_POINTS[i]
        local y1 = SURFACE_LINE_POINTS[i + 1]
        local x2 = SURFACE_LINE_POINTS[i + 2]
        local y2 = SURFACE_LINE_POINTS[i + 3]
        -- using y = mx + b line formula
        -- calculate m 
        local m = (y2 - y1) / (x2 - x1)
        -- calculate b
        local b = y1 - (m * x1)
        -- filling in the table using the line formula
        for j = x1, x2 do
            table.insert(LINE_COLLISION_PIXELS, {x = j, y = math.floor((m * j) + b)})
        end
    end


    -- define landing zone surface line points
    LANDING_SURFACE_LINE_POINTS = {1100, 748, 1135, 748}


    -- counter to reduce the frequency of collision checks
    COLLISION_FREQUENCY_COUNTER = 0


    -- for timer
    START_TIME = love.timer.getTime()


    -- game manager setting up game states
    GAME_MANAGER = {"1-tutorial", "2-game_play", "3-paused", "4-landed", "5-crashed", "6-out_of_bounds", "7-score_screen"}
    CURRENT_GAME_STATE = GAME_MANAGER[1]


    -- drawings
    TUTORIAL_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("        A    S    D \n\nthruster commands", LANDER.x - 48, LANDER.y + 30)
            love.graphics.print("PRESS SPACE TO START", SCREEN_X / 2, SCREEN_Y / 2)
        end
    }

    HUD_TEXT = {
        draw = function ()
            -- displayed variables on the right corner
            local X_location = SCREEN_X - 75
            local Y_location = SCREEN_Y - 790
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Ypos: " .. math.floor(LANDER.y), X_location, Y_location)
            love.graphics.print("Xpos: " .. math.floor(LANDER.x), X_location, Y_location + 15)
            love.graphics.print("Yvel: " .. math.floor(LANDER.y_velocity), X_location, Y_location + 30)
            love.graphics.print("Xvel: " .. math.floor(LANDER.x_velocity), X_location, Y_location + 45)
            love.graphics.print("Time: " .. math.floor(ELAPSED_TIME), X_location, Y_location + 60)
            love.graphics.print("Fuel: " .. math.floor(LANDER.fuel_s), X_location, Y_location + 75)
        end
    }

    LANDER_GRAPHIC = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", LANDER.x, LANDER.y, 25, 25)
        end
    }

    LUNAR_SURFACE_GRAPHIC = {
        draw = function ()
            love.graphics.setColor(0.25, 0.25, 0.25)
            love.graphics.setLineWidth(3)
            love.graphics.line(SURFACE_LINE_POINTS)
        end
    }

    LANDING_ZONE_GRAPHIC = {
        draw = function ()
            love.graphics.setColor(0.90, 0.90, 0.90)
            love.graphics.setLineWidth(2)
            love.graphics.line(LANDING_SURFACE_LINE_POINTS)
        end
    }

    LANDED_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("THE EAGLE HAS LANDED!", SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PRESS r TO RESTART THIS LEVEL", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
            love.graphics.print("PRESS c CONTINUE TO NEXT LEVEL", SCREEN_X / 2, (SCREEN_Y / 2) + 40)
        end
    }

    CRASHED_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("LANDER HAS CRASHED!", SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PRESS r TO RESTART THIS LEVEL", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
        end
    }

    OUT_OF_BOUNDS_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("OUT OF BOUNDS! LANDER IS LOST FOREVER IN SPACE!", SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PRESS r TO RESTART THIS LEVEL", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
        end
    }

end


function love.update(dt)


    if CURRENT_GAME_STATE == "1-tutorial" then

        -- exit 1-tutorial into 2-game_play by pressing "space"
        function love.keypressed(key)
               if key == 'space' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
        end

    end


    if CURRENT_GAME_STATE == "2-game_play" then


        -- x axis trusters and acceleration, thruster 0 = off, thruster 1 = to the right, thruster 2 = to the left
        if love.keyboard.isDown("a") and LANDER.fuel_s > 0 then
            LANDER.x_thruster = 1
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt * (LANDER.x_thruster_force_N/math.abs(LANDER.y_only_thruster_force_N))
        elseif love.keyboard.isDown("d") and LANDER.fuel_s > 0 then
            LANDER.x_thruster = 2
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt * (LANDER.x_thruster_force_N/math.abs(LANDER.y_only_thruster_force_N))
        else
            LANDER.x_thruster = 0
        end

        if LANDER.x_thruster == 1 and LANDER.fuel_s > 1 then
            LANDER.x_velocity = LANDER.x_velocity + LANDER.x_thruster_acceleration * dt
        elseif LANDER.x_thruster == 2 and LANDER.fuel_s > 1 then
            LANDER.x_velocity = LANDER.x_velocity - LANDER.x_thruster_acceleration * dt
        end

        -- x axis lander movement
        LANDER.x = LANDER.x + LANDER.x_velocity * dt


        -- y axis trusters and acceleration
        LANDER.y_thruster = false
        if love.keyboard.isDown("s") and LANDER.fuel_s > 1 then
            LANDER.y_thruster = true
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt
        end

        if LANDER.y_thruster == false then
            LANDER.y_velocity = LANDER.y_velocity + LANDER.y_only_lunar_force_acceleration * dt
        elseif LANDER.y_thruster == true and LANDER.fuel_s > 0 then
            LANDER.y_velocity = LANDER.y_velocity + LANDER.y_total_thruster_and_lunar_acceleration * dt
        end

        -- y axis lander movement
        LANDER.y = LANDER.y + LANDER.y_velocity * dt


        -- update lander collision pixels as the lander moves
        LANDER_COLLISION_PIXELS = {
            {x = math.floor(LANDER.x + 1) , y = math.floor(LANDER.y + 1)}, -- upper left
            {x = math.floor(LANDER.x + 25) , y = math.floor(LANDER.y + 1)}, -- upper right
            {x = math.floor(LANDER.x + 1), y = math.floor(LANDER.y + 25)}, -- lower left
            {x = math.floor(LANDER.x + 25), y = math.floor(LANDER.y + 25)} -- lover right
        }


        -- landing zone check
        -- check lower left lander collision pixel against the y landing level
        if LANDER_COLLISION_PIXELS[3]["y"] == LANDING_SURFACE_LINE_POINTS[2] and
            -- check left and right lander collision pixels against landing pad
            LANDER_COLLISION_PIXELS[3]["x"] >= LANDING_SURFACE_LINE_POINTS[1] and
            LANDER_COLLISION_PIXELS[4]["x"] <= LANDING_SURFACE_LINE_POINTS[3] and
            -- check x and y velocity as absolute values for acceptable landing levels 
            math.abs(LANDER.y_velocity) < 4 and math.abs(LANDER.x_velocity) < 1.5 then
            -- change landing flag to true
            print("***LANDED***")
            -- exit 2-game_play into 4-landed by proper landing
            CURRENT_GAME_STATE = GAME_MANAGER[4]
        end


        -- crash check
        -- collision with surface check and counter used to reduce the check frequency to 50 times a second for a smoother game
        COLLISION_FREQUENCY_COUNTER = COLLISION_FREQUENCY_COUNTER + dt
        if COLLISION_FREQUENCY_COUNTER > 0.02 then
            for i = 3, #LANDER_COLLISION_PIXELS do
                for j = 1, #LINE_COLLISION_PIXELS do
                    if LANDER_COLLISION_PIXELS[i]["x"] == LINE_COLLISION_PIXELS[j]["x"] and LANDER_COLLISION_PIXELS[i]["y"] == LINE_COLLISION_PIXELS[j]["y"] then
                        print("***COLLISION***")
                        -- exit 2-game_play into 5-crashed by collision with surface
                        CURRENT_GAME_STATE = GAME_MANAGER[5]
                    end
                end
            end
            COLLISION_FREQUENCY_COUNTER = 0
        end


        -- out of bounds check 
        -- check lower left lander collision pixel against  top bounds of map using Y
        if LANDER_COLLISION_PIXELS[3]["y"] < 0 or
            -- check lower right lander collision against left bounds of map using X
            LANDER_COLLISION_PIXELS[4]["x"] < 0 or
            -- check lower left lander collision against right bounds of the map using X
            LANDER_COLLISION_PIXELS[3]["x"] > 1280 then
            print("***OUT OF BOUNDS***")
            -- exit 2-game_play into 6-out_of_bounds by exiting the screen
            CURRENT_GAME_STATE = GAME_MANAGER[6]
        end


        -- pause game
        -- exit 2_game_play into 3_paused by pressing "p"
        function love.keypressed(key)
            if key == 'p' then
                CURRENT_GAME_STATE = GAME_MANAGER[3]
            end
        end

    end


    if CURRENT_GAME_STATE == "3-paused" then
        -- exit 3_paused into 2-game_play by pressing "p"
        function love.keypressed(key)
            if key == 'p' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
        end
    end


    if CURRENT_GAME_STATE == "4-landed" then

        function love.keypressed(key)
            -- exit 4_landed into 2-game_play by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]

                -- resetting level, this should be done properly when levels are implemented

                LANDER.fuel_s = 120
                LANDER.y = 40
                LANDER.y_velocity = 0
                LANDER.x = 200
                LANDER.x_velocity = 0

            end

            -- -- exit 4_paused into 2-game_play by pressing "c" continue to next level
            -- -- TO DO change level
            -- if key == 'c' then
            --     CURRENT_GAME_STATE = GAME_MANAGER[2]
            -- end
        end
    end


    if CURRENT_GAME_STATE == "5-crashed" then
        function love.keypressed(key)
            -- exit 5_crashed into 2-game_play by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]

                -- resetting level, this should be done properly when levels are implemented

                LANDER.fuel_s = 120
                LANDER.y = 40
                LANDER.y_velocity = 0
                LANDER.x = 200
                LANDER.x_velocity = 0

            end
        end
    end


    if CURRENT_GAME_STATE == "6-out_of_bounds" then
        function love.keypressed(key)
            -- exit 6-out_of_bounds into 2-game_play by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]

                -- resetting level, this should be done properly when levels are implemented

                LANDER.fuel_s = 120
                LANDER.y = 40
                LANDER.y_velocity = 0
                LANDER.x = 200
                LANDER.x_velocity = 0
            end
        end
    end


    if CURRENT_GAME_STATE == "7-score_screen" then
        -- TO DO implement after levels
    end


    -- for timer
    ELAPSED_TIME = love.timer.getTime() - START_TIME

end


function love.draw()

    if CURRENT_GAME_STATE == "1-tutorial" then
        TUTORIAL_TEXT.draw()
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
    end

    if CURRENT_GAME_STATE == "2-game_play" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
    end

    if CURRENT_GAME_STATE == "3-paused" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
    end

    if CURRENT_GAME_STATE == "4-landed" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        LANDED_TEXT.draw()
    end

    if CURRENT_GAME_STATE == "5-crashed" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        CRASHED_TEXT.draw()
    end

    if CURRENT_GAME_STATE == "6-out_of_bounds" then
        HUD_TEXT.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        OUT_OF_BOUNDS_TEXT.draw()
    end

    if CURRENT_GAME_STATE == "7-score_screen" then
        -- TO DO implement after levels
    end

end