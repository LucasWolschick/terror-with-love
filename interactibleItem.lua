local Entity             = require "entity"
local tagged             = require "tagged"

local InteractibleItem   = {}
InteractibleItem.__index = InteractibleItem
setmetatable(InteractibleItem, Entity)

function InteractibleItem.new(x, y, id, img)
    local self = Entity.new(x, y)
    setmetatable(self, InteractibleItem)

    tagged.addTag(self, tagged.tags.INTERACTIBLE)

    self.img = love.graphics.newImage(img)
    self.id = id

    return self
end

function InteractibleItem:setImage(img)
    self.img = love.graphics.newImage(img)
end

function InteractibleItem:interact()
end

function InteractibleItem:interactRadius()
    return 50
end

function InteractibleItem:draw()
    if not self:isVisible() then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, math.floor(self.x - self.img:getWidth() / 2), math.floor(self.y - self.img:getHeight()),
        0, 1, 1)
end

function InteractibleItem:remove()
    tagged.removeTag(self, tagged.tags.INTERACTIBLE)
    Entity.remove(self)
end

return InteractibleItem
