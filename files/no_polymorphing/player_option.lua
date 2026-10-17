---@type player_opt
local player_option = {}

player_option.mod_setting_key = "%MODULE_ID%.enabled"

local player_child_name = "%MODULE_FULL_ID%.player_child"

function player_option.value_initiator()
    return EntityGetWithName(player_child_name) ~= 0
end

function player_option.on_enable(player)
    local effect_entity = EntityCreateNew(player_child_name)
    EntityAddChild(player.id, effect_entity)
    EntityAddComponent2(effect_entity, "InheritTransformComponent")
    EntityAddComponent2(effect_entity, "GameEffectComponent", {
        effect = "PROTECTION_POLYMORPH",
        frames = -1,
    })
end

function player_option.on_disable()
    EntityKill(EntityGetWithName(player_child_name))
end

return player_option
