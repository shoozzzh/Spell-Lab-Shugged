do_picker_button( "mods/spell_lab_shugged/files/gui/buttons/edit_wands.png", PICKERS.SpellPicker, "spell_picker", function( showing )
	if showing and held_wand and mod_setting_get( "quick_spell_picker" ) then
		mod_setting_set( "show_wand_edit_panel", true )
	end
end )
