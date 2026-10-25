local Screen = {}

Screen.WIDTH = 320
Screen.HEIGHT = 180

-- There is only one window, so the canvas is module state rather than an object.
local canvas

function Screen.init()
    -- The filter is baked in when a canvas is created, so this must run first.
    love.graphics.setDefaultFilter("nearest", "nearest")
    canvas = love.graphics.newCanvas(Screen.WIDTH, Screen.HEIGHT)
end

-- Everything drawn between begin() and finish() is in 320x180 game coordinates.
function Screen.begin()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.1, 0.1, 0.15)
end

function Screen.finish()
    love.graphics.setCanvas()
    -- setColor is global state; without this the canvas is tinted by whatever was drawn last.
    love.graphics.setColor(1, 1, 1)

    -- Integer scale only, so every game pixel is the same size on screen.
    local w, h = love.graphics.getDimensions()
    local scale = math.max(1, math.floor(math.min(w / Screen.WIDTH, h / Screen.HEIGHT)))
    local x = math.floor((w - Screen.WIDTH * scale) / 2)
    local y = math.floor((h - Screen.HEIGHT * scale) / 2)

    love.graphics.draw(canvas, x, y, 0, scale, scale)
end

return Screen
