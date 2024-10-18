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

if settings[ "force_2gcedge" ] == nil then
	settings[ "force_2gcedge" ] = #EntityGetAllChildren( entity_id, "spell_lab_shugged_force_2gcedge" ) > 0
end

if on_setting_turning_on( "force_2gcedge" ) then
	local effects = { "DAMAGE_MULTIPLIER", "DAMAGE_MULTIPLIER", "LOW_HP_DAMAGE_BOOST" }
	for k,v in pairs( effects ) do
		local effect = GetGameEffectLoadTo( entity_id, v, true )
		ComponentSetValue2( effect, "frames", -1 )
		EntityAddTag( ComponentGetEntity( effect ), "spell_lab_shugged_force_2gcedge" )
	end
	local damage_models = EntityGetComponent( entity_id, "DamageModelComponent" )
	for index,damage_model in pairs( damage_models or {} ) do
		local max_hp = ComponentGetValue2( damage_model, "max_hp" )
		ComponentSetValue2( damage_model, "hp", max_hp / 5 )
	end
elseif on_setting_turning_off( "force_2gcedge" ) then
	for _, child_id in ipairs( EntityGetAllChildren( entity_id, "spell_lab_shugged_force_2gcedge" ) or {} ) do
		EntityKill( child_id )
	end
	local damage_models = EntityGetComponent( entity_id, "DamageModelComponent" )
	for index,damage_model in pairs( damage_models or {} ) do
		local max_hp = ComponentGetValue2( damage_model, "max_hp" )
		ComponentSetValue2( damage_model, "hp", max_hp )
	end
end

if settings[ "no_polymorphing" ] == nil then
	settings[ "no_polymorphing" ] = EntityHasTag( entity_id, "polymorphable_NOT" )
end

if on_setting_turning_on( "no_polymorphing" ) then
	EntityAddTag( entity_id, "polymorphable_NOT" )
elseif on_setting_turning_off( "no_polymorphing" ) then
	if not GameHasFlagRun( "ending_game_completed_with_34_orbs" ) then
		EntityRemoveTag( entity_id, "polymorphable_NOT" )
	end
end

if settings[ "invincible" ] == nil then
	settings[ "invincible" ] = EntityGetWithName( "spell_lab_shugged_invincible" ) ~= 0
end

if on_setting_turning_on( "invincible" ) then
	local effect = GetGameEffectLoadTo( entity_id, "PROTECTION_ALL", true )
	ComponentSetValue2( effect, "frames", -1 )
	EntitySetName( ComponentGetEntity( effect ), "spell_lab_shugged_invincible" )
	-- EntityAddComponent2( ComponentGetEntity( effect ), "UIIconComponent", {
	-- 	icon_sprite_file="data/ui_gfx/status_indicators/protection_all.png",
	-- 	name="$status_protection_all",
	-- 	description="$statusdesc_protection_all",
	-- 	is_perk=false,
	-- } )
elseif on_setting_turning_off( "invincible" ) then
	EntityKill( EntityGetWithName( "spell_lab_shugged_invincible" ) )
end

if settings[ "disable_casting" ] == nil then
	settings[ "disable_casting" ] = EntityGetFirstComponent( entity_id, "GunComponent" ) == nil
end

if on_setting_turning_on( "disable_casting" ) then
	local gun_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "GunComponent" )
	if gun_comp then
		EntitySetComponentIsEnabled( entity_id, gun_comp, false )
	end
elseif on_setting_turning_off( "disable_casting" ) then
	local gun_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "GunComponent" )
	if gun_comp then
		EntitySetComponentIsEnabled( entity_id, gun_comp, true )
	end
end

if settings[ "disable_toxic_statuses" ] == nil then
	settings[ "disable_toxic_statuses" ] = EntityHasTag( entity_id, "glue_NOT" )
end

if on_setting_turning_on( "disable_toxic_statuses" ) then
	EntityAddTag( entity_id, "glue_NOT" )
elseif on_setting_turning_off( "disable_toxic_statuses" ) then
	EntityRemoveTag( entity_id, "glue_NOT" )
end

if ModSettingGet( mod_setting_prefix .. "disable_toxic_statuses" ) then
	local toxic_statuses = {
		"TELEPORTATION",
		"UNSTABLE_TELEPORTATION",
		"BLINDNESS",
		"MOVEMENT_SLOWER",
		"CONFUSION",
		"FROZEN",
		"ELECTROCUTION",
	}
	for _, status_name in ipairs( toxic_statuses ) do
		local effect = GameGetGameEffect( entity_id, status_name )
		while effect ~= 0 do
			if ComponentGetValue2( effect, "disable_movement" ) then
				local ctrl_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "ControlsComponent" )
				ComponentSetValue2( ctrl_comp, "enabled", true )
			end
			EntityKill( ComponentGetEntity( effect ) )
			effect = GameGetGameEffect( entity_id, status_name )
		end
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