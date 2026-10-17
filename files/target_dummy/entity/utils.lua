dofile_once "%MOD_PATH%/require.lua"

local format = require "format"
local settings = require "mod_settings"
local var = require "var"
local mutils = require "misc_utils"

local utils = {}

---@class target_dummy_vars
---@field last_hit_frame integer
---@field first_hit_frame integer
---@field current_dps number
---@field highest_dps number
---@field total_damage number
---@field last_frame_damage number

local var_map = {
    last_hit_frame = "value_int",
    first_hit_frame = "value_int",
    current_dps = "value_float",
    highest_dps = "value_float",
    total_damage = "value_float",
    last_frame_damage = "value_float",
}

function utils.access_vars(entity_id)
    ---@type target_dummy_vars
    return var.access(entity_id, var_map, "%MOD_ID%.")
end

function utils.center_text(text)
    return mutils.get_text_size(text, 1, "%MODULE_PATH%/fonts/blue.xml", true) / 2
end

function utils.set_text(entity_id, tag_sprite, value)
    local sprite_comp = EntityGetFirstComponent(entity_id, "SpriteComponent", "%MOD_ID%." .. tag_sprite)
    if not sprite_comp then return end
    local text = format.damage_dummy(value, settings.get_or_default("dummy_target_show_full_damage_number", false), "i")
    ComponentSetValue2(sprite_comp, "offset_x", utils.center_text(text))
    ComponentSetValue2(sprite_comp, "text", text)
    EntityRefreshSprite(entity_id, sprite_comp)
end
