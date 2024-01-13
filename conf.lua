function love.conf(t)
    -- basic settings
    t.window.title = "APOLLO 11 LANDER"
    t.window.width = 1280
    t.window.height = 800

    -- for testing
    -- t.console = true

    -- disable stuff that is not needed for the game
    t.accelerometerjoystick = false
    t.audio.mixwithsystem = false
    t.window.icon = 'sprites/lander_mk2/Lander_A1.png'
    t.modules.joystick = false
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
end