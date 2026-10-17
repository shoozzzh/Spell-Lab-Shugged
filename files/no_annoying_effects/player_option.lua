---@type player_opt
local player_option = {}

player_option.mod_setting_key = "%MODULE_ID%.enabled"

function player_option.value_initiator(player)
    return player.tag.glue_NOT
end

function player_option.on_enable(player)
    player.tag.glue_NOT = true
end

function player_option.on_disable(player)
    player.tag.glue_NOT = false
end

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
function player_option.on_enabled_update(player)
    player:get_children():each(function(child)
        if child.tag["%MODULE_FULL_ID%.bypass"] then goto continue end

        local effect_comp = child:comp_first "GameEffectComponent"
        if not effect_comp then goto continue end

        local game_effect_id = effect_comp.effect
        if not toxic_game_effects[game_effect_id] then goto continue end

        effect_comp.disable_movement = false

        if effect_comp.frames > 1 then
            effect_comp.frames = 1
        end

        ::continue::
    end)
end

return player_option
