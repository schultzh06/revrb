local Manager = {}

local current
local pending

function Manager.switch(scene, params)
    pending = { scene = scene, params = params }
end

local function apply_pending()
    if not pending then
        return
    end
    if current and current.exit then
        current.exit()
    end
    current = pending.scene
    local params = pending.params
    pending = nil
    if current.enter then
        current.enter(params)
    end
end

function Manager.tick()
    apply_pending()
    if current and current.tick then
        current.tick()
    end
end

function Manager.draw()
    if current and current.draw then
        current.draw()
    end
end

function Manager.keypressed(key)
    if current and current.keypressed then
        current.keypressed(key)
    end
end

return Manager
