local Sounds = {}

Sounds.sounds = {
    LOST = {
        id = "LOST",
        snd = love.audio.newSource("assets/sounds/lost.wav", "static"),
        volume = 0.2,
        loudness = 0,
    },
    WIN = {
        id = "WIN",
        snd = love.audio.newSource("assets/sounds/win.wav", "static"),
        volume = 0.05,
        loudness = 0,
    },

    PLR_STEP = {
        id = "PLR_STEP",
        snd = love.audio.newSource("assets/sounds/step.wav", "static"),
        volume = 0.2,
        loudness = 1,
    },
    PLR_RUN = {
        id = "PLR_RUN",
        snd = love.audio.newSource("assets/sounds/step.wav", "static"),
        volume = 0.2,
        loudness = 2,
    },
    KEY = {
        id = "KEY",
        snd = love.audio.newSource("assets/sounds/key.wav", "static"),
        volume = 0.2,
        loudness = 1,
    },
    PICK_UP = {
        id = "PICK_UP",
        snd = love.audio.newSource("assets/sounds/grab.wav", "static"),
        volume = 0.2,
        loudness = 2,
    },
    DROP = {
        id = "DROP",
        snd = love.audio.newSource("assets/sounds/drop.wav", "static"),
        volume = 0.2,
        loudness = 3,
    },
    DOOR = {
        id = "DOOR",
        snd = love.audio.newSource("assets/sounds/door.wav", "static"),
        volume = 0.2,
        loudness = 1,
    },
    LEVER = {
        id = "LEVER",
        snd = love.audio.newSource("assets/sounds/lever.wav", "static"),
        volume = 0.2,
        loudness = 3,
    },

    MONSTER_STEP = {
        id = "MONSTER_STEP",
        snd = love.audio.newSource("assets/sounds/scaryfoot.wav", "static"),
        volume = 0.12,
        loudness = 0,
    }
}

Sounds._listeners = {}

function Sounds.setup()
    love.audio.setDistanceModel("none")
end

function Sounds.play(sound)
    local s = sound.snd:clone()
    s:setVolume(sound.volume)
    s:setRelative(true)
    s:play()
end

function Sounds.playAt(sound, x, y)
    local s = sound.snd:clone()
    s:setVolume(sound.volume)
    s:setPosition(x, y, 0)
    s:play()

    for listener in pairs(Sounds._listeners) do
        listener(sound, x, y)
    end
end

function Sounds.playAtRelative(sound, x, y)
    local s = sound.snd:clone()
    s:setVolume(sound.volume)
    s:setRelative(true)
    s:play()

    for listener in pairs(Sounds._listeners) do
        listener(sound, x, y)
    end
end

function Sounds.setListeningPosition(x, y)
    love.audio.setPosition(x, y, 0)
end

function Sounds.registerListener(listenerCallback)
    Sounds._listeners[listenerCallback] = true
end

function Sounds.unregisterListener(listenerCallback)
    Sounds._listeners[listenerCallback] = nil
end

return Sounds
