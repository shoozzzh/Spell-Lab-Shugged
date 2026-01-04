local entity_id = GetUpdatedEntityID()
local child_id = EntityLoad( "mods/spell_lab_shugged/files/entities/dummy_target/dummy_target_child.xml" )
EntityAddChild( entity_id, child_id )