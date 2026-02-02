local module_path = module_path()

---@type callbacks
local callbacks = {}

function callbacks.OnPlayerSpawned( player_id )
    EntityAddComponent2( player_id, "LuaComponent", {
        script_shot = module_path .. "player_shot.lua",
    } )
end

return callbacks
