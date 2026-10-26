local Loop = require("src.core.loop")
local Screen = require("src.render.screen")
local Manager = require("src.scenes.manager")
local Input = require("src.input.input")
local Debug = require("src.render.debug")

local loop
local last_frames -- kept so the debug overlay can show what the last tick saw

local function tick()
    last_frames = Input.sample()
    Manager.tick(last_frames)
end

function love.load()
    Screen.init()
    Input.init()

    -- Init fixed time loop
    loop = Loop.new()

    Manager.switch(require("src.scenes.title"))
end

function love.update(dt)
    loop:update(dt, tick)
end

function love.draw()
    Screen.begin()
    Manager.draw()
    Screen.finish()
    Debug.draw_overlay({ frames = last_frames })
end

function love.keypressed(key)
    -- Dev keys work in every scene and never reach the scene.
    if key == "f1" then
        Debug.toggle()
        return
    end
    Manager.keypressed(key)
end
