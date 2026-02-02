local module_path = module_path()

return function()
	local changed, is_active = menus:toggle_button( "spell_group_box", module_path .. "button.png" )
	if changed and is_active and held_wand then
		mod_setting.set( "show_wand_edit_panel", true )
	end
end
