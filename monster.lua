local Entity = require "entity"
local tagged = require "tagged"
local sounds = require "sounds"
local Monster = {}
Monster.__index = Monster
setmetatable(Monster, Entity)

local function aStar(graph, positions, start, target)
    local function h(node)
        return math.sqrt((positions[node].x - positions[target].x) ^ 2 +
            (positions[node].y - positions[target].y) ^ 2)
    end

    local function d(n1, n2)
        return math.sqrt((positions[n1].x - positions[n2].x) ^ 2 +
            (positions[n1].y - positions[n2].y) ^ 2)
    end
    local open = {}
    open[start] = true
    local cameFrom = {}
    local g = {}
    g[start] = 0
    local f = {}
    f[start] = h(start)
    while next(open) do
        local current = next(open)
        local currentF = math.huge
        for node in pairs(open) do
            if f[node] < currentF then
                current = node
                currentF = f[node]
            end
        end
        if current == target then
            local path = {}
            while current do
                table.insert(path, 1, current)
                current = cameFrom[current]
            end
            return path
        end
        open[current] = nil
        for _, neighbor in ipairs(graph[current]) do
            local tentativeG = g[current] + d(current, neighbor)
            if tentativeG < (g[neighbor] or math.huge) then
                cameFrom[neighbor] = current
                g[neighbor] = tentativeG
                f[neighbor] = g[neighbor] + h(neighbor)
                open[neighbor] = true
            end
        end
    end
    return nil
end

local function getPath(graph, positions, start, target)
    -- find the closest node to the start and target
    local startNode = nil
    local targetNode = nil
    local startDist = math.huge
    local targetDist = math.huge
    for node in pairs(graph) do
        local nodepos = positions[node]
        local startDist2 = math.sqrt((nodepos.x - start.x) ^ 2 + (nodepos.y - start.y) ^ 2)
        local targetDist2 = math.sqrt((nodepos.x - target.x) ^ 2 +
            (nodepos.y - target.y) ^ 2)
        if startDist2 < startDist then
            startDist = startDist2
            startNode = node
        end
        if targetDist2 < targetDist then
            targetDist = targetDist2
            targetNode = node
        end
    end

    return aStar(graph, positions, startNode, targetNode)
end

function Monster.new(x, y)
    local self = Entity.new(x, y)
    setmetatable(self, Monster)

    tagged.addTag(self, tagged.tags.MONSTER)

    self.img = love.graphics.newImage("assets/monstro.png")
    self.w, self.h = self.img:getDimensions()
    self.speed = 64
    self.callback = function(sound, x, y)
        self:handleSound(sound, x, y)
    end
    sounds.registerListener(self.callback)

    self.soundTimer = 0
    self.moveX = 0

    self.brain = {
        soundFlag = nil,
        state = "think",
        data = { timer = 2 }
    }

    return self
end

function Monster:handleSound(sound, x, y)
    local d = math.sqrt((x - self.x) ^ 2 + (y - self.y) ^ 2)
    if not self.brain.soundFlag then
        if ((sound.loudness > 0 and d < 200) or sound.loudness >= 2) then
            self.brain.soundFlag = { priority = sound.loudness, x = x, y = y }
        end
    else
        local lastd = math.sqrt((self.brain.soundFlag.x - self.x) ^ 2 +
            (self.brain.soundFlag.y - self.y) ^ 2)
        if sound.loudness > self.brain.soundFlag.priority or d < lastd then
            self.brain.soundFlag = { priority = sound.loudness, x = x, y = y }
        end
    end
end

function Monster:act(dt)
    local graph = assert(tagged.getFirstTagged(tagged.tags.GRAPH))

    local function changeState(newState)
        if newState == "think" then
            self.brain.state = "think"
            self.brain.data = { timer = 2 }
        elseif newState == "move" then
            self.brain.state = "move"
            self.brain.data = {
                path = getPath(graph.graph, graph.positions, { x = self.x, y = self.y },
                    graph.positions[math.random(#graph.positions)])
            }
        elseif newState == "investigate" then
            self.brain.state = "investigate"
            self.brain.data = {
                path = getPath(graph.graph, graph.positions, { x = self.x, y = self.y },
                    self.brain.soundFlag)
            }
            self.brain.soundFlag = nil
        elseif newState == "chase" then
            self.brain.state = "chase"
            self.brain.data = {}
        end
    end

    if self.brain.state == "think" then
        -- if there's a sound and it's near the player, chase the player
        local plr = assert(tagged.getFirstTagged(tagged.tags.PLAYER))
        local d = math.sqrt((plr.x - self.x) ^ 2 + (plr.y - self.y) ^ 2)

        if self.brain.soundFlag then
            if d < 200 then
                changeState("chase")
            else
                changeState("investigate")
            end
        else
            self.brain.data.timer = self.brain.data.timer - dt
            if self.brain.data.timer <= 0 then
                changeState("move")
            end
        end
    elseif self.brain.state == "move" then
        if self.brain.soundFlag then
            changeState("investigate")
        else
            local path = self.brain.data.path
            if not path then
                changeState("think")
            else
                local nextNode = path[1]
                local nextPos = graph.positions[nextNode]
                local dx = nextPos.x - self.x
                local dy = nextPos.y - self.y
                local mag = math.sqrt(dx * dx + dy * dy)
                if mag < 8 then
                    table.remove(path, 1)
                    if #path == 0 then
                        changeState("think")
                    end
                end
                return dx, dy
            end
        end
    elseif self.brain.state == "investigate" then
        -- if there's a sound and it's near the player, chase the player
        local plr = assert(tagged.getFirstTagged(tagged.tags.PLAYER))
        local d = math.sqrt((plr.x - self.x) ^ 2 + (plr.y - self.y) ^ 2)
        if self.brain.soundFlag then
            if d < 300 then
                changeState("chase")
            else
                self.brain.soundFlag = nil
            end
        end

        if not self.brain.soundFlag then
            local path = self.brain.data.path
            if not path then
                changeState("think")
            else
                local nextNode = path[1]
                local nextPos = graph.positions[nextNode]
                local dx = nextPos.x - self.x
                local dy = nextPos.y - self.y
                local mag = math.sqrt(dx * dx + dy * dy)
                if mag < 8 then
                    table.remove(path, 1)
                    if #path == 0 then
                        changeState("think")
                    end
                end
                return dx, dy
            end
        end
    elseif self.brain.state == "chase" then
        local plr = assert(tagged.getFirstTagged(tagged.tags.PLAYER))
        return plr.x - self.x, plr.y - self.y
    end

    return 0, 0
end

function Monster:moveUpdate(dt)
    local dx, dy = self:act(dt)

    local STEP_DELAY = 0.75

    local mag = math.sqrt(dx * dx + dy * dy)
    if mag > 0 then
        dx = dx / mag
        dy = dy / mag
    else
        self.soundTimer = STEP_DELAY / 2
    end

    local modifier = self.brain.state == "investigate" and 2 or (self.brain.state == "chase" and 4.1 or 1)

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

    self.moveX = dx

    self.soundTimer = self.soundTimer + dt * modifier
    if self.soundTimer > STEP_DELAY then
        sounds.playAt(sounds.sounds.MONSTER_STEP, self.x, self.y)
        self.soundTimer = 0
    end
end

function Monster:update(dt)
    if not self:isVisible() then
        return
    end

    self:moveUpdate(dt)
end

function Monster:draw()
    if not self:isVisible() then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.img, math.floor(self.x - self.w / 2 * (self.moveX > 0 and -1 or 1)),
        math.floor(self.y - self.h + math.sin(love.timer.getTime()) * 3), 0, self.moveX > 0 and -1 or 1, 1)
end

function Monster:remove()
    sounds.unregisterListener(self.callback)
    tagged.removeTag(self, tagged.tags.MONSTER)
    Entity.remove(self)
end

return Monster
