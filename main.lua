local Loop = require("src.core.loop")
local Screen = require("src.render.screen")

local loop
local ticks = 0

function love.load()
    Screen.init()

    -- Init fixed time loop
    loop = Loop.new()
end

function love.update(dt)
    loop:update(dt, function()
        ticks = ticks + 1
        if ticks % 60 == 0 then
            print("tick " .. ticks)
            print("time " .. love.timer.getTime())
        end
    end)
end

function love.draw()
    Screen.begin()

    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill", 10, 10, 50, 30)
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.rectangle("line", 0, 0, Screen.WIDTH, Screen.HEIGHT)

    Screen.finish()
end
