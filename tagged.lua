local Tagged = {}

Tagged.tags = {}
Tagged.tags.ENTITY = "entity"
Tagged.tags.PLAYER = "player"
Tagged.tags.PICKABLE = "pickable"
Tagged.tags.INTERACTIBLE = "interactible"
Tagged.tags.CAMERA = "camera"

local tags = {}

function Tagged.addTag(entity, tag)
    if not tags[tag] then
        tags[tag] = setmetatable({}, { __mode = "v" })
    end
    table.insert(tags[tag], entity)
end

function Tagged.removeTag(entity, tag)
    if tags[tag] then
        for i, e in ipairs(tags[tag]) do
            if e == entity then
                table.remove(tags[tag], i)
                break
            end
        end
    end
end

function Tagged.getTagged(tag)
    return { unpack(tags[tag] or {}) }
end

function Tagged.getFirstTagged(tag)
    return tags[tag] and tags[tag][1] or nil
end

function Tagged.wipe()
    tags = {}
end

return Tagged
