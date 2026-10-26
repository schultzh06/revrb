local Loop = require("src.core.loop")
local Screen = require("src.render.screen")
local Manager = require("src.scenes.manager")
local Input = require("src.input.input")

local loop

local function tick()
    Manager.tick(Input.sample())
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
end

function love.keypressed(key)
    Manager.keypressed(key)
end
