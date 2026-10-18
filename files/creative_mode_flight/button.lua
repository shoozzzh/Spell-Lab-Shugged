local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])

---@param mb_utils mb_utils
return function(mb_utils)
    if DebugGetIsDevBuild() then
        mb_utils.button_toggle(nil, false, module_tr.note_dev_exe:key())
    else
        mb_utils.button_toggle(nil, false)
    end
end
