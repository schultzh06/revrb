return {
    -- Slot 1: left side of the keyboard. Move with WASD, jump with the thumb.
    {
        left = { "sc:a", "axis:leftx-", "button:dpleft" },
        right = { "sc:d", "axis:leftx+", "button:dpright" },
        up = { "sc:w", "axis:lefty-", "button:dpup" },
        down = { "sc:s", "axis:lefty+", "button:dpdown" },
        jump = { "sc:space", "button:a" },
        attack = { "sc:f", "button:x" },
        dash = { "sc:lshift", "button:rightshoulder", "axis:triggerright+" },
        throw = { "sc:e", "button:b" },
    },

    -- Slot 2: right side. Move with the arrows, actions on the keys just above them.
    {
        left = { "sc:left", "axis:leftx-", "button:dpleft" },
        right = { "sc:right", "axis:leftx+", "button:dpright" },
        up = { "sc:up", "axis:lefty-", "button:dpup" },
        down = { "sc:down", "axis:lefty+", "button:dpdown" },
        jump = { "sc:/", "button:a" },
        attack = { "sc:.", "button:x" },
        dash = { "sc:rshift", "button:rightshoulder", "axis:triggerright+" },
        throw = { "sc:,", "button:b" },
    },
}
