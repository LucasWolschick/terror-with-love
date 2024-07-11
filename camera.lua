local Entity = require "entity"
local tagged = require "tagged"

local PADDING = 5
local MARGIN = 50

local function clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end

local Camera = {}
Camera.__index = Camera
setmetatable(Camera, Entity)

--[[
    CAMERA BOXES:


    +-----------------+  +-----------+
    |           x=====x  |           |
    |           [     $--+-x=====x---+--+
    |           [     ]    [     ]      |
    |           [   P ]    [  P  ]      |
    +-----------x=====x    [     ]      |
                      +----x=====x------+

    Camera boxes are regions of the screen which the camera gets restricted to.
    The active camera box is the one that the player is currently in.
    The camera will not move outside of the active camera box, but it will try to
    center the player in the box.

    The camera box is defined by the top left corner and the bottom right corner, and
    is defined in world coordinates.

    The camera starts with no camera box, and is free.
    When the player enters a camera box, it is marked active.
    When the player leaves the camera box, it looks for the next camera box to enter.
    If there is no camera box to enter, the camera is free again.
]]
function Camera.new()
    local self = Entity.new(0, 0)
    setmetatable(self, Camera)

    self.boxes = {
        { x1 = 0,   y1 = 0,   x2 = 500, y2 = 500 },
        { x1 = 500, y1 = 0,   x2 = 600, y2 = 700 },
        { x1 = 0,   y1 = 500, x2 = 500, y2 = 700 },
        { x1 = 0,   y1 = -50, x2 = 500, y2 = 0 },
    }
    self.activeBox = nil

    return self
end

function Camera:zIndex()
    return -math.huge
end

function Camera:update(dt)
    local tgtX = self.x
    local tgtY = self.y

    local plr = tagged.getFirstTagged(tagged.tags.PLAYER)
    if plr then
        if self.activeBox then
            -- check if we're still inside)
            if plr.x < self.activeBox.x1 - PADDING or plr.x > self.activeBox.x2 + PADDING or
                plr.y < self.activeBox.y1 - PADDING or plr.y > self.activeBox.y2 + PADDING then
                self.activeBox = nil
            end
        end

        if not self.activeBox then
            for _, box in ipairs(self.boxes) do
                if plr.x >= box.x1 and plr.x <= box.x2 and
                    plr.y >= box.y1 and plr.y <= box.y2 then
                    self.activeBox = box
                    break
                end
            end
        end

        if self.activeBox then
            local x1, y1, x2, y2 = self.activeBox.x1, self.activeBox.y1, self.activeBox.x2, self.activeBox.y2
            -- add some padding
            x1 = x1 - MARGIN
            y1 = y1 - MARGIN
            x2 = x2 + MARGIN
            y2 = y2 + MARGIN

            local boxWidth = x2 - x1
            local boxHeight = y2 - y1

            local tgtCenterX, tgtCenterY = plr.x, plr.y
            if boxWidth < WIDTH then
                tgtCenterX = x1 + boxWidth / 2
            else
                tgtCenterX = clamp(tgtCenterX, x1 + WIDTH / 2, x2 - WIDTH / 2)
            end

            if boxHeight < HEIGHT then
                tgtCenterY = y1 + boxHeight / 2
            else
                tgtCenterY = clamp(tgtCenterY, y1 + HEIGHT / 2, y2 - HEIGHT / 2)
            end

            tgtX = tgtCenterX - WIDTH / 2
            tgtY = tgtCenterY - HEIGHT / 2
        else -- free camera
            tgtX = plr.x - WIDTH / 2
            tgtY = plr.y - plr.h / 2 - HEIGHT / 2
        end
    end

    local t = 10 * dt
    self.x = t * (tgtX) + (1 - t) * self.x
    self.y = t * (tgtY) + (1 - t) * self.y
end

function Camera:draw()
    love.graphics.push()
    love.graphics.translate(math.floor(-self.x), math.floor(-self.y))
end

function Camera:drawEnd()
    -- draw the camera boxes
    for _, box in ipairs(self.boxes) do
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("line", box.x1, box.y1, box.x2 - box.x1, box.y2 - box.y1)
    end
    love.graphics.pop()
end

function Camera:remove()
    tagged.addTag(self, tagged.tags.CAMERA)
    Entity.remove(self)
end

return Camera
