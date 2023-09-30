function love.load()
    LANDER = {}
    LANDER.x = 400
    LANDER.y = 40
end

function love.update(dt)
    -- lander if falling
    LANDER.y = LANDER.y + 50 * dt

    -- up trust
    if love.keyboard.isDown("s") then
        LANDER.y = LANDER.y - 60 * dt
    end
end

function love.draw()
    -- draw lander
    love.graphics.circle("fill", LANDER.x, LANDER.y, 20)
end