local InteractibleItem = require "interactibleItem"
local tagged = require "tagged"
local Entity = require "entity"

local PickableReceptacle = {}
PickableReceptacle.__index = PickableReceptacle
setmetatable(PickableReceptacle, Entity)

function PickableReceptacle.new(x, y, id)
    local self = Entity.new(x, y)
    setmetatable(self, PickableReceptacle)

    self.id = id
    self.holding = nil

    tagged.addTag(self, tagged.tags.RECEPTACLE)

    return self
end

function PickableReceptacle:getItem()
    return self.holding
end

function PickableReceptacle:setItem(item)
    self.holding = item
end

function PickableReceptacle:draw()
    if not self:isVisible() then
        return
    end
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", self.x, self.y, 16)

    if self.holding then
        love.graphics.setColor(1, 1, 1, 1)
        self.holding:drawHeld(self.x, self.y)
    end
end

return PickableReceptacle
