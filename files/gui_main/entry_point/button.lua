local pop = require "pop"
local mutils = require "misc_utils"
local settings = require "mod_settings"
local gui_elems = require "gui.elems"
local tr = require "tr"
local this_tr = tr.as_prefix(tr.main_gui.entry_point)

local button_image = "%THIS_PATH%/button.png"
local button_width, button_height = mutils.get_image_size(button_image)
local button_x, button_y, dragging, last_dragging

local is_panel_open = false

return function()
    if not button_x then
        button_x = settings.get_or_default("gui_entry_point_x", pop.screen_size[1] - button_width - 3)
        button_y = settings.get_or_default("gui_entry_point_y", 3)
    end

    pop.pos.push(button_x, button_y)
    button_x, button_y, dragging = pop.draggable_space(button_width, button_height, true)

    if last_dragging and not dragging then
        settings.set("gui_entry_point_x", button_x)
        settings.set("gui_entry_point_y", button_y)
    end
    last_dragging = dragging

    if pop.button(button_image) and not dragging then
        gui_elems.sound_button_clicked()
        is_panel_open = not is_panel_open
    end
    pop.pos.pop()

    if not dragging then
        pop.tooltip_custom(3, 10, true)(function()
            local layout = pop.layout_stack(0, pop.text_line_height)

            layout:next(function()
                pop.text(is_panel_open and this_tr.hide:key() or this_tr.show:key())
            end)

            layout:next(function() gui_elems.text_dim(MOD_VERSION) end)

            layout:next(function() gui_elems.text_dim(this_tr.desc:key()) end)
        end)
    end

    return is_panel_open
end
