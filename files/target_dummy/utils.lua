local format = dofile_once( mod_path .. "files/format.lua" )
local mod_setting = dofile_once( mod_path .. "files/mod_setting.lua" )
local var = dofile_once( mod_path .. "files/var.lua" )

local module_path = module_path()

local var_map = {
    last_hit_frame = "value_int",
    first_hit_frame = "value_int",
    current_dps = "value_float",
    highest_dps = "value_float",
    total_damage = "value_float",
    last_frame_damage = "value_float",
}

function access_vars( entity_id )
    return var.access( entity_id, var_map, mod_id .. "." )
end

function center_text( text )
    return get_text_size( text, 1, module_path .. "fonts/blue.xml", true ) / 2
end

function set_text( entity_id, tag_sprite, value )
    local sprite_comp = EntityGetFirstComponent( entity_id, "SpriteComponent", mod_id .. "." .. tag_sprite )
    if not sprite_comp then return end
    local text = format.damage( value, mod_setting.get "dummy_target_show_full_damage_number", "i" )
    ComponentSetValue2( sprite_comp, "offset_x", center_text( text ) )
    ComponentSetValue2( sprite_comp, "text", text )
    EntityRefreshSprite( entity_id, sprite_comp )
end
