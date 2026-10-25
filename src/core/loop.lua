local Loop = {}
Loop.DT = 1 / 60
Loop.MAX_DT = 0.25
Loop.__index = Loop

function Loop.new()
    local self = setmetatable({}, Loop)
    self.accumulator = 0
    return self
end

function Loop:update(dt, step_fn)
    self.accumulator = self.accumulator + math.min(dt, Loop.MAX_DT)
    while self.accumulator >= Loop.DT do
        step_fn()
        self.accumulator = self.accumulator - Loop.DT
    end
end

return Loop
