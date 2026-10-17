local pop = require "pop"
local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])
local gui_elems = require "gui.elems"
local common_val = require "common_values"
local tl = require "tinklin"

local globals_x = "%MODULE_ID%.previous_pos.x"
local globals_y = "%MODULE_ID%.previous_pos.y"

---@param mb_utils mb_utils
return function(mb_utils)
    if GlobalsGetValue(globals_x, "NONE") == "NONE" then
        pop.option_next "DrawSemiTransparent"
    end

    mb_utils.button()

    local left_click, right_click = pop.prev_clicked()
    if left_click then
        local player = common_val.player
        if player then
            gui_elems.sound_button_clicked()
            if GlobalsGetValue(globals_x, "0") == "0" then
                local px, py = unpack(player.pos)
                GlobalsSetValue(globals_x, ("%.0f"):format(px))
                GlobalsSetValue(globals_y, ("%.0f"):format(py))
                player.pos = tl.vec(14600, -6050)
                GameSetCameraPos(14600, -6050)
            else
                if not common_val.shift then
                    local cx = tonumber(GlobalsGetValue(globals_x, "0"))
                    local cy = tonumber(GlobalsGetValue(globals_y, "0")) - 10
                    player.pos = tl.vec(cx, cy)
                    player:apply_xform()
                    GameSetCameraPos(cx, cy)
                else
                    player.pos = tl.vec(250, -100)
                    player:apply_xform()
                    GameSetCameraPos(250, -100)
                end
                GlobalsSetValue(globals_x, "0")
                GlobalsSetValue(globals_y, "0")
            end
        end
    elseif right_click then
        if GlobalsGetValue(globals_x, "NONE") ~= "NONE" then
            gui_elems.sound_button_clicked()
            EntityLoad("%MODULE_PATH%/lazy_loader/entity.xml", 14600, -6000)
        end
    end

    if GlobalsGetValue(globals_x, "NONE") == "NONE" then
        pop.tooltip(module_tr.enter:key())
    else
        pop.tooltip(module_tr.leave:key(), module_tr.desc:key())
    end
end
