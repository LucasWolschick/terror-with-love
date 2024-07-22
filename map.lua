local sti     = require "lib.sti"
local Collide = require "collide"

local Entity  = require "entity"
local tagged  = require "tagged"

local Map     = {}
Map.__index   = Map
setmetatable(Map, Entity)

local function rotate(t, theta)
    -- move vertices to origin
    local x1 = t.x1 - t.x1
    local y1 = t.y1 - t.y1
    local x2 = t.x2 - t.x1
    local y2 = t.y2 - t.y1

    -- rotate vertices
    local x1r = x1 * math.cos(theta) - y1 * math.sin(theta)
    local y1r = x1 * math.sin(theta) + y1 * math.cos(theta)
    local x2r = x2 * math.cos(theta) - y2 * math.sin(theta)
    local y2r = x2 * math.sin(theta) + y2 * math.cos(theta)

    -- move vertices back
    x1r = x1r + t.x1
    y1r = y1r + t.y1
    x2r = x2r + t.x1
    y2r = y2r + t.y1

    -- calc new top left and bottom right
    x1 = math.min(x1r, x2r)
    y1 = math.min(y1r, y2r)
    x2 = math.max(x1r, x2r)
    y2 = math.max(y1r, y2r)

    return { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function Map.new()
    local self = Entity.new(0, 0)
    setmetatable(self, Map)

    self.map = sti("assets/map/map.lua", {}, 0, 0)

    self.walls = {}
    for _, object in pairs(self.map.layers["walls"].objects) do
        local t = rotate({
            x1 = object.x,
            y1 = object.y,
            x2 = object.x + object.width,
            y2 = object.y + object.height
        }, math.rad(object.rotation))
        table.insert(self.walls, t)
    end

    self.cameraBoxes = {}
    for _, object in pairs(self.map.layers["cameras"].objects) do
        local t = rotate({
            x1 = object.x,
            y1 = object.y,
            x2 = object.x + object.width,
            y2 = object.y + object.height
        }, math.rad(object.rotation))
        table.insert(self.cameraBoxes, t)
    end

    self.rooms = {}
    for _, object in pairs(self.map.layers["rooms"].objects) do
        local t = rotate({
            x1 = object.x,
            y1 = object.y,
            x2 = object.x + object.width,
            y2 = object.y + object.height
        }, math.rad(object.rotation))
        table.insert(self.rooms, t)
    end

    tagged.addTag(self, tagged.tags.MAP)

    return self
end

function Map:resolveCollision(rect)
    local dx, dy = 0, 0
    local collided = false

    for _, wall in ipairs(self.walls) do
        local collides, x, y = Collide.resolveAabb(rect, wall)
        collided = collided or collides
        dx = dx + x
        dy = dy + y
        rect.x1 = rect.x1 + x
        rect.y1 = rect.y1 + y
        rect.x2 = rect.x2 + x
        rect.y2 = rect.y2 + y
    end

    return collided, dx, dy
end

function Map:zIndex()
    return -1e12
end

function Map:draw()
    love.graphics.setColor(1, 1, 1, 1)

    local camera = tagged.getFirstTagged(tagged.tags.CAMERA)
    assert(camera, "cant draw map without camera")

    self.map:drawTileLayer(self.map.layers["ground"])
end

function Map:remove()
    tagged.removeTag(self, tagged.tags.MAP)
    Entity.remove(self)
end

return Map
