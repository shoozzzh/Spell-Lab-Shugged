---@type player_opt
local player_option = {}

player_option.mod_setting_key = module_name()

local player_child_name = mod_id .. ".invincible"

function player_option.value_initiator()
    return EntityGetWithName(player_child_name) ~= 0
end

function player_option.on_enable(player_id)
    local effect_entity = EntityCreateNew(player_child_name)
    EntityAddChild(player_id, effect_entity)
    EntityAddComponent2(effect_entity, "InheritTransformComponent")
    EntityAddComponent2(effect_entity, "GameEffectComponent", {
        effect = "PROTECTION_ALL",
        frames = -1,
    })
end

function player_option.on_disable()
    EntityKill(EntityGetWithName(player_child_name))
end

return player_option
