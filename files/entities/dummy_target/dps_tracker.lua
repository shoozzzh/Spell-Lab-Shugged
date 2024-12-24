dofile_once( "mods/spell_lab_shugged/files/lib/helper.lua" )
dofile_once( "mods/spell_lab_shugged/files/lib/variables.lua" )
dofile_once( "data/scripts/lib/utilities.lua" )

local function set_text( entity_id, tag_sprite, value, offset_y )
	local child_id = ( EntityGetAllChildren( entity_id, "spell_lab_shugged_dummy_target_child" ) or {} )[1]
	if not EntityGetIsAlive( child_id ) then return end
	local sprite_comp = EntityGetFirstComponent( child_id, "SpriteComponent", tag_sprite )
	if not sprite_comp then return end
	local text = format_damage( value, not ModSettingGet( "spell_lab_shugged.dummy_target_show_full_damage_number" ), "i" )
	ComponentSetValue2( sprite_comp, "offset_x", center_text( text ) )
	ComponentSetValue2( sprite_comp, "text", text )
	EntityRefreshSprite( entity_id, sprite_comp )
end

function damage_received( damage, message, entity_thats_responsible, is_fatal )
	local now = GameGetFrameNum()
	local entity_id = GetUpdatedEntityID()

	local damage_model = EntityGetFirstComponent( entity_id, "DamageModelComponent" )
	if damage_model then
		local max_hp = ComponentGetValue2( damage_model, "max_hp" )
		ComponentSetValue2( damage_model, "max_hp", 4 )
		ComponentSetValue2( damage_model, "hp", math.max( 4, damage * 1.1 ) )
	end
	local last_hit_frame_comp = get_variable_storage_component( entity_id, "spell_lab_shugged_last_hit_frame" )
	local last_hit_frame = ComponentGetValue2( last_hit_frame_comp, "value_int" )
	ComponentSetValue2( last_hit_frame_comp, "value_int", now )
	local reset = ( now - last_hit_frame > 180 )

	local first_hit_frame_comp = get_variable_storage_component( entity_id, "spell_lab_shugged_first_hit_frame" )
	local first_hit_frame = ComponentGetValue2( first_hit_frame_comp, "value_int" )
	if reset then
		ComponentSetValue2( first_hit_frame_comp, "value_int", now )
		first_hit_frame = now
	end

	local current_dps_comp = get_variable_storage_component( entity_id, "spell_lab_shugged_current_dps" )
	local current_dps = ComponentGetValue2( current_dps_comp, "value_float" )
	current_dps = current_dps + damage
	ComponentSetValue2( current_dps_comp, "value_float", current_dps )

	local highest_dps_comp = get_variable_storage_component( entity_id, "spell_lab_shugged_highest_dps" )
	local highest_dps = reset and 0 or ComponentGetValue2( highest_dps_comp, "value_float" )
	if current_dps > highest_dps then
		ComponentSetValue2( highest_dps_comp, "value_float", current_dps )
	end
	
	local total_damage_comp = get_variable_storage_component( entity_id, "spell_lab_shugged_total_damage" )
	local total_damage = ( reset and 0 or ComponentGetValue2( total_damage_comp, "value_float" ) ) + damage
	ComponentSetValue2( total_damage_comp, "value_float", total_damage )
	set_text( entity_id, "spell_lab_shugged_total_damage", total_damage )

	local average_dps = total_damage / ( now - first_hit_frame + 1 ) * 60
	set_text( entity_id, "spell_lab_shugged_average_dps", average_dps )

	local child_id = EntityGetAllChildren( entity_id, "spell_lab_shugged_dummy_target_child" )
	if EntityGetIsAlive( child_id ) then
		EntitySetComponentsWithTagEnabled( child_id, "invincible", true )
	end
end