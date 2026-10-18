local pop = require "pop"
local tl = require "tinklin"
local gui_elems = require "gui.elems"
local tr = require "tr"
local module_tr = tr.as_prefix(tr.hp_fixer)
local format = require "format"
local var = require "var"
local common_val = require "common_values"

local player_child_name = "%MODULE_FULL_ID%.player_child"

local var_map = {
    hp_fixed_to = "value_float",
    max_hp_fixed_to = "value_float",
}

---@class hp_fixer_vars
---@field hp_fixed_to number
---@field max_hp_fixed_to number

---@param mb_utils mb_utils
return function(mb_utils)
    local player_child = tl.entity_with_name(player_child_name)
    if player_child then
        local _, right_click = mb_utils.button()
        if right_click then
            gui_elems.sound_button_clicked()
            player_child:kill()
        end

        local vars = var.access(player_child.id, var_map, "") --[[@as hp_fixer_vars]]
        pop.tooltip(module_tr.fixed_to:text(format.decimal(vars.hp_fixed_to, 2),
            format.decimal(vars.max_hp_fixed_to, 2)))

        pop.pos.push(-2, -2)
        pop.image "%MOD_PATH%/files/gui_main/locked.png"
        pop.pos.pop()
    else
        if pop.button "%MODULE_PATH%/button.png" then
            gui_elems.sound_button_clicked()
            if common_val.shift then
                player_child = tl.entity_load_child("%MODULE_PATH%/hp_fixer.xml", common_val.player)
                player_child.name = player_child_name
            else
                local dm_comp = common_val.player:comp_first "DamageModelComponent"
                if dm_comp then
                    local max_hp = dm_comp.max_hp
                    dm_comp.hp = max_hp
                end
            end
        end
        pop.tooltip(module_tr:key())
    end
end
