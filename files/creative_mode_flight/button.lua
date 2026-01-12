		local desc = wrap_key( "creative_mode_flight_description" )
		if DebugGetIsDevBuild() then
			desc = GameTextGetTranslatedOrNot( desc ) .. "\n" .. get_text( "creative_mode_flight_note_dev_exe" )
		end
		gui_elements.flag_toggle_button( "mods/spell_lab_shugged/files/gui/buttons/creative_mode_flight.png", "creative_mode_flight", nil, nil, desc )