local Collide = {}

function Collide.aabb(r1, r2)
    return r1.x1 < r2.x2 and r1.x2 > r2.x1 and r1.y1 < r2.y2 and r1.y2 > r2.y1
end

function Collide.pointInRect(x, y, r)
    return x >= r.x1 and x <= r.x2 and y >= r.y1 and y <= r.y2
end

function Collide.pointInCircle(px, py, cx, cy, cr)
    return (px - cx) ^ 2 + (py - cy) ^ 2 <= cr ^ 2
end

--- Resolves a collision between two rectangles.
---
--- Returns true and a delta to apply to the first rectangle if a collision is detected,
--- otherwise returns false and zeros.
function Collide.resolveAabb(r1, r2)
    if not Collide.aabb(r1, r2) then
        return false, 0, 0
    end

    local dx, dy = 0, 0
    -- if we're here, there's an overlap in both the x and y axes
    if (r1.x1 + r1.x2) / 2 < (r2.x1 + r2.x2) / 2 then
        -- r1 is to the left of r2
        dx = r2.x1 - r1.x2
    else
        -- r1 is to the right of r2
        dx = r2.x2 - r1.x1
    end

    if (r1.y1 + r1.y2) / 2 < (r2.y1 + r2.y2) / 2 then
        -- r1 is above r2
        dy = r2.y1 - r1.y2
    else
        -- r1 is below r2
        dy = r2.y2 - r1.y1
    end

    if math.abs(dx) < math.abs(dy) then
        dy = 0
    else
        dx = 0
    end

    return true, dx, dy
end

return Collide
