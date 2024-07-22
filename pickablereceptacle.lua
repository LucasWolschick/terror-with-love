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
    if self.holding then
        love.graphics.setColor(0, 1, 0, 1)
    else
        love.graphics.setColor(1, 1, 0, 1)
    end
    love.graphics.rectangle("line", self.x - 16, self.y - 16, 32, 32)
end

return PickableReceptacle
