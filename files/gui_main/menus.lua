local pop = require "pop"
local tr = require "tr"
local tr_utils = require "tr_utils"
local gui_elems = require "gui.elems"

---@class menus
local menus = {
    active = "",
}

function menus:is_active(picker)
    return picker == self.active
end

function menus:set_active(picker)
    local result = picker == self.active
    if result then picker = "" end
    self.active = picker
    return result
end

local menu_path = "%MOD_PATH%/files/%s/menu.lua"
function menus:menu()
    dofile_once(menu_path:format(self.active))()
end

local buttons_path = "%MOD_PATH%/files/%s/buttons.lua"
function menus:buttons()
    dofile_once(buttons_path:format(self.active))()
end

---@param module_name string
---@param filepath string
---@param option_text string?
---@return boolean
---@return boolean
function menus:button(module_name, filepath, option_text)
    if module_name ~= self.active then
        pop.option_next "DrawSemiTransparent"
    end
    option_text = tr_utils.maybe(option_text or tr_utils.key(module_name))
    local changed = false
    if module_name == self.active then
        if pop.button(filepath) then
            gui_elems.sound_button_clicked()
            self:set_active ""
            changed = true
        end
        pop.tooltip(tr.general.option_disable:text(option_text))
    else
        if pop.button(filepath) then
            gui_elems.sound_button_clicked()
            self:set_active(module_name)
            changed = true
        end
        pop.tooltip(tr.general.option_enable:text(option_text))
    end
    return changed, module_name == self.active
end

return menus
