local Entity             = require "entity"
local tagged             = require "tagged"

local InteractibleItem   = {}
InteractibleItem.__index = InteractibleItem
setmetatable(InteractibleItem, Entity)

function InteractibleItem.new(x, y, id)
    local self = Entity.new(x, y)
    setmetatable(self, InteractibleItem)

    tagged.addTag(self, tagged.tags.INTERACTIBLE)

    self.id = id

    return self
end

function InteractibleItem:interact()
end

function InteractibleItem:interactRadius()
    return 50
end

function InteractibleItem:remove()
    tagged.removeTag(self, tagged.tags.INTERACTIBLE)
    Entity.remove(self)
end

return InteractibleItem
