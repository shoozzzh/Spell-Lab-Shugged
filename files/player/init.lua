local tl = require "tinklin"

---@type callbacks
local callbacks = {}

local script = "%MODULE_PATH%/player_update.lua"

function callbacks.OnPlayerSpawned(player_id)
    local player = tl.entity_wrap(player_id)
    local inited = player:comps "LuaComponent":any(function(c)
        return c.script_source_file == script
    end)

    if not inited then
        GlobalsSetValue("%MOD_ID%.refresh_player_state", "1")
        player:comp_new "LuaComponent" {
            script_source_file = script,
            execute_on_added = true,
            execute_every_n_frame = 1,
        }
    end
end

return callbacks
