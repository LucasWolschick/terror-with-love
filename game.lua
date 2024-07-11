local bgImage      = love.graphics.newImage("assets/bg.png")

local Player       = require "player"
local PickableItem = require "pickableItem"
local tagged       = require "tagged"

local Game         = {}
Game.__index       = Game

function Game.new()
    local self = setmetatable({}, Game)

    Player.new(100, 100)
    PickableItem.new(100, 100, "ball", "assets/thing.png")

    return self
end

function Game:update(dt)
    for _, object in ipairs(tagged.getTagged(tagged.tags.ENTITY)) do
        object:update(dt)
    end

    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function Game:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(bgImage, 0, 0, 0, 1, 1)

    local drawQueue = {}
    for _, object in ipairs(tagged.getTagged(tagged.tags.ENTITY)) do
        table.insert(drawQueue, object)
    end
    table.sort(drawQueue, function(a, b)
        return a:zIndex() < b:zIndex()
    end)
    for _, object in ipairs(drawQueue) do
        object:draw()
    end
end

return Game
