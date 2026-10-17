local pop = require "pop"
local gui_elems = require "gui.elems"
local tr = require "tr"
local sc = require "shortcuts"
local dt = require "dummy_transforming"

---@param mb_utils mb_utils
return function(mb_utils)
    if not dt.armed then
        pop.option_next "DrawSemiTransparent"
    end
    if mb_utils.button() then
        gui_elems.sound_button_clicked()
        dt.armed = not dt.armed
    end
    pop.tooltip(tr["%MODULE_ID%"]:text(sc.text.transform_mortal_into_dummy))
end
