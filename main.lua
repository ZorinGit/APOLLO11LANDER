function love.load()
    -- set resolution
    love.window.setMode(1280, 800)

    -- set lunar properties
    LUNAR = {}
    LUNAR.gravity_force_N_per_kg = 1.6

    -- set lander properties 
    LANDER = {}
    LANDER.mass_kg = 15103
    LANDER.fuel_s = 120
    --test
    -- LANDER.fuel_s =20

    -- y axis lander variables 
    LANDER.y = 40
    -- testing
    -- LANDER.y = 700
    LANDER.y_velocity = 0
    LANDER.y_only_lunar_force_N = LANDER.mass_kg * LUNAR.gravity_force_N_per_kg
    LANDER.y_only_lunar_force_acceleration = LANDER.y_only_lunar_force_N / LANDER.mass_kg
    LANDER.y_thruster = false
    LANDER.y_only_thruster_force_N = - 45000
    LANDER.y_total_thruster_and_lunar_force_N = LANDER.y_only_lunar_force_N + LANDER.y_only_thruster_force_N
    LANDER.y_total_thruster_and_lunar_acceleration = tonumber(string.format("%.2f", (LANDER.y_total_thruster_and_lunar_force_N / LANDER.mass_kg)))

    -- x axis lander variables
    LANDER.x = 200
    -- testing
    -- LANDER.x = 1102
    LANDER.x_velocity = 0
    LANDER.x_thruster = 0
    LANDER.x_thruster_force_N = 7200
    LANDER.x_thruster_acceleration = tonumber(string.format("%.2f", (LANDER.x_thruster_force_N / LANDER.mass_kg)))

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

    COLLISION_FLAG = false

    -- landing line points
    LANDING_SURFACE_LINE_POINTS = {1100, 748, 1135, 748}

    LANDING_FLAG = false

    OUT_OF_BOUNDS_FLAG = false

    -- for timer
    START_TIME = love.timer.getTime()
    -- counter to reduce the frequency of collision checks
    COLLISION_FREQUENCY_COUNTER = 0
end


function love.update(dt)

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
    if LANDING_FLAG == false then
        LANDER.y = LANDER.y + LANDER.y_velocity * dt
    end


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
    if LANDING_FLAG == false then
        LANDER.x = LANDER.x + LANDER.x_velocity * dt
    end


    -- update lander collision pixels
    LANDER_COLLISION_PIXELS = {
        {x = math.floor(LANDER.x + 1) , y = math.floor(LANDER.y + 1)}, -- upper left
        {x = math.floor(LANDER.x + 25) , y = math.floor(LANDER.y + 1)}, -- upper right
        {x = math.floor(LANDER.x + 1), y = math.floor(LANDER.y + 25)}, -- lower left
        {x = math.floor(LANDER.x + 25), y = math.floor(LANDER.y + 25)} -- lover right
    }

    -- tests for updated collision pixels
    -- for i, point in ipairs(LANDER_COLLISION_PIXELS) do
    --     print("Point "..i..": x = "..point.x..", y = "..point.y)
    -- end
    -- for i = 1, 4 do
    --     for k , v in pairs(LANDER_COLLISION_PIXELS[i]) do
    --         print(k, v)
    --     end
    -- end

    -- collision check and counter used to reduce the check frequency to 50 times a second for a smoother game
    COLLISION_FREQUENCY_COUNTER = COLLISION_FREQUENCY_COUNTER + dt
    if COLLISION_FREQUENCY_COUNTER > 0.02 then
        for i = 3, #LANDER_COLLISION_PIXELS do
            for j = 1, #LINE_COLLISION_PIXELS do
                if LANDER_COLLISION_PIXELS[i]["x"] == LINE_COLLISION_PIXELS[j]["x"] and LANDER_COLLISION_PIXELS[i]["y"] == LINE_COLLISION_PIXELS[j]["y"] then
                    COLLISION_FLAG = true
                    print("***COLLISION***")
                end
            end
        end
        COLLISION_FREQUENCY_COUNTER = 0
    end


    -- landing check
    -- check lower left lander collision pixel against the y landing level
    if LANDER_COLLISION_PIXELS[3]["y"] == LANDING_SURFACE_LINE_POINTS[2] and
        -- check left and right lander collision pixels against landing pad
        LANDER_COLLISION_PIXELS[3]["x"] >= LANDING_SURFACE_LINE_POINTS[1] and
        LANDER_COLLISION_PIXELS[4]["x"] <= LANDING_SURFACE_LINE_POINTS[3] and
        -- check x and y velocity for acceptable levels
        LANDER.y_velocity < 3 and LANDER.x_velocity < 1.5 then
        -- change landing flag to true
        LANDING_FLAG = true
        print("***LANDED***")
    end

    -- out of bounds check 
    -- check lower left lander collision pixel against  top bounds of map using Y
    if LANDER_COLLISION_PIXELS[3]["y"] < 0 or
        -- check lower right lander collision against left bounds of map using X
        LANDER_COLLISION_PIXELS[4]["x"] < 0 or
        -- check lower left lander collision against right bounds of the map using X
        LANDER_COLLISION_PIXELS[3]["x"] > 1280 then
        OUT_OF_BOUNDS_FLAG = true
        print("***OUT OF BOUNDS***")
    end


    -- check lander parameters by pressing p
    function love.keypressed(key)
        if key == "p" then
            for k, v in pairs(LANDER) do
                print(k, v)
            end
        end
    end

    -- for timer
    ELAPSED_TIME = love.timer.getTime() - START_TIME
end


function love.draw()

    if COLLISION_FLAG == false then
        -- displayed variables on the right corner
        local y_location = 1205
        local x_location = 10
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Ypos: " .. math.floor(LANDER.y), y_location, x_location)
        love.graphics.print("Xpos: " .. math.floor(LANDER.x), y_location, x_location + 15)
        love.graphics.print("Yvel: " .. math.floor(LANDER.y_velocity), y_location, x_location + 30)
        love.graphics.print("Xvel: " .. math.floor(LANDER.x_velocity), y_location, x_location + 45)
        love.graphics.print("Time: " .. math.floor(ELAPSED_TIME), y_location, x_location + 60)
        love.graphics.print("Fuel: " .. math.floor(LANDER.fuel_s), y_location, x_location + 75)

        -- draw lander
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", LANDER.x, LANDER.y, 25, 25)
    end

    -- lander collision pixels drawn
    love.graphics.setColor(255, 0, 0)
    love.graphics.points(LANDER_COLLISION_PIXELS[1]["x"], LANDER_COLLISION_PIXELS[1]["y"])
    love.graphics.points(LANDER_COLLISION_PIXELS[2]["x"], LANDER_COLLISION_PIXELS[2]["y"])
    love.graphics.points(LANDER_COLLISION_PIXELS[3]["x"], LANDER_COLLISION_PIXELS[3]["y"])
    love.graphics.points(LANDER_COLLISION_PIXELS[4]["x"], LANDER_COLLISION_PIXELS[4]["y"])


    -- draw lunar surface
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.setLineWidth(3)
    love.graphics.line(SURFACE_LINE_POINTS)

    -- draw landing zone
    love.graphics.setColor(0.90, 0.90, 0.90)
    love.graphics.setLineWidth(2)
    love.graphics.line(LANDING_SURFACE_LINE_POINTS)



end