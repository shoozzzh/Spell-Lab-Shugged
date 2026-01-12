do
	local gif_mode = mod_setting_get( "gif_mode" )
	local description = wrap_key( gif_mode and "gif_mode_disable" or "gif_mode_enable" )
	local left_click, right_click = gui_elements.flag_toggle_button( "mods/spell_lab_shugged/files/gui/buttons/show_wand_edit_panel.png", "show_wand_edit_panel", "wand_edit_panel", nil, description )
	if right_click then
		sound_button_clicked()
		mod_setting_set( "gif_mode", not gif_mode )
	end
end