local Player             = require "player"
local PickableItem       = require "pickableItem"
local tagged             = require "tagged"
local InteractibleItem   = require "interactibleItem"
local Camera             = require "camera"
local Room               = require "room"
local PickableReceptacle = require "pickablereceptacle"

local Game               = {}
Game.__index             = Game

function Game.new()
    local self = setmetatable({}, Game)

    Camera.new()
    Room.new()
    Player.new(100, 100)
    PickableItem.new(100, 100, "ball", "assets/thing.png")
    PickableReceptacle.new(200, 200, "receptacle")

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
    love.graphics.clear(0, 0, 0, 1)

    local drawQueue = {}
    for _, object in ipairs(tagged.getTagged(tagged.tags.ENTITY)) do
        table.insert(drawQueue, object)
    end
    table.sort(drawQueue, function(a, b)
        return a:zIndex() < b:zIndex()
    end)
    for i = 1, #drawQueue do
        local object = drawQueue[i]
        object:draw()
    end
    for i = #drawQueue, 1, -1 do
        local object = drawQueue[i]
        object:drawEnd()
    end
end

return Game
