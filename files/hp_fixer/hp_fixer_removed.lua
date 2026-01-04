dofile_once( "data/scripts/lib/utilities.lua" )
local entity_id = GetUpdatedEntityID()
local player_id = EntityGetParent( entity_id )
local comp = get_variable_storage_component( entity_id, "wait_for_kill_flag_on_death" )
if not comp then return end
local damage_model = EntityGetFirstComponentIncludingDisabled( player_id, "DamageModelComponent" )
if not damage_model then return end
local wait_for_kill_flag_on_death = ComponentGetValue2( comp, "value_bool" )
ComponentSetValue2( damage_model, "wait_for_kill_flag_on_death", wait_for_kill_flag_on_death )