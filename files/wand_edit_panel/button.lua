local module_path = this_folder()

return function()
	local gif_mode = mod_setting.get "gif_mode"
	local description = wrap_key( gif_mode and "gif_mode_disable" or "gif_mode_enable" )
	local _, right_click = gui_elements.button_setting_toggle(
		module_path .. "button.png", "show_wand_edit_panel", "wand_edit_panel", description )
	if right_click then
		sound_button_clicked()
		mod_setting.set( "gif_mode", not gif_mode )
	end
end
