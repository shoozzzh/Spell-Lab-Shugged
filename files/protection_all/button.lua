local gui_elems = require "gui.elems"

return function()
    gui_elems.button_setting_toggle("%MODULE_PATH%/button.png", "%MODULE_ID%", "$status_protection_all")
end
