local Entity = require "entity"
local tagged = require "tagged"

local PADDING = 20
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

local function box(t)
    return { x1 = t[1], y1 = t[2], x2 = t[3], y2 = t[4] }
end

function Camera.new()
    local self = Entity.new(0, 0)
    setmetatable(self, Camera)

    self.boxes = {
        -- biblioteca
        box { 98, 66, 586, 322 },
        -- cozinha
        box { 624, 181, 1050, 362 },
        -- escritório
        box { 98, 332, 352, 668 },
        -- piano
        box { 382, 332, 590, 668 },
        -- salão de jantar
        box { 624, 392, 1050, 668 },
        -- quarto 1
        box { 1086, 286, 1342, 668 },
        -- quarto 2
        box { 1384, 286, 1638, 668 },
        -- corredor
        box { 98, 697, 1638, 827 },
        -- suíte
        box { 98, 850, 362, 1193 },
        -- sala de lazer
        box { 392, 850, 615, 1269 },
        -- salão principal
        box { 646, 917, 1026, 1206 },
        -- lareira
        box { 1054, 850, 1272, 1250 },
        -- sala de reunião
        box { 1300, 850, 1638, 977 },
        -- salão de arte
        box { 1300, 1000, 1638, 1348 },
        -- banheiro
        box { 98, 1209, 362, 1348 },
        -- saída
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
                -- no padding here
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

    local t = clamp(5 * dt, 0, 1)
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
