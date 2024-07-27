local Player    = require "player"
local tagged    = require "tagged"
local Camera    = require "camera"
local Map       = require "map"
local Hud       = require "hud"
local Ambience  = require "ambience"
local sounds    = require "sounds"
local Monster   = require "monster"

local Game      = {}
Game.__index    = Game

local gameTitle = love.graphics.newImage("assets/titulo.png")
local lost      = love.graphics.newImage("assets/morreu.png")
local won       = love.graphics.newImage("assets/escapou.png")

function Game.new()
    local self = setmetatable({}, Game)

    self.state = ""
    self:changeState("menu")

    tagged.addTag(self, tagged.tags.GAME)

    return self
end

function Game:getState()
    return self.state
end

function Game:changeState(newState)
    if self.ents then
        for _, object in ipairs(self.ents) do
            object:remove()
        end
    end
    tagged.wipe()
    tagged.addTag(self, tagged.tags.GAME)
    self.progress = nil
    self.hud = nil
    self.timer = nil
    self.ents = nil

    if newState == "menu" then
        self.timer = 0
    elseif newState == "game" then
        self.ents = {
            Map.new(),
            Player.new(1024, 1860),
            Camera.new(1024 - WIDTH / 2, 1860 - HEIGHT / 2),
            Ambience.new(),
            Monster.new(1024 - WIDTH / 2, 1860 - HEIGHT / 2)
        }
        self.hud = Hud.new()
        self.progress = 0
    elseif newState == "gameover" then
        sounds.play(sounds.sounds.LOST)
    elseif newState == "victory" then
        sounds.play(sounds.sounds.WIN)
    end

    self.state = newState
end

function Game:update(dt)
    if self:getState() == "menu" then
        self.timer = self.timer + dt

        if love.keyboard.isDown("return") and self.timer > 0.5 then
            self:changeState("game")
        end

        if love.keyboard.isDown("escape") and self.timer > 0.5 then
            love.event.quit()
        end
    elseif self:getState() == "game" then
        for _, object in ipairs(tagged.getTagged(tagged.tags.ENTITY)) do
            object:update(dt)
            if self:getState() ~= "game" then
                break
            end
        end
    end

    if love.keyboard.isDown("escape") and self:getState() ~= "menu" then
        self:changeState("menu")
    end
end

function Game:setProgress(progress)
    self.progress = progress
end

function Game:getProgress()
    return self.progress
end

function Game:draw()
    love.graphics.clear(0, 0, 0, 1)

    if self:getState() == "menu" then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Aperte Enter para começar", WIDTH / 2 - 150, HEIGHT - 32, 300, "center")

        love.graphics.draw(gameTitle, WIDTH / 2, HEIGHT / 2, 0, 1, 1, gameTitle:getWidth() / 2, gameTitle:getHeight() / 2)
    elseif self:getState() == "game" then
        local drawQueue = {}
        for _, object in ipairs(tagged.getTagged(tagged.tags.ENTITY)) do
            table.insert(drawQueue, object)
        end
        table.sort(drawQueue, function(a, b)
            return a:zIndex() < b:zIndex()
        end)
        for i = 1, #drawQueue do
            local object = drawQueue[i]
            object:draw()
        end
        for i = #drawQueue, 1, -1 do
            local object = drawQueue[i]
            object:drawEnd()
        end
        self.hud:draw(self)
    elseif self:getState() == "gameover" then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(lost, WIDTH / 2, HEIGHT / 2, 0, 1, 1, lost:getWidth() / 2, lost:getHeight() / 2)
    elseif self:getState() == "victory" then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(won, WIDTH / 2, HEIGHT / 2, 0, 1, 1, won:getWidth() / 2, won:getHeight() / 2)
    end
end

return Game
