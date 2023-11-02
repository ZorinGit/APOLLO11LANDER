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
    LANDER.fuel_s = 0

    -- set lander sprites different opacities used here for ghost images used for smoother movement
    LANDER.spriteA1 = love.graphics.newImage('sprites/lander_mk2/Lander_A1.png')
    LANDER.spriteA05 = love.graphics.newImage('sprites/lander_mk2/Lander_A05.png')
    LANDER.spriteA025 = love.graphics.newImage('sprites/lander_mk2/Lander_A025.png')

    -- set lander thruster sprites
    LANDER.sprite_y_thruster = love.graphics.newImage('sprites/thrusters_mk2/Y_Thruster.png')
    LANDER.sprite_x_thruster_left = love.graphics.newImage('sprites/thrusters_mk2/X_Thruster_left.png')
    LANDER.sprite_x_thruster_right = love.graphics.newImage('sprites/thrusters_mk2/X_Thruster_right.png')

    -- x axis lander variables
    LANDER.x = 0
    LANDER.x_old1 = 0
    LANDER.x_old2 = 0
    LANDER.x_velocity = 0
    LANDER.x_thruster_left = false
    LANDER.x_thruster_right = false
    LANDER.x_thruster_force_N = 7200
    LANDER.x_thruster_acceleration = tonumber(string.format("%.2f", (LANDER.x_thruster_force_N / LANDER.mass_kg)))

    -- y axis lander variables 
    LANDER.y = 0
    LANDER.y_old1 = 0
    LANDER.y_old2 = 0
    LANDER.y_velocity = 0
    LANDER.y_only_lunar_force_N = LANDER.mass_kg * LUNAR.gravity_force_N_per_kg
    LANDER.y_only_lunar_force_acceleration = LANDER.y_only_lunar_force_N / LANDER.mass_kg
    LANDER.y_thruster = false
    LANDER.y_only_thruster_force_N = - 45000
    LANDER.y_total_thruster_and_lunar_force_N = LANDER.y_only_lunar_force_N + LANDER.y_only_thruster_force_N
    LANDER.y_total_thruster_and_lunar_acceleration = tonumber(string.format("%.2f", (LANDER.y_total_thruster_and_lunar_force_N / LANDER.mass_kg)))


    -- initialize lander collision pixels surface line points and line collision pixels and landing zone surface and score
    LANDER_COLLISION_PIXELS = {}
    SURFACE_LINE_POINTS = {}
    LINE_COLLISION_PIXELS = {}
    LANDING_SURFACE_LINE_POINTS = {}
    SCORE = 0


    -- counter to reduce the frequency of collision checks
    -- COLLISION_FREQUENCY_COUNTER = 0

    -- counter to reduce the frequency for updating ghost images and magnitude of velocity to change the update rate
    GHOST_IMAGE_UPDATE_COUNTERx1 = 0
    GHOST_IMAGE_UPDATE_COUNTERx2 = 0
    GHOST_IMAGE_UPDATE_COUNTERy1 = 0
    GHOST_IMAGE_UPDATE_COUNTERy2 = 0
    GHOST_BASE_UPDATE_SPEED = 0.08
    GHOST_FINAL_UPDATE_SPEED = 0.08
    VELOCITY_MAGNITUDE = 0


    -- start timer NOT USED
    START_TIME = love.timer.getTime()


    -- game manager setting up game states
    GAME_MANAGER = {"1-tutorial", "2-game_play", "3-paused", "4-landed", "5-crashed", "6-out_of_bounds", "7-score_screen"}
    CURRENT_GAME_STATE = GAME_MANAGER[1]


    -- levels - NAME - LANDER.x - LANDER.x_velocity - LANDER.y - LANDER.y_velocity - LANDER.fuel_s - SURFACE_LINE_POINTS - LANDING_SURFACE_LINE_POINTS

    LEVEL_1 = {
        name = "LEVEL_1",
        lander_x = 150,
        lander_x_velocity = 0,
        lander_y = 50,
        lander_y_velocity = 0,
        lander_fuel_s = 100,
        surface_line_points = {0, 750, 1280, 750},
        landing_surface_line_points = {300, 748, 350, 748}
    }

    LEVEL_2 = {
        name = "LEVEL_2",
        lander_x = 150,
        lander_x_velocity = 5,
        lander_y = 50,
        lander_y_velocity = 0,
        lander_fuel_s = 90,
        surface_line_points = {0, 750, 500, 750, 550, 780, 920, 780, 970, 750, 1280, 750},
        landing_surface_line_points = {1100, 748, 1170, 748}
    }

    LEVEL_3 = {
        name = "LEVEL_3",
        lander_x = 150,
        lander_x_velocity = 8,
        lander_y = 350,
        lander_y_velocity = 3,
        lander_fuel_s = 85,
        surface_line_points = {0, 750, 500, 750, 550, 300, 920, 300, 970, 750, 1280, 750},
        landing_surface_line_points = {1100, 748, 1145, 748}
    }

    LEVEL_4 = {
        name = "LEVEL_4",
        lander_x = 150,
        lander_x_velocity = -10,
        lander_y = 20,
        lander_y_velocity = 15,
        lander_fuel_s = 110,
        surface_line_points = {0, 750, 500, 750, 550, 450, 1000, 450, 1090, 750, 1140, 750, 1280, 450},
        landing_surface_line_points = {1095, 748, 1137, 748}
    }

    LEVEL_5 = {
        name = "LEVEL_5",
        lander_x = 1200,
        lander_x_velocity = -28,
        lander_y = 600,
        lander_y_velocity = 10,
        lander_fuel_s = 85,
        surface_line_points = {0, 750, 100, 750, 150, 450, 200, 450, 250, 100, 400, 100, 450, 750, 1280, 750},
        landing_surface_line_points = {160, 448, 190, 448}
    }

    -- set up level stuff
    LEVELS = {LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5}
    TOTAL_NUMBER_OF_LEVELS = #LEVELS
    LEVEL_NUMBER = 1
    CURRENT_LEVEL = LEVELS[LEVEL_NUMBER]
    LEVEL_LOADED_FLAG = false


    -- drawings
    TUTORIAL_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("        A    S    D \n\nTHRUSTER COMMANDS", LANDER.x - 48, LANDER.y + 30)
            love.graphics.print("PRESS SPACE TO START", SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PRESS p TO PAUSE", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
            love.graphics.print("PRESS r TO RESTART ANY TIME", SCREEN_X / 2, (SCREEN_Y / 2) + 40)
            local X_location = SCREEN_X - 90
            local Y_location = SCREEN_Y - 790
            love.graphics.print("VELOCITIES ->", X_location - 180, Y_location)
            love.graphics.print("MUST BE UNDER 5 m/s FOR SAFE LANDING", X_location - 270, Y_location + 15)
            love.graphics.print("THRUSTERS WILL NOT FIRE IF FUEL ->\n                   RUNS OUT", X_location - 260, Y_location + 34)
            love.graphics.print("IF LANDER EXITS THE SCREEN IT WILL BECOME LOST IN SPACE ->", X_location - 320, Y_location + 150)
            love.graphics.print("LANDING ZONE", LANDING_SURFACE_LINE_POINTS[1] - 25, LANDING_SURFACE_LINE_POINTS[2] - 20)
            -- TO DO make tutorial text nicer, add score/fuel explanation
        end
    }

    HUD_TEXT = {
        draw = function ()
            -- displayed variables on the right corner
            local X_location = SCREEN_X - 90
            local Y_location = SCREEN_Y - 790
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Yvel: " .. math.floor(LANDER.y_velocity) .. " m/s", X_location, Y_location)
            love.graphics.print("Xvel: " .. math.floor(LANDER.x_velocity) .. " m/s", X_location, Y_location + 17)
            love.graphics.print("Fuel: " .. math.floor(LANDER.fuel_s) .. " s", X_location , Y_location + 34)
            love.graphics.print(CURRENT_LEVEL["name"], X_location, Y_location + 51)
        end
    }

    THRUSTER_GRAPHIC = {
        draw = function ()
            if LANDER.y_thruster == true then
                love.graphics.draw(LANDER.sprite_y_thruster, LANDER.x, LANDER.y)
            end

            if LANDER.x_thruster_left == true then
                love.graphics.draw(LANDER.sprite_x_thruster_left, LANDER.x, LANDER.y)
            end

            if LANDER.x_thruster_right == true then
                love.graphics.draw(LANDER.sprite_x_thruster_right, LANDER.x, LANDER.y)
            end
        end
    }

    LANDER_GRAPHIC = {
        draw = function ()
            love.graphics.draw(LANDER.spriteA1, LANDER.x_old2, LANDER.y_old2)
            love.graphics.draw(LANDER.spriteA05, LANDER.x_old1, LANDER.y_old1)
            love.graphics.draw(LANDER.spriteA025, LANDER.x, LANDER.y)
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

    PAUSED_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("PRESS p TO UNPAUSE", SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PRESS r TO RESTART", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
        end
    }

    LANDED_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("THE EAGLE HAS LANDED!", SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PRESS r TO RESTART THIS LEVEL", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
            love.graphics.print("PRESS c TO CONTINUE", SCREEN_X / 2, (SCREEN_Y / 2) + 40)
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

    SCORE_SCREEN_TEXT = {
        draw = function (SCORE)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("CONGRATULATIONS! YOUR FINAL SCORE IS: " .. math.floor(SCORE), SCREEN_X / 2, SCREEN_Y / 2)
            love.graphics.print("PLEASE PRESS x TO EXIT GAME!", SCREEN_X / 2, (SCREEN_Y / 2) + 20)
            -- TO DO add music credits and dedication to apollo11
        end
    }


    -- sounds
    CHATTER_SOUND = love.audio.newSource("sounds/chatter.mp3", "stream")
    CHATTER_SOUND:setLooping(true)
    CHATTER_SOUND:setVolume(0.03)
    MUSIC_SOUND = love.audio.newSource("sounds/music.mp3", "stream")
    MUSIC_SOUND:setLooping(true)
    MUSIC_SOUND:setVolume(0.3)
    CRASH_PROBLEM_SOUND = love.audio.newSource("sounds/crash_problem.mp3", "static")
    CRASH_PROBLEM_SOUND:setLooping(false)
    CRASH_PROBLEM_SOUND:setVolume(0.045)
    LAND_SUCCESS_SOUND = love.audio.newSource("sounds/land_success.mp3", "static")
    LAND_SUCCESS_SOUND:setLooping(false)
    LAND_SUCCESS_SOUND:setVolume(0.09)
    VICTORY_SMALL_STEP_SOUND = love.audio.newSource("sounds/victory_small_step.mp3", "static")
    VICTORY_SMALL_STEP_SOUND:setLooping(false)
    VICTORY_SMALL_STEP_SOUND:setVolume(0.07)
    THRUSTER_HEAVY_SOUND = love.audio.newSource("sounds/thruster_heavy.mp3", "static")
    THRUSTER_HEAVY_SOUND:setLooping(true)
    THRUSTER_HEAVY_SOUND:setVolume(0.08)
    THRUSTER_LIGHT_LEFT_SOUND = love.audio.newSource("sounds/thruster_light.mp3", "static")
    THRUSTER_LIGHT_LEFT_SOUND:setLooping(true)
    THRUSTER_LIGHT_LEFT_SOUND:setPosition(-4, 10, 0)
    THRUSTER_LIGHT_RIGHT_SOUND = love.audio.newSource("sounds/thruster_light.mp3", "static")
    THRUSTER_LIGHT_RIGHT_SOUND:setLooping(true)
    THRUSTER_LIGHT_RIGHT_SOUND:setPosition(4, 10, 0)
    -- TO DO make game louder and add victory music add more music

    -- function to stop thruster sound effects
    SOUND_EFFECTS = {THRUSTER_HEAVY_SOUND, THRUSTER_LIGHT_LEFT_SOUND, THRUSTER_LIGHT_RIGHT_SOUND}
    function INTERACT_THRUSTER_SOUND_EFFECTS(method, ...)
        for i = 1, #SOUND_EFFECTS do
            SOUND_EFFECTS[i][method](SOUND_EFFECTS[i], ...)
        end
    end

end


------------------------------------------------------------------------------------------------------------------------------------


function love.update(dt)

    -- loading current level
    if LEVEL_LOADED_FLAG == false then

        LANDER.x = CURRENT_LEVEL.lander_x
        LANDER.x_old1 = CURRENT_LEVEL.lander_x
        LANDER.x_old2 = CURRENT_LEVEL.lander_x
        LANDER.x_velocity = CURRENT_LEVEL.lander_x_velocity
        LANDER.y = CURRENT_LEVEL.lander_y
        LANDER.y_old1 = CURRENT_LEVEL.lander_y
        LANDER.y_old2 = CURRENT_LEVEL.lander_y
        LANDER.y_velocity = CURRENT_LEVEL.lander_y_velocity
        LANDER.fuel_s = CURRENT_LEVEL.lander_fuel_s
        SURFACE_LINE_POINTS = CURRENT_LEVEL.surface_line_points
        LANDING_SURFACE_LINE_POINTS = CURRENT_LEVEL.landing_surface_line_points

        -- load initial lander collision pixels
        LANDER_COLLISION_PIXELS = {
            {x = LANDER.x , y = LANDER.y}, -- upper left
            {x = LANDER.x + 24 , y = LANDER.y}, -- upper right
            {x = LANDER.x, y = LANDER.y + 24}, -- lower left
            {x = LANDER.x + 24, y = LANDER.y + 24} -- lover right
        }

        -- load line collision pixels for this level

        LINE_COLLISION_PIXELS = {}

        -- populating table for all collision pixels in the surface line based on the SURFACE_LINE_POINTS
        -- NOTE WILL NOT HANDLE VERTICAL LINES - divide by 0
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

        -- finish loading level
        LEVEL_LOADED_FLAG = true
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "1-tutorial" then

        -- exit 1-tutorial into 2-game_play by pressing "space"
        function love.keypressed(key)
               if key == 'space' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "2-game_play" then

        -- sound stuff 
        -- start sounds and reset volumes
        CHATTER_SOUND:play()
        CHATTER_SOUND:setVolume(0.03)
        MUSIC_SOUND:play()
        MUSIC_SOUND:setVolume(0.3)


        -- x axis trusters and acceleration left or right
        LANDER.x_thruster_left = false
        LANDER.x_thruster_right = false
        if love.keyboard.isDown("a") and LANDER.fuel_s > 0 then
            LANDER.x_thruster_left = true
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt * (LANDER.x_thruster_force_N/math.abs(LANDER.y_only_thruster_force_N))
        end

        if love.keyboard.isDown("d") and LANDER.fuel_s > 0 then
            LANDER.x_thruster_right = true
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt * (LANDER.x_thruster_force_N/math.abs(LANDER.y_only_thruster_force_N))
        end

        if LANDER.x_thruster_left == true and LANDER.fuel_s > 1 then
            LANDER.x_velocity = LANDER.x_velocity + LANDER.x_thruster_acceleration * dt
        end

        if LANDER.x_thruster_right == true and LANDER.fuel_s > 1 then
            LANDER.x_velocity = LANDER.x_velocity - LANDER.x_thruster_acceleration * dt
        end

        -- ghost images coordinates to make movement smoother
        if GHOST_IMAGE_UPDATE_COUNTERx2 >= GHOST_FINAL_UPDATE_SPEED then
            LANDER.x_old2 = LANDER.x_old1
            GHOST_IMAGE_UPDATE_COUNTERx2 = 0
        end

        if GHOST_IMAGE_UPDATE_COUNTERx1 >= GHOST_FINAL_UPDATE_SPEED then
            LANDER.x_old1 = LANDER.x
            GHOST_IMAGE_UPDATE_COUNTERx1 = 0
        end

        GHOST_IMAGE_UPDATE_COUNTERx2 = GHOST_IMAGE_UPDATE_COUNTERx2 + dt
        GHOST_IMAGE_UPDATE_COUNTERx1 = GHOST_IMAGE_UPDATE_COUNTERx1 + dt

        -- x axis lander movement
        LANDER.x = LANDER.x + LANDER.x_velocity * dt

        -- x axis sounds
        if LANDER.x_thruster_left == true then
            THRUSTER_LIGHT_LEFT_SOUND:play()
        else
            THRUSTER_LIGHT_LEFT_SOUND:stop()
        end

        if LANDER.x_thruster_right == true then
            THRUSTER_LIGHT_RIGHT_SOUND:play()
        else
            THRUSTER_LIGHT_RIGHT_SOUND:stop()
        end


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

        -- ghost images coordinates to make movement smoother
        if GHOST_IMAGE_UPDATE_COUNTERy2 >= GHOST_FINAL_UPDATE_SPEED then
            LANDER.y_old2 = LANDER.y_old1
            GHOST_IMAGE_UPDATE_COUNTERy2 = 0
        end

        if GHOST_IMAGE_UPDATE_COUNTERy1 >= GHOST_FINAL_UPDATE_SPEED then
            LANDER.y_old1 = LANDER.y
            GHOST_IMAGE_UPDATE_COUNTERy1 = 0
        end

        GHOST_IMAGE_UPDATE_COUNTERy2 = GHOST_IMAGE_UPDATE_COUNTERy2 + dt
        GHOST_IMAGE_UPDATE_COUNTERy1 = GHOST_IMAGE_UPDATE_COUNTERy1 + dt

        -- y axis lander movement
        LANDER.y = LANDER.y + LANDER.y_velocity * dt

        -- y axis sounds
        if LANDER.y_thruster == true then
            THRUSTER_HEAVY_SOUND:play()
        else
            THRUSTER_HEAVY_SOUND:stop()
        end


        -- calculate magnitude of velocity and update speed for frequency of updating ghost images
        VELOCITY_MAGNITUDE = math.sqrt(math.pow(LANDER.x_velocity, 2) + math.pow(LANDER.y_velocity, 2))
        if VELOCITY_MAGNITUDE > 0 then
            GHOST_FINAL_UPDATE_SPEED = GHOST_BASE_UPDATE_SPEED / VELOCITY_MAGNITUDE
        end


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
            math.abs(LANDER.y_velocity) < 6 and math.abs(LANDER.x_velocity) < 6 then
            -- change landing flag to true
            print("***LANDED***")
            -- pause chatter lower music volume and play landing chatter
            CHATTER_SOUND:pause()
            MUSIC_SOUND:setVolume(0.08)
            LAND_SUCCESS_SOUND:play()
            -- exit 2-game_play into 4-landed by proper landing
            CURRENT_GAME_STATE = GAME_MANAGER[4]
        end


        -- crash check
        -- collision with surface check and counter used to reduce the check frequency to 50 times a second for a smoother game
        -- COLLISION_FREQUENCY_COUNTER = COLLISION_FREQUENCY_COUNTER + dt
        -- if COLLISION_FREQUENCY_COUNTER > 0.02 then
        for i = 3, #LANDER_COLLISION_PIXELS do
            for j = 1, #LINE_COLLISION_PIXELS do
                if LANDER_COLLISION_PIXELS[i]["x"] == LINE_COLLISION_PIXELS[j]["x"] and LANDER_COLLISION_PIXELS[i]["y"] == LINE_COLLISION_PIXELS[j]["y"] then
                    print("***COLLISION***")
                    -- pause chatter lower music volume and play huston we have a problem chatter
                    CHATTER_SOUND:pause()
                    MUSIC_SOUND:setVolume(0.08)
                    CRASH_PROBLEM_SOUND:play()
                    -- exit 2-game_play into 5-crashed by collision with surface
                    CURRENT_GAME_STATE = GAME_MANAGER[5]
                end
            end
        end
            -- COLLISION_FREQUENCY_COUNTER = 0
        -- end


        -- out of bounds check 
        -- check lower left lander collision pixel against  top bounds of map using Y
        if LANDER_COLLISION_PIXELS[3]["y"] < 0 or
            -- check lower right lander collision against left bounds of map using X
            LANDER_COLLISION_PIXELS[4]["x"] < 0 or
            -- check lower left lander collision against right bounds of the map using X
            LANDER_COLLISION_PIXELS[3]["x"] > 1280 then
            print("***OUT OF BOUNDS***")
            -- pause chatter lower music volume and huston we have a problem chatter
            CHATTER_SOUND:pause()
            MUSIC_SOUND:setVolume(0.08)
            CRASH_PROBLEM_SOUND:play()
            -- exit 2-game_play into 6-out_of_bounds by exiting the screen
            CURRENT_GAME_STATE = GAME_MANAGER[6]
        end



        function love.keypressed(key)
            -- pause game
            -- exit 2_game_play into 3_paused by pressing "p"
            if key == 'p' then
                CURRENT_GAME_STATE = GAME_MANAGER[3]
            end
            -- restart current level any time
            -- exit 2_game_play into load then 2-game_play by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
                LEVEL_LOADED_FLAG = false
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "3-paused" then

        -- lower background sounds 
        CHATTER_SOUND:setVolume(0.002)
        MUSIC_SOUND:setVolume(0.05)

        -- exit 3_paused into 2-game_play by pressing "p"
        function love.keypressed(key)
            if key == 'p' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
            -- restart current level during paused
            -- exit 3_paused into load then 2-game_play by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
                LEVEL_LOADED_FLAG = false
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "4-landed" then



        function love.keypressed(key)
            -- exit 4-landed into 2-game_play by pressing "r" to restart level
            if key == 'r' then
                -- stop landing chatter
                LAND_SUCCESS_SOUND:stop()
                CURRENT_GAME_STATE = GAME_MANAGER[2]
                LEVEL_LOADED_FLAG = false
            end

            if key == 'c' then
                -- stop landing chatter
                LAND_SUCCESS_SOUND:stop()

                -- iterate to next level
                LEVEL_NUMBER = LEVEL_NUMBER + 1
                -- switch to next level or the score_screen if no more levels
                if LEVEL_NUMBER <= TOTAL_NUMBER_OF_LEVELS then
                -- if LEVEL_NUMBER <= 1 then
                    CURRENT_LEVEL = LEVELS[LEVEL_NUMBER]
                    LEVEL_LOADED_FLAG = false
                    -- update score with leftover fuel
                    SCORE = SCORE + LANDER.fuel_s
                    -- exit 4-landed into 2-game_play by pressing "c" to continue to next level
                    CURRENT_GAME_STATE = GAME_MANAGER[2]
                else
                    -- play victory small step for man sound and stop chatter
                    CHATTER_SOUND:stop()
                    VICTORY_SMALL_STEP_SOUND:play()
                    -- update score with leftover fuel
                    SCORE = SCORE + LANDER.fuel_s
                    -- exit 4-landed into 7-score_screen by pressing "c" to continue to score_screen
                    CURRENT_GAME_STATE = GAME_MANAGER[7]
                end
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "5-crashed" then

        function love.keypressed(key)
            -- exit 5_crashed into 2-game_play by pressing "r" to restart level
            if key == 'r' then
                -- stop cash chatter
                CRASH_PROBLEM_SOUND:stop()

                LEVEL_LOADED_FLAG = false

                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
        end

        -- TO DO add crash animation
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "6-out_of_bounds" then

        function love.keypressed(key)
            -- exit 6-out_of_bounds into 2-game_play by pressing "r" to restart level
            if key == 'r' then
                -- stop huston we have a problem chatter
                CRASH_PROBLEM_SOUND:stop()

                LEVEL_LOADED_FLAG = false

                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "7-score_screen" then

        function love.keypressed(key)
            -- exit 7-out_of_bounds quitting the game window with "x"
            if key == 'x' then
                love.event.quit()
            end
        end
        -- TO DO add victory music and or sounds
    end

-----------------------------------------------------------

    -- sound stuff
    -- turn off thruster sounds if not during 2-game_play state
    if CURRENT_GAME_STATE ~= "2-game_play" then
        INTERACT_THRUSTER_SOUND_EFFECTS("stop")
    end

    -- run timer - NOT USED
    ELAPSED_TIME = love.timer.getTime() - START_TIME

end


------------------------------------------------------------------------------------------------------------------------------------


function love.draw()

    if CURRENT_GAME_STATE == "1-tutorial" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        TUTORIAL_TEXT.draw()
    end

    if CURRENT_GAME_STATE == "2-game_play" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        THRUSTER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
    end

    if CURRENT_GAME_STATE == "3-paused" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        PAUSED_TEXT.draw()
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
        SCORE_SCREEN_TEXT.draw(SCORE)
    end

end