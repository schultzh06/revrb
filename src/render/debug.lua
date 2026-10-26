local Input = require("src.input.input")

local Debug = {}

-- Render-only state: toggling it must never change what the sim does.
local enabled = false

function Debug.toggle()
    enabled = not enabled
end

-- Screen-space text, drawn after the canvas at window resolution so it stays
-- small and crisp. info.frames is nil until the first tick has run.
function Debug.draw_overlay(info)
    if not enabled then
        return
    end

    love.graphics.setColor(1, 1, 0.4)
    love.graphics.print("FPS " .. love.timer.getFPS(), 8, 8)

    for slot, frame in ipairs(info.frames or {}) do
        local held = ""
        for _, a in ipairs(Input.ACTIONS) do
            if frame[a] then
                held = held .. a .. " "
            end
        end
        love.graphics.print("P" .. slot .. ": " .. held, 8, 8 + slot * 16)
    end

    love.graphics.setColor(1, 1, 1)
end

-- M1: Debug.draw_world(...) for colliders, called inside the canvas.

return Debug
