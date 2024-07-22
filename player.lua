local Entity = require "entity"
local tagged = require "tagged"
local plrImage = love.graphics.newImage("assets/player.png")

local Player = {}
Player.__index = Player
setmetatable(Player, Entity)

function Player.new(x, y)
    local self = Entity.new(x, y)
    setmetatable(self, Player)

    tagged.addTag(self, tagged.tags.PLAYER)

    self.w, self.h = plrImage:getDimensions()
    self.speed = 100
    self.carrying = nil

    self.eWasPressed = false

    return self
end

function Player:moveUpdate(dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown("left", "a") then
        dx = dx - 1
    end
    if love.keyboard.isDown("right", "d") then
        dx = dx + 1
    end
    if love.keyboard.isDown("up", "w") then
        dy = dy - 1
    end
    if love.keyboard.isDown("down", "s") then
        dy = dy + 1
    end

    local modifier = 1
    if self.carrying then
        modifier = 0.75
    elseif love.keyboard.isDown("lshift", "rshift") then
        modifier = 2
    end

    local mag = math.sqrt(dx * dx + dy * dy)
    if mag > 0 then
        dx = dx / mag
        dy = dy / mag
    end

    local spd = self.speed * modifier

    self.x = self.x + dx * spd * dt
    self.y = self.y + dy * spd * dt
end

function Player:dropCarriedItem()
    -- query world for a receptacle
    local receptacles = tagged.getTagged(tagged.tags.RECEPTACLE)
    local nearest, distance = nil, 10
    for _, receptacle in ipairs(receptacles) do
        local d = self:distance(receptacle)
        if not receptacle:getItem() and d < distance then
            nearest, distance = receptacle, d
        end
    end

    if nearest then
        nearest:setItem(self.carrying)
        self.carrying:pick(nearest)
        self.carrying = nil
    else
        self.carrying:drop(self.x, self.y)
        self.carrying = nil
    end
end

function Player:pickItem(item)
    if item.holder then
        -- the holder must be a receptacle if we got here
        -- unset the item from the holder
        item.holder:setItem(nil)
    end
    item:pick(self)
    self.carrying = item
end

function Player:carriedItemUpdate(dt)
    -- pick up/drop an item
    if not self.carrying then
        local pickables = tagged.getTagged(tagged.tags.PICKABLE)
        local nearest, distance = nil, 10
        for _, pickable in ipairs(pickables) do
            local d = self:distance(pickable)
            if pickable:pickable() and d < distance then
                nearest, distance = pickable, d
            end
        end

        if nearest and love.keyboard.isDown("e") and not self.eWasPressed then
            self:pickItem(nearest)
        end
    else
        if love.keyboard.isDown("e") and not self.eWasPressed then
            -- drop the item
            self:dropCarriedItem()
        end
    end

    -- interact with an item
    if not self.carrying then
        local interactibles = tagged.getTagged(tagged.tags.INTERACTIBLE)
        for _, interactible in ipairs(interactibles) do
            if self:distance(interactible) < interactible:interactRadius() and love.keyboard.isDown("e") and not self.eWasPressed then
                interactible:interact()
                break
            end
        end
    end
end

function Player:update(dt)
    if not self:isVisible() then
        return
    end

    self:moveUpdate(dt)
    self:carriedItemUpdate(dt)
    self.eWasPressed = love.keyboard.isDown("e")
end

function Player:draw()
    if not self:isVisible() then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(plrImage, math.floor(self.x - self.w / 2), math.floor(self.y - self.h), 0, 1, 1)
end

function Player:remove()
    tagged.removeTag(self, tagged.tags.PLAYER)
    Entity.remove(self)
end

return Player
