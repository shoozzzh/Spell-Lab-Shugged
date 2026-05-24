---@type player_opt
local player_option = {}

local module_path = module_path()

player_option.mod_setting_key = module_name()

local player_child_name = mod_id .. ".all_seeing_eye"

function player_option.value_initiator()
    return EntityGetWithName(player_child_name) ~= 0
end

function player_option.on_enable(player_id)
    EntityAddChild(player_id, EntityLoad(module_path .. "player_child/entity.xml"))
end

function player_option.on_disable()
    EntityKill(EntityGetWithName(player_child_name))
end

return player_option
