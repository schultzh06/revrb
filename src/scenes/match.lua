local Manager = require("src.scenes.manager")
local Screen = require("src.render.screen")
local Input = require("src.input.input")

local Match = {}

local ticks
local enter

function Match.enter()
    print("welcome to the match hello world")
    ticks = 0
    enter = false
end

function Match.tick(frames)
    ticks = ticks + 1
    -- Debug: one line per press, so holding a key should print exactly once.
    for slot, frame in ipairs(frames) do
        for _, a in ipairs(Input.ACTIONS) do
            if frame[a .. "_pressed"] then
                print("slot " .. slot .. ": " .. a .. " pressed")
            end
        end
    end
end

function Match.draw()
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill", 10, 10, 50, 30)
    love.graphics.setColor(0.3, 0.6, 1)
    love.graphics.rectangle("line", 0, 0, Screen.WIDTH, Screen.HEIGHT)
    love.graphics.print(ticks, 125, 100)
    if enter then
        love.graphics.print("hi", 125, 50)
    end
end

function Match.keypressed(key)
    enter = (key == "return")
    if key == "escape" then
        Manager.switch(require("src.scenes.title"))
    end
end

return Match
