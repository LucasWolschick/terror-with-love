WIDTH = 320
HEIGHT = 240
SCALE = 2
UPDATE_TIME = 1 / 60

function love.conf(t)
    t.window.width = WIDTH * SCALE
    t.window.height = HEIGHT * SCALE
end
