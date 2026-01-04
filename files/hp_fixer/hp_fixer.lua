dofile_once( "data/scripts/lib/utilities.lua" )
local entity_id = GetUpdatedEntityID()
local player_id = EntityGetParent( entity_id )
local damage_model = EntityGetFirstComponentIncludingDisabled( player_id, "DamageModelComponent" )
if not damage_model then return end
local hp_comp = get_variable_storage_component( entity_id, "hp" )
local max_hp_comp = get_variable_storage_component( entity_id, "max_hp" )
if not hp_comp or not max_hp_comp then
	hp = ComponentGetValue2( damage_model, "hp" )
	max_hp = ComponentGetValue2( damage_model, "max_hp" )
	EntityAddComponent2( entity_id, "VariableStorageComponent", { name = "hp", value_float = hp } )
	EntityAddComponent2( entity_id, "VariableStorageComponent", { name = "max_hp", value_float = max_hp } )
	local wait_for_kill_flag_on_death = ComponentGetValue2( damage_model, "wait_for_kill_flag_on_death" )
	EntityAddComponent2( entity_id, "VariableStorageComponent",
		{ name = "wait_for_kill_flag_on_death", value_bool = wait_for_kill_flag_on_death } )
	ComponentSetValue2( damage_model, "wait_for_kill_flag_on_death", true )
	return
end
local hp = ComponentGetValue2( hp_comp, "value_float" )
local max_hp = ComponentGetValue2( max_hp_comp, "value_float" )
ComponentSetValue2( damage_model, "hp", hp )
ComponentSetValue2( damage_model, "max_hp", max_hp )