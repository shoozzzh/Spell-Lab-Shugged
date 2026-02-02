local module_path = this_folder()

return function()
	local desc = wrap_key  "creative_mode_flight_description"
	if DebugGetIsDevBuild() then
		desc = GameTextGetTranslatedOrNot( desc ) .. "\n" .. get_text  "creative_mode_flight_note_dev_exe"
	end
	gui_elements.button_setting_toggle( module_path .. "button.png", "creative_mode_flight", nil, desc )
end
