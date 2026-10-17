---@type callbacks
local callbacks = {}

function callbacks.OnPlayerSpawned(player_id)
    EntityAddComponent2(player_id, "LuaComponent", { script_shot = "%MODULE_PATH%/player_shot.lua" })
end

return callbacks
