local InteractibleItem   = require "interactibleItem"
local PickableItem       = require "pickableItem"
local PickableReceptacle = require "pickablereceptacle"
local tagged             = require "tagged"

local keysnd             = love.audio.newSource("assets/key.wav", "static")
keysnd:setVolume(0.1)
local doorsnd = love.audio.newSource("assets/door.wav", "static")
doorsnd:setVolume(0.1)
local leversnd = love.audio.newSource("assets/lever.wav", "static")
leversnd:setVolume(0.1)


local function getDoor(id)
    for _, object in ipairs(tagged.getTagged(tagged.tags.DOOR)) do
        if object.id == id then
            return object
        end
    end
    return nil
end

local function setupPuzzle1(objects, keyCallback)
    -- estatueta no quarto2
    -- alvo_estatueta na estante da biblioteca
    -- estatueta + alvo_estatueta = chave1

    local estatueta = objects["estatueta"]
    local alvo_estatueta = objects["alvo_estatueta"]
    local chave1 = objects["chave1"]

    local keyspawned = false

    local keyobject = InteractibleItem.new(chave1.x, chave1.y, "chave1", "assets/key.png")
    keyobject:setVisible(false)
    function keyobject:interact()
        if not keyspawned then
            return false
        end
        self:setVisible(false)
        keyCallback()
    end

    local statueobject = PickableItem.new(estatueta.x, estatueta.y, "estatueta", "assets/statuette.png")

    local statueholder = PickableReceptacle.new(alvo_estatueta.x, alvo_estatueta.y, "alvo_estatueta")
    function statueholder:setItem(item)
        self.holding = item
        if item and item.id == "estatueta" and not keyspawned then
            keyspawned = true
            keyobject:setVisible(true)
        end
    end
end

local function setupPuzzle2(objects, keyCallback)
    -- prato na cozinha
    -- alvo_prato na cozinha
    -- prato + alvo_prato = destranca sala_cozinha
    -- chave2 na sala_cozinha

    local prato = objects["prato"]
    local alvo_prato = objects["alvo_prato"]
    local porta = assert(getDoor("sala_cozinha"))
    local chave2 = objects["chave2"]

    local keyobject = InteractibleItem.new(chave2.x, chave2.y, "chave2", "assets/key.png")

    function keyobject:interact()
        self:setVisible(false)
        keyCallback()
    end

    local plateobject = PickableItem.new(prato.x, prato.y, "prato", "assets/dish.png")

    local plateholder = PickableReceptacle.new(alvo_prato.x, alvo_prato.y, "alvo_prato")
    local unlocked = false
    function plateholder:setItem(item)
        self.holding = item
        if item and item.id == "prato" and not unlocked then
            unlocked = true
            porta:open()
            love.audio.play(doorsnd)
        end
    end
end

local function setupPuzzle3(objects, keyCallback)
    -- alavanca no escritório
    -- porta sala_reuniao trancada
    -- puxa alavanca, destranca porta
    -- chave3 na sala_reuniao

    local alavanca = objects["alavanca_escritorio"]
    local porta = assert(getDoor("sala_reuniao"))
    local chave3 = objects["chave3"]

    local keyobject = InteractibleItem.new(chave3.x, chave3.y, "chave3", "assets/key.png")
    keyobject:setVisible(false)

    function keyobject:interact()
        self:setVisible(false)
        keyCallback()
    end

    local leverobject = InteractibleItem.new(alavanca.x, alavanca.y, "alavanca_escritorio", "assets/lever-off.png")
    local lever = "off"
    function leverobject:interact()
        love.audio.play(leversnd)
        if lever == "off" then
            lever = "on"
            self:setImage("assets/lever-on.png")
            porta:open()
            love.audio.play(doorsnd)
            keyobject:setVisible(true)
        else
            lever = "off"
            self:setImage("assets/lever-off.png")
            porta:close()
            love.audio.play(doorsnd)
            keyobject:setVisible(false)
        end
    end
end

local function setupPuzzle4(objects, keyCallback)
    -- espelho na sala de lazer
    -- alvo_espelho na suíte
    -- espelho + alvo_espelho = chave4

    local espelho = objects["espelho"]
    local alvo_espelho = objects["alvo_espelho"]
    local chave4 = objects["chave4"]

    local keyspawned = false
    local keyobject = InteractibleItem.new(chave4.x, chave4.y, "chave4", "assets/key.png")
    keyobject:setVisible(false)

    function keyobject:interact()
        if not keyspawned then
            return false
        end
        self:setVisible(false)
        keyCallback()
    end

    local mirrorobject = PickableItem.new(espelho.x, espelho.y, "espelho", "assets/mirror.png")

    local mirrorholder = PickableReceptacle.new(alvo_espelho.x, alvo_espelho.y, "alvo_espelho")
    function mirrorholder:setItem(item)
        self.holding = item
        if item and item.id == "espelho" and not keyspawned then
            keyspawned = true
            keyobject:setVisible(true)
        end
    end
end

local function setupPuzzle5(objects, keyCallback)
    -- escrivaninha está no escritório
    -- interage com escrivaninha = chave5

    local escrivaninha = objects["escrivaninha"]
    local chave5 = objects["chave5"]

    local keyobject = InteractibleItem.new(chave5.x, chave5.y, "chave5", "assets/key.png")
    keyobject:setVisible(false)

    function keyobject:interact()
        self:setVisible(false)
        keyCallback()
    end

    local interacted = false
    local deskobject = InteractibleItem.new(escrivaninha.x, escrivaninha.y, "escrivaninha", "assets/trigger.png")
    function deskobject:interact()
        if not interacted then
            interacted = true
            keyobject:setVisible(true)
        end
    end
end

local function setupPuzzle6(objects, keyCallback)
    -- balde no banheiro
    -- lareira na lareira
    -- balde + lareira = chave6
    -- balde some quando usado

    local balde = objects["balde"]
    local lareira = objects["lareira"]
    local chave6 = objects["chave6"]

    local keyspawned = false
    local keyobject = InteractibleItem.new(chave6.x, chave6.y, "chave6", "assets/key.png")
    keyobject:setVisible(false)

    function keyobject:interact()
        if not keyspawned then
            return false
        end
        self:setVisible(false)
        keyCallback()
    end

    local bucketobject = PickableItem.new(balde.x, balde.y, "balde", "assets/bucket.png")

    local bucketholder = PickableReceptacle.new(lareira.x, lareira.y, "lareira")

    function bucketholder:setItem(item)
        self.holding = item
        if item and item.id == "balde" and not keyspawned then
            keyspawned = true
            keyobject:setVisible(true)
            item:remove()
        end
    end
end

local function setupPuzzle7(objects, keyCallback)
    -- alavanca no quarto1
    -- sala_arte trancada
    -- puxa alavanca, destranca porta

    -- quadro na sala de arte
    -- interage com quadro = chave7

    local alavanca = objects["alavanca_quarto1"]
    local porta = assert(getDoor("sala_arte"))
    local quadro = objects["quadro"]
    local chave7 = objects["chave7"]

    local keyobject = InteractibleItem.new(chave7.x, chave7.y, "chave7", "assets/key.png")
    keyobject:setVisible(false)

    function keyobject:interact()
        self:setVisible(false)
        keyCallback()
    end

    local leverobject = InteractibleItem.new(alavanca.x, alavanca.y, "alavanca_quarto1", "assets/lever-off.png")
    local lever = "off"

    function leverobject:interact()
        love.audio.play(leversnd)
        if lever == "off" then
            lever = "on"
            self:setImage("assets/lever-on.png")
            porta:open()
            love.audio.play(doorsnd)
        else
            lever = "off"
            self:setImage("assets/lever-off.png")
            porta:close()
            love.audio.play(doorsnd)
        end
    end

    local interacted = false
    local frameobject = InteractibleItem.new(quadro.x, quadro.y, "quadro", "assets/painting.png")

    function frameobject:interact()
        if not interacted then
            interacted = true
            keyobject:setVisible(true)
        end
    end
end

return function(tiledMap)
    local objects = {}
    for _, object in ipairs(tiledMap.layers["items"].objects) do
        objects[object.name] = object
    end

    local keys = {}



    local function keyCallback(i)
        return function()
            keys[i] = true

            love.audio.play(keysnd)

            local count = 0
            for i = 1, 7 do
                if keys[i] then
                    count = count + 1
                end
            end

            local game = tagged.getFirstTagged(tagged.tags.GAME)
            if game then
                game:setProgress(count)
            end

            if count == 7 then
                assert(getDoor("sala_final")):open()
                love.audio.play(doorsnd)
            end
        end
    end

    setupPuzzle1(objects, keyCallback(1))
    setupPuzzle2(objects, keyCallback(2))
    setupPuzzle3(objects, keyCallback(3))
    setupPuzzle4(objects, keyCallback(4))
    setupPuzzle5(objects, keyCallback(5))
    setupPuzzle6(objects, keyCallback(6))
    setupPuzzle7(objects, keyCallback(7))
end
