local pop = require "pop"
local gui_elems = require "gui.elems"
local common_val = require "common_values"
local tr = require "tr"

local wand_data = {
    stats = {
        shuffle_deck_when_empty = false,
        actions_per_round = 1,
        fire_rate_wait = 10,
        reload_time = 20,
        mana_max = 100000,
        mana_charge_speed = 100000,
        capacity = 26,
        spread_degrees = 0,
        speed_multiplier = 1,
    },
    sprite = {
        file = "data/items_gfx/wands/wand_0821.png",
        hotspot = {
            x = 18.0,
            y = 0.0,
        },
        x = 4,
        y = 3,
    },
}

---@param mb_utils mb_utils
return function(mb_utils)
    local left_click, right_click = mb_utils.button()
    if left_click then
        gui_elems.sound_button_clicked()
        local wand = EntityLoad("data/entities/items/wand_level_01.xml", unpack(common_val.world_dest_pos))
        WANDS.initialize_wand(wand, wand_data)
    elseif right_click and common_val.held_wand then
        gui_elems.sound_button_clicked()
        WANDS.initialize_wand(common_val.held_wand, wand_data, false)
    end
    pop.tooltip(tr["%MODULE_ID%"]:key())
end
