local Game = require "game"
local tagged = require "tagged"

local game
local canvas = love.graphics.newCanvas(WIDTH, HEIGHT)

function love.load()
    canvas:setFilter("nearest", "nearest")
    game = Game.new()
end

local updateAccum = 0
function love.update(dt)
    updateAccum = updateAccum + dt

    while updateAccum >= UPDATE_TIME do
        game:update(UPDATE_TIME)
        updateAccum = updateAccum - UPDATE_TIME
    end
end

function love.draw()
    love.graphics.clear()

    love.graphics.setCanvas(canvas)
    game:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, 0, 0, 0, SCALE, SCALE)
end
