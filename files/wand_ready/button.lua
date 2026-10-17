local pop = require "pop"
local gui_elems = require "gui.elems"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local format = require "format"
local common_val = require "common_values"

local key_raw_value = "%MOD_ID%.wand_cast_delay_fixed_to_raw_value"
local key_cast_delay = "%MOD_ID%.wand_cast_delay_fixed_to"
local key_reload_time = "%MOD_ID%.wand_reload_time_fixed_to"

---@param mb_utils mb_utils
return function(mb_utils)
    local fixed_to_raw_value = GlobalsGetValue(key_raw_value, "0") == "1"
    local cast_delay_fixed_to = tonumber(GlobalsGetValue(key_cast_delay, ""))
    local reload_time_fixed_to = tonumber(GlobalsGetValue(key_reload_time, ""))

    local left_click, right_click = mb_utils.button()
    if fixed_to_raw_value or (cast_delay_fixed_to and reload_time_fixed_to) then
        if left_click then
            if clear_held_wand_wait() then gui_elems.sound_button_clicked() end
        elseif right_click then
            if fixed_to_raw_value then
                GlobalsSetValue(key_raw_value, "")
                gui_elems.sound_button_clicked()
            elseif cast_delay_fixed_to and reload_time_fixed_to then
                GlobalsSetValue(key_cast_delay, "")
                GlobalsSetValue(key_reload_time, "")
                gui_elems.sound_button_clicked()
            end
        end

        if fixed_to_raw_value then
            local raw_value_text = module_tr.wand_raw_value:text()
            pop.tooltip(module_tr:key(), module_tr.cast_delay_fixed_to:text(raw_value_text, raw_value_text))
        elseif cast_delay_fixed_to and reload_time_fixed_to then
            pop.tooltip(module_tr:key(), module_tr.cast_delay_fixed_to:text(
                format.frames(cast_delay_fixed_to), format.frames(reload_time_fixed_to)))
        end

        pop.pos.push(-2, -2)
        pop.image "%MOD_PATH%/files/gui/locked.png"
        pop.pos.pop()
    else
        if common_val.shift and left_click then
            if common_val.held_wand then
                local ab_comp = common_val.held_wand:comp_first "AbilityComponent"
                if ab_comp then
                    local cast_delay = ab_comp:object "gunaction_config".fire_rate_wait
                    local reload_time = ab_comp:object "gunaction_config".reload_time
                    GlobalsSetValue(key_cast_delay, tostring(cast_delay))
                    GlobalsSetValue(key_reload_time, tostring(reload_time))
                    gui_elems.sound_button_clicked()
                end
            end
        elseif common_val.shift and right_click then
            GlobalsSetValue(key_cast_delay, "0")
            GlobalsSetValue(key_reload_time, "0")
            gui_elems.sound_button_clicked()
        elseif common_val.alt and (left_click or right_click) then
            GlobalsSetValue(key_raw_value, "1")
            gui_elems.sound_button_clicked()
        elseif left_click then
            if clear_held_wand_wait() then gui_elems.sound_button_clicked() end
        end
        pop.tooltip(module_tr:key(), module_tr.desc:key())
    end
end
