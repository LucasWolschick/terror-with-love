local Entity = require "entity"
local Ambience = {}
Ambience.__index = Ambience
setmetatable(Ambience, Entity)

function Ambience.new()
    local self = Entity.new(0, 0)

    self.ambience = love.audio.newSource("assets/sounds/drone.ogg", "stream")
    self.ambience:setLooping(true)
    self.ambience:setRelative(true)
    love.audio.play(self.ambience)

    setmetatable(self, Ambience)
    return self
end

function Ambience:remove()
    Entity.remove(self)
    love.audio.stop(self.ambience)
end

return Ambience
