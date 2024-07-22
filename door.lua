local Entity  = require "entity"
local collide = require "collide"
local tagged  = require "tagged"
local Door    = {}
Door.__index  = Door
setmetatable(Door, Entity)

function Door.new(id, x, y, w, h)
    local self = Entity.new(x, y)
    setmetatable(self, Door)

    tagged.addTag(self, tagged.tags.DOOR)

    self.id = id
    self.w = w
    self.h = h

    return self
end

function Door:open()
    self:setVisible(false)
end

function Door:close()
    self:setVisible(true)
end

function Door:collide(rect)
    if self:isVisible() then
        local collided, dx, dy = collide.resolveAabb(rect, {
            x1 = self.x,
            y1 = self.y,
            x2 = self.x + self.w,
            y2 = self.y + self.h
        })
        return collided, dx, dy
    end
    return false, 0, 0
end

function Door:draw()
    if not self:isVisible() then
        return
    end

    -- set brown color
    love.graphics.setColor(0.5, 0.3, 0.1, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Door:remove()
    tagged.removeTag(self, tagged.tags.DOOR)
    Entity.remove(self)
end

return Door
