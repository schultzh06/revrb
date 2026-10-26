local baton = require("lib.baton")
local Bindings = require("src.input.bindings")

local Input = {}

local players = {}
local prev = {} -- last tick's frame per slot

local ACTIONS = { "left", "right", "up", "down", "jump", "attack", "dash", "throw" }
local EDGE_ACTIONS = { "jump", "attack", "dash", "throw" }

Input.ACTIONS = ACTIONS

-- Seeding prev with "nothing held" means add_edges never sees nil, and the
-- first frame gets the same fields as every later one.
local function empty_frame()
    local frame = {}
    for _, a in ipairs(ACTIONS) do
        frame[a] = false
    end
    return frame
end

function Input.init()
    local joysticks = love.joystick.getJoysticks()
    for slot, layout in ipairs(Bindings) do
        players[slot] = baton.new({
            controls = layout,
            joystick = joysticks[slot],
        })
        prev[slot] = empty_frame()
    end
end

local function read_frame(player)
    local cur = {}
    for _, a in ipairs(ACTIONS) do
        cur[a] = player:down(a)
    end
    return cur
end

local function add_edges(cur, last)
    for _, e in ipairs(EDGE_ACTIONS) do
        cur[e .. "_pressed"] = cur[e] and not last[e]
    end
    return cur
end

function Input.sample()
    local cur = {}
    for slot, player in ipairs(players) do
        player:update()
        cur[slot] = add_edges(read_frame(player), prev[slot])
        prev[slot] = cur[slot]
    end
    return cur
end

return Input
