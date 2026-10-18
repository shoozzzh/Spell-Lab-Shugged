local mutils = require "misc_utils"

---@type fun(): entity_id?
return mutils.get_globals "%MOD_PATH%/files/gui/get_player.lua".get_player
