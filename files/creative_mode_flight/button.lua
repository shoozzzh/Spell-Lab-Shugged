local tr = require "tr"
local module_tr = tr.as_prefix(tr["%MODULE_ID%"])

---@param mb_utils mb_utils
return function(mb_utils)
    if DebugGetIsDevBuild() then
        mb_utils.button_toggle(nil, module_tr.desc:key(), module_tr.note_dev_exe:key())
    else
        mb_utils.button_toggle(nil, module_tr.desc:key())
    end
end
