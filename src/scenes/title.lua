local Manager = require("src.scenes.manager")

local Title = {}

local blink -- Tick counter for press enter blink anim

function Title.enter()
    blink = 0
end

function Title.tick()
    blink = blink + 1
end

function Title.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("REVRB", 140, 60)
    if blink % 60 < 40 then
        love.graphics.print("press enter", 125, 100)
    end
end

function Title.keypressed(key)
    if key == "return" then
        Manager.switch(require("src.scenes.match"))
    end
end

return Title
