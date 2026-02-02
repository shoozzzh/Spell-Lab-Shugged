dofile_once "mods/spell_lab_shugged/files/misc_utils.lua"

local module_path = module_path()

function interacting( entity_who_interacted, entity_interacted, interactable_name )
	EntityKill( entity_interacted )
	EntityLoad( module_path .. "lazy_loader/entity.xml", 14600, -6000 )
end
