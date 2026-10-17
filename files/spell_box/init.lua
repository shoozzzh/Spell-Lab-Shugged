local spell_box = require "spell_box"

---@type callbacks
local callbacks = {}

function callbacks.OnWorldPreUpdate()
    if GameGetFrameNum() % 60 == 0 then
        spell_box.update()
    end
end

return callbacks
