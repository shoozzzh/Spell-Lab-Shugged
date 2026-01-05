		local desc = wrap_key( "creative_mode_flight_description" )
		if DebugGetIsDevBuild() then
			desc = GameTextGetTranslatedOrNot( desc ) .. "\n" .. text_get_translated( "creative_mode_flight_note_dev_exe" )
		end
		do_flag_toggle_image_button( "mods/spell_lab_shugged/files/gui/buttons/creative_mode_flight.png", "creative_mode_flight", nil, nil, desc )