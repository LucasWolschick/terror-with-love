local Entity         = require "entity"
local tagged         = require "tagged"

local PickableItem   = {}
PickableItem.__index = PickableItem
setmetatable(PickableItem, Entity)

function PickableItem.new(x, y, id, img)
    local self = Entity.new(x, y)
    setmetatable(self, PickableItem)

    tagged.addTag(self, tagged.tags.PICKABLE)

    self.player = nil
    self.id = id
    self.img = love.graphics.newImage(img)
    self.w, self.h = self.img:getDimensions()

    return self
end

function PickableItem:pickable()
    return not self.player
end

function PickableItem:pick(player)
    self.player = player
end

function PickableItem:drop(x, y)
    self.player = nil
    self.x = x
    self.y = y
end

function PickableItem:draw()
    if not self:isVisible() then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    if self.player then
        love.graphics.draw(self.img, math.floor(self.player.x - self.w / 2), math.floor(self.player.y - self.h), 0, 1, 1)
    else
        love.graphics.draw(self.img, math.floor(self.x - self.w / 2), math.floor(self.y - self.h), 0, 1, 1)
    end
end

function PickableItem:zIndex()
    if self.player then
        return self.player:zIndex() + 1
    else
        return self.y
    end
end

function PickableItem:remove()
    tagged.removeTag(self, tagged.tags.PICKABLE)
    Entity.remove(self)
end

return PickableItem
