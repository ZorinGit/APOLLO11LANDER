function love.load()
    -- set resolution
    love.window.setMode(1280, 800)

    -- set lunar properties
    LUNAR = {}
    LUNAR.gravity_force_N_per_kg = 1.6

    -- set lander properties 
    LANDER = {}
    LANDER.mass_kg = 15103

    -- y axis lander variables 
    LANDER.y = 40
    LANDER.y_velocity = 0
    LANDER.y_only_lunar_force_N = LANDER.mass_kg * LUNAR.gravity_force_N_per_kg
    LANDER.y_only_lunar_force_acceleration = LANDER.y_only_lunar_force_N / LANDER.mass_kg
    LANDER.y_thruster = false
    LANDER.y_only_thruster_force_N = - 45000
    LANDER.y_total_thruster_and_lunar_force_N = LANDER.y_only_lunar_force_N + LANDER.y_only_thruster_force_N
    LANDER.y_total_thruster_and_lunar_acceleration = tonumber(string.format("%.2f", (LANDER.y_total_thruster_and_lunar_force_N / LANDER.mass_kg)))

    -- x axis lander variables
    LANDER.x = 640
    LANDER.x_velocity = 0

    -- for timer
    START_TIME = love.timer.getTime()

end


function love.update(dt)

    -- y axis trusters and acceleration
    LANDER.y_thruster = false
    if love.keyboard.isDown("s") then
        LANDER.y_thruster = true
    end

    if LANDER.y_thruster == false then
        LANDER.y_velocity = LANDER.y_velocity + LANDER.y_only_lunar_force_acceleration * dt
    elseif LANDER.y_thruster == true then
        LANDER.y_velocity = LANDER.y_velocity + LANDER.y_total_thruster_and_lunar_acceleration * dt
    end

    -- y axis lander movement
    LANDER.y = LANDER.y + LANDER.y_velocity * dt



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
    -- displayed variables on the right corner
    local y_location = 1205
    local x_location = 10
    love.graphics.print("Ypos: " .. math.floor(LANDER.y), y_location, x_location)
    love.graphics.print("Xpos: " .. math.floor(LANDER.x), y_location, x_location + 15)
    love.graphics.print("Yvel: " .. math.floor(LANDER.y_velocity), y_location, x_location + 30)
    love.graphics.print("Time: " .. math.floor(ELAPSED_TIME), y_location, x_location + 45)

    -- draw lander
    love.graphics.circle("fill", LANDER.x, LANDER.y, 15)
end