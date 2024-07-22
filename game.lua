local Player = require "player"
local tagged = require "tagged"
local Camera = require "camera"
local Map    = require "map"
local Hud    = require "hud"

local Game   = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)

    Map.new()
    Player.new(1024, 1860)
    Camera.new(1024 - WIDTH / 2, 1860 - HEIGHT / 2)

    self.hud = Hud.new()
    self.progress = 0

    tagged.addTag(self, tagged.tags.GAME)

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

function Game:setProgress(progress)
    self.progress = progress
end

function Game:getProgress()
    return self.progress
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

    self.hud:draw(self)
end

return Game
