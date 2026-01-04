local error_msg = nil
local mx, my = DEBUG_GetMouseWorld()
local mortal_id = EntityGetClosestWithTag( mx, my, "mortal" )
local mortal_x, mortal_y = EntityGetTransform( mortal_id )
if not is_valid_entity( mortal_id ) or ( mx - mortal_x ) ^ 2 + ( my - mortal_y ) ^ 2 > 1600 then
	mortal_id = EntityGetClosestWithTag( mx, my, "enemy" )
	mortal_x, mortal_y = EntityGetTransform( mortal_id )
	if not is_valid_entity( mortal_id ) or ( mx - mortal_x ) ^ 2 + ( my - mortal_y ) ^ 2 > 1600 then
		error_msg = text_get_translated( "transform_mortal_failed_no_mortal_found" )
	end
end
if EntityHasTag( mortal_id, "player_unit" ) or EntityHasTag( mortal_id, "polymorphed_player" ) then
	error_msg = text_get_translated( "transform_mortal_failed_cant_transform_player" )
end
if EntityHasTag( mortal_id, "spell_lab_shugged_target_dummy" ) then
	error_msg = text_get_translated(  "transform_mortal_failed_already_transformed" )
end
if not error_msg then
	-- GameDropAllItems( mortal_id )
	local comp_names_to_disable = {
		"AnimalAIComponent",
		"PhysicsAIComponent",
		"FishAIComponent",
		"AdvancedFishAIComponent",
		"BossDragonComponent",
		"WormComponent",
		"WormAIComponent",
		"BossHealthBarComponent",
		"CameraBoundComponent",
	}
	for _, comp_name in ipairs( comp_names_to_disable ) do
		for _, c in ipairs( EntityGetComponent( mortal_id, comp_name ) or {} ) do
			EntitySetComponentIsEnabled( mortal_id, c, false )
		end
	end
	for _, ctrl_comp in ipairs( EntityGetComponentIncludingDisabled( mortal_id, "ControlsComponent" ) or {} ) do
		ComponentSetValue2( ctrl_comp, "enabled", false )
	end
	local cp_comp = EntityGetFirstComponentIncludingDisabled( mortal_id, "CharacterPlatformingComponent" )
	if cp_comp then
		for _, field_name in ipairs( {
			"velocity_min_x",
			"velocity_min_y",
			"velocity_max_x",
			"velocity_max_y",
			"pixel_gravity",
			"run_velocity",
			"fly_velocity_x",
			"fly_speed_up",
			"fly_speed_down",
		} ) do
			ComponentSetValue2( cp_comp, field_name, 0 )
		end
	end
	local cd_comp = EntityGetFirstComponentIncludingDisabled( mortal_id, "CharacterDataComponent" )
	if cd_comp then
		ComponentSetValue2( cd_comp, "mVelocity", 0, 0 )
	end
	for _, pbody_id in ipairs( PhysicsBodyIDGetFromEntity( mortal_id ) ) do
		PhysicsBodyIDSetGravityScale( pbody_id, 0 )
		local x, y, a = PhysicsBodyIDGetTransform( pbody_id )
		PhysicsBodyIDSetTransform( pbody_id, x, y, a, 0, 0 )
	end
	local dm_comp = EntityGetFirstComponentIncludingDisabled( mortal_id, "DamageModelComponent" )
	if dm_comp then
		ComponentSetValue2( dm_comp, "wait_for_kill_flag_on_death", true )
	end
	dm_comp = EntityGetFirstComponent( mortal_id, "DamageModelComponent" )
	if dm_comp then
		ComponentSetValue2( dm_comp, "wait_for_kill_flag_on_death", true )
	end
	EntityAddComponent2( mortal_id, "LuaComponent", {
		_tags="enabled_in_world",
		script_source_file = "mods/spell_lab_shugged/files/scripts/transformed_mortal_update.lua",
		execute_every_n_frame = 1,
	} )
	EntityLoadToEntity( "mods/spell_lab_shugged/files/entities/dummy_target/base_dummy_target.xml", mortal_id )
	EntityAddTag( mortal_id, "spell_lab_shugged_target_dummy" )
	GamePrint( GameTextGet( wrap_key( "transform_mortal_succeeded" ), GameTextGetTranslatedOrNot( EntityGetName( mortal_id ) ) ) )
else
	GamePrint( error_msg )
end