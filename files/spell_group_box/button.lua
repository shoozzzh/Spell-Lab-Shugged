do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/spell_groups.png", PICKERS.SpellGroupBox, "spell_group_box", function( showing )
	if showing and held_wand then
		mod_setting_set( "show_wand_edit_panel", true )
	end
end )
