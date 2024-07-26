local tagged = require "tagged"

local Entity = {}
Entity.__index = Entity

function Entity.new(x, y)
    local self = setmetatable({}, Entity)

    tagged.addTag(self, tagged.tags.ENTITY)

    self.x = x
    self.y = y
    self.visible = true

    return self
end

function Entity:zIndex()
    return self.y
end

function Entity:distance(other)
    return math.sqrt((self.x - other.x) ^ 2 + (self.y - other.y) ^ 2)
end

function Entity:isVisible()
    return self.visible
end

function Entity:setVisible(visible)
    self.visible = visible
end

function Entity:update(dt)
end

function Entity:draw()
end

-- for camera, mainly
function Entity:drawEnd()
end

function Entity:remove()
    print("WHAT")
    tagged.removeTag(self, tagged.tags.ENTITY)
end

return Entity
