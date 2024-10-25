local old_shot = shot
function shot( ... )
	local root_id = EntityGetRootEntity( GetUpdatedEntityID() )
	if EntityHasTag( root_id, "player_unit" ) and ModSettingGet( "spell_lab_shugged.disable_toxic_statuses" ) then
		EntityKill( GetUpdatedEntityID() )
	else
		old_shot( ... )
	end
end