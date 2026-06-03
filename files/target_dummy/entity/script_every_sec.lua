dofile_once "mods/spell_lab_shugged/files/misc_utils.lua"

local module_path = module_path()
dofile_once( module_path .. "utils.lua" )

local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent( entity_id )

local vars = access_vars( parent_id )

set_text( entity_id, "current_dps", vars.current_dps )
vars.current_dps = 0

set_text( entity_id, "highest_dps", vars.highest_dps )

EntitySetComponentIsEnabled( entity_id, GetUpdatedComponentID(), false )
