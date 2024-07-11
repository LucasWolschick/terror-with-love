local Entity = require "entity"

local Room = {}
Room.__index = Room
setmetatable(Room, Entity)

function Room.new()
    local self = Entity.new(0, 0)
    setmetatable(self, Room)

    self.bgImage = love.graphics.newImage("assets/bg.png")

    return self
end

function Room:zIndex()
    return -1e12
end

function Room:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.bgImage, 0, 0, 0, 1, 1)
end

return Room
