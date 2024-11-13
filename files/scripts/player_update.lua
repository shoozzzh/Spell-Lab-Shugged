local entity_id = GetUpdatedEntityID()

local mod_setting_prefix = "spell_lab_shugged."

settings = settings or {}
if GlobalsGetValue( "spell_lab_shugged.refresh_player_state", "0" ) == "1" then
	settings = {}
	GlobalsSetValue( "spell_lab_shugged.refresh_player_state", "0" )
end

on_setting_turning_on = on_setting_turning_on or function( setting_name )
	local result = not settings[ setting_name ] and ModSettingGet( mod_setting_prefix .. setting_name )
	if result then
		settings[ setting_name ] = true
	end
	return result
end
on_setting_turning_off = on_setting_turning_off or function( setting_name )
	local result = settings[ setting_name ] and not ModSettingGet( mod_setting_prefix .. setting_name )
	if result then
		settings[ setting_name ] = false
	end
	return result
end

if settings[ "no_polymorphing" ] == nil then
	settings[ "no_polymorphing" ] = EntityGetWithName( "spell_lab_shugged_no_polymorphing" ) ~= 0
end

if on_setting_turning_on( "no_polymorphing" ) then
	local effect_entity = EntityCreateNew( "spell_lab_shugged_no_polymorphing" )
	EntityAddChild( entity_id, effect_entity )
	EntityAddComponent2( effect_entity, "InheritTransformComponent" )
	EntityAddComponent2( effect_entity, "GameEffectComponent", {
		effect = "PROTECTION_POLYMORPH",
		frames = -1,
	} )
elseif on_setting_turning_off( "no_polymorphing" ) then
	EntityKill( EntityGetWithName( "spell_lab_shugged_no_polymorphing" ) )
end

if settings[ "invincible" ] == nil then
	settings[ "invincible" ] = EntityGetWithName( "spell_lab_shugged_invincible" ) ~= 0
end

if on_setting_turning_on( "invincible" ) then
	local effect_entity = EntityCreateNew( "spell_lab_shugged_invincible" )
	EntityAddChild( entity_id, effect_entity )
	EntityAddComponent2( effect_entity, "InheritTransformComponent" )
	EntityAddComponent2( effect_entity, "GameEffectComponent", {
		effect = "PROTECTION_ALL",
		frames = -1,
	} )
elseif on_setting_turning_off( "invincible" ) then
	EntityKill( EntityGetWithName( "spell_lab_shugged_invincible" ) )
end

if settings[ "disable_toxic_statuses" ] == nil then
	settings[ "disable_toxic_statuses" ] = EntityHasTag( entity_id, "glue_NOT" )
end

if on_setting_turning_on( "disable_toxic_statuses" ) then
	EntityAddTag( entity_id, "glue_NOT" )
elseif on_setting_turning_off( "disable_toxic_statuses" ) then
	EntityRemoveTag( entity_id, "glue_NOT" )
end

-- broad-spectrum protection
if ModSettingGet( mod_setting_prefix .. "disable_toxic_statuses" ) then
	local toxic_game_effects = {
		TELEPORTATION          = true,
		UNSTABLE_TELEPORTATION = true,
		BLINDNESS              = true,
		CONFUSION              = true,
		MOVEMENT_SLOWER        = true,
		FROZEN                 = true,
		ELECTROCUTION          = true,
	}
	for _, child_id in ipairs( EntityGetAllChildren( entity_id ) or {} ) do
		if EntityHasTag( child_id, "spell_lab_shugged_non_toxic_status" ) then goto continue end

		local effect_comp = EntityGetFirstComponentIncludingDisabled( child_id, "GameEffectComponent" )
		if not effect_comp then goto continue end

		local game_effect_id = ComponentGetValue2( effect_comp, "effect" )
		if not toxic_game_effects[ game_effect_id ] then goto continue end

		ComponentSetValue2( effect_comp, "frames", 0 )
		::continue::
	end
end

if settings[ "creative_mode_flight" ] == nil then
	settings[ "creative_mode_flight" ] = EntityGetWithName( "spell_lab_shugged_flight_overwritten_values" ) ~= 0
end

flight_overwritten_fields = flight_overwritten_fields or {
	"run_velocity",
	"fly_velocity_x",
	"fly_speed_max_up",
	"fly_speed_max_down",
	"velocity_max_x",
	"velocity_max_y",
}
flight_overwritten_fields2 = flight_overwritten_fields2 or {
	velocity_min_x = -200,
	velocity_min_y = -200,
	pixel_gravity = 0,
	swim_idle_buoyancy_coeff = 0,
	swim_down_buoyancy_coeff = 0,
	swim_up_buoyancy_coeff = 0,
	fly_speed_change_spd = 0,
	swim_drag = 1,
	swim_extra_horizontal_drag = 1,
}

local flight_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "LuaComponent", "spell_lab_shugged_creative_mode_flight" )
	or EntityAddComponent2( entity_id, "LuaComponent", {
		_tags = "spell_lab_shugged_creative_mode_flight",
		_enabled = false,
		script_source_file = "mods/spell_lab_shugged/files/scripts/creative_mode_flight.lua",
		execute_every_n_frame = 1,
	} )

if on_setting_turning_on( "creative_mode_flight" ) then
	local cp_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
	if cp_comp then
		local values_entity = EntityLoad( "mods/spell_lab_shugged/files/entities/flight_overwritten_values.xml" )
		EntityAddChild( entity_id, values_entity )
		local values_comp = EntityGetFirstComponentIncludingDisabled( values_entity, "CharacterPlatformingComponent" )
		for _, field_name in ipairs( flight_overwritten_fields ) do
			ComponentSetValue2( values_comp, field_name, ComponentGetValue2( cp_comp, field_name ) )
			ComponentSetValue2( cp_comp, field_name, 200 )
		end
		for field_name, value in pairs( flight_overwritten_fields2 ) do
			ComponentSetValue2( values_comp, field_name, ComponentGetValue2( cp_comp, field_name ) )
			ComponentSetValue2( cp_comp, field_name, value )
		end
	end
	EntitySetComponentIsEnabled( entity_id, flight_comp, true )
elseif on_setting_turning_off( "creative_mode_flight" ) then
	local cp_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
	if cp_comp then
		local values_entity = EntityGetWithName( "spell_lab_shugged_flight_overwritten_values" )
		if values_entity ~= 0 then
			local values_comp = EntityGetFirstComponentIncludingDisabled( values_entity, "CharacterPlatformingComponent" )
			for _, field_name in ipairs( flight_overwritten_fields ) do
				ComponentSetValue2( cp_comp, field_name, ComponentGetValue2( values_comp, field_name ) )
			end
			for field_name, _ in pairs( flight_overwritten_fields2 ) do
				ComponentSetValue2( cp_comp, field_name, ComponentGetValue2( values_comp, field_name ) )
			end
			EntityKill( values_entity )
		end
	end
	EntitySetComponentIsEnabled( entity_id, flight_comp, false )
end

if settings[ "better_all_seeing_eye" ] == nil then
	settings[ "better_all_seeing_eye" ] = EntityGetWithName( "spell_lab_shugged_better_all_seeing_eye" ) ~= 0
end

if on_setting_turning_on( "better_all_seeing_eye" ) then
	EntityAddChild( entity_id, EntityLoad( "mods/spell_lab_shugged/files/entities/better_all_seeing_eye.xml" ) )
elseif on_setting_turning_off( "better_all_seeing_eye" ) then
	EntityKill( EntityGetWithName( "spell_lab_shugged_better_all_seeing_eye" ) )
end