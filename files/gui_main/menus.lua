local pop = require "pop"
local tr = require "tr"
local tr_utils = require "tr_utils"
local gui_elems = require "gui.elems"

---@class menus
---@field private active string?
local menus = {}

---@param menu string
---@return boolean
function menus:is_active(menu)
    return menu == self.active
end

---@param menu string
---@return boolean is_now_active
function menus:set_active(menu)
    if self:is_active(menu) then
        self.active = nil
        return false
    else
        self.active = menu
        return true
    end
end

local pattern_menu_gui_path = "%MOD_PATH%/files/%s/menu.lua"

function menus:menu()
    if self.active == nil then return end
    dofile_once(pattern_menu_gui_path:format(self.active)).menu()
end

function menus:buttons()
    if self.active == nil then return end
    dofile_once(pattern_menu_gui_path:format(self.active)).buttons()
end

---@param module_id string
---@param filepath string
---@param option_text string?
---@return boolean
---@return boolean
function menus:button(module_id, filepath, option_text)
    if module_id ~= self.active then
        pop.option_next "DrawSemiTransparent"
    end
    option_text = tr_utils.maybe(option_text or tr_utils.key(module_id))
    local changed = false
    if module_id == self.active then
        if pop.button(filepath) then
            gui_elems.sound_button_clicked()
            self:set_active ""
            changed = true
        end
        pop.tooltip(tr.general.option_disable:text(option_text))
    else
        if pop.button(filepath) then
            gui_elems.sound_button_clicked()
            self:set_active(module_id)
            changed = true
        end
        pop.tooltip(tr.general.option_enable:text(option_text))
    end
    return changed, module_id == self.active
end

return menus
