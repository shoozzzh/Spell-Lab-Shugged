local sc = require "shortcuts"
local dt = require "dummy_transforming"

---@type callbacks
local callbacks = {}

callbacks.OnWorldPreUpdate = function()
    if sc.detector.is_fired(sc.table.dummy_transform) then
        dt.execute_if_armed()
    end
end

return callbacks
