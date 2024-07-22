local Hud = {}
Hud.__index = Hud

function Hud.new()
    local self = setmetatable({}, Hud)

    self.key_img = love.graphics.newImage("assets/key-hud.png")

    return self
end

function Hud:draw(game)
    love.graphics.push()
    love.graphics.origin()

    love.graphics.setColor(1, 1, 1)
    for i = 1, game:getProgress() do
        love.graphics.draw(self.key_img, WIDTH - 48 - 10, 10 + 30 * (i - 1))
    end

    love.graphics.pop()
end

return Hud
