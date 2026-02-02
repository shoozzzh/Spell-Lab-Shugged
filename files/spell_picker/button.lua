local module_path = this_folder()

return function()
	local changed, is_active = menus:toggle_button( "spell_picker", module_path .. "button.png", "spell_picker" )
	if changed and is_active and held_wand and mod_setting.get "quick_spell_picker" then
		mod_setting.set( "show_wand_edit_panel", true )
	end
end
