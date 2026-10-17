local sc = require "shortcuts"
local keystroke_listener = require "shortcuts.keystroke_listener"

---@type callbacks
local callbacks = {}

function callbacks.OnWorldPreUpdate()
    sc.update()
    keystroke_listener:update()
end

return callbacks
