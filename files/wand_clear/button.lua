local tr = require "tr"
local gui_elems = require "gui.elems"
local pop = require "pop"
local common_val = require "common_values"
local wand_utils = require "wand_utils"

---@param mb_utils mb_utils
return function(mb_utils)
    if mb_utils.button() then
        if common_val.held_wand then
            gui_elems.sound_button_clicked()
            wand_utils.clear(common_val.held_wand)
        end
    end
    pop.tooltip(tr["%MODULE_ID%"]:key())
end
