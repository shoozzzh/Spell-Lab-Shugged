local tr = require "tr"
local pop = require "pop"
local sc = require "shortcuts"

---@param mb_utils mb_utils
return function(mb_utils)
    mb_utils.button()
    pop.tooltip(tr.shortcut_tips_title:key(), sc.edit_panel_shortcut_tips)
end
