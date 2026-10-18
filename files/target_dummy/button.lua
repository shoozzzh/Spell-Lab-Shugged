local pop = require "pop"
local gui_elems = require "gui.elems"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local common_val = require "common_values"

local snap_gird_size = 10
local function snap(value)
    return math.floor(value / snap_gird_size + 0.5) * snap_gird_size
end

---@param mb_utils mb_utils
return function(mb_utils)
    local left_click, right_click = mb_utils.button()
    do
        if common_val.alt and pop.prev_hovered() then
            local x, y = unpack(common_val.world_dest_pos)
            x, y = snap(x), snap(y)

            -- nolla why do you have to do this
            GameCreateSpriteForXFrames("%MODULE_PATH%/target_dummy/sprite.png", x, y, false, 14, 10.5, 2, true)
        end
        if left_click or right_click then
            local x, y = unpack(common_val.world_dest_pos)
            if common_val.alt then
                x, y = snap(x), snap(y)
            end
            if left_click then
                EntityLoad("%MODULE_PATH%/entity.xml", x, y)
            elseif right_click then
                EntityLoad("%MODULE_PATH%/entity_final.xml", x, y)
            end
            gui_elems.sound_button_clicked()
        end
    end
    pop.tooltip_custom(3, 0, true)(function()
        local layout = pop.layout_stack(0, pop.text_line_height)
        for line in module_tr.tooltip:text():gmatch "[^\n]+" do
            layout:next(function()
                pop.text(line)
            end)
        end

        layout:shift(0, 6)

        layout:next(function() pop.text(module_tr.numbers_are:key()) end)
        layout:next(function()
            pop.text(module_tr.last_frame_damage:key(), { color = { r = 0, g = 207, b = 40, a = 255 } })
        end)
        layout:next(function()
            pop.text(module_tr.average_dps:key(), { color = { r = 208, g = 208, b = 248, a = 255 } })
        end)
        layout:next(function()
            pop.text(module_tr.total_damage:key(), { color = { r = 255, g = 85, b = 0, a = 255 } })
        end)
        layout:next(function()
            pop.text(module_tr.dps:key(), { color = { r = 208, g = 208, b = 248, a = 255 } })
        end)
        layout:next(function()
            pop.text(module_tr.highest_dps:key(), { color = { r = 126, g = 126, b = 126, a = 255 } })
        end)
    end)
end
