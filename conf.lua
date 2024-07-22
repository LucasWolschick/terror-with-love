WIDTH = 640
HEIGHT = 400
SCALE = 2
UPDATE_TIME = 1 / 60

function love.conf(t)
    t.window.width = WIDTH * SCALE
    t.window.height = HEIGHT * SCALE
    t.window.title = "Terror no Escuro"
    t.console = true
end
