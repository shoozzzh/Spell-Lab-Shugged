local utils = dofile_once "%THIS_PATH%/utils.lua"

local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)

local vars = utils.access_vars(parent_id)

utils.set_text(entity_id, "current_dps", vars.current_dps)
vars.current_dps = 0

utils.set_text(entity_id, "highest_dps", vars.highest_dps)

EntitySetComponentIsEnabled(entity_id, GetUpdatedComponentID(), false)
