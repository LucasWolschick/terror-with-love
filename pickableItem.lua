local Entity         = require "entity"
local tagged         = require "tagged"

local PickableItem   = {}
PickableItem.__index = PickableItem
setmetatable(PickableItem, Entity)

function PickableItem.new(x, y, id, img)
    local self = Entity.new(x, y)
    setmetatable(self, PickableItem)

    tagged.addTag(self, tagged.tags.PICKABLE)

    self.holder = nil
    self.id = id
    self.img = love.graphics.newImage(img)
    self.w, self.h = self.img:getDimensions()

    return self
end

function PickableItem:pickable()
    return not self.holder or not tagged.hasTag(self.holder, tagged.tags.PLAYER)
end

function PickableItem:pick(holder)
    self.holder = holder
    self.x = holder.x
    self.y = holder.y
end

function PickableItem:drop(x, y)
    self.holder = nil
    self.x = x
    self.y = y
end

function PickableItem:draw()
    if not self:isVisible() then
        return
    end

    if self.holder then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, math.floor(self.x - self.w / 2), math.floor(self.y - self.h), 0, 1, 1)
end

function PickableItem:drawHeld(x, y)
    if not self:isVisible() then
        return
    end

    if not self.holder then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, math.floor(x - self.w / 2), math.floor(y - self.h), 0, 1, 1)
end

function PickableItem:zIndex()
    if self.holder then
        return self.holder:zIndex() + 1
    else
        return self.y
    end
end

function PickableItem:remove()
    tagged.removeTag(self, tagged.tags.PICKABLE)
    Entity.remove(self)
end

return PickableItem
