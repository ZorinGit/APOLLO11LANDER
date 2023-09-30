function love.load()
    -- set resolution
    love.window.setMode(1280, 800)

    -- set lander properties 
    LANDER = {}
    LANDER.x = 640
    LANDER.y = 40
    LANDER.mass_kg = 15200
    LUNAR_GRAVITY_FORCE_NPERKG = 1.6
    LANDER.lunar_force_N = LANDER.mass_kg * LUNAR_GRAVITY_FORCE_NPERKG
    LUNAR_ACCELERATION = LANDER.lunar_force_N / LANDER.mass_kg
    LANDER.velocity = 0

    START_TIME = love.timer.getTime()
end

function love.update(dt)
    ELAPSED_TIME = love.timer.getTime() - START_TIME
    -- lander is falling
    LANDER.velocity = LANDER.velocity + LUNAR_ACCELERATION * dt
    LANDER.y = LANDER.y + LANDER.velocity * dt

    -- up trust
    if love.keyboard.isDown("s") then
        LANDER.y = LANDER.y - 60 * dt
    end
end

function love.draw()
    -- displayed variables
    local y_location = 1205
    local x_location = 10
    love.graphics.print("Ypos: " .. math.floor(LANDER.y), y_location, x_location)
    love.graphics.print("Xpos: " .. math.floor(LANDER.x), y_location, x_location + 15)
    love.graphics.print("Lvel: " .. math.floor(LANDER.velocity), y_location, x_location + 30)
    love.graphics.print("Time: " .. math.floor(ELAPSED_TIME), y_location, x_location + 45)

    -- draw lander
    love.graphics.circle("fill", LANDER.x, LANDER.y, 15)
end