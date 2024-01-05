function love.load()


    -- define resolution
    SCREEN_X = 1280
    SCREEN_Y = 800


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


    -- crash animations
    CRASH_ANIMATION_INDEX = 1
    DUST_CRASH_ANIMATION = {}
    table.insert(DUST_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/dust_crash01.png'))
    table.insert(DUST_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/dust_crash02.png'))
    table.insert(DUST_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/dust_crash03.png'))
    table.insert(DUST_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/dust_crash04.png'))
    table.insert(DUST_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/dust_crash05.png'))
    CURRENT_DUST_CRASH_FRAME = DUST_CRASH_ANIMATION[CRASH_ANIMATION_INDEX]
    LANDER_CRASH_ANIMATION = {}
    table.insert(LANDER_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/lander_crash01.png'))
    table.insert(LANDER_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/lander_crash02.png'))
    table.insert(LANDER_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/lander_crash03.png'))
    table.insert(LANDER_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/lander_crash04.png'))
    table.insert(LANDER_CRASH_ANIMATION, love.graphics.newImage('sprites/lander_crash/lander_crash05.png'))
    CURRENT_LANDER_CRASH_FRAME = LANDER_CRASH_ANIMATION[CRASH_ANIMATION_INDEX]

    -- transition curtain rectangle
    TRANSITION_CURTAIN = {}
    TRANSITION_CURTAIN.mode = "fill"
    TRANSITION_CURTAIN.x = 0
    TRANSITION_CURTAIN.y = 0
    TRANSITION_CURTAIN.width = SCREEN_X
    TRANSITION_CURTAIN.height = SCREEN_Y
    TRANSITION_CURTAIN.flag = true


    -- splash and score screens
    SPLASH_SCREEN = {}
    SPLASH_SCREEN.pic = love.graphics.newImage('sprites/screen_pics/splash_screen.png')
    SPLASH_SCREEN.x = 0
    SPLASH_SCREEN.y = 0
    SCORE_SCREEN = {}
    SCORE_SCREEN.pic = love.graphics.newImage('sprites/screen_pics/score_screen2.png')
    SCORE_SCREEN.x = 0
    SCORE_SCREEN.y = 0


    -- initialize lander collision pixels surface line points and landing zone surface and score
    LANDER_COLLISION_PIXELS = {}
    SURFACE_LINE_POINTS = {}
    LANDING_SURFACE_LINE_POINTS = {}
    SCORE = 0

    -- OLD COLLISION SYSTEM SAVED FOR POSTERITY
    -- LINE_COLLISION_PIXELS = {}
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


    -- DT TIMERS!
    DT_TIMER_FOR_SPLASH_SCREEN = 0
    DT_TIMER_FOR_TUTORIAL = 0
    DT_TIMER_FOR_LOADED_HUD = 0
    DT_TIMER_FOR_SOUND_CONTROL = 0
    DT_TIMER_FOR_FUEL_ALERT = 0
    DT_TIMER_FOR_CRASH_ANIMATION = 0
    DT_TIMER_FOR_SCORE_SCREEN = 0



    -- game manager setting up game states
    GAME_MANAGER = {"1-tutorial", "2-game_play", "3-paused", "4-landed", "5-crashed", "6-out_of_bounds", "7-score_screen", "8-loaded", "9-splash_screen"}
    CURRENT_GAME_STATE = GAME_MANAGER[9]

    -- levels - NAME - LANDER.x - LANDER.x_velocity - LANDER.y - LANDER.y_velocity - LANDER.fuel_s - SURFACE_LINE_POINTS - LANDING_SURFACE_LINE_POINTS

    LEVEL_1 = {
        name = "LEVEL_1",
        lander_x = 150,
        lander_x_velocity = 0,
        lander_y = 50,
        lander_y_velocity = 0,
        lander_fuel_s = 99,
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
        surface_line_points = {0, 750, 400, 750, 450, 300, 920, 300, 970, 750, 1280, 750},
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


    -- initialize font and screen locations for text for drawings
    TXT_FONT = love.graphics.newFont("font/Gorton-Condensed.otf", 14)
    MED_TXT_FONT = love.graphics.newFont("font/Gorton-Condensed.otf", 22)
    BIG_TXT_FONT = love.graphics.newFont("font/Gorton-Condensed.otf", 36)
    NUM_FONT = love.graphics.newFont("font/Zerlina.otf", 18)
    BIG_NUM_FONT = love.graphics.newFont("font/Zerlina.otf", 45)
    X_MENU_TEXT_LOCATION = (SCREEN_X / 2) - 120
    Y_MENU_TEXT_LOCATION = (SCREEN_Y / 2) - 60
    MENU_TEXT_LINE_SPACER = 20

    -- drawings
    --tackers for tutorial
    SPACE_COUNTER_FOR_TUTORIAL = 0
    TUTORIAL_MENU_TEXT_FLAG = false
    TUTORIAL_RED_TEXT_OPACITY = 0

    TUTORIAL_TEXT = {
        draw = function ()
            love.graphics.setFont(TXT_FONT)
            love.graphics.setColor(1, 0, 0, TUTORIAL_RED_TEXT_OPACITY)
            love.graphics.print("A", LANDER.x - 25, LANDER.y + 5)
            love.graphics.print("D", LANDER.x + 40, LANDER.y + 5)
            love.graphics.print("S", LANDER.x + 8, LANDER.y + 35)
            love.graphics.print("THRUSTER COMMAND KEYS", LANDER.x - 90, LANDER.y + 70)
            local X_location = SCREEN_X - 260
            local Y_location = SCREEN_Y - 790
            love.graphics.print("VELOCITIES IN", X_location, Y_location)
            love.graphics.print("METERS PER SECOND", X_location - 31, Y_location + 18)
            love.graphics.print("FUEL IN SECONDS", X_location - 10, Y_location + 42)
            love.graphics.print("LANDING ZONE", LANDING_SURFACE_LINE_POINTS[1] - 30, LANDING_SURFACE_LINE_POINTS[2] - 30)
            love.graphics.print("VELOCITIES MUST BE GREEN - UNDER 5 METERS PER SECOND FOR NOMINAL LANDING - LEFTOVER FUEL WILL BE ADDED TO YOUR SCORE - THERE ARE 5 LEVELS", LANDING_SURFACE_LINE_POINTS[1] - 280, LANDING_SURFACE_LINE_POINTS[2] + 20)
            love.graphics.print("PLEASE READ RED TUTORIAL TEXT THEN PRESS SPACE", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*0)

            if TUTORIAL_MENU_TEXT_FLAG == true then
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("PRESS P TO PAUSE", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*1)
                love.graphics.print("PRESS R TO RESTART ANY TIME", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*2)
                love.graphics.print("UP AND DOWN ARROWS CONTROL SOUND VOLUME", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*3)
                love.graphics.print("PRESS SPACE TO START", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*4) 
            end
        end
    }

    HUD_TEXT_OPACITY = 0
    HUD_TEXT = {
        draw = function ()
            -- displayed variables on the right corner
            local X_location_txt = SCREEN_X - 108
            local X_location_sig = SCREEN_X - 55
            local X_location_num = SCREEN_X - 45
            local Y_location = SCREEN_Y - 790
            local line_space = 20
            love.graphics.setColor(1, 1, 1, HUD_TEXT_OPACITY)
            -- text
            love.graphics.setFont(TXT_FONT)
            love.graphics.print("VERT", X_location_txt, Y_location + (line_space * 0))
            love.graphics.print("HORI", X_location_txt, Y_location + (line_space * 1))
            love.graphics.print("FUEL", X_location_txt, Y_location + (line_space * 2))
            love.graphics.print("SCOR", X_location_txt, Y_location + (line_space * 3))
            love.graphics.print("LEVL", X_location_txt, Y_location + (line_space * 4))
            --signs
            love.graphics.setFont(NUM_FONT)
            if math.floor(LANDER.y_velocity) >= 1 then
                love.graphics.print("+", X_location_sig, Y_location + (line_space * 0))
            elseif math.floor(LANDER.y_velocity) <= -1 then
                love.graphics.print("-", X_location_sig, Y_location + (line_space * 0))
            end
            if math.floor(LANDER.x_velocity) >= 1 then
                love.graphics.print("+", X_location_sig, Y_location + (line_space * 1))
            elseif math.floor(LANDER.x_velocity) <= -1 then
                love.graphics.print("-", X_location_sig, Y_location + (line_space * 1))
            end
            -- numbers
            love.graphics.print(string.format("%03d", math.floor(LANDER.fuel_s)), X_location_num, Y_location + (line_space * 2))
            love.graphics.print(string.format("%03d", SCORE ), X_location_num, Y_location + (line_space * 3))
            love.graphics.print(string.format("%03d", LEVEL_NUMBER), X_location_num, Y_location + (line_space * 4))
            -- velocity numbers and text, changing color to green if under 5
            if math.floor(LANDER.y_velocity) < 6 and math.floor(LANDER.y_velocity) > -1 then
                love.graphics.setColor(0, 1, 0, HUD_TEXT_OPACITY)
            end
            love.graphics.print(string.format("%03d", math.abs(math.floor(LANDER.y_velocity))), X_location_num, Y_location + (line_space * 0))
            love.graphics.setColor(1, 1, 1, HUD_TEXT_OPACITY)
            if math.abs(math.floor(LANDER.x_velocity)) < 6 then
                love.graphics.setColor(0, 1, 0, HUD_TEXT_OPACITY)
            end
            love.graphics.print(string.format("%03d", math.abs(math.floor(LANDER.x_velocity))), X_location_num, Y_location + (line_space * 1))
        end
    }

    TRANSITION_CURTAIN_GRAPHIC = {
        draw = function ()
            love.graphics.setColor(0, 0, 0)
            if TRANSITION_CURTAIN.flag == true then
                love.graphics.rectangle(TRANSITION_CURTAIN.mode, TRANSITION_CURTAIN.x, TRANSITION_CURTAIN.y, TRANSITION_CURTAIN.width, TRANSITION_CURTAIN.height)
            end
        end
    }

    THRUSTER_GRAPHIC = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
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
            love.graphics.setColor(1, 1, 1)
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
            love.graphics.setFont(TXT_FONT)
            love.graphics.print("PRESS P TO UNPAUSE", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*0)
            love.graphics.print("PRESS R TO RESTART LEVEL", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*1)
        end
    }

    LANDED_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(TXT_FONT)
            love.graphics.print("THE EAGLE HAS LANDED", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*0)
            love.graphics.print("PRESS C TO CONTINUE", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*1)
        end
    }

    CRASHED_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(TXT_FONT)
            love.graphics.print("LANDER HAS CRASHED", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*0)
            love.graphics.print("PRESS R TO RESTART", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*1)
        end
    }

    OUT_OF_BOUNDS_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(TXT_FONT)
            love.graphics.print("OUT OF BOUNDS! LANDER IS LOST FOREVER IN SPACE", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*0)
            love.graphics.print("PRESS R TO RESTART", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*1)
        end
    }

    SCORE_SCREEN_BACKGROUND = {
        draw = function ()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(SCORE_SCREEN.pic, SCORE_SCREEN.x, SCORE_SCREEN.y)
        end
    }

    -- tables for fade in credits
    CREDITS_TEXT_TABLE = {
        "CREDITS",
        "",
        "DESIGN ZORIN",
        "PROGRAMMING ZORIN",
        "PIXEL ART ZORIN",
        " ",
        "PICTURES FROM NASA",
        "RETOUCHED BY LEONARDO AI",
        " ",
        "MUSIC KEVIN MACLEOD",
        "EQUATORIAL COMPLEX",
        "FROZEN STAR",
        "WIZARDTORIUM",
        "FANFARE FOR SPACE",
        " ",
        "CHATTER FROM NASA MISSIONS",
        "APOLLO 11 AND APOLLO 13",
        " ",
        "OTHER SOUNDS",
        "NEWLOCKNEW FREESOUND",
        "LINK-BOY FREESOUND",
        "ZE RUBENATOR YOUTUBE",
        "PLAYED N FAVED YOUTUBE",
        " ",
        "DSKY FONTS",
        "EHDORRII GITHUB",
        " ",
        "DEDICATED TO",
        "THE APOLLO 11 ASTRONAUTS ",
        " ",
        "PRESS X TO EXIT GAME"
    }

    CREDITS_TEXT_OPACITY = {}

    for i = 1, #CREDITS_TEXT_TABLE do
        CREDITS_TEXT_OPACITY[i] = 0
    end
    INDEX_FOR_CREDITS_TEXT_OPACITY = 1

    local x_center_point = 850
    CREDITS_X_LOCATION = {}
    for i = 1, #CREDITS_TEXT_TABLE do
        CREDITS_X_LOCATION[i] = x_center_point - (love.graphics.getFont():getWidth(CREDITS_TEXT_TABLE[i]) / 2)
    end

    local y_center_point = 100
    local y_line_spacer = 21
    CREDITS_Y_LOCATION = {}
    for i = 1, #CREDITS_TEXT_TABLE do
        CREDITS_Y_LOCATION[i] = y_center_point + (y_line_spacer * i)
    end

    SCORE_SCREEN_TEXT = {
        draw = function (SCORE)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(MED_TXT_FONT)
            local line_1 = "CONGRATULATIONS YOUR FINAL SCORE IS " .. math.floor(SCORE)
            love.graphics.print(line_1, x_center_point - (love.graphics.getFont():getWidth(line_1) / 2), y_center_point - (y_line_spacer * 3))

            -- credits
            for i = 1, #CREDITS_TEXT_TABLE do
                love.graphics.setFont(TXT_FONT)
                love.graphics.setColor(1, 1, 1, CREDITS_TEXT_OPACITY[i])
                love.graphics.print(CREDITS_TEXT_TABLE[i], CREDITS_X_LOCATION[i], CREDITS_Y_LOCATION[i])
            end
        end
    }
    LOADED_SCREEN_TEXT_OPACITY = 0
    LOADED_SCREEN_TEXT = {
        draw = function ()
            love.graphics.setColor(1, 1, 1, LOADED_SCREEN_TEXT_OPACITY)
            love.graphics.setFont(TXT_FONT)
            love.graphics.print("PRESS SPACE TO START", X_MENU_TEXT_LOCATION, Y_MENU_TEXT_LOCATION + MENU_TEXT_LINE_SPACER*0)
        end
    }

    CRASH_ANIMATION = {
        draw = function ()
            love.graphics.draw(CURRENT_LANDER_CRASH_FRAME, LANDER.x, LANDER.y)
            love.graphics.draw(CURRENT_DUST_CRASH_FRAME, LANDER.x, LANDER.y)
        end
    }

    SPLASH_SCREEN_BACKGROUND_OPACITY = 0
    SPLASH_SCREEN_BACKGROUND = {
        draw = function ()
            love.graphics.setColor(1, 1, 1, SPLASH_SCREEN_BACKGROUND_OPACITY)
            love.graphics.draw(SPLASH_SCREEN.pic, SPLASH_SCREEN.x, SPLASH_SCREEN.y)
        end
    }

    -- tables for fade in title
    TITLE_TEXT_TABLE = {"A", " ", "P", " ", "O", " ", "L", " ", "L", " ", "O", " ", " ", "1", " ", "1", " ", " ", " ", "L", " ", "A", " ", "N", " ", "D", " ", "E", " ", "R"}
    TITLE_TEXT_OPACITY = {}

    for i = 1, #TITLE_TEXT_TABLE do
        TITLE_TEXT_OPACITY[i] = 0
    end
    INDEX_FOR_OPACITY_TABLE = 1

    TITLE_X_LOCATIONS = {}
    local title_x_start_location = 350
    for i = 1, #TITLE_TEXT_TABLE do
        TITLE_X_LOCATIONS[i] = title_x_start_location
        title_x_start_location = title_x_start_location + 20
    end

    TITLE_Y_LOCATION = 25

    --text opacity for splash screen
    SPLASH_SCREEN_TEXT_OPACITY = 0

    SPLASH_SCREEN_FADE_IN_TITLE = {
        draw = function ()
            love.graphics.setFont(BIG_TXT_FONT)
            for i = 1, #TITLE_TEXT_TABLE do
                love.graphics.setColor(1, 1, 1, TITLE_TEXT_OPACITY[i])
                -- make 15 and 17 "11" use the number font
                if i == 14 or i == 16 then
                    love.graphics.setFont(BIG_NUM_FONT)
                else
                    love.graphics.setFont(BIG_TXT_FONT)
                end
                love.graphics.print(TITLE_TEXT_TABLE[i], TITLE_X_LOCATIONS[i], TITLE_Y_LOCATION)
            end
            love.graphics.setFont(TXT_FONT)
            love.graphics.setColor(1, 1, 1, SPLASH_SCREEN_TEXT_OPACITY)
            love.graphics.print("PRESS SPACE TO CONTINUE", 530, 100)
        end
    }


    FUEL_LOW_ALERT_FLAG = false
    FUEL_CRITICAL_ALERT_FLAG = false
    FUEL_FLASH_FLAG = true
    FUEL_ALERT_TEXT = {
        draw = function ()
            if (FUEL_LOW_ALERT_FLAG == true or FUEL_CRITICAL_ALERT_FLAG == true) and FUEL_FLASH_FLAG == true then
                -- red alert text
                love.graphics.setColor(1, 0, 0)
                love.graphics.setFont(TXT_FONT)
                if FUEL_LOW_ALERT_FLAG == true then
                    love.graphics.print("FUEL LOW", X_MENU_TEXT_LOCATION + 60, SCREEN_Y - 780 + MENU_TEXT_LINE_SPACER*0)
                end
                if FUEL_CRITICAL_ALERT_FLAG == true then
                    love.graphics.print("FUEL CRITICAL", X_MENU_TEXT_LOCATION + 45, SCREEN_Y - 780 + MENU_TEXT_LINE_SPACER*0)
                end
                -- red fuel gauge
                local X_location_txt = SCREEN_X - 108
                local X_location_num = SCREEN_X - 45
                local Y_location = SCREEN_Y - 790
                local line_space = 20
                love.graphics.print("FUEL", X_location_txt, Y_location + (line_space * 2))
                love.graphics.setFont(NUM_FONT)
                love.graphics.print(string.format("%03d", math.floor(LANDER.fuel_s)), X_location_num, Y_location + (line_space * 2))
            end
            if FUEL_LOW_ALERT_FLAG == true or FUEL_CRITICAL_ALERT_FLAG == true then
                love.graphics.setFont(TXT_FONT)
                love.graphics.setColor(1, 0, 0)
                love.graphics.print("PRESS ENTER TO DISABLE", X_MENU_TEXT_LOCATION, SCREEN_Y - 780 + MENU_TEXT_LINE_SPACER*1)
            end
        end
    }


    -- SOUNDS
    SOUND_LEVELS = {0, 0.5, 1, 2, 4, 8, 16, 32}
    SOUND_LEVEL_INDEX = 5
    MASTER_VOLUME_MODIFIER = SOUND_LEVELS[SOUND_LEVEL_INDEX]
    CHATTER_SOUND = love.audio.newSource("sounds/chatter.mp3", "stream")
    CHATTER_SOUND_BASE_VOL = 0.03
    CHATTER_SOUND:setVolume(CHATTER_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    CHATTER_SOUND:setLooping(true)
    MUSIC_SOUND = love.audio.newSource("sounds/music.mp3", "stream")
    MUSIC_SOUND_BASE_VOL = 0.3
    MUSIC_SOUND:setVolume(MUSIC_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    MUSIC_SOUND:setLooping(true)
    CRASH_PROBLEM_SOUND = love.audio.newSource("sounds/crash_problem.mp3", "static")
    CRASH_PROBLEM_SOUND_BASE_VOL = 0.045
    CRASH_PROBLEM_SOUND:setVolume(CRASH_PROBLEM_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    CRASH_PROBLEM_SOUND:setLooping(false)
    LAND_SUCCESS_SOUND = love.audio.newSource("sounds/land_success.mp3", "static")
    LAND_SUCCESS_SOUND_BASE_VOL = 0.09
    LAND_SUCCESS_SOUND:setVolume(LAND_SUCCESS_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    LAND_SUCCESS_SOUND:setLooping(false)
    VICTORY_SMALL_STEP_SOUND = love.audio.newSource("sounds/victory_small_step.mp3", "static")
    VICTORY_SMALL_STEP_SOUND_BASE_VOL = 0.1
    VICTORY_SMALL_STEP_SOUND:setVolume(VICTORY_SMALL_STEP_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    VICTORY_SMALL_STEP_SOUND:setLooping(false)
    THRUSTER_HEAVY_SOUND = love.audio.newSource("sounds/thruster_heavy.mp3", "static")
    THRUSTER_HEAVY_SOUND_BASE_VOL = 0.07
    THRUSTER_HEAVY_SOUND:setVolume(THRUSTER_HEAVY_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    THRUSTER_HEAVY_SOUND:setLooping(true)
    THRUSTER_LIGHT_LEFT_SOUND = love.audio.newSource("sounds/thruster_light.mp3", "static")
    THRUSTER_LIGHT_LEFT_SOUND_BASE_VOL = 1
    THRUSTER_LIGHT_LEFT_SOUND:setVolume(THRUSTER_LIGHT_LEFT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    THRUSTER_LIGHT_LEFT_SOUND:setLooping(true)
    THRUSTER_LIGHT_LEFT_SOUND:setPosition(-4, 10, 0)
    THRUSTER_LIGHT_RIGHT_SOUND = love.audio.newSource("sounds/thruster_light.mp3", "static")
    THRUSTER_LIGHT_RIGHT_SOUND_BASE_VOL = 1
    THRUSTER_LIGHT_RIGHT_SOUND:setVolume(THRUSTER_LIGHT_RIGHT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    THRUSTER_LIGHT_RIGHT_SOUND:setLooping(true)
    THRUSTER_LIGHT_RIGHT_SOUND:setPosition(4, 10, 0)
    THUD_BIG_SOUND = love.audio.newSource("sounds/thud_big.wav", "static")
    THUD_BIG_SOUND_BASE_VOL = 0.9
    THUD_BIG_SOUND:setVolume(THUD_BIG_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    THUD_BIG_SOUND:setLooping(false)
    THUD_SMALL_SOUND = love.audio.newSource("sounds/thud_small.mp3", "static")
    THUD_SMALL_SOUND_BASE_VOL = 0.45
    THUD_SMALL_SOUND:setVolume(THUD_SMALL_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    THUD_SMALL_SOUND:setLooping(false)
    FUEL_LOW_ALERT_SOUND = love.audio.newSource("sounds/fuel_low.mp3", "static")
    FUEL_LOW_ALERT_SOUND_BASE_VOL = 0.011
    FUEL_LOW_ALERT_SOUND:setVolume(FUEL_LOW_ALERT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    FUEL_LOW_ALERT_SOUND:setLooping(true)
    FUEL_CRITICAL_ALERT_SOUND = love.audio.newSource("sounds/fuel_critical.mp3", "static")
    FUEL_CRITICAL_ALERT_SOUND_BASE_VOL = 0.015
    FUEL_CRITICAL_ALERT_SOUND:setVolume(FUEL_CRITICAL_ALERT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
    FUEL_CRITICAL_ALERT_SOUND:setLooping(true)
    SPLASH_SCREEN_MUSIC = love.audio.newSource("sounds/splash_screen_music.mp3", "stream")
    SPLASH_SCREEN_MUSIC_BASE_VOL = 0.12
    SPLASH_SCREEN_MUSIC:setVolume(SPLASH_SCREEN_MUSIC_BASE_VOL * MASTER_VOLUME_MODIFIER)
    SPLASH_SCREEN_MUSIC:setLooping(false)
    SCORE_SCREEN_MUSIC = love.audio.newSource("sounds/score_screen_music.mp3", "stream")
    SCORE_SCREEN_MUSIC_BASE_VOL = 0.1
    SCORE_SCREEN_MUSIC:setVolume(SCORE_SCREEN_MUSIC_BASE_VOL * MASTER_VOLUME_MODIFIER)
    SCORE_SCREEN_MUSIC:setLooping(false)

    -- helper function to play big or small thud depending on speed during crash
    function CHOSE_PLAY_THUD_HELPER()
        if VELOCITY_MAGNITUDE > 15 then
            THUD_BIG_SOUND:play()
        else
            THUD_SMALL_SOUND:play()
        end
    end

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

        -- initialize transition curtain
        TRANSITION_CURTAIN.x = 0
        TRANSITION_CURTAIN.flag = true

        -- reset crash animation
        CRASH_ANIMATION_INDEX = 1

        -- reset fuel alarm flags
        FUEL_LOW_ALERT_FLAG = false
        FUEL_CRITICAL_ALERT_FLAG = false
        FUEL_FLASH_FLAG = true

        -- reset text opacities and timer for new loading
        LOADED_SCREEN_TEXT_OPACITY = 0
        HUD_TEXT_OPACITY = 0
        DT_TIMER_FOR_LOADED_HUD = 0

        -- OLD COLLISION SYSTEM SAVED FOR POSTERITY
        -- -- load line collision pixels for this level
        -- LINE_COLLISION_PIXELS = {}
        -- -- populating table for all collision pixels in the surface line based on the SURFACE_LINE_POINTS
        -- -- NOTE WILL NOT HANDLE VERTICAL LINES - divide by 0
        -- for i = 1, #SURFACE_LINE_POINTS - 2 , 2 do
        --     -- declare x and y values for point1 and point2
        --     local x1 = SURFACE_LINE_POINTS[i]
        --     local y1 = SURFACE_LINE_POINTS[i + 1]
        --     local x2 = SURFACE_LINE_POINTS[i + 2]
        --     local y2 = SURFACE_LINE_POINTS[i + 3]
        --     -- using y = mx + b line formula
        --     -- calculate m 
        --     local m = (y2 - y1) / (x2 - x1)
        --     -- calculate b
        --     local b = y1 - (m * x1)
        --     -- filling in the table using the line formula
        --     for j = x1, x2 do
        --         table.insert(LINE_COLLISION_PIXELS, {x = j, y = math.floor((m * j) + b)})
        --     end
        -- end

        -- finish loading level
        LEVEL_LOADED_FLAG = true
    end

-----------------------------------------------------------

    -- SOUND CONTROLS
    -- dt timer must be used here to so that sound does not change too fast when arrow keys are down
    DT_TIMER_FOR_SOUND_CONTROL = DT_TIMER_FOR_SOUND_CONTROL + dt
    if DT_TIMER_FOR_SOUND_CONTROL > 0.125 then
        if SOUND_LEVEL_INDEX < #SOUND_LEVELS and love.keyboard.isDown('up') then
            SOUND_LEVEL_INDEX = SOUND_LEVEL_INDEX + 1
        end
        if 1 < SOUND_LEVEL_INDEX and love.keyboard.isDown('down') then
            SOUND_LEVEL_INDEX = SOUND_LEVEL_INDEX - 1
        end
        DT_TIMER_FOR_SOUND_CONTROL = 0
    end

    MASTER_VOLUME_MODIFIER = SOUND_LEVELS[SOUND_LEVEL_INDEX]

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "1-tutorial" then
        -- sound stuff
        SPLASH_SCREEN_MUSIC:setVolume((SPLASH_SCREEN_MUSIC_BASE_VOL - 0.065) * MASTER_VOLUME_MODIFIER)
        -- start tutorial timer
        DT_TIMER_FOR_TUTORIAL = DT_TIMER_FOR_TUTORIAL + dt



        -- move transition curtain off the screen
        if TRANSITION_CURTAIN.x < SCREEN_X then
            TRANSITION_CURTAIN.x = TRANSITION_CURTAIN.x + dt*1300
        else
            TRANSITION_CURTAIN.flag = false
        end

        -- 
        function love.keypressed(key)
            if key == 'space' then
                SPACE_COUNTER_FOR_TUTORIAL = SPACE_COUNTER_FOR_TUTORIAL + 1

            end
        end

        -- fade in tutorial text after 0.5 second
        if DT_TIMER_FOR_TUTORIAL > 0.5 then
            TUTORIAL_RED_TEXT_OPACITY = TUTORIAL_RED_TEXT_OPACITY + (dt / 2.5)
        end

        -- fade in the hud after 1 second
        if DT_TIMER_FOR_TUTORIAL > 1 and HUD_TEXT_OPACITY < 1 then
            HUD_TEXT_OPACITY = HUD_TEXT_OPACITY + (dt / 2.5)
        end

        -- change the flag to display menu text
        if SPACE_COUNTER_FOR_TUTORIAL == 1 then
            TUTORIAL_RED_TEXT_OPACITY = 1
            TUTORIAL_MENU_TEXT_FLAG = true
        end

        -- exit 1-tutorial into 2-game_play by pressing "space" and stop music
        if SPACE_COUNTER_FOR_TUTORIAL == 2 then
            CURRENT_GAME_STATE = GAME_MANAGER[2]
            SPLASH_SCREEN_MUSIC:stop()
            -- ensure hud is completely visible
            HUD_TEXT_OPACITY = 1
        end

    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "2-game_play" then

        -- sound stuff 
        -- start sounds and reset volumes
        CHATTER_SOUND:play()
        CHATTER_SOUND:setVolume(CHATTER_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        MUSIC_SOUND:play()
        MUSIC_SOUND:setVolume(MUSIC_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        THRUSTER_HEAVY_SOUND:setVolume(THRUSTER_HEAVY_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        THRUSTER_LIGHT_LEFT_SOUND:setVolume(THRUSTER_LIGHT_LEFT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        THRUSTER_LIGHT_RIGHT_SOUND:setVolume(THRUSTER_LIGHT_RIGHT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        FUEL_LOW_ALERT_SOUND:setVolume(FUEL_LOW_ALERT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        FUEL_CRITICAL_ALERT_SOUND:setVolume(FUEL_CRITICAL_ALERT_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)



        -- x axis trusters and acceleration left or right
        if love.keyboard.isDown("a") and LANDER.fuel_s > 0.1 then
            LANDER.x_thruster_left = true
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt * (LANDER.x_thruster_force_N/math.abs(LANDER.y_only_thruster_force_N))
        else
            LANDER.x_thruster_left = false
        end

        if love.keyboard.isDown("d") and LANDER.fuel_s > 0.1 then
            LANDER.x_thruster_right = true
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt * (LANDER.x_thruster_force_N/math.abs(LANDER.y_only_thruster_force_N))
        else
            LANDER.x_thruster_right = false
        end

        if LANDER.x_thruster_left == true and LANDER.fuel_s > 0.1 then
            LANDER.x_velocity = LANDER.x_velocity + LANDER.x_thruster_acceleration * dt
        end

        if LANDER.x_thruster_right == true and LANDER.fuel_s > 0.1 then
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
        if love.keyboard.isDown("s") and LANDER.fuel_s > 0.1 then
            LANDER.y_thruster = true
            -- fuel consumption
            LANDER.fuel_s = LANDER.fuel_s - 1 * dt
        else
            LANDER.y_thruster = false
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
            {x = math.floor(LANDER.x + 1), y = math.floor(LANDER.y + 1)}, -- upper left
            {x = math.floor(LANDER.x + 25), y = math.floor(LANDER.y + 1)}, -- upper right
            {x = math.floor(LANDER.x + 1), y = math.floor(LANDER.y + 25)}, -- lower left 1
            {x = math.floor(LANDER.x + 25), y = math.floor(LANDER.y + 25)}, -- lower right 1
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
            LAND_SUCCESS_SOUND:play()
            CHATTER_SOUND:pause()
            -- exit 2-game_play into 4-landed by proper landing
            CURRENT_GAME_STATE = GAME_MANAGER[4]
        end


        -- OLD COLLISION SYSTEM SAVED FOR POSTERITY
        -- -- crash check
        -- -- collision with surface check and counter used to reduce the check frequency to 50 times a second for a smoother game
        -- -- COLLISION_FREQUENCY_COUNTER = COLLISION_FREQUENCY_COUNTER + dt
        -- -- if COLLISION_FREQUENCY_COUNTER > 0.02 then
        -- for i = 3, #LANDER_COLLISION_PIXELS do
        --     for j = 1, #LINE_COLLISION_PIXELS do
        --         if LANDER_COLLISION_PIXELS[i]["x"] == LINE_COLLISION_PIXELS[j]["x"] and LANDER_COLLISION_PIXELS[i]["y"] == LINE_COLLISION_PIXELS[j]["y"] then
        --             print("***COLLISION***")
        --             -- pause chatter lower music volume and play huston we have a problem chatter
        --             CHATTER_SOUND:pause()
        --             MUSIC_SOUND:setVolume(0.08)
        --             CRASH_PROBLEM_SOUND:play()
        --             -- exit 2-game_play into 5-crashed by collision with surface
        --             CURRENT_GAME_STATE = GAME_MANAGER[5]
        --         end
        --     end
        -- end
        --     -- COLLISION_FREQUENCY_COUNTER = 0
        -- -- end


        -- COLLISION CHECK BASED ON LINE SEGMENT INTERSECTION OR COINCIDENCE
        for i = 1, #SURFACE_LINE_POINTS - 2 , 2 do

            -- declare C.x C.y D.x D.y for line intersection algorithm line CD
            local C = {x = SURFACE_LINE_POINTS[i], y = SURFACE_LINE_POINTS[i + 1]}
            local D = {x = SURFACE_LINE_POINTS[i + 2], y = SURFACE_LINE_POINTS[i + 3]}

            -- declare A.x A.y B.x B.y for line intersection algorithm line AB
            local A = {x = LANDER_COLLISION_PIXELS[3]["x"], y = LANDER_COLLISION_PIXELS[3]["y"]}
            local B = {x = LANDER_COLLISION_PIXELS[4]["x"], y = LANDER_COLLISION_PIXELS[4]["y"]}

            -- declare numerators and denominator to be used 
            local a_numerator = (D.x - C.x)*(C.y - A.y) - (C.x - A.x)*(D.y - C.y)
            local b_numerator = (B.x - A.x)*(C.y - A.y) - (C.x - A.x)*(B.y - A.y)
            local denominator = (D.x - C.x)*(B.y - A.y) - (B.x - A.x)*(D.y - C.y)

            -- COLLISION CHECKS

            -- if a_numerator and denominator is 0, line segments could be coincidental, further check for overlap using lander corners A.x B.x
            if a_numerator == 0 and denominator == 0 then
                -- check right side B.x and left A.x side of the lander if they are between C.x and D.x which means coincidental
                if (C.x <= B.x and B.x <= D.x) or ( C.x <= A.x and A.x <= D.x ) then
                    print("COLLISION!!!")
                    print("a_numerator =" .. a_numerator .. " b_numerator = " .. b_numerator ..  " denominator = " .. denominator)
                    print("A.x = " .. A.x .. " B.x = " .. B.x .. " C.x = " .. C.x .. " D.x = " .. D.x)
                    -- pause chatter lower music volume and play huston we have a problem chatter and thud
                    CHOSE_PLAY_THUD_HELPER()
                    CRASH_PROBLEM_SOUND:play()
                    CHATTER_SOUND:pause()
                    -- exit 2-game_play into 5-crashed by collision with surface
                    CURRENT_GAME_STATE = GAME_MANAGER[5]
                end
                -- check for intersection
            elseif denominator ~= 0 then
                -- if the above are false continue by calculating a and b multiply a and b by 100 then put them in math.floor() 
                local a = math.floor((a_numerator / denominator) * 100)
                local b = math.floor((b_numerator / denominator) * 100)
                -- if both a and b are between 0 and 100, line segments intersect at some point
                if a >= 0 and a <= 100 and b >= 0 and b <= 100 then
                    print("COLLISION!!!")
                    print ("a = " .. a .. " b = " .. b)
                    -- pause chatter lower music volume and play huston we have a problem chatter and thud
                    CHOSE_PLAY_THUD_HELPER()
                    CRASH_PROBLEM_SOUND:play()
                    CHATTER_SOUND:pause()
                    -- exit 2-game_play into 5-crashed by collision with surface
                    CURRENT_GAME_STATE = GAME_MANAGER[5]
                end
            end
        end


        -- out of bounds check 
        -- check lower left lander collision pixel against  top bounds of map using Y
        if LANDER_COLLISION_PIXELS[3]["y"] < 0 or
            -- check lower right lander collision against left bounds of map using X
            LANDER_COLLISION_PIXELS[4]["x"] < 0 or
            -- check lower left lander collision against right bounds of the map using X
            LANDER_COLLISION_PIXELS[3]["x"] > 1280 then
            print("***OUT OF BOUNDS***")
            -- pause chatter lower music volume and huston we have a problem chatter
            CRASH_PROBLEM_SOUND:play()
            CHATTER_SOUND:pause()
            -- exit 2-game_play into 6-out_of_bounds by exiting the screen
            CURRENT_GAME_STATE = GAME_MANAGER[6]
        end


        -- control for flashing alert
        if math.floor(LANDER.fuel_s) == 31 then
            FUEL_LOW_ALERT_FLAG = true
            LANDER.fuel_s = LANDER.fuel_s - 1
            FUEL_LOW_ALERT_SOUND:play()
        end

        if math.floor(LANDER.fuel_s) == 11 and FUEL_LOW_ALERT_FLAG == false then
            FUEL_CRITICAL_ALERT_FLAG = true
            LANDER.fuel_s = LANDER.fuel_s - 1
            FUEL_CRITICAL_ALERT_SOUND:play()
        end

        if FUEL_LOW_ALERT_FLAG == true or FUEL_CRITICAL_ALERT_FLAG == true then
            DT_TIMER_FOR_FUEL_ALERT = DT_TIMER_FOR_FUEL_ALERT + dt
        end

        if (FUEL_LOW_ALERT_FLAG == true or FUEL_CRITICAL_ALERT_FLAG == true) and DT_TIMER_FOR_FUEL_ALERT > 0.4 then
            FUEL_FLASH_FLAG = true
        end

        if (FUEL_LOW_ALERT_FLAG == true or FUEL_CRITICAL_ALERT_FLAG == true) and DT_TIMER_FOR_FUEL_ALERT > 0.8 then
            FUEL_FLASH_FLAG = false
            DT_TIMER_FOR_FUEL_ALERT = 0
        end


        function love.keypressed(key)
            -- pause game
            -- exit 2_game_play into 3_paused by pressing "p"
            if key == 'p' then
                CURRENT_GAME_STATE = GAME_MANAGER[3]
            end
            -- restart current level any time
            -- exit 2_game_play into load then 8-loaded by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[8]
                LEVEL_LOADED_FLAG = false
            end
            -- press space for disabling fuel alerts
            if key == 'return' then
                FUEL_LOW_ALERT_FLAG = false
                FUEL_LOW_ALERT_SOUND:stop()
                FUEL_CRITICAL_ALERT_FLAG = false
                FUEL_CRITICAL_ALERT_SOUND:stop()
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "3-paused" then

        -- lower background sounds
        CHATTER_SOUND:setVolume((CHATTER_SOUND_BASE_VOL - 0.028) * MASTER_VOLUME_MODIFIER)
        MUSIC_SOUND:setVolume((MUSIC_SOUND_BASE_VOL - 0.25) * MASTER_VOLUME_MODIFIER)

        -- exit 3_paused into 2-game_play by pressing "p"
        function love.keypressed(key)
            if key == 'p' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
            end
            -- restart current level during paused
            -- exit 3_paused into load then 8-loaded by pressing "r" to restart level
            if key == 'r' then
                CURRENT_GAME_STATE = GAME_MANAGER[8]
                LEVEL_LOADED_FLAG = false
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "4-landed" then

        -- landed sounds
        MUSIC_SOUND:setVolume((MUSIC_SOUND_BASE_VOL - 0.22) * MASTER_VOLUME_MODIFIER)
        LAND_SUCCESS_SOUND:setVolume(LAND_SUCCESS_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)


        function love.keypressed(key)
            -- exit 4-landed into 8-loaded by pressing "r" to restart level
            if key == 'r' then
                -- stop landing chatter
                LAND_SUCCESS_SOUND:stop()
                CURRENT_GAME_STATE = GAME_MANAGER[8]
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
                    -- exit 4-landed into 8-loaded by pressing "c" to continue to next level
                    CURRENT_GAME_STATE = GAME_MANAGER[8]
                else
                    -- stop chatter and music, play small step for man sound and victory music
                    CHATTER_SOUND:stop()
                    MUSIC_SOUND:stop()
                    VICTORY_SMALL_STEP_SOUND:play()
                    SCORE_SCREEN_MUSIC:play()
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

        --crashed sounds
        MUSIC_SOUND:setVolume((MUSIC_SOUND_BASE_VOL - 0.22) * MASTER_VOLUME_MODIFIER)
        CRASH_PROBLEM_SOUND:setVolume(CRASH_PROBLEM_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        THUD_BIG_SOUND:setVolume(THUD_BIG_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)
        THUD_SMALL_SOUND:setVolume(THUD_SMALL_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)

        function love.keypressed(key)
            -- exit 5_crashed into 8-loaded by pressing "r" to restart level
            if key == 'r' then
                -- stop cash chatter
                THUD_SMALL_SOUND:stop()
                THUD_BIG_SOUND:stop()
                CRASH_PROBLEM_SOUND:stop()

                LEVEL_LOADED_FLAG = false
                -- exit 5-crashed into 8-loaded by pressing "c" to continue to next level
                CURRENT_GAME_STATE = GAME_MANAGER[8]
            end
        end

        -- crash animation
        DT_TIMER_FOR_CRASH_ANIMATION = DT_TIMER_FOR_CRASH_ANIMATION + dt
        if CRASH_ANIMATION_INDEX < #DUST_CRASH_ANIMATION and DT_TIMER_FOR_CRASH_ANIMATION > 0.14 then
            CRASH_ANIMATION_INDEX = CRASH_ANIMATION_INDEX + 1
            CURRENT_DUST_CRASH_FRAME = DUST_CRASH_ANIMATION[CRASH_ANIMATION_INDEX]
            CURRENT_LANDER_CRASH_FRAME = LANDER_CRASH_ANIMATION[CRASH_ANIMATION_INDEX]
            DT_TIMER_FOR_CRASH_ANIMATION = 0
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "6-out_of_bounds" then

        -- crashed sounds
        MUSIC_SOUND:setVolume((MUSIC_SOUND_BASE_VOL - 0.22) * MASTER_VOLUME_MODIFIER)
        CRASH_PROBLEM_SOUND:setVolume(CRASH_PROBLEM_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)

        function love.keypressed(key)
            -- exit 6-out_of_bounds into 8-loaded by pressing "r" to restart level
            if key == 'r' then
                -- stop huston we have a problem chatter
                CRASH_PROBLEM_SOUND:stop()

                LEVEL_LOADED_FLAG = false

                CURRENT_GAME_STATE = GAME_MANAGER[8]
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "7-score_screen" then

        -- start timer
        DT_TIMER_FOR_SCORE_SCREEN = DT_TIMER_FOR_SCORE_SCREEN + dt

        -- score sounds
        SCORE_SCREEN_MUSIC:setVolume(SCORE_SCREEN_MUSIC_BASE_VOL * MASTER_VOLUME_MODIFIER)
        VICTORY_SMALL_STEP_SOUND:setVolume(VICTORY_SMALL_STEP_SOUND_BASE_VOL * MASTER_VOLUME_MODIFIER)

        -- control the alpha to fade in credits after 3 seconds
        if CREDITS_TEXT_OPACITY[INDEX_FOR_CREDITS_TEXT_OPACITY] < 1  and DT_TIMER_FOR_SCORE_SCREEN > 9 then
            CREDITS_TEXT_OPACITY[INDEX_FOR_CREDITS_TEXT_OPACITY] = CREDITS_TEXT_OPACITY[INDEX_FOR_CREDITS_TEXT_OPACITY] + (dt / 1.9)
        elseif CREDITS_TEXT_OPACITY[INDEX_FOR_CREDITS_TEXT_OPACITY] >= 1 and DT_TIMER_FOR_SCORE_SCREEN > 8 and INDEX_FOR_CREDITS_TEXT_OPACITY < #CREDITS_TEXT_TABLE then
            INDEX_FOR_CREDITS_TEXT_OPACITY = INDEX_FOR_CREDITS_TEXT_OPACITY + 1
        end

        function love.keypressed(key)
            -- exit 7-out_of_bounds quitting the game window with "x"
            if key == 'x' then
                love.event.quit()
            end
        end
    end

-----------------------------------------------------------

    if CURRENT_GAME_STATE == "8-loaded" then
        -- move transition curtain off the screen
        if TRANSITION_CURTAIN.x < SCREEN_X then
            TRANSITION_CURTAIN.x = TRANSITION_CURTAIN.x + dt*1300
        else
            TRANSITION_CURTAIN.flag = false
        end

        -- increase timer for hud fade in
        if DT_TIMER_FOR_LOADED_HUD < 5 then
            DT_TIMER_FOR_LOADED_HUD = DT_TIMER_FOR_LOADED_HUD + dt
        end
        -- fade in hud text after 1 second
        if DT_TIMER_FOR_LOADED_HUD > 0.8 and HUD_TEXT_OPACITY < 1 then
            LOADED_SCREEN_TEXT_OPACITY = LOADED_SCREEN_TEXT_OPACITY + (dt / 1.5)
            HUD_TEXT_OPACITY = HUD_TEXT_OPACITY + (dt / 1.5)
        end

        -- exit 8-loaded into 2-game_play by pressing "space"
        function love.keypressed(key)
            if key == 'space' then
                CURRENT_GAME_STATE = GAME_MANAGER[2]
                -- ensure hud is completely visible
                HUD_TEXT_OPACITY = 1
            end
        end
    end


-----------------------------------------------------------


    if CURRENT_GAME_STATE == "9-splash_screen" then

        -- start timer
        DT_TIMER_FOR_SPLASH_SCREEN = DT_TIMER_FOR_SPLASH_SCREEN + dt

        -- splash screen sounds
        SPLASH_SCREEN_MUSIC:play()
        SPLASH_SCREEN_MUSIC:setVolume(SPLASH_SCREEN_MUSIC_BASE_VOL * MASTER_VOLUME_MODIFIER)

        -- control the alpha to fade in the background after 1.6 seconds
        if SPLASH_SCREEN_BACKGROUND_OPACITY < 1 and DT_TIMER_FOR_SPLASH_SCREEN > 1.6 then
            SPLASH_SCREEN_BACKGROUND_OPACITY = SPLASH_SCREEN_BACKGROUND_OPACITY + (dt / 4)
        end

        -- control the alpha to fade in title text after 3 seconds
        if TITLE_TEXT_OPACITY[INDEX_FOR_OPACITY_TABLE] < 1  and DT_TIMER_FOR_SPLASH_SCREEN > 3 then
            TITLE_TEXT_OPACITY[INDEX_FOR_OPACITY_TABLE] = TITLE_TEXT_OPACITY[INDEX_FOR_OPACITY_TABLE] + (dt * 6.5)
        elseif TITLE_TEXT_OPACITY[INDEX_FOR_OPACITY_TABLE] >= 1 and DT_TIMER_FOR_SPLASH_SCREEN > 3 and INDEX_FOR_OPACITY_TABLE < #TITLE_TEXT_TABLE then
            INDEX_FOR_OPACITY_TABLE = INDEX_FOR_OPACITY_TABLE + 1
        end

        -- control the alpha to fade in text after 5 seconds
        if SPLASH_SCREEN_TEXT_OPACITY < 1 and DT_TIMER_FOR_SPLASH_SCREEN > 9.5 then
            SPLASH_SCREEN_TEXT_OPACITY = SPLASH_SCREEN_TEXT_OPACITY + ( dt / 1.8)
        end

        -- exit 9-splash_screen into 1-tutorial by pressing "space"
        function love.keypressed(key)
            if key == 'space' then
            CURRENT_GAME_STATE = GAME_MANAGER[1]
            end
        end
    end


-----------------------------------------------------------

    -- sound stuff
    -- turn off thruster and alarm sounds if not during 2-game_play state
    if CURRENT_GAME_STATE ~= "2-game_play" then
        INTERACT_THRUSTER_SOUND_EFFECTS("stop")
        FUEL_LOW_ALERT_SOUND:stop()
        FUEL_CRITICAL_ALERT_SOUND:stop()
    end

end


------------------------------------------------------------------------------------------------------------------------------------


function love.draw()

    if CURRENT_GAME_STATE == "1-tutorial" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        TUTORIAL_TEXT.draw()
        TRANSITION_CURTAIN_GRAPHIC.draw()
    end

    if CURRENT_GAME_STATE == "2-game_play" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        THRUSTER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        FUEL_ALERT_TEXT.draw()
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
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        CRASHED_TEXT.draw()
        CRASH_ANIMATION.draw()
    end

    if CURRENT_GAME_STATE == "6-out_of_bounds" then
        HUD_TEXT.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        OUT_OF_BOUNDS_TEXT.draw()
    end

    if CURRENT_GAME_STATE == "7-score_screen" then
        SCORE_SCREEN_BACKGROUND.draw()
        SCORE_SCREEN_TEXT.draw(SCORE)
    end

    if CURRENT_GAME_STATE == "8-loaded" then
        HUD_TEXT.draw()
        LANDER_GRAPHIC.draw()
        LUNAR_SURFACE_GRAPHIC.draw()
        LANDING_ZONE_GRAPHIC.draw()
        LOADED_SCREEN_TEXT.draw()
        TRANSITION_CURTAIN_GRAPHIC.draw()
    end

    if CURRENT_GAME_STATE == "9-splash_screen" then
        SPLASH_SCREEN_BACKGROUND.draw()
        SPLASH_SCREEN_FADE_IN_TITLE.draw()
    end

end