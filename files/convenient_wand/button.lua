local pop = require "pop"
local gui_elems = require "gui.elems"
local common_val = require "common_values"
local tr = require "tr"
local wand_utils = require "wand_utils"
local tl = require "tinklin"

---@type wand_utils.wand_data
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
    look = {
        name = "Eradication staff",
        file = "data/items_gfx/wands/wand_0821.png",
        grip_x = 4,
        grip_y = 3,
        tip_x = 22,
        tip_y = 3,
        fire_rate_wait = 0,
        actions_per_round = 0,
        shuffle_deck_when_empty = 0,
        deck_capacity = 7,
        spread_degrees = 0,
        reload_time = 0,
    },
}

---@param mb_utils mb_utils
return function(mb_utils)
    local left_click, right_click = mb_utils.button()
    if left_click then
        gui_elems.sound_button_clicked()
        local wand = tl.entity_load("data/entities/items/wand_level_01.xml", unpack(common_val.world_dest_pos))
        wand_utils.apply_wand_data(wand, wand_data)
    elseif right_click and common_val.held_wand then
        gui_elems.sound_button_clicked()
        wand_utils.apply_wand_data(common_val.held_wand, wand_data)
    end
    pop.tooltip(tr["%MODULE_ID%"]:key())
end
