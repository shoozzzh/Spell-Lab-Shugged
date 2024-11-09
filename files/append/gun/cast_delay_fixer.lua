local _StartReload = StartReload
function StartReload( reload_time )
	do
		if not EntityHasTag( GetUpdatedEntityID(), "player_unit" ) then goto skip end

		if GlobalsGetValue( "spell_lab_shugged.wand_reload_time_fixed_to_raw_value", "0" ) == "1" then
			reload_time = gun.reload_time
			goto skip
		end

		local reload_time_fixed_to = GlobalsGetValue( "spell_lab_shugged.wand_reload_time_fixed_to", "" )
		if reload_time_fixed_to == "" then goto skip end

		reload_time_fixed_to = tonumber( reload_time_fixed_to )
		if not reload_time_fixed_to then goto skip end

		reload_time = reload_time_fixed_to
	end
	
	::skip::
	_StartReload( reload_time )
end

local _register_action = register_action
function register_action( ... )
	local fire_rate_wait_saved = nil
	do
		if not EntityHasTag( GetUpdatedEntityID(), "player_unit" ) then goto skip end

		if GlobalsGetValue( "spell_lab_shugged.wand_cast_delay_fixed_to_raw_value", "0" ) == "1" then
			c.fire_rate_wait = state_from_game.fire_rate_wait
			goto skip
		end

		local cast_delay_fixed_to = GlobalsGetValue( "spell_lab_shugged.wand_cast_delay_fixed_to", "" )
		if cast_delay_fixed_to == "" then goto skip end

		cast_delay_fixed_to = tonumber( cast_delay_fixed_to )
		if not cast_delay_fixed_to then goto skip end

		fire_rate_wait_saved = c.fire_rate_wait
		c.fire_rate_wait = cast_delay_fixed_to
	end
	
	::skip::
	_register_action( ... )

	if fire_rate_wait_saved then
		c.fire_rate_wait = fire_rate_wait_saved
	end
end