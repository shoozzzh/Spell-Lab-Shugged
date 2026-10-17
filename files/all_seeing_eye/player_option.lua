local tl = require "tinklin"

---@type player_opt
local player_option = {}

player_option.mod_setting_key = "%MODULE_ID%.enabled"

local player_child_name = "%MODULE_FULL_ID%.player_child"

function player_option.value_initiator()
    return tl.entity_with_name(player_child_name) ~= nil
end

function player_option.on_enable(player)
    player:add_child(tl.entity_load "%MODULE_PATH%/player_child/entity.xml")
end

function player_option.on_disable()
    tl.entity_with_name(player_child_name):kill()
end

return player_option
