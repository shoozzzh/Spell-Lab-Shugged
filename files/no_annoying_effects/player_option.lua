---@type player_opt
local player_option = {}

local module_path = module_path()

player_option.mod_setting_key = module_name()

function player_option.value_initiator(player_id)
    return EntityHasTag(player_id, "glue_NOT")
end

function player_option.on_enable(player_id)
    EntityAddTag(player_id, "glue_NOT")
end

function player_option.on_disable(player_id)
    EntityRemoveTag(player_id, "glue_NOT")
end

function player_option.on_enabled_update(player_id)
    -- broad-spectrum protection
    local toxic_game_effects = {
        TELEPORTATION          = true,
        UNSTABLE_TELEPORTATION = true,
        BLINDNESS              = true,
        CONFUSION              = true,
        MOVEMENT_SLOWER        = true,
        FROZEN                 = true,
        ELECTROCUTION          = true,
    }
    for _, child_id in ipairs(EntityGetAllChildren(player_id) or {}) do
        if EntityHasTag(child_id, "spell_lab_shugged_non_toxic_status") then goto continue end

        local effect_comp = EntityGetFirstComponentIncludingDisabled(child_id, "GameEffectComponent")
        if not effect_comp then goto continue end

        local game_effect_id = ComponentGetValue2(effect_comp, "effect")
        if not toxic_game_effects[game_effect_id] then goto continue end

        ComponentSetValue2(effect_comp, "disable_movement", false)
        if ComponentGetValue2(effect_comp, "frames") > 1 then
            ComponentSetValue2(effect_comp, "frames", 1)
        end
        ::continue::
    end
end

return player_option
