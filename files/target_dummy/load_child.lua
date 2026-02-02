dofile_once "mods/spell_lab_shugged/files/misc_utils.lua"

local module_path = module_path()

local entity_id = GetUpdatedEntityID()
local child_id = EntityLoad( module_path .. "child.xml" )
EntityAddChild( entity_id, child_id )
