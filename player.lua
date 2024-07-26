local Entity = require "entity"
local tagged = require "tagged"
local sounds = require "sounds"

local Player = {}
Player.__index = Player
setmetatable(Player, Entity)

local images = {
    down = {
        id = "down",
        img = love.graphics.newImage("assets/player-front.png"),
        item_offset = { x = 44, y = 85 },
        item_z = "front"
    },
    up = {
        id = "up",
        img = love.graphics.newImage("assets/player-back.png"),
        item_offset = { x = 16, y = 85 },
        item_z = "back"
    },
    left = {
        id = "left",
        img = love.graphics.newImage("assets/player-left.png"),
        item_offset = { x = 40, y = 83 },
        item_z = "front"
    },
    right = {
        id = "right",
        img = love.graphics.newImage("assets/player-right.png"),
        item_offset = { x = 40, y = 83 },
        item_z = "back"
    }
}

function Player.new(x, y)
    local self = Entity.new(x, y)
    setmetatable(self, Player)

    tagged.addTag(self, tagged.tags.PLAYER)

    self.w, self.h = images.up.img:getDimensions()
    self.speed = 128
    self.carrying = nil
    self.lastDirection = { x = 0, y = 1 }
    self.soundTimer = 0
    self.img = images.up

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

    local STEP_DELAY = 0.75

    local mag = math.sqrt(dx * dx + dy * dy)
    if mag > 0 then
        dx = dx / mag
        dy = dy / mag

        self.lastDirection = { x = dx, y = dy }

        if dx > 0 then
            self.img = images.right
        elseif dx < 0 then
            self.img = images.left
        elseif dy > 0 then
            self.img = images.down
        elseif dy < 0 then
            self.img = images.up
        end
    else
        self.soundTimer = STEP_DELAY / 2
    end

    local spd = self.speed * modifier
    local newX = self.x + dx * spd * dt
    local newY = self.y + dy * spd * dt


    for _, map in ipairs(tagged.getTagged(tagged.tags.MAP)) do
        local collided, dx, dy = map:resolveCollision(
            { x1 = newX - 16, y1 = newY - 20, x2 = newX + 16, y2 = newY })
        if collided then
            newX = newX + dx
            newY = newY + dy
        end
    end

    self.x = newX
    self.y = newY

    self.soundTimer = self.soundTimer + dt * modifier
    if self.soundTimer > STEP_DELAY then
        sounds.playAtRelative(sounds.sounds.PLR_STEP, self.x, self.y)
        self.soundTimer = 0
    end
    sounds.setListeningPosition(self.x, self.y)
end

function Player:dropCarriedItem()
    -- query world for a receptacle
    local receptacles = tagged.getTagged(tagged.tags.RECEPTACLE)
    local nearest, distance = nil, 32
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

    sounds.playAtRelative(sounds.sounds.DROP, self.x, self.y)
end

function Player:pickItem(item)
    if item.holder then
        -- the holder must be a receptacle if we got here
        -- unset the item from the holder
        item.holder:setItem(nil)
    end
    sounds.playAtRelative(sounds.sounds.PICK_UP, self.x, self.y)
    item:pick(self)
    self.carrying = item
end

function Player:getDirection()
    return self.lastDirection
end

function Player:carriedItemUpdate(dt)
    -- pick up/drop an item
    if not self.carrying then
        local pickables = tagged.getTagged(tagged.tags.PICKABLE)
        local nearest, distance = nil, 48
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

function Player:victoryTriggerUpdate(dt)
    local game = assert(tagged.getFirstTagged(tagged.tags.GAME))

    if game:getProgress() == 7 and self:distance({ x = 1000, y = 2000, }) < 100 then
        game:changeState("victory")
    end
end

function Player:update(dt)
    if not self:isVisible() then
        return
    end

    self:moveUpdate(dt)
    self:carriedItemUpdate(dt)
    self:victoryTriggerUpdate(dt)
    self.eWasPressed = love.keyboard.isDown("e")
end

function Player:draw()
    if not self:isVisible() then
        return
    end

    if self.carrying and self.img.item_z == "back" then
        local offset = self.img.item_offset
        love.graphics.setColor(1, 1, 1, 1)
        self.carrying:drawHeld(self.x - self.w / 2 + offset.x, self.y - self.h + offset.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img.img, math.floor(self.x - self.w / 2), math.floor(self.y - self.h), 0, 1, 1)

    if self.carrying and self.img.item_z == "front" then
        local offset = self.img.item_offset
        love.graphics.setColor(1, 1, 1, 1)
        self.carrying:drawHeld(self.x - self.w / 2 + offset.x, self.y - self.h + offset.y)
    end
end

function Player:remove()
    tagged.removeTag(self, tagged.tags.PLAYER)
    Entity.remove(self)
end

return Player
